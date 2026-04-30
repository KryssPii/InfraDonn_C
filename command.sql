--Tableau Inventaire mobilier
SELECT
    ROUND(
        REPLACE(latitude, ',', '.')::NUMERIC,
        4
    ),
    ROUND(
        REPLACE(longitude, ',', '.')::NUMERIC,
        4
    ),
    CASE LOWER(TRIM(type))
        WHEN 'banc' THEN 'banc'
        WHEN 'banc public' THEN 'banc'
        WHEN 'lampadaire' THEN 'lampadaire'
        WHEN 'lampadaire led' THEN 'lampadaire'
        WHEN 'lampadaire LED' THEN 'lampadaire'
        WHEN 'poubelle' THEN 'poubelle'
        WHEN 'poubelle tri' THEN 'poubelle'
        WHEN 'corbeille' THEN 'poubelle'
        WHEN 'lampadaire sodium' THEN 'lampadaire'
        WHEN 'fontaine' THEN 'fontaine'
        WHEN 'fontaine publique' THEN 'fontaine'
        WHEN 'borne EV' THEN 'borne'
        WHEN 'Borne recharge' THEN 'borne'
        WHEN 'borne recharge EV' THEN 'borne'
        WHEN 'Panneau' THEN 'panneau'
        WHEN 'panneau info' THEN 'panneau'
        WHEN 'panneau affichage' THEN 'panneau'
        ELSE NULL
    END,
    CASE
        WHEN date_installation LIKE '%.%.%' THEN TO_DATE(
            date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation LIKE '____-__-__' THEN TO_DATE(
            date_installation,
            'YYYY-MM-DD'
        )
        ELSE NULL
    END,
    CASE LOWER(TRIM(etat))
        WHEN 'à remplacer' THEN 'usé'
        WHEN 'use' THEN 'usé'
        WHEN 'usé' THEN 'usé'
        WHEN 'bon' THEN 'bon'
        ELSE NULL
    END
FROM inventaire_mobilier
    --Tableau des lieu

ALTER TABLE Lieu ADD CONSTRAINT unique_nom UNIQUE (Nom);

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
    ('HEIG-VD', 46.78, 6.66),
    (
        'Place de la Gare',
        46.78106843,
        6.64157228
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
    ('Rue Haldimand', 46.78, 6.65),
    (
        'Rue de la Maison Rouge',
        46.78,
        6.64
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
    ('Parc des Rives', 46.78, 6.64),
    (
        'Avenue des Bains',
        46.78308929,
        6.635762336
    ),
    (
        'Plage d''Yverdon',
        46.78470569,
        6.63408617
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
    ),
    (
        'Rue de la Maison Rouge',
        46.77841271,
        6.640736301
    )
ON CONFLICT (Nom) DO NOTHING;

--Tableau Interventions
-- Requête 1 : interventions
SELECT
    CASE TRIM(technicien)
        WHEN 'Alves Pedro' THEN 'Alves Pedro'
        WHEN 'Pedro' THEN 'Alves Pedro'
        WHEN 'P. Alves' THEN 'Alves Pedro'
        WHEN 'Jean-Marc Bonvin' THEN 'Jean-Marc Bonvin'
        WHEN 'Jean-Marc' THEN 'Jean-Marc Bonvin'
        WHEN 'JM' THEN 'Jean-Marc Bonvin'
        WHEN 'stagiaire' THEN 'stagiaire'
        ELSE NULL
    END AS technicien,
    CASE
        WHEN date LIKE '%.%.%' THEN TO_DATE(date, 'DD.MM.YYYY')
        ELSE date::DATE
    END AS date,
    COALESCE(
        NULLIF(
            REGEXP_REPLACE(
                cout_materiel,
                '[^0-9]+',
                '',
                'g'
            ),
            ''
        ),
        '0'
    )::NUMERIC AS cout_materiel
FROM staging.interventions;

-- Requête 2 : signalements
SELECT
    CASE
        WHEN LOWER(TRIM(signale_par)) LIKE '%email%' THEN 'email'
        WHEN LOWER(TRIM(signale_par)) LIKE '%concierge%' THEN 'concierge'
        WHEN LOWER(TRIM(signale_par)) LIKE '%habitant%' THEN 'habitant'
        WHEN LOWER(TRIM(signale_par)) LIKE '%passant%' THEN 'passant'
        WHEN LOWER(TRIM(signale_par)) LIKE '%patrouille%' THEN 'patrouille'
        WHEN LOWER(TRIM(signale_par)) LIKE '%weber%' THEN 'Weber'
        WHEN LOWER(TRIM(signale_par)) LIKE '%rochat%' THEN 'Rochat'
        WHEN LOWER(TRIM(signale_par)) LIKE '%pereira%' THEN 'Pereira'
        WHEN LOWER(TRIM(signale_par)) LIKE '%dupont%' THEN 'Dupont'
        ELSE NULL
    END AS signale_par
FROM staging.signalements;

-- Requête 3 : mobilier
SELECT
    ROUND(
        REPLACE(latitude, ',', '.')::NUMERIC,
        4
    ) AS latitude,
    ROUND(
        REPLACE(longitude, ',', '.')::NUMERIC,
        4
    ) AS longitude,
    CASE LOWER(TRIM(type))
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
        WHEN 'borne recharge' THEN 'borne'
        WHEN 'borne recharge ev' THEN 'borne'
        WHEN 'panneau' THEN 'panneau'
        WHEN 'panneau info' THEN 'panneau'
        WHEN 'panneau affichage' THEN 'panneau'
        ELSE NULL
    END AS type,
    CASE LOWER(TRIM(etat))
        WHEN 'bon' THEN 'bon'
        WHEN 'usé' THEN 'usé'
        WHEN 'à remplacer' THEN 'usé'
        ELSE NULL
    END AS etat
FROM staging.inventaire_mobilier;

--Mettre les techniciens dans le tableau
INSERT INTO
    Technicien (nom, prenom)
VALUES ('Bonvin', 'Jean-Marc'),
    ('Alves', 'Pedro'),
    ('Koffi', 'Marc'),
    ('Stagiaire', '');

SELECT
    CASE (TRIM(technicien))
        WHEN 'Alves Pedro' THEN 'Alves Pedro'
        WHEN 'Pedro' THEN 'Alves Pedro'
        WHEN 'P. Alves' THEN 'Alves Pedro'
        WHEN 'Jean-Marc Bonvin' THEN 'Jean-Marc Bonvin'
        WHEN 'Jean-Marc' THEN 'Jean-Marc Bonvin'
        WHEN 'JM' THEN 'Jean-Marc Bonvin'
        WHEN 'stagiaire' THEN 'stagiaire'
        ELSE NULL
    END,

-- Supprimer tout sauf les chiffres, puis caster
SELECT
    COALESCE(
        REGEXP_REPLACE(
            cout_materiel,
            '[^0-9]+',
            '',
            'g'
        ),
        '0'
    ),
    CASE (TRIM(cout_materiel))
        WHEN 'NULL' THEN '0'
    END
FROM staging.interventions

SELECT
    CASE
        WHEN (TRIM(duree)) LIKE '%h%' THEN REPLACE(duree, 'h', '')::NUMERIC * 60
        WHEN (TRIM(duree)) LIKE '%min%' THEN REPLACE(duree, 'min', '')::NUMERIC
        ELSE NULL
    END
FROM staging.interventions

SELECT
    CASE
        WHEN (TRIM(type_intervention)) LIKE '%remplacement%' THEN 'remplacement'
        WHEN (TRIM(type_intervention)) LIKE '%réparation%' THEN 'reparation'
        WHEN (TRIM(type_intervention)) LIKE '%Réparation%' THEN 'reparation'
        WHEN (TRIM(type_intervention)) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN (TRIM(type_intervention)) LIKE '%peinture%' THEN 'peinture'
        WHEN (TRIM(type_intervention)) LIKE '%remise en service%' THEN 'remise en service'
        WHEN (TRIM(type_intervention)) LIKE '%hivernage%' THEN 'hivernage'
        WHEN (TRIM(type_intervention)) LIKE '%redressage%' THEN 'redressage'
        WHEN (TRIM(type_intervention)) LIKE '%mise à jour%' THEN 'mise à jour'
        WHEN (TRIM(type_intervention)) LIKE '%détartrage%' THEN 'detartrage'
        ELSE NULL
    END
FROM staging.interventions

SELECT
    CASE
        WHEN LOWER(TRIM(telephone)) LIKE '+41%' THEN REPLACE(telephone, '+41 ', '0')
        ELSE telephone
    END
FROM fournisseurs_contacts

SELECT
    CASE
        WHEN (TRIM(email)) LIKE '%@%' THEN (TRIM(email))
        ELSE NULL
    END
FROM fournisseurs_contacts

INSERT INTO
    mobilier (type)
SELECT DISTINCT
    CASE
        WHEN (TRIM(type_materiel)) LIKE '%banc%' THEN 'banc'
        WHEN (TRIM(type_materiel)) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN (TRIM(type_materiel)) LIKE '%poubelle%' THEN 'poubelle'
        WHEN (TRIM(type_materiel)) LIKE '%fontaine%' THEN 'fontaine'
        WHEN (TRIM(type_materiel)) LIKE '%borne%' THEN 'borne'
        WHEN (TRIM(type_materiel)) LIKE '%panneau%' THEN 'panneau'
        ELSE NULL
    END
FROM fournisseurs
WHERE
    type_materiel IS NOT NULL;