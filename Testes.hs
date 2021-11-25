--Sara

--fibRec :: (Integral a) => a -> a
fibRec 0
fibRec 1
fibRec 20

--fibLista :: (Integral a) => a -> a
fibLista 0
fibLista 1
fibLista 20

--fibHelper :: Integral a => Int -> Int -> [a] -> a
fibHelper 5 2 [0,1]
fibHelper 8 5 [0,1,1,2,3]
fibHelper 8 3 [0,1,1]

--
--fibLista' :: Integral a => Int -> a 
fibLista' 8
fibLista' 5

--fibListaInfinita :: (Integral a) => a -> a
fibListaInfinita 8
fibListaInfinita 5

--fibRecBN :: BigNumber -> BigNumber
output (fibRecBN (scanner "8"))
output (fibRecBN (scanner "5"))

--fibListaBN :: BigNumber -> BigNumber
output (fibListaBN (scanner "8"))
output (fibListaBN (scanner "5"))

--fibListaInfinitaBN :: BigNumber -> BigNumber
output (fibListaInfinitaBN (scanner "8"))
output (fibListaInfinitaBN (scanner "5"))

--Andre
