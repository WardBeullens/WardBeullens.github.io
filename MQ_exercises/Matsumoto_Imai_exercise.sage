import pickle

# parameters
q = 256
n = 41
theta = 1

#define finite field
K.<t> = GF(q)

# functions to convert from GF(q)-vector to ASCII-strings and back:
FE_to_int = { x:i for i,x in enumerate(K) }
int_to_FE = { i:x for i,x in enumerate(K) }

def vector_to_string(vec):
    S = ""
    for x in vec:
        S += chr(FE_to_int[x])
    return S

def string_to_vector(S):
    V = []
    for char in S:
        V.append(int_to_FE[ord(char)])
    return vector(K,V)


# evaluate the public key on input v
def Evaluate_PK(Pk,v):
    return vector(K,[ v*M*v  for M in Pk])


#read public key and ciphertext from file
Pk, ciphertext = pickle.load( open( "Pk_ciphertext.pickle", "rb" ) )

print("ciphertext vector:", ciphertext)
print("ciphertext ASCII: ", vector_to_string(ciphertext))

#TODO: recover the message from Pk and ciphertext

