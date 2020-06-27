file=$1

while IFS= read -r domain; do
	echo "http://${domain}"
done < $file
