--u zakaznika ukaze se sazbou, kolik utratil na pc
select email, role_tbl.typ, (sum(extract(epoch from (odhlaseni - prihlaseni))/60)*sazba) as time_logged 
from log_tbl, osoba_tbl, zakaznik_tbl, role_tbl where 
                    zakaznik_tbl.osoba_fk = 1
                    AND osoba_tbl.osoba_id = zakaznik_tbl.osoba_fk AND role_tbl.role_id = zakaznik_tbl.role_fk
group by email, role_tbl.typ, sazba;

--vydelano z kazdeho zakaznika
select email, role_tbl.typ, (sum(extract(epoch from (odhlaseni - prihlaseni))/60)*sazba) as vydelek 
from log_tbl, osoba_tbl, zakaznik_tbl, role_tbl where
					osoba_tbl.osoba_id = zakaznik_tbl.osoba_fk AND role_tbl.role_id = zakaznik_tbl.role_fk
group by email, role_tbl.typ, sazba order by vydelek desc;

--vydelano ze zakaznika v časovém období
select email, role_tbl.typ,
sum(extract(epoch from (odhlaseni - prihlaseni))/60) as hodiny,
(sum(extract(epoch from (odhlaseni - prihlaseni))/60)*sazba) as vydelek 
from log_tbl, osoba_tbl, zakaznik_tbl, role_tbl where
					osoba_tbl.osoba_id = zakaznik_tbl.osoba_fk 
					AND role_tbl.role_id = zakaznik_tbl.role_fk
					and log_tbl.odhlaseni > to_timestamp('2018-01', 'YYYY-MM-DD HH:MI:SS') 
					and log_tbl.odhlaseni < to_timestamp('2018-02', 'YYYY-MM-DD HH:MI:SS')
group by email, role_tbl.typ, sazba order by vydelek desc;

--vydelano z kazdeho typu zakaznika
select role_tbl.typ, (sum(extract(epoch from (odhlaseni - prihlaseni))/60)*sazba) as vydelek
from log_tbl, osoba_tbl, zakaznik_tbl, role_tbl where
					osoba_tbl.osoba_id = zakaznik_tbl.osoba_fk AND role_tbl.role_id = zakaznik_tbl.role_fk
group by role_tbl.typ, sazba order by vydelek desc;

--vydelano z kazdeho typu zakaznika za urcite obdobi
select role_tbl.typ, (sum(extract(epoch from (odhlaseni - prihlaseni))/60)*sazba) as vydelek
from log_tbl, osoba_tbl, zakaznik_tbl, role_tbl where
					osoba_tbl.osoba_id = zakaznik_tbl.osoba_fk 
					AND role_tbl.role_id = zakaznik_tbl.role_fk
					and log_tbl.odhlaseni > to_timestamp('2018-01', 'YYYY-MM-DD HH:MI:SS') 
					and log_tbl.odhlaseni < to_timestamp('2018-02', 'YYYY-MM-DD HH:MI:SS')
group by role_tbl.typ, sazba order by vydelek desc;

--jaky pocitac se pouziva nejcasteji zakazniky
SELECT pocitac_id, pocitac_tbl.nazev, COUNT(pocitac_fk) as pocet_pouziti
FROM pocitac_tbl, log_tbl, zakaznik_tbl where log_tbl.osoba_fk = zakaznik_tbl.osoba_fk and log_tbl.pocitac_fk = pocitac_tbl.pocitac_id
group by pocitac_id
order by pocet_pouziti desc;

--jaky pocitac se pouziva nejcasteji zakazniky za obdobi
SELECT pocitac_id, pocitac_tbl.nazev, COUNT(pocitac_fk) as pocet_pouziti
FROM pocitac_tbl, log_tbl, zakaznik_tbl where 
log_tbl.osoba_fk = zakaznik_tbl.osoba_fk 
and log_tbl.pocitac_fk = pocitac_tbl.pocitac_id
and log_tbl.odhlaseni > to_timestamp('2018-01', 'YYYY-MM-DD HH:MI:SS') 
and log_tbl.odhlaseni < to_timestamp('2020', 'YYYY-MM-DD HH:MI:SS')
group by pocitac_id
order by pocet_pouziti desc;


--holik hodin stravili zamestnanci na pc 
select email, jmeno, prijmeni, round(sum(extract(epoch from (odhlaseni - prihlaseni))/3600)) as cas_na_pc 
from log_tbl, osoba_tbl, zamestnanec_tbl 
where osoba_tbl.osoba_id = zamestnanec_tbl.osoba_fk
and log_tbl.osoba_fk = zamestnanec_tbl.osoba_fk
group by email, prijmeni, jmeno;

--holik hodin stravili zamestnanci na pc za obdobi
select email, jmeno, prijmeni, round(sum(extract(epoch from (odhlaseni - prihlaseni))/3600)) as cas_na_pc 
from log_tbl, osoba_tbl, zamestnanec_tbl 
where osoba_tbl.osoba_id = zamestnanec_tbl.osoba_fk
and log_tbl.osoba_fk = zamestnanec_tbl.osoba_fk
and log_tbl.odhlaseni > to_timestamp('2018-01', 'YYYY-MM-DD HH:MI:SS') 
and log_tbl.odhlaseni < to_timestamp('2020', 'YYYY-MM-DD HH:MI:SS')
group by email, prijmeni, jmeno;

--kolik si videlala obsluha za nějake obdobi
select email, jmeno, prijmeni, round(sum(extract(epoch from ( datum_konec - datum_zacatek))/3600)) as odpracovany_cas,
(round(sum(extract(epoch from (datum_konec - datum_zacatek))/3600))*kc_hodina) as vydelek
from obsluha_tbl, zamestnanec_tbl,smena_tbl, smena_zamestnanec_rel, osoba_tbl
where osoba_tbl.osoba_id = zamestnanec_tbl.osoba_fk
and zamestnanec_tbl.zamestnanec_id = obsluha_tbl.zamestnanec_fk
and smena_zamestnanec_rel.smena_fk = smena_tbl.smena_id
and smena_zamestnanec_rel.zamestnanec_fk = obsluha_tbl.zamestnanec_fk
and smena_tbl.datum_zacatek  > to_timestamp('2018-01', 'YYYY-MM-DD HH:MI:SS') 
and smena_tbl.datum_konec < to_timestamp('2023', 'YYYY-MM-DD HH:MI:SS')
group by email, prijmeni, jmeno, obsluha_tbl.kc_hodina;