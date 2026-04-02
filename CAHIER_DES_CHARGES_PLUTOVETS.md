# CAHIER DES CHARGES - PLUTOVETS

## 📋 TABLE DES MATIÈRES

1. [Présentation du Projet](#présentation-du-projet)
2. [Objectifs Généraux](#objectifs-généraux)
3. [Spécifications Fonctionnelles](#spécifications-fonctionnelles)
4. [Spécifications Techniques](#spécifications-techniques)
5. [Architecture du Système](#architecture-du-système)
6. [Base de Données](#base-de-données)
7. [Interface Utilisateur](#interface-utilisateur)
8. [Sécurité](#sécurité)
9. [Performance et Scalabilité](#performance-et-scalabilité)
10. [Déploiement et Maintenance](#déploiement-et-maintenance)
11. [Livraison et Acceptation](#livraison-et-acceptation)

---

## 🐾 PRÉSENTATION DU PROJET

### Contexte
PlutoVets est une application mobile moderne de gestion vétérinaire qui connecte les propriétaires d'animaux avec les services vétérinaires. L'application permet aux utilisateurs de gérer le profil de leurs animaux, de prendre des rendez-vous, et d'accéder à des services vétérinaires variés.

### Public Cible
- **Propriétaires d'animaux** (chiens, chats, NAC)
- **Cliniques vétérinaires** partenaires
- **Vétérinaires** indépendants

### Périmètre du Projet
L'application couvre la gestion complète du cycle de vie des animaux domestiques, de l'enregistrement à la prise en charge médicale.

---

## 🎯 OBJECTIFS GÉNÉRAUX

### Objectifs Principaux
1. **Simplifier la gestion vétérinaire** pour les propriétaires d'animaux
2. **Faciliter l'accès aux soins** vétérinaires
3. **Centraliser les informations médicales** des animaux
4. **Automatiser la prise de rendez-vous**
5. **Améliorer la communication** entre propriétaires et vétérinaires

### Objectifs Secondaires
- Réduire le délai d'attente pour les consultations
- Améliorer le suivi médical des animaux
- Digitaliser les carnets de santé
- Offrir une expérience utilisateur intuitive

---

## 📱 SPÉCIFICATIONS FONCTIONNELLES

### Module 1: Gestion des Utilisateurs (AUTH-01 à AUTH-04)

#### AUTH-01: Inscription
- **Description**: Création de compte utilisateur avec informations personnelles
- **Fonctionnalités**:
  - Formulaire d'inscription (email, mot de passe, nom, prénom, téléphone)
  - Validation email en temps réel
  - Création automatique du premier animal
  - Acceptation des CGU
- **Règles Métier**:
  - Email unique obligatoire
  - Mot de passe: 8 caractères minimum, 1 majuscule, 1 chiffre
  - Vérification email obligatoire

#### AUTH-02: Connexion
- **Description**: Accès sécurisé au compte utilisateur
- **Fonctionnalités**:
  - Formulaire de connexion (email, mot de passe)
  - Option "Se souvenir de moi"
  - Mot de passe oublié
  - Double authentification optionnelle
- **Règles Métier**:
  - Tentatives limitées (5 max)
  - Session JWT de 24h
  - Token de rafraîchissement

#### AUTH-03: Profil Utilisateur
- **Description**: Gestion des informations personnelles
- **Fonctionnalités**:
  - Affichage des informations personnelles
  - Modification des données (nom, prénom, téléphone)
  - Changement de mot de passe
  - Suppression de compte
- **Règles Métier**:
  - Email non modifiable après inscription
  - Historique des modifications sauvegardé

#### AUTH-04: Déconnexion
- **Description**: Fermeture sécurisée de session
- **Fonctionnalités**:
  - Déconnexion immédiate
  - Nettoyage des tokens locaux
  - Confirmation de déconnexion
- **Règles Métier**:
  - Invalidation du token côté serveur
  - Nettoyage complet des données locales

### Module 2: Gestion des Animaux (PET-01 à PET-05)

#### PET-01: Enregistrement d'Animal
- **Description**: Ajout d'un nouvel animal au profil
- **Fonctionnalités**:
  - Formulaire d'enregistrement (nom, espèce, race, âge, poids)
  - Photo de profil optionnelle
  - Informations médicales de base
  - Numéro d'identification (puce, tatouage)
- **Règles Métier**:
  - Maximum 10 animaux par utilisateur
  - Photo obligatoire pour identification
  - Poids obligatoire pour dosage médicaments

#### PET-02: Fiche Animal
- **Description**: Affichage détaillé des informations d'un animal
- **Fonctionnalités**:
  - Informations générales (nom, espèce, race, âge)
  - Historique médical complet
  - Liste des vaccinations
  - Documents médicaux (scans, ordonnances)
  - Statut actuel (sain, traitement, surveillance)
- **Règles Métier**:
  - Accès uniquement au propriétaire
  - Historique chronologique inversé
  - Documents classés par type

#### PET-03: Modification d'Animal
- **Description**: Mise à jour des informations d'un animal
- **Fonctionnalités**:
  - Modification des informations générales
  - Ajout/suppression de photos
  - Mise à jour poids et âge
  - Ajout notes spéciales
- **Règles Métier**:
  - Historique des modifications conservé
  - Validation des poids (min/max par espèce)
  - Photos maximum 5 par animal

#### PET-04: Suppression d'Animal
- **Description**: Retrait d'un animal du profil
- **Fonctionnalités**:
  - Suppression logique (archivage)
  - Confirmation avec mot de passe
  - Export des données avant suppression
  - Raison de suppression optionnelle
- **Règles Métier**:
  - Conservation des données médicales 5 ans
  - Suppression irréversible après 30 jours
  - Notification aux cliniques partenaires

#### PET-05: Liste des Animaux
- **Description**: Vue d'ensemble de tous les animaux
- **Fonctionnalités**:
  - Grille/Galerie d'animaux
  - Filtres par espèce, statut
  - Recherche par nom
  - Tri par nom, âge, dernière visite
- **Règles Métier**:
  - Affichage limité à 20 par page
  - Cache local pour accès rapide
  - Synchronisation automatique

### Module 3: Réservations (BOOK-01 à BOOK-06)

#### BOOK-01: Prise de Rendez-vous
- **Description**: Création d'une nouvelle réservation
- **Fonctionnalités**:
  - Sélection de l'animal concerné
  - Choix du service vétérinaire
  - Sélection date/heure disponibles
  - Lieu (clinique/domicile)
  - Notes pour le vétérinaire
- **Règles Métier**:
  - Anticipation minimum 24h
  - Annulation gratuite jusqu'à 48h avant
  - Confirmation par email/SMS
  - Paiement en ligne optionnel

#### BOOK-02: Calendrier Disponibilités
- **Description**: Visualisation des créneaux disponibles
- **Fonctionnalités**:
  - Calendrier mensuel interactif
  - Créneaux horaires disponibles
  - Filtres par type de consultation
  - Vue semaine/mois
- **Règles Métier**:
  - Horaires: 9h-18h, lun-sam
  - Créneaux de 30 minutes
  - Mise à jour en temps réel
  - Fuseau horaire automatique

#### BOOK-03: Gestion des Réservations
- **Description**: Suivi et modification des rendez-vous
- **Fonctionnalités**:
  - Liste des réservations (passées/futures)
  - Modification date/heure (sous conditions)
  - Annulation avec remboursement
  - Ajout notes/documents
- **Règles Métier**:
  - Modification possible jusqu'à 48h avant
  - Annulation: 100% remboursement >48h, 50% 24-48h, 0% <24h
  - Historique conservé indéfiniment

#### BOOK-04: Notifications Rendez-vous
- **Description**: Alertes automatiques de rappel
- **Fonctionnalités**:
  - Rappel 24h avant (email + push)
  - Rappel 2h avant (SMS + push)
  - Confirmation de prise en charge
  - Alerte de retard
- **Règles Métier**:
  - Notifications paramétrables
  - Respect des préférences utilisateur
  - Historique des notifications

#### BOOK-05: Services Vétérinaires
- **Description**: Catalogue des services disponibles
- **Fonctionnalités**:
  - Liste des services avec descriptions
  - Prix et durée estimée
  - Spécialités par espèce
  - Promotions et offres
- **Règles Métier**:
  - Prix TTC affiché
  - Durée estimée incluant attente
  - Disponibilité par espèce
  - Mise à jour mensuelle

#### BOOK-06: Historique des Rendez-vous
- **Description:**
- **Fonctionnalités**:
  - Historique complet avec filtres
  - Export PDF/CV
  - Statistiques d'utilisation
  - Notes et comptes-rendus
- **Règles Métier**:
  - Conservation 10 ans
  - Export format standard
  - Anonymisation possible

### Module 4: Synchronisation (SYNC-01 à SYNC-03)

#### SYNC-01: Synchronisation Multi-appareils
- **Description**: Synchronisation des données entre appareils
- **Fonctionnalités**:
  - Sync automatique en arrière-plan
  - Conflit résolution automatique
  - Mode hors-ligne
  - Priorité des modifications
- **Règles Métier**:
  - Sync toutes les 5 minutes
  - Dernière modification gagne
  - Cache local 24h maximum

#### SYNC-02: Sauvegarde Cloud
- **Description**: Backup sécurisé des données
- **Fonctionnalités**:
  - Backup quotidien automatique
  - Restauration sélective
  - Versioning des données
  - Chiffrement AES-256
- **Règles Métier**:
  - Rétention 30 jours
  - Compression automatique
  - Double backup (géoredondance)

#### SYNC-03: Import/Export
- **Description**: Migration des données
- **Fonctionnalités**:
  - Export CSV/JSON/PDF
  - Import depuis autres plateformes
  - Validation des données importées
  - Rapport d'import
- **Règles Métier**:
  - Format standardisé
  - Validation obligatoire
  - Support Unicode

### Module 5: Services Externes (EXT-01 à EXT-03)

#### EXT-01: Contenu Vétérinaire
- **Description**: Articles et guides vétérinaires
- **Fonctionnalités**:
  - Articles par espèce/thème
  - Vidéos éducatives
  - Quiz de connaissances
  - Recherche avancée
- **Règles Métier**:
  - Contenu validé par des vétérinaires
  - Mise à jour mensuelle
  - Personnalisation par profil

#### EXT-02: Campagnes de Santé
- **Description**: Alertes et rappels de santé
- **Fonctionnalités**:
  - Rappels vaccins
  - Alertes saisonnières
  - Conseils prévention
  - Notifications géolocalisées
- **Règles Métier**:
  - Personnalisation par animal
  - Respect vie privée
  - Opt-out possible

#### EXT-03: Partenaires Vétérinaires
- **Description**: Annuaire des cliniques partenaires
- **Fonctionnalités**:
  - Recherche géolocalisée
  - Avis et notes
  - Prise de RDV directe
  - Services spécialisés
- **Règles Métier**:
  - Vérification des licences
  - Modération des avis
  - Mise à jour annuelle

---

## 🛠️ SPÉCIFICATIONS TECHNIQUES

### Architecture Globale
- **Architecture**: Client-Serveur avec API RESTful
- **Pattern**: Clean Architecture (Domain, Data, Presentation)
- **Approche**: Mobile-First avec Responsive Design

### Technologies Frontend (Flutter)
- **Framework**: Flutter 3.x
- **Langage**: Dart 3.x
- **State Management**: BLoC Pattern
- **Navigation**: Go Router
- **Local Storage**: SharedPreferences + Hive
- **HTTP Client**: Dio
- **Dependency Injection**: GetIt

### Technologies Backend (Node.js)
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Base de Données**: PostgreSQL 14+
- **ORM**: pg (native PostgreSQL)
- **Authentification**: JWT + Refresh Tokens
- **File Storage**: Cloudinary
- **Push Notifications**: Firebase Cloud Messaging

### Infrastructure
- **Hébergement**: Cloud (AWS/Azure/GCP)
- **Base de Données**: PostgreSQL managé
- **CDN**: CloudFlare
- **Monitoring**: New Relic/Datadog
- **Logs**: ELK Stack

### API Specifications
- **Format**: RESTful API
- **Authentification**: Bearer Token (JWT)
- **Rate Limiting**: 100 req/min par utilisateur
- **Versioning**: /api/v1/
- **Documentation**: OpenAPI 3.0
- **CORS**: Configuré pour domaines autorisés

---

## 🏗️ ARCHITECTURE DU SYSTÈME

### Architecture Frontend (Flutter)

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                    │
│  ├── Screens (Pages)                                  │
│  ├── Widgets (Components)                              │
│  └── BLoC (Business Logic Component)                   │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                         │
│  ├── Entities (Business Models)                         │
│  ├── Use Cases (Business Rules)                        │
│  └── Repositories (Contracts)                         │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                           │
│  ├── Repositories (Implementation)                      │
│  ├── Data Sources (Remote/Local)                      │
│  └── Models (Data Transfer Objects)                    │
└─────────────────────────────────────────────────────────────┘
```

### Architecture Backend (Node.js)

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway                         │
├─────────────────────────────────────────────────────────────┤
│  Routes Layer                                         │
│  ├── Auth Routes (/api/auth)                          │
│  ├── Users Routes (/api/users)                         │
│  ├── Pets Routes (/api/pets)                           │
│  ├── Bookings Routes (/api/bookings)                    │
│  └── External Routes (/api/external)                   │
├─────────────────────────────────────────────────────────────┤
│  Business Layer                                        │
│  ├── Services (Business Logic)                          │
│  ├── Validators (Input Validation)                      │
│  └── Middleware (Auth, Rate Limiting, etc.)          │
├─────────────────────────────────────────────────────────────┤
│  Data Access Layer                                     │
│  ├── Database (PostgreSQL)                             │
│  ├── File Storage (Cloudinary)                         │
│  └── Cache (Redis)                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ BASE DE DONNÉES

### Schéma Principal

#### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Pets Table
```sql
CREATE TABLE pets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100),
    birth_date DATE,
    weight DECIMAL(5,2),
    gender VARCHAR(10),
    identification_number VARCHAR(50),
    special_needs TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Bookings Table
```sql
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(id),
    booking_date TIMESTAMP NOT NULL,
    location VARCHAR(20) CHECK (location IN ('clinic', 'home')),
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Services Table
```sql
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    species_restrictions TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Indexes et Performance
- Index sur les clés étrangères
- Index composite sur (user_id, created_at)
- Index sur les champs de recherche
- Partitionnement par date pour les tables volumineuses

---

## 🎨 INTERFACE UTILISATEUR

### Design System
- **Thème**: Material Design 3
- **Palette**: Bleu vétérinaire (primaire), Vert (succès), Rouge (erreur)
- **Typographie**: Roboto + Open Sans
- **Icônes**: Material Icons + Custom Icons

### Responsive Design
- **Mobile**: 320px - 768px (priorité)
- **Tablette**: 768px - 1024px
- **Desktop**: 1024px+ (support)

### Accessibility
- WCAG 2.1 AA compliance
- Support lecteur d'écran
- Navigation clavier complète
- Contrastes respectés

### Performance UI
- 60 FPS constant
- Chargement progressif
- Skeleton screens
- Lazy loading

---

## 🔒 SÉCURITÉ

### Authentification
- **Password Hashing**: bcrypt (12 rounds)
- **JWT Tokens**: RS256 signature
- **Refresh Tokens**: Rotation automatique
- **Session Management**: Redis store

### Data Protection
- **Encryption**: TLS 1.3 en transit
- **Data at Rest**: AES-256
- **PII Masking**: Logs anonymisés
- **GDPR Compliance**: Droits utilisateurs

### API Security
- **Rate Limiting**: 100 req/min
- **Input Validation**: Joi/Express-validator
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Content Security Policy

### Mobile Security
- **Code Obfuscation**: Flutter build modes
- **Root Detection**: SafetyNet/DeviceCheck
- **Certificate Pinning**: HTTPS only
- **Local Storage Encryption**: Flutter Secure Storage

---

## ⚡ PERFORMANCE ET SCALABILITÉ

### Performance Targets
- **API Response Time**: <200ms (95th percentile)
- **App Load Time**: <3s
- **Database Query Time**: <100ms
- **Memory Usage**: <150MB mobile

### Scalability Strategy
- **Horizontal Scaling**: Load balancer + app instances
- **Database Scaling**: Read replicas + connection pooling
- **CDN**: Static assets globally distributed
- **Caching Strategy**: Multi-level caching (Redis, CDN, Browser)

### Monitoring
- **APM**: Application Performance Monitoring
- **Error Tracking**: Sentry/Rollbar
- **Analytics**: Custom dashboard
- **Health Checks**: Automated monitoring

---

## 🚀 DÉPLOIEMENT ET MAINTENANCE

### CI/CD Pipeline
- **Source Control**: Git flow
- **Build**: Automated testing + Docker build
- **Deploy**: Blue-green deployment
- **Rollback**: Automated rollback on failure

### Environment Strategy
- **Development**: Local + staging
- **Testing**: Automated E2E tests
- **Production**: Blue-green with monitoring
- **Disaster Recovery**: Backup + restore procedures

### Maintenance
- **Updates**: Scheduled maintenance windows
- **Backups**: Daily automated backups
- **Patching**: Security patches within 24h
- **Documentation**: Living documentation

---

## 📦 LIVRAISON ET ACCEPTATION

### Livrables
1. **Application Mobile** (iOS + Android)
2. **API Backend** (Node.js + PostgreSQL)
3. **Documentation Technique**
4. **Guide Utilisateur**
5. **Kit de Déploiement**

### Critères d'Acceptation
- ✅ Tous les modules fonctionnels implémentés
- ✅ Tests unitaires >90% coverage
- ✅ Tests E2E passants
- ✅ Performance targets atteints
- ✅ Security audit validé
- ✅ Documentation complète

### Timeline
- **Phase 1**: MVP (Auth + Pets + Bookings) - 2 mois
- **Phase 2**: Advanced Features (Sync + External) - 1 mois
- **Phase 3**: Production Ready + Optimization - 1 mois

---

## 📊 MÉTRIQUES DE SUCCÈS

### KPIs Techniques
- **Uptime**: >99.9%
- **Response Time**: <200ms
- **Error Rate**: <0.1%
- **Load Time**: <3s

### KPIs Business
- **Adoption Rate**: >1000 users/mois
- **Retention Rate**: >80% après 30 jours
- **Booking Conversion**: >60%
- **User Satisfaction**: >4.5/5

---

## 🔮 ÉVOLUTIONS FUTURES

### Roadmap V2
- **AI Features**: Diagnostic assistance
- **IoT Integration**: Connected devices
- **Telemedicine**: Video consultations
- **Marketplace**: Products and services
- **Multi-language**: International expansion

### Scalability Long-term
- **Microservices**: Service decomposition
- **Event-Driven**: Kafka/RabbitMQ
- **GraphQL**: Flexible data queries
- **Edge Computing**: Global distribution

---

*Ce cahier des charges est un document vivant qui évoluera avec le projet. Toute modification doit être documentée et validée par les parties prenantes.*

**Version**: 1.0  
**Date**: 2 Avril 2026  
**Auteur**: Équipe de Développement PlutoVets
