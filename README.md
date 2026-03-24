# QR Nutrition

Application mobile Flutter + Firebase pour scanner des produits alimentaires
via QR code ou code-barres, consulter l'historique et suivre la nutrition
quotidienne. Le projet gere les roles `user`, `admin` et `super_admin`.

## Stack
- Flutter
- Firebase Core / Auth / Firestore / Storage
- Firebase Messaging (pret pour notifications)
- `mobile_scanner` (scan QR + code-barres)
- `qr_flutter` (generation QR)
- `provider` + `go_router`

## Structure du projet
```
lib/
  app/
    app.dart
    router.dart

  core/
    constants/
    errors/
    theme/
    utils/
    widgets/

  features/
    auth/
    home/
    profile/
    products/
    scanner/
    history/
    dashboard/
    admin/
    settings/
    super_admin/

  firebase_options.dart
  main.dart
```

## Dependance a ajouter
Deja referencees dans `pubspec.yaml`:
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `firebase_storage`, `firebase_messaging`
- `google_sign_in`
- `mobile_scanner`, `qr_flutter`
- `uuid`, `intl`
- `provider`, `go_router`

## Configuration Firebase
1. Lancer la configuration Firebase:
   - `flutterfire configure`
2. Verifier les fichiers:
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
3. Mettre a jour les regles:
   - `firestore.rules`

Le fichier `firebase.json` reference les regles Firestore.

## Collections Firestore
```
users/{uid}
products/{productId}
scans/{scanId}
users/{uid}/scan_history/{scanId}
admin_logs/{logId}
settings/app_config
```

## Gestion des roles
Roles possibles:
- `user`
- `admin`
- `super_admin`

Attribution:
- Tout compte cree via l'app: `role = user`
- `admin` et `super_admin` sont attribues manuellement et de maniere securisee.

### Tester les roles
1. Creer un compte via l'app.
2. Aller dans Firestore `users/{uid}`.
3. Modifier le champ `role`:
   - `admin` ou `super_admin`.

## QR / Code-barres
### Lecture
Le module scanner utilise `mobile_scanner` et accepte:
- QR code
- Code-barres

### Generation
Si un produit est cree sans `qrCodeValue`, une valeur unique est generee.
Dans la page d'edition produit (admin), un QR est affiche et peut etre copie.

### Permissions
Android `android/app/src/main/AndroidManifest.xml`:
```
<uses-permission android:name="android.permission.CAMERA" />
```

iOS `ios/Runner/Info.plist`:
```
<key>NSCameraUsageDescription</key>
<string>Camera required for scanning</string>
```

## Lancer l'application
```
flutter pub get
flutter run
```

## Seed / Demo data
Dans l'ecran Admin, le menu "Seed demo" ajoute des produits de demo.
La logique est dans `lib/core/utils/seed_service.dart`.

## Tests
```
flutter test
```
Tests fournis:
- navigation par role
- creation produit (controller)
- flow scanner (controller)
- historique
- dashboard

## Notes
- Les regles Firestore limitent les actions selon le role.
- Les roles ne sont pas modifiables via l'interface publique.
- Le systeme est pret pour evoluer (notifications, storage, etc.).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
