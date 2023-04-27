-- mod-version:3 -- lite-xl 2.1

local core = require "core"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local Doc = require "core.doc"
local DocView = require "core.docview"
local translate = require "core.doc.translate"

config.plugins.autocorrect = common.merge({
  map_file = USERDIR .. PATHSEP .. "autocorrect",
  word_end_trigger = "[^'%a%d]$"
}, config.plugins.autocorrect)

local autocorrect_map = {}
if system.get_file_info(config.plugins.autocorrect.map_file) then
  core.add_thread(function()
    local word_correct_from = nil
    for line in io.lines(config.plugins.autocorrect.map_file) do
      local word = line:gsub("\n$", line)
      if word_correct_from then
        autocorrect_map[word_correct_from] = word
        word_correct_from = nil
      else
        word_correct_from = word
      end
    end
    core.log("Successfully loaded autocorrect map %s.", config.plugins.autocorrect.map_file)
  end)
end

local function autocorrect_word(word)
  local autocorrected = autocorrect_map[word:lower()]
  if autocorrected then
    if word:find("^[A-Z]+$") then
      return autocorrected:upper()
    elseif word:find("^[A-Z]$") then
      return autocorrected:sub(1,1):upper() .. autocorrected:sub(2)
    end
    return autocorrected
  end
  return nil;
end

local function get_word_information(doc, line, col)
  if not line and not col then
    for sidx, line1, col1, line2, col2 in doc:get_selections(true) do
      if line1 == line2 and col1 == col2 then
        return get_word_information(doc, line1, col1)
      end
    end
  end
  local word_start_line, word_start_col = translate.previous_word_start(doc, line, col)
  local word_end_line, word_end_col = translate.end_of_word(doc, word_start_line, word_start_col)
  if word_start_line == word_end_line then
    local word = doc.lines[word_start_line]:sub(word_start_col, word_end_col - 1)
    return word, word_start_line, word_start_col, word_end_line, word_end_col, line, col
  end
  return nil
end

local old_text_input = Doc.text_input
function Doc:text_input(text, idx)
  old_text_input(self, text, idx)
  if text:find(config.plugins.autocorrect.word_end_trigger) then
    local word, line1, col1, line2, col2, selline, selcol = get_word_information(self)
    if word then
      local autocorrected = autocorrect_word(word)
      if autocorrected then
        self:remove(line1, col1, line2, col2)
        self:insert(line1, col1, autocorrected)
        self:set_selection(line2, col1 + #autocorrected + (selcol - col2))
      end
    end
  end
end

local function save_autocorrect_map()
  local f = io.open(config.plugins.autocorrect.map_file, "wb")
  for k,v in pairs(autocorrect_map) do
    if v ~= nil then
      f:write(k .. "\n")
      f:write(v .. "\n")
    end
  end
  f:close()
end

command.add(DocView, {
  ["autocorrect:add-word"] = function()
    local word
    if core.active_view.doc:has_selection() then
      word = core.active_view.doc:get_text(core.active_view.doc:get_selection())
    else
      word = get_word_information(core.active_view.doc)
    end
    core.command_view:enter("Enter Word to be Autocorrected", {
      text = word,
      submit = function(autocorrect_from_word)
        core.command_view:enter("Enter Word to Autocorrect '" .. autocorrect_from_word .. "' to", {
          text = word,
          submit = function(autocorrect_to_word)
            autocorrect_map[autocorrect_from_word:lower()] = autocorrect_to_word
            save_autocorrect_map()
          end
        })
      end
    })
  end,
  ["autocorrect:remove-word"] = function()
    local word
    if core.active_view.doc:has_selection() then
      word = core.active_view.doc:get_text(core.active_view.doc:get_selection())
    else
      word = get_word_information(core.active_view.doc)
    end
    local words_to_correct_from = {}
    for k,v in pairs(autocorrect_map) do table.insert(words_to_correct_from, k) end
    core.command_view:enter("Enter Word to Remove from Autocorrection", {
      text = word,
      submit = function(autocorrect_word)
        local lower = autocorrect_word:lower()
        if autocorrect_map[lower] then
          autocorrect_map[lower] = nil
          save_autocorrect_map()
        else
          core.error("Can't find autocorrect word '%s'.", autocorrect_word)
        end
      end,
      suggest = function(word)
        return common.fuzzy_match(words_to_correct_from, word:lower())
      end
    })
  end
})
command.add(nil, {
  ["autocorrect:open-list"] = function()
    core.root_view:open_doc(core.open_doc(config.plugins.autocorrect.map_file))
  end
})
