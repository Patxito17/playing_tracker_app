#!/bin/bash
# scripts/screenshots_ios.sh
#
# Ejecuta el test de screenshots en el simulador iOS y organiza los PNGs
# en la estructura que espera Fastlane deliver.
#
# Uso: ./scripts/screenshots_ios.sh
# Prerequisitos: Xcode, Flutter, simulador "iPhone 17 Pro Max"

set -e

BUNDLE_ID="com.gabriom.playingtrackerapp"
DEVICE_NAME="iPhone 17 Pro Max"
OUTPUT_DIR="fastlane/screenshots"

echo "📱 Generando screenshots para iOS ($DEVICE_NAME)..."

# Arrancar simulador si no está corriendo
BOOTED=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep "Booted" | wc -l | tr -d ' ')
if [ "$BOOTED" -eq 0 ]; then
  echo "▶️  Arrancando simulador..."
  DEVICE_UDID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -Eo '[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}' | head -1)
  if [ -z "$DEVICE_UDID" ]; then
    echo "❌ No se encontró el simulador \"$DEVICE_NAME\". Comprueba con: xcrun simctl list devices"
    exit 1
  fi
  xcrun simctl boot "$DEVICE_UDID"
  sleep 5
fi

# Ejecutar integration test
echo "🧪 Ejecutando integration test de screenshots..."
flutter test integration_test/screenshots_test.dart -d "$DEVICE_NAME"

echo "📂 Extrayendo screenshots del simulador..."
APP_CONTAINER=$(xcrun simctl get_app_container booted "$BUNDLE_ID" data 2>/dev/null || echo "")

if [ -z "$APP_CONTAINER" ]; then
  echo "❌ No se encontró el contenedor de la app (Bundle ID: $BUNDLE_ID)."
  echo "   Asegúrate de que la app se instaló correctamente durante el test."
  exit 1
fi

SCREENSHOTS_DIR="$APP_CONTAINER/Documents/screenshots"

if [ ! -d "$SCREENSHOTS_DIR" ]; then
  echo "❌ No se encontró el directorio de screenshots: $SCREENSHOTS_DIR"
  exit 1
fi

# Organizar por locale para Fastlane: fastlane/screenshots/<locale>/<device>/
for FILE in "$SCREENSHOTS_DIR"/*.png; do
  [ -f "$FILE" ] || continue
  FILENAME=$(basename "$FILE")
  if [[ "$FILENAME" == *_en.png ]]; then
    LOCALE="en-US"
  elif [[ "$FILENAME" == *_es.png ]]; then
    LOCALE="es-ES"
  else
    LOCALE="en-US"
  fi
  DEST_DIR="$OUTPUT_DIR/$LOCALE/$DEVICE_NAME"
  mkdir -p "$DEST_DIR"
  cp "$FILE" "$DEST_DIR/$FILENAME"
  echo "   ✅ $FILENAME → $DEST_DIR/"
done

echo ""
echo "✅ Screenshots guardados en $OUTPUT_DIR:"
find "$OUTPUT_DIR" -name "*.png" | sort | sed 's/^/   /'
