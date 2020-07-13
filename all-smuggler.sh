python3 ~/tools/smuggler/smuggler.py -m GET -u $1 -l "${2}-GET" -x
python3 ~/tools/smuggler/smuggler.py -m POST -u $1 -l "${2}-POST" -x
python3 ~/tools/smuggler/smuggler.py -m DELETE -u $1 -l "${2}-DELETE" -x
