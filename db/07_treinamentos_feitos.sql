-- ============================================================
-- Corrige os treinamentos: marca como REALIZADOS os meses que
-- já passaram (janeiro a julho/2026). Agosto em diante fica
-- pendente.
-- ============================================================
BEGIN;

UPDATE treinamentos
   SET feitos = COALESCE(
         (SELECT jsonb_agg(m ORDER BY (m#>>'{}')::int)
            FROM jsonb_array_elements(meses) AS m
           WHERE (m#>>'{}')::int < 8),
         '[]'::jsonb)
 WHERE ano = 2026;

SELECT nome, meses, feitos FROM treinamentos WHERE ano=2026 ORDER BY nome;

COMMIT;
