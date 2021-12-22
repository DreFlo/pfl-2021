/**
piece(Type, X, Y)

Type - s - samurai
     - n - ninja
     - b - blank

0 <= X <= 7

0 <= Y <= 7
*/
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

is_capture_move(piece(Type, _, _), X2, Y2) :-
     can_capture(piece(Type, _, _), piece(_, X2, Y2)).

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

% diagonal case
move(Game, step(piece(Type, X1, Y1), X2, Y2), NewGame) :-
     is_diagonal_move(X1, Y1, X2, Y2),
     within_bounds(Game, X1, Y1),
     within_bounds(Game, X2, Y2),
     %is_capture_move(piece(Type, _, _), piece(_, X2, Y2)),
     move_helper(Game, piece(Type, X1, Y1), X2, Y2, NewGame).

add_one_captured(s, CapturedSamurai, CapturedNinjas, CapturedSamurai, NewCapturedNinjas) :-
     NewCapturedNinjas is CapturedNinjas + 1,
     format('~d  ~d', [CapturedNinjas, NewCapturedNinjas]).

add_one_captured(n, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, CapturedNinjas) :-
     NewCapturedSamurai is CapturedSamurai + 1.

% horizontal case
move(Game, step(piece(Type, X1, Y), X2, Y), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     within_bounds(Game, X1, Y),
     within_bounds(Game, X2, Y),
     is_capture_move(piece(Type, _, _), X2, Y2),
     is_between_horizontal(piece(Type, _, Y), piece(Type, X1, Y), piece(_, X2, Y2)),
     move_helper(Game, piece(Type, X1, Y), X2, Y, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).

move(Game, step(piece(Type, X1, Y), X2, Y), NewGame) :-
     within_bounds(Game, X1, Y),
     within_bounds(Game, X2, Y),
     is_capture_move(piece(Type, _, _), X2, Y2).

move(Game, step(piece(Type, X1, Y), X2, Y), NewGame) :-
     within_bounds(Game, X1, Y),
     within_bounds(Game, X2, Y),
     move_helper(Game, piece(Type, X1, Y), X2, Y, NewGame).

move(Game, step(piece(Type, X, Y1), X, Y2), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     within_bounds(Game, X, Y1),
     within_bounds(Game, X, Y2),
     is_capture_move(piece(Type, _, _), X, Y2),
     is_between_vertical(piece(Type, X, _), piece(Type, X, Y1), piece(_, X, Y2)),
     move_helper(Game, piece(Type, X, Y1), X, Y2, game(Board, CapturedSamurai, CapturedNinjas, State, Turn, Size)),
     add_one_captured(Type, CapturedSamurai, CapturedNinjas, NewCapturedSamurai, NewCapturedNinjas).

move(Game, step(piece(Type, X, Y1), X, Y2), game(Board, NewCapturedSamurai, NewCapturedNinjas, State, Turn, Size)) :-
     within_bounds(Game, X, Y1),
     within_bounds(Game, X, Y2),
     is_capture_move(piece(Type, _, _), X, Y2).

% vartical case
move(Game, step(piece(Type, X, Y1), X, Y2), NewGame) :-
     within_bounds(Game, X, Y1),
     within_bounds(Game, X, Y2),
     move_helper(Game, piece(Type, X, Y1), X, Y2, NewGame).

play :-
     initial_state(8, Game),
     display_game(Game),
     !,
     move(Game, step(piece(_, 3, 0), 0, 3), NewGame),
     move(NewGame, step(piece(_, 0, 0), 0, 7), NewGame2),
     display_game(NewGame2).

% make type = turn in game
