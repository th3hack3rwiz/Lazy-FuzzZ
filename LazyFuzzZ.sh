echo -e "\033[0;37m\e[1m$(figlet -f slant  Lazy FuzzZ)"
YELLOW='\033[0;33m'
echo -e "\033[0;37m\e[1m\n\t\t\t  ${YELLOW}© Created By: th3hack3rwiz"
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
MAGENTA='\033[0;95m'
new=0
function usage()
{
	echo -e "${GREEN}\n[+] Usage:\n\t./lazyfuzz  <target-domain name> <subdomains' http/https URLs to Fuzz file> <common wordlist file>"	
	echo -e "${GREEN}  Eg: ./lazyfuzz  example.com   example.com_https_subdomains.txt   common_fuzzing_wordlist.txt\n"
	echo -e "${GREEN} -f : to use your own ffuf flags. (IMPORTANT: -f, if used, should be written before other arguments)"
	echo -e "${GREEN}  Eg: ./lazyfuzz -f '-mc 403 -t 200'  example.com   example.com_https_subdomains.txt   common_fuzzing_wordlist.txt"
	echo -e "${CYAN}Default ffuf flags used: -mc 200,403 -fs 0 -t 80 -sa -timeout 7"
	echo -e "${RED}WARNING: Do not specify Output Flags, -u, and -w !"
}

while getopts :f: fuzz_args; do 
	case $fuzz_args in
		f)
			echo -e "\n\nReplacing original flags with new flags..."
			new=1
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


if [[ $# -ne 3 ]]
then usage
	echo -e "\n[+]Check usage!"
	 else
	 	printf "\n"
		cat ${2} | grep ${1} | sort -u | sed 's/'${1}'/'${1}'\/FUZZ/g' > ${1}.fuZZmeePleasee
		echo -e "${GREEN}[+] Starting Lazy FuzzZ! :D\n"
		mkdir lazyFuzzZ.output.${3}
		for line in $(cat ${1}.fuZZmeePleasee) 
		do echo -e "${CYAN}[+]Running on $line"
		subdomain=$(echo ${line} | sed s/FUZZ//g | awk -F '/' '{print $3}')  #storing subdomain name
		if [[ $new -eq 1 ]] ; then
			 ffuf $(echo $flags) -u $line -w ${3} -of csv -o test > /dev/null
		else
			 ffuf -mc 200,403 -fs 0 -t 80 -sa -timeout 7 -u $line -w ${3} -of csv -o test > /dev/null
		fi
		cat test | sed s/'^.*http'/http/g | sed 's/\,\,/ /g' | grep http > lazyFuzzZ.output.${3}/${subdomain}.output
		if [[ -s lazyFuzzZ.output.${3}/${subdomain}.output ]]	#checking if file is non empty
			then 
				max_occurence=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $3}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $1}')
				max_size=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $3}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $2}')
			if [[ $max_occurence>100 ]]
				echo -e "${MAGENTA}[+]Results obtained with false positives... Removing them..."
				then cat lazyFuzzZ.output.${3}/${subdomain}.output | grep -v $max_size > buff ; cat buff > lazyFuzzZ.output.${3}/${subdomain}.output
			fi
			if [[ -s lazyFuzzZ.output.${3}/${subdomain}.output ]]	#checking if file is non empty

				then
				line_of_result=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | wc -l)
				max_freq_size=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $3}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $2}')
				max_size_freq=$(cat lazyFuzzZ.output.${3}/${subdomain}.output | awk -F "," '{print $3}'| sort -n | grep [[:digit:]] | uniq -c | sort -k1 -nr | head -1 | awk '{print $1}')
				if [[ line_of_result -gt 1 ]]; then
					if [[ max_size_freq -le line_of_result/2 ]]
					then echo -e "${GREEN}[+] Results were obtained for $line ! :D \n"
					else
						echo -e "${ORANGE}[+]More false positives detected! :-]] Removing them..."
						cat lazyFuzzZ.output.${3}/${subdomain}.output | grep -v $max_freq_size > buff ; cat buff > lazyFuzzZ.output.${3}/${subdomain}.output
						echo -e "${GREEN}[+] Results were obtained for $line ! :D \n"
					fi 
				fi	
					cat lazyFuzzZ.output.${3}/${subdomain}.output | cut -d " " -f1 >> lazyFuzzZ.output.${3}/burpSeeds
			else
				echo -e "${BLUE}[-] Results found were all false positives! :( Moving on..\n"
				rm lazyFuzzZ.output.${3}/${subdomain}.output			#removing it if it's empty
			fi
		else
			echo -e "${RED}[-]No results found! :-| Moning on..\n"
			rm lazyFuzzZ.output.${3}/${subdomain}.output			#removing it if it's empty
		fi
		sleep 7
		done
		#echo -e "\n${CYAN}[+]Firing up BurpFeed and sending the results to Burpsuite!"
		#python <path to bfedd.py>/bfeed.py lazyFuzzZ.output.${3}/burpSeeds > /dev/null
		#echo -e "\n${GREEN}[+] Script completed successfully! :D"
	fi
