﻿INSERT INTO "UZYTKOWNIK"("nazwa_uzytkownika") VALUES 
('JB'), 
('GP'), 
('KOWALCP4');

INSERT INTO "EKSPERYMENTY_DOSTEP"("id_uzytkownika", "sesja_id") VALUES
 (1,1),
 (1,1),
 (2,1),
 (3,1),
 (1,2), 
 (2,2);

INSERT INTO "SESJA_POMIAROWA"("nazwa_id") VALUES
 (1),
 (1),
 (1),
 (2),
 (3);

INSERT INTO "EKSPERYMENT"("nazwa") VALUES 
('EKSPERYMENT COMPTONA'), 
('PRAWO OHMA'), 
('OGNIWA PELTIERA');