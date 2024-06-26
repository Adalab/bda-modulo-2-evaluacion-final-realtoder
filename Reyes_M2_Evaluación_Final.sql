USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT title
FROM film;


-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT title
FROM film
WHERE rating = 'PG-13';


-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT title, description
FROM film
WHERE description LIKE '%amazing%';


-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT title
FROM film
WHERE length > 120;


-- 5. Recupera los nombres de todos los actores.

/*Entiendo que nos piden únicamente el nombre de pila (sin apellido) y que no importa que se repitan. Si nos pidieran nombres únicos, es decir, 
sin repeticiones, usaríamos DISTINCT.*/

SELECT first_name
FROM actor;


-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

/* He empleado 'LIKE' en lugar de '=' porque se piden apellidos que 'contengan' Gibson (podría darse el caso de que un actor 
se apellidara 'McGibson'.*/

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';


-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT first_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;


-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT title
FROM film
WHERE rating NOT IN ('R', 'PG-13');


-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT rating, COUNT(film_id) AS num_films
FROM FILM
GROUP BY rating;


-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

/*He optado por un INNER JOIN para que aparezcan los clientes que han alquilado al menos una película. Si quisiéramos que aparecieran
todos los clientes, independientemente de si han alquilado o no, utilizaría un LEFT JOIN.*/

SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS num_rentals
FROM customer AS c
INNER JOIN rental AS r
  ON c.customer_id = r.customer_id
GROUP BY c.customer_id;


-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

/* La tabla 'category' se relaciona con la tabla 'rental' a través de las tablas 'film_category' e 'inventory'. 
Hago tres INNER JOIN para conectarlas. */

SELECT c.name AS category, COUNT(r.rental_id) AS total_rentals
FROM category AS c
INNER JOIN film_category AS fc
  ON c.category_id = fc.category_id
INNER JOIN inventory AS i
  ON fc.film_id = i.film_id
INNER JOIN rental AS r
  ON i.inventory_id = r.inventory_id
GROUP BY c.name;


-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT rating, AVG(length) AS average_length
FROM film
GROUP BY rating;


-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

/* Los nombres y apellidos de los actores (tabla 'actor') están conectados al título de la película (tabla 'film') a través de la tabla 'film_actor'. 
Hago dos INNER JOIN para vincularlas.  */
 
 SELECT a.first_name, a.last_name
 FROM actor AS a
 INNER JOIN film_actor AS fa
  ON a.actor_id = fa.actor_id
INNER JOIN film AS f
  ON fa.film_id = f.film_id
WHERE f.title = 'Indian Love';
 

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

/* Este ejercicio puede resolverse de dos maneras en función del resultado deseado:
En la primera opción, buscamos las filas que contengan 'dog' y 'cat' en cualquier parte de la frase. Filtrará por las palabras 'dog' y 'cat', pero también por otras como 'category' y 'doggie'. 
En la segunda, buscamos solamente las filas que contengan 'dog' y 'cat' como palabras completas. Para ello añadimos espacios después y antes del símbolo '%'.
En este caso concreto, ambas búsquedas arrojan los mismos resultados. */

SELECT title, description
FROM film
WHERE description LIKE '%dog%' OR description LIKE '%cat%';

SELECT title, description
FROM film
WHERE description LIKE '% dog %' OR description LIKE '% cat %';


-- 15. ¿Hay algún actor o actriz que no aparezca en ninguna película en la tabla film_actor?

/* Conectamos los actores con las películas vinculando las tablas 'actor' y 'film_actor' a través de un LEFT JOIN para que aparezcan 
los resultados NULL en caso de que los haya. En este caso no los hay, por lo que la respuesta a la pregunta es No.*/

SELECT a.first_name, a.last_name
FROM actor AS A
LEFT JOIN film_actor AS fa
  ON a.actor_id = fa.actor_id
WHERE film_id IS NULL;


-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

SELECT title 
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

/* Es curioso que todas las películas parecen haberse estrenado en 2006, según los resultados de esta búsqueda: SELECT release_year FROM film;*/


-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".

/* Esta consulta puede resolverse: 1) Con dos INNER JOIN que vinculen 'film' con 'category' mediante 'film_category'. */

SELECT f.title
FROM film AS f
INNER JOIN film_category AS fc
  ON f.film_id = fc.film_id
INNER JOIN category AS c
  ON c.category_id = fc.category_id
WHERE c.name = 'Family';

/* 2) Con la siguiente CTE, que crea la tabla temporal 'family_films' : */

WITH family_films AS (SELECT film_category.film_id AS id
					  FROM film_category 
					  INNER JOIN category
					    ON film_category.category_id = category.category_id
					  WHERE category.name = 'Family')
SELECT title
FROM film 
INNER JOIN family_films 
			ON film.film_id = family_films.id;


-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

/* Primero hago una subconsulta para encontrar las id de los actores que hayan actuado en más de 10 películas. A continuación, uso dicha 
subconsulta para vincular las id con los nombres y apellidos de los actores.*/

SELECT a.first_name, a.last_name
FROM actor AS a
WHERE a.actor_id IN 
	(SELECT fa.actor_id
	FROM film_actor AS fa
	GROUP BY actor_id
	HAVING COUNT(fa.actor_id) > 10);


-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

/* Se trata de una consulta muy sencilla, pues toda la información que nos piden está contenida en la misma tabla.*/

SELECT title
FROM film
WHERE rating = 'R' AND length > 120;


-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.

SELECT c.name AS category, AVG(f.length) AS average_length
FROM category AS c
INNER JOIN film_category AS fc
  ON c.category_id = fc.category_id
INNER JOIN film AS f
  ON fc.film_id = f.film_id
GROUP BY c.name
HAVING average_length > 120;


-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT CONCAT(first_name, ' ', last_name) as actor_name, COUNT(fa.film_id) AS num_movies
FROM actor AS a
INNER JOIN film_actor AS fa
  ON a.actor_id = fa.actor_id
GROUP BY fa.actor_id
HAVING num_movies >= 5;


-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.

/* Conecto las tablas 'film' e 'inventory' con un INNER JOIN y a continuación hago una subconsulta en el WHERE para filtrar los resultados 
deseados conectando las tablas 'inventory' y 'rental'. Utilizo la función DATEDIFF, que devuelve la diferencia entre dos fechas.

Es curioso que en la tabla 'film' hay una columna llamada 'rental_duration'. Estuve tentada de utilizarla ya que la consulta habría sido mucho 
más fácil (SELECT title FROM film WHERE rental_duration > 5), pero no le di mucha credibilidad a los datos de dicha columna, ya que la duración
de un alquiler no puede ser fija sino que dependerá de cada cliente.
*/

SELECT title
FROM film AS f
INNER JOIN inventory AS i 
  ON f.film_id = i.film_id
WHERE i.inventory_id IN (
	SELECT r.inventory_id
	FROM rental AS r
	WHERE DATEDIFF(return_date, rental_date) > 5)
	GROUP BY f.title;
    

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

/*  El contenido entre paréntesis es la subconsulta que devuelve los actores que han actuado en películas del género 'Horror'.
	Utilizo NOT IN para excluir a los que NO han actuado en dicho género */
    
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE actor_id NOT IN (  
	SELECT a.actor_id  
	FROM actor AS a
	INNER JOIN film_actor AS fa
		ON a.actor_id = fa.actor_id
	INNER JOIN film_category AS fc
		ON fa.film_id = fc.film_id
	INNER JOIN category AS c
		ON fc.category_id = c.category_id
	WHERE name = "Horror");


-- 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

/* De nuevo, hago una subconsulta para identificar aquellas películas que pertenecen al género 'Comedy' y la utilizo para filtrar 
la consulta principal.*/

SELECT title
FROM film
WHERE length > 180 AND film_id IN (
	SELECT film_id
	FROM film_category AS fc
	INNER JOIN category AS c
		ON fc.category_id = c.category_id
	WHERE c.name = "Comedy");
    
    
-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.

/*Para la resolución de este ejercicio he utilizado recursos externos que he adaptado a mis preferencias y necesidades.

- He unido el nombre y apellido de los actores mediante la función CONCAT
- He vinculado la tabla 'film_actor' consigo misma para encontrar los actores que han trabajado juntos. 
- He puesto la condición 'fa1.actor_id <> fa2.actor_id' para evitar que los actores se emparejen consigo mismos.
- Este código PERMITE los duplicados. Por ejemplo: en la columna 'actor1', aparece 'Adam Grant' como compañero de 'Al Garland' en 1 película. 
Al buscar a 'Al Garland' en la misma columna, volverá a salir esta combinación. Lo he hecho así por una preferencia personal, pero si quisiéramos
que NO aparecieran los duplicados, bastaría con sustituir el código "fa1.actor_id <> fa2.actor_id" por "fa1.actor_id < fa2.actor_id" en el ON del primer INNER JOIN.
*/
 
 
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1, CONCAT(a2.first_name, ' ', a2.last_name) AS actor2, COUNT(*) AS num_films_together
FROM film_actor AS fa1
INNER JOIN film_actor AS fa2 
  ON fa1.film_id = fa2.film_id AND fa1.actor_id <> fa2.actor_id  
INNER JOIN actor AS a1 
  ON fa1.actor_id = a1.actor_id
INNER JOIN actor AS a2 
  ON fa2.actor_id = a2.actor_id
GROUP BY actor1, actor2
HAVING COUNT(*) > 0
ORDER BY actor1;


