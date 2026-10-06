# CrowdFundr

**Une plateforme de financement participatif conçue de bout en bout comme un projet de bases de données : de la note de clarification de la formulation du client, la modélisation UML à trois implémentations fonctionnelles (PostgreSQL, PostgreSQL + JSONB, MongoDB) avec des applications console.**

![Python](https://img.shields.io/badge/Python-3.9%2B-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white)
![PlantUML](https://img.shields.io/badge/UML-PlantUML-blue)

> Projet universitaire en équipe (cours de  conception de bases de données, 4 étudiants).

## À propos

CrowdFundr est une plateforme moderne de financement participatif qui a besoin d'une base de données pour gérer des projets proposés, des équipes de créateurs, des soutiens financiers et ses utilisateurs.

Elle permet à des créateurs de publier des projets (technologiques, artistiques ou sociaux), à des utilisateurs de les financer, éventuellement en échange d'une contrepartie (numérique ou physique, expédiée par un transporteur partenaire), et aux contributeurs de noter les projets qu'ils ont soutenus.

Le même domaine métier est modélisé et implémenté **trois fois**, afin de comparer les approches :

| Approche | Dossier | Points clés |
|---|---|---|
| Relationnel (PostgreSQL) | [`postgresql/`](postgresql) | Schéma normalisé, héritage, triggers pour les contraintes complexes, application console |
| JSON-relationnel (PostgreSQL `JSONB`) | [`json-relational/`](json-relational) | Sous-entités intégrées en JSONB, contraintes assurées par des `CHECK` |
| Documents (MongoDB) | [`mongodb/`](mongodb) | 3 collections (`personnes`, `projets`, `contributions`), pipelines d'agrégation, application console |

## Ce que démontre ce projet

- **Modélisation conceptuelle** en UML (diagrammes de classes avec sources PlantUML), puis traduction en modèles logiques (MLD) avec les choix documentés pour chaque cas d'héritage.
- **Contraintes d'intégrité complexes** que le SQL seul ne sait pas exprimer de façon déclarative, implémentées avec des **triggers PostgreSQL** :
  - un projet est exactement d'un seul type : technologique, artistique ou social (héritage exclusif) ;
  - une contrepartie est exactement numérique ou physique ;
  - un utilisateur ne peut noter qu'un projet auquel il a déjà contribué.
- **SQL analytique** : jointures multiples, `GROUP BY` / `HAVING`, sous-requêtes, `EXISTS`.
- **Réflexion sur la migration de données** : modèle relationnel → JSONB → documents, et les compromis de chacun.
- **Applications** en Python avec requêtes paramétrées (aucun SQL construit par concaténation), gestion des erreurs et rollback, et configuration par variables d'environnement.

## Les trois besoins métier

1. Quels **projets artistiques** font intervenir **à la fois** Hideo Kojima et Yoji Shinkawa et ont dépassé leur objectif de financement ?
2. Quelle est la **moyenne des notes** des **projets sociaux soutenus par Amnesty International**, en ne comptant que les utilisateurs ayant contribué plus de 50 € ?
3. Pour chaque **projet accompagné par un incubateur**, combien d'**utilisateurs distincts** ont réclamé au moins une contrepartie physique expédiée par **Chronopost** ?

Ils sont implémentés en SQL ([`postgresql/sql/03_queries.sql`](postgresql/sql/03_queries.sql)), dans l'application PostgreSQL, et sous forme de pipelines d'agrégation MongoDB dans l'application MongoDB.

## Modèle de données

![Diagramme de classes UML](docs/diagrams/relational-mcd-v2.png)

Autres diagrammes : [modèle JSON-relationnel](docs/diagrams/json-relational-uml.png) · [modèle MongoDB](docs/diagrams/mongodb-model.png). Les sources PlantUML (`.puml`) se trouvent dans [`docs/diagrams/`](docs/diagrams).

## Structure du dépôt

```
crowdfundr/
├── postgresql/
│   ├── sql/                 # 01_create → 05_delete (schéma, données, requêtes, mises à jour, suppressions)
│   └── app.py               # Application console (PostgreSQL)
├── json-relational/
│   └── schema.sql           # Schéma PostgreSQL avec colonnes JSONB
├── mongodb/
│   ├── setup.js             # Crée les collections, index et données d'exemple (mongosh)
│   └── app.py               # Application console (MongoDB)
├── docs/
│   ├── ENONCE.md            # Énoncé original du projet
│   ├── NOTE_DE_CLARIFICATION.md   # Exigences, contraintes, hypothèses, répartition du travail
│   ├── modeling/            # Modèles logiques (MLD) de chaque approche
│   └── diagrams/            # Diagrammes UML (PNG + sources PlantUML)
├── .env.example             # Modèle de configuration
└── requirements.txt
```

## Démarrage

### 1. Environnement Python

```bash
python -m venv venv
source venv/bin/activate        # Windows : venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # puis modifiez .env avec vos propres valeurs
```

### 2a. Version PostgreSQL

```bash
createdb crowdfundr
psql -d crowdfundr -f postgresql/sql/01_create.sql
psql -d crowdfundr -f postgresql/sql/02_insert.sql
python postgresql/app.py
```

`03_queries.sql` contient les requêtes métier et peut être exécuté à tout moment.
`04_update.sql` et `05_delete.sql` sont des scripts de démonstration qui modifient les données d'exemple.

### 2b. Version JSON-relationnelle

```bash
createdb crowdfundr_json
psql -d crowdfundr_json -f json-relational/schema.sql
```

### 2c. Version MongoDB

```bash
mongosh --file mongodb/setup.js     # crée la base "crowdfundr" avec des données d'exemple
python mongodb/app.py
```

## Fonctionnalités des applications console

**Menu utilisateur**

- Se connecter ou créer un compte
- Ajouter une contribution à un projet
- Évaluer un projet (note de 1 à 5 + avis), uniquement si vous y avez contribué
- Afficher tous les projets
- Consulter vos contributions et leur total

**Menu administrateur** (nécessite que `CROWDFUNDR_ADMIN_PASSWORD` soit défini dans `.env`)

- Gérer les utilisateurs et les projets (lister, modifier, supprimer ; les opérations exactes diffèrent légèrement entre les applications PostgreSQL et MongoDB)
- Afficher les tables / collections
- Exécuter les trois requêtes complexes ci-dessus

## Documentation

- [Énoncé du projet](docs/ENONCE.md)
- [Note de clarification](docs/NOTE_DE_CLARIFICATION.md)
- Modèles logiques : [relationnel](docs/modeling/relational-mld-v2.md) · [JSON-relationnel](docs/modeling/json-relational-mld.md)
