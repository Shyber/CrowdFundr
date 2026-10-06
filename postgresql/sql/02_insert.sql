-- =====================================================
-- MembreEquipe (15 lignes)
-- =====================================================
INSERT INTO MembreEquipe (id_personne, nom, prenom, pays_residence, date_naissance) VALUES
(1,  'Kojima',      'Hideo',     'Japon',         '1963-08-24'),
(2,  'Shinkawa',    'Yoji',      'Japon',         '1971-01-19'),
(3,  'Miyamoto',    'Shigeru',   'Japon',         '1952-11-16'),
(4,  'Aonuma',      'Eiji',      'Japon',         '1963-01-01'),
(5,  'Ueda',        'Fumito',    'Japon',         '1970-03-15'),
(6,  'Ancel',       'Michel',    'France',        '1972-09-17'),
(7,  'Cage',        'David',     'France',        '1969-06-09'),
(8,  'Levine',      'Ken',       'États-Unis',    '1966-07-04'),
(9,  'Blow',        'Jonathan',  'États-Unis',    '1971-01-23'),
(10, 'Schafer',     'Tim',       'États-Unis',    '1967-07-26'),
(11, 'Okamoto',     'Yoshiki',   'Japon',         '1960-05-12'),
(12, 'Inaba',       'Atsushi',   'Japon',         '1966-02-28'),
(13, 'Horii',       'Yuji',      'Japon',         '1957-01-06'),
(14, 'Toriyama',    'Motomu',    'Japon',         '1972-09-09'),
(15, 'Tabata',      'Hajime',    'Japon',         '1974-12-17');
 
 
-- =====================================================
-- Utilisateur (15 lignes)
-- =====================================================
INSERT INTO Utilisateur (id_personne, pseudo, adresse_mail, nom, date_naissance) VALUES
(16, 'alice_w',     'alice@mail.com',     'Walters',   '1990-03-10'),
(17, 'bob_m',       'bob@mail.com',       'Martin',    '1985-07-22'),
(18, 'carla_d',     'carla@mail.com',     'Dupont',    '1992-11-05'),
(19, 'david_r',     'david@mail.com',     'Roux',      '1988-01-30'),
(20, 'emma_l',      'emma@mail.com',      'Laurent',   '1995-06-14'),
(21, 'felix_g',     'felix@mail.com',     'Garcia',    '1991-09-02'),
(22, 'gina_b',      'gina@mail.com',      'Bernard',   '1987-04-18'),
(23, 'hugo_n',      'hugo@mail.com',      'Nguyen',    '1993-12-25'),
(24, 'iris_k',      'iris@mail.com',      'Klein',     '1996-08-07'),
(25, 'julien_p',    'julien@mail.com',    'Petit',     '1989-02-20'),
(26, 'karine_v',    'karine@mail.com',    'Valois',    '1994-05-11'),
(27, 'leo_f',       'leo@mail.com',       'Fontaine',  '1990-10-30'),
(28, 'maya_s',      'maya@mail.com',      'Simon',     '1986-03-03'),
(29, 'noel_c',      'noel@mail.com',      'Colin',     '1997-07-07'),
(30, 'olivia_t',    'olivia@mail.com',    'Thomas',    '1991-12-01');
 
 
-- =====================================================
-- Incubateur (15 lignes)
-- =====================================================
INSERT INTO Incubateur (nom_incubateur, annee_creation, budget) VALUES
('Station F',             2017, 250000000.00),
('Y Combinator',          2005, 500000000.00),
('Techstars',             2006, 100000000.00),
('Startup Studio Paris',  2013,  15000000.00),
('Le Camping',            2011,   8000000.00),
('NUMA Paris',            2000,  12000000.00),
('Schoolab',              2014,   9000000.00),
('50 Partners',           2012,   7500000.00),
('Euratechnologies',      2009,  20000000.00),
('BPI Inno Lab',          2015,  30000000.00),
('Village by CA',         2014,  18000000.00),
('HEC Incubateur',        2000,  11000000.00),
('Impulse Partners',      2013,   6000000.00),
('TheFamily',             2013,  25000000.00),
('Agoranov',              2000,  10000000.00);
 
 
-- =====================================================
-- Transporteur (15 lignes)
-- =====================================================
INSERT INTO Transporteur (nom, delai_livraison) VALUES
('Chronopost',    2),
('Colissimo',     5),
('DHL',           3),
('UPS',           4),
('FedEx',         3),
('TNT',           4),
('GLS',           6),
('Mondial Relay', 7),
('DPD',           4),
('Colis Privé',   6),
('Amazon Logistics', 2),
('BRT',           5),
('Hermes',        5),
('SEUR',          4),
('InPost',        3);
 
 
-- =====================================================
-- ONG (15 lignes)
-- =====================================================
INSERT INTO ONG (num_ong, nom_ong, pays) VALUES
(1,  'Amnesty International',   'Royaume-Uni'),
(2,  'Médecins Sans Frontières','France'),
(3,  'Greenpeace',              'Pays-Bas'),
(4,  'Oxfam',                   'Royaume-Uni'),
(5,  'UNICEF',                  'États-Unis'),
(6,  'WWF',                     'Suisse'),
(7,  'La Croix-Rouge',          'Suisse'),
(8,  'Care International',      'États-Unis'),
(9,  'Action Contre la Faim',   'France'),
(10, 'Handicap International',  'Belgique'),
(11, 'Plan International',      'Royaume-Uni'),
(12, 'Save the Children',       'Royaume-Uni'),
(13, 'Transparency International','Allemagne'),
(14, 'Human Rights Watch',      'États-Unis'),
(15, 'Islamic Relief',          'Royaume-Uni');
 
 
-- =====================================================
-- Projet (15 lignes)
-- Projets artistiques (titres utilisés pour Q1) : 'Silent Canvas', 'Phantom Brushwork'
-- Projet 'Silent Canvas' et 'Phantom Brushwork' seront portés par Kojima & Shinkawa
-- Projets sociaux soutenus par Amnesty International (Q2) : 'Voix Libres', 'Droit Debout'
-- Projets avec incubateur (Q3) : plusieurs
-- =====================================================
INSERT INTO Projet (titre, description, objectif_financier, date_lancement, incubateur) VALUES
-- Artistiques
('Silent Canvas',       'Art numérique inspiré de Metal Gear',          5000.00,   '2024-01-10', 'Station F'),
('Phantom Brushwork',   'Exposition illustrée entre deux mondes',        8000.00,   '2024-02-14', 'Station F'),
('Melodies of Time',    'Album indépendant de musique orchestrale',      12000.00,  '2024-03-01', 'Le Camping'),
-- Technologiques
('NeuroCraft',          'IA générative pour le jeu vidéo indépendant',  50000.00,  '2024-01-15', 'Y Combinator'),
('EcoTrack',            'Application de suivi de l''empreinte carbone',  30000.00,  '2024-02-20', 'Techstars'),
('MedConnect',          'Plateforme de télémédecine rurale',             75000.00,  '2024-03-10', 'Station F'),
('BlockAid',            'Aide humanitaire via blockchain',               40000.00,  '2024-04-01', 'TheFamily'),
-- Sociaux
('Voix Libres',         'Soutien aux journalistes emprisonnés',          20000.00,  '2024-01-20', 'NUMA Paris'),
('Droit Debout',        'Accès au droit pour les sans-abri',             15000.00,  '2024-02-10', 'HEC Incubateur'),
('Eau Pour Tous',       'Forages en zones rurales africaines',           60000.00,  '2024-03-05', NULL),
('École Nomade',        'Éducation pour enfants migrants',               35000.00,  '2024-04-15', NULL),
('Résilience Urbaine',  'Jardins partagés en quartiers défavorisés',     18000.00,  '2024-05-01', 'Euratechnologies'),
-- Projets supplémentaires artistiques et technologiques
('Pixel Dreams',        'Jeu vidéo 2D narratif',                         7000.00,  '2024-02-01', '50 Partners'),
('DataViz Art',         'Visualisation artistique de données ouvertes',  9000.00,  '2024-03-20', 'BPI Inno Lab'),
('Heritage 3D',         'Numérisation de patrimoine culturel',           25000.00, '2024-04-10', 'Schoolab');
 
 
-- =====================================================
-- Projet_artistique (5 lignes)
-- =====================================================
INSERT INTO Projet_artistique (titre, medium) VALUES
('Silent Canvas',       'Peinture numérique'),
('Phantom Brushwork',   'Illustration traditionnelle'),
('Melodies of Time',    'Musique orchestrale'),
('Pixel Dreams',        'Jeu vidéo 2D'),
('DataViz Art',         'Installation numérique');

-- =====================================================
-- Désactiver le trigger pour respecter l'ordre d'insertion
-- =====================================================
ALTER TABLE Contrepartie DISABLE TRIGGER trg_check_cont_type;

-- =====================================================
-- Projet_technologique (5 lignes pour compléter les 15 de Projet)
-- =====================================================
INSERT INTO Projet_technologique (titre, type_innovation) VALUES
('NeuroCraft',      'Intelligence artificielle'),
('EcoTrack',        'Application mobile'),
('MedConnect',      'Télémédecine'),
('BlockAid',        'Blockchain'),
('Heritage 3D',     'Numérisation 3D');
 
-- =====================================================
-- Projet_social (5 lignes)
-- =====================================================
INSERT INTO Projet_social (titre, region_cible) VALUES
('Voix Libres',       'International'),
('Droit Debout',      'France'),
('Eau Pour Tous',     'Afrique subsaharienne'),
('École Nomade',      'Europe'),
('Résilience Urbaine','France');
 
 
-- =====================================================
-- Contrepartie (15 lignes)
-- =====================================================
INSERT INTO Contrepartie (id_contrepartie, projet) VALUES
(1,  'Silent Canvas'),
(2,  'Silent Canvas'),
(3,  'Phantom Brushwork'),
(4,  'Phantom Brushwork'),
(5,  'NeuroCraft'),
(6,  'NeuroCraft'),
(7,  'EcoTrack'),
(8,  'MedConnect'),
(9,  'Voix Libres'),
(10, 'Voix Libres'),
(11, 'Droit Debout'),
(12, 'Droit Debout'),
(13, 'Heritage 3D'),
(14, 'Pixel Dreams'),
(15, 'Melodies of Time');
 
 
-- =====================================================
-- Contrepartie_numerique (8 lignes)
-- =====================================================
INSERT INTO Contrepartie_numerique (id_contrepartie, format_fichier, taille) VALUES
(1,  'PNG',  25.50),
(3,  'PDF',  10.00),
(5,  'ZIP',  500.00),
(7,  'APK',  80.00),
(9,  'PDF',  5.00),
(11, 'PDF',  3.50),
(14, 'EXE',  200.00),
(15, 'MP3',  120.00);
 
 
-- =====================================================
-- Contrepartie_physique (7 lignes)
-- Plusieurs via Chronopost pour Q3
-- =====================================================
INSERT INTO Contrepartie_physique (id_contrepartie, poids, frais_livraison, transporteur) VALUES
(2,  0.50,  5.90,  'Chronopost'),   -- Silent Canvas
(4,  1.20,  7.50,  'Chronopost'),   -- Phantom Brushwork
(6,  2.00,  9.00,  'Colissimo'),    -- NeuroCraft
(8,  0.30,  4.50,  'Chronopost'),   -- MedConnect
(10, 0.80,  6.00,  'DHL'),          -- Voix Libres
(12, 0.60,  5.50,  'Chronopost'),   -- Droit Debout
(13, 3.50,  12.00, 'Chronopost');   -- Heritage 3D

-- =====================================================
-- Réactiver le trigger après insertion des données
-- =====================================================
ALTER TABLE Contrepartie ENABLE TRIGGER trg_check_cont_type;

 
-- =====================================================
-- Contribution (15 lignes)
-- Objectifs : Silent Canvas=5000, Phantom Brushwork=8000
-- Q1 : somme contributions > objectif pour ces deux projets
-- Q2 : contributions > 50€ sur Voix Libres et Droit Debout
-- Q3 : contributions avec contrepartie physique Chronopost
-- =====================================================
INSERT INTO Contribution (date_heure, utilisateur, projet, montant, contrepartie) VALUES
-- Silent Canvas : total = 6500 > 5000 ✓
('2024-02-01 10:00:00', 16, 'Silent Canvas',     3000.00, 2),   -- alice, physique Chronopost
('2024-02-02 11:00:00', 17, 'Silent Canvas',     2000.00, 1),   -- bob, numérique
('2024-02-03 12:00:00', 18, 'Silent Canvas',     1500.00, 2),   -- carla, physique Chronopost
 
-- Phantom Brushwork : total = 9500 > 8000 ✓
('2024-03-01 09:00:00', 16, 'Phantom Brushwork', 4000.00, 4),   -- alice, physique Chronopost
('2024-03-02 10:00:00', 19, 'Phantom Brushwork', 3000.00, 3),   -- david, numérique
('2024-03-03 11:00:00', 20, 'Phantom Brushwork', 2500.00, 4),   -- emma, physique Chronopost
 
-- Voix Libres (soutenu par Amnesty International)
('2024-02-15 08:00:00', 21, 'Voix Libres',        80.00, 9),    -- felix > 50 ✓
('2024-02-16 09:00:00', 22, 'Voix Libres',       120.00, 10),   -- gina > 50 ✓
('2024-02-17 10:00:00', 23, 'Voix Libres',        30.00, 9),    -- hugo < 50 ✗
 
-- Droit Debout (soutenu par Amnesty International)
('2024-03-10 14:00:00', 21, 'Droit Debout',      200.00, 12),   -- felix > 50 ✓ physique Chronopost
('2024-03-11 15:00:00', 24, 'Droit Debout',       60.00, 11),   -- iris > 50 ✓
('2024-03-12 16:00:00', 25, 'Droit Debout',       20.00, 11),   -- julien < 50 ✗
 
-- Heritage 3D (incubateur = Schoolab, contrepartie physique Chronopost)
('2024-04-20 10:00:00', 26, 'Heritage 3D',       100.00, 13),   -- karine, physique Chronopost
('2024-04-21 11:00:00', 27, 'Heritage 3D',       150.00, 13),   -- leo, physique Chronopost
 
-- MedConnect (incubateur = Station F, contrepartie physique Chronopost)
('2024-03-20 13:00:00', 28, 'MedConnect',         75.00, 8);    -- maya, physique Chronopost
 
 
-- =====================================================
-- SoutenuPar (projets sociaux soutenus par ONG)
-- Amnesty International (num_ONG=1) soutient Voix Libres et Droit Debout
-- =====================================================
INSERT INTO SoutenuPar (ong, projet) VALUES
(1,  'Voix Libres'),          -- Amnesty International
(1,  'Droit Debout'),         -- Amnesty International
(2,  'Eau Pour Tous'),        -- MSF
(3,  'Résilience Urbaine'),   -- Greenpeace
(4,  'École Nomade'),         -- Oxfam
(5,  'Eau Pour Tous'),        -- UNICEF (doublon intentionnel ONG différente)
(6,  'Résilience Urbaine'),
(7,  'Voix Libres'),
(8,  'École Nomade'),
(9,  'Droit Debout'),
(10, 'Eau Pour Tous'),
(11, 'École Nomade'),
(12, 'Voix Libres'),
(13, 'Droit Debout'),
(14, 'Voix Libres');
 
 
-- =====================================================
-- PorterPar (membres portant des projets)
-- Kojima (1) ET Shinkawa (2) portent TOUS LES DEUX :
--   'Silent Canvas' et 'Phantom Brushwork' (projets artistiques, Q1)
-- =====================================================
INSERT INTO PorterPar (membre, projet, role) VALUES
(1,  'Silent Canvas',       'chef_projet'),     -- Kojima
(2,  'Silent Canvas',       'designer'),        -- Shinkawa
(1,  'Phantom Brushwork',   'chef_projet'),     -- Kojima
(2,  'Phantom Brushwork',   'designer'),        -- Shinkawa
(1,  'Pixel Dreams',        'chef_projet'),     -- Kojima seul (contrôle Q1)
(2,  'DataViz Art',         'designer'),        -- Shinkawa seul (contrôle Q1)
(3,  'NeuroCraft',          'chef_projet'),
(4,  'EcoTrack',            'developpeur'),
(5,  'Heritage 3D',         'chef_projet'),
(6,  'Melodies of Time',    'community_manager'),
(7,  'MedConnect',          'chef_projet'),
(8,  'BlockAid',            'developpeur'),
(9,  'Résilience Urbaine',  'community_manager'),
(10, 'École Nomade',        'chef_projet'),
(11, 'Voix Libres',         'community_manager');
 
 
-- =====================================================
-- Evaluer (15 lignes)
-- Rappel : un utilisateur ne peut évaluer que s'il a contribué
-- Q2 : notes sur Voix Libres et Droit Debout, filtrées sur contribution > 50€
-- =====================================================
INSERT INTO Evaluer (projet, utilisateur, note, avis_text, date_avis) VALUES
-- Silent Canvas
('Silent Canvas',       16, 5, 'Œuvre bouleversante, visuellement époustouflante.',  '2024-02-10'),
('Silent Canvas',       17, 4, 'Très beau travail, quelques détails à peaufiner.',   '2024-02-11'),
('Silent Canvas',       18, 5, 'Un chef-d''œuvre du numérique.',                     '2024-02-12'),
 
-- Phantom Brushwork
('Phantom Brushwork',   16, 5, 'Illustration d''une sensibilité rare.',              '2024-03-10'),
('Phantom Brushwork',   19, 4, 'Magnifique exposition, très immersive.',             '2024-03-11'),
('Phantom Brushwork',   20, 3, 'Beau mais manque un peu de cohérence narrative.',    '2024-03-12'),
 
-- Voix Libres (Q2 : felix note=4, gina note=5 → contrib>50 ; hugo note=2 → contrib<50 exclu)
('Voix Libres',         21, 4, 'Initiative indispensable pour la liberté de presse.','2024-02-25'),
('Voix Libres',         22, 5, 'Projet vital, je soutiens à 100%.',                  '2024-02-26'),
('Voix Libres',         23, 2, 'Bien mais communication perfectible.',               '2024-02-27'),
 
-- Droit Debout (Q2 : felix note=5, iris note=4 → contrib>50 ; julien note=3 → exclu)
('Droit Debout',        21, 5, 'Accès au droit pour tous, enfin !',                  '2024-03-20'),
('Droit Debout',        24, 4, 'Très beau projet, bien organisé.',                   '2024-03-21'),
('Droit Debout',        25, 3, 'Bonne idée mais exécution à améliorer.',             '2024-03-22'),
 
-- Heritage 3D
('Heritage 3D',         26, 5, 'Numérisation de haute qualité, bravo.',              '2024-05-01'),
('Heritage 3D',         27, 4, 'Excellent travail de préservation culturelle.',      '2024-05-02'),
 
-- MedConnect
('MedConnect',          28, 5, 'Application révolutionnaire pour les zones rurales.','2024-04-05');
 
 
-- =====================================================
-- FIN DES INSERTS
-- =====================================================
 
 