# Credits to defparam (https://github.com/defparam) 

if [[ $1 == "" || $2 == "" ]]; then
	echo "Usage: ./list-smuggler.sh file output"
	exit 2
fi

cat $1 | python3 ~/tools/smuggler/smuggler.py -m GET -l "${2}-GET" -x
cat $1 | python3 ~/tools/smuggler/smuggler.py -m POST -l "${2}-POST" -x
cat $1 | python3 ~/tools/smuggler/smuggler.py -m DELETE -l "${2}-DELETE" -x
