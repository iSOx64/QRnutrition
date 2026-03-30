# QR Nutrition

Application mobile Flutter + Firebase pour scanner des produits alimentaires via QR code ou code‑barres, consulter l’historique et suivre la nutrition quotidienne. Le projet gère les rôles `user`, `admin` et `super_admin`.

## Stack
- Flutter
- Firebase Core / Auth / Firestore / Storage
- Firebase Messaging (prêt pour notifications)
- `mobile_scanner` (scan QR + code‑barres)
- `qr_flutter` (génération QR)
- `provider` + `go_router`

## Installation complète
Lis `INSTALLATION.md` pour une installation **de A à Z** (clone → Flutter → Firebase → règles → run) et la création de `.env`.

## FlutterFire (obligatoire pour Firebase)
La configuration Firebase se fait avec **FlutterFire CLI**, pas via `.env`.
Commande :
```
flutterfire configure
```
Elle génère :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- (si iOS) `ios/Runner/GoogleService-Info.plist`

## Configuration rapide
```
flutter pub get
flutter run
```

## Fichier `.env`
- Le fichier `.env` est **local** et ignoré par git.
- Copie l’exemple puis ajuste si besoin :

```
cp .env.example .env
```

## Collections Firestore
```
users/{uid}
products/{productId}
scans/{scanId}
users/{uid}/scan_history/{scanId}
admin_logs/{logId}
settings/app_config
```

## Gestion des rôles
Rôles possibles :
- `user`
- `admin`
- `super_admin`

Attribution :
- Tout compte créé via l’app : `role = user`
- `admin` et `super_admin` sont attribués manuellement.

### Tester les rôles
1. Créer un compte via l’app.
2. Aller dans Firestore `users/{uid}`.
3. Modifier le champ `role` (`admin` ou `super_admin`).

## QR / Code‑barres
### Lecture
Le module scanner utilise `mobile_scanner` et accepte :
- QR code
- Code‑barres

### Génération
Si un produit est créé sans `qrCodeValue`, une valeur unique est générée.
Dans la page d’édition produit (admin), un QR est affiché et peut être copié.

### Permissions caméra
Android `android/app/src/main/AndroidManifest.xml` :
```
<uses-permission android:name="android.permission.CAMERA" />
```

iOS `ios/Runner/Info.plist` :
```
<key>NSCameraUsageDescription</key>
<string>Camera required for scanning</string>
```

## Lancer l’application
```
flutter pub get
flutter run
```

## Seed / Demo data
Dans l’écran Admin, le menu "Seed demo" ajoute des produits de démo.
La logique est dans `lib/core/utils/seed_service.dart`.

## Tests
```
flutter test
```

## Notes
- Les règles Firestore limitent les actions selon le rôle.
- Les rôles ne sont pas modifiables via l’interface publique.
- Le système est prêt pour évoluer (notifications, storage, etc.).
