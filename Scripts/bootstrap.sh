#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v xcodegen >/dev/null 2>&1; then
  pushd "$ROOT_DIR/Demo" >/dev/null
  xcodegen generate --spec project.yml
  popd >/dev/null
else
  echo "warning: xcodegen not found. Install it to generate Demo/PhaseDrivenDemo.xcodeproj from Demo/project.yml"
fi

if [ -d "$ROOT_DIR/Demo/PhaseDrivenDemo.xcodeproj" ]; then
  xcodebuild -project "$ROOT_DIR/Demo/PhaseDrivenDemo.xcodeproj" -resolvePackageDependencies >/dev/null
fi

echo "Bootstrap complete."
