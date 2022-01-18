/**
piece(Type, X, Y)

Type - s - samurai
     - n - ninja
     - b - blank

0 <= X <= 7

0 <= Y <= 7
*/
:- use_module(library(lists)).
:- use_module(library(random)).

% read_number(-X)
read_number(X):-
     read_number_aux(X, false,0).

read_number_aux(X,_,Acc):- 
     get_code(C),
     C >= 48,
     C =< 57,
     !,
     Acc1 is 10*Acc + (C - 48),
     read_number_aux(X, true, Acc1).
read_number_aux(X, true, X).

% read_until_between(+Min, +Max, -Value)
read_until_between(Min,Max,Value):-
    repeat,
    read_number(Value),
    Value >= Min,
    Value < Max,
    !.

% get_piece_at(+X, +Y, +Game, -Piece)
% Gets piece at position (X, Y) in the Game
get_piece_at(X, Y, game(Board, _, _, _, _, _), Piece) :-
     nth0(Y, Board, Row),
     nth0(X, Row, Piece).

% initial_row(+PieceNo, +Size, +Y, +Type, -Row)
% Initializes a board row of size Size with pieces of tupt Type at position (PieceNo, Y)
initial_row(0, _, _, _, []).
initial_row(PieceNo, Size, Y, Type, [piece(Type, X, Y) | Tail]) :-
     NewPieceNo is PieceNo - 1,
     X is Size - PieceNo,
     initial_row(NewPieceNo, Size, Y, Type, Tail).

% initial_middle(+PieceNo, +Size, +Number, -Middle)
% Initializes the middle portion of the board with blank pieces 
initial_middle(PieceNo, Size, Number, Number, [Result]) :-
     initial_row(PieceNo, Size, Number, b, Result).
initial_middle(PieceNo, Size, Number, Y, [Head | Tail]) :-
     NewY is Y + 1,
     initial_row(PieceNo, Size, Y, b, Head),
     initial_middle(PieceNo, Size, Number, NewY, Tail).

% initial_board(+Size, -Board)
% Initializes a board of size Size
initial_board(Size, [FirstRow | Tail]) :-
     LastY is Size - 1,
     Number is Size - 2,
     initial_row(Size, Size, 0, s, FirstRow),
     initial_middle(Size, Size, Number, 1, Middle),
     initial_row(Size, Size, LastY, n, LastRow),
     append(Middle, [LastRow], Tail).

% write_piece(+Piece)
% Writes a piece in the console
write_piece(piece(s, _, _)) :-
     write('|S').
write_piece(piece(n, _, _)) :-
     write('|N').
write_piece(piece(b, _, _)) :-
     write('| ').

% write_line(+Line)
% Writes a line of pieces in the console
write_line([]) :-
     write('|\n').
write_line([H | T]) :-
     write_piece(H),
     write_line(T).

% write_border(+Size)
% Write a border of size Size in the console
write_border(0) :-
     write('+\n').
write_border(Size) :-
     write('+-'),
     NewSize is Size - 1,
     write_border(NewSize).

% display_board(+Board, +Size)
% Display a board in the console
display_board([], Size) :-
     write_border(Size).
display_board([H | T], Size) :-
     write_border(Size),
     write_line(H),
     display_board(T, Size).

% initial_state(+Size, -Game)
% Initializes a game of size Size
initial_state(Size, game(Board, 0, 0, _, _, Size)) :-
     initial_board(Size, Board).

% get_turn_string(+Turn, -String)
% Gets correspondent string for each turn
get_turn_string(s, 'Samurai').
get_turn_string(n, 'Ninja').

% display_game(+Game)
% Displays all game info int the console
display_game(game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size)) :-
     get_turn_string(Turn, TurnString), nl,
     write('Mode: '),
     display(Mode), nl,
     format('~w\'s turn\n-----------------\n\nPoints - ~d\n', [TurnString, CapturedNinjas]),
     display_board(Board, Size),
     format('Points - ~d\n', [CapturedSamurai]),
     !.

% replace_in_row(+Index, +Elem, +Row, -Result)
% Replaces Row element at Index with Elem
replace_in_row(0, Elem, [_ | Tail], [Elem | Tail]).
replace_in_row(Index, Elem, [Head | Tail], [Head | Result]) :-
     NewIndex is Index - 1,
     replace_in_row(NewIndex, Elem, Tail, Result).

% replace_in_board(+X, +Y, +Elem, +Board, -Result)
% Replaces Board element at (X, Y) with Elem
replace_in_board(X, 0, Elem, [Head | Tail], [Result | Tail]) :-
     replace_in_row(X, Elem, Head, Result).
replace_in_board(X, Y, Elem, [Head | Tail], [Head | Result]) :-
     NewY is Y - 1,
     replace_in_board(X, NewY, Elem, Tail, Result).

% replace_in_game(+X, +Y, +Elem, +Game, -Result)
% Replaces element at (X, Y) in the Game's board with Elem
replace_in_game(X, Y, Elem, game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size), game(NewBoard, CapturedSamurai, CapturedNinjas, Mode, Turn, Size)) :-
     replace_in_board(X, Y, Elem, Board, NewBoard).

% move_helper(+Game, +Piece, +X, +Y, -Result)
% Substitutes the piece at (X1, Y1) with a blank and the piece at (X2, Y2) with the moved piece
move_helper(Game, piece(Type, X1, Y1), X2, Y2, NewGame) :-
     replace_in_game(X1, Y1, piece(b, X1, Y1), Game, Temp),
     replace_in_game(X2, Y2, piece(Type, X2, Y2), Temp, NewGame).

% within_bounds(+Game, +X, +Y)
% Checks if (X, Y) is within the bounds of the game
within_bounds(game(_, _, _, _, _, Size), X, Y) :-
     X > -1,
     X < Size,
     Y > -1,
     Y < Size.

% can_capture(+Piece1, +Piece2)
% Checks if Piece1 is of a type that can capture Piece2
can_capture(piece(s, _, _), piece(n, _, _)).
can_capture(piece(n, _, _), piece(s, _, _)).

% is_capture_move(+Piece, +Game, +X2, +Y2)
% Checks if a move is an attempted capture
is_capture_move(piece(Type, _, _), Game, X2, Y2) :-
     get_piece_at(X2, Y2, Game, Piece),
     can_capture(piece(Type, _, _), Piece).

% is_diagonal_move(+X1, +Y1, +X2, +Y2)
% Checks if a move is a diagonal move
is_diagonal_move(X1, Y1, X2, Y2) :-
     DeltaX is abs(X2 - X1),
     DeltaY is abs(Y2 - Y1),
     DeltaX is DeltaY.

% is_clear(+Dir, +X1, +Y1, +X2, +Y2, +Game)
% Checks if the path from (X1, Y1) to (X2, Y2) is only filled with blanks
is_clear(_, X, Y, X, Y, _).
is_clear(west, X1, Y, X2, Y, game(Board, _, _, _, _, _)) :-
     get_piece_at(X1, Y, game(Board, _, _, _, _, _), piece(b, X1, Y)),
     NewX is X1 - 1,
     is_clear(west, NewX, Y, X2, Y, game(Board, _, _, _, _, _)).
is_clear(east, X1, Y, X2, Y, game(Board, _, _, _, _ ,_)) :-
     get_piece_at(X1, Y, game(Board, _, _, _, _, _), piece(b, X1, Y)),
     NewX is X1 + 1,
     is_clear(east, NewX, Y, X2, Y, game(Board, _, _, _, _, _)).
is_clear(north, X, Y1, X, Y2, game(Board, _, _, _, _ , _)) :-
     get_piece_at(X, Y1, game(Board, _, _, _, _, _), piece(b, X, Y1)),
     NewY is Y1 - 1,
     is_clear(north, X, NewY, X, Y2, game(Board, _, _, _, _, _)).
is_clear(south, X, Y1, X, Y2, game(Board, _, _, _, _ , _)) :-
     get_piece_at(X, Y1, game(Board, _, _, _, _, _), piece(b, X, Y1)),
     NewY is Y1 + 1,
     is_clear(south, X, NewY, X, Y2, game(Board, _, _, _, _, _)).
is_clear(nw, X1, Y1, X2, Y2, game(Board, _, _, _, _, _)) :-
     get_piece_at(X1, Y1, game(Board, _, _, _, _, _), piece(b, X1, Y1)),
     NewX is X1 - 1,
     NewY is Y1 - 1,
     is_clear(nw, NewX, NewY, X2, Y2, game(Board, _, _, _, _, _)).
is_clear(ne, X1, Y1, X2, Y2, game(Board, _, _, _, _, _)) :-
     get_piece_at(X1, Y1, game(Board, _, _, _, _, _), piece(b, X1, Y1)),
     NewX is X1 + 1,
     NewY is Y1 - 1,
     is_clear(ne, NewX, NewY, X2, Y2, game(Board, _, _, _, _, _)).
is_clear(se, X1, Y1, X2, Y2, game(Board, _, _, _, _, _)) :-
     get_piece_at(X1, Y1, game(Board, _, _, _, _, _), piece(b, X1, Y1)),
     NewX is X1 + 1,
     NewY is Y1 + 1,
     is_clear(se, NewX, NewY, X2, Y2, game(Board, _, _, _, _, _)).
is_clear(sw, X1, Y1, X2, Y2, game(Board, _, _, _, _, _)) :-
     get_piece_at(X1, Y1, game(Board, _, _, _, _, _), piece(b, X1, Y1)),
     NewX is X1 - 1,
     NewY is Y1 + 1,
     is_clear(sw, NewX, NewY, X2, Y2, game(Board, _, _, _, _, _)).

% check_vertical(+Type, +Dir, +Game, +X, +CurrY, +TargetY)
% Checks if a vertical move is a valid capture move
check_vertical(Type, _, game(Board, _, _, _, _, _), X, CurrY, TargetY) :-
     get_piece_at(X, CurrY, game(Board, _, _, _, _, _), piece(Type, X, CurrY)),
     !,
     get_begin_y(CurrY, Dir, BeginY),
     is_clear(Dir, X, BeginY, X, TargetY, game(Board, _, _, _, _, _)).
check_vertical(Type, south, game(Board, _, _, _, _, _), X, CurrY, TargetY) :-
     dif(CurrY, TargetY),
     NewY is CurrY + 1,
     check_vertical(Type, south, game(Board, _, _, _, _, _), X, NewY, TargetY).
check_vertical(Type, north, game(Board, _, _, _, _, _), X, CurrY, TargetY) :-
     dif(CurrY, TargetY),
     NewY is CurrY - 1,
     check_vertical(Type, north, game(Board, _, _, _, _, _), X, NewY, TargetY).

% get_direction_vertical(+BeginY, +TargetY, -Dir)
% Get vertical direction (north or south) from start and end Y
get_direction_vertical(BeginY, TargetY, south) :-
     TargetY > BeginY.
get_direction_vertical(BeginY, TargetY, north) :-
     TargetY < BeginY.

% get_begin_y(+Y, +Dir, -NewY)
% Get Begin Y to check if path is clear
get_begin_y(Y, south, NewY) :-
     NewY is Y + 1.
get_begin_y(Y, north, NewY) :-
     NewY is Y - 1.

% get_direction_horizontal(+BeginX, +TargetX, -Dir)
% Get horizontal direction (east or west) from start and end X
get_direction_horizontal(BeginX, TargetX, east) :-
     TargetX > BeginX.
get_direction_horizontal(BeginX, TargetX, west) :-
     TargetX < BeginX.

% get_begin_x(+X, +Dir, -BeginX)
% Get Begin X to check if path is clear
get_begin_x(X, east, BeginX) :-
     BeginX is X + 1.
get_begin_x(X, west, BeginX) :-
     BeginX is X - 1.

% check_horizontal(+Type, +Dir, +Game, +Y, +CurrX, +TargetX)
% Check if a horizontal move is a valid capture move
check_horizontal(Type, Dir, game(Board, _, _, _, _, _), Y, CurrX, TargetX) :-
     get_piece_at(CurrX, Y, game(Board, _, _, _, _, _), piece(Type, CurrX, Y)),
     !,
     get_begin_x(CurrX, Dir, BeginX),
     is_clear(Dir, BeginX, Y, TargetX, Y, game(Board, _, _, _, _, _)).
check_horizontal(Type, east, game(Board, _, _, _, _, _), Y, CurrX, TargetX) :-
     dif(CurrX, TargetX),
     NewX is CurrX + 1,
     check_horizontal(Type, east, game(Board, _, _, _, _, _), Y, NewX, TargetX).
check_horizontal(Type, west, game(Board, _, _, _, _, _), Y, CurrX, TargetX) :-
     dif(CurrX, TargetX),
     NewX is CurrX - 1,
     check_horizontal(Type, west, game(Board, _, _, _, _, _), Y, NewX, TargetX).

% get_direction_diagonal(+BeginX, +BeginY, +TargetX, +TargetY, -Dir)
% Get diagonal direction from start and end coordinates
get_direction_diagonal(BeginX, BeginY, TargetX, TargetY, ne) :-
     TargetX > BeginX,
     TargetY < BeginY.
get_direction_diagonal(BeginX, BeginY, TargetX, TargetY, se) :-
     TargetX > BeginX,
     TargetY > BeginY.
get_direction_diagonal(BeginX, BeginY, TargetX, TargetY, sw) :-
     TargetX < BeginX,
     TargetY > BeginY.
get_direction_diagonal(BeginX, BeginY, TargetX, TargetY, nw) :-
     TargetX < BeginX,
     TargetY < BeginY.

% get_begin_coord(+X, +Y, +Dir, -BeginX, -BeginY)
% Get beginning coordinates to check if path is clear
get_begin_coord(X, Y, ne, BeginX, BeginY) :-
     BeginX is X + 1,
     BeginY is Y - 1.
get_begin_coord(X, Y, se, BeginX, BeginY) :-
     BeginX is X + 1,
     BeginY is Y + 1.
get_begin_coord(X, Y, sw, BeginX, BeginY) :-
     BeginX is X - 1,
     BeginY is Y + 1.
get_begin_coord(X, Y, nw, BeginX, BeginY) :-
     BeginX is X - 1,
     BeginY is Y - 1.

% check_diagonal(+Type, +Dir, +Game, +CurrX, +CurrY, +TargetX, +TagretY)
% Check if diagonal move is valid capture move
check_diagonal(Type, Dir, game(Board, _, _, _, _, _), CurrX, CurrY, TargetX, TargetY) :-
     get_piece_at(CurrX, CurrY, game(Board, _, _, _, _, _), piece(Type, CurrX, CurrY)),
     !,
     get_begin_coord(CurrX, CurrY, Dir, BeginX, BeginY),
     is_clear(Dir, BeginX, BeginY, TargetX, TargetY, game(Board, _, _, _, _, _)).
check_diagonal(Type, ne, game(Board, _, _, _, _, _), CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX + 1,
     NewY is CurrY - 1,
     check_diagonal(Type, ne, game(Board, _, _, _, _, _), NewX, NewY, TargetX, TargetY).
check_diagonal(Type, se, game(Board, _, _, _, _, _), CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX + 1,
     NewY is CurrY + 1,
     check_diagonal(Type, se, game(Board, _, _, _, _, _), NewX, NewY, TargetX, TargetY).
check_diagonal(Type, sw, game(Board, _, _, _, _, _), CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX - 1,
     NewY is CurrY + 1,
     check_diagonal(Type, sw, game(Board, _, _, _, _, _), NewX, NewY, TargetX, TargetY).
check_diagonal(Type, nw, game(Board, _, _, _, _, _), CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX - 1,
     NewY is CurrY - 1,
     check_diagonal(Type, nw, game(Board, _, _, _, _, _), NewX, NewY, TargetX, TargetY).

% add_one_captured(+Turn, +CapturedSamurai, +CapturedNinjas, -NewCapturedSamurai, -NewCapturedNinjas)
% Update captured piece numbers according to who captured a piece
add_one_captured(s, CapturedSamurai, CapturedNinjas, CapturedSamurai, NewCapturedNinjas) :-
     NewCapturedNinjas is CapturedNinjas + 1.
add_one_captured(n, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, CapturedNinjas) :-
     NewCapturedSamurai is CapturedSamurai + 1.

% move(+Game, +Move, -NewGame)
% Make a move if it is a valid move and update captured piece numbers
move(Game, step(piece(Type, X1, Y1), X2, Y2), game(Board, NewCapturedSamurai, NewCapturedNinjas, Mode, Turn, Size)) :-
     valid_moves(Game, ListOfMoves),
     member(step(piece(Type, X1, Y1), X2, Y2), ListOfMoves),
     is_capture_move(piece(Type, _, _), Game, X2, Y2),
     move_helper(Game, piece(Type, X1, Y1), X2, Y2, game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).
move(Game, step(piece(Type, X1, Y1), X2, Y2), NewGame) :-
     valid_moves(Game, ListOfMoves),
     member(step(piece(Type, X1, Y1), X2, Y2), ListOfMoves),
     \+ is_capture_move(piece(Type, _, _), Game, X2, Y2),
     move_helper(Game, piece(Type, X1, Y1), X2, Y2, NewGame).

% game_over(+Game, -Winner)
% Check if game is over and return winner
game_over(game(_, _, CapturedNinjas, _, _, Size), s) :-
     PiecesToWin is div(Size, 2),
     CapturedNinjas >= PiecesToWin.
game_over(game(_, CapturedSamurai, _, _, _, Size), n) :-
     PiecesToWin is div(Size, 2),
     CapturedSamurai >= PiecesToWin.
game_over(game(_, _, _, _, _, _), u).

% get_mode_and_turn_from_choice(+Choice, -Mode, -StartTurn)
% Get game mode and start turn from user choice
get_mode_and_turn_from_choice(1, h_h, s).
get_mode_and_turn_from_choice(2, h_h, n).
get_mode_and_turn_from_choice(3, p_v_random_ai, s).
get_mode_and_turn_from_choice(4, p_v_random_ai, n).
get_mode_and_turn_from_choice(5, p_v_miopic_ai, s).
get_mode_and_turn_from_choice(6, p_v_miopic_ai, n).
get_mode_and_turn_from_choice(7, random_ai_v_random_ai, s).
get_mode_and_turn_from_choice(8, miopic_ai_v_miopic_ai, s).
get_mode_and_turn_from_choice(9, random_ai_v_miopic_ai, s).
get_mode_and_turn_from_choice(10, random_ai_v_miopic_ai, n).

% start_menu(-Size, -Mode, -StartTurn)
% Present start menu
start_menu(Size, Mode, StartTurn) :-
     repeat,
     format('# Menu\nInput board size: ', []),
     read_number(Size),
     write('# Write game mode\n1 - Human Samurai/Human Ninja\n2 - Human Ninja/ Human Samurai\n3 - Human Samurai/EASY AI Ninja\n4 - EASY AI Ninja/Human Samurai\n5 - Human Samurai/HARD AI Ninja\n6 - HARD AI Ninja/Human Samurai\n7 - EASY AI Samurai/EASY AI Ninja\n8 - HARD AI Samurai/HARD AI Ninja\n9 - EASY AI Samurai/HARD AI Ninja\n10-HARD AI Ninja/EASY AI Samurai\nChoice '),
     read_until_between(1, 11, Choice),
     get_mode_and_turn_from_choice(Choice, Mode, StartTurn).

% change_player(+Game, -NewGame)
% Change the game turn
change_player(game(Board, CapturedSamurai, CapturedNinjas, Mode, s, Size), game(Board, CapturedSamurai, CapturedNinjas, Mode, n, Size)).
change_player(game(Board, CapturedSamurai, CapturedNinjas, Mode, n, Size), game(Board, CapturedSamurai, CapturedNinjas, Mode, s, Size)).

% choose_move_miopic_helper(+Game, +Moves, -Move)
% Choose the move for the miopic AI
choose_move_miopic_helper(_, [step(Piece, X, Y)], step(Piece, X, Y)).
choose_move_miopic_helper(Game, [step(Piece, X, Y) | _], step(Piece, X, Y)) :-
     is_capture_move(Piece, Game, X, Y).
choose_move_miopic_helper(Game, [_ | Tail], Move) :-
     choose_move_miopic_helper(Game, Tail, Move).

% choose_move(+Game, +AIType, -Move)
% Choose move according to AI Type
choose_move(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, n, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, n, Size), ListOfMoves),
     random_member(Move, ListOfMoves).
choose_move(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_random_ai, Turn, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_random_ai, Turn, Size), ListOfMoves),
     random_member(Move, ListOfMoves).
choose_move(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, n, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, n, Size), ListOfMoves),
     choose_move_miopic_helper(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, n, Size), ListOfMoves, Move).
choose_move(game(Board, CapturedSamurai, CapturedNinjas, miopic_ai_v_miopic_ai, Turn, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, miopic_ai_v_miopic_ai, Turn, Size), ListOfMoves),
     choose_move_miopic_helper(game(Board, CapturedSamurai, CapturedNinjas, miopic_ai_v_miopic_ai, Turn, Size), ListOfMoves, Move).
choose_move(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_miopic_ai, s, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_miopic_ai, s, Size), ListOfMoves),
     random_member(Move, ListOfMoves).
choose_move(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_miopic_ai, n, Size), _, Move) :-
     valid_moves(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_miopic_ai, n, Size), ListOfMoves),
     choose_move_miopic_helper(game(Board, CapturedSamurai, CapturedNinjas, random_ai_v_miopic_ai, n, Size), ListOfMoves, Move).

input_move(X-Y) :-  get_char(X),skip_line, get_char(Y), skip_line, write(X), nl, write(Y), nl.

% read_move_from_player(+GameState, -Move)
% Get move input from player
read_move_from_player(game(Board, _, _, _, Turn, Size), step(piece(Turn, X1, Y1), X2, Y2)) :-
     repeat,
     write('Input Piece to move. X '),
     read_until_between(0, Size, X1),
     write('Y '),
     read_until_between(0, Size, Y1),
     write('To X '),
     read_until_between(0, Size, X2),
     write('Y '),
     read_until_between(0, Size, Y2),
     get_piece_at(X1, Y1, game(Board, _, _, _, Turn, Size), piece(Turn, X1, Y1)),
     valid_moves(game(Board, _, _, _, Turn, Size), ListOfMoves),
     member(step(piece(Turn, X1, Y1), X2, Y2), ListOfMoves).

% play_game(+Game, -Winner)
% Gameloop to play game
play_game(Game, s) :-
     display_game(Game),
     write('Samurai wins!').
play_game(Game, n) :-
     display_game(Game),
     write('Ninja wins!').
play_game(game(Board, CapturedSamurai, CapturedNinjas, h_h, Turn, Size), u) :-
     display_game(game(Board, CapturedSamurai, CapturedNinjas, h_h, Turn, Size)),
     read_move_from_player(game(Board, CapturedSamurai, CapturedNinjas, h_h, Turn, Size), Move),
     move(game(Board, CapturedSamurai, CapturedNinjas, h_h, Turn, Size), Move, Temp),
     game_over(Temp, Winner),
     change_player(Temp, NewGame),
     play_game(NewGame, Winner).
play_game(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, s, Size), u) :-
     display_game(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, s, Size)),
     read_move_from_player(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, s, Size), Move),
     move(game(Board, CapturedSamurai, CapturedNinjas, p_v_random_ai, s, Size), Move, Temp),
     game_over(Temp, Winner),
     change_player(Temp, NewGame),
     play_game(NewGame, Winner).
play_game(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, s, Size), u) :-
     display_game(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, s, Size)),
     read_move_from_player(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, s, Size), Move),
     move(game(Board, CapturedSamurai, CapturedNinjas, p_v_miopic_ai, s, Size), Move, Temp),
     game_over(Temp, Winner),
     change_player(Temp, NewGame),
     play_game(NewGame, Winner).
play_game(game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size), u) :-
     display_game(game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size)),
     choose_move(game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size), _, Move),
     move(game(Board, CapturedSamurai, CapturedNinjas, Mode, Turn, Size), Move, Temp),
     game_over(Temp, Winner),
     change_player(Temp, NewGame),
     play_game(NewGame, Winner).

%iterate_over_southeast_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in southeast direction and return valid ones
iterate_over_southeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2)]) :-
     X2 < Size,
     Y2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y2),
     get_begin_coord(X1, Y1, se, CheckX, CheckY),
     check_diagonal(Type, se, game(Board, _, _, _, _, _), CheckX, CheckY, X2, Y2).
iterate_over_southeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2) | Tail]) :-
     X2 < Size,
     Y2 < Size,
     get_piece_at(X2, Y2, game(Board, _, _, _, _, _), piece(b, X2, Y2)),
     get_begin_coord(X1, Y1, se, CheckX, CheckY),
     is_clear(se, CheckX, CheckY, X2, Y2, game(Board, _, _, _, _, _)),
     NewX is X2 + 1,
     NewY is Y2 + 1,
     iterate_over_southeast_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_southeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, Tail) :-
     X2 < Size,
     Y2 < Size,
     NewX is X2 + 1,
     NewY is Y2 + 1,
     iterate_over_southeast_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_southeast_moves(_, _, _, []).

%get_southeast_moves(+Piece, +Board, +Size, -SoutheastMoves)
% Get valid southeast moves for a piece
get_southeast_moves(piece(Type, X, Y), Board, Size, SoutheastMoves) :-
     NewX is X + 1,
     NewY is Y + 1,
     NewX < Size,
     NewY < Size,
     iterate_over_southeast_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, SoutheastMoves).
get_southeast_moves(_, _, _, []).

%iterate_over_southwest_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in southwest direction and return valid ones
iterate_over_southwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2)]) :-
     X2 > -1,
     Y2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y2),
     get_begin_coord(X1, Y1, sw, CheckX, CheckY),
     check_diagonal(Type, sw, game(Board, _, _, _, _, _), CheckX, CheckY, X2, Y2).
iterate_over_southwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2) | Tail]) :-
     X2 > -1,
     Y2 < Size,
     get_piece_at(X2, Y2, game(Board, _, _, _, _, _), piece(b, X2, Y2)),
     get_begin_coord(X1, Y1, sw, CheckX, CheckY),
     is_clear(sw, CheckX, CheckY, X2, Y2, game(Board, _, _, _, _, _)),
     NewX is X2 - 1,
     NewY is Y2 + 1,
     iterate_over_southwest_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_southwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, Tail) :-
     X2 > -1,
     Y2 < Size,
     NewX is X2 - 1,
     NewY is Y2 + 1,
     iterate_over_southwest_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_southwest_moves(_, _, _, []).

%get_southwest_moves(+Piece, +Board, +Size, -SouthwestMoves)
% Get valid southwest moves for a piece
get_southwest_moves(piece(Type, X, Y), Board, Size,SouthwestMoves) :-
     NewX is X - 1,
     NewY is Y + 1,
     NewX > -1,
     NewY < Size,
     iterate_over_southwest_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, SouthwestMoves).
get_southwest_moves(_, _, _, []).

%iterate_over_northeast_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in northeast direction and return valid ones
iterate_over_northeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2)]) :-
     X2 < Size,
     Y2 > -1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y2),
     get_begin_coord(X1, Y1, ne, CheckX, CheckY),
     check_diagonal(Type, ne, game(Board, _, _, _, _, _), CheckX, CheckY, X2, Y2).
iterate_over_northeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, [step(piece(Type, X1, Y1), X2, Y2) | Tail]) :-
     X2 < Size,
     Y2 > - 1,
     get_piece_at(X2, Y2, game(Board, _, _, _, _, _), piece(b, X2, Y2)),
     get_begin_coord(X1, Y1, ne, CheckX, CheckY),
     is_clear(ne, CheckX, CheckY, X2, Y2, game(Board, _, _, _, _, _)),
     NewX is X2 + 1,
     NewY is Y2 - 1,
     iterate_over_northeast_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_northeast_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Size, Tail) :-
     X2 < Size,
     Y2 > - 1,
     NewX is X2 + 1,
     NewY is Y2 - 1,
     iterate_over_northeast_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Size, Tail).
iterate_over_northeast_moves(_, _, _, []).

%get_northeast_moves(+Piece, +Board, +Size, -NortheastMoves)
% Get valid northeast moves for a piece
get_northeast_moves(piece(Type, X, Y), Board, Size, NortheastMoves) :-
     NewX is X + 1,
     NewY is Y - 1,
     NewX < Size,
     NewY > -1,
     iterate_over_northeast_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, NortheastMoves).
get_northeast_moves(_, _, _, []).

%iterate_over_northwest_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in northwest direction and return valid ones
iterate_over_northwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, [step(piece(Type, X1, Y1), X2, Y2)]) :-
     X2 > -1,
     Y2 > -1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y2),
     get_begin_coord(X1, Y1, nw, CheckX, CheckY),
     check_diagonal(Type, nw, game(Board, _, _, _, _, _), CheckX, CheckY, X2, Y2).
iterate_over_northwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, [step(piece(Type, X1, Y1), X2, Y2) | Tail]) :-
     X2 > -1,
     Y2 > -1,
     get_piece_at(X2, Y2, game(Board, _, _, _, _, _), piece(b, X2, Y2)),
     get_begin_coord(X1, Y1, nw, CheckX, CheckY),
     is_clear(nw, CheckX, CheckY, X2, Y2, game(Board, _, _, _, _, _)),
     NewX is X2 - 1,
     NewY is Y2 - 1,
     iterate_over_northwest_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Tail).
iterate_over_northwest_moves(step(piece(Type, X1, Y1), X2, Y2), Board, Tail) :-
     X2 > -1,
     Y2 > -1,
     NewX is X2 - 1,
     NewY is Y2 - 1,
     iterate_over_northwest_moves(step(piece(Type, X1, Y1), NewX, NewY), Board, Tail).
iterate_over_northwest_moves(_, _, []).

%get_northeast_moves(+Piece, +Board, +Size, -NortheastMoves)
% Get valid northwest moves for a piece
get_northwest_moves(piece(Type, X, Y), Board, NorthwestMoves) :-
     NewX is X - 1,
     NewY is Y - 1,
     NewX > -1,
     NewY > -1,
     iterate_over_northwest_moves(step(piece(Type, X, Y), NewX, NewY), Board, NorthwestMoves).
get_northwest_moves(_, _, []).

%get_diagonal_moves(+Piece, +Board, +Size, -DiagonalMoves)
% Get valid diagonal moves for a piece
get_diagonal_moves(Piece, Board, Size, DiagonalMoves) :-
     get_northwest_moves(Piece, Board, NorthwestMoves),
     get_northeast_moves(Piece, Board, Size, NortheastMoves),
     get_southeast_moves(Piece, Board, Size, SoutheastMoves),
     get_southwest_moves(Piece, Board, Size, SouthwestMoves),
     append(NorthwestMoves, NortheastMoves, NorthMoves),
     append(SoutheastMoves, SouthwestMoves, SouthMoves),
     append(NorthMoves, SouthMoves, DiagonalMoves).

%iterate_over_south_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in south direction and return valid ones
iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, [step(piece(Type, X, Y1), X, Y2)]) :-
     Y2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _,_), X, Y2),
     get_begin_y(Y1, south, CheckY),
     check_vertical(Type, south, game(Board, _, _, _, _, _), X, CheckY, Y2).
iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, [step(piece(Type, X, Y1), X, Y2) | Tail]) :-
     Y2 < Size,
     get_piece_at(X, Y2, game(Board, _, _, _, _, _), piece(b, X, Y2)),
     get_begin_y(Y1, south, CheckY),
     is_clear(south, X, CheckY, X, Y2, game(Board, _, _, _, _, _)),
     NewY is Y2 + 1,
     iterate_over_south_moves(step(piece(Type, X, Y1), X, NewY), Board, Size, Tail).
iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, Tail) :-
     Y2 < Size,
     NewY is Y2 + 1,
     iterate_over_south_moves(step(piece(Type, X, Y1), X, NewY), Board, Size, Tail).
iterate_over_south_moves(_, _, _, []).

%get_south_moves(+Piece, +Board, +Size, -DiagonalMoves)
% Get valid south moves for a piece
get_south_moves(piece(Type, X, Y), Board, Size, SouthMoves) :-
     NewY is Y + 1,
     NewY < Size,
     iterate_over_south_moves(step(piece(Type, X, Y), X, NewY), Board, Size, SouthMoves).
get_south_moves(_, _, _, []).

%iterate_over_north_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in north direction and return valid ones
iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, [step(piece(Type, X, Y1), X, Y2)]) :-
     Y2 > -1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _,_), X, Y2),
     get_begin_y(Y1, north, CheckY),
     check_vertical(Type, north, game(Board, _, _, _, _, _), X, CheckY, Y2).
iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, [step(piece(Type, X, Y1), X, Y2) | Tail]) :-
     Y2 > -1,
     get_piece_at(X, Y2, game(Board, _, _, _, _, _), piece(b, X, Y2)),
     get_begin_y(Y1, north, CheckY),
     is_clear(north, X, CheckY, X, Y2, game(Board, _, _, _, _, _)),
     NewY is Y2 - 1,
     iterate_over_north_moves(step(piece(Type, X, Y1), X, NewY), Board, Tail).
iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, Tail) :-
     Y2 > -1,
     NewY is Y2 - 1,
     iterate_over_north_moves(step(piece(Type, X, Y1), X, NewY), Board, Tail).
iterate_over_north_moves(_, _, []).

%get_north_moves(+Piece, +Board, +Size, -NorthMoves)
% Get valid north moves for a piece
get_north_moves(piece(Type, X, Y), Board, NorthMoves) :-
     NewY is Y - 1,
     NewY > -1,
     iterate_over_north_moves(step(piece(Type, X, Y), X, NewY), Board, NorthMoves).
get_north_moves(_, _, []).

%get_vertical_moves(+Piece, +Board, +Size, -VerticalMoves)
% Get valid vertical moves for a piece 
get_vertical_moves(Piece, Board, Size, VerticalMoves) :-
     get_north_moves(Piece, Board, NorthMoves),
     get_south_moves(Piece, Board, Size, SouthMoves),
     append(NorthMoves, SouthMoves, VerticalMoves).

%iterate_over_east_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in east direction and return valid ones
iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, [step(piece(Type, X1, Y), X2, Y)]) :-
     X2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y),
     get_begin_x(X1, east, CheckX),
     check_horizontal(Type, east, game(Board, _, _, _, _, _), Y, CheckX, X2).
iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, [step(piece(Type, X1, Y), X2, Y) | Tail]) :-
     X2 < Size,
     get_piece_at(X2, Y, game(Board, _, _, _, _, _), piece(b, X2, Y)),
     get_begin_x(X1, east, CheckX),
     is_clear(east, CheckX, Y, X2, Y, game(Board, _, _, _, _, _)),
     NewX is X2 + 1,
     iterate_over_east_moves(step(piece(Type, X1, Y), NewX, Y), Board, Size, Tail).
iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, Tail) :-
     X2 < Size,
     NewX is X2 + 1,
     iterate_over_east_moves(step(piece(Type, X1, Y), NewX, Y), Board, Size, Tail).
iterate_over_east_moves(_, _, _, []).

%get_east_moves(+Piece, +Board, +Size, -EastMoves)
% Get valid east moves for a piece
get_east_moves(piece(Type, X, Y), Board, Size, EastMoves) :-
     NewX is X + 1,
     NewX < Size,
     iterate_over_east_moves(step(piece(Type, X, Y), NewX, Y), Board, Size, EastMoves).
get_east_moves(_, _, _, []).

%iterate_over_west_moves(+Move, +Board, +Size, -Moves)
% Iterate over moves in west direction and return valid ones
iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, [step(piece(Type, X1, Y), X2, Y)]) :-
     X2 > - 1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y),
     get_begin_x(X1, west, CheckX),
     check_horizontal(Type, west, game(Board, _, _, _, _, _), Y, CheckX, X2).
iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, [step(piece(Type, X1, Y), X2, Y) | Tail]) :-
     X2 > -1,
     get_piece_at(X2, Y, game(Board, _, _, _, _, _), piece(b, X2, Y)),
     get_begin_x(X1, west, CheckX),
     is_clear(west, CheckX, Y, X2, Y, game(Board, _, _, _, _, _)),
     NewX is X2 - 1,
     iterate_over_west_moves(step(piece(Type, X1, Y), NewX, Y), Board, Tail).
iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, Tail) :-
     X2 > -1,
     NewX is X2 - 1,
     iterate_over_west_moves(step(piece(Type, X1, Y), NewX, Y), Board, Tail).
iterate_over_west_moves(_, _, []).

%get_west_moves(+Piece, +Board, +Size, -WestMoves)
% Get valid west moves for a piece
get_west_moves(piece(Type, X, Y), Board, WestMoves) :-
     NewX is X - 1,
     NewX > -1,
     iterate_over_west_moves(step(piece(Type, X, Y), NewX, Y), Board, WestMoves).
get_west_moves(_, _, []).
     
%get_horizontal_moves(+Piece, +Board, +Size, -HorizontalMoves)   
% Get valid horizontal moves for a piece 
get_horizontal_moves(Piece, Board, Size, HorizontalMoves) :-
     get_east_moves(Piece, Board, Size, EastMoves),
     get_west_moves(Piece, Board, WestMoves),
     append(EastMoves, WestMoves, HorizontalMoves).

%moves_for_piece(+Piece, +Board, +Size, -ListOfMoves)
% Get all valid moves for a piece
moves_for_piece(Piece, Board, Size, ListOfMoves) :-
     get_horizontal_moves(Piece, Board, Size, HorizontalMoves),
     get_vertical_moves(Piece, Board, Size, VerticalMoves),
     get_diagonal_moves(Piece, Board, Size, DiagonalMoves),
     append(HorizontalMoves, VerticalMoves, Temp),
     append(Temp, DiagonalMoves, ListOfMoves).

%go_through_row(+Pieces, +Board, +Turn, +Size, -RowMoves)
% Get all valid moves for pieces in a row
go_through_row([], _, _, _, []).
go_through_row([piece(Turn, X, Y) | Tail], Board, Turn, Size, RowMoves) :-
     moves_for_piece(piece(Turn, X, Y), Board, Size, PieceMoves),
     go_through_row(Tail, Board,  Turn, Size, TailMoves),
     append(PieceMoves, TailMoves, RowMoves).
go_through_row([_ | Tail], Board, Turn, Size, TailMoves) :-
     go_through_row(Tail, Board, Turn, Size, TailMoves).

%go_through_board(+Rows, +Board, +Turn, +Size, -ListOfMoves)
% Get all valid moves in a board
go_through_board([], _, _, _, []).
go_through_board([Row | Tail], Board, Turn, Size, ListOfMoves) :-
     go_through_row(Row, Board, Turn, Size, RowMoves),
     go_through_board(Tail, Board, Turn, Size, TailMoves),
     append(RowMoves, TailMoves, ListOfMoves).

%valid_moves(+GameState, -ListOfMoves)
% Get all valid moves in a game
valid_moves(game(Board, _, _, _, Turn, Size), ListOfMoves) :-
     go_through_board(Board, Board, Turn, Size, ListOfMoves),
     !.

% value(+Game, +Player, -Value)
% Get game state value for player (the number of pieces they've capture)
value(game(_, _, CapturedNinjas, _, _, _), s, CapturedNinjas).
value(game(_, CapturedSamurai, _, _, _, _), n, CapturedSamurai).

%play()
% Play game
play :-
     start_menu(Size, Mode, StartTurn),
     initial_state(Size, game(Board, CapturedSamurai, CapturedNinjas, Mode, StartTurn, Size)),
     write('Initial state set\n'),
     play_game(game(Board, CapturedSamurai, CapturedNinjas, Mode, StartTurn, Size), u).
