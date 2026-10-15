-- ============================================================
-- 09 — Sincroniza as preventivas com o REG 7002 atual
--
-- O sistema foi carregado em 07/08/2026 com execuções até 05/08.
-- A planilha já tem execuções até 01/09/2026 (73 registros novos),
-- por isso o sistema mostrava como atrasado o que já foi feito.
--
-- Casamento por equipamento + sequência (chave única nas 255).
-- Fonte: REG 7002 - Lista de Serviços, extraída em 08/09/2026.
-- ============================================================
BEGIN;

-- guarda o estado anterior, para poder comparar depois
CREATE TEMP TABLE _antes AS
  SELECT p.id, p.ultima_acao FROM preventivas p;

UPDATE preventivas p SET ultima_acao='2026-08-13', numero_os=808,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADOR INKJET 03' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-13', numero_os=808,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADOR INKJET 03' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-13', numero_os=808,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADOR INKJET 03' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-13', numero_os=808,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADOR INKJET 03' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-31', numero_os=812,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-31', numero_os=812,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-31', numero_os=812,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-31', numero_os=812,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=811,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=811,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=811,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=811,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-05', numero_os=733,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-05', numero_os=733,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-05', numero_os=733,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=773,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=810,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=810,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=810,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=810,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-10', numero_os=809,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-10', numero_os=809,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-10', numero_os=809,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-10', numero_os=809,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=804,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 2' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=805,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=805,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=805,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-18', numero_os=805,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-19', numero_os=806,
       periodicidade_dias=30
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=801,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 2' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-13', numero_os=793,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CAIXA DE CONTEÇÃO RESIDUOS' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=776,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=776,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=776,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=776,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=776,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=734,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=734,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=734,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=734,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=734,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=735,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=735,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=735,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=735,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-05-15', numero_os=735,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=791,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 2' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-05-27', numero_os=754,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 3' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-05-27', numero_os=754,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 3' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-05-27', numero_os=754,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 3' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-05-27', numero_os=754,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 3' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-05-27', numero_os=754,
       periodicidade_dias=120
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='REATOR 3' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=780,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE AGUA ENVASE 01' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=780,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE AGUA ENVASE 01' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-28', numero_os=800,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ELEVADOR DE CARGA 1' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=771,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 5' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=771,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 5' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=771,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 5' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=771,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 5' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=771,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 5' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=794,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 1' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-05-14', numero_os=722,
       periodicidade_dias=465
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADOR INKJET 03' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-04-28', numero_os=726,
       periodicidade_dias=465
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 01' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=779,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=779,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=795,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='COMPRESSOR PARAFUSO TB 30' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=799,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='GERADOR' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=799,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='GERADOR' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=799,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='GERADOR' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=799,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='GERADOR' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=799,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='GERADOR' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=778,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=778,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=778,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-06', numero_os=775,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-06', numero_os=775,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-15', numero_os=786,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MAQUINA DE SELAR CAIXA 3' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-08', numero_os=782,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 04' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=784,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 02' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-06', numero_os=774,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-07', numero_os=810,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=773,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=773,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 3' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=777,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=778,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-22', numero_os=796,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 01' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=772,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=772,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE ENVASE 4' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-30', numero_os=802,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-23', numero_os=792,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='CALDEIRA' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-20', numero_os=789,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE 20L' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-24', numero_os=797,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 2' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=8;
UPDATE preventivas p SET ultima_acao='2026-07-21', numero_os=790,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 01' AND p.sequencia=9;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-31', numero_os=798,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 1' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=8;
UPDATE preventivas p SET ultima_acao='2026-07-17', numero_os=788,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ENVASE AUTOMATICO 02' AND p.sequencia=9;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=777,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=777,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-10', numero_os=777,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TANQUE DE MATÉRIA PRIMA 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-07', numero_os=783,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-09-01', numero_os=816,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELÉTRICA AMARELA' AND p.sequencia=8;
UPDATE preventivas p SET ultima_acao='2026-07-30', numero_os=802,
       periodicidade_dias=90
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=8;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-07-09', numero_os=781,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='MÁQUINA DE AEROSSOL 1' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-26', numero_os=813,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='TUNEL SLEEVE' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=814,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='APLICADORA SLEEVE' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=7;
UPDATE preventivas p SET ultima_acao='2026-08-27', numero_os=815,
       periodicidade_dias=60
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='EMPILHADEIRA ELETRICA AZUL' AND p.sequencia=8;
UPDATE preventivas p SET ultima_acao='2026-05-22', numero_os=750,
       periodicidade_dias=180
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SELADORA DE TAMPAS 03' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-08-04', numero_os=803,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='SPDA' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-02', numero_os=787,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='INFRAESTRUTURA PREDIAL' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2026-07-02', numero_os=787,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='INFRAESTRUTURA PREDIAL' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2026-07-02', numero_os=787,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='INFRAESTRUTURA PREDIAL' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2026-07-02', numero_os=787,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='INFRAESTRUTURA PREDIAL' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2026-08-24', numero_os=807,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DATADORA INKJET 02' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2026-01-16', numero_os=641,
       periodicidade_dias=365
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='FOSSAS SÉPTICAS' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=1;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=2;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=3;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=4;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2025-10-30', numero_os=602,
       periodicidade_dias=360
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='ROTULADORA 3' AND p.sequencia=6;
UPDATE preventivas p SET ultima_acao='2024-12-05', numero_os=351,
       periodicidade_dias=900
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=5;
UPDATE preventivas p SET ultima_acao='2025-09-01', numero_os=547,
       periodicidade_dias=900
  FROM equipamentos e
 WHERE p.equipamento_id=e.id AND e.nome='DESMINERALIZADORA DE ÁGUA' AND p.sequencia=6;

-- quantas mudaram de fato
SELECT count(*) AS "execuções atualizadas"
  FROM preventivas p JOIN _antes a ON a.id=p.id
 WHERE COALESCE(a.ultima_acao,'1900-01-01') <> COALESCE(p.ultima_acao,'1900-01-01');

-- situação depois da sincronização
SELECT
  count(*) FILTER (WHERE ultima_acao + periodicidade_dias * INTERVAL '1 day' <  CURRENT_DATE) AS atrasadas,
  count(*) FILTER (WHERE ultima_acao + periodicidade_dias * INTERVAL '1 day' >= CURRENT_DATE
                     AND ultima_acao + periodicidade_dias * INTERVAL '1 day' <  CURRENT_DATE + 5) AS "vencem em 5 dias",
  count(*) FILTER (WHERE ultima_acao + periodicidade_dias * INTERVAL '1 day' >= CURRENT_DATE + 5) AS "em dia",
  count(*) AS total
FROM preventivas WHERE ativo;

COMMIT;