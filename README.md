# Recon

Step 1: Clone Repository

git clone https://github.com/nihal200209/Recon.git

cd Recon 

Step 2 How to Run the Tool
chmod +x Recon.sh
./Recon.sh  example.com (domain)

Project : 

1. Project Overview
Recon is an automated Bash-based reconnaissance framework designed for authorized security testing and bug bounty reconnaissance. The tool integrates multiple industry-standard recon utilities into a single structured workflow to automate the information gathering phase of penetration testing.

2. Objectives of the Project

•	Automate reconnaissance workflow

•	Reduce manual effort during bug bounty hunting

•	Organize outputs into structured directories

•	Identify high-value vulnerability candidates

•	Generate logs for reporting and documentation

3. Architecture & Workflow

Target Domain

   ↓
   
Subdomain Enumeration

   ↓
   
Live Host Detection

   ↓
   
Technology Fingerprinting

   ↓
   
Port Scanning

   ↓
   
Admin Panel Discovery

   ↓
   
URL Collection

   ↓
   
Parameter Extraction

   ↓
   
Vulnerability Pattern Detection

   ↓
   
Cloud & Sensitive File Detection

   ↓
   
Security Header Analysis

   ↓
   
Structured Output Report



4. Features Breakdown

Subdomain Enumeration

Uses subfinder to discover subdomains.

Live Host Detection

Uses httpx to detect active hosts.

Technology Fingerprinting

Identifies technologies, titles, and status codes.

Port Scanning

Uses nmap to scan top 1000 ports.

Admin Panel Discovery

Detects common admin paths using curl.

URL Collection
Uses waybackurls, gau, and katana.
Vulnerability Pattern Detection
Filters URLs for XSS, IDOR, SQLi, Open Redirect.
JavaScript Discovery
Finds JS files for further analysis.
API Endpoint Detection
Detects API version endpoints.
Sensitive File Detection
Detects exposed backup, config, and environment files.
Cloud Asset Detection
Identifies S3, GCP, and Azure storage links.
Security Header Check
Checks for important HTTP security headers.


6. Output Directory Structure

output/
   └── target.com/
         ├── subdomains.txt
         ├── live_hosts.txt
         ├── tech.txt
         ├── ports.txt
         ├── urls.txt
         ├── xss_urls.txt
         ├── idor_urls.txt
         ├── sqli_urls.txt
         ├── security_headers.txt
         └── recon.log


6. Required Dependencies
•	curl
•	wget
•	git
•	nmap
•	jq
•	golang
•	subfinder
•	httpx
•	waybackurls
•	gau
•	katana


7. Installation Commands

sudo apt update && sudo apt upgrade -y
sudo apt install curl wget git nmap jq golang -y

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest

8. How to Run the Tool
chmod +x Recon.sh
./Recon.sh  example.com (domain)


9. Advantages
•	Fully automated workflow
•	Structured output management
•	Time-efficient reconnaissance
•	Bug bounty ready framework
•	Integrated multi-tool support

10. Limitations
•	Pattern-based detection only (no exploitation)
•	No rate limiting control
•	No auto PDF/HTML report generation
•	No built-in WAF detection


11. Future Improvements
•	Integrate Nuclei for vulnerability scanning
•	Add parallel processing
•	Add JSON export option
•	Generate automatic HTML/PDF reports
•	Add Telegram/Slack notifications
•	Implement rate limiting and WAF detection


12. Legal Disclaimer
This tool is intended strictly for educational purposes and authorized security testing only. Unauthorized scanning or testing of systems without proper permission is illegal and punishable under applicable laws.




