-- Consultas SQL:
-- Consulta 1: Jogos acima da média de avaliações positivas
SELECT g.name, g.positive
FROM games g
WHERE g.positive >
(
    SELECT AVG(g.positive)
    FROM games g
)
ORDER BY g.positive DESC
LIMIT 20;

-- Consulta 2: Descobrir quais são os 10 gêneros mais lucrativos na plataforma, considerando apenas jogos que possuem desenvolvedores associados
SELECT 
      g.name AS genero,
      COUNT(DISTINCT gam.app_id) AS total_jogos,
      ROUND(AVG(gam.price), 2) AS preco_medio,
      SUM(gam.price * gam.estimated_owners_min) AS receita_minima_estimada
FROM genres g
JOIN game_genres gg ON g.genre_id = gg.genre_id
JOIN games gam ON gg.app_id = gam.app_id
JOIN game_developers gd ON gam.app_id = gd.app_id
GROUP BY g.genre_id, g.name
HAVING COUNT(DISTINCT gam.app_id) >= 5
ORDER BY receita_minima_estimada DESC
LIMIT 10; 

-- Consulta 3: Descobrir quais desenvolvedores possuem os jogos com as maiores médias de avaliações positivas
SELECT 
    d.name AS desenvolvedor,
    COUNT(g.app_id) AS total_jogos_lancados,
    SUM(g.positive) AS total_avaliacoes_positivas,
    ROUND(AVG(g.positive), 0) AS media_positivas_por_jogo
FROM developers d
JOIN game_developers gd ON d.developer_id = gd.developer_id
JOIN games g ON gd.app_id = g.app_id
GROUP BY d.developer_id, d.name
HAVING total_jogos_lancados >= 2
ORDER BY media_positivas_por_jogo DESC
LIMIT 10;

-- Consulta 4: Descobrir quais jogos acima de 25$ possuiram o maior pico de jogadores simultaneamente
SELECT 
    g.app_id,
    g.name AS nome_jogo,
    g.price AS preco,
    g.peak_ccu AS pico_jogadores_simultaneos,
    GROUP_CONCAT(DISTINCT gen.name SEPARATOR ', ') AS generos
FROM games g
JOIN game_genres gg ON g.app_id = gg.app_id
JOIN genres gen ON gg.genre_id = gen.genre_id
WHERE g.price >= 25.00 
  AND g.peak_ccu > (
      SELECT AVG(peak_ccu) 
      FROM games
  )
GROUP BY g.app_id, g.name, g.price, g.peak_ccu
ORDER BY g.peak_ccu DESC, g.price DESC
LIMIT 15;

-- Consulta 5: Descobrir quais Distribuidoras trazem o catálogo mais acessível globalmente, calculando a média de idiomas suportados por jogo lançado.
SELECT 
    p.publisher_id,
    p.name AS distribuidora,
    COUNT(DISTINCT gp.app_id) AS total_jogos_lancados,
    ROUND(AVG(sub_idiomas.qtd_idiomas), 1) AS media_idiomas_por_jogo
FROM publishers p
JOIN game_publishers gp ON p.publisher_id = gp.publisher_id
JOIN (

    SELECT 
        gsl.app_id, 
        COUNT(DISTINCT gsl.language_id) AS qtd_idiomas
    FROM game_supported_languages gsl
    GROUP BY gsl.app_id
) sub_idiomas ON gp.app_id = sub_idiomas.app_id
GROUP BY p.publisher_id, p.name
HAVING total_jogos_lancados >= 3 
ORDER BY media_idiomas_por_jogo DESC, total_jogos_lancados DESC
LIMIT 10;
