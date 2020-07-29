black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

echo -e "\n${yellow}[+] Installing subfinder${reset}\n"

GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/cmd/subfinder

echo -e "\n${green}[-] Installed subfinder${reset}\n"

echo -e "\n${yellow}[+] Installing amass${reset}\n"

export GO111MODULE=on
go get -v github.com/OWASP/Amass/v3/...

echo -e "\n${green}[-] Installed amass${reset}\n"

echo -e "\n${yellow}[+] Installing assetfinder${reset}\n"

go get -u github.com/tomnomnom/assetfinder

echo -e "\n${green}[-] Installed assetfinder${reset}\n"

echo -e "\n${yellow}[+] Installing findomain${reset}\n"

mkdir ~/tools
if [[ ! -d ~/tools/ ]]; then
	mkdir ~/tools
fi

wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux
chmod +x findomain-linux

echo -e "\n${green}[-] Installed findomain${reset}\n"

echo -e "\n${yellow}[+] Installing subdomainizer${reset}\n"

cd ~/tools/
git clone https://github.com/nsonaniya2010/SubDomainizer.git
cd SubDomainizer
pip3 install -r requirements.txt
cd

echo -e "\n${green}[-] Installed subdomainizer${reset}\n"

echo -e "\n${yellow}[+] Installing github subdomains${reset}\n"

cd ~/tools/
git clone https://github.com/gwen001/github-search.git

echo -e "\n${green}[-] Installed github subdomains${reset}\n"

echo -e "\n${yellow}[+] Installing httpx${reset}\n"

GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx

echo -e "\n${green}[-] Installed httpx${reset}\n"

echo -e "\n${yellow}[+] Installing dirsearch${reset}\n"

cd ~/tools/
git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch

echo -e "\n${green}[-] Installed dirsearch${reset}\n"

echo -e "\n${yellow}[+] Installing naabu${reset}\n"

GO111MODULE=on go get -v github.com/projectdiscovery/naabu/cmd/naabu

echo -e "\n${green}[-] Installed naabu${reset}\n"

echo -e "\n${yellow}[+] Installing Osmedeus${reset}\n"

git clone https://github.com/j3ssie/Osmedeus

echo -e "\n${green}[-] Installed Osmedeus${reset}\n"

echo -e "\n${yellow}[+] Installing waybackurls, gau${reset}\n"

go get github.com/tomnomnom/waybackurls
GO111MODULE=on go get -u -v github.com/lc/gau

echo -e "\n${green}[-] Installed waybackurls and gau${reset}\n"

echo -e "\n${yellow}[+] Installing gf, qsreplace, unfurl ${reset}\n"

go get -u github.com/tomnomnom/gf
echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns
mv Gf-Patterns/*.json ~/.gf

go get -u github.com/tomnomnom/qsreplace
go get -u github.com/tomnomnom/unfurl

echo -e "\n${yellow}[+] Installing gf, qsreplace, unfurl${reset}\n"

echo -e "\n${yellow}[+] Installing gospider${reset}\n"

go get -u github.com/jaeles-project/gospider

echo -e "\n${green}[-] Installed gospider${reset}\n"

echo -e "\n${yellow}[+] Installing bash-hacks${reset}\n"

cd ~/tools/
git clone https://github.com/micha3lb3n/bash-hacks.git

echo -e "\n${green}[-] Installed bash-hacks${reset}\n"

echo -e "\n${yellow}[+] Installing subzy${reset}\n"

go get -u -v github.com/lukasikic/subzy
go install -v github.com/lukasikic/subzy

echo -e "\n${green}[-] Installed subzy${reset}\n"

echo -e "\n${yellow}[+] Installing nuclei${reset}\n"

GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei

echo -e "\n${green}[-] Installed nuclei${reset}\n"

echo -e "${cyan}Happy hacking ~ !${reset}\n"



