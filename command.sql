SELECT
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
END

FROM interventions