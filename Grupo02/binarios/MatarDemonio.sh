#!/bin/bash

echo "Demonio Finalizado"
PIDD="$(ps -aef | grep Demonio.sh | awk 'NR==1 {print $2}')"
kill -9 $PIDD &>/dev/null