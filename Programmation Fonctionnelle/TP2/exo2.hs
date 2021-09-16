import Prelude hiding (drop, take)

-- Paire / Impaire 
paire :: Int -> Bool 
paire 0 = True -- On considère que 0 est paire. 
paire x = impaire (x-1)

impaire :: Int -> Bool
impaire 0 = False
impaire x = paire (x-1)

-- Supprime les n premiers éléments d'une liste 
drop :: Int -> [a] -> [a]
drop _ [] = []
drop 0 x = x
drop n (x:xs) = drop (n-1) xs

-- Garde les n premiers éléments d'une liste 
take :: Int -> [a] -> [a]
take _ [] = []
take 0 x = []
take n (x:xs) = x : take (n-1) xs 

-- Coupe une liste en deux et retourne un tuple d'arité 2 
halve :: [a] -> ([a],[a])
halve [] = ([],[])
halve x = (take ((length x) `div` 2) x, drop ((length x) `div` 2) x)
-- Alternative : halve xs = (take n xs, drop n xs) where n = (length xs) `div` 2

-- Fusionne 2 listes triées en une seule liste triée 
merge :: Ord a => [a] -> [a] -> [a]
merge [] x = x
merge x [] = x
merge (x:xs) (y:ys) 
     | x <= y = x:merge xs (y:ys)
     | otherwise = y:merge (x:xs) ys

-- Tri par fusion 
msort :: Ord a => [a] -> [a]
msort [] = []
msort [x] = [x]
msort xs = merge (msort rs) (msort ls) 
      where (rs, ls) = halve xs


