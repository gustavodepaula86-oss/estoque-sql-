# 📦 Sistema de Gestão de Estoque — SQL + SQLite

Projeto pessoal de banco de dados relacional para controle de estoque de um comércio de vestuário.
Desenvolvido com **SQLite** e gerenciado via **DBeaver**.

> **Nota:** os dados deste repositório (EAN, SKU) são fictícios, gerados para fins de portfólio. A estrutura e a lógica do banco refletem um sistema real em uso.

---

## 🎯 Objetivo

Substituir o controle manual em planilhas por um banco de dados relacional, permitindo:
- Consultas rápidas de estoque por produto, tamanho e categoria
- Rastreamento de entradas e vendas de mercadoria
- Relatórios de movimentação por período
- Classificação de níveis de estoque

---

## 🗂️ Estrutura do Banco de Dados

### Tabela `produtos`
Armazena o cadastro de todos os produtos e seus níveis de estoque.

| Coluna          | Tipo    | Descrição                                   |
|-----------------|---------|----------------------------------------------|
| id              | INTEGER | Chave primária                               |
| ean             | TEXT    | Código de barras (EAN)                       |
| sku             | TEXT    | Código interno do produto (inclui categoria) |
| tipo            | TEXT    | Categoria do produto (ex: camiseta, calça)   |
| tamanho         | TEXT    | Ex: P, M, G, GG / 28, 30, 32...              |
| estoque_inicial | INTEGER | Quantidade cadastrada inicialmente           |
| estoque_atual   | INTEGER | Quantidade atual em estoque                  |

### Tabela `movimentacoes`
Registra todas as entradas e vendas de produtos.

| Coluna      | Tipo              | Descrição                        |
|-------------|-------------------|-----------------------------------|
| id          | INTEGER           | Chave primária                   |
| produto_id  | INTEGER           | Chave estrangeira → produtos.id  |
| data        | TEXT (YYYY-MM-DD) | Data da movimentação              |
| tipo_mov    | TEXT              | 'entrada' ou 'venda'              |
| quantidade  | INTEGER           | Quantidade movimentada            |
| observacao  | TEXT              | Observação opcional               |

---

## 🔍 Exemplos de Queries

### Estoque atual por categoria
```sql
SELECT tipo, tamanho, SUM(estoque_atual) AS total
FROM produtos
GROUP BY tipo, tamanho
ORDER BY tipo, tamanho;
```

### Produtos sem estoque
```sql
SELECT sku, tipo, tamanho, estoque_atual
FROM produtos
WHERE estoque_atual = 0
ORDER BY tipo, tamanho;
```

### Histórico de movimentações com dados do produto
```sql
SELECT p.sku, p.tamanho, m.tipo_mov, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
ORDER BY m.data DESC;
```

### Total de vendas por produto no mês
```sql
SELECT p.sku, p.tamanho, SUM(m.quantidade) AS total_vendas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo_mov = 'venda'
  AND strftime('%Y-%m', m.data) = '2026-06'
GROUP BY p.id
ORDER BY total_vendas DESC;
```

### Classificação automática de estoque com CASE WHEN
```sql
SELECT sku, tamanho, estoque_inicial, estoque_atual,
  CASE
    WHEN estoque_atual = 0                     THEN 'Sem estoque'
    WHEN estoque_atual < estoque_inicial * 0.3 THEN 'Estoque baixo'
    WHEN estoque_atual < estoque_inicial * 0.7 THEN 'Estoque normal'
    ELSE 'Estoque alto'
  END AS status_estoque
FROM produtos
ORDER BY estoque_atual ASC;
```

### Entradas vs. vendas por produto
```sql
SELECT p.sku, p.tamanho,
  SUM(CASE WHEN m.tipo_mov = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN m.tipo_mov = 'venda'   THEN m.quantidade ELSE 0 END) AS total_vendas
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id
ORDER BY p.sku;
```

---

## 🛠️ Tecnologias Utilizadas

| Ferramenta | Uso |
|------------|-----|
| SQLite     | Banco de dados relacional |
| DBeaver    | Interface visual para queries e auditoria |
| SQL        | Linguagem de consulta e manipulação de dados |

---

## 📊 Dados do Projeto

- **363 variações de produtos** cadastradas (camisetas e calças, incluindo bermuda e chino)
- Controle por **EAN, SKU, tamanho e categoria**
- Movimentações com rastreamento de **entradas e vendas**
- Dados de EAN/SKU fictícios para fins de publicação pública

---

## 👤 Autor

**Gustavo de Paula**
[gustavodepaula.86@gmail.com](mailto:gustavodepaula.86@gmail.com)
Araçatuba – SP, Brasil

## 📊 Dashboard Interativo

Visualização dos dados no Looker Studio:
🔗 https://datastudio.google.com/reporting/03d0da01-9529-44a9-a1ab-217418f274a8
