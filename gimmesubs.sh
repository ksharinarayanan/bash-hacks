target=$1

if [[ -d ~/.subdomains/$target ]]; then
	rm -rf ~/.subdomains/$target
fi

mkdir ~/.subdomains/$target

location=~/.subdomains/$target

subfinder -d $target | tee $location/subfinder-$1

amass enum -d $target -o $location/amass-$1

findomain -t $target -u $location/findomain-$1

assetfinder $target | tee $location/assetfinder-$1

cat $location/* | sort -u | tee $location/$1-subdomains




