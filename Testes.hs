--Sara

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