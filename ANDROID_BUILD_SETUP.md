# Android Build Setup for Flutter

This document provides instructions on how to set up your environment for building Android apps with Flutter, avoiding Java compatibility issues.

## Java Version Compatibility

Flutter's Android build system works best with Java 17 (LTS). Using newer versions like Java 21 can cause compatibility issues with the Android Gradle plugin.

## Setup Instructions

### 1. Install Java 17

```bash
# Using Homebrew (macOS)
brew install --cask zulu@17

# Verify installation
/usr/libexec/java_home -v 17
```

### 2. Configure Your Project

For each Flutter project, update the `android/gradle.properties` file to include:

```properties
# Set Java home to Java 17
org.gradle.java.home=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
```

### 3. Use Compatible Gradle Versions

In `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.3-all.zip
```

In `android/settings.gradle`:

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "7.3.0" apply false
    id "org.jetbrains.kotlin.android" version "1.7.10" apply false
}
```

### 4. Set Environment Variables (Optional)

For a system-wide configuration, add to your `~/.zshrc` or `~/.bash_profile`:

```bash
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

### 5. Use the Setup Script

Alternatively, run the provided setup script before building:

```bash
source setup_android_build_env.sh
flutter build apk
```

## Troubleshooting

If you encounter build errors:

1. Verify Java version: `java -version`
2. Check Gradle configuration
3. Run `flutter clean` before building
4. Ensure localization files are generated: `flutter gen-l10n`

## Template Files

- `android_gradle_properties_template.txt`: Template for gradle.properties
- `setup_android_build_env.sh`: Script to set up the environment 