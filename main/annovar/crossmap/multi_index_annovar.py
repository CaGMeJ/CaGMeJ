import os
import re
import sys

prefix = sys.argv[1] 
number = sys.argv[2] 
dbfile = prefix + number + ".no_sorted.split.txt"			#now the dbfile is the newdb generated in step 1
filesize = os.path.getsize(dbfile)
memo = {}
offset = 0
for i in range(int(number)):
    offset += os.path.getsize(prefix + ("{:0=2}.no_sorted.split.txt".format(i)) )
#eigenとfathmmは100,他は1000
Bin =  100
filetype = "A" 
IDX = open(dbfile + ".idx", mode = "w")
#IDX.write("#BIN\t{0}\t{1}\n".format(Bin, filesize))


with open(dbfile) as lines:
    for line in lines:
        length = len(line)
        new_line = re.sub('[\r\n]+$', '', line)
	
        if line[0] == "#":		#comment line is skipped
            offset += length
            continue

	
        if filetype == 'A':
            Chr, Start = new_line.split("\t")[:2]
            if re.match(r"^\d+$", Start):
                Start = int(Start)
        elif filetype == 'B':
            Chr, Start =  new_line.split("\t")[1:3]
            if re.match(r"^\d+$", Start):
                Start = int(Start)
                Start += 1		#UCSC use zero-start
        elif filetype == 'C':
            Chr, undef, Start = new_line.split("\t")[2:5]
            if re.match(r"^\d+$", Start):
                Start = int(Start)
                Start += 1 

        try:
            Start
        except NameError:
            print("Error: unable to find start site from input line {0}\n".format(new_line))
        if type(Start) == str:
            print("Error: the start site ({0}) is not a positive integer in input line <{1}> (trying to convert to integer...)\n".format(Start, new_line))
            continue
         
        curbin = Start - ( Start % Bin )
        region = Chr + "\t" + str(curbin)
        if not region in memo:
            memo[region] = {}
        if not "min" in memo[region]:
            memo[region]['min']   = str(offset)
        memo[region]['max']    = str(offset + length)

        if re.match(r"000$", str(offset)):
            print("NOTICE: Indexing {0}: {1}\r".format(dbfile, int(100*offset/filesize)), file=sys.stderr)
        offset += length


for k in sorted(memo.keys()):
    IDX.write("\t".join([k, memo[k]['min'], memo[k]['max']]))
    IDX.write("\n")


print("\nDone!\n", file=sys.stderr)
IDX.close()
