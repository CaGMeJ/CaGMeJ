import sys

variant_type = sys.argv[1]
csv_path = sys.argv[2]
out_type = sys.argv[3]
prefix = sys.argv[4]
case2 = []
case4 = []

with open(csv_path, mode = "r") as lines:
    next(lines)
    for line in  lines:
        tumor, normal, _, _, control_panel = line.rstrip("\n").split(",")
        if normal == "None" and control_panel == "None":
            case4.append(tumor)
        elif control_panel == "None":
            case2.append(tumor)

if out_type == "sample_name":
    if len(case2) == 0: case2 = ["None"]
    if len(case4) == 0: case4 = ["None"]
    print(",".join(case2) + " " + ",".join(case4))
elif out_type == "file_name":
    file_list = []
    if len(case2):
        file_list.append(prefix + "/merge_{}_filt_pair.txt".format(variant_type))
    if len(case4):
        file_list.append(prefix + "/merge_{}_filt_unpair.txt".format(variant_type))

    print(",".join(file_list))
else:
    sys.exit(1)
