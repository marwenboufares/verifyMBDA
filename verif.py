import re

# Fonction pour vérifier le format du premier champ
def verifier_format_champ1(champ):
    # Utilisation d'une expression régulière pour vérifier le format
    if re.match(r'\d+Kg', champ):
        return True
    else:
        return False

# Fonction pour vérifier le format du deuxième champ
def verifier_format_champ2(champ):
    # Utilisation de str.format() pour vérifier le format
    if re.match(r'\d+-m', champ):
        return True
    else:
        return False

# Nom du fichier d'entrée et de sortie
fichier_entree = 'data.txt'
fichier_sortie = 'data_formatees.html'

# Ouvrir le fichier d'entrée en mode lecture
with open(fichier_entree, 'r') as f_in:
    # Lire les lignes du fichier
    lignes = f_in.readlines()

# Ouvrir le fichier de sortie en mode écriture
with open(fichier_sortie, 'w') as f_out:
    # Écrire le début du fichier HTML
    f_out.write('<!DOCTYPE html>\n<html>\n<head>\n<title>Données formatées</title>\n<style>\ntd { padding: 5px; }\n</style>\n</head>\n<body>\n<table border="1">\n')

    # Écrire la première ligne (description des champs) en gras et en bleu
    f_out.write('<tr>')
    for champ in lignes[0].split('|'):
        f_out.write('<td style="font-weight:bold; color:blue;">{}</td>'.format(champ.strip()))
    f_out.write('</tr>\n')

    # Parcourir chaque ligne du fichier à partir de la deuxième ligne jusqu'à la dernière
    for ligne in lignes[1:]:
        # Séparer les champs en utilisant le séparateur |
        champs = ligne.split('|')
        ligne_erreur = False
        # Vérifier le format de chaque champ
        for i, champ in enumerate(champs):
            champ = champ.strip()
            if i == 0:
                if not verifier_format_champ1(champ):
                    ligne_erreur = True
                    champs[i] = '<span style="color:red;">{}</span>'.format(champ)
            elif i == 1:
                if not verifier_format_champ2(champ):
                    ligne_erreur = True
                    champs[i] = '<span style="color:red;">{}</span>'.format(champ)
        if ligne_erreur:
            f_out.write('<tr>')
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
        else:
            f_out.write('<tr>')
            for champ in champs:
                f_out.write('<td>{}</td>'.format(champ))
            f_out.write('</tr>\n')
    # Écrire la fin du fichier HTML
    f_out.write('</table>\n</body>\n</html>')

# Afficher un message pour indiquer que le processus est terminé
print("Le fichier a été traité. Les champs mal formatés sont en rouge dans le fichier de sortie HTML.")
