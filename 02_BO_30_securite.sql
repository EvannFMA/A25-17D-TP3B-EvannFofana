-- 02_BO_30_securite.sql

DECLARE
    CURSOR c_roles IS
        SELECT 'role_bibliothecaire' AS role_name FROM dual
        UNION ALL
        SELECT 'role_membre' FROM dual;

    v_role_name VARCHAR2(30);
BEGIN
    -- Donne certaines permissions sur les tables au role bibliothecaire et au role membre
    FOR role_rec IN c_roles LOOP
        v_role_name := role_rec.role_name;

        IF v_role_name = 'role_bibliothecaire' THEN
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.EMPRUNTS TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.MEMBRES TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.LIVRES TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.AUTEURS TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.SECTIONS TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON bo.GENRES TO ' || v_role_name;

            EXECUTE IMMEDIATE 'GRANT EXECUTE ON bo.GESTION_EMPRUNTS_PKG TO ' || v_role_name;

        ELSIF v_role_name = 'role_membre' THEN
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.LIVRES TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.AUTEURS TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.SECTIONS TO ' || v_role_name;
            EXECUTE IMMEDIATE 'GRANT SELECT ON bo.GENRES TO ' || v_role_name;
        END IF;
    END LOOP;

    EXECUTE IMMEDIATE 'GRANT role_bibliothecaire TO employe01';
    EXECUTE IMMEDIATE 'GRANT role_membre TO membre01';

END;
/
