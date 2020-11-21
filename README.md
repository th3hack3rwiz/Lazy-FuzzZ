![](https://th3hack3rwiz.github.io/images/LazyFuzz/banner_final.PNG)
# Lazy-FuzzZ

Sometimes we want to fuzz a set of sub-domain URLs with a common wordlist for content discovery. Fuzzing each URL one by one is a tedious task, and not to mention the false positives we obtain in those results. To solve this problem I created Lazy FuzzZ. It fuzzes all those urls, removes all the false positive results and stores only legitimate results which are later sent to Burp Suite.

## Installation

1. Clone the repository : git clone https://github.com/th3hack3rwiz/Lazy-FuzzZ.git
2. cd Lazy-FuzzZ ; chmod +x lazyFuzzZ.sh 
3. The script is now ready to use. 

## Requirements

1. Must have ffuf installed from: https://github.com/ffuf/ffuf
2. Must have bfeed.py installed from: https://github.com/ZephrFish/BurpFeed/blob/master/bfeed.py

## Instructions

- Add the path to bfeed.py on line no. 129 of lazyFuzzZ.sh.
- Use flags (-d ,-f, or -a) if required, before supplying command line arguments.

## Usage

- It  requires 3 command line arguments: ./lazyFuzzZ.sh <target_domain_name> <subdomains_https.txt> <common-wordlist.txt>

![](https://th3hack3rwiz.github.io/images/LazyFuzz/usage_final.PNG)

## Example usage

![](https://th3hack3rwiz.github.io/images/LazyFuzz/results.PNG)

# Explained output

![](https://th3hack3rwiz.github.io/images/LazyFuzz/output_final.PNG)

## Features 

1. Helps in automating the directory enumeration process.
2. Provides users with an option to use their prefered set of ffuf flags.
3. Fuzzes a set of sub-domains' URLs with a common-wordlist and stores clean results in a new directory. *(It creates a new directory using name of the wordlist supplied)*
4. Removes most false positive from the results we obtain from ffuf.
5. Adds only legitimate results to an active burp session using bfeed.py.
