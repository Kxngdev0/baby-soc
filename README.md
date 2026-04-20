🛡️ PHOLX.CO.,LTD: Mini Project Baby SOC (v4)
Lightweight Security Operations Center (SOC) Terminal Dashboard. โครงการขนาดเล็กสำหรับฝึกหัด Intern ของ PHOLX เพื่อเรียนรู้พื้นฐานการทำ Log Analysis และ System Monitoring โดยใช้เพียง Bash Script
🚀 Overview
สคริปต์นี้ถูกออกแบบมาเพื่อเฝ้าระวังความปลอดภัยของ Server ในระดับพื้นฐาน (101) โดยเน้นความเร็ว ความเบา และความแม่นยำในการดักจับพฤติกรรมสุ่มเสี่ยงจากการ Login
Key Features:
👤 Top Target Users: คัดแยก User ที่โดนพยายามสุ่มรหัสผ่านบ่อยที่สุด
💀 Top Attacker IPs: ระบุ IP Address ที่เป็นอันตราย
🔍 Blacklist Checking: ตรวจสอบ IP กับบัญชีดำ (ip_black.txt) แบบ Real-time
📊 Professional UI: หน้าจอ Terminal Dashboard สวยงาม เข้าใจง่าย
🛠️ Getting Started
Prerequisites:
Linux (Debian/Ubuntu recommended)
Root/Sudo privileges (for reading auth.log)
grep, awk, sed (standard in most distros)


