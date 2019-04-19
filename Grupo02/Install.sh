#!/bin/bash

GRUPO=${PWD/}
DIRCONF=conf
DIRLOG=conf/log



main() {
	export GRUPO
	setearDirectoriosPorDefecto
	DIRLOGBIN=$GRUPO/binarios
	mkdir -m 777 $DIRCONF $DIRLOG
	verificarPermisosLogueo $GRUPO/$DIRLOG/Install.log
	loguear "Inicio del proceso. Usuario: `whoami` Fecha y hora:  `date`" "INFO"
	loguear "Carpeta de config creada." "INFO"
	loguearDirectoriosPorDefecto

	while [[ $CONFIRMO_DIRECTORIOS = "NO" ]]; do
		directorios=()
		elegirDirectorios
		while [[ $ESPACIO_SUFICIENTE = "NO" ]]; do
			elegirEspacioMinimo
			verificarEspacio
		done
		mostrarDirectoriosElegidos
		confirmarInstalacion
	done
	reconfirmarInstalacion
	grabarConfig
	creardirectorios
	
	setearDireccionLoggerDefinitiva
	loguear "Actualizando la configuracion del sistema" "INFO"
	loguear "Instalacion CONCLUIDA" "INFO"
	loguear "FIN del proceso. Usuario: `whoami` Fecha y hora:  `date`" "INFO"

	echo "Desea posicionarse en el directorio del inicializador? (si/no)"
	read respuesta
	if [[ $respuesta = "si" ]]; then
		cd "$(obtenerVariable DIRBIN)"
	fi
	

}

setearDirectoriosPorDefecto() {
	DIRBIN=bin #a-El directorio de ejecutables
	DIRMAE=mae #b-El directorio de archivos maestros 
	DIRNOV=nov #c-El directorio de arribo de archivos externos, es decir, los archivos de novedades con las entregas a realizar
	DIROK=ok #d-El directorio donde se depositan temporalmente las novedades aceptadas para que luego se procesen
	DIRNOK=nok #e-El directorio donde se depositan todos los archivos rechazados
	DIRPROC=proc #f-El directorio donde se depositan los archivos ya procesados
	DIROUT=out #g-El directorio donde se depositan los archivos de salida
	
	DATASIZE=100
	CONFIRMO_DIRECTORIOS=NO
	ESPACIO_SUFICIENTE=NO
}

verificarPermisosLogueo(){
	if ! [[ -r "$1" ]]; then
		name="$(obtenerNombreArchivo "$1")"
		loguear "Intentando setear permiso de lectura a $name" "INFO"
		echo "Seteando permiso de lectura a $name"
		chmod +r "$1"
		if ! [[ $? -eq 0 ]]; then
			loguear "No se puede setear permiso de lectura a $name" "ERR"
			echo "No se pudo setear permiso de lectura a $name"
			return 1
		fi
	fi
}


obtenerNombreArchivo(){
	echo "$(echo $1 | sed "s#.*/##")"
}

function loguear(){
	. $DIRLOGBIN/Loger.sh "Install" "$1" "$2"
}

loguearDirectoriosPorDefecto(){
	loguear "Directorio por defecto de Configuración: $GRUPO/$DIRCONF " "INFO" #0
	loguear "Directorio por defecto de Ejecutables: $DIRBIN " "INFO"#a
	loguear "Directorio por defecto de Maestros y Tablas: $DIRMAE " "INFO"#b
	loguear "Directorio por defecto de Recepcion de Novedades: $DIRNOV " "INFO"#c
	loguear "Directorio por defecto de Archivos s: $DIROK " "INFO"#d
	loguear "Directorio por defecto de Archivos Rechazados: $DIRNOK " "INFO" #e
	loguear "Directorio por defecto de Archivos Procesados: $DIRPROC " "INFO"#f
	loguear "Directorio por defecto de Archivos de Salida: $DIROUT " "INFO" #g

}

function elegirDirectorios() {
	echo "A continuacion se inicia el proceso de eleccion de directorios.
	En caso de haber algun porblema se setearan nombres por default."
	#a
	echo "Defina el directorio de ejecutables (Grupo02/$DIRBIN): "
	setearDirectorio DIRBIN
	directorios+=("$DIRBIN")
	loguear "El usuario eligio el nombre $DIRBIN para el directorio de ejecutables" "INFO"
	#b
	echo "Defina el directorio de Archivos Maestros (Grupo02/$DIRMAE): "
	setearDirectorio DIRMAE
	directorios+=("$DIRMAE")
	loguear "El usuario eligio el nombre $DIRMAE para el directorio de maestros y tablas" "INFO"
	#c
	echo "Defina el directorio de recepción de novedades (Grupo02/$DIRNOV): "
	setearDirectorio DIRNOV
	directorios+=("$DIRNOV")
	loguear "El usuario eligio el nombre $DIRNOV para el directorio de recepcion de novedades" "INFO"
	#d
	echo "Defina el directorio de Archivos Aceptados (Grupo02/$DIROK): "
	setearDirectorio DIROK
	directorios+=("$DIROK")
	loguear "El usuario eligio el nombre $DIROK para el directorio de novedades aceptadas, para luego ser procesadas" "INFO"
	#e
	echo "Defina el directorio de rechazados (Grupo02/$DIRNOK): "
	setearDirectorio DIRNOK
	directorios+=("$DIRNOK")
	loguear "El usuario eligio el nombre $DIRNOK para el directorio de rechazados" "INFO"
	#f
	echo "Defina el directorio de Archivos Procesados (Grupo02/$DIRPROC): "
	setearDirectorio DIRPROC
	directorios+=("$DIRPROC")
	loguear "El usuario eligio el nombre $DIRPROC para el directorio de archivos ya procesados" "INFO"
	#g
	echo "Defina el directorio de Archivos de Salida (Grupo02/$DIROUT): "
	setearDirectorio DIROUT
	directorios+=("$DIROUT")
	loguear "El usuario eligio el nombre $DIROUT para el directorio de archivos de salida" "INFO"
}

function setearDirectorio(){
	read respuesta
	if [[ $respuesta = "" ]] || ! esDirectorioValido "$respuesta"; then
		return 0
	fi
	eval "$1=\"$respuesta\""
}

function esDirectorioValido(){
	#NO puede haber dos directorios con el mismo nombre
	for i in "${directorios[@]}"; do
		if [ "$i" == "$1" ]; then
			loguear "Intento de utilizar el directorio $1 que no está disponible" "WAR"
			echo "$1 ya fue elegido para otro directorio, se usara el default."
			return 1	#es invalido
		fi
	done

	if esDirReservado "$1"; then
		return 1 #si es reservado, nombre invalido
	fi

	return 0 #es valido
}

function esDirReservado(){
	if [ "$1" == "$DIRCONF" ] || [ "$1" == "binarios" ] || [ "$1" == "datos" ]; then
		loguear "Intento de utilizar el directorio $1 que no está disponible" "WAR"
		echo "$1 es un nombre de directorio reservado, se usara el default."
		return 0 #verdadero, es un dir reservado
	fi
	return 1
}

function elegirEspacioMinimo() {

	echo "Defina espacio mínimo libre para la recepción de archivos en Mbytes (De lo contrario se definira 100 por defecto)"
	loguear "Defina espacio mínimo libre para la recepción de archivos en Mbytes" "INFO"
	read DATASIZE

}

function verificarEspacio() {
	
	SPACE=$(df $PWD | awk 'FNR>1{print $4}')
	echo $SPACE
	
	#Ingresa enter directamente y se setea a 100 por defecto
	if [[ $DATASIZE = "" ]];then
		ESPACIO_SUFICIENTE="Si"
		DATASIZE=100
		loguear "Espacio seleccionado $DATASIZE MB" "INFO"
	#Chequeo que tenga solo digitos y despues que no pueda ser solo 0
	elif ! [[ $DATASIZE =~ ^[0-9]+$ ]]; then
		echo "Debe ingresar un numero entero."

	elif [ "$DATASIZE" -eq "0" ];then
		echo "El valor debe ser mayor a 0."

	elif [[ $SPACE -gt $DATASIZE ]]; then
		ESPACIO_SUFICIENTE="Si"
		loguear "Espacio seleccionado $DATASIZE MB" "INFO"
		echo "Suficiente espacio en disco"
		echo "Espacio requerido $DATASIZE MB"
		echo "De enter para continuar"

	else
		echo "Insuficiente espacio en disco"
		echo "Espacio requerido $DATASIZE MB"
		echo "Intentelo nuevamente"
		loguear "Espacio Insuficiente $DATASIZE MB" "WAR"
	fi
}

function mostrarDirectoriosElegidos() {
	echo "Directorio elegido para los ejecutables: $DIRBIN" 
	echo "Directorio elegido para Archivos Maestros: $DIRMAE"
	echo "Directorio elegido para Recepcion de Novedades: $DIRNOV"
	echo "Directorio elegido para Archivos Temporalmente Aceptados: $DIROK"
	echo "Directorio elegido para Archivos Rechazados: $DIRNOK"
	echo "Directorio elegido para Archivos Procesados: $DIRPROC"
	echo "Directorio elegido para Archivos de Salida: $DIROUT"
}

function confirmarInstalacion() {
	
	#TODO Verificar que pasa si elije algo distinto a si o no
	answ=
	while [[ $answ = "" ]]; do
		echo "Desea continuar con la instalación? (Si – No)"
		loguear "Desea continuar con la instalacion?" "INFO"
		read answ
		answ=$(echo $answ | awk '{print tolower($0)}')
		loguear "El usuario responde: $answ" "INFO"

		if [[ $answ = "si" ]]; then
			CONFIRMO_DIRECTORIOS="Si"
		fi

		if [[ $answ = "no" ]]; then
			clear
		fi

	done
}

function reconfirmarInstalacion() {
	#TODO Verificar que pasa si elije algo distinto a si o no
	answ=
	while [[ $answ = "" ]]; do
		echo "Iniciando Instalación. Esta Ud. seguro que desea iniciar la instalacion? (Si-No)"
		loguear "Iniciando Instalación. Esta Ud. seguro? (Si-No)" "INFO"
		read answ
		answ=$(echo $answ | awk '{print tolower($0)}')
		loguear "El usuario responde: $answ" "INFO"

		if [[ $answ = "si" ]]; then
			CONFIRMO_DIRECTORIOS="Si"
		fi

		if [[ $answ = "no" ]]; then
			rm -r $GRUPO/dirconf
			echo "Instalación cancelada"
			exit
		fi
	done
}

function grabarConfig() {
	cd $GRUPO/$DIRCONF
	echo "GRUPO-$GRUPO-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRCONF-$GRUPO/$DIRCONF-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRBIN-$GRUPO/$DIRBIN-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRMAE-$GRUPO/$DIRMAE-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRNOV-$GRUPO/$DIRNOV-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIROK-$GRUPO/$DIROK-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRNOK-$GRUPO/$DIRNOK-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRPROC-$GRUPO/$DIRPROC-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIROUT-$GRUPO/$DIROUT-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRLOG-$GRUPO/$DIRLOG-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DATASIZE-$DATASIZE" > tpconfig.txt
	cd ../

	unset DIRBIN
	unset DIRMAE
	unset DIRNOV
	unset DIROK
	unset DIRNOK
	unset DIRPROC
	unset DIROUT
	
}

function creardirectorios() {
	echo "Creando estructuras de directorio"

	loguear "Actualizando la configuracion del sistema" "INFO"
	loguear "Creando estructuras de directorio..." "INFO"
	loguear "Instalacion CONCLUIDA" "INFO"

	loguear "Instalando programas y funciones" "INFO"
	
	#loguear "Directorio para Archivos de Log: $DIRLOG" "INFO"
	#mkdir -p "$DIRLOG"
	
	loguear  "Directorio elegido para los ejecutables: $(obtenerVariable DIRBIN)" "INFO"

	loguear "Directorio elegido para Archivos Maestros: $(obtenerVariable DIRMAE)" "INFO"

	loguear "Directorio elegido para Recepcion de Novedades: $(obtenerVariable DIRNOV)" "INFO"
	mkdir -p "$(obtenerVariable DIRREC)"

	loguear "Directorio elegido para Archivos Aceptados: $(obtenerVariable DIROK)" "INFO"
	mkdir -p "$(obtenerVariable DIROK)"
	
	loguear "Directorio elegido para Archivos Rechazados: $(obtenerVariable DIRNOK)" "INFO"
	mkdir -p "$(obtenerVariable DIRNOK)"

	loguear "Directorio elegido para Archivos de Salida: $(obtenerVariable DIROUT)" "INFO"
	mkdir -p "$(obtenerVariable DIROUT)"

	loguear "Directorio elegido para Archivos Procesados: $(obtenerVariable DIRPROC)" "INFO"
	mkdir -p "$(obtenerVariable DIRPROC)"


	loguear "Grabando Archivos Maestros: $(obtenerVariable DIRMAE)" "INFO"
	mv $GRUPO/datos "$(obtenerVariable DIRMAE)"

	loguear "Grabando Archivos Ejecutables: $(obtenerVariable DIRBIN)" "INFO"
    mv $GRUPO/binarios "$(obtenerVariable DIRBIN)"

}

obtenerVariable(){
	echo $(grep $1 $GRUPO/$DIRCONF/tpconfig.txt | cut -d '-' -f 2)
}

setearDireccionLoggerDefinitiva() {
	DIRLOGBIN="$(obtenerVariable DIRBIN)"
}

main