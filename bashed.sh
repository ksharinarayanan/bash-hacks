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

while getopts "d:" opt
do
	case "${opt}" in
		d)
			target="${OPTARG}"
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

echo -e "\n${yellow}[+] Starting crt.sh${reset}\n"

if [[ ! -f $subLocation/crtsh-$target ]]; then
	crtsh $target | tee $subLocation/crtsh-$target
	echo -e "\n${green}[-] crt.sh done${reset}"
else
	echo -e "${cyan}crt.sh already done\n${reset}"
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

domainHeart=~/.recon-data/$target


if [[ ! -d $domainHeart/crawl-data ]]; then

	read -p "Should I run the linkfinding module [y/n]: " input
	
	if [[ $input == 'Y' || $input == 'y' ]]; then
		if [[ -f $subLocation/$target-subdomains ]]; then
			echo -e "\n${yellow}[+] Starting linkfinding${reset}\n"
			mkdir $domainHeart/crawl-data
			~/tools/bash-hacks/./add-http.sh $subLocation/$target-subdomains > $domainHeart/crawl-data/http-$target-subdomains
			gospider --sites $domainHeart/crawl-data/http-$target-subdomains -t 20 -c 10 --include-subs --include-other-source -o $domainHeart/crawl-data
			cat $domainHeart/crawl-data/* | sort -u > $domainHeart/crawl-data/final-results
			echo -e "\n${yellow}The subdomains found crawling are: \n${reset}"
			cat $domainHeart/crawl-data/* | sort -u | grep subdomains | cut -d " " -f 3 | tee $subLocation/crawl-subdomains
			cat $subLocation/* | sort -u > $subLocation/$target-subdomains
			echo -e "\n${green}[-] Linkfinding done${reset}\n"
		else
			echo "${red}Please complete the subdomain scan first!${reset}\n"
		fi
	fi
fi

if [[ ! -d $domainHeart/httpx ]]; then

        read -p "Should I run httpx [y/n]: " input

        if [[ $input == 'y' || $input == 'Y' ]]; then

	       echo -e "\n${yellow}[+] Running httpx${reset}\n"
	       curr=$(pwd)
	       mkdir $domainHeart/httpx
	       cd $domainHeart/httpx
	       httpx -l $subLocation/$target-subdomains -store-response -title -status-code -threads 77 -silent -no-color | tee result
	       echo -e "\n${cyan}The live domains are: \n$reset"
	       cat result | grep -v "\[4\|\[5" | cut -d [ -f 1 | cut -d " " -f 1 | tee $domainHeart/live-domains
       	       echo -e "\n$reset"
               cd $curr
               echo -e "${green}\n[-] httpx done\n${reset}"
	fi
fi


if [[ ! -f $domainHeart/ports ]]; then
	read -p "Should I port scan [y/n]: " input

	if [[ $input == 'y' ]]; then
		if [[ -f $subLocation/$target-subdomains ]]; then
			echo -e "\n${yellow}[+] Starting port scan ${reset}\n"
			naabu -silent -hL $subLocation/$target-subdomains -t 20 -o $domainHeart/ports
			echo -e "\n${green}[-] Port scanning completed${reset}\n"
		else
			echo "${red}Please complete the subdomain scan first!${reset}\n"
		fi
	fi
fi

if [[ ! -f $domainHeart/.nuclei-output ]]; then
	read -p "Should I run nuclei [y/n]: " input
	if [[ $input == 'y' || $input == 'Y' ]]; then
		if [[ ! -f $domainHeart/live-domains ]]; then
			echo -e "\n${red}You must run httpx to run nuclei${reset}\n"
			exit 1
		fi
		echo -e "\n${cyan}Output is not saved!${reset}"
		python3 ~/tools/bash-hacks/run-nuclei.py -l $domainHeart/live-domains
		touch $domainHeart/.nuclei-output
	fi
	
fi

