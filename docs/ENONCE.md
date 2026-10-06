# Énoncé du projet

## Hypothèses

CrowdFundr, une plateforme moderne de financement participatif, souhaite concevoir une base de données pour gérer les projets proposés, les équipes de créateurs, les soutiens financiers et ses utilisateurs.

Un projet a un titre, une description, un objectif financier (en euros), une date de lancement, et optionnellement un incubateur partenaire. Un projet est porté par un ou plusieurs membres d'équipe, qui ont chacun un rôle unique sur ce projet (chef de projet, développeur, designer, community manager). Un incubateur a un nom, une année de création et un budget d'accompagnement. Un membre d'équipe a un nom, un prénom, un pays de résidence et une date de naissance.

La plateforme catégorise les projets comme suivant :

* Un projet technologique qui possède un type d'innovation.
* Un projet artistique qui possède un médium principal (ex : peinture, musique).
* Un projet social qui possède une région cible. De plus, un projet social peut être officiellement soutenu par une ou plusieurs ONG (Organisations Non Gouvernementales). Une ONG est identifiée par un numéro d'enregistrement unique, et possède un nom et un pays d'origine.

Un utilisateur (contributeur) possède un pseudo unique, une adresse mail, un nom et une date de naissance. On souhaite enregistrer toutes les contributions financières qu'il effectue sur les projets. Une contribution est liée à un utilisateur et à un projet, possède une date et heure (permettant à un utilisateur de contribuer plusieurs fois au même projet), un montant, et peut optionnellement inclure une contrepartie choisie par l'utilisateur.

Il existe deux types de contreparties :

* Les contreparties numériques qui ont un format de fichier et une taille en Mo.
* Les contreparties physiques qui ont un poids estimé et des frais de livraison. Pour des raisons logistiques, chaque contrepartie physique est obligatoirement expédiée via un unique Transporteur partenaire. Un transporteur possède un nom et un délai de livraison moyen (en jours).

Un utilisateur peut également évaluer un projet (note de 1 à 5) et laisser un avis textuel. La plateforme impose qu'un utilisateur ait contribué financièrement au moins une fois à un projet pour pouvoir le noter. On n'autorise qu'un seul avis par utilisateur pour un projet donné, et on enregistre la date de cet avis.

## Besoins

La plateforme CrowdFundr souhaite pouvoir répondre aux questions suivantes :

* Quels projets artistiques font intervenir à la fois Hideo Kojima et Yoji Shinkawa (membres d'équipe) et ont dépassé leur objectif financier (somme des contributions > objectif) ?
* Quelle est la moyenne des notes des projets sociaux qui sont soutenus par l'ONG nommée Amnesty International, en ne prenant en compte que les utilisateurs ayant apporté une contribution supérieure à 50 euros sur ces projets ?
* Pour chaque projet accompagné par un incubateur, combien d'utilisateurs distincts ont réclamé au moins une contrepartie physique expédiée via le transporteur "Chronopost" lors de leurs contributions ?
