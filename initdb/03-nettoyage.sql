-- ============================================================
-- 1. TABLE : technicien
-- ============================================================

TRUNCATE TABLE technicien RESTART IDENTITY CASCADE;

INSERT INTO
    technicien (nom, prenom)
VALUES ('Bonvin', 'Jean-Marc'),
    ('Alves', 'Pedro'),
    ('Koffi', 'Marc'),
    ('Stagiaire', '')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. TABLE : lieu
-- ============================================================

ALTER TABLE lieu
ADD CONSTRAINT IF NOT EXISTS unique_nom UNIQUE (nom);

INSERT INTO
    lieu (nom, latitude, longitude)
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
ON CONFLICT (nom) DO NOTHING;

-- ============================================================
-- 3. TABLE : inventaire_mobilier
-- ============================================================
-- FIX : les deux CASE (type et date_installation) étaient fusionnés
--       en un seul bloc malformé dans l'original.

INSERT INTO
    inventaire_mobilier (
        latitude,
        longitude,
        type,
        etat,
        date_installation
    )
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
    END,
    CASE LOWER(TRIM(etat))
        WHEN 'bon' THEN 'bon'
        WHEN 'usé' THEN 'usé'
        WHEN 'use' THEN 'usé'
        WHEN 'à remplacer' THEN 'usé'
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
    END
FROM staging.inventaire_mobilier;

-- ============================================================
-- 4. TABLE : interventions
-- ============================================================
-- FIX 1 : CASE manquant sur cout_materiel
-- FIX 2 : fk_id_technicien résolu via LEFT JOIN (pas depuis staging)

INSERT INTO
    interventions (
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
    CASE
        WHEN s.date LIKE '%.%.%' THEN TO_DATE(s.date, 'DD.MM.YYYY')
        ELSE s.date::DATE
    END,
    TRIM(s.objet),
    CASE
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%réparation%' THEN 'reparation'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%redressage%' THEN 'redressage'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%mise à jour%' THEN 'mise à jour'
        WHEN LOWER(TRIM(s.type_intervention)) LIKE '%détartrage%' THEN 'detartrage'
        ELSE NULL
    END,
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
        ELSE NULL
    END,
    CASE
        WHEN TRIM(s.duree) LIKE '%h%' THEN REPLACE(
            REPLACE(s.duree, 'h', ''),
            ' ',
            ''
        )::NUMERIC * 60
        WHEN TRIM(s.duree) LIKE '%min%' THEN REPLACE(
            REPLACE(s.duree, 'min', ''),
            ' ',
            ''
        )::NUMERIC
        ELSE NULL
    END,

-- FIX : mot-clé CASE manquant dans l'original
CASE
    WHEN LOWER(TRIM(s.cout_materiel)) IN ('null', '')
    OR s.cout_materiel IS NULL THEN 0
    ELSE NULLIF(
        REGEXP_REPLACE(
            s.cout_materiel,
            '[^0-9.]+',
            '',
            'g'
        ),
        ''
    )::NUMERIC
END,
TRIM(s.remarque),

-- FIX : résolution de l'id via JOIN au lieu de lire depuis staging
t.id_technicien
FROM
    staging.interventions s
    LEFT JOIN technicien t ON CONCAT(t.nom, ' ', t.prenom) = CASE TRIM(s.technicien)
        WHEN 'Alves Pedro' THEN 'Alves Pedro'
        WHEN 'Pedro' THEN 'Alves Pedro'
        WHEN 'P. Alves' THEN 'Alves Pedro'
        WHEN 'Jean-Marc Bonvin' THEN 'Bonvin Jean-Marc'
        WHEN 'Jean-Marc' THEN 'Bonvin Jean-Marc'
        WHEN 'JM' THEN 'Bonvin Jean-Marc'
        WHEN 'Koffi Marc' THEN 'Koffi Marc'
        WHEN 'Marc' THEN 'Koffi Marc'
        WHEN 'stagiaire' THEN 'Stagiaire '
        ELSE NULL
    END;

-- ============================================================
-- 5. TABLE : signalements
-- ============================================================

INSERT INTO
    signalements (signale_par)
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
    END
FROM staging.signalements;

-- ============================================================
-- 6. TABLE : mobilier (types distincts depuis fournisseurs)
-- ============================================================

INSERT INTO
    mobilier (type)
SELECT DISTINCT
    CASE
        WHEN TRIM(type_materiel) LIKE '%banc%' THEN 'banc'
        WHEN TRIM(type_materiel) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN TRIM(type_materiel) LIKE '%poubelle%' THEN 'poubelle'
        WHEN TRIM(type_materiel) LIKE '%fontaine%' THEN 'fontaine'
        WHEN TRIM(type_materiel) LIKE '%borne%' THEN 'borne'
        WHEN TRIM(type_materiel) LIKE '%panneau%' THEN 'panneau'
        ELSE NULL
    END
FROM fournisseurs
WHERE
    type_materiel IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================================
-- 7. TABLE : fournisseurs_contacts
-- ============================================================
-- FIX : deux WHEN identiques (+41%) dans l'original — un seul suffit

INSERT INTO
    fournisseurs_contacts (telephone, email)
SELECT
    CASE
        WHEN TRIM(telephone) LIKE '+41%' THEN REGEXP_REPLACE(telephone, '^\+41\s*', '0')
        ELSE TRIM(telephone)
    END,
    CASE
        WHEN TRIM(email) LIKE '%@%' THEN TRIM(email)
        ELSE NULL
    END
FROM staging.fournisseurs_contacts;