-- =========================================
-- 05_delete.sql
-- Suppression sélective d'enregistrements basée sur les insertions
-- =========================================

-- Supprimer les utilisateurs avec ID 20, 22, 25, 28 (certains utilisateurs spécifiques)
DELETE FROM Evaluer WHERE utilisateur IN (20, 22, 25, 28);

DELETE FROM Contribution WHERE utilisateur IN (20, 22, 25, 28);

DELETE FROM Utilisateur WHERE id_personne IN (20, 22, 25, 28);

-- Supprimer certains membres d'équipe (ID 5, 8, 10)
DELETE FROM PorterPar WHERE membre IN (5, 8, 10);

DELETE FROM MembreEquipe WHERE id_personne IN (5, 8, 10);

-- Supprimer les contraintes d'évaluation et contributions liées aux projets spécifiques
DELETE FROM Evaluer
WHERE
    projet IN (
        'Pixel Dreams',
        'Heritage 3D',
        'EcoTrack'
    );

DELETE FROM Contribution
WHERE
    projet IN (
        'Pixel Dreams',
        'Heritage 3D',
        'EcoTrack'
    );

-- Supprimer les contraintes PorterPar pour certains projets
DELETE FROM PorterPar
WHERE
    projet IN (
        'Pixel Dreams',
        'Heritage 3D',
        'EcoTrack'
    );

-- Supprimer les contreparties liées aux projets supprimés
-- (d'abord les sous-classes, puis la classe mère)
DELETE FROM Contrepartie_numerique
WHERE id_contrepartie IN (
    SELECT id_contrepartie FROM Contrepartie
    WHERE projet IN ('Pixel Dreams', 'Heritage 3D', 'EcoTrack')
);

DELETE FROM Contrepartie_physique
WHERE id_contrepartie IN (
    SELECT id_contrepartie FROM Contrepartie
    WHERE projet IN ('Pixel Dreams', 'Heritage 3D', 'EcoTrack')
);

DELETE FROM Contrepartie
WHERE projet IN ('Pixel Dreams', 'Heritage 3D', 'EcoTrack');

-- Supprimer les projets spécialisés correspondants
DELETE FROM Projet_artistique WHERE titre IN ('Pixel Dreams');

DELETE FROM Projet_technologique
WHERE
    titre IN ('Heritage 3D', 'EcoTrack');

-- Supprimer les projets eux-mêmes
DELETE FROM Projet
WHERE
    titre IN (
        'Pixel Dreams',
        'Heritage 3D',
        'EcoTrack'
    );

-- Supprimer certains transporteurs (Hermes, SEUR)
-- Les contributions gardent leur montant ; la contrepartie choisie est optionnelle -> NULL
UPDATE Contribution SET contrepartie = NULL
WHERE contrepartie IN (
    SELECT id_contrepartie FROM Contrepartie_physique
    WHERE transporteur IN ('Hermes', 'SEUR')
);

DELETE FROM Contrepartie_physique WHERE transporteur IN ('Hermes', 'SEUR');

-- Supprimer les contreparties devenues orphelines (sans sous-classe)
DELETE FROM Contrepartie c
WHERE NOT EXISTS (SELECT 1 FROM Contrepartie_numerique n WHERE n.id_contrepartie = c.id_contrepartie)
  AND NOT EXISTS (SELECT 1 FROM Contrepartie_physique  f WHERE f.id_contrepartie = c.id_contrepartie);

DELETE FROM Transporteur WHERE nom IN ('Hermes', 'SEUR');

-- Supprimer un incubateur : l'incubateur d'un projet est optionnel,
-- on détache donc d'abord les projets accompagnés au lieu de les supprimer.
UPDATE Projet SET incubateur = NULL WHERE incubateur = '50 Partners';

DELETE FROM Incubateur WHERE nom_incubateur = '50 Partners';
