#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
source_icon="$root/docs/images/app-icon.png"

if [[ ! -f "$source_icon" ]]; then
  echo "Missing $source_icon" >&2
  exit 1
fi

resize() {
  local size="$1"
  local destination="$2"
  sips -z "$size" "$size" "$source_icon" --out "$destination" >/dev/null
}

ios_dir="$root/ios/Runner/Assets.xcassets/AppIcon.appiconset"
while read -r filename size; do
  resize "$size" "$ios_dir/$filename"
done <<'SIZES'
Icon-App-20x20@1x.png 20
Icon-App-20x20@2x.png 40
Icon-App-20x20@3x.png 60
Icon-App-29x29@1x.png 29
Icon-App-29x29@2x.png 58
Icon-App-29x29@3x.png 87
Icon-App-40x40@1x.png 40
Icon-App-40x40@2x.png 80
Icon-App-40x40@3x.png 120
Icon-App-60x60@2x.png 120
Icon-App-60x60@3x.png 180
Icon-App-76x76@1x.png 76
Icon-App-76x76@2x.png 152
Icon-App-83.5x83.5@2x.png 167
Icon-App-1024x1024@1x.png 1024
SIZES

launch_dir="$root/ios/Runner/Assets.xcassets/LaunchImage.imageset"
resize 168 "$launch_dir/LaunchImage.png"
resize 336 "$launch_dir/LaunchImage@2x.png"
resize 504 "$launch_dir/LaunchImage@3x.png"

macos_dir="$root/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for size in 16 32 64 128 256 512 1024; do
  resize "$size" "$macos_dir/app_icon_$size.png"
done

while read -r density size; do
  resize "$size" "$root/android/app/src/main/res/mipmap-$density/ic_launcher.png"
done <<'SIZES'
mdpi 48
hdpi 72
xhdpi 96
xxhdpi 144
xxxhdpi 192
SIZES

echo "Generated app icons from docs/images/app-icon.png"
