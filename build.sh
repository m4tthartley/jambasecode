
files="main.c video_apple.m"
libs="-framework Cocoa -framework QuartzCore -framework Metal"

mkdir -p ./build
clang -g -I../core $files $libs -o ./build/jam