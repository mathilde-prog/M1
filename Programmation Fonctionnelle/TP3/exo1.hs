-- Type de matrice fonctionnelle 
type Matf = Int -> Int -> (Bool, Int) 

exemple :: Matf 
exemple i j
     | (1 <= i) && (i <= 6) && (1 <= j) && (j <= 5) = (True, 2*i+j)
     | otherwise = (False, 0)

-- Matrice 4 x 4 avec des 1 sur sa diagonale et des 0 partout ailleurs 
identite4x4 :: Matf 
identite4x4 i j
     | (1 <= i) && (i <= 4) && (1 <= j) && (j <= 4) && (i == j) = (True, 1)
     | (1 <= i) && (i <= 4) && (1 <= j) && (j <= 4) && (i /= j) = (True, 0)
     | otherwise = (False, 0)

-- Retourne le nombre de lignes d'une matrice 
nbLines :: Matf -> Int 
nbLines f = nbLinesIntern f 1 
     where nbLinesIntern f i = case f i 1 of 
                         (True, _) -> 1 + nbLinesIntern f (i+1) 
                         (False, 0) -> 0
                         
-- Retourne le nombre de colonnes d'une matrice                  
nbCols :: Matf -> Int 
nbCols f = nbColsIntern f 1 
     where nbColsIntern f j = case f j 1 of 
                         (True, _) -> 1 + nbColsIntern f (j+1)
                         (False, 0) -> 0
                         
-- Retourne les dimensions de la matrice donnée en paramètre                  
dims :: Matf -> (Int, Int)
dims m = (nbLines m, nbCols m)

-- Teste si deux matrices sont de même dimensions 
cmpDims :: Matf -> Matf -> Bool
cmpDims m n = dims m == dims n 

-- "fait la somme" des deux matrices données en paramètres, sinon levez une exception 
add :: Matf -> Matf -> Matf 
add m n = if not (cmpDims m n)
             then error "add appliquée à 2 matrices de tailles différentes"
             else let (l, c) = dims m in 
                  (\i j -> if 1 <= i && i <= l && 1 <= j && j <= c 
                             then (True, snd(m j i) + snd (n i j))
                           else (False, 0))
          
          
          
          
          
          
          
          
          
