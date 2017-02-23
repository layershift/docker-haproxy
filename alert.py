import subprocess
import time
import smtplib
from email.mime.text import MIMEText
import socket
import datetime

webserver=socket.gethostname()                                      # hostname
user=''                                                             # haproxy user
password=''                                                         # haproxy password
host_ip=socket.gethostbyname(socket.gethostname())                  # server IP
wisdom_url=''                                                       # URL to wisdom page about the host/setup
client=''                                                           # stack name
stack=''                                                            # LIVE | DEV
ctid=''

def main():
    firstrun = True
    currentstat = []
    while True:
        readstats = subprocess.check_output(["echo show stat | socat unix-connect:/var/lib/haproxy/stats stdio"], shell=True)
        vips = readstats.splitlines()
        #check if server is up or down and matches previous weight
        #
        for i in range(0,len(vips)):
            #store currnet status
            if "UP" in str(vips[i]):
                currentstat.append("UP")
            elif "DOWN" in str(vips[i]):
                currentstat.append("DOWN")
            else:
                currentstat.append("none")
            #ignore first run as we have no old data to compare to
            if firstrun == False:
                #compare new and old stats
                if (currentstat[i] != oldstat[i] and currentstat[i]!="none") and ("FRONTEND" not in str(vips[i]) and "BACKEND" not in str(vips[i])):
                    servername= str(vips[i])
                    servername = servername.split(",")
                    realserver = servername[0]
                    dttm = datetime.datetime.now()
                    alert = "Alert raised at: " + dttm.isoformat() + "\n\n" + realserver + " has changed status!\n"+ servername[1] + " is now " + currentstat[i] + "\n\nPlease check HAProxy status page: http://"+user+":"+password+"@"+host_ip+"/stats ( "+user+":"+password+" )."
                    mail(str(alert))

        firstrun = False
        oldstat = []
        oldstat = currentstat
        currentstat = []
        time.sleep(10)

def mail(alert):
    me="root@" + webserver
    you=""
    msg=MIMEText(alert)
    msg["From"] = me
    msg["To"] = you

    if "DOWN" in alert:
        msg["Subject"] = "[Monitor] [PROBLEM]: " +servername[1]+ ": HAproxy MySQL alert raised on " + webserver
    elif "UP" in alert:
        msg["Subject"] = "[Monitor] [OK]: "+servername[1]+": HAproxy MySQL alert cleared on " + webserver

    s = smtplib.SMTP('localhost')
    try:
        s.sendmail(me, [you], msg.as_string())
    finally:
        s.quit()

main()
