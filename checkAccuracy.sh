#!/usr/bin/env python

import os
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
    valeurs_acceptees = ["Oui", "Non", ""]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 44eme champ "Température de fonctionnement"
def verifier_format_champ44(champ):
    # Utilisation d'une expression régulière pour vérifier le format (-xxx/+yyyC)
    return re.match(r'^\(-\d{1,3}/\+\d{1,3}C\)$', champ) is not None

# Nom du fichier d'entrée et de sortie
fichier_entree = 'extract.txt'
fichier_entree_corrige = 'extract_intermediate.txt'
fichier_sortie = 'extract_checked.html'

# Liste des remplacements à effectuer pour le contenu du fichier
remplacements = [
    ("unit�", "unite"),
    ("m�tre", "metre"),
    ("contr�l�", "controle"),
    ("Publi�", "Publie")
]

# Liste des remplacements à effectuer pour les en-têtes des colonnes
remplacements_entetes = [
    ("Numï¿½ro", "Numero"),
    ("Franï¿½ais", "Francais"),
    ("Rï¿½fï¿½rence", "Reference"),
    ("Matiï¿½re", "Matiere"),
    ("Unitï¿½", "Unite"),
    ("dï¿½faut", "defaut"),
    ("contrï¿½le", "controle"),
    ("appliquï¿½", "applique"),
    ("Modifiï¿½", "Modifie"),
    ("rï¿½glementations", "reglementations"),
    ("Crï¿½ï¿½", "Cree"),
    ("nï¿½", "numero"),
    ("etcï¿½", ""),
    ("Contrï¿½le", "Controle"),
    ("Rï¿½glementations", "Reglementations"),
    ("ï¿½", ""),
    ("lï¿½exportation", "lexportation"),
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

# Corriger les en-têtes des colonnes
en_tetes = lignes[0].split('|')
for i, en_tete in enumerate(en_tetes):
    for incorrect, correct in remplacements_entetes:
        en_tetes[i] = en_tetes[i].replace(incorrect, correct)
lignes[0] = '|'.join(en_tetes) + '\n'

# Compteur d'erreurs par colonne et listes des lignes avec erreurs
erreurs_par_colonne = [0] * len(en_tetes)
lignes_erreurs_par_colonne = [[] for _ in range(len(en_tetes))]

# Vérifier le format de chaque champ
for idx, ligne in enumerate(lignes[1:], start=1):
    champs = ligne.split('|')
    for i, champ in enumerate(champs):
        champ = champ.strip()
        if i == 0 and not verifier_format_champ1(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 1 and not verifier_format_champ2(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 2 and not verifier_format_champ3(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 4 and not verifier_format_champ5(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 10 and not verifier_format_champ12(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 29 and not verifier_format_champ30(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)
        elif i == 43 and not verifier_format_champ44(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)

# Calculer la largeur maximale pour chaque colonne
largeurs_max = [len(en_tete.strip()) for en_tete in en_tetes]
for ligne in lignes[1:]:
    champs = ligne.split('|')
    for i, champ in enumerate(champs):
        largeur_champ = len(champ.strip())
        if largeur_champ > largeurs_max[i]:
            largeurs_max[i] = largeur_champ

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
.highlight {
    background-color: #ffcccb; /* Rouge clair fluorescent */
}
.fixed-width {
    width: 5ch; /* Largeur fixe pour la colonne "Nombre d'erreurs" */
}
</style>
</head>
<body>
''')

    # Afficher le message d'erreur
    total_erreurs = sum(erreurs_par_colonne)
    if total_erreurs == 0:
        f_out.write('<p class="success">Errors = 0</p>\n')
    else:
        f_out.write('<p class="error">Errors = {}</p>\n'.format(total_erreurs))

    # Stocker les largeurs maximales des colonnes en JSON
    f_out.write('<div id="largeursMax" style="display:none;">{}</div>\n'.format(largeurs_max))

    # Tableau des erreurs par colonne
    f_out.write('<table id="tableErreursParColonne">\n')
    f_out.write('<tr><th>Colonne</th><th class="fixed-width">Nombre d\'erreurs</th><th>Lignes</th></tr>\n')
    for i, count in enumerate(erreurs_par_colonne):
        if count > 0:
            lignes_erreurs = ', '.join(map(str, lignes_erreurs_par_colonne[i]))
            f_out.write('<tr><td>{}</td><td class="fixed-width">{}</td><td>{}</td></tr>\n'.format(en_tetes[i].strip(), count, lignes_erreurs))
    f_out.write('</table>\n')

    # Commencer le tableau HTML des données
    f_out.write('<table>\n')

    # Écrire la première ligne (description des champs) en gras et en bleu
    f_out.write('<tr>')
    f_out.write('<th>Ligne</th>')
    for champ in en_tetes:
        f_out.write('<th>{}</th>'.format(champ.strip()))
    f_out.write('</tr>\n')

    # Parcourir chaque ligne du fichier à partir de la deuxième ligne jusqu'à la dernière
    for i, ligne in enumerate(lignes[1:], start=1):
        # Séparer les champs en utilisant le séparateur |
        champs = ligne.split('|')
        # Vérifier le format de chaque champ et surligner les colonnes avec des erreurs
        f_out.write('<tr>')
        f_out.write('<td>{}</td>'.format(i))
        for j, champ in enumerate(champs):
            champ = champ.strip()
            if j == 0:
                if not verifier_format_champ1(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 1:
                if not verifier_format_champ2(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 2:
                if not verifier_format_champ3(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 4:
                if not verifier_format_champ5(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 10:
                if not verifier_format_champ12(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 29:
                if not verifier_format_champ30(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            elif j == 43:
                if not verifier_format_champ44(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            highlight_class = "highlight" if erreurs_par_colonne[j] > 0 else ""
            f_out.write('<td class="{}">{}</td>'.format(highlight_class, champs[j]))
        f_out.write('</tr>\n')

    # Écrire la fin du fichier HTML
    f_out.write('</table>\n</body>\n</html>')

# Supprimer le fichier intermédiaire
os.remove('extract_intermediate.txt')

# Afficher un message pour indiquer que le processus est terminé
print("Le fichier a été traité. Les champs mal formatés sont en rouge et en gras dans le fichier de sortie HTML.")
