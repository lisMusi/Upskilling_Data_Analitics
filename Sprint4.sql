-- Nivel 1: Diseña una base de datos con un esquema de estrella:
 
CREATE DATABASE IF NOT EXISTS orders -- Creo la base de datos
DEFAULT CHARACTER SET = 'utf8mb4' DEFAULT COLLATE 'utf8mb4_general_ci'; 

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
    cvv VARCHAR(4),
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
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura, porque sino no me deja realizar el cambio

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

-- Ahora añado las Foreign Keys que relacionaran las tablas entre ellas en este esquema de estrella
ALTER TABLE orders.transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id);

ALTER TABLE orders.transaction
ADD FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE orders.transaction 
CHANGE COLUMN user_id 
user_id INT;   -- cambio el campo 'user_id' a INT para que sea igual al campo 'id' de la tabla 'users'

ALTER TABLE orders.transaction
ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- Nivel 1:
-- Ejercicio 1: Realiza una subconsulta que muestre todos los usuarios con más de 30 transacciones

SELECT u.name AS nombre_usuario, u.surname AS apellido_usuario, COUNT(t.id) AS transacciones
FROM users AS u
JOIN transaction AS t
ON u.id = t.user_id
GROUP BY 1, 2
HAVING transacciones > 30;

-- Nivel 1:
-- Ejercicio 2: Media del 'amount' por IBAN de las targetas de crédito en la compañía Donec Ltd

SELECT c.company_name AS nombre_compañia, cc.id AS tarjeta_credito, cc.iban, ROUND(AVG(t.amount),2) AS importe
FROM credit_cards AS cc
JOIN transaction AS t
JOIN companies AS c
WHERE cc.id = t.credit_card_id
AND t.company_id IN (SELECT c.id
						FROM companies
                        WHERE c.company_name = 'Donec Ltd')
GROUP BY 1, 2;


-- Nivel 2: Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas 3 transacciones fueron declinadas.

SELECT credit_card_id, SUM(declined) -- compruebo cuantas tarjetas han sido declinadas más de una vez en general
FROM transaction
GROUP BY 1; -- Ninguna tarjeta ha sido declinada más de una vez

-- Primero creo una tabla temporal:
CREATE TEMPORARY TABLE IF NOT EXISTS status_card AS (SELECT credit_card_id, timestamp, SUM(declined) AS total_declinadas, 
			ROW_NUMBER() OVER (PARTITION BY credit_card_id  -- uso la función row_number() para contar el numero de transacciones por tarjeta
								ORDER BY timestamp DESC) AS transaccion -- y lo ordeno por fecha descendiente para que las ultimas sean las primeras
	FROM transaction
	GROUP BY 1, 2); -- pero salen todas y solo quiero las 3 ultimas por compañia

-- Y ahora si creo mi tabla con los campos que me interesan:    
CREATE TABLE card_status AS -- Tabla 5
SELECT credit_card_id,
	CASE -- uso un condicional para obtener las tarjetas activas o inactivas segun las ultimas 3 transacciones declinadas
		WHEN SUM(total_declinadas) >= 3 THEN 'inactive'
        ELSE 'active'
	END AS status
FROM status_card
WHERE transaccion <= 3 -- con este where obtengo las 3 ultimas transacciones (declinadas o no) por tarjeta
GROUP BY 1; -- uso un condicional para obtener las tarjetas activas o inactivas segun las ultimas 3 transacciones declinadas

SELECT * FROM orders.card_status; -- visualizo mi nueva tabla

-- Ahora creo la PK y la FK con la que la relacionaré:
ALTER TABLE card_status
ADD PRIMARY KEY (credit_card_id);

ALTER TABLE credit_cards
ADD FOREIGN KEY (id) REFERENCES card_status(credit_card_id);

-- Nivel 2:
-- Ejercicio 1: ¿Cuántas tarjetas están activas?

SELECT COUNT(credit_card_id) AS tarjetas_activas
FROM card_status
WHERE status = 'active'; -- todas las tarjetas están activas

SELECT COUNT(credit_card_id) AS tarjetas_inactivas
FROM card_status
WHERE status = 'inactive'; -- comprobamos mirando las tarjetas inactivas


-- Nivel 3: Crea una tabla que nos permita unir los datos del archivo products.csv con la base de datos creada, teniendo en cuenta que en transaction hay product_ids. 

SELECT t.id, t.products_id
FROM transaction AS t; -- primero observamos los datos que incluiremos en la tabla

-- creamos la tabla 'products':
CREATE TABLE products( -- Tabla 6
	id VARCHAR(10), 
    product_name VARCHAR(40),
    price VARCHAR(10),
    colour VARCHAR(10),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(10));

-- cargamos los datos de la tabla desde el archivo csv:
LOAD DATA LOCAL INFILE '/Users/liss/Desktop/ItAcademy/2-Especialización/¡Sprints!/S4/Datos/products.csv'
INTO TABLE orders.products
FIELDS TERMINATED BY ','  -- Delimitador de las columnas
LINES TERMINATED BY '\n'  -- Fin de línea
IGNORE 1 ROWS;            -- Ignorar la primera línea (encabezados)

-- visualizamos la tabla:
SELECT * FROM orders.products;

-- sustituimos los símbolos '$' de la columna price y cambiamos el tipo de dato de VARCHAR a DECIMAL:
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura, porque sino no me deja realizar el cambio

UPDATE products
SET price = REPLACE(price, "$", "") 
WHERE price IS NOT NULL;

ALTER TABLE orders.products 
CHANGE COLUMN price 
price DECIMAL(10,2);

SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

-- elimino los espacios despues de las comas de 'products_id' de la tabla 'transaction':
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura, porque sino no me deja realizar el cambio

UPDATE transaction
SET products_id = REPLACE(products_id, " ", "") 
WHERE products_id IS NOT NULL;

SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

SELECT * FROM orders.transaction; -- visualizo los cambios

-- ahora creo la tabla puente 'sales' que me relaciona las tablas 'products' y 'transaction':
CREATE TABLE sales AS( -- tabla 7
	SELECT t.id AS transaction_id, p.id AS product_id
	FROM products AS p
	JOIN transaction AS t 
	ON FIND_IN_SET(p.id, t.products_id));

-- visualizo la nueva tabla:
SELECT * FROM orders.sales;

-- y compruebo que todos los valores son correctos, sabiendo que tenemos 578 transaction_id diferentes:
SELECT COUNT(DISTINCT transaction_id)
FROM sales;

-- creo la PK de la tabla 'products':
ALTER TABLE products
ADD PRIMARY KEY (id);

-- le añado las FKs a la tabla 'sales' que la relacionan con 'transaction' y 'products':
ALTER TABLE sales
ADD FOREIGN KEY (transaction_id) REFERENCES transaction (id),
ADD FOREIGN KEY (product_id) REFERENCES products (id);

-- Nivel 3: 
-- Ejercicio 1: Número de veces que se ha vendido cada producto

SELECT p.product_name AS producto, COUNT(s.product_id) AS cantidad_de_ventas
FROM sales AS s
JOIN products AS p
ON p.id = s.product_id
GROUP BY p.id
ORDER BY cantidad_de_ventas DESC;

