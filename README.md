# PROJET DE GESTION DES EMPRUNTS CHEZ BIBLIORG
## DESCRIPTION
TP3B en programmation pour base de données

## STRUCTURE DU PROJET
1. 01_SYS_00_users.sql
2. 02_BO_00_drop.sql
3. 02_BO_05_objects.sql
4. 02_BO_15_gestion_emprunts_pkg.pks
5. 02_BO_16_gestion_emprunts_pkg.pkb
6. 02_BO_20_triggers.sql
7. 02_BO_25_data.sql
8. 02_BO_30_securite.sql
9. Transactions.sql
10. Tests_fonctionnels_TP3B.sql

## REPO GITHUB
https://github.com/EvannFMA/A25-17D-TP3B-EvannFofana

 
## TÂCHES
* Création et gestion des curseurs
* Création et gestion des déclencheurs
* Création et gestion des rôles et des privilèges
* Completion du package
* Complétion des tests fonctionnels
* Gestion des transactions

## COMMENTAIRES
- Normalement il devrait y avoir un erreur de suppression d'un membre dans les tests fonctionnels -
- Elle est gardée exprès car c'est marqué de le faire dans l'exercice -
- S'assurer d'être déconnecté quand on lance 01_SYS_00_users.sql -

## INSTRUCTIONS
1.	Cloner le dépôt :
Faire un git clone <https://github.com/EvannFMA/A25-17D-TP3B-EvannFofana.git>
2. Lancer le script 01_SYS avec sys
3. Lancer les scripts 02_BO avec bo (Est créé à l'étape 2)
4. Lancer les tests fonctionnels avec bo (Les tests commencent avec bo pour les archives et ensuite ALTER en employe01 pour ensuite ALTER en bo encore)
