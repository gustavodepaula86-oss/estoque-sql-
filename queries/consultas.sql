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

-- Estoque atual por categoria (tipo) e tamanho
SELECT tipo, tamanho, SUM(estoque_atual) AS total
FROM produtos
GROUP BY tipo, tamanho
ORDER BY tipo, tamanho;

-- Estoque atual de todos os produtos (ordenado por categoria)
SELECT sku, tipo, tamanho, estoque_atual
FROM produtos
ORDER BY tipo, tamanho, sku;


-- ============================================================
-- 2. ALERTAS DE ESTOQUE
-- ============================================================

-- Produtos sem estoque (zerados)
SELECT sku, tipo, tamanho
FROM produtos
WHERE estoque_atual = 0
ORDER BY tipo, tamanho;

-- Classificação automática de status de estoque (baseado na variação frente ao estoque inicial)
SELECT sku, tipo, tamanho, estoque_inicial, estoque_atual,
  CASE
    WHEN estoque_atual = 0                          THEN 'Sem estoque'
    WHEN estoque_atual < estoque_inicial * 0.3      THEN 'Estoque baixo'
    WHEN estoque_atual < estoque_inicial * 0.7      THEN 'Estoque normal'
    ELSE                                                  'Estoque alto'
  END AS status_estoque
FROM produtos
ORDER BY estoque_atual ASC;


-- ============================================================
-- 3. MOVIMENTAÇÕES
-- ============================================================

-- Histórico completo de movimentações com dados do produto
SELECT p.sku, p.tipo, p.tamanho,
       m.tipo_mov, m.quantidade, m.data, m.observacao
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
ORDER BY m.data DESC;

-- Apenas entradas
SELECT p.sku, p.tamanho, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo_mov = 'entrada'
ORDER BY m.data DESC;

-- Apenas vendas (saídas)
SELECT p.sku, p.tamanho, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo_mov = 'venda'
ORDER BY m.data DESC;

-- Movimentações de um período específico (ajuste as datas)
SELECT p.sku, p.tamanho, m.tipo_mov, m.quantidade, m.data
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.data BETWEEN '2026-06-01' AND '2026-06-30'
ORDER BY m.data DESC;


-- ============================================================
-- 4. RELATÓRIOS DE VENDAS E GIRO
-- ============================================================

-- Total de vendas por produto (mais vendidos)
SELECT p.sku, p.tamanho, SUM(m.quantidade) AS total_vendas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo_mov = 'venda'
GROUP BY p.id
ORDER BY total_vendas DESC;

-- Total de vendas por produto no mês atual
SELECT p.sku, p.tamanho, SUM(m.quantidade) AS total_vendas
FROM movimentacoes m
INNER JOIN produtos p ON m.produto_id = p.id
WHERE m.tipo_mov = 'venda'
  AND strftime('%Y-%m', m.data) = strftime('%Y-%m', 'now')
GROUP BY p.id
ORDER BY total_vendas DESC;

-- Entradas vs. vendas por produto
SELECT p.sku, p.tamanho,
  SUM(CASE WHEN m.tipo_mov = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN m.tipo_mov = 'venda'   THEN m.quantidade ELSE 0 END) AS total_vendas
FROM produtos p
LEFT JOIN movimentacoes m ON m.produto_id = p.id
GROUP BY p.id
ORDER BY p.sku;

-- Resumo geral: entradas e vendas totais no banco
SELECT
  SUM(CASE WHEN tipo_mov = 'entrada' THEN quantidade ELSE 0 END) AS total_entradas,
  SUM(CASE WHEN tipo_mov = 'venda'   THEN quantidade ELSE 0 END) AS total_vendas
FROM movimentacoes;


-- ============================================================
-- 5. BUSCAS ESPECÍFICAS
-- ============================================================

-- Buscar produto por SKU (substitua pelo termo desejado)
SELECT sku, tipo, tamanho, estoque_atual
FROM produtos
WHERE sku LIKE '%CAM%'
ORDER BY tamanho;

-- Buscar produto por SKU exato
SELECT *
FROM produtos
WHERE sku = 'SEU-SKU-AQUI';

-- Buscar produto por EAN
SELECT *
FROM produtos
WHERE ean = 'SEU-EAN-AQUI';

-- Estoque de uma categoria (tipo) específica (ex: 'camiseta' ou 'calça')
SELECT sku, tamanho, estoque_atual
FROM produtos
WHERE tipo = 'camiseta'
ORDER BY tamanho, sku;
