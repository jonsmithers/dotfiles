var VimMode = {
  showModals() {
    this._modals = Screen.all().map(screen => screen.frame()).map(screenFrame => {
      Phoenix.log(screenFrame.x);
      let modal = new Modal();
      modal.text = "Moving Windows";
      modal.appearance = 'light';
      modal.weight = 30;
      modal.origin = {
        x: (screenFrame.x + screenFrame.width/2-130),
        y: (screenFrame.y + screenFrame.height/2)
      };
      return modal;
    });

    this._modals.forEach(modal => modal.show());
  },
  hideModals() {
    if (this._modals) {
      this._modals.forEach(modal => modal.close());
    }
  }
};
VimMode._keys = [];
VimMode.disable = function() {
  this.hideModals();
  this._active = false;
  _(this._keys).each(function(key) {
    key.disable();
  });
};
VimMode.enable = function() {
  this.showModals()
  this._active = true;
  _(this._keys).each(function(key) {
    key.enable();
  });
};
VimMode.bind = function(key, mods, callback) {
  var callback2 = function() {
    try {
      callback();
    } catch (e) {
      toast(e);
      VimMode.disable();
    }
  };
  keyhandler = new Key(key, mods, callback2);
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
var alt_w = new Key('w', ['alt'], function() {
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

function toast(str) {
   var m = new Modal();
   m.text = str;
   m.origin = {x: 50, y: 90};
   m.duration = 0.6;
   m.show();
}

// ############################################################################
// Bindings
// ############################################################################

VimMode.bind( ".", mNone, function() {
  var rect = Window.focused().frame();
  rect.width = rect.width*0.9;
  Window.focused().setFrame(rect);
});

// The cursor keys move the focussed window.
VimMode.bind( 'up', mNone, function() {
  Window.focused().nudgeUp( 5 );
});

VimMode.bind( 'right', mNone, function() {
  Window.focused().nudgeRight( 5 );
});

VimMode.bind( 'down', mNone, function() {
  Window.focused().nudgeDown( 5 );
});

VimMode.bind( 'left', mNone, function() {
  Window.focused().nudgeLeft( 5 );
});

// <SHIFT> + cursor keys grows/shrinks the focussed window.
VimMode.bind( 'right', mShift, function() {
  Window.focused().growWidth();
});

VimMode.bind( 'left', mShift, function() {
  Window.focused().shrinkWidth();
});

VimMode.bind( 'up', mShift, function() {
  Window.focused().shrinkHeight();
});

VimMode.bind( 'down', mShift, function() {
  Window.focused().growHeight();
});

// ############################################################################
// Bindings for specific apps
// ############################################################################
//

var focusTitle = function(title) {

  var m = new Modal();
  m.message = "Focusing...";
  m.origin = {x: 50, y: 90};
  m.show();

  try {
    var winToFocus;
    var allWindows = Window.all({visible: true});
    Phoenix.log("Searching " + allWindows.length + " windows");
    allWindows.forEach(function(element, index, array) {
      if (element.title().indexOf(title) === 0) {
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
    Phoenix.log('error');
    Phoenix.log(e);
    toast(e);
  } finally {
    m.close();
  }
};
var cycle = function(appName) {
  try {
    var exclusions = [];
    for (var i = 1; i < arguments.length; i++) {
      exclusions.push(arguments[i]);
    }
    var app = App.get(appName);
    if (!app) {
      var result = App.launch(appName);
      if (result) {
        result.focus();
        toast(appName + " launched");
      } else {
        toast("couldn't launch " + appName);
      }
      return;
    }

    var appWindowsTemp = app.windows();
    var appWindows = [];

    for (i = 0; i < appWindowsTemp.length; i++) {
      if (appWindowsTemp[i].title()) {
        appWindows.push(appWindowsTemp[i]);
      }
    }

    if (appWindows.length === 0) {
      var launched = App.launch(appName);
      if (launched) {
        launched.focus();
      }
      toast(appName + " had no titled windows");
      return;
    }

    var curWin = Window.focused();
    var curWinBelongsToApp = false;
    if (curWin) { // some window is focused
      for (i = 0; i < appWindows.length; i++) {
        if (curWin.title() == appWindows[i].title()) {
          curWinBelongsToApp = true;
          break;
        }
      }
    }

    var index = 0;
    if (curWinBelongsToApp) {
      if (appWindows.length == 1) {
        toast(appName + " only has 1 window");
        return;
      }

      index++; // do not focus already-focused window
    }


    var shouldBeExcluded = function(title) {
      for (var i = 0; i < exclusions.length; i++) {
        if (title.indexOf(exclusions[i]) === 0) {
          return true;
        }
      }
      return false;
    };

    while (shouldBeExcluded(appWindows[index].title())) {
      Phoenix.log("exclude " + appWindows[index].title());
      index++;
      if (index == appWindows.length) {
        break;
      }
    }
    if (index == appWindows.length) {
      toast("no real windows to switch to");
      return;
    }
    appWindows[index].focus();
    toast(appWindows[index].title());
    return;
  } catch (e) {
    toast(e);
  }
};

var storedKeys = [
  new Key( 'a', ['alt'], function() { cycle('Atom'); }),
  new Key( 'e', ['alt'], function() { cycle('Eclipse'); }),
  new Key( 'f', ['alt'], function() { cycle('Finder'); }),
  new Key( 'i', ['alt'], function() { cycle('Google Chrome', 'Google Hangouts', 'Developer Tools', 'Hangouts', 'Pushbullet', 'Google Play Music'); }),
  new Key( 'm', ['alt'], function() { cycle('Mail'); }),
  new Key( 'n', ['alt'], function() { cycle('iTerm'); }),
  new Key( 'o', ['alt'], function() { cycle('Microsoft Outlook'); }),
  new Key( 'p', ['alt'], function() { focusTitle('Pushbullet'); }),
  new Key( 'r', ['alt'], function() { cycle('Rocket.Chat+'); }),
  new Key( 's', ['alt'], function() { cycle('WebStorm'); }),
];

VimMode.bind('-', mNone, () => {
  var frame = Window.focused().frame()
  frame.height -= 10
  Window.focused().setSize(frame)
});
VimMode.bind('t', mNone, withFocusedWindow(window => {
  var otherScreen = window.screen().next();
  if (!otherScreen) {
    toast("no other screen");
    return;
  }

  var screenFrame = otherScreen.flippedVisibleFrame();

  window.setFrame({
    x: screenFrame.x,
    y: screenFrame.y,
    width: Math.min(window.size().width, screenFrame.width),
    height: Math.min(window.size().height, screenFrame.height)
  });
}));
VimMode.bind('f', mNone, withFocusedWindow(window => {
  window.setFrame(window.screen().flippedVisibleFrame());
}));
function withFocusedWindow(callback) {
  return () => {
    if (!Window.focused()) {
      toast("No focused window");
      VimMode.disable();
      return;
    }
    callback(Window.focused());
  };
}
VimMode.bind ('j', mNone, withFocusedWindow(window => {
  var rect = window.frame();
  rect.y += rect.height/2;
  rect.height -= rect.height/2;
  window.setFrame(rect);
}));
VimMode.bind ('k', mNone, withFocusedWindow(window => {
  var rect = window.frame();
  rect.height -= rect.height/2;
  window.setFrame(rect);
}));
VimMode.bind ('l', mNone, withFocusedWindow(window => {
  var rect = window.screen().flippedVisibleFrame();
  rect.x = rect.x + rect.width/2;
  rect.width = rect.width/2;
  window.setFrame(rect);
}));
VimMode.bind ('h', mNone, withFocusedWindow(window => {
  var rect = window.screen().flippedVisibleFrame();
  rect.width = rect.width/2;
  window.setFrame(rect);
}));
VimMode.bind('k', ['alt'], withFocusedWindow(window => {
  window.focusClosestNeighbor('north')
  VimMode.disable();
}));
VimMode.bind('j', ['alt'], withFocusedWindow(window => {
  window.focusClosestNeighbor('south')
  VimMode.disable();
}));
VimMode.bind('l', ['alt'], withFocusedWindow(window => {
  window.focusClosestNeighbor('east')
  VimMode.disable();
}));
VimMode.bind('h', ['alt'], withFocusedWindow(window => {
  window.focusClosestNeighbor('west')
  VimMode.disable();
}));

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
  return _( this.all() ).find( function( app ) {
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
