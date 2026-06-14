# ETAPA 4 – PRIMEIRA PARTE: SCRIPT PYTHON PARA CARREGAR OS DADOS DA FONTE PARA A TABELA DESNORMALIZADA
import csv
import sys
import os
import mysql.connector
from mysql.connector import Error

# configuração
DB_HOST     = "localhost"
DB_PORT     = 3306
DB_USER     = "root"
DB_PASSWORD = "!DBsi_846"
DB_NAME     = "trabalho_final_fdb_desnormalizado"
CSV_FILE    = "games.csv"          
ENCODING    = "utf-8"              
BATCH_SIZE  = 50                   


def clean_bool(value: str) -> bool:
    """Converte TRUE/FALSE/1/0/Yes/No para bool Python."""
    return str(value).strip().lower() in ("true", "1", "yes")


def clean_int(value: str, default: int = 0) -> int:
    """Converte string para int, retornando default se vazio/inválido."""
    try:
        return int(str(value).strip())
    except (ValueError, TypeError):
        return default


def clean_decimal(value: str, default: float = 0.0) -> float:
    """Converte string para float, retornando default se vazio/inválido."""
    try:
        return float(str(value).strip())
    except (ValueError, TypeError):
        return default


def clean_str(value: str, maxlen: int = None) -> str | None:
    """Limpa string; retorna None se vazia."""
    s = str(value).strip() if value is not None else ""
    if s == "" or s.lower() == "nan":
        return None
    return s[:maxlen] if maxlen else s


def parse_owners(value: str):
    """
    Campo 'Estimated owners' vem como '0 - 20000'.
    Devolve a string original (VARCHAR 50) sem alteração,
    pois a tabela desnormalizada o armazena como texto.
    """
    return clean_str(value, 50)


INSERT_SQL = """
INSERT INTO games (
    app_id, name, release_date, estimated_owners, peak_ccu,
    required_age, price, discount, DLC_count,
    about_the_game, supported_languages, full_audio_languages,
    reviews, header_image, website, support_url, support_email,
    windows, mac, linux,
    metacritic_score, metacritic_url, user_score,
    positive, negative, score_rank,
    achievements, recommendations, notes,
    average_playtime_forever, average_playtime_two_weeks,
    median_playtime_forever, median_playtime_two_weeks,
    developers, publishers, categories, genres, tags,
    screenshots, movies
) VALUES (
    %s, %s, %s, %s, %s,
    %s, %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s,
    %s, %s,
    %s, %s,
    %s, %s, %s, %s, %s,
    %s, %s
)
"""


def build_row(row: dict) -> tuple:
    """Mapeia um dict do CSV para a tupla de parâmetros do INSERT."""
    return (
        clean_int(row.get("AppID"), 0),                         # app_id
        clean_str(row.get("Name"), 500),                        # name
        clean_str(row.get("Release date"), 50),                 # release_date
        parse_owners(row.get("Estimated owners")),              # estimated_owners
        clean_int(row.get("Peak CCU")),                         # peak_ccu
        clean_decimal(row.get("Required age")),                 # required_age
        clean_decimal(row.get("Price")),                        # price
        clean_int(row.get("Discount")),                         # discount
        clean_int(row.get("DLC count")),                        # DLC_count
        clean_str(row.get("About the game")),                   # about_the_game
        clean_str(row.get("Supported languages")),              # supported_languages
        clean_str(row.get("Full audio languages")),             # full_audio_languages
        clean_str(row.get("Reviews")),                          # reviews
        clean_str(row.get("Header image")),                     # header_image
        clean_str(row.get("Website")),                          # website
        clean_str(row.get("Support url")),                      # support_url
        clean_str(row.get("Support email"), 255),               # support_email
        clean_bool(row.get("Windows")),                         # windows
        clean_bool(row.get("Mac")),                             # mac
        clean_bool(row.get("Linux")),                           # linux
        clean_int(row.get("Metacritic score")),                 # metacritic_score
        clean_str(row.get("Metacritic url")),                   # metacritic_url
        clean_int(row.get("User score")),                       # user_score
        clean_int(row.get("Positive")),                         # positive
        clean_int(row.get("Negative")),                         # negative
        clean_str(row.get("Score rank"), 100),                  # score_rank
        clean_int(row.get("Achievements")),                     # achievements
        clean_int(row.get("Recommendations")),                  # recommendations
        clean_str(row.get("Notes")),                            # notes
        clean_int(row.get("Average playtime forever")),         # average_playtime_forever
        clean_int(row.get("Average playtime two weeks")),       # average_playtime_two_weeks
        clean_int(row.get("Median playtime forever")),          # median_playtime_forever
        clean_int(row.get("Median playtime two weeks")),        # median_playtime_two_weeks
        clean_str(row.get("Developers")),                       # developers
        clean_str(row.get("Publishers")),                       # publishers
        clean_str(row.get("Categories")),                       # categories
        clean_str(row.get("Genres")),                           # genres
        clean_str(row.get("Tags")),                             # tags
        clean_str(row.get("Screenshots")),                      # screenshots
        clean_str(row.get("Movies")),                           # movies
    )


def load_csv_to_db():
    if not os.path.exists(CSV_FILE):
        print(f"[ERRO] Arquivo CSV não encontrado: {CSV_FILE}")
        sys.exit(1)

    print(f"[INFO] Conectando ao MySQL ({DB_HOST}:{DB_PORT}/{DB_NAME})...")
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset="utf8mb4",
            allow_local_infile=True,
        )
        cursor = conn.cursor()
        print("[INFO] Conexão estabelecida.")
    except Error as e:
        print(f"[ERRO] Falha na conexão: {e}")
        sys.exit(1)

    
    cursor.execute("TRUNCATE TABLE games") # para limpar a tabela antes de executar
    conn.commit()
    print("[INFO] Tabela 'games' limpa. Iniciando carga...")

    batch: list[tuple] = []
    total_ok = 0
    total_err = 0

    with open(CSV_FILE, newline="", encoding=ENCODING, errors="replace") as f:
        reader = csv.DictReader(f)

        for lineno, row in enumerate(reader, start=2):   # linha 1 - cabeçalho
            try:
                params = build_row(row)
                batch.append(params)

                if len(batch) >= BATCH_SIZE:
                    cursor.executemany(INSERT_SQL, batch)
                    conn.commit()
                    total_ok += len(batch)
                    print(f"  → {total_ok} registros inseridos...")
                    batch.clear()

            except Exception as e:
                total_err += 1
                print(f"  [AVISO] Linha {lineno} ignorada: {e}")

        if batch:
            try:
                cursor.executemany(INSERT_SQL, batch)
                conn.commit()
                total_ok += len(batch)
            except Error as e:
                total_err += len(batch)
                print(f"  [ERRO] Lote final: {e}")

    cursor.close()
    conn.close()

    print(f"\n[CONCLUÍDO] Inseridos: {total_ok} | Erros: {total_err}")


if __name__ == "__main__":
    load_csv_to_db()
