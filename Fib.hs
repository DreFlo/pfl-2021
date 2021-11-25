import BigNumber (BigNumber, oneBN, twoBN, somaBN, subBN, equalsBN, zeroBN, scanner, output, bigNumberToInt, lesserOrEqualsBN, greaterOrEqualsBN)

--Utiliza recursão para calcular o número de Fibonacci
fibRec :: (Integral a) => a -> a
fibRec 0 = 0
fibRec 1 = 1
fibRec n
    | n < 0 = error "Negative number"
    | otherwise = fibRec(n - 2) + fibRec(n - 1)

--Calcula o fibonacci usando a lista finita em que cada elemento é a soma dos ultimos dois elementos, sendo que o index n na lista
--retorna o respetivo fibonacci 
fibLista :: (Integral a) => a -> a
fibLista n =  lista !! fromIntegral n
    where lista = 0 : 1 : [lista !! (x -2) + lista !! (x - 1) | x <- [2.. (fromIntegral n)]]

--Guarda num lista dada como argumento o número de Fibonacci i no index i utilizando os dois últimos números da lista 
--n representa o comprimento da lista e c é o numero fibonacii que queremos calcular  
fibHelper :: Integral a => Int -> Int -> [a] -> a
fibHelper n c lst
    | n == 0 = 0
    | n + 1 == c = lst !! n
    | otherwise = fibHelper n (c + 1) (lst ++ [last lst + last (init lst)])

--Calcula o fibonacci n com ajuda de fibHelper 
fibLista' :: Integral a => Int -> a
fibLista' n = fibHelper n 2 [0, 1]

--Calcula o fibonacci usando a lista infinita em que cada elemento é a soma dos ultimos dois elementos, sendo que o index n na lista
--retorna o respetivo fibonacci 
fibListaInfinita :: (Integral a) => a -> a
fibListaInfinita n = lista !! fromIntegral n
    where lista = 0 : 1 : zipWith (+) lista (tail lista)

--Semelhante a fibRec, mas calculando o fibonacci de um BigNumber 
fibRecBN :: BigNumber -> BigNumber
fibRecBN n
    |n `equalsBN` zeroBN = zeroBN
    |n `equalsBN` oneBN = oneBN
    |otherwise = fibRecBN(n `subBN` twoBN) `somaBN` fibRecBN(n `subBN` oneBN)

--Semelhante a fibLista, mas calculando o fibonacci de um BigNumber 
fibListaBN :: BigNumber -> BigNumber
fibListaBN n = lista !! bigNumberToInt n
    where lista = zeroBN : oneBN : [(lista !! (x - 2)) `somaBN` (lista !! (x - 1)) | x <- [2.. (bigNumberToInt n)]]

--Semelhante a fibListaInfinita, mas calculando o fibonacci de um BigNumber 
fibListaInfinitaBN :: BigNumber -> BigNumber
fibListaInfinitaBN n = lista !! bigNumberToInt n
    where lista = zeroBN : oneBN : zipWith somaBN lista (tail lista)