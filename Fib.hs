import BigNumber (BigNumber, oneBN, twoBN, somaBN, subBN, equalsBN, zeroBN, scanner, output, bigNumberToInt, lesserOrEqualsBN, greaterOrEqualsBN)

--Calculate n-th fibonacci number using recursion
fibRec :: (Integral a) => a -> a
fibRec 0 = 0
fibRec 1 = 1
fibRec n
    | n < 0 = error "Negative number"
    | otherwise = fibRec(n - 2) + fibRec(n - 1)

--Calculate n-th fibonacci number using a finite list comprehension
--where each number is the sum of the two previous numbers
fibLista :: (Integral a) => a -> a
fibLista n =  lista !! fromIntegral n
    where lista = 0 : 1 : [lista !! (x -2) + lista !! (x - 1) | x <- [2.. (fromIntegral n)]]

--Calculate n-th fibonacci number using a list accumulator and recursion where with each
--recursive call the new fibonacci number is appended to the list until it is sufficiently long, then last value is returned 
fibHelper :: Integral a => Int -> Int -> [a] -> a
fibHelper n c lst
    | n == 0 = 0
    | n + 1 == c = lst !! n
    | otherwise = fibHelper n (c + 1) (lst ++ [last lst + last (init lst)])

--Calculate n-th fibonacci number by calling fibHelper with accumulator list starting at [0, 1]
fibLista' :: Integral a => Int -> a
fibLista' n = fibHelper n 2 [0, 1]

--Calculate n-th fibonacci number using an infinite list comprehension where each number is the sum of the two previous numbers 
fibListaInfinita :: (Integral a) => a -> a
fibListaInfinita n = lista !! fromIntegral n
    where lista = 0 : 1 : zipWith (+) lista (tail lista)

--Calculate n-th fibonacci number using recursion using BigNumber for argument and return value 
fibRecBN :: BigNumber -> BigNumber
fibRecBN n
    |n `equalsBN` zeroBN = zeroBN
    |n `equalsBN` oneBN = oneBN
    |otherwise = fibRecBN(n `subBN` twoBN) `somaBN` fibRecBN(n `subBN` oneBN)

--Calculate n-th fibonacci number using a finite list comprehension where each number is the sum of
--the two previous numbers using BigNumber for argument and return value
fibListaBN :: BigNumber -> BigNumber
fibListaBN n = lista !! bigNumberToInt n
    where lista = zeroBN : oneBN : [(lista !! (x - 2)) `somaBN` (lista !! (x - 1)) | x <- [2.. (bigNumberToInt n)]]

--Calculate n-th fibonacci number using an infinite list comprehension where each number is
--the sum of the two previous numbers using BigNumber for argument and return valuefibListaInfinitaBN :: BigNumber -> BigNumber
fibListaInfinitaBN n = lista !! bigNumberToInt n
    where lista = zeroBN : oneBN : zipWith somaBN lista (tail lista)