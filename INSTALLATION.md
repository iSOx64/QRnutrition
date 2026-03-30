# Installation (A → Z)

Ce guide explique comment **cloner**, **installer**, et **connecter** l’app à **ton propre Firebase** sans erreurs, puis la lancer sur un appareil/emulateur Android.

---

## 0) Pré‑requis

- **Flutter SDK** (stable) + Dart (via Flutter)
- **Android Studio** (ou VS Code) + un émulateur / appareil Android
- Un compte **Google** (pour Firebase)
- **Firebase CLI** (optionnel mais pratique pour déployer les règles)
- **FlutterFire CLI** (obligatoire pour configurer Firebase dans Flutter)

---

## 1) Cloner le projet

```bash
git clone <TON_REPO_GITHUB>
cd first_app
```

---

## 2) Installer les dépendances Flutter

```bash
flutter pub get
```

---

## 3) Créer ton fichier `.env`

Le repo contient un exemple :

```bash
cp .env.example .env
```

- Le fichier `.env` est **local** et ignoré par git.
- Aujourd’hui il sert, par exemple, à surcharger les URLs OpenFoodFacts (si besoin) et à activer un flag `APP_DEBUG`.
- **Important :** la configuration Firebase ne se fait **pas** via `.env` mais via **FlutterFire CLI**.

---

## 4) Créer un projet Firebase

Dans la **console Firebase** :

1. Crée un **nouveau projet**
2. Active **Authentication**
   - Au minimum: **Email/Password**
   - Optionnel: **Google** (pour le `signInWithGoogle`)
3. Active **Cloud Firestore**
4. Active **Firebase Storage** (utilisé pour les images produit)

Tu peux ignorer Realtime Database si tu ne l’utilises pas.

---

## 5) Installer et configurer FlutterFire CLI (connexion à ton Firebase)

### 5.1 Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Assure‑toi que `~/.pub-cache/bin` est dans ton `PATH`  
(Windows : ajoute ce dossier à ta variable d’environnement `Path`).

### 5.2 Se connecter à Firebase (CLI)

```bash
firebase login
```

Un navigateur s’ouvrira pour valider ton compte Google.

### 5.3 Lier le projet Flutter à TON projet Firebase

Depuis la racine du projet:

```bash
flutterfire configure
```

Étapes :
1. Sélectionne ton compte Google.
2. Choisis ton **projet Firebase**.
3. Choisis les plateformes à configurer:
   - au minimum: **android**
   - optionnel: ios / web / windows / macOS / linux

La commande:
- associe ce projet Flutter à **ton** projet Firebase,
- génère / met à jour:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - (si iOS) `ios/Runner/GoogleService-Info.plist`

> Si tu ajoutes plus tard d’autres plateformes (iOS/Web/Desktop), relance `flutterfire configure` en incluant les nouvelles cibles.

---

## 6) (Optionnel) Auth Google : SHA‑1 / SHA‑256 Android

Si tu veux utiliser la connexion **Google** sur Android:

1. Récupère tes empreintes SHA‑1 / SHA‑256, par exemple avec Android Studio ou:

```bash
./gradlew signingReport        # dans android/
```

2. Dans Firebase Console → Project Settings → **Your apps** → Android:
   - Ajoute les empreintes SHA‑1 et SHA‑256 à ton application Android.
3. Re‑télécharge `google-services.json` et remplace celui dans `android/app/`.

Sans cette étape, le `signInWithGoogle` peut échouer en prod / sur certains devices.

---

## 7) Déployer les règles Firestore (recommandé)

Ce repo contient:
- `firestore.rules`
- `firebase.json` (référence les règles)

Pour les appliquer à ton projet Firebase (nécessite Firebase CLI):

```bash
firebase deploy --only firestore:rules
```

Cela applique la logique de sécurité (rôles, restrictions par user, etc.) présente dans `firestore.rules`.

---

## 8) Vérifier les permissions caméra

Pour que le scan fonctionne :

### Android

Dans `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS

Dans `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera required for scanning</string>
```

---

## 9) Lancer l’application

Une fois les étapes précédentes faites:

```bash
flutter pub get
flutter run
```

L’app utilise:
- `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` dans `lib/main.dart`,
- la config générée par FlutterFire (`firebase_options.dart` + `google-services.json`).

---

## 9.1) Branding (nom + icône)

Le projet est configuré avec:
- **Nom app**: `QRnutrition`
  - Android: `android/app/src/main/AndroidManifest.xml`
  - iOS: `ios/Runner/Info.plist`
- **Icône app**: générée depuis `icon.png` avec `flutter_launcher_icons`.

Si tu veux régénérer les icônes:

```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## 10) Première utilisation (rôles)

L’app gère les rôles:
- `user`
- `admin`
- `super_admin`

Par défaut, un compte créé via l’app reçoit `role = user`.

Pour tester les écrans admin / super‑admin:

1. Crée un compte via l’app.
2. Dans Firestore Console: ouvre `users/{uid}`.
3. Modifie le champ `role` en:
   - `admin` ou
   - `super_admin`.

Les règles Firestore limiteront automatiquement les actions selon ce rôle.

---

## 10.1) Utilisation: ajouter / supprimer un repas

Dans l’app, un **repas** correspond à un **scan enregistré** (historique + dashboard).

- **Ajouter un repas**
  - Ouvre une fiche produit puis clique **“J’ai mangé ce produit”**, ou
  - Va dans **Dashboard (Jour)** puis clique **Ajouter** pour créer un repas perso (nom + macros + date/heure).
  - Firestore écrit:
    - `scans/{scanId}`
    - `users/{uid}/scan_history/{scanId}`

- **Modifier un repas**
  - Dans **Dashboard (Jour)**, le bouton **Modifier** est disponible pour les repas manuels (`sourceType = manual`).
  - Firestore met à jour:
    - `users/{uid}/scan_history/{scanId}`

- **Supprimer un repas**
  - Va dans **Dashboard (Jour)** ou **Historique** et supprime l’élément.
  - Firestore supprime:
    - `users/{uid}/scan_history/{scanId}`

## 11) Import OpenFoodFacts (optionnel, pour remplir `products`)

Depuis l’arrivée de la connexion directe à OpenFoodFacts, la collection `products` Firestore est **optionnelle**.  
Tu peux toutefois la remplir avec des données de démo ou un dataset réel.

Le dossier `tools/` contient des scripts (par exemple pour importer un dataset Maroc) :

```bash
python tools/import_off_morocco.py \
  --project <TON_PROJECT_ID> \
  --service-account <CHEMIN_VERS_SERVICE_ACCOUNT_JSON> \
  --dataset-type csv \
  --country morocco
```

> Attention: le JSON de service account doit rester **local** et ne jamais être commité
> (le `.gitignore` du projet ignore déjà les fichiers `*firebase-adminsdk*.json`).

---

## 12) Dépannage rapide

- **Erreur `FirebaseOptions` / `UnsupportedError`**  
  → Tu n’as pas configuré la plateforme courante (ex: iOS/Web/Desktop).  
  → Relance `flutterfire configure` en incluant la plateforme.

- **Build Android échoue**  
  → Vérifie que `android/app/google-services.json` correspond bien à ton projet Firebase actuel.

- **Auth Google ne marche pas**  
  → Assure‑toi d’avoir ajouté **SHA‑1** et **SHA‑256** dans les settings Android de Firebase,  
    puis re‑télécharge et remplace `google-services.json`.

- **`permission-denied` dans Firestore**  
  → Vérifie:
    - que les règles Firestore (`firestore.rules`) sont bien déployées,
    - que ton user a le bon `role` dans `users/{uid}`.
