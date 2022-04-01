-- these are write-xl's basic startup settings.
-- you can modify these how you wish.

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local DocView = require "core.docview"

local document_width = 900

core.reload_module('colors.document')

config.plugins.autocomplete = false
config.plugins.treeview = false
config.highlight_current_line = false
config.plugins.linewrapping = { 
  enable_by_default = true, 
  mode = "word", 
  guide = false,
  width_override = function(docview) return math.min(document_width, docview.size.x) end
}

function DocView:draw_line_gutter(line, x, y, width) 
  if self.size.x > document_width then
    renderer.draw_rect(x + width - style.padding.x, y, 1, self.size.y, style.scrollbar2)
    renderer.draw_rect(x + width + style.padding.x + document_width, y, 1, self.size.y, style.scrollbar2)
  end
end
function DocView:get_gutter_width() return math.max(self.size.x - document_width, 0) / 2 end
config.plugins.tag_highlight = false
