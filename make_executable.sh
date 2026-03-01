#!/bin/bash
# Quick script to make scripts executable
chmod +x rebuild.sh
chmod +x commit_and_push.sh
echo "Made rebuild.sh executable"
echo "Made commit_and_push.sh executable"
ls -la *.sh | grep -E "(rebuild|commit_and_push)\.sh"