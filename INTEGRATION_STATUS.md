# Estado da integração Forza Horizon + Pinyon Shift

Data do baseline: 2026-08-27.

## Objetivo

Esta árvore integra a base pública do Pinyon Shift com os avanços confirmados
durante o desenvolvimento local do Forza Horizon Recomp. A árvore jogável
anterior permanece preservada em `../ForzaHorizonRecompAtual` e não deve ser
alterada durante a validação desta integração.

## Base confirmada

- Pinyon Shift: commit `29b48259bd581b52852d2b5275a8208e0bd821ad`.
- ReXGlue 0.10: commit `f5337cdc947ff6d4c4196737e2c807a48f2a1fc2`.
- Série integrada: 38 patches aplicados em ordem; marcador em
  `.local/rexglue/.pinyon-patches.json`.
- Hash do conjunto aplicado:
  `6DEE283F28722FEFCF1561114A98490DE001CFDE505525DBC1AA9262F4641323`.
- Build Release inicial concluída com sucesso.
- Executável inicial SHA-256:
  `BF3FB721130BB4E024F0B704F868019ADC819722DBB869E3BAA716E9DEEEF16C`.

## Compatibilidade dos dados do jogo

Os três executáveis extraídos da árvore anterior coincidem exatamente com o
dump suportado pelo Pinyon:

| Arquivo | Tamanho | SHA-256 |
| --- | ---: | --- |
| `default.xex` | 20.856.832 | `DB40DF605ADE49A612B35A7A24C38F6004BCB17A88ED6B48288DE16DF9E3987C` |
| `SpeechFacade_default.xex` | 2.138.112 | `D54F6AAE6AE2FD6DA9B8C37D48F0A6BB295CAA18AD82D0D9DF66026141A41594` |
| `XMediaFacade_default.xex` | 2.662.400 | `ED285BEEFEAFCDC90CF64D6085D19C874E3F1E15072C12CDF9BA2237C88E2CE5` |

A imagem ISO completa não é usada pelo fluxo integrado porque seu hash não é
aceito pela política rígida do launcher, embora os XEX sejam idênticos.

## Decisão de merge

O código antigo não foi copiado indiscriminadamente. A comparação mostrou que
o Pinyon já cobre os endereços de função descobertos localmente e implementa
de forma sistêmica as correções de reentrada, continuations, interior-PC resume,
tail calls, thunks, save, I/O, XMA e geometria.

Não foram portados:

- o subsistema local de fibers e troca manual de `PPCContext`;
- o fallback preditivo de faixa de resolve que causou render em apenas parte da
  tela;
- instrumentações duplicadas de I/O, memória, áudio e draw;
- alterações geradas manualmente que agora são produzidas pelo codegen novo.

Foram preservados:

- todos os dados extraídos, em cópia independente;
- o save local pós-primeira corrida, copiado para `.local/preview/user`;
- os marcos e diagnósticos da árvore anterior como referência histórica;
- todos os endereços de função relevantes, agora gerados pela análise sistêmica
  do Pinyon. Entre eles estão `82DBCE80`, `8257F910`, `82DBD148` e `829CB048`.

## Como testar

Execute `RUN_WITH_LOG.bat` nesta pasta ou
`../run_forza_horizon_integrated.bat`.

O teste deve validar, nesta ordem:

1. inicialização e FMVs;
2. opções do menu principal;
3. carregamento do save existente;
4. renderização completa do mundo;
5. controles e desempenho no gameplay;
6. entrada e conclusão de evento;
7. salvamento, tela pós-evento e novo carregamento.

Não use o save da árvore antiga diretamente. A integração trabalha somente na
cópia sob `.local/preview/user`.

## Logs para análise

- Runtime: `.local/preview/logs/runtime.log`.
- Performance: `.local/preview/logs/performance.csv`.
- Relatórios de crash: `.local/preview/reports`.
- Dumps: `.local/preview/crashes`.
- Proveniência da build: `.local/build.json`.

Ao ocorrer um crash, não selecione Ignorar. Encerre pelo fluxo normal do crash
handler para preservar o primeiro erro e o bundle correspondente.

## Próximo marco

O executável está compilado, mas o comportamento visual e a progressão ainda
dependem de teste manual. Nenhuma correção antiga adicional deve ser portada
antes desse teste A/B. O primeiro desvio observado deve ser analisado contra o
log e contra a árvore anterior, mantendo uma alteração por vez.

## Experimento gráfico: sombra sob os veículos

Em 27 de agosto de 2026 foi adicionado o patch `0038`, baseado na causa
identificada pelo Xenia Canary PR 1158. O artefato não é primariamente um erro
de depth bias: comparações do jogo recebem do host mais precisão do que o Xenos
expunha ao amostrar texturas normalizadas.

Como este ReXGlue antecede a infraestrutura completa de proveniência de
depth-resolve do Xenia, o primeiro teste usa uma variante conservadora para o
projeto: amostras normalizadas de formatos fixed-point, somente com filtros
point explícitos, são arredondadas para 16 bits fracionários. Formatos float,
filtros lineares e o caminho Vulkan não são alterados.

A build Release com 38 patches concluiu com sucesso. O teste A/B deve observar
principalmente a faixa ou sombra listrada sob o carro e também procurar
regressões em HUD, mapas, transparências, iluminação e motion blur. Se o efeito
for confirmado, o próximo passo é portar a proveniência de depth-resolve para
restringir ainda mais a correção antes de sugeri-la upstream.
