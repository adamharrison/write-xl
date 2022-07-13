-- mod-version:3 --lite-xl 2.1
-- Plugin designed to make it easy to edit single files, push them, and load them from multiple machines.
-- Designed as part of the write-xl project.

local core = require "core"
local keymap = require "core.keymap"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.gitsave = common.merge({
  repository_root = system.absolute_path("."),
  remote_branch_name = "master",
  local_branch_name = "master",
  -- should be set in your project config, if you want to init correctly. if already set in .git, it'll use that.
  remote_url = nil,
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

local git = PLATFORM == "Android" and system.load_native_plugin("gitsave", "libgitsave_native.so") or require "plugins.gitsave.libgitsave_native"
local function load_repo()
  return git.open(config.plugins.gitsave.repository_root, config.plugins.gitsave)
end
local repo = nil

local function fetch_and_merge(repo)
  local remote = repo:remote("origin", config.plugins.gitsave.remote_url)
  remote:fetch(function()
    core.log("Successfully fetched git remote origin.")
    if not repo:branch(config.plugins.gitsave.local_branch_name, "refs/remotes/origin/" .. config.plugins.gitsave.remote_branch_name) then
      local merged = repo:merge("refs/remotes/origin/" .. config.plugins.gitsave.remote_branch_name)
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

if system.get_file_info(".git") then
  repo = load_repo()
  if config.plugins.gitsave.auto_pull then
    fetch_and_merge(repo)
  end
end

command.add(nil, {
  ["gitsave:init"] = function()
    repo = load_repo()
  end,
  ["gitsave:fetch"] = function() 
    -- Determine if we actually have the username/password and remote_url configured. If not, then prompt for them.
    fetch_and_merge(repo)
  end,
  ["gitsave:push"] = function() 
    local doc = core.active_view and core.active_view.doc
    if repo:add(doc.filename) then
      core.command_view:enter("Commit message? (blank is OK)", function(text)
        local remote = repo:remote("origin")
        repo:commit(text or ("Automatic GitSave Commit " + os.date("%Y-%m-%dT%H:%M:%S")))
        core.log("Pushing to remote for %s.", doc.filename .. "...")
        remote:push("refs/heads/" .. config.plugins.gitsave.local_branch_name, function ()
          core.log("Pushed changes to remote for %s.", doc.filename)
        end)
      end)
    else
      core.log("No changes detected on %s.", doc.filename)
    end
  end
})

command.add(DocView, {
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
