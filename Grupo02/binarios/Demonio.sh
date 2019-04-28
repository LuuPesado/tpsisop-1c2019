#!/bin/bash

main() {
	count=0
	while :
	do
		count=$((count+1))
		echo "Demonio corriendo"
		echo "Voy por el ciclo $count" >> logDemonio
		nbNov=`ls -a $DIRNOV | sed -e "/\.$/d" | wc -l`
		if [ $nbNov -gt 0 ]
		then
				clasificarEntregas
				nbOK=`ls -a $DIROK | sed -e "/\.$/d" | wc -l`
				if [ $nbOK -gt 0 ]
				then
					"$DIRBIN"/Proc.sh "PROCESO" > /dev/null &
				fi
		fi
		sleep 2s
	done
}


clasificarEntregas(){
	#local nov= ls $DIRNOV
	for entrega in $(find $DIRNOV -type f)
	do
		#Entrega vacia ?
		if [ -s $entrega ];
		then
  		echo "$entrega no vacia" >> logDemonio
		else
  		echo "$entrega vacia" >> logRechazados
			mv $entrega $DIRNOK
		fi
		#Entrega tiene un nombre valido ?
		echo "$entrega" | grep -v '^Entrega_[0-9][0-9]$' > tmp.txt
		local inv=`cat tmp.txt`
		if [ -z inv]
		then
			echo "$entrega tiene un nombre valido" >> logDemonio
		else
			echo "$entrega no tiene un nombre valido "  >> logRechazados
			mv $entrega $DIRNOK
		fi
		#Entrega es un archivo regular ?
		if [ -f $entrega ];
		then
			echo "$entrega es un archivo regular" >> logDemonio
		else
			echo "$entrega no es un archivo regular" >> logRechazados
			mv $entrega $DIRNOK
		fi
		#Entrega ya esta en DIRPROC ?
		if [ -e $DIRPROC/$entrega ];
		then
			echo "$entrega ya procesada" >> logRechazados
			mv $entrega $DIRNOK
		fi
	done
	echo `ls $DIRNOV` >> logAceptados
	mv $DIRNOV/* $DIROK
}

main
