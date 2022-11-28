USE imdb;


-- P1. ¿Encuentre el número total de filas en cada tabla del esquema?
SELECT
TABLE_NAME, SUM(TABLE_ROWS)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'IMDB'
GROUP BY TABLE_NAME;

-- director_mapping	    3867
-- genre	            14662
-- movie	            8344
-- names	            23934
-- ratings	            8230
-- role_mapping	        15158





-- P2. ¿Qué columnas en la tabla de películas tienen valores nulos?
SELECT
(SELECT count(*) FROM movie WHERE id is NULL) as id,
(SELECT count(*) FROM movie WHERE title is NULL) as title,
(SELECT count(*) FROM movie WHERE year  is NULL) as year,
(SELECT count(*) FROM movie WHERE date_published  is NULL) as date_published,
(SELECT count(*) FROM movie WHERE duration  is NULL) as duration,
(SELECT count(*) FROM movie WHERE country  is NULL) as year,
(SELECT count(*) FROM movie WHERE worlwide_gross_income  is NULL) as worlwide_gross_income,
(SELECT count(*) FROM movie WHERE languages  is NULL) as languages,
(SELECT count(*) FROM movie WHERE production_company  is NULL) as production_company
;


-- found null in below given columns ( count mentioned)
-- year 20
-- worlwide_gross_income  3724
-- languages 194
-- production_company 528

-- Q3.Encuentra el número total de películas estrenadas cada año ¿Cómo se ve la tendencia mes a mes?


SELECT year,
       Count(title) AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY year;
-- En el año 2017, el número más alto. de películas se estrenaron, es decir, 3052)

-- Número de películas estrenadas cada mes
SELECT Month(date_published) AS MONTH_NUM,
       Count(*)              AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY month_num
ORDER  BY month_num;

-- Marzo tiene el máximo y diciembre el mínimo. de películas estrenadas.

/*La mayor cantidad de películas se produce en el mes de marzo.
Entonces, ahora que ha entendido la tendencia mensual de las películas, echemos un vistazo a los otros detalles en la tabla de películas.
Sabemos que EE. UU. e India producen una gran cantidad de películas cada año. Busquemos el número de películas producidas por EE. UU. o India durante el último año.*/

-- Q4. ¿Cuántas películas se produjeron en los EE. UU. o la India en el año 2019?

-- Países como india formato lower y upper

SELECT Count(DISTINCT id) AS number_of_movies, year
FROM   movie
WHERE  ( upper(country) LIKE '%INDIA%'
          OR upper(country) LIKE '%USA%' )
       AND year = 2019;

-- Número de películas producidas por EE. UU. o India durante el último año, es decir, 2019 es "1059".



 /* Estados Unidos e India produjeron más de mil películas en el año 2019.
Averigüemos los diferentes géneros en el conjunto de datos.*/

-- P5. ¿Encontrar la lista única de los géneros presentes en el conjunto de datos?

SELECT DISTINCT genre FROM   genre;

-- P6.¿Qué género tuvo la mayor cantidad de películas producidas en general?

SELECT     genre,
           Count(mov.id) AS number_of_movies
FROM       movie       AS mov
INNER JOIN genre       AS gen
where      gen.movie_id = mov.id
GROUP BY   genre
ORDER BY   number_of_movies DESC limit 1 ;



-- El género drama tuvo la mayor cantidad de películas producidas en general, es decir, 4285.

-- P7. ¿Cuántas películas pertenecen a un solo género?

SELECT genre_count,
       Count(movie_id) movie_count
FROM (SELECT movie_id, Count(genre) genre_count
      FROM genre
      GROUP BY movie_id
      ORDER BY genre_count DESC) genre_counts
WHERE genre_count = 1
GROUP BY genre_count;


-- 3289 películas tienen exactamente un género.


-- P8.¿Cuál es la duración promedio de las películas en cada género?


/* ej de output:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT     genre,
           Round(Avg(duration),2) AS avg_duration
FROM       movie as mov
INNER JOIN genre as gen
ON      gen.movie_id = mov.id
GROUP BY   genre
ORDER BY avg_duration DESC;


-- La duración de las películas de acción es más alta con una duración de 112,88 minutos, mientras que las películas de terror tienen una duración mínima de 92,72 minutos.

-- P9.¿Cuál es el rango del género de películas de "suspenso" entre todos los géneros en términos de cantidad de películas producidas?
/* ej de output:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
WITH genre_summary AS
(
   SELECT
      genre,
	  Count(movie_id)                            AS movie_count ,
	  Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
   FROM       genre
   GROUP BY   genre
   )
SELECT *
FROM   genre_summary
WHERE  genre = "THRILLER" ;



-- El género de suspenso ocupa el tercer lugar con 1484 películas.

-- P10. ¿Encuentra los valores mínimo y máximo en cada columna de la tabla de calificaciones excepto en la columna movie_id?
/* ej. de output:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT
   Min(avg_rating)    AS min_avg_rating,
   Max(avg_rating)    AS max_avg_rating,
   Min(total_votes)   AS min_total_votes,
   Max(total_votes)   AS max_total_votes,
   Min(median_rating) AS min_median_rating,
   Max(median_rating) AS min_median_rating
FROM   ratings;


/* Entonces, los valores mínimo y máximo en cada columna de la tabla de calificaciones están en el rango esperado.
Esto implica que no hay valores atípicos en la tabla.*/

-- P11. ¿Cuáles son las 10 mejores películas según la calificación promedio?
/* ej de output:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
SELECT
   title,
   avg_rating,
   Rank() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM       ratings AS rat
INNER JOIN movie   AS mov
ON         mov.id = rat.movie_id limit 10;


-- P12. Resuma la tabla de calificaciones en función de los recuentos de películas por calificaciones medianas.
/* ej de output:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT median_rating,
       Count(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count DESC;

/* Las películas con una calificación media de 7 son las más altas en número.*/

-- P13. ¿Qué productora ha producido la mayor cantidad de películas exitosas (calificación promedio> 8)?
/* ej de output:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/

SELECT production_company,
      Count(movie_id) AS movie_count,
      Rank() OVER( ORDER BY Count(movie_id) DESC ) AS prod_company_rank
FROM ratings AS rat
     INNER JOIN movie AS mov
     ON mov.id = rat.movie_id
WHERE avg_rating > 8
     AND production_company IS NOT NULL
GROUP BY production_company;

-- Dream Warrior Pictures y National Theatre Live Production tienen la mayor cantidad de películas exitosas, es decir, 3 películas con calificación promedio > 8

-- P14. ¿Cuántas películas estrenadas en cada género durante marzo de 2017 en EE. UU. tuvieron más de 1000 votos?
/* ej de output:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT genre,
       Count(mov.id) AS movie_count
FROM movie AS mov
     INNER JOIN genre AS gen
           ON gen.movie_id = mov.id
     INNER JOIN ratings AS rat
           ON rat.movie_id = mov.id
WHERE year = 2017
	  AND Month(date_published) = 3
	  AND country LIKE '%USA%'
	  AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;

-- El género dramático tuvo el máximo no. de lanzamientos con 24 películas, mientras que el género familiar fue menor con 1 película solamente.

-- P15. ¿Encontrar películas de cada género que comiencen con la palabra 'The' y que tengan una calificación promedio > 8?
/* ej de output:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/


SELECT title, avg_rating, genre
FROM movie AS mov
     INNER JOIN genre AS gen
           ON gen.movie_id = mov.id
     INNER JOIN ratings AS rat
               ON rat.movie_id = mov.id
WHERE avg_rating > 8
	  AND title LIKE 'THE%'
ORDER BY avg_rating DESC;

-- Hay 8 películas que comienzan con la palabra 'The' y que tienen una calificación promedio > 8.

-- P16. De las películas estrenadas entre el 1 de abril de 2018 y el 1 de abril de 2019, ¿cuántas recibieron una calificación media de 8?

SELECT
   median_rating,
Count(*) AS movie_count
FROM movie AS mov INNER JOIN
     ratings AS rat ON rat.movie_id = mov.id
WHERE median_rating = 8
	  AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating;

-- Hay 361 películas que se estrenaron entre el 1 de abril de 2018 y el 1 de abril de 2019 y recibieron una calificación promedio de 8.
-- P17. ¿Las películas alemanas obtienen más votos que las películas italianas?

SELECT
   country,
   sum(total_votes) as total_votes
FROM movie AS mov
	INNER JOIN ratings as rat
          ON mov.id=rat.movie_id
WHERE lower(country) = 'germany' or lower(country) = 'italy'
GROUP BY country;

-- De la salida podemos ver que las películas alemanas tienen más votos que las películas italianas.
-- country  total_votes
-- Germany	106710
-- Italy	77965


-- P18. ¿Qué columnas en la tabla de nombres tienen valores nulos?
/*ej de output:
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/


SELECT Sum(CASE
             WHEN name IS NULL THEN 1
             ELSE 0
           END) AS name_null,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_null,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_null,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_null
FROM names;

-- null result

-- name                 0
-- height 				17335
-- date_of_birth 	    13431
-- known_for_movie		15226


-- P19. ¿Quiénes son los tres directores principales en los tres géneros principales cuyas películas tienen una calificación promedio> 8?
/* ej de output:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH top_3_genres
AS (
    SELECT genre,
	   Count(mov.id) AS movie_count ,
	   Rank() OVER(ORDER BY Count(mov.id) DESC) AS genre_rank
    FROM movie AS mov
	   INNER JOIN genre AS gen
			 ON gen.movie_id = mov.id
	   INNER JOIN ratings AS rat
			 ON rat.movie_id = mov.id
    WHERE avg_rating > 8
    GROUP BY genre limit 3
    )
SELECT
    nam.NAME AS director_name ,
	Count(dm.movie_id) AS movie_count
FROM director_mapping AS dm
       INNER JOIN genre gen using (movie_id)
       INNER JOIN names AS nam
       ON nam.id = dm.name_id
       INNER JOIN top_3_genres using (genre)
       INNER JOIN ratings using (movie_id)
WHERE avg_rating > 8
GROUP BY name
ORDER BY movie_count DESC limit 3 ;

-- James Mangold	4
-- Anthony Russo	3
-- Soubin Shahir	3


-- P20. ¿Quiénes son los dos mejores actores cuyas películas tienen una calificación media >= 8?
/* ej de output:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */


SELECT
   nam.name AS actor_name,
       Count(movie_id) AS movie_count
FROM role_mapping AS rm
       INNER JOIN movie AS mov
             ON mov.id = rm.movie_id
       INNER JOIN ratings AS rat USING(movie_id)
       INNER JOIN names AS nam
             ON nam.id = rm.name_id
WHERE rat.median_rating >= 8
	  AND category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC LIMIT 2;

-- Mammootty	8
-- Mohanlal	5


-- P21. ¿Cuáles son las tres principales productoras según el número de votos recibidos por sus películas?
/* ej de output:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/


SELECT
   production_company,
   Sum(total_votes) AS vote_count,
   Rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM movie AS mov
INNER JOIN ratings AS rat
	  ON rat.movie_id = mov.id
GROUP BY production_company LIMIT 3;

-- Marvel Studios, Twentieth Century Fox y Warner Bros son las tres principales productoras según el número de votos recibidos por sus películas.

-- P22. Clasifica a los actores con películas estrenadas en India según sus calificaciones promedio. ¿Qué actor está en la parte superior de la lista?
/* ej de output:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actor_summary
     AS (SELECT n.name AS actor_name, total_votes,
                Count(R.movie_id) AS movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating
         FROM movie AS m
                INNER JOIN ratings AS r
                      ON m.id = r.movie_id
                INNER JOIN role_mapping AS rm
					  ON m.id = rm.movie_id
                INNER JOIN names AS n
                        ON rm.name_id = n.id
         WHERE category = 'actor'
                AND country = "india"
         GROUP BY name
         HAVING movie_count >= 5)
SELECT *,
       Rank() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
FROM actor_summary;

-- Vijay Sethupathi, Fahadh Faasil y Yogi Babu son los 3 mejores actores en el orden respectivo.

-- El mejor actor es Vijay Sethupathi


-- P23.Descubra las cinco mejores actrices en películas hindi estrenadas en India en función de sus calificaciones promedio.
/* ej de output:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_detail
	 AS(
       SELECT
          n.name AS actress_name, total_votes,
		  Count(r.movie_id) AS movie_count,
		  Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
        FROM movie AS m
             INNER JOIN ratings AS r
                   ON m.id=r.movie_id
			 INNER JOIN role_mapping AS rm
                   ON m.id = rm.movie_id
			 INNER JOIN names AS n
                   ON rm.name_id = n.id
	    WHERE Upper(category) = 'ACTRESS'
              AND Upper(country) = "INDIA"
              AND Upper(languages) LIKE '%HINDI%'
	   GROUP BY name
	   HAVING movie_count>=3
       )
SELECT *,
         Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM actress_detail LIMIT 5;



/* Taapsee Pannu encabeza con una calificación promedio de 7.74.*/


/* P24. Seleccione películas de suspenso según la calificación promedio y clasifíquelas en la siguiente categoría:
      Clasificación > 8: Películas superéxito
      Calificación entre 7 y 8: películas exitosas
      Calificación entre 5 y 7: películas de una sola vez
      Calificación < 5: Películas fracasadas
--------------------------------------------------------------------------------------------*/
with thriller_movies as (
    select
       distinct title,
       avg_rating
    from movie as mov inner join ratings as rat
         on mov.id = rat.movie_id
         inner join genre as gen on gen.movie_id = mov.id
	where genre like 'THRILLER')
select *,
       case
         when avg_rating > 8 then 'superhit movies'
         when avg_rating between 7 and 8  then 'Hit movies'
         when avg_rating between 5 and 7 then 'one-time-watch movies'
         else 'Flop movies'
		end as avg_rating_category
from thriller_movies ;
-- Rating category        counts
-- Hit movies	            166
-- Flop movies	            492
-- one-time-watch movies	785
-- superhit movies	         39



-- P25. ¿Cuál es el total acumulado por género y el promedio móvil de la duración promedio de la película?
/* ej de output:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT genre,
       ROUND(AVG(duration),2) AS avg_duration,
       SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
       ROUND(AVG(AVG(duration)) OVER(ORDER BY genre ROWS 10 PRECEDING),2) AS moving_avg_duration
FROM movie AS m
INNER JOIN genre AS g
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;



-- P26. ¿Cuáles son las cinco películas más taquilleras de cada año que pertenecen a los tres géneros principales?

/* ej de output:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH top_3_genres
     AS( SELECT genre,
                Count(m.id) AS movie_count ,
                Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
         FROM movie AS m
              INNER JOIN genre AS g
                     ON g.movie_id = m.id
              INNER JOIN ratings AS r
                     ON r.movie_id = m.id
         GROUP BY genre limit 3 ), movie_summary
     AS( SELECT genre, year,
                title AS movie_name,
                CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
                DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
         FROM movie AS m
              INNER JOIN genre AS g
                    ON m.id = g.movie_id
         WHERE genre IN
         ( SELECT genre FROM top_3_genres)
         GROUP BY   movie_name
          )
SELECT * FROM   movie_summary
WHERE  movie_rank<=5
ORDER BY YEAR;

-- Query le dara las 5 películas más taquilleras de cada año de los 3 géneros principales según el número total. de películas

-- P27. ¿Cuáles son las dos productoras principales que han producido el mayor número de visitas (puntuación media >= 8) entre las películas multilingües?
/* ej de output:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

WITH production_company_detail
     AS (SELECT production_company,
                Count(*) AS movie_count
         FROM movie AS mov
                INNER JOIN ratings AS rat
		      ON rat.movie_id = mov.id
         WHERE median_rating >= 8
	       AND production_company IS NOT NULL
               AND Position(',' IN languages) > 0
         GROUP BY production_company
         ORDER BY movie_count DESC)
SELECT *,
       Rank() over( ORDER BY movie_count DESC) AS prod_comp_rank
FROM production_company_detail LIMIT 2;


-- Star Cinema y Twentieth Century Fox son las 2 principales productoras que han producido la mayor cantidad de éxitos.

-- P28. ¿Quiénes son las 3 mejores actrices en función de la cantidad de películas Super Hit (calificación promedio> 8) en el género dramático?
/* ej de output:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/


WITH actress_summary
     AS( SELECT n.name AS actress_name,
                SUM(total_votes) AS total_votes,
		Count(r.movie_id) AS movie_count,
                Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
	FROM movie AS m
             INNER JOIN ratings AS r
                   ON m.id=r.movie_id
             INNER JOIN role_mapping AS rm
                   ON m.id = rm.movie_id
             INNER JOIN names AS n
		   ON rm.name_id = n.id
             INNER JOIN GENRE AS g
                  ON g.movie_id = m.id
	WHERE lower(category) = 'actress'
              AND avg_rating>8
              AND lower(genre) = "drama"
	GROUP BY name )
SELECT *,
	   Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM actress_summary LIMIT 3;

-- Parvathy Thiruvothu, Susan Brown y Amanda Lawrence son las 3 mejores actrices según el número de películas Super Hit (calificación promedio >8) en el género dramático.


/* P29. Obtenga los siguientes detalles de los 9 mejores directores (según la cantidad de películas)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Formato:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH next_date_published_detail
     AS( SELECT d.name_id, name, d.movie_id, duration, r.avg_rating, total_votes, m.date_published,
                Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
          FROM director_mapping                                                                      AS d
               INNER JOIN names                                                                                 AS n
                     ON n.id = d.name_id
               INNER JOIN movie AS m
                     ON m.id = d.movie_id
               INNER JOIN ratings AS r
                     ON r.movie_id = m.id ), top_director_summary AS
( SELECT *,
         Datediff(next_date_published, date_published) AS date_difference
  FROM   next_date_published_detail )
SELECT   name_id AS director_id,
         name AS director_name,
         Count(movie_id) AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2) AS avg_rating,
         Sum(total_votes) AS total_votes,
         Min(avg_rating) AS min_rating,
         Max(avg_rating) AS max_rating,
         Sum(duration) AS total_duration
FROM top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;
