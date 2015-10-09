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
  keys.push(api.bind(key, mods, callback));
}
 
// ############################################################################
// Modal activation
// ############################################################################
 
// Modal activator
// This hotkey enables/disables all other hotkeys.
var active = false;
api.bind('w', ['alt'], function() {
  if (!active) {
    enableKeys();
  } else {
    disableKeys();
  }
});
 
// These keys end Phoenix mode.
bind('escape', [], function() {
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
 
// Center window.
bind( 'c', mNone, cycleCalls(
  toGrid,
  [
    [0.22, 0.025, 0.56, 0.95],
    [0.1, 0, 0.8, 1]
  ]
));
 
// The cursor keys together with cmd make any window occupy any
// half of the screen.
bind( 'right', mCmd, cycleCalls(
  toGrid,
  [
    [0.5, 0, 0.5, 1], 
    [0.75, 0, 0.25, 1]
  ]
));
 
bind( 'left', mCmd, cycleCalls(
  toGrid,
  [
    [0, 0, 0.5, 1],
    [0, 0, 0.25, 1]
  ]
));
 
bind( 'down', mCmd, function() {
  Window.focusedWindow().toGrid(0, 0.7, 1, 0.3);
});
 
bind( 'up', mCmd, function() {
  Window.focusedWindow().toGrid(0, 0, 1, 0.3);
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
    if (element.title().indexOf(title) == 0) {
      if (!winToFocus) {
        winToFocus = element;
      }
    }
  });

  if (winToFocus) {
    winToFocus.focusWindow();
    api.alert("focused");
  } else {
    api.alert("No window has title '"+title+"'");
  }
}
var cycle = function(appName) {
  //api.alert(curWin.title());

  var exclusions = new Array();
  for (var i = 1; i < arguments.length; i++) {
    exclusions.push(arguments[i]);
  }
  var app = App.findByTitle(appName);
  if (!app) {
    api.alert("app is null");
    api.launch(appName);
    return;
  }

  var appWindowsTemp = app.allWindows();
  var appWindows = new Array();

  for (var i = 0; i < appWindowsTemp.length; i++) {
    if (appWindowsTemp[i].title()) {
      appWindows.push(appWindowsTemp[i]);
    }
  }

  if (appWindows.length==0) {
    api.alert("app has no titled windows");
    api.launch(appName);
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
      api.alert("no other windows");
      return;
    }

    index++; // do not focus already-focused window
  }

  while (shouldBeExcluded(appWindows[index].title())) {
    api.alert("exclude " + appWindows[index].title());
    index++;
    if (index == appWindows.length) {
      break;
    }
  }
  if (index == appWindows.length) {
    api.alert("no real windows to switch to");
    return;
  }
  api.alert('Go To "' + appWindows[index].title() +'"');
  appWindows[index].focusWindow();
  return;

  function shouldBeExcluded(title) {
    for (var i = 0; i < exclusions.length; i++) {
      if (title.indexOf(exclusions[i]) == 0) {
        return true;
      }
    }
    return false;
  }
}
api.bind( 'a', ['alt'], function() { api.alert(""); cycle('Atom') });
api.bind( 'i', ['alt'], function() { api.alert(""); cycle('Google Chrome', 'Hangouts', 'Pushbullet', 'Google Play Music') })
api.bind( 'h', ['alt'], function() { api.alert("focus"); focusTitle('Hangouts') });
api.bind( 'p', ['alt'], function() { api.alert("focus"); focusTitle('Pushbullet') });
api.bind( 't', ['alt'], function() { api.alert(""); cycle('iTerm') });
api.bind( 'o', ['alt'], function() { api.alert(""); cycle('Microsoft Outlook') });
api.bind( 'l', ['alt'], function() { api.alert(""); cycle('Microsoft Lync') });
api.bind( 'e', ['alt'], function() { api.alert(""); cycle('Eclipse') });
api.bind( 'f', ['alt'], function() { api.alert(""); cycle('Finder') });
bind( 't', mNone, function() {
  api.alert("throwing");
  var focusedWindow = Window.focusedWindow();
  var nextScreen = focusedWindow.screen().nextScreen()
  if (!nextScreen) {
    api.alert("no other screen");
  } else {
    var screenFrame = nextScreen.frameWithoutDockOrMenu();
    var windowFrame = focusedWindow.topLeft();
    Window.focusedWindow().setTopLeft({x: screenFrame.x, y: screenFrame.y});
    api.alert("threw window");
  }
  disableKeys();
});
// api.bind( 'i', ['alt'], function() {
//   var app = App.findByTitle('Google Chrome');
//   if (!app) {
//     api.launch('Google Chrome');
//   } else {
//     var curWin = Window.focusedWindow();
//     var index = -1;
//     if (app.allWindows().length==0) {
//       api.launch('Google Chrome');
//     }
//     app.allWindows().forEach(function(element, index2, array) {
//       if (element.title() == curWin.title()) {
//         index = index2;   
//       }
//     });
// 
//     var finalIndex=index;
//     index++;
//     if (index == app.allWindows().length) {
//       index = 0;
//     }
//     while ( ((!app.allWindows()[index].title()) && (index!=finalIndex)) || (app.allWindows()[index].title().indexOf('Hangouts')==0) ) {
//       index++;
//       if (index == app.allWindows().length) {
//         index = 0;
//       }
//     }
//     app.allWindows()[index].focusWindow();
//   }
// });
// api.bind( 't', ['alt'], function() {
//   var app = App.findByTitle('iTerm');
//   if (!app || !app.firstWindow()) {
//     api.launch('iTerm');
//   } else {
//     var win = app.firstWindow().focusWindow();
//   }
// });
// api.bind( 'o', ['alt'], function() {
//   var app = App.findByTitle('Microsoft Outlook');
//   if (!app) {
//     api.launch('Microsoft Outlook')
//   } else {
//     var win = app.firstWindow();
//     win.focusWindow();
//   }
// });
// api.bind( 'e', ['alt'], function() {
//   var app = App.findByTitle('Eclipse');
//   if (!app) {
//     api.launch('Eclipse');
//   } else {
//     var win = app.firstWindow();
//     win.focusWindow();
//   }
// });
// api.bind( 'f', ['alt'], function() {
//   var app = App.findByTitle('Finder');
//   if (!app || !app.firstWindow()) {
//     api.launch('Finder');
//   } else {
//     app.firstWindow().focusWindow();
//   }
// });
bind( 'f', mNone, function() {
  Window.focusedWindow().toFullScreen();
  disableKeys();
});
bind ('l', mNone, function() {
  Window.focusedWindow().toE();
  disableKeys();
});
bind ('h', mNone, function() {
  Window.focusedWindow().toW();
  disableKeys();
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
 
  api.alert( 'Chrome Dev Tools Layout', 0.25 );
 
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
 
// Disables all remembered keys.
function disableKeys() {
  active = false;
  _(keys).each(function(key) {
    key.disable();
  });
  api.alert("done", 0.5);
}
 
// Enables all remembered keys.
function enableKeys() {
  active = true;
  _(keys).each(function(key) {
    key.enable();
  });
  api.alert("Phoenix", 0.5);
}
 
// ### Helper methods `Window`
//
// #### Window#toGrid()
//
// This method can be used to push a window to a certain position and size on
// the screen by using four floats instead of pixel sizes.  Examples:
//
//     // Window position: top-left; width: 25%, height: 50%
//     someWindow.toGrid( 0, 0, 0.25, 0.5 );
//
//     // Window position: 30% top, 20% left; width: 50%, height: 35%
//     someWindow.toGrid( 0.3, 0.2, 0.5, 0.35 );
//
// The window will be automatically focussed.  Returns the window instance.
function windowToGrid(window, x, y, width, height) {
  var screen = window.screen().frameWithoutDockOrMenu();
 
  window.setFrame({
  x: Math.round( x * screen.width ) + padding + screen.x,
  y: Math.round( y * screen.height ) + padding + screen.y,
  width: Math.round( width * screen.width ) - ( 2 * padding ),
  height: Math.round( height * screen.height ) - ( 2 * padding )
  });
 
  window.focusWindow();
 
  return window;
}
 
function toGrid(x, y, width, height) {
  windowToGrid(Window.focusedWindow(), x, y, width, height);
}
 
Window.prototype.toGrid = function(x, y, width, height) {
  windowToGrid(this, x, y, width, height);
};
 
// Convenience method, doing exactly what it says.  Returns the window
// instance.
Window.prototype.toFullScreen = function() {
  return this.toGrid( 0, 0, 1, 1 );
};
 
 
// Convenience method, pushing the window to the top half of the screen.
// Returns the window instance.
Window.prototype.toN = function() {
  return this.toGrid( 0, 0, 1, 0.5 );
};
 
// Convenience method, pushing the window to the right half of the screen.
// Returns the window instance.
Window.prototype.toE = function() {
  return this.toGrid( 0.5, 0, 0.5, 1 );
};
 
// Convenience method, pushing the window to the bottom half of the screen.
// Returns the window instance.
Window.prototype.toS = function() {
  return this.toGrid( 0, 0.5, 1, 0.5 );
};
 
// Convenience method, pushing the window to the left half of the screen.
// Returns the window instance.
Window.prototype.toW = function() {
  return this.toGrid( 0, 0, 0.5, 1 );
};
 
 
// Stores the window position and size, then makes the window full screen.
// Should the window be full screen already, its original position and size
// is restored.  Returns the window instance.
Window.prototype.toggleFullscreen = function() {
  if ( previousSizes[ this ] ) {
  this.setFrame( previousSizes[ this ] );
  delete previousSizes[ this ];
  }
  else {
  previousSizes[ this ] = this.frame();
  this.toFullScreen();
  }
 
  return this;
};
 
// Move the currently focussed window left by [`nudgePixel`] pixels.
Window.prototype.nudgeLeft = function( factor ) {
  var win = this,
  frame = win.frame(),
  pixels = nudgePixels * ( factor || 1 );
 
  if (frame.x >= pixels) {
  frame.x -= pixels;
  } else {
  frame.x = 0;
  }
  win.setFrame( frame );
};
 
// Move the currently focussed window right by [`nudgePixel`] pixels.
Window.prototype.nudgeRight = function( factor ) {
  var win = this,
  frame = win.frame(),
  maxLeft = win.screen().frameIncludingDockAndMenu().width - frame.width,
  pixels = nudgePixels * ( factor || 1 );
 
  if (frame.x < maxLeft - pixels) {
  frame.x += pixels;
  } else {
  frame.x = maxLeft;
  }
  win.setFrame( frame );
};
 
// Move the currently focussed window left by [`nudgePixel`] pixels.
Window.prototype.nudgeUp = function( factor ) {
  var win = this,
  frame = win.frame(),
  pixels = nudgePixels * ( factor || 1 );
 
  if (frame.y >= pixels) {
  frame.y -= pixels;
  } else {
  frame.y = 0;
  }
  win.setFrame( frame );
};
 
// Move the currently focussed window right by [`nudgePixel`] pixels.
Window.prototype.nudgeDown = function( factor ) {
  var win = this,
  frame = win.frame(),
  maxTop = win.screen().frameIncludingDockAndMenu().height - frame.height,
  pixels = nudgePixels * ( factor || 1 );
 
  if (frame.y < maxTop - pixels) {
  frame.y += pixels;
  } else {
  frame.y = maxTop;
  }
  win.setFrame( frame );
};
 
// #### Functions for growing / shrinking the focussed window.
 
Window.prototype.growWidth = function() {
  this.nudgeLeft(3);
 
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;
 
  if (frame.width < screenFrame.width - pixels) {
  frame.width += pixels;
  } else {
  frame.width = screenFrame.width;
  }
 
  win.setFrame(frame);
};
 
Window.prototype.growHeight = function() {
  this.nudgeUp(3);
 
  var win = this,
  frame = win.frame(),
  screenFrame = win.screen().frameIncludingDockAndMenu(),
  pixels = nudgePixels * 6;
 
  if (frame.height < screenFrame.height - pixels) {
  frame.height += pixels;
  } else {
  frame.height = screenFrame.height;
  }
 
  win.setFrame(frame);
};
 
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

