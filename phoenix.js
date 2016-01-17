var VimMode = {}
VimMode._keys = [];
VimMode.modals = [];
VimMode._showLabels = function() {
  this._modals = [];
  var modals = this._modals;
  try {
    _(Screen.screens()).each(function(screen) {
      var m = new Modal();
      m.message = "Managing Windows";

      // this coordinate calculation is not universal
      var rect = screen.frameInRectangle();
      Phoenix.log("screen::: x:" + rect.x + ", y:" + rect.y + ", width:" + rect.width + ", height:" + rect.height);
      var x = rect.x + rect.width/2;
      var y = rect.y + rect.height/2;
      if (screen.hash() != Screen.mainScreen().hash()) {
        y = -rect.height/2;
      }
      m.origin = {x:x, y:y};

      m.show();
      modals.push(m);
    });
  }
  catch(e) {
    Phoenix.log(e);
  }
};
VimMode._hideLabels = function () {
  _(this._modals).each(function(modal) {
    modal.close();
  });
};
VimMode.disable = function() {
  this._active = false;
  _(this._keys).each(function(key) {
    key.disable();
  });
  this._hideLabels();
}
VimMode.enable = function() {
  this._active = true;
  _(this._keys).each(function(key) {
    key.enable();
  });
  this._showLabels();
}
VimMode.bind = function(key, mods, callback) {
  var callback2 = function() {
    try {
      callback();
    } catch (e) {
      toast(e);
      VimMode.disable();
    }
  }
  keyhandler = Phoenix.bind(key, mods, callback2);
  if (keyhandler) {
    this._keys.push(keyhandler);
  } else {
    toast(key + " binding failed");
  }
};
 
var mNone = [],
  mCmd = ['cmd'],
  mShift = ['shift'],
  nudgePixels = 10,
  padding = 0,
  previousSizes = {};
 
// ############################################################################
// Modal activation
// ############################################################################
 
// Modal activator
// This hotkey enables/disables all other hotkeys.
var active = false;
var alt_w = Phoenix.bind('w', ['alt'], function() {
  if (!active) {
    VimMode.enable();
  } else {
    VimMode.disable();
  }
});
 
// These keys end Phoenix mode.
VimMode.bind('escape', [], function() {
  VimMode.disable();
});
VimMode.bind('return', [], function() {
  VimMode.disable();
});
 
// ############################################################################
// Bindings
// ############################################################################
 
// ### General key configurations
//
// Space toggles the focussed between full screen and its initial size and position.
VimMode.bind( 'space', mNone, function() {
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
VimMode.bind( 'c', mNone, function() {
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


VimMode.bind( ".", mNone, function() {
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
VimMode.bind( 'up', mNone, function() {
  Window.focusedWindow().nudgeUp( 5 );
});
 
VimMode.bind( 'right', mNone, function() {
  Window.focusedWindow().nudgeRight( 5 );
});
 
VimMode.bind( 'down', mNone, function() {
  Window.focusedWindow().nudgeDown( 5 );
});
 
VimMode.bind( 'left', mNone, function() {
  Window.focusedWindow().nudgeLeft( 5 );
});
 
// <SHIFT> + cursor keys grows/shrinks the focussed window.
VimMode.bind( 'right', mShift, function() {
  Window.focusedWindow().growWidth();
});
 
VimMode.bind( 'left', mShift, function() {
  Window.focusedWindow().shrinkWidth();
});
 
VimMode.bind( 'up', mShift, function() {
  Window.focusedWindow().shrinkHeight();
});
 
VimMode.bind( 'down', mShift, function() {
  Window.focusedWindow().growHeight();
});
 
// ############################################################################
// Bindings for specific apps
// ############################################################################
//

var focusTitle = function(title) {

  var m = new Modal();
  m.message = "Focusing...";
  m.show();

  try {
    var winToFocus
    Window.windows().forEach(function(element, index, array) {
      if (element.title().indexOf(title) == 0) {
        if (!winToFocus) {
          winToFocus = element;
        }
      }
    });

    if (winToFocus) {
      winToFocus.focus();
    } else {
      toast("No window has title '"+title+"'");
    }
  } catch (e) {
    toast(e);
  } finally {
    m.close();
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
        result.focus();
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
var x01 = Phoenix.bind( 'b', ['alt'], function() { cycle('Brackets') });
var x02 = Phoenix.bind( 'i', ['alt'], function() { cycle('Google Chrome', 'Hangouts', 'Pushbullet', 'Google Play Music') })
var x03 = Phoenix.bind( 'h', ['alt'], function() { focusTitle('Hangouts') });
var x04 = Phoenix.bind( 'p', ['alt'], function() { focusTitle('Pushbullet') });
var x05 = Phoenix.bind( 't', ['alt'], function() { cycle('iTerm') });
var x06 = Phoenix.bind( 'r', ['alt'], function() { cycle('Rocket.Chat') });
var x07 = Phoenix.bind( 'o', ['alt'], function() { cycle('Microsoft Outlook') });
var x08 = Phoenix.bind( 'l', ['alt'], function() { cycle('Microsoft Lync') });
var x09 = Phoenix.bind( 'm', ['alt'], function() { cycle('MacVim') });
var x10 = Phoenix.bind( 'e', ['alt'], function() { cycle('Eclipse') });
var x11 = Phoenix.bind( 'f', ['alt'], function() { cycle('Finder') });
VimMode.bind( 't', mNone, function() {
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
VimMode.bind( 'f', mNone, function() {
  var rect = Window.focusedWindow().screen().visibleFrameInRectangle();
  Window.focusedWindow().setFrame(rect);
  VimMode.disable();
});
VimMode.bind ('l', mNone, function() {
  var rect = Screen.mainScreen().visibleFrameInRectangle();
  rect.width = rect.width/2;
  rect.x = rect.width;
  Window.focusedWindow().setFrame(rect);
  VimMode.disable();
});
VimMode.bind ('h', mNone, function() {
  try {
    var rect = Screen.mainScreen().visibleFrameInRectangle();
    rect.width = rect.width/2;
    Window.focusedWindow().setFrame(rect);
    VimMode.disable();
  } catch (e) {
    Phoenix.log(e)
  }
});
 
// Chrome Devtools
//
// When checking HTML/JS in Chrome I want to have my browsing window to the
// East and my Chrome devtools window to the W, the latter not quite on full
// height.
VimMode.bind( 'd', mNone, function() {
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
 
  VimMode.disable();
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
 
VimMode.disable();
toast("reloaded");
