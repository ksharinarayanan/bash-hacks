import argparse
import sys


Parser = argparse.ArgumentParser()
Parser.add_argument('-l', '--list', help="File with URLs")
Parser.add_argument('-o', '--output', help="Output file (optional)")
Args = Parser.parse_args()


if Args.list == None:
	print("Argument --list required!")
	print(Parser.print_help())
	sys.exit(2)

paths = open(Args.list, "r")
res = []
for path in paths:
    res.append(path.split('/'))

if Args.output != None:
	output_file = open(Args.output, "w")
res.sort()
for i in res:
    for w in i:
        if w != " " and w != '\n':
            print(w)
            if Args.output != None:
            	output_file.write(w)
if Args.output != None:
	print("Written to " + Args.output)
	output_file.close()