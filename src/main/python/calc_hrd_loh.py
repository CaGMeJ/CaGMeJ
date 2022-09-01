import sys

file_path = sys.argv[1]
skip_Chr = "chr17"
segment_threshold = 15 * 10 **6
HRD_LOH = 0

with open(file_path, mode="r") as lines:
    for line in lines:
        if line[:10] == "chromosome":
            continue
        else:
            tmp = line.rstrip("\n")
            elem = tmp.split("\t")
            Chr = elem[1]
            Start = int(elem[2])
            End = int(elem[3])
            A = int(elem[11])
            B = int(elem[12])
            segment_length = End -Start
            if Chr == skip_Chr:
                continue
            if segment_length < segment_threshold:
                continue 
            if (A==0)^(B==0):
                HRD_LOH += 1
print(HRD_LOH) 
