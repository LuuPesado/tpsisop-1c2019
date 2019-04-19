#!/bin/bash

main(){
	#me paro afuera, un solo nivel porque la raiz debia ser Grupo02, no puedo salir
	cd ..
	cargarVariables
	if yaInicializado; then
		loguearInit "Intentando iniciar ambiente ya inicializado" "WAR"
		echo "Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"
	else
		loguearInit "Iniciando ambiente" "INFO"
		(verificarInstalacion && verificarPermisos) || return 1
		setearVariablesAmbiente
		procesoCompleto
		comenzarDemonio
	fi
	cd $DIRBIN
}

cargarVariables(){
	GRUPO="$(obtenerVariable GRUPO)"
	DIRCONF="$(obtenerVariable DIRCONF)"
	DIRBIN="$(obtenerVariable DIRBIN)"
	DIRMAE="$(obtenerVariable DIRMAE)"
	DIRNOV="$(obtenerVariable DIRNOV)"
	DIROK="$(obtenerVariable DIROK)"
	DIRNOK="$(obtenerVariable DIRNOK)"
	DIRPROC="$(obtenerVariable DIRPROC)"
	DIROUT="$(obtenerVariable DIROUT)"
	DIRLOG="$(obtenerVariable DIRLOG)"
	DATASIZE="$(obtenerVariable DATASIZE)"
#	SLEEPTIME="$(obtenerVariable SLEEPTIME)"
}

obtenerVariable(){
	echo $(grep $1 conf/tpconfig.txt | cut -d '-' -f 2)
}

yaInicializado(){
	return $([[ $PREPARARAMBIENTE == "SI" ]])
}

function loguearInit(){
	. $DIRBIN/Loger.sh "Init" "$1" "$2"
}

verificarInstalacion(){
	if verificarArchivosFaltantes; then
		mostrarDatosConfig
		loguearInit "Error en la instalación" "ERR"
		loguearInit "Componentes Faltantes: $(mostrarFaltantes)" "ERR"
		echo "Estado de la instalacion: INCOMPLETA"
		echo "Componentes Faltantes: $(mostrarFaltantes)"
		return 1
	fi
}

verificarArchivosFaltantes(){
	##Verifico los maestros
	[[ -f "$DIRMAE/Operadores.txt" ]] || return 0
	[[ -f "$DIRMAE/Sucursales.txt" ]] || return 0

	return 1

}

mostrarDatosConfig(){
	echo "Directorio de Ejecutables: $(obtenerRuta "$DIRBIN")"
	[[ -d "$DIRBIN" ]] && echo "$(list_dir "$DIRBIN")"

	echo "Directorio de Maestros y Tablas: $(obtenerRuta "$DIRMAE")"
	[[ -d "$DIRMAE" ]] && echo "$(list_dir "$DIRMAE")"

	echo "Directorio de recepcion de archivos de novedades: $(obtenerRuta "$DIRNOV")"

	echo "Directorio de Archivos aceptados: $(obtenerRuta "$DIROK")"
	
	echo "Directorio de Archivos Rechazados: $(obtenerRuta "$DIRNOK")"

	echo "Directorio de Archivos de procesar ofertas : $(obtenerRuta "$DIRPROC")"

	echo "Directorio de Archivos de informes: $(obtenerRuta "$DIROUT")"

	echo "Directorio de Archivos de Log: $(obtenerRuta "$DIRLOG")"
	[[ -d "$DIRLOG" ]] && echo "$(list_dir "$DIRLOG")"
}

list_dir(){
	echo "$(ls "$1" | tr "\n" " ")"
}

obtenerRuta(){
	echo "$(echo "$1" | sed "s#$GRUPO/##")"
}


mostrarFaltantes(){
	output=""
	[[ -d "$GRUPO" ]] || output="$output $(obtenerRuta "$GRUPO")"
	[[ -d "$DIRBIN" ]] || output="$output $(obtenerRuta "$DIRBIN")"
	[[ -d "$DIRMAE" ]] || output="$output $(obtenerRuta "$DIRMAE")"
	[[ -d "$DIRNOV" ]] || output="$output $(obtenerRuta "$DIRNOV")"
	[[ -d "$DIROK" ]] || output="$output $(obtenerRuta "$DIROK")"
	[[ -d "$DIRNOK" ]] || output="$output $(obtenerRuta "$DIRNOK")"
	[[ -d "$DIRPROC" ]] || output="$output $(obtenerRuta "$DIRPROC")"
	[[ -d "$DIROUT" ]] || output="$output $(obtenerRuta "$DIROUT")"
	[[ -d "$DIRLOG" ]] || output="$output $(obtenerRuta "$DIRLOG")"

	#[[ -d "$LOGSIZE" ]] || output="$output $(obtenerRuta "$LOGSIZE")"
	#[[ -d "$SLEEPTIME" ]] || output="$output $(obtenerRuta "$SLEEPTIME")"
	#Maestros
	[[ -f "$DIRMAE/Operadores.txt" ]] || output="$output Operadores.txt"
	[[ -f "$DIRMAE/Sucursales.txt" ]] || output="$output Sucursales.txt"

	echo "$output"
}

verificarPermisos(){
	verificarPermisoLectura "$DIRMAE/Operadores.txt" || return 1
	verificarPermisoLectura "$DIRMAE/Sucursales.txt" || return 1

	verificarPermisoEjecucion "$DIRBIN/Init.sh" || return 1
	verificarPermisoEjecucion "$DIRBIN/Loger.sh" || return 1
	verificarPermisoEjecucion "$DIRBIN/Demonio.sh" || return 1
	verificarPermisoEjecucion "$DIRBIN/MatarDemonio.sh" || return 1
	verificarPermisoEjecucion "$DIRBIN/Proc.sh" || return 1
}

verificarPermisoLectura(){
	name="$(obtenerNombreArchivo "$1")"
	loguearInit "Intentando setear permiso de lectura a $name" "INFO"
	echo "Seteando permiso de lectura a $name"
	chmod +r-xw "$1"
	if ! [[ $? -eq 0 ]]; then
		loguearInit "No se puede setear permiso de lectura a $name" "ERR"
		echo "No se pudo setear permiso de lectura a $name"
		return 1
	fi
}

obtenerNombreArchivo(){
	echo "$(echo $1 | sed "s#.*/##")"
}

verificarPermisoEjecucion(){
	#Si no se puede leer > no se puede ejecutar
	verificarPermisoLectura "$1" || return 1
	name="$(obtenerNombreArchivo "$1")"
	loguearInit "Intentando setear permiso de ejecucion a $name" "INFO"
	echo "Intentando setear permiso de ejecucion a $name"
	chmod +x+r-w "$1"
	if ! [[ $? -eq 0 ]]; then
		loguearInit "No se puede setear permiso de ejecucion a $name" "ERR"
		echo "No se puede setear permiso de ejecucion a $name"
		return 1
	fi
}

setearVariablesAmbiente(){
	export PREPARARAMBIENTE="SI"
	export GRUPO
	export DIRBIN
	export DIRMAE
	export DIRREC
	export DIROK
	export DIRPROC
	export DIRINFO
	export DIRLOG
	export DIRNOK
	export LOGSIZE
#	export SLEEPTIME
#	export MAX_LOG_SIZE
#	export LOG_DEFAULT_LONG
	return 1
}

procesoCompleto(){
	mostrarDatosConfig 1
	echo
	echo
	loguearInit "Estado de la instalacion: INICIALIZADO" "INFO"
	echo "Estado de la instalacion: INICIALIZADO"

}

comenzarDemonio(){
	if leerRespuestaUsuario "Desea iniciar el demonio?"; then
		"$DIRBIN"/Demonio.sh "DEMONIO" > /dev/null &
		loguearInit "Iniciando Demonio..." "INFO"
		PIDD="$(ps -aef | grep Demonio.sh | awk 'NR==1 {print $2}')"
		loguearInit "Demonio corriendo bajo el numero de proceso: $PIDD" "INFO"
		echo "Demonio corriendo bajo el numero de proceso: $PIDD"
		export PIDD
	else
		loguearInit "Demonio no iniciado por el usuario" "INFO"
		echo "Para activar el demonio ejecute . $DIRBIN/Demonio.sh"
	fi
}

leerRespuestaUsuario(){
	echo "$1 (Si - No)"
	read answ
	answ=$(echo $answ | awk '{print tolower($0)}')
	if [[ $answ = "si" ]]; then
		loguearInit "El usuario inició el demonio" "INFO"
		echo "Ingresa SI"
		return 0
	else
		if [[ $answ = "no" ]]; then
			loguearInit "El usuario no inició el demonio" "INFO"
			echo "Ingresa NO"
		else
			loguearInit "Respuesta del usuario inválida" "ERR"
			echo "Ingresa un valor no valido. No se inicia el proceso"
		fi
		return 1
	fi
}
main