# Tpsisop-1c2019 Grupo 2

## Instrucciones para la instalación

- Abrir la terminal
- Dirigirse al directorio donde desea realizar la instalación y copiar allí la carpeta: "Grupo02"
- Se obtendrá una estructura como la siguiente en el directorio elegido:

```
├── Grupo02
│   ├── binarios
│   │   ├── Install.sh
│   │   ├── Loger.sh
│   └── datos
│       ├── Operadores.txt
│       ├── Sucursales.txt
├── Instal.sh
```

- Ejecutar el Instalador con el siguiente comando ubicado en el directorio elegido anteriormente para la instalación:  
  ` . ./Instalep.sh `
- Al ejecutar el Install se le solicitará que indique los nombres de las carpetas requeridas para ubicar los archivos. Además, se pedirá que se ingrese la cantidad de megabytes para el espacio disponible de los archivos, en caso de que no haya espacio suficiente se le informará.

- Finalmente, se obtendrá una estructura de carpetas similar a la siguiente en el directorio Grupo02:

```
├── bin
│   ├── Install.sh
│   ├── Loger.sh
├── conf
│   ├── log
|	|	├──Install.log
│   └── tpconfig.txt
├── mae
│   ├── Operadores.txt
│   ├── Sucursales.txt
├── nov
├── ok
├── nok
├── proc
└── out

```

Luego posicionarse en el directorio bin (o el que haya elegido para colocar los archivos ejecutables) -TODO arreglar para que se mueva solo- y correr el comando ./Init.sh

Esto seteará los permisos correspondientes a cada archivo para luego poder accaeder a ellos e iniciará, si aspi lo decide el Demonio (Por ahora solo hace un echo)

