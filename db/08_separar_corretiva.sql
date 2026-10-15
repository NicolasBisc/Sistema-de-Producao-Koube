-- ============================================================
-- 08 — Separação preventiva x corretiva
--
-- 1) remove os 28 registros que não são preventiva nem corretiva
--    (Instalação, Externo, Outros, Melhoria) — pedido do Simone
-- 2) normaliza maiúsculas/espaços do campo tipo
-- 3) importa as 6 corretivas da planilha nova (junho/2026)
--    Numeração: entram na sequência geral como 805..810.
--    O nº original da planilha fica registrado em observacoes.
-- ============================================================
BEGIN;

-- 1) descartar o que não é preventiva nem corretiva
DELETE FROM ordens_servico
 WHERE btrim(initcap(tipo)) IN ('Instalação','Instalacao','Externo','Outros','Melhoria');

-- 2) normalizar o tipo (havia 'corretiva' e 'preditiva ' minúsculos/com espaço)
UPDATE ordens_servico SET tipo = btrim(initcap(tipo))
 WHERE tipo <> btrim(initcap(tipo));

-- 3) corretivas da planilha nova

INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (805,'Corretiva','Manipulação','Raquel','Escada com os rodizios estourados',
  '2026-06-22','08:30','Sabrina',
  'Foi trocado todos os rodizios da escada por um maior. Já que estava com um rodizio de 1 polegada e foi colocada uma maior de 3 polegadas','2026-06-22','15:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 1','6:30:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (806,'Corretiva','Produção','Edson','Problema em nos bicos da máquina 3 do perfect',
  '2026-06-22','11:00','Viviane',
  'Foi identificado um desgaste na vedação do eixo do pistão que fecha a saída do bico. Como medida paliativa para não interromper a produção, um dos bicos foi removido e colocado so um após a substituição das peças necessárias, os dois bicos foram montados, regulados, testados e a máquina foi liberada.','2026-06-22','15:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 2','4:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (807,'Corretiva','Produção','Edson','Vazamento na bomba que injeta o purogas',
  '2026-06-24','10:00','Sabrina',
  'Foi constatado vazamento na bomba, após análise identificou-se rompimento da gaxeta de retenção de fluído. Foi realizada a substituição do componente, seguida pelos ajustes de alinhamento e torque necessarios. O equipamento foi testado após validação, liberado para a produção','2026-06-24','13:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 3','3:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (808,'Corretiva','Rotulagem','Ulisses','Problema na tomada da máquina de sleeve com cheiro de queimado',
  '2026-06-24','09:00','Sabrina',
  'Realizou-se uma analise para indentificar a causa da falha no equipamento. Inicialmente, efetuado o desligamento do disjuntor da maquina de sleeve por motivos de segurança, visto que a tomada de alimentação apresentava condutores danificados por sobreaquecimento (derretidos). tambem o plugue estava defeituoso, sendo necessaria a substituição do componente apos feita a troca, tambem foi identificado cabos frouxas, no painel eletrico central, foi reaperto adequado: apos a conclusão das intervenções o disjuntor foi religado e executou-se o monitoramento e a medição dos parâmetros eletricos. apos a verificações a maquina foi liberada para produção.','2026-06-24','14:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 4','5:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (809,'Corretiva','Produção','Edson','Problema com regulagem da máquina de envase 01',
  '2026-06-24','09:00','Viviane',
  'Foi feito uma análise para identificar o problema após a análise foi diagnosticado problema no potenciômentro já que estava com defeito na regulagem da máquina de envase 01. Foi realizado regulagens e testado, assim liberado para a produção','2026-06-24','14:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 5','5:00:00')
 ON CONFLICT (numero) DO NOTHING;
INSERT INTO ordens_servico
 (numero,tipo,area,solicitante,solicitacao,data_abertura,hora_abertura,tecnico,
  descricao_servico,data_conclusao,hora_conclusao,status,pendencias,tempo_execucao)
 VALUES (810,'Corretiva','Produção','Edson','Problema no recrave do aerosol',
  '2026-06-24','09:00','Viviane',
  'Realizada inspeção no recrave na maquina de aerosol 1 Foi realizada inspeção no sistema de recrave da máquina de aerossol após relato de falha no processo. Durante a análise, foi identificado que a arruela (ring) de pressão da pinça de recrave estava quebrada, impossibilitando o funcionamento correto do conjunto. A peça danificada foi removida para avaliação e constatou-se a necessidade de substituição. O orçamento da peça foi solicitado ao fornecedor e a compra encontra-se aguardando aprovação/entrega. Enquanto a peça não chega, a máquina permanece parada ou, quando necessário, é realizada a troca do conjunto de recrave com outra máquina para manter a continuidade da produção. Após o recebimento da peça, será efetuada a substituição, regulagem do sistema, testes de funcionamento e liberação definitiva do equipamento para operação.','2026-06-24','14:00',
  'Concluído','Planilha Corretiva 2026, OSM original nº 6','5:00:00')
 ON CONFLICT (numero) DO NOTHING;

-- 4) sequência acompanha o maior número
SELECT setval('seq_osm', (SELECT MAX(numero) FROM ordens_servico));

-- conferência
SELECT tipo, count(*) FROM ordens_servico GROUP BY tipo ORDER BY count(*) DESC;
SELECT 'total' AS r, count(*) FROM ordens_servico;

COMMIT;