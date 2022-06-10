-- mod-version:3 -- lite-xl 2.1

local core = require "core"
local style = require "core.style"
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"
local common = require "core.common"
local DocView = require "core.docview"
local StatusView = require "core.statusview"
local CommandView = require "core.commandview"
local Doc = require "core.doc"


local chapters = common.merge({
  
}, config.plugins.chapters)


local function compute_locations(doc, minline, maxline)
  minline = minline or 1
  maxline = maxline or #doc.lines
  for i = minline, maxline do
    local has, _, idx = doc.lines[i]:find("^%s*#*%s*Chapter%s+(%d+)")
    if has then
      doc.chapter_lines[tonumber(idx)] = i
    end
  end
end

local function get_chapter(doc, line)
    if not doc.chaper_lines or (not line and doc.chapter_current) then return doc.chapter_current end
    line = line or doc:get_selection() 
    for i, v in ipairs(doc.chapter_lines) do
      if line < v then return math.max(i - 1, 1) end
    end
    return #doc.chapter_lines
end

local old_new = DocView.new
function DocView:new(doc, ...)
  old_new(self, doc, ...)
  doc.chapter_lines = {}
  compute_locations(doc)
end

local old_set_selections = Doc.set_selections
function Doc:set_selections(idx, line1, col1, ...)
  old_set_selections(self, idx, line1, col1, ...)
  self.chapter_current = get_chapter(self, line1)
end

function chapters.jump_to(docview, chapter)
  if docview.doc.chapter_lines[chapter] then
    docview.doc:set_selection(docview.doc.chapter_lines[chapter], #docview.doc.lines[docview.doc.chapter_lines[chapter]])
    docview:update()
    local ox, oy = docview:get_content_offset()
    local x, y = docview:get_line_screen_position(docview.doc.chapter_lines[chapter])
    docview.scroll.to.y = math.max(0, y - oy)
  end
end


local old_doc_insert = Doc.raw_insert
function Doc:raw_insert(line, col, text, undo_stack, time)
  local old_lines = #self.lines
  old_doc_insert(self, line, col, text, undo_stack, time)
  if old_lines ~= #self.lines then 
    local start = get_chapter(self, line)
    if start then
      for i = start + 1, #self.chapter_lines do
        self.chapter_lines[i] = self.chapter_lines[i] + (#self.lines - old_lines)
      end
    end
  end
end

local old_doc_remove = Doc.raw_remove
function Doc:raw_remove(line1, col1, line2, col2, undo_stack, time)
  local old_lines = #self.lines
  old_doc_remove(self, line1, col1, line2, col2, undo_stack, time)
  if old_lines ~= #self.lines then 
    local start = get_chapter(self, line1)
    if start then
      for i = start + 1, #self.chapter_lines do
        self.chapter_lines[i] = self.chapter_lines[i] + (#self.lines - old_lines)
      end
    end
  end
end


local function predicate_docview()
  return  core.active_view:is(DocView)
    and not core.active_view:is(CommandView)
end

core.status_view:add_item(
  predicate_docview,
  "chapters:display",
  StatusView.Item.RIGHT,
  function()
    local dv = core.active_view
    local chapter = get_chapter(core.active_view.doc)
    if not chapter then return {} end
    return { "Chapter " .. chapter }
  end
)


command.add("core.docview", {
  ["chapters:jump"] = function()
    core.command_view:enter("Jump to Chapter", function(text)
      chapters.jump_to(core.active_view, tonumber(text))
    end)
  end,
  ["chapters:previous"] = function()
    chapters.jump_to(core.active_view, get_chapter(core.active_view.doc) - 1)
  end,
  ["chapters:current"] = function()
    chapters.jump_to(core.active_view, get_chapter(core.active_view.doc))
  end,
  ["chapters:next"] = function()
    chapters.jump_to(core.active_view, get_chapter(core.active_view.doc) + 1)
  end
})

keymap.add {
  ["alt+pagedown"] = "chapters:next",
  ["alt+pageup"] = "chapters:previous",
  ["alt+home"] = "chapters:current"
}

return chapters
