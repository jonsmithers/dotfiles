// This is my configuration for Phoenix <https://github.com/sdegutis/Phoenix>,
// a super-lightweight OS X window manager that can be configured and
// scripted through Javascript.

 
var mNone = [],
  mCmd = ['cmd'],
  mShift = ['shift'],
  nudgePixels = 10,
  padding = 0,
  previousSizes = {};
 
// Remembers hotkey bindings.
var keys = [];
function bind(key, mods, callback) {
  keyhandler = Phoenix.bind(key, mods, callback);
  if (keyhandler) {
    keys.push(keyhandler);
  } else {
    Phoenix.notify(key + " handler failed");
  }
}
 
// ############################################################################
// Modal activation
// ############################################################################
 
// Modal activator
// This hotkey enables/disables all other hotkeys.
var active = false;
var alt_w = Phoenix.bind('w', ['alt'], function() {
  if (!active) {
    enableKeys();
  } else {
    disableKeys();
  }
});
 
// These keys end Phoenix mode.
bind('escape', [], function() {
  Phoenix.log('escape');
  disableKeys();
});
bind('return', [], function() {
  disableKeys();
});
 
// ############################################################################
// Bindings
// ############################################################################
 
// ### General key configurations
//
// Space toggles the focussed between full screen and its initial size and position.
bind( 'space', mNone, function() {
  Window.focusedWindow().toggleFullscreen();
});

function toast(str) {
   var m = new Modal();
   m.message = str;
   m.origin = {x: 50, y: 90};
   m.duration = 3;
   m.show();
}
 
// Center window.
bind( 'c', mNone, function() {
    var m = new Modal();
    m.message = "hey";
    m.origin = {x: 50, y: 90};
    m.duration = 3;
    m.show();
    //setTimeout(function() { m.close() }, 1000);
  }

  //cycleCalls(
  //toGrid,
  //[
  //  [0.22, 0.025, 0.56, 0.95],
  //  [0.1, 0, 0.8, 1]
  //]
);


bind( ".", mNone, function() {
  try {
    var rect = Window.focusedWindow().frame();
    rect.width = rect.width*.9;
    Window.focusedWindow().setFrame(rect);
  }
  catch(e) {
    Phoenix.notify(e);
  }
});
 
// The cursor keys move the focussed window.
bind( 'up', mNone, function() {
  Window.focusedWindow().nudgeUp( 5 );
});
 
bind( 'right', mNone, function() {
  Window.focusedWindow().nudgeRight( 5 );
});
 
bind( 'down', mNone, function() {
  Window.focusedWindow().nudgeDown( 5 );
});
 
bind( 'left', mNone, function() {
  Window.focusedWindow().nudgeLeft( 5 );
});
 
// <SHIFT> + cursor keys grows/shrinks the focussed window.
bind( 'right', mShift, function() {
  Window.focusedWindow().growWidth();
});
 
bind( 'left', mShift, function() {
  Window.focusedWindow().shrinkWidth();
});
 
bind( 'up', mShift, function() {
  Window.focusedWindow().shrinkHeight();
});
 
bind( 'down', mShift, function() {
  Window.focusedWindow().growHeight();
});
 
// ############################################################################
// Bindings for specific apps
// ############################################################################
//

var focusTitle = function(title) {
  var winToFocus
  Window.allWindows().forEach(function(element, index, array) {
    Phoenix.notify("...");
    if (element.title().indexOf(title) == 0) {
      if (!winToFocus) {
        winToFocus = element;
      }
    }
  });
  Phoenix.log("set winToFocus");

  if (winToFocus) {
    winToFocus.focus();
    Phoenix.log("focused");
  } else {
    Phoenix.log("No window has title '"+title+"'");
  }
}
var cycle = function(appName) {
  try {
    var exclusions = new Array();
    for (var i = 1; i < arguments.length; i++) {
      exclusions.push(arguments[i]);
    }
    var app = App.get(appName);
    if (!app) {
      Phoenix.log("app is null");
      var result = App.launch(appName);
      if (result) {
        toast('focus1');
        result.focus();
        toast('focus2');
      }
      Phoenix.log('result of launch: ' + result);
      return;
    }

    var appWindowsTemp = app.windows();
    var appWindows = new Array();

    for (var i = 0; i < appWindowsTemp.length; i++) {
      if (appWindowsTemp[i].title()) {
        appWindows.push(appWindowsTemp[i]);
      }
    }

    if (appWindows.length==0) {
      Phoenix.log("app has no titled windows");
      Phoenix.launch(appName);
      return;
    }

    var curWin = Window.focusedWindow();
    var curWinBelongsToApp = false;
    if (curWin) { // some window is focused
      for (var i = 0; i < appWindows.length; i++) {
        if (curWin.title() == appWindows[i].title()) {
          curWinBelongsToApp = true;
          break;
        }
      }
    }

    var index = 0;
    if (curWinBelongsToApp) {
      if (appWindows.length == 1) {
        Phoenix.log("no other windows");
        return;
      }

      index++; // do not focus already-focused window
    }

    while (shouldBeExcluded(appWindows[index].title())) {
      Phoenix.log("exclude " + appWindows[index].title());
      index++;
      if (index == appWindows.length) {
        break;
      }
    }
    if (index == appWindows.length) {
      Phoenix.log("no real windows to switch to");
      return;
    }
    Phoenix.log('Go To "' + appWindows[index].title() +'"');
    appWindows[index].focus();
    return;

    function shouldBeExcluded(title) {
      for (var i = 0; i < exclusions.length; i++) {
        if (title.indexOf(exclusions[i]) == 0) {
          return true;
        }
      }
      return false;
    }
  } catch (e) {
    Phoenix.log(e);
  }
}

var x00 = Phoenix.bind( 'a', ['alt'], function() { Phoenix.log("a"); cycle('Atom') });
var x01 = Phoenix.bind( 'b', ['alt'], function() { Phoenix.notify(""); cycle('Brackets') });
var x02 = Phoenix.bind( 'i', ['alt'], function() { Phoenix.notify(""); cycle('Google Chrome', 'Hangouts', 'Pushbullet', 'Google Play Music') })
var x03 = Phoenix.bind( 'h', ['alt'], function() { Phoenix.notify("focus"); focusTitle('Hangouts') });
var x04 = Phoenix.bind( 'p', ['alt'], function() { Phoenix.notify("focus"); focusTitle('Pushbullet') });
var x05 = Phoenix.bind( 't', ['alt'], function() { Phoenix.notify(""); cycle('iTerm') });
var x06 = Phoenix.bind( 'r', ['alt'], function() { Phoenix.notify(""); cycle('Rocket.Chat') });
var x07 = Phoenix.bind( 'o', ['alt'], function() { Phoenix.notify(""); cycle('Microsoft Outlook') });
var x08 = Phoenix.bind( 'l', ['alt'], function() { Phoenix.notify(""); cycle('Microsoft Lync') });
var x09 = Phoenix.bind( 'm', ['alt'], function() { Phoenix.notify(""); cycle('MacVim') });
var x10 = Phoenix.bind( 'e', ['alt'], function() { Phoenix.notify(""); cycle('Eclipse') });
var x11 = Phoenix.bind( 'f', ['alt'], function() { Phoenix.notify(""); cycle('Finder') });
bind( 't', mNone, function() {
  try {
  var focusedWindow = Window.focusedWindow();
  var otherScreen = Screen.mainScreen().next();
  Phoenix.log(Screen.mainScreen().hash());
  Phoenix.log(Window.focusedWindow().screen().hash());
  if (!otherScreen) {
    Phoenix.notify("no other screen");
  } else {
    var screenFrame = otherScreen.visibleFrameInRectangle();
    Phoenix.log(otherScreen.hash())

    var w = Window.focusedWindow();
    Phoenix.log("old " + w.screen().hash());
    w.setTopLeft({x: screenFrame.x, y: screenFrame.y});
    Phoenix.log("new " + w.screen().hash());

    Phoenix.notify("threw window");
  }
  } catch (e) {
    Phoenix.log(e)
  }
  disableKeys();
});
bind( 'f', mNone, function() {
  var rect = Window.focusedWindow().screen().visibleFrameInRectangle();
  Window.focusedWindow().setFrame(rect);
  disableKeys();
});
bind ('l', mNone, function() {
    var rect = Screen.mainScreen().visibleFrameInRectangle();
    rect.width = rect.width/2;
    rect.x = rect.width;
    Window.focusedWindow().setFrame(rect);
  disableKeys();
});
bind ('h', mNone, function() {
  try {
    var rect = Screen.mainScreen().visibleFrameInRectangle();
    rect.width = rect.width/2;
    Window.focusedWindow().setFrame(rect);
    disableKeys();
  } catch (e) {
    Phoenix.log(e)
  }
});
 
// Chrome Devtools
//
// When checking HTML/JS in Chrome I want to have my browsing window to the
// East and my Chrome devtools window to the W, the latter not quite on full
// height.
bind( 'd', mNone, function() {
  var chrome = App.findByTitle('Google Chrome'),
  browseWindow = chrome.findWindowNotMatchingTitle('^Developer Tools -'),
  devToolsWindow = chrome.findWindowMatchingTitle('^Developer Tools -');
 
  Phoenix.notify( 'Chrome Dev Tools Layout', 0.25 );
 
  if ( browseWindow ) {
  browseWindow.toE();
  }
 
  if ( devToolsWindow ) {
  devToolsWindow.toGrid( 0, 0, 0.5, 1 );
  }
 
  disableKeys();
});
 
 
// ############################################################################
// Helpers
// ############################################################################
 
// Cycle args for the function, if called repeatedly
// cycleCalls(fn, [ [args1...], [args2...], ... ])
var lastCall = null;
function cycleCalls(fn, argsList) {
  var argIndex = 0, identifier = {};
  return function () {
  if (lastCall !== identifier || ++argIndex >= argsList.length) {
    argIndex = 0;
  }
  lastCall = identifier;
  fn.apply(this, argsList[argIndex]);
  };
}

var windowModal = new Modal();
windowModal.message = "Managing Windows";
 
// Disables all remembered keys.
function disableKeys() {
  active = false;
  _(keys).each(function(key) {
    key.disable();
  });
  windowModal.close();
}
 
// Enables all remembered keys.
function enableKeys() {
  active = true;
  _(keys).each(function(key) {
    key.enable();
  });
  windowModal.show();
}
 
Window.prototype.shrinkWidth = function() {
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;
 
  if (frame.width >= pixels * 2) {
  frame.width -= pixels;
  } else {
  frame.width = pixels;
  }
 
  win.setFrame(frame);
 
  this.nudgeRight(3);
};
 
Window.prototype.shrinkHeight = function() {
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameWithoutDockOrMenu(),
  pixels = nudgePixels * 6;
 
  if (frame.height >= pixels * 2) {
  frame.height -= pixels;
  } else {
  frame.height = pixels;
  }
 
  win.setFrame(frame);
 
  this.nudgeDown(3);
};
 
// ### Helper methods `App`
//
// Finds the window with a certain title.  Expects a string, returns a window
// instance or `undefined`.  If there are several windows with the same title,
// the first found instance is returned.
App.findByTitle = function( title ) {
  return _( this.runningApps() ).find( function( app ) {
  if ( app.title() === title ) {
    app.show();
    return true;
  }
  });
};
 
 
// Finds the window whose title matches a regex pattern.  Expects a string
// (the pattern), returns a window instance or `undefined`.  If there are
// several matching windows, the first found instance is returned.
App.prototype.findWindowMatchingTitle = function( title ) {
  var regexp = new RegExp( title );
 
  return _( this.visibleWindows() ).find( function( win ) {
  return regexp.test( win.title() );
  });
};
 
 
// Finds the window whose title doesn't match a regex pattern.  Expects a
// string (the pattern), returns a window instance or `undefined`.  If there
// are several matching windows, the first found instance is returned.
App.prototype.findWindowNotMatchingTitle = function( title ) {
  var regexp = new RegExp( title );
 
  return _( this.visibleWindows() ).find( function( win ) {
  return !regexp.test( win.title() );
  });
};
 
 
// Returns the first visible window of the app or `undefined`.
App.prototype.firstWindow = function() {
  return this.visibleWindows()[ 0 ];
};
 
// ############################################################################
// Init
// ############################################################################
 
// Initially disable all hotkeys
disableKeys();

