#!/bin/zsh
BIN_NAME='xcvdetector'
BIN_PATH='/usr/local/bin'
  
if [ "$1" = "install" ]; then

  if [ "$2" ]; then
    BIN_PATH=$2
  fi
  
  EXECUTABLE=".build/release/$BIN_NAME"
  if [ -f "$EXECUTABLE" ]; then
    echo "Coping xcvdetector to the $BIN_PATH"
    #cp "$EXECUTABLE" "$BIN_PATH/$BIN_NAME"
    echo "Done! Restart terminal or open new and use $BIN_NAME"
  else
    ls .build/release
    echo '================================'
    echo 'Cant locate executable. Did you run "make"?'
    echo '================================'
  fi
  
  exit 0
fi

echo 'CLEANING. Please wait...'
swift package clean

if swift build; then
  echo '================================'
  echo 'BUILD SUCCEED'
  echo '================================'  
else
  echo '================================'
  echo 'BUILD FAILED'
  echo '================================'
  exit 1
fi

if swift test; then
  echo '================================'
  echo 'TESTS PASSED'
  echo '================================'
else
  echo '================================'
  echo 'TESTS FAILED'
  echo '================================'
  exit 1
fi

if swift build -c release; then
  echo '================================'
  echo 'RELEASE BUILD PASSED'
  echo "You can find executable at ./buid/release/$BIN_NAME or run 'make install' to install"
  echo '================================'
else
  echo '================================'
  echo 'RELEASE BUILD FAILED'
  echo '================================'
  exit 1
fi
