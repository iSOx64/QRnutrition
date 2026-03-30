# Installation (A → Z)

Ce guide explique comment **cloner**, **installer**, et **connecter** l’app à **ton propre Firebase** sans erreurs.

## Pré‑requis
- **Flutter SDK** (stable) + Dart (via Flutter)
- **Android Studio** (ou VS Code) + un émulateur / appareil Android
- Un compte **Google** (pour Firebase)
- (Optionnel) **Firebase CLI** pour déployer les règles Firestore
- **FlutterFire CLI** (recommandé)

## 1) Cloner le projet
```bash
git clone <TON_REPO_GITHUB>
cd first_app
```

## 2) Installer les dépendances Flutter
```bash
flutter pub get
```

## 3) Créer ton fichier `.env`
Le repo contient un exemple :
```bash
cp .env.example .env
```

> Le fichier `.env` est ignoré par git.  
> Note : Firebase ne se configure pas via `.env` dans Flutter — on utilise FlutterFire CLI.

## 4) Créer un projet Firebase
Dans la console Firebase :
- Crée un **nouveau projet**
- Active **Authentication** (Email/Password + Google si besoin)
- Active **Cloud Firestore**
- Active **Firebase Storage** (si tu utilises les images produit)

## 5) Connecter l’app à TON Firebase (FlutterFire CLI)

### 5.1 Installer FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```
Assure‑toi que `~/.pub-cache/bin` est dans ton PATH (Windows : ajoute‑le à `Path`).

### 5.2 Login Firebase
```bash
firebase login
```

### 5.3 Configurer FlutterFire (étape clé)
Depuis la racine du projet :
```bash
flutterfire configure
```

Ce que fait la commande :
- Associe ce projet Flutter à **ton** projet Firebase
- Génère la config Flutter

Fichiers générés / mis à jour :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- (si iOS) `ios/Runner/GoogleService-Info.plist`

Choisis ton projet Firebase puis sélectionne au minimum :
- **android**
- (optionnel) iOS / web / windows / macOS / linux

> Important : si tu veux iOS/web/desktop, relance `flutterfire configure` en incluant ces plateformes.

## 6) Déployer les règles Firestore (recommandé)
Ce repo contient :
- `firestore.rules`
- `firebase.json` (référence les règles)

Pour les appliquer à ton Firebase :
```bash
firebase deploy --only firestore:rules
```

## 7) Vérifier les permissions caméra
Android : `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

iOS : `ios/Runner/Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>Camera required for scanning</string>
```

## 8) Lancer l’application
```bash
flutter run
```

## 9) Première utilisation (rôles)
L’app gère les rôles :
- `user`
- `admin`
- `super_admin`

Par défaut, un compte créé via l’app reçoit `role = user`.

Pour tester les écrans admin :
- Va dans Firestore : `users/{uid}`
- Mets `role` à `admin` ou `super_admin`

## 10) Dépannage rapide
- **Erreur FirebaseOptions / UnsupportedError** : tu n’as pas configuré ta plateforme (iOS/Web/Desktop). Relance `flutterfire configure`.
- **Build Android échoue** : vérifie que `android/app/google-services.json` correspond à ton projet Firebase.
- **Auth Google ne marche pas** : ajoute SHA‑1/SHA‑256 dans Firebase (Android app settings) puis re‑télécharge `google-services.json`.
- **Firestore permission denied** : vérifie que les règles Firestore sont déployées et que ton user a le bon `role`.

## 11) Import OpenFoodFacts (optionnel, pour remplir `products`)
Si tu veux remplir la collection `products` automatiquement :

1. Crée un **Service Account** dans Firebase Console → Project Settings → Service Accounts.
2. Télécharge le JSON et place‑le localement (ne le commit pas).
3. Exécute l’import :

```bash
python tools/import_off_morocco.py --project <TON_PROJECT_ID> --service-account <CHEMIN_JSON> --dataset-type csv --country morocco
```
