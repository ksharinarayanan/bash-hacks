black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

if [[ -f ~/.bash_aliases ]]; then
	source ~/.bash_aliases
fi

while getopts "d:a" opt
do
	case "${opt}" in
		d)
			target="${OPTARG}"
			;;
		a)
			run_all="${OPTARG}"
			;;
	esac
done

if [[ $target == "" ]]; then
	echo "Usage: ./bashed.sh -d domain.com"
	exit 2
fi

if [[ ! -d ~/.recon-data ]]; then
        mkdir ~/.recon-data
        echo -e "\n${green}Your output would be stored under ~/.recon-data/${reset}\n"
	echo -e "\n${cyan}Make sure that you have subfinder, amass, assetfinder, findomain, github-subdomains.py, subdomainizer, httpx, gospider and naabu installed with github-subdomains.py and subdomainizer under the ~/tools directory${reset}\n"

fi

if [[ $target == "list" ]]; then
	targets=$(ls ~/.recon-data/)
	echo ""
	for t in $targets; do
		if [[ -f ~/.recon-data/$t/subdomains/$t-subdomains ]]; then
			l=$(cat ~/.recon-data/$t/subdomains/$t-subdomains | grep -c "")
			if [[ -f ~/.recon-data/$t/live-domains ]]; then
				echo "$yellow$t - $l subdomains $green( LIVE - $(count ~/.recon-data/$t/live-domains) )$reset"
			else
				echo "$cyan$t - $l subdomains$reset"
			fi
		else
			echo "${red}$t - scanning not complete${reset}"
		fi
	done
	echo ""
	exit 2
fi

run_all=1

if [[ $run_all != "" ]]; then
        echo -e "\n${cyan}All modules set to run...${reset}\n"
        run_all=1
else
        echo -e "\n${cyan}Modules will run on an input by input basis...${reset}\n"
        run_all=0
fi



subLocation=~/.recon-data/$target/subdomains

if [[ -d ~/.recon-data/$target/subdomains ]]; then
	read -p "The target's data already exists, do you want to start fresh, if no it continues from where you left(y/n): " input
	if [[ $input == 'y' || $input == 'Y' ]]; then
		rm -rf ~/.recon-data/$target
	fi
fi
if [[ ! -d ~/.recon-data/$target ]]; then
	mkdir ~/.recon-data/$target
fi

if [[ ! -d ~/.recon-data/$target/subdomains ]]; then
	mkdir ~/.recon-data/$target/subdomains
fi

echo -e "\n${yellow}[+] Starting subfinder${reset}\n"
if [[ ! -f $subLocation/subfinder-$target ]]; then
	subfinder -d $target -silent | tee $subLocation/subfinder-$target
	echo -e "\n${green}[-] Subfinder done${reset}"
else
	echo -e "${cyan}Subfinder already done${reset}"
fi

echo -e "\n${yellow}[+] Starting amass${reset}\n"

if [[ ! -f $subLocation/amass-$target ]]; then
	amass enum --passive -d $target -o $subLocation/amass-$target
	echo -e "\n${green}[-] Amass done${reset}"
else
	echo -e "${cyan}Amass already done${reset}"
fi

echo -e "\n${yellow}[+] Starting findomain${reset}\n"

if [[ ! -f $subLocation/findomain-$target ]]; then
	findomain -q -t $target -u $subLocation/findomain-$target
	echo -e "\n${green}[-] Findomain done${reset}"
else
	echo -e "${cyan}Findomain already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting assetfinder${reset}\n"

if [[ ! -f $subLocation/assetfinder-$target ]]; then
	assetfinder -subs-only $target | tee $subLocation/assetfinder-$target
	echo -e "\n${green}[-] Assetfinder done${reset}"
else
	echo -e "${cyan}Assetfinder already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting chaos${reset}\n"

if [[ ! -f $subLocation/chaos-$target ]]; then
	chaos -d $target -silent | tee $subLocation/chaos-$target
else
	echo -e "${cyan}Chaos already done\n${reset}"
fi

echo -e "\n${yellow}[+] Starting subdomainizer${reset}\n"

if [[ ! -f $subLocation/subdomainizer-$target ]]; then
	python3 ~/tools/SubDomainizer/SubDomainizer.py -u $target -g -gt $GITHUB_API_KEY -o $subLocation/subdomainizer-$target
	echo -e "\n${green}[-] Subdomainizer done${reset}"
else
	echo -e "${cyan}Subdomainizer already done${reset}\n"
fi

echo -e "\n${yellow}[+] Starting github subdomains\n${reset}"

if [[ ! -f $subLocation/github-subdomains-$target ]]; then
	python3 ~/tools/github-search/github-subdomains.py -d $target -t $GITHUB_TOKEN | tee $subLocation/github-subdomains-$target
	echo -e "\n${green}[-] Github subdomains done${reset}"
else
	echo -e "\n${cyan}Github subdomains already done${reset}\n"
fi

echo -e "\n\n${green}The final list of subdomains are:\n${yellow}"
cat $subLocation/* | sort -u | grep $target | tee $subLocation/$target-subdomains
echo "${reset}"
total=$(cat $subLocation/$target-subdomains | grep -c "")
echo -e "\n\nTotal subdomains found: $total\n"

httpxLocation=""
if [[ -f ~/.recon-data/$target/live-domains ]]; then
	httpxLocation="~/.recon-data/${target}/latest-live-domains"
else
	httpxLocation="~/.recon-data/${target}/live-domains"
fi

cat $subLocation/$target-subdomains | httpx -silent | tee $httpxLocation
cat $httpxLocation | sort -u | tee temp
mv temp $httpxLocation
