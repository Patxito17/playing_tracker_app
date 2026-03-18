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

# Obtener UDID antes de lanzar el test
DEVICE_UDID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep "Booted" | grep -Eo '[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}' | head -1)
SIM_DATA="$HOME/Library/Developer/CoreSimulator/Devices/$DEVICE_UDID/data"

# Limpiar screenshots previos del simulador para no confundirnos
find "$SIM_DATA/Containers/Data/Application" -path "*/Documents/screenshots/*.png" -delete 2>/dev/null || true

# Ejecutar integration test en segundo plano
# flutter test desinstala la app al terminar y borra el contenedor de datos.
# Por eso copiamos los PNGs mientras el test todavía está corriendo.
echo "🧪 Ejecutando integration test de screenshots (en segundo plano)..."
flutter test integration_test/screenshots_test.dart -d "$DEVICE_NAME" &
TEST_PID=$!

echo "📂 Esperando screenshots del simulador..."
TIMEOUT=180
ELAPSED=0
EXPECTED=8

while [ $ELAPSED -lt $TIMEOUT ]; do
  COUNT=$(find "$SIM_DATA/Containers/Data/Application" -path "*/Documents/screenshots/*.png" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -ge "$EXPECTED" ]; then
    echo "   ✅ $COUNT screenshots encontrados"
    break
  fi
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

SCREENSHOTS_FOUND=$(find "$SIM_DATA/Containers/Data/Application" -path "*/Documents/screenshots/*.png" 2>/dev/null)

if [ -z "$SCREENSHOTS_FOUND" ]; then
  echo "❌ No se encontraron screenshots en el simulador (timeout ${TIMEOUT}s)."
  echo "   Buscado en: $SIM_DATA/Containers/Data/Application/*/Documents/screenshots/"
  kill $TEST_PID 2>/dev/null || true
  exit 1
fi

# Organizar por locale para Fastlane: fastlane/screenshots/<locale>/<device>/
for FILE in $SCREENSHOTS_FOUND; do
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

# Esperar a que el test termine antes de salir
wait $TEST_PID
TEST_EXIT=$?
if [ $TEST_EXIT -ne 0 ]; then
  echo "⚠️  El test terminó con código $TEST_EXIT, pero los screenshots ya fueron copiados."
fi

echo ""
echo "✅ Screenshots guardados en $OUTPUT_DIR:"
find "$OUTPUT_DIR" -name "*.png" | sort | sed 's/^/   /'
