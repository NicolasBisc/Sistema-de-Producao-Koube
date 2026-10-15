-- Dá acesso TOTAL ao Simone (mesmo nível do Bianca)
UPDATE usuarios
   SET nivel = 'admin',
       acesso_producao = TRUE,
       acesso_manutencao = TRUE,
       acesso_supervisao = TRUE,
       ativo = TRUE
 WHERE codigo = 'SPV';

-- conferência
SELECT codigo, nome, nivel, acesso_producao, acesso_manutencao, acesso_supervisao, senha_temporaria
  FROM usuarios ORDER BY codigo;
