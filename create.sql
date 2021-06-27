--definujeme nove datatypy

CREATE EXTENSION CITEXT;--nainstaluj CITEXT
--custom datatyp s kontrolou mailu
CREATE DOMAIN email_DOM AS CITEXT
CHECK(
    value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
);
--custom datatyp s kontrolou rodneho cisla
CREATE DOMAIN rc_DOM AS VARCHAR(12) 
CHECK (
    value ~ '^[0-9][0-9]([0-3]|[5-8])[0-9][0-3][1-9](\/{0,1})[0-9]{3,4}'
    );
--custom datatzp s kontrolou telefonu
CREATE DOMAIN telefon_DOM AS VARCHAR(16) 
CHECK (
    value ~ '^(\+{0,1})[0-9]{1,3}\s{0,1}[0-9]{3}\s{0,1}[0-9]{3}\s{0,1}[0-9]{3}'
    );
-- enum typ predstavujici status pocitace pri odhlaseni uzivatele
CREATE TYPE stav_ENUM as ENUM (
    'ONLINE', 'OFFLINE', 'SERVICE'
);
--instalace rozsireni
CREATE EXTENSION IF NOT EXISTS pgcrypto;
--nejdrive udelame tabulky bez fk
CREATE TABLE pocitac_tbl(
    pocitac_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nazev TEXT UNIQUE NOT NULL,
    udrzba TIMESTAMP NOT NULL,
    CONSTRAINT pocitac_udrzba_kontrola CHECK (udrzba <= CURRENT_TIMESTAMP)
);

CREATE TABLE osoba_tbl (
    osoba_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    email email_DOM UNIQUE NOT NULL, --domain email_DOM jiz obsahuje kontrolu na format emailu, jedna se o domain CITEXT
    heslo TEXT NOT NULL
);

CREATE TABLE role_tbl (
    role_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    typ TEXT UNIQUE NOT NULL,
    sazba INTEGER NOT NULL,
    CONSTRAINT role_sazba_kontrola CHECK (sazba > 0)
);

CREATE TABLE smena_tbl(
    smena_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    jmeno_smeny TEXT NOT NULL,
    datum_zacatek TIMESTAMP NOT NULL,
    datum_konec TIMESTAMP NOT NULL,
    CONSTRAINT smena_datum_kontrola CHECK ((datum_zacatek > CURRENT_TIMESTAMP)AND(datum_zacatek < datum_konec))
);
--tabulkz s constrainty
CREATE TABLE zakaznik_tbl (
    osoba_fk INTEGER UNIQUE NOT NULL,
    role_fk INTEGER NOT NULL,
    kredit INTEGER NOT NULL,
    CONSTRAINT fk_zakaznik_to_osoba FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl (osoba_id), --nebudou se mazat pro statistiky, když bude uživatel chtít být vymazán, smaže se jeho email a jeho nick a heslo se nahradi placeholdery
    CONSTRAINT fk_zakaznik_to_role FOREIGN KEY (role_fk) REFERENCES role_tbl (role_id), --on delete do nothing, role se stejně nejdriv bude muset zmenit u zakazniku, nez se smaze
    CONSTRAINT zakaznik_kredit_kladny CHECK (kredit >= 0)
);

CREATE TABLE zamestnanec_tbl (
    osoba_fk INTEGER UNIQUE NOT NULL,
    rc rc_DOM UNIQUE NOT NULL, --domain rc_DOM jiz obsahuje kontrolu na format, jedna se o dommain VARCHAR(13)
    telefon telefon_DOM UNIQUE NOT null, -- domain telefon_DOM jiz obsahuje kontrolu na format, jedna se domain VARCHAR(16)
    jmeno TEXT NOT NULL,
    prijmeni TEXT NOT NULL,
    CONSTRAINT fk_zamestnantec_to_osoba FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl(osoba_id) --zamestnanci se nemazou, on delete do nothing
);

CREATE TABLE obsluha_tbl(
    osoba_fk INTEGER UNIQUE NOT NULL,
    kc_hodina INTEGER,
    CONSTRAINT fk_obsluha_to_osoba FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl (osoba_id),
    CONSTRAINT obsluha_kc_hodina_kladne CHECK (kc_hodina > 0)
);

CREATE TABLE manazer_tbl(
    osoba_fk INTEGER UNIQUE NOT NULL,
    plat INTEGER,
    CONSTRAINT fk_obsluha_to_osoba FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl (osoba_id),
    CONSTRAINT plat_kladne CHECK (plat > 0)
);

CREATE TABLE smena_zamestnanec_rel (
    smena_zamestnanec_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    smena_fk INTEGER NOT NULL,
    osoba_fk INTEGER NOT NULL,
    CONSTRAINT fk_smena_zamestnanec_to_smena FOREIGN KEY (smena_fk) REFERENCES smena_tbl (smena_id) ON DELETE CASCADE, --když se zruši směna, zruší se pro všechny zaměstnance
    CONSTRAINT fk_smena_zamestnanec_to_zamestnanec FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl (osoba_id) --zaměstnanci se nemažou
);

CREATE TABLE log_tbl(
    log_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    osoba_fk INTEGER NOT NULL,
    pocitac_fk INTEGER NOT NULL,
    prihlaseni TIMESTAMP NOT NULL,
    odhlaseni TIMESTAMP NOT NULL,
    stav stav_ENUM NOT NULL,
    udrzba TIMESTAMP NOT NULL,
    CONSTRAINT fk_log_to_osoba FOREIGN KEY (osoba_fk) REFERENCES osoba_tbl (osoba_id), --osoby se nemazou
    CONSTRAINT fk_log_to_pocitac FOREIGN KEY (pocitac_fk) REFERENCES pocitac_tbl (pocitac_id), --pocitace neni potreba smazat
    CONSTRAINT log_kontrola_prihlaseni_odhlaseni CHECK (odhlaseni > prihlaseni),
    CONSTRAINT log_kontrola_udrzba CHECK (udrzba <= CURRENT_TIMESTAMP)
);
