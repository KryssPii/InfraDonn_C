SELECT
 ROUND(REPLACE(latitude, ',', '.')::NUMERIC, 4),
 ROUND(REPLACE(longitude, ',', '.')::NUMERIC, 4),
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
    CASE LOWER(TRIM(etat))
        WHEN 'bon' THEN 'bon'
        WHEN 'usé' THEN 'usé'
        WHEN 'à remplacer' THEN 'usé'
        ELSE NULL
    END
FROM inventaire_mobilier


SELECT 
CASE(TRIM(technicien))
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
SELECT COALESCE(REGEXP_REPLACE(cout_materiel, '[^0-9]+', '', 'g'), '0'),
CASE (TRIM(cout_materiel))
WHEN 'NULL' THEN '0'
END
FROM staging.interventions




SELECT CASE 
WHEN (TRIM(duree)) LIKE '%h%' THEN REPLACE (duree, 'h', '')::NUMERIC * 60
WHEN  (TRIM(duree)) LIKE '%min%' THEN REPLACE (duree, 'min', '')::NUMERIC
ELSE NULL
END
FROM staging.interventions

SELECT CASE 
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