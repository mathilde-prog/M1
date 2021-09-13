type Domino = (Int, Int)

-- Détermine s'il est possible de former une chaine linéaire avec deux dominos donnés 
chainelineairepossible2 :: Domino -> Domino -> Bool 
chainelineairepossible2 (a,b) (c,d)
      | (a == c) || (a == d) || (b == c) || (b == d) = True
      | otherwise = False

-- CORRECTION PROF 

dominosA2Match :: Domino -> Domino -> Bool
dominosA2Match (x,y) (w,z) = y == w || y == z || x == w || x == z 

domino2Construct :: Domino -> Domino -> Domino
domino2Construct (x,y) (w,z)
    | y == w = (x,z)
    | y == z = (x,w)
    | x == w = (y,z)
    | x == z = (y,w)
    
-- Détermine s'il est possible de former une chaine linéaire avec trois dominos donnés 
dominosA3Match :: Domino -> Domino -> Domino -> Bool 
dominosA3Match d1 d2 d3 = (dominosA2Match d1 d2 && dominosA2Match d3 (domino2Construct d1 d2)) || (dominosA2Match d2 d3 && dominosA2Match d1 (domino2Construct d2 d3)) || (dominosA2Match d1 d3 && dominosA2Match d2 (domino2Construct d1 d3))


