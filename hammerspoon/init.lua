local default_browser = "Firefox"
-- local default_browser = "Google Chrome"
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", function()
  if (default_browser == "Firefox") then
    default_browser = "Google Chrome"
    -- hs.alert.show("using Google Chrome")
    io.popen('/opt/homebrew/bin/defaultbrowser chrome')
  else
    default_browser = "Firefox"
    -- hs.alert.show("using Firefox")
    io.popen('/opt/homebrew/bin/defaultbrowser firefox')
  end
end)

hs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({})

hs.loadSpoon("hs_select_window")
local SWbindings = {
   all_windows =  { {"alt"}, "w"},
}
spoon.hs_select_window:bindHotkeys(SWbindings)

-- https://github.com/philc/hammerspoon-config/blob/d2c1046273da4c0140d0b33dd55ee8e637db5e6d/init.lua#L109-L119
local function myLaunchOrFocus(appName)
  local app = hs.appfinder.appFromName(appName)
  if not app then
    hs.application.launchOrFocus(appName)
  else
    local windows = app:allWindows()
    if windows[1] then
      windows[1]:focus()
    end
  end
end

hs.hotkey.bind({"alt"}, "B", function()
  hs.application.launchOrFocus(default_browser)
end)
hs.hotkey.bind({"alt"}, "C", function()
  hs.application.launchOrFocus("Visual Studio Code")
end)
hs.hotkey.bind({"alt"}, "Z", function()
  hs.application.launchOrFocus("zoom.us")
end)
hs.hotkey.bind({"alt"}, "M", function()
  hs.application.launchOrFocus(default_browser)
  hs.eventtap.keyStroke({"cmd"}, "1")
end)
hs.hotkey.bind({"alt"}, "T", function()
  hs.application.launchOrFocus("kitty")
end)
hs.hotkey.bind({"alt"}, "N", function()
  -- myLaunchOrFocus("neovide")
  hs.application.launchOrFocus("Alacritty")
  -- hs.application.launchOrFocus("neovide")
end)
-- hs.hotkey.bind({"alt"}, "C", function()
--   hs.application.launchOrFocus("Google Calendar")
--   -- hs.application.launchOrFocus("Firefox")
--   -- hs.eventtap.keyStroke({"cmd"}, "2")
-- end)
hs.hotkey.bind({"alt"}, "I", function()
  -- hs.application.launchOrFocus("Visual Studio Code")
  hs.application.launchOrFocus("IntelliJ IDEA")
end)
hs.hotkey.bind({"alt"}, "V", function()
  hs.application.launchOrFocus("MacVim")
end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="HaMmErSpOoN", informativeText="Hello World"}):send()
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("hammerspoon loaded")

local function showKeyPress(tap_event)
  local duration = 1.5  -- popup duration
  local modifiers = ""  -- key modifiers string representation
  local flags = tap_event:getFlags()
  local character = hs.keycodes.map[tap_event:getKeyCode()]
  -- we only want to read special characters via getKeyCode, so we
  -- use this subset of hs.keycodes.map
  local special_chars = {
    ["f1"] = true, ["f2"] = true, ["f3"] = true, ["f4"] = true,
    ["f5"] = true, ["f6"] = true, ["f7"] = true, ["f8"] = true,
    ["f9"] = true, ["f10"] = true, ["f11"] = true, ["f12"] = true,
    ["f13"] = true, ["f14"] = true, ["f15"] = true, ["f16"] = true,
    ["f17"] = true, ["f18"] = true, ["f19"] = true, ["f20"] = true,
    ["pad"] = true, ["pad*"] = true, ["pad+"] = true, ["pad/"] = true,
    ["pad-"] = true, ["pad="] = true, ["pad0"] = true, ["pad1"] = true,
    ["pad2"] = true, ["pad3"] = true, ["pad4"] = true, ["pad5"] = true,
    ["pad6"] = true, ["pad7"] = true, ["pad8"] = true, ["pad9"] = true,
    ["padclear"] = true, ["padenter"] = true, ["return"] = true,
    ["tab"] = true, ["space"] = true, ["delete"] = true, ["escape"] = true,
    ["help"] = true, ["home"] = true, ["pageup"] = true,
    ["forwarddelete"] = true, ["end"] = true, ["pagedown"] = true,
    ["left"] = true, ["right"] = true, ["down"] = true, ["up"] = true
  }

  -- if we have a simple character (no modifiers), we want a shorter
  -- popup duration.
  if (not flags.shift and not flags.cmd and
        not flags.alt and not flags.ctrl) then
    duration = 0.3
  end

  -- we want to get regular characters via getCharacters as it
  -- "cleans" the key for us (e.g. for a "⇧-5" keypress we want
  -- to show "⇧-%").
  if special_chars[character] == nil then
    character = tap_event:getCharacters(true)
    if flags.shift then
      character = string.lower(character)
    end
  end

  -- make some known special characters look good
  if character == "return" then
    character = "⏎"
  elseif character == "delete" then
    character = "⌫"
  elseif character == "escape" then
    character = "⎋"
  elseif character == "space" then
    character = "SPC"
  elseif character == "up" then
    character = "↑"
  elseif character == "down" then
    character = "↓"
  elseif character == "left" then
    character = "←"
  elseif character == "right" then
    character = "→"
  end

  -- get modifiers' string representation
  if flags.ctrl then
    modifiers = modifiers .. "C-"
  end
  if flags.cmd then
    modifiers = modifiers .. "⌘-"
  end
  if flags.shift then
    modifiers = modifiers .. "⇧-"
  end
  if flags.alt then
    modifiers = modifiers .. "⌥-"
  end

  -- actually show the popup
  local style = {}
  style['atScreenEdge'] = 2
  hs.alert.show(modifiers .. character, style, duration)

end


local key_tap = hs.eventtap.new(
  {hs.eventtap.event.types.keyDown},
  showKeyPress
)
