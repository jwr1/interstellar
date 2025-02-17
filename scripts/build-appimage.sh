#!/bin/sh

set -eu

EXE_BUNDLE_DIR=$(echo build/linux/*/release/bundle)
BUILD_DIR=$(mktemp -d)

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

LIB4BN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"

# Prepare AppDir
mkdir -p "$BUILD_DIR"/AppDir/usr/share/applications

cp -r "$EXE_BUNDLE_DIR"/data "$BUILD_DIR"/AppDir
cp linux/appimage/interstellar.desktop "$BUILD_DIR"/AppDir
cp linux/appimage/interstellar.desktop "$BUILD_DIR"/AppDir/usr/share/applications
cp assets/icons/logo.png "$BUILD_DIR"/AppDir/interstellar.png
cp assets/icons/logo.png "$BUILD_DIR"/AppDir/.DirIcon

# ADD LIBRARIES
wget "$LIB4BN" -O "$BUILD_DIR"/lib4bin
chmod +x "$BUILD_DIR"/lib4bin
xvfb-run -a -- "$BUILD_DIR"/lib4bin l -p -v -e -k \
	-d "$BUILD_DIR"/AppDir \
	"$EXE_BUNDLE_DIR"/interstellar

# Prepare sharun
ln -s ./bin/interstellar "$BUILD_DIR"/AppDir/AppRun
"$BUILD_DIR"/AppDir/sharun -g

# MAKE APPIMAGE WITH URUNTIME
wget -q "$URUNTIME" -O "$BUILD_DIR"/uruntime
chmod +x "$BUILD_DIR"/uruntime

echo "Generating AppImage..."
mkdir -p dist
"$BUILD_DIR"/uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S24 -B16 \
	--header "$BUILD_DIR"/uruntime \
	-i "$BUILD_DIR"/AppDir -o dist/interstellar-linux-"$ARCH".AppImage

rm -r "$BUILD_DIR"
echo "All Done!"
