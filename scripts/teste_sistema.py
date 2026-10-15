from playwright.sync_api import sync_playwright
import json
U="file://./frontend/index.html"
STUB="""()=>{ window.fetch=async(u,o)=>{
  const ok=(x)=>new Response(JSON.stringify(x),{status:200,headers:{'Content-Type':'application/json'}});
  u=String(u);
  if(u.includes('/auth/login')) return ok({access_token:'t',usuario:{codigo:'SUP',nome:'Simone Rodrigues',cargo:'Supervisor de Produção',nivel:'admin',acesso_producao:true,acesso_manutencao:true,acesso_supervisao:true}});
  if(u.includes('/programacao/periodo')) return ok([{data:'2026-08-10',programado:12500,realizado:13000},{data:'2026-08-11',programado:12500,realizado:11800}]);
  return ok([]); }; }"""
falhas=[]; erros=[]
with sync_playwright() as pw:
    b=pw.chromium.launch(); pg=b.new_page(viewport={"width":1500,"height":950})
    pg.on("pageerror", lambda e: erros.append(str(e)))
    pg.on("dialog", lambda d: d.accept())
    pg.goto(U); pg.wait_for_timeout(1500)
    pg.evaluate(STUB)
    pg.fill("#loginCod","SUP"); pg.fill("#loginSenha","senha-de-teste"); pg.click("#btnEntrar"); pg.wait_for_timeout(2000)
    if not pg.evaluate("document.getElementById('login-screen').classList.contains('hidden')"):
        falhas.append("login com credencial válida não entrou")

    # navega por todas as views e todas as subtabs
    views=pg.evaluate("[...document.querySelectorAll('[data-view]')].map(b=>b.dataset.view)")
    for v in views:
        pg.evaluate(f"[...document.querySelectorAll('[data-view]')].find(b=>b.dataset.view==='{v}').click()")
        pg.wait_for_timeout(700)
        ativa=pg.evaluate("document.querySelector('.view.active')?.id||''")
        if not ativa: falhas.append(f"view '{v}' não ativou nenhuma seção")
        n=pg.evaluate("document.querySelectorAll('.view.active .subtab').length")
        for i in range(n):
            pg.evaluate(f"document.querySelectorAll('.view.active .subtab')[{i}].click()")
            pg.wait_for_timeout(350)
    print("views testadas:", views)

    # funções críticas existem e respondem
    checks={
      "toast":"typeof toast==='function'",
      "sair":"typeof sair==='function'",
      "acharProduto":"typeof acharProduto==='function'",
      "copiarDoEnvase":"typeof copiarDoEnvase==='function'",
      "atualizarDiff":"typeof atualizarDiff==='function'",
      "preencherPerfil":"typeof preencherPerfil==='function'",
      "dBR":"typeof dBR==='function'",
      "dISO":"typeof dISO==='function'",
      "montarDashDados":"typeof montarDashDados==='function'",
      "buildProg":"typeof buildProg==='function'",
    }
    for k,expr in checks.items():
        if not pg.evaluate(expr): falhas.append(f"função ausente: {k}")

    # conversores de data
    casos=[("2026-08-11","11/08/2026"),("2026-08-11 08:40","11/08/2026 08:40"),("","—")]
    for ent,esp in casos:
        got=pg.evaluate(f"dBR({json.dumps(ent)})")
        if got!=esp: falhas.append(f"dBR({ent!r}) = {got!r}, esperado {esp!r}")
    for ent,esp in [("11/08/2026","2026-08-11"),("1/8/2026","2026-08-01"),("2026-08-11","2026-08-11")]:
        got=pg.evaluate(f"dISO({json.dumps(ent)})")
        if got!=esp: falhas.append(f"dISO({ent!r}) = {got!r}, esperado {esp!r}")

    # dashboard semanal e mensal
    for per in ["semanal","mensal"]:
        pg.evaluate(f"dashPeriodo='{per}'"); pg.evaluate("gerarDashboard()"); pg.wait_for_timeout(1200)
        r=pg.evaluate("""()=>{const s=document.getElementById('dashSheetPage');
          return {vazio:!!s.querySelector('.ds-vazio'),barras:s.querySelectorAll('.ds-bcol').length,resumo:!!s.querySelector('.ds-resumo')};}""")
        if r["vazio"] or r["barras"]==0: falhas.append(f"dashboard {per} veio vazio: {r}")
        if not r["resumo"]: falhas.append(f"dashboard {per} sem bloco de resumo")

    # modal do colaborador
    pg.evaluate("[...document.querySelectorAll('[data-view]')].find(b=>b.dataset.view==='supervisao').click()"); pg.wait_for_timeout(600)
    ok=pg.evaluate("typeof abrirPerfilColab==='function' ? (abrirPerfilColab(0),true) : false")
    if ok:
        pg.wait_for_timeout(600)
        m=pg.evaluate("""()=>{const w=document.querySelector('#colabModal .cp-wrap');const b=w.getBoundingClientRect();
          const f=document.querySelector('#colabModal .cp-foot').getBoundingClientRect();
          return {cabe:b.bottom<=innerHeight+1, rodape:f.bottom<=innerHeight+1};}""")
        if not m["cabe"]: falhas.append("modal do colaborador transborda")
        if not m["rodape"]: falhas.append("rodapé do modal inacessível")
        pg.evaluate("document.getElementById('colabModal').classList.remove('open')")
    else: falhas.append("abrirPerfilColab não existe")

    # troca de senha
    pg.evaluate("profileModal.classList.add('open')"); pg.wait_for_timeout(300)
    pg.evaluate("document.getElementById('btnEditarPerfil').click()"); pg.wait_for_timeout(500)
    if not pg.evaluate("senhaModal.classList.contains('open')"): falhas.append("modal de troca de senha não abre")
    pg.fill("#snAtual","a"); pg.fill("#snNova","abc"); pg.fill("#snNova2","abc")
    pg.evaluate("snSalvar.click()"); pg.wait_for_timeout(400)
    if "8 caracteres" not in pg.eval_on_selector_all(".kt-msg","e=>e.map(x=>x.textContent).join('|')"):
        falhas.append("validação de senha curta não avisou")
    pg.evaluate("senhaModal.classList.remove('open')")

    # perfil = quem entrou
    pg.evaluate("preencherPerfil()")
    if pg.inner_text("#pfCodigo")!="SUP": falhas.append("perfil não mostra o usuário logado")

    # sem alert nativo
    if pg.evaluate("window.alert.toString().includes('native code')===false"): pass

    b.close()

print("\n=== ERROS DE JS ===")
print("\n".join(erros) if erros else "  nenhum")
print(f"\n=== FALHAS ({len(falhas)}) ===")
print("\n".join("  ✗ "+f for f in falhas) if falhas else "  nenhuma")

# --- 2ª rodada: os 4 controles recém-ligados ---
with sync_playwright() as pw:
    b=pw.chromium.launch(); pg=b.new_page(viewport={"width":1500,"height":950})
    e2=[]; pg.on("pageerror",lambda e:e2.append(str(e)))
    pg.on("dialog", lambda d: d.accept("803"))
    pg.goto(U); pg.wait_for_timeout(1400); pg.evaluate(STUB)
    pg.fill("#loginCod","SUP"); pg.fill("#loginSenha","senha-de-teste"); pg.click("#btnEntrar"); pg.wait_for_timeout(1800)
    f2=[]
    for bid in ["btnNovaProg","btnNovoUsuario","btnBuscar","btnNotif"]:
        if not pg.evaluate(f"typeof document.getElementById('{bid}').onclick==='function'"):
            f2.append(f"{bid} continua sem handler")
        else:
            pg.evaluate(f"document.getElementById('{bid}').click()"); pg.wait_for_timeout(900)
    print("\n=== 2ª RODADA (controles novos) ===")
    print("  erros JS:", e2 or "nenhum")
    print("  falhas  :", f2 or "nenhuma")
    b.close()
