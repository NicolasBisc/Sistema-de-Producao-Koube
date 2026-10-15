-- ============================================================
-- Troca do código de acesso do Simone: SPV -> SUP
-- Seguro rodar mais de uma vez.
-- ============================================================
BEGIN;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM usuarios WHERE codigo='SUP' AND nome<>'Simone') THEN
    RAISE EXCEPTION 'Já existe outro usuário com o código SUP. Abortado.';
  END IF;
END $$;

UPDATE usuarios SET codigo='SUP' WHERE codigo='SPV' AND nome='Simone';

SELECT codigo, nome, nivel, acesso_producao, acesso_manutencao, acesso_supervisao
  FROM usuarios WHERE nivel='admin' ORDER BY codigo;

COMMIT;
