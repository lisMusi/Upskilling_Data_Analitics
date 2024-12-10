-- Nivel 1

-- Ejercicio 1: crear una tabla llamada "credit_card" que almacene detalles sobre las tarjetas de crédito

CREATE TABLE credit_card (
	id varchar(20) NOT NULL PRIMARY KEY, 
    iban varchar(40), 
    pan varchar(20), 
    pin varchar(10), 
    cvv varchar(4), 
    expiring_date date
);

-- Como al intentar cargar los datos en la tabla nos da error por el formato de la fecha cambio la variable que contiene la fecha a formato texto
ALTER TABLE transactions.credit_card 
CHANGE COLUMN expiring_date 
expiring_date VARCHAR(15);

SELECT*
FROM credit_card; -- compruebo que los datos se han cargado correctamente esta vez

-- Para intentar hacer un cambio de formato de las fechas (que están en formato americano) para que SQL las acepte y pueda trabajar con ellas en formato date
-- necesito deshabilitar momentaneamente las foreign keys y la opción de actualización segura.
-- Tendré que habilitarlas justo después de ejecutar la query porque esto no es recomendable tenerlo desactivado ya que podríamos afectar la base de datos.

SET FOREIGN_KEY_CHECKS=0; -- para desactivar las foreign keys
SET SQL_SAFE_UPDATES=0; -- para desabilitar la opción de actualización segura

-- Ahora cambio los valores de la fecha al modelo de fecha que SQL acepta para luego cambiar el tipo de variable:
UPDATE transactions.credit_card 
SET expiring_date = DATE_FORMAT(STR_TO_DATE(expiring_date, '%m/%d/%Y'), '%Y-%m-%d') -- str_to_date cambia las fechas de formato string a date
WHERE credit_card.id IS NOT null;

SET FOREIGN_KEY_CHECKS=1; -- vuelvo a activar las foreign keys
SET SQL_SAFE_UPDATES=1; -- vuelvo a habilitar la opción de actualización segura

-- Comprobamos que los valores se han cambiado correctamente:
SELECT*
FROM credit_card;

-- Vuelvo a cambiar el tipo de variable a fecha:
ALTER TABLE transactions.credit_card 
CHANGE COLUMN expiring_date 
expiring_date date;

-- Para relacionar las tablas credit_card y transactions lo hago a través de la PK de credit_card que relacionaré con la FK credit_card_id de transaction
-- Creo la FK credit_card_id de transaction:
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);


-- Ejercicio 2: Cambiar el número de cuenta del usuario ID CcU-2938

SELECT*
FROM credit_card
WHERE id = 'CcU-2938'; -- primero observo los datos del usuario

-- Cambio el iban del usuario:
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT*
FROM credit_card
WHERE id = 'CcU-2938'; -- compruebo que el cambio se ha efectuado


-- Ejercicio 3: Ingresar un nuevo usuario en la tabla "transaction"

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) -- nombre de las columnas a las que afectará nuestra fila de datos.
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
 -- Los valores de las columnas los pongo en orden para evitar errores. 
 
 -- Me da error porque company_id es una foreign key lo que significa que: 
 -- Primero he de crear el mismo valor de id en la tabla 'company' 
INSERT INTO company (id)
VALUES ('b-9999');

 -- También he de crear el mismo valor de id en la tabla 'credit_card' 
INSERT INTO credit_card (id)
VALUES ('CcU-9999');

-- Vuelvo a intentar la primera query:

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Compruebo que se haya insertado bien nuestra fila en la tabla transaction:
SELECT * 
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


-- Ejercicio 4: Eliminar la columna "pan" de la tabla credit_card:

ALTER TABLE credit_card
DROP COLUMN pan; -- Elimino la columna 'pan' de 'credit_card'

SELECT * 
FROM credit_card; -- Compruebo que la he eliminado correctamente


-- Nivel 2

-- Ejercicio 1: Elimina de la tabla transaction el registro ID: 02C6201E-D90A-1859-B4EE-88D2986D3B02.

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT *
FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';


-- Ejercicio 2: Crear una vista (VistaMarketing)

CREATE VIEW VistaMarketing AS
SELECT c.company_name AS nombre, ANY_VALUE(c.phone) AS telefono, 
ANY_VALUE(c.country) AS pais, ROUND(AVG(t.amount), 2) AS media_de_compra
FROM company AS c
JOIN transaction AS t ON c.id = t.company_id
WHERE t.declined = 0 -- filtro para descartar las ventas declinadas
GROUP BY 1;-- Creo la vista

SELECT * 
FROM VistaMarketing
ORDER BY media_de_compra DESC; --  Visualizo la vista ordenada de mayor a menor Media de compra


-- Ejercicio 3: Filtra la vista VistaMarketing para mostrar solo las compañías alemanas

SELECT * 
FROM VistaMarketing
WHERE Pais = 'Germany';


-- Nivel 3

-- Ejercicio 1: Dejar los comandos ejecutados para obtener el diagrama (describir el paso a paso):

-- Lo primero es cambiar los tipos de los campos de la tabla 'credit_card':
ALTER TABLE transactions.credit_card 
CHANGE COLUMN iban 
iban VARCHAR(50);

ALTER TABLE transactions.credit_card 
CHANGE COLUMN pin 
pin VARCHAR(4);

ALTER TABLE transactions.credit_card 
CHANGE COLUMN cvv 
cvv INT;

ALTER TABLE transactions.credit_card 
CHANGE COLUMN expiring_date  
expiring_date VARCHAR(20);

-- También he de añadir una nueva columna llamada 'fecha_actual' que sea de tipo DATE
ALTER TABLE transactions.credit_card 
ADD fecha_actual DATE;

-- Eliminar la columna 'website' de la tabla 'company' 
ALTER TABLE company 
DROP COLUMN website;

-- Ahora hemos de crear la tabla data_user
-- Creamos la tabla user e introducimos los datos:
CREATE INDEX idx_user_id ON transaction(user_id); -- repetir en credit_card
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

-- Renombrar la tabla a data_user:
RENAME TABLE user
TO data_user;

-- Y cambiar el nombre de la columna 'email' de la tabla 'data_user' por 'personal_email' 
ALTER TABLE data_user
CHANGE COLUMN email
personal_email VARCHAR(150);

-- Y visualizarla:
SELECT *
FROM data_user;

-- Como al intentar hacer el diagrma la relación entre las tablas 'data_user' y 'transaction' no es correcta, 
-- introducimos el usuario que existe en 'transaction' pero no en 'data user':
INSERT INTO data_user (id)
VALUES ('9999');

-- Borro la FK existente:
ALTER TABLE data_user
DROP FOREIGN KEY data_user_ibfk_1;

-- y vuelvo a establecer la relación:
ALTER TABLE transaction
ADD FOREIGN KEY (user_id) REFERENCES data_user(id);


-- Ejercicio 2: Crear una vista "InformeTecnico". Mostrar los resultados ordenados de manera descendente en función del ID de transaction.

CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaccion, d.name AS nombre_usuario, d.surname AS apellido_usuario, 
cr.iban AS iban_de_tarjeta_usada, c.company_name AS nombre_compañia_de_transaccion_realizada
FROM transaction AS t
JOIN data_user AS d ON t.user_id = d.id
JOIN credit_card AS cr ON t.credit_card_id = cr.id
JOIN company AS c ON t.company_id = c.id;

--  Visualizo la vista ordenada de mayor a menor id de Transaction
SELECT * 
FROM InformeTecnico
ORDER BY id_transaccion DESC;
