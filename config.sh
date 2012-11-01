echo "Vergeben Sie eine ID für den Drucker:"
read ID
echo "Drucker aktiv (0/1)?"
read IS_ACTIVE
echo "IS_ACTIVE=$IS_ACTIVE" >> ./cfg/$ID.cfg


# usw

#IS_ACTIVE=1
#TYP=Canon7055
#IS_COLOUR=1
#IP=10.16.102.211:8000
#ADMIN_USER=7654321
#ADMIN_PWD=7654321
#DIR_NEWUSER=
#PARAM_NEWUSER=
#DIR_LIMIT=
#PARAM_LIMIT=
#DIR_DEL_USER=
#PARAM_DEL_USER=
#CMD_ADDUSER=curl -s -b <TMPDIR>/cookie_<ID>.txt -d "SecID=<NO>&Pswd=0&Pswd_Chk=1&TotalCheck=1&Flag=Exec_Data" "<ADMIN_USER>:<ADMIN_PWD>@<IP>/rps/csp.cgi"
#CMD_COOKIE=curl -c <TMPDIR>/cookie_<ID>.txt "<IP>/login" -d "uri=/&deptid=<ADMIN_USER>&password=<ADMIN_PWD>" && curl -s -b <TMPDIR>/cookie_<ID>.txt -c <TMPDIR>/cookie_<ID>.txt "<ADMIN_USER>:<ADMIN_PWD>@<IP>/rps/nativetop.cgi?RUIPNxBundle=&CorePGTAG=PGTAG_CONF_ENV_PAP" > /dev/null
# Die Werte geben die Position der entsprechenden Werte in der Auswertedatei des jeweiligen 
# Kopierers an. Dabei ist folgende Reihenfolge zu beachten:
# KopienSW;DruckSW;LimitSW;KopienCl;DruckCl;LimitCl
#FELDER=1;0;2;0;0;0

