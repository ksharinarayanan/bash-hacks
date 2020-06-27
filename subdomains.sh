black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

source ~/.profile

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

if [[ $target == "list" ]]; then
	targets=$(ls ~/.recon-data/)
	for t in $targets; do
		if [[ -f ~/.recon-data/$t/subdomains/$t-subdomains ]]; then
			l=$(cat ~/.recon-data/$t/subdomains/$t-subdomains | grep -c "")
			echo "$t - $l subdomains"
		else
			echo "${red}$t scanning not complete${reset}"
		fi
	done
	exit 2
fi

location=~/.recon-data/$target/subdomains

if [[ -d ~/.recon-data/$target/subdomains ]]; then
	read -p "The target's data already exists, do you want to start fresh, if no it continues from where you left(y/n): " input
	if [[ $input == 'y' || $input == 'Y' ]]; then
		rm -rf ~/.subdomains/$target/subdomains
	fi
fi
if [[ ! -d ~/.recon-data/$target ]]; then
	mkdir ~/.subdomains/$target
fi

if [[ ! -d ~/.recon-data/$target/subdomains ]]; then
	mkdir ~/.recon-data/$target/subdomains
fi

echo -e "\n${yellow}[+] Starting subfinder${reset}\n"
if [[ ! -f $location/subfinder-$target ]]; then
	subfinder -d $target | tee $location/subfinder-$target
	echo -e "\n${green}[-] Subfinder done${reset}"
else
	echo -e "${cyan}Subfinder already done${reset}"
fi

echo -e "\n${yellow}[+] Starting amass${reset}\n"

if [[ ! -f $location/amass-$target ]]; then
	amass enum --passive -d $target -o $location/amass-$target
	echo -e "\n${green}[-] Amass done${reset}"
else
	echo -e "${cyan}Amass already done${reset}"
fi

echo -e "\n${yellow}[+] Starting findomain${reset}\n"

if [[ ! -f $location/findomain-$target ]]; then
	findomain -t $target -u $location/findomain-$target
	echo -e "\n${green}[-] Findomain done${reset}"
else
	echo -e "${cyan}Findomain already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting assetfinder${reset}\n"

if [[ ! -f $location/assetfinder-$target ]]; then
	assetfinder -subs-only $target | tee $location/assetfinder-$target
	echo -e "\n${green}[-] Assetfinder done${reset}"
else
	echo -e "${cyan}Assetfinder already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting chaos${reset}\n"

if [[ ! -f $location/chaos-$target ]]; then
	chaos -d $target | tee $location/chaos-$target
else
	echo -e "${cyan}Chaos already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting subdomainizer${reset}\n"

if [[ ! -f $location/subdomainizer-$target ]]; then
	python3 ~/tools/SubDomainizer/SubDomainizer.py -u $target -g -gt $GITHUB_API_KEY -o $location/subdomainizer-$target
	echo -e "\n${green}[-] Subdomainizer done${reset}"
else
	echo -e "${cyan}Subdomainizer already done${reset}\n"
fi

echo -e "\n${yellow}[+] Starting github subdomains\n${reset}"

if [[ ! -f $location/github-subdomains-$target ]]; then
	python3 ~/tools/github-search/github-subdomains.py -d $target -t $GITHUB_TOKEN | tee $location/github-subdomains-$target
	echo -e "\n${green}[-] Github subdomains done${reset}"
else
	echo -e "\n${cyan}Github subdomains already done${reset}\n"
fi

echo -e "\n\n${green}The final list of subdomains are:\n${yellow}"
cat $location/* | sort -u | grep $target | tee $location/$target-subdomains
echo "${reset}"
total=$(cat $location/$target-subdomains | grep -c "")
echo -e "\n\nTotal subdomains found: $total\n"



