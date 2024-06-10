#!/usr/bin/env python

import re

# Fonction pour vérifier le format du premier champ "Numéro"
def verifier_format_champ1(champ):
    return re.match(r'^\d{11}$', champ) is not None

# Fonction pour vérifier le format du deuxième champ "Nom du fabricant"
def verifier_format_champ2(champ):
    return re.match(r'^NOM_FAB_\d{1,4}$', champ) is not None

# Fonction pour vérifier le format du troisième champ "Référence Fabricant"
def verifier_format_champ3(champ):
    return re.match(r'^REF_FAB_\d{1,4}$', champ) is not None

# Fonction pour vérifier le format du quatrième champ "Nom court Anglais"
def verifier_format_champ5(champ):
    valeurs_acceptees = [
        "ACCESSORIES", "ADHESIVE", "MAGNET", "POWER-SUPPLY", "ROTATION-DAMPERS",
        "RING", "GUIDE-RING", "SEAL-RING", "BASE-ON-TUBE", "BATTERY",
        "BEARING", "BOX", "WASHER", "TRANSISTOR", "RESISTOR",
        "CAPACITOR", "CONNECTOR-HOUSING", "HOOD", "CAP", "CASE",
        "CONNECTOR", "CONTACT", "DIODE", "SOCKET", "LABEL",
        "STOP-RING", "WIRE", "ELASTIC-RING", "BACKSHELL"
    ]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 11eme champ "Unité par défaut"
def verifier_format_champ12(champ):
    valeurs_acceptees = [
        "kilogramme",
        "kilogramme(s)",
        "metre",
        "metre(s)",
        "litre",
        "litre(s)",
        "metre cube",
        "unite",
        "unite(s)"
    ]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 29eme champ "Conforme au RoHS"
def verifier_format_champ30(champ):
    valeurs_acceptees = ["Oui", "Non"]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 11eme champ "Température de fonctionnement"
def verifier_format_champ44(champ):
    # Utilisation d'une expression régulière pour vérifier le format (-xxx/+yyyC)
    return re.match(r'^\(-\d{1,3}/\+\d{1,3}C\)$', champ) is not None

# Nom du fichier d'entrée et de sortie
fichier_entree = 'export_input.txt'
fichier_entree_corrige = 'export_input_corrige.txt'
fichier_sortie = 'export_output.html'

# Liste des remplacements à effectuer
remplacements = [
    ("unit�", "unite"),
    ("m�tre", "metre"),
    ("contr�l�", "controle"),
    ("Publi�", "Publie")
    # Ajouter d'autres remplacements si nécessaire
]

# Lire le contenu du fichier d'entrée
with open(fichier_entree, 'r', encoding='utf-8') as f_in:
    contenu = f_in.read()

# Effectuer les remplacements standards
for incorrect, correct in remplacements:
    contenu = contenu.replace(incorrect, correct)

# Effectuer les remplacements des formats spécifiques (Température)
contenu = re.sub(r'\(-\d{1,3}/\+\d{1,3}�C\)', lambda x: x.group(0).replace('�', ''), contenu)

# Sauvegarder le contenu corrigé dans un nouveau fichier
with open(fichier_entree_corrige, 'w', encoding='utf-8') as f_out:
    f_out.write(contenu)

# Ouvrir le fichier d'entrée corrigé en mode lecture
with open(fichier_entree_corrige, 'r') as f_in:
    # Lire les lignes du fichier
    lignes = f_in.readlines()

# Compteur d'erreurs
erreurs = 0

# Vérifier le format de chaque champ
for ligne in lignes[1:]:
    champs = ligne.split('|')
    for i, champ in enumerate(champs):
        champ = champ.strip()
        if i == 0 and not verifier_format_champ1(champ):
            erreurs += 1
        elif i == 1 and not verifier_format_champ2(champ):
            erreurs += 1
        elif i == 2 and not verifier_format_champ3(champ):
            erreurs += 1
        elif i == 4 and not verifier_format_champ5(champ):
            erreurs += 1
        elif i == 10 and not verifier_format_champ12(champ):
            erreurs += 1
        elif i == 29 and not verifier_format_champ30(champ):
            erreurs += 1
        elif i == 43 and not verifier_format_champ44(champ):
            erreurs += 1

# Ouvrir le fichier de sortie en mode écriture
with open(fichier_sortie, 'w', encoding='utf-8') as f_out:
    # Écrire le début du fichier HTML
    f_out.write('''<!DOCTYPE html>
<html>
<head>
<title>Données formatées</title>
<style>
body {
    font-family: Arial, sans-serif;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}
th, td {
    border: 1px solid #ddd;
    padding: 8px;
}
th {
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #154c79;
    color: white;
}
tr:nth-child(even) {
    background-color: #f2f2f2;
}
tr:hover {
    background-color: #ddd;
}
.error {
    color: red;
    font-weight: bold;
}
.success {
    color: green;
    font-weight: bold;
}
</style>
</head>
<body>
''')

    # Afficher le message d'erreur
    if erreurs == 0:
        f_out.write('<p class="success">Errors = 0</p>\n')
    else:
        f_out.write('<p class="error">Errors = {}</p>\n'.format(erreurs))

    # Commencer le tableau HTML
    f_out.write('<table>\n')

    # Écrire la première ligne (description des champs) en gras et en bleu
    f_out.write('<tr>')
    f_out.write('<th>Ligne</th>')
    for champ in lignes[0].split('|'):
        f_out.write('<th>{}</th>'.format(champ.strip()))
    f_out.write('</tr>\n')

    # Parcourir chaque ligne du fichier à partir de la deuxième ligne jusqu'à la dernière
    for i, ligne in enumerate(lignes[1:], start=1):
        # Séparer les champs en utilisant le séparateur |
        champs = ligne.split('|')
        ligne_erreur = False
        # Vérifier le format de chaque champ
        for j, champ in enumerate(champs):
            champ = champ.strip()
            if j == 0:
                if not verifier_format_champ1(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 1:
                if not verifier_format_champ2(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 2:
                if not verifier_format_champ3(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 4:
                if not verifier_format_champ5(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 10:
                if not verifier_format_champ12(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 29:
                if not verifier_format_champ30(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 43:
                if not verifier_format_champ44(champ):
                    ligne_erreur = True
                    champs[j] = '<span class="error">{}</span>'.format(champ)
        if ligne_erreur:
            f_out.write('<tr>')
            f_out.write('<td>{}</td>'.format(i))
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
        else:
            f_out.write('<tr>')
            f_out.write('<td>{}</td>'.format(i))
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
    # Écrire la fin du fichier HTML
    f_out.write('</table>\n</body>\n</html>')

# Afficher un message pour indiquer que le processus est terminé
print("Le fichier a été traité. Les champs mal formatés sont en rouge et en gras dans le fichier de sortie HTML.")
