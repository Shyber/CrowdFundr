-- =========================================
-- 01_create.sql
-- CrowdFundr - PostgreSQL
-- =========================================

DROP TABLE IF EXISTS Evaluer CASCADE;

DROP TABLE IF EXISTS Contribution CASCADE;

DROP TABLE IF EXISTS PorterPar CASCADE;

DROP TABLE IF EXISTS SoutenuPar CASCADE;

DROP TABLE IF EXISTS Projet_social CASCADE;

DROP TABLE IF EXISTS Projet_artistique CASCADE;

DROP TABLE IF EXISTS Projet_technologique CASCADE;

DROP TABLE IF EXISTS Contrepartie_physique CASCADE;

DROP TABLE IF EXISTS Contrepartie_numerique CASCADE;

DROP TABLE IF EXISTS Contrepartie CASCADE;

DROP TABLE IF EXISTS Utilisateur CASCADE;

DROP TABLE IF EXISTS MembreEquipe CASCADE;

DROP TABLE IF EXISTS Projet CASCADE;

DROP TABLE IF EXISTS Incubateur CASCADE;

DROP TABLE IF EXISTS Transporteur CASCADE;

DROP TABLE IF EXISTS ONG CASCADE;

DROP TYPE IF EXISTS role_membre CASCADE;

CREATE TYPE role_membre AS ENUM (
    'chef_projet',
    'developpeur',
    'designer',
    'community_manager'
);

CREATE TABLE Incubateur (
    nom_incubateur VARCHAR(100) PRIMARY KEY,
    annee_creation INTEGER NOT NULL,
    budget NUMERIC(12, 2) NOT NULL CHECK (budget > 0)
);

CREATE TABLE Transporteur (
    nom VARCHAR(100) PRIMARY KEY,
    delai_livraison INTEGER NOT NULL CHECK (delai_livraison > 0)
);

CREATE TABLE ONG (
    num_ong SERIAL PRIMARY KEY,
    nom_ong VARCHAR(100) NOT NULL,
    pays VARCHAR(100) NOT NULL
);

CREATE TABLE Projet (
    titre VARCHAR(150) PRIMARY KEY,
    description TEXT NOT NULL,
    objectif_financier NUMERIC(12, 2) NOT NULL CHECK (objectif_financier > 0),
    date_lancement DATE NOT NULL,
    incubateur VARCHAR(100),
    FOREIGN KEY (incubateur) REFERENCES Incubateur (nom_incubateur)
);

CREATE TABLE MembreEquipe (
    id_personne SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    pays_residence VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL
);

CREATE TABLE Utilisateur (
    id_personne SERIAL PRIMARY KEY,
    pseudo VARCHAR(100) UNIQUE NOT NULL,
    adresse_mail VARCHAR(150) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL
);

CREATE TABLE Contrepartie (
    id_contrepartie SERIAL PRIMARY KEY,
    projet VARCHAR(150) NOT NULL,
    FOREIGN KEY (projet) REFERENCES Projet (titre)
);

CREATE TABLE Projet_technologique (
    titre VARCHAR(150) PRIMARY KEY,
    type_innovation VARCHAR(100) NOT NULL,
    FOREIGN KEY (titre) REFERENCES Projet (titre)
);

CREATE TABLE Projet_artistique (
    titre VARCHAR(150) PRIMARY KEY,
    medium VARCHAR(100) NOT NULL,
    FOREIGN KEY (titre) REFERENCES Projet (titre)
);

CREATE TABLE Projet_social (
    titre VARCHAR(150) PRIMARY KEY,
    region_cible VARCHAR(100) NOT NULL,
    FOREIGN KEY (titre) REFERENCES Projet (titre)
);

CREATE TABLE Contrepartie_numerique (
    id_contrepartie INTEGER PRIMARY KEY,
    format_fichier VARCHAR(50) NOT NULL,
    taille NUMERIC(8, 2) NOT NULL CHECK (taille >= 0),
    FOREIGN KEY (id_contrepartie) REFERENCES Contrepartie (id_contrepartie)
);

CREATE TABLE Contrepartie_physique (
    id_contrepartie INTEGER PRIMARY KEY,
    poids NUMERIC(8, 2) NOT NULL CHECK (poids > 0),
    frais_livraison NUMERIC(8, 2) NOT NULL CHECK (frais_livraison >= 0),
    transporteur VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_contrepartie) REFERENCES Contrepartie (id_contrepartie),
    FOREIGN KEY (transporteur) REFERENCES Transporteur (nom)
);

CREATE TABLE SoutenuPar (
    ong INTEGER,
    projet VARCHAR(150),
    PRIMARY KEY (ong, projet),
    FOREIGN KEY (ong) REFERENCES ONG (num_ong),
    FOREIGN KEY (projet) REFERENCES Projet_social (titre)
);

CREATE TABLE PorterPar (
    membre INTEGER,
    projet VARCHAR(150),
    role role_membre NOT NULL,
    PRIMARY KEY (membre, projet),
    FOREIGN KEY (membre) REFERENCES MembreEquipe (id_personne),
    FOREIGN KEY (projet) REFERENCES Projet (titre)
);

CREATE TABLE Contribution (
    date_heure TIMESTAMP,
    utilisateur INTEGER,
    projet VARCHAR(150),
    montant NUMERIC(10, 2) NOT NULL CHECK (montant > 0),
    contrepartie INTEGER,
    PRIMARY KEY (
        date_heure,
        utilisateur,
        projet
    ),
    FOREIGN KEY (utilisateur) REFERENCES Utilisateur (id_personne),
    FOREIGN KEY (projet) REFERENCES Projet (titre),
    FOREIGN KEY (contrepartie) REFERENCES Contrepartie (id_contrepartie)
);

CREATE TABLE Evaluer (
    projet VARCHAR(150),
    utilisateur INTEGER,
    note INTEGER NOT NULL CHECK (note BETWEEN 1 AND 5),
    avis_text TEXT,
    date_avis DATE NOT NULL,
    PRIMARY KEY (projet, utilisateur),
    FOREIGN KEY (projet) REFERENCES Projet (titre),
    FOREIGN KEY (utilisateur) REFERENCES Utilisateur (id_personne)
);

-- =====================================================
-- TRIGGER : Evaluation seulement après contribution
-- Π(projet, utilisateur)(Evaluer) ⊆ Π(projet, utilisateur)(Contribution)
-- =====================================================

CREATE OR REPLACE FUNCTION check_evaluer_contribution()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Contribution c
        WHERE c.projet = NEW.projet
          AND c.utilisateur = NEW.utilisateur
    ) THEN
        RAISE EXCEPTION
        'Un utilisateur doit contribuer avant d''évaluer un projet';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_evaluer_contribution
BEFORE INSERT OR UPDATE ON Evaluer
FOR EACH ROW
EXECUTE FUNCTION check_evaluer_contribution();

-- =====================================================
-- TRIGGER : Exclusivité héritage Projet
-- Un projet doit appartenir à une seule sous-table
-- =====================================================

CREATE OR REPLACE FUNCTION check_projet_exclusif()
RETURNS TRIGGER AS $$
DECLARE
    nb INT;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Projet_technologique WHERE titre = NEW.titre) +
        (SELECT COUNT(*) FROM Projet_artistique WHERE titre = NEW.titre) +
        (SELECT COUNT(*) FROM Projet_social WHERE titre = NEW.titre)
    INTO nb;

    IF nb > 1 THEN
        RAISE EXCEPTION
        'Un projet ne peut appartenir qu''à une seule sous-classe';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_projet_tech
AFTER INSERT OR UPDATE ON Projet_technologique
FOR EACH ROW
EXECUTE FUNCTION check_projet_exclusif();

CREATE TRIGGER trg_check_projet_art
AFTER INSERT OR UPDATE ON Projet_artistique
FOR EACH ROW
EXECUTE FUNCTION check_projet_exclusif();

CREATE TRIGGER trg_check_projet_soc
AFTER INSERT OR UPDATE ON Projet_social
FOR EACH ROW
EXECUTE FUNCTION check_projet_exclusif();

-- =====================================================
-- TRIGGER : Exclusivité héritage Contrepartie
-- =====================================================

CREATE OR REPLACE FUNCTION check_contrepartie_exclusive()
RETURNS TRIGGER AS $$
DECLARE
    nb INT;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Contrepartie_numerique WHERE id_contrepartie = NEW.id_contrepartie) +
        (SELECT COUNT(*) FROM Contrepartie_physique WHERE id_contrepartie = NEW.id_contrepartie)
    INTO nb;

    IF nb > 1 THEN
        RAISE EXCEPTION
        'Une contrepartie ne peut appartenir qu''à une seule sous-classe';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_cont_num
AFTER INSERT OR UPDATE ON Contrepartie_numerique
FOR EACH ROW
EXECUTE FUNCTION check_contrepartie_exclusive();

CREATE TRIGGER trg_check_cont_phy
AFTER INSERT OR UPDATE ON Contrepartie_physique
FOR EACH ROW
EXECUTE FUNCTION check_contrepartie_exclusive();

-- =====================================================
-- TRIGGER : Garantir que Contrepartie est numérique OU physique
-- =====================================================

CREATE OR REPLACE FUNCTION check_contrepartie_has_type()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Contrepartie_numerique WHERE id_contrepartie = NEW.id_contrepartie
        UNION
        SELECT 1 FROM Contrepartie_physique WHERE id_contrepartie = NEW.id_contrepartie
    ) THEN
        RAISE EXCEPTION 'Une contrepartie doit être numérique ou physique';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_cont_type
AFTER INSERT OR UPDATE ON Contrepartie
FOR EACH ROW
EXECUTE FUNCTION check_contrepartie_has_type();

-- =====================================================
-- TRIGGER : Interdiction intersection Utilisateur / MembreEquipe
-- =====================================================

CREATE OR REPLACE FUNCTION check_personne_exclusive_utilisateur()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM MembreEquipe
        WHERE id_personne = NEW.id_personne
    ) THEN
        RAISE EXCEPTION
        'Une personne ne peut être à la fois Utilisateur et MembreEquipe';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_utilisateur
BEFORE INSERT OR UPDATE ON Utilisateur
FOR EACH ROW
EXECUTE FUNCTION check_personne_exclusive_utilisateur();

CREATE OR REPLACE FUNCTION check_personne_exclusive_membre()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Utilisateur
        WHERE id_personne = NEW.id_personne
    ) THEN
        RAISE EXCEPTION
        'Une personne ne peut être à la fois Utilisateur et MembreEquipe';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_membre
BEFORE INSERT OR UPDATE ON MembreEquipe
FOR EACH ROW
EXECUTE FUNCTION check_personne_exclusive_membre();