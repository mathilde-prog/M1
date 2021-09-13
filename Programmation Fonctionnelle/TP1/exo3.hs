-- Fonction qui, pour 4 nombres, renvoie True si les nombres sont égaux et False sinon
nbegaux :: Int -> Int -> Int -> Int -> Bool 
nbegaux a b c d 
     | (a == b) && (b == c) && (c == d) = True
     | otherwise = False
     
-- Fonction qui, pour 4 nombres, retourne le plus grand des 4
maxi :: Int -> Int -> Int -> Int -> Int
maxi a b c d 
   | (a >= b) && (a >= c) && (a >= d) = a 
   | (b >= a) && (b >= c) && (b >= d) = b 
   | (c >= a) && (c >= b) && (c >= d) = c
   | (d >= a) && (d >= b) && (d >= c) = d 
   
-- CORRECTION DU PROF
egaux4 :: Eq a => a -> a -> a -> a -> Bool
egaux4 a b c d = a == b && b == c && c == d
  
-- La fonction max (équivalente à max2) existe déjà
-- Exemple d'implémentation de max2 (== max)
max2 :: Ord a => a -> a -> a 
max2 a b | a >= b = a 
           | otherwise = b 
                      
max4 :: Ord a => a -> a -> a -> a -> a 
max4 a b c d = max2 (max2 a b) (max2 c d)
