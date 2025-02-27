
set -e

files="system_apple.m game.c render.c"
libs="-framework Cocoa -framework QuartzCore -framework Metal"
options="-fno-objc-arc"

mkdir -p ./build

clang -g -I../core $files $libs $options -o ./build/game.so --shared
echo "game.so built"
clang -g -I../core main.m $files $libs $options -o ./build/jam -DHOTRELOAD
echo "jam built"