-- mod-version:3 --lite-xl 2.1 --priority:10

-- these are write-xl's basic startup settings.
-- you can modify these how you wish.

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local DocView = require "core.docview"
local command = require "core.command"
local TreeView = require "plugins.treeview"
local keymap = require "core.keymap"
local EmptyView = require "core.emptyview"


local function draw_text(x, y, color)
  local th = style.big_font:get_height()
  local dh = 2 * th + style.padding.y * 2
  local x1, y1 = x, y + (dh - th) / 2
  local xv = x1
  local title = "Write XL"
  local version = "version git"
  local title_width = style.big_font:get_width(title)
  local version_width = style.font:get_width(version)
  if version_width > title_width then
    version = VERSION
    version_width = style.font:get_width(version)
    xv = x1 - (version_width - title_width)
  end
  x = renderer.draw_text(style.big_font, title, x1, y1, color)
  renderer.draw_text(style.font, version, xv, y1 + th, color)
  x = x + style.padding.x
  renderer.draw_rect(x, y, math.ceil(1 * SCALE), dh, color)
  local lines = {
    { fmt = "%s to run a command", cmd = "core:find-command" },
    { fmt = "%s to open a file from the project", cmd = "core:find-file" },
    { fmt = "%s to change project folder", cmd = "core:change-project-folder" },
    { fmt = "%s to open a project folder", cmd = "core:open-project-folder" },
  }
  th = style.font:get_height()
  y = y + (dh - (th + style.padding.y) * #lines) / 2
  local w = 0
  for _, line in ipairs(lines) do
    local text = string.format(line.fmt, keymap.get_binding(line.cmd))
    w = math.max(w, renderer.draw_text(style.font, text, x + style.padding.x, y, color))
    y = y + th + style.padding.y
  end
  return w, dh
end

function EmptyView:draw()
  self:draw_background(style.background)
  local w, h = draw_text(0, 0, { 0, 0, 0, 0 })
  local x = self.position.x + math.max(style.padding.x, (self.size.x - w) / 2)
  local y = self.position.y + (self.size.y - h) / 2
  draw_text(x, y, { 0, 0, 0, 255 })
end

local document_width = 900 * SCALE

core.reload_module('colors.word')

config.plugins.autocomplete = false
TreeView.visible = false
config.highlight_current_line = false
if system.get_file_info(USERDIR .. "/words") then
  config.plugins.spellcheck.dictionary_file = USERDIR .. "/words"
elseif system.get_file_info(DATADIR .. "/words") then
  config.plugins.spellcheck.dictionary_file = DATADIR .. "/words"
end
config.plugins.language_c = false
config.plugins.language_cpp = false
config.plugins.language_css = false
config.plugins.language_html = false
config.plugins.language_js = false
config.plugins.language_python = false
config.plugins.language_xml = false
config.plugins.linewrapping = {
  enable_by_default = true,
  mode = "word",
  guide = false,
  indent = false,
  width_override = function(docview) return math.min(document_width, docview.size.x) end
}
config.plugins.tag_highlight = false
config.transitions = false

function DocView:draw_line_gutter(line, x, y, width)
  if self.size.x > document_width then
    renderer.draw_rect(x + width - style.padding.x, y, 1, self.size.y, style.scrollbar2)
    renderer.draw_rect(x + width + style.padding.x + document_width, y, 1, self.size.y, style.scrollbar2)
  end
end
function DocView:get_gutter_width() return math.max(self.size.x - document_width, 0) / 2 end

command.add(nil, {
  ["files:delete"] = function()
    core.command_view:enter("Delete file path", function(text)
      local success, err, path = common.rm(text)
      if not success then
        core.error("cannot delete file %q: %s", path, err)
      end
    end)
  end
})

keymap.add {
  ["ctrl+h"] = "core:open-log",
  ["ctrl+shift+y"] = "synonyms:replace",
  ["ctrl+shift+t"] = "spell-check:replace",
  ["ctrl+q"] = { "command:escape", "doc:select-none", "dialog:select-no" }
}
