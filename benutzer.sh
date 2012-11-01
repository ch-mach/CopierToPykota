#!/bin/bash

#Die Datei $FILE_KOPIERER_ACCOUNTS wird erstellt bzw. ergaenzt.
#In ihr stehen in jeder Zeile zwei sechsstellige Nummern und ein Kürzel.
#Nummer1;Nummer2;Kuerzel
#Die Nummern sind eindeutig, die Kuerzel sind genauso sortiert wie in der Datei $FILE_ACCOUNTS .

#Die Datei $FILE_LIMIT_LISTE wird erstellt bzw. ergaenzt.
#In ihr steht in jeder Zeile ein Kuerzel und die noch vorhandene Sw-Seitezahl.
#Kuerzel;Sw-Zahl
#Die Kuerzel sind genauso sortiert wie in der Datei $FILE_ACCOUNTS .

#Zu jedem Kuerzel wird eine PDF-Datei mit Kuerzel und Nummern angelegt. 
#In der Datei Alle.pdf sind diese aneinandergehängt.

fileCfgKopierer="allgemein.cfg"

#Parameter aus config-Datei auslesen
while read line
do
  if [[ -z ${line###*} ]]; then continue; fi
  declare $(echo $line|cut -d= -f1)=$(echo $line|cut -d= -f2)
done < $fileCfgKopierer

#array kopierer enthaelt Namen der Kopierer
kopierer=( $(cd $DIR_CFG; grep -c "IS_ACTIVE=1" *.cfg | sed '/:0/d;s/.cfg:[0-9]*//') )

#Einlesen des Typs der Kopierer (array typ) und setzen der Cookies
for ((i=0; i<${#kopierer[$i]}; i++))
do
  typ[$i]=$(grep "TYP=" $DIR_CFG/${kopierer[$i]}.cfg| tail -n1|cut -d"=" -f2- )
  $DIR_LIB/cookie ${kopierer[$i]}
done

if ! [[ -a $FILE_KOPIERER_ACCOUNTS ]]; then touch $FILE_KOPIERER_ACCOUNTS; fi
#Erstellung von PDF-Karten: Sind Vorlagen vorhanden so, ist pdf=0 sonst =1
if [[ -a $DIR_LIB/checkpdf ]]; then pdf=$($DIR_LIB/checkpdf); fi

#sortierte Listen der Kürzel für Accounts und Drucker
kueAccListe=$(cat $FILE_ACCOUNTS |grep ^[1-2] | cut -d ";" -f2|sort)
kueKopListe=$(cat $FILE_KOPIERER_ACCOUNTS| cut -d";" -f3|sort)
 
#sortierte Listen mit den Abweichungen; Plus sind bei Accounts vorhanden, Minus nicht
kollPlus=$(diff <(echo $kueAccListe|sed 's/ /\n/g') <(echo $kueKopListe|sed 's/ /\n/g') | grep "<"|sed 's/<//g' )
kollMinus=$(diff <(echo $kueAccListe|sed 's/ /\n/g') <(echo $kueKopListe|sed 's/ /\n/g') | grep ">"|sed 's/>//g' )

#Plus: Für die (Plus) Kürzel wird eine Nummer erzeugt und Beides in die Liste der Kopieraccounts eingetragen
#Es wird ein Eintrag in der Log-Datei vorgenommen
for koll in $kollPlus
do
  # Es werden für jedes Kuerzel zwei Nummern erzeugt.
  nm=( 0 0 )
  for (( j=0; j<=1; j++ ))
  do
    nummer=$(cat /dev/urandom | tr -dc "0-9" | head -c6)
    #Die Schleife prüft, ob die Nummer ungültig oder schon vorhanden ist.
    while [[ ${nummer:0:1} -ne 0 && $(cat $FILE_KOPIERER_ACCOUNTS|grep -q $nummer;echo $?) -eq 0 ]]
    do
      nummer=$(cat /dev/urandom | tr -dc "0-9" | head -c6)
    done
    echo -n $nummer";" >> $FILE_KOPIERER_ACCOUNTS
    
    #Nutzer auf Kopierer anlegen
    for ((i=0; i<${#kopierer[$i]}; i++))
    do
      $DIR_LIB/adduser ${kopierer[$i]} $nummer
    done

    nm[$j]=$nummer

  done

  echo $koll >> $FILE_KOPIERER_ACCOUNTS
  echo $koll";0" >> $FILE_LIMIT_LISTE

  echo $(date)": "$koll" angelegt">>$FILE_LOG_USER

  #Fuer jeden Benutzer wird eine Karte mit den IDs im PDF-Format erzeugt
  if [[ $pdf -eq 0 ]]; then
    cat $DIR_PDF/Vorlage/Karte.fdf|sed -e "s/xxx/$koll/" -e "s/sID/${nm[0]}/" -e "s/vID/${nm[1]}/"|\
      pdftk $DIR_PDF/Vorlage/Karte.pdf fill_form - output $DIR_PDF/$koll.pdf flatten;
  fi

done

#Minus: Bei den (Minus) Kürzeln wird nachgefragt, ob sie gelöscht werden sollen.
#Es wird ein Eintrag in der Log-Datei vorgenommen.
for koll in $kollMinus
do 
  echo -e "\n"$koll" ist in der Druckerliste aber ohne account"
  while true; do
    read -p " Soll "$koll" aus der Liste entfernt werden? J/N [Ja]" jn
    case $jn in
        [Nn]* ) break;;
        * ) 
	  echo "Konto auslesen und in Log-Datei eintragen"; 
	  echo $(date)": "$koll" ausgetragen. Konotstand: ...">>$FILE_LOG_USER; 
	  sed -i "/$koll/d" $FILE_KOPIERER_ACCOUNTS; 
	  sed -i "/$koll/d" $FILE_LIMIT_LISTE; 
          #ID-Karte (pdf) loeschen
          rm $DIR_PDF/$koll.pdf; 
          break;;
    esac
  done
done
    
#Gesamt PDF der Karten erstellen
if [[ $pdf -eq 0 ]]; then 
  wd=$(pwd)
  cd $DIR_PDF; pdftk *.pdf cat output $wd/Alle.pdf; cd $wd;
fi
