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
  
    FUNCTION est_disponible_fct (
        i_livres_id          IN NUMBER,
        o_date_retour_prevue OUT DATE
    ) RETURN BOOLEAN;

    FUNCTION rechercher_livre_fct (
        io_livres_id IN OUT NUMBER
    ) RETURN t_info_livre;
    
    PROCEDURE emprunter_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER   
    );
    
    PROCEDURE retourner_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER    
    );
    
    FUNCTION est_penalites_impayees_fct (
        i_membres_id IN NUMBER
    ) RETURN boolean;
    
    PROCEDURE archiver_prc (
        i_annee_a_archiver in varchar2 default g_annee_courante,
        i_mois_a_archiver  in varchar2 default g_mois_courant 
    );
    
    FUNCTION archiver_annee_fct (
        i_annee_a_archiver in varchar2
    ) RETURN number;

END gestion_emprunts_pkg;