-- =========================================
-- 04_update.sql
-- =========================================


-- =====================================================
-- Incubateur
-- =====================================================
UPDATE Incubateur SET budget = 270000000.00 WHERE nom_incubateur = 'Station F';
UPDATE Incubateur SET annee_creation = 2004 WHERE nom_incubateur = 'Y Combinator';


-- =====================================================
-- Transporteur
-- =====================================================
UPDATE Transporteur SET delai_livraison = 1 WHERE nom = 'Chronopost';
UPDATE Transporteur SET delai_livraison = 2 WHERE nom = 'DHL';


-- =====================================================
-- ONG
-- =====================================================
UPDATE ONG SET pays = 'Belgique' WHERE nom_ong = 'Amnesty International';
UPDATE ONG SET nom_ong = 'MSF - Médecins Sans Frontières' WHERE num_ong = 2;


-- =====================================================
-- MembreEquipe
-- =====================================================
UPDATE MembreEquipe SET pays_residence = 'États-Unis' WHERE id_personne = 6;  -- Ancel
UPDATE MembreEquipe SET pays_residence = 'Japon'      WHERE id_personne = 8;  -- Levine


-- =====================================================
-- Utilisateur
-- =====================================================
UPDATE Utilisateur SET adresse_mail = 'alice.walters@mail.com' WHERE id_personne = 16;
UPDATE Utilisateur SET pseudo       = 'bob_martin'             WHERE id_personne = 17;


-- =====================================================
-- Projet
-- =====================================================
UPDATE Projet SET objectif_financier = 6000.00  WHERE titre = 'Silent Canvas';
UPDATE Projet SET objectif_financier = 10000.00 WHERE titre = 'Phantom Brushwork';
UPDATE Projet SET incubateur = 'NUMA Paris'     WHERE titre = 'Eau Pour Tous';
UPDATE Projet SET description = 'IA générative pour le jeu vidéo indépendant — v2'
    WHERE titre = 'NeuroCraft';


-- =====================================================
-- Projet_artistique
-- =====================================================
UPDATE Projet_artistique SET medium = 'Peinture numérique & aquarelle' WHERE titre = 'Silent Canvas';
UPDATE Projet_artistique SET medium = 'Musique orchestrale & électronique' WHERE titre = 'Melodies of Time';


-- =====================================================
-- Projet_technologique
-- =====================================================
UPDATE Projet_technologique SET type_innovation = 'IA générative'   WHERE titre = 'NeuroCraft';
UPDATE Projet_technologique SET type_innovation = 'Santé numérique' WHERE titre = 'MedConnect';


-- =====================================================
-- Projet_social
-- =====================================================
UPDATE Projet_social SET region_cible = 'Afrique & Asie du Sud' WHERE titre = 'Eau Pour Tous';
UPDATE Projet_social SET region_cible = 'France & Belgique'     WHERE titre = 'Droit Debout';


-- =====================================================
-- Contrepartie_numerique
-- =====================================================
UPDATE Contrepartie_numerique SET format_fichier = 'WEBP', taille = 30.00 WHERE id_contrepartie = 1;
UPDATE Contrepartie_numerique SET taille = 550.00                          WHERE id_contrepartie = 5;


-- =====================================================
-- Contrepartie_physique
-- =====================================================
UPDATE Contrepartie_physique SET frais_livraison = 4.90 WHERE id_contrepartie = 2;
UPDATE Contrepartie_physique SET poids = 1.50, frais_livraison = 8.00 WHERE id_contrepartie = 4;


-- =====================================================
-- Contribution
-- =====================================================
UPDATE Contribution
    SET montant = 3500.00
    WHERE utilisateur = 16 AND projet = 'Silent Canvas';

UPDATE Contribution
    SET montant = 90.00
    WHERE utilisateur = 21 AND projet = 'Voix Libres';


-- =====================================================
-- Evaluer
-- =====================================================
UPDATE Evaluer
    SET note = 4, avis_text = 'Très beau, une légère baisse suite aux retouches.'
    WHERE projet = 'Silent Canvas' AND utilisateur = 16;

UPDATE Evaluer
    SET note = 5, avis_text = 'Projet encore plus convaincant après la mise à jour.'
    WHERE projet = 'MedConnect' AND utilisateur = 28;


-- =====================================================
-- PorterPar
-- =====================================================
UPDATE PorterPar SET role = 'developpeur'
    WHERE membre = 4 AND projet = 'EcoTrack';

UPDATE PorterPar SET role = 'chef_projet'
    WHERE membre = 10 AND projet = 'École Nomade';

-- =====================================================
-- FIN DES UPDATES
-- =====================================================
