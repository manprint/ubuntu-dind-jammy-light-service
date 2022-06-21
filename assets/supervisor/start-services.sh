#!/bin/bash

function start_docker() {
	echo "Avvio del servizio docker in corso...."
	service docker start
	sleep 10
	echo "Funzione di avvio terminata...."
}

$@
