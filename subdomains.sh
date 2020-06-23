while getopts "d:" opt
do
	case "${opt}" in
		d)
			target="${OPTARG}"
			;;
	esac
done
if [[ $target == "" ]]; then
	echo "Usage: ./subdomains.sh -d domain.com"
	exit 2
fi

location=~/.subdomains/$target

if [[ -d ~/.subdomains/$target ]]; then
	read -p "The target's data already exists, do you want to start fresh, if no it continues from where you left(y/n): " input
	if [[ $input == 'y' || $input == 'Y' ]]; then
		rm -rf ~/.subdomains/$target
	fi
fi
if [[ ! -d ~/.subdomains/$target ]]; then
	mkdir ~/.subdomains/$target
fi


if [[ ! -f $location/subfinder-$target ]]; then
	subfinder -d $target | tee $location/subfinder-$target
else
	echo -e "Subfinder already done\n"
fi

if [[ ! -f $location/amass-$target ]]; then
	amass enum -d $target -o $location/amass-$target
else
	echo -e "Amass already done\n"
fi

if [[ ! -f $location/findomain-$target ]]; then
	findomain -t $target -u $location/findomain-$target
else
	echo -e "Findomain already done\n"
fi

if [[ ! -f $location/assetfinder-$target ]]; then
	assetfinder $target | tee $location/assetfinder-$target
else
	echo -e "Assetfinder already done\n"
fi

if [[ ! -f $location/subdomainizer-$target ]]; then
	python3 ~/tools/SubDomainizer/SubDomainizer.py -u $target -g -gt f236a11e6591955df4b985b83ead43eff4f9bd5e -o $location/subdomainizer-$target
else
	echo -e "Subdomainizer already done\n"
fi

cat $location/* | sort -u | tee $location/$target-subdomains


