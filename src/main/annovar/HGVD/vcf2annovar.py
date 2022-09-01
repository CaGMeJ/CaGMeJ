import sys

filepath = sys.argv[1]
out = sys.argv[2]
file = open(out, mode = "w")

with open(filepath,mode="r") as lines:
   for line in lines:
       if line[0] == "#":
           continue
       elem = line.rstrip("\n").split("\t")
       Chr = elem[0].replace('chr', '')
       pos = int(elem[1])
       ref = elem[3]
       alt_list = elem[4].split(',')
       info = {}
       for i in  elem[7].split(';'):
           tmp = i.split("=")
           info[tmp[0]] = tmp[1]
       sample = info["Mean_depth"]
       Filter = elem[6]
       nr = int(info["NR"])
       na_list = [int(i) for i in info["NA"].split(',')]
       na_sum = sum([int(na) for na in na_list])
       if len(na_list) < len(alt_list):
           print('Warning: NA can not be found')
           na_list += [0 for i in range(len(alt_list) - len(na_list))]
       for idx in range(len(alt_list)):
           alt = alt_list[idx]
           left_match_size = 0 
           for i in range(min(len(alt), len(ref))):
               if alt[i] == ref[i]:
                   left_match_size += 1
               else:
                   break
               
           pos_n = pos + left_match_size
           ref_n = ref[left_match_size:] if len(ref) > left_match_size else '-'
           alt = alt[left_match_size:] if len(alt) > left_match_size else '-'
           if ref_n!='-' and alt!='-':
               start, end = (pos_n, pos_n)
           elif ref_n=='-' :
               start, end = (pos_n-1, pos_n-1)
           elif alt=='-':
               start, end = (pos_n, pos_n+len(ref_n)-1)
           
           comment = Filter + ";" + str(nr) + ";" + str(na_list[idx]) + ";" + '{:.6f}'.format(na_list[idx]/(nr+na_sum))
           file.write('\t'.join([Chr, str(start), str(end), ref_n, alt, comment]) + "\n")

file.close()
