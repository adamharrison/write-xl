-- mod-version:3 --lite-xl 2.1
-- Plugin designed to make it easy to edit single files, push them, and load them from multiple machines.
-- Designed as part of the write-xl project.

local core = require "core"
local keymap = require "core.keymap"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

local git = require "libraries.libgit2"

config.plugins.gitsave = common.merge({
  -- if true, checks on startup to see if the primary project is a git repo, and if so, perform a fetch and merge.
  auto_pull = false,
  -- the username to authenticate with
  username = nil,
  -- the password to authenticate with
  password = nil,
  -- the email to use on commits
  email = nil,
  -- the name to use on commits
  name = nil
}, config.plugins.gitsave)

local function fetch_and_merge(repo, options)
  options = options or {}
  if not config.plugins.gitsave.username or not config.plugins.gitsave.password then
    error("Requires a username and password, please set them with config.plugins.gitsave.username and config.plugins.gitsave.password.")
  end
  local remote_url = options.remote_url
  local remote_name = options.remote_name or "origin"
  local remote_branch_name = options.remote_branch_name or "master"
  local local_branch_name = options.local_branch_name or "master"
  local remote = repo:remote(remote_name, remote_url)
  core.add_thread(function()
    core.log("Fetching git remote origin...")
    remote:fetch()
    core.log("Successfully fetched git remote origin.")
    if not repo:branch(local_branch_name, "refs/remotes/origin/" .. remote_branch_name) then
      local merged = repo:merge("refs/remotes/origin/" .. remote_branch_name)
      if merged and type(merged) == "string" then
        core.log("Performed fast-forward to " .. merged .. ".")
        repo:reset(merged, "hard")
      elseif merged then
        local commit_id = repo:commit("Merged remote.")
        repo:reset(commit_id, "hard")
        core.log("Performed merge, committed, and reset to " .. commit_id .. ".")
      else
        core.log("No merge required, up-to-date.")
      end
    else
      core.log("Set HEAD to origin HEAD.")
      repo:reset("HEAD", "hard")
    end
  end)
end

local extant_gits = {}

local function load_repo_for_directory(directory)
  if system.get_file_info(directory .. PATHSEP .. ".git") then
    extant_gits[directory] = extant_gits[directory] or git.open(directory, config.plugins.gitsave)
    return extant_gits[directory]
  else
    local dir = common.dirname(directory)
    if dir then return load_repo_for_directory(dir) end
  end
  return nil
end

if config.plugins.gitsave.auto_pull then
  local repo = load_repo_for_directory(system.absolute_path("."))
  if repo then fetch_and_merge(repo) end
end

local function suggest_directory(text)
  text = common.home_expand(text)
  local basedir = common.dirname(core.project_dir)
  return common.home_encode_list((basedir and text == basedir .. PATHSEP or text == "") and
    core.recent_projects or common.dir_path_suggest(text))
end

local function ask_repo_for_directory(clone)
  local file = core.active_view and core.active_view:is(DocView) and core.active_view.filename
  core.command_view:enter("Directory to initialize?", {
    text = file and common.dirname(docview.filename) or "",
    submit = function(directory)
      local info = system.get_file_info(directory)
      if not info or info.type ~= "dir" then error("Please select a directory.") end
      if system.get_file_info(directory .. PATHSEP .. ".git") then error("This directory already has a git repository.") end
      if not clone and load_repo_for_directory(directory) then error("This directory is inside an existing git repository.") end
      core.command_view:enter("Remote to add?", {
        submit = function(remote_url)
          extant_gits[directory] = git.open(directory, config.plugins.gitsave)
          core.log("Succesfully added repository to %s.", directory)
          if clone then fetch_and_merge(extant_gits[directory], { remote_url = remote_url }) end
        end
      })
    end,
    suggest = suggest_directory
  })
end

command.add(nil, {
  ["gitsave:init"] = function()
    ask_repo_for_directory()
  end,
  ["gitsave:clone"] = function()
    ask_repo_for_directory(true)
  end
})


command.add(function()
  local file = core.active_view and core.active_view.doc and core.active_view.doc.abs_filename
  if not file then
    local repo = load_repo_for_directory(system.absolute_path("."))
    return true, repo
  end
  local repo = load_repo_for_directory(common.dirname(file))
  return file and repo, repo
end, {
  ["gitsave:push"] = function(repo)
    local doc = core.active_view and core.active_view.doc
    if not config.plugins.gitsave.name or not config.plugins.gitsave.email then
      error("Requires a name and email, please set them with config.plugins.gitsave.name and config.plugins.gitsave.email")
    end
    if repo:add(doc.filename) then
      core.command_view:enter("Commit message? (blank is OK)", {
        submit = function(text)
          local remote = repo:remote("origin")
          repo:commit(text or ("Automatic GitSave Commit " + os.date("%Y-%m-%dT%H:%M:%S")))
          core.log("Pushing to remote for %s.", doc.filename .. "...")
          local local_branch_name = config.plugins.gitsave.local_branch_name or "master"
          core.add_thread(function()
            remote:push("refs/heads/" .. local_branch_name)
            core.log("Pushed changes to remote for %s.", doc.filename)
          end)
        end
      })
    else
      core.log("No changes detected on %s.", doc.filename)
    end
  end,
  ["gitsave:fetch"] = function(repo)
    fetch_and_merge(repo)
  end,
  ["gitsave:save"] = function()
    local doc = core.active_view and core.active_view.doc
    if doc then
      command.perform((not doc.filename or doc:is_dirty()) and "doc:save" or "gitsave:push")
    end
  end
})

keymap.add_direct {
  ["ctrl+s"] = { "gitsave:save", "doc:save" }
}
