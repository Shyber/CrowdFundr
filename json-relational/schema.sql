-- ============================================================
-- MODELE JSON-RELATIONNEL
-- SGBD cible : PostgreSQL
-- ============================================================

-- Nettoyage optionnel
DROP TABLE IF EXISTS contribution CASCADE;
DROP TABLE IF EXISTS projet CASCADE;
DROP TABLE IF EXISTS utilisateur CASCADE;
DROP TABLE IF EXISTS membre_equipe CASCADE;
DROP TABLE IF EXISTS incubateur CASCADE;
DROP TABLE IF EXISTS ong CASCADE;
DROP TABLE IF EXISTS transporteur CASCADE;

DROP TYPE IF EXISTS type_projet_enum CASCADE;

-- ============================================================
-- TYPES ENUM
-- ============================================================

CREATE TYPE type_projet_enum AS ENUM (
    'technologique',
    'artistique',
    'social'
);

-- ===========================================mongosh --file mongodb/setup.jsmongosh --file mongodb/setup.js=================
-- TABLE UTILISATEUR
-- ============================================================

CREATE TABLE utilisateur (
    pseudo VARCHAR(100) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    date_naissance DATE,
    adresse_mail VARCHAR(255) NOT NULL UNIQUE
);

-- ============================================================
-- TABLE MEMBRE_EQUIPE
-- ============================================================

CREATE TABLE membre_equipe (
    id_membre SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    date_naissance DATE,
    prenom VARCHAR(100) NOT NULL,
    pays_residence VARCHAR(100)
);

-- ============================================================
-- TABLE INCUBATEUR
-- ============================================================

CREATE TABLE incubateur (
    id_incubateur SERIAL PRIMARY KEY,
    nom_incubateur VARCHAR(150) NOT NULL,
    annee_creation DATE,
    budget NUMERIC(15,2)
);

-- ============================================================
-- TABLE ONG
-- ============================================================

CREATE TABLE ong (
    num_ong INT PRIMARY KEY,
    nom_ong VARCHAR(150) NOT NULL,
    pays VARCHAR(100) NOT NULL
);

-- ============================================================
-- TABLE TRANSPORTEUR
-- ============================================================

CREATE TABLE transporteur (
    id_transporteur SERIAL PRIMARY KEY,
    nom_tr VARCHAR(150) NOT NULL,
    delai_livraison INT NOT NULL CHECK (delai_livraison >= 0)
);

-- ============================================================
-- TABLE PROJET
-- ============================================================

CREATE TABLE projet (
    id_projet SERIAL PRIMARY KEY,

    titre VARCHAR(200) NOT NULL,
    description TEXT,
    objectif_financier NUMERIC(15,2) NOT NULL CHECK (objectif_financier > 0),
    date_lancement DATE NOT NULL,

    type_projet type_projet_enum NOT NULL,

    -- Remplace Projet_technologique, Projet_artistique, Projet_social
    details_projet JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Association optionnelle avec Incubateur
    id_incubateur INT NULL,

    -- Remplace Contrepartie, Contrepartie_numerique, Contrepartie_physique
    contreparties JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Remplace PorterPar
    equipe JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Remplace Evaluer
    evaluations JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Remplace l'association Projet_social -- ONG
    soutiens_ong JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT fk_projet_incubateur
        FOREIGN KEY (id_incubateur)
        REFERENCES incubateur(id_incubateur)
        ON DELETE SET NULL,

    CONSTRAINT chk_details_projet_json_object
        CHECK (jsonb_typeof(details_projet) = 'object'),

    CONSTRAINT chk_contreparties_json_array
        CHECK (jsonb_typeof(contreparties) = 'array'),

    CONSTRAINT chk_equipe_json_array
        CHECK (jsonb_typeof(equipe) = 'array'),

    CONSTRAINT chk_evaluations_json_array
        CHECK (jsonb_typeof(evaluations) = 'array'),

    CONSTRAINT chk_soutiens_ong_json_array
        CHECK (jsonb_typeof(soutiens_ong) = 'array'),

    -- Si le projet est social, il doit avoir au moins une ONG de soutien
    CONSTRAINT chk_projet_social_soutiens_ong
        CHECK (
            type_projet <> 'social'
            OR jsonb_array_length(soutiens_ong) >= 1
        )
);

-- ============================================================
-- TABLE CONTRIBUTION
-- ============================================================

CREATE TABLE contribution (
    id_contribution SERIAL PRIMARY KEY,

    pseudo VARCHAR(100) NOT NULL,
    id_projet INT NOT NULL,

    date_heure TIMESTAMP NOT NULL,
    montant NUMERIC(15,2) NOT NULL CHECK (montant > 0),

    -- Contrepartie choisie par l'utilisateur
    contrepartie_choisie JSONB NULL,

    CONSTRAINT fk_contribution_utilisateur
        FOREIGN KEY (pseudo)
        REFERENCES utilisateur(pseudo)
        ON DELETE CASCADE,

    CONSTRAINT fk_contribution_projet
        FOREIGN KEY (id_projet)
        REFERENCES projet(id_projet)
        ON DELETE CASCADE,

    CONSTRAINT chk_contrepartie_choisie_json_object
        CHECK (
            contrepartie_choisie IS NULL
            OR jsonb_typeof(contrepartie_choisie) = 'object'
        )
);