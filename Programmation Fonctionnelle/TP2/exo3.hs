-- EVALUATEUR DE TAUTOLOGIES 

-- Type de données 
data Prop = Const Bool 
            | Var Char 
            | Not Prop 
            | And Prop Prop 
            | Imply Prop Prop 

-- 4 propositions 
p1 :: Prop
p1 = And (Var 'A')(Not (Var 'A'))

p2 :: Prop
p2 = Imply (And (Var 'A') (Var 'B'))(Var 'A')

p3 :: Prop
p3 = Imply (Var 'A')(And (Var 'A')(Var 'B'))

p4 :: Prop
p4 = Imply (And (Var 'A')(Imply (Var 'A')(Var 'B')))(Var 'B')

type Assoc k v = [(k,v)]
type Subst = Assoc Char Bool 

-- Fonction find 
find :: Eq k => k -> Assoc k v -> v 
find k ts = head [v' | (k', v') <- ts, k' == k]

-- Fonction eval : évalue une proposition donnée selon une liste de substitution donnée
eval :: Subst -> Prop -> Bool
eval _ (Const b) = b 
eval s (Var x) = find x s 
eval s (Not p) = not (eval s p)
eval s (And p q) = eval s p && eval s q
eval s (Imply p q) = eval s p <= eval s q 

-- rmdups :: Eq a => [a] -> [a]
-- rmdups [] = []
-- rmdups (x:xs) =  x:filter (/= x) (rmdups xs)

-- vars :: Prop -> [Char]
-- vars p = rmdups (vars2 p)

-- INCOMPLET 
-- vars2 :: Prop -> [Char]
-- vars2 (Const _)
