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
xvfb-run -a -- "$BUILD_DIR"/lib4bin --dst-dir "$BUILD_DIR"/AppDir --strip --with-hooks --strace-mode \
	"$EXE_BUNDLE_DIR"/interstellar /usr/lib/x86_64-linux-gnu/libGL*

# unsharun
rm -fv "$BUILD_DIR"/AppDir/lib
mv -v "$BUILD_DIR"/AppDir/shared/lib "$BUILD_DIR"/AppDir
mv -v "$BUILD_DIR"/AppDir/shared/bin/interstellar "$BUILD_DIR"/AppDir
patchelf --set-rpath \
	'$ORIGIN/lib:$ORIGIN/lib/pulseaudio:$ORIGIN/lib/gvfs:$ORIGIN/lib/gio/modules' \
	"$BUILD_DIR"/AppDir/interstellar
patchelf --set-interpreter ./lib/ld-linux-x86-64.so.2 "$BUILD_DIR"/AppDir/interstellar

echo '#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"

# since we patched a relative interpreter we have to change cwd
cd "$CURRENTDIR" || exit 1

export GIO_MODULE_DIR="$CURRENTDIR/lib/gio/modules"
export FONTCONFIG_FILE="$CURRENTDIR/etc/fonts/fonts.conf"
export GSETTINGS_SCHEMA_DIR="$CURRENTDIR/share/glib-2.0/schemas"
export __EGL_VENDOR_LIBRARY_DIRS="$CURRENTDIR/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d"
export XKB_CONFIG_ROOT="$CURRENTDIR/share/X11/xkb"
export TERMINFO="$CURRENTDIR/share/terminfo"
export XDG_DATA_DIRS="$CURRENTDIR/share:/usr/local/share:/usr/share"

exec "$CURRENTDIR"/interstellar' > "$BUILD_DIR"/AppDir/AppRun
chmod +x "$BUILD_DIR"/AppDir/AppRun

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
