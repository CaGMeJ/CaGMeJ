import sys
from Bio import SeqIO

record = SeqIO.to_dict(SeqIO.parse(sys.argv[3], 'fasta'))
out = open(sys.argv[1], mode = "w")

with open(sys.argv[2]) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t", 6)
        new_elem = elem[6].replace("\t", " ").split(";")
        old_elem = elem[6].replace("\t", " ").split(";")
        new_elem[1] = elem[0]
        new_elem[2] = elem[1] 
        new_elem[3] = elem[2]

        if len(old_elem) < 10:
            print(elem)
            continue
        if  len(new_elem) >= 27:
            print(line)
            import sys
            sys.exit() 
        out.write(("\t".join(new_elem)) + "\n")
