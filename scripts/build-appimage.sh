#!/bin/sh

set -eu

export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$(uname -m)"

BUILD_DIR=$(mktemp -d)

LIB4BN_URL="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"

# Prepare AppDir
cp -r build/linux/*/release/bundle/. "$BUILD_DIR"/AppDir
cp linux/appimage/interstellar.desktop "$BUILD_DIR"/AppDir
cp assets/icons/logo.png "$BUILD_DIR"/AppDir/interstellar.png

# Add libraries
wget "$LIB4BN_URL" -O "$BUILD_DIR"/lib4bin
chmod +x "$BUILD_DIR"/lib4bin
xvfb-run -a -- "$BUILD_DIR"/lib4bin l -s -k -e -v -p -d "$BUILD_DIR"/AppDir "$BUILD_DIR"/AppDir/interstellar /usr/lib/*/libGL*
ln -s ../data "$BUILD_DIR"/AppDir/bin/data
ln -s ../lib "$BUILD_DIR"/AppDir/bin/lib
ln -s ../../data "$BUILD_DIR"/AppDir/shared/bin/data
ln -s ../../lib "$BUILD_DIR"/AppDir/shared/bin/lib

# Prepare sharun
ln "$BUILD_DIR"/AppDir/sharun "$BUILD_DIR"/AppDir/AppRun
"$BUILD_DIR"/AppDir/sharun -g

# Make AppImage
wget "$APPIMAGETOOL_URL" -O "$BUILD_DIR"/appimagetool
chmod +x "$BUILD_DIR"/appimagetool
"$BUILD_DIR"/appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n "$BUILD_DIR"/AppDir dist/interstellar-linux-$ARCH.AppImage

# Cleanup
rm -r "$BUILD_DIR"
echo "All done!"
