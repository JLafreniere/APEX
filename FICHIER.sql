
--Michael Trahan
--Jonathan Lafreniere
------------------------------------------Drop tables --------------------------------------
DROP TABLE CONTACTS CASCADE CONSTRAINTS;
DROP TABLE FOURNISSEURS CASCADE CONSTRAINTS;
DROP TABLE CLASSES CASCADE CONSTRAINTS;
DROP TABLE PIECES CASCADE CONSTRAINTS;
DROP TABLE COMMANDES CASCADE CONSTRAINTS;
DROP TABLE DETAIL_COMMANDE CASCADE CONSTRAINTS;
DROP TABLE ACCES CASCADE CONSTRAINTS;

-----------------------------------------Drop sequences ------------------------------------
drop sequence seq_commandes;
drop sequence seq_fournisseurs;
drop sequence seq_classes;
-----------------------------------------Sequences -----------------------------------------

--Sequence commande
create sequence seq_commandes
start with 1000
minvalue 1000
maxvalue 9999
increment by 1
nocycle;
/
--Sequence fournisseur
create sequence seq_fournisseurs
start with 10
minvalue 10
maxvalue 999
increment by 1
nocycle;
/
--Sequence classe
create sequence seq_classes
start with 5
minvalue 5
maxvalue 99
increment by 1
nocycle;
/
-----------------------------------------Cr�ation de table ---------------------------------
CREATE TABLE FOURNISSEURS
( NO_FOURNISSEUR  NUMBER(3) CONSTRAINT  PK_FOURNISSEURS  PRIMARY KEY,
  NOM   VARCHAR2(15)
      CONSTRAINT  NN_FOURNISSEURS_NOM  NOT NULL
      CONSTRAINT  UN_FOURNISSEURS_NOM  UNIQUE,
  NO_CIVIQUE VARCHAR2(5),
  RUE   VARCHAR2(30),
  APP   VARCHAR2(3),
  VILLE   VARCHAR2(15) DEFAULT 'TROIS-RIVIERES',
  PROVINCE  VARCHAR2(20),
  CODE_POSTAL VARCHAR2(7),
  TELEPHONE VARCHAR2(10));
/
CREATE TABLE CONTACTS
( NO_FOURNISSEUR NUMBER(3) CONSTRAINT FK_CONTACTS_FOURNISSEURS REFERENCES FOURNISSEURS(NO_FOURNISSEUR),
  NO_CONTACT  CHAR(3),
  NOM VARCHAR2(35),
  CELL CHAR(10),
  ROLE VARCHAR2(35),
   CONSTRAINT PK_CONTACTS  PRIMARY  KEY(NO_FOURNISSEUR, NO_CONTACT));
/
CREATE TABLE CLASSES
( NO_CLASSE NUMBER(2) CONSTRAINT PK_CLASSES  PRIMARY  KEY,
  DESCRIPTION VARCHAR2(35),
  QTE_MAXIMUM NUMBER(3));
/
CREATE TABLE PIECES
( NO_PIECE  CHAR(3) CONSTRAINT PK_PIECE  PRIMARY  KEY,
  DESCRIPTION VARCHAR2(15)
      CONSTRAINT  NN_PIECE_DESCRIPTION  NOT  NULL,
  CLASSE  number(2) CONSTRAINT FK_PIECES_CLASSES REFERENCES CLASSES(NO_CLASSE),
  COULEUR VARCHAR2(15),
  POIDS   NUMBER
      CONSTRAINT CK_PIECE_POIDS  CHECK(POIDS > 0 AND POIDS < 30),
  PRIX    NUMBER(6,2),
  QTE_INVENTAIRE  NUMBER(3),
  SCHEMA_PIECE blob,
  MIME_TYPE_PIECE varchar2(255),
  FILE_NAME_PIECE varchar2(255)
  );
/
CREATE TABLE COMMANDES
(NO_COMMANDE  NUMBER(4) CONSTRAINT PK_COMMANDES  PRIMARY KEY,
 DATE_COMMANDE  DATE,
 RESPONSABLE VARCHAR2(25),
 MONTANT NUMBER,
 ESCOMPTE    NUMBER,
 COMMENTAIRE VARCHAR2(255));
/
CREATE TABLE DETAIL_COMMANDE 
( NO_COMMANDE NUMBER(4) CONSTRAINT FK_DETAIL_COMMANDES REFERENCES COMMANDES (NO_COMMANDE),
  NO_PIECE CHAR(3) CONSTRAINT FK_DETAIL_PIECES REFERENCES PIECES (NO_PIECE),
  NO_FOURNISSEUR NUMBER(3) CONSTRAINT FK_DETAIL_FOUNISSEUR REFERENCES FOURNISSEURS(NO_FOURNISSEUR),
  QUANTITE NUMBER(3),
  PRIX NUMBER(6,2),
  TOTAL NUMBER(8,2),
  DATE_LIVRAISON DATE,
  COMMENTAIRE VARCHAR2(255),
    CONSTRAINT PK_DETAIL_COMMANDE PRIMARY KEY(NO_COMMANDE, NO_PIECE, NO_FOURNISSEUR));
 / 
CREATE TABLE ACCES 
(ID_ACCES NUMBER CONSTRAINT PK_ACCES PRIMARY KEY,
CODE_ACCES VARCHAR2(255) CONSTRAINT NN_CODE_ACCES_ACCES NOT NULL,
MOT_PASSE VARCHAR(255) CONSTRAINT NN_MOT_PASSE_ACCES NOT NULL);
/
-------------------------------------Triggers -------------------------------------------------

--Trigger commandes
create or replace trigger ti_commandes
before insert on commandes
for each row
begin

if INSERTING then
:new.no_commande := seq_commandes.nextval;
end if;

end;
/
--Trigger fournisseurs
create or replace trigger ti_fournisseurs
before insert on fournisseurs
for each row
begin

if INSERTING then
:new.no_fournisseur := seq_fournisseurs.nextval;
end if;

end;
/
--Trigger contacts
create or replace trigger ti_contacts
before insert on contacts
for each row
declare
new_id number;
id_char char;
begin

if INSERTING then

select NVL(max(substr(no_contact, 2, 2)),-1) into new_id from contacts where substr(Upper(:NEW.nom), 0, 1) = substr(upper(nom), 0, 1);
new_id := new_id+1;
id_char := substr(:NEW.nom, 0, 1);

  if (new_id < 10) then
  :new.no_contact := substr(upper(:new.nom),0,1) || 0 || new_id; 
 else
  :new.no_contact := substr(upper(:new.nom),0,1) || new_id;
  end if;
end if;
end;
/
--Trigger classes
create or replace trigger ti_classes
before insert on classes
for each row
begin

if INSERTING then
:new.no_classe := seq_classes.nextval;
end if;

end;
/
--Trigger pi�ce
create or replace trigger ti_pieces
before insert on pieces
for each row
declare
new_id number;
id_char char;
begin

if INSERTING then

select NVL(max(substr(no_piece, 2, 2)),-1) into new_id from pieces where substr(Upper(:NEW.description), 0, 1) = substr(upper(description), 0, 1);
new_id := new_id+1;
id_char := substr(:NEW.description, 0, 1);

  if (new_id < 10) then
  :new.no_piece := id_char||'0'||new_id;
  
  else
  :new.no_piece := id_char||new_id;
  end if;
end if;
end;

/
-------------------------------------Entete Package -------------------------------------------
create or replace package pck_fournisseur is 
function valider_date(p_date date) return boolean;
end pck_fournisseur;
/

-------------------------------------Body Package----------------------------------------------
create or replace package body pck_fournisseur as

--Fonction retournant vrai si la date en parametre est plus petite qu'aujourd'hui
--Possible utilité : Validation sur une date de naissance
function valider_date(p_date date) return boolean is
begin

if p_date <= sysdate then
return true;
else return false;
end if;
end valider_date;

end pck_fournisseur;
/

-------------------------------------insert ---------------------------------------------------

--Les inserts peuvent être considérés comme des jeux d'essais pour tout ce qui est triggers / séquences



INSERT INTO ACCES VALUES (1, 'bob', 'bob');
INSERT INTO ACCES VALUES (2, 'ap0301', 'bob');
INSERT INTO ACCES VALUES (3, 'scott', 'scott');
COMMIT;

INSERT INTO FOURNISSEURS VALUES (NULL, 'LACOMBE', '3352', 'RUE LAJOIE', NULL, DEFAULT, 'QUEBEC', 'G9A 5E6', NULL);
INSERT INTO FOURNISSEURS VALUES (NULL, 'GOYER', '8526', 'BOUL. CHAREST', NULL, 'QUEBEC', 'QUEBEC', 'G1S 4S2', '4185257766');
INSERT INTO FOURNISSEURS VALUES (NULL, 'SMITH', '677', 'Queen St. East', null, 'TORONTO', 'ONTARIO', 'M4M 1G6', '416465547');
INSERT INTO FOURNISSEURS VALUES (NULL, 'LAJOIE', '35', 'Rue de Port Royal Est', '345', 'MONTREAL', 'QUEBEC', 'H3L 3T1', '5143871670') ;
INSERT INTO FOURNISSEURS VALUES (NULL, 'JONES', '45', 'O''Connor Street', NULL, 'OTTAWA', 'ONTARIO', 'K1P 1A4', NULL) ;
COMMIT;

INSERT INTO CONTACTS VALUES (10, NULL, 'BOB', '8193761721', 'VENDEUR');
COMMIT;
INSERT INTO CONTACTS VALUES (11, NULL, 'JEAN', '8193769787', 'ASSISTANT');
COMMIT;
INSERT INTO CONTACTS VALUES (11, NULL, 'BOB', '8193761721', 'VENDEUR');
COMMIT;
INSERT INTO CONTACTS VALUES (11, NULL, 'JOHN', '8193765858', 'DIRECTEUR');
COMMIT;
INSERT INTO CONTACTS VALUES (12, NULL, 'CATHERINE', '8196685757', 'COMMUNICATIONS');
COMMIT;
INSERT INTO CONTACTS VALUES (13, NULL, 'LEBLANC', '8193761721', 'COMMUNICATIONS');  
COMMIT;
INSERT INTO CONTACTS VALUES (13, NULL, 'NOLIN', '8197775555', 'DIRECTEUR');
COMMIT;
INSERT INTO CONTACTS VALUES (14, NULL, 'NOLIN', '8197775555', 'DIRECTEUR');
COMMIT;


INSERT INTO CLASSES VALUES (NULL, 'EQUIPEMENT SPORTIF', 85);
INSERT INTO CLASSES VALUES (NULL, 'VETEMENTS', 200);
INSERT INTO CLASSES VALUES (NULL, 'ACCESSOIRES', 75);
INSERT INTO CLASSES VALUES (NULL, 'ENTRAINEMENT', 57);
INSERT INTO CLASSES VALUES (NULL, 'PIECES DE REPARATION', 25);
INSERT INTO CLASSES VALUES (NULL, 'CHAUSSURES', 210);
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'PATINS', 5,'GRIS', 6, 95.63, 100, NULL, NULL, NULL) ;
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'RAQUETTES', 5, 'BRUN', 15, 85.36, 456, NULL, NULL, NULL) ;
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'SKIS', 5, 'ROUGE', 20, 560, 50, NULL, NULL, NULL) ;
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'SKIS', 5, 'BLEU', 18, 800, 20, NULL, NULL, NULL) ;
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'ANORAKS', 6, 'ROUGE', 4, 350, 10, NULL, NULL, NULL) ;
COMMIT;
INSERT INTO PIECES VALUES (NULL, 'BONNETS', 7, 'JAUNE', 1, 45, 25, NULL, NULL, NULL) ;
COMMIT;

INSERT INTO COMMANDES VALUES (NULL, sysdate-100, 'GUYLAINE', 735.5, NULL, NULL) ;
INSERT INTO COMMANDES VALUES (NULL, sysdate-700, 'GUYLAINE', 37.5, 15, '15 % Bon fournisseur, P23') ;
INSERT INTO COMMANDES VALUES (NULL, sysdate-10, 'GUYLAINE', 10.5, NULL, 'Commande rapide, R01') ;
INSERT INTO COMMANDES VALUES (NULL, sysdate-412, 'GUYLAINE', 318, 1, 'Longue echeance, R01') ;
INSERT INTO COMMANDES VALUES (NULL, SYSDATE-10, 'LUC', 108.5, 4, 'Sp�cial fragile');
INSERT INTO COMMANDES VALUES (NULL, sysdate-45, 'GUYLAINE', 735.5, NULL, 'Livrable aujourd''hui, S02') ;
COMMIT;
  
INSERT INTO DETAIL_COMMANDE VALUES (1000, 'P00', 10, 5, 25.50, 127.50, SYSDATE-75, 'Insertion1');
INSERT INTO DETAIL_COMMANDE VALUES (1000, 'P00', 11, 10, 25.50, 255, SYSDATE-85, 'Insertion2');
INSERT INTO DETAIL_COMMANDE VALUES (1000, 'B00', 10, 15, 10, 150, SYSDATE-95, 'Insertion3');
INSERT INTO DETAIL_COMMANDE VALUES (1000, 'R00', 10, 4, 10, 40, SYSDATE-92, 'Insertion4');
INSERT INTO DETAIL_COMMANDE VALUES (1000, 'B00', 11, 8, 20, 160, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1001, 'B00', 12, 3, 12.5, 37.5, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1002, 'S00', 12, 3, 3.5, 10.5, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1003, 'A00', 13, 2, 30, 60, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1003, 'S00', 14, 12, 21.5, 258, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1004, 'S01', 14, 7, 15.5, 108.5, SYSDATE-75, 'Insertion5');
INSERT INTO DETAIL_COMMANDE VALUES (1005, 'P00', 11, 5, 25.50, 127.50, SYSDATE+15, 'Insertion6');
INSERT INTO DETAIL_COMMANDE VALUES (1005, 'B00', 11, 15, 10, 150, SYSDATE+1, 'Insertion8');
INSERT INTO DETAIL_COMMANDE VALUES (1005, 'R00', 11, 4, 10, 40, SYSDATE+5, 'Insertion9');
INSERT INTO DETAIL_COMMANDE VALUES (1005, 'B00', 12, 6, 20, 160, SYSDATE+4, 'Insertion10');

COMMIT;
/
begin 
dbms_output.put_line('Debut de la section de test');
dbms_output.put_line('Test 1 est-ce que 10 octobre 2016 est plus petit que la date d''aujourd''hui?');

--Le resultat attendu est que la date est plus petite que celle d'aujourd'hui, donc le return est true
if pck_fournisseur.valider_date('2016-10-10') then
dbms_output.put_line('La date entrée est plus petite qu''aujourd''hui');
else 
dbms_output.put_line('La date entrée est plus grande qu''aujourd''hui');
end if;
dbms_output.put_line(' ');

dbms_output.put_line('Test 2 est-ce que 10 decembre 2016 est plus petit que la date d''aujourd''hui?');

--Le resultat attendu est que la date est plus grande que celle d'aujourd'hui, donc le return est false
if pck_fournisseur.valider_date('2016-12-10') then
dbms_output.put_line('La date entrée est plus petite qu''aujourd''hui');
else 
dbms_output.put_line('La date entrée est plus grande qu''aujourd''hui');
end if;

dbms_output.put_line('Fin des tests');
end;
