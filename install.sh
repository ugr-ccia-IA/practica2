#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

done=0
declare -A osInfo;
osInfo[/etc/redhat-release]=dnf
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
osInfo[/etc/alpine-release]=apk
osInfo[/etc/arch-release]=pacman

for f in ${!osInfo[@]}
do
    ## Instalamos las librerias necesarias
    if [[ -f $f ]];then
        echo Package manager: ${osInfo[$f]}
        case ${osInfo[$f]} in
            apt-get)
                sudo apt-get install -y freeglut3-dev libjpeg-dev libopenmpi-dev openmpi-bin openmpi-doc libxmu-dev libxi-dev cmake libboost-all-dev
                done=1
                ;;
            dnf)
                sudo dnf install -y freeglut-devel libjpeg-turbo-devel openmpi-devel libXmu-devel libXi-devel cmake boost-devel
                sed -i 's/^set(CMAKE_CXX_FLAGS.*-std=c++17.*)/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++11 -lglut")/' CMakeLists.txt
                done=1
                ;;
            pacman)
                sudo pacman -Sy freeglut libjpeg openmpi openmpi libxmu libxi boost cmake
                sed -i 's/^set(CMAKE_CXX_FLAGS.*-std=c++17.*)/set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++11 -lglut")/' CMakeLists.txt
                done=1
                ;;
            *)
                printf "${RED}<=========================AVISO=========================>
La instalación por defecto no está disponible. Por favor, instale manualmente las librerías necesarias.
Tenga en cuenta que el nombre de las librerías puede variar dependiendo de la distribución.\n\n"
                printf " ${YELLOW}>>> LIBRERIAS:
- freeglut3-dev
- libjpeg-dev
- libopenmpi-dev
- openmpi-bin
- openmpi-doc
- libxmu-dev
- libxi-dev
- cmake
- libboost-all-dev"
                ;;
        esac
    fi

    if [ $done -eq 1 ]; then
        ## Creamos el makefile para nuestra máquina
        cmake -DCMAKE_BUILD_TYPE=Debug .      # con el flag de depuración activo
        # cmake -DCMAKE_BUILD_TYPE=Release .   # sin información de depuración

        ## Compilamos!
        make

        if [ $? -eq 0 ]; then
            printf "${GREEN} >>> INSTALACIÓN Y COMPILACIÓN CORRECTA \n"
        fi
    fi
done
