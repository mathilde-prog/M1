-- Fait  la  somme  des  100  premiers  carrés d’entiers.
sumcarre :: Num a => [a] -> a
sumcarre [] = 0
sumcarre(x : xs) = x + sum xs + sumcarre xs -- OU sumcarre (x : xs) = sum (x^2, sumcarre xs)

-- exécuter sumcarre(1..100), donne le résultat : 338350

-- Retourne une liste contenant n répliques de x 
replic :: Int -> a -> [a]
replic n a = take n (repeat a)

-- Retourne la liste des triangles rectangles dont l’hypoténuse est de taille n donnée.
pyths :: Int -> [(Int,Int,Int)]
pyths h = [(a,b,c) | a <- [1..h], b <- [1..h], c <- [1..h], a^2 + b^2 == c^2 || b^2 + c^2 == a^2 || a^2 + c^2 == b^2, a == h || b == h || c == h]


-- CORRECTION PROF 
sumcarreprof :: Int 
sumcarreprof = sum [x^2 | x <- [1..100]]

replicprof :: Int -> a -> [a]
replicprof n a = [ a | _ <- [1..n]]

pythsprof :: Int -> [(Int, Int, Int)] 
pythsprof n = [(x,y,z) | x <- [1..n], y <- [1..n], z <- [1..n], 
        z == n && x^2 + y^2 == z^2 ||
        y == n && x^2 + z^2 == y^2 ||
        x == n && z^2 + y^2 == x^2] 
