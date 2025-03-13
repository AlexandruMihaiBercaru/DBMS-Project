/*
    CERINTA 6
    Pentru fiecare depou, sa se afle si sa se afiseze urmatoarele informatii:
    - numele si adresa completa
    - gradul de ocupare al depoului, pentru fiecare tip de mijloc de transport care poate fi garat in acel depou
    (sub forma de fractie, dar si procentual) si gradul de ocupare total (afisat in aceeasi forma)
    - o statistica ce indica starea vehiculelor din depou: cate sunt functionale, cate sunt in reparatie
    (sa se afiseze si data la care au intrat in reparatie, pentru fiecare vehicul, impreuna cu numarul de parc) 
    si cate defecte.
    - numarul total de angajati din fiecare depou, indiferent de job
    - o clasificare a angajatilor dupa job
*/

CREATE OR REPLACE PROCEDURE ex6
IS
    TYPE   t_depouri                IS TABLE OF depou%rowtype INDEX BY PLS_INTEGER;
    CURSOR cc(p_cod_dep NUMBER) IS 
        SELECT v.*, m.tip_mijloc_transport
        FROM vehicul v JOIN model m ON v.cod_model = m.cod_model
        WHERE v.intrebuintare = 'transport'
        AND v.cod_depou = p_cod_dep
        ORDER BY v.cod_vehicul;
    TYPE    vehicule_per_categorie IS RECORD
    (   denumire_categ  VARCHAR2(32),
        nr NUMBER);
    TYPE t_vehicule IS TABLE OF cc%ROWTYPE;
    TYPE t_vehicule_din_fiecare_tip IS VARRAY(4) OF vehicule_per_categorie;
    TYPE tab_ang    IS TABLE OF angajat%rowtype;
    v_vehicule                  t_vehicule := t_vehicule();
    v_depouri                   t_depouri  := t_depouri();
    v_adresa                    VARCHAR2(128);    
    total_vehicule              NUMBER;
    total_capacitate            NUMBER := 0;
    procent                     NUMBER;
    veh_functionale             t_coduri := t_coduri();
    veh_in_reparatie            t_coduri := t_coduri();
    veh_defecte                 t_coduri := t_coduri();
    vect_categorii              t_vehicule_din_fiecare_tip  := t_vehicule_din_fiecare_tip();
    categorii                   t_denumiri := t_denumiri('autobuz', 'troleibuz', 'tramvai');
    data_intrare_rep            DATE;
    v_angajati                  tab_ang := tab_ang();
    total_ang                   NUMBER;
    total_soferi                NUMBER;
    total_ingineri              NUMBER;
    total_mecanici              NUMBER;
    total_muncitori             NUMBER;

    FUNCTION numara_categorie (p_vehicule IN t_vehicule, p_categ IN VARCHAR2)
        RETURN NUMBER
    IS
        contor NUMBER := 0;
    BEGIN
        FOR i IN 1..p_vehicule.LAST LOOP
            IF lower(p_vehicule(i).tip_mijloc_transport) = lower(p_categ) THEN
                contor := contor + 1;
            END IF;
        END LOOP;
        RETURN contor;
    END numara_categorie;
    
    PROCEDURE filtreaza_stare (p_vehicule IN t_vehicule, p_stare IN VARCHAR2, rez OUT NOCOPY t_coduri)
    AS
    BEGIN
        rez := t_coduri();
        FOR i IN 1..p_vehicule.LAST LOOP
            IF lower(p_vehicule(i).stare) = lower(p_stare) THEN
                rez.extend;
                rez(rez.last) := p_vehicule(i).cod_vehicul;
            END IF;
        END LOOP;
    END filtreaza_stare;
            
BEGIN
    SELECT * BULK COLLECT INTO v_depouri FROM depou;
    vect_categorii.extend(4);
    FOR i IN 1..v_depouri.last LOOP
        dbms_output.new_line();
        dbms_output.put_line('---------------------------------------');
        total_vehicule := 0;
        total_ang := 0; total_ingineri := 0; total_soferi := 0; total_mecanici := 0; total_muncitori := 0;
        
        OPEN cc(v_depouri(i).cod_depou);
        FETCH cc BULK COLLECT INTO v_vehicule;
        CLOSE cc;
        
        SELECT localitate || ', ' || nume_strada || ' nr. ' || numar INTO v_adresa
        FROM adresa WHERE cod_adresa = v_depouri(i).cod_adresa;
        
        veh_functionale.delete; veh_in_reparatie.delete; veh_defecte.delete;
       
        FOR k IN 1..categorii.count LOOP
            vect_categorii(k).denumire_categ := categorii(k);
            vect_categorii(k).nr := numara_categorie(v_vehicule, categorii(k));
            total_vehicule := total_vehicule + vect_categorii(k).nr;
        END LOOP;
        total_capacitate := NVL(v_depouri(i).capacitate_autobuze, 0) + NVL(v_depouri(i).capacitate_troleibuze, 0) + NVL(v_depouri(i).capacitate_tramvaie, 0);
        filtreaza_stare(v_vehicule, 'functional', veh_functionale);
        filtreaza_stare(v_vehicule, 'in reparatie', veh_in_reparatie);
        filtreaza_stare(v_vehicule, 'defect', veh_defecte);
        
        SELECT * BULK COLLECT INTO v_angajati FROM angajat WHERE cod_depou = v_depouri(i).cod_depou;
        total_ang := v_angajati.count;
        FOR i IN 1..v_angajati.last LOOP
            CASE 
                WHEN v_angajati(i).tip_job = 'sofer' THEN
                    total_soferi := total_soferi + 1;
                WHEN v_angajati(i).tip_job = 'inginer' THEN
                    total_ingineri := total_ingineri + 1;
                WHEN v_angajati(i).tip_job = 'mecanic' THEN
                    total_mecanici := total_mecanici + 1;
                ELSE
                    total_muncitori := total_muncitori + 1;
            END CASE;
        END LOOP;
        
        dbms_output.put_line(UPPER(v_depouri(i).denumire) || ' - ' || v_adresa);
        dbms_output.new_line();
        IF v_depouri(i).capacitate_autobuze IS NOT NULL THEN
            procent := vect_categorii(1).nr / v_depouri(i).capacitate_autobuze * 100;
            dbms_output.put_line('Grad de ocupare autobuze: ' || vect_categorii(1).nr || '/' || v_depouri(i).capacitate_autobuze
            || ' ' || TRUNC(procent) || '%');
        END IF;
        
        IF v_depouri(i).capacitate_troleibuze IS NOT NULL THEN
            procent := vect_categorii(2).nr / v_depouri(i).capacitate_troleibuze * 100;
            dbms_output.put_line('Grad de ocupare troleibuze: ' || vect_categorii(2).nr || '/' || v_depouri(i).capacitate_troleibuze
            || ' ' || TRUNC(procent) || '%');
        END IF;
        
        IF v_depouri(i).capacitate_tramvaie IS NOT NULL THEN
            procent := vect_categorii(3).nr / v_depouri(i).capacitate_tramvaie * 100;
            dbms_output.put_line('Grad de ocupare tramvaie: ' || vect_categorii(3).nr || '/' || v_depouri(i).capacitate_tramvaie
            || ' ' || TRUNC(procent) || '%');
        END IF;
        
        procent := total_vehicule / total_capacitate * 100;
        dbms_output.put_line('Grad de ocupare totala: ' || total_vehicule || '/' || total_capacitate || ' ' || TRUNC(procent) || '%');
        dbms_output.new_line;
        
        dbms_output.put_line('Numar vehicule functionale: ' || veh_functionale.count);
        FOR i IN 1..veh_functionale.last LOOP
            dbms_output.put(veh_functionale(i) || ' ');
        END LOOP;
        dbms_output.new_line();
        
        dbms_output.put_line('Numar vehicule defecte: ' || veh_defecte.count);
        IF veh_defecte.count > 0 THEN
            FOR i IN 1..veh_defecte.last LOOP
                dbms_output.put(veh_defecte(i) || ' ');
            END LOOP;
        END IF;
        dbms_output.new_line();
        
        dbms_output.put_line('Numar vehicule in reparatie: ' || veh_in_reparatie.count);
        IF veh_in_reparatie.count > 0 THEN
            dbms_output.put_line('Vehiculul   Data incepere reparatie');
            FOR i IN 1..veh_in_reparatie.last LOOP
                SELECT data_incepere INTO data_intrare_rep
                FROM reparatie r JOIN vehicul_transport vt ON r.cod_vehicul_tr = vt.cod_vehicul_tr
                                 WHERE vt.cod_vehicul_tr = veh_in_reparatie(i)
                AND data_finalizare IS NULL;
                dbms_output.put_line(RPAD(veh_in_reparatie(i),12) || TO_CHAR(data_intrare_rep, 'dd/mm/yyyy'));
            END LOOP;
        END IF;
        
        dbms_output.new_line();
        dbms_output.put_line('Total angajati: ' || total_ang);
        dbms_output.put_line('Soferi - ' || total_soferi || ', Mecanici - ' || total_mecanici || ', Ingineri - ' || total_ingineri || ', Muncitori necalificati - ' || total_muncitori);
    END LOOP;
END ex6;
/

--apelul
BEGIN
    ex6;
END;
/



/* 
    CERINTA 7
    Pentru o luna din an data ca parametru, sa se determine toti soferii care au efectuat minim 2 curse in acea luna (indiferent de an) cu acelasi vehicul 
    si sa li se creasca salariul cu 5% (daca nu exista niciun sofer care sa respecte conditia, sa se afiseze un mesaj sugestiv);
    Sa se determine traseele pe care a circulat soferul cu acel vehicul, intervalul orar in care s-a aflat in cursa si durata medie a unei ture dus-intors
    Pentru acel vehicul, sa se mentioneze daca a fost sau nu implicat intr-un eveniment de circulatie (daca da, sa se afiseze informatii referitoare la acel eveniment de circulatie)
    In plus, sa se determine care au fost cele mai circulate trasee (per total) in acea luna.
*/

CREATE OR REPLACE PROCEDURE ex7 (p_luna VARCHAR2)
AS
    TYPE refcursor IS REF CURSOR;
    --in cursor, salvez cele mai circulate trasee din acea luna
    CURSOR c_aparitii_lunare IS
    SELECT cod_sofer, cod_vehicul_tr, COUNT(cod_sofer) AS aparitii_pe_masina,
        CURSOR(SELECT numar_traseu 
                        FROM cursa c2 
                        WHERE TO_CHAR(c2.data_cursa, 'mm') = p_luna
                        GROUP BY numar_traseu HAVING COUNT(numar_traseu) =
                        (SELECT MAX(COUNT(numar_traseu)) 
                        FROM cursa c3 
                        WHERE TO_CHAR(c3.data_cursa, 'mm') = p_luna 
                        GROUP BY numar_traseu)
               )
    FROM cursa 
    WHERE TO_CHAR(data_cursa, 'mm') = p_luna
    GROUP BY cod_sofer, cod_vehicul_tr
    ORDER BY 3 DESC, 1;
    --pentru fiecare vehicul, caut evenimentele de circulatie in care a fost implicat
    CURSOR vehicul_implicat_accidente(p_cod_vehicul vehicul.cod_vehicul%type) IS
    SELECT ec.data_producere, ec.descriere, i.daune
        FROM implica i, eveniment_circulatie ec
        WHERE i.cod_eveniment = ec.cod_eveniment
        AND i.cod_vehicul_tr = p_cod_vehicul;
    
    v_cod_sofer         angajat.cod_angajat%type;
    v_cod_veh           vehicul.cod_vehicul%type;
    v_aparitii          NUMBER;
    v_cursor            refcursor;
    v_nume              angajat.nume%type;
    v_prenume           angajat.prenume%type;
    v_salariu_vechi     angajat.salariu%type;
    v_salariu_nou       angajat.salariu%type;
    v_traseu            traseu.numar_traseu%type;
    nr_accidente        NUMBER;
    
BEGIN
    
    OPEN c_aparitii_lunare;
    LOOP
        FETCH c_aparitii_lunare INTO v_cod_sofer, v_cod_veh, v_aparitii, v_cursor;
        --ma opresc cand ajung la soferii care au mai putin de 2 aparitii pe un vehicul 
        EXIT WHEN v_aparitii < 2 OR c_aparitii_lunare%notfound;
        
        SELECT nume, prenume, salariu INTO v_nume, v_prenume, v_salariu_vechi
            FROM angajat WHERE cod_angajat = v_cod_sofer;
            
        UPDATE angajat
            SET salariu = salariu * 1.05
            WHERE cod_angajat = v_cod_sofer
            RETURNING salariu INTO v_salariu_nou;
        
        dbms_output.put_line('Soferul ' || v_nume || ' ' || v_prenume || ' a aparut cu vehiculul ' || v_cod_veh || ' pe urmatoarele trasee: ');
        
        FOR cc IN ( SELECT cod_sofer, cod_vehicul_tr, numar_traseu, data_cursa, ora_incepere_ture, ora_finalizare_ture, 
                    TRUNC((ABS(ora_finalizare_ture - ora_incepere_ture) * 24 * 60) / numar_ture) timp_tura
                    FROM cursa
                    WHERE cod_sofer = v_cod_sofer AND cod_vehicul_tr = v_cod_veh AND TO_CHAR(data_cursa, 'mm') = p_luna) LOOP
            dbms_output.put_line('  ->' || cc.numar_traseu || ', in data de ' || TO_CHAR(cc.data_cursa, 'dd/mm/yyyy') ||
            ', in intervalul: ' || TO_CHAR(cc.ora_incepere_ture, 'hh24:mi') || '-' || TO_CHAR(cc.ora_finalizare_ture, 'hh24:mi')
            || '. Durata medie a unei ture: ' || cc.timp_tura || ' minute');
        END LOOP;
        
        nr_accidente := 0;
        dbms_output.new_line;
        dbms_output.put_line('Vehiculul ' || v_cod_veh || ' a fost implicat in evenimentele de circulatie: ');
        FOR event IN vehicul_implicat_accidente(v_cod_veh) LOOP
            nr_accidente := nr_accidente + 1;
            dbms_output.put_line('  -> pe data de ' || TO_CHAR(event.data_producere, 'dd/mm/yyyy') || ', ' || event.descriere);
            dbms_output.put_line('      daune suferite: ' || event.daune);
        END LOOP;
        IF nr_accidente = 0 THEN
            dbms_output.put_line('Nu a fost implicat in niciun eveniment de circulatie!');
        END IF;
        
        dbms_output.put_line('Salariu vechi: ' || v_salariu_vechi || ' -> Salariu nou: ' || v_salariu_nou);
        dbms_output.put_line('------------------------------------');
        dbms_output.new_line;
    END LOOP;
    IF c_aparitii_lunare%rowcount = 1 THEN
        dbms_output.put_line('In luna ' || TO_CHAR(TO_DATE(p_luna, 'mm'), 'MONTH') || ', nu exista niciun sofer care sa fi mers de cel putin 2 ori cu acelasi vehicul');
    END IF;
    
    dbms_output.put('Cele mai circulate trasee in luna ' ||  TO_CHAR(TO_DATE(p_luna, 'mm'), 'MONTH') || ': ');
    LOOP
        FETCH v_cursor INTO v_traseu;
        EXIT WHEN v_cursor%notfound;
        dbms_output.put(v_traseu || ' ');
    END LOOP;
    dbms_output.new_line;
    CLOSE v_cursor;    
    CLOSE c_aparitii_lunare;
END ex7;
/

BEGIN
    ex7('01');
END;
/

BEGIN
    ex7('07');
END;
/

BEGIN
    ex7('09');
END;
/
rollback;
--luni bune: 01, 07, 09


SELECT * FROM vehicul;
SELECT * FROM REPARATIE;
SELECT * FROM CURSA;
select * from implica;
SELECT * FROM statie;


/*  
    CERINTA 8
    Pentru un nume de statie introdus de la tastatura / dat ca parametru,
    sa se afle toate traseele active care tranziteaza acea statie (numarul traseului + directia de deplasare (tur)),
    iar pentru fiecare traseu, cate modele vehicule au trecut prin acea statie in ultimele 3 luni 
    Sa se trateze cazurile in care exista mai multe statii cu acelasi nume, nu se gaseste nicio statie cu numele introdus
    de la tastatura, sau cand o statie nu apare pe niciun traseu.
*/

CREATE OR REPLACE TYPE rec_traseu IS OBJECT
(
    indicativ_traseu    NUMBER,
    statie_capat_1      VARCHAR2(64),
    statie_capat_2      VARCHAR2(64),
    nr_modele           NUMBER
);
/

CREATE OR REPLACE TYPE tab_trasee IS TABLE OF rec_traseu;
/

CREATE OR REPLACE FUNCTION ex8 (v_nume_statie statie.nume%type, v_trasee OUT tab_trasee)
    RETURN NUMBER
IS
    nr_trasee           NUMBER;
    v_statie            statie%rowtype;
    nu_apare_pe_trasee  EXCEPTION;
    v_coduri_statii     t_coduri;
    v_nume_statii       t_denumiri;
    contine_statia      BOOLEAN;
    v_indicativ         traseu.numar_traseu%type;
    v_capat_1           statie.nume%type;
    v_capat_2           statie.nume%type;
    v_nr_modele         NUMBER;
    CURSOR itinerariu_traseu(param_traseu   traseu.numar_traseu%type) IS
        SELECT pt.cod_statie, s.nume
        FROM parcurs_traseu pt JOIN statie s ON pt.cod_statie = s.cod_statie
        WHERE pt.numar_traseu = param_traseu
        ORDER BY pt.numar_ordine;
        
BEGIN
    v_trasee := tab_trasee();
    SELECT * INTO v_statie FROM statie WHERE lower(nume) LIKE '%' || lower(v_nume_statie) || '%';
    
    --numar pe cate trasee apare statia data ca parametru
    SELECT COUNT(*) INTO nr_trasee
        FROM parcurs_traseu pt 
        JOIN traseu t ON pt.numar_traseu = t.numar_traseu
        WHERE t.data_suspendare IS NULL
        AND pt.cod_statie = v_statie.cod_statie;
        
    IF nr_trasee = 0 THEN
        RAISE nu_apare_pe_trasee;
    END IF;
    
    --parcurg traseele si le selectez doar pe cele care au in itinerariul lor statia ceruta
    FOR c IN (SELECT numar_traseu FROM traseu WHERE data_suspendare IS NULL) LOOP
        contine_statia := FALSE;
        OPEN itinerariu_traseu(c.numar_traseu);
        FETCH itinerariu_traseu BULK COLLECT INTO v_coduri_statii, v_nume_statii;
        CLOSE itinerariu_traseu;
        FOR i IN 1..v_coduri_statii.last LOOP
            IF v_coduri_statii(i) = v_statie.cod_statie THEN
                contine_statia := TRUE;
            END IF;
        END LOOP;
        IF contine_statia = TRUE THEN
            v_trasee.extend;
            v_indicativ := c.numar_traseu;
            v_capat_1 := v_nume_statii(v_nume_statii.first);
            v_capat_2 := v_nume_statii(v_nume_statii.last);
            
            --calculez cate modele diferite au aparut pe acest traseu in ultimele 3 luni
            SELECT COUNT (DISTINCT m.denumire) INTO v_nr_modele
            FROM cursa cr
                JOIN vehicul_transport vt ON vt.cod_vehicul_tr = cr.cod_vehicul_tr
                JOIN vehicul v ON v.cod_vehicul = vt.cod_vehicul_tr
                JOIN model m ON v.cod_model = m.cod_model
            WHERE cr.numar_traseu = c.numar_traseu AND MONTHS_BETWEEN(SYSDATE, cr.data_cursa) <= 3;
            
            --adaug o noua inregistrare in tablou
            v_trasee(v_trasee.last) := rec_traseu(v_indicativ, v_capat_1, v_capat_2, v_nr_modele);
        END IF;
    END LOOP;
    RETURN nr_trasee;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Exista mai multe statii cu acest nume');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nu exista nicio statie cu acest nume');
    WHEN nu_apare_pe_trasee THEN
        RAISE_APPLICATION_ERROR(-20003, 'Statia data nu apare pe niciun traseu');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Codul erorii: ' ||SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Mesajul erorii: ' ||SQLERRM);
END;
/


--apelul
DECLARE
    v_statie        statie.nume%type    := '&p_statie';
    nr_trasee       NUMBER;
    trasee          tab_trasee          := tab_trasee();
BEGIN
    nr_trasee   := ex8(v_statie, trasee);
    dbms_output.put_line('Statia ' || initcap(v_statie) || ' apare pe ' || nr_trasee || ' trasee:');
    FOR i IN 1..trasee.last LOOP
        dbms_output.put_line(trasee(i).indicativ_traseu || ': ' || trasee(i).statie_capat_1 || ' -> ' || trasee(i).statie_capat_2);
        dbms_output.put_line('    Pe acest traseu au circulat ' || trasee(i).nr_modele || ' modele de vehicule in ultimele 3 luni.');
    END LOOP;
END;
/

-- Doamna Ghica (ok)
-- Piata Unirii (too many rows)
-- Preciziei (fara trasee)
-- Aeroport (no data found)


SELECT pt.cod_statie, s.nume, s.artera
FROM parcurs_traseu pt JOIN statie s ON pt.cod_statie = s.cod_statie
WHERE pt.numar_traseu = 1
ORDER BY numar_traseu, s.artera;

select * from traseu;
select * from cursa;
select * from statie where cod_statie not in (select cod_statie from parcurs_traseu);




/* 
    CERINTA 9
    Se prelungesc lucrarile de reparatie ale unui vehicul:
    Pentru reparatie, mai sunt necesare un anumit numar de bucati dintr-o componenta. 
    Daca mai sunt suficiente bucati din acea piesa pe stoc (indiferent de lotul de provenienta), sa se utilizeze la reparatie.
    (Daca exista mai multe loturi cu aceeasi piesa, mai intai se vor epuiza componentele din lotul mai vechi.)
    Apoi, sa se incerce mutarea vehiculului intr-un alt atelier: doar daca mai sunt locuri, sa se mute intr-unul din atelierele
    care se afla la aceeasi adresa cu un depou. Mutarea se va face in acel atelier care are cele mai multe locuri libere.
    (Sa se afiseze un mesaj daca a reusit mutarea, respectiv daca nu a reusit).
    Coordonarea reparatiei va fi preluata de catre inginerul care lucreaza in depoul aflat la aceeasi adresa cu atelierul.
    (Observatie: exista (maxim) un inginer in fiecare depou!!!)
    La final, sa se afiseze datele actualizate referitoare la reparatie:
    numele atelierului in care se afla, inginerul supervizor, producatorul si modelul, vechimea vehiculului (in ani),
    numarul total de componente schimbate.
*/

--inserturi pentru a avea mai multe loturi cu aceeasi componenta
INSERT INTO lot_componenta VALUES (13, 'Tampoane tramvai', 15, 8800, SYSDATE, 1);
INSERT INTO lot_componenta VALUES (14, 'Boghiu', 1, 700, SYSDATE, 8);
INSERT INTO componenta VALUES(13, 1, 300);
INSERT INTO componenta VALUES(13, 2, 300);

CREATE OR REPLACE PROCEDURE ex9
(v_nume_piesa lot_componenta.nume_componenta%type, v_nr_buc lot_componenta.cantitate%type,
v_cod_reparatie reparatie.cod_reparatie%type)
IS
    piese_insuficiente EXCEPTION;
    reparatie_finalizata EXCEPTION;
    deja_in_atelier   EXCEPTION;
    ateliere_pline      EXCEPTION;
    CURSOR calcul_stoc_piesa(param_nume_piesa lot_componenta.nume_componenta%type) IS
        SELECT l.cod_lot, COUNT(c.cod_lot) "consumate",
                (SELECT l2.cantitate FROM lot_componenta l2 WHERE l2.cod_lot = l.cod_lot) AS "stoc initial",
                (SELECT l3.data_livrare FROM lot_componenta l3 WHERE l3.cod_lot = l.cod_lot) 
                FROM lot_componenta l LEFT JOIN componenta c ON l.cod_lot = c.cod_lot
                WHERE LOWER(l.nume_componenta) = LOWER(param_nume_piesa)
                GROUP BY l.cod_lot
                ORDER BY 4;
    CURSOR depou_cu_atelier IS
        SELECT d.cod_depou, at.cod_atelier, at.capacitate, 
        at.capacitate - (SELECT COUNT(*) FROM reparatie r2 WHERE r2.data_finalizare IS NULL AND r2.cod_atelier = at.cod_atelier) locuri_libere
        FROM depou d JOIN adresa a ON d.cod_adresa = a.cod_adresa
                     JOIN atelier at ON a.cod_adresa = at.cod_adresa
        ORDER BY 4 DESC;

    TYPE rec_stoc IS RECORD
    (   cod_lot         lot_componenta.cod_lot%type,
        consumate       lot_componenta.cantitate%type,
        buc_livrare     lot_componenta.cantitate%type,
        data_livrare    lot_componenta.data_livrare%type
    );
    TYPE tab_stoc IS TABLE OF rec_stoc;
    v_stocuri   tab_stoc    := tab_stoc();
    buc_consumate            NUMBER := 0;
    v_total_piese            NUMBER;
    v_consumate_din_lot      NUMBER;
    piese_adaugate           NUMBER;
    piese_adaugate_din_lot   NUMBER;
    poz                      NUMBER; 
    nr_ord_piesa             NUMBER;
    v_data_fin               DATE;
    v_atelier_vechi          reparatie.cod_atelier%type;
    v_atelier_nou            reparatie.cod_atelier%type;
    v_inginer_nou            reparatie.cod_inginer%type;
    v_depou                  depou.cod_depou%type;
    v_capacitate             NUMBER;
    v_locuri_libere          NUMBER;
    
    PROCEDURE afiseaza_mesaj(p_cod_reparatie reparatie.cod_reparatie%type)
    IS
    BEGIN
        FOR c IN(
            SELECT TO_CHAR(rep.data_incepere, 'dd.mm.yyyy') data, v.producator, m.denumire den_model, TRUNC((SYSDATE - v.an_achizitie) / 365) ani_vech,
            a.nume || ' ' || a.prenume supervizor, at.denumire den_atelier, COUNT(c.cod_reparatie) nr_piese_inloc 
            FROM reparatie rep
            JOIN inginer i ON i.cod_inginer = rep.cod_inginer
            JOIN angajat a ON a.cod_angajat = i.cod_inginer
            JOIN atelier at ON at.cod_atelier = rep.cod_atelier
            JOIN vehicul_transport vt ON vt.cod_vehicul_tr = rep.cod_vehicul_tr
            JOIN vehicul v ON v.cod_vehicul = vt.cod_vehicul_tr
            JOIN model m ON m.cod_model = v.cod_model
            JOIN componenta c ON c.cod_reparatie = rep.cod_reparatie
            WHERE rep.cod_reparatie = p_cod_reparatie
            GROUP BY TO_CHAR(rep.data_incepere, 'dd.mm.yyyy'), v.producator, m.denumire, TRUNC((SYSDATE - v.an_achizitie) / 365),
            a.nume || ' ' || a.prenume, at.denumire) 
        LOOP
            dbms_output.put_line('Vehiculul ' || c.den_model || ' cu o vechime de ' || c.ani_vech || ' ani, produs de ' || 
            c.producator || ' se afla in reparatie din data de ' || c.data || ' la ' || c.den_atelier || '. ');
            dbms_output.put_line('Reparatia este coordonata de catre Ing. ' || c.supervizor || '. ');
            dbms_output.put_line('Pana la acest moment, s-au inlocuit ' || c.nr_piese_inloc || ' piese.');
            dbms_output.new_line;
        END LOOP;
    END afiseaza_mesaj;
BEGIN
    BEGIN
        SELECT data_finalizare, cod_atelier INTO v_data_fin, v_atelier_vechi FROM reparatie WHERE cod_reparatie = v_cod_reparatie; 
        IF v_data_fin IS NOT NULL THEN
            RAISE reparatie_finalizata;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nu exista nicio reparatie cu codul dat ca parametru.');
        WHEN reparatie_finalizata THEN
            RAISE_APPLICATION_ERROR(-20001, 'Reparatia s-a incheiat, nu se mai poate modifica.');
    END;
    
    SELECT SUM(cantitate) 
    INTO v_total_piese
    FROM lot_componenta WHERE LOWER(nume_componenta) = LOWER(v_nume_piesa) GROUP BY nume_componenta;
    
    OPEN calcul_stoc_piesa(v_nume_piesa);
    FETCH calcul_stoc_piesa BULK COLLECT INTO v_stocuri;
    CLOSE calcul_stoc_piesa;
    
    FOR i IN 1..v_stocuri.last LOOP
        buc_consumate := buc_consumate + v_stocuri(i).consumate;
    END LOOP;
    
    IF v_total_piese - buc_consumate < v_nr_buc THEN
        RAISE piese_insuficiente;
    ELSE
        afiseaza_mesaj(v_cod_reparatie);
        poz := 1;
        piese_adaugate := 0;
        piese_adaugate_din_lot := 0;
        WHILE piese_adaugate < v_nr_buc LOOP
            nr_ord_piesa := v_stocuri(poz).consumate + piese_adaugate_din_lot + 1;
            --am terminat un lot, trec la urmatorul
            IF nr_ord_piesa > v_stocuri(poz).buc_livrare THEN
                poz := poz + 1;
                piese_adaugate_din_lot := 0;
                CONTINUE;
            END IF;
            INSERT INTO COMPONENTA VALUES(v_stocuri(poz).cod_lot, nr_ord_piesa, v_cod_reparatie);
            piese_adaugate := piese_adaugate + 1;
            piese_adaugate_din_lot := piese_adaugate_din_lot + 1;
        END LOOP;
    END IF;
    
    <<mutare_reparatie>>
    DECLARE
        total_libere NUMBER;
    BEGIN 
        total_libere := 0;
        FOR c IN depou_cu_atelier LOOP
            IF c.cod_atelier = v_atelier_vechi THEN
                RAISE deja_in_atelier;
            END IF;
            total_libere := total_libere + c.locuri_libere;
        END LOOP;
        
        IF total_libere = 0 THEN
            RAISE ateliere_pline;
        END IF;
        
        --daca nu se arunca exceptiile, inseamna ca se poate realiza mutarea
        OPEN depou_cu_atelier;
        FETCH depou_cu_atelier INTO v_depou, v_atelier_nou, v_capacitate, v_locuri_libere;
        
        SELECT i.cod_inginer INTO v_inginer_nou
        FROM angajat a JOIN inginer i ON a.cod_angajat = i.cod_inginer 
        WHERE a.cod_depou = v_depou;
        
        UPDATE reparatie
        SET cod_atelier = v_atelier_nou,
            cod_inginer = v_inginer_nou
        WHERE cod_reparatie = v_cod_reparatie;
        dbms_output.put_line('S-a produs mutarea de la atelierul ' || v_atelier_vechi || ' la atelierul ' || v_atelier_nou);
           
        CLOSE depou_cu_atelier;
    EXCEPTION
        WHEN deja_in_atelier THEN
            dbms_output.put_line('Nu s-a produs mutarea, deoarece reparatia deja are loc intr-un atelier care se afla la un depou.');
            dbms_output.new_line;
        WHEN ateliere_pline THEN
            dbms_output.put_line('Nu s-a produs mutarea, deoarece toate ateliere aflate in cadrul depourilor se afla la capacitate maxima.');
            dbms_output.new_line;
    END;
    
    afiseaza_mesaj(v_cod_reparatie);
      
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista nicio piesa cu acest nume.');
    WHEN piese_insuficiente THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nu exista suficiente piese pentru a putea continua reparatia.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Codul erorii: ' ||SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Mesajul erorii: ' ||SQLERRM);
END;
/

BEGIN
    ex9('Tampoane tramvai', 8, 100);
END;
/

BEGIN
    ex9('Tampoane tramvai', 8, 300);
END;
/

BEGIN
    ex9('Boghiu', 2, 270);
END;
/

BEGIN
    ex9('Stergator', 2, 270);
END;
/

BEGIN
    ex9('Tampoane tramvai', 8, 300);
END;
/

BEGIN
    ex9('Tampoane tramvai', 8, 270);
END;
/
rollback;
select * from reparatie order by cod_atelier;
select * from atelier;

BEGIN
    ex9('Tampoane tramvai', 1, 290);
    ex9('Tampoane tramvai', 1, 300);
    ex9('Tampoane tramvai', 1, 310);
    ex9('Tampoane tramvai', 1, 320);
    
    ex9('Tampoane tramvai', 1, 190);
END;
/

rollback;

SELECT * FROM lot_componenta;
SELECT * FROM componenta order by 1;
select * from reparatie order by 3, 6;
SELECT cod_inginer, cod_depou
FROM inginer JOIN angajat ON angajat.cod_angajat = inginer.cod_inginer;



/*
    CERINTA 10
    Trigger care permite inserarea in tabelul lot_componenta doar de luni pana vineri (exceptand perioada
    23 decembrie 2024 - 10 ianuarie 2025, considerata perioada de concediu), si nu permite deloc
    actualizarea sau stergerea informatiilor din acea tabela.
*/
    CREATE OR REPLACE TRIGGER adaugare_lot
        BEFORE INSERT OR UPDATE OR DELETE ON lot_componenta
    BEGIN
        IF INSERTING THEN
            IF TO_CHAR(SYSDATE, 'D') <> '1' AND TO_CHAR(SYSDATE, 'D') <> '7' THEN
                IF SYSDATE - TO_DATE('23/12/2024', 'DD/MM/YYYY') <= TO_DATE('10/01/2025', 'DD/MM/YYYY') -  TO_DATE('23/12/2024', 'DD/MM/YYYY') THEN
                    RAISE_APPLICATION_ERROR(-20000, 'Nu aveti voie sa introduceti date in acest tabel in timpul concediului');
                END IF;
            ELSE
                RAISE_APPLICATION_ERROR(-20001, 'Nu aveti voie sa introduceti date in acest tabel in weekend');
            END IF;
        ELSIF UPDATING THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nu aveti voie sa actualizati date din acest tabel.');
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Nu aveti voie sa stergeti date din acest tabel.');
        END IF;
    END;
    /
    SELECT * FROM lot_componenta;
    
    INSERT INTO lot_componenta VALUES(15, 'Rulmenti', 1000, 9990,  SYSDATE, 3);
rollback;
    UPDATE lot_componenta SET cod_furnizor = 1 WHERE cod_lot <= 10;
    
    DELETE FROM lot_componenta WHERE lower(nume_componenta) LIKE '%autobuz%';
    
  
  
/* ----------------------------------------- */  
CREATE TABLE statistici_curse_lunare(
    cod_luna        VARCHAR2(8)     CONSTRAINT pk_stats_curse PRIMARY KEY,
    nr_curse_bus    NUMBER,
    nr_curse_trol   NUMBER,
    nr_curse_tram   NUMBER
);
--DROP TABLE statistici_curse_lunare;
DECLARE
    var1  VARCHAR2(8);
    var2  NUMBER;
    var3  NUMBER;
    var4  NUMBER;
    CURSOR curse_lunare IS
        SELECT TO_CHAR(c1.data_cursa, 'MM-YYYY') "luna" ,
            (SELECT COUNT(c2.cod_cursa) FROM cursa c2 JOIN traseu t ON c2.numar_traseu = t.numar_traseu
                WHERE TO_CHAR(c1.data_cursa, 'MM-YYYY') =  TO_CHAR(c2.data_cursa, 'MM-YYYY') AND t.vehicule_folosite = 'autobuz') "curse_autobuz",
            (SELECT COUNT(c2.cod_cursa) FROM cursa c2 JOIN traseu t ON c2.numar_traseu = t.numar_traseu
                WHERE TO_CHAR(c1.data_cursa, 'MM-YYYY') =  TO_CHAR(c2.data_cursa, 'MM-YYYY') AND t.vehicule_folosite = 'troleibuz') "curse_troleibuz",
            (SELECT COUNT(c2.cod_cursa) FROM cursa c2 JOIN traseu t ON c2.numar_traseu = t.numar_traseu
                WHERE TO_CHAR(c1.data_cursa, 'MM-YYYY') =  TO_CHAR(c2.data_cursa, 'MM-YYYY') AND t.vehicule_folosite = 'tramvai') "curse_tramvai"
        FROM cursa c1 
        GROUP BY TO_CHAR(c1.data_cursa, 'MM-YYYY') 
        ORDER BY 1;
BEGIN
    OPEN curse_lunare;
    LOOP
        FETCH curse_lunare INTO var1, var2, var3, var4;
        EXIT WHEN curse_lunare%NOTFOUND;
        INSERT INTO statistici_curse_lunare VALUES(var1, var2, var3, var4);
    END LOOP;
    CLOSE curse_lunare;
END;
/

SELECT * FROM statistici_curse_lunare;

/*
    CERINTA 11
    Creati un trigger care sa se decalnseze cand se incearca o modificare asupra tabelei cursa, astfel:
    - sa se permita introducerea unei curse, doar daca soferul conduce un vehicul garat la depoul la care este la randul sau repartizat
    si doar daca vehiculul respecta categoria de mijloc de transport de pe permisul soferului
    - pentru o cursa deja existenta, nu se pot actualiza decat codul vehiculului de transport sau numarul traseului
    (un update care ar incalca conditiile de mai sus nu ar trebui permis)
    - dupa orice modificare, sa se actualizeze tabela statistici_curse_lunare, astfel incat sa contina numarul corect
    de curse pentru fiecare mijloc de transport, pentru fiecare luna
*/

--functie care verifica respectarea conditiei de insert / update
CREATE OR REPLACE FUNCTION repartitie_corecta
(p_cod_sofer sofer.cod_sofer%type, p_nr_traseu traseu.numar_traseu%type, p_cod_vehicul vehicul.cod_vehicul%type)
RETURN BOOLEAN
IS
    permite BOOLEAN;
    v_categ_permis      sofer.categorie_permis%type;
    v_cod_depou_ang     angajat.cod_depou%type;
    v_cod_depou_veh     angajat.cod_depou%type;
    v_tip_traseu        traseu.vehicule_folosite%type;
    v_tip_vehicul       model.tip_mijloc_transport%type;
    
BEGIN
    BEGIN
        SELECT s.categorie_permis, a.cod_depou INTO v_categ_permis, v_cod_depou_ang
        FROM sofer s JOIN angajat a ON s.cod_sofer = a.cod_angajat
        WHERE s.cod_sofer = p_cod_sofer;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Cod sofer inexistent');
    END;
    
    BEGIN
        SELECT veh.cod_depou, m.tip_mijloc_transport INTO v_cod_depou_veh, v_tip_vehicul 
        FROM vehicul veh JOIN model m ON m.cod_model = veh.cod_model
        WHERE veh.cod_vehicul = p_cod_vehicul;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Vehicul inexistent');   
    END;
    
    BEGIN
        SELECT vehicule_folosite INTO v_tip_traseu FROM traseu WHERE numar_traseu = p_nr_traseu;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Traseu inexistent');   
    END;
    
    permite := FALSE;
    IF v_cod_depou_veh = v_cod_depou_ang THEN
        IF v_tip_traseu = v_tip_vehicul THEN
            CASE v_categ_permis
                WHEN 'BUS' THEN
                    IF v_tip_traseu = 'autobuz' THEN
                        permite := TRUE;
                    END IF;
                WHEN 'TRL' THEN
                    IF v_tip_traseu = 'troleibuz' THEN
                        permite := TRUE;
                    END IF;
                ELSE
                    IF v_tip_traseu = 'tramvai' THEN
                        permite := TRUE;
                    END IF;
            END CASE;
        END IF;
    END IF;
    RETURN permite;
END repartitie_corecta;
/


CREATE OR REPLACE TRIGGER modif_curse
    BEFORE INSERT OR UPDATE OR DELETE ON cursa
    FOR EACH ROW
DECLARE
    e_permis BOOLEAN;
    tip_cursa   traseu.vehicule_folosite%type;
    v_data  VARCHAR2(8);
    v_nr    NUMBER;
BEGIN
    IF INSERTING THEN
        e_permis := repartitie_corecta(:NEW.cod_sofer, :NEW.numar_traseu, :NEW.cod_vehicul_tr);
        IF e_permis = FALSE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Datele nu respecta conditiile: verificati daca soferul si vehiculul apartin de acelasi depou, sau daca traseul a fost ales corect');
        ELSE
            SELECT vehicule_folosite INTO tip_cursa FROM traseu WHERE numar_traseu = :NEW.numar_traseu;
            v_data := TO_CHAR(:NEW.data_cursa, 'MM-YYYY');
            SELECT COUNT(*) INTO v_nr FROM statistici_curse_lunare WHERE cod_luna = v_data;
            IF v_nr = 0 THEN
                INSERT INTO statistici_curse_lunare VALUES(v_data, 0, 0, 0);
            END IF;
            CASE tip_cursa
                WHEN 'autobuz' THEN
                    UPDATE statistici_curse_lunare
                    SET nr_curse_bus = nr_curse_bus + 1
                    WHERE cod_luna = v_data;
                WHEN 'troleibuz' THEN
                    UPDATE statistici_curse_lunare
                    SET nr_curse_trol = nr_curse_trol + 1
                    WHERE cod_luna = v_data;
                ELSE
                    UPDATE statistici_curse_lunare
                    SET nr_curse_tram = nr_curse_tram + 1
                    WHERE cod_luna = v_data;
            END CASE;
        END IF;
    ELSIF UPDATING('numar_traseu') OR UPDATING('cod_vehicul_tr') THEN
        e_permis := repartitie_corecta(:NEW.cod_sofer, :NEW.numar_traseu, :NEW.cod_vehicul_tr);
        IF e_permis = FALSE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Modificarea nu este corecta: verificati daca soferul si vehiculul apartin de acelasi depou, sau daca traseul a fost ales corect');
        END IF;
    ELSIF DELETING THEN
        SELECT vehicule_folosite INTO tip_cursa FROM traseu WHERE numar_traseu = :OLD.numar_traseu;
        v_data := TO_CHAR(:OLD.data_cursa, 'MM-YYYY');
        CASE tip_cursa
            WHEN 'autobuz' THEN
                UPDATE statistici_curse_lunare
                SET nr_curse_bus = nr_curse_bus - 1
                WHERE cod_luna = v_data;
            WHEN 'troleibuz' THEN
                UPDATE statistici_curse_lunare
                SET nr_curse_trol = nr_curse_trol - 1
                WHERE cod_luna = v_data;
            ELSE
                UPDATE statistici_curse_lunare
                SET nr_curse_tram = nr_curse_tram - 1
                WHERE cod_luna = v_data;
        END CASE;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Se pot actualiza doar linia sau vehiculul.');
    END IF;
END;
/

SELECT * FROM statistici_curse_lunare;
SELECT * FROM cursa;
SELECT * FROM vehicul;
SELECT * FROM angajat;
SELECT * FROM sofer;
SELECT * FROM traseu;
rollback;

INSERT INTO CURSA VALUES(2000, 119, 1000, 182, SYSDATE, TO_DATE('05:43', 'HH24:MI'), TO_DATE('06:15', 'HH24:MI'),TO_DATE('21:59', 'HH24:MI'), TO_DATE('22:08', 'HH24:MI'), 17); --ok
INSERT INTO CURSA VALUES(2000, 1, 1000, 14, SYSDATE, TO_DATE('05:43', 'HH24:MI'), TO_DATE('06:15', 'HH24:MI'),TO_DATE('21:59', 'HH24:MI'), TO_DATE('22:08', 'HH24:MI'), 17); -- not ok
--119, 182, 1000
UPDATE CURSA SET numar_ture = 2 WHERE cod_cursa = 1000; --nepermis
UPDATE CURSA SET numar_traseu = 14 WHERE cod_cursa = 1000; --ok
UPDATE CURSA SET cod_vehicul_tr = 9096 WHERE cod_cursa = 1000; --modificare gresita

DELETE FROM cursa WHERE TO_CHAR(data_cursa, 'MM-YYYY') = '01-2023'; 

SELECT * FROM cursa WHERE cod_cursa = 1000;



/* CERINTA 12: trigger care se declanseaza de fiecare data cand se executa o operatie ldd */


CREATE TABLE audit_societate(
    utilizator  VARCHAR2(30),
    nume_bd VARCHAR2(30),
    eveniment VARCHAR2(20),
    tip_obiect_referit VARCHAR2(30),
    nume_obiect_referit VARCHAR2(30),
    data_comanda TIMESTAMP(3)
);

CREATE OR REPLACE TRIGGER ex12_ldd
    AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    INSERT INTO audit_societate VALUES
    (sys.login_user, sys.database_name, sys.sysevent, sys.dictionary_obj_type, 
    sys.dictionary_obj_name, systimestamp(3));
END;
/

CREATE OR REPLACE TYPE t_modele IS TABLE OF VARCHAR2(64);
/

CREATE OR REPLACE VIEW viz_vehicule AS
    SELECT v.cod_vehicul, v.producator, m.denumire, m.tip_mijloc_transport, TO_CHAR(v.an_achizitie, 'yyyy') "an_achiz"
    FROM vehicul v JOIN model m ON v.cod_model = m.cod_model;
    
DROP TYPE t_modele;

DROP VIEW viz_vehicule;

SELECT * FROM audit_societate;
--TRUNCATE TABLE audit_societate;