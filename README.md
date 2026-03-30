# QR Nutrition

Application mobile **Flutter + Firebase** pour scanner des produits alimentaires (code‑barres), récupérer les informations **OpenFoodFacts** (image, tableau nutritionnel, Nutri‑Score, NOVA, Éco‑score…), suivre l’historique de consommation et disposer d’outils **admin / super admin**.

L’application gère plusieurs rôles (`user`, `admin`, `super_admin`) et stocke les scans dans Firestore pour alimenter un dashboard nutritionnel.

---

## Fonctionnalités principales

- **Scan produit**
  - Scan code‑barres (caméra ou image) via `mobile_scanner` + `flutter_zxing`.
  - Récupération automatique du produit:
    - d’abord dans **Firestore** (`products`),
    - sinon via **OpenFoodFacts** (API REST).
  - Affichage immédiat:
    - image produit,
    - tableau nutritionnel (kcal, protéines, glucides, lipides + nutriments détaillés),
    - Nutri‑Score, NOVA, Éco‑score, quantité, pays, labels, emballage.

- **Détails produit**
  - Fiche complète avec:
    - image,
    - infos nutritionnelles structurées,
    - ingrédients, allergènes,
    - Nutri‑Score, NOVA, Éco‑score,
    - métadonnées (quantité, pays, labels, emballage),
    - bouton **“J’ai mangé ce produit”** (ajouter un repas) qui enregistre un scan dans l’historique (et le dashboard).

- **Historique & dashboard**
  - Historique personnel des scans: `users/{uid}/scan_history/{scanId}`.
  - Résumés journaliers / hebdomadaires (calories, macros…) à partir de l’historique.
  - Dans l’écran **Dashboard (Jour)**, l’utilisateur peut gérer ses repas du jour: **ajouter / modifier (repas manuels) / supprimer**.
  - Dans l’écran **Historique**, l’utilisateur peut consulter et **supprimer** un repas.

- **Gestion des rôles**
  - `user`: usage normal de l’app (scan, historique, dashboard).
  - `admin`: gestion du catalogue produits Firestore, logs, stats administrateur.
  - `super_admin`: gestion globale des admins, paramètres globaux, logs système.

- **Recherche produits**
  - Recherche par **nom** et **code‑barres**:
    - Firestore (produits actifs),
    - puis fallback OpenFoodFacts (nom / code).

---

## Stack technique

- **Mobile**
  - Flutter (Material 3)
  - Routing: `go_router`
  - State management: `provider`

- **Backend / BaaS**
  - Firebase:
    - `firebase_core`
    - `firebase_auth`
    - `cloud_firestore`
    - `firebase_storage`
    - (prêt pour) `firebase_messaging`

- **Scan & QR**
  - `mobile_scanner`
  - `flutter_zxing`
  - `qr_flutter`

- **Divers**
  - `google_sign_in`
  - `uuid`, `intl`, `path_provider`, `share_plus`, `google_fonts`
  - `http` pour l’appel OpenFoodFacts

---

## Architecture du projet

```text
lib/
  app/
    app.dart           # MultiProvider, thème, MaterialApp.router
    router.dart        # Définition des routes (GoRouter)

  core/
    constants/         # Constantes globales
    errors/            # Types d’erreurs (AppFailure, AuthFailure, ...)
    theme/             # Thème Material 3
    utils/             # Helpers (QR, seed data, etc.)
    widgets/           # Widgets réutilisables (InfoCard, etc.)

  features/
    auth/              # Authentification + user Firebase
    home/              # Accueil utilisateur
    profile/           # Profil / paramètres utilisateur
    products/          # Modèle produit, CRUD, recherche, fiches
    scanner/           # Scan code-barres + logique de liaison produit
    history/           # Historique des scans
    dashboard/         # Résumés nutritionnels
    admin/             # Interfaces admin (produits, logs, stats)
    settings/          # Paramètres globaux (super admin)
    super_admin/       # Gestion des admins, logs système
    openfoodfacts/     # Service d’accès API OpenFoodFacts

  firebase_options.dart # Config Firebase générée par FlutterFire CLI
  main.dart             # Entrée de l’app, Firebase.initializeApp
```

---

## Modèle de données Firebase (principal)

**Collections Firestore :**

```text
users/{uid}
  scan_history/{scanId}

products/{productId}

scans/{scanId}

admin_logs/{logId}

settings/app_config
```

- `users` : profil applicatif, rôle (`user`/`admin`/`super_admin`), préférences.
- `scan_history` : historique personnel attaché à chaque user.
- `products` : catalogue produit Firestore (optionnel depuis OpenFoodFacts, mais toujours supporté).
- `scans` : stockage global des scans (pour stats admin).
- `admin_logs`, `settings` : utilisé par les écrans admin / super‑admin.

Les règles de sécurité sont définies dans `firestore.rules` et déployées via `firebase.json`.

---

## Repas (CRUD)

Dans l’app, un “repas” correspond à un **scan enregistré**.

- **Ajouter un repas**
  - Depuis la fiche produit (`ProductDetailsPage`), bouton **“J’ai mangé ce produit”**.
  - Depuis le **Dashboard (Jour)**, bouton **Ajouter** pour créer un repas perso (nom + macros + date/heure).
  - Écrit dans Firestore:
    - `scans/{scanId}` (global)
    - `users/{uid}/scan_history/{scanId}` (historique personnel)

- **Modifier un repas**
  - Depuis le **Dashboard (Jour)**, bouton **Modifier** disponible pour les repas `manual`.
  - Met à jour l’entrée de l’historique user:
    - `users/{uid}/scan_history/{scanId}`

- **Supprimer un repas**
  - Depuis le **Dashboard (Jour)** ou l’écran **Historique**.
  - Supprime par défaut:
    - `users/{uid}/scan_history/{scanId}`
  - (Optionnel côté code) possibilité de supprimer aussi `scans/{scanId}` si activé pour l’admin.

---

## Rôles & sécurité

- **Rôles possibles :**
  - `user`
  - `admin`
  - `super_admin`

- **Attribution :**
  - Tout compte créé via l’app : `role = user`.
  - Les rôles `admin` / `super_admin` sont mis à jour manuellement dans Firestore (interface sécurisée ou via la console).

- **Pages par rôle :**
  - `user` : `UserHome`, `Scanner`, `Recherche`, `Fiche produit`, `Historique`, `Dashboard`, `Profil`.
  - `admin` : pages `user` + `AdminHome`, `AdminProducts` (liste/ajout/modification), `AdminStatistics`, `AdminLogs`.
  - `super_admin` : pages `admin` + `SuperAdminHome`, `ManageAdmins`, `GlobalSettings`, `SystemLogs`.

- **Règles Firestore :**
  - Fichier : `firestore.rules`
  - Logique principale :
    - `users/{uid}` : lisible par le propriétaire + admins, modifiable par le propriétaire (sans changer le rôle).
    - `products` : lecture pour tout utilisateur connecté, écriture réservée aux admins.
    - `scans` / `scan_history` : écritures contrôlées pour garantir que chaque user ne gère que ses propres scans.

---

## Connexion à Firebase

L’app est reliée à Firebase dans `main.dart` :

```text
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

- `DefaultFirebaseOptions` vient de `lib/firebase_options.dart`, généré par **FlutterFire CLI**.
- Android utilise aussi `android/app/google-services.json`.

**Configuration rapide :**

```bash
flutter pub get
flutterfire configure   # choisir TON projet Firebase
flutter run
```

Pour un guide complet (création du projet Firebase, SHA‑1, Google Sign‑In, déploiement des règles, etc.), voir `INSTALLATION.md`.

---

## Fichier `.env`

- Le fichier `.env` est **local** et ignoré par git.
- Le repo fournit un modèle : `.env.example`.
- Crée ton `.env` avec :

```bash
cp .env.example .env
```

Par défaut, il contient les URLs OpenFoodFacts et un flag `APP_DEBUG`.

---

## Branding (nom + icône)

- Nom affiché de l’app: **`QRnutrition`**
  - Android: `android/app/src/main/AndroidManifest.xml` (`android:label`)
  - iOS: `ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`)
- Icône de l’app: générée depuis `icon.png` avec `flutter_launcher_icons`.
  - Configuration dans `pubspec.yaml`.

---

## Permissions caméra

- Android `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

- iOS `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Camera required for scanning</string>
```

---

## Lancer l’application

```bash
flutter pub get
flutter run
```


