# gopher_eye

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Development

### Setup Firebase
This project requires Firebase SDK. When configured this Firebase produces
artifacts with sensitive information like API keys. To avoid this, developers will
need to configure their own Firebase project.

1. Install [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
2. Log into Firebase
```bash
firebase login
```
3. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```
4. Configure App to use Firebase, and choose the GopherEye project
```bash
flutterfire configure
```
