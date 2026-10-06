#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CrowdFundr MongoDB Application

Application console connectee a la base MongoDB creee par mongodb/setup.js.
Schema utilise :
- personnes
- projets
- contributions
"""

import hmac
import os
from datetime import datetime

from pymongo import ASCENDING, MongoClient
from pymongo.errors import PyMongoError


# Configuration is read from environment variables (or a local .env file).
# See .env.example at the root of the repository.
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:  # python-dotenv is optional
    pass

MONGO_CONFIG = {
    "uri": os.getenv("MONGO_URI", "mongodb://localhost:27017/"),
    "database": os.getenv("MONGO_DB", "crowdfundr"),
}

# No default: admin access stays disabled until a password is configured.
ADMIN_PASSWORD = os.getenv("CROWDFUNDR_ADMIN_PASSWORD")


class CrowdFundrMongoApp:
    """Application CrowdFundr connectee a MongoDB."""

    def __init__(self):
        self.client = None
        self.db = None
        self.personnes = None
        self.projets = None
        self.contributions = None
        self.user = None
        self.is_admin = False

    # ===== CONNEXION =====

    def connect_db(self):
        """Etablir la connexion a MongoDB."""
        try:
            self.client = MongoClient(MONGO_CONFIG["uri"], serverSelectionTimeoutMS=3000)
            self.client.admin.command("ping")
            self.db = self.client[MONGO_CONFIG["database"]]
            self.personnes = self.db["personnes"]
            self.projets = self.db["projets"]
            self.contributions = self.db["contributions"]
            self.create_indexes()
            print("Connexion a MongoDB reussie!\n")
            return True
        except PyMongoError as error:
            print(f"Erreur de connexion MongoDB: {error}")
            return False

    def close_db(self):
        """Fermer la connexion MongoDB."""
        if self.client:
            self.client.close()
        print("\nConnexion fermee.")

    def create_indexes(self):
        """Creer les index utiles pour le schema en 3 collections."""
        self.personnes.create_index([("id_personne", ASCENDING)], unique=True)
        self.personnes.create_index([("pseudo", ASCENDING)], unique=True, sparse=True)
        self.personnes.create_index([("type_personne", ASCENDING)])
        self.projets.create_index([("titre", ASCENDING)], unique=True)
        self.projets.create_index([("type", ASCENDING)])
        self.projets.create_index([("membres.id_personne", ASCENDING)])
        self.projets.create_index([("ong.nom_ONG", ASCENDING)])
        self.contributions.create_index(
            [("date_heure", ASCENDING), ("utilisateur_id", ASCENDING), ("projet_titre", ASCENDING)],
            unique=True,
        )
        self.contributions.create_index([("projet_titre", ASCENDING)])
        self.contributions.create_index([("utilisateur_id", ASCENDING)])
        self.contributions.create_index([("contrepartie.transporteur.nom", ASCENDING)])

    # ===== OUTILS =====

    def lire_float(self, message, minimum=None):
        """Lire un nombre decimal au clavier."""
        try:
            value = float(input(message).strip())
            if minimum is not None and value < minimum:
                print(f"La valeur doit etre superieure ou egale a {minimum}.")
                return None
            return value
        except ValueError:
            print("Valeur invalide.")
            return None

    def lire_date(self, message):
        """Lire une date au format YYYY-MM-DD."""
        value = input(message).strip()
        try:
            return datetime.strptime(value, "%Y-%m-%d")
        except ValueError:
            print("Date invalide. Format attendu: YYYY-MM-DD.")
            return None

    def get_next_user_id(self):
        """Calculer le prochain id_personne."""
        last = self.personnes.find_one(sort=[("id_personne", -1)])
        return int(last["id_personne"]) + 1 if last else 1

    def get_user_by_pseudo(self, pseudo):
        """Trouver un utilisateur par pseudo."""
        return self.personnes.find_one({"type_personne": "utilisateur", "pseudo": pseudo})

    def choisir_projet(self, filtre=None):
        """Afficher une liste de projets et retourner le projet choisi."""
        projets = list(
            self.projets.find(
                filtre or {},
                {"titre": 1, "type": 1, "objectif_financier": 1, "date_lancement": 1},
            ).sort("date_lancement", -1)
        )

        if not projets:
            print("Aucun projet disponible.")
            return None

        for index, projet in enumerate(projets, 1):
            print(
                f"{index}. {projet['titre']} "
                f"({projet.get('type', 'N/A')}, objectif {projet.get('objectif_financier', 0)} EUR)"
            )

        try:
            choix = int(input("Choisir le numero du projet: ").strip())
            if 1 <= choix <= len(projets):
                return projets[choix - 1]
        except ValueError:
            pass

        print("Choix invalide.")
        return None

    # ===== MENUS =====

    def menu_principal(self):
        """Afficher le menu principal."""
        while True:
            print("\n" + "=" * 50)
            print("     CROWDFUNDR MONGODB - MENU PRINCIPAL")
            print("=" * 50)
            print("1. Utilisateur normal")
            print("2. Administrateur")
            print("3. Quitter")
            print("=" * 50)

            choix = input("Votre choix (1-3): ").strip()
            if choix == "1":
                self.menu_utilisateur()
            elif choix == "2":
                if self.authentifier_admin():
                    self.menu_admin()
            elif choix == "3":
                print("Merci d'avoir utilise CrowdFundr MongoDB!")
                break
            else:
                print("Choix invalide.")

    def authentifier_admin(self):
        """Authentifier l'administrateur."""
        if not ADMIN_PASSWORD:
            print("Acces admin desactive : definissez CROWDFUNDR_ADMIN_PASSWORD (voir .env.example).")
            return False
        password = input("\nMot de passe administrateur: ")
        if hmac.compare_digest(password, ADMIN_PASSWORD):
            self.is_admin = True
            print("Authentification reussie!")
            return True
        print("Mot de passe incorrect.")
        return False

    def menu_utilisateur(self):
        """Menu utilisateur."""
        while True:
            print("\n" + "=" * 50)
            print("     MENU UTILISATEUR")
            print("=" * 50)
            print("1. Se connecter / creer un profil")
            print("2. Ajouter une contribution")
            print("3. Evaluer un projet")
            print("4. Afficher tous les projets")
            print("5. Voir mes contributions")
            print("6. Retour")
            print("=" * 50)

            choix = input("Votre choix (1-6): ").strip()
            if choix == "1":
                self.gerer_compte_utilisateur()
            elif choix == "2":
                self.ajouter_contribution() if self.user else print("Veuillez d'abord vous connecter.")
            elif choix == "3":
                self.evaluer_projet() if self.user else print("Veuillez d'abord vous connecter.")
            elif choix == "4":
                self.afficher_projets()
            elif choix == "5":
                self.voir_mes_contributions() if self.user else print("Veuillez d'abord vous connecter.")
            elif choix == "6":
                break
            else:
                print("Choix invalide.")

    def menu_admin(self):
        """Menu administrateur."""
        while True:
            print("\n" + "=" * 50)
            print("     MENU ADMINISTRATEUR")
            print("=" * 50)
            print("1. Gerer les utilisateurs")
            print("2. Gerer les projets")
            print("3. Afficher les collections")
            print("4. Executer les requetes complexes")
            print("5. Retour")
            print("=" * 50)

            choix = input("Votre choix (1-5): ").strip()
            if choix == "1":
                self.menu_gerer_utilisateurs()
            elif choix == "2":
                self.menu_gerer_projets()
            elif choix == "3":
                self.menu_afficher_collections()
            elif choix == "4":
                self.menu_requetes_complexes()
            elif choix == "5":
                self.is_admin = False
                break
            else:
                print("Choix invalide.")

    # ===== UTILISATEURS =====

    def gerer_compte_utilisateur(self):
        """Connexion ou creation de profil utilisateur."""
        print("\n1. Se connecter")
        print("2. Creer un profil")
        choix = input("Votre choix (1-2): ").strip()

        if choix == "1":
            self.connecter_utilisateur()
        elif choix == "2":
            self.creer_compte_utilisateur()
        else:
            print("Choix invalide.")

    def connecter_utilisateur(self):
        """Connecter un utilisateur existant."""
        pseudo = input("Pseudo: ").strip()
        user = self.get_user_by_pseudo(pseudo)
        if user:
            self.user = user
            print(f"Connexion reussie. Bienvenue {user.get('nom', pseudo)}!")
        else:
            print("Utilisateur non trouve.")

    def creer_compte_utilisateur(self):
        """Creer un utilisateur dans la collection personnes."""
        print("\n--- Creation de profil ---")
        pseudo = input("Pseudo: ").strip()
        if self.get_user_by_pseudo(pseudo):
            print("Ce pseudo existe deja.")
            return

        email = input("Email: ").strip()
        nom = input("Nom: ").strip()
        date_naissance = self.lire_date("Date de naissance (YYYY-MM-DD): ")
        if not date_naissance:
            return

        user = {
            "id_personne": self.get_next_user_id(),
            "type_personne": "utilisateur",
            "pseudo": pseudo,
            "adresse_mail": email,
            "nom": nom,
            "date_naissance": date_naissance,
        }
        self.personnes.insert_one(user)
        self.user = user
        print(f"Profil cree. ID: {user['id_personne']}")

    def menu_gerer_utilisateurs(self):
        """Menu admin pour les utilisateurs."""
        while True:
            print("\n" + "-" * 50)
            print("GESTION DES UTILISATEURS")
            print("-" * 50)
            print("1. Afficher tous les utilisateurs")
            print("2. Modifier le nom d'un utilisateur")
            print("3. Supprimer les contributions d'un utilisateur")
            print("4. Retour")
            print("-" * 50)

            choix = input("Votre choix (1-4): ").strip()
            if choix == "1":
                self.admin_afficher_utilisateurs()
            elif choix == "2":
                self.admin_modifier_utilisateur()
            elif choix == "3":
                self.admin_supprimer_contributions_utilisateur()
            elif choix == "4":
                break
            else:
                print("Choix invalide.")

    def admin_afficher_utilisateurs(self):
        """Afficher les utilisateurs."""
        users = list(
            self.personnes.find({"type_personne": "utilisateur"}).sort("pseudo", ASCENDING)
        )
        if not users:
            print("Aucun utilisateur.")
            return

        print(f"\n{'ID':<5} {'Pseudo':<20} {'Email':<30} {'Nom':<20}")
        print("-" * 80)
        for user in users:
            print(
                f"{user.get('id_personne', ''):<5} "
                f"{user.get('pseudo', ''):<20} "
                f"{user.get('adresse_mail', ''):<30} "
                f"{user.get('nom', ''):<20}"
            )

    def admin_modifier_utilisateur(self):
        """Modifier le nom d'un utilisateur dans personnes."""
        pseudo = input("Pseudo de l'utilisateur: ").strip()
        nouveau_nom = input("Nouveau nom: ").strip()
        result = self.personnes.update_one(
            {"type_personne": "utilisateur", "pseudo": pseudo},
            {"$set": {"nom": nouveau_nom}},
        )
        print("Utilisateur modifie." if result.modified_count else "Utilisateur non trouve.")

    def admin_supprimer_contributions_utilisateur(self):
        """Supprimer les contributions et evaluations d'un utilisateur."""
        pseudo = input("Pseudo de l'utilisateur: ").strip()
        user = self.get_user_by_pseudo(pseudo)
        if not user:
            print("Utilisateur non trouve.")
            return

        confirmation = input("Confirmer la suppression? (oui/non): ").strip().lower()
        if confirmation != "oui":
            print("Suppression annulee.")
            return

        user_id = user["id_personne"]
        deleted = self.contributions.delete_many({"utilisateur_id": user_id})
        updated = self.projets.update_many({}, {"$pull": {"evaluations": {"utilisateur_id": user_id}}})
        print(f"{deleted.deleted_count} contribution(s) supprimee(s).")
        print(f"Evaluations supprimees dans {updated.modified_count} projet(s).")

    # ===== CONTRIBUTIONS ET EVALUATIONS =====

    def ajouter_contribution(self):
        """Ajouter une contribution dans la collection contributions."""
        print("\n--- Ajouter une contribution ---")
        projet = self.choisir_projet()
        if not projet:
            return

        montant = self.lire_float("Montant de la contribution (EUR): ", minimum=0.01)
        if montant is None:
            return

        print("\nType de contrepartie")
        print("1. Numerique")
        print("2. Physique")
        type_choix = input("Votre choix (1-2): ").strip()

        contrepartie = {"id_contrepartie": int(datetime.now().timestamp())}
        if type_choix == "1":
            contrepartie["type"] = "numerique"
            contrepartie["format_fichier"] = input("Format fichier: ").strip() or "PDF"
            taille = self.lire_float("Taille du fichier: ", minimum=0)
            if taille is None:
                return
            contrepartie["taille"] = taille
        elif type_choix == "2":
            contrepartie["type"] = "physique"
            poids = self.lire_float("Poids: ", minimum=0.01)
            frais = self.lire_float("Frais livraison: ", minimum=0)
            if poids is None or frais is None:
                return
            transporteur = input("Transporteur: ").strip() or "Chronopost"
            contrepartie["poids"] = poids
            contrepartie["frais_livraison"] = frais
            contrepartie["transporteur"] = {
                "nom": transporteur,
                "delai_livraison": 2 if transporteur == "Chronopost" else 5,
            }
        else:
            print("Choix invalide.")
            return

        self.contributions.insert_one(
            {
                "date_heure": datetime.now(),
                "projet_titre": projet["titre"],
                "utilisateur_id": self.user["id_personne"],
                "montant": montant,
                "contrepartie": contrepartie,
            }
        )
        print(f"Contribution de {montant:.2f} EUR ajoutee au projet {projet['titre']}.")

    def evaluer_projet(self):
        """Evaluer un projet seulement si l'utilisateur a contribue."""
        print("\n--- Evaluer un projet ---")
        titres = self.contributions.distinct("projet_titre", {"utilisateur_id": self.user["id_personne"]})
        projets = list(self.projets.find({"titre": {"$in": titres}}, {"titre": 1}).sort("titre", ASCENDING))

        if not projets:
            print("Vous n'avez contribue a aucun projet.")
            return

        for index, projet in enumerate(projets, 1):
            print(f"{index}. {projet['titre']}")

        try:
            choix = int(input("Choisir le numero du projet: ").strip())
            projet = projets[choix - 1]
        except (ValueError, IndexError):
            print("Choix invalide.")
            return

        try:
            note = int(input("Note (1-5): ").strip())
            if not 1 <= note <= 5:
                print("La note doit etre entre 1 et 5.")
                return
        except ValueError:
            print("Note invalide.")
            return

        avis = input("Avis: ").strip()
        evaluation = {
            "utilisateur_id": self.user["id_personne"],
            "pseudo": self.user["pseudo"],
            "note": note,
            "avis_text": avis,
            "date_avis": datetime.now(),
        }
        self.projets.update_one(
            {"titre": projet["titre"]},
            {"$pull": {"evaluations": {"utilisateur_id": self.user["id_personne"]}}},
        )
        self.projets.update_one({"titre": projet["titre"]}, {"$push": {"evaluations": evaluation}})
        print("Evaluation enregistree.")

    def voir_mes_contributions(self):
        """Afficher les contributions de l'utilisateur connecte."""
        cursor = self.contributions.find({"utilisateur_id": self.user["id_personne"]}).sort("date_heure", -1)
        total = 0
        found = False
        for contribution in cursor:
            found = True
            montant = contribution.get("montant", 0)
            total += montant
            print(
                f"- {contribution['projet_titre']}: {montant:.2f} EUR "
                f"({contribution.get('date_heure')})"
            )
        print(f"Total: {total:.2f} EUR" if found else "Aucune contribution.")

    # ===== PROJETS =====

    def menu_gerer_projets(self):
        """Menu admin pour les projets."""
        while True:
            print("\n" + "-" * 50)
            print("GESTION DES PROJETS")
            print("-" * 50)
            print("1. Ajouter un projet")
            print("2. Modifier l'objectif d'un projet")
            print("3. Supprimer un projet")
            print("4. Afficher tous les projets")
            print("5. Retour")
            print("-" * 50)

            choix = input("Votre choix (1-5): ").strip()
            if choix == "1":
                self.admin_ajouter_projet()
            elif choix == "2":
                self.admin_modifier_objectif_projet()
            elif choix == "3":
                self.admin_supprimer_projet()
            elif choix == "4":
                self.afficher_projets()
            elif choix == "5":
                break
            else:
                print("Choix invalide.")

    def admin_ajouter_projet(self):
        """Ajouter un projet minimal."""
        print("\n--- Ajouter un projet ---")
        titre = input("Titre: ").strip()
        if self.projets.find_one({"titre": titre}):
            print("Ce projet existe deja.")
            return

        description = input("Description: ").strip()
        type_projet = input("Type (artistique/social/technologique): ").strip().lower()
        objectif = self.lire_float("Objectif financier: ", minimum=0.01)
        date_lancement = self.lire_date("Date de lancement (YYYY-MM-DD): ")
        if objectif is None or not date_lancement:
            return

        projet = {
            "titre": titre,
            "description": description,
            "type": type_projet,
            "objectif_financier": objectif,
            "date_lancement": date_lancement,
            "incubateur": None,
            "membres": [],
            "ong": [],
            "evaluations": [],
        }
        if type_projet == "artistique":
            projet["medium"] = input("Medium: ").strip()
        elif type_projet == "social":
            projet["region_cible"] = input("Region cible: ").strip()
        elif type_projet == "technologique":
            projet["type_innovation"] = input("Type innovation: ").strip()

        self.projets.insert_one(projet)
        print(f"Projet {titre} ajoute.")

    def admin_modifier_objectif_projet(self):
        """Modifier l'objectif financier."""
        titre = input("Titre du projet: ").strip()
        objectif = self.lire_float("Nouvel objectif financier: ", minimum=0.01)
        if objectif is None:
            return

        result = self.projets.update_one({"titre": titre}, {"$set": {"objectif_financier": objectif}})
        print("Projet modifie." if result.modified_count else "Projet non trouve ou objectif identique.")

    def admin_supprimer_projet(self):
        """Supprimer un projet et ses contributions."""
        titre = input("Titre du projet a supprimer: ").strip()
        confirmation = input("Confirmer la suppression? (oui/non): ").strip().lower()
        if confirmation != "oui":
            print("Suppression annulee.")
            return

        deleted_project = self.projets.delete_one({"titre": titre})
        deleted_contribs = self.contributions.delete_many({"projet_titre": titre})
        if deleted_project.deleted_count:
            print(f"Projet supprime. {deleted_contribs.deleted_count} contribution(s) supprimee(s).")
        else:
            print("Projet non trouve.")

    def afficher_projets(self):
        """Afficher tous les projets avec total des contributions et moyenne."""
        pipeline = [
            {
                "$lookup": {
                    "from": "contributions",
                    "localField": "titre",
                    "foreignField": "projet_titre",
                    "as": "contributions",
                }
            },
            {
                "$addFields": {
                    "total_contributions": {"$sum": "$contributions.montant"},
                    "nb_contributions": {"$size": "$contributions"},
                    "nb_evaluations": {"$size": {"$ifNull": ["$evaluations", []]}},
                    "note_moyenne": {"$avg": "$evaluations.note"},
                }
            },
            {"$sort": {"date_lancement": -1}},
        ]

        found = False
        for projet in self.projets.aggregate(pipeline):
            found = True
            incubateur = projet.get("incubateur")
            print(f"\n- {projet.get('titre')}")
            print(f"  Type: {projet.get('type')}")
            print(f"  Objectif: {projet.get('objectif_financier')} EUR")
            print(f"  Total contributions: {projet.get('total_contributions', 0):.2f} EUR")
            print(f"  Nombre contributions: {projet.get('nb_contributions', 0)}")
            print(f"  Incubateur: {incubateur.get('nom_incubateur') if incubateur else 'N/A'}")
            if projet.get("note_moyenne") is None:
                print("  Aucune evaluation")
            else:
                print(f"  Note moyenne: {projet['note_moyenne']:.2f}/5 ({projet['nb_evaluations']} evaluation(s))")

        if not found:
            print("Aucun projet.")

    # ===== COLLECTIONS =====

    def menu_afficher_collections(self):
        """Afficher un apercu des collections MongoDB."""
        print("\n--- APERCU MONGODB ---")
        print(f"Base: {MONGO_CONFIG['database']}")
        print(f"Collection personnes: {self.personnes.count_documents({})} document(s)")
        print(f"Collection projets: {self.projets.count_documents({})} document(s)")
        print(f"Collection contributions: {self.contributions.count_documents({})} document(s)")
        print(f"Utilisateurs: {self.personnes.count_documents({'type_personne': 'utilisateur'})}")
        print(f"Membres equipe: {self.personnes.count_documents({'type_personne': 'membre_equipe'})}")

    # ===== REQUETES COMPLEXES =====

    def menu_requetes_complexes(self):
        """Menu des trois requetes demandees."""
        while True:
            print("\n" + "-" * 50)
            print("REQUETES COMPLEXES MONGODB")
            print("-" * 50)
            print("RQ1. Projets artistiques Kojima + Shinkawa avec objectif depasse")
            print("RQ2. Moyenne des notes des projets sociaux Amnesty avec contribution > 50")
            print("RQ3. Utilisateurs distincts avec contrepartie Chronopost par projet incube")
            print("4. Retour")
            print("-" * 50)

            choix = input("Votre choix (RQ1-RQ3 ou 4): ").strip().upper()
            if choix == "RQ1":
                self.rq1_projets_artistiques()
            elif choix == "RQ2":
                self.rq2_moyenne_projets_sociaux()
            elif choix == "RQ3":
                self.rq3_utilisateurs_chronopost()
            elif choix == "4":
                break
            else:
                print("Choix invalide.")

    def rq1_projets_artistiques(self):
        """Projets artistiques avec Hideo Kojima et Yoji Shinkawa, objectif depasse."""
        pipeline = [
            {"$match": {"type": "artistique"}},
            {
                "$lookup": {
                    "from": "personnes",
                    "localField": "membres.id_personne",
                    "foreignField": "id_personne",
                    "as": "membres_details",
                }
            },
            {
                "$lookup": {
                    "from": "contributions",
                    "localField": "titre",
                    "foreignField": "projet_titre",
                    "as": "contributions",
                }
            },
            {
                "$addFields": {
                    "total_contributions": {"$sum": "$contributions.montant"},
                    "membres_cles": {
                        "$setIntersection": [
                            {
                                "$map": {
                                    "input": "$membres_details",
                                    "as": "m",
                                    "in": {"$concat": ["$$m.prenom", " ", "$$m.nom"]},
                                }
                            },
                            ["Hideo Kojima", "Yoji Shinkawa"],
                        ]
                    },
                }
            },
            {
                "$match": {
                    "$expr": {
                        "$and": [
                            {"$gt": ["$total_contributions", "$objectif_financier"]},
                            {"$eq": [{"$size": "$membres_cles"}, 2]},
                        ]
                    }
                }
            },
            {
                "$project": {
                    "_id": 0,
                    "titre": 1,
                    "medium": 1,
                    "objectif_financier": 1,
                    "total_contributions": 1,
                }
            },
            {"$sort": {"total_contributions": -1}},
        ]
        result = list(self.projets.aggregate(pipeline))
        if not result:
            print("Aucun resultat.")
            return

        print(f"\n{'Titre':<30} {'Medium':<25} {'Objectif':<12} {'Total':<12}")
        print("-" * 85)
        for projet in result:
            print(
                f"{projet.get('titre', ''):<30} "
                f"{projet.get('medium', ''):<25} "
                f"{projet.get('objectif_financier', 0):<12.2f} "
                f"{projet.get('total_contributions', 0):<12.2f}"
            )

    def rq2_moyenne_projets_sociaux(self):
        """Moyenne des notes des projets sociaux Amnesty, contributeurs > 50 EUR."""
        pipeline = [
            {"$match": {"type": "social", "ong.nom_ONG": "Amnesty International"}},
            {
                "$lookup": {
                    "from": "contributions",
                    "localField": "titre",
                    "foreignField": "projet_titre",
                    "as": "contributions",
                }
            },
            {
                "$project": {
                    "evaluations": 1,
                    "gros_contributeurs": {
                        "$map": {
                            "input": {
                                "$filter": {
                                    "input": "$contributions",
                                    "as": "c",
                                    "cond": {"$gt": ["$$c.montant", 50]},
                                }
                            },
                            "as": "c",
                            "in": "$$c.utilisateur_id",
                        }
                    },
                }
            },
            {"$unwind": "$evaluations"},
            {"$match": {"$expr": {"$in": ["$evaluations.utilisateur_id", "$gros_contributeurs"]}}},
            {
                "$group": {
                    "_id": None,
                    "moyenne_notes": {"$avg": "$evaluations.note"},
                    "nb_evaluations": {"$sum": 1},
                }
            },
        ]
        result = list(self.projets.aggregate(pipeline))
        if not result:
            print("Aucun resultat.")
            return

        row = result[0]
        print(f"Moyenne des notes: {row['moyenne_notes']:.2f}/5")
        print(f"Nombre d'evaluations prises en compte: {row['nb_evaluations']}")

    def rq3_utilisateurs_chronopost(self):
        """Utilisateurs distincts avec au moins une contrepartie physique Chronopost."""
        pipeline = [
            {"$match": {"incubateur": {"$ne": None}}},
            {
                "$lookup": {
                    "from": "contributions",
                    "localField": "titre",
                    "foreignField": "projet_titre",
                    "as": "contributions",
                }
            },
            {"$unwind": "$contributions"},
            {
                "$match": {
                    "contributions.contrepartie.type": "physique",
                    "contributions.contrepartie.transporteur.nom": "Chronopost",
                }
            },
            {
                "$group": {
                    "_id": {
                        "titre": "$titre",
                        "incubateur": "$incubateur.nom_incubateur",
                    },
                    "utilisateurs": {"$addToSet": "$contributions.utilisateur_id"},
                }
            },
            {
                "$project": {
                    "_id": 0,
                    "titre": "$_id.titre",
                    "incubateur": "$_id.incubateur",
                    "nb_utilisateurs": {"$size": "$utilisateurs"},
                }
            },
            {"$sort": {"nb_utilisateurs": -1, "titre": 1}},
        ]
        result = list(self.projets.aggregate(pipeline))
        if not result:
            print("Aucun resultat.")
            return

        print(f"\n{'Projet':<30} {'Incubateur':<25} {'Utilisateurs':<12}")
        print("-" * 75)
        for row in result:
            print(f"{row['titre']:<30} {row['incubateur']:<25} {row['nb_utilisateurs']:<12}")

    # ===== LANCEMENT =====

    def run(self):
        """Lancer l'application."""
        if not self.connect_db():
            print("Impossible de demarrer l'application.")
            return

        try:
            self.menu_principal()
        except KeyboardInterrupt:
            print("\nApplication interrompue.")
        finally:
            self.close_db()


def main():
    app = CrowdFundrMongoApp()
    app.run()


if __name__ == "__main__":
    main()
