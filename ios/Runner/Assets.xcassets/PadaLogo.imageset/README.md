# Pada Logo Asset Set

This asset set contains the logo for the iOS native splash screen.

## Current Setup

The launch screen is configured to use the `PadaLogo` image asset. Since iOS storyboards don't support SVG directly, PNG versions of the logo are required.

## Required Files

You need to add PNG versions of `assets/images/pada_logo.svg` to this directory:

1. **PadaLogo.png** (1x) - Base resolution
2. **PadaLogo@2x.png** (2x) - Double resolution for Retina displays
3. **PadaLogo@3x.png** (3x) - Triple resolution for Retina HD displays

## How to Convert SVG to PNG

1. Open `assets/images/pada_logo.svg` in a design tool (Figma, Sketch, Adobe Illustrator, etc.)
2. Export as PNG at three different sizes:
   - 1x: 200x200 pixels (or appropriate size)
   - 2x: 400x400 pixels
   - 3x: 600x600 pixels
3. Save them as:
   - `PadaLogo.png`
   - `PadaLogo@2x.png`
   - `PadaLogo@3x.png`
4. Place all three files in this directory: `ios/Runner/Assets.xcassets/PadaLogo.imageset/`

## Alternative: Using Command Line

If you have ImageMagick or another tool installed:
```bash
# Convert SVG to PNG at different resolutions
convert -background none -density 72 assets/images/pada_logo.svg -resize 200x200 ios/Runner/Assets.xcassets/PadaLogo.imageset/PadaLogo.png
convert -background none -density 144 assets/images/pada_logo.svg -resize 400x400 ios/Runner/Assets.xcassets/PadaLogo.imageset/PadaLogo@2x.png
convert -background none -density 216 assets/images/pada_logo.svg -resize 600x600 ios/Runner/Assets.xcassets/PadaLogo.imageset/PadaLogo@3x.png
```

## Note

The logo should be white/transparent to match the blue background of the splash screen, similar to how it appears in the Flutter splash screen.

