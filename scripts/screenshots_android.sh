#!/bin/bash
# scripts/screenshots_android.sh
#
# Ejecuta el test de screenshots en el emulador Android y organiza los PNGs
# en la estructura que espera Fastlane supply.
#
# Uso: ./scripts/screenshots_android.sh
# Prerequisitos: Android SDK, emulador corriendo, Flutter

set -e

PACKAGE="com.gabriom.playingtrackerapp"
OUTPUT_DIR="fastlane/screenshots"
DEVICE_LABEL="Pixel 7 Pro"

echo "🤖 Generando screenshots para Android..."

# Verificar emulador corriendo
DEVICE_ID=$(adb devices 2>/dev/null | grep "emulator" | awk '{print $1}' | head -1)

if [ -z "$DEVICE_ID" ]; then
  echo "❌ No hay emulador Android corriendo."
  echo "   Lista de emuladores disponibles: flutter emulators"
  echo "   Para arrancar uno: flutter emulators --launch <emulator_id>"
  exit 1
fi

echo "   Emulador detectado: $DEVICE_ID"

# Ejecutar integration test
echo "🧪 Ejecutando integration test de screenshots..."
flutter test integration_test/screenshots_test.dart -d "$DEVICE_ID"

echo "📂 Extrayendo screenshots del emulador..."
# path_provider/getApplicationDocumentsDirectory en Android devuelve:
# /data/user/0/<package>/app_flutter/
REMOTE_DIR="/data/user/0/$PACKAGE/app_flutter/screenshots"

# Verificar existencia
if ! adb -s "$DEVICE_ID" shell "[ -d $REMOTE_DIR ]" 2>/dev/null; then
  echo "❌ No se encontró el directorio de screenshots en el emulador."
  echo "   Ruta buscada: $REMOTE_DIR"
  exit 1
fi

SCREENSHOTS=$(adb -s "$DEVICE_ID" shell "ls $REMOTE_DIR" 2>/dev/null | tr -d '\r')

for FILENAME in $SCREENSHOTS; do
  if [[ "$FILENAME" == *_en.png ]]; then
    LOCALE="en-US"
  elif [[ "$FILENAME" == *_es.png ]]; then
    LOCALE="es-ES"
  else
    LOCALE="en-US"
  fi
  DEST_DIR="$OUTPUT_DIR/$LOCALE/$DEVICE_LABEL"
  mkdir -p "$DEST_DIR"
  adb -s "$DEVICE_ID" pull "$REMOTE_DIR/$FILENAME" "$DEST_DIR/$FILENAME" 2>/dev/null
  echo "   ✅ $FILENAME → $DEST_DIR/"
done

echo ""
echo "✅ Screenshots guardados en $OUTPUT_DIR:"
find "$OUTPUT_DIR" -name "*.png" | sort | sed 's/^/   /'
