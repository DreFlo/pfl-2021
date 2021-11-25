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

--isNegative :: BigNumber -> Bool
isNegative (scanner "12")
isNegative (scanner "0")
isNegative (scanner "-12")

--isPositive :: BigNumber -> Bool
isPositive (scanner "12")
isPositive (scanner "0") -- > ??
isPositive (scanner "-12")

--FALTA
--minusBNHelper :: BigNumber -> BigNumber
output (minusBNHelper (scanner "-12"))

--removeLeadingZeros :: BigNumber -> BigNumber
output (removeLeadingZeros (scanner "000012"))
output (removeLeadingZeros (scanner "100002"))
output (removeLeadingZeros (scanner "120000"))

--minusBN :: BigNumber -> BigNumber
output (minusBN (scanner "-12"))
output (minusBN (scanner "12"))

--firstBN :: BigNumber -> Int
firstBN (scanner "-12")
firstBN (scanner "12")

--tailBN :: BigNumber -> BigNumber
output (tailBN (scanner "1245"))
output (tailBN (scanner "12"))

--paddBN :: BigNumber -> BigNumber -> BigNumber
output (paddBN (scanner "12") (scanner "123"))
output (paddBN (scanner "12") (scanner "12367"))
output (paddBN (scanner "12") (scanner "1")) -- > este caso dá erro

--FALTA
--scannerHelper :: String  -> BigNumber
output (scannerHelper (scanner "-12"))

--scanner :: String -> BigNumber
output (scanner "-12")
output (scanner "12")

--testes do output estão incluidos nos outros testes

--Andre

-- somaPosBN

-- output (somaPosBN (scanner "1") (scanner "0"))
-- output (somaPosBN (scanner "1") (scanner "1"))
-- output (somaPosBN (scanner "0") (scanner "1"))

-- somaBN

-- output (somaBN (scanner "1") (scanner "0"))
-- output (somaBN (scanner "1") (scanner "1"))
-- output (somaBN (scanner "0") (scanner "1"))
-- output (somaBN (scanner "123") (scanner "-123"))
-- output (somaBN (scanner "-123") (scanner "-123"))
-- output (somaBN (scanner "-123") (scanner "123"))

-- orderedSubPosBN

-- output (orderedSubPosBN (scanner "1") (scanner "0"))
-- output (orderedSubPosBN (scanner "1") (scanner "1"))

-- lengthBN

-- lengthBN (scanner "1234567890")

-- greaterEqualLengthBN

-- greaterEqualLengthBN (scanner "9") (scanner "1")
-- greaterEqualLengthBN (scanner "9") (scanner "9")
-- greaterEqualLengthBN (scanner "1") (scanner "9")

-- greaterBN

-- greaterBN (scanner "1") (scanner "10")
-- greaterBN (scanner "1") (scanner "1")
-- greaterBN (scanner "10") (scanner "1")

-- subBNHelper

-- output (subBNHelper (scanner "2") (scanner "1"))
-- output (subBNHelper (scanner "1") (scanner "2"))

-- subBN

-- output (subBN (scanner "1") (scanner "0"))
-- output (subBN (scanner "1") (scanner "1"))
-- output (subBN (scanner "0") (scanner "1"))
-- output (subBN (scanner "123") (scanner "-123"))
-- output (subBN (scanner "-123") (scanner "-123"))
-- output (subBN (scanner "-123") (scanner "123"))

-- baseMulBN

-- output (baseMulBN (scanner "1") (scanner "3") 0 0)
-- output (baseMulBN (scanner "9") (scanner "9") 1 0)

-- digitOrdBN

-- digitOrdBN (scanner "123") 0
-- digitOrdBN (scanner "123") 1

-- mulListBN

-- mulListBN (scanner "20") (scanner "13")

-- mulPosBN

-- output (mulBN (scanner "1") (scanner "1"))
-- output (mulBN (scanner "1") (scanner "0"))
-- output (mulBN (scanner "0") (scanner "1"))
-- output (mulBN (scanner "123") (scanner "123"))

-- mulBN

-- output (mulBN (scanner "1") (scanner "1"))
-- output (mulBN (scanner "1") (scanner "0"))
-- output (mulBN (scanner "0") (scanner "1"))
-- output (mulBN (scanner "123") (scanner "123"))
-- output (mulBN (scanner "-123") (scanner "123"))
-- output (mulBN (scanner "123") (scanner "-123"))
-- output (mulBN (scanner "-123") (scanner "-123"))

-- equalsBN

-- equalsBN (scanner "1") (scanner "10")
-- equalsBN (scanner "1") (scanner "1")
-- equalsBN (scanner "10") (scanner "1")

-- greaterOrEqualsBN

-- greaterOrEqualsBN (scanner "1") (scanner "10")
-- greaterOrEqualsBN (scanner "1") (scanner "1")
-- greaterOrEqualsBN (scanner "10") (scanner "1")

-- lesserOrEqualsBN

-- lesserOrEqualsBN (scanner "1") (scanner "10")
-- lesserOrEqualsBN (scanner "1") (scanner "1")
-- lesserOrEqualsBN (scanner "10") (scanner "1")

-- naiveDivBN

-- naiveDivBN (scanner "12") (scanner "3") (scanner "1")
-- naiveDivBN (scanner "9") (scanner "3") (scanner "1")

-- divBN

-- divBN (scanner "10") (scanner "1")
-- divBN (scanner "10") (scanner "10")
-- divBN (scanner "10") (scanner "100")
-- divBN (scanner "77") (scanner "4")

-- bigNumberToInt

-- bigNumberToInt (scanner "0")
-- bigNumberToInt (scanner "10")
-- bigNumberToInt (scanner "-10")

-- safeDivBN

-- safeDivBN (scanner "1") (scanner "0")
-- safeDivBN (scanner "1") (scanner "1")