#!/bin/sh
set -eu
umask 077
PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
GAME_DIR="${VALHEIM_DIR:-$HOME/.local/share/Steam/steamapps/common/Valheim}"
cd "$GAME_DIR"
if [ "$#" -eq 0 ]; then
    set -- "$GAME_DIR/valheim.x86_64"
fi
exec "$PROJECT_DIR/runtime/start_game_bepinex.sh" "$@"
