# MLD relationnel-JSON - CrowdFundr

## 1. Objectif du modèle

Ce modèle logique de données propose une version **relationnelle-JSON** du projet CrowdFundr.

L'idée est de conserver en relationnel les données qui servent aux identifiants, aux clés étrangères, aux contraintes fortes et aux jointures fréquentes, tout en utilisant des attributs `JSON` pour les données semi-structurées ou variables.

---

## 2. Choix de modélisation

### Projet

Dans le MCD initial, `Projet` possède trois sous-types :

- `Projet_technologique`
- `Projet_artistique`
- `Projet_social`

Dans le modèle relationnel-JSON, ces sous-types sont regroupés dans la table `PROJET` grâce à deux attributs :

- `type_projet`
- `details_projet JSON`

Ainsi, les attributs spécifiques comme `type_innovation`, `medium` ou `region_cible` sont stockés dans `details_projet`.

### Contrepartie

Dans le MCD initial, `Contrepartie` possède deux sous-types :

- `Contrepartie_numerique`
- `Contrepartie_physique`

Dans ce modèle, les contreparties sont stockées dans un attribut JSON de la table `PROJET` :

- `contreparties JSON`

Chaque objet JSON contient le type de contrepartie et ses attributs spécifiques.

### Associations transformées en JSON

Certaines associations sont intégrées dans `PROJET` sous forme de tableaux JSON :

- `equipe` remplace l'association `PorterPar`
- `evaluations` remplace l'association `Evaluer`
- `soutiens_ong` remplace l'association entre `Projet_social` et `ONG`
- `contreparties` remplace la composition entre `Projet` et `Contrepartie`

La table `CONTRIBUTION` reste relationnelle, car elle contient des montants financiers et représente un événement important du système.

---

## 3. Relations du modèle

### PROJET

```text
PROJET(
  #idProjet : INT,
  titre : VARCHAR,
  description : TEXT,
  objectif_financier : DECIMAL,
  date_lancement : DATE,
  type_projet : ENUM('technologique', 'artistique', 'social'),
  details_projet : JSON,
  idIncubateur => INCUBATEUR(idIncubateur) NULL,
  contreparties : JSON,
  equipe : JSON,
  evaluations : JSON,
  soutiens_ong : JSON
)
```

### UTILISATEUR

```text
UTILISATEUR(
  #pseudo : VARCHAR,
  nom : VARCHAR,
  date_naissance : DATE,
  adresse_mail : VARCHAR
)
```


### INCUBATEUR

```text
INCUBATEUR(
  #idIncubateur : INT,
  nom_incubateur : VARCHAR,
  annee_creation : DATE,
  budget : DECIMAL
)
```



### CONTRIBUTION

```text
CONTRIBUTION(
  #idContribution : INT,
  pseudo => UTILISATEUR(pseudo),
  idProjet => PROJET(idProjet),
  date_heure : TIMESTAMP,
  montant : DECIMAL,
  contrepartie_choisie : JSON
)
```

---

## 4. Détail des attributs JSON

### details_projet

L'attribut `details_projet` contient les informations spécifiques au type de projet.

Projet technologique :

```json
{ "type_innovation": "..." }
```

Projet artistique :

```json
{ "medium": "..." }
```

Projet social :

```json
{ "region_cible": "..." }
```

Contrainte logique :

```text
Si type_projet = 'technologique', alors details_projet contient type_innovation.
Si type_projet = 'artistique', alors details_projet contient medium.
Si type_projet = 'social', alors details_projet contient region_cible.
```

### contreparties

L'attribut `contreparties` contient la liste des contreparties proposées par un projet.

```json
[
  {
    "idContrepartie": "...",
    "type_contrepartie": "numerique",
    "format_fichier": "...",
    "taille": "..."
  },
  {
    "idContrepartie": "...",
    "type_contrepartie": "physique",
    "poids": "...",
    "frais_livraison": "...",
    "Transporteur": {"nom_tr":"...",
                    "delai_livraison":"..."
                    }
  }
]
```

Contrainte logique :

```text
Si type_contrepartie = 'numerique',
alors l'objet contient format_fichier et taille.

Si type_contrepartie = 'physique',
alors l'objet contient poids, frais_livraison et idTransporteur.
```

`idTransporteur` référence logiquement `TRANSPORTEUR(idTransporteur)`.

### equipe

L'attribut `equipe` contient les membres qui portent un projet, avec leur rôle.

```json
[
  {
    "idMembre": "...",
    "role": "..."
  }
]
```

Contrainte logique :

```text
idMembre référence MEMBRE_EQUIPE(idMembre).
Un même membre ne doit pas avoir deux fois le même rôle sur le même projet.
```

### evaluations

L'attribut `evaluations` contient les avis laissés sur un projet.

```json
[
  {
    "pseudo": "...",
    "note": "...",
    "avis_text": "...",
    "date_avis": "..."
  }
]
```

Contraintes logiques :

```text
pseudo référence UTILISATEUR(pseudo).
note est comprise entre 1 et 5.
Un utilisateur ne peut évaluer un projet qu'une seule fois.
Un utilisateur ne peut évaluer un projet que s'il a déjà contribué à ce projet.
```

### soutiens_ong

L'attribut `soutiens_ong` contient les ONG qui soutiennent un projet social.

```json
[
  {
    "num_ONG": "..."
  }
]
```

Contrainte logique :

```text
num_ONG référence ONG(num_ONG).
Si type_projet = 'social', alors soutiens_ong ne doit pas être vide.
Si type_projet n'est pas 'social', alors soutiens_ong peut être vide.
```

### contrepartie_choisie

Dans `CONTRIBUTION`, l'attribut `contrepartie_choisie` indique la contrepartie choisie par l'utilisateur.

```json
{
  "idContrepartie": "..."
}
```

Contrainte logique :

```text
contrepartie_choisie.idContrepartie doit exister dans PROJET.contreparties[]
pour le projet concerné par la contribution.
```

---

## 5. Contraintes principales

### Contraintes relationnelles

```text
CONTRIBUTION.pseudo -> UTILISATEUR.pseudo
CONTRIBUTION.idProjet -> PROJET.idProjet
PROJET.idIncubateur -> INCUBATEUR.idIncubateur
```

### Contraintes internes aux JSON

```text
PROJET.equipe[].idMembre -> MEMBRE_EQUIPE(idMembre)
PROJET.evaluations[].pseudo -> UTILISATEUR(pseudo)
PROJET.soutiens_ong[].num_ONG -> ONG(num_ONG)
PROJET.contreparties[].idTransporteur -> TRANSPORTEUR(idTransporteur)
CONTRIBUTION.contrepartie_choisie.idContrepartie -> PROJET.contreparties[].idContrepartie
```

### Contraintes métier

```text
objectif_financier > 0
montant > 0
note BETWEEN 1 AND 5
adresse_mail UNIQUE
pseudo UNIQUE
titre UNIQUE
```

Un projet doit avoir un seul type :

```text
type_projet IN ('technologique', 'artistique', 'social')
```

Une contrepartie doit avoir un seul type :

```text
type_contrepartie IN ('numerique', 'physique')
```

---

## 6. Index

Pour interroger efficacement les données JSON :

```sql
CREATE INDEX idx_projet_details_projet
ON PROJET USING GIN(details_projet);

CREATE INDEX idx_projet_contreparties
ON PROJET USING GIN(contreparties);

CREATE INDEX idx_projet_equipe
ON PROJET USING GIN(equipe);

CREATE INDEX idx_projet_evaluations
ON PROJET USING GIN(evaluations);

CREATE INDEX idx_projet_soutiens_ong
ON PROJET USING GIN(soutiens_ong);

CREATE INDEX idx_contribution_contrepartie_choisie
ON CONTRIBUTION USING GIN(contrepartie_choisie);
```

---

## 7. Version compacte du MLD

```text
PROJET(
  #idProjet,
  titre,
  description,
  objectif_financier,
  date_lancement,
  type_projet,
  details_projet JSON,
  idIncubateur,
  contreparties JSON,
  equipe JSON,
  evaluations JSON,
  soutiens_ong JSON
)

UTILISATEUR(
  #pseudo,
  nom,
  date_naissance,
  adresse_mail
)

MEMBRE_EQUIPE(
  #idMembre,
  nom,
  date_naissance,
  prenom,
  pays_residence
)

INCUBATEUR(
  #idIncubateur,
  nom_incubateur,
  annee_creation,
  budget
)

ONG(
  #num_ONG,
  nom_ONG,
  pays
)

TRANSPORTEUR(
  #idTransporteur,
  nom_tr,
  delai_livraison
)

CONTRIBUTION(
  #idContribution,
  pseudo,
  idProjet,
  date_heure,
  montant,
  contrepartie_choisie JSON
)
```