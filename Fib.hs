fibRec :: (Integral a) => a -> a
fibRec 0 = 0
fibRec 1 = 1
fibRec n
    | n < 0 = error "Negative number"
    | otherwise = fibRec(n - 2) + fibRec(n - 1)

fibLista :: (Integral a) => a -> a
fibLista n =  lista !! fromIntegral n
    where lista = 0 : 1 : [lista !! (x -2) + lista !! (x - 1) | x <- [2.. (fromIntegral n)]]

fibHelper :: Integral a => Int -> Int -> [a] -> a
fibHelper n c lst
    | n + 1 == c = lst !! n
    | otherwise = fibHelper n (c + 1) (lst ++ [last lst + last (init lst)])

fibLista' :: Integral a => Int -> a
fibLista' n = fibHelper n 2 [0, 1]

fibListaInfinita :: (Integral a) => a -> a
fibListaInfinita n = lista !! fromIntegral n
    where lista = 0 : 1 : zipWith (+) lista (tail lista)