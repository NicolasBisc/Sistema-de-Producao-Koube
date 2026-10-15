-- ============================================================
-- TREINAMENTOS 2026 (base: planilha Treinamentos_2026.xlsx)
-- 13 treinamentos do cronograma anual
-- ============================================================

DELETE FROM treinamentos_agenda;
DELETE FROM treinamentos;

INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Procedimento produção','Interno','Joana','','','[1, 4, 8]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Procedimento rotulagem','Interno','Joana','','','[1, 4, 8]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Identificação de Lote e data','Interno','Joana','','','[1, 4, 8]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Ponto crítico de controle','Interno','Joana','','','[3, 8]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Manuseio em redes de gás','Interno (Manutenção)','Viviane','','','[4]'::jsonb,'Davi',TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Reciclagem treinamento envase gás','Interno (Manutenção)','Viviane','','','[]'::jsonb,'Davi',TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Reciclagem treinamento sleeve','Externo / Interno','Viviane','','','[7]'::jsonb,'Davi',TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Comunicação e liderança','Externo / Interno','Hugo','','','[1, 7]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Organização 5S','Externo / Interno','Lauro','','','[2, 3, 5, 9]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Treinamento sobre produtos','Interno','Mirela','','','[1, 2, 3, 8]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'EPIS','Externo / Interno','Talita','','','[1, 4, 7, 10]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Produtos não conforme','Interno','Mateus','','','[2, 3, 5, 9]'::jsonb,'[]'::jsonb,TRUE);
INSERT INTO treinamentos (ano,nome,tipo,objetivo,publico,responsavel,meses,feitos,ativo) VALUES (2026,'Política da qualidade, missão, visão e valores','Interno','SGQ e Produção','','','[1, 4, 8]'::jsonb,'[]'::jsonb,TRUE);

-- FERIADOS NACIONAIS 2026 (ajuste os municipais conforme necessário)
INSERT INTO feriados (data,descricao) VALUES ('2026-01-01','Confraternização Universal') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-02-16','Carnaval') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-02-17','Carnaval') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-04-03','Sexta-feira Santa') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-04-21','Tiradentes') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-05-01','Dia do Trabalho') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-06-04','Corpus Christi') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-09-07','Independência') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-10-12','Nossa Senhora Aparecida') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-11-02','Finados') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-11-15','Proclamação da República') ON CONFLICT (data) DO NOTHING;
INSERT INTO feriados (data,descricao) VALUES ('2026-12-25','Natal') ON CONFLICT (data) DO NOTHING;