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

initial_row(0, _, _, []).

initial_row(Size, Y, Type, [piece(Type, X, Y) | Tail]) :-
     NewSize is Size - 1,
     X is 8 - Size,
     initial_row(NewSize, Y, Type, Tail).

initial_middle(Size, Number, Number, [Result]) :-
     initial_row(Size, Number, b, Result).

initial_middle(Size, Number, Y, [Head | Tail]) :-
     NewY is Y + 1,
     initial_row(Size, Y, b, Head),
     initial_middle(Size, Number, NewY, Tail).

initial_board(Size, [FirstRow | Tail]) :-
     LastY is Size - 1,
     Number is Size - 2,
     initial_row(Size, 0, s, FirstRow),
     initial_middle(Size, Number, 1, Middle),
     initial_row(Size, LastY, n, LastRow),
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

write_border :-
     write('+-+-+-+-+-+-+-+-+\n').

display_board([]) :-
     write_border.

display_board([H | T]) :-
     write_border,
     write_line(H),
     display_board(T).

%game(Board, CapturedSamurai, CapturedNinjas, State, Turn)
%TODO alter to State to start after
initial_state(Size, game(Board, 0, 0, playing, samurai, Size)) :-
     initial_board(Size, Board).

get_turn_string(samurai, 'Samurai').

get_turn_string(ninja, 'Ninja').

display_game(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn, _)) :-
     get_turn_string(Turn, TurnString),
     format('~w\'s turn\n-----------------\n\nPoints - ~d\n', [TurnString, CapturedNinjas]),
     display_board(Board),
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

% 1 is between 2 and 3
is_between_horizontal(piece(Type, X1, _), piece(Type, X2, _), piece(_, X3, _)) :-
     X1 > X2,
     X1 < X3;
     X1 < X2,
     X1 > X3.

is_between_vertical(piece(Type, _, Y1), piece(Type, _, Y2), piece(_, _,Y3)) :-
     Y1 > Y2,
     Y1 < Y3;
     Y1 < Y2,
     Y1 > Y3.

check_vertical(_, _, _, X, TargetY, TargetY) :-
     fail.

check_vertical(Type, _, Game, X, CurrY, TargetY) :-
     get_piece_at(X, CurrY, Game, piece(Type, X, CurrY)).

check_vertical(Type, south, Game, X, CurrY, TargetY) :-
     dif(CurrY, TargetY),
     NewY is CurrY + 1,
     check_vertical(Type, south, Game, X, NewY, TargetY).

check_vertical(Type, north, Game, X, CurrY, TargetY) :-
     dif(CurrY, TargetY),
     NewY is CurrY - 1,
     check_vertical(Type, north, Game, X, NewY, TargetY).

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

check_horizontal(_, _, _, Y, TargetX, TargetX) :-
     fail.

check_horizontal(Type, _, Game, Y, CurrX, TargetX) :-
     get_piece_at(CurrX, Y, Game, piece(Type, CurrX, Y)).

check_horizontal(Type, east, Game, Y, CurrX, TargetX) :-
     dif(CurrX, TargetX),
     NewX is CurrX + 1,
     check_horizontal(Type, east, Game, Y, NewX, TargetX).

check_horizontal(Type, west, Game, Y, CurrX, TargetX) :-
     dif(CurrX, TargetX),
     NewX is CurrX - 1,
     check_horizontal(Type, west, Game, Y, NewX, TargetX).

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

check_diagonal(_, _, _, TargetX, TargetY, TargetX, TargetY) :-
     fail.

check_diagonal(Type, _, Game, CurrX, CurrY, _, _) :-
     get_piece_at(CurrX, CurrY, Game, piece(Type, CurrX, CurrY)).

check_diagonal(Type, ne, Game, CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX + 1,
     NewY is CurrY - 1,
     check_diagonal(Type, ne, Game, NewX, NewY, TargetX, TargetY).

check_diagonal(Type, se, Game, CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX + 1,
     NewY is CurrY + 1,
     check_diagonal(Type, se, Game, NewX, NewY, TargetX, TargetY).

check_diagonal(Type, sw, Game, CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX - 1,
     NewY is CurrY + 1,
     check_diagonal(Type, sw, Game, NewX, NewY, TargetX, TargetY).

check_diagonal(Type, nw, Game, CurrX, CurrY, TargetX, TargetY) :-
     dif(CurrX, TargetX),
     dif(CurrY, TargetY),
     NewX is CurrX - 1,
     NewY is CurrY - 1,
     check_diagonal(Type, nw, Game, NewX, NewY, TargetX, TargetY).

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
     move_helper(Game, piece(Type, X, Y1), X, Y2, NewGame).

play :-
     initial_state(8, Game),
     display_game(Game),
     !,
     replace_in_game(3, 4, piece(s, 3, 4), Game, NG1),
     get_piece_at(1, 0, NG1, Piece1),
     move(NG1, step(Piece1, 0, 1), NG2),
     get_piece_at(5, 7, NG2, Piece2),
     move(NG2, step(Piece2, 5, 6), NG3),
     get_piece_at(0, 1, NG3, Piece3),
     move(NG3, step(Piece3, 5, 6), NG4),
     display_game(NG4).

% make type = turn in game