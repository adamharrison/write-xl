-- mod-version:3 -- lite-xl 2.1
local doc = require "core.doc"
local common = require "core.common"
local DocView = require "core.docview"

local tag_color_list = {
  { common.color "#ff0000" },
  { common.color "#00ff00" },
  { common.color "#0000ff" },
  { common.color "#ffff00" },
  { common.color "#00ffff" }
}

local function compute_tags(doc, text)
  doc.tag_cache = doc.tag_cache or {}
  if not text then
      text = ""
      for i = 1, math.min(#doc.lines, 100) do 
        text = text .. doc.lines[i]
      end
  end
  local s, e = 0
  while s and s < #text do
    s, e = text:find("%[([^%]]+)%]", s + 1)
    if s then
      local tag = text:sub(s + 1, e - 1)
      if not doc.tag_cache[tag] then
        local total = 0
        for i, v in pairs(doc.tag_cache) do total = total + 1 end
        doc.tag_cache[tag] = tag_color_list[total] or { math.random(255), math.random(255), math.random(255) }
      end
    end
  end
end


local old_draw_line_body = DocView.draw_line_body
function DocView:draw_line_body(line, x, y)
  local s, e = 0
  local color = nil
  while s and s < #self.doc.lines[line] do
    s, e = self.doc.lines[line]:find("%[([^%]]+)%]", s + 1)
    if s then
      local tag = self.doc.lines[line]:sub(s + 1, e - 1)
      if self.doc.tag_cache[tag] then
        color = self.doc.tag_cache[tag]
        break
      end
    end
  end
  renderer.draw_rect(x, y, self:get_col_x_offset(line, #self.doc.lines[line]), self:get_line_height(line), color)
  old_draw_line_body(self, line, x, y)
end

local old_on_text_input = DocView.on_text_input
function DocView:on_text_input(text)
  old_on_text_input(self, text)
  compute_tags(doc, text)
end

local old_new = DocView.new
function DocView:new(doc)
  old_new(self, doc)
  compute_tags(doc)
end
