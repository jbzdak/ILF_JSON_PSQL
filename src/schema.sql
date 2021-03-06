﻿DROP TABLE IF EXISTS "UZYTKOWNIK" CASCADE;
DROP TABLE IF EXISTS "EKSPERYMENTY_DOSTEP" CASCADE;
DROP TABLE IF EXISTS "SESJA_POMIAROWA" CASCADE;
DROP TABLE IF EXISTS "EKSPERYMENT" CASCADE;
DROP TABLE IF EXISTS "SERIE" CASCADE;

CREATE TABLE "UZYTKOWNIK" (
	id serial primary key,
	nazwa_uzytkownika text
);

CREATE TABLE "EKSPERYMENTY_DOSTEP"(
	id serial primary key,
	id_uzytkownika integer,
	sesja_id integer
);

CREATE TABLE "SESJA_POMIAROWA"(
	id serial primary key,
	nazwa_id integer
);

CREATE TABLE "EKSPERYMENT"(
	id serial primary key,
	nazwa text
);

CREATE TABLE "SERIE"(
	id serial primary key,
	sesja_id integer,
	data timestamp,
	wynik text
);
/*
ALTER TABLE "EKSPERYMENTY_DOSTEP"
	ADD CONSTRAINT "EKSPERYMENTY_DOSTEP_uzytkownik_id_fk" FOREIGN KEY (id_uzytkownika)
	REFERENCES "UZYTKOWNIK"(id);

ALTER TABLE "EKSPERYMENTY_DOSTEP"
	ADD CONSTRAINT "EKSPERYMENTY_DOSTEP_sesja_id_fk" FOREIGN KEY (sesja_id)
	REFERENCES "SESJA_POMIAROWA"(id);

ALTER TABLE "SESJA_POMIAROWA"
	ADD CONSTRAINT "SESJA_POMIAROWA_eksperyment_nazwa_fk" FOREIGN KEY(nazwa_id)
	REFERENCES "EKSPERYMENT"(id);

ALTER TABLE "SERIE"
	ADD CONSTRAINT "SERIE_sesja_id_fk" FOREIGN KEY(sesja_id)
	REFERENCES "SESJA_POMIAROWA"(id); 
*/

CREATE OR REPLACE FUNCTION put_json()
	RETURNS TRIGGER AS
	$$
	import json
	from datetime import datetime
	
	rec = plpy.execute('SELECT * FROM "SERIE" WHERE sesja_id = %d' %TD['new']['sesja_id'] )
	plpy.execute('DELETE FROM "SERIE" WHERE sesja_id = %d' %TD['new']['sesja_id'] )
	obj = json.loads( TD['new']['wynik'] ) 
	
	if len(rec) == 0:
		for x in obj.keys():
			del obj[x]["pragma"]
		TD['new']['wynik'] = json.dumps(obj, separators=(',',':'))
	else:
		prev = json.loads(rec[0]['wynik'])
		for x in obj.keys():
			if x not in prev.keys() and obj[x]["pragma"] != "transient":
				prev[x] = {}
				prev[x]['value'] = obj[x]["value"]
			elif obj[x]["pragma"] == "append":
				for v in obj[x]["value"]:
					prev[x]["value"].append(v)
			elif obj[x]["pragma"] == "replace":
				prev[x]["value"] = obj[x]["value"]
			elif obj[x]["pragma"] == "transient":
				pass
			else:
				return "SKIP"
		TD['new']['wynik'] = json.dumps(prev, separators=(',',':'))
		TD['new']['data'] = datetime.now();
	return "MODIFY"
	$$
LANGUAGE 'plpythonu' VOLATILE;
--not secure for users to modify sesja_id directly, possible sql-injection


CREATE TRIGGER manage_json 
	BEFORE INSERT ON "SERIE" 
	FOR EACH ROW EXECUTE PROCEDURE put_json();

