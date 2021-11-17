import Data.Text.Internal.Read (digitToInt)
import Data.Char (chr, ord)

data BigNumber = Empty | BN BigNumber Int deriving Show

isNegative :: BigNumber -> Bool
isNegative (BN Empty x) = x < 0
isNegative (BN xs x) = isNegative xs

isPositive :: BigNumber -> Bool
isPositive = not . isNegative

minusBN :: BigNumber -> BigNumber
minusBN (BN Empty x) = BN Empty (-x)
minusBN (BN xs x) = BN (minusBN xs) x

firstBN :: BigNumber -> Int
firstBN (BN Empty x) = x
firstBN (BN xs _) = firstBN xs

tailBN :: BigNumber -> BigNumber
tailBN (BN Empty x) = Empty
tailBN (BN xs x) = BN (tailBN xs) x

paddBN :: BigNumber -> BigNumber -> BigNumber
paddBN (BN Empty x) (BN Empty _) = BN Empty x
paddBN (BN Empty x) (BN ys y) = BN (paddBN (BN Empty 0) ys) x

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
    | isPositive x && isPositive y = somaPosBN x y
    | isNegative x && isNegative y = minusBN (somaPosBN (minusBN x) (minusBN y))
    | isPositive x && isNegative y = subPosBN x (minusBN y)
    | otherwise = subPosBN y (minusBN x)

subPosBN :: BigNumber -> BigNumber -> BigNumber
subPosBN (BN Empty x) (BN Empty y)
    | abs (x - y) < 10 = BN Empty (x - y)
    | otherwise = BN (BN Empty ((x - y) `div` 10)) ((x - y) `mod` 10)
subPosBN x (BN Empty y) = subPosBN x (BN (BN Empty 0) y)
subPosBN (BN Empty x) y = subPosBN (BN (BN Empty 0) x) y
subPosBN (BN xs x) (BN ys y)
    | x >= y = BN (subPosBN xs ys) (x - y)
    | x < y = BN (subPosBN (BN headBN (nextBN - 1)) ys) (10 + x - y)
    where (BN headBN nextBN) = xs

lengthBN :: BigNumber -> Int
lengthBN Empty = 0
lengthBN (BN xs x) = 1 + lengthBN xs

{-
isBigger :: BigNumber -> BigNumber -> Bool
isBigger x y
    | isPositive x && isNegative y = True 
    | isNegative x && isPositive y = False
    | isPositive x && isPositive y && lengthBN x > lengthBN y = True
    | isPositive x && isPositive y && lengthBN x < lengthBN y = False
    | isPositive x && isPositive y && lengthBN x == lengthBN y = if firstBN x > first
-}

compareUntilDifferent :: BigNumber -> BigNumber -> Bool
compareUntilDifferent Empty Empty = False 
compareUntilDifferent x y
    | firstBN x > firstBN y = True
    | firstBN x < firstBN y = False
    | otherwise = compareUntilDifferent (tailBN x) (tailBN y)

subBN :: BigNumber -> BigNumber -> BigNumber
subBN x y
    | isPositive x && isPositive y = subPosBN x y
    | isPositive x && isNegative y = somaPosBN x (minusBN y)
    | isNegative x && isPositive y = minusBN (somaPosBN (minusBN x) y)
    | otherwise = subPosBN (minusBN y) (minusBN x)