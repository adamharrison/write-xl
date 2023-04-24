-- mod-version:3 -- lite-xl 2.1
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local keymap = require "core.keymap"
local StatusView = require "core.statusview"

config.plugins.sessionclock = common.merge({
  inactive_time = 30
}, config.plugins.sessionclock)

local time = ""

local start_time = os.time()
local total_active_time = 0

local last_action = system.get_time()

local old_on_event = core.on_event
function core.on_event(type, ...)
  if type == "keypressed" or type == "mousepressed" or type == "mousewheel" then
    if last_action then
      total_active_time = total_active_time + system.get_time() - last_action
    end
    last_action = system.get_time()
  end
  return old_on_event(type, ...)
end

local session_clock_display = nil
local active_session_clock_display = nil

local function format_duration(duration)
  return string.format("%02d:%02d", math.floor(duration / 3600), math.floor(duration / 60) % 60)
end

local function update_clocks()
  session_clock_display = format_duration(os.time() - start_time)
  active_session_clock_display = format_duration((last_action and (system.get_time() - last_action) or 0) + total_active_time)
end

update_clocks()

core.add_thread(function()
  while true do
    if last_action and (system.get_time() - last_action > config.plugins.sessionclock.inactive_time) then
      total_active_time = total_active_time + math.min(system.get_time() - last_action, config.plugins.sessionclock.inactive_time)
      last_action = nil
    end
    update_clocks()
    coroutine.yield(1)
  end
end)


core.status_view:add_item({
  name = "status:session-clock",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    return {style.accent, active_session_clock_display .. " / " .. session_clock_display}
  end,
  position = -1,
  separator = core.status_view.separator2
})
