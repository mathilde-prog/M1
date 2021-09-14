-- Fonction inverse récursive qui inverse une liste 
inverse :: [a] -> [a]
inverse [] = []
inverse (x:xs) = inverse xs ++ [x]

-- Teste si une liste est un palindrome
isPalindrome :: Eq a => [a] -> Bool
isPalindrome lst 
    | (length lst <= 1) = False 
isPalindrome lst = (lst == inverse lst) 

-- Crée un palindrome à partir d'une liste 
doPalindrome :: [a] -> [a]
doPalindrome lst = init lst ++ inverse lst 

