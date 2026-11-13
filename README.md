# AITHA — tratamento de vendas com dbt

Projeto dbt para validar registros de vendas no Databricks e publicar dados nas camadas Bronze, Silver e Gold.

## Arquitetura

- **Bronze (`bronze_sales`)**: espelho completo da tabela `oracio.source.raw_sales`, incluindo registros marcados para exclusão. A tabela é reconstruída a cada execução para refletir atualizações e exclusões da origem.
- **Silver intermediária (`int_silver_sales`)**: view que ignora linhas com `exclude = TRUE`, converte os tipos e classifica registros com problemas, como campos inválidos/ausentes, valores negativos e IDs duplicados.
- **Silver validada (`silver_sales`)**: tabela com apenas os registros que passaram pelas validações.
- **Quarentena (`quarentine_silver_sales`)**: tabela incremental que mantém o estado dos registros inválidos.
- **Gold (`fct_sales`, `mart_sales_by_date_store`)**: fato de vendas e agregação por data e loja.

O nome `quarentine_silver_sales` é mantido como identificador dbt para não quebrar referências existentes; os diretórios e macros usam a grafia `quarantine`.

### Estados da quarentena

- `open`: registro presente na origem e ainda inválido.
- `resolved`: registro voltou a passar pelas validações.
- `removed`: registro anteriormente em quarentena foi excluído do snapshot ou marcado com `exclude = TRUE`. Não significa que foi corrigido.

`first_seen_at` é preservado desde a primeira entrada em quarentena. `last_seen_at` avança apenas enquanto o registro permanece inválido e não avança ao ser resolvido ou removido. `resolved_at` é preenchido somente no estado `resolved`. Se um registro removido voltar, ele retorna a `open` se inválido ou passa a `resolved` se válido.

## Pré-requisitos

- Docker com Docker Compose, ou Python 3.12 e `uv` para execução local.
- Acesso a um workspace Databricks com o catálogo `oracio`.
- A tabela `oracio.source.raw_sales`, incluindo `source_record_key` único e estável e a coluna booleana `exclude`. A origem deve representar o snapshot completo atual; exclusões físicas devem estar refletidas na tabela e exclusões lógicas devem usar `exclude = TRUE`.
- Credenciais Databricks definidas pelas variáveis `DATABRICKS_HOST`, `DATABRICKS_HTTP_PATH` e `DATABRICKS_TOKEN`.

Crie um arquivo `.env` na raiz (ele é ignorado pelo Git) com:

```dotenv
DATABRICKS_HOST=https://<workspace>
DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/<warehouse-id>
DATABRICKS_TOKEN=<token>
```

## Executar com Docker Compose

```powershell
docker compose run --build --rm dbt debug
docker compose run --rm dbt build
```

`dbt build` executa os modelos, snapshots e testes. O perfil é carregado de `dbt_project/profiles.yml`; os valores secretos vêm do `.env`.

## Executar localmente

Instale as dependências travadas:

```powershell
uv sync --locked
```

Defina as três variáveis Databricks no ambiente e execute:

```powershell
$env:DATABRICKS_HOST = "https://<workspace>"
$env:DATABRICKS_HTTP_PATH = "/sql/1.0/warehouses/<warehouse-id>"
$env:DATABRICKS_TOKEN = "<token>"
uv run dbt debug --project-dir dbt_project --profiles-dir dbt_project
uv run dbt build --project-dir dbt_project --profiles-dir dbt_project
```

Para validar apenas a configuração/Jinja sem conectar ao warehouse:

```powershell
uv run dbt parse --project-dir dbt_project --profiles-dir dbt_project
```

## Incrementalidade e custo

Como a origem permite atualizações e exclusões e não declara uma coluna confiável de watermark nem Change Data Feed, a Bronze é um espelho completo e lê a origem a cada execução. Isso preserva correções e remoções; filtrar somente chaves novas deixaria dados incorretos. A Silver validada também é reconstruída para retirar registros que se tornem inválidos. Para volumes grandes, uma otimização segura depende de habilitar e documentar um mecanismo de alterações (por exemplo, Change Data Feed ou watermark com semântica de exclusão) na origem.
