-- 02_BO_30_securite.sql

DECLARE
    CURSOR c_roles IS
        -- Dual est une table bidon qui permet de lancer le SELECT sans FROM (Sinon erreur)
        SELECT 'role_bibliothecaire' AS role_name FROM dual
        UNION ALL
        SELECT 'role_membre' FROM dual;

    nom_role VARCHAR2(30);
BEGIN
    -- Donne certaines permissions sur les tables au role bibliothecaire et au role membre
    FOR rec_role IN c_roles LOOP
        nom_role := rec_role.role_name;

        IF nom_role = 'role_bibliothecaire' THEN
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.EMPRUNTS TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.MEMBRES TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.LIVRES TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.AUTEURS TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.SECTIONS TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.GENRES TO ' || nom_role;

            EXECUTE IMMEDIATE 'GRANT EXECUTE ON bo.GESTION_EMPRUNTS_PKG TO ' || nom_role;

        ELSIF nom_role = 'role_membre' THEN
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.LIVRES TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.AUTEURS TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.SECTIONS TO ' || nom_role;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.GENRES TO ' || nom_role;
        END IF;
    END LOOP;

    EXECUTE IMMEDIATE 'GRANT role_bibliothecaire TO employe01';
    EXECUTE IMMEDIATE 'GRANT role_membre TO membre01';

END;
/
