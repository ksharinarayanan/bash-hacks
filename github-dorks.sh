while getopts "o:a:" opt
do
	case "${opt}" in
		o)
			organization="${OPTARG}"
			;;
		a)
			additional="${OPTARG}"
	esac
done

if [[ $organization == "" ]]; then
	echo "Usage: ./generate.sh -o tesla.com(required) -a additional_query_for_every_dock(optional)"
	exit 2
fi

if [[ ! -f dorks.txt ]]; then
	echo "dorks.txt not found !"
	exit 2
fi

while IFS= read -r dork; do
	if [[ $additional != "" ]]; then
		echo "https://github.com/search?q=\"${organization}\"+${dork}+${additional}&type=Code"
	else
		echo "https://github.com/search?q=\"${organization}\"+${dork}&type=Code"
	fi
done < dorks.txt


