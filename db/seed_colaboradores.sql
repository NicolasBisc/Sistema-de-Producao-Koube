-- COLABORADORES DA PRODUÇÃO (21 pessoas, todas com foto conferida)
-- Manutenção entra na 'Equipe Manutenção'; demais sem linha definida
-- (a gestão distribui pelo Perfil → Linha/Equipe).

INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('DÉBORA LEAL','Op. Produção A (Manipulação)','Manipulação',NULL,'2016-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LAURO ASSIS','Op. Produção C (Envase)','Envase',NULL,'2019-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LAURO MACEDO','Op. Produção B (Manipulação)','Manipulação',NULL,'2019-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('ZECA LEAL','Supervisor de Produção','Gestão',NULL,'2020-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LEONEL FARIAS','Mantenedor Geral A (Manutenção)','Manutenção',(SELECT id FROM linhas_producao WHERE nome='Equipe Manutenção'),'2020-05-21','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LEONEL FARIAS','Op. Produção B (Envase)','Envase',NULL,'2021-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('CELINA BRANDÃO','Op. Produção B (Rotulagem)','Rotulagem',NULL,'2022-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('ELIAS MOREIRA','Op. Produção B (Envase)','Envase',NULL,'2023-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LEONEL TAVARES','Mantenedor Geral B (Manutenção)','Manutenção',(SELECT id FROM linhas_producao WHERE nome='Equipe Manutenção'),'2024-06-17','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('ULISSES NOGUEIRA','Op. Produção C (Envase)','Envase',NULL,'2024-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('DÉBORA DANTAS','Auxiliar de Produção (Envase)','Envase',NULL,'2024-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LAURO FONTES','Auxiliar de Produção (Envase)','Envase',NULL,'2026-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('VIVIANE REZENDE','Auxiliar de Produção (Rotulagem)','Rotulagem',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('CELINA ASSIS','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('DAVI DANTAS','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('PRISCILA LEAL','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('EDSON REZENDE','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('ELIAS REZENDE','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('ULISSES CORREIA','Auxiliar de Produção (Envase)','Envase',NULL,'2025-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('LÍVIA TAVARES','Aprendiz','Gestão',NULL,'2026-01-01','','ativo');
INSERT INTO colaboradores (nome,cargo,setor,linha_id,data_admissao,foto,status) VALUES ('HUGO XAVIER','Auxiliar de Produção (Envase)','Envase',NULL,'2026-01-01','','ativo');