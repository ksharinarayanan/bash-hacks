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
        echo -e "\n${cyan}Target: ${target}${reset}\n"
        run_all=1
else
        echo -e "\n${cyan}Modules will run on an input by input basis...${reset}\n"
        run_all=0
fi



subLocation=~/.recon-data/$target/subdomains

if [[ ! -d ~/.recon-data/$target ]]; then
	mkdir ~/.recon-data/$target
fi

if [[ ! -d ~/.recon-data/$target/subdomains ]]; then
	mkdir ~/.recon-data/$target/subdomains
else
	subLocation=~/.recon-data/$target/subdomains/latest
	if [[ -d $subLocation ]]; then
		rm -rf $subLocation
	fi
	mkdir ~/.recon-data/$target/subdomains/latest
fi

echo -e "\n${yellow}[+] Starting findomain${reset}\n"
findomain -q -t $target -u $subLocation/findomain-$target
echo -e "\n${green}[-] Findomain done${reset}"

echo -e "\n${yellow}[+] Starting chaos${reset}\n"
chaos -d $target -silent | tee $subLocation/chaos-$target
echo -e "\n${green}[-] Chaos done${reset}\n"

echo -e "\n\n${green}The final list of subdomains are:\n${yellow}"

cat $subLocation/* | sort -u | grep $target | tee $subLocation/$target-subdomains
echo "${reset}"
total=$(cat $subLocation/$target-subdomains | grep -c "")
echo -e "\n\nTotal subdomains found: $total\n"

echo -e "\n[+] Starting HTTPX\n"
httpxLocation=""
if [[ -f $HOME/.recon-data/$target/live-domains ]]; then
	httpxLocation="$HOME/.recon-data/${target}/latest-live-domains"
else
	httpxLocation="$HOME/.recon-data/${target}/live-domains"
fi

cat $subLocation/$target-subdomains | httpx -silent -threads 200 | tee $httpxLocation
cat $httpxLocation | sort -u > temp
mv temp $httpxLocation

echo -e "\n[-] HTTPX done\n"

source $HOME/tools/Slack/slack.sh

if [[ -f $HOME/.recon-data/$target/latest-live-domains ]]; then
	changes=$(comm -23 $HOME/.recon-data/$target/latest-live-domains $HOME/.recon-data/$target/live-domains)
	mv $HOME/.recon-data/$target/latest-live-domains $HOME/.recon-data/$target/live-domains	
	if [[ $changes != "" ]]; then
		echo "New subdomains found on target ${target}:" | subdomain_monitor
		spaces=$(echo $changes | head -n 1 | tr -cd ' \t' | wc -c)
		message=""
		for ((i=1;i<=$spaces+1;i++)); do
			message+=$(echo $changes | cut -d ' ' -f $i)
			message+="\n"
			domain=$(echo $changes | cut -d ' ' -f $i)
			python3 $HOME/tools/Slave/all-templates-nuclei.py $domain
		done
		echo $message | subdomain_monitor
	fi
fi
