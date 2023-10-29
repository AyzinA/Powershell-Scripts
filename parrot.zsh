#!/bin/zsh

# Create and run a new terminal window with 'curl parrot.live' in each.
for i in {1..10}; do
  osascript -e 'tell application "Terminal" to do script "curl parrot.live"'
done
