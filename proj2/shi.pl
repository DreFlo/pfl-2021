/**
piece(Type, X, Y)

Type - s - samurai
     - n - ninja
     - b - blank

0 <= X <= 7

0 <= Y <= 7
*/
initRow(0, _, _, []).

initRow(Size, Y, Type, [piece(Type, X, Y) | Tail]) :-
     NewSize is Size - 1,
     X is 8 - Size,
     initRow(NewSize, Y, Type, Tail).

initMiddle(Size, Number, Number, Result) :-
     initRow(Size, Number, b, Result).

initMiddle(Size, Number, Y, [Head | Tail]) :-
     NewY is Y + 1,
     initRow(Size, Y, b, Head),
     initMiddle(Size, Number, NewY, Tail).

initBoard(Size, [FirstRow | Tail]) :-
     LastY is Size - 1,
     Number is Size - 2,
     initRow(Size, 0, s, FirstRow),
     initMiddle(Size, Number, 1, Middle),
     initRow(Size, LastY, n, LastRow),
     append(Middle, LastRow, Tail).

writePiece(piece(s, _, _)) :-
     write('|S').

writePiece(piece(n, _, _)) :-
     write('|N').

writePiece(piece(b, _, _)) :-
     write('| ').

writeLine([]) :-
     write('|\n').

writeLine([H | T]) :-
     writePiece(H),
     writeLine(T).

writeBorder :-
     write('+-+-+-+-+-+-+-+-+\n').

writeBoard([]) :-
     writeBorder.

writeBoard([H | T]) :-
     writeBorder,
     writeLine(H),
     writeBoard(T).

%game(Board, CapturedSamurai, CapturedNinjas, State, Turn)
%TODO alter to State to start after
initial_State(Size, game(Board, 0, 0, playing, samurai)) :-
     initBoard(Size, Board).

getTurnString(samurai, 'Samurai').

getTurnString(ninja, 'Ninja').

display_Game(game(Board, CapturedSamurai, CapturedNinjas, playing, Turn)) :-
     getTurnString(Turn, TurnString),
     format('~w\'s turn\n-----------------\n\nPoints - ~d\n', [TurnString, CapturedNinjas]),
     writeBoard(Board),
     format('Points - ~d\n', [CapturedSamurai]).

play :-
     initial_State(8, Game),
     display_Game(Game).
