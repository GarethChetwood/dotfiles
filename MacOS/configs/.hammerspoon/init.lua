HYPER = {'ctrl', 'shift', 'alt', 'cmd'}

-- local DragToScroll = hs.loadSpoon('DragToScroll')
local ClipboardTool = hs.loadSpoon('ClipboardTool')
local DoubleTap = hs.loadSpoon('DoubleTap')
local MouseScroll = hs.loadSpoon('DragToScroll')

-- Mike Solomon @msol 2019

local log = hs.logger.new('main', 'info')
DEVELOPING_THIS = false -- set to true to ease debugging


function setUpClipboardTool()
    ClipboardTool.show_in_menubar = false
    ClipboardTool.paste_on_select = true
    ClipboardTool.show_copied_alert = false

    ClipboardTool:start()
    ClipboardTool:bindHotkeys({
      toggle_clipboard = {{"cmd", "alt"}, "v"}
    })
end

-- setUpClipboardTool()

local myDoKeyStroke = function(modifiers, character)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, string.lower(character), true):post()
  hs.timer.usleep(2000)
  event.newKeyEvent(modifiers, string.lower(character), false):post()
end


local function keyCode(key, mods, callback)
  mods = mods or {}
  callback = callback or function() end
  return function()
      if(key) then
        hs.eventtap.event.newKeyEvent(mods, string.lower(key), true):post()
        hs.timer.usleep(1000)
        hs.eventtap.event.newKeyEvent(mods, string.lower(key), false):post()
      end
      callback()
  end
end

-- This is required for some actions to fire properly
local keySleep = function()
  hs.timer.usleep(2000)
end

local function browserPaste()
  myDoKeyStroke({"cmd"}, "l")
  myDoKeyStroke({"cmd"}, "v")
end

local function runLastCommand()
  myDoKeyStroke({}, "up")
  myDoKeyStroke({}, "return")
end

local function goToEndLine()
  -- hs.eventtap.keyStroke({"cmd"}, "right")
  myDoKeyStroke({"cmd"}, "right")
end

local function selectStartLine()
  myDoKeyStroke({ "shift", "cmd"}, "left")
end

local function selectEndLine()
  myDoKeyStroke({ "shift", "cmd"}, "right")
end

local function endLineSemicolon()
  goToEndLine()
  myDoKeyStroke({}, ";")  -- for some reason this one gets ignored???
  myDoKeyStroke({}, ";")
end

local function endLineComma()
  goToEndLine()
  myDoKeyStroke({}, ",")  -- for some reason this one gets ignored???
  myDoKeyStroke({}, ",")
end

local function selectWord()
  myDoKeyStroke({"alt"}, "left")
  myDoKeyStroke({"shift", "alt"}, "right")
end

local function selectLine()
  myDoKeyStroke({"cmd"}, "left")
  myDoKeyStroke({"cmd"}, "left")
  myDoKeyStroke({"shift", "cmd"}, "right")
end

local function copy()
  myDoKeyStroke({"cmd"}, "c")
end

local function cut()
  myDoKeyStroke({"cmd"}, "x")
end

local function paste()
  myDoKeyStroke({"cmd"}, "v")
end

local function copyWord()
  selectWord()
  copy()
end

local function cutWord()
  selectWord()
  cut()
end

local function cutLine()
  selectLine()
  keySleep()
  cut()
  keySleep()
  cut()
end

local function copyLine()
  selectLine()
  keySleep()
  copy()
  keySleep()
  copy()
end

local function pasteWord()
  selectWord()
  paste()
end

local function pasteLine()
  selectLine()
  keySleep()
  paste()
  keySleep()
  paste()
end

local function deleteStartLine()
  myDoKeyStroke({"cmd"}, "delete")
end

local function deleteEndLine()
  myDoKeyStroke({"cmd"}, "forwarddelete")
end

local function deleteLine()
  selectLine()
  myDoKeyStroke({}, "delete")
  myDoKeyStroke({}, "delete")
end


local function sendCurlyBrace()
  hs.eventtap.keyStrokes("{")
end


local function sendSpacedCurlyBrace()
  hs.eventtap.keyStrokes("{")
  myDoKeyStroke({}, "space")
  myDoKeyStroke({}, "space")
  myDoKeyStroke({}, "left")
end

local function sendChar(char)
  return function()
    hs.eventtap.keyStrokes(char)
  end
end

local function sendSpacedChar(char)
  return function()
    hs.eventtap.keyStrokes(char)
    myDoKeyStroke({}, "space")
    myDoKeyStroke({}, "space")
    myDoKeyStroke({}, "left")
  end
end


local function remapKey(mods, key, keyCode)
  hs.hotkey.bind(mods, key, keyCode, nil, keyCode)
end

local function focusApp(app_name, all_windows)
  local focused = hs.application.launchOrFocus(app_name)
  if( focused and all_windows ) then
    local app = hs.application.get(app_name)
    app:activate(true)
  end
end

function move_mouse_to_screen_center(screen)
  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
end

function get_window_under_mouse()
  -- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it
  -- and breaks itself
  local _ = hs.application

  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()

  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

-- focus on the last-focused window of the application given by name, or else launch it
function hyperFocusOrOpen(key, app_name, all_windows)
  local function toggleApp()
    local hs_app = hs.application.get(app_name)
    if( hs_app == nil ) then
      focusApp(app_name, all_windows)
    else
      if(hs_app:isFrontmost()) then
        hs_app:hide()
      else
        focusApp(app_name, all_windows)
      end
    end
  end
  remapKey(HYPER, key, toggleApp)
end

function switchScreen()
  local screen = hs.mouse.getCurrentScreen()
  local nextScreen = screen:next()
  move_mouse_to_screen_center(nextScreen)
  return get_window_under_mouse():focus()
end

-- Switches to an app that might be on another screen
function switchToApp(key, appName)
  local function doSwitch()
    local mouseScreen = hs.mouse.getCurrentScreen()
    local slackWindow = hs.application.find(appName):mainWindow()
    local slackScreen = slackWindow:screen()
    if( #hs.screen.allScreens() == 1 ) then
      hyperFocusOrOpen(key, appName)
    else
      switchScreen()
    end
  end

  hs.hotkey.bind(HYPER, key, doSwitch)
end



-- Start/end of line
remapKey(HYPER, "l", keyCode("right",{"cmd"}));
remapKey(HYPER, "o", keyCode("right",{"shift","cmd"}));

-- Highlight from cursor back/forth
remapKey(HYPER, "j", keyCode("left",{"cmd"}));
remapKey(HYPER, "u", keyCode("left",{"shift","cmd"}));

-- Up down
remapKey(HYPER, "i", keyCode("up"));
remapKey(HYPER, "k", keyCode("down"));

remapKey(HYPER, "m", keyCode("left"));
-- remapKey(HYPER, ",", keyCode("right"));   -- neesd to be done in karabiner (sys diag)

remapKey({"ctrl"}, "tab", keyCode("tab",{"cmd"}));
remapKey({"option"}, "tab", keyCode("tab",{"cmd"}));

remapKey(HYPER, "a", keyCode("b", HYPER));

hs.hotkey.bind(HYPER, ";", endLineSemicolon)
hs.hotkey.bind(HYPER, ",", endLineComma)
hs.hotkey.bind(HYPER, "p", browserPaste)
hs.hotkey.bind(HYPER, "return", runLastCommand)
hs.hotkey.bind({"shift"}, "[", sendCurlyBrace)


-- DoubleTap:bindSingleDoubleTapFunctions(HYPER, "d", selectWord, selectLine);
-- DoubleTap:bindSingleDoubleTapFunctions(HYPER, "d", selectWord, selectLine);
-- DoubleTap:bindSingleDoubleTapFunctions(HYPER, "x", cutWord, cutLine);
DoubleTap:bindSingleDoubleTapFunctions(HYPER, "c", copyWord, copyLine)
DoubleTap:bindSingleDoubleTapFunctions(HYPER, "v", pasteWord, pasteLine)

DoubleTap:bindSingleDoubleTapFunctions(HYPER, "delete", deleteStartLine, deleteLine)
DoubleTap:bindSingleDoubleTapFunctions(HYPER, "forwarddelete", deleteEndLine, deleteLine)
-- DoubleTap:bindSingleDoubleTapFunctions({"shift"}, "[", sendChar("{"), sendSpacedChar("{"));
-- DoubleTap:bindSingleDoubleTapFunctions({"shift"}, "9", sendChar("("), sendSpacedChar("("));
-- DoubleTap:bindSingleDoubleTapFunctions({}, "[", sendChar("["), sendSpacedChar("["));

switchToApp("f", "Slack")

-- App bindings
-- function setUpAppBindings()
--   hyperFocusAll('w', 'React Native Debugger', 'Simulator', 'qemu-system-x86_64')
--   hyperFocusOrOpen('e', 'Notes')
--   hyperFocus('i', 'IntelliJ IDEA', 'IntelliJ IDEA-EAP', 'Xcode', 'Android Studio', 'Atom', 'Code')
hyperFocusOrOpen('d', 'Finder', true)
hyperFocusOrOpen('x', 'System Settings')
--   hyperFocusOrOpen('x', 'Calendar')
--   hyperFocusOrOpen('m', 'Messages')
--   hyperFocusOrOpen('r', 'Slack')
--   hyperFocus('t', 'Safari')
--   hyperFocusOrOpen(';', 'iTerm2')
--   hyperFocusOrOpen('s', 'OmniFocus')
--   hyperFocus('f', 'Google Chrome', 'Firefox')
--   hyperFocusOrOpen('space', 'Sublime Text')
-- end

-- -- Window management
-- function setUpWindowManagement()
--   hs.window.animationDuration = 0 -- disable animations
--   hs.grid.setMargins({0, 0})
--   hs.grid.setGrid('2x2')

--   function mkSetFocus(to)
--     return function() hs.grid.set(hs.window.focusedWindow(), to) end
--   end

--   local fullScreen = hs.geometry("0,0 2x2")
--   local leftHalf = hs.geometry("0,0 1x2")
--   local rightHalf = hs.geometry("1,0 1x2")
--   local upperLeft = hs.geometry("0,0 1x1")
--   local lowerLeft = hs.geometry("0,1 1x1")
--   local upperRight = hs.geometry("1,0 1x1")
--   local lowerRight = hs.geometry("1,1 1x1")

--   hs.hotkey.bind(HYPER, 'l', mkSetFocus(fullScreen))
--   hs.hotkey.bind(HYPER, 'h', mkSetFocus(leftHalf))
--   hs.hotkey.bind(HYPER, "'", mkSetFocus(rightHalf))
--   hs.hotkey.bind(HYPER, "y", mkSetFocus(upperLeft))
--   hs.hotkey.bind(HYPER, "b", mkSetFocus(lowerLeft))
--   hs.hotkey.bind(HYPER, "u", mkSetFocus(upperRight))
--   hs.hotkey.bind(HYPER, "n", mkSetFocus(lowerRight))

--   hs.hotkey.bind(HYPER, "up", hs.window.filter.focusNorth)
--   hs.hotkey.bind(HYPER, "down", hs.window.filter.focusSouth)
--   hs.hotkey.bind(HYPER, "left", hs.window.filter.focusWest)
--   hs.hotkey.bind(HYPER, "right", hs.window.filter.focusEast)
--   -- hs.hotkey.bind(HYPER, "v", hs.window.filter.focusNorth)
--   -- hs.hotkey.bind(HYPER, "c", hs.window.filter.focusSouth)
--   -- hs.hotkey.bind(HYPER, "j", hs.window.filter.focusWest)
--   -- hs.hotkey.bind(HYPER, "p", hs.window.filter.focusEast)
--   hs.hotkey.bind(HYPER, "q", hs.hints.windowHints)
--   -- HYPER "d" -- Bound in Karabiner to Cmd+Tab (application switcher)
--   -- HYPER "k" -- Bound in Karabiner to Cmd+` (next window of application)

--   -- throw to other screen
--   hs.hotkey.bind(HYPER, 'o', function()
--     local window = hs.window.focusedWindow()
--     window:moveToScreen(window:screen():next())
--   end)
-- end

-- -- focus on the last-focused window of the first application given by name
-- function hyperFocus(key, ...)
--   hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(true, ...))
-- end


-- -- focus on the last-focused window of every application given by name
-- function hyperFocusAll(key, ...)
--   hs.hotkey.bind(HYPER, key, mkFocusByPreferredApplicationTitle(false, ...))
-- end


-- -- creates callback function to select application windows by application name
-- function mkFocusByPreferredApplicationTitle(stopOnFirst, ...)
--   local arguments = {...} -- create table to close over variadic args
--   return function()
--     local nowFocused = hs.window.focusedWindow()
--     local appFound = false
--     for _, app in ipairs(arguments) do
--       if stopOnFirst and appFound then break end
--       log:d('Searching for app ', app)
--       local application = hs.application.get(app)
--       if application ~= nil then
--         log:d('Found app', application)
--         local window = application:mainWindow()
--         if window ~= nil then
--           log:d('Found main window', window)
--           if window == nowFocused then
--             log:d('Already focused, moving on', application)
--           else
--             window:focus()
--             appFound = true
--           end
--         end
--       end
--     end
--     return appFound
--   end
-- end


-- function maybeEnableDebug()
--   if DEVELOPING_THIS then
--     log.setLogLevel('debug')
--     log.d('Loading in development mode')
--     -- automatically reload changes when we're developing
--     hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
--     hs.alert('Hammerspoon config reloaded')
--     log:d('Hammerspoon config reloaded')
--   end
-- end

-- Main

--maybeEnableDebug()
--setUpAppBindings()
--setUpWindowManagement()
