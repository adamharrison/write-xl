-- mod-version:3 --lite-xl 2.1
local core = require "core"
local style = require "core.style"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local DocView = require "core.docview"
local Doc = require "core.doc"

-- Generated the synonym file from the supplied dictionary, with the following string.
-- perl -e 'use File::Slurp; use JSON qw(encode_json from_json); my %words = (); map { my $json = from_json(scalar(read_file($_))); for (keys(%$json)) { $words{lc($_)} = [map { lc($_) } @{$json->{$_}->{SYNONYMS}}] } } (glob("*.json")); for my $key (grep { int(@{$words{$_}}) > 0 && $words{$_}->[0] ne $_ } sort(keys(%words))) { print $key . ":" . join(",", grep { $_ ne $key } @{$words{$key}}) . "\n"; }' > ../user/synonyms

local synonym_file_locations = { USERDIR .. PATHSEP .. "synonyms", USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "synonyms" ..  PATHSEP .. "synonyms" }
local autodetected_synonym_file = nil
for i,v in ipairs(synonym_file_locations) do if system.get_file_info(v) then autodetected_synonym_file = v break end end

config.plugins.synonyms = common.merge({
  synonym_file = autodetected_synonym_file
}, config.plugins.synonyms)

local synonyms = {}
local word_pattern = "%a+"

if config.plugins.synonyms.synonym_file and system.get_file_info(config.plugins.synonyms.synonym_file) then
  core.add_thread(function()
    local i = 0
    for line in io.lines(config.plugins.synonyms.synonym_file) do
      local s = line:find(":")
      local n = s
      local word = line:sub(1, s - 1)
      local t = {}
      while true do
        n = line:find(",", s + 1)
        if n then
          table.insert(t, line:sub(s + 1, n - 1))
          s = n
        else
          table.insert(t, line:sub(s + 1, #line))
          break
        end
      end
      synonyms[word] = t
      i = i + 1
      if i % 1000 == 0 then coroutine.yield() end
    end
    core.redraw = true
    core.log_quiet(
      "Finished loading synonym file: \"%s\"",
      config.plugins.synonyms.synonym_file
    )
  end)
else
  error("can't find synonyms list; please supply one with config.plugins.synonyms.synonym_file")
end

local function get_word_at_caret()
  local doc = core.active_view.doc
  local l, c = doc:get_selection()
  local s, e = 0, 0
  local text = doc.lines[l]
  while true do
    s, e = text:find(word_pattern, e + 1)
    if c >= s and c <= e + 1 then
      return text:sub(s, e):lower(), s, e
    end
  end
end


command.add("core.docview", {

  ["synonyms:replace"] = function()
    local word, s, e = get_word_at_caret()

    -- find suggestions
    local suggestions = synonyms[word]
    if not suggestions or #suggestions == 0 then
      core.error("Could not find any suggestions for \"%s\"", word)
      return
    end

    local doc = core.active_view.doc
    local line = doc:get_selection()
    local has_upper = doc.lines[line]:sub(s, s):match("[A-Z]")
    local transformed_suggestions = {}
    for k, v in ipairs(suggestions) do
      if has_upper then
        v = v:gsub("^.", string.upper)
      end
      table.insert(transformed_suggestions, v)
    end

    -- select word and init replacement selector
    local label = string.format("Replace \"%s\" With", word)
    doc:set_selection(line, e + 1, line, s)
    core.command_view:enter(label, function(text, item)
      text = item or text
      doc:replace(function() return text end)
    end, function(text)
      local t = {}
      for _, w in ipairs(transformed_suggestions) do
        if w:lower():find(text:lower(), 1, true) then
          table.insert(t, w)
        end
      end
      return t
    end)
  end,

})

local contextmenu = require "plugins.contextmenu"
contextmenu:register("core.docview", {
  contextmenu.DIVIDER,
  { text = "View Synonyms", command = "synonyms:replace" }
})
