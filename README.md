# 🛒 Desafio E-commerce — Transações, Procedures e Backup

## 📋 Descrição

Este projeto implementa **transações SQL**, **stored procedures com tratamento de erro** e **backup/recovery** para o banco de dados de e-commerce, como parte da formação **SQL Database Specialist** da DIO.

---

## 🗂 Arquivos

```
├── ecommerce_transacoes_backup.sql   # Script principal: DDL + DML + Transações + Procedure + Evento
├── backup_ecommerce_completo.sql     # Arquivo de backup gerado via mysqldump
└── README.md
```

---

## 🏗 Esquema Lógico do Banco `ecommerce`

O banco representa uma plataforma de comércio eletrônico com os seguintes relacionamentos:

```
clients ──── orders ──────── productOrder ──── product
                │                                  │
             payments                    productSupplier ── supplier
                                         productSeller   ── seller
                                         storageLocation ── productStorage
order_audit_log  ← tabela de auditoria de transações
```

### Tabelas principais

| Tabela | Responsabilidade |
|---|---|
| `clients` | Clientes da plataforma |
| `product` | Catálogo de produtos |
| `orders` | Pedidos realizados |
| `payments` | Formas de pagamento por cliente |
| `productStorage` | Estoques físicos |
| `supplier` | Fornecedores |
| `seller` | Vendedores terceiros |
| `productOrder` | Itens de cada pedido (M:N) |
| `productSupplier` | Produtos por fornecedor (M:N) |
| `productSeller` | Produtos por vendedor (M:N) |
| `storageLocation` | Localização de produto no estoque (M:N) |
| `order_audit_log` | Registro de auditoria das transações |

---

## ⚙️ Parte 1 — Transações Manuais

### CODE 1 — Desabilitar autocommit + transação simples

Desabilita o `autocommit` para controle manual de confirmações. A transação confirma um pedido em aberto e registra a ação no log de auditoria.

```sql
SET autocommit = 0;

START TRANSACTION;
    UPDATE orders SET orderStatus = 'Confirmado'
    WHERE idOrder = 2 AND orderStatus = 'Em processamento';

    INSERT INTO order_audit_log (idOrder, acao, status_antes, status_depois)
    VALUES (2, 'CONFIRMAR_PEDIDO', 'Em processamento', 'Confirmado');
COMMIT;
```

### CODE 2 — Transação com SAVEPOINT e múltiplos DML

Processa um pedido completo em etapas: insere cliente, cria o pedido, estabelece um `SAVEPOINT` e depois adiciona os itens. Caso os itens falhem, o `ROLLBACK TO SAVEPOINT` preserva o pedido criado.

```sql
START TRANSACTION;
    INSERT INTO clients ...;
    SET @novo_pedido = LAST_INSERT_ID();

    SAVEPOINT sp_antes_itens;

    INSERT INTO productOrder ...;
    INSERT INTO order_audit_log ...;
COMMIT;
```

---

## 🔁 Parte 2 — Procedure com Tratamento de Erro

### `sp_processar_pedido`

Encapsula a lógica de criação de pedido dentro de uma procedure com `EXIT HANDLER` para `SQLEXCEPTION`.

**Fluxo:**

```
sp_processar_pedido(idCliente, descricao, frete, idProduto, quantidade)
    │
    ├─ Verifica existência do cliente
    │   └─ Não existe → SIGNAL → EXIT HANDLER → ROLLBACK total
    │
    ├─ Insere pedido → SAVEPOINT sp_pedido_criado
    │
    ├─ Verifica estoque do produto
    │   └─ Insuficiente → ROLLBACK TO SAVEPOINT → pedido cancelado
    │
    └─ Insere item + log → COMMIT
```

**Resultados dos testes:**

| Cenário | Resultado |
|---|---|
| Cliente existe, estoque OK | `SUCESSO — Pedido N processado` |
| Estoque insuficiente | `AVISO — Pedido criado mas cancelado por estoque insuficiente` |
| Cliente inexistente | `ERRO — Transação revertida` |

---

## 🗄️ Parte 3 — Backup e Recovery

### Gerar o backup completo

```bash
mysqldump -u root -p \
    --routines \
    --triggers \
    --events \
    --single-transaction \
    --add-drop-database \
    --databases ecommerce \
> backup_ecommerce_completo.sql
```

O arquivo inclui: estrutura das tabelas, dados, procedures, triggers e eventos agendados.

### Outros tipos de backup

```bash
# Apenas estrutura (DDL)
mysqldump -u root -p --no-data --routines --triggers --events ecommerce \
> backup_ecommerce_estrutura.sql

# Apenas dados (DML)
mysqldump -u root -p --no-create-info ecommerce \
> backup_ecommerce_dados.sql

# Múltiplos bancos
mysqldump -u root -p --routines --triggers --events \
    --databases ecommerce company_constraints \
> backup_multiplos_bancos.sql
```

### Restaurar

```bash
mysql -u root -p < backup_ecommerce_completo.sql
```

---

## 📅 Evento Agendado (Bônus)

O script também cria um **evento** que limpa automaticamente logs de auditoria com mais de 90 dias, executado semanalmente:

```sql
CREATE EVENT evt_limpeza_log_auditoria
ON SCHEDULE EVERY 1 WEEK
DO BEGIN
    DELETE FROM order_audit_log
    WHERE executado_em < NOW() - INTERVAL 90 DAY;
END;
```

---

## 🚀 Como Executar

**Pré-requisito:** MySQL 8.0+

```bash
mysql -u root -p < ecommerce_transacoes_backup.sql
```

---

## 🧩 Tecnologias

- **MySQL 8.0** — SGBD relacional
- **SQL** — DDL, DML, TCL (`START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`)
- **Stored Procedures** — com `DECLARE HANDLER`, `SIGNAL`, `GET DIAGNOSTICS`
- **mysqldump** — backup com `--routines`, `--triggers`, `--events`

---

## 👤 Autor

### **[Sailanth](https://github.com/Sailanth)**

Desafio de Projeto — Formação SQL Database Specialist | DIO
