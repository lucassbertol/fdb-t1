<div align="center">

<img src="https://cdn.simpleicons.org/mysql" width="60" alt="MySQL logo"/>

# Steam Top 500 - Banco de Dados

**Modelagem e povoamento de um banco de dados desnormalizado e normalizado a partir dos 500 jogos com mais proprietários estimados da Steam**

![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)
![CSV](https://img.shields.io/badge/CSV-217346?style=flat-square&logo=files&logoColor=white)

</div>

---

## 📌 Overview

Este projeto consiste na modelagem, criação e povoamento de um banco de dados a partir de um arquivo `.csv` contendo os **500 jogos com mais proprietários estimados da Steam**.

O fluxo do trabalho é dividido em três etapas principais:

1. Criação de um banco de dados **desnormalizado**, refletindo a estrutura bruta do CSV.
2. Criação de um banco de dados **normalizado**, projetado a partir da modelagem relacional do conjunto de dados.
3. Inserção dos dados via scripts, partindo do CSV para o banco desnormalizado e deste para o banco normalizado, deixando ambos prontos para a realização de consultas.

Desenvolvido como trabalho final da disciplina de **Fundamentos de Banco de Dados** — Sistemas de Informação, UFSM.

---

## ✨ Estrutura do Projeto

- 📄 **Dataset (.csv)** — base de dados original com os 500 jogos mais possuídos da Steam
- 🗄️ **Banco desnormalizado** — script SQL de criação das tabelas seguindo a estrutura original do CSV
- 🐍 **Script Python de inserção** — lê o `.csv` e popula o banco desnormalizado
- 🗃️ **Banco normalizado** — script SQL de criação das tabelas seguindo o modelo relacional normalizado
- 🔁 **Script SQL de migração** — transfere os dados do banco desnormalizado para o banco normalizado
- 🔎 **Consultas** — banco normalizado pronto para execução de queries de análise

---

## 🛠️ Tech Stack

| Camada | Tecnologia |
|--------|------------|
| Banco de Dados | MySQL |
| Povoamento (CSV → Desnormalizado) | Python |
| Migração (Desnormalizado → Normalizado) | SQL |
| Dataset | CSV |

---

## 🚀 Getting Started

### Prerequisites

- MySQL Server
- Python 3.8+
- pip

### 1. Clone the repository

```bash
git clone https://github.com/lucassbertol/fdb-t1
cd fdb-t1
```

### 2. Crie o banco de dados desnormalizado

```bash
mysql -u root -p < sql/desnormalizado.sql
```

### 3. Instale as dependências do script Python

```bash
pip install -r requirements.txt
```

### 4. Popule o banco desnormalizado a partir do CSV

```bash
python insert_csv.py
```

### 5. Crie o banco de dados normalizado

```bash
mysql -u root -p < sql/normalizado.sql
```

### 6. Migre os dados do banco desnormalizado para o normalizado

```bash
mysql -u root -p < sql/migracao.sql
```

Após esses passos, o banco normalizado estará pronto para a execução das consultas.

---

## 🖼️ Diagramas

---

## 👤 Authors

**Lucas, Renato, Otávio e Artur**
Information Systems — Fundamentos de Banco de Dados

[![GitHub](https://img.shields.io/badge/GitHub-lucassbertol-181717?style=flat-square&logo=github)](https://github.com/lucassbertol)

---
