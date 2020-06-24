black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

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

echo -e "\n${yellow}[+] Starting subfinder${reset}\n"
if [[ ! -f $location/subfinder-$target ]]; then
	subfinder -d $target | tee $location/subfinder-$target
	echo -e "\n${green}[-] Subfinder done${reset}"
else
	echo -e "${cyan}Subfinder already done${reset}"
fi

echo -e "\n${yellow}[+] Starting amass${reset}\n"

if [[ ! -f $location/amass-$target ]]; then
	amass enum -d $target -o $location/amass-$target
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

echo -e "\n${yellow}[+] Starting subdomainizer${reset}\n"

if [[ ! -f $location/subdomainizer-$target ]]; then
	python3 ~/tools/SubDomainizer/SubDomainizer.py -u $target -g -gt f236a11e6591955df4b985b83ead43eff4f9bd5e -o $location/subdomainizer-$target
	echo -e "\n${green}[-] Subdomainizer done${reset}"
else
	echo -e "${cyan}Subdomainizer already done${reset}\n"
fi

echo -e "\n\n${green}The final list of subdomains are:\n${yellow}"
cat $location/* | sort -u | tee $location/$target-subdomains
echo "${reset}"
sed 's/^/http:\/\//' -i $location/$target-subdomains > $location/http-$target-subdomains
