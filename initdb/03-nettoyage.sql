-- ============================================================
-- 0. REMISE À ZÉRO (dans l'ordre inverse des FK)
-- ============================================================

TRUNCATE TABLE Possession RESTART IDENTITY CASCADE;

TRUNCATE TABLE Signalement RESTART IDENTITY CASCADE;

TRUNCATE TABLE Mobilier RESTART IDENTITY CASCADE;

TRUNCATE TABLE Interventions RESTART IDENTITY CASCADE;

TRUNCATE TABLE Citoyen RESTART IDENTITY CASCADE;

TRUNCATE TABLE Fournisseurs RESTART IDENTITY CASCADE;

TRUNCATE TABLE Technicien RESTART IDENTITY CASCADE;

TRUNCATE TABLE Lieu RESTART IDENTITY CASCADE;

-- ============================================================
-- 1. TABLE : Technicien (valeurs fixes, pas depuis staging)
-- ============================================================

INSERT INTO
    Technicien (nom, prenom)
VALUES ('Bonvin', 'Jean-Marc'),
    ('Alves', 'Pedro'),
    ('Koffi', 'Marc'),
    ('Stagiaire', '')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. TABLE : Lieu  (référentiel fixe tiré de l'inventaire)
-- ============================================================

ALTER TABLE Lieu
ADD CONSTRAINT IF NOT EXISTS unique_nom UNIQUE (Nom);

INSERT INTO
    Lieu (Nom, Latitude, Longitude)
VALUES (
        'Avenue de la Gare',
        46.78047778,
        6.641623979
    ),
    (
        'Rue du Lac',
        46.77932212,
        6.637371232
    ),
    (
        'Rue du Casino',
        46.77885475,
        6.639355991
    ),
    (
        'HEIG-VD',
        46.78000000,
        6.660000000
    ),
    (
        'Place de la Gare',
        46.78106843,
        6.641572280
    ),
    (
        'Place Pestalozzi',
        46.77850749,
        6.640148663
    ),
    (
        'Rue du Milieu',
        46.77893365,
        6.639979194
    ),
    (
        'Y-Parc',
        46.76481563,
        6.628153421
    ),
    (
        'Chemin de Maillefer',
        46.78101226,
        6.655518258
    ),
    (
        'Rue Haldimand',
        46.78000000,
        6.650000000
    ),
    (
        'Rue de la Maison Rouge',
        46.78000000,
        6.640000000
    ),
    (
        'Route de Lausanne',
        46.76574288,
        6.641578676
    ),
    (
        'Centre sportif',
        46.76747554,
        6.637246191
    ),
    (
        'Quai de Nogent',
        46.78490298,
        6.635316069
    ),
    (
        'Parc des Rives',
        46.78000000,
        6.640000000
    ),
    (
        'Avenue des Bains',
        46.78308929,
        6.635762336
    ),
    (
        'Plage d''Yverdon',
        46.78470569,
        6.634086170
    ),
    (
        'Avenue des Sports',
        46.77877368,
        6.651261212
    ),
    (
        'Rue de la Plaine',
        46.77985343,
        6.642843841
    ),
    (
        'Rue des Pêcheurs',
        46.76845721,
        6.635170659
    ),
    (
        'Passage de l''Hôtel de Ville',
        46.78085084,
        6.640507645
    )
ON CONFLICT (Nom) DO NOTHING;

-- ============================================================
-- 3. TABLE : Fournisseurs  (depuis staging.fournisseurs_contacts)
-- ============================================================

INSERT INTO
    Fournisseurs (
        nom_entreprise,
        contact,
        telephone,
        email,
        type_materiel,
        remarque
    )
SELECT
    NULLIF(TRIM(entreprise), '') AS nom_entreprise,
    NULLIF(TRIM(contact), '') AS contact,
    CASE
        WHEN TRIM(telephone) LIKE '+41%' THEN REGEXP_REPLACE(telephone, '^\+41\s*', '0')
        ELSE NULLIF(TRIM(telephone), '')
    END AS telephone,
    CASE
        WHEN TRIM(email) LIKE '%@%' THEN TRIM(email)
        ELSE NULL
    END AS email,
    NULLIF(TRIM(type_materiel), '') AS type_materiel,
    NULLIF(TRIM(remarques), '') AS remarque
FROM staging.fournisseurs_contacts
WHERE
    NULLIF(TRIM(entreprise), '') IS NOT NULL;
-- exclut les lignes sans nom

-- ============================================================
-- 4. TABLE : Mobilier  (depuis staging.inventaire_mobilier)
-- ============================================================

INSERT INTO
    Mobilier (
        type,
        materiau,
        etat,
        date_installation,
        remarque,
        fk_id_lieu,
        fk_id_intervention
    )
SELECT
    -- Type normalisé
    CASE LOWER(TRIM(s.type))
        WHEN 'banc' THEN 'banc'
        WHEN 'banc public' THEN 'banc'
        WHEN 'lampadaire' THEN 'lampadaire'
        WHEN 'lampadaire led' THEN 'lampadaire'
        WHEN 'lampadaire sodium' THEN 'lampadaire'
        WHEN 'poubelle' THEN 'poubelle'
        WHEN 'poubelle tri' THEN 'poubelle'
        WHEN 'corbeille' THEN 'poubelle'
        WHEN 'fontaine' THEN 'fontaine'
        WHEN 'fontaine publique' THEN 'fontaine'
        WHEN 'borne ev' THEN 'borne'
        WHEN 'borne e.v.' THEN 'borne'
        WHEN 'borne recharge' THEN 'borne'
        WHEN 'borne recharge ev' THEN 'borne'
        WHEN 'borne recharge e.v.' THEN 'borne'
        WHEN 'panneau' THEN 'panneau'
        WHEN 'panneau info' THEN 'panneau'
        WHEN 'panneau affichage' THEN 'panneau'
        ELSE NULL
    END AS type,
    -- Matériau unifié
    CASE LOWER(TRIM(s.materiau))
        WHEN 'bois' THEN 'bois'
        WHEN 'métal' THEN 'metal'
        WHEN 'metal' THEN 'metal'
        ELSE NULLIF(LOWER(TRIM(s.materiau)), '')
    END AS materiau,
    -- État normalisé ('inconnu' si vide)
    CASE LOWER(TRIM(s.etat))
        WHEN 'bon' THEN 'bon'
        WHEN 'usé' THEN 'usé'
        WHEN 'use' THEN 'usé'
        WHEN 'à remplacer' THEN 'usé'
        ELSE 'inconnu'
    END AS etat,
    -- Date d'installation : DD.MM.YYYY ou YYYY-MM-DD uniquement
    CASE
        WHEN s.date_installation LIKE '%.%.%' THEN TO_DATE(
            s.date_installation,
            'DD.MM.YYYY'
        )
        WHEN s.date_installation LIKE '____-__-__' THEN TO_DATE(
            s.date_installation,
            'YYYY-MM-DD'
        )
        ELSE NULL -- années seules ('2020') ou mois texte → NULL
    END AS date_installation,
    -- Remarque ('inconnu' si vide)
    COALESCE(
        NULLIF(TRIM(s.remarques), ''),
        'inconnu'
    ) AS remarque,
    -- Lien vers Lieu via le nom
    l.id_lieu AS fk_id_lieu,
    -- Pas de lien direct avec une intervention pour l'instant
    NULL AS fk_id_intervention
FROM staging.inventaire_mobilier s
    LEFT JOIN Lieu l ON TRIM(s.lieu) = l.Nom;

-- ============================================================
-- 5. TABLE : Interventions  (depuis staging.interventions)
-- ============================================================
INSERT INTO
    Interventions (
        date,
        objet,
        type_intervention,
        technicien,
        duree,
        cout_materiel,
        remarque,
        fk_id_technicien
    )
SELECT
    -- Date : DD.MM.YYYY ou YYYY-MM-DD
    CASE
        WHEN s.date LIKE '%.%.%' THEN TO_DATE(s.date, 'DD.MM.YYYY')
        ELSE s.date::DATE
    END AS date,
    -- Objet (texte brut nettoyé)
    TRIM(s.objet) AS objet,
    -- Type d'intervention normalisé
    CASE
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%réparation%' THEN 'reparation'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%reparation%' THEN 'reparation'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%redressage%' THEN 'redressage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%mise à jour%' THEN 'mise à jour'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%détartrage%' THEN 'detartrage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%detartrage%' THEN 'detartrage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%réparation fuite%' THEN 'reparation'
        ELSE NULL
    END AS type_intervention,
    -- Technicien : nom affiché normalisé
    CASE TRIM(s.technicien)
        WHEN 'Alves Pedro' THEN 'Alves Pedro'
        WHEN 'Pedro' THEN 'Alves Pedro'
        WHEN 'P. Alves' THEN 'Alves Pedro'
        WHEN 'Jean-Marc Bonvin' THEN 'Jean-Marc Bonvin'
        WHEN 'Jean-Marc' THEN 'Jean-Marc Bonvin'
        WHEN 'JM' THEN 'Jean-Marc Bonvin'
        WHEN 'Koffi Marc' THEN 'Koffi Marc'
        WHEN 'Marc' THEN 'Koffi Marc'
        WHEN 'stagiaire' THEN 'Stagiaire'
        WHEN 'Stagiaire' THEN 'Stagiaire'
        ELSE NULL
    END AS technicien,
    -- Durée convertie en minutes (INTEGER)
    -- Cas traités : '2h', '1h30', '30 min', '3h'
    -- Cas ignorés : 'une matinée', 'une journée' → NULL
    CASE
        WHEN TRIM(s.duree) ~ '^\d+h\d+$' THEN (
            SPLIT_PART(TRIM(s.duree), 'h', 1)::INT * 60 + SPLIT_PART(TRIM(s.duree), 'h', 2)::INT
        )
        WHEN TRIM(s.duree) ~ '^\d+h$' THEN REPLACE(TRIM(s.duree), 'h', '')::INT * 60
        WHEN TRIM(s.duree) ~ '^\d+\s*min$' THEN REGEXP_REPLACE(
            TRIM(s.duree),
            '[^0-9]',
            '',
            'g'
        )::INT
        ELSE NULL
    END AS duree,
    -- Coût matériel : extraction numérique, 0 si vide/garantie
    CASE
        WHEN s.cout_materiel IS NULL
        OR LOWER(TRIM(s.cout_materiel)) IN ('null', '', 'garantie') THEN 0
        ELSE NULLIF(
            REGEXP_REPLACE(
                s.cout_materiel,
                '[^0-9.]',
                '',
                'g'
            ),
            ''
        )::NUMERIC
    END AS cout_materiel,
    -- Remarque (colonne s'appelle 'remarques' dans staging)
    NULLIF(TRIM(s.remarques), '') AS remarque,
    -- Clé étrangère : résolution via JOIN sur Technicien
    t.id_technicien
FROM
    staging.interventions s
    LEFT JOIN Technicien t ON CONCAT(t.nom, ' ', t.prenom) = CASE TRIM(s.technicien)
        WHEN 'Alves Pedro' THEN 'Alves Pedro'
        WHEN 'Pedro' THEN 'Alves Pedro'
        WHEN 'P. Alves' THEN 'Alves Pedro'
        WHEN 'Jean-Marc Bonvin' THEN 'Bonvin Jean-Marc'
        WHEN 'Jean-Marc' THEN 'Bonvin Jean-Marc'
        WHEN 'JM' THEN 'Bonvin Jean-Marc'
        WHEN 'Koffi Marc' THEN 'Koffi Marc'
        WHEN 'Marc' THEN 'Koffi Marc'
        WHEN 'stagiaire' THEN 'Stagiaire '
        WHEN 'Stagiaire' THEN 'Stagiaire '
        ELSE NULL
    END;

-- ============================================================
-- 6. TABLE : Citoyen  (référentiel déduit de staging.signalements)
-- ============================================================

INSERT INTO
    Citoyen (nom_signalement, nom_contact)
SELECT DISTINCT
    -- Catégorie générique du déclarant
    CASE
        WHEN LOWER(TRIM(signale_par)) LIKE '%email%' THEN 'email'
        WHEN LOWER(TRIM(signale_par)) LIKE '%concierge%' THEN 'concierge'
        WHEN LOWER(TRIM(signale_par)) LIKE '%habitant%' THEN 'habitant'
        WHEN LOWER(TRIM(signale_par)) LIKE '%passant%' THEN 'passant'
        WHEN LOWER(TRIM(signale_par)) LIKE '%patrouille%' THEN 'patrouille'
        ELSE 'autre'
    END AS nom_signalement,
    -- Nom exact du déclarant conservé tel quel
    NULLIF(TRIM(signale_par), '') AS nom_contact
FROM staging.signalements
WHERE
    NULLIF(TRIM(signale_par), '') IS NOT NULL;

-- ============================================================
-- 7. TABLE : Signalement  (depuis staging.signalements)
-- ============================================================

INSERT INTO
    Signalement (
        date,
        signale_par,
        objet,
        description,
        urgence,
        statut,
        fk_id_citoyen,
        fk_id_mobilier
    )
SELECT
    -- Date : DD.MM.YYYY ou YYYY-MM-DD
    CASE
        WHEN s.date LIKE '%.%.%' THEN TO_DATE(s.date, 'DD.MM.YYYY')
        WHEN s.date LIKE '____-__-__' THEN TO_DATE(s.date, 'YYYY-MM-DD')
        ELSE NULL
    END AS date,
    -- Déclarant (texte brut nettoyé)
    NULLIF(TRIM(s.signale_par), '') AS signale_par,
    -- Objet tel quel (texte libre)
    TRIM(s.objet) AS objet,
    -- Description
    NULLIF(TRIM(s.description), '') AS description,
    -- Urgence normalisée
    CASE LOWER(TRIM(s.urgence))
        WHEN 'urgent' THEN 'urgent'
        WHEN 'normal' THEN 'normal'
        ELSE 'non renseigné'
    END AS urgence,
    -- Statut normalisé
    CASE LOWER(TRIM(s.statut))
        WHEN 'fait' THEN 'fait'
        WHEN 'en attente' THEN 'en attente'
        WHEN 'en cours' THEN 'en cours'
        ELSE 'non renseigné'
    END AS statut,
    -- Clé étrangère vers Citoyen
    c.id_citoyen AS fk_id_citoyen,
    -- Pas de lien mobilier pour l'instant
    NULL AS fk_id_mobilier
FROM staging.signalements s
    LEFT JOIN Citoyen c ON NULLIF(TRIM(s.signale_par), '') = c.nom_contact
    -- On n'insère que les lignes dont la date peut être parsée (évite NOT NULL violation)
WHERE (
        (
            s.date LIKE '%.%.%'
            AND LENGTH(TRIM(s.date)) = 10
        )
        OR (
            s.date LIKE '____-__-__'
            AND LENGTH(TRIM(s.date)) = 10
        )
    );