-- mod-version:3 -- lite-xl 2.1

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local command = require "core.command"
local DocView = require "core.docview"

local function doc() return core.active_view.doc end

local function toggle_selection(delimiter, idx, line1, col1, line2, col2)
  local inverted, remove, fline, fcol, lline, lcol = line1 > line2 or (line1 == line2 and col1 > col2)
  if inverted then 
    fline, fcol = inverted and line2 or line1, inverted and col2 or col1
    lline, lcol = inverted and line1 or line2, inverted and col1 or col2
    remove = 
      doc().lines[fline]:sub(fcol, fcol + #delimiter - 1) == delimiter and 
      lcol >= #delimiter and doc().lines[lline]:sub(lcol - #delimiter, lcol - 1) == delimiter
    local shift = #delimiter * (remove and -2 or 2)
    print("SHIFT", shift)
    if remove then
      doc():remove(lline, lcol - #delimiter, lline, lcol)
      doc():remove(fline, fcol, #delimiter, fline, fcol + #delimiter)
    else
      doc():insert(lline, lcol, delimiter)
      doc():insert(fline, fcol, delimiter)
    end
    if inverted then
      doc():set_selections(idx, line1, col1+shift, line2, col2)
    else
      doc():set_selections(idx, line1, col1, line2, col2+shift)
    end
  end
end

command.add(DocView, {
  ["write-xl:bold"] = function() 
    for idx, line1, col1, line2, col2 in doc():get_selections(false) do
      toggle_selection("**", idx, line1, col1, line2, col2)
    end
  end,
  ["write-xl:italicize"] = function() 
    toggle_selection("*", idx, line1, col1, line2, col2)
  end
})

keymap.add {
  ["ctrl+b"] = "write-xl:bold",
  ["ctrl+i"] = "write-xl:italicize"
}
