prérequis:

Pour utiliser le script de verification il faut avoir installé sur la machine OBLIGATOIREMENT:
- Python 3.9.10 ou une version ulterieure
- bash shell

Inputs:
Le fichier texte d'export, qui DOIT ETRE RENOMME EN "export_input.txt" ET MIS DIRECTEMENT SOUS LE REPERTOIRE DU SCRIPT.

Outputs:
Un fichier html d'export (export_output.html), qui contient les données export en sortie traités.

How to use:
1- Exporter votre fichier texte
2- Renommer-le en export_input.txt
3- Metter le sous le repertoire ou se trouve le script
4- Ouvrir une fenetre de bash shell dans le meme repertoire
5- Executer la commande suivante: ./checkAccuracy.sh

Une fois le script est exécuté, un fichier html de sortie export_output.html doit etre crée et qui contient le meme tableau de data importés avec
les champs qui correspondent pas à leurs formules COLORES EN ROUGE, et avec un nombre d'erreurs total au début.

installation python:
1- Accédez au site officiel de Python : https://www.python.org/downloads/release/python-3910/
2- Téléchargez l'installateur pour Windows en sélectionnant la version Windows installer (64-bit/32-bit)
3- Cochez la case "Add Python 3.9 to PATH" pendant l'installation pour ajouter Python 3.9 à votre variable d'environnement PATH. Cela permettra d'accéder à Python depuis n'importe quel répertoire dans l'invite de commandes.
4- Démarrer l'installation.


