import random

load('Matsumoto_Imai_exercise.sage')

# do attack

def tensor(a,b):
    return vector([ ai*bj for ai in a for bj in b])


# make some input-output pairs
evals = n**2 + 10
Inputs = [ vector(K, [ K.random_element() for _ in range(n) ]) for _ in range(evals)]
Outputs = [ Evaluate_PK(Pk,v) for v in Inputs ] 

# make a big matrix with all the cross-terms
tensor = [ tensor(o,i) for (i,o) in zip(Inputs,Outputs) ]
M = Matrix(K,tensor)
print('Solving for bilinear equations:')
print('cols:', M.ncols())
print('rows:', M.nrows())
print('rank:', M.rank())
print()

# the elements in the kernel are our bilinear equations.
RK = M.right_kernel()
print('kernel dimension:', RK.dimension())

#plug ciphertext in equations 
def plug_ct(vec,ct):
    ct = list(ct)
    out = zero_vector(K,n)
    for i in range(n):
        out += ct[i]*vector(K,vec[i*n:(i+1)*n])
    return out

linear_relations = [ plug_ct(vec, ciphertext) for vec in RK.basis() ]

#solve linear relations
LR = Matrix(K,linear_relations)
print('Solving for message:')
print('cols:', LR.ncols())
print('rows:', LR.nrows())
print('rank:', LR.rank())
print()
LRK = LR.right_kernel()

# brute-force search to find which of the messages is the real one
for candidate_message in LRK:
    if Evaluate_PK(Pk,candidate_message) == ciphertext:
        print('message is: ', vector_to_string(candidate_message))