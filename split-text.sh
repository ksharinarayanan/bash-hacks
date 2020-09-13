if [[ $1 == "" ]]; then
	echo "Usage: bash split-text.sh text"
	exit 1
fi

IFS=' ' read -ra ADDR <<< "$1"
for i in "${ADDR[@]}"; do
    echo "$i"
done
