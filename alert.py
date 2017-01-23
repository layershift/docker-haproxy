import subprocess
import time
import smtplib
from email.mime.text import MIMEText
import socket
import datetime
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
                    alert = "Alert raised at: " + dttm.isoformat() + "\n\n" + realserver + " has changed status!\n"+ servername[1] + " is now " + currentstat[i] + "\n\nPlease check HAProxy status page: http://layershift:wqG6phBp73zYsrJ6@node141737-magento5.j.layershift.co.uk/stats \n\nand Galera Cluster members!\n"
                    mail(str(alert))
        firstrun = False
        oldstat = []
        oldstat = currentstat
        currentstat = []
        time.sleep(10)
def mail(alert):
    sender = 'root@node141737-magento5.j.layershift.co.uk'
    reciever = 'bart+magento@layershift.com'
    msg=MIMEText(alert)
    if "DOWN" in alert:
        msg["Subject"] = "[PROBLEM] [Magento 5]: HAproxy MySQL alert raised on " + socket.gethostname()
    elif "UP" in alert:
        msg["Subject"] = "[OK] [Magento 5]: HAproxy MySQL alert cleared on " + socket.gethostname()
    else:
        msg["Subject"] = "[Magento 5]: HAproxy MySQL alert on " + socket.gethostname()
    msg["From"] = sender
    msg["To"] = reciever
    smtpObj = smtplib.SMTP('127.0.0.1', 25)
    try:
        smtpObj.sendmail(sender, reciever, msg.as_string())
    finally:
        smtpObj.quit()
main()
