-- Nivel 1: Dissenya una base de dades amb un esquema d'estrella:
 
CREATE DATABASE orders; -- Creo la base de datos

use orders; -- y la selecciono para comenzar a crear las tablas que contendrá

CREATE TABLE transaction( -- Tabla 1
	id VARCHAR(40) NOT NULL PRIMARY KEY, -- a cada tabla le asigno su Primary Key
    credit_card_id VARCHAR(10),
    company_id VARCHAR(10),
    timestamp TIMESTAMP,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    products_id VARCHAR(10),
    user_id VARCHAR(10),
    latitude VARCHAR(20),
    longitude VARCHAR(20));
    
 CREATE TABLE users( -- Tabla 2
	id VARCHAR(10) NOT NULL PRIMARY KEY,
    name VARCHAR(20),
    surname VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(40),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(10),
    adress VARCHAR(100)); 
    
 CREATE TABLE credit_cards( -- Tabla 3
	id VARCHAR(10) NOT NULL PRIMARY KEY,
    user_id VARCHAR(10),
    iban VARCHAR(40),
    pan VARCHAR(40),
    pin VARCHAR(4),
    cvv INT,
    track1 VARCHAR(50),
    track2 VARCHAR(50),
    expiring_date DATE);  

 CREATE TABLE companies( -- Tabla 4
	id VARCHAR(10) NOT NULL PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(50),
    country VARCHAR(100),
    website VARCHAR(100)); 

-- Como me da error al intentar importar los datos de las tablas del csv:
SHOW VARIABLES LIKE 'secure_file_priv'; -- NULL significa que la exportación o importación de datos está desactivada
-- Para poder activar la exportación e importación de datos primero cree el archivo /etc/my.cnf que no existía 
-- y le añadí los valores: [mysqld]secure_file_priv="" local_infile=1 [client]loose-local-infile=1

-- También me aseguré que la variable local_infile estuviera activa
SET GLOBAL local_infile = true;
SHOW VARIABLES LIKE 'local_infile';

-- Y como me seguía dando error, edite la conexión en la subpestaña «Advanced» casilla «Others» añadiendo 'OPT_LOCAL_INFILE=1'. 

-- Al intentar cargar los datos el campo 'timestamp' (de 'transactions') tengo valores 0, cambio el tipo a VARCHAR(50) en la tabla:
ALTER TABLE orders.transaction 
CHANGE COLUMN timestamp 
timestamp VARCHAR(50);

-- Ahora importo los datos desde 'transaction.csv' a la tabla creada:
LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/transactions.csv'
INTO TABLE orders.transaction
FIELDS TERMINATED BY ';'    -- Delimitador de las columnas
LINES TERMINATED BY '\r\n'  -- Fin de línea (para arquivos que vienen de Windows)
IGNORE 1 ROWS;              -- Ignorar la primera línea (encabezados)

-- Y modifico el formato del campo 'timestamp' para volver a cambiar la variable de VARCHAR a TIMESTAMP
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura, porque sino no me deja realizar el cambio

UPDATE orders.transaction 
SET timestamp = DATE_FORMAT(STR_TO_DATE(timestamp, '%d/%m/%y %H:%i'), '%y-%m-%d %H:%i'); -- str_to_date cambia las fechas de formato string a date

SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

ALTER TABLE orders.transaction -- y vuelvo a cambiar el tipo de variable para 'timestamp' a TIMESTAMP
CHANGE COLUMN timestamp 
timestamp TIMESTAMP;

-- Al intentar cargar los datos el campo 'birth_date' (de 'users') me salen valores a 0, cambio el tipo de DATE a VARCHAR(20) en la tabla:
ALTER TABLE orders.users 
CHANGE COLUMN birth_date 
birth_date VARCHAR(20);

-- Tambien cambio el campo 'id' de VARCHAR a INT porque me daba errores de ordenación
ALTER TABLE orders.users 
CHANGE COLUMN id 
id INT;

-- Luego importo los datos desde los diferentes archivos de csv (users_usa, users_uk y users_ca) a la tabla creada: 
LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/users_usa.csv'
INTO TABLE orders.users
FIELDS TERMINATED BY ','    -- Delimitador de las columnas
OPTIONALLY ENCLOSED BY '"'  -- Delimitador de texto (comillas dobles), para que me coja bien la fecha y la dirección
LINES TERMINATED BY '\r\n'    -- Fin de línea (para archivos que vienen de Windows)
IGNORE 1 LINES;             -- Ignorar la primera línea (encabezados)

LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/users_uk.csv'
INTO TABLE orders.users
FIELDS TERMINATED BY ','    -- Delimitador de las columnas
OPTIONALLY ENCLOSED BY '"'  -- Delimitador de texto (comillas dobles), para que me coja bien la fecha y la dirección
LINES TERMINATED BY '\r\n'    -- Fin de línea (para archivos que vienen de Windows)
IGNORE 1 LINES;             -- Ignorar la primera línea (encabezados)

LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/users_ca.csv'
INTO TABLE orders.users
FIELDS TERMINATED BY ','    -- Delimitador de las columnas
OPTIONALLY ENCLOSED BY '"'  -- Delimitador de texto (comillas dobles), para que me coja bien la fecha y la dirección
LINES TERMINATED BY '\r\n'    -- Fin de línea (para archivos que vienen de Windows)
IGNORE 1 LINES;             -- Ignorar la primera línea (encabezados)

-- Y modifico el formato del campo 'birth_date' para volver a cambiar la variable de VARCHAR a DATE
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura, porque sino no me deja realizar el cambio

UPDATE orders.users 
SET birth_date = DATE_FORMAT(STR_TO_DATE(birth_date, '%b %d, %Y'), '%Y-%m-%d') -- str_to_date cambia las fechas de formato string a date
WHERE users.id IS NOT null;

SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

ALTER TABLE orders.users -- y vuelvo a cambiar el tipo de variable para 'birth date' a DATE
CHANGE COLUMN birth_date 
birth_date DATE;

-- Cambio el campo 'user_id' (de 'credit_cards') de VARCHAR a INT para que sea igual al campo 'id' de la tabla 'users': 
ALTER TABLE orders.credit_cards
CHANGE COLUMN user_id 
user_id INT;

-- También cambio el tipo de dato de 'expiring_date' de DATE a VARCHAR(20) en la tabla:
ALTER TABLE orders.credit_cards 
CHANGE COLUMN expiring_date 
expiring_date  VARCHAR(20);

-- Importo los datos desde 'credit_cards.csv' a la tabla creada:
LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/credit_cards.csv'
INTO TABLE orders.credit_cards
FIELDS TERMINATED BY ','   -- Delimitador de las columnas
LINES TERMINATED BY '\n'   -- Fin de línea
IGNORE 1 LINES;            -- Ignorar la primera línea (encabezados)

-- Y modifico el formato del campo 'expiring_date' para volver a cambiar la variable de VARCHAR a DATE
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura

UPDATE orders.credit_cards 
SET expiring_date = DATE_FORMAT(STR_TO_DATE(expiring_date, '%m/%d/%Y'), '%Y-%m-%d') -- str_to_date cambia las fechas de formato string a date
WHERE credit_cards.id IS NOT null;

SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

ALTER TABLE orders.credit_cards -- y vuelvo a cambiar el tipo de variable de 'expioring_date' a DATE
CHANGE COLUMN expiring_date 
expiring_date  DATE;

-- Y también importo los datos desde 'companies.csv' a la tabla creada:
LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/companies.csv'
INTO TABLE orders.companies
FIELDS TERMINATED BY ','    -- Delimitador de las columnas
LINES TERMINATED BY '\r\n'  -- Fin de línea
IGNORE 1 LINES;             -- Ignorar la primera línea (encabezados)


