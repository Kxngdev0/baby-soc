#!/bin/bash

LOG_FILE="/tmp/auth_test.log"
REPORT="report.log"
BLACKLIST="ip_black.txt"

# ===== 1. Check Input & Validation (เพิ่มการเช็กตัวเลข) =====
# ถ้าไม่ใส่ค่ามา หรือใส่มาไม่ใช่ตัวเลข [0-9] ให้แจ้งเตือนแล้วหยุด
if [[ -z "$1" ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "❌ [ERROR] Usage: ./monitor.sh <threshold_number>"
    echo "Example: ./monitor.sh 15"
    exit 1
fi

threshold=$1

# ===== 2. Check Log File Access =====
if [ ! -f "$LOG_FILE" ]; then
    echo "⚠️ [ERROR] Log file not found! (Try running with sudo)"
    exit 1
fi

# ===== Functions =====

get_top_attackers() {
    grep "Failed password" "$LOG_FILE" \
    | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' \
    | sort | uniq -c | sort -nr | head -3
}

# ฟังก์ชันใหม่: หาชื่อ User ที่โดนสุ่มรหัสบ่อยที่สุด 
get_top_target_users() {
    grep "Failed password" "$LOG_FILE" \
    | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' \
    | sort | uniq -c | sort -nr | head -3
}

# ฟังก์ชันใหม่: เช็ก Blacklist และนับจำนวนที่เจอ 
check_blacklist_count() {
    local found=0
    if [ ! -f "$BLACKLIST" ]; then
        echo "[INFO] No blacklist file found."
        return 0
    fi

    while read -r ip; do
        if grep -q "$ip" "$LOG_FILE"; then
            echo "🚫 Blacklist IP detected: $ip"
            ((found++))
        fi
    done < "$BLACKLIST"
    return $found # ส่งค่าจำนวนที่เจอออกไปผ่าน Exit Code
}

write_report() {
    # บันทึกประวัติ: วันเวลา | จำนวนพลาด | จำนวน Blacklist ที่เจอ
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $1 | Blacklist Hits: $2" >> "$REPORT"
}

# ===== Main Logic =====

echo "==============================="
echo "   BABY SOC V3 - MONITORING    "
echo "==============================="

# 1. แสดงชื่อ User ที่โดนโจมตีหนักสุด
echo "👤 Top Target Users:"
get_top_target_users
echo ""

# 2. แสดง IP ที่พยายามเจาะระบบมากสุด
echo "💀 Top Attacker IPs:"
get_top_attackers
echo ""

# 3. เช็กรายชื่อ IP ใน Blacklist
echo "🔍 Checking Blacklist..."
check_blacklist_count
hits=$? # รับค่าจาก return ของฟังก์ชัน check_blacklist_count
echo "Total Blacklist hits: $hits"
echo ""

# 4. บันทึกผลและแจ้งเตือน
failed_count=$(grep "Failed password" "$LOG_FILE" | wc -l)
write_report "$failed_count" "$hits"

echo "-------------------------------"
if [ "$failed_count" -gt "$threshold" ]; then
    echo "🚨 ALERT: Brute force detected! ($failed_count attempts)"
else
    echo "✅ Status: Normal"
fi
echo "Report updated in: $REPORT"

