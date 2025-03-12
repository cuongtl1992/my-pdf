#!/bin/bash

# Script to set up the Android build environment with Java 17
# This script should be run before building Android apps with Flutter

# Set JAVA_HOME to Java 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java version
java -version

echo "Android build environment set up with Java 17"
echo "You can now run 'flutter build apk' or other Android build commands"

# Optional: Add this to your .zshrc or .bash_profile to make it permanent
echo ""
echo "To make this configuration permanent, add these lines to your ~/.zshrc or ~/.bash_profile:"
echo 'export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"'
echo 'export PATH="$JAVA_HOME/bin:$PATH"' 