/* 
    CERINTA 4 & 5
    IMPLEMENTAREA TABELELOR + CONSTRANGERILOR
    INSERAREA DE INFORMATII IN TABELE
*/


CREATE TABLE ADRESA(
cod_adresa      NUMBER(5)       CONSTRAINT pk_adresa PRIMARY KEY,
nume_strada     VARCHAR2(50)    NOT NULL,
numar           VARCHAR2(10)    NOT NULL,
bloc            VARCHAR2(10),
apartament      NUMBER(5),
localitate      VARCHAR2(20)    NOT NULL,
judet           VARCHAR2(20)
);

--functie care imi genereaza un numar aleator intr-un interval
--al carui capete sunt date ca parametru
CREATE OR REPLACE FUNCTION random
(margin_left    NUMBER, margin_right   NUMBER)
RETURN NUMBER
IS
    nr NUMBER;
BEGIN
    nr := TRUNC(dbms_random.value(margin_left, margin_right + 1));
    RETURN nr;
END;
/
 
 
CREATE OR REPLACE TYPE t_denumiri IS TABLE OF VARCHAR2(128);
/



DECLARE
    v_strazi    t_denumiri  := t_denumiri('Str. Mihai Eminescu', 'Calea Dorobantilor', 'Bd. Unirii', 'Str. Lizeanu',
                                           'Bd. Bucurestii Noi', 'Bd. Timisoara', 'Bd. Theodor Pallady', 'Str. Tony Bulandra',
                                           'Sos. Colentina', 'Str. Preciziei', 'Bd. Octavian Goga', 'Str. Nitu Vasile',
                                           'Str. Gioachino Rossini', 'Str. Teilor', 'Bd. Iuliu Maniu', 'Bd. Dacia', 'Sos. Andronache',
                                           'Str. Lalelelor', 'Str. Parcului', 'Str. Arcului', 'Str. Eroilor',
                                           'Str. Rozelor', 'Str. Lacului');
    localitati  t_denumiri  := t_denumiri('Otopeni', 'Voluntari', 'Bragadiru', 'Afumati', 'Popesti-Leordeni');
    blocuri     t_denumiri  := t_denumiri('OT5', 'T7A', '25B', '20', 'K1', 'K2', 'T5', 'T6', '14C', 'ABC');
    v_strada        VARCHAR2(50);
    indice_strada   NUMBER;
    indice_loc      NUMBER;
    v_numar_strada  NUMBER;
    v_apartament    NUMBER;
BEGIN
    FOR i IN 1..60 LOOP
        IF i BETWEEN 1 AND 45 THEN
            indice_strada := random(1, 17);
        ELSE 
            indice_strada := random(18, 23);
        END IF;
        v_strada := v_strazi(indice_strada);
        v_numar_strada := random(1, 200);
        IF i BETWEEN 36 AND 45 THEN
            v_apartament := random(1, 42);
            INSERT INTO ADRESA VALUES(i, v_strada, v_numar_strada, blocuri(i-35), v_apartament, 'Bucuresti', null);
            CONTINUE;
        ELSIF i BETWEEN 46 AND 60 THEN
            indice_loc := random(1, localitati.count);
            INSERT INTO ADRESA VALUES(i, v_strada, v_numar_strada, null, null, localitati(indice_loc), 'Ilfov');
            CONTINUE;
        END IF;
        INSERT INTO ADRESA(cod_adresa, nume_strada, numar, localitate) 
            VALUES(i, v_strada, v_numar_strada, 'Bucuresti');
    END LOOP;
END;
/
SELECT * FROM ADRESA;
--TRUNCATE TABLE ADRESA;




CREATE TABLE FURNIZOR(
cod_furnizor    NUMBER(3)      CONSTRAINT pk_furnizor PRIMARY KEY,
nume            VARCHAR2(50)   NOT NULL,
numar_telefon   CHAR(12)       NOT NULL,
adresa_email    VARCHAR2(50)
);

CREATE SEQUENCE seq_furn
MAXVALUE 999
NOCYCLE NOCACHE;

INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'Alstom', '+40212721700', 'contact@transport.alstom.com');
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'Siemens', '+40216296400', 'siemens.ro@siemens.com');
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'TisTram', '+48516178828', 'kontakt@tistram.com');
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'MEXIMPEX SRL', '+40213166847', null);
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'Schaeffler Romania', '+40268505000', 'info.ro@schaeffler.com');
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'Unix Automotive', '+40264501899', null);
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'Räder-Vogel', '+494075499-0', 'rv@raedervogel.de');
INSERT INTO FURNIZOR VALUES(seq_furn.NEXTVAL, 'FAUR SA', '+40212556559', 'faur_marketing@bega.ro');

SELECT * FROM FURNIZOR;


CREATE TABLE MODEL(
cod_model               NUMBER(5)       CONSTRAINT pk_model PRIMARY KEY,
denumire                VARCHAR2(20)    UNIQUE NOT NULL,
tip_mijloc_transport    VARCHAR2(20)    CHECK (tip_mijloc_transport IN ('tramvai', 'autobuz', 'troleibuz')),
lungime                 NUMBER(2),
numar_scaune            NUMBER(3),
capacitate_calatori     NUMBER(3),
viteza_maxima           NUMBER(5,2)
);

ALTER TABLE MODEL MODIFY denumire VARCHAR2(64);

CREATE SEQUENCE seq_model
INCREMENT BY 1 START WITH 1000
MAXVALUE 99999
NOCYCLE NOCACHE;

INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Kent C12', 'autobuz', 9, 28, 65, 80.6);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Kent C18', 'autobuz', 15, 52, 160, 75.8);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Trollino 12', 'troleibuz', 11, 32, 74, 75);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, '415T', 'troleibuz', 8, 28, 88, 55);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Citaro (Euro III)', 'autobuz', 10, 40, 81, 65.5);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Citaro 2 (Euro IV)', 'autobuz', 10, 40, 81, 69.8);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Imperio Metropolitan', 'tramvai', 32, 80, 320, 66.6);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'T4R', 'tramvai', 26, 48, 256, 55.6);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, '260', 'autobuz', 8, 32, 88, 52);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'Citelis 12T', 'troleibuz', 16, 50, 160, 77.8);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'V3A-93', 'tramvai', 24, 66, 250, 50.6);
INSERT INTO MODEL VALUES(seq_model.NEXTVAL, 'm5.65', 'tramvai', 14, 32, 74, 80.6);
--pentru vehiculele de interventie (tramvai plug)
INSERT INTO MODEL(cod_model, denumire) VALUES(seq_model.NEXTVAL, '1VU');

SELECT * FROM MODEL;




CREATE TABLE TRASEU(
numar_traseu            NUMBER(3)                 CONSTRAINT pk_traseu PRIMARY KEY,
lungime                 NUMBER(5,2)               NOT NULL,
categorie               VARCHAR2(15)              NOT NULL CHECK(categorie IN ('urban', 'regional', 'de noapte')),
frecventa               INTERVAL DAY TO SECOND    NOT NULL,
medie_calatori          NUMBER(6)                 NOT NULL,
data_infiintare         DATE                      NOT NULL,
data_suspendare         DATE
);

ALTER TABLE TRASEU MODIFY data_infiintare DEFAULT TO_DATE('01/09/1990', 'DD/MM/YYYY');

INSERT INTO TRASEU VALUES(1, 35.7, 'urban', INTERVAL '8' MINUTE, 35000, DEFAULT, null);
INSERT INTO TRASEU VALUES(5, 12, 'urban', INTERVAL '15' MINUTE, 5000, DEFAULT, TO_DATE('01/12/2023', 'DD/MM/YYYY'));
INSERT INTO TRASEU VALUES(14, 8.9, 'urban', INTERVAL '20' MINUTE, 1500, TO_DATE('01/05/2001', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(21, 33.2, 'urban', INTERVAL '5' MINUTE, 22000, DEFAULT, null);
INSERT INTO TRASEU VALUES(66, 8.2, 'urban', INTERVAL '20' MINUTE, 4500, DEFAULT, null);
INSERT INTO TRASEU VALUES(73, 18, 'urban', INTERVAL '12' MINUTE, 8200, TO_DATE('15/12/2024', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(85, 12, 'urban', INTERVAL '9' MINUTE, 5100, DEFAULT, null);
INSERT INTO TRASEU VALUES(182, 14.5, 'urban', INTERVAL '13' MINUTE, 7600, DEFAULT, null);
INSERT INTO TRASEU VALUES(104, 21, 'urban', INTERVAL '4' MINUTE, 13200, TO_DATE('01/05/2001', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(381, 15, 'urban', INTERVAL '7' MINUTE, 14400, TO_DATE('01/05/2001', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(605, 12, 'urban', INTERVAL '20' MINUTE, 4000, TO_DATE('01/12/2023', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(441, 42, 'regional', INTERVAL '40' MINUTE, 3500, DEFAULT, null);
INSERT INTO TRASEU VALUES(413, 28, 'regional', INTERVAL '50' MINUTE, 500, DEFAULT, null);
INSERT INTO TRASEU VALUES(901, 13, 'de noapte', INTERVAL '30' MINUTE, 2500, TO_DATE('01/06/2024', 'DD/MM/YYYY'), null);
INSERT INTO TRASEU VALUES(902, 7.9, 'de noapte', INTERVAL '60' MINUTE, 1500, TO_DATE('01/06/2024', 'DD/MM/YYYY'), null);
SELECT * FROM TRASEU;


CREATE TABLE STATIE(
cod_statie          NUMBER(5)       CONSTRAINT pk_statie PRIMARY KEY,
nume                VARCHAR2(25)    NOT NULL UNIQUE,
localitate          VARCHAR2(25)    NOT NULL,
artera              VARCHAR2(100)   NOT NULL
);

ALTER TABLE STATIE MODIFY nume VARCHAR2(64);

DECLARE
    v_statii_1    t_denumiri := t_denumiri('Lizeanu', 'Bucur Obor', 'Doamna Ghica', 'Bd. Ferdinand', 'Piata Iancului',
    'Vasile Lascar', 'Vatra Luminoasa', 'Pasaj Victoria', 'Piata Muncii', 'Stadionul National', 'Baba Novac', 'I.O.R.',
    'Piata Titan', 'Piata Dorobanti', 'Arcul de Triumf', 'Piata Charles de Gaulle', 'Parcul Herastrau','Piata 1 Mai', 
    'Clabucet', 'Bd. Laminorului', 'Parc Bazilescu', 'Circul Globus', 'Piata Gemeni', 'Armeneasca', 'Scoala Iancului', 
    'Piata Sudului', 'Piata Crangasi', 'Gradina Cismigiu', 'Gradina Botanica', 'Baicului', 'Raul Doamnei',
    'Valea Oltului', 'Valea Ialomitei', 'Parc Drumul Taberei', 'Favorit', 'Orizont', 'Izvor', 'Piata Unirii 1', 
    'Piata Unirii 2', 'Tineretului', 'Timpuri Noi', 'Piata Resita', 'Piata Sf. Gheorghe', 'Pasaj Colentina',
    'Cimitirul Bellu', 'Piata Danny Huwe', 'Piata Regina Maria', 'Gara de Nord', 'Gara Basarab', 'Podul Grant', 
    'Lujerului', 'Pacii', 'Dristorului', 'Universitate', 'Piata Rosetti', 'Mihai Eminescu', 'Valea Cascadelor', 
    'Preciziei', 'C.F.R. Progresul', 'I.M.G.B.', 'Delfinului', 'Granitul', 'Sfanta Vineri');
    
    strazi_1    t_denumiri  := t_denumiri('Sos. Stefan Cel Mare', 'Sos. Colentina', 'Bd. Nicolae Grigorescu',
    'Bd. Regina Elisabeta', 'Str. Barbu Vacarescu', 'Calea Floreasca', 'Str. Turnu Magurele', 'Sos. Giurgiului',
    'Sos. Alexandriei', 'Calea Serban Voda', 'Bd. Carol I', 'Bd. Drumul Taberei', 'Sos. Virtutii', 'Sos. Pantelimon',
    'Bd. Iancu de Hunedoara', 'Bd. Ion Mihalache');
    
    v_statii_2  t_denumiri  :=  t_denumiri('Gladiolelor', 'Biserica', 'Acvila', 'Crinului', 'Cimitir Ghencea', 'Pasaj Lujerului',
    'Crizantemelor', 'Primaria Clinceni', 'Soseaua de Centura', 'Cartierul Latin');
    strazi_2    t_denumiri  := t_denumiri('Str. Lalelelor', 'Str. Parcului', 'Str. Arcului', 'Str. Eroilor');  
    v_localitate  VARCHAR2(25);
    i_strada      NUMBER;
    
BEGIN
    --statiile din Bucuresti 
    FOR i IN 1..v_statii_1.last LOOP
        i_strada := random(1, strazi_1.count);
        INSERT INTO STATIE VALUES(1000 + i, v_statii_1(i), 'Bucuresti', strazi_1(i_strada));
    END LOOP;
    --statiile din afara Bucurestiului
    FOR i IN 1..v_statii_2.last LOOP
        i_strada := random(1, strazi_2.count);
        IF i MOD 3 = 0 THEN v_localitate := 'Bragadiru';
        ELSIF i MOD 3 = 1 THEN v_localitate := 'Domnesti';
        ELSE v_localitate := 'Clinceni';
        END IF;
        INSERT INTO STATIE VALUES(2000 + i, v_statii_2(i), v_localitate, strazi_2(i_strada));
    END LOOP;
END;
/
SELECT * FROM STATIE;

CREATE TABLE INTERVENTIE(
numar_interventie       NUMBER(5)                   CONSTRAINT pk_interventie PRIMARY KEY,
data_interventie        TIMESTAMP WITH TIME ZONE    NOT NULL,              
cauza                   VARCHAR2(100)               NOT NULL,              
durata                  INTERVAL DAY TO SECOND      NOT NULL
);


DECLARE
    cauze_interventii  t_denumiri := t_denumiri('Copaci cazuti pe reteaua de contact', 'Eveniment circulatie', 
    'Lipsa tensiune', 'Deszapezire', 'Eveniment circulatie');
    v_data      TIMESTAMP WITH TIME ZONE;
    v_durata    NUMBER;
    indice      NUMBER;
BEGIN
    FOR i IN 800..830 LOOP
        v_data := SYSDATE - INTERVAL '1' DAY * random(0, 365) + INTERVAL '1' SECOND * random(0, 86400);
        v_durata := random(1, 30) * 10;
        indice := i MOD 5 + 1;
        INSERT INTO INTERVENTIE VALUES(i, v_data, cauze_interventii(indice), TO_DSINTERVAL('PT' || v_durata || 'M'));
    END LOOP;
END;
/
SELECT * FROM INTERVENTIE;


CREATE TABLE DEPOU(
cod_depou               NUMBER(5)       CONSTRAINT pk_depou PRIMARY KEY,
denumire                VARCHAR2(50)    UNIQUE NOT NULL,
an_infiintare           DATE            NOT NULL,
categorie               VARCHAR2(50)    NOT NULL CHECK(categorie IN('autobaza', 'depou tramvaie', 'depou troleibuze', 'depou mixt')),
capacitate_autobuze     NUMBER(3),
capacitate_troleibuze   NUMBER(3),
capacitate_tramvaie     NUMBER(3),
cod_adresa              NUMBER(5)  
CONSTRAINT fk_depou_adr       REFERENCES ADRESA(cod_adresa) ON DELETE SET NULL,
CONSTRAINT adr_depou_unic     UNIQUE(cod_adresa)
);  

INSERT INTO DEPOU VALUES(101, 'Depoul Bujoreni', TO_DATE('01/06/1998', 'dd/mm/yyyy'), 'depou mixt', 20, 15, null, 15);
INSERT INTO DEPOU VALUES(201, 'Depoul Bucurestii Noi', TO_DATE('01/06/1985', 'dd/mm/yyyy'), 'depou mixt', null, 30, 30, 27);
INSERT INTO DEPOU VALUES(301, 'Depoul Titan', TO_DATE('01/06/1988', 'dd/mm/yyyy'), 'depou mixt', 40, null, 20, 5);
INSERT INTO DEPOU VALUES(401, 'Depoul Militari', TO_DATE('01/06/2000', 'dd/mm/yyyy'), 'depou mixt', 20, 15, 15, 29);
INSERT INTO DEPOU VALUES(501, 'Depoul Floreasca', TO_DATE('01/06/1990', 'dd/mm/yyyy'), 'autobaza', 10, null, null, 21);
INSERT INTO DEPOU VALUES(601, 'Depoul Vatra Luminoasa', TO_DATE('01/06/1980', 'dd/mm/yyyy'), 'depou troleibuze', null, 15, null, 11);
INSERT INTO DEPOU VALUES(701, 'Depoul Colentina', TO_DATE('01/06/1979', 'dd/mm/yyyy'), 'depou tramvaie', null, null, 30, 1);
SELECT * FROM DEPOU;



CREATE TABLE VEHICUL(
cod_vehicul         NUMBER(5)       CONSTRAINT pk_vehicul PRIMARY KEY,
producator          VARCHAR2(25)    NOT NULL,
an_achizitie        DATE            NOT NULL,
data_verificare     DATE            DEFAULT TO_DATE('06/01/2025', 'dd/mm/yyyy'),
stare               VARCHAR2(20)    DEFAULT 'functional' 
                                    CONSTRAINT verif_stare CHECK(stare IN('functional', 'defect', 'in reparatie')),               
kilometraj          NUMBER(10)      DEFAULT 0,
intrebuintare       VARCHAR2(20)    CHECK(intrebuintare IN('transport', 'interventie')),
cod_depou           NUMBER(5)       NOT NULL,
cod_model           NUMBER(5),
CONSTRAINT fk_veh_dep FOREIGN KEY (cod_depou) REFERENCES DEPOU(cod_depou) ON DELETE SET NULL,
CONSTRAINT fk_veh_mod FOREIGN KEY (cod_model) REFERENCES MODEL(cod_model) ON DELETE SET NULL
);

CREATE TYPE t_coduri IS TABLE OF NUMBER;
/
CREATE TYPE t_date IS TABLE OF DATE;
/

DECLARE 
    v_coduri_modele  t_coduri;
    producatori      t_denumiri;
    an_achiz         DATE;
    ani_achiz        t_date;
    v_date_verif     t_date     := t_date(TO_DATE('15/10/2024', 'dd/mm/yyyy'), TO_DATE('15/10/2022', 'dd/mm/yyyy'), TO_DATE('15/11/2018', 'dd/mm/yyyy'));
    nr_linie         NUMBER := 0;
    v_data           DATE;
    v_cod_veh        NUMBER;
    nr_veh_per_dep   NUMBER := 1;
    v_stare          VARCHAR2(20);
    v_km             NUMBER;
    
BEGIN
    --AUTOBUZE
    SELECT cod_model BULK COLLECT INTO v_coduri_modele FROM MODEL WHERE tip_mijloc_transport LIKE 'autobuz';
    producatori := t_denumiri('Otokar', 'Otokar', 'Mercedes Benz', 'Mercedes Benz', 'Ikarus');
    ani_achiz   := t_date(TO_DATE('2018', 'yyyy'), TO_DATE('2018', 'yyyy'), TO_DATE('2007', 'yyyy'), TO_DATE('2009', 'yyyy'), TO_DATE('1991', 'yyyy'));
    FOR i IN 1..v_coduri_modele.last LOOP
        FOR i_dep IN (SELECT cod_depou FROM depou WHERE capacitate_autobuze IS NOT NULL) LOOP
            FOR k IN 1..nr_veh_per_dep LOOP
                v_cod_veh := 1000 + nr_linie;
                v_km := random(10000, 500000);
                IF nr_linie MOD 4 = 0 THEN v_data := v_date_verif(1);
                ELSE v_data :=  TO_DATE('06/01/2025', 'dd/mm/yyyy');
                END IF;
                IF nr_linie MOD 6 = 0 THEN v_stare := 'in reparatie';
                ELSIF nr_linie MOD 8 = 0 THEN v_stare := 'defect';
                ELSE v_stare := 'functional';
                END IF;
                INSERT INTO vehicul 
                VALUES(v_cod_veh, producatori(i), ani_achiz(i), v_data, v_stare, v_km, 'transport', i_dep.cod_depou, v_coduri_modele(i));
                nr_linie := nr_linie + 1;
            END LOOP;
            nr_veh_per_dep := nr_veh_per_dep MOD 3 + 1;
        END LOOP;
    END LOOP;
    
    --TROLEIBUZE
    SELECT cod_model BULK COLLECT INTO v_coduri_modele FROM MODEL WHERE tip_mijloc_transport LIKE 'troleibuz';
    producatori := t_denumiri('Solaris', 'Ikarus', 'Astra Irisbus');
    ani_achiz := t_date(TO_DATE('2022', 'yyyy'), TO_DATE('1999', 'yyyy'), TO_DATE('2007', 'yyyy'));
    FOR i IN 1..v_coduri_modele.last LOOP
        FOR i_dep IN (SELECT cod_depou FROM depou WHERE capacitate_troleibuze IS NOT NULL) LOOP
            FOR k IN 1..nr_veh_per_dep LOOP
                v_cod_veh := 5000 + nr_linie;
                v_km := random(10000, 500000);
                
                IF nr_linie MOD 5 = 0 THEN v_data := v_date_verif(2);
                ELSE v_data :=  TO_DATE('06/01/2025', 'dd/mm/yyyy');
                END IF;
                
                IF nr_linie MOD 8 = 0 THEN v_stare := 'in reparatie';
                ELSIF nr_linie MOD 5 = 0 THEN v_stare := 'defect';
                ELSE v_stare := 'functional';
                END IF;
                
                INSERT INTO vehicul 
                VALUES(v_cod_veh, producatori(i), ani_achiz(i), v_data, v_stare, v_km, 'transport', i_dep.cod_depou, v_coduri_modele(i));
                nr_linie := nr_linie + 1;
            END LOOP;
            nr_veh_per_dep := nr_veh_per_dep MOD 3 + 1;
        END LOOP;
    END LOOP;
    
    --TRAMVAIE
    SELECT cod_model BULK COLLECT INTO v_coduri_modele FROM MODEL WHERE tip_mijloc_transport LIKE 'tramvai';
    producatori := t_denumiri('Astra Arad', 'CKD Praga', 'R.A.T.B. URAC', 'Rathgeber München');
    ani_achiz := t_date(TO_DATE('2024', 'yyyy'), TO_DATE('1975', 'yyyy'), TO_DATE('1999', 'yyyy'), TO_DATE('1960', 'yyyy'));
    FOR i IN 1..v_coduri_modele.last LOOP
        FOR i_dep IN (SELECT cod_depou FROM depou WHERE capacitate_tramvaie IS NOT NULL) LOOP
            FOR k IN 1..nr_veh_per_dep LOOP
                v_cod_veh := 9000 + nr_linie;
                v_km := random(10000, 500000);
                
                IF i = 3 THEN an_achiz := TO_DATE(random(1991, 2008), 'yyyy');
                ELSE an_achiz := ani_achiz(i);
                END IF;
                
                IF nr_linie MOD 3 = 0 THEN v_data := v_date_verif(1);
                ELSE v_data :=  TO_DATE('06/01/2025', 'dd/mm/yyyy');
                END IF;
                
                IF nr_linie MOD 7 = 0 THEN v_stare := 'in reparatie';
                ELSIF nr_linie MOD 6 = 0 THEN v_stare := 'defect';
                ELSE v_stare := 'functional';
                END IF;
                
                INSERT INTO vehicul 
                VALUES(v_cod_veh, producatori(i), an_achiz, v_data, v_stare, v_km, 'transport', i_dep.cod_depou, v_coduri_modele(i));
                nr_linie := nr_linie + 1;
            END LOOP;
            nr_veh_per_dep := nr_veh_per_dep MOD 4 + 1;
        END LOOP;
    END LOOP;
    
    --VEHICULE DE INTERVENTIE
    INSERT INTO VEHICUL VALUES(1, 'MAN', TO_DATE('2006', 'yyyy'), TO_DATE('13/10/2014', 'dd/mm/yyyy'), 'functional', 14090, 'interventie', 101, null);
    INSERT INTO VEHICUL VALUES(2, 'Mercedes', TO_DATE('1999', 'yyyy'), TO_DATE('15/11/2018', 'dd/mm/yyyy'), 'functional', 108900, 'interventie', 301, null);
    INSERT INTO VEHICUL VALUES(3, 'ROMAN', TO_DATE('1973', 'yyyy'), TO_DATE('13/10/2014', 'dd/mm/yyyy'), 'functional', 549720, 'interventie', 401, null);
    INSERT INTO VEHICUL VALUES(4, 'ROMAN', TO_DATE('1975', 'yyyy'), TO_DATE('13/10/2014', 'dd/mm/yyyy'), 'functional', 519730, 'interventie', 501, null);
    INSERT INTO VEHICUL VALUES(5, 'I.T.B.', TO_DATE('1966', 'yyyy'), TO_DATE('13/10/2000', 'dd/mm/yyyy'), 'functional', 14000, 'interventie', 201, 1012);
    INSERT INTO VEHICUL VALUES(6, 'I.T.B.', TO_DATE('1967', 'yyyy'), TO_DATE('13/10/1999', 'dd/mm/yyyy'), 'functional', 14001, 'interventie', 401, 1012);
    INSERT INTO VEHICUL VALUES(7, 'I.T.B.', TO_DATE('1968', 'yyyy'), TO_DATE('13/10/2000', 'dd/mm/yyyy'), 'functional', 14002, 'interventie', 701, 1012);
    INSERT INTO VEHICUL VALUES(8, 'Ikarus', TO_DATE('1991', 'yyyy'), TO_DATE('13/10/2002', 'dd/mm/yyyy'), 'functional', 14003, 'interventie', 601, 1003);
    INSERT INTO VEHICUL VALUES(9, 'Iveco', TO_DATE('2008', 'yyyy'), TO_DATE('13/10/2012', 'dd/mm/yyyy'), 'functional', 18300, 'interventie', 101, null);
    INSERT INTO VEHICUL VALUES(10, 'Iveco', TO_DATE('2008', 'yyyy'), TO_DATE('13/10/2012', 'dd/mm/yyyy'), 'functional', 18301, 'interventie', 301, null);
    INSERT INTO VEHICUL VALUES(11, 'Iveco', TO_DATE('2008', 'yyyy'), TO_DATE('13/10/2012', 'dd/mm/yyyy'), 'functional', 18302, 'interventie', 401, null);
    INSERT INTO VEHICUL VALUES(12, 'Iveco', TO_DATE('2008', 'yyyy'), TO_DATE('13/10/2012', 'dd/mm/yyyy'), 'functional', 18303, 'interventie', 501, null);
END;
/

SELECT * FROM vehicul;
TRUNCATE TABLE vehicul;



CREATE TABLE VEHICUL_TRANSPORT(
cod_vehicul_tr      NUMBER(5)       CONSTRAINT pk_veh_tr PRIMARY KEY,
CONSTRAINT fk_veh_tr FOREIGN KEY (cod_vehicul_tr) REFERENCES VEHICUL(cod_vehicul) ON DELETE CASCADE
);

DECLARE
    v_coduri_veh_tr  t_coduri  := t_coduri();
BEGIN
    SELECT cod_vehicul BULK COLLECT INTO v_coduri_veh_tr FROM vehicul WHERE intrebuintare = 'transport';
    FORALL i IN 1..v_coduri_veh_tr.last 
        INSERT INTO vehicul_transport VALUES (v_coduri_veh_tr(i));
END;
/
SELECT * FROM vehicul_transport;


CREATE TABLE VEHICUL_INTERVENTIE(
cod_vehicul_int         NUMBER(5)       CONSTRAINT pk_veh_int PRIMARY KEY,
categorie_utilitate     VARCHAR2(50)    NOT NULL,
CONSTRAINT fk_veh_int FOREIGN KEY(cod_vehicul_int) REFERENCES VEHICUL(cod_vehicul) ON DELETE CASCADE
);

INSERT INTO vehicul_interventie VALUES(1, 'vehicul pentru deszapezit');
INSERT INTO vehicul_interventie VALUES(2, 'vehicul remorcare');
INSERT INTO vehicul_interventie VALUES(3, 'vehicul remorcare');
INSERT INTO vehicul_interventie VALUES(4, 'autospeciala sudura');
INSERT INTO vehicul_interventie VALUES(5, 'tramvai plug');
INSERT INTO vehicul_interventie VALUES(6, 'tramvai utilitar');
INSERT INTO vehicul_interventie VALUES(7, 'tramvai utilitar');
INSERT INTO vehicul_interventie VALUES(8, 'troleibuz utilitar');
INSERT INTO vehicul_interventie VALUES(9, 'autospeciala interventie retea');
INSERT INTO vehicul_interventie VALUES(10, 'vehicul remorcare');
INSERT INTO vehicul_interventie VALUES(11, 'automacara');
INSERT INTO vehicul_interventie VALUES(12, 'autospeciala interventie retea');
SELECT * FROM vehicul_interventie;
TRUNCATE TABLE vehicul_interventie;

CREATE TABLE PARCURS_TRASEU(
numar_traseu        NUMBER(3)       CONSTRAINT fk_parcurs_trs  REFERENCES TRASEU(numar_traseu) ON DELETE CASCADE,
cod_statie          NUMBER(5)       CONSTRAINT fk_parcurs_stat REFERENCES STATIE(cod_statie) ON DELETE CASCADE,
numar_ordine        NUMBER(3),
CONSTRAINT pk_parcurs PRIMARY KEY(numar_traseu, cod_statie)
);

DROP TABLE PARCURS_TRASEU;


DECLARE
    TYPE t_statii   IS TABLE OF statie%rowtype;
    TYPE t_parcurs  IS TABLE OF parcurs_traseu%rowtype;
    v_statii_buc        t_statii := t_statii();
    nr_statie_start     NUMBER;
    nr_statii_traseu    NUMBER;
    statii_5            t_parcurs := t_parcurs();
    nr_ord_statie       NUMBER;
BEGIN
    FOR i IN (SELECT numar_traseu FROM traseu WHERE numar_traseu NOT IN(605, 441, 413)) LOOP
        nr_ord_statie := 1;
        IF i.numar_traseu MOD 2 = 0 THEN
            SELECT * BULK COLLECT INTO v_statii_buc FROM statie WHERE localitate = 'Bucuresti' ORDER BY 4;
        ELSE
            SELECT * BULK COLLECT INTO v_statii_buc FROM statie WHERE localitate = 'Bucuresti' ORDER BY 4 DESC;
        END IF;
        nr_statie_start := random(1, 48);
        nr_statii_traseu := random(5, 15);
        FOR k IN nr_statie_start..nr_statie_start + nr_statii_traseu LOOP
            INSERT INTO PARCURS_TRASEU VALUES(i.numar_traseu, v_statii_buc(k).cod_statie, nr_ord_statie);
            nr_ord_statie := nr_ord_statie + 1;
        END LOOP;
    END LOOP;
    
    --traseul 605 are aceleasi statii ca si traseul 5 (cel suspendat)
    SELECT * BULK COLLECT INTO statii_5 FROM parcurs_traseu WHERE numar_traseu = 5;
    FORALL i IN 1..statii_5.last 
        INSERT INTO PARCURS_TRASEU VALUES(605, statii_5(i).cod_statie, statii_5(i).numar_ordine);
        
    --traseele regionale au o statie in bucuresti (aceeasi statie terminus) si restul in localitati din Ilfov
    INSERT INTO PARCURS_TRASEU VALUES(413, 1051, 1);
    INSERT INTO PARCURS_TRASEU VALUES(441, 1051, 1);
    
    SELECT * BULK COLLECT INTO v_statii_buc FROM statie WHERE localitate <> 'Bucuresti';
    nr_statie_start := random(1, 5);
    nr_statii_traseu := random(3, 5);
    nr_ord_statie := 2;
    FOR k IN nr_statie_start..nr_statie_start + nr_statii_traseu LOOP
        INSERT INTO PARCURS_TRASEU VALUES(413, v_statii_buc(k).cod_statie, nr_ord_statie);
        nr_ord_statie := nr_ord_statie + 1;
    END LOOP;
    
    SELECT * BULK COLLECT INTO v_statii_buc FROM statie WHERE localitate <> 'Bucuresti' ORDER BY 1 DESC;
    nr_statie_start := random(1, 5);
    nr_statii_traseu := random(3, 5);
    nr_ord_statie := 2;
    FOR k IN nr_statie_start..nr_statie_start + nr_statii_traseu LOOP
        INSERT INTO PARCURS_TRASEU VALUES(441, v_statii_buc(k).cod_statie, nr_ord_statie);
        nr_ord_statie := nr_ord_statie + 1;
    END LOOP;   
END;
/

select * from parcurs_traseu;
SELECT pt.numar_traseu, pt.cod_statie, s.nume, s.artera, pt.numar_ordine
FROM parcurs_traseu pt JOIN statie s ON pt.cod_statie = s.cod_statie
ORDER BY 1, 5;
--truncate table parcurs_traseu;
--SELECT * FROM statie WHERE localitate = 'Bucuresti' ORDER BY 4;


CREATE TABLE OBSERVATIE(
cod_observatie      NUMBER(5)       CONSTRAINT pk_observ  PRIMARY KEY,
descriere           VARCHAR2(256)   NOT NULL,
data_obs            DATE            NOT NULL,
cod_vehicul         NUMBER(5)       NOT NULL,
CONSTRAINT fk_observ_veh FOREIGN KEY (cod_vehicul) REFERENCES VEHICUL(cod_vehicul)
);


INSERT INTO OBSERVATIE VALUES(1001, 'Retras definitiv din circulatie', SYSDATE, 9078);
INSERT INTO OBSERVATIE VALUES(1002, 'Transferat de la Dep. Bujoreni la Dep. Militari', TO_DATE('01/05/2023', 'DD/MM/YYYY'), 5054);
INSERT INTO OBSERVATIE VALUES(1003, 'Reparat capital', TO_DATE('01/02/2012', 'DD/MM/YYYY'), 5054);
INSERT INTO OBSERVATIE VALUES(1004, 'Transformat in vehicul utilitar', TO_DATE('01/02/2012', 'DD/MM/YYYY'), 8);
INSERT INTO OBSERVATIE VALUES(1005, 'Retras definitiv din circulatie, propus spre casare', SYSDATE, 1032);
SELECT * FROM observatie;

CREATE TABLE ANGAJAT(
cod_angajat         NUMBER(5)          CONSTRAINT pk_angajat PRIMARY KEY,
nume                VARCHAR2(25)       NOT NULL,
prenume             VARCHAR2(25)       NOT NULL,
numar_telefon       CHAR(12)           UNIQUE,
data_angajare       DATE               DEFAULT TO_DATE('01-01-2000','DD-MM-YYYY'),
salariu             NUMBER(5)          NOT NULL CHECK(salariu > 0),
tip_job             VARCHAR2(25)       NOT NULL,
cod_adresa          NUMBER(5)          CONSTRAINT fk_ang_adr REFERENCES ADRESA(cod_adresa) ON DELETE SET NULL,
cod_depou           NUMBER(5)          CONSTRAINT fk_ang_dep REFERENCES DEPOU(cod_depou) ON DELETE SET NULL
);


DECLARE
    v_nume  t_denumiri := t_denumiri('Ionescu', 'Popescu', 'Andrei', 'Grigore', 'Popa', 'Dumitrescu', 'Dumitru', 
    'Marinescu', 'Anghelescu', 'Stan', 'Rudeanu', 'Udrea', 'Ciobanu', 'Moise', 'Stoica', 'Moldoveanu', 'Iordache',
    'Militaru', 'Constantinescu', 'Nita', 'Ionita', 'Tudor', 'Dobre', 'Nistor', 'Florea', 'Stanciu', 'Gheorghiu');
    v_prenume t_denumiri := t_denumiri('Gheorghe', 'Marian', 'Andrei', 'Teodor', 'Alexandru', 'Marius', 'Costantin',
    'Tudor', 'Laurentiu', 'Nicolae', 'Paul', 'Radu', 'Sorin', 'Toma', 'Traian', 'Vicentiu', 'Ioana', 'Florina',
    'Ecaterina', 'Daniela', 'Carmen', 'Maria', 'Georgeta', 'Sorina', 'Cristina', 'Ana', 'Luminita', 'Monica', 'Viorica');
    v_telefon       NUMBER;
    v_data_ang      VARCHAR2(16);
    v_salariu       NUMBER;
    v_job           VARCHAR2(25);
    v_adresa        NUMBER;
    v_depou         NUMBER;
    indice_nume     NUMBER;
    indice_prenume  NUMBER;
BEGIN
    FOR i IN 100..159 LOOP
        indice_nume := random(1, v_nume.count);
        indice_prenume := random(1, v_prenume.count);
        v_telefon := random(700000000, 799999999);
        v_data_ang := random(1, 28) || '/' || random(1, 12) || '/' || random(1990, 2014);
        IF i BETWEEN 100 AND 129 THEN v_salariu := random(450, 600) * 10;
        ELSIF i BETWEEN 130 AND 144 THEN v_salariu := random(400, 500) * 10;
        ELSIF i BETWEEN 145 AND 149 THEN v_salariu := random(700, 900) * 10;
        ELSE v_salariu := random(250, 300) * 10;
        END IF;
        
        IF i BETWEEN 100 AND 129 THEN v_job := 'sofer';
        ELSIF i BETWEEN 130 AND 144 THEN v_job := 'mecanic';
        ELSIF i BETWEEN 145 AND 149 THEN v_job := 'inginer';
        ELSE v_job := 'muncitor necalificat';
        END IF;
        v_adresa := random(1, 60);
        v_depou := (i MOD 7 + 1) * 100 + 1;
        INSERT INTO ANGAJAT VALUES(i, v_nume(indice_nume), v_prenume(indice_prenume), '+40' || v_telefon, 
        TO_DATE(v_data_ang, 'DD/MM/YYYY'), v_salariu, v_job, v_adresa, v_depou);
    END LOOP;
END;
/
TRUNCATE TABLE ANGAJAT;
SELECT * FROM ANGAJAT;

CREATE TABLE SOFER(
cod_sofer           NUMBER(5)           CONSTRAINT pk_sofer PRIMARY KEY,
experienta          NUMBER(2)           NOT NULL,
categorie_permis    VARCHAR2(5)         NOT NULL CHECK(categorie_permis IN('BUS', 'TRAM', 'TRL')),
data_expirare       DATE                DEFAULT TO_DATE('31/05/2025', 'dd-mm-yyyy'),
CONSTRAINT fk_sofer_ang FOREIGN KEY(cod_sofer) REFERENCES ANGAJAT(cod_angajat) ON DELETE CASCADE
);

SELECT * FROM depou;

DECLARE
    v_exp           NUMBER;
    v_categ         VARCHAR2(5);
    v_permise       t_denumiri;
    permis_random   NUMBER;
    v_data_exp      DATE;
BEGIN
    FOR c IN (SELECT cod_angajat, cod_depou FROM angajat WHERE tip_job = 'sofer') LOOP
        v_exp := random(5, 40);
        v_permise := t_denumiri();
        IF c.cod_depou IN (101, 301, 401, 501) THEN 
            v_permise.extend;
            v_permise(v_permise.last) := 'BUS';
        END IF;
        IF c.cod_depou IN (101, 201, 401, 601) THEN 
            v_permise.extend;
            v_permise(v_permise.last) := 'TRL';
        END IF;
        IF c.cod_depou IN (201, 301, 401, 701) THEN 
            v_permise.extend;
            v_permise(v_permise.last) := 'TRAM';
        END IF;
        
        v_data_exp := SYSDATE + 365 * (v_permise.count);
        permis_random := random(1, v_permise.last);
        INSERT INTO SOFER VALUES(c.cod_angajat, v_exp, v_permise(permis_random), v_data_exp);
    END LOOP;    
END;
/
SELECT * FROM SOFER;
TRUNCATE TABLE SOFER;


CREATE TABLE MECANIC(
cod_mecanic         NUMBER(5)           CONSTRAINT pk_mecanic PRIMARY KEY,
specializare        VARCHAR2(20),
CONSTRAINT fk_mec_ang FOREIGN KEY(cod_mecanic) REFERENCES ANGAJAT(cod_angajat) ON DELETE CASCADE
);

DECLARE
    v_meserii   t_denumiri := t_denumiri('Maistru Sudura', 'Maistru Mecanic Auto', 'Tehnician Retea', 'Tehnician Sudura');
    i           NUMBER     := 1;
    j           NUMBER;
BEGIN
    FOR c IN (SELECT cod_angajat FROM angajat WHERE tip_job = 'mecanic') LOOP
        j := i MOD 4 + 1;
        INSERT INTO MECANIC VALUES(c.cod_angajat, v_meserii(j));
        i := i + 1;
    END LOOP;
END;
/
SELECT * FROM mecanic;



CREATE TABLE INGINER(
cod_inginer             NUMBER(5)       CONSTRAINT pk_inginer PRIMARY KEY,
institutie_absolvita    VARCHAR2(100)   NOT NULL,
CONSTRAINT fk_ing_ang FOREIGN KEY(cod_inginer) REFERENCES ANGAJAT(cod_angajat) ON DELETE CASCADE
);

DECLARE
    v_fac   t_denumiri := t_denumiri('Facultatea de Transporturi, UPB', 'Facultatea de Autovehicule Rutiere si Mecanica, UTCN', 'Facultatea de Ingineria Traficului, ULBS', 'Facultatea de Inginerie Mecanica, UPB');
    i NUMBER := 1;
    j NUMBER;
BEGIN
    FOR c IN (SELECT cod_angajat FROM angajat WHERE tip_job = 'inginer') LOOP
        j := i MOD 4 + 1;
        INSERT INTO INGINER VALUES(c.cod_angajat, v_fac(j));
        i := i + 1;
    END LOOP;
END;
/

SELECT * FROM inginer;

CREATE TABLE CURSA(
cod_cursa               NUMBER(8)       CONSTRAINT pk_cursa     PRIMARY KEY,
cod_sofer               NUMBER(5)       CONSTRAINT fk_cursa_sof REFERENCES SOFER(cod_sofer) ON DELETE CASCADE,
cod_vehicul_tr          NUMBER(5)       CONSTRAINT fk_cursa_veh REFERENCES VEHICUL_TRANSPORT(cod_vehicul_tr) ON DELETE CASCADE,
numar_traseu            NUMBER(3)       CONSTRAINT fk_cursa_trs REFERENCES TRASEU(numar_traseu) ON DELETE CASCADE,
data_cursa              DATE            NOT NULL,
ora_preluare            DATE            NOT NULL,
ora_incepere_ture       DATE            NOT NULL,
ora_finalizare_ture     DATE            NOT NULL,
ora_predare             DATE            NOT NULL,
numar_ture              NUMBER(3)       NOT NULL,
CONSTRAINT sof_zi_unic UNIQUE(cod_sofer, data_cursa),
CONSTRAINT verif_ore CHECK(ora_incepere_ture - ora_preluare > 0  
                           AND ora_predare - ora_finalizare_ture > 0)
);


ALTER TABLE TRASEU
ADD vehicule_folosite VARCHAR2(25);
DECLARE
    v_veh   VARCHAR2(25);
BEGIN
    FOR c IN (SELECT numar_traseu FROM traseu) LOOP
        IF c.numar_traseu BETWEEN 1 AND 59 THEN
            v_veh := 'tramvai';
        ELSIF c.numar_traseu BETWEEN 60 AND 99 THEN
            v_veh := 'troleibuz';
        ELSE v_veh := 'autobuz';
        END IF;
        UPDATE traseu t SET t.vehicule_folosite = v_veh WHERE t.numar_traseu = c.numar_traseu;
    END LOOP;
END;
/
SELECT * FROM TRASEU;

DECLARE
    v_sofer NUMBER;
    v_cod_dep   NUMBER;
    v_permis    VARCHAR2(5);
    v_tip_veh   VARCHAR2(16);
    veh_posibile    t_coduri := t_coduri();
    trasee_posibile t_coduri := t_coduri();
    ora1        DATE;
    ora2        DATE;
    ora3        DATE;
    ora4        DATE;
    v_data      DATE;
    v_nr_ture   NUMBER;
    indice_traseu NUMBER;
    indice_veh NUMBER;
BEGIN
    FOR k IN 1000..1289 LOOP
        v_sofer := random(100, 129);
        veh_posibile   := t_coduri();
        trasee_posibile := t_coduri();
        SELECT cod_depou INTO v_cod_dep FROM angajat WHERE cod_angajat = v_sofer;
        SELECT categorie_permis INTO v_permis FROM sofer WHERE cod_sofer = v_sofer;
        CASE v_permis
            WHEN 'BUS' THEN v_tip_veh := 'autobuz';
            WHEN 'TRL' THEN v_tip_veh := 'troleibuz';
            ELSE v_tip_veh := 'tramvai';
        END CASE;

        --selectez vehiculele care sunt arondate in acelasi depou in care lucreaza si soferul,
        --si corespund ca tip cu categoria de permis a soferului
        SELECT v.cod_vehicul BULK COLLECT INTO veh_posibile 
            FROM vehicul v
            JOIN depou d ON d.cod_depou = v.cod_depou
            JOIN model m ON m.cod_model = v.cod_model
            WHERE v.intrebuintare = 'transport' AND v.cod_depou = v_cod_dep AND m.tip_mijloc_transport = v_tip_veh;
        indice_veh := random(1, veh_posibile.last);
        
        --selectez traseele posibile
        SELECT numar_traseu BULK COLLECT INTO trasee_posibile FROM traseu WHERE vehicule_folosite = v_tip_veh;
        indice_traseu := random(1, trasee_posibile.last);
        v_data := SYSDATE - random(1, 730);
        
        IF trasee_posibile(indice_traseu) <> 901 AND trasee_posibile(indice_traseu) <> 902 THEN
            ora1 := TO_DATE('04:' || random(30, 59), 'HH24:MI');
            ora2 := TO_DATE('05:0' || random(0, 9), 'HH24:MI');
            ora3 := TO_DATE('22:' || random(10, 59), 'HH24:MI');
            ora4 := TO_DATE('23:' || random(10, 50), 'HH24:MI');
        ELSE
            ora1 := TO_DATE('22:' || random(30, 59), 'HH24:MI');
            ora2 := TO_DATE('23:0' || random(0, 9), 'HH24:MI');
            ora3 := TO_DATE('05:' || random(30, 59), 'HH24:MI');
            ora4 := TO_DATE('06:0' || random(0, 9), 'HH24:MI');
        END IF;
        v_nr_ture := random(7, 25);
        INSERT INTO CURSA VALUES(k, v_sofer, veh_posibile(indice_veh), trasee_posibile(indice_traseu), v_data, ora1, ora2, ora3, ora4, v_nr_ture);
    END LOOP;
END;
/
TRUNCATE TABLE cursa;
SELECT cod_sofer, cod_vehicul_tr, numar_traseu, data_cursa,
TO_CHAR(ora_preluare, 'hh24:mi') t1, TO_CHAR(ora_incepere_ture, 'hh24:mi') t2,
TO_CHAR(ora_finalizare_ture, 'hh24:mi') t3, TO_CHAR(ora_predare, 'hh24:mi') t4, numar_ture FROM CURSA;



CREATE TABLE PARTICIPARE_INTERVENTIE(
cod_participare         NUMBER(5)       CONSTRAINT pk_part  PRIMARY KEY,
cod_mecanic             NUMBER(5)       CONSTRAINT fk_part_mec REFERENCES MECANIC(cod_mecanic) ON DELETE CASCADE,
cod_vehicul_int         NUMBER(5)       CONSTRAINT fk_part_veh REFERENCES VEHICUL_INTERVENTIE(cod_vehicul_int) ON DELETE CASCADE,
numar_interventie       NUMBER(5)       CONSTRAINT fk_part_int REFERENCES INTERVENTIE(numar_interventie) ON DELETE CASCADE
);
DROP TABLE participare_interventie;
SELECT * FROM interventie;
SELECT * FROM vehicul_interventie;
SELECT * FROM mecanic;

CREATE SEQUENCE seq_particip
INCREMENT BY 10 START WITH 10
MAXVALUE 99990;

INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 136, 4, 807);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 133, 4, 807);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 133, 4, 800);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 143, 9, 800);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 139, 9, 800);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 139, 11, 800);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 130, 2, 819);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 131, 2, 819);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 132, 2, 819);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 134, 3, 816);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 142, 10, 814);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 130, 2, 811);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 141, 3, 811);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 134, 6, 801);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 135, 6, 801);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 142, 3, 801);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 138, 7, 804);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 138, 3, 806);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 142, 10, 809);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 134, 1, 803);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 137, 1, 803);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 134, 5, 808);
INSERT INTO PARTICIPARE_INTERVENTIE VALUES(seq_particip.nextval, 143, 12, 822);
SELECT * FROM participare_interventie;

CREATE TABLE ATELIER(
cod_atelier         NUMBER(5)       CONSTRAINT pk_atelier PRIMARY KEY,
denumire            VARCHAR2(50)    UNIQUE NOT NULL,
an_infiintare       DATE            NOT NULL,
capacitate          NUMBER(3)       CHECK(capacitate >= 1),
cod_adresa          NUMBER(5)       
CONSTRAINT fk_atelier REFERENCES ADRESA(cod_adresa) ON DELETE SET NULL,
CONSTRAINT addr_unic_atel UNIQUE(cod_adresa)
);

INSERT INTO ATELIER VALUES(100, 'U.R.A.C.', TO_DATE('01/06/1998', 'dd/mm/yyyy'), 8, 2);
INSERT INTO ATELIER VALUES(200, 'Atelier Unirii', TO_DATE('01/06/2004', 'dd/mm/yyyy'), 4, 45);
INSERT INTO ATELIER VALUES(300, 'Atelier Berceni', TO_DATE('01/06/1960', 'dd/mm/yyyy'), 12, 3);
INSERT INTO ATELIER VALUES(400, 'Atelier Tital', TO_DATE('01/06/1977', 'dd/mm/yyyy'), 6, 5);
INSERT INTO ATELIER VALUES(500, 'Atelier Vatra Luminoasa', TO_DATE('01/06/1988', 'dd/mm/yyyy'), 4, 11);
SELECT cod_atelier, denumire, to_char(an_infiintare, 'yyyy'), capacitate, cod_adresa FROM ATELIER;


CREATE TABLE EVENIMENT_CIRCULATIE(
cod_eveniment       NUMBER(5)       CONSTRAINT pk_event PRIMARY KEY,
data_producere      DATE            NOT NULL,
localizare          VARCHAR2(100),
descriere           VARCHAR2(100),
numar_interventie   NUMBER(5)       
CONSTRAINT fk_event_int REFERENCES INTERVENTIE(numar_interventie) ON DELETE SET NULL,
CONSTRAINT nr_int_unic UNIQUE(numar_interventie)
);

SELECT * FROM interventie;

DECLARE
    localizari t_denumiri := t_denumiri('Soseua de Centura', 'Depou Bujoreni', 'Bd. Nicolae Grigorescu',
    'Piata Victoriei', 'Piata Unirii', 'Calea Grivitei', 'Sos. Giurgiului', 'Drumul Taberei', 
    'Sos. Pantelimon', 'Bd. Iancu de Hunedoara', 'Bd. Ion Mihalache');
    descrieri_event t_denumiri := t_denumiri('Deraiere', 'Coliziune cu un autoturism', 'Coliziune intre autobuze', 
    'Pana Auto', 'Tamponare cu un autoturism', 'Ciocnire intre un autobuz si tramvai', 'Incendiu');
    i1 NUMBER;
    i2 NUMBER;
    pk NUMBER := 10;
BEGIN
    FOR c IN (SELECT numar_interventie, CAST(data_interventie AS DATE) data_interv 
    FROM interventie WHERE lower(cauza) like '%eveniment%') LOOP
        i1 := random(1, localizari.last);
        i2 := random(1, descrieri_event.last);
        INSERT INTO EVENIMENT_CIRCULATIE VALUES(pk, c.data_interv, localizari(i1), descrieri_event(i2), c.numar_interventie);
        pk := pk + 1;
    END LOOP;
END;
/
TRUNCATE TABLE eveniment_circulatie;
SELECT * FROM EVENIMENT_CIRCULATIE;


CREATE TABLE IMPLICA(
cod_eveniment       NUMBER(5)       CONSTRAINT fk_imp_event REFERENCES EVENIMENT_CIRCULATIE(cod_eveniment) ON DELETE CASCADE,
cod_vehicul_tr      NUMBER(5)       CONSTRAINT fk_imp_vehic REFERENCES VEHICUL_TRANSPORT(cod_vehicul_tr) ON DELETE CASCADE,
daune               VARCHAR2(256)   NOT NULL,
CONSTRAINT pk_imp PRIMARY KEY (cod_eveniment, cod_vehicul_tr)
);

INSERT INTO IMPLICA VALUES(10, 1001, 'Parbriz si Faruri Sparte');
INSERT INTO IMPLICA VALUES(10, 9084, 'Tampoane indoite, partea din fata a caroseriei distrusa');
INSERT INTO IMPLICA VALUES(11, 1008, 'Partea din fata a caroseriei distrusa');
INSERT INTO IMPLICA VALUES(11, 9072, 'Partea stanga a caroseriei distrusa, geamuri sparte, articulatia dintre vagoanele 2 si 3 rupta');
INSERT INTO IMPLICA VALUES(12, 9071, 'Pantograf , Rulmentii boghiurilor distrusi');
INSERT INTO IMPLICA VALUES(13, 1030, 'Pneuri sparte');
INSERT INTO IMPLICA VALUES(14, 9096, 'Pantograf rupt');
INSERT INTO IMPLICA VALUES(15, 5055, 'Parbriz si faruri sparte');
INSERT INTO IMPLICA VALUES(16, 1000, 'Ambreiaj stricat');
INSERT INTO IMPLICA VALUES(16, 1006, 'Caroserie indoita');
INSERT INTO IMPLICA VALUES(16, 1018, 'Parbriz si Faruri Sparte');
INSERT INTO IMPLICA VALUES(17, 1001, 'Faruri sparte, caroseria indoita');
INSERT INTO IMPLICA VALUES(18, 9072, 'Rulmentii boghiurilor distrusi');
INSERT INTO IMPLICA VALUES(19, 1036, 'Caroseria laterala distrusa complet');
INSERT INTO IMPLICA VALUES(19, 1032, 'Parbriz si oglinzi sparte');
INSERT INTO IMPLICA VALUES(20, 1027, 'Faruri sparte');
INSERT INTO IMPLICA VALUES(20, 1028, 'Oglinda sparta, caroseria zgariata');
INSERT INTO IMPLICA VALUES(21, 1016, 'Parbriz crapat');
INSERT INTO IMPLICA VALUES(21, 1017, 'Oglinda rupta');
INSERT INTO IMPLICA VALUES(21, 1018, 'Luneta sparta');

SELECT * FROM IMPLICA;

CREATE TABLE REPARATIE(
cod_reparatie       NUMBER(5)       CONSTRAINT pk_rep PRIMARY KEY,
data_incepere       DATE            NOT NULL,            
data_finalizare     DATE,
cod_vehicul_tr      NUMBER(5)       CONSTRAINT fk_rep_veh REFERENCES VEHICUL_TRANSPORT(cod_vehicul_tr) ON DELETE SET NULL,
cod_inginer         NUMBER(5)       CONSTRAINT fk_rep_ing REFERENCES INGINER(cod_inginer) ON DELETE SET NULL,
cod_atelier         NUMBER(5)       CONSTRAINT fk_rep_atl REFERENCES ATELIER(cod_atelier) ON DELETE SET NULL
);

select * from inginer;

CREATE SEQUENCE seq_reparatii
INCREMENT BY 10 START WITH 10
MAXVALUE 99999
NOCYCLE NOCACHE;

DECLARE
    v_atelier   NUMBER;
    v_inginer   NUMBER;
    v_data      DATE;
BEGIN
    FOR c IN (SELECT cod_vehicul FROM vehicul WHERE stare = 'in reparatie') LOOP
        v_atelier := random(1, 5) * 100;
        v_inginer := random(145, 149);
        v_data := SYSDATE - random(1, 180);
        INSERT INTO REPARATIE VALUES(seq_reparatii.nextval, v_data, null, c.cod_vehicul, v_inginer, v_atelier);
    END LOOP;
    INSERT INTO REPARATIE VALUES (seq_reparatii.nextval, TO_DATE('18-11-2023', 'DD-MM-YYYY'), 
    TO_DATE('01-02-2024', 'DD-MM-YYYY'), 1018, 145, 100);
     INSERT INTO REPARATIE VALUES (seq_reparatii.nextval, TO_DATE('18-06-2023', 'DD-MM-YYYY'), 
    TO_DATE('01-08-2023', 'DD-MM-YYYY'), 1018, 145, 100);
     INSERT INTO REPARATIE VALUES (seq_reparatii.nextval, TO_DATE('22-02-2023', 'DD-MM-YYYY'), 
    TO_DATE('14-06-2023', 'DD-MM-YYYY'), 9070, 148, 500);
     INSERT INTO REPARATIE VALUES (seq_reparatii.nextval, TO_DATE('30-01-2024', 'DD-MM-YYYY'), 
    TO_DATE('01-02-2024', 'DD-MM-YYYY'), 9098, 149, 500);
END;
/
SELECT * FROM REPARATIE;
TRUNCATE TABLE REPARATIE;


CREATE TABLE LOT_COMPONENTA(
cod_lot             NUMBER(5)       CONSTRAINT pk_lotcomp PRIMARY KEY,
nume_componenta     VARCHAR2(50)    NOT NULL,
cantitate           NUMBER(5)       NOT NULL CHECK(cantitate >= 1),
pret                NUMBER(6,2)     NOT NULL CHECK(pret > 0),
data_livrare        DATE            NOT NULL,
cod_furnizor        NUMBER(3)       CONSTRAINT fk_lot REFERENCES FURNIZOR(cod_furnizor) ON DELETE SET NULL
);

SELECT * FROM IMPLICA;

INSERT INTO LOT_COMPONENTA VALUES(1, 'Ambreiaj Autobuz', 15, 4500, TO_DATE('18-11-2023', 'DD-MM-YYYY'), 5);
INSERT INTO LOT_COMPONENTA VALUES(2, 'Parbriz Tramvai', 10, 2100, TO_DATE('10-09-2023', 'DD-MM-YYYY'), 7);
INSERT INTO LOT_COMPONENTA VALUES(3, 'Boghiu', 3, 8500, TO_DATE('18-11-2022', 'DD-MM-YYYY'), 8);
INSERT INTO LOT_COMPONENTA VALUES(4, 'Pneuri Autobuz', 40, 800, TO_DATE('16-10-2023', 'DD-MM-YYYY'), 6);
INSERT INTO LOT_COMPONENTA VALUES(5, 'Caroserie Autobuz', 30, 9900, TO_DATE('18-11-2023', 'DD-MM-YYYY'), 4);
INSERT INTO LOT_COMPONENTA VALUES(6, 'Parbriz Autobuz', 15, 1800, TO_DATE('10-09-2023', 'DD-MM-YYYY'), 7);
INSERT INTO LOT_COMPONENTA VALUES(7, 'Tampoane tramvai', 10, 5000, TO_DATE('10-01-2023', 'DD-MM-YYYY'), 3);
INSERT INTO LOT_COMPONENTA VALUES(8, 'Pantograf tramvai', 5, 9900, TO_DATE('16-09-2022', 'DD-MM-YYYY'), 1);
INSERT INTO LOT_COMPONENTA VALUES(9, 'Faruri Autobuz', 50, 9000, TO_DATE('05-04-2022', 'DD-MM-YYYY'), 2);
INSERT INTO LOT_COMPONENTA VALUES(10, 'Oglinzi Autobuz', 50, 4000, TO_DATE('10-09-2023', 'DD-MM-YYYY'), 7);
INSERT INTO LOT_COMPONENTA VALUES(11, 'Geam Autobuz', 30, 8000, TO_DATE('10-09-2023', 'DD-MM-YYYY'), 8);
INSERT INTO LOT_COMPONENTA VALUES(12, 'Geam Tramvai', 30, 7500, TO_DATE('10-09-2023', 'DD-MM-YYYY'), 8);


CREATE TABLE COMPONENTA(
cod_lot             NUMBER(5)      CONSTRAINT fk_comp_lot REFERENCES LOT_COMPONENTA(cod_lot) ON DELETE SET NULL,
numar_componenta    NUMBER(5)      NOT NULL,
cod_reparatie       NUMBER(5)      CONSTRAINT fk_comp_rep REFERENCES REPARATIE(cod_reparatie) ON DELETE SET NULL,
CONSTRAINT pk_comp PRIMARY KEY(cod_lot, numar_componenta)
);


INSERT INTO COMPONENTA VALUES(6, 1, 170);
INSERT INTO COMPONENTA VALUES(4, 1, 170);
INSERT INTO COMPONENTA VALUES(4, 2, 170);
INSERT INTO COMPONENTA VALUES(5, 1, 180);
INSERT INTO COMPONENTA VALUES(5, 2, 190);
INSERT INTO COMPONENTA VALUES(6, 2, 200);
INSERT INTO COMPONENTA VALUES(9, 1, 200);
INSERT INTO COMPONENTA VALUES(9, 2, 200);
INSERT INTO COMPONENTA VALUES(11, 1, 210);
INSERT INTO COMPONENTA VALUES(11, 2, 210);
INSERT INTO COMPONENTA VALUES(4, 3, 220);
INSERT INTO COMPONENTA VALUES(4, 4, 220);
INSERT INTO COMPONENTA VALUES(5, 3, 230);
INSERT INTO COMPONENTA VALUES(1, 1, 240);
INSERT INTO COMPONENTA VALUES(1, 2, 250);
INSERT INTO COMPONENTA VALUES(1, 3, 260);
INSERT INTO COMPONENTA VALUES(3, 1, 270);
INSERT INTO COMPONENTA VALUES(3, 2, 280);
INSERT INTO COMPONENTA VALUES(3, 3, 280);
INSERT INTO COMPONENTA VALUES(7, 1, 280);
INSERT INTO COMPONENTA VALUES(7, 2, 280);
INSERT INTO COMPONENTA VALUES(8, 1, 290);
INSERT INTO COMPONENTA VALUES(2, 1, 300);
INSERT INTO COMPONENTA VALUES(7, 3, 300);
INSERT INTO COMPONENTA VALUES(7, 4, 300);
INSERT INTO COMPONENTA VALUES(12, 1, 310);
INSERT INTO COMPONENTA VALUES(12, 2, 310);
INSERT INTO COMPONENTA VALUES(12, 3, 310);
INSERT INTO COMPONENTA VALUES(2, 2, 320);
INSERT INTO COMPONENTA VALUES(10, 1, 330);
INSERT INTO COMPONENTA VALUES(10, 2, 330);
INSERT INTO COMPONENTA VALUES(6, 3, 340);
INSERT INTO COMPONENTA VALUES(5, 4, 340);
INSERT INTO COMPONENTA VALUES(2, 3, 350);
INSERT INTO COMPONENTA VALUES(8, 2, 360);

SELECT * FROM COMPONENTA;

