-- mod-version:3 --lite-xl 2.1

local core = require "core"
local keymap = require "core.keymap"
local command = require "core.command"
local common = require "core.common"
local git = require "plugins.gitsave.native"

config.plugins.gitsave = common.merge({
  repository_root = system.absolute_path("."),
  -- if true, checks to see if the primary project is a git repo, and if so, perform a fetch.
  auto_open_and_pull = true,
  -- the username to authenticate with
  username = nil,
  -- the password to authenticate with
  password = nil,
  -- the email to use on commits
  email = nil,
  -- the name to use on commits
  name = nil,
  
}, config.plugins.gitsave)

local git = require "plugins.gitsave.native"
local function load_repo()
  return git.open(config.plugins.gitsave.repository_root, config.plugins.gitsave)
end
local repo = nil

local function fetch_and_merge(repo)
  local remote = repo:remote("origin")
  remote:fetch(function()
    local merged = repo:merge("refs/remotes/origin/master")
    if merged and type(merged) == "string" then
      repo:reset(merged, "hard")
    else if merged then
      local commit_id = repo:commit("Merged remote.")
      repo:reset(commit_id, "hard")
    end
  end)
end

if config.plugins.gitsave.auto_open_and_pull and system.get_file_info(".git") then
  repo = load_repo()
  fetch_and_merge(repo)
end

command.add(DocView, {
  ["gitsave:init"] = function()
    repo = load_repo()
  end,
  ["gitsave:fetch"] = function() 
    fetch_and_merge(repo)
  end,
  ["gitsave:push"] = function() 
    local doc = core.active_view and core.active_view.doc
    if repo:add(doc.abs_filename) then
      core.command_view:enter("Commit message? (blank is OK)", function(text)
        local remote = repo:remote("origin")
        repo:commit(text or ("Automatic GitSave Commit " + os.date("%Y-%m-%dT%H:%M:%S")))
        remote:push("refs/heads/master", function ()
          core.log("Pushed changes to remote for %s.", doc.filename)
        end)
      end)
    else
      core.log("No changes detected on %s.", doc.filename)
    end
  end,
  ["gitsave:check-push-to-git"] = function() 
    local doc = core.active_view and core.active_view.doc
    if doc then
      if (not doc.filename or doc:is_dirty()) then
        command.perform("doc:save")
      else
        command.perform("gitsave:push")
      end
    end
  end
})

keymap.add_direct {
  ["ctrl+s"] = "gitsave:save-to-git"
}
