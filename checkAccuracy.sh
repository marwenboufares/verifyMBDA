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
#def verifier_format_champ12(champ):
#    if re.match(r'^litre(s)$', champ):
#        return True
#    else:
#        return False

def verifier_format_champ12(champ):

    valeurs_acceptees = [
        "kilogramme",
        "kilogramme(s)",
        "mètre",
        "mètre(s)",
        "litre",
        "litre(s)",
        "mètre cube",
        "unité",
        "unite(s)"
    ]
    return champ in valeurs_acceptees

# Nom du fichier d'entrée et de sortie
fichier_entree = 'export_input.txt'
fichier_sortie = 'export_output.html'

# Compteur d'erreurs
erreurs = 0

# Ouvrir le fichier d'entrée en mode lecture
with open(fichier_entree, 'r') as f_in:
    # Lire les lignes du fichier
    lignes = f_in.readlines()

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
                    champs[j] = '<span style="color:red;">{}</span>'.format(champ)
            elif j == 1:
                if not verifier_format_champ2(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red;">{}</span>'.format(champ)
            elif j == 2:
                if not verifier_format_champ3(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red;">{}</span>'.format(champ)
            elif j == 10:
                if not verifier_format_champ12(champ):
                    ligne_erreur = True
                    champs[j] = '<span style="color:red;">{}</span>'.format(champ)
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

