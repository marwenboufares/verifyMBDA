#!/usr/bin/env python

import os
import re
import json

# Charger les valeurs acceptées depuis un fichier JSON
#with open('acceptedValues.json', 'r', encoding='utf-8') as f:
#    data = json.load(f)
with open('C:/Users/mboufares/Desktop/MBDA/verifyMBDA/acceptedValues.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Récupérer les valeurs pour le "Nom court Francais"
av_nomCourtFrancais = data.get('nomCourtFrancais', [])

# Fonction pour vérifier le format du quatrième champ "Nom court Francais"
def verif_champ_nomCourtFr(champ):
    return any(val.lower() in champ.lower() for val in av_nomCourtFrancais)

# Fonction pour vérifier si le champ nom francais contient au moins un espace
def verif_champ_nomFr_espace(champ):
    return ' ' in champ

# Récupérer les valeurs pour les champs unités
av_champs_kilogramme = data.get("champs_kilogramme", [])
av_champs_litre = data.get("champs_litre", [])
av_champs_metre = data.get("champs_metre", [])
av_champs_metre_cube = data.get("champs_metre_cube", [])

# Fonction pour vérifier si une unité est correcte
def verif_champ_unite(nom_champ, unite):
    # Vérifier la correspondance entre le champ et l'unité
    if nom_champ in av_champs_kilogramme:
        return unite in ["kilogramme", "kilogramme(s)"]
    elif nom_champ in av_champs_litre:
        return unite in ["litre", "litre(s)"]
    elif nom_champ in av_champs_metre:
        return unite in ["metre", "metre(s)"]
    elif nom_champ in av_champs_metre_cube:
        return unite == "metre cube"
    else:
        # Si le champ n'est pas dans les listes spécifiques, l'unité doit être "unite" ou "unite(s)"
        return unite in ["unite", "unite(s)"]

# Fonction pour vérifier le format du 29eme champ "Conforme au RoHS"
def verif_champ_conformeRoHs(champ):
    valeurs_acceptees = ["Oui", "Non", ""]
    return champ in valeurs_acceptees

# Fonction pour vérifier le level
def verif_champ_conformeLevel(champ):
    valeurs_acceptees = ["Level1", "Level2", "Level3", "Level4", "Level5"]
    return champ in valeurs_acceptees

# Fonction pour vérifier le format du 44eme champ "Température de fonctionnement"
def verif_champ_temperature(champ):
    # Utilisation d'une expression régulière pour vérifier le format (-xxx/+yyyC)
    return re.match(r'^$|^\(?(-\d{1,3}|0)/\+\d{1,3}C\)?$', champ) is not None

def verif_champ_avec_exclusion(champ, regle):
    result = False  # Variable pour stocker le résultat

    # Si la règle est un dictionnaire avec une clé "exclude"
    if isinstance(regle, dict) and "exclude" in regle:
        if champ in regle["exclude"]:
            result = False  # Champ exclu, donc rejeté
        else:
            result = True  # Champ accepté car non exclu

    # Sinon, la règle est une liste ou une valeur exacte
    else:
        result = champ in regle  # Le champ doit correspondre à la règle
    return result


# Nom du fichier d'entrée et de sortie
fichier_entree = 'C:/Users/mboufares/Desktop/MBDA/verifyMBDA/extract.txt'
fichier_entree_corrige = 'C:/Users/mboufares/Desktop/MBDA/verifyMBDA/extract_intermediate.txt'
fichier_sortie = 'C:/Users/mboufares/Desktop/MBDA/verifyMBDA/extract_checked.html'

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
contenu = re.sub(r'-\d{1,3}/\+\d{1,3}�C', lambda x: x.group(0).replace('�', ''), contenu)

# Séparer le contenu en lignes
lignes = contenu.splitlines()

# Diviser chaque ligne en colonnes
lignes_modifiees = []
for ligne in lignes:
    colonnes = ligne.split('|')  # Séparer la ligne en colonnes

    if len(colonnes) > 16:  # S'assurer qu'il y a au moins 16 colonnes
        # Échanger les colonnes 11 (index 10) et 16 (index 15)
        colonnes[11], colonnes[16] = colonnes[16], colonnes[11]

    # Ajouter la ligne modifiée à la liste
    lignes_modifiees.append('|'.join(colonnes))

# Réécrire le contenu modifié dans le fichier de sortie
with open(fichier_entree_corrige, 'w', encoding='utf-8') as f_out:
    f_out.write('\n'.join(lignes_modifiees))

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
        if i == 5:
            if verif_champ_nomFr_espace(champ):
                erreurs_par_colonne[i] += 1
                lignes_erreurs_par_colonne[i].append(idx)
        if i == 6:
            if not verif_champ_nomCourtFr(champ):
                erreurs_par_colonne[i] += 1
                lignes_erreurs_par_colonne[i].append(idx)

            # Vérifier l'unité correspondante (colonne 12)
            unite = champs[10].strip()
            if not verif_champ_unite(champ, unite):
                erreurs_par_colonne[10] += 1
                lignes_erreurs_par_colonne[10].append(idx)

        elif i == 29 and not verif_champ_conformeRoHs(champ):
            erreurs_par_colonne[i] += 1
            lignes_erreurs_par_colonne[i].append(idx)

        elif i == 15:
            if not verif_champ_conformeLevel(champ):
                erreurs_par_colonne[i] += 1
                lignes_erreurs_par_colonne[i].append(idx)

            colonnes_a_verifier = [16, 18, 19, 20, 21, 22, 23, 24]
            # Obtenir les règles de validation spécifiques au niveau
            regles_niveau = data.get(champ)

            if not regles_niveau:
                for col in colonnes_a_verifier:
                    erreurs_par_colonne[col] += 1
                    lignes_erreurs_par_colonne[col].append(idx)
            else:
                for col in colonnes_a_verifier:
                    valeur_champ = champs[col]
                    regle = regles_niveau.get(str(col))
                    if regle and not verif_champ_avec_exclusion(valeur_champ, regle):
                        erreurs_par_colonne[col] += 1
                        lignes_erreurs_par_colonne[col].append(idx)

        elif i == 43 and not verif_champ_temperature(champ):
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
    f_out.write('<div id="largeursMax" style="display:none;">{}</div>\n'.format(json.dumps(largeurs_max)))

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

            if j == 5:
                if verif_champ_nomFr_espace(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)

            if j == 6:
                if not verif_champ_nomCourtFr(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)

                unite = champs[10].strip()  # Récupérer la colonne 12 (index 10)
                if not verif_champ_unite(champ, unite):
                    champs[10] = '<span class="error">{}</span>'.format(champs[10])
            elif j == 29:
                if not verif_champ_conformeRoHs(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)

            elif j == 15:
                if not verif_champ_conformeLevel(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)

                # Si la colonne 15 a une valeur "Level1" à "Level5"
                if len(champs) > 15:
                    level = champs[15]
                    colonnes_a_verifier = [16, 18, 19, 20, 21, 22, 23, 24]

                    if level in data.keys():
                        valeurs_attendues = data[level]

                        # Vérifier les valeurs des colonnes spécifiées
                        for col_idx in colonnes_a_verifier:
                            if col_idx < len(champs):  # Vérifier si col_idx est un index valide
                                valeur_champ = champs[col_idx].strip()  # Obtenir la valeur du champ dans la colonne actuelle

                                # Récupérer la valeur attendue pour cette colonne dans 'valeurs_attendues'
                                valeur_attendue = valeurs_attendues.get(str(col_idx), None)

                                # Si une liste de valeurs acceptées est définie pour cette colonne
                                if isinstance(valeur_attendue, list):
                                    if not verif_champ_avec_exclusion(valeur_champ, valeur_attendue):
                                        champs[col_idx] = '<span class="error">{}</span>'.format(champs[col_idx])

                                # Si une règle d'exclusion est définie
                                elif isinstance(valeur_attendue, dict) and "exclude" in valeur_attendue:
                                    if not verif_champ_avec_exclusion(valeur_champ, valeur_attendue):
                                        champs[col_idx] = '<span class="error">{}</span>'.format(champs[col_idx])

                                # Sinon, une valeur exacte est attendue pour cette colonne
                                elif valeur_attendue is not None:
                                    if valeur_champ != valeur_attendue:
                                        champs[col_idx] = '<span class="error">{}</span>'.format(champs[col_idx])
                    else:
                        for col_idx in colonnes_a_verifier:
                            if col_idx < len(champs):  # Vérifier si col_idx est un index valide
                                champs[col_idx] = '<span class="error">{}</span>'.format(champs[col_idx])

            elif j == 43:
                if not verif_champ_temperature(champ):
                    champs[j] = '<span class="error">{}</span>'.format(champ)
            highlight_class = "highlight" if erreurs_par_colonne[j] > 0 else ""
            f_out.write('<td class="{}">{}</td>'.format(highlight_class, champs[j]))
        f_out.write('</tr>\n')

    # Écrire la fin du fichier HTML
    f_out.write('</table>\n</body>\n</html>')

# Supprimer le fichier intermédiaire de manière sécurisée
try:
    os.remove('extract_intermediate.txt')
except FileNotFoundError:
    print("Le fichier 'extract_intermediate.txt' n'existe pas ou a déjà été supprimé.")

# Afficher un message pour indiquer que le processus est terminé
print("Le fichier a été traité. Les champs mal formatés sont en rouge et en gras dans le fichier de sortie HTML.")