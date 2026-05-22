-- ============================================================
-- VUE 1 : v_lampadaires_detail
-- Fiche technique de chaque lampadaire
-- ============================================================
CREATE OR REPLACE VIEW v_lampadaires_detail AS
SELECT
    m.id_mobilier AS id_lampadaire,
    l.nom AS lieu,
    -- Type sodium ou LED (stocké dans le champ materiau)
    CASE LOWER(TRIM(m.materiau))
        WHEN 'sodium' THEN 'sodium'
        WHEN 'led' THEN 'LED'
        ELSE LOWER(TRIM(m.materiau))
    END AS type_lampe,
    -- Année d'installation
    EXTRACT(
        YEAR
        FROM m.date_installation
    )::INT AS annee_installation,
    -- Nombre de pannes : interventions dont l'objet contient
    -- "lampadaire" ET le nom du lieu (jointure textuelle,
    -- car pas de FK directe intervention → mobilier dans le schéma)
    COUNT(i.id_interventions) AS nb_pannes,
    -- Coût cumulé de toutes les interventions liées
    COALESCE(SUM(i.cout_materiel), 0)::NUMERIC(10, 2) AS cout_cumule,
    -- Date de la dernière intervention
    MAX(i.date) AS derniere_intervention,
    -- Coordonnées GPS (pour cartographie)
    l.latitude,
    l.longitude
FROM
    Mobilier m
    JOIN Lieu l ON m.fk_id_lieu = l.id_lieu
    LEFT JOIN Interventions i ON i.objet ILIKE '%lampadaire%'
    AND i.objet ILIKE '%' || l.nom || '%'
WHERE
    LOWER(TRIM(m.type)) = 'lampadaire'
GROUP BY
    m.id_mobilier,
    l.nom,
    m.materiau,
    m.date_installation,
    l.latitude,
    l.longitude;

-- ============================================================
-- VUE 2 : v_lampadaires_priorite
-- Score = nb_pannes × 3 + âge × 2 + coût_cumulé / 100
-- ============================================================
CREATE OR REPLACE VIEW v_lampadaires_priorite AS
SELECT
    d.*,
    -- Âge en années (référence 2026)
    (2026 - d.annee_installation) AS age_annees,
    -- Score de priorité
    ROUND(
        (d.nb_pannes * 3) + (
            (2026 - d.annee_installation) * 2
        ) + (d.cout_cumule / 100.0),
        2
    ) AS score_priorite
FROM v_lampadaires_detail d
ORDER BY score_priorite DESC;

-- ============================================================
-- VUE 3 : v_lampadaires_budget
-- Sélection dans le budget CHF 50'000.-
-- Coût estimé = moyenne des remplacements complets de lampadaires
-- ============================================================
CREATE OR REPLACE VIEW v_lampadaires_budget AS
WITH
    cout_moyen AS (
        -- Coût moyen d'un remplacement complet de lampadaire
        SELECT ROUND(AVG(i.cout_materiel), 2) AS cout_unitaire
        FROM Interventions i
        WHERE
            LOWER(i.type_intervention) = 'remplacement'
            AND i.objet ILIKE '%lampadaire%'
            AND i.cout_materiel > 0
    ),
    priorite_avec_cout AS (
        SELECT p.*, cm.cout_unitaire
        FROM
            v_lampadaires_priorite p
            CROSS JOIN cout_moyen cm
    ),
    cumul AS (
        SELECT *, SUM(cout_unitaire) OVER (
                ORDER BY score_priorite DESC ROWS BETWEEN UNBOUNDED PRECEDING
                    AND CURRENT ROW
            )::NUMERIC(10, 2) AS cout_cumule_budget
        FROM priorite_avec_cout
    )
SELECT
    id_lampadaire,
    lieu,
    type_lampe,
    annee_installation,
    age_annees,
    nb_pannes,
    cout_cumule,
    derniere_intervention,
    score_priorite,
    cout_unitaire AS cout_remplacement_estime,
    cout_cumule_budget,
    latitude,
    longitude
FROM cumul
WHERE
    cout_cumule_budget <= 50000
ORDER BY score_priorite DESC;