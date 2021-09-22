import System.IO (hSetEcho, stdin)

-- Retourne le caractère saisi (aussi la correction du prof)
getCh :: IO Char
getCh = do
    hSetEcho stdin False
    c <- getChar
    hSetEcho stdin True
    return c

-- Retourne une chaine saisie
sgetLine :: IO String 
sgetLine = do 
        x <- getCh
        putChar '-'
        if x == '\n'
            then return []
            else do 
                xs <- sgetLine
                return (x:xs)

-- Correction du prof 
sgetLineProf :: IO String 
sgetLineProf = do 
    c <- getCh
    if c == '\n'
        then do 
            putChar c 
            return []
        else do 
            putChar '-'
            xs <- sgetLineProf
            return (c:xs)
             
-- Découvre les caractères correctes de la chaîne à deviner (correction prof)
match :: String -> String -> String 
match xs ys = [if elem x ys then x else '-' | x <- xs]

-- Gère les propositions de l'adversaire jusqu'à ce qu'il l'ai trouvé
play :: String -> IO ()
play m = do  
    putStr "\n? "
    x <- getLine 
    if x == m 
        then do 
            putStr "You got it\n"
    else do
        putStr (match m x ++ "\n")
        play m

-- Correction prof
playProf :: String -> IO ()
playProf word = do 
        putStr "? "
        guess <- getLine 
        if guess == word 
            then putStrLn "You got it"
            else do 
                putStrLn (match word guess)
                playProf word 

-- Demande le mot secret puis fait jouer l'adversaire en appliquant la fonction play 
hangman :: IO ()
hangman = do
    putStr "Quel est le mot secret ?\n"
    m <- sgetLineProf
    play m 

-- Correction du prof
hangmanProf :: IO()
hangmanProf = do 
    putStrLn "Think of a word:"
    word <- sgetLine 
    putStrLn "Try to guess it:"
    playProf word 

-- Programme principal pour jouer au pendu 
main :: IO ()
main = hangmanProf
