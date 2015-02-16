from mwmatching import maxWeightMatching
from random import randrange
from time import clock
from math import pow

for n in list(range(2, 151)):
  n_edges = (pow(n, 2) + n) / 2
  edges = []
  for i in list(range(n - 1)):
    for j in list(range(i + 1, n)):
      edges.append([i, j, randrange(0, n_edges)])

  # Return a list "mate", such that mate[i] == j if vertex i is matched to
  # vertex j, and mate[i] == -1 if vertex i is not matched.
  before = clock()
  match = maxWeightMatching(edges, maxcardinality=True)
  after = clock()

  print str(n) + "\t" + str(after - before)
