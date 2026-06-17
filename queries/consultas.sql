-- ============================================================
-- SISTEMA DE GESTÃO DE ESTOQUE — SQLite
-- Autor: Gustavo de Paula
-- Descrição: Consultas principais do banco de dados de estoque
-- ============================================================


-- ============================================================
-- 1. VISÃO GERAL DO ESTOQUE
-- ============================================================

-- Total de produtos cadastrados
SELECT COUNT(*) AS total_produtos
FROM produtos;

-- Estoque atual por categoria e tamanho
SELECT categoria, tamanho, SUM(quantidade) AS total
FROM produtos
GROUP BY categoria, tamanho
ORDER BY categoria, tamanho;

-- Estoque atual de todos os produtos (ordenado por categoria)
SELECT sku, descricao, categoria, tamanho, quantidade
FROM produtos
ORDER BY categoria, tamanho, descricao;


-- ============================================================
-- 2. ALERTAS DE ESTOQUE
-- ============================================================

-- Produtos abaixo do estoque mínimo
SELECT sku, descricao, tamanho, quantidade, estoque_minimo,
       (estoque_minimo - quantidade) AS faltam
FROM produtos
WHERE quantidade < estoque_minimo
ORDER BY faltam DESC;

-- Produtos sem estoque (zerados)
SELECT sku, descricao, tamanho
FROM produtos
WHERE quantidade = 0
ORDER BY categoria, tamanho;

-- Classificação automática de status de estoque
SELECT descricao, tamanho, quantidade,
  CASE
    WHEN quantidade = 0                  THEN 'Sem estoque'
    WHEN quantidade < estoque_minimo     THEN 'Estoque baixo'
    WHEN quantidade < estoque_minimo * 2 THEN 'Estoque normal'
    ELSE                                      'Estoque alto'
  END AS status_estoque
FROM produtos
ORDER BY quantidade ASC;


-- ============================================================
-- 3. MOVIMENTAÇÕES
-- ============================================================

-- Histórico completo de movimentações com nome do produto
SELECT p.sku, p.descricao, p.tamanho,
       m.tipo, m.quantidade, m.data, m.observacao
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
ORDER BY m.data DESC;

-- Apenas entradas
SELECT p.descricao, p.tamanho, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo = 'entrada'
ORDER BY m.data DESC;

-- Apenas saídas
SELECT p.descricao, p.tamanho, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo = 'saida'
ORDER BY m.data DESC;

-- Movimentações de um período específico (ajuste as datas)
SELECT p.descricao, p.tamanho, m.tipo, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.data BETWEEN '2026-06-01' AND '2026-06-30'
ORDER BY m.data DESC;


-- ============================================================
-- 4. RELATÓRIOS DE VENDAS E GIRO
-- ============================================================

-- Total de saídas por produto (mais vendidos)
SELECT p.descricao, p.tamanho, SUM(m.quantidade) AS total_saidas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo = 'saida'
GROUP BY p.id
ORDER BY total_saidas DESC;

-- Total de saídas por produto no mês atual
SELECT p.descricao, p.tamanho, SUM(m.quantidade) AS total_saidas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo = 'saida'
  AND strftime('%Y-%m', m.data) = strftime('%Y-%m', 'now')
GROUP BY p.id
ORDER BY total_saidas DESC;

-- Entradas vs. saídas por produto
SELECT p.descricao, p.tamanho,
  SUM(CASE WHEN m.tipo = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN m.tipo = 'saida'   THEN m.quantidade ELSE 0 END) AS total_saidas
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id
ORDER BY p.descricao;

-- Resumo geral: entradas e saídas totais no banco
SELECT
  SUM(CASE WHEN tipo = 'entrada' THEN quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN tipo = 'saida'   THEN quantidade ELSE 0 END) AS total_saidas
FROM movimentacoes;


-- ============================================================
-- 5. BUSCAS ESPECÍFICAS
-- ============================================================

-- Buscar produto por descrição (substitua 'camiseta' pelo termo desejado)
SELECT sku, descricao, tamanho, quantidade
FROM produtos
WHERE descricao LIKE '%camiseta%'
ORDER BY tamanho;

-- Buscar produto por SKU
SELECT *
FROM produtos
WHERE sku = 'SEU-SKU-AQUI';

-- Buscar produto por EAN
SELECT *
FROM produtos
WHERE ean = 'SEU-EAN-AQUI';

-- Estoque de uma categoria específica (ex: Camisa ou Calça)
SELECT descricao, tamanho, quantidade
FROM produtos
WHERE categoria = 'Camisa'
ORDER BY tamanho, descricao;
