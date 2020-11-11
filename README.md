# Lazy-FuzzZ

## Installation

1. Clone the repository : git clone https://github.com/th3hack3rwiz/Lazy-FuzzZ.git
2. The script is ready to use. 

## Requirements

1. Must have ffuf installed from: https://github.com/ffuf/ffuf
2. Must have bfeed.py installed from: https://github.com/ZephrFish/BurpFeed/blob/master/bfeed.py

## Instructions

- Add path to bfeed.py in LazyFuzzZ.sh on line no. 90

## Usage

**[+] Usage:** ./LazyFuzzZ.sh  <target-domain_name> <subdomains_https_file.txt> <common_wordlist.txt>  

***Eg:*** ./LazyFuzzZ.sh  example.com example.com_https_subdomains.txt   common_fuzzing_wordlist.txt

  **-f :** to use your own ffuf flags. (**IMPORTANT:** -f, if used, should be written before other arguments)

 ***Eg:*** ./LazyFuzzZ.sh -f '-mc 403 -t 200 -recursion -recursion-depth 3'  example.com example.com_https_subdomains.txt   common_fuzzing_wordlist.txt

 **[+] Default FFUF Flags used:** -mc 200,403 -fs 0 -t 80 -sa -timeout 7

 **[-] WARNING:** Do not specify Output Flags, -u, and -w !

## Features 

1. Helps in automating the fuzzing process.
2. Fuzzes a set of subdomain URLs with a common-wordlist and gives clean results in a new directory.  
3. Removes most false positive fuzzing outcomes.
4. Adds only legitimate results to an active burp session using bfeed.py.
