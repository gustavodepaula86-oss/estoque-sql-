# 📦 Sistema de Gestão de Estoque — SQL + SQLite

Projeto pessoal de banco de dados relacional para controle de estoque de um comércio de vestuário.  
Desenvolvido com **SQLite** e gerenciado via **DBeaver**.

---

## 🎯 Objetivo

Substituir o controle manual em planilhas por um banco de dados relacional, permitindo:
- Consultas rápidas de estoque por produto, tamanho e categoria
- Rastreamento de entradas e saídas de mercadoria
- Alertas automáticos de itens abaixo do estoque mínimo
- Relatórios de movimentação por período

---

## 🗂️ Estrutura do Banco de Dados

### Tabela `produtos`
Armazena o cadastro de todos os produtos e seus níveis de estoque.

| Coluna         | Tipo    | Descrição                          |
|----------------|---------|------------------------------------|
| id             | INTEGER | Chave primária                     |
| ean            | TEXT    | Código de barras (EAN)             |
| sku            | TEXT    | Código interno do produto          |
| descricao      | TEXT    | Nome/descrição do produto          |
| categoria      | TEXT    | Ex: Camisa, Calça                  |
| tamanho        | TEXT    | Ex: P, M, G, GG / 38, 40, 42...   |
| quantidade     | INTEGER | Quantidade atual em estoque        |
| estoque_minimo | INTEGER | Quantidade mínima antes do alerta  |

### Tabela `movimentacoes`
Registra todas as entradas e saídas de produtos.

| Coluna      | Tipo    | Descrição                        |
|-------------|---------|----------------------------------|
| id          | INTEGER | Chave primária                   |
| produto_id  | INTEGER | Chave estrangeira → produtos.id  |
| tipo        | TEXT    | 'entrada' ou 'saida'             |
| quantidade  | INTEGER | Quantidade movimentada           |
| data        | TEXT (YYYY-MM-DD)| Data da movimentação.   |
| observacao  | TEXT    | Observação opcional              |

---

## 🔍 Exemplos de Queries

### Estoque atual por categoria
```sql
SELECT categoria, tamanho, SUM(quantidade) AS total
FROM produtos
GROUP BY categoria, tamanho
ORDER BY categoria, tamanho;
```

### Produtos abaixo do estoque mínimo
```sql
SELECT sku, descricao, tamanho, quantidade, estoque_minimo
FROM produtos
WHERE quantidade < estoque_minimo
ORDER BY quantidade ASC;
```

### Histórico de movimentações com nome do produto
```sql
SELECT p.descricao, p.tamanho, m.tipo, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
ORDER BY m.data DESC;
```

### Total de saídas por produto no mês
```sql
SELECT p.descricao, p.tamanho, SUM(m.quantidade) AS total_saidas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo = 'saida'
  AND strftime('%Y-%m', m.data) = '2026-06'
GROUP BY p.id
ORDER BY total_saidas DESC;
```

### Classificação automática de estoque com CASE WHEN
```sql
SELECT descricao, tamanho, quantidade,
  CASE
    WHEN quantidade = 0              THEN 'Sem estoque'
    WHEN quantidade < estoque_minimo THEN 'Estoque baixo'
    WHEN quantidade < estoque_minimo * 2 THEN 'Estoque normal'
    ELSE 'Estoque alto'
  END AS status_estoque
FROM produtos
ORDER BY quantidade ASC;
```

### Entradas vs. saídas por produto
```sql
SELECT p.descricao, p.tamanho,
  SUM(CASE WHEN m.tipo = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN m.tipo = 'saida'   THEN m.quantidade ELSE 0 END) AS total_saidas
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id
ORDER BY p.descricao;
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

- **+400 variações de produtos** cadastradas (camisas e calças)
- Controle por **EAN, SKU, tamanho e categoria**
- Movimentações com rastreamento de **entradas e saídas**
- Alertas de **estoque mínimo** configurados por produto

---

## 👤 Autor

**Gustavo de Paula**  
[gustavodepaula.86@gmail.com](mailto:gustavodepaula.86@gmail.com)  
Araçatuba – SP, Brasil
## 📊 Dashboard

Visualização interativa dos dados de estoque:
https://datastudio.google.com/u/0/reporting/03d0da01-9529-44a9-a1ab-217418f274a8/page/Xea1F

## 📊 Dashboard Interativo

Visualização dos dados no Looker Studio:
🔗 https://datastudio.google.com/reporting/03d0da01-9529-44a9-a1ab-217418f274a8
