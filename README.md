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

Le port du API est 5000. Il fait une snapshot chaque 20 secondes (0.2 minutes), mais sa ce peut change avec un fichier json settings.json :

`
{
    "github_token": "ghp_xxxxXXXXXXXXXXXXXXXXXXXXXX",
    "snapshot_interval" : 0.2
}
`
Le point de terminaison 'get_all_columns_with_cards' renvoie toutes les colonnes avec les cartes originales, qui sont mises à jour au fur et à mesure que l'on passe d'une colonne à l'autre. Si le carte a l'atribute ferme (issue or pull request is closed), le lead time est calcule. Github nous donne le temps ou la carte est cree et fermee.

Lorsqu'une carte est déplacée vers une colonne, une "copie" de la carte pointant vers la carte mère originale est créée, et cette "copie" est ajoutée à la nouvelle colonne. De cette façon, lorsque vous recherchez dans une colonne particulière des cartes qui sont là depuis un certain temps, ces cartes "copies" apparaîtront parce qu'elles ont été là. En ne les ajoutant que lorsqu'une carte a été déplacée, nous vérifions qu'aucune copie inutile de cartes n'est créée dans les colonnes.