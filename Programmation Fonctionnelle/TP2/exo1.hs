import Prelude hiding (product, length, init, (++), insert, isort)

-- Calcule le produit des nombres d'une liste 
product :: Num a => [a] -> a 
product [] = 1
product (n:ns) = n * product ns

-- Calcule la longueur d'une liste 
length :: [a] -> Int
length [] = 0
length (_:xs) = 1 + length(xs)

-- Renvoie une liste sans le dernier élément 
init :: [a] -> [a]
init (x:[]) = []
init (x:xs) = [x] ++ init xs

-- Correction du prof pour init 
initProf :: [a] -> [a] 
initProf [_] = []
initProf (x:xs) = x : initProf xs 

-- Opérateur de concaténation de deux listes en une seule liste 
(++) :: [a] -> [a] -> [a]
(++) [] x = x 
(++) (x:xs) y = x:(xs ++ y)

-- Correction du prof pour (++)
-- (++) :: [a] -> [a] -> [a]
-- [] ++ ys = ys 
-- (x:xs) ++ ys = x:(xs ++ ys)

-- Insertion d'un élément dans une liste déjà ordonnée  
insert :: Ord a => a -> [a] -> [a]
insert a [] = [a]
insert a (x:xs) 
     | (a <= x) = (a:x:xs)
     | otherwise = [x] ++ insert a xs
     
-- Correction du prof pour insert  
-- insert :: Ord a => a -> [a] -> [a]
-- insert x [] = [x]
-- insert x (y:ys) | x <= y = x : y : ys 
--                | otherwise = y : (insert x ys)

-- Tri d'une liste par insertion 
isort :: Ord a => [a] -> [a]
isort [] = []
isort (x:xs) = insert x (isort xs)
