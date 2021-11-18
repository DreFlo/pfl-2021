import Data.Text.Internal.Read (digitToInt)
import Data.Char (chr, ord)

data BigNumber = Empty | BN BigNumber Int deriving Show

isNegative :: BigNumber -> Bool
isNegative (BN Empty x) = x < 0
isNegative (BN xs x) = isNegative xs

isPositive :: BigNumber -> Bool
isPositive = not . isNegative

minusBNHelper :: BigNumber -> BigNumber
minusBNHelper (BN Empty x) = BN Empty (-x)
minusBNHelper (BN xs x) = BN (minusBNHelper xs) x

removeLeadingZeros :: BigNumber -> BigNumber
removeLeadingZeros x
    | lengthBN x == 1 = x
    | firstBN x == 0 = removeLeadingZeros (tailBN x)
    | otherwise = x

minusBN :: BigNumber -> BigNumber
minusBN = minusBNHelper . removeLeadingZeros

firstBN :: BigNumber -> Int
firstBN (BN Empty x) = x
firstBN (BN xs _) = firstBN xs

tailBN :: BigNumber -> BigNumber
tailBN (BN Empty x) = Empty
tailBN (BN xs x) = BN (tailBN xs) x

paddBN :: BigNumber -> BigNumber -> BigNumber
paddBN (BN Empty x) (BN Empty _) = BN Empty x
paddBN (BN Empty x) (BN ys y) = BN (paddBN (BN Empty 0) ys) x
paddBN (BN xs x) (BN ys y) = BN (paddBN xs ys) x

scannerHelper :: String  -> BigNumber
scannerHelper [] = Empty
scannerHelper (x:xs) = BN (scannerHelper xs) (digitToInt x)

scanner :: String -> BigNumber
scanner str 
    | head str /= '-' = scannerHelper (reverse str)
    | otherwise = minusBN (scannerHelper (reverse (tail str)))

output :: BigNumber -> String
output (BN Empty x)
    | x < 0 = ['-', chr (abs x + ord '0')]
    | otherwise = [chr (x + ord '0')]
output (BN xs x) = output xs ++ [chr (x + ord '0')]

somaPosBN :: BigNumber -> BigNumber -> BigNumber
somaPosBN (BN Empty x) (BN Empty y)
    | x + y < 10 = BN Empty (x + y)
    | otherwise = BN (BN Empty ((x + y) `div` 10)) ((x + y) `mod` 10)
somaPosBN x (BN Empty y) = somaPosBN x (BN (BN Empty 0) y)
somaPosBN (BN Empty x) y = somaPosBN (BN (BN Empty 0) x) y
somaPosBN (BN xs x) (BN ys y)
    | x + y < 10 = BN (somaPosBN xs ys) (x + y)
    | otherwise = BN (somaPosBN (BN headBN (nextBN + ((x + y) `div` 10))) ys) ((x + y) `mod` 10)
    where (BN headBN nextBN) = xs

somaBN :: BigNumber -> BigNumber -> BigNumber
somaBN x y
    | isPositive x && isPositive y = removeLeadingZeros (somaPosBN x y)
    | isNegative x && isNegative y = removeLeadingZeros (minusBN (somaPosBN (minusBN x) (minusBN y)))
    | isPositive x && isNegative y = removeLeadingZeros (subBN x (minusBN y))
    | otherwise = removeLeadingZeros (subBN y (minusBN x))

orderedSubPosBN :: BigNumber -> BigNumber -> BigNumber
orderedSubPosBN (BN Empty x) (BN Empty y)
    | abs (x - y) < 10 = BN Empty (x - y)
    | otherwise = BN (BN Empty ((x - y) `div` 10)) ((x - y) `mod` 10)
orderedSubPosBN x (BN Empty y) = orderedSubPosBN x (BN (BN Empty 0) y)
orderedSubPosBN (BN Empty x) y = orderedSubPosBN (BN (BN Empty 0) x) y
orderedSubPosBN (BN xs x) (BN ys y)
    | x >= y = BN (orderedSubPosBN xs ys) (x - y)
    | x < y = BN (orderedSubPosBN (BN headBN (nextBN - 1)) ys) (10 + x - y)
    where (BN headBN nextBN) = xs

lengthBN :: BigNumber -> Int
lengthBN Empty = 0
lengthBN (BN xs x) = 1 + lengthBN xs

isGreaterEqualLength :: BigNumber -> BigNumber -> Bool
isGreaterEqualLength Empty Empty = False 
isGreaterEqualLength x y
    | firstBN x > firstBN y = True
    | firstBN x < firstBN y = False
    | otherwise = isGreaterEqualLength (tailBN x) (tailBN y)

isGreater :: BigNumber -> BigNumber -> Bool
isGreater x y
    | lengthBN x < lengthBN y = False
    | lengthBN x == lengthBN y = isGreaterEqualLength x y
    | lengthBN x > lengthBN y = isGreaterEqualLength x (paddBN y x)

subBNHelper :: BigNumber -> BigNumber -> BigNumber
subBNHelper x y
    | isGreater y x = minusBN (orderedSubPosBN y x)
    | otherwise = orderedSubPosBN x y

subBN :: BigNumber -> BigNumber -> BigNumber
subBN x y
    | isPositive x && isPositive y = removeLeadingZeros (subBNHelper x y)
    | isPositive x && isNegative y = removeLeadingZeros (somaBN x (minusBN y))
    | isNegative x && isPositive y = removeLeadingZeros (minusBN (somaBN (minusBN x) y))
    | otherwise = removeLeadingZeros (somaBN (minusBN y) x)

eBN :: BigNumber -> Int -> BigNumber
eBN x 0 = x;
eBN x n = BN (eBN x (n - 1)) 0

baseMultBN :: BigNumber -> BigNumber -> Int -> Int -> BigNumber
baseMultBN (BN Empty x) (BN Empty y) ex ey
    | x * y < 10 = BN Empty (x * y) `eBN` (ex + ey)
    | otherwise = BN (BN Empty ((x * y) `div` 10)) ((x * y) `mod` 10) `eBN` (ex + ey)
    
digitOrdBN :: BigNumber -> Int -> BigNumber
digitOrdBN (BN _ x) 0 = BN Empty x
digitOrdBN (BN xs _) n = digitOrdBN xs (n - 1)

multListBN :: BigNumber -> BigNumber -> [BigNumber]
multListBN x y = [baseMultBN (digitOrdBN x xn) (digitOrdBN y yn) xn yn | xn <- [0 .. lengthBN x - 1], yn <- [0 .. lengthBN y - 1]]

multPosBN :: BigNumber -> BigNumber -> BigNumber
multPosBN x y = foldl somaBN (BN Empty 0) (multListBN x y)

mulBN :: BigNumber -> BigNumber -> BigNumber
mulBN x y
    | isPositive x && isPositive y = multPosBN x y
    | isPositive x && isNegative y = minusBN (multPosBN x (minusBN y))
    | isNegative x && isPositive y = minusBN (multPosBN (minusBN x) y)
    | otherwise  = multPosBN (minusBN x) (minusBN y)
