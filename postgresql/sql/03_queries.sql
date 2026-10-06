-- =====================================================
--REQUETES SELON LES BESOIN DU PROJET
-- =====================================================
--Quels projets artistiques font intervenir à la fois Hideo Kojima et Yoji Shinkawa (membres d'équipe)
--et ont dépassé leur objectif financier (somme des contributions > objectif)
-- =====================================================
SELECT Projet.titre
FROM
    MembreEquipe
    JOIN PorterPar ON MembreEquipe.id_personne = PorterPar.membre
    JOIN Projet ON PorterPar.projet = Projet.titre
    JOIN Projet_artistique ON Projet_artistique.titre = Projet.titre
    JOIN Contribution ON Projet.titre = Contribution.projet
WHERE
    MembreEquipe.nom = 'Shinkawa'
    AND MembreEquipe.prenom = 'Yoji'
    AND Projet.titre IN (
        SELECT Projet.titre
        FROM
            MembreEquipe
            JOIN PorterPar ON MembreEquipe.id_personne = PorterPar.membre
            JOIN Projet ON PorterPar.projet = Projet.titre
            JOIN Projet_artistique ON Projet_artistique.titre = Projet.titre
        WHERE
            MembreEquipe.nom = 'Kojima'
            AND MembreEquipe.prenom = 'Hideo'
    )
GROUP BY
    Projet.titre,
    Projet.objectif_financier
HAVING
    SUM(Contribution.montant) > Projet.objectif_financier;
-- =====================================================
--RQ2 : Quelle est la moyenne des notes des projets sociaux qui sont soutenus par l'ONG nommée Amnesty International,
--en ne prenant en compte que les utilisateurs ayant apporté une contribution supérieure à 50 euros sur ces projets ?
-- =====================================================
SELECT AVG(Evaluer.note) AS note_moyenne
FROM Evaluer
    JOIN Projet_social ON Evaluer.projet = Projet_social.titre
WHERE
    EXISTS (
        SELECT 1
        FROM SoutenuPar
            JOIN ONG ON ONG.num_ONG = SoutenuPar.ONG
        WHERE SoutenuPar.projet = Projet_social.titre
            AND ONG.nom_ONG = 'Amnesty International'
    )
    -- EXISTS (et non un JOIN) : chaque note n'est comptée qu'une fois,
    -- même si l'utilisateur a fait plusieurs contributions > 50 EUR.
    AND EXISTS (
        SELECT 1
        FROM Contribution
        WHERE Contribution.projet = Evaluer.projet
            AND Contribution.utilisateur = Evaluer.utilisateur
            AND Contribution.montant > 50
    );

-- =====================================================
-- RQ3 : Projets avec incubateur : nombre d'utilisateurs distincts
--       ayant contribué avec une contrepartie physique via Chronopost
-- =====================================================
SELECT
    p.titre,
    p.incubateur,
    COUNT(DISTINCT c.utilisateur) AS nb_utilisateurs_chronopost
FROM
    Projet p
    JOIN Contribution c ON p.titre = c.projet
    JOIN Contrepartie_physique cp ON c.contrepartie = cp.id_contrepartie
WHERE
    p.incubateur IS NOT NULL
    AND cp.transporteur = 'Chronopost'
GROUP BY
    p.titre,
    p.incubateur
ORDER BY nb_utilisateurs_chronopost DESC;

-- =====================================================
-- REQUETES COMPLEXES SUPPLEMENTAIRES
-- =====================================================

-- RQ4 : Utilisateurs ayant contribué à plusieurs types de projets différents
SELECT u.id_personne, u.pseudo, u.nom, COUNT(
        DISTINCT CASE
            WHEN pt.titre IS NOT NULL THEN 'technologique'
        END
    ) + COUNT(
        DISTINCT CASE
            WHEN pa.titre IS NOT NULL THEN 'artistique'
        END
    ) + COUNT(
        DISTINCT CASE
            WHEN ps.titre IS NOT NULL THEN 'social'
        END
    ) AS nb_types_projets
FROM
    Utilisateur u
    JOIN Contribution c ON u.id_personne = c.utilisateur
    LEFT JOIN Projet_technologique pt ON c.projet = pt.titre
    LEFT JOIN Projet_artistique pa ON c.projet = pa.titre
    LEFT JOIN Projet_social ps ON c.projet = ps.titre
GROUP BY
    u.id_personne,
    u.pseudo,
    u.nom
HAVING
    COUNT(
        DISTINCT CASE
            WHEN pt.titre IS NOT NULL THEN 'technologique'
        END
    ) + COUNT(
        DISTINCT CASE
            WHEN pa.titre IS NOT NULL THEN 'artistique'
        END
    ) + COUNT(
        DISTINCT CASE
            WHEN ps.titre IS NOT NULL THEN 'social'
        END
    ) > 1
ORDER BY nb_types_projets DESC;

-- RQ5 : Projets ayant dépassé leur objectif de plus de 50%
SELECT
    p.titre,
    p.objectif_financier,
    SUM(c.montant) AS total_collecte,
    SUM(c.montant) - p.objectif_financier AS surplus,
    ROUND(
        (
            SUM(c.montant) / p.objectif_financier - 1
        ) * 100,
        2
    ) AS pourcent_depassement
FROM Projet p
    JOIN Contribution c ON p.titre = c.projet
GROUP BY
    p.titre,
    p.objectif_financier
HAVING
    SUM(c.montant) >= p.objectif_financier * 1.5
ORDER BY pourcent_depassement DESC;

-- RQ6 : Membres d'équipe avec le plus grand nombre de rôles différents sur les projets
SELECT 
    me.id_personne,
    me.nom,
    me.prenom,
    COUNT(DISTINCT pp.role) AS nb_roles_differents,
    STRING_AGG(DISTINCT pp.role::text, ', ') AS roles_exerces
FROM MembreEquipe me
JOIN PorterPar pp ON me.id_personne = pp.membre
GROUP BY me.id_personne, me.nom, me.prenom
ORDER BY nb_roles_differents DESC;

-- RQ7 : Montant total des frais de livraison par transporteur et nombre de livraisons
SELECT
    t.nom AS nom_transporteur,
    t.delai_livraison,
    COUNT(cp.id_contrepartie) AS nb_livraisons,
    SUM(cp.frais_livraison) AS frais_totaux,
    ROUND(AVG(cp.frais_livraison), 2) AS frais_moyen
FROM
    Transporteur t
    JOIN Contrepartie_physique cp ON t.nom = cp.transporteur
GROUP BY
    t.nom,
    t.delai_livraison
ORDER BY frais_totaux DESC;

-- RQ8 : Projets avec le plus haut taux d'évaluation moyen et nombre d'évaluateurs distincts
SELECT
    p.titre,
    p.objectif_financier,
    ROUND(AVG(e.note), 2) AS note_moyenne,
    COUNT(DISTINCT e.utilisateur) AS nb_evaluateurs,
    COUNT(DISTINCT c.utilisateur) AS nb_contributeurs,
    COUNT(DISTINCT c.utilisateur) - COUNT(DISTINCT e.utilisateur) AS nb_non_evaluateurs
FROM
    Projet p
    LEFT JOIN Evaluer e ON p.titre = e.projet
    LEFT JOIN Contribution c ON p.titre = c.projet
GROUP BY
    p.titre,
    p.objectif_financier
HAVING
    AVG(e.note) IS NOT NULL
ORDER BY note_moyenne DESC, nb_evaluateurs DESC;

-- =====================================================
--REQUETES Simples
-- =====================================================

--1--liste des noms des ONG triée
SELECT nom_ong FROM ONG ORDER BY nom_ong;
--2--liste des transporteurs triée (ordre décroissant)
SELECT Transporteur.nom
FROM Transporteur
ORDER BY Transporteur.nom DESC;
--3--Le nom des projets soutenu par amnesty international
SELECT SoutenuPar.projet
FROM SoutenuPar
    JOIN ONG ON ONG.num_ONG = SoutenuPar.ONG
WHERE
    ONG.nom_ONG = 'Amnesty International';
--4-- Les projets ayant au moin une note inférieur ou égale à 3
SELECT projet.titre
FROM Projet
    JOIN Evaluer ON Projet.titre = Evaluer.projet
WHERE
    Evaluer.note <= 3;
--5--Le nom / prenom des personne ayant au moins une fois été chef d’équipe
SELECT MembreEquipe.nom, MembreEquipe.prenom
FROM MembreEquipe
    JOIN PorterPar ON PorterPar.membre = MembreEquipe.id_personne
WHERE
    role = 'chef_projet';

-- 6. Liste tous les utilisateurs avec leur pseudo
SELECT
    id_personne,
    pseudo,
    nom,
    adresse_mail
FROM Utilisateur
ORDER BY nom;

-- 7. Affiche tous les projets avec leur date de lancement
SELECT
    titre,
    description,
    objectif_financier,
    date_lancement
FROM Projet
ORDER BY date_lancement DESC;

-- 8. Liste les incubateurs par année de création
SELECT
    nom_incubateur,
    annee_creation,
    budget
FROM Incubateur
ORDER BY annee_creation DESC;

-- 9. Affiche tous les projets artistiques avec leur medium
SELECT pa.titre, pa.medium, p.description
FROM
    Projet_artistique pa
    JOIN Projet p ON p.titre = pa.titre;

-- 10. Affiche tous les projets technologiques avec leur type d'innovation
SELECT pt.titre, pt.type_innovation, p.objectif_financier
FROM
    Projet_technologique pt
    JOIN Projet p ON p.titre = pt.titre;

-- 11. Liste les projets sociaux par région cible
SELECT ps.titre, ps.region_cible, p.description
FROM Projet_social ps
    JOIN Projet p ON p.titre = ps.titre
ORDER BY ps.region_cible;

-- 12. Affiche tous les membres d'équipe avec leurs dates de naissance
SELECT
    id_personne,
    nom,
    prenom,
    pays_residence,
    date_naissance
FROM MembreEquipe
ORDER BY date_naissance;

-- 13. Affiche les contributions triées par montant décroissant (TOP 20)
SELECT
    date_heure,
    utilisateur,
    projet,
    montant
FROM Contribution
ORDER BY montant DESC
LIMIT 20;

-- 14. Liste les évaluations avec notes et avis
SELECT e.projet, e.utilisateur, e.note, e.avis_text, e.date_avis
FROM Evaluer e
ORDER BY e.note DESC;

-- 15. Affiche les contreparties numériques avec leur format
SELECT c.id_contrepartie, c.projet, cn.format_fichier, cn.taille
FROM
    Contrepartie c
    JOIN Contrepartie_numerique cn ON c.id_contrepartie = cn.id_contrepartie;

/* 
-- =====================================================
-- REQUETES STATISQUES 
-- =====================================================
NIVEAU 1 — Agrégation simple sur une table

1.1. Nombre de membres par projet
1.2. Note moyenne d'un projet
1.3. Nombre de contributions par projet
1.4. Nombre de contributions par utilisateur
1.5. Nombre de contreparties par projet

NIVEAU 2 — Agrégation avec jointure simple

2.1. Note moyenne par type de projet
2.2. Nombre de contreparties physiques pour un projet
2.3. Nombre de contreparties numériques pour un projet
2.4. Nombre de contreparties physiques qu'un transporteur a véhiculées
2.5. Contribution moyenne par utilisateur (contrepartie numérique)
2.6. Moyenne des objectifs financiers des projets sociaux par région

NIVEAU 3 — Agrégation avec jointures multiples

3.1. Montant moyen des contributions par projet social par région
3.2. Dans combien de projets un membre a été chef
3.3. Projets ayant déjà atteint leur objectif financier

NIVEAU 4 — Agrégations imbriquées ou corrélées

4.1. Type de projet auquel chaque incubateur a le plus contribué
4.2. Taux de réussite moyen d'un membre en tant que chef (moyenne des moyennes de réussite de ses projets)
4.3. Moyenne des contributions pour un même chef sur ses projets

*/

-- NIVEAU 1 — Agrégation simple sur une table

-- 1.1 Nombre de membres par projet
SELECT Projet, COUNT(membre) AS nb_membres
FROM PorterPar
GROUP BY
    Projet;

-- 1.2 Note moyenne d'un projet
SELECT Projet, AVG(note) AS note_projet FROM Evaluer GROUP BY Projet;

-- 1.3 Nombre de contributions par projet
SELECT Projet, COUNT(utilisateur) AS nb_contributions
    -- SELECT Projet, COUNT(*) AS nb_contributions : COMPTE NULL MAIS REVIENS A PAREIL CAR NON NUL PAR DEFAUT
FROM Contribution
GROUP BY
    Projet;

-- 1.4. Nombre de contributions par utilisateur
SELECT
    u.id_personne AS id_personne,
    u.nom AS nom_utilisateur,
    COUNT(*) AS nb_contributions_utilisateur
FROM Contribution c
    JOIN Utilisateur u ON c.utilisateur = u.id_personne
GROUP BY
    u.id_personne,
    u.nom;

-- 1.5. Nombre de contreparties par projet
SELECT Projet, COUNT(id_contrepartie) AS nb_contreparies
    -- SELECT Projet, COUNT(*) AS nb_contreparies
FROM Contrepartie
GROUP BY
    Projet;

-- NIVEAU 2 — Agrégation avec jointure simple

-- 2.1. Note moyenne par type de projet
SELECT
    'technologique' AS type_projet,
    AVG(e.note) AS note_moyenne
    -- 'AS type_projet' est juste pour donner le nom à la colonne
    -- 'AS note_moyenne' est juste pour donner le nom à la colonne
    --  Donc en sortie on aura deux colonnes, type_projet, note_moyenne
FROM
    Evaluer e
    JOIN Projet_technologique pt ON e.projet = pt.titre
UNION
SELECT 'artistique', AVG(e.note)
FROM
    Evaluer e
    JOIN Projet_artistique pa ON e.projet = pa.titre
UNION
SELECT 'social', AVG(e.note)
FROM Evaluer e
    JOIN Projet_social ps ON e.projet = ps.titre;

-- 2.2. Nombre de contreparties physiques pour un projet
SELECT
    c.projet,
    'Physique' AS type_contrepartie,
    COUNT(c.id_contrepartie) AS nb_contreparties_physiques
FROM
    Contrepartie c
    JOIN Contrepartie_physique cp ON cp.id_contrepartie = c.id_contrepartie
GROUP BY
    c.projet;

-- 2.3. Nombre de contreparties numériques pour un projet
SELECT
    c.projet,
    'Numerique' AS type_contrepartie,
    COUNT(c.id_contrepartie) AS nb_contreparties_numeriques
FROM
    Contrepartie c
    JOIN Contrepartie_numerique cn ON cn.id_contrepartie = c.id_contrepartie
GROUP BY
    c.projet;

-- 2.4. Nombre de contreparties physiques qu'un transporteur a véhiculées
SELECT
    cp.transporteur AS nom_transporteur,
    'Physique' AS type_contrepartie,
    COUNT(cp.id_contrepartie) AS nb_contreparties
FROM
    Contrepartie_physique cp
    JOIN Transporteur t ON t.nom = cp.transporteur
GROUP BY
    cp.transporteur;

-- 2.5. Contribution moyenne par utilisateur
SELECT
    u.id_personne AS id_utilisateur,
    u.nom AS nom_utilisateur,
    AVG(ct.montant) AS contribution_moyenne
FROM
    Contribution ct
    JOIN Utilisateur u ON ct.utilisateur = u.id_personne
GROUP BY
    u.id_personne,
    u.nom;

-- 2.6. Moyenne des objectifs financiers des projets sociaux par région
SELECT
    ps.titre AS nom_projet,
    ps.region_cible AS region,
    AVG(p.objectif_financier) AS objectif_regional
FROM Projet p
    JOIN Projet_social ps ON ps.titre = p.titre
GROUP BY
    ps.titre,
    ps.region_cible;

-- NIVEAU 3 — Agrégation avec jointures multiples

-- 3.1. Montant moyen des contributions par projet social par région
SELECT
    ps.region_cible AS region,
    AVG(ct.montant) AS montant_moyen_contribution
FROM
    Contribution ct
    JOIN Projet_social ps ON ct.projet = ps.titre
GROUP BY
    ps.region_cible;

-- 3.2. Dans combien de projets un membre a été chef
SELECT
    pp.membre AS id_membre,
    me.nom AS nom_membre,
    me.prenom AS prenom_membre,
    COUNT(pp.projet) AS nb_projets_chef
FROM PorterPar pp
    JOIN MembreEquipe me ON me.id_personne = pp.membre
WHERE
    pp.role = 'chef_projet'
GROUP BY
    pp.membre,
    me.nom,
    me.prenom;

-- 3.3. Projets ayant déjà atteint leur objectif financier
SELECT p.titre, p.objectif_financier, SUM(ct.montant) AS total_contributions
FROM Projet p
    JOIN Contribution ct ON ct.projet = p.titre
GROUP BY
    p.titre,
    p.objectif_financier
HAVING
    SUM(ct.montant) >= p.objectif_financier;

-- NIVEAU 4 — Agrégations imbriquées ou corrélées

-- 4.1. Type de projet auquel chaque incubateur a le plus contribué
SELECT incubateur, type_projet
FROM (
        SELECT p.incubateur, 'technologique' AS type_projet, COUNT(*) AS nb
        FROM
            Projet p
            JOIN Projet_technologique pt ON pt.titre = p.titre
        WHERE
            p.incubateur IS NOT NULL
        GROUP BY
            p.incubateur
        UNION ALL
        SELECT p.incubateur, 'artistique', COUNT(*)
        FROM
            Projet p
            JOIN Projet_artistique pa ON pa.titre = p.titre
        WHERE
            p.incubateur IS NOT NULL
        GROUP BY
            p.incubateur
        UNION ALL
        SELECT p.incubateur, 'social', COUNT(*)
        FROM Projet p
            JOIN Projet_social ps ON ps.titre = p.titre
        WHERE
            p.incubateur IS NOT NULL
        GROUP BY
            p.incubateur
    ) AS stats
WHERE
    nb = (
        SELECT MAX(nb2)
        FROM (
                SELECT p2.incubateur, COUNT(*) AS nb2
                FROM
                    Projet p2
                    JOIN Projet_technologique pt2 ON pt2.titre = p2.titre
                WHERE
                    p2.incubateur = stats.incubateur
                GROUP BY
                    p2.incubateur
                UNION ALL
                SELECT p2.incubateur, COUNT(*)
                FROM
                    Projet p2
                    JOIN Projet_artistique pa2 ON pa2.titre = p2.titre
                WHERE
                    p2.incubateur = stats.incubateur
                GROUP BY
                    p2.incubateur
                UNION ALL
                SELECT p2.incubateur, COUNT(*)
                FROM Projet p2
                    JOIN Projet_social ps2 ON ps2.titre = p2.titre
                WHERE
                    p2.incubateur = stats.incubateur
                GROUP BY
                    p2.incubateur
            ) AS sous_stats
    );

-- 4.2. Taux de réussite moyen d'un membre en tant que chef (moyenne des moyennes de réussite de ses projets)
-- Taux de réussite d'un projet = total_contributions / objectif_financier
SELECT
    chef.membre AS id_membre,
    me.nom AS nom_membre,
    me.prenom AS prenom_membre,
    AVG(taux_projet.taux) AS taux_reussite_moyen
FROM
    PorterPar chef
    JOIN MembreEquipe me ON me.id_personne = chef.membre
    JOIN (
        SELECT ct.projet, SUM(ct.montant) / p.objectif_financier AS taux
        FROM Contribution ct
            JOIN Projet p ON p.titre = ct.projet
        GROUP BY
            ct.projet,
            p.objectif_financier
    ) AS taux_projet ON taux_projet.projet = chef.projet
WHERE
    chef.role = 'chef_projet'
GROUP BY
    chef.membre,
    me.nom,
    me.prenom;

-- 4.3. Moyenne des contributions pour un même chef sur ses projets
SELECT
    chef.membre AS id_membre,
    me.nom AS nom_membre,
    me.prenom AS prenom_membre,
    AVG(moy_projet.moy_contributions) AS moyenne_globale
FROM
    PorterPar chef
    JOIN MembreEquipe me ON me.id_personne = chef.membre
    JOIN (
        SELECT ct.projet, AVG(ct.montant) AS moy_contributions
        FROM Contribution ct
        GROUP BY
            ct.projet
    ) AS moy_projet ON moy_projet.projet = chef.projet
WHERE
    chef.role = 'chef_projet'
GROUP BY
    chef.membre,
    me.nom,
    me.prenom;




