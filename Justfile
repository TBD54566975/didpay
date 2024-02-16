# Run the Flutter app
run:
  flutter run

# Get Flutter and Dart packages
get:
  #!/bin/bash
  echo "Getting dependencies for main project"
  flutter pub get
  echo "Getting dependencies for packages"
  for dir in packages/*; do \
    if [ -d $dir ]; then \
      echo "Getting dependencies in $dir"; \
      (cd $dir && flutter pub get || dart pub get); \
    fi \
  done

# Clean the project
clean:
  flutter clean

# Build the app for release
build:
  flutter build apk

# Run tests
test: test-app test-packages

# Run Flutter tests
test-app:
  flutter test

# Run package tests
test-packages:
  #!/bin/bash
  for dir in packages/*; do \
    if [ -d $dir ]; then \
      echo "Running tests in $dir"; \
      (cd $dir && dart test); \
    fi \
  done

# Analyze the project's Dart code
analyze:
  #!/bin/bash
  flutter analyze
  for dir in packages/*; do \
    if [ -d $dir ]; then \
      (cd $dir && dart analyze); \
    fi \
  done  

# Generate code (localization, etc.)
generate:
  flutter gen-l10n

# Coverage report
coverage:
  #!/bin/bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  open coverage/html/index.html
