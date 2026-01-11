-- MathBench.idr - Comprehensive Idris2 benchmark for x86_64-v1 baseline
-- Tests all major instruction classes through mathematical operations
-- Part of idris2-pack-docker benchmarking suite

module Main

import Data.Vect
import Data.Nat
import Data.Bits
import System.Clock

%default total

--------------------------------------------------------------------------------
-- Timing utilities
--------------------------------------------------------------------------------

partial
timeIO : String -> IO a -> IO a
timeIO label action = do
  start <- clockTime Monotonic
  result <- action
  end <- clockTime Monotonic
  let diff = timeDifference end start
  let ns = nanoseconds diff
  let us = ns `div` 1000
  let ms = us `div` 1000
  putStrLn $ "  " ++ label ++ ": " ++ show ms ++ "ms (" ++ show us ++ "us)"
  pure result

--------------------------------------------------------------------------------
-- x86_64-v1 INTEGER ARITHMETIC (ADD, SUB, MUL, DIV, MOD)
--------------------------------------------------------------------------------

-- Addition chain (tests ADD instruction)
addChain : Nat -> Nat -> Nat -> Nat
addChain Z acc _ = acc
addChain (S n) acc x = addChain n (acc + x) x

-- Subtraction chain (tests SUB instruction)
subChain : Integer -> Integer -> Nat -> Integer
subChain acc _ Z = acc
subChain acc x (S n) = subChain (acc - x) x n

-- Multiplication chain (tests MUL/IMUL instructions)
mulChain : Integer -> Integer -> Nat -> Integer
mulChain acc _ Z = acc
mulChain acc x (S n) = mulChain (acc * x) x n

-- Division chain (tests DIV/IDIV instructions)
partial
divChain : Integer -> Integer -> Nat -> Integer
divChain acc _ Z = acc
divChain acc x (S n) = divChain (acc `div` x) x n

-- Modulo operations (tests DIV for remainder)
partial
modChain : Integer -> Integer -> Nat -> Integer
modChain acc _ Z = acc
modChain acc x (S n) = modChain (acc `mod` x + acc) x n

-- Mixed arithmetic (tests instruction scheduling)
mixedArith : Integer -> Integer -> Integer -> Integer
mixedArith a b c = (a + b) * c - (a * b) + (c * c) - (a + c)

partial
runIntegerBench : Nat -> IO ()
runIntegerBench iterations = do
  putStrLn "--- Integer Arithmetic (ADD, SUB, MUL, DIV, MOD) ---"

  ignore $ timeIO "ADD chain (10000 adds)" $ do
    let result = addChain 10000 0 7
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "SUB chain (10000 subs)" $ do
    let result = subChain 1000000 3 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "MUL chain (20 muls)" $ do
    let result = mulChain 1 2 20
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "DIV chain (1000 divs)" $ do
    let result = divChain 1000000000000 2 30
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "MOD chain (1000 mods)" $ do
    let result = modChain 1000000 17 1000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Mixed arith (1000 ops)" $ do
    let results = map (\i => mixedArith i (i+1) (i+2)) [1..1000]
    putStr $ "    Sum: " ++ show (sum results) ++ " "
    pure results

  putStrLn ""

--------------------------------------------------------------------------------
-- x86_64-v1 BITWISE OPERATIONS (AND, OR, XOR, NOT, SHL, SHR)
--------------------------------------------------------------------------------

-- Bitwise AND chain
andChain : Bits64 -> Bits64 -> Nat -> Bits64
andChain acc _ Z = acc
andChain acc x (S n) = andChain (acc .&. (x + cast n)) x n

-- Bitwise OR chain
orChain : Bits64 -> Bits64 -> Nat -> Bits64
orChain acc _ Z = acc
orChain acc x (S n) = orChain (acc .|. (x + cast n)) x n

-- Bitwise XOR chain
xorChain : Bits64 -> Bits64 -> Nat -> Bits64
xorChain acc _ Z = acc
xorChain acc x (S n) = xorChain (xor acc (x + cast n)) x n

-- Left shift chain (tests SHL)
shlChain : Bits64 -> Nat -> Bits64
shlChain x Z = x
shlChain x (S n) = shlChain (shiftL x 1) n

-- Right shift chain (tests SHR)
shrChain : Bits64 -> Nat -> Bits64
shrChain x Z = x
shrChain x (S n) = shrChain (shiftR x 1) n

-- Bit manipulation mix
bitMix : Bits64 -> Bits64 -> Bits64
bitMix a b = xor (shiftL (a .&. b) 3) (shiftR (a .|. b) 2)

partial
runBitwiseBench : IO ()
runBitwiseBench = do
  putStrLn "--- Bitwise Operations (AND, OR, XOR, SHL, SHR) ---"

  ignore $ timeIO "AND chain (10000 ops)" $ do
    let result = andChain 0xFFFFFFFFFFFFFFFF 0xAAAAAAAAAAAAAAAA 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "OR chain (10000 ops)" $ do
    let result = orChain 0 0x5555555555555555 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "XOR chain (10000 ops)" $ do
    let result = xorChain 0 0x123456789ABCDEF0 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "SHL chain (60 shifts)" $ do
    let result = shlChain 1 60
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "SHR chain (60 shifts)" $ do
    let result = shrChain 0x8000000000000000 60
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Bit mix (1000 ops)" $ do
    let results = map (\i => bitMix (cast i) (cast (i * 17))) [1..1000]
    case results of
      (x :: _) => putStr $ "    Sample: " ++ show x ++ " "
      [] => putStr "    Sample: N/A "
    pure results

  putStrLn ""

--------------------------------------------------------------------------------
-- x86_64-v1 FLOATING POINT (SSE2: ADDSD, SUBSD, MULSD, DIVSD, SQRTSD)
--------------------------------------------------------------------------------

-- FP addition chain
fpAddChain : Double -> Double -> Nat -> Double
fpAddChain acc _ Z = acc
fpAddChain acc x (S n) = fpAddChain (acc + x) x n

-- FP subtraction chain
fpSubChain : Double -> Double -> Nat -> Double
fpSubChain acc _ Z = acc
fpSubChain acc x (S n) = fpSubChain (acc - x) x n

-- FP multiplication chain
fpMulChain : Double -> Double -> Nat -> Double
fpMulChain acc _ Z = acc
fpMulChain acc x (S n) = fpMulChain (acc * x) x n

-- FP division chain
partial
fpDivChain : Double -> Double -> Nat -> Double
fpDivChain acc _ Z = acc
fpDivChain acc x (S n) = fpDivChain (acc / x) x n

-- Square root chain (tests SQRTSD)
sqrtChain : Double -> Nat -> Double
sqrtChain x Z = x
sqrtChain x (S n) = sqrtChain (sqrt (x + 1.0)) n

-- Trigonometric (tests FP unit heavily)
trigMix : Double -> Double
trigMix x = sin x * cos x + tan (x / 2.0)

-- Exponential/log (tests complex FP)
expLogMix : Double -> Double
expLogMix x = exp (log (x + 1.0)) * log (exp x)

partial
runFPBench : IO ()
runFPBench = do
  putStrLn "--- Floating Point (ADDSD, SUBSD, MULSD, DIVSD, SQRTSD) ---"

  ignore $ timeIO "FP ADD chain (10000 ops)" $ do
    let result = fpAddChain 0.0 0.1 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "FP SUB chain (10000 ops)" $ do
    let result = fpSubChain 10000.0 0.1 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "FP MUL chain (50 ops)" $ do
    let result = fpMulChain 1.0 1.0001 50
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "FP DIV chain (1000 ops)" $ do
    let result = fpDivChain 1.0e100 1.1 1000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "SQRT chain (1000 ops)" $ do
    let result = sqrtChain 1000000.0 1000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Trig mix (1000 ops)" $ do
    let results = map (\i => trigMix (cast i * 0.01)) [1..1000]
    putStr $ "    Sum: " ++ show (sum results) ++ " "
    pure results

  ignore $ timeIO "Exp/Log mix (1000 ops)" $ do
    let results = map (\i => expLogMix (cast i * 0.01)) [1..1000]
    putStr $ "    Sum: " ++ show (sum results) ++ " "
    pure results

  putStrLn ""

--------------------------------------------------------------------------------
-- x86_64-v1 COMPARISON/BRANCH (CMP, Jcc, CMOV)
--------------------------------------------------------------------------------

-- Comparison chain (tests CMP + conditional)
cmpChain : Integer -> Integer -> Nat -> Integer
cmpChain acc _ Z = acc
cmpChain acc x (S n) =
  if acc < x then cmpChain (acc + 1) x n
  else if acc > x then cmpChain (acc - 1) x n
  else cmpChain acc x n

-- Min/max chain (tests CMOV-style operations)
minMaxChain : Integer -> Nat -> (Integer, Integer)
minMaxChain seed Z = (seed, seed)
minMaxChain seed (S n) =
  let next = (seed * 1103515245 + 12345) `mod` 2147483648
      (minV, maxV) = minMaxChain next n
  in (min seed minV, max seed maxV)

-- Conditional accumulation
condAccum : Integer -> Nat -> Integer
condAccum acc Z = acc
condAccum acc (S n) =
  let v = cast n `mod` 7
  in if v == 0 then condAccum (acc + cast n) n
     else if v == 1 then condAccum (acc - cast n) n
     else if v == 2 then condAccum (acc * 2) n
     else if v == 3 then condAccum (acc `div` 2) n
     else condAccum acc n

partial
runComparisonBench : IO ()
runComparisonBench = do
  putStrLn "--- Comparison/Branch (CMP, Jcc, conditional) ---"

  ignore $ timeIO "CMP chain (10000 compares)" $ do
    let result = cmpChain 0 5000 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Min/Max chain (10000 ops)" $ do
    let (minV, maxV) = minMaxChain 12345 10000
    putStr $ "    Min: " ++ show minV ++ " Max: " ++ show maxV ++ " "
    pure (minV, maxV)

  ignore $ timeIO "Conditional accum (10000 branches)" $ do
    let result = condAccum 1000000 10000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  putStrLn ""

--------------------------------------------------------------------------------
-- MEMORY ACCESS PATTERNS (tests cache behavior)
--------------------------------------------------------------------------------

-- Sequential access (cache-friendly)
seqAccess : Vect n Int -> Int
seqAccess [] = 0
seqAccess (x :: xs) = x + seqAccess xs

-- Strided access (less cache-friendly) - sum every nth element
partial
stridedSum : List Int -> Nat -> Nat -> Int
stridedSum [] _ _ = 0
stridedSum (x :: xs) stride Z = x + stridedSum xs stride stride
stridedSum (_ :: xs) stride (S k) = stridedSum xs stride k

partial
runMemoryBench : IO ()
runMemoryBench = do
  putStrLn "--- Memory Access Patterns ---"

  ignore $ timeIO "Sequential access (10000 elem)" $ do
    let vec : Vect 10000 Int = replicate 10000 42
    let result = seqAccess vec
    putStr $ "    Sum: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Strided access (stride=7)" $ do
    let lst = take 10000 [1..]
    let result = stridedSum lst 7 0
    putStr $ "    Sum: " ++ show result ++ " "
    pure result

  putStrLn ""

--------------------------------------------------------------------------------
-- DEPENDENT TYPE OPERATIONS (Idris2 specialty)
--------------------------------------------------------------------------------

-- Vector dot product (length-safe)
dot : Num a => Vect n a -> Vect n a -> a
dot [] [] = 0
dot (x :: xs) (y :: ys) = x * y + dot xs ys

-- Matrix type
Matrix : Nat -> Nat -> Type -> Type
Matrix rows cols a = Vect rows (Vect cols a)

-- Matrix-vector multiply
matVecMult : Num a => Matrix m n a -> Vect n a -> Vect m a
matVecMult [] _ = []
matVecMult (row :: rows) v = dot row v :: matVecMult rows v

-- Identity matrix generation
identity : Num a => (n : Nat) -> Matrix n n a
identity Z = []
identity (S k) = (1 :: replicate k 0) :: map (0 ::) (identity k)

partial
runDependentTypeBench : IO ()
runDependentTypeBench = do
  putStrLn "--- Dependent Type Operations ---"

  ignore $ timeIO "Vector dot (size 1000)" $ do
    let v1 : Vect 1000 Double = replicate 1000 1.5
    let v2 : Vect 1000 Double = replicate 1000 2.5
    let result = dot v1 v2
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Matrix-vector mult (100x100)" $ do
    let m : Matrix 100 100 Double = replicate 100 (replicate 100 0.1)
    let v : Vect 100 Double = replicate 100 1.0
    let result = matVecMult m v
    putStr $ "    Result[0]: " ++ show (head result) ++ " "
    pure result

  ignore $ timeIO "Identity matrix (50x50)" $ do
    let m : Matrix 50 50 Int = identity 50
    -- Trace is sum of diagonal = 50 for identity matrix
    putStr $ "    Generated 50x50 identity "
    pure m

  putStrLn ""

--------------------------------------------------------------------------------
-- COMPLEX ALGORITHMS (real-world workloads)
--------------------------------------------------------------------------------

-- Complex number type
record Complex where
  constructor MkComplex
  re : Double
  im : Double

Num Complex where
  (MkComplex a b) + (MkComplex c d) = MkComplex (a + c) (b + d)
  (MkComplex a b) * (MkComplex c d) = MkComplex (a*c - b*d) (a*d + b*c)
  fromInteger n = MkComplex (fromInteger n) 0

magSq : Complex -> Double
magSq (MkComplex r i) = r * r + i * i

-- Mandelbrot iteration
mandelbrotIter : Complex -> Complex -> Nat -> Nat
mandelbrotIter c z Z = 0
mandelbrotIter c z (S n) =
  if magSq z > 4.0 then S n
  else mandelbrotIter c (z * z + c) n

mandelbrot : Double -> Double -> Nat -> Nat
mandelbrot x y maxIter = mandelbrotIter (MkComplex x y) (MkComplex 0 0) maxIter

-- Fibonacci (tail recursive)
fibTail : Nat -> Nat
fibTail n = go n 0 1
  where
    go : Nat -> Nat -> Nat -> Nat
    go Z a _ = a
    go (S k) a b = go k b (a + b)

-- Simpson's rule integration
partial
simpsons : (Double -> Double) -> Double -> Double -> Nat -> Double
simpsons f a b n =
  let h = (b - a) / cast n
      terms = map (\i =>
        let x = a + cast i * h
            coef = if i == 0 || i == n then 1.0
                   else if mod i 2 == 0 then 2.0 else 4.0
        in coef * f x) [0..n]
  in (h / 3.0) * sum terms

-- Prime sieve (algorithmic benchmark)
partial
sieve : List Nat -> List Nat
sieve [] = []
sieve (p :: xs) = p :: sieve (filter (\x => mod x p /= 0) xs)

partial
primes : Nat -> List Nat
primes n = sieve [2..n]

partial
runAlgorithmBench : IO ()
runAlgorithmBench = do
  putStrLn "--- Complex Algorithms ---"

  ignore $ timeIO "Mandelbrot (100x100 grid)" $ do
    let grid = [mandelbrot (cast x * 0.04 - 2.0) (cast y * 0.04 - 2.0) 100
                | x <- [0..99], y <- [0..99]]
    putStr $ "    Total iterations: " ++ show (sum grid) ++ " "
    pure grid

  ignore $ timeIO "Fibonacci (fib 45)" $ do
    let result = fibTail 45
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Simpson's rule (1000 intervals)" $ do
    let result = simpsons (\x => x * x * sin x) 0.0 3.14159265 1000
    putStr $ "    Result: " ++ show result ++ " "
    pure result

  ignore $ timeIO "Prime sieve (primes < 10000)" $ do
    let ps = primes 10000
    putStr $ "    Count: " ++ show (length ps) ++ " "
    pure ps

  putStrLn ""

--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

partial
main : IO ()
main = do
  putStrLn "================================================================================"
  putStrLn "  Idris2 Comprehensive Benchmark - x86_64-v1 Baseline Instruction Coverage"
  putStrLn "  Tests: Integer, Bitwise, FP, Comparison, Memory, Dependent Types, Algorithms"
  putStrLn "================================================================================"
  putStrLn ""

  runIntegerBench 10000
  runBitwiseBench
  runFPBench
  runComparisonBench
  runMemoryBench
  runDependentTypeBench
  runAlgorithmBench

  putStrLn "================================================================================"
  putStrLn "  Benchmark Complete"
  putStrLn "================================================================================"
