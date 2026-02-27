# Brief C — Plan de remplacement des lampadaires

## Contexte

La Commune dispose d'un crédit de CHF 50'000.- pour remplacer des lampadaires en 2026. Le responsable des infrastructures vous demande de prioriser les remplacements.

## Demande


### Livrable 3 — Sélection dans le budget

Produire une vue SQL qui sélectionne les lampadaires à remplacer par ordre de priorité, en s'arrêtant quand le coût cumulé estimé de remplacement dépasse CHF 50'000.-. Utiliser le coût moyen d'une intervention de type "remplacement complet" comme estimation du coût de remplacement.

Inclure les coordonnées GPS pour cartographie.

## Format de rendu

- 3 vues SQL nommées `v_lampadaires_detail`, `v_lampadaires_priorite`, `v_lampadaires_budget`
- Un court paragraphe (5-10 lignes) justifiant le classement
