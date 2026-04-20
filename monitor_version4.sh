#!/bin/bash

# --- 1. Configuration  ---
LOG_FILE="/home/admin/Mini_project_baby_SOC/sample.log"
BLACKLIST="ip_black.txt"
REPORT="report.log"
THRESHOLD=$1

# สีสำหรับ Output (Professional UI)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- 2. Input Validation  ---
if [[ -z "$THRESHOLD" ]] || ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}${BOLD}Usage:${NC} $0 <threshold_number>"
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}[ERROR]${NC} Log file '$LOG_FILE' not found!"
    exit 1
fi

# --- 3. Functions (เน้นความเร็วและแม่นยำ) ---

get_top_target_users() {
    # ดึง User ที่โดนสุ่มรหัสบ่อยที่สุด 3 อันดับ
    grep "Failed password" "$LOG_FILE" | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' | sort | uniq -c | sort -nr | head -3
}

get_top_attackers() {
    # ดึง IP ที่พยายามเจาะระบบบ่อยที่สุด 3 อันดับ
    grep "Failed password" "$LOG_FILE" | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort | uniq -c | sort -nr | head -3
}

check_blacklist_and_count() {
    if [[ ! -f "$BLACKLIST" ]]; then
        echo -e "${YELLOW}[INFO] Blacklist file not found.${NC}"
        return 0
    fi
    
    #  ใช้ grep -f เพื่อหา IP ใน Log ที่ตรงกับใน Blacklist ทันที (ไม่ต้อง Loop)
    local found_ips=$(grep "Failed password" "$LOG_FILE" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -f "$BLACKLIST" | sort -u)
    
    if [[ -z "$found_ips" ]]; then
        echo -e "${GREEN}No blacklisted IPs detected.${NC}"
        return 0
    else
        local count=0
        for ip in $found_ips; do
            echo -e "${RED}⚠️  Blacklist IP detected: $ip${NC}"
            ((count++))
        done
        return $count
    fi
}

write_report() {
    local total_failed=$1
    local bl_hits=$2
    # บันทึกแบบ CSV หรือ Format ที่อ่านง่าย
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILED: $total_failed | BLACKLIST_HITS: $bl_hits" >> "$REPORT"
}

# --- 4. Main Logic ---
clear
echo -e "${BLUE}${BOLD}==========================================="
echo -e "      BABY SOC V4 - SECURITY MONITOR       "
echo -e "===========================================${NC}"

# 1. แสดง Target Users
echo -e "\n${BOLD}👤 Top Target Users:${NC}"
get_top_target_users

# 2. แสดง Attacker IPs
echo -e "\n${BOLD}💀 Top Attacker IPs:${NC}"
get_top_attackers

# 3. เช็ค Blacklist
echo -e "\n${BOLD}🔍 Checking Blacklist...${NC}"
check_blacklist_and_count
hits=$?
echo -e "Total Blacklist hits: ${YELLOW}$hits${NC}"

# 4. วิเคราะห์และ Alert
FAILED_COUNT=$(grep -c "Failed password" "$LOG_FILE")
echo -e "\n-------------------------------------------"
if [ "$FAILED_COUNT" -gt "$THRESHOLD" ]; then
    echo -e "${RED}${BOLD}🚨 ALERT: Brute force detected! ($FAILED_COUNT attempts)${NC}"
else
    echo -e "${GREEN}✅ Status: Normal ($FAILED_COUNT attempts)${NC}"
fi

# 5. จบงาน
write_report "$FAILED_COUNT" "$hits"
echo -e "Report updated in: ${BOLD}$REPORT${NC}"
echo -e "${BLUE}===========================================${NC}"
