#include <git2.h>
#include <string.h>
#if LITE_XL_PLUGIN
  #include "lite_xl_plugin_api.h"
#else
  #include <lua.h>
  #include <lauxlib.h>
  #include <lualib.h>
#endif

/* Contains the following functions:
  git init
  git remote add
  git fetch
  git reset
  git branch
  git merge
  git add
  git commit
  git push
  
  Test Cases:
  
    * init a repo
    * add an https test origin on github
    * git fetch that repo
    * merge the remote into HEAD
    * complete
  
*/

#define API_GIT_REPO "Git.Repo"
#define API_GIT_REMOTE "Git.Repo.Remote"

static const char* git_error_last_string() { 
  const git_error* last_error = git_error_last();
  return last_error->message;
}

static git_commit* git_retrieve_commit(lua_State* L, git_repository* repository, const char* commit_name) {
  git_oid commit_id;
  git_commit* commit;
  if (git_reference_name_to_id(&commit_id, repository, commit_name)) {
    luaL_error(L, "git reference lookup error: %s", git_error_last_string());
    return NULL;
  }
  if (git_commit_lookup(&commit, repository, &commit_id)) {
    luaL_error(L, "git commit lookup error: %s", git_error_last_string());
    return NULL;
  }
  return commit;
}

static void* luaL_checkinternal(lua_State *L, int idx, const char* type) {
  luaL_checktype(L, idx, LUA_TTABLE);
  luaL_checktype(L, idx, LUA_TTABLE);
  lua_getfield(L, idx, "internal");
  void* internal = lua_touserdata(L, -1);
  if (!internal) {
    luaL_error(L, "invalid %s", type);
    return NULL;
  }
  lua_pop(L, 1);
  return internal;
}

static int f_git_init(lua_State* L) {
  git_repository* repository;
  if (git_repository_init(&repository, luaL_checkstring(L, 1), 0) != 0)
    return luaL_error(L, "git init error: %s", git_error_last_string());
  int has_credentials = lua_gettop(L) > 1;
  lua_newtable(L);
  luaL_setmetatable(L, API_GIT_REPO);
  lua_pushlightuserdata(L, repository);
  lua_setfield(L, -2, "internal");
  if (has_credentials) {
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "credentials");
  }
  return 1;
}


static int f_git_open(lua_State* L) {
  git_repository* repository;
  if (git_repository_open(&repository, luaL_checkstring(L, 1)) != 0 && git_repository_init(&repository, luaL_checkstring(L, 1), 0) != 0)
    return luaL_error(L, "git open error: %s", git_error_last_string());
  int has_credentials = lua_gettop(L) > 1;
  lua_newtable(L);
  luaL_setmetatable(L, API_GIT_REPO);
  lua_pushlightuserdata(L, repository);
  lua_setfield(L, -2, "internal");
  if (has_credentials) {
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "credentials");
  }
  return 1;
}

static int f_git_repo_create_load_remote(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* name = luaL_checkstring(L, 2);
  const char* url = luaL_checkstring(L, 3);
  lua_newtable(L);
  luaL_setmetatable(L, API_GIT_REMOTE);
  git_remote* remote;
  if (git_remote_lookup(&remote, repository, name) && git_remote_create(&remote, repository, name, url))
    return luaL_error(L, "git remote add error: %s", git_error_last_string());
  lua_pushlightuserdata(L, remote);
  lua_setfield(L, -2, "internal");
  lua_pushvalue(L, 1);
  lua_setfield(L, -2, "repo");
  return 1;
}

static int f_git_repo_create_load_branch(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* branch_name = luaL_checkstring(L, 2);
  const char* commit_name = luaL_checkstring(L, 3);
  git_reference* reference;
  
  int value = git_branch_lookup(&reference, repository, branch_name, GIT_BRANCH_LOCAL);
  if (value == GIT_EINVALIDSPEC)
    return luaL_error(L, "git branch lookup error: %s", git_error_last_string());
  if (value == GIT_ENOTFOUND) {
    git_commit* commit = git_retrieve_commit(L, repository, commit_name);
    value = git_branch_create(&reference, repository, branch_name, commit, 1);
    git_commit_free(commit);
    if (value)
      return luaL_error(L, "git branch create error: %s", git_error_last_string());
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }
  git_reference_free(reference);
  return 1;
}


struct credentials {
  const char* username;
  const char* password;
};

static int credential_callback(git_credential** out, const char* url, const char* username_from_url, unsigned int allowed_types, void* payload) {
  struct credentials* credentials = payload;
  git_credential_userpass_plaintext_new(out, credentials->username, credentials->password);
  return 0;
}

static int f_git_remote_fetch(lua_State* L) {
  git_remote* remote = luaL_checkinternal(L, 1, API_GIT_REMOTE);
  lua_getfield(L, 1, "repo");
  lua_getfield(L, -1, "credentials");
  luaL_checktype(L, -1, LUA_TTABLE);
  lua_getfield(L, -1, "username");
  lua_getfield(L, -2, "password");
  struct credentials credentials = { luaL_checkstring(L, -2), luaL_checkstring(L, -1) };
  git_fetch_options fetch_opts = GIT_FETCH_OPTIONS_INIT;
  fetch_opts.callbacks.credentials = credential_callback;
  fetch_opts.callbacks.payload = &credentials;
  if (git_remote_fetch(remote, NULL, &fetch_opts, NULL))
    return luaL_error(L, "git remote fetch error: %s", git_error_last_string());
  if (lua_type(L, 2) == LUA_TFUNCTION) {
    lua_pushvalue(L, 2);
    lua_call(L, 0, 0);
  }
  return 0;
}

static int f_git_remote_push(lua_State* L) {
  git_remote* remote = luaL_checkinternal(L, 1, API_GIT_REMOTE);
  const char* branch = luaL_checkstring(L, 2);
  lua_getfield(L, 1, "repo");
  lua_getfield(L, -1, "credentials");
  luaL_checktype(L, -1, LUA_TTABLE);
  lua_getfield(L, -1, "username");
  lua_getfield(L, -2, "password");
  struct credentials credentials = { luaL_checkstring(L, -2), luaL_checkstring(L, -1) };
  git_push_options push_opts = GIT_PUSH_OPTIONS_INIT;
  push_opts.callbacks.credentials = credential_callback;
  push_opts.callbacks.payload = &credentials;
  git_strarray array;
  array.strings = &branch;
  array.count = 1;
  if (git_remote_push(remote, &array, &push_opts))
    return luaL_error(L, "git remote push error: %s", git_error_last_string());
  if (lua_type(L, 3) == LUA_TFUNCTION) {
    lua_pushvalue(L, 3);
    lua_call(L, 0, 0);
  }
  return 0;
}

static int f_git_repo_reset(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* commit_name = luaL_checkstring(L, 2);
  const char* type = luaL_checkstring(L, 3);
  git_commit* commit = git_retrieve_commit(L, repository, commit_name);
  git_reset_t reset_type = GIT_RESET_SOFT;
  if (strcmp(type, "mixed") == 0)
    reset_type = GIT_RESET_MIXED;
  else if (strcmp(type, "hard") == 0)
    reset_type = GIT_RESET_HARD;
  int result = git_reset(repository, (git_object*)commit, reset_type, NULL);
  git_commit_free(commit);
  if (result)
    return luaL_error(L, "git reset error: %s", git_error_last_string());
  return 0;
}


// returns a string if a fast-forward (the commit to use), true if a merge is required, false if no merge required.
static int f_git_repo_merge(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* commit_name = luaL_checkstring(L, 2);
  git_oid commit_id;
  git_annotated_commit* commit;
  git_merge_options merge_options;
  git_merge_options_init(&merge_options, GIT_MERGE_OPTIONS_VERSION);
  git_checkout_options checkout_options;
  git_checkout_options_init(&checkout_options, GIT_CHECKOUT_OPTIONS_VERSION);
  if (git_reference_name_to_id(&commit_id, repository, commit_name))
    return luaL_error(L, "git reference lookup error: %s", git_error_last_string());
  // Determine if a fast-forward. If it is, report 0. If we need to actually merge, 
  git_oid merge_base, master_id;
  if (git_reference_name_to_id(&master_id, repository, "refs/heads/master"))
    return luaL_error(L, "git reference lookup error: %s", git_error_last_string());
  if (git_merge_base(&merge_base, repository, &master_id, &commit_id))
    return luaL_error(L, "git merge base error: %s", git_error_last_string());
  // If merge base is the same as master, this is a fast forward, and we should return the commit id of the merging in branch.
  if (memcmp(merge_base.id, commit_id.id, sizeof(merge_base.id)) == 0) {
    lua_pushboolean(L, 0);
    return 1;  
  // If merge base is the merging in commit, we've already merged it.
  } else if (memcmp(merge_base.id, master_id.id, sizeof(merge_base.id)) == 0) {
    lua_pushlstring(L, commit_id.id, sizeof(commit_id.id));
    return 1;
  }
  if (git_annotated_commit_lookup(&commit, repository, &commit_id))
    return luaL_error(L, "git commit lookup error: %s", git_error_last_string());
  int result = git_merge(repository, (const git_annotated_commit**)&commit, 1, &merge_options, &checkout_options);
  git_annotated_commit_free(commit);
  if (result)
    return luaL_error(L, "git merge error: %s", git_error_last_string());
  git_index* index;
  git_repository_index(&index, repository);    
  if (git_index_has_conflicts(index)) {
    git_index_free(index);
    return luaL_error(L, "git merge has conflicts");
  } 
  lua_pushboolean(L, 1);
  git_index_free(index);
  return 1;
}



static int f_git_repo_commit(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* commit_message = luaL_checkstring(L, 2);
  git_signature *me = NULL;
  git_index *index;
  lua_getfield(L, 1, "credentials");
  lua_getfield(L, -1, "email");
  const char* email = luaL_checkstring(L, -1);
  lua_getfield(L, -2, "name");
  const char* name = luaL_checkstring(L, -1);
  int error = git_signature_now(&me, name, email);
  git_commit* commit = git_retrieve_commit(L, repository, "HEAD");
  git_oid new_commit_id;
  git_oid tree_id;
  git_tree* tree;
  if (git_repository_index(&index, repository))
    return luaL_error(L, "git index error: %s", git_error_last_string());
  if (git_index_write_tree(&tree_id, index))
    return luaL_error(L, "git write tree error: %s", git_error_last_string());
  if (git_tree_lookup(&tree, repository, &tree_id))
    return luaL_error(L, "git tree lookup error: %s", git_error_last_string());
  error = git_commit_create(
    &new_commit_id,
    repository,
    "HEAD",                      /* name of ref to update */
    me,                          /* author */
    me,                          /* committer */
    "UTF-8",                     /* message encoding */
    commit_message,              /* message */
    tree,                        /* root tree */
    1,                           /* parent count */
    (const git_commit**)&commit);                    /* parents */
  if (error)
    return luaL_error(L, "git commit error: %s", git_error_last_string());
  lua_pushlstring(L, new_commit_id.id, sizeof(new_commit_id.id));
  return 1;
}

static int f_git_repo_lookup(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* commit_name = luaL_checkstring(L, 2);
  git_oid commit_id;
  if (git_reference_name_to_id(&commit_id, repository, commit_name))
    return luaL_error(L, "git reference lookup error: %s", git_error_last_string());
  lua_pushlstring(L, commit_id.id, sizeof(commit_id.id));
  return 1;
}

static int matched_path_callback(const char *path, const char *matched_pathspec, void *L) {
  lua_pushstring(L, path);
  return 0;
}

static int f_git_repo_add(lua_State* L) {
  git_repository* repository = luaL_checkinternal(L, 1, API_GIT_REPO);
  const char* path = luaL_checkstring(L, 2);
  
  unsigned int flags = 0;
  if (git_status_file(&flags, repository, path))
    return luaL_error("git status error: %s", git_error_last_string());
  if (!(flags & (GIT_STATUS_WT_MODIFIED | GIT_STATUS_WT_DELETED | GIT_STATUS_WT_NEW)))
    return 0;
    
  git_tree *tree;
  git_commit *commit;
  git_index *index;
  if (git_repository_index(&index, repository))
    return luaL_error(L, "git index error: %s", git_error_last_string());
  git_strarray array;
  array.strings = (char**)&path;
  array.count = 1;
  int top = lua_gettop(L);
  int value = git_index_add_all(index, &array, GIT_INDEX_ADD_FORCE, matched_path_callback, L);
  if (!value)
    value = git_index_write(index);
  git_index_free(index);
  if (value)
    return luaL_error(L, "git add error: %s", git_error_last_string());
  return lua_gettop(L) - top;
}

static int f_git_repo_gc(lua_State* L) {
  lua_getfield(L, -1, "internal");
  if (lua_touserdata(L, -1))
    git_repository_free(lua_touserdata(L, -1));
  return 0;
}

static int f_git_remote_gc(lua_State* L) {
  lua_getfield(L, 1, "internal");
  if (lua_touserdata(L, -1))
    git_remote_free(lua_touserdata(L, -1));
  return 0;
}

static int f_git_gc(lua_State* L) {
  git_libgit2_shutdown();
  return 0;
}

luaL_Reg remote_metatable[] = {
  { "__gc",       f_git_remote_gc },
  { "push",       f_git_remote_push },
  { "fetch",      f_git_remote_fetch },
  { NULL, NULL }
};

static luaL_Reg repo_metatable[] = {
  { "__gc",       f_git_repo_gc },
  { "commit",     f_git_repo_commit },
  { "add",        f_git_repo_add },
  { "remote",     f_git_repo_create_load_remote },
  { "branch",     f_git_repo_create_load_branch },
  { "reset",      f_git_repo_reset },
  { "merge",      f_git_repo_merge },
  { "lookup",     f_git_repo_lookup },
  { NULL, NULL }
};

static luaL_Reg plugin_api[] = {
  { "__gc",       f_git_gc },
  { "open",       f_git_open },
  { NULL, NULL }
};


#if LITE_XL_PLUGIN
int luaopen_lite_xl_native(lua_State* L, void* XL) {
  lite_xl_plugin_init(XL);
#else 
int luaopen_native(lua_State* L) {
#endif
  git_libgit2_init();
  luaL_newmetatable(L, API_GIT_REPO);
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  luaL_setfuncs(L, repo_metatable, 0);
  luaL_newmetatable(L, API_GIT_REMOTE);
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  luaL_setfuncs(L, remote_metatable, 0);
  luaL_newlib(L, plugin_api);
  lua_pushvalue(L, -1);
  lua_setmetatable(L, -2);
  return 1;
}
