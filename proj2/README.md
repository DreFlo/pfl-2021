# Shi - T4G4

||||
|-|-|-|
| André Flores | 201907001 | 50% |
| Sara Marinha | 201906805 | 50% |

## Instalation and Execution

incluir todos os passos necessários para correta execução do jogo em ambientes Linux e Windows (para além da instalação do SICStus Prolog 4.7);

## Game Description

<p>Shi is a two-player game played in an 8x8 board, each player starting with 8 pieces in a line on opposite sides of the board. The two players' sides are called <em>Ninja</em> and <em>Samurai</em>, the <em>Samurai</em> side always gets the first move of the game.</p>
<p>The goal of the game is to capture the other player's pieces until they only have 4, at which point they will lose. Each piece can move in any direction regardless of the distance as long as there isn't a piece already at the target position. To capture an opponent's piece a player must "jump" over another of their pieces that is colinear with the attacking and target piece and in between them, pieces are only able to jump when attacking.</p>
<p><a href=https://boardgamegeek.com/boardgame/319861/shi>Source</a></p>

## Game Logic
descrever (não basta copiar código fonte) o projeto e implementação da lógica do jogo em Prolog. O predicado de início de jogo deve ser play/0. Esta secção deve ter informação sobre os seguintes tópicos (até 2400 palavras no total):

### Internal representation of the game state 

indicação de como representam o estado do jogo, incluindo tabuleiro (tipicamente usando lista de listas com diferentes átomos para as peças), jogador atual, e eventualmente peças capturadas e/ou ainda por jogar, ou outras informações que possam ser necessárias (dependendo do jogo). Deve incluir exemplos da representação em Prolog de estados de jogo inicial, intermédio e final, e indicação do significado de cada átomo (ie., como representam as diferentes peças).

### Game state display

descrição da implementação do predicado de visualização do estado de jogo. Pode incluir informação sobre o sistema de menus criado, assim como interação com o utilizador, incluindo formas de validação de entrada. O predicado de visualização deverá chamar-se display_game(+GameState), recebendo o estado de jogo atual (que inclui o jogador que efetuará a próxima jogada). Serão valorizadas visualizações apelativas e intuitivas. Serão também valorizadas representações de estado de jogo e implementação de predicados de visualização flexíveis, por exemplo, funcionando para qualquer tamanho de tabuleiro, usando um predicado initial_state(+Size, -GameState) que recebe o tamanho do tabuleiro como argumento e devolve o estado inicial do jogo.

### Move Piece

Validação e execução de uma jogada, obtendo o novo estado do jogo. O predicado deve chamar-se move(+GameState, +Move, -NewGameState).

### Game over

Verificação da situação de fim do jogo, com identificação do vencedor. O predicado deve chamar-se game_over(+GameState, -Winner).

### List of valid moves

Obtenção de lista com jogadas possíveis. O predicado deve chamar-se valid_moves(+GameState, -ListOfMoves).

### Avaliation of game state

Forma(s) de avaliação do estado do jogo do ponto de vista de um jogador, quantificada através do predicado value(+GameState, +Player, -Value).

### AI implementation

Escolha da jogada a efetuar pelo computador, dependendo do nível de dificuldade, através de um predicado choose_move(+GameState, +Level, -Move). O nível 1 deverá devolver uma jogada válida aleatória. O nível 2 deverá devolver a melhor jogada no momento (algoritmo míope), tendo em conta a avaliação do estado de jogo.

## Conclusion

Conclusões do trabalho, incluindo limitações do trabalho desenvolvido (known issues), assim como possíveis melhorias identificadas (roadmap). (até 250 palavras)

## Bibliography

[Original description of Shi](https://boardgamegeek.com/boardgame/319861/shi)