# 🆓 iOS Testing Gratuit pour PlutoVets

## 🟢 Option 1: GitHub Actions (Recommandé)

### Étapes:
1. **Créer repository GitHub**:
   - Allez sur https://github.com/new
   - Nom: `plutovets-main`
   - Public (gratuit)

2. **Pousser le code**:
   ```bash
   git remote add origin https://github.com/VOTRE_USERNAME/plutovets-main.git
   git push -u origin main
   ```

3. **Activer GitHub Pages**:
   - Allez dans Settings > Pages
   - Source: "Deploy from a branch"
   - Branch: `gh-pages` et `/ (root)`

4. **Résultat**:
   - Web app: `https://VOTRE_USERNAME.github.io/plutovets-main/`
   - Test sur iPhone: Ouvrir cette URL dans Safari

## 🌐 Option 2: Netlify (Alternative)

1. **Allez sur https://netlify.com**
2. **Sign up** (gratuit)
3. **Drag & drop** le dossier `plutovets_mobile/build/web`
4. **Obtenez une URL** comme: `https://plutovets.netlify.app`

## 📱 Option 3: Test Local (Si vous avez un Mac)

1. **Copiez le projet** sur un Mac
2. **Exécutez**:
   ```bash
   cd plutovets_mobile
   flutter run -d ios
   ```
3. **Connectez votre iPhone** via USB
4. **Testez directement** depuis Xcode

## 🎯 Meilleure Option Gratuite

**GitHub Pages** est la meilleure option car:
- ✅ 100% gratuit
- ✅ Déploiement automatique
- ✅ URL permanente
- ✅ Test sur Safari mobile
- ✅ Mises à jour automatiques

## 🔧 Test sur iPhone

1. **Ouvrez Safari** sur votre iPhone
2. **Allez à l'URL**: `https://VOTRE_USERNAME.github.io/plutovets-main/`
3. **Ajoutez à l'écran d'accueil**:
   - Tap sur "Partager"
   - "Sur l'écran d'accueil"
   - "Ajouter"

## 📊 Fonctionnalités Testées

- ✅ Authentification
- ✅ Dashboard
- ✅ Gestion des animaux
- ✅ Réservations
- ✅ Profil
- ✅ Navigation
- ✅ Design responsive

## 🚀 Déploiement Automatique

Chaque `git push` déclenche:
1. Build Flutter web
2. Déploiement sur GitHub Pages
3. Disponible immédiatement sur iPhone
