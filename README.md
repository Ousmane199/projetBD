# Projet Base de Données - BricoPlus

## 📋 Description

Système de gestion de base de données Oracle pour l'entreprise BricoPlus gérant des usines, points de vente, employés, produits et leurs interactions. Ce projet implémente un modèle relationnel complet avec contraintes d'intégrité, triggers de validation et visualisation des données via Power BI.

## 🏗️ Architecture de la Base de Données

### Tables Principales

#### 🏭 Gestion des Sites de Production

- **USINES** : Informations sur les sites de production
- **TYPEU** : Types d'usines (chaîne assemblage, scierie, métallurgie, fonderie)
- **DEPARTEMENTS** : Départements organisationnels des usines

#### 🏪 Gestion des Points de Vente

- **POINTS_DE_VENTE** : Magasins de distribution (GSB, Brico-Express)

#### 👥 Gestion des Ressources Humaines

- **EMPLOYES** : Informations personnelles et professionnelles des employés
- **QUALIFICATIONS** : Compétences et qualifications requises
- **POSSEDER** : Association employés-qualifications
- **AUTORISER** : Qualifications autorisées par département

#### 📦 Gestion des Produits

- **PRODUITS** : Catalogue de produits
- **GAMME** : Catégories de produits (11 gammes disponibles)
- **ASSEMBLER** : Nomenclature des produits composés

#### 💼 Gestion des Operations

- **FABRIQUER** : Suivi de la production
- **VENDRE** : Transactions de vente
- **FACTURER** : Grille tarifaire des produits

#### ⏱️ Gestion du Temps de Travail

- **TRAVAILLER_USINE** : Heures travaillées en usine
- **TRAVAILLER_PT_VENTE** : Heures travaillées en point de vente
- **DIRIGER** : Historique de direction des départements

#### 💰 Gestion de la Rémunération

- **PAYER1** : Salaires fixes et indices
- **PAYER2** : Indices de rétrocession par gamme
- **RESPONSABLE** : Responsabilités par gamme de produits

## 🔒 Contraintes et Validations

### Triggers de Validation Implémentés

Le système comprend **21 triggers** assurant l'intégrité des données :

#### Validations de Format

- Codes postaux : Format `XXXXX` (5 chiffres)
- Numéros de téléphone : Format `XXXXXXXXXX` (10 chiffres)
- Codes gamme : Format `GXX` (G suivi de 2 chiffres)

#### Validations Métier

- Dates : Aucune date future autorisée
- Quantités : Toutes supérieures à 0
- Mois : Valeurs entre 1 et 12
- Codes : Tous les identifiants > 0
- Types énumérés : Validation des valeurs autorisées

#### Contraintes Spécifiques

- Un produit ne peut pas être composé de lui-même
- IndiceRetrocessionG : Valeur entre 0 et 1 (exclusif)
- Types d'usines limités : chaîne assemblage, scierie, métallurgie, fonderie
- Types de points de vente : GSB ou Brico-Express

## 📊 Gammes de Produits Disponibles

1. Jardin et piscine
2. Mobilier intérieur
3. Plomberie et chauffage
4. Salle de bain et WC
5. Luminaire
6. Électricité et domotique
7. Quincaillerie
8. Cuisine
9. Peinture et droguerie
10. Carrelage et parquet
11. Matériaux de construction

## 🚀 Installation

- Oracle Database 11g ou supérieur
- Power BI Desktop (pour la visualisation)

### Déploiement de la Base de Données

```bash
# Se connecter à Oracle
Serveur
90.103.29.148:15210/FREEPDB1

# A confirmer avec nous
GROUPE_4
groupe4

```

### Filtres et Slicers Recommandés

- Période (Année, Mois)
- Gamme de produits
- Usine / Point de vente
- Type de point de vente (GSB, Brico-Express)
- Département
- Employé / Responsable de gamme

## 📁 Structure du Projet

```
projetBD/
│
├── creationBD.sql          # Script de création complet
├── README.md               # Documentation du projet
├── requetes/               # Répertoire pour les requêtes SQL
│   └── analyses.sql        # Requêtes d'analyse
├── python/
│   └── generation.sql      # Script python pour generer les données aleatoirement
└── powerbi/                # Dashboards Power BI
    ├── BricoPlus_Production_Et_Vente.pbix
    ├── BricoPlus_Global.pbix
    └── BricoPlus_Rh_Et_Salaire.pbix
```

## 🔧 Utilisation

### Exemples de Requêtes SQL

#### Insérer une usine

```sql
INSERT INTO USINES (CodeU, NomU, RueU, CPostalU, VilleU, TelU)
VALUES (1, 'Usine Paris Nord', '15 Rue de l''Industrie', '75018', 'Paris', '0145678901');

Sinon directement Excel
```

## ⚠️ Gestion des Erreurs

Les triggers génèrent des erreurs Oracle personnalisées (codes -20001 à -20303) pour faciliter le débogage :

- **-20001 à -20009** : Erreurs de dates futures
- **-20100 à -20199** : Erreurs de validation des entités principales
- **-20200 à -20303** : Erreurs de validation des relations

## 📝 Master MIAGE

Projet académique - Tous droits réservés

## 🔄 Versions

- **v1.0** (Novembre 2025) : Version initiale avec structure complète, triggers et intégration Power BI

---

**Note** : Ce système est conçu pour un environnement Oracle avec visualisation Power BI. La connexion DirectQuery est recommandée pour des données en temps réel.
