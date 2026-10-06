# MLD 2

## 1. Choix de modélisation

### Héritage pour Projet
On choisit ici un héritage par référence.
Ce choix permet de séparer les informations communes et spécifiques, tout en évitant d’avoir des colonnes inutiles ou vides (NULL) dans la table Projet.

### Héritage pour Contrepartie

On choisit un héritage par référence.

La table Contrepartie contient les informations communes à toutes les contreparties, notamment :

l’identifiant de la contrepartie,
le projet auquel elle appartient.

Une contrepartie dépend d’un unique projet via une clé étrangère, ce qui traduit la composition entre Projet et Contrepartie.

### Héritage pour Personne

La classe `Personne` est abstraite et n'a aucune association tansdisque les **clases filles** en possèdent, donc on réalise l'héritage par **classe fille**.

### Association Transporteur

Un transporteur peut expédier plusieurs contreparties physiques.

La clé étrangère est donc placée dans ContrepartiePhysique.

On modélise :

un transporteur unique par contrepartie physique
plusieurs contreparties physiques par transporteur.

---

## 2. Relations

> **Note :** Tous les attributs sont `NOT NULL` par défaut, sauf indication contraire.

### MembreEquipe

```
MembreEquipe(
  #id_personne : int,
  nom : str,
  prenom : str,
  pays_residence : str,
  date_naissance : date
)
```

### Utilisateur

```
Utilisateur(
  #id_personne : int,
  pseudo : str,
  adresse_mail : str,
  nom : str,
  date_naissance : date
)
```


### Projet (classe mère)

```
Projet(
    #titre : str,
    description : str,
    objectif_financier : float,
    date_lancement : date,
    incubateur => Incubateur.
)
```
*incubateur est optionnel*

### Projet_technologique

```
Projet_technologique(
    #titre => Projet(titre) ,
    type_innovation : str
)
```


### Projet_artistique

```
Projet_artistique(
    #titre => Projet(titre),
    medium : str
)
```


### Projet_social

```
Projet_social(
    #titre => Projet(titre),
    region_cible : str
)
```


### Contribution

```
Contribution(
  #date_heure : datetime,
  #utilisateur => Utilisateur(id_personne),
  #projet => Projet(titre),
  montant : float,
  contrepartie => Contrepartie(id_contrepartie)
)
```

### Contrepartie (classe mère)

```
Contrepartie(
  #id_contrepartie : int,
  projet => Projet(titre)
)
```
- `projet est note nul à cause de la cardinalité sur l'association 1:N`

### Contrepartie_numerique

```
Contrepartie_numerique(
    #id_contrepartie => Contrepartie(id_contrepartie),
    format_fichier : str,
    taille : float,
)
```


### Contrepartie_physique

```
Contrepartie_physique(
    #id_contrepartie => Contrepartie(id_contrepartie),
    poids : float,
    frais_livraison : float,
    transporteur => Transporteur(nom)
)
```



### Transporteur

```
Transporteur(
    #nom : str,
    delai_livraison : int
)
```


### ONG

```
ONG(
  #num_ONG : int,
  nom_ONG : str,
  pays : str
)
```

### SoutenuPar

```
SoutenuPar(
  #ong => ONG(num_ONG),
  #projet => Projet(titre)
)
```

### Evaluer

```
Evaluer(
  #projet => Projet(titre),
  #utilisateur => Utilisateur(id_personne),
  note : int,
  avis_text : str,
  date_avis : date 
)
```

### Incubateur

```
Incubateur(
  #nom_incubateur : str,
  annee_creation : int,
  budget : float
)
```

### PorterPar

```
PorterPar(
  #membre => MembreEquipe(id_personne),
  #projet => Projet(titre),
  role : Role_membre
)
```

### Role_membre

```
Role_membre(
  chef_projet, 
  developpeur, 
  designer, 
  community_manager
)
```
---

## 3. Contraintes

## Contrainte générale sur le MCD
- role : UNIQUE
- num_ONG : UNIQUE
- pseudo : UNIQUE
- note >= 1 AND note <= 5
- montant >= 0
- objectif_financier > 0
- date_heure : local_key
- taille >= 0
- poids > 0
- frais_livraison >= 0
- budget > 0
- Ne peut evaluer un projet qu'un utilisateur ayant contribué financièrement au moin une fois à un projet: 

- Une seule evaluation par utilisateur pour un projet donné.

## Contrainte sur les cardinalité

### Les cardinalitées de type 1:N
Il existe 5 association de type 1:N
### 1)-MembreEquipe(1)---PorterPar(N):
```
Restriction(MembreEquipe,id_personne IS NOT NULL) AND Projection(MembreEquipe,id_personne)=Projection(PorterPar,membre)
```

### 2)-Projet(1)---PorterPar(N):
```
Restriction(Projet,titre IS NOT NULL) AND Projection(Projet,titre)=Projection(PorterPar,projet)
```

### 3)-Projet(N)---Incubateur(0..1):
```
Restriction(Incubateur, nom_incubateur OPTIONAL) AND Projection(Incubateur,nom_incubateur)--inclus_dans>Projection(PorterPar,projet)
```

### 4)-Projet(1)---Evaluer(N):
```
Restriction(Projet, titre IS NOT NULL) AND Projection(Projet,titre)=Projection(Evaluer,titre)
```

### 5)-Utilisateur(1)---Evaluer(N):
```
Restriction(Utilisateur, pseudo IS NOT NULL) AND Projection(Utilisateur,pseudo)=Projection(Evaluer,utlisateur)
```

### Les cardinalitées de type N:M
Il existe deux associations de type N:M
### 1)-Projet(N)--Contribution--Utilisateur(N):
```
PROJECTION(Projet,titre)=PROJECTION(Contribution,projet) AND PROJECTION(Utilisateur,id_personne)=PROJECTION(Contribution,utilisateur)
```

### 1)-Projet(N)--SoutenuPar--ONG(N):
```
PROJECTION(Projet,titre)=PROJECTION(SoutenuPar,projet) AND PROJECTION(ONG,num_ONG)=PROJECTION(SoutenuPar,ong)
```

## Contraintes liée aux trois héritages

### 1)Héritage avec Personne comme classe mère:

- `L'intersection de ces deux projections filles est vide` 


### 2)Héritage avec Projet comme classe mère:
```
PROJECTION(Projet, titre) = PROJECTION(Projet_technologique, titre) UNION PROJECTION(Projet_artistique, titre) UNION PROJECTION(Projet_social, titre)
```
- `L'intersection de ces trois projections filles est vide`

### 3)Héritage avec Contrepartie comme classe mère:
```
PROJECTION(Contrepartie, id_contrepartie) = PROJECTION(Contrepartie_numerique, id_contrepartie) UNION PROJECTION(Contrepartie_physique, id_contrepartie)
```
- `L'intersection de ces deux projections filles est vide`


### Contribution nécessaire pour évaluer

Un utilisateur ne peut évaluer un projet que s'il a une `Contribution` associée :
```
Projection(Evaluer, (projet, utilisateur)) ⊆ Projection(Contribution, (projet, utilisateur))
```
