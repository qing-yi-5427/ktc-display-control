#!/bin/zsh
set -eu
cd -- "${0:A:h}"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
sed '/@main struct KTCApp:/,$d' App.swift > "$test_dir/App.swift"
xcrun swiftc -parse-as-library -framework SwiftUI -framework AppKit "$test_dir/App.swift" Backup.swift tests/BackupTests.swift -o "$test_dir/BackupTests"
"$test_dir/BackupTests"
