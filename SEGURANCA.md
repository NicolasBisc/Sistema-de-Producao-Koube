# Koube Produção — Infraestrutura de Segurança

Análise e medidas implementadas para deixar o sistema robusto. Documento para
o Bianca e o time, e para consulta de auditoria.

## Camadas de proteção implementadas

### 1. Autenticação
- **Senhas com bcrypt** (hash + salt individual). A senha real nunca é
  armazenada nem trafega em texto no banco.
- **JWT (HS256)** com expiração de 8h (uma jornada). Sem token válido, nenhuma
  rota protegida responde.
- **SECRET_KEY via variável de ambiente** (`.env`), nunca no código. Gerar com
  `openssl rand -hex 32`.

### 2. Proteção contra força bruta (`protecao.py`)
- **Rate limiting no login**: conta tentativas falhas por IP + código.
- **Bloqueio temporário**: após **5 falhas em 5 minutos**, bloqueia por **15
  minutos** (HTTP 429). Zera ao logar com sucesso.
- **Log de tentativas falhas** na auditoria, sem revelar se o usuário existe
  (a mensagem é sempre "Código ou senha inválidos").

### 3. Política de senha (`protecao.validar_forca_senha`)
- Mínimo 8 caracteres, com maiúscula, minúscula e número.
- Bloqueia senhas comuns (koube123, 12345678, etc.).
- Aplicada ao **criar usuário** e ao **trocar senha**.

### 4. Primeiro acesso
- Todo usuário criado nasce com `senha_temporaria = TRUE`.
- O login devolve essa flag; o frontend deve **forçar a troca** antes de liberar
  o sistema (endpoint `POST /auth/trocar-senha`).

### 5. Autorização
- **Níveis**: admin | supervisor | operador | manutencao.
- **Só admin cria/gerencia usuários** (`somente_admin`). Testado: supervisor
  recebe 403.
- Flags `acesso_producao` / `acesso_manutencao` por usuário.

### 6. Validação de entrada (`schemas.py`)
- Todos os endpoints usam **schemas Pydantic** (não `dict` solto): tipos,
  tamanhos e formatos validados antes de tocar no banco. Reduz risco de dados
  malformados e de payloads maliciosos.
- Uso de **ORM (SQLAlchemy)** com queries parametrizadas — protege contra
  **SQL injection** por padrão.

### 7. Cabeçalhos HTTP de segurança (`SecurityHeadersMiddleware`)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` (anti-clickjacking)
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy`: bloqueia geolocalização, microfone, câmera
- `Strict-Transport-Security` (HSTS): força HTTPS por 1 ano (efetivo atrás do
  Nginx/Certbot).

### 8. CORS restrito
- Origens limitadas às definidas em `CORS_ORIGINS` (sem wildcard `*`).
- Métodos e cabeçalhos restritos ao necessário.

### 9. Auditoria
- Toda ação relevante (login, criar, editar, excluir, gerar documento) é
  gravada com **autor, data/hora e descrição**, além de valor antigo/novo em
  JSON quando aplicável. Serve de trilha para investigação.

## Checklist de deploy seguro (na VM)
- [ ] `SECRET_KEY` forte no `.env` (nunca a padrão).
- [ ] `DATABASE_URL` com senha forte do Postgres.
- [ ] HTTPS ativo via Certbot (`certbot --nginx -d producao.koube.com.br`).
- [ ] Trocar a senha inicial (`koube123`) dos usuários NBI e SPV no 1º acesso.
- [ ] Porta do Postgres **não** exposta publicamente (só rede interna do Docker).
- [ ] Backups automáticos do banco `koube_producao`.
- [ ] `/docs` da API: considerar restringir em produção (é útil, mas expõe o
      mapa de endpoints).

## Recomendações futuras (evolução)
- **Refresh tokens + revogação** (logout server-side / bloquear token roubado).
- **Redis** para o rate limiting, se rodar em múltiplos workers/instâncias.
- **2FA** para o admin.
- **Timeout de sessão por inatividade** no frontend (logout automático).
- Rotação periódica de `SECRET_KEY`.
- Monitoramento/alerta de picos de `login_falha` na auditoria.

> Nota honesta: nenhuma medida torna um sistema "100% invulnerável". O conjunto
> acima cobre os vetores mais comuns (força bruta, injeção, clickjacking, senha
> fraca, acesso indevido) e coloca o Koube Produção num patamar sólido de
> segurança para uso interno. As recomendações futuras elevam ainda mais a barra
> conforme a necessidade crescer.
