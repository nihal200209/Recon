#!/bin/bash

domain=$1

if [ -z "$domain" ]; then
  echo "Usage: ./Recon.sh <domain>"
  exit 1
fi

outdir="output/$domain"
mkdir -p "$outdir"

logfile="$outdir/recon.log"
exec > >(tee -a "$logfile") 2>&1
clear

# ================= Banner =================
echo "================================================="
echo " ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗ "
echo " ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║ "
echo " ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║ "
echo " ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║ "
echo " ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║ "
echo " ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ "
echo " Recon –        Advanced Live Recon Framework"
echo
echo "          By - Shashank Gupta (Cyber Hunterz)"
echo "================================================="
echo "[+] Target : $domain"
echo "[+] Start  : $(date)"
echo "================================================="

# ================= 1. Subdomains =================
echo
echo " Subdomain Enumeration "
subfinder -d "$domain" -silent | sort -u | tee "$outdir/subdomains.txt"
echo "[✓] Total Subdomains : $(wc -l < "$outdir/subdomains.txt")"

# ================= 2. Live Hosts =================
echo
echo " Live Host Detection "
httpx -l "$outdir/subdomains.txt" -silent | tee "$outdir/live_hosts.txt"
echo "[✓] Live Hosts : $(wc -l < "$outdir/live_hosts.txt")"

# ================= 3. Technology =================
echo
echo " Technology Fingerprinting "
httpx -l "$outdir/live_hosts.txt" -title -sc -td -silent | tee "$outdir/tech.txt"

# ================= 4. Ports =================
echo
echo " Port Scanning "
sed 's~http[s]*://~~' "$outdir/live_hosts.txt" | cut -d/ -f1 | sort -u > "$outdir/hosts.txt"
[ -s "$outdir/hosts.txt" ] && nmap -iL "$outdir/hosts.txt" -T4 --top-ports 1000 | tee "$outdir/ports.txt"

# ================= 4A. Admin Panels =================
echo
echo " Admin Panel Discovery "
> "$outdir/admin_panels.txt"

paths=(admin login admin/login administrator dashboard wp-admin cpanel manage)

for host in $(cat "$outdir/live_hosts.txt"); do
  for p in "${paths[@]}"; do
    url="$host/$p"
    code=$(curl -ks -o /dev/null -w "%{http_code}" "$url")
    if [[ "$code" == "200" || "$code" == "401" || "$code" == "403" ]]; then
      echo "[ADMIN] $url [$code]"
      echo "$url [$code]" >> "$outdir/admin_panels.txt"
    fi
  done
done

echo "[✓] Admin Panels Found : $(wc -l < "$outdir/admin_panels.txt")"

# ================= 5. URL Collection =================
echo
echo " URL Collection "
> "$outdir/urls_raw.txt"

cat "$outdir/live_hosts.txt" | waybackurls 2>/dev/null | tee -a "$outdir/urls_raw.txt"
command -v gau >/dev/null && cat "$outdir/live_hosts.txt" | gau --silent | tee -a "$outdir/urls_raw.txt"
command -v katana >/dev/null && katana -list "$outdir/live_hosts.txt" -silent | tee -a "$outdir/urls_raw.txt"

grep "^http" "$outdir/urls_raw.txt" | grep -vE "\.(jpg|png|css|svg|woff|pdf|mp4)$" | sort -u | tee "$outdir/urls.txt"
echo "[✓] URLs Collected : $(wc -l < "$outdir/urls.txt")"

# ================= 6. Params + XSS =================
echo
echo " Parameter + XSS Detection "

grep "=" "$outdir/urls.txt" | sort -u | tee "$outdir/urls_with_params.txt"

grep -Ei "(q=|s=|search=|redirect=|next=|url=|page=|ref=|id=)" \
 "$outdir/urls_with_params.txt" | tee "$outdir/xss_urls.txt"

cut -d? -f2 "$outdir/urls_with_params.txt" | tr '&' '\n' | cut -d= -f1 | sort -u | tee "$outdir/params.txt"

echo "[✓] XSS URLs : $(wc -l < "$outdir/xss_urls.txt")"

# ================= 6A. IDOR =================
echo
echo " IDOR Detection "
grep -Ei "(id=|uid=|user_id=|account=|profile=|order=|invoice=)" \
 "$outdir/urls_with_params.txt" | sort -u | tee "$outdir/idor_urls.txt"
echo "[✓] IDOR Candidates : $(wc -l < "$outdir/idor_urls.txt")"

# ================= 6B. SQLi =================
echo
echo " SQLi Detection "
grep -Ei "(id=|cat=|item=|pid=|number=)" \
 "$outdir/urls_with_params.txt" | sort -u | tee "$outdir/sqli_urls.txt"
echo "[✓] SQLi Candidates : $(wc -l < "$outdir/sqli_urls.txt")"

# ================= 7. JavaScript Files =================
echo
echo " JavaScript File Discovery "
grep -Ei "\.js(\?|$)" "$outdir/urls.txt" | sort -u | tee "$outdir/js_files.txt"
echo "[✓] JS Files Found : $(wc -l < "$outdir/js_files.txt")"

# ================= 8. API Endpoints =================
echo
echo " Hidden API Endpoint Detection "
grep -Ei "/api/|/v1/|/v2/|/v3/" "$outdir/urls.txt" | sort -u | tee "$outdir/api_endpoints.txt"
echo "[✓] API Endpoints : $(wc -l < "$outdir/api_endpoints.txt")"

# ================= 9. Sensitive Files =================
echo
echo " Sensitive File Detection "
echo
grep -Ei "\.(env|log|bak|old|zip|tar|sql|yml|yaml|conf|backup)$" \
 "$outdir/urls.txt" | sort -u | tee "$outdir/sensitive_files.txt"
echo "[✓] Sensitive Files : $(wc -l < "$outdir/sensitive_files.txt")"

# ================= 10. Open Redirect =================
echo
echo " Open Redirect Detection "
echo
grep -Ei "(redirect=|next=|url=|return=|continue=)" \
 "$outdir/urls_with_params.txt" | sort -u | tee "$outdir/open_redirect.txt"
echo "[✓] Open Redirect Candidates : $(wc -l < "$outdir/open_redirect.txt")"

# ================= 11. Upload Endpoints =================
echo
echo " File Upload Endpoint Detection "
echo
grep -Ei "(upload|file|image|avatar|media)" \
 "$outdir/urls.txt" | sort -u | tee "$outdir/upload_points.txt"
echo "[✓] Upload Endpoints : $(wc -l < "$outdir/upload_points.txt")"

# ================= 12. Auth Endpoints =================
echo
echo " Authentication Endpoint Detection "
echo
grep -Ei "(login|signin|signup|register|auth|reset|forgot|password)" \
 "$outdir/urls.txt" | sort -u | tee "$outdir/auth_endpoints.txt"
echo "[✓] Auth Endpoints : $(wc -l < "$outdir/auth_endpoints.txt")"

# ================= 13. Cloud Assets =================
echo
echo " Cloud Asset Detection "
echo
grep -Ei "(s3.amazonaws.com|storage.googleapis.com|blob.core.windows.net)" \
 "$outdir/urls.txt" | sort -u | tee "$outdir/cloud_assets.txt"
echo "[✓] Cloud Assets : $(wc -l < "$outdir/cloud_assets.txt")"

# ================= 14. Security Headers =================
echo
echo " Security Headers Check "
for host in $(cat "$outdir/live_hosts.txt"); do
  echo "----- $host -----"
  curl -ks -I "$host" | grep -Ei \
  "content-security-policy|x-frame-options|strict-transport-security|x-content-type-options"
done | tee "$outdir/security_headers.txt"

# ================= Completion =================
echo
echo "================================================="
echo "[✔] Recon Scan Completed"
echo "[✔] Output Directory : $outdir"
echo "[✔] Log File         : $logfile"
echo "================================================="
