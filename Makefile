# ==============================================================================
# Makefile — Playing Tracker
# ==============================================================================
# Uso básico:
#   make <comando>
#
# Comandos disponibles:
#   make help           → Muestra esta ayuda
#   make setup          → Instala dependencias y genera código
#   make clean          → Limpia artefactos de compilación
#   make analyze        → Analiza el código Dart
#   make test           → Ejecuta los tests
#   make apk            → Genera APK de release para Android (sin ofuscación)
#   make apk-prod       → Genera APK de release ofuscado (igual que CI/CD)
#   make aab            → Genera App Bundle para Google Play Store
#   make aab-prod       → Genera App Bundle ofuscado (igual que CI/CD)
#   make ipa            → Genera IPA de release para iOS (requiere Mac + Xcode)
#   make ipa-prod       → Genera IPA de release ofuscado (igual que CI/CD)
#   make build-all      → Genera APK + IPA en modo producción (requiere Mac)
# ==============================================================================

# Colores para la salida en terminal
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
BOLD   := \033[1m
RESET  := \033[0m

# Ruta al ExportOptions.plist que configura la firma y el método de exportación de iOS
IOS_EXPORT_OPTIONS := ios/ExportOptions.plist

# Directorio donde se guardan los símbolos de debug (para Crashlytics)
SYMBOLS_DIR_ANDROID := build/symbols/android
SYMBOLS_DIR_IOS     := build/symbols/ios

# ==============================================================================
# Ayuda
# ==============================================================================

.PHONY: help
help:
	@echo ""
	@echo "$(BOLD)$(BLUE)╔══════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(BLUE)║          Playing Tracker — Comandos de Build          ║$(RESET)"
	@echo "$(BOLD)$(BLUE)╚══════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BOLD)── Entorno ─────────────────────────────────────────────$(RESET)"
	@echo "  $(GREEN)make setup$(RESET)       Instala dependencias (pub get) y genera código"
	@echo "  $(GREEN)make clean$(RESET)       Limpia artefactos de compilación (flutter clean)"
	@echo "  $(GREEN)make analyze$(RESET)     Analiza el código Dart en busca de errores/warnings"
	@echo "  $(GREEN)make test$(RESET)        Ejecuta todos los tests unitarios y de widget"
	@echo ""
	@echo "$(BOLD)── Android ──────────────────────────────────────────────$(RESET)"
	@echo "  $(GREEN)make apk$(RESET)         APK de release. Útil para instalar en un dispositivo."
	@echo "                   Ruta: build/app/outputs/flutter-apk/app-release.apk"
	@echo ""
	@echo "  $(GREEN)make apk-prod$(RESET)    APK ofuscado (igual que en producción/CI)."
	@echo "                   Incluye símbolos de debug en: $(SYMBOLS_DIR_ANDROID)/"
	@echo "                   ⚠️  Requiere keystore configurado en android/key.properties"
	@echo ""
	@echo "  $(GREEN)make aab$(RESET)         App Bundle para subir a Google Play Store."
	@echo "                   Ruta: build/app/outputs/bundle/release/app-release.aab"
	@echo ""
	@echo "  $(GREEN)make aab-prod$(RESET)    App Bundle ofuscado (igual que en producción/CI)."
	@echo "                   ⚠️  Requiere keystore configurado en android/key.properties"
	@echo ""
	@echo "$(BOLD)── iOS (requiere Mac con Xcode instalado) ───────────────$(RESET)"
	@echo "  $(GREEN)make ipa$(RESET)         IPA de release. Útil para instalar en un dispositivo."
	@echo "                   Ruta: build/ios/ipa/*.ipa"
	@echo "                   ⚠️  Requiere certificado y provisioning profile en Xcode"
	@echo ""
	@echo "  $(GREEN)make ipa-prod$(RESET)    IPA ofuscado (igual que en producción/CI)."
	@echo "                   Incluye símbolos de debug en: $(SYMBOLS_DIR_IOS)/"
	@echo "                   ⚠️  Requiere certificado y provisioning profile en Xcode"
	@echo ""
	@echo "$(BOLD)── Todo en uno ──────────────────────────────────────────$(RESET)"
	@echo "  $(GREEN)make build-all$(RESET)   Genera APK + IPA en modo producción (solo en Mac)"
	@echo ""


# ==============================================================================
# Entorno y preparación
# ==============================================================================

## Instala dependencias y genera el código necesario (Freezed, etc.)
.PHONY: setup
setup:
	@echo "$(BLUE)▶ Instalando dependencias...$(RESET)"
	flutter pub get
	@echo "$(BLUE)▶ Generando código (build_runner)...$(RESET)"
	dart run build_runner build --delete-conflicting-outputs
	@echo "$(BLUE)▶ Generando traducciones (l10n)...$(RESET)"
	flutter gen-l10n
	@echo "$(GREEN)✅ Setup completado.$(RESET)"

## Limpia artefactos de compilación de Flutter
.PHONY: clean
clean:
	@echo "$(YELLOW)🧹 Limpiando proyecto...$(RESET)"
	flutter clean
	@echo "$(GREEN)✅ Proyecto limpiado.$(RESET)"

## Analiza el código Dart
.PHONY: analyze
analyze:
	@echo "$(BLUE)🔍 Analizando código...$(RESET)"
	flutter analyze --no-fatal-infos

## Ejecuta todos los tests
.PHONY: test
test:
	@echo "$(BLUE)🧪 Ejecutando tests...$(RESET)"
	flutter test


# ==============================================================================
# Android — APK
# ==============================================================================

## APK de release básico (sin ofuscación). Ideal para pruebas rápidas en dispositivo.
## El archivo resultante se encuentra en:
##   build/app/outputs/flutter-apk/app-release.apk
## Para instalarlo: adb install build/app/outputs/flutter-apk/app-release.apk
.PHONY: apk
apk:
	@echo "$(BLUE)🤖 Generando APK de release...$(RESET)"
	flutter build apk --release
	@echo "$(GREEN)✅ APK generado en: build/app/outputs/flutter-apk/app-release.apk$(RESET)"

## APK de release OFUSCADO (idéntico al generado por el pipeline CI/CD de producción).
## Requiere que android/key.properties exista con:
##   storePassword=...
##   keyPassword=...
##   keyAlias=...
##   storeFile=release.jks
## Los símbolos de debug (para Crashlytics) se guardan en $(SYMBOLS_DIR_ANDROID)/
.PHONY: apk-prod
apk-prod:
	@echo "$(BLUE)🤖 Generando APK de producción (ofuscado)...$(RESET)"
	flutter build apk \
		--release \
		--obfuscate \
		--split-debug-info=$(SYMBOLS_DIR_ANDROID)
	@echo "$(GREEN)✅ APK generado en: build/app/outputs/flutter-apk/app-release.apk$(RESET)"
	@echo "$(YELLOW)📦 Símbolos de debug en: $(SYMBOLS_DIR_ANDROID)/$(RESET)"


# ==============================================================================
# Android — App Bundle (AAB)
# ==============================================================================

## App Bundle de release básico. Formato requerido para Google Play Store.
## El archivo resultante se encuentra en:
##   build/app/outputs/bundle/release/app-release.aab
.PHONY: aab
aab:
	@echo "$(BLUE)🤖 Generando App Bundle de release...$(RESET)"
	flutter build appbundle --release
	@echo "$(GREEN)✅ AAB generado en: build/app/outputs/bundle/release/app-release.aab$(RESET)"

## App Bundle OFUSCADO (idéntico al generado por el pipeline CI/CD de producción).
.PHONY: aab-prod
aab-prod:
	@echo "$(BLUE)🤖 Generando App Bundle de producción (ofuscado)...$(RESET)"
	flutter build appbundle \
		--release \
		--obfuscate \
		--split-debug-info=$(SYMBOLS_DIR_ANDROID)
	@echo "$(GREEN)✅ AAB generado en: build/app/outputs/bundle/release/app-release.aab$(RESET)"
	@echo "$(YELLOW)📦 Símbolos de debug en: $(SYMBOLS_DIR_ANDROID)/$(RESET)"


# ==============================================================================
# iOS — IPA
# ==============================================================================
# PREREQUISITOS:
#   1. Tener Xcode instalado y configurado en la Mac.
#   2. Tener instalado en la Keychain el certificado de distribución de Apple (.p12).
#   3. Tener el Provisioning Profile descargado y reconocido por Xcode.
#   4. El archivo ios/ExportOptions.plist debe existir y estar configurado con el
#      método de exportación (development, ad-hoc, app-store, enterprise).
#
# El archivo IPA resultante se encuentra en:
#   build/ios/ipa/<nombre_app>.ipa

## IPA de release básico. Útil para instalar en dispositivos de prueba.
## Usa la firma y configuración definida en ios/ExportOptions.plist.
.PHONY: ipa
ipa:
	@echo "$(BLUE)🍏 Generando IPA de release...$(RESET)"
	flutter build ipa \
		--release \
		--export-options-plist=$(IOS_EXPORT_OPTIONS)
	@echo "$(GREEN)✅ IPA generado en: build/ios/ipa/$(RESET)"

## IPA de release OFUSCADO (idéntico al generado por el pipeline CI/CD de producción).
## Los símbolos de debug (para Crashlytics) se guardan en $(SYMBOLS_DIR_IOS)/
.PHONY: ipa-prod
ipa-prod:
	@echo "$(BLUE)🍏 Generando IPA de producción (ofuscado)...$(RESET)"
	flutter build ipa \
		--release \
		--obfuscate \
		--split-debug-info=$(SYMBOLS_DIR_IOS) \
		--export-options-plist=$(IOS_EXPORT_OPTIONS)
	@echo "$(GREEN)✅ IPA generado en: build/ios/ipa/$(RESET)"
	@echo "$(YELLOW)📦 Símbolos de debug en: $(SYMBOLS_DIR_IOS)/$(RESET)"


# ==============================================================================
# Build completo (APK + IPA) — Solo en Mac
# ==============================================================================

## Genera APK + IPA en modo producción. Equivale a ejecutar el pipeline CI/CD localmente.
## Solo funciona en macOS (el build de iOS requiere Xcode).
.PHONY: build-all
build-all: apk-prod ipa-prod
	@echo ""
	@echo "$(BOLD)$(GREEN)🎉 Build completo finalizado.$(RESET)"
	@echo "   APK → build/app/outputs/flutter-apk/app-release.apk"
	@echo "   IPA → build/ios/ipa/"
	@echo ""
