#!/bin/sh
set -eu
PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export DOTNET_CLI_HOME="$PROJECT_DIR/tools/dotnet-home"
export NUGET_PACKAGES="$PROJECT_DIR/tools/nuget"
if command -v dotnet >/dev/null 2>&1; then
    DOTNET_CMD=dotnet
else
    DOTNET_CMD="$PROJECT_DIR/tools/dotnet/dotnet"
fi
"$DOTNET_CMD" build "$PROJECT_DIR/src/Continue.csproj" -c Release --ignore-failed-sources
mkdir -p "$PROJECT_DIR/dist"
cp "$PROJECT_DIR/src/bin/Release/netstandard2.1/ValheimContinue.dll" "$PROJECT_DIR/dist/ValheimContinue.dll"
