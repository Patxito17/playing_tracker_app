fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Genera screenshots en el simulador iOS y los organiza para Fastlane

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Sube metadatos y screenshots a App Store Connect (sin binario)

### ios release_metadata

```sh
[bundle exec] fastlane ios release_metadata
```

Pipeline completo iOS: genera screenshots y sube a App Store Connect

----


## Android

### android screenshots

```sh
[bundle exec] fastlane android screenshots
```

Genera screenshots en el emulador Android y los organiza para Fastlane

### android upload_metadata

```sh
[bundle exec] fastlane android upload_metadata
```

Sube metadatos y screenshots a Google Play Console (sin AAB)

### android release_metadata

```sh
[bundle exec] fastlane android release_metadata
```

Pipeline completo Android: genera screenshots y sube a Google Play

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
