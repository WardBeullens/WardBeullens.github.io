import random

load('Matsumoto_Imai_exercise.sage')

R.<X> = K[]

if q == 256 and n == 40:
    L.<X> = K.extension(X^40 + t*X^27 + t*X^17 + t*X^4 + X^3 + 1)
if q == 256 and n == 41:
    L.<X> = K.extension(X^41 + X^39 + X^23 + X^22 + X^21 + t*X^15 + X^8 + 1)

if not L.is_field():
    print("L is not a field")
    exit()

def random_invertible_matrix(K,n):
    while True:
        M = random_matrix(K,n,n)
        if M.is_invertible():
            return M

generate_pk = False

if generate_pk:

    qtheta = (mod(q,q**n-1)**theta).lift()

    M = Matrix(L, [ [ X**(j+(qtheta*i)) for j in range(n) ] for i in range(n) ] )

    Mi = [ zero_matrix(K, n,n) for _ in range(n)] 

    for i in range(n):
        for j in range(n):
            for k in range(n):
                Mi[k][i,j] = M[i][j][k]

    S = random_invertible_matrix(K,n)
    T = random_invertible_matrix(K,n)

    # compose with T
    Pk = [ sum([ T[i,j]*Mi[j] for j in range(n) ]) for i in range(n) ] 

    # compose with S 
    Pk = [ S.transpose()*M*S for M in Pk ]

    def MakeUD(M,n):
        for i in range(n):
            for j in range(i+1,n):
                M[i,j] += M [j,i]
                M[j,i] = 0

    for M in Pk:
        MakeUD(M,n)

    def decrypt(S,T,ct):
        ct = T.inverse()*ct
        ct = L(list(ct))
        ct = ct**((1+qtheta).inverse_mod((q**n)-1))
        ct = vector(K,list(ct))
        ct = S.inverse()*ct
        return ct

    message = string_to_vector("Don't use Matsumoto-Imai in practice ... ")
    ciphertext = Evaluate_PK(Pk,message)
    message2 = decrypt(S,T,ciphertext)

    print(len(message))

    print("message:", vector_to_string(message))
    print("ciphertext:", vector_to_string(ciphertext))

    if message2 != message:

        print("Decryption failed")
        exit()

    pickle.dump( (Pk, ciphertext), open( "Pk_ciphertext.pickle", "wb" ) )

else:
    Pk, ciphertext = pickle.load( open( "Pk_ciphertext.pickle", "rb" ) )


# do attack

def tensor(a,b):
    return vector([ ai*bj for ai in a for bj in b])

evals = n**2 + 10
Inputs = [ vector(K, [ K.random_element() for _ in range(n) ]) for _ in range(evals)]
Outputs = [ Evaluate_PK(Pk,v) for v in Inputs ] 

tensor = [ tensor(o,i) for (i,o) in zip(Inputs,Outputs) ]

M = Matrix(K,tensor)
print('cols:', M.ncols())
print('rows:', M.nrows())
print('rank:', M.rank())

RK = M.right_kernel()
print('kernel dimension:', RK.dimension())

#plug in ciphertext 
def plug_ct(vec,ct):
    ct = list(ct)
    out = zero_vector(K,n)
    for i in range(n):
        out += ct[i]*vector(K,vec[i*n:(i+1)*n])
    return out

linear_relations = [ plug_ct(vec, ciphertext) for vec in RK.basis() ]

LR = Matrix(K,linear_relations)
print('cols:', LR.ncols())
print('rows:', LR.nrows())
print('rank:', LR.rank())

LRK = LR.right_kernel()

for b in LRK.basis():
    print(len(b))
    print(b)

for candidate_message in LRK:
    if Evaluate_PK(Pk,candidate_message) == ciphertext:
        print('message is: ', vector_to_string(candidate_message))