module BigNumber (BigNumber, zeroBN, oneBN, twoBN, somaBN, subBN, mulBN, divBN, scanner, output, equalsBN, bigNumberToInt, safeDivBN, lesserOrEqualsBN, greaterOrEqualsBN) where

import Data.Text.Internal.Read (digitToInt)
import Data.Char (chr, ord)

data BigNumber = Empty | BN BigNumber Int deriving Show

--Checks whether the BigNumber is negative
isNegative :: BigNumber -> Bool
isNegative (BN Empty x) = x < 0
isNegative (BN xs x) = isNegative xs

--Checks whether the BigNumber is positive
isPositive :: BigNumber -> Bool
isPositive = not . isNegative

zeroBN :: BigNumber
zeroBN = BN Empty 0

oneBN :: BigNumber
oneBN = BN Empty 1

twoBN :: BigNumber
twoBN = BN Empty 2

--Calculates the additive inverse of a given BigNumber
minusBNHelper :: BigNumber -> BigNumber
minusBNHelper (BN Empty x) = BN Empty (-x)
minusBNHelper (BN xs x) = BN (minusBNHelper xs) x

--Removes leading zeros of a BigNumber
removeLeadingZeros :: BigNumber -> BigNumber
removeLeadingZeros x
    | lengthBN x == 1 = x
    | firstBN x == 0 = removeLeadingZeros (tailBN x)
    | otherwise = x

--Calculates the additive inverse of a given BigNumber after removing leading zeros
minusBN :: BigNumber -> BigNumber
minusBN = minusBNHelper . removeLeadingZeros

--Return the first digit of a BigNumber
firstBN :: BigNumber -> Int
firstBN (BN Empty x) = x
firstBN (BN xs _) = firstBN xs

--Return the given BigNumber without the first element
tailBN :: BigNumber -> BigNumber
tailBN (BN Empty x) = Empty
tailBN (BN xs x) = BN (tailBN xs) x

--Does padding to the first argument until it has the same length of the second argument
paddBN :: BigNumber -> BigNumber -> BigNumber
paddBN (BN Empty x) (BN Empty _) = BN Empty x
paddBN (BN Empty x) (BN ys y) = BN (paddBN zeroBN ys) x
paddBN (BN xs x) (BN ys y) = BN (paddBN xs ys) x

--Converts a string into BigNumber, that is going to be saved in reversed order (VER) 
scannerHelper :: String  -> BigNumber
scannerHelper [] = Empty
scannerHelper (x:xs) = BN (scannerHelper xs) (digitToInt x)

--Converts a string into a BigNumber
scanner :: String -> BigNumber
scanner str
    | head str /= '-' = scannerHelper (reverse str)
    | otherwise = minusBN (scannerHelper (reverse (tail str)))

--Converts BigNumber into a String
output :: BigNumber -> String
output (BN Empty x)
    | x < 0 = ['-', chr (abs x + ord '0')]
    | otherwise = [chr (x + ord '0')]
output (BN xs x) = output xs ++ [chr (x + ord '0')]

somaPosBN :: BigNumber -> BigNumber -> BigNumber
-- Last digit of a BN
somaPosBN (BN Empty x) (BN Empty y)
    -- Result is a single digit BN
    | x + y < 10 = BN Empty (x + y)
    -- result is a two digit BN
    | otherwise = BN (BN Empty ((x + y) `div` 10)) ((x + y) `mod` 10)
-- If left BN has run out of digits add a left 0 and run again
somaPosBN x (BN Empty y) = somaPosBN x (BN zeroBN y)
-- If right BN has run out of digits add a left 0 and run again
somaPosBN (BN Empty x) y = somaPosBN (BN zeroBN x) y
-- Recursive case
somaPosBN (BN xs x) (BN ys y)
    -- No carry is needed
    | x + y < 10 = BN (somaPosBN xs ys) (x + y)
    -- If carry is needed
    | otherwise = BN (somaPosBN (BN headBN (nextBN + ((x + y) `div` 10))) ys) ((x + y) `mod` 10)
    where (BN headBN nextBN) = xs

somaBN :: BigNumber -> BigNumber -> BigNumber
-- Transform into equivalent sum with positive numbers
somaBN x y
    | isPositive x && isPositive y = removeLeadingZeros (somaPosBN x y)
    | isNegative x && isNegative y = removeLeadingZeros (minusBN (somaPosBN (minusBN x) (minusBN y)))
    | isPositive x && isNegative y = removeLeadingZeros (subBN x (minusBN y))
    | otherwise = removeLeadingZeros (subBN y (minusBN x))

orderedSubPosBN :: BigNumber -> BigNumber -> BigNumber
-- Last digit of a BigNumber
orderedSubPosBN (BN Empty x) (BN Empty y)
    -- Result is a single digit BigNumber
    | abs (x - y) < 10 = BN Empty (x - y)
    -- Result is two digit BigNumber
    | otherwise = BN (BN Empty ((x - y) `div` 10)) ((x - y) `mod` 10)
-- If left BN has run out of digits add a left 0 and run again
orderedSubPosBN x (BN Empty y) = orderedSubPosBN x (BN zeroBN y)
-- If right BN has run out of digits add a left 0 and run again
orderedSubPosBN (BN Empty x) y = orderedSubPosBN (BN zeroBN x) y
-- Recursive case
orderedSubPosBN (BN xs x) (BN ys y)
    -- No carry is needed
    | x >= y = BN (orderedSubPosBN xs ys) (x - y)
    -- If carry is needed remove 1 from xs and add 10 to x
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

-- If y > x do - (y - x)
subBNHelper :: BigNumber -> BigNumber -> BigNumber
subBNHelper x y
    | y `greaterBN` x = minusBN (orderedSubPosBN y x)
    | otherwise = orderedSubPosBN x y

-- Change subtraction to equivalent with positive numbers
subBN :: BigNumber -> BigNumber -> BigNumber
subBN x y
    | isPositive x && isPositive y = removeLeadingZeros (subBNHelper x y)
    | isPositive x && isNegative y = removeLeadingZeros (somaBN x (minusBN y))
    | isNegative x && isPositive y = removeLeadingZeros (minusBN (somaBN (minusBN x) y))
    | otherwise = removeLeadingZeros (somaBN (minusBN y) x)

-- Equivalent to x * 10^n
eBN :: BigNumber -> Int -> BigNumber
eBN x 0 = x;
eBN x n = removeLeadingZeros (BN (eBN x (n - 1)) 0)

-- Equivalent to (x * 10^ex) * (y * 10^ey)
baseMulBN :: BigNumber -> BigNumber -> Int -> Int -> BigNumber
baseMulBN (BN Empty x) (BN Empty y) ex ey
    -- Result of x * y is a single digit number
    | x * y < 10 = BN Empty (x * y) `eBN` (ex + ey)
    -- Result of x * y is a two digit number
    | otherwise = BN (BN Empty ((x * y) `div` 10)) ((x * y) `mod` 10) `eBN` (ex + ey)

-- Get the n-th digit of a BigNumber, counting from the right and starting at 0
digitOrdBN :: BigNumber -> Int -> BigNumber
digitOrdBN (BN _ x) 0 = BN Empty x
digitOrdBN (BN xs _) n = digitOrdBN xs (n - 1)

-- Create a list of all the smaller multiplications of a multi-digit multiplication that add together into the result
mulListBN :: BigNumber -> BigNumber -> [BigNumber]
mulListBN x y = [baseMulBN (digitOrdBN x xn) (digitOrdBN y yn) xn yn | yn <- [0 .. lengthBN y - 1], xn <- [0 .. lengthBN x - 1]]

-- Reduce list of smaller multiplication results with sum
mulPosBN :: BigNumber -> BigNumber -> BigNumber
mulPosBN x y = foldl somaBN zeroBN (mulListBN x y)

mulBN :: BigNumber -> BigNumber -> BigNumber
-- Change to equivalent multiplication with positive numbers
mulBN x y
    | isPositive x && isPositive y = mulPosBN x y
    | isPositive x && isNegative y = minusBN (mulPosBN x (minusBN y))
    | isNegative x && isPositive y = minusBN (mulPosBN (minusBN x) y)
    | otherwise  = mulPosBN (minusBN x) (minusBN y)

equalsBN :: BigNumber -> BigNumber -> Bool
equalsBN Empty Empty = True;
equalsBN (BN xs x) (BN ys y)
    -- If length is different, numbers are different
    | lengthBN (BN xs x) /= lengthBN (BN ys y) = False
    -- If a number differs, numbers are different
    | x /= y = False
    -- Call with xs and ys
    | otherwise = equalsBN xs ys

greaterOrEqualsBN :: BigNumber -> BigNumber -> Bool
greaterOrEqualsBN x y = x `greaterBN` y || x `equalsBN` y

lesserOrEqualsBN :: BigNumber -> BigNumber -> Bool
lesserOrEqualsBN x y = not (x `greaterBN` y) || x `equalsBN` y

-- Naive division, only for smaller numbers
naiveDivBN :: BigNumber -> BigNumber -> BigNumber -> (BigNumber, BigNumber)
naiveDivBN x y q
    -- If y times q is greater than x then result is q - 1 and calculate the remainder
    | mulBN y q `greaterBN` x = (subBN q oneBN, subBN x (mulBN y (subBN q oneBN)))
    -- Otherwise call with q + 1
    | otherwise = naiveDivBN x y (somaBN q oneBN)

-- Helper for divBN, does the heavy lifting
divBNHelper :: BigNumber -> BigNumber -> BigNumber -> BigNumber -> (BigNumber, BigNumber)
-- If x has been entirely consumed then division is over, return tuple with quotient and remainder
divBNHelper Empty _ q r = (q, r)
-- Follows manual division algorithm
-- Take r multiply it by 10 and add the first digit of x and naively divide the result by y 
-- (starting with quotient accumulator at 1) and store the result in q_div and r_div 
-- Call divBNHelper with the remaining digits of x, y, the previous quotient times 10 plus q_div, and r_div 
divBNHelper x y q r = divBNHelper (tailBN x) y (removeLeadingZeros (BN q q_div)) (removeLeadingZeros r_div)
    where (BN _ q_div, r_div) = naiveDivBN (removeLeadingZeros (BN r (firstBN x))) y oneBN

-- Divide BigNumbers
divBN :: BigNumber -> BigNumber -> (BigNumber, BigNumber)
-- Call divBNHelper with x, y and q and r accumulators starting at zero
divBN x y = divBNHelper x y zeroBN zeroBN

--Transforms a BigNumber into an Int
bigNumberToInt :: BigNumber -> Int
-- If argument is a single digit BigNumber, returns the digit
bigNumberToInt (BN Empty x) = x
bigNumberToInt (BN xs x)
    -- Else if argument is negative and multi-digit, reduce to positive case
    | isNegative (BN xs x) = - bigNumberToInt (minusBN (BN xs x))
    -- Otherwise multiply the Int transformation of xs by 10 and add x
    | otherwise = bigNumberToInt xs * 10 + x

-- Division with safeguard for divide by 0
safeDivBN :: BigNumber -> BigNumber -> Maybe (BigNumber, BigNumber)
safeDivBN x y
    -- If y equals 0 returns Nothing
    | y `equalsBN` zeroBN = Nothing
    -- Otherwise calls regular division and returns that value
    | otherwise = Just (divBN x y)
