#!/bin/bash
BOLD='\e[1m'
GOLD='\e[38;5;226m'
GREY='\033[0;37m'
echo -e "${GOLD}${BOLD}$(figlet -f slant  Lazy FuzzZ)"
echo -e "\033[0;37m\e[1m\n\t\t\t  ${GREY}${BOLD}© Created By: th3hack3rwiz"
CYAN='\033[0;36m'
PEACH='\e[38;5;216m'
GREEN='\e[38;5;149m'
ORANGE='\e[38;5;202m'
MAGENTA='\033[0;95m'
PINK='\e[38;5;204m'
YELLOW='\e[38;5;227m'
OFFWHITE='\e[38;5;157m'
RED='\e[38;5;196m'

new=0	#new flag
dis=0	#disable flag
append=0 #append flag
function usage()
{
	echo -e "${PINK}\n[+] Usage:\n\t./lazyFuzzZ  <target-domain name> <subdomains_http/https_URLs_to_fuzz.txt> <common wordlist file>"	
	echo -e "${GREEN}  Eg: ./lazyFuzzZ  example.com   example.com_https_subdomains.txt   common_fuzzing_wordlist.txt\n"
	echo -e "${GREEN} -f : to use your own ffuf flags. ${OFFWHITE}(IMPORTANT: This flag should be written before command line arguments)"
	echo -e "${GREEN}  Eg: ./lazyFuzzZ -f '-mc 403 -t 200'  example.com   example.com_https_subdomains.txt   common_fuzzing_wordlist.txt\n"
	echo -e "${GREEN} -a : to append ffuf flags. ${OFFWHITE}(IMPORTANT: This flag should be written before the command line arguments)"
	echo -e "${GREEN}  Eg: ./lazyFuzzZ -a '-H User-Agent:xyz -H X-Forwarded-For:127.0.0.1 -b cookie_1:value;cookie_2:value -replay-proxy http://127.0.0.1:8080' example.com  	example.com_https_subdomains.txt common_fuzzing_wordlist.txt"
	echo -e "${YELLOW}\n[+] Tip! If you are going to using the -replay-proxy ffuf flag, use -d flag with lazyFuzzZ."
	echo -e "${GREEN}\n -d : to DISABLE bfeed.py ${OFFWHITE}(IMPORTANT: This flag should be written before command line arguments)"
	echo -e "${GREEN} -h : to display usage."
	echo -e "${CYAN}\n[+] Default ffuf flags used: -mc 200,403 -fs 0 -t 80 -sa -timeout 7"
	echo -e "${RED}[-] WARNING: Do not specify 'output flags', -u, and -w for ffuf!"
}

while getopts :f:dha: fuzz_args; do 
	case $fuzz_args in
		f)
			#echo -e "\n\n[+]Replacing original flags with new flags..."
			new=1
			flags=$OPTARG
			;;
		d)
			#echo -e "\n[+]Disabling bfeed.py..."
			dis=1
			;;
		h)	usage
			exit 1
			;;
		a)	append=1
			flags=$OPTARG
			;;
		*)
			usage
			echo "Invalid argument!"
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [[ append -eq 1 && new -eq 1 ]] ; then
		echo -e "${RED}\n[-] Don't specify -a and -f flags together!"
		exit 1
fi
if [[ $# -ne 3 ]] ; then
	usage
	echo -e "\n[-] Not enough arguments! Check usage."
else
	printf "\n"
	cat ${2} | grep ${1} | uniq | sed 's/'${1}'/'${1}'\/FUZZ/g' > ${1}.fuZZmeePleasee
	echo -e "${GREEN}[+] Starting Lazy FuzzZ! :D\n"
	mkdir lazyFuzzZ.output.${3}
	for line in $(cat ${1}.fuZZmeePleasee) ; do
		echo -e "${CYAN}[+]Running on $line"
		subdomain=$(echo ${line} | sed s/FUZZ//g | awk -F '/' '{print $3}')  #storing subdomain name
		if [[ $new -eq 1 ]] ; then
			ffuf $(echo $flags) -u $line -w ${3} -of csv -o test > /dev/null
		elif [[ $append -eq 1 ]] ; then
			ffuf -mc 200,403 -fs 0 -t 80 -sa -timeout 7 -u $line -w ${3} $(echo $flags) -of csv -o test > /dev/null	
		else
			ffuf -mc 200,403 -fs 0 -t 80 -sa -timeout 7 -u $line -w ${3} -of csv -o test > /dev/null
		fi
		cat test | sed s/'^.*http'/http/g | sed 's/\,\,/ /g' | sed 's/ [[:digit:]]*,/                    /g' | sed 's/,$//g' | grep http > lazyFuzzZ.output.${3}/${subdomain}.output
		if [[ -s lazyFuzzZ.output.${3}/${subdomain}.output ]] ; then 	#checking if file is non empty
			max_occurence=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $2}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $1}')
			max_size=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $2}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $2}')
			if [[ max_occurence -gt 100 ]] ; then
				echo -e "${MAGENTA}[+] Results obtained with false positives... Removing them..."
				cat lazyFuzzZ.output.${3}/${subdomain}.output | grep -v $max_size > buff ; cat buff > lazyFuzzZ.output.${3}/${subdomain}.output ; rm buff
				if [[ -s lazyFuzzZ.output.${3}/${subdomain}.output ]] ;	then
					line_of_result=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l)
					max_freq_size=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $2}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $2}')
					max_size_freq=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $2}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $1}')
					if [[ $line_of_result -gt 2 ]]; then
						if [[ $max_size_freq -le line_of_result/2 ]] ; then
							cat lazyFuzzZ.output.${3}/${subdomain}.output | cut -d " " -f1 >> lazyFuzzZ.output.${3}/burpSeeds
							echo -e "${GREEN}[+] Number of results obtained for $line : ${YELLOW}$( cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l )   \n"
						else
							echo -e "${ORANGE}[+] More false positives detected! :-]] Removing them..."
							cat lazyFuzzZ.output.${3}/${subdomain}.output | grep -v $max_freq_size > buff ; cat buff > lazyFuzzZ.output.${3}/${subdomain}.output ; rm buff
							if [[ -s lazyFuzzZ.output.${3}/${subdomain}.output ]] ; then
								cat lazyFuzzZ.output.${3}/${subdomain}.output | cut -d " " -f1 >> lazyFuzzZ.output.${3}/burpSeeds
								echo -e "${GREEN}[+] Number of results obtained for $line : ${YELLOW}$( cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l )   \n"
							else
								echo -e "${PEACH}[-] Results found were all false positives! :( Moving on..\n"
								rm lazyFuzzZ.output.${3}/${subdomain}.output			#removing it if it's empty
							fi	
						fi 
					else
						cat lazyFuzzZ.output.${3}/${subdomain}.output | cut -d " " -f1 >> lazyFuzzZ.output.${3}/burpSeeds
						echo -e "${GREEN}[+] Number of results obtained for $line : ${YELLOW}$( cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l )   \n"
					fi	
				else
					echo -e "${PEACH}[-] Results found were all false positives! :( Moving on..\n"
					rm lazyFuzzZ.output.${3}/${subdomain}.output			#removing it if it's empty
				fi				
			else
				cat lazyFuzzZ.output.${3}/${subdomain}.output | cut -d " " -f1 >> lazyFuzzZ.output.${3}/burpSeeds
				echo -e "${GREEN}[+] Number of results obtained for $line : ${YELLOW}$( cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l )   \n"
			fi
		else
			echo -e "${RED}[-] No results found! :-| Moving on..\n"
			rm lazyFuzzZ.output.${3}/${subdomain}.output
		fi
		sleep 7
	done
	rm  ${1}.fuZZmeePleasee
	if [[ $dis -eq 0 ]] ; then
		echo -e "\n${CYAN}[+]Firing up BurpFeed and sending the results to Burpsuite!"
		#python <path_to_bfeed.py>/bfeed.py lazyFuzzZ.output.${3}/burpSeeds > /dev/null
	fi
	echo -e "${GREEN}[+] Thank you for using Lazy FuzzZ! :D"
	rm test
	rm ${1}.fuZZmeePleasee
fi
