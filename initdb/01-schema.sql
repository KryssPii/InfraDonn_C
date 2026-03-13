-- Active: 1772189751523@@127.0.0.1@5432@infradon
-- Table Lieu
CREATE TABLE Lieu (
    id_lieu SERIAL PRIMARY KEY,
    Nom VARCHAR(100) NOT NULL,
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8)
);

-- Table Technicien
CREATE TABLE Technicien (
    id_technicien SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL
);

-- Table Citoyen
CREATE TABLE Citoyen (
    id_citoyen SERIAL PRIMARY KEY,
    nom_signalement VARCHAR(100),
    nom_contact VARCHAR(100)
);

-- Table Fournisseurs
CREATE TABLE Fournisseurs (
    id_fournisseurs SERIAL PRIMARY KEY,
    nom_entreprise VARCHAR(150) NOT NULL,
    contact VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100),
    type_materiel VARCHAR(100),
    remarque TEXT
);

-- Table Interventions
CREATE TABLE Interventions (
    id_interventions SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    objet VARCHAR(200),
    type_intervention VARCHAR(100),
    technicien VARCHAR(100),
    duree INT,
    cout_materiel DECIMAL(10, 2),
    remarque TEXT,
    fk_id_technicien INT,
    FOREIGN KEY (fk_id_technicien) REFERENCES Technicien(id_technicien)
);

-- Table Mobilier
CREATE TABLE Mobilier (
    id_mobilier SERIAL PRIMARY KEY,
    type VARCHAR(100),
    materiau VARCHAR(100),
    etat VARCHAR(50),
    date_installation DATE,
    remarque TEXT,
    fk_id_lieu INT,
    fk_id_intervention INT,
    FOREIGN KEY (fk_id_lieu) REFERENCES Lieu(id_lieu),
    FOREIGN KEY (fk_id_intervention) REFERENCES Interventions(id_interventions)
);

-- Table Signalement
CREATE TABLE Signalement (
    id_signalement SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    signale_par VARCHAR(100),
    objet VARCHAR(200),
    description TEXT,
    urgence VARCHAR(50),
    statut VARCHAR(50),
    fk_id_citoyen INT,
    fk_id_mobilier INT,
    FOREIGN KEY (fk_id_citoyen) REFERENCES Citoyen(id_citoyen),
    FOREIGN KEY (fk_id_mobilier) REFERENCES Mobilier(id_mobilier)
);

-- Table Possession (table de liaison Fournisseurs <-> Mobilier)
CREATE TABLE Possession (
    fk_id_fournisseurs INT NOT NULL,
    fk_id_mobilier INT NOT NULL,
    PRIMARY KEY (fk_id_fournisseurs, fk_id_mobilier),
    FOREIGN KEY (fk_id_fournisseurs) REFERENCES Fournisseurs(id_fournisseurs),
    FOREIGN KEY (fk_id_mobilier) REFERENCES Mobilier(id_mobilier)
);