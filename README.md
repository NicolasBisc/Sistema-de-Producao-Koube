# Sistema de Gestão de Produção e Manutenção

Aplicação web para centralizar os dados operacionais de uma indústria
química — programação de produção, manutenção preventiva e corretiva,
colaboradores, auditoria e indicadores. Desenvolvida para a **Koube Química
do Brasil** e em operação interna desde agosto de 2026.

**Stack:** FastAPI · PostgreSQL · JavaScript · Docker

> **Sobre os dados deste repositório.** O sistema opera com dados reais de
> produção, mas este repositório é uma versão anonimizada, em linha com a
> LGPD: nomes de pessoas foram substituídos por fictícios atribuídos ao
> acaso, sem tabela de correspondência; datas de admissão foram reduzidas ao
> ano; fotos de colaboradores foram removidas; e credenciais, códigos de
> acesso e endereços internos foram trocados por placeholders. O volume, a
> estrutura e a lógica de cálculo foram preservados — 44 equipamentos, 255
> atividades preventivas e cerca de 790 ordens de serviço — para que o
> comportamento do sistema possa ser avaliado de verdade.

---

## O problema

O controle de produção e manutenção vivia em planilhas Excel paralelas: o
REG 7002/7003 para preventiva, o REG 7001/7005 para ordens de serviço, e uma
planilha separada para corretivas criada depois. Cada uma com sua numeração,
seu responsável e sua versão "mais atual". Consequências rotineiras:

- vencimento de preventiva calculado à mão, com atraso descoberto tarde
- ordens de serviço com numeração colidindo entre planilhas
- nenhum histórico de quem alterou o quê
- indicadores montados manualmente a cada reunião

## O que o sistema faz

**Produção** — programação diária por setor (envase, manipulação,
rotulagem), lançamento do realizado, metas mensais e dashboards de meta
versus realizado, com relatório imprimível em A4.

**Manutenção** — cadastro de equipamentos e atividades preventivas com
periodicidade. O vencimento e o status (em dia · vence em breve · atrasado)
são **calculados**, nunca digitados. Registrar a execução atualiza a última
ação e recalcula a próxima automaticamente. Corretiva e preventiva ficam
separadas, cada uma no seu registro (REG 7001/7005 e REG 7002/7003).

**Colaboradores** — cadastro, alocação em linhas e equipes, controle de
férias com cálculo de direito e vencimento.

**Auditoria** — toda alteração registra autor, ação, entidade e o valor
antes e depois.

**Usuários** — autenticação com JWT, permissão por módulo, bloqueio por
tentativas de login.

---

## Arquitetura

```
backend/
  main.py        41 endpoints FastAPI
  models.py      16 tabelas SQLAlchemy
  schemas.py     validação Pydantic na entrada
  logica.py      cálculo de vencimento, status e indicadores
  security.py    hash de senha com bcrypt
  protecao.py    rate limit e bloqueio por força bruta
  auth.py        emissão e verificação de JWT

frontend/
  index.html     interface completa, sem dependência externa

db/
  schema.sql     estrutura
  seed*.sql      carga inicial
  0*.sql         migrações numeradas, idempotentes

scripts/
  backup_koube.sh        dump diário com retenção de 30 dias
  restaurar_backup.sh    restauração com confirmação
  teste_sistema.py       suite de testes de interface
```

### Decisões que valem explicar

**Status calculado, não armazenado.** `logica.status_preventiva()` recebe a
última execução e a periodicidade e devolve próxima ação, dias de atraso e
status. Nada de campo `status` no banco esperando alguém atualizar — a fonte
da verdade é a data da execução.

**Migrações idempotentes.** Cada `.sql` numerado pode rodar duas vezes sem
efeito colateral, e aborta com mensagem clara se encontrar o banco num
estado que não esperava. Uma delas trava explicitamente se a faixa de
numeração que vai ocupar não estiver livre.

**Frontend em arquivo único.** Sem build, sem bundler, sem `node_modules`.
Serve direto do container FastAPI. Para um sistema interno mantido por uma
pessoa, a simplicidade de implantação venceu a organização em módulos.

**Validação na entrada.** Todo endpoint de escrita recebe um schema
Pydantic. Uma versão anterior aceitava `dict` cru em seis rotas, o que
permitia quantidade negativa e periodicidade zero.

---

## Rodando localmente

```bash
git clone <url-deste-repositorio>
cd koube-producao

cp backend/.env.example backend/.env
# preencha POSTGRES_PASSWORD e gere a SECRET_KEY:
python -c "import secrets; print(secrets.token_urlsafe(48))"

docker compose -f docker-compose.producao.yml up -d --build
```

Interface em `http://localhost:8010`.

Para criar o primeiro usuário, gere um hash e insira no banco:

```bash
docker exec producao-api python -c "import security; print(security.hash_senha('SUA_SENHA'))"
```

Os arquivos em `db/` contêm um placeholder `$2b$12$REPLACE_ME...` no lugar
dos hashes originais — substitua pelo hash gerado acima.

## Testes

```bash
pip install playwright && playwright install chromium
python scripts/teste_sistema.py
```

Percorre as cinco telas e suas subabas, verifica os módulos, gera os
dashboards, valida os conversores de data e o fluxo de troca de senha,
falhando se aparecer qualquer erro de JavaScript.

---

## Histórico técnico

Alguns problemas reais encontrados e como foram resolvidos — o que mais
ensinou neste projeto:

| Problema | Causa | Correção |
|---|---|---|
| Campo numérico perdia o foco a cada dígito | `oninput` reconstruía a tabela inteira via `innerHTML` | atualizar só a célula afetada |
| Login aceitava credencial vazia | fallback de "modo demonstração" que chamava `entrar()` no `catch` | exigir credencial válida, com mensagem por caso |
| Preventivas apareciam na aba de corretiva | a renderização ignorava o campo `tipo` | filtrar pela aba ativa |
| 91 corretivas nunca apareciam | endpoint limitado às 200 OS mais recentes, e as recentes eram todas preventivas | subir o limite e filtrar no servidor |
| Toda execução gravava como "Preditiva" | `tipo` fixo no código e ausente na resposta da API | usar o tipo da própria atividade |
| Cálculo de datas quebrado | constante `HOJE` fixa numa data passada | usar a data corrente |
| Relatório de indicadores com números inventados | valores de protótipo que nunca foram ligados ao banco | calcular a partir das ordens de serviço |

---

## Licença e autoria

Desenvolvido por **Nicolas Biscaia** durante atuação na Koube Química do
Brasil. O sistema é de propriedade da empresa; este repositório existe como
registro técnico do trabalho, com os dados operacionais e pessoais
removidos.

- [nicolasbiscaia.dev](https://nicolasbiscaia.dev)
- [LinkedIn](https://www.linkedin.com/in/nicolasbiscaia/)
