-- 02_BO_15_gestion_emprunts_pkg.pks

CREATE OR REPLACE PACKAGE BO.gestion_emprunts_pkg AUTHID current_user AS
    TYPE t_info_livre IS RECORD (
        id      livres.id%TYPE,
        titre   livres.titre%TYPE,
        isbn    livres.isbn%TYPE,
        auteur  auteurs.nom_auteur%TYPE,
        editeur livres.maison_edition%TYPE,
        annee   livres.annee_publication%TYPE,
        langue  livres.langage%TYPE,
        section sections.nom%TYPE,
        genre   genres.nom_genre%TYPE
    );
    
    e_livre_indisponible EXCEPTION;
    e_penalites_impayees EXCEPTION;
    
    g_annee_courante VARCHAR2(4) := '2020';
    g_mois_courant   VARCHAR2(2) := '12';

---------------------------------------------------------------------------------------------

-- Fonction : est_disponible_fct
--
-- BUT : Vérifie la disponibilité d'un livre en fonction de son ID et retourne la date de retour prévue si applicable.
--
-- PARAMÈTRES :
-- i_livres_id (number) : ID du livre dont la disponibilité doit être vérifiée.
-- o_date_retour_prevue (date) : Date de retour prévue du livre, retournée si le livre est en emprunt.
--
-- RETOUR (boolean) :
--   TRUE si le livre est disponible, FALSE si le livre est déjà emprunté.
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette fonction.
    FUNCTION est_disponible_fct (
        i_livres_id          IN NUMBER,
        o_date_retour_prevue OUT DATE
    ) RETURN BOOLEAN;

---------------------------------------------------------------------------------------------
-- Fonction : rechercher_livre_fct
--
-- BUT : Recherche un livre dans la base de données et retourne ses informations détaillées.
--
-- PARAMÈTRES :
-- io_livres_id (IN OUT number) : ID du livre à rechercher. Il sera mis à jour avec l'ID du livre trouvé.
--
-- RETOUR (t_info_livre) :
--   Un enregistrement contenant les informations du livre (id, titre, isbn, auteur, éditeur, année, langue, section, genre).
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette fonction.
    FUNCTION rechercher_livre_fct (
        io_livres_id IN OUT NUMBER
    ) RETURN t_info_livre;

---------------------------------------------------------------------------------------------
-- Procédure : emprunter_livre_prc
--
-- BUT : Permet à un membre d'emprunter un livre.
--
-- PARAMÈTRES :
-- i_membres_id (number) : ID du membre empruntant le livre.
-- i_livres_id (number)  : ID du livre à emprunter.
--
-- RETOUR :
--   Aucune valeur retournée.
--
-- EXCEPTIONS :
--   e_livre_indisponible : Levée si le livre est déjà emprunté ou indisponible.
--   e_penalites_impayees : Levée si le membre a des pénalités impayées et ne peut pas emprunter de nouveau livre.
    PROCEDURE emprunter_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER   
    );

---------------------------------------------------------------------------------------------
-- Procédure : retourner_livre_prc
--
-- BUT : Permet à un membre de retourner un livre emprunté.
--
-- PARAMÈTRES :
-- i_membres_id (number) : ID du membre retournant le livre.
-- i_livres_id (number)  : ID du livre à retourner.
--
-- RETOUR :
--   Aucune valeur retournée.
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette procédure.
    PROCEDURE retourner_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER    
    );

---------------------------------------------------------------------------------------------
-- Fonction : est_penalites_impayees_fct
--
-- BUT : Vérifie si un membre a des pénalités impayées.
--
-- PARAMÈTRES :
-- i_membres_id (number) : ID du membre à vérifier.
--
-- RETOUR (boolean) :
--   TRUE si le membre a des pénalités impayées, FALSE sinon.
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette fonction.
    FUNCTION est_penalites_impayees_fct (
        i_membres_id IN NUMBER
    ) RETURN boolean;

---------------------------------------------------------------------------------------------
-- Procédure : archiver_prc
--
-- BUT : Archive les emprunts pour une année et un mois donnés. Si aucun mois ou année n'est précisé,
--       les valeurs par défaut (g_annee_courante et g_mois_courant) seront utilisées.
--
-- PARAMÈTRES :
-- i_annee_a_archiver (varchar2) : L'année à archiver (par défaut '2020').
-- i_mois_a_archiver (varchar2)  : Le mois à archiver (par défaut '12').
--
-- RETOUR :
--   Aucune valeur retournée.
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette procédure.
    PROCEDURE archiver_prc (
        i_annee_a_archiver in varchar2 default g_annee_courante,
        i_mois_a_archiver  in varchar2 default g_mois_courant 
    );

---------------------------------------------------------------------------------------------
-- Fonction : archiver_annee_fct
--
-- BUT : Archive les emprunts pour une année donnée et retourne le nombre d'emprunts archivés.
--
-- PARAMÈTRES :
-- i_annee_a_archiver (varchar2) : L'année à archiver.
--
-- RETOUR (number) :
--   Le nombre d'emprunts archivés pour l'année donnée.
--
-- EXCEPTIONS :
--   Aucune exception levée dans cette fonction.
    FUNCTION archiver_annee_fct (
        i_annee_a_archiver in varchar2
    ) RETURN number;

END gestion_emprunts_pkg;