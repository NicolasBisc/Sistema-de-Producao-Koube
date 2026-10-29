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

O supervisor de produção organizava férias, programação de produção,
treinamentos de RH e manutenções em planilhas espalhadas, cada uma com sua
numeração, seu formato e sua versão "mais atual". Na prática:

- vencimento de preventiva calculado à mão, com atraso descoberto tarde
- ordens de serviço com numeração repetida entre planilhas
- nenhum histórico de quem alterou o quê
- indicadores montados manualmente a cada reunião

O sistema reuniu essas informações em um só lugar e deu ao supervisor
autonomia para consultar e acompanhar a operação sem depender de montar
relatórios à mão.

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
férias com cálculo de direito e vencimento, e plano de treinamentos.

**Histórico** — cada alteração fica registrada com quem fez e o que mudou.

**Usuários** — login com senha e acesso liberado por módulo.

---

## Arquitetura

```
backend/
  main.py        rotas da API
  models.py      tabelas do banco
  schemas.py     validação dos dados recebidos
  logica.py      cálculo de vencimento, status e indicadores
  security.py    senhas
  protecao.py    proteção contra tentativas repetidas de login
  auth.py        sessão do usuário

frontend/
  index.html     interface completa, sem dependência externa

db/
  schema.sql     estrutura
  seed*.sql      carga inicial
  0*.sql         migrações numeradas

scripts/
  backup_koube.sh        backup diário do banco
  restaurar_backup.sh    restauração do backup
  teste_sistema.py       testes da interface
```

### Decisões que valem explicar

**Status calculado, não armazenado.** `logica.status_preventiva()` recebe a
última execução e a periodicidade e devolve próxima ação, dias de atraso e
status. Nada de campo `status` no banco esperando alguém atualizar — a fonte
da verdade é a data da execução.

**Migrações que podem rodar de novo.** Cada `.sql` numerado pode ser
executado mais de uma vez sem estragar os dados, e para com uma mensagem
clara se encontrar o banco num estado inesperado.

**Frontend em arquivo único.** Sem etapa de build. Para um sistema interno
mantido por uma pessoa, a simplicidade de implantação pesou mais que a
organização em módulos.

**Validação na entrada.** Uma versão anterior aceitava quantidade negativa e
periodicidade zero; hoje os dados são conferidos antes de gravar.

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

Alguns problemas reais que encontrei e como resolvi — foi o que mais me
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

- [Portfólio](https://portfolio-nicolasbiscaia-shgh.vercel.app)
- [LinkedIn](https://www.linkedin.com/in/nicolasbiscaia/)
