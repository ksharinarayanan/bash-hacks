file=$1

if [[ $1 == "" ]]; then
	echo "Usage: ./catch.sh /path/to/file"
	exit 2
fi

if [[ $2 != "" ]]; then
	if [[ ! -f $2 ]]; then
		echo "File ${2} not found!"
		exit 2
	fi
	keywords=$2
	
else
	keywords="~/tools/bash-hacks/wordlists/sensitive"
fi

if [[ ! -f $1 ]]; then
	echo "File ${1} not found!"
	exit 2
fi

data=""

while IFS= read -r line; do
	if [[ $data != "" ]]; then
		data="${data}\|${line}"	
	else
		data="${line}"
	fi
done < $keywords

cat $file | grep -i "${data}"
