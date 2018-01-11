#!/usr/bin/env python
import json
import os

for localLocation, systemLocation in links.items():

  systemLocation = os.path.expanduser(systemLocation);
  localLocation  = os.path.realpath(localLocation);

  if not os.path.exists(localLocation):
    exit(localLocation + " does not exist")
  elif os.path.exists(systemLocation):
    print "already exists: " + systemLocation
  else:
    bashCommand = "ln -s %(localLocation)s %(systemLocation)s" % locals()
    print(bashCommand)
    os.system(bashCommand)
