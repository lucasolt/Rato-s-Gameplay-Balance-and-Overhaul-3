-- =================================================================================================
-- PROPOSTA DE RELIABILITY  --  escala 62-95 para a formula nova
--
-- NAO carrega: esta fora de `Code/` e nao esta registrado no metadata/items de proposito.
-- `PATCH_GBO_weapons.lua` e gerado pelo editor, entao use isto como REFERENCIA para ajustar por la,
-- ou rode como script avulso para testar em sessao viva.
--
-- Coluna "hoje" = valor medido no preset global vivo (2026-08-27), nao no `InventoryItemDefs` --
-- essa tabela esta desatualizada e nao recebe o `PATCH_GBO_weapons`.
--
-- Delta grande = arma cujo valor antigo era compensacao de TAXA DE DESGASTE, nao descricao de
-- confiabilidade. Ver o cabecalho de `Code/__JamParams.lua`.
--
-- -------------------------------------------------------------------------------------------------
-- CHANCE DE JAM RESULTANTE (por ataque), com JamSlopePct = 25 e teto 20
--
--                 JamRelRef = 40              JamRelRef = 60  <-- AJUSTE ATUAL
--   Reliability   Cond 60 / 40 / 20           Cond 60 / 40 / 20
--       95           1  /  2  /  3               1  /  1  /  2
--       93           1  /  3  /  4               1  /  2  /  2
--       90           2  /  4  /  5               2  /  3  /  3
--       85           4  /  6  /  8               3  /  4  /  5
--       78           6  /  8  / 11               4  /  6  /  7
--       72           7  / 11  / 14               5  /  7  /  9
--       65           9  / 13  / 18               6  /  9  / 12
--       62          10  / 14  / 19               6  / 10  / 13
--
-- Com JamRelRef = 60 a escala fica ~40% mais suave e o teto de 20 nunca e alcancado (maximo ~13%).
-- A ORDEM entre as armas nao muda -- so a intensidade. Se a sensacao ficar branda demais, o caminho
-- e baixar JamRelRef (50 -> meio termo, 40 -> a proposta original), nao mexer nos valores abaixo.
-- =================================================================================================

-- ---- Kalashnikov / MG robusta -- folga de tolerancia, tolera sujeira ---------------------------
AK47.Reliability = 91--95           -- hoje 95   (inalterado)
AK74.Reliability = 90--95           -- hoje 95   (inalterado)
RPK74.Reliability = 89--94          -- hoje 95
AKSU.Reliability = 88 
PapovkaSKS_1.Reliability = 86--93   -- hoje 76   <<< +17  irma da AK em robustez; valor antigo era
                                --                    compensacao por ser tiro unico
MG58.Reliability = 88           -- hoje 95
MG42.Reliability = 89           -- hoje 90
HK21.Reliability = 87           -- hoje 90

-- ---- Ferrolho / revolver / muito confiavel -----------------------------------------------------
Gewehr98.Reliability = 98--90       -- hoje 25   <<< +65  MAIOR INVERSAO. Ferrolho Mauser e dos
                                --                    mecanismos mais confiaveis que existem; o 25
                                --                    era puro artefato do desgaste por bala
M24Sniper.Reliability = 95--      -- hoje 44   <<< +44  ferrolho moderno, camara justa (por isso 88 e
                                --                    nao 92)
Winchester1894.Reliability = 80--90 -- hoje 95   alavanca simples
Winchester_Quest.Reliability = 80--90
ColtAnaconda.Reliability = 90--91   -- hoje 85   revolver: sem ciclo automatico para falhar
ColtPeacemaker.Reliability = 93 -- hoje 85
TexRevolver.Reliability = 93    -- hoje 85
AA12.Reliability = 84           -- hoje 80   projetada para confiabilidade
FNMinimi.Reliability = 85       -- hoje 85
BrowningM2HMG.Reliability = 90  -- hoje 80   M2 e lendariamente confiavel

-- ---- Boa -- bem construidas, tolerancia media --------------------------------------------------
Galil.Reliability = 87          -- hoje 83   base AK
Galil_FlagHill.Reliability = 87 -- hoje 77
AUG.Reliability = 85            -- hoje 85   (inalterado)
MP5.Reliability = 85            -- hoje 85   (inalterado)
MP5K.Reliability = 85           -- hoje 85   (inalterado)
          -- hoje 80
G36.Reliability = 82            -- hoje 75

-- ---- Padrao -- impingimento direto, sensivel a fuligem -----------------------------------------
Glock18.Reliability = 81        -- hoje 80
M14SAW.Reliability = 80         -- hoje 80   (inalterado)
M14SAW_AUTO.Reliability = 80    -- hoje 80
UZI.Reliability = 79            -- hoje 75
LionRoar.Reliability = 79       -- hoje 80
GoldenGun.Reliability = 79      -- hoje 80
M16A2.Reliability = 78          -- hoje 80
AR15.Reliability = 81--78           -- hoje 80
M4Commando.Reliability = 78     -- hoje 80
MP40.Reliability = 77           -- hoje 70
Bereta92.Reliability = 77       -- hoje 70
FAMAS.Reliability = 76          -- hoje 70

-- ---- Sensivel -- tolerancias apertadas ou acao delicada ----------------------------------------
DragunovSVD.Reliability = 75    -- hoje 50   <<< +25  confiavel na pratica, mas e rifle de precisao
HiPower.Reliability = 74        -- hoje 50   <<< +24
M41Shotgun.Reliability = 73     -- hoje 71
FNFAL.Reliability = 72          -- hoje 65   tolerancias apertadas, sensivel a areia -- o unico
                                --           valor herdado que ja descrevia a realidade
DoubleBarrelShotgun.Reliability = 99 -- hoje 50

-- ---- Exigente -- match rifle, municao-sensivel, recuo curto ------------------------------------
PSG1.Reliability = 68           -- hoje 53   camara de competicao
BarretM82.Reliability = 66      -- hoje 10   <<< +55  pesada e cara de manter, mas nao 10x pior que
                                --                    uma AK -- e esse era o problema de leitura
                                --                    para o jogador
DesertEagle.Reliability = 63    -- hoje 40   famosa por exigir carga plena
Auto5.Reliability = 80          -- hoje 20   recuo curto, anel de friccao precisa estar certo
Auto5_quest.Reliability = 80   -- hoje 20

-- =================================================================================================
-- NAO MEXER: itens sem ciclo mecanico ja estao em 100 e nunca emperram
--   facas, machetes, granadas, explosivos, veiculos, Unarmed, FlareStick, GlowStick
-- Deficit 0 => chance 0 na formula nova, sem precisar de caso especial.
--
-- ARMAS NAO COBERTAS AQUI: as do CUAE e outros mods de arma. Como a formula le `Reliability` da
-- property, elas continuam funcionando -- mas com os valores originais, que foram calibrados para o
-- significado ANTIGO (taxa de desgaste). Se alguma delas parecer emperrar demais ou de menos, e
-- provavelmente isso, nao a formula.
-- =================================================================================================
