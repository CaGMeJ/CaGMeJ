import re
import sys
def html_parser(path):
 items = {}
 with open(path) as file:
   text = file.read()
   li_tags = re.findall(r'\<li\>(.+?)\<\/li\>', text)
   for li_tag in li_tags:
     item_name = re.search(r'(?<=\"\>)(.+?)(?=\<\/a)', li_tag).group()
     item_evaluation = re.search(r'(?<=\[)(.+?)(?=\])', li_tag).group()
     items[item_name] = item_evaluation
 return items

def arg_parser():
 args = {}
 args["file_dir"] = sys.argv[1]
 args["output_dir"] = sys.argv[2]
 args["fastqc_script_dir"] = sys.argv[3]
 args["per_page"] = sys.argv[4]
 return args
