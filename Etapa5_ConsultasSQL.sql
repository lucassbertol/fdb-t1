USE trabalho_final_fdb_normalizado;

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

-- Consulta 2: Listar jogos e suas empresas publicadoras, incluindo jogos sem publisher cadastrado.
SELECT g.name AS jogo,
       p.name AS publisher
FROM games g
LEFT JOIN game_publishers gp
    ON g.app_id = gp.app_id
LEFT JOIN publishers p
    ON gp.publisher_id = p.publisher_id
    ORDER BY g.name ASC;

-- Consulta 3: Descobrir quais são os 10 gêneros mais lucrativos na plataforma, considerando apenas jogos que possuem desenvolvedores associados
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

-- Consulta 4: Descobrir quais desenvolvedores possuem os jogos com as maiores médias de avaliações positivas
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

-- Consulta 5: Listar os 15 jogos com preço igual ou superior a US$ 25 e pico de jogadores simultâneos acima da média
SELECT
    g.app_id,
    g.name,
    g.price,
    g.peak_ccu
FROM games g
WHERE g.price >= 25
  AND g.peak_ccu > (
      SELECT AVG(peak_ccu)
      FROM games
  )
ORDER BY g.peak_ccu DESC
LIMIT 15;

-- Consulta 6: Exibe os desenvolvedores que possuem pelo menos um jogo com número de jogadores simultâneos acima da média da plataforma.
SELECT DISTINCT
    d.name AS desenvolvedor
FROM developers d
JOIN game_developers gd ON d.developer_id = gd.developer_id
JOIN games g ON gd.app_id = g.app_id
WHERE g.app_id IN (
    SELECT app_id
    FROM games
    WHERE peak_ccu > (
        SELECT AVG(peak_ccu)
        FROM games
    )
)
ORDER BY desenvolvedor;

-- Consulta 7: Encontrar as empresas relacionadas a jogos muito populares.
SELECT
    d.name AS empresa,
    'Developer' AS tipo,
    g.name AS jogo,
    g.peak_ccu
FROM developers d
JOIN game_developers gd ON d.developer_id = gd.developer_id
JOIN games g ON gd.app_id = g.app_id
WHERE g.peak_ccu > 100000

UNION

SELECT
    p.name AS empresa,
    'Publisher' AS tipo,
    g.name AS jogo,
    g.peak_ccu
FROM publishers p
JOIN game_publishers gp ON p.publisher_id = gp.publisher_id
JOIN games g ON gp.app_id = g.app_id
WHERE g.peak_ccu > 100000

ORDER BY peak_ccu DESC;

    
