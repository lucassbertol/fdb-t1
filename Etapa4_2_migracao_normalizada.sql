-- ETAPA 4 – SEGUNDA PARTE: SCRIPT SQL PARA QUE OS DADOS DA TABELA DESNORMALIZADA SEJAM COPIADOS PARA AS
-- RESPECTIVAS TABELAS NORMALIZADAS
USE trabalho_final_fdb_normalizado;

-- desativa checagens de chaves estrangeiras (p/ acelerar a carga em lote) e sql_safe_updates (p/ limpar tabelas)
SET foreign_key_checks = 0;
SET SQL_SAFE_UPDATES = 0;
SET group_concat_max_len = 1048576;

-- limpa os dados antigos para evitar duplicações se rodar o script novamente
TRUNCATE TABLE game_developers;
TRUNCATE TABLE game_publishers;
TRUNCATE TABLE game_genres;
TRUNCATE TABLE game_categories;
TRUNCATE TABLE game_tags;
TRUNCATE TABLE game_supported_languages;
TRUNCATE TABLE game_audio_languages;
TRUNCATE TABLE screenshots;
TRUNCATE TABLE movies;
DELETE FROM games;
DELETE FROM developers;
DELETE FROM publishers;
DELETE FROM genres;
DELETE FROM categories;
DELETE FROM tags;
DELETE FROM languages;

-- 1. CARGA DA TABELA PRINCIPAL: GAMES
INSERT IGNORE INTO games (
    app_id, name, release_date,
    estimated_owners_min, estimated_owners_max,
    peak_ccu, required_age, price, discount, dlc_count,
    about_the_game, reviews, header_image,
    website, support_url, support_email,
    windows, mac, linux,
    metacritic_score, metacritic_url,
    user_score, positive, negative, score_rank,
    achievements, recommendations, notes,
    average_playtime_forever, average_playtime_two_weeks,
    median_playtime_forever, median_playtime_two_weeks
)
SELECT
    r.app_id,
    r.name,
    CASE
        WHEN r.release_date IS NULL OR TRIM(r.release_date) = '' THEN NULL
        ELSE STR_TO_DATE(r.release_date, '%b %d, %Y')
    END,
    CASE WHEN r.estimated_owners REGEXP '^[0-9]+ - [0-9]+$'
         THEN CAST(SUBSTRING_INDEX(r.estimated_owners, ' - ', 1) AS UNSIGNED)
         ELSE NULL END,
    CASE WHEN r.estimated_owners REGEXP '^[0-9]+ - [0-9]+$'
         THEN CAST(SUBSTRING_INDEX(r.estimated_owners, ' - ', -1) AS UNSIGNED)
         ELSE NULL END,
    IFNULL(r.peak_ccu, 0),
    IFNULL(CAST(r.required_age AS SIGNED), 0),
    IFNULL(r.price, 0),
    IFNULL(r.discount, 0),
    IFNULL(r.dlc_count, 0),
    r.about_the_game, r.reviews, r.header_image,
    r.website, r.support_url, LEFT(r.support_email, 255),
    IFNULL(r.windows, FALSE), IFNULL(r.mac, FALSE), IFNULL(r.linux, FALSE),
    IFNULL(r.metacritic_score, 0), r.metacritic_url,
    IFNULL(r.user_score, 0), IFNULL(r.positive, 0), IFNULL(r.negative, 0),
    LEFT(r.score_rank, 100),
    IFNULL(r.achievements, 0), IFNULL(r.recommendations, 0), r.notes,
    IFNULL(r.average_playtime_forever, 0), IFNULL(r.average_playtime_two_weeks, 0),
    IFNULL(r.median_playtime_forever, 0), IFNULL(r.median_playtime_two_weeks, 0)
FROM trabalho_final_fdb_desnormalizado.games r
WHERE r.app_id IS NOT NULL;


-- 2. NORMALIZAÇÃO: DEVELOPERS
-- 2.1 tabela dimensão (nomes únicos)
INSERT IGNORE INTO developers (name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.developers, ',', n.n), ',', -1)) AS nome_dev
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.developers) - LENGTH(REPLACE(t.developers, ',', ''))
WHERE t.developers IS NOT NULL AND TRIM(t.developers) != ''
HAVING nome_dev != '';

-- 2.2 tabela associativa (relacionamento N:M)
INSERT IGNORE INTO game_developers (app_id, developer_id)
SELECT t.app_id, d.developer_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.developers) - LENGTH(REPLACE(t.developers, ',', ''))
JOIN developers d
  ON d.name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.developers, ',', n.n), ',', -1))
WHERE t.developers IS NOT NULL AND TRIM(t.developers) != '' AND t.app_id IS NOT NULL;


-- 3. NORMALIZAÇÃO: PUBLISHERS
-- 3.1 tabela dimensão
INSERT IGNORE INTO publishers (name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.publishers, ',', n.n), ',', -1)) AS nome_pub
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.publishers) - LENGTH(REPLACE(t.publishers, ',', ''))
WHERE t.publishers IS NOT NULL AND TRIM(t.publishers) != ''
HAVING nome_pub != '';

-- 3.2 tabela associativa
INSERT IGNORE INTO game_publishers (app_id, publisher_id)
SELECT t.app_id, p.publisher_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.publishers) - LENGTH(REPLACE(t.publishers, ',', ''))
JOIN publishers p
  ON p.name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.publishers, ',', n.n), ',', -1))
WHERE t.publishers IS NOT NULL AND TRIM(t.publishers) != '' AND t.app_id IS NOT NULL;


-- 4. NORMALIZAÇÃO: GENRES
-- 4.1 tabela dimensão
INSERT IGNORE INTO genres (name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.genres, ',', n.n), ',', -1)) AS nome_genre
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.genres) - LENGTH(REPLACE(t.genres, ',', ''))
WHERE t.genres IS NOT NULL AND TRIM(t.genres) != ''
HAVING nome_genre != '';

-- 4.2 tabela associativa
INSERT IGNORE INTO game_genres (app_id, genre_id)
SELECT t.app_id, g.genre_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.genres) - LENGTH(REPLACE(t.genres, ',', ''))
JOIN genres g
  ON g.name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.genres, ',', n.n), ',', -1))
WHERE t.genres IS NOT NULL AND TRIM(t.genres) != '' AND t.app_id IS NOT NULL;


-- 5. NORMALIZAÇÃO: CATEGORIES
-- 5.1 tabela dimensão
INSERT IGNORE INTO categories (name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.categories, ',', n.n), ',', -1)) AS nome_cat
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15) n
  ON n.n <= 1 + LENGTH(t.categories) - LENGTH(REPLACE(t.categories, ',', ''))
WHERE t.categories IS NOT NULL AND TRIM(t.categories) != ''
HAVING nome_cat != '';

-- 5.2 tabela associativa
INSERT IGNORE INTO game_categories (app_id, category_id)
SELECT t.app_id, c.category_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15) n
  ON n.n <= 1 + LENGTH(t.categories) - LENGTH(REPLACE(t.categories, ',', ''))
JOIN categories c
  ON c.name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.categories, ',', n.n), ',', -1))
WHERE t.categories IS NOT NULL AND TRIM(t.categories) != '' AND t.app_id IS NOT NULL;



-- 6. NORMALIZAÇÃO: TAGS
-- 6.1 tabela dimensão
INSERT IGNORE INTO tags (name)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.tags, ',', n.n), ',', -1)) AS nome_tag
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
      UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20) n
  ON n.n <= 1 + LENGTH(t.tags) - LENGTH(REPLACE(t.tags, ',', ''))
WHERE t.tags IS NOT NULL AND TRIM(t.tags) != ''
HAVING nome_tag != '';

-- 6.2 tabela associativa
INSERT IGNORE INTO game_tags (app_id, tag_id)
SELECT t.app_id, tg.tag_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
      UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20) n
  ON n.n <= 1 + LENGTH(t.tags) - LENGTH(REPLACE(t.tags, ',', ''))
JOIN tags tg
  ON tg.name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.tags, ',', n.n), ',', -1))
WHERE t.tags IS NOT NULL AND TRIM(t.tags) != '' AND t.app_id IS NOT NULL;


-- 7. NORMALIZAÇÃO: LANGUAGES
-- remove colchetes e aspas das listas Python gravadas no CSV original
-- 7.1 cadastra idiomas de 'supported_languages'
INSERT IGNORE INTO languages (name)
SELECT DISTINCT TRIM(REPLACE(REPLACE(
    SUBSTRING_INDEX(SUBSTRING_INDEX(
        REPLACE(REPLACE(t.supported_languages, '[', ''), ']', ''),
        ',', n.n), ',', -1),
    "'", ''), '"', '')) AS nome_lang
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
      UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20) n
  ON n.n <= 1 + LENGTH(t.supported_languages) - LENGTH(REPLACE(t.supported_languages, ',', ''))
WHERE t.supported_languages IS NOT NULL AND TRIM(t.supported_languages) NOT IN ('', '[]')
HAVING nome_lang != '';

-- 7.2 cadastra idiomas adicionais de 'full_audio_languages'
INSERT IGNORE INTO languages (name)
SELECT DISTINCT TRIM(REPLACE(REPLACE(
    SUBSTRING_INDEX(SUBSTRING_INDEX(
        REPLACE(REPLACE(t.full_audio_languages, '[', ''), ']', ''),
        ',', n.n), ',', -1),
    "'", ''), '"', '')) AS nome_lang_audio
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.full_audio_languages) - LENGTH(REPLACE(t.full_audio_languages, ',', ''))
WHERE t.full_audio_languages IS NOT NULL AND TRIM(t.full_audio_languages) NOT IN ('', '[]')
HAVING nome_lang_audio != '';

-- 7.3 associativa: idiomas suportados
INSERT IGNORE INTO game_supported_languages (app_id, language_id)
SELECT t.app_id, l.language_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
      UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20) n
  ON n.n <= 1 + LENGTH(t.supported_languages) - LENGTH(REPLACE(t.supported_languages, ',', ''))
JOIN languages l ON l.name = TRIM(REPLACE(REPLACE(
    SUBSTRING_INDEX(SUBSTRING_INDEX(
        REPLACE(REPLACE(t.supported_languages, '[', ''), ']', ''),
        ',', n.n), ',', -1),
    "'", ''), '"', ''))
WHERE t.supported_languages IS NOT NULL AND TRIM(t.supported_languages) NOT IN ('', '[]') AND t.app_id IS NOT NULL;

-- 7.4 associativa: idiomas com áudio completo
INSERT IGNORE INTO game_audio_languages (app_id, language_id)
SELECT t.app_id, l.language_id
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.full_audio_languages) - LENGTH(REPLACE(t.full_audio_languages, ',', ''))
JOIN languages l ON l.name = TRIM(REPLACE(REPLACE(
    SUBSTRING_INDEX(SUBSTRING_INDEX(
        REPLACE(REPLACE(t.full_audio_languages, '[', ''), ']', ''),
        ',', n.n), ',', -1),
    "'", ''), '"', ''))
WHERE t.full_audio_languages IS NOT NULL AND TRIM(t.full_audio_languages) NOT IN ('', '[]') AND t.app_id IS NOT NULL;


-- 8. ENTIDADES DEPENDENTES: SCREENSHOTS
INSERT IGNORE INTO screenshots (app_id, url)
SELECT t.app_id,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.screenshots, ',', n.n), ',', -1)) AS url_print
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
      UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
      UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20) n
  ON n.n <= 1 + LENGTH(t.screenshots) - LENGTH(REPLACE(t.screenshots, ',', ''))
WHERE t.screenshots IS NOT NULL AND TRIM(t.screenshots) != '' AND t.app_id IS NOT NULL
HAVING url_print LIKE 'http%';


-- 9. ENTIDADES DEPENDENTES: MOVIES
INSERT IGNORE INTO movies (app_id, url)
SELECT t.app_id,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.movies, ',', n.n), ',', -1)) AS url_movie
FROM trabalho_final_fdb_desnormalizado.games t
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
  ON n.n <= 1 + LENGTH(t.movies) - LENGTH(REPLACE(t.movies, ',', ''))
WHERE t.movies IS NOT NULL AND TRIM(t.movies) != '' AND t.app_id IS NOT NULL
HAVING url_movie LIKE 'http%';


-- 10. REATIVAR INTEGRIDADE REFERENCIAL (foreign_key_checks e sql_safe_updates)
SET foreign_key_checks = 1;
SET SQL_SAFE_UPDATES = 1;


-- 11. CONTAGEM AUDITORIA FINAL
SELECT 'games'                       AS tabela, COUNT(*) AS registros FROM games
UNION ALL SELECT 'developers',                  COUNT(*) FROM developers
UNION ALL SELECT 'game_developers',             COUNT(*) FROM game_developers
UNION ALL SELECT 'publishers',                  COUNT(*) FROM publishers
UNION ALL SELECT 'game_publishers',             COUNT(*) FROM game_publishers
UNION ALL SELECT 'genres',                      COUNT(*) FROM genres
UNION ALL SELECT 'game_genres',                 COUNT(*) FROM game_genres
UNION ALL SELECT 'categories',                  COUNT(*) FROM categories
UNION ALL SELECT 'game_categories',             COUNT(*) FROM game_categories
UNION ALL SELECT 'tags',                        COUNT(*) FROM tags;
