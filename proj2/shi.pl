/**
piece(Type, X, Y)

Type - s - samurai
     - n - ninja
     - b - blank

0 <= X <= 7

0 <= Y <= 7
*/
:- use_module(library(lists)).

get_piece_at(X, Y, game(Board, _, _, _, _, _), Piece) :-
     nth0(Y, Board, Row),
     nth0(X, Row, Piece).

initial_row(0, _, _, _, []).
initial_row(PieceNo, Size, Y, Type, [piece(Type, X, Y) | Tail]) :-
     NewPieceNo is PieceNo - 1,
     X is Size - PieceNo,
     initial_row(NewPieceNo, Size, Y, Type, Tail).

initial_middle(PieceNo, Size, Number, Number, [Result]) :-
     initial_row(PieceNo, Size, Number, b, Result).
initial_middle(PieceNo, Size, Number, Y, [Head | Tail]) :-
     NewY is Y + 1,
     initial_row(PieceNo, Size, Y, b, Head),
     initial_middle(PieceNo, Size, Number, NewY, Tail).

initial_board(Size, [FirstRow | Tail]) :-
     LastY is Size - 1,
     Number is Size - 2,
     initial_row(Size, Size, 0, s, FirstRow),
     initial_middle(Size, Size, Number, 1, Middle),
     initial_row(Size, Size, LastY, n, LastRow),
     append(Middle, [LastRow], Tail).

write_piece(piece(s, _, _)) :-
     write('|S').
write_piece(piece(n, _, _)) :-
     write('|N').
write_piece(piece(b, _, _)) :-
     write('| ').

write_line([]) :-
     write('|\n').
write_line([H | T]) :-
     write_piece(H),
     write_line(T).

write_border(0) :-
     write('+\n').
write_border(Size) :-
     write('+-'),
     NewSize is Size - 1,
     write_border(NewSize).

display_board([], Size) :-
     write_border(Size).
display_board([H | T], Size) :-
     write_border(Size),
     write_line(H),
     display_board(T, Size).

%game(Board, CapturedSamurai, CapturedNinjas, State, Turn)
%TODO alter to State to start after
initial_state(Size, game(Board, 0, 0, playing, s, Size)) :-
     initial_board(Size, Board).

get_turn_string(s, 'Samurai').

get_turn_string(n, 'Ninja').

display_game(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, Size)) :-
     get_turn_string(Turn, TurnString),
     format('~w\'s turn\n-----------------\n\nPoints - ~d\n', [TurnString, CapturedNinjas]),
     display_board(Board, Size),
     format('Points - ~d\n', [CapturedSamurai]).

replace_in_row(0, Elem, [_ | Tail], [Elem | Tail]).

replace_in_row(Index, Elem, [Head | Tail], [Head | Result]) :-
     NewIndex is Index - 1,
     replace_in_row(NewIndex, Elem, Tail, Result).

replace_in_board(X, 0, Elem, [Head | Tail], [Result | Tail]) :-
     replace_in_row(X, Elem, Head, Result).

replace_in_board(X, Y, Elem, [Head | Tail], [Head | Result]) :-
     NewY is Y - 1,
     replace_in_board(X, NewY, Elem, Tail, Result).

replace_in_game(X, Y, Elem, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size), game(NewBoard, CapturedSamurai, CapturedNinjas, State, Turn, Size)) :-
     replace_in_board(X, Y, Elem, Board, NewBoard).

move_helper(Game, piece(Type, X1, Y1), X2, Y2, NewGame) :-
     replace_in_game(X1, Y1, piece(b, X1, Y1), Game, Temp),
     replace_in_game(X2, Y2, piece(Type, X2, Y2), Temp, NewGame).

within_bounds(game(_, _, _, _, _, Size), X, Y) :-
     X > -1,
     X < Size,
     Y > -1,
     Y < Size.

can_capture(piece(s, _, _), piece(n, _, _)).
can_capture(piece(n, _, _), piece(s, _, _)).

is_capture_move(piece(Type, _, _), Game, X2, Y2) :-
     get_piece_at(X2, Y2, Game, Piece),
     can_capture(piece(Type, _, _), Piece).

is_diagonal_move(X1, Y1, X2, Y2) :-
     DeltaX is abs(X2 - X1),
     DeltaY is abs(Y2 - Y1),
     DeltaX is DeltaY.

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

get_direction_vertical(BeginY, TargetY, south) :-
     TargetY > BeginY.
get_direction_vertical(BeginY, TargetY, north) :-
     TargetY < BeginY.

get_begin_y(Y, south, NewY) :-
     NewY is Y + 1.
get_begin_y(Y, north, NewY) :-
     NewY is Y - 1.

get_direction_horizontal(BeginX, TargetX, east) :-
     TargetX > BeginX.
get_direction_horizontal(BeginX, TargetX, west) :-
     TargetX < BeginX.

get_begin_x(X, east, BeginX) :-
     BeginX is X + 1.
get_begin_x(X, west, BeginX) :-
     BeginX is X - 1.

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

add_one_captured(s, CapturedSamurai, CapturedNinjas, CapturedSamurai, NewCapturedNinjas) :-
     NewCapturedNinjas is CapturedNinjas + 1.
add_one_captured(n, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, CapturedNinjas) :-
     NewCapturedSamurai is CapturedSamurai + 1.

% diagonal case
move(Game, step(piece(Type, X1, Y1), X2, Y2), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     is_diagonal_move(X1, Y1, X2, Y2),
     within_bounds(Game, X1, Y1),
     within_bounds(Game, X2, Y2),
     is_capture_move(piece(Type, _, _), Game, X2, Y2),
     get_direction_diagonal(X1, Y1, X2, Y2, Dir),
     get_begin_coord(X1, Y1, Dir, BeginX, BeginY),
     check_diagonal(Type, Dir, Game, BeginX, BeginY, X2, Y2),
     move_helper(Game, piece(Type, X1, Y1), X2, Y2, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).
move(Game, step(piece(Type, X1, Y1), X2, Y2), NewGame) :-
     is_diagonal_move(X1, Y1, X2, Y2),
     within_bounds(Game, X1, Y1),
     within_bounds(Game, X2, Y2),
     \+ is_capture_move(piece(Type, _, _), Game, X2, Y2),
     get_direction_diagonal(X1, Y1, X2, Y2, Dir),
     get_begin_coord(X1, Y1, Dir, BeginX, BeginY),
     \+ check_diagonal(Type, Dir, Game, BeginX, BeginY, X2, Y2),
     move_helper(Game, piece(Type, X1, Y1), X2, Y2, NewGame).

% horizontal case
move(Game, step(piece(Type, X1, Y), X2, Y), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     within_bounds(Game, X1, Y),
     within_bounds(Game, X2, Y),
     is_capture_move(piece(Type, _, _), Game, X2, Y),
     get_direction_horizontal(X1, X2, Dir),
     get_begin_x(X1, Dir, BeginX),
     check_horizontal(Type, Dir, Game, Y, BeginX, X2),
     move_helper(Game, piece(Type, X1, Y), X2, Y, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).
move(Game, step(piece(Type, X1, Y), X2, Y), NewGame) :-
     within_bounds(Game, X1, Y),
     within_bounds(Game, X2, Y),
     \+ is_capture_move(piece(Type, _, _), Game, X2, Y),
     get_direction_horizontal(X1, X2, Dir),
     get_begin_x(X1, Dir, BeginX),
     \+ check_horizontal(Type, Dir, Game, Y, BeginX, X2),
     move_helper(Game, piece(Type, X1, Y), X2, Y, NewGame).

% vertical case
move(Game, step(piece(Type, X, Y1), X, Y2), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     within_bounds(Game, X, Y1),
     within_bounds(Game, X, Y2),
     is_capture_move(piece(Type, _, _), Game, X, Y2),
     get_direction_vertical(Y1, Y2, Dir),
     get_begin_y(Y1, Dir, BeginY),
     check_vertical(Type, Dir, Game, X, BeginY, Y2),
     move_helper(Game, piece(Type, X, Y1), X, Y2, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).
move(Game, step(piece(Type, X, Y1), X, Y2), NewGame) :-
     within_bounds(Game, X, Y1),
     within_bounds(Game, X, Y2),
     \+ is_capture_move(piece(Type, _, _), Game, X, Y2),
     get_direction_vertical(Y1, Y2, Dir),
     get_begin_y(Y1, Dir, BeginY),
     \+ check_vertical(Type, Dir, Game, X, BeginY, Y2),
     move_helper(Game, piece(Type, X, Y1), X, Y2, NewGame).

game_over(game(_, _, CapturedNinjas, playing, _, Size), s) :-
     PiecesToWin is div(Size, 2),
     CapturedNinjas >= PiecesToWin.
game_over(game(_, CapturedSamurai, _, playing, _, Size), n) :-
     PiecesToWin is div(Size, 2),
     CapturedSamurai >= PiecesToWin.
game_over(game(_, _, _, playing, _, _), u).

start_menu(Size) :-
     write('# Menu\nInput board size: '),
     read(Size).

change_player(game(Board, CapturedSamurai, CapturedNinjas, State, s, Size), game(Board, CapturedSamurai, CapturedNinjas, State, n, Size)).
change_player(game(Board, CapturedSamurai, CapturedNinjas, State, n, Size), game(Board, CapturedSamurai, CapturedNinjas, State, s, Size)).

play_game(_, s) :-
     write('Samurai wins!').
play_game(_, n) :-
     write('Ninja wins!').
play_game(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, Size), u) :-
     display_game(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, Size)),
     write('Input Piece to move. X'), nl,
     read(X1),
     write('Y'), nl,
     read(Y1),
     write('To X'), nl,
     read(X2),
     write('Y'), nl,
     read(Y2),
     !,
     get_piece_at(X1, Y1, game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, Size), piece(Turn, X1, Y1)),
     move(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, Size), step(piece(Turn, X1, Y1), X2, Y2), Temp),
     game_over(Temp, Winner),
     change_player(Temp, NewGame),
     play_game(NewGame, Winner).

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

get_southeast_moves(piece(Type, X, Y), Board, Size, SoutheastMoves) :-
     NewX is X + 1,
     NewY is Y + 1,
     NewX < Size,
     NewY < Size,
     iterate_over_southeast_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, SoutheastMoves).
get_southeast_moves(_, _, _, []).

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

get_southwest_moves(piece(Type, X, Y), Board, Size,SouthwestMoves) :-
     NewX is X - 1,
     NewY is Y + 1,
     NewX > -1,
     NewY < Size,
     iterate_over_southwest_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, SouthwestMoves).
get_southwest_moves(_, _, _, []).

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

get_northeast_moves(piece(Type, X, Y), Board, Size, NortheastMoves) :-
     NewX is X + 1,
     NewY is Y - 1,
     NewX < Size,
     NewY > -1,
     iterate_over_northeast_moves(step(piece(Type, X, Y), NewX, NewY), Board, Size, NortheastMoves).
get_northeast_moves(_, _, _, []).

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

get_northwest_moves(piece(Type, X, Y), Board, NorthwestMoves) :-
     NewX is X - 1,
     NewY is Y - 1,
     NewX > -1,
     NewY > -1,
     iterate_over_northwest_moves(step(piece(Type, X, Y), NewX, NewY), Board, NorthwestMoves).
get_northwest_moves(_, _, []).

get_diagonal_moves(Piece, Board, Size, DiagonalMoves) :-
     get_northwest_moves(Piece, Board, NorthwestMoves),
     get_northeast_moves(Piece, Board, Size, NortheastMoves),
     get_southeast_moves(Piece, Board, Size, SoutheastMoves),
     get_southwest_moves(Piece, Board, Size, SouthwestMoves),
     append(NorthwestMoves, NortheastMoves, NorthMoves),
     append(SoutheastMoves, SouthwestMoves, SouthMoves),
     append(NorthMoves, SouthMoves, DiagonalMoves).

iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, [step(piece(Type, X, Y1), X, Y2)]) :-
     Y2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _,_), X, Y2),
     get_begin_y(Y1, south, CheckY),
     check_vertical(Type, south, game(Board, _, _, _, _, _), X, CheckY, Y2).
iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, [step(piece(Type, X, Y1), X, Y2) | Tail]) :-
     Y2 < Size,
     get_piece_at(X, Y2, game(Board, _, _, _, _, _), piece(b, X, Y2)),
     NewY is Y2 + 1,
     iterate_over_south_moves(step(piece(Type, X, Y1), X, NewY), Board, Size, Tail).
iterate_over_south_moves(step(piece(Type, X, Y1), X, Y2), Board, Size, Tail) :-
     Y2 < Size,
     NewY is Y2 + 1,
     iterate_over_south_moves(step(piece(Type, X, Y1), X, NewY), Board, Size, Tail).
iterate_over_south_moves(_, _, _, []).

get_south_moves(piece(Type, X, Y), Board, Size, SouthMoves) :-
     NewY is Y + 1,
     NewY < Size,
     iterate_over_south_moves(step(piece(Type, X, Y), X, NewY), Board, Size, SouthMoves).
get_south_moves(_, _, _, []).

iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, [step(piece(Type, X, Y1), X, Y2)]) :-
     Y2 > -1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _,_), X, Y2),
     get_begin_y(Y1, north, CheckY),
     check_vertical(Type, north, game(Board, _, _, _, _, _), X, CheckY, Y2).
iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, [step(piece(Type, X, Y1), X, Y2) | Tail]) :-
     Y2 > -1,
     get_piece_at(X, Y2, game(Board, _, _, _, _, _), piece(b, X, Y2)),
     NewY is Y2 - 1,
     iterate_over_north_moves(step(piece(Type, X, Y1), X, NewY), Board, Tail).
iterate_over_north_moves(step(piece(Type, X, Y1), X, Y2), Board, Tail) :-
     Y2 > -1,
     NewY is Y2 - 1,
     iterate_over_north_moves(step(piece(Type, X, Y1), X, NewY), Board, Tail).
iterate_over_north_moves(_, _, []).

get_north_moves(piece(Type, X, Y), Board, NorthMoves) :-
     NewY is Y - 1,
     NewY > -1,
     iterate_over_north_moves(step(piece(Type, X, Y), X, NewY), Board, NorthMoves).
get_north_moves(_, _, []).

get_vertical_moves(Piece, Board, Size, VerticalMoves) :-
     get_north_moves(Piece, Board, NorthMoves),
     get_south_moves(Piece, Board, Size, SouthMoves),
     append(NorthMoves, SouthMoves, VerticalMoves).

iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, [step(piece(Type, X1, Y), X2, Y)]) :-
     X2 < Size,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y),
     get_begin_x(X1, east, CheckX),
     check_horizontal(Type, east, game(Board, _, _, _, _, _), Y, CheckX, X2).
iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, [step(piece(Type, X1, Y), X2, Y) | Tail]) :-
     X2 < Size,
     get_piece_at(X2, Y, game(Board, _, _, _, _, _), piece(b, X2, Y)),
     NewX is X2 + 1,
     iterate_over_east_moves(step(piece(Type, X1, Y), NewX, Y), Board, Size, Tail).
iterate_over_east_moves(step(piece(Type, X1, Y), X2, Y), Board, Size, Tail) :-
     X2 < Size,
     NewX is X2 + 1,
     iterate_over_east_moves(step(piece(Type, X1, Y), NewX, Y), Board, Size, Tail).
iterate_over_east_moves(_, _, _, []).

get_east_moves(piece(Type, X, Y), Board, Size, EastMoves) :-
     NewX is X + 1,
     NewX < Size,
     iterate_over_east_moves(step(piece(Type, X, Y), NewX, Y), Board, Size, EastMoves).
get_east_moves(_, _, _, []).

iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, [step(piece(Type, X1, Y), X2, Y)]) :-
     X2 > - 1,
     is_capture_move(piece(Type, _, _), game(Board, _, _, _, _, _), X2, Y),
     get_begin_x(X1, west, CheckX),
     check_horizontal(Type, west, game(Board, _, _, _, _, _), Y, CheckX, X2).
iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, [step(piece(Type, X1, Y), X2, Y) | Tail]) :-
     X2 > -1,
     get_piece_at(X2, Y, game(Board, _, _, _, _, _), piece(b, X2, Y)),
     get_begin_x(X1, west, CheckX),
     \+ check_horizontal(Type, west, game(Board, _, _, _, _, _), Y, CheckX, X2),
     NewX is X2 - 1,
     iterate_over_west_moves(step(piece(Type, X1, Y), NewX, Y), Board, Tail).
iterate_over_west_moves(step(piece(Type, X1, Y), X2, Y), Board, Tail) :-
     X2 > -1,
     NewX is X2 - 1,
     iterate_over_west_moves(step(piece(Type, X1, Y), NewX, Y), Board, Tail).
iterate_over_west_moves(_, _, []).

get_west_moves(piece(Type, X, Y), Board, WestMoves) :-
     NewX is X - 1,
     NewX > -1,
     iterate_over_west_moves(step(piece(Type, X, Y), NewX, Y), Board, WestMoves).
get_west_moves(_, _, []).
     
get_horizontal_moves(Piece, Board, Size, HorizontalMoves) :-
     get_east_moves(Piece, Board, Size, EastMoves),
     get_west_moves(Piece, Board, WestMoves),
     append(EastMoves, WestMoves, HorizontalMoves).

moves_for_piece(Piece, Board, Size, DiagonalMoves) :-
     %get_horizontal_moves(Piece, Board, Size, HorizontalMoves),
     %get_vertical_moves(Piece, Board, Size, VerticalMoves).
     get_diagonal_moves(Piece, Board, Size, DiagonalMoves).
     %append(HorizontalMoves, VerticalMoves, Temp).
     %append(Temp, DiagonalMoves, ListOfMoves).

go_through_row([], _, _, _, []).
go_through_row([piece(Turn, X, Y) | Tail], Board, Turn, Size, RowMoves) :-
     moves_for_piece(piece(Turn, X, Y), Board, Size, PieceMoves),
     go_through_row(Tail, Board,  Turn, Size, TailMoves),
     append(PieceMoves, TailMoves, RowMoves).
go_through_row([_ | Tail], Board, Turn, Size, TailMoves) :-
     go_through_row(Tail, Board, Turn, Size, TailMoves).

go_through_board([], _, _, _, []).
go_through_board([Row | Tail], Board, Turn, Size, ListOfMoves) :-
     go_through_row(Row, Board, Turn, Size, RowMoves),
     go_through_board(Tail, Board, Turn, Size, TailMoves),
     append(RowMoves, TailMoves, ListOfMoves).

valid_moves(game(Board, _, _, playing, Turn, Size), ListOfMoves) :-
     go_through_board(Board, Board, Turn, Size, ListOfMoves).

play :-
     initial_state(8, Game),
     replace_in_game(4, 2, piece(n, 4, 2), Game, NG),
     replace_in_game(3, 1, piece(s, 3, 1), NG, NG2),
     replace_in_game(5, 3, piece(s, 5, 3), NG2, NG3),
     replace_in_game(3, 3, piece(s, 3, 3), NG3, NG4),
     replace_in_game(6, 4, piece(s, 6, 4), NG4, NG5),
     replace_in_game(2, 4, piece(s, 2, 4), NG5, NG6),
     replace_in_game(5, 1, piece(s, 5, 1), NG6, NG7),
     display_game(NG7),
     !,
     valid_moves(NG7, List),
     display(List).
     /**
     !,
     replace_in_game(3, 4, piece(s, 3, 4), Game, NG1),
     get_piece_at(1, 0, NG1, Piece1),
     move(NG1, step(Piece1, 0, 1), NG2),
     display_game(NG2),
     get_piece_at(5, 7, NG2, Piece2),
     move(NG2, step(Piece2, 5, 6), NG3),
     display_game(NG3),
     get_piece_at(0, 1, NG3, Piece3),
     !,
     move(NG3, step(Piece3, 5, 6), NG4),
     display_game(NG4).*/

%TODO N saltar se n for captura
