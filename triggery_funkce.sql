--triggery
--trigger na sifrovani hesla
CREATE TRIGGER ecrypt_heslo
BEFORE INSERT ON osoba_tbl
FOR EACH ROW EXECUTE PROCEDURE krypt_hesla();

--kontrola, jestli je osoba v zakaznicich pred vlozenim do zamestnancu
CREATE TRIGGER zamestnanec_vs_zakaznik_test
BEFORE INSERT ON zamestnanec_tbl
FOR EACH ROW EXECUTE PROCEDURE testik_isa();

--kontrola, jestli je osoba v zamestnancich pred vlozenim do zakazniku
CREATE TRIGGER zakaznik_vs_zamestnanec_test
BEFORE INSERT ON zakaznik_tbl
FOR EACH ROW EXECUTE PROCEDURE testik_isa();

--kontrola, jestli je zamestnanec v manazerech pred vlozenim do obsluhy
CREATE TRIGGER obsluha_vs_manazer_test
BEFORE INSERT ON obsluha_tbl
FOR EACH ROW EXECUTE PROCEDURE testik_isa();

--kontrola, jestli je zamestnanec v obsluze pred vlozenim do manazeru
CREATE TRIGGER manazer_vs_obsluha_test
BEFORE INSERT ON manazer_tbl
FOR EACH ROW EXECUTE PROCEDURE testik_isa();

--funkce------------------------------------------------------------
--funkce na automaticke hashovani hesla
CREATE OR REPLACE FUNCTION krypt_hesla()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$func$
BEGIN
NEW.heslo = crypt(NEW.heslo,gen_salt('bf'));
RETURN NEW;
END;
$func$

--kontrola IsA
CREATE OR REPLACE FUNCTION testik_isa()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$func$
BEGIN
RAISE NOTICE 'Test na IsA';
IF
	(TG_TABLE_NAME = 'zamestnanec_tbl')
THEN 
	IF
		EXISTS (SELECT 1
				FROM zakaznik_tbl
				WHERE zakaznik_tbl.osoba_fk = new.osoba_fk)
	THEN 
		RAISE NOTICE 'Tato osoba je jiz zakaznik a nemuze byt zamestnanec';
		RETURN NULL;
	ELSE
		RAISE NOTICE 'Test na IsA byl uspesny';
		RETURN NEW;
	END IF;
END IF;

IF (TG_TABLE_NAME = 'zakaznik_tbl')
THEN 
	IF
		EXISTS (SELECT 1
				FROM zamestnanec_tbl
				WHERE zamestnanec_tbl.osoba_fk = new.osoba_fk)
	THEN 
		RAISE NOTICE 'Tato osoba je jiz zamestnanec a nemuze byt zakaznik';
		RETURN NULL;
	ELSE
		RAISE NOTICE 'Test na IsA byl uspesny';
		RETURN NEW;
	END IF;
END IF;

IF (TG_TABLE_NAME = 'obsluha_tbl')
THEN 
	IF
		EXISTS (SELECT 1
				FROM manazer_tbl
				WHERE manazer_tbl.zamestnanec_fk = new.zamestnanec_fk)
	THEN 
		RAISE NOTICE 'Tato osoba je jiz manazer a nemuze byt obsluha';
		RETURN NULL;
	ELSE
		RAISE NOTICE 'Test na IsA byl uspesny';
		RETURN NEW;
	END IF;
END IF;

IF (TG_TABLE_NAME = 'manazer_tbl')
THEN 
	IF
		EXISTS (SELECT 1
				FROM obsluha_tbl
				WHERE obsluha_tbl.zamestnanec_fk = new.zamestnanec_fk)
	THEN 
		RAISE NOTICE 'Tato osoba je jiz obsluha a nemuze byt manazer';
		RETURN NULL;
	ELSE
		RAISE NOTICE 'Test na IsA byl uspesny';
		RETURN NEW;
	END IF;
END IF;
END;
$func$