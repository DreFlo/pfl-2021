module BigNumber (BigNumber(Empty, BN), zeroBN, oneBN, twoBN, somaBN, subBN, mulBN, divBN, scanner, output, equalsBN, bigNumberToInt) where

import Data.Text.Internal.Read (digitToInt)
import Data.Char (chr, ord)

data BigNumber = Empty | BN BigNumber Int deriving Show

isNegative :: BigNumber -> Bool
isNegative (BN Empty x) = x < 0
isNegative (BN xs x) = isNegative xs

isPositive :: BigNumber -> Bool
isPositive = not . isNegative

zeroBN :: BigNumber
zeroBN = BN Empty 0

oneBN :: BigNumber
oneBN = BN Empty 1

twoBN :: BigNumber
twoBN = BN Empty 2

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
paddBN (BN Empty x) (BN ys y) = BN (paddBN zeroBN ys) x
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
somaPosBN x (BN Empty y) = somaPosBN x (BN zeroBN y)
somaPosBN (BN Empty x) y = somaPosBN (BN zeroBN x) y
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
orderedSubPosBN x (BN Empty y) = orderedSubPosBN x (BN zeroBN y)
orderedSubPosBN (BN Empty x) y = orderedSubPosBN (BN zeroBN x) y
orderedSubPosBN (BN xs x) (BN ys y)
    | x >= y = BN (orderedSubPosBN xs ys) (x - y)
    | x < y = BN (orderedSubPosBN (BN headBN (nextBN - 1)) ys) (10 + x - y)
    where (BN headBN nextBN) = xs

lengthBN :: BigNumber -> Int
lengthBN Empty = 0
lengthBN (BN xs x) = 1 + lengthBN xs

greaterEqualLengthBN :: BigNumber -> BigNumber -> Bool
greaterEqualLengthBN Empty Empty = False
greaterEqualLengthBN x y
    | firstBN x > firstBN y = True
    | firstBN x < firstBN y = False
    | otherwise = greaterEqualLengthBN (tailBN x) (tailBN y)

greaterBN :: BigNumber -> BigNumber -> Bool
greaterBN x y
    | lengthBN x < lengthBN y = False
    | lengthBN x == lengthBN y = greaterEqualLengthBN x y
    | lengthBN x > lengthBN y = greaterEqualLengthBN x (paddBN y x)

subBNHelper :: BigNumber -> BigNumber -> BigNumber
subBNHelper x y
    | greaterBN y x = minusBN (orderedSubPosBN y x)
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

baseMulBN :: BigNumber -> BigNumber -> Int -> Int -> BigNumber
baseMulBN (BN Empty x) (BN Empty y) ex ey
    | x * y < 10 = BN Empty (x * y) `eBN` (ex + ey)
    | otherwise = BN (BN Empty ((x * y) `div` 10)) ((x * y) `mod` 10) `eBN` (ex + ey)

digitOrdBN :: BigNumber -> Int -> BigNumber
digitOrdBN (BN _ x) 0 = BN Empty x
digitOrdBN (BN xs _) n = digitOrdBN xs (n - 1)

mulListBN :: BigNumber -> BigNumber -> [BigNumber]
mulListBN x y = [baseMulBN (digitOrdBN x xn) (digitOrdBN y yn) xn yn | xn <- [0 .. lengthBN x - 1], yn <- [0 .. lengthBN y - 1]]

mulPosBN :: BigNumber -> BigNumber -> BigNumber
mulPosBN x y = foldl somaBN zeroBN (mulListBN x y)

mulBN :: BigNumber -> BigNumber -> BigNumber
mulBN x y
    | isPositive x && isPositive y = mulPosBN x y
    | isPositive x && isNegative y = minusBN (mulPosBN x (minusBN y))
    | isNegative x && isPositive y = minusBN (mulPosBN (minusBN x) y)
    | otherwise  = mulPosBN (minusBN x) (minusBN y)

equalsBN :: BigNumber -> BigNumber -> Bool
equalsBN Empty Empty = True;
equalsBN (BN xs x) (BN ys y)
    | lengthBN (BN xs x) /= lengthBN (BN ys y) = False
    | x /= y = False
    | otherwise = equalsBN xs ys

greaterOrEqualsBN :: BigNumber -> BigNumber -> Bool
greaterOrEqualsBN x y = x `greaterBN` y || x `equalsBN` y

lesserOrEqualsBN :: BigNumber -> BigNumber -> Bool
lesserOrEqualsBN x y = not (x `greaterBN` y) || x `equalsBN` y

baseDivBN :: BigNumber -> BigNumber -> BigNumber -> (BigNumber, BigNumber)
baseDivBN x y q
    | mulBN y q `greaterBN` x = (subBN q oneBN, subBN x (mulBN y (subBN q oneBN)))
    | otherwise = baseDivBN x y (somaBN q oneBN)

divBNHelper :: BigNumber -> BigNumber -> BigNumber -> BigNumber -> (BigNumber, BigNumber)
divBNHelper Empty _ q r = (q, r)
divBNHelper x y q r = divBNHelper (tailBN x) y (removeLeadingZeros (BN q q_div)) (removeLeadingZeros r_div)
    where (BN _ q_div, r_div) = baseDivBN (removeLeadingZeros (BN r (firstBN x))) y oneBN

divBN :: BigNumber -> BigNumber -> (BigNumber, BigNumber)
divBN x y = divBNHelper x y zeroBN zeroBN

bigNumberToInt :: BigNumber -> Int
bigNumberToInt (BN Empty x) = x
bigNumberToInt (BN xs x) = bigNumberToInt xs * 10 + x