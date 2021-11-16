import Data.Text.Internal.Read (digitToInt)
import Data.Char (chr, ord)
type BigNumber = [Int]

isNegative :: BigNumber -> Bool
isNegative bn = last bn < 0

scanner :: String -> BigNumber
scanner str
    | head str == '-' = reverse ((- head newBN) : tail newBN)
    | otherwise = reverse (map digitToInt str)
    where newBN = map digitToInt (tail str)

output :: BigNumber -> String
output bn
    | isNegative bn = '-' : str
    | otherwise = str
    where  str = reverse [chr (abs x + ord '0') | x <- bn]

normalize :: BigNumber -> BigNumber
normalize [] = []
normalize [x] = if x >= 10 then [x `mod` 10, x `div` 10] else [x]
normalize (l:lst)
    | l < 10 = l : normalize lst
    | l >= 10 = (l `mod` 10) : normalize (head lst + l `div` 10 : tail lst)

zipBigNumbers :: (Int -> Int -> Int) -> BigNumber -> BigNumber -> BigNumber
zipBigNumbers _ [] [] = []
zipBigNumbers _ lhs [] = lhs
zipBigNumbers _ [] rhs = rhs
zipBigNumbers f (l:lhs) (r:rhs) = f l r : zipBigNumbers f lhs rhs

somaBN :: BigNumber -> BigNumber -> BigNumber
somaBN x y = normalize (zipBigNumbers (+) x y)