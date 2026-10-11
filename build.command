#!/bin/zsh
set -eu
cd -- "${0:A:h}"
make -B -C backend
app="$PWD/build/KTC 显示器控制台.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
xcrun swiftc -parse-as-library -O -framework SwiftUI -framework AppKit App.swift Backup.swift -o "$app/Contents/MacOS/KTCControl"
cp backend/m1ddc "$app/Contents/Resources/"
cp backend/LICENSE "$app/Contents/Resources/m1ddc-LICENSE.txt"
cp Info.plist "$app/Contents/"
cp AppIcon.icns "$app/Contents/Resources/"
xattr -cr "$app"
codesign --force --sign - "$app/Contents/Resources/m1ddc"
codesign --force --sign - "$app"
print "Built: $app"
