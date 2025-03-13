/* CERINTA 13*/


CREATE OR REPLACE PACKAGE pack_ex13 IS                           
    PROCEDURE incheie_reparatia(p_cod_reparatie reparatie.cod_reparatie%type,
                                p_data_final    reparatie.data_finalizare%type);
END;
/


CREATE OR REPLACE PACKAGE BODY pack_ex13 IS
    TYPE tab_obs  IS TABLE OF observatie%rowtype;
    
    CURSOR c(p_cod_reparatie reparatie.cod_reparatie%type) IS
    SELECT r.cod_reparatie, lc.cod_lot || '/' ||TO_CHAR(lc.data_livrare, 'DD.MM.YYYY') lot_data, COUNT(cmp.numar_componenta) nr_comp_folosite, lc.nume_componenta, f.nume furnizor 
    FROM reparatie r 
        JOIN componenta cmp ON cmp.cod_reparatie = r.cod_reparatie 
        JOIN lot_componenta lc ON lc.cod_lot = cmp.cod_lot 
        JOIN furnizor f ON f.cod_furnizor = lc.cod_furnizor 
    WHERE r.cod_reparatie = p_cod_reparatie
    GROUP BY r.cod_reparatie, lc.cod_lot || '/' ||TO_CHAR(lc.data_livrare, 'DD.MM.YYYY'), lc.nume_componenta, f.nume 
    ORDER BY 4;
    
    TYPE tab_piese IS TABLE OF c%rowtype;
    
    FUNCTION get_cod_vehicul(p_cod_reparatie    reparatie.cod_reparatie%type)
        RETURN NUMBER IS
        v_cod NUMBER;
    BEGIN
        SELECT cod_vehicul_tr INTO v_cod FROM reparatie WHERE cod_reparatie = p_cod_reparatie;
        RETURN v_cod;
    END;
    
    
    FUNCTION clasifica_reparatia(p_cod_reparatie    reparatie.cod_reparatie%type)
        RETURN VARCHAR2 IS
        v_tip       VARCHAR2(64);
        nr_piese    NUMBER;
    BEGIN
        SELECT COUNT(*) INTO nr_piese FROM componenta WHERE cod_reparatie = p_cod_reparatie;
        CASE 
            WHEN nr_piese BETWEEN 1 AND 4 THEN
                v_tip := 'Reparatie minora';
            WHEN nr_piese BETWEEN 5 AND 8 THEN
                v_tip := 'Reparatie majora';
            ELSE
                v_tip := 'Reparatie capitala';
        END CASE;
        RETURN v_tip;
    END;
    
    
    PROCEDURE actualizeaza_vehicul(p_cod_vehicul vehicul.cod_vehicul%type,
                                   p_data_verif  vehicul.data_verificare%type) IS
    BEGIN
        UPDATE vehicul
        SET data_verificare = p_data_verif,
            stare = 'functional'
        WHERE cod_vehicul = p_cod_vehicul;
        dbms_output.put_line('Informatiile despre vehicul au fost actualizate.');
    END;
    
    
    PROCEDURE afis_observatii(p_cod_vehicul  observatie.cod_vehicul%type) IS
        v_obs   tab_obs := tab_obs();
    BEGIN
        SELECT * BULK COLLECT INTO v_obs FROM observatie WHERE cod_vehicul = p_cod_vehicul;
        FOR i IN 1..v_obs.last LOOP
            dbms_output.put_line(v_obs(i).descriere || ', adaugata in data de: ' || TO_CHAR(v_obs(i).data_obs, 'DD.MM.YYYY'));
        END LOOP;
    END;
    

    PROCEDURE observatie_noua(p_descriere   observatie.descriere%type,
                              p_data        observatie.data_obs%type,
                              p_cod_vehicul vehicul.cod_vehicul%type) IS
        cod_obs NUMBER;
    BEGIN
        SELECT MAX(cod_observatie) + 1 INTO cod_obs FROM observatie;
        INSERT INTO observatie VALUES(cod_obs, p_descriere, p_data, p_cod_vehicul);
        dbms_output.put_line('Istoricul vehiculului a fost actualizat.');
        dbms_output.put_line('---------------------------------------');
        dbms_output.put_line('Toate observatiile:');
        afis_observatii(p_cod_vehicul);
        dbms_output.put_line('---------------------------------------');
    END;
    
    
    PROCEDURE statistici_reparatie(p_cod_reparatie    reparatie.cod_reparatie%type) IS
        v_piese  tab_piese := tab_piese();
    BEGIN
        dbms_output.put_line('S-au folosit urmatoarele componente:');
        OPEN c(p_cod_reparatie);
        FETCH c BULK COLLECT INTO v_piese;
        CLOSE c;
        FOR i IN 1..v_piese.last LOOP
            dbms_output.put_line(v_piese(i).nr_comp_folosite || ' x ' || v_piese(i).nume_componenta || ' furnizate de '  || v_piese(i).furnizor || ' in lotul ' || v_piese(i).lot_data);
        END LOOP;
        dbms_output.put_line('---------------------------------------');
    END;
    
    PROCEDURE incheie_reparatia(p_cod_reparatie reparatie.cod_reparatie%type,
                                p_data_final    reparatie.data_finalizare%type) IS
        v_cod_vehicul         reparatie.cod_vehicul_tr%type;
        v_data_final          reparatie.data_finalizare%type;
        v_descriere           VARCHAR2(64);
        deja_finalizata       EXCEPTION;
    BEGIN
        SELECT cod_vehicul_tr, data_finalizare INTO v_cod_vehicul, v_data_final
        FROM reparatie WHERE cod_reparatie = p_cod_reparatie;
        IF v_data_final IS NOT NULL THEN
            RAISE deja_finalizata;
        END IF;
        UPDATE reparatie
        SET data_finalizare = p_data_final
        WHERE cod_reparatie = p_cod_reparatie;
        dbms_output.put_line('S-a actualizat reparatia.');
        v_cod_vehicul := get_cod_vehicul(p_cod_reparatie);
        actualizeaza_vehicul(v_cod_vehicul, p_data_final);
        v_descriere := clasifica_reparatia(p_cod_reparatie);
        observatie_noua(v_descriere, p_data_final, v_cod_vehicul);
        statistici_reparatie(p_cod_reparatie);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nu exista reparatia cu acest cod');
        WHEN deja_finalizata THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nu se poate incheia o reparatie deja finalizata');
    END;
    
END;
/
--rollback;


INSERT INTO OBSERVATIE VALUES(1006, 'Transferat de la depoul Titan la depoul Militari', SYSDATE - 365, 9084);
EXECUTE pack_ex13.incheie_reparatia(300, SYSDATE);

SELECT * FROM observatie;
SELECT * FROM reparatie;
SELECT * FROM depou;

rollback;
SELECT * FROM observatie;