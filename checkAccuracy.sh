#!/usr/bin/env python

import re

# Fonction pour vérifier le format du premier champ "Numéro"
def verifier_format_champ1(champ):
    if re.match(r'^\d{11}$', champ):
        return True
    else:
        return False

# Fonction pour vérifier le format du deuxième champ "Nom du fabricant"
def verifier_format_champ2(champ):
    if re.match(r'^NOM_FAB_\d{1,4}$', champ):
        return True
    else:
        return False

# Fonction pour vérifier le format du troisième champ "Référence Fabricant"
def verifier_format_champ3(champ):
    if re.match(r'^REF_FAB_\d{1,4}$', champ):
        return True
    else:
        return False

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
    valeurs_acceptees = [
        "Oui",
        "Non"
    ]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 11eme champ "Température de fonctionnement"
def verifier_format_champ44(champ):
    # Utilisation d'une expression régulière pour vérifier le format (-xxx/+yyyC)
    if re.match(r'^\(-\d{1,3}/\+\d{1,3}C\)$', champ):
        return True
    else:
        return False


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
#champ_43 = re.sub(r'\(-\d{1,3}/\+\d{1,3}�C\)', lambda x: x.group(0).replace('�', ''), champs[43].strip())


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
        elif i == 10 and not verifier_format_champ12(champ):
            erreurs += 1
        elif i == 29 and not verifier_format_champ30(champ):
            erreurs += 1
        elif i == 43 and not verifier_format_champ44(champ):
            erreurs += 1

# Ouvrir le fichier de sortie en mode écriture
with open(fichier_sortie, 'w') as f_out:
    # Écrire le début du fichier HTML
    f_out.write('<!DOCTYPE html>\n<html>\n<head>\n<title>Données formatées</title>\n<style>\ntd { padding: 5px; }\n</style>\n</head>\n<body>\n')

    # Afficher le message d'erreur
    if erreurs == 0:
        f_out.write('<p style="color:green;">Errors = 0</p>\n')
    else:
        f_out.write('<p style="color:red;">Errors = {}</p>\n'.format(erreurs))

    # Commencer le tableau HTML
    f_out.write('<table border="1">\n')

    # Écrire la première ligne (description des champs) en gras et en bleu
    f_out.write('<tr>')
    f_out.write('<td style="font-weight:bold; color:blue;">Ligne</td>')
    for champ in lignes[0].split('|'):
        f_out.write('<td style="font-weight:bold; color:blue;">{}</td>'.format(champ.strip()))
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
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
            elif j == 1:
                if not verifier_format_champ2(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
            elif j == 2:
                if not verifier_format_champ3(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
            elif j == 10:
                if not verifier_format_champ12(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
            elif j == 29:
                if not verifier_format_champ30(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
            elif j == 43:
                if not verifier_format_champ44(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red; font-weight:bold;">{}</span>'.format(champ)
        if ligne_erreur:
            f_out.write('<tr>')
            f_out.write('<td style="font-weight:bold; color:blue;">{}</td>'.format(i))
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
        else:
            f_out.write('<tr>')
            f_out.write('<td style="font-weight:bold; color:blue;">{}</td>'.format(i))
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
    # Écrire la fin du fichier HTML
    f_out.write('</table>\n</body>\n</html>')

# Afficher un message pour indiquer que le processus est terminé
print("Le fichier a été traité. Les champs mal formatés sont en rouge dans le fichier de sortie HTML.")
