#!/bin/bash
echo "tell application \"System Events\" to key up \"{alt}\"" | osascript
echo "tell application \"System Events\" to key up \"{option}\"" | osascript
echo "tell application \"System Events\" to key up \"{command}\"" | osascript
echo "tell application \"System Events\" to key up \"{shift}\"" | osascript
echo "tell application \"System Events\" to keystroke \"$1\"" | osascript
