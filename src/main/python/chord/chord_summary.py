import sys

csv_path = sys.argv[1]
output_dir = sys.argv[2]
header = True

with open(csv_path) as csv_lines:
    csv_line = csv_lines.readline()
    while csv_line:
        csv_line = csv_lines.readline()
        if not csv_line:
            break
        sample_name = csv_line.split(",")[0]
        file_path = output_dir + "/" + sample_name + "/" + sample_name + ".txt"
        
        with open(file_path) as lines:
            line = "start"
            if not header:
                next(lines)
            while line:
                line = lines.readline()
                S = []
                tmp = ""
                quotation_mark = -1
                for s in list(line):
                   if s == " " and quotation_mark < 0:
                       S.append(tmp)
                       tmp = ""
                   elif s == '"':
                       quotation_mark *= -1
                   else:
                       tmp += s
                if len(tmp) > 0 and quotation_mark < 0:
                   S.append(tmp)
                if header:
                    print("\t".join(S))
                    header = False
                else:
                    print("\t".join(S[1:]))
