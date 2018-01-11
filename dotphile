#!/usr/bin/env python
import json
import os

config = {}
for localPath, operativePath in json.load(open("config.json"))["links"].items():
  localPath = os.path.realpath(localPath)
  operativePath = os.path.expanduser(operativePath)
  config[localPath] = operativePath

missingFiles = filter(lambda f: not os.path.exists(f), config.keys())
if (len(missingFiles)):
  exit("Some files are missing\n  " + "\n  ".join(missingFiles))

existingFiles = filter(os.path.exists, config.values())
if (len(existingFiles)):
  print str(len(existingFiles)) + " operative paths already exist"
  print "  " + "\n  ".join(existingFiles)

pairsToLink = filter(lambda (localPath, operativePath): not os.path.exists(operativePath), config.items())
print "Creating " + str(len(pairsToLink)) + " symlinks"
for (localPath, operativePath) in pairsToLink:
  bashCommand = "ln -s %(localPath)s %(operativePath)s" % locals()
  print("  " + bashCommand)
  os.system(bashCommand)
