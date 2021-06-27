
--procedury
--procedura pro tvorbu osoby
CREATE PROCEDURE osoba_insert( _e email_DOM, _h TEXT)
LANGUAGE PLPGSQL
AS $BODY$
BEGIN
    INSERT INTO osoba_tbl( email, heslo)
    VALUES( _e, _h);   
END
$BODY$;

--procedura pro tvorbu zakaznika
--call zakaznik_insert('janous@seznam.cz', 'janousheslo', 2, 1000);
CREATE PROCEDURE zakaznik_insert (_e email_DOM, _h TEXT, _r INTEGER, _k INTEGER)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_osoba_fk INTEGER;
BEGIN
	CALL osoba_insert( _e, _h);
	_osoba_fk =  (SELECT osoba_id from osoba_tbl where email = _e);
    INSERT INTO zakaznik_tbl( osoba_fk, role_fk, kredit)
    VALUES(_osoba_fk, _r, _k);   
END
$BODY$;

--procedura pro tvorbu zamestnance
CREATE PROCEDURE zamestnanec_insert( _e email_DOM, _h TEXT, _r rc_DOM, _t telefon_DOM, _j TEXT, _p TEXT)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_osoba_fk INTEGER;
BEGIN
	CALL osoba_insert( _e, _h);
	_osoba_fk =  (SELECT osoba_id from osoba_tbl where email = _e);
    INSERT INTO zamestnanec_tbl( osoba_fk, rc, telefon, jmeno, prijmeni)
    VALUES(_osoba_fk, _r, _t, _j, _p);   
END
$BODY$;

--procedura pro tvorbu obsluhy
--call obsluha_insert( 'annaObsluha@kavarna.cz', 'annaheslo', '985224/4284', '+420147258369', 'Anna', 'Janska', 150);
CREATE PROCEDURE obsluha_insert( _e email_DOM, _h TEXT, _r rc_DOM, _t telefon_DOM, _j TEXT, _p TEXT, _k INTEGER)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_osoba_fk INTEGER;
BEGIN
	CALL zamestnanec_insert( _e, _h, _r, _t, _j, _p);
	_osoba_fk =  (SELECT osoba_id from osoba_tbl where email = _e);
	INSERT INTO obsluha_tbl (osoba_fk, kc_hodina) VALUES (_osoba_fk, _k);
END
$BODY$;

--procedura pro tvorbu manazera
--call manazer_insert( 'pavelManazer@kavarna.cz', 'pavelheslo', '980224/4264', '+420789456123', 'Pavel', 'Janovsky', 30000);
CREATE PROCEDURE manazer_insert( _e email_DOM, _h TEXT, _r rc_DOM, _t telefon_DOM, _j TEXT, _p TEXT, _plat INTEGER)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_osoba_fk INTEGER;
BEGIN
	CALL zamestnanec_insert (_e, _h, _r, _t, _j, _p);
	_osoba_fk =  (SELECT osoba_id from osoba_tbl where email = _e);
	INSERT INTO manazer_tbl (osoba_fk, plat) VALUES (_osoba_fk, _plat);
END
$BODY$;


--procedure pro tvorbu role
CREATE PROCEDURE role_insert(_t TEXT, _s INTEGER)
LANGUAGE PLPGSQL

AS $BODY$
BEGIN
	INSERT INTO role_tbl (typ, sazba) VALUES (_t, _s);
END
$BODY$;

--procedure pro tvorbu pocitace
--call pocitac_insert('Marenka');
CREATE PROCEDURE pocitac_insert(_n TEXT)
LANGUAGE PLPGSQL

AS $BODY$
BEGIN
	INSERT INTO pocitac_tbl (nazev, udrzba) VALUES (_n, CURRENT_TIMESTAMP);
END
$BODY$;

--procedura pro tvorbu smeny
--call smena_insert('ranni ctvrtek 20.1.', '2022-01-30 06:00:00', '2022-01-30 10:00:00');
CREATE PROCEDURE smena_insert(_j TEXT, _z TIMESTAMP, _k TIMESTAMP)
LANGUAGE PLPGSQL

AS $BODY$
BEGIN
	INSERT INTO smena_tbl (jmeno_smeny, datum_zacatek, datum_konec) VALUES (_j, _z, _k);
END
$BODY$;

--procedura pro prirazeni smeny
--call smena_zamestnanec_insert('2022-01-30 06:00:00', 2);
CREATE PROCEDURE smena_zamestnanec_insert(_z TIMESTAMP, _oid INTEGER)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_smena_fk INTEGER;
BEGIN
	_smena_fk = (SELECT smena_id FROM smena_tbl WHERE datum_zacatek = _z);
	INSERT INTO smena_zamestnanec_rel (smena_fk, osoba_fk) VALUES (_smena_fk, _oid);
END
$BODY$;

--procedura pro vytvořeni logu
--call log_insert(2, 2, '2020-01-28 06:00:00', '2020-01-28 06:20:00', 'SERVICE');
CREATE PROCEDURE log_insert(_o INTEGER, _p INTEGER, _login TIMESTAMP, _logout TIMESTAMP, _s stav_ENUM)
LANGUAGE PLPGSQL

AS $BODY$
DECLARE
_udrzba TIMESTAMP;
BEGIN
IF EXISTS (SELECT 1
				FROM zamestnanec_tbl
				WHERE zamestnanec_id = _o)
	THEN
	UPDATE pocitac_tbl SET udrzba = _logout WHERE pocitac_id = _p;
END IF;
_udrzba = (SELECT udrzba FROM pocitac_tbl WHERE pocitac_id = _p);

INSERT INTO log_tbl(osoba_fk, pocitac_fk, prihlaseni, odhlaseni, stav, udrzba) VALUES (_o, _p, _login, _logout, _s, _udrzba);
	
END
$BODY$;
