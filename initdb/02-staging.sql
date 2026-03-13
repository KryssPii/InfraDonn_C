-- initdb/02-staging.sql

CREATE SCHEMA IF NOT EXISTS staging;

-- Exemple pour inventaire_mobilier — reproduire pour les 3 autres tables
CREATE TABLE staging.inventaire_mobilier (
    id TEXT, type TEXT, materiau TEXT, lieu TEXT,
    latitude TEXT, longitude TEXT,
    date_installation TEXT, etat TEXT, remarques TEXT
);
CREATE TABLE staging.interventions (
    id TEXT, type TEXT, date TEXT, type_intervention TEXT,
    technicien TEXT, duree TEXT,
    cout_materiel TEXT, remarques TEXT
);
CREATE TABLE staging.signalements (
    id TEXT, type TEXT, statut TEXT, urgence TEXT,
    date_installation TEXT, etat TEXT, remarques TEXT,
    date TEXT, objet TEXT, description TEXT
);
CREATE TABLE staging.fournisseurs_contacts (
    id TEXT, type TEXT, materiau TEXT, lieu TEXT,
    latitude TEXT, longitude TEXT,
    date_installation TEXT, etat TEXT, remarques TEXT
);
-- ... (signalements, interventions, fournisseurs)

-- Import CSV — data/ est monté sous /data/ dans le conteneur
COPY staging.inventaire_mobilier
FROM '/data/inventaire_mobilier.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- ... (répéter pour les 3 autres fichiers)
COPY staging.interventions
FROM '/data/interventions'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY staging.signalements
FROM '/data/signalements.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY staging.fournisseurs_contacts
FROM '/data/fournisseurs_contacts.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');