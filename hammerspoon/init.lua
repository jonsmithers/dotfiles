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
