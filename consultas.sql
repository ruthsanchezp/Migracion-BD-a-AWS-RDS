
Consultas SQL

1.	 ¿Cuántos partidos han terminado 0-0?

SELECT x.* FROM public.partidos x
WHERE ("golesLocal" IN (0)) AND ("golesVisitante" IN (0)) AND ("EquipoVisitante" = 'Barcelona')

 
Respuesta: 85 partidos

2.	¿Cuántos goles ha marcado el Barcelona? 


SELECT SUM(golesLocal) + SUM(golesVisitante) AS TotalGoles
FROM partidos
WHERE EquipoLocal = 'Barcelona' OR EquipoVisitante = 'Barcelona';

Respuesta: 3339


3.	¿En qué temporada se han marcado más goles?


SELECT temporada, SUM(golesLocal + golesVisitante) AS total_goles
FROM partidos
GROUP BY temporada


ORDER BY total_goles DESC
LIMIT 1;


Respuesta: temporada 1970 – total_goles 2294
4.	¿Cuál es el equipo que tiene el record de meter más goles como local? ¿Y cómo visitante?
Local

SELECT EquipoLocal AS Equipo, SUM(golesLocal) AS TotalGolesLocal FROM partidos GROUP BY EquipoLocal ORDER BY TotalGolesLocal DESC LIMIT 1;

Respuesta:  Real Madrid, 2054 goles
Visitante

SELECT EquipoVisitante AS Equipo, SUM(golesVisitante) AS TotalGolesVisitante FROM partidos GROUP BY EquipoVisitante ORDER BY TotalGolesVisitante DESC LIMIT 1;

Respuesta: Barcelona, con 1296 goles. 
5.	¿Cuál son las 3 décadas en las que más goles se metieron?

SELECT FLOOR(YEAR(fecha) / 10) * 10 AS Decada, SUM(golesLocal + golesVisitante) AS TotalGoles
FROM partidos
GROUP BY Decada
ORDER BY TotalGoles DESC
LIMIT 3;

Respuesta: Decada 2000, TotalGoles 20526; Decada 1990, TotalGoles 19321; Decada 1980, Total Goles 17336

6.	¿Qué equipo es el mejor local en los últimos 5 años?
SELECT EquipoLocal AS Equipo, COUNT(*) AS TRINFOLOCAL
FROM partidos
WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR) AND golesLocal > golesVisitante
GROUP BY EquipoLocal
ORDER BY TRINFOLOCAL DESC
LIMIT 1;
Respuesta: Barcelona, con 77 triunfos
7.	¿Cuál es la media de victorias por temporada en los equipos que han estado menos de 10 temporadas en 1ª división? El resultado tiene que ser una tabla con dos columnas: Equipo | Media de victorias por temporada

WITH equipos_menos_10_temporadas AS (
SELECT Equipo, COUNT(DISTINCT temporada) AS temporadas_en_primera_division
FROM (
        SELECT EquipoLocal AS Equipo, temporada
        FROM partidos
        UNION ALL
        SELECT EquipoVisitante AS Equipo, temporada
        FROM partidos
    ) AS equipos_participantes
    GROUP BY Equipo
    HAVING COUNT(DISTINCT temporada) < 10
)
SELECT Equipo, AVG(victorias_por_temporada) AS Media_victorias_por_temporada
FROM (
    SELECT Equipo, temporada, 
           SUM(CASE WHEN Equipo = EquipoLocal AND golesLocal > golesVisitante THEN 1
                    WHEN Equipo = EquipoVisitante AND golesVisitante > golesLocal THEN 1
                    ELSE 0 END) AS victorias_por_temporada
    FROM partidos
    WHERE Equipo IN (SELECT Equipo FROM equipos_menos_10_temporadas)
    GROUP BY Equipo, temporada
) AS victorias
GROUP BY Equipo;


Respuesta: Orihuela, 24; Ciudad de Murcia: 22; Alcorcon, 21,4
8.	¿Quién ha estado más temporadas en 1ª División: Barcelona o Real Madrid?

SELECT equipo, COUNT(DISTINCT temporada) AS primera
 FROM (
 SELECT EquipoLocal AS equipo, temporada
 FROM partidos
 UNION ALL
 SELECT EquipoVisitante AS equipo, temporada
 FROM tabla
) AS equipos_participantes
GROUP BY equipo
ORDER BY primera DESC
LIMIT 1;

Respuesta: Barcelona, 45; Real Madrid, 45. 
9.	¿Cuál es el record de goles como visitante en una temporada del Real Madrid?

SELECT temporada, SUM(golesVisitante) AS TotalGoles
FROM partidos
WHERE EquipoVisitante = 'Real Madrid'
GROUP BY temporada
ORDER BY TotalGoles DESC
LIMIT 1;

Respuesta: Temporada 2011-12, 51 goles
10.	¿En qué temporada se marcaron más goles en Cataluña?
o	Goles marcados y recibidos por el Barcelona jugando de local en dicha temporada.
o	Goles marcados y recibidos por el Espanyol jugando de local en dicha temporada.

WITH goles_cataluna AS (
    SELECT temporada, 
           SUM(CASE WHEN EquipoLocal = 'Barcelona' THEN golesLocal ELSE 0 END) AS goles_barcelona_local,
           SUM(CASE WHEN EquipoVisitante = 'Barcelona' THEN golesVisitante ELSE 0 END) AS goles_barcelona_visitante,
           SUM(CASE WHEN EquipoLocal = 'Espanyol' THEN golesLocal ELSE 0 END) AS goles_espanyol_local,
          SUM(CASE WHEN EquipoVisitante = 'Espanyol' THEN golesVisitante ELSE 0 END) AS goles_espanyol_visitante
    FROM partidos
    WHERE EquipoLocal IN ('Barcelona', 'Espanyol') OR EquipoVisitante IN ('Barcelona', 'Espanyol')
    GROUP BY temporada
    ORDER BY (SUM(golesLocal) + SUM(golesVisitante)) DESC
    LIMIT 1
)
SELECT temporada, goles_barcelona_local, goles_barcelona_visitante, goles_espanyol_local, goles_espanyol_visitante
FROM goles_cataluna;

Respuesta: Barcelona, local, 73 goles; Cataluña, visitante, 41 goles; Espanyol, local 3 goles, Espanyol, visitante, 15 goles.

