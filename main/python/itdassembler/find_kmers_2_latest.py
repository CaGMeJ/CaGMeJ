import os
import sys

filename = sys.argv[1]
k = int(sys.argv[2])
current = sys.argv[3]
cut_min = int(sys.argv[4])
cut_max = int(sys.argv[5])

os.chdir(current)
f = open(filename,"r")
content1 = f.readlines()
all_kmers = open("all_kmers.txt","w")


for i,s in enumerate(content1):
  if i%2==0:
    continue
  else:
    for j in range(len(s)-k):
      all_kmers.write(s[j:j+k]+"\n")

f.close()
all_kmers.close()

f = open("all_kmers.txt","r")
all_kmers = sorted(f.readlines())
all_kmers_sorted = open("sorted_all_kmers.txt","w")
kmer_frequency = open("kmer_frequency.txt", "w")

prev = all_kmers[0]
count = 1
all_kmers_sorted.write(all_kmers[0])

for s in all_kmers[1:]:
    if prev == s:
        count += 1
    else:
        kmer_frequency.write(prev.rstrip() + " " + str(count) + "\n")
        count = 1
        prev = s

    all_kmers_sorted.write(s)

kmer_frequency.write(prev.rstrip() + " " + str(count) + "\n")

f.close()
all_kmers_sorted.close()
kmer_frequency.close()

f = open("kmer_frequency.txt", "r")
kmer_frequency = sorted(f.readlines(), key = lambda x : int(x.split()[1]))[::-1]
kmer_frequency_sorted = open("sorted_kmer_frequency.txt", "w")
kmer_frequency_filter = open("filter_sorted_kmer_frequency.txt", "w")
hasht = {}
index = 0

for s in kmer_frequency:
    kmer_frequency_sorted.write(s)
    kmer, frequency = s.split()
    if cut_min < int(frequency) < cut_max:
        kmer_frequency_filter.write(s)
        hasht[kmer] = str(index)
        index += 1

f.close()
kmer_frequency_sorted.close()
kmer_frequency_filter.close()

adjacency_matrix = open("adjacency_matrix.txt", "w")

for i,s in enumerate(content1):
  if i%2==0:
    continue
  else:
    for j in range(len(s)-k-1):
      a = "Just " + hasht[s[j:j+k]] if s[j:j+k] in hasht else "Nothing"
      b = "Just " + hasht[s[j+1:j+k+1]] if s[j+1:j+k+1] in hasht else "Nothing"
      adjacency_matrix.write(a + " " + b+"\n")

adjacency_matrix.close()
