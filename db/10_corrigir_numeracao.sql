-- ============================================================
-- 10 — Corrige a numeração e importa as 12 OSM que faltavam
--
-- O SQL 08 colocou as 6 corretivas novas em 805..810, mas a
-- planilha REG 7005 já usa 805..816 para preventivas de
-- agosto/setembro/2026. A numeração da planilha é a oficial.
--
--   corretivas novas : 805..810  ->  817..822
--   preventivas      : entram com os números 805..816 da planilha
--
-- Fonte: REG 7005 - Registro OSM, extraída em 08/09/2026.
-- ============================================================
BEGIN;

-- 1) tira as corretivas da faixa disputada (sobe todas de uma vez,
--    em ordem decrescente para não colidir entre si)
UPDATE ordens_servico SET numero = numero + 12
 WHERE numero BETWEEN 805 AND 810
   AND tipo = 'Corretiva'
   AND pendencias LIKE '%Planilha Corretiva 2026%';

-- confere que a faixa 805..816 está livre
DO $$
DECLARE n INT;
BEGIN
  SELECT count(*) INTO n FROM ordens_servico WHERE numero BETWEEN 805 AND 816;
  IF n > 0 THEN RAISE EXCEPTION 'A faixa 805..816 ainda tem % registro(s). Abortado.', n; END IF;
END $$;

-- 2) as 12 preventivas que a planilha tem e o banco nunca recebeu

INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (805,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em COMPRESSOR PISTÃO VERMELHO',
  '2026-08-18','13:00','Viviane',
  'Feito inspeção nos pontos previstos da preventiva, feito uma melhoria em nos cabos de energia colocado um quadro de distribuição. Tudo funcionando corretamente','2026-08-18','15:00',
  'Concluído','2:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (806,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em COMPRESSOR PARAFUSO TB 30',
  '2026-08-19','08:30','Viviane',
  'Feito inspeção nos pontos previstos da preventiva. Verificado histórico de falhas e quantidade de horas: filtro de óleo 237horas, filtro separador 237 horas e filtro de ar 237 horas','2026-08-19','11:00',
  'Concluído','2:30:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (807,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em DATADORA INKJET 02',
  '2026-08-24','09:00','Viviane',
  'Feito inspeção nos pontos previstos da preventiva. Feito limpeza no equipamento','2026-08-24','10:40',
  'Concluído','1:40:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (808,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em DATADORA INKJET 03',
  '2026-08-13','08:50','Viviane',
  'Feito inspeção nos pontos previstos da preventiva. Feito limpeza no equipamento','2026-08-13','10:00',
  'Concluído','1:10:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (809,'Preventiva','Produção','Jéssica','Fazer manutenção preventiva em MÁQUINA DE ENVASE 4',
  '2026-08-10','08:30','Viviane',
  'Equipamento foi revisado em todos os pontos de checagem','2026-08-10','10:50',
  'Concluído','2:20:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (810,'Preventiva','Produção','Jéssica','Fazer manutenção preventiva em MÁQUINA DE ENVASE 2',
  '2026-08-07','09:00','Viviane',
  'Foi trocado vedações, potenciômetro, limpeza interna do equipamento, arrumação dos cabos, ajuste no timer para nível centesimal para melhorar precisão e programado modo contador para acompanhar produção, cerificado correia das esteiras: feito tensionamento, completado nível de óleo do redutor','2026-08-07','11:30',
  'Concluído','2:30:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (811,'Preventiva','Produção','Jéssica','Fazer manutenção preventiva em MÁQUINA DE ENVASE 1',
  '2026-08-07','08:00','Viviane',
  'Foi trocado vedações, potenciômetro, limpeza interna do equipamento, arrumação dos cabos, ajuste no timer para nível centesimal para melhorar precisão e programado modo contador para acompanhar produção, cerificado correia das esteiras: feito tensionamento, completado nível de óleo do redutor','2026-08-07','11:20',
  'Concluído','3:20:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (812,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em DESMINERALIZADORA DE ÁGUA',
  '2026-08-31','09:20','Viviane',
  'Verificado 2 filtros de saída em PP 25 micras, trocado somente 1. Checado vazamentos, bombas e instalação elétrica','2026-08-31','11:20',
  'Concluído','2:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (813,'Preventiva','Produção','Jéssica','Fazer Manutenção Preventiva Programada em TUNEL SLEEVE',
  '2026-08-26','08:30','Viviane',
  'foi feito manutenção preventiva em caixa reservatória de água também foi ajustado boia, também foi consertado os cabos elétricos','2026-08-26','10:50',
  'Concluído','2:20:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (814,'Preventiva','Produção','Jéssica','Fazer manutenção preventiva em APLICADORA SLEEVE',
  '2026-08-27','10:00','Viviane',
  'feita checagem em todos os puntos previsto em da preventiva trocada faca de corte feita uma limpeza em todas as rodana','2026-08-27','12:00',
  'Concluído','2:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (815,'Preventiva','Expedição','Sabrina','Fazer manutenção preventiva em EMPILHADEIRA ELÉTRICA Azul',
  '2026-08-27','08:00','Viviane',
  'Durante a manutenção preventiva, foi realizada a desmontagem do conjunto de transmissão para inspeção, sendo identificado rompimento da engrenagem interna. O componente danificado foi substituído e, posteriormente, efetuada a troca do óleo da transmissão, com montagem e verificação do conjunto. Após os testes funcionais, não foram observadas anormalidades, deixando o equipamento em condições adequadas e seguras para operação','2026-08-27','18:00',
  'Concluído','10:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,tempo_execucao)
 VALUES (816,'Preventiva','Expedição','Sabrina','Fazer Manutenção Preventiva Programada em EMPILHADEIRA ELÉTRICA AMARELA',
  '2026-09-01','08:00','Viviane',
  'Durante a manutenção preventiva da empilhadeira elétrica, foram realizadas as inspeções previstas no plano de manutenção, abrangendo bateria, correntes, sistema hidráulico, transmissão, garfos, rodas, comandos e carregador. Após a execução da preventiva, foi necessária a desmontagem do conjunto de transmissão para inspeção técnica e avaliação das condições internas dos componentes. Durante a intervenção, foi identificado desgaste no rolamento giratório da transmissão, sendo realizada sua substituição, juntamente com a verificação dos demais componentes do conjunto. Também foi constatado dano no rolamento da roda de apoio, sendo efetuada a substituição do componente. Após a montagem, foram realizados testes funcionais e operacionais, verificando folgas, ruídos, vibrações e o correto funcionamento da transmissão e do sistema de deslocamento, deixando o equipamento em condições adequadas para operação.','2026-09-01','18:00',
  'Concluído','10:00:00')
 ON CONFLICT (numero) DO NOTHING;

-- 3) sequência acompanha o maior número
SELECT setval('seq_osm', (SELECT MAX(numero) FROM ordens_servico));

-- conferência
SELECT tipo, count(*) FROM ordens_servico GROUP BY tipo ORDER BY count(*) DESC;
SELECT 'total' AS r, count(*) FROM ordens_servico;
SELECT numero, tipo, data_abertura FROM ordens_servico
 WHERE numero BETWEEN 805 AND 822 ORDER BY numero;

COMMIT;