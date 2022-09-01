from parser2 import html_parser, arg_parser
import json
import math
import glob
import os
import shutil

args = arg_parser()
file_dir = args["file_dir"]
input_files = sorted(glob.glob(file_dir + "/*/*.html"))
output_dir = args["output_dir"]
fastqc_script_dir = args["fastqc_script_dir"]
per_page = int(args["per_page"])
file_list={}

for file in input_files:
    basename = "/".join(file.split("/")[-2:])
    file_list[basename] = html_parser(file)

item_list = ["Filename", 
             "Basic Statistics", 
             "Per base sequence quality", 
             "Per tile sequence quality", 
             "Per sequence quality scores",
             "Per base sequence content", 
             "Per sequence GC content",
             "Per base N content", 
             "Sequence Length Distribution", 
             "Sequence Duplication Levels",
             "Over- represented sequences",
             "Adapter Content"]

#evaluation color
evaluation_img={}
for evaluation, img_color in zip(["PASS", "WARNING", "FAIL"],
                                 ["#98fb98","#ffcc00","#ff3300"]): 

     evaluation_img[evaluation] = "<div class='circle' style='background-color:"\
                                + img_color \
                                + ";'></div>"


#item template
text = """
<html>
<meta charset="utf-8"/>
<div class="arrow_left" id="left"></div>
<div class="arrow_right" id="right"></div>
<link rel="stylesheet" href="fastqc.css">
<div>Page<span id="page">1</span>/"""+ str(math.ceil(len(file_list)/per_page)) +"""</div>
<br>
<table id="table" class="table"   width="1000px" cellspacing="0" cellpadding="10px">
<tr>"""
for item in item_list:
   text += '<th bgcolor="#87ceeb" width="80px"><font color="#FFFFFF" size="2">' \
           + item \
           + "</font></th>"

text += "</tr>"

#initial filename, evaluation
count = 0
file_json = []
color =["#ffffff", "#f5f5f5"]
for key, values in file_list.items():
    text += '<td   bgcolor="' \
           + color[count%2] \
           + '">' \
           + '<a href="../qc/fastqc/fastqc/' \
           + key \
           + '"><font size="2">' \
           + key \
           + '</font></a>' \
           + '</td>'
    for item_tmp in item_list[1:]:
       item = item_tmp
       if item == "Over- represented sequences":
          item = "Overrepresented sequences"
       if item in values.keys():
          evaluation = values[item]
          text += '<td bgcolor="'\
                + color[count%2] \
                +'" align="center" >' \
                + evaluation_img[evaluation] \
                + '</td>'
       else:
          text += '<td bgcolor="'\
                + color[count%2] \
                +'" align="center" >' \
                + '</td>'
    text += "</tr>"
    count += 1
    if count >= per_page:
       break
#filename, evaluation list
for key, values in file_list.items():
    temp_json = ["<a href='fastqc/" \
                 + key \
                 + "'><font size='2'>" \
                 + key \
                 + "</font></a>"]
    for item_tmp in item_list[1:]:
       item = item_tmp
       if item == "Over- represented sequences":
          item = "Overrepresented sequences"
       if item in values.keys():
          evaluation = values[item]
          temp_json.append(evaluation_img[evaluation])
       else:
          temp_json.append("")
    file_json.append(temp_json)
#make js file
text += '</table>'
with open(fastqc_script_dir + "/fastqc_list.js") as template:
 with open(output_dir + "/fastqc.js", mode = "w") as file:
     file.write("var file_list =" + json.dumps(file_json) + ";" 
              + "var per_page =" + json.dumps(per_page) + ";"
              + template.read()) 

text += '<script src = "fastqc.js"></script></html>'

#copy css file
shutil.copyfile(fastqc_script_dir + "/fastqc_list.css", output_dir + "/fastqc.css")
#make html file
with open(output_dir + "/index.html", mode = "w") as file:
    file.write(text)
