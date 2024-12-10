--  Nivel 1:

-- Para ver los datos de la tabla company:
SELECT * 
fROM company;

-- Para ver los datos de la tabla transaction:
SELECT * 
FROM transaction;

-- 	Listado de los paises que estan comprando:
SELECT DISTINCT country AS Paises
FROM company
INNER JOIN transaction 
ON company.id = transaction.company_id;

-- Cantidad de paises que estan comprando:
SELECT COUNT(DISTINCT country) AS Cantidad_de_paises
FROM company
INNER JOIN transaction 
ON company.id = transaction.company_id;

-- Compañía con la media mas alta de ventas, utilizando Limit 1:
SELECT DISTINCT company.company_name AS Company, ROUND(AVG(transaction.amount), 2) AS ventas
FROM company
INNER JOIN transaction ON company.id = transaction.company_id
WHERE transaction.declined = 0 -- usamos este filtro para descartar las ventas que han sido declinadas (0 = no declinado, 1 = declinado)
GROUP BY company.company_name
ORDER BY AVG(transaction.amount) DESC
LIMIT 1;
--  Compañía con la media mas alta de ventas, utilizando subquery:                      
SELECT DISTINCT company.company_name AS Company, ROUND(AVG(transaction.amount), 2) AS ventas
FROM company
INNER JOIN transaction ON company.id = transaction.company_id
WHERE transaction.declined = 0
GROUP BY company.company_name
HAVING AVG(transaction.amount) = (SELECT MAX(media)
									FROM (SELECT AVG(amount) AS media
											FROM transaction
                                            WHERE declined = 0
											GROUP BY company_id) AS subquery);

-- Mostrar todas las transacciones realizadas por empresas alemanas:
SELECT * 
FROM transaction
WHERE transaction.company_id IN (SELECT id
								FROM company
								WHERE country = 'Germany');

-- Lista de empresas que han realizado transacciones por un 'amount' superior a la media:
SELECT company.company_name AS Company
FROM company
WHERE company.id IN (SELECT transaction.company_id
						FROM transaction
						WHERE transaction.amount > (SELECT AVG(amount)
													FROM transaction));
                                                    
--  Entregar el listado de empresas que NO tienen transacciones registradas:
SELECT company.company_name AS Company
FROM company
WHERE company.id NOT IN (SELECT transaction.company_id
						FROM transaction); -- como esta consulta no me da ningun nombre, compruebo que es correcto haciendo la consulta contraria:
--  Listado de empresas que SI tienen transacciones registradas:
SELECT company.company_name AS Company
FROM company
WHERE company.id IN (SELECT transaction.company_id
						FROM transaction); -- confirmamos que todas las empresas tienen transacciones registradas
			
--  Nivel 2:
            
-- Identifica los 5 días que se generó más cantidad de ingressos a la empresa por ventas. 
-- Muestra la fecha de cada transacción junto con el total de les ventas:
SELECT DATE(timestamp) AS fecha, SUM(amount) AS ingresos -- usamos DATE() para extraer la fecha, sin la hora, de la columna 'timestamp' 
FROM transaction
WHERE declined = 0 -- para tener en cuenta solo las ventas no declinadas
GROUP BY DATE(timestamp)
ORDER BY SUM(amount) DESC
LIMIT 5; -- para ver solo los 5 días con mayor cantidad de ingresos

-- Cúal es la media de ventas por país? 
-- Presenta los resultados ordenados de mayor a menor media.
SELECT company.country AS pais, ROUND(AVG(transaction.amount),2) AS ventas
FROM company
JOIN transaction ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY 1
ORDER BY 2 DESC;

-- Lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que "Non Institute":
-- Lista aplicando JOIN y subconsultas:

SELECT transaction.*
FROM transaction
JOIN company ON transaction.company_id = company.id 
WHERE company.country = (SELECT company.country
							FROM company
							WHERE company.company_name = 'Non Institute'); -- Incluido 'Non Institute'

SELECT transaction.*
FROM transaction
JOIN company ON transaction.company_id = company.id 
WHERE company.country = (SELECT company.country
							FROM company
							WHERE company.company_name = 'Non Institute')
AND company.company_name != 'Non Institute'; -- Excluyendo 'Non Institute'

-- Lista solo con subconsultas:
SELECT *
FROM transaction
WHERE transaction.company_id IN (SELECT company.id
									FROM company
									WHERE company.country = (SELECT company.country
																FROM company
																WHERE company.company_name = 'Non Institute')); -- Incluido 'Non Institute'

SELECT *
FROM transaction
WHERE transaction.company_id IN (SELECT company.id
									FROM company
									WHERE company.country = (SELECT company.country
																FROM company
																WHERE company.company_name = 'Non Institute')
									AND company.company_name != 'Non Institute'); -- Excluyendo 'Non Institute'

--  Nivel 3:
            
-- Nombre, teléfono, país, fecha y amount de las empresas que realizaron transacciones con valores entre 100 y 200 euros 
-- en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 o 13 de marzo de 2022. 
-- Ordenalos de mayor a menor cantidad.

SELECT company.company_name AS nombre, company.phone AS telefono, company.country AS pais, DATE(transaction.timestamp) AS fecha, 
transaction.amount AS amount
FROM company
JOIN transaction ON company.id = transaction.company_id
WHERE transaction.amount BETWEEN 100 AND 200 AND DATE(transaction.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY transaction.amount DESC;

-- Listado de las empresas donde se especifique si tienen más de 4 transacciones o menos:
SELECT company.company_name AS nombre, 
       CASE -- funciona como un bucle que recorre las condiciones y devuelve un valor asociado cuando la condición se cumple (como una sentencia if-else)
           WHEN COUNT(transaction.amount) >= 4 THEN 'Mas de 4'
           ELSE 'Menos de 4'
       END AS categoria_amount -- después del END necesario para indicar que acaba el bucle, se le puede nombrar
FROM company
JOIN transaction ON company.id = transaction.company_id
GROUP BY 1;

