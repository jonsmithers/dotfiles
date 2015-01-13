S.log( "===================================== " + (new Date()).toTimeString() + " =====================================");
var monitorThunderbolt = "2560x1440";
// CREATE OPERATIONS
/**
 * param appName {String} The NAME of the app to focus or iterate
 * Returns true if it found and focussed a window, otherwise false.
 */
var iterateApp = function(appName) {
  if (!appName) {
    appName = S.app().name();
    S.log("Using focussed app: " + appName);
  } else {
    S.log(appName + ": iterating app");
  }

  // get ALL windows for app 
  // (workaround for having multiple eclipse workspaces open)
  var appWindows = [];
  slate.eachApp(function(app) {
    if (app.name() == appName) {
      app.eachWindow(function(win) {
        if (win.title()) {
          if (win.title() != "Hangouts") // TODO: don't hard code this
          appWindows.push(win);
        }
      });
    }
  });

  // handle edge cases
  if (appWindows.length == 0) {
    S.log(appName + ": no windows found");
    return false;
  }
  if (appWindows.length == 1) {
    appWindows[0].focus();
    S.log(appName + ": only 1 window");
    return true;
  }

  // choose window to focus
  if (S.window().title() == appWindows[0].title()) {
    appWindows[1].focus();
  } else {
    appWindows[0].focus();
  }

  // log messages
  S.log("=== v " + appName + " v ===");
  appWindows.forEach(function(win) {
    S.log(appName + "::" + win.title());
  });
  S.log("=== ^ " + appName + " ^ ===");

  return true;
}
var pushRight = slate.operation("push", {
  "direction" : "right",
  "style" : "bar-resize:screenSizeX/2"
});
var pushLeft = slate.operation("push", {
  "direction" : "left",
  "style" : "bar-resize:screenSizeX/2"
});
var halveHeight = slate.operation("move", {
      "x": "windowTopLeftX",
      "y": "windowTopLeftY",
      "width": "windowSizeX",
      "height": "screenSizeY/2",
});
var pushUp = slate.operation("push", {
  "direction" : "top",
  "style" : "none"
});
var pushDown = slate.operation("push", {
  "direction" : "bottom",
  "style" : "none"
});
var fullscreen = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX",
  "height" : "screenSizeY"
});

var showOrOpen = function(appName, appPath) {
  if (!iterateApp(appName)) {
    S.shell('/usr/bin/open -a "' + appPath + '"');
  }
}


var focusAsma    = function() { slate.log("enter function"); iterateApp("mil.af.c2ad.asma.client.swing.ui.AsmaClientDev"); };
var focusChrome  = function() { slate.log("enter function"); if (!iterateApp("Google Chrome")) S.shell('/usr/bin/open -a "/Applications/Google Chrome.app/"'); };
var focusEclipse = function() { slate.log("enter function"); if (!iterateApp("Eclipse")) S.shell('/usr/bin/open -a "/Users/smithers/programs/eclipse/Eclipse.app/"'); };
var focusFinder  = function() { slate.log("enter function"); if (!iterateApp("Finder")) S.shell('/usr/bin/open /Users/smithers/git/.'); };
var focusITerm   = function() { slate.log("enter function"); if (!iterateApp("iTerm")) S.shell('/usr/bin/open -a /Applications/iTerm.app/'); };
var focusMail    = function() { slate.log("enter function"); if (!iterateApp("Mail")) S.shell('/usr/bin/open -a /Applications/Mail.app'); };
var focusOutlook = function() { slate.log("enter function"); showOrOpen("Microsoft Outlook", "/Applications/Microsoft Office 2011/Microsoft Outlook.app"); };
var focusSublime = function() { slate.log("enter function"); showOrOpen("Sublime Text", "/Applications/Sublime Text.app"); };
var relaunchSlate = slate.operation("relaunch");
var testDelay = function() {S.log("Executing now"); };
/*
DEPRECATED ACTIONS
var focusITerm2 = slate.operation("focus", { "app" : "iTerm" });
var focusChrome2 = slate.operation("focus", { "app" : "Google Chrome" });
*/


// BIND THEM TO KEYS
slate.bindAll({
  "h:ctrl,alt,cmd": function(win) { win.doOperation(pushLeft); },
  "j:ctrl,alt,cmd": function(win) { win.doOperation(halveHeight); win.doOperation(pushDown); },
  "k:ctrl,alt,cmd": function(win) { win.doOperation(halveHeight); win.doOperation(pushUp);   },
  "l:ctrl,alt,cmd": function(win) { win.doOperation(pushRight); },
  "f:ctrl,alt":     function(win) { win.doOperation(fullscreen); },
  "a:alt": focusAsma,
  "i:alt": focusChrome,
  "e:alt": focusEclipse,
  "f:alt": focusFinder,
  "t:alt": focusITerm,
  "m:alt": focusMail,
  "o:alt": focusOutlook,
  "s:alt": focusSublime,
  "r:alt": relaunchSlate,
  "d:alt": testDelay,
});

slate.log("Parsed to end");
