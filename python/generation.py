import pandas as pd
import numpy as np
import random
from datetime import date, timedelta
import os

random.seed(42)
np.random.seed(42)

OUTPATH = "bricoplus_population.xlsx"

# Paramètres
start_date = date(2020,1,1)
end_date = date.today() 
days = (end_date - start_date).days + 1
villes = ["Angers","Grenoble","Le Havre","Paris","Toulouse","Marseille","Toulon",
          "Nice","Bordeaux","Lille","Montpellier","Lyon","Avignon","Limoges",
          "Nantes","Poitiers","Orléans","Rennes","Dijon","Besançon"]

rues_par_ville = {
    "Paris": [
        "Avenue des Champs-Élysées","Rue de Rivoli","Boulevard Saint-Germain",
        "Rue du Faubourg Saint-Honoré","Rue de la Paix","Rue Monge","Rue Censier",
        "Rue Daubenton","Rue Chapon","Rue du Temple"
    ],
    "Lyon": ["Rue de la République","Rue Victor Hugo","Quai Jules Courmont","Rue Mercière","Cours Lafayette"],
    "Marseille": ["La Canebière","Rue Paradis","Boulevard Longchamp","Rue Saint-Ferréol","Cours Julien"],
    "Toulouse": ["Rue d'Alsace-Lorraine","Allées Jean Jaurès","Rue Saint-Rome","Boulevard de Strasbourg"],
    "Bordeaux": ["Cours Victor Hugo","Rue Sainte-Catherine","Quinconces","Place de la Bourse","Rue du Palais Gallien"],
    "Lille": ["Rue Faidherbe","Grand Place","Rue de Béthune","Place du Général de Gaulle"],
    "Nantes": ["Rue Crébillon","Place du Bouffay","Rue de Strasbourg","Bd de la Prairie au Duc"],
    "Montpellier": ["Rue de la Loge","Place de la Comédie","Rue Foch","Rue des Trésoriers de la Bourse"],
    "Nice": ["Promenade des Anglais","Avenue Jean Médecin","Rue Masséna","Boulevard Gambetta"],
    "Brest": ["Rue de Siam","Cours Dajot"], 
    "Angers": ["Rue Saint-Laud","Boulevard Foch","Rue de la Roë","Rue du Mail"],
    "Grenoble": ["Rue Félix Viallet","Rue Jean-Jacques Rousseau","Avenue Alsace Lorraine","Rue Lesdiguières"],
    "Le Havre": ["Quai Southampton","Rue Lemonnier","Rue de Paris","Boulevard de Strasbourg"],
    "Toulon": ["Place d'Armes","Avenue de la République","Rue des Arts"],
    "Avignon": ["Rue de la République","Place de l'Horloge","Rue Joseph Vernet"],
    "Limoges": ["Rue Jean Jaurès","Cours Bugeaud","Place Denis Dussoubs"],
    "Poitiers": ["Rue Carnot","Place Charles de Gaulle","Rue du Marché"],
    "Orléans": ["Rue Jeanne d'Arc","Place du Martroi","Rue de Bourgogne"],
    "Rennes": ["Rue Saint-Michel","Place de la Mairie","Rue d'Antrain"],
    "Dijon": ["Rue de la Liberté","Place Darcy","Rue des Godrans"],
    "Besançon": ["Grande Rue","Rue du Palais","Place Granvelle"]
}
for v in villes:
    if v not in rues_par_ville:
        rues_par_ville[v] = ["Rue de la République","Rue Victor Hugo","Avenue Jean Jaurès"]
prenoms_fr = [
    "Marie","Jean","Pierre","Julie","Luc","Sophie","Antoine","Nathalie","Théo","Emma",
    "Louis","Camille","Paul","Claire","Julien","Laura","Maxime","Chloé","Hugo","Manon",
    "Arthur","Léa","Thomas","Alice","Adrien","Margaux","Lucas","Émilie","Noah","Inès",
    "Léna","Mathis","Sarah","Romain","Anaïs","Gabriel","Louise","Alexandre","Elodie","Baptiste",
    "Louis","Pauline","Nicolas","Marine","Vincent","Jeanne","Quentin","Olivia","Célia","Malo"
]

noms_fr = [
    "Martin","Bernard","Dubois","Thomas","Robert","Richard","Petit","Durand","Leroy","Moreau",
    "Simon","Laurent","Lefebvre","Michel","Garcia","David","Bertrand","Rousseau","Blanc","Morel",
    "Garnier","Faure","Boyer","Roux","Nicolas","Muller","Perrin","Morin","Henry","Renaud",
    "Mathieu","Gauthier","Marchand","Denis","Leclerc","Brun","Philippe","Caron","Bonnet","Masson",
    "Lemoine","Fabre","Gros","Barbier","Colin","Bourgeois","Rousse","Leroy","Prevost","Olivier"
]
produits_catalog = [
    "Perceuse sans fil Bosch 18V","Visseuse Makita 12V","Scie circulaire DeWalt 165mm",
    "Ponceuse Black+Decker 280W","Perceuse Bosch GBH 2-26","Scie sauteuse Metabo 720W",
    "Scie plongeante Festool TS 55","Meuleuse Bosch GWS 7-125","Perceuse à colonne Einhell",
    "Rabot électrique Makita DKP180","Visserie inox assortie 200 pcs","Planche chêne 2m",
    "Panneau MDF 244x122 cm","Équerre Stanley 250mm","Niveau à bulle Stanley 600mm",
    "Tournevis Facom set 10","Clé à molette Bahco 250mm","Perceuse à percussion Hitachi",
    "Rouleau peinture 25cm","Pistolet silicone Bosch","Compresseur Pro 24L","Scie à onglet Ryobi",
    "Rallonge électrique 20m","Lampe de chantier LED 30W","Tasseau sapin 45x45 2m",
    "Cheville universelle 10mm 50pcs","Serre-joint 100mm","Colle bois Titebond 500g","Mastic polyuréthane Soudal"
]
extra_products = []
brands = ["Bosch","Makita","DeWalt","Festool","Stanley","Ryobi","Black+Decker","Hitachi","Metabo"]
for brand in brands:
    for base in ["Perceuse 18V","Visseuse 12V","Scie circulaire 160mm","Ponceuse 240W"]:
        extra_products.append(f"{brand} {base}")
produits_catalog = list(dict.fromkeys(produits_catalog + extra_products))  # unique

# USINES (repris / exemple)
usines_data = [
    (1,"Usine Angers Nord","Rue Saint-Laud","49000","Angers","02 41 12 23 33"),
    (2,"Usine Angers Sud","Boulevard Foch","49000","Angers","02 38 74 52 10"),
    (3,"Usine Grenoble Metallurgie","Rue Jean-Jacques Rousseau","38000","Grenoble","04 76 22 12 77"),
    (4,"Usine Le Havre","Quai Southampton","76600","Le Havre","02 47 26 11 90"),
    (5,"Usine Paris Centre","Rue Daubenton","75005","Paris","01 55 62 29 01"),
    (6,"Usine Toulouse Ouest","Rue d'Alsace-Lorraine","31000","Toulouse","05 61 00 00 01"),
    (7,"Usine Marseille Sud","Rue Paradis","13006","Marseille","04 91 00 00 02"),
    (8,"Usine Nice Est","Avenue Jean Médecin","06000","Nice","04 93 00 00 03"),
    (9,"Usine Bordeaux Nord","Cours Victor Hugo","33000","Bordeaux","05 56 00 00 04"),
    (10,"Usine Lille Est","Rue Faidherbe","59000","Lille","03 20 00 00 05"),
    (11,"Usine Lyon Sud","Rue de la République","69002","Lyon","04 72 00 00 06"),
    (12,"Usine Montpellier Ouest","Rue de la Loge","34000","Montpellier","04 67 00 00 07"),
    (13,"Usine Nantes Centre","Rue Crébillon","44000","Nantes","02 40 00 00 08"),
    (14,"Usine Rennes Nord","Rue Saint-Michel","35000","Rennes","02 99 00 00 09"),
    (15,"Usine Dijon Centre","Rue de la Liberté","21000","Dijon","03 80 00 00 10"),
]
usines = pd.DataFrame(usines_data, columns=["CodeU","NomU","RueU","CPostalU","VilleU","TelU"])

# TYPEU, AVOIR_TYPE, DEPARTEMENTS
typeu = pd.DataFrame([
    (1, "chaine assemblage"),
    (2, "scierie"),
    (3, "métallurgie"),
    (4, "fonderie")
], columns=["CodeTU", "NomTU"])
                 
avoir_type_rows = [(1,1),(1,2),(2,2),(3,3),(4,1),(5,3),(6,4),(7,1),(8,1),(9,3),(10,4),(11,2),(12,1),(13,1),(14,2),(15,3)]
avoir_type = pd.DataFrame(avoir_type_rows, columns=["CodeU","CodeTU"])

departements_list = ["fabrication","assemblage","RH","expédition","logistique","direction","finance"]
departements_rows = []
did = 1
for u in usines["CodeU"]:
    for d in departements_list:
        departements_rows.append((did,u,d))
        did += 1
departements = pd.DataFrame(departements_rows, columns=["CodeD","CodeU","NomD"])

pv_rows = []
pv_id = 1
for ville in villes:
    enseignes = [f"Leroy Merlin {ville}", f"Brico Express {ville}"]
    for enseigne in enseignes:
        rue = random.choice(rues_par_ville[ville])
        numero = random.randint(1,120)
        cp = "75000" if ville=="Paris" else {
            "Angers":"49000","Grenoble":"38000","Le Havre":"76600","Toulouse":"31000","Marseille":"13000",
            "Toulon":"83000","Nice":"06000","Bordeaux":"33000","Lille":"59000","Montpellier":"34000",
            "Lyon":"69002","Avignon":"84000","Limoges":"87000","Nantes":"44000","Poitiers":"86000",
            "Orléans":"45000","Rennes":"35000","Dijon":"21000","Besançon":"25000"}.get(ville, "00000")
        tel = "0" + "".join([str(random.randint(0, 9)) for _ in range(9)])
        pv_rows.append((pv_id, enseigne, f"{numero} {rue}", cp, ville, tel, "GSB" if "Leroy" in enseigne else "Brico-Express"))
        pv_id += 1
points_de_vente = pd.DataFrame(pv_rows, columns=["CodePV","NomPV","RuePV","CPostalPV","VillePV","TelPV","TypePV"])

# QUALIFICATIONS (exemples)
qual_rows = [
    (1,None,"Opérateur fabrication niveau 1",12.0),
    (2,1,"Opérateur fabrication niveau 2",13.0),
    (3,None,"Technicien maintenance",15.0),
    (4,3,"Technicien méthode",16.5),
    (5,None,"Responsable production",25.0),
]
qualifications = pd.DataFrame(qual_rows, columns=["CodeQ","CodeQ_est_completee","NomQ","TauxMinQ"])

# EMPLOYES 
n_employes = 2000
employes_rows = []
phone_mobile_prefixes = ["06","07"]
for eid in range(1, n_employes+1):
    prenom = random.choice(prenoms_fr)
    nom = random.choice(noms_fr)
    ville_pro = random.choice(list(usines["VilleU"]))
    rue_pro = random.choice(rues_par_ville[ville_pro])
    numero_pro = random.randint(1,200)
    cp_pro = usines[usines["VilleU"]==ville_pro]["CPostalU"].iloc[0]
    rue_pro_full = f"{numero_pro} {rue_pro}"
    prefix_map = {
        "01": "01", "02": "02", "03": "03", "04": "04", "05": "05"
    }
    prefix_geo = prefix_map.get(cp_pro[0], "09")
    tel_pro = prefix_geo + "".join([str(random.randint(0, 9)) for _ in range(8)])

    if random.random() < 0.8:
        ville_perso = ville_pro
        rues_choice = rues_par_ville[ville_perso]
    else:
        ville_perso = random.choice(villes)
        rues_choice = rues_par_ville[ville_perso]
    rue_perso = random.choice(rues_choice)
    numero_perso = random.randint(1,300)
    cp_perso = usines[usines["VilleU"]==ville_perso]["CPostalU"].iloc[0] if ville_perso in list(usines["VilleU"]) else "00000"
    rue_perso_full = f"{numero_perso} {rue_perso}"
    tel_perso = random.choice(phone_mobile_prefixes) + "".join([str(random.randint(0, 9)) for _ in range(8)])
    employes_rows.append((eid, nom, prenom, rue_perso_full, cp_perso, ville_perso, rue_pro_full, cp_pro, ville_pro, tel_perso, tel_pro))
employes = pd.DataFrame(employes_rows, columns=["CodeE","NomE","PrenomE","RuePersE","CPostalPersE","VillePersE",
                                               "RueProE","CPostalProE","VilleProE","TelPersE","TelProE"])



# GAMME & PRODUITS (version conforme au dictionnaire Oracle)
# -----------------------------------------------------------

gamme_names = [
    "jardin et piscine",
    "mobilier intérieur",
    "plomberie et chauffage",
    "salle de bain et WC",
    "luminaire",
    "électricité et domotique",
    "quincaillerie",
    "cuisine",
    "peinture et droguerie",
    "carrelage et parquet",
    "matériaux de construction"
]

# Création des codes de gamme au format G01, G02, ...
gammes = pd.DataFrame(
    [(f"G{(i+1):02d}", name) for i, name in enumerate(gamme_names)],
    columns=["CodeG", "NomG"]
)

# Génération des produits (référence à CodeG au format Gxx)
produits_rows = []
pid = 1
while pid <= 240:
    base = random.choice(produits_catalog)
    variant = f"{base} - modèle {random.randint(100,999)}"
    g = random.choice(list(gammes["CodeG"]))
    produits_rows.append((pid, variant, base.split()[0].capitalize(), g))  
    pid += 1

produits = pd.DataFrame(produits_rows, columns=["CodeP", "NomP", "MarqueP", "CodeG"])

# ASSEMBLER (corrigé avec Qte_Assembl et logique acyclique inchangée)

assembler_rows = []
relations = {}  

def cree_cycle(compose, composant):
    """Vérifie récursivement si ajouter (compose -> composant) crée un cycle."""
    if composant == compose:
        return True
    for fils in relations.get(composant, set()):
        if cree_cycle(compose, fils):
            return True
    return False

# Génération acyclique
produit_ids = list(produits["CodeP"])
for p1 in produit_ids:
    if random.random() < 0.3: 
        nb_comp = random.randint(1, 3)
        candidats = random.sample(produit_ids, nb_comp * 2)  
        composants_valides = []
        for p2 in candidats:
            if p1 == p2:
                continue  
            if cree_cycle(p1, p2):
                continue 
            composants_valides.append(p2)
            if len(composants_valides) >= nb_comp:
                break
        for p2 in composants_valides:
            qte_assembl = random.randint(1, 10)
            assembler_rows.append((p1, p2, qte_assembl))
            relations.setdefault(p1, set()).add(p2)

assembler = pd.DataFrame(
    assembler_rows,
    columns=["CodeP_compose", "CodeP_est_compose", "Qte_Assembl"]
)



# CORRESPONDANCE TYPEU ↔ GAMME (logique métier)
typeu_to_gamme = {
    "chaine assemblage": ["cuisine", "luminaire", "mobilier intérieur"],
    "scierie": ["mobilier intérieur", "matériaux de construction", "carrelage et parquet"],
    "métallurgie": ["quincaillerie", "électricité et domotique"],
    "fonderie": ["plomberie et chauffage", "salle de bain et WC"]
}

# Création d’un mapping CodeTU → [CodeG]
type_to_gammes = {}
for _, trow in typeu.iterrows():
    nom_tu = trow["NomTU"]
    gammes_ok = [g for g, name in zip(gammes["CodeG"], gammes["NomG"]) if name in typeu_to_gamme.get(nom_tu, [])]
    type_to_gammes[trow["CodeTU"]] = gammes_ok

# FABRIQUER (journalier) cohérent avec TYPEU ↔ GAMME
fabric_rows = []
for _, usine in usines.iterrows():
    codeu = usine["CodeU"]
    types_usine = avoir_type[avoir_type["CodeU"] == codeu]["CodeTU"].tolist()
    gammes_autorisees = set()
    for t in types_usine:
        gammes_autorisees.update(type_to_gammes.get(t, []))
    produits_autorises = produits[produits["CodeG"].isin(gammes_autorisees)]["CodeP"].tolist()
    if not produits_autorises:
        produits_autorises = random.sample(list(produits["CodeP"]), 5)
    selected = random.sample(produits_autorises, min(len(produits_autorises), random.randint(10, 20)))
    for p in selected:
        for offset in range(days):
            if random.random() < 0.05: 
                d = start_date + timedelta(days=offset)
                q = random.randint(1, 120)
                fabric_rows.append((codeu, p, d.strftime("%Y-%m-%d"), q))

fabricer = pd.DataFrame(fabric_rows, columns=["CodeU","CodeP","DateFab","Qte_Fab"])

# Mois/Années à générer (par ex. de 2020 à 2025 inclus)
months = []
for y in range(2020, end_date.year + 1):
    for m in range(1, 13):
        months.append((m, y))
dept_staff = {
    "fabrication": 30,
    "assemblage": 25,
    "RH": 6,
    "expédition": 12,
    "logistique": 10,
    "direction": 3,
    "finance": 4
}

# ==========================================================
# AFFECTATION FIXE DES EMPLOYÉS À UN SEUL DÉPARTEMENT PAR USINE
# ==========================================================
affectations_usine = []
employes_affectes_usine = set()

for _, dep in departements.iterrows():
    villeu = usines.loc[usines["CodeU"] == dep["CodeU"], "VilleU"].iloc[0]

    candidats = [e for e in employes[employes["VilleProE"] == villeu]["CodeE"].tolist()
                 if e not in employes_affectes_usine]

    needed = dept_staff.get(dep["NomD"], 5)

    if len(candidats) < needed:
        candidats = [e for e in employes["CodeE"].tolist() if e not in employes_affectes_usine]

    chosen = random.sample(candidats, k=min(needed, len(candidats)))

    for e in chosen:
        affectations_usine.append((dep["CodeD"], e))
        employes_affectes_usine.add(e)

affectations_usine = pd.DataFrame(affectations_usine, columns=["CodeD", "CodeE"])


# TRAVAILLER_USINE (corrigé, conforme à AFFECTATIONS_USINE)

trus_rows = []
for (m, y) in months:
    for _, aff in affectations_usine.iterrows():
        codeD, codeE = aff["CodeD"], aff["CodeE"]
        temps = random.choice(["temps_plein", "temps_partiel"])
        nb_heures = round((35 if temps == "temps_plein" else 17.5) * 4.333, 2)
        trus_rows.append((codeD, m, y, codeE, nb_heures))

travailler_usine = pd.DataFrame(
    trus_rows,
    columns=["CodeD", "Mois", "Annee", "CodeE", "NbHeures_U"]
)


# ==========================================================
# AFFECTATION FIXE DES EMPLOYÉS À UN SEUL POINT DE VENTE
# ==========================================================
affectations_pv = []
employes_affectes_pv = set()

for _, pv in points_de_vente.iterrows():
    villev = pv["VillePV"]

    candidats = [e for e in employes[employes["VilleProE"] == villev]["CodeE"].tolist()
                 if e not in employes_affectes_pv]

    needed = 3

    if len(candidats) < needed:
        candidats = [e for e in employes["CodeE"].tolist() if e not in employes_affectes_pv]

    chosen = random.sample(candidats, k=min(needed, len(candidats)))

    for e in chosen:
        affectations_pv.append((pv["CodePV"], e))
        employes_affectes_pv.add(e)

affectations_pv = pd.DataFrame(affectations_pv, columns=["CodePV", "CodeE"])


# ==========================================================
# EMPLOYÉS AYANT UNE DOUBLE AFFECTATION (USINE + POINT DE VENTE)
# ==========================================================
double_rows = []

for ville in employes["VilleProE"].unique():
    emp_ville = employes[employes["VilleProE"] == ville]["CodeE"].tolist()
    usines_ville = usines[usines["VilleU"] == ville]["CodeU"].tolist()
    pvs_ville = points_de_vente[points_de_vente["VillePV"] == ville]["CodePV"].tolist()

    if emp_ville and usines_ville and pvs_ville:
        emp_usine_ville = affectations_usine[
            affectations_usine["CodeE"].isin(emp_ville)
        ]["CodeE"].unique().tolist()

        nb = max(1, len(emp_usine_ville) // 10)
        selected = random.sample(emp_usine_ville, k=min(nb, len(emp_usine_ville)))

        for e in selected:
            pv = random.choice(pvs_ville)
            if e not in affectations_pv["CodeE"].values:
                affectations_pv = pd.concat([
                    affectations_pv,
                    pd.DataFrame([(pv, e)], columns=["CodePV", "CodeE"])
                ], ignore_index=True)
                double_rows.append((ville, e, pv))



# ==========================================================
# LISTE DES EMPLOYÉS À DOUBLE AFFECTATION (présents dans plusieurs entités)
# ==========================================================

# Un employé est "doublement affecté" s’il apparaît plusieurs fois dans affectations_pv
employes_double = affectations_pv["CodeE"].value_counts()
employes_double = employes_double[employes_double > 1].index.tolist()

# ==========================================================
# TRAVAILLER_PT_VENTE (corrigé pour respecter 35h max par semaine cumulées)
# ==========================================================
trpv_rows = []

heures_plein = 35 * 4.333  # 35h/semaine en moyenne mensuelle
heures_partiel = 17.5 * 4.333  

for (m, y) in months:
    for _, pv_aff in affectations_pv.iterrows():
        codePV = pv_aff["CodePV"]
        codeE = pv_aff["CodeE"]

        est_double = codeE in affectations_usine["CodeE"].values

        if est_double:
            repartition = random.uniform(0.4, 0.6)
            heures_usine = heures_plein * repartition
            heures_pv = heures_plein * (1 - repartition)
        else:
            heures_pv = random.choice([heures_plein, heures_partiel])

        trpv_rows.append((codePV, m, y, codeE, round(heures_pv, 2)))

travailler_pt_vente = pd.DataFrame(
    trpv_rows,
    columns=["CodePV", "Mois", "Annee", "CodeE", "NbHeures_PV"]
)



# FACTURER (corrigé selon le schéma SQL)
facture_rows = []
for (m, y) in months:
    for codeP in random.sample(list(produits["CodeP"]), k=random.randint(10, 30)):
        prix = round(random.uniform(5, 1500), 2)
        facture_rows.append((codeP, m, y, prix))

facturer = pd.DataFrame(
    facture_rows,
    columns=["CodeP", "Mois", "Annee", "PrixUnitP"]
)


# VENDRE (corrigé selon le schéma SQL)
vendre_rows = []

for _, pv_row in points_de_vente.iterrows():
    codePV = pv_row["CodePV"]

    employes_pv = travailler_pt_vente[travailler_pt_vente["CodePV"] == codePV]["CodeE"].unique().tolist()
    if not employes_pv:
        continue

    produits_pv = random.sample(list(produits["CodeP"]), k=random.randint(10, 20))

    for codeE in employes_pv:
        annees_employe = travailler_pt_vente[
            (travailler_pt_vente["CodePV"] == codePV) &
            (travailler_pt_vente["CodeE"] == codeE)
        ]["Annee"].unique()

        for annee in annees_employe:
            produits_vendus = random.sample(produits_pv, k=random.randint(3, 8))
            for codeP in produits_vendus:
                qte = random.randint(1, 30)
                mois = random.randint(1, 12)
                vendre_rows.append((codeP, codePV, codeE, mois, annee, qte))

vendre = pd.DataFrame(
    vendre_rows,
    columns=["CodeP", "CodePV", "CodeE", "Mois", "Annee", "Qte_Vendue"]
)

aut_rows = []
for _, dep in departements.iterrows():
    q_auth = random.sample(list(qualifications["CodeQ"]), k=random.randint(1, min(3, len(qualifications))))
    for q in q_auth:
        aut_rows.append((dep["CodeD"], q))
autoriser = pd.DataFrame(aut_rows, columns=["CodeD", "CodeQ"])
# DIRIGER (CodeD, CodeE, DateDebutDir) cohérent : le directeur appartient au département
diriger_rows = []

employes_par_dept = (
    affectations_usine.groupby("CodeD")["CodeE"]
    .apply(list)
    .to_dict()
)

for _, dept in departements.iterrows():
    coded = dept["CodeD"]

    candidats = employes_par_dept.get(coded, [])

    if not candidats:
        usine_parent = usines[usines["CodeU"] == dept["CodeU"]].iloc[0] if "CodeU" in dept else None
        if usine_parent is not None:
            deps_meme_unite = departements[departements["CodeU"] == usine_parent["CodeU"]]["CodeD"].tolist()
            candidats = []
            for d2 in deps_meme_unite:
                candidats.extend(employes_par_dept.get(d2, []))

    if not candidats:
        candidats = random.sample(list(employes["CodeE"]), 1)

    directeur = random.choice(candidats)

    date_dir = date(y, 1, 1)  

    diriger_rows.append((coded, directeur, date_dir))

diriger = pd.DataFrame(diriger_rows, columns=["CodeD", "CodeE", "DateDebutDir"])


# ----------------------------
# POSSEDER : qualifications autorisées par le(s) département(s) de l'employé
# ----------------------------

pos_rows = []

employe_departements = (
    affectations_usine.groupby("CodeE")["CodeD"]
    .apply(list)
    .to_dict()
)

departement_qualifs = (
    autoriser.groupby("CodeD")["CodeQ"]
    .apply(list)
    .to_dict()
)

for e in employes["CodeE"]:
    # Départements de cet employé
    deps = employe_departements.get(e, [])
    qualifs_autorisees = set()
    for d in deps:
        qualifs_autorisees.update(departement_qualifs.get(d, []))
    if not qualifs_autorisees:
        qualifs_autorisees = set(random.sample(list(qualifications["CodeQ"]), k=random.randint(1,2)))
    nb = random.choices([1,2,3], weights=[0.6,0.3,0.1])[0]
    qs = random.sample(list(qualifs_autorisees), k=min(nb, len(qualifs_autorisees)))
    for q in qs:
        pos_rows.append((q, e))

posseders = pd.DataFrame(pos_rows, columns=["CodeQ","CodeE"])

# ==========================================================
# PAYER1 : rémunération annuelle dépendant de la qualification et du temps de travail réel
# ==========================================================
payer1_rows = []
base_heures_mensuelles = 151.67 #35h/semaine 
qualif_emp = (
    posseders.merge(qualifications, on="CodeQ", how="left")
    .groupby("CodeE")["TauxMinQ"]
    .max()
    .to_dict()
)
# Moyenne d'heures travaillées par mois pour chaque employé (usine + point de vente)
heures_emp = pd.concat([
    travailler_usine.groupby("CodeE")["NbHeures_U"].mean(),
    travailler_pt_vente.groupby("CodeE")["NbHeures_PV"].mean()
], axis=1).fillna(0)
# Total mensuel
heures_emp["HeuresTotales"] = heures_emp["NbHeures_U"] + heures_emp["NbHeures_PV"]
# Dictionnaire pour un accès rapide
heures_mensuelles_emp = heures_emp["HeuresTotales"].to_dict()
for e in employes["CodeE"]:
    taux_horaire = qualif_emp.get(e, 12.0)
    heures_mensuelles = heures_mensuelles_emp.get(e, base_heures_mensuelles)
    ratio_temps = min(heures_mensuelles / base_heures_mensuelles, 1.0)
    for y in range(2020, end_date.year + 1):
        fixe_mensuel = round(base_heures_mensuelles * taux_horaire * ratio_temps * random.uniform(1.0, 1.3), 2)
        indice_sal = int(round(taux_horaire / 5))
        payer1_rows.append((e, y, fixe_mensuel, indice_sal))
payer1 = pd.DataFrame(payer1_rows, columns=["CodeE", "Annee", "FixeMensuelE", "IndiceSalE"])


# RESPONSABLE : un employé responsable d'une gamme donnée par an (avec continuité partielle)
responsable_rows = []

# Dictionnaire pour mémoriser le responsable précédent par gamme
responsable_precedent = {}

for y in range(2020, end_date.year + 1):
    for g in gammes["CodeG"]:
        if g in responsable_precedent and random.random() < 0.7:
            e = responsable_precedent[g]
        else:
            e = random.choice(list(employes["CodeE"]))
            responsable_precedent[g] = e  
        responsable_rows.append((e, y, g))

responsable = pd.DataFrame(responsable_rows, columns=["CodeE", "Annee", "CodeG"])



# PAYER2 : indice de rétrocession pour chaque gamme et année
payer2_rows = []
for y in range(2020, end_date.year + 1):
    for g in gammes["CodeG"]:
        ind = round(random.uniform(0.1, 0.9), 2)
        payer2_rows.append((y, g, ind))
payer2 = pd.DataFrame(payer2_rows, columns=["Annee", "CodeG", "IndiceRetrocessionG"])

# ==========================================================
# SAUVEGARDE : 1 fichier CSV par table
# ==========================================================
output_dir = "bricoplus_csv"
os.makedirs(output_dir, exist_ok=True)

tables = {
    "USINES": usines,
    "TYPEU": typeu,
    "AVOIR_TYPE": avoir_type,
    "DEPARTEMENTS": departements,
    "POINTS_DE_VENTE": points_de_vente,
    "QUALIFICATIONS": qualifications,
    "EMPLOYES": employes,
    "POSSEDER": posseders,
    "AUTORISER": autoriser,
    "DIRIGER": diriger,
    "GAMME": gammes,
    "PRODUITS": produits,
    "ASSEMBLER": assembler,
    "FABRIQUER": fabricer,
    "VENDRE": vendre,
    "FACTURER": facturer,
    "TRAVAILLER_USINE": travailler_usine,
    "TRAVAILLER_PT_VENTE": travailler_pt_vente,
    "PAYER1": payer1,
    "RESPONSABLE": responsable,
    "PAYER2": payer2
}

for name, df in tables.items():
    file_path = os.path.join(output_dir, f"{name}.csv")
    # encodage UTF-8, séparateur “;” (plus lisible sous Excel/LibreOffice)
    df.to_csv(file_path, index=False, sep=";", encoding="utf-8")
    print(f"Fichier CSV créé : {file_path}")

print(f"\nTous les fichiers CSV ont été enregistrés dans le dossier : {output_dir}")