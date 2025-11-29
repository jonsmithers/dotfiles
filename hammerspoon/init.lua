local default_browser = "Arc"
-- local default_browser = "Firefox"
-- local default_browser = "Google Chrome"
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", function()
  if (default_browser == "Firefox") then
    default_browser = "Google Chrome"
    io.popen('/opt/homebrew/bin/defaultbrowser chrome')
  elseif (default_browser == "Google Chrome") then
    default_browser = "Arc"
    io.popen('/opt/homebrew/bin/defaultbrowser browser')
  else
    default_browser = "Firefox"
    io.popen('/opt/homebrew/bin/defaultbrowser firefox')
  end
end)

hs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({})

local SKIP = 'skip'

for _, v in pairs({
  {'alt', 'I', "Visual Studio Code"},
  {'alt', 'T', "kitty"},
  -- {'alt', 'T', "Ghostty"},
  {'alt', 'V', "MacVim"},
  {'alt', 'W', "WhatsApp"},
  {'alt', 'Z', "Zoom"},
  {'alt', 'B', function() return default_browser end},
  {'alt', 'M', "Slack"},
}) do
  local mod, key, what_do = table.unpack(v);
  hs.hotkey.bind(mod, key, function()
    if (type(what_do) == 'string') then
      hs.application.launchOrFocus(what_do)
      return
    end
    if (type(what_do) == 'function') then
      local result = what_do()
      if (result == SKIP) then
        return
      end
      if (type(result) ~= 'string') then
        hs.alert.show('unexpected type')
        return
      end
      hs.application.launchOrFocus(result)
    end
  end)
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="⛽🦄", informativeText="Hello World"}):send()
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("hammerspoon loaded")
