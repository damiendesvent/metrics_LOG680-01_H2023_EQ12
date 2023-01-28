# LOG680-01_H2023_EQ12

## Description

Cours LOG680 - Introduction à l'approche DevOps  
Session Hiver 2023  
Groupe 01  
Equipe 12  

## Membres

Damien Desvent  
Bruno Moya Ruiz  
Dorian Perthuis  


## Exécuter le serveur

Le serveur fonctionne avec Docker et Docker-Compose. Pour exécuter le serveur ici la comande:

`sudo  docker compose --file "api/docker-compose.yaml" up -d --build `

Cette comande, initialise le postgresql database dans docker-compose.yaml, et apres un container avec Python 3.10 pour faire fonctionner fastapi.
