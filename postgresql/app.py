#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CrowdFundr Application
Application de gestion du crowdfunding avec deux profils utilisateurs :
- Utilisateur : Contribuer, évaluer, modifier ses données
- Administrateur : Gérer utilisateurs et projets
"""

import psycopg2
from psycopg2 import sql, Error
from datetime import datetime
import hmac
import os
import sys

# ===== CONFIGURATION =====
# Credentials are read from environment variables (or a local .env file).
# See .env.example at the root of the repository.
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:  # python-dotenv is optional
    pass

DB_CONFIG = {
    'host': os.getenv('PGHOST', 'localhost'),
    'port': os.getenv('PGPORT', '5432'),
    'dbname': os.getenv('PGDATABASE', 'crowdfundr'),
    'user': os.getenv('PGUSER', 'postgres'),
    'password': os.getenv('PGPASSWORD', ''),
}

# No default: admin access stays disabled until a password is configured.
ADMIN_PASSWORD = os.getenv('CROWDFUNDR_ADMIN_PASSWORD')


class CrowdFundrApp:
    """Classe principale pour la gestion de l'application CrowdFundr"""
    
    def __init__(self):
        """Initialiser la connexion à la base de données"""
        self.conn = None
        self.cursor = None
        self.user_id = None
        self.is_admin = False
    
    def connect_db(self):
        """Établir la connexion à PostgreSQL"""
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor()
            print("✓ Connexion à PostgreSQL réussie!\n")
            return True
        except Error as e:
            print(f"✗ Erreur de connexion: {e}")
            return False
    
    def close_db(self):
        """Fermer la connexion à la base de données"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        print("\n✓ Connexion fermée.")
    
    def execute_query(self, query, params=None, fetch=False):
        """Exécuter une requête SQL"""
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            
            if fetch:
                result = self.cursor.fetchall()
                return result
            else:
                self.conn.commit()
                return True
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur SQL: {e}")
            return None
    
    # ===== MENUS PRINCIPAUX =====
    
    def menu_principal(self):
        """Afficher le menu principal"""
        while True:
            print("\n" + "="*50)
            print("     CROWDFUNDR - MENU PRINCIPAL")
            print("="*50)
            print("1. Utilisateur Normal")
            print("2. Administrateur")
            print("3. Quitter")
            print("="*50)
            
            choice = input("Votre choix (1-3): ").strip()
            
            if choice == '1':
                self.menu_utilisateur()
            elif choice == '2':
                if self.authentifier_admin():
                    self.menu_admin()
            elif choice == '3':
                print("\nMerci d'avoir utilisé CrowdFundr!")
                break
            else:
                print("✗ Choix invalide!")
    
    def authentifier_admin(self):
        """Authentifier l'administrateur (simple vérification)"""
        if not ADMIN_PASSWORD:
            print("✗ Accès admin désactivé : définissez CROWDFUNDR_ADMIN_PASSWORD (voir .env.example).")
            return False
        password = input("\nMot de passe administrateur: ")
        if hmac.compare_digest(password, ADMIN_PASSWORD):
            self.is_admin = True
            print("✓ Authentification réussie!")
            return True
        else:
            print("✗ Mot de passe incorrect!")
            return False
    
    def menu_utilisateur(self):
        """Menu pour utilisateur normal   """
        while True:
            print("\n" + "="*50)
            print("     MENU UTILISATEUR")
            print("="*50)
            print("1. Se connecter / Créer un compte")
            print("2. Ajouter une contribution")
            print("3. Évaluer un projet")
            print("4. Afficher tous les projets")
            print("5. Voir mes contributions")
            print("6. Retour au menu principal")
            print("="*50)
            
            choice = input("Votre choix (1-6): ").strip()
            
            if choice == '1':
                self.gerer_compte_utilisateur()
            elif choice == '2' and self.user_id:
                self.ajouter_contribution()
            elif choice == '3' and self.user_id:
                self.evaluer_projet()
            elif choice == '4':
                self.afficher_projets()
            elif choice == '5' and self.user_id:
                self.voir_mes_contributions()
            elif choice == '6':
                break
            else: 
                if not self.user_id and choice in ['2', '3', '5']:
                    print("✗ Veuillez d'abord vous connecter!")
                else:
                    print("✗ Choix invalide!")
    
    def menu_admin(self):
        """Menu pour administrateur"""
        while True:
            print("\n" + "="*50)
            print("     MENU ADMINISTRATEUR")
            print("="*50)
            print("1. Gérer les utilisateurs")
            print("2. Gérer les projets")
            print("3. Afficher les tables")
            print("4. Exécuter les requêtes complexes")
            print("5. Retour au menu principal")
            print("="*50)
            
            choice = input("Votre choix (1-5): ").strip()
            
            if choice == '1':
                self.menu_gerer_utilisateurs()
            elif choice == '2':
                self.menu_gerer_projets()
            elif choice == '3':
                self.menu_afficher_tables()
            elif choice == '4':
                self.menu_requetes_complexes()
            elif choice == '5':
                self.is_admin = False
                break
            else:
                print("✗ Choix invalide!")
    
    # ===== GESTION UTILISATEURS (NORMAL) =====
    
    def gerer_compte_utilisateur(self):
        """Gérer la connexion ou création de compte utilisateur"""
        print("\n" + "-"*50)
        print("1. Se connecter")
        print("2. Créer un nouveau compte")
        print("-"*50)
        
        choice = input("Votre choix (1-2): ").strip()
        
        if choice == '1':
            self.connecter_utilisateur()
        elif choice == '2':
            self.creer_compte_utilisateur()
        else:
            print("✗ Choix invalide!")
    
    def connecter_utilisateur(self):
        """Connecter un utilisateur existant"""
        pseudo = input("\nPseudo: ").strip()
        
        query = """
        SELECT id_personne, pseudo, adresse_mail, nom
        FROM Utilisateur
        WHERE pseudo = %s
        """
        result = self.execute_query(query, (pseudo,), fetch=True)
        
        if result:
            self.user_id = result[0][0]
            print(f"✓ Connexion réussie! Bienvenue {result[0][3]}!")
        else:
            print("✗ Utilisateur non trouvé!")
    
    def creer_compte_utilisateur(self):
        """Créer un nouveau compte utilisateur"""
        print("\n--- Création de compte ---")
        pseudo = input("Pseudo: ").strip()
        email = input("Email: ").strip()
        nom = input("Nom: ").strip()
        date_naissance = input("Date de naissance (YYYY-MM-DD): ").strip()
        
        query = """
        INSERT INTO Utilisateur (pseudo, adresse_mail, nom, date_naissance)
        VALUES (%s, %s, %s, %s)
        RETURNING id_personne
        """
        
        try:
            self.cursor.execute(query, (pseudo, email, nom, date_naissance))
            user_id = self.cursor.fetchone()[0]
            self.conn.commit()
            self.user_id = user_id
            print(f"✓ Compte créé avec succès! ID: {user_id}")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    # ===== CONTRIBUTIONS (UTILISATEUR ) =====
    
    def ajouter_contribution(self):
        """Ajouter une contribution pour un projet"""
        print("\n--- Ajouter une contribution ---")
        
        # Afficher les projets disponibles
        query = "SELECT titre, objectif_financier FROM Projet LIMIT 10"
        projets = self.execute_query(query, fetch=True)
        
        if not projets:
            print("✗ Aucun projet disponible!")
            return
        
        print("\nProjets disponibles:")
        for i, (titre, objectif) in enumerate(projets, 1):
            print(f"{i}. {titre} (Objectif: {objectif}€)")
        
        choice = input("\nChoisir le numéro du projet: ").strip()
        
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(projets):
                projet = projets[idx][0]
            else:
                print("✗ Choix invalide!")
                return
        except ValueError:
            print("✗ Entrée invalide!")
            return
        
        try:
            montant = float(input("Montant de la contribution (€): "))
            if montant <= 0:
                print("✗ Le montant doit être positif!")
                return
        except ValueError:
            print("✗ Montant invalide!")
            return
        
        query = """
        INSERT INTO Contribution (date_heure, utilisateur, projet, montant)
        VALUES (%s, %s, %s, %s)
        """
        
        try:
            self.cursor.execute(query, (datetime.now(), self.user_id, projet, montant))
            self.conn.commit()
            print(f"✓ Contribution de {montant}€ enregistrée!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def evaluer_projet(self):
        """Évaluer un projet (vérifier qu'on a contribué)"""
        print("\n--- Évaluer un projet ---")
        
        # Afficher les projets auxquels l'utilisateur a contribué
        query = """
        SELECT DISTINCT p.titre
        FROM Projet p
        JOIN Contribution c ON p.titre = c.projet
        WHERE c.utilisateur = %s
        """
        projets = self.execute_query(query, (self.user_id,), fetch=True)
        
        if not projets:
            print("✗ Vous n'avez contribué à aucun projet!")
            return
        
        print("\nProjets auxquels vous avez contribué:")
        for i, (titre,) in enumerate(projets, 1):
            print(f"{i}. {titre}")
        
        choice = input("\nChoisir le numéro du projet: ").strip()
        
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(projets):
                projet = projets[idx][0]
            else:
                print("✗ Choix invalide!")
                return
        except ValueError:
            print("✗ Entrée invalide!")
            return
        
        try:
            note = int(input("Note (1-5): "))
            if not 1 <= note <= 5:
                print("✗ La note doit être entre 1 et 5!")
                return
        except ValueError:
            print("✗ Note invalide!")
            return
        
        avis = input("Avis (optionnel, Entrée pour passer): ").strip() or None
        
        query = """
        INSERT INTO Evaluer (projet, utilisateur, note, avis_text, date_avis)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (projet, utilisateur) DO UPDATE
        SET note = %s, avis_text = %s, date_avis = %s
        """
        
        try:
            today = datetime.now().date()
            self.cursor.execute(query, (projet, self.user_id, note, avis, today, note, avis, today))
            self.conn.commit()
            print("✓ Évaluation enregistrée!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def afficher_projets(self):
        """Afficher tous les projets avec leurs notes"""
        print("\n--- Tous les projets ---")
        query = """
        SELECT p.titre, p.description, p.objectif_financier, p.date_lancement,
               COALESCE(AVG(e.note), 0) as note_moyenne, COUNT(e.utilisateur) as nb_evaluations
        FROM Projet p
        LEFT JOIN Evaluer e ON p.titre = e.projet
        GROUP BY p.titre, p.description, p.objectif_financier, p.date_lancement
        ORDER BY p.date_lancement DESC
        """
        
        projets = self.execute_query(query, fetch=True)
        
        if projets:
            for titre, description, objectif, date_lancement, note_moyenne, nb_evaluations in projets:
                print(f"\n• {titre}")
                print(f"  Description: {description}")
                print(f"  Objectif: {objectif}€")
                print(f"  Lancé le: {date_lancement}")
                if nb_evaluations > 0:
                    print(f"   Note: {note_moyenne:.2f}/5 ({nb_evaluations} évaluations)")
                else:
                    print(f"   Aucune évaluation")
        else:
            print("✗ Aucun projet trouvé!")
    
    def voir_mes_contributions(self):
        """Afficher les contributions de l'utilisateur"""
        print("\n--- Mes contributions ---")
        query = """
        SELECT projet, montant, date_heure
        FROM Contribution
        WHERE utilisateur = %s
        ORDER BY date_heure DESC
        """
        
        contributions = self.execute_query(query, (self.user_id,), fetch=True)
        
        if contributions:
            total = 0
            for projet, montant, date_heure in contributions:
                print(f"• {projet}: {montant}€ ({date_heure})")
                total += float(montant)
            print(f"\nTotal: {total}€")
        else:
            print("✗ Vous n'avez aucune contribution!")
    
    # ===== GESTION UTILISATEURS (ADMIN) =====
    
    def menu_gerer_utilisateurs(self):
        """Menu pour gérer les utilisateurs"""
        while True:
            print("\n" + "-"*50)
            print("GESTION DES UTILISATEURS")
            print("-"*50)
            print("1. Ajouter un utilisateur")
            print("2. Modifier un utilisateur")
            print("3. Supprimer un utilisateur")
            print("4. Afficher tous les utilisateurs")
            print("5. Retour")
            print("-"*50)
            
            choice = input("Votre choix (1-5): ").strip()
            
            if choice == '1':
                self.admin_ajouter_utilisateur()
            elif choice == '2':
                self.admin_modifier_utilisateur()
            elif choice == '3':
                self.admin_supprimer_utilisateur()
            elif choice == '4':
                self.admin_afficher_utilisateurs()
            elif choice == '5':
                break
            else:
                print("✗ Choix invalide!")
    
    def admin_ajouter_utilisateur(self):
        """Admin : Ajouter un utilisateur"""
        print("\n--- Ajouter un utilisateur ---")
        pseudo = input("Pseudo: ").strip()
        email = input("Email: ").strip()
        nom = input("Nom: ").strip()
        date_naissance = input("Date de naissance (YYYY-MM-DD): ").strip()
        
        query = """
        INSERT INTO Utilisateur (pseudo, adresse_mail, nom, date_naissance)
        VALUES (%s, %s, %s, %s)
        RETURNING id_personne
        """
        
        try:
            self.cursor.execute(query, (pseudo, email, nom, date_naissance))
            user_id = self.cursor.fetchone()[0]
            self.conn.commit()
            print(f"✓ Utilisateur créé! ID: {user_id}")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_modifier_utilisateur(self):
        """Admin : Modifier un utilisateur"""
        print("\n--- Modifier un utilisateur ---")
        
        user_id = input("ID de l'utilisateur: ").strip()
        
        print("\n1. Modifier le pseudo")
        print("2. Modifier l'email")
        print("3. Modifier le nom")
        print("4. Modifier la date de naissance")
        
        choice = input("Votre choix (1-4): ").strip()
        
        if choice == '1':
            new_value = input("Nouveau pseudo: ").strip()
            query = "UPDATE Utilisateur SET pseudo = %s WHERE id_personne = %s"
        elif choice == '2':
            new_value = input("Nouvel email: ").strip()
            query = "UPDATE Utilisateur SET adresse_mail = %s WHERE id_personne = %s"
        elif choice == '3':
            new_value = input("Nouveau nom: ").strip()
            query = "UPDATE Utilisateur SET nom = %s WHERE id_personne = %s"
        elif choice == '4':
            new_value = input("Nouvelle date (YYYY-MM-DD): ").strip()
            query = "UPDATE Utilisateur SET date_naissance = %s WHERE id_personne = %s"
        else:
            print("✗ Choix invalide!")
            return
        
        try:
            self.cursor.execute(query, (new_value, user_id))
            self.conn.commit()
            if self.cursor.rowcount > 0:
                print("✓ Utilisateur modifié!")
            else:
                print("✗ Utilisateur non trouvé!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_supprimer_utilisateur(self):
        """Admin : Supprimer un utilisateur"""
        print("\n--- Supprimer un utilisateur ---")
        
        user_id = input("ID de l'utilisateur: ").strip()
        
        # Confirmation
        confirmation = input("Êtes-vous sûr? (oui/non): ").strip().lower()
        if confirmation != 'oui':
            print("Suppression annulée.")
            return
        
        try:
            # Supprimer les contributions d'abord
            query = "DELETE FROM Evaluer WHERE utilisateur = %s"
            self.cursor.execute(query, (user_id,))
            
            query = "DELETE FROM Contribution WHERE utilisateur = %s"
            self.cursor.execute(query, (user_id,))
            
            # Supprimer l'utilisateur
            query = "DELETE FROM Utilisateur WHERE id_personne = %s"
            self.cursor.execute(query, (user_id,))
            
            self.conn.commit()
            
            if self.cursor.rowcount > 0:
                print("✓ Utilisateur supprimé!")
            else:
                print("✗ Utilisateur non trouvé!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_afficher_utilisateurs(self):
        """Admin : Afficher tous les utilisateurs"""
        print("\n--- Tous les utilisateurs ---")
        query = """
        SELECT id_personne, pseudo, adresse_mail, nom, date_naissance
        FROM Utilisateur
        ORDER BY id_personne
        """
        
        utilisateurs = self.execute_query(query, fetch=True)
        
        if utilisateurs:
            print(f"\n{'ID':<5} {'Pseudo':<20} {'Email':<30} {'Nom':<20} {'Date Naiss.':<15}")
            print("-" * 90)
            for user_id, pseudo, email, nom, date_naiss in utilisateurs:
                print(f"{user_id:<5} {pseudo:<20} {email:<30} {nom:<20} {date_naiss}")
        else:
            print("✗ Aucun utilisateur!")
    
    # ===== GESTION PROJETS (ADMIN) =====
    
    def menu_gerer_projets(self):
        """Menu pour gérer les projets"""
        while True:
            print("\n" + "-"*50)
            print("GESTION DES PROJETS")
            print("-"*50)
            print("1. Ajouter un projet")
            print("2. Modifier un projet")
            print("3. Supprimer un projet")
            print("4. Afficher tous les projets")
            print("5. Retour")
            print("-"*50)
            
            choice = input("Votre choix (1-5): ").strip()
            
            if choice == '1':
                self.admin_ajouter_projet()
            elif choice == '2':
                self.admin_modifier_projet()
            elif choice == '3':
                self.admin_supprimer_projet()
            elif choice == '4':
                self.admin_afficher_projets()
            elif choice == '5':
                break
            else:
                print("✗ Choix invalide!")
    
    def admin_ajouter_projet(self):
        """Admin : Ajouter un projet"""
        print("\n--- Ajouter un projet ---")
        titre = input("Titre du projet: ").strip()
        description = input("Description: ").strip()
        try:
            objectif = float(input("Objectif financier (€): "))
            if objectif <= 0:
                print("✗ L'objectif doit être positif!")
                return
        except ValueError:
            print("✗ Objectif invalide!")
            return
        
        date_lancement = input("Date de lancement (YYYY-MM-DD): ").strip()
        incubateur = input("Incubateur (optionnel, Entrée pour passer): ").strip() or None
        
        query = """
        INSERT INTO Projet (titre, description, objectif_financier, date_lancement, incubateur)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING titre
        """
        
        try:
            self.cursor.execute(query, (titre, description, objectif, date_lancement, incubateur))
            self.conn.commit()
            print(f"✓ Projet '{titre}' créé avec succès!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_modifier_projet(self):
        """Admin : Modifier un projet"""
        print("\n--- Modifier un projet ---")
        
        titre = input("Titre du projet à modifier: ").strip()
        
        print("\n1. Modifier la description")
        print("2. Modifier l'objectif financier")
        print("3. Modifier la date de lancement")
        print("4. Modifier l'incubateur")
        
        choice = input("Votre choix (1-4): ").strip()
        
        if choice == '1':
            new_value = input("Nouvelle description: ").strip()
            query = "UPDATE Projet SET description = %s WHERE titre = %s"
        elif choice == '2':
            try:
                new_value = float(input("Nouvel objectif (€): "))
                if new_value <= 0:
                    print("✗ L'objectif doit être positif!")
                    return
            except ValueError:
                print("✗ Objectif invalide!")
                return
            query = "UPDATE Projet SET objectif_financier = %s WHERE titre = %s"
        elif choice == '3':
            new_value = input("Nouvelle date (YYYY-MM-DD): ").strip()
            query = "UPDATE Projet SET date_lancement = %s WHERE titre = %s"
        elif choice == '4':
            new_value = input("Nouvel incubateur (optionnel, Entrée pour NULL): ").strip() or None
            query = "UPDATE Projet SET incubateur = %s WHERE titre = %s"
        else:
            print("✗ Choix invalide!")
            return
        
        try:
            self.cursor.execute(query, (new_value, titre))
            self.conn.commit()
            if self.cursor.rowcount > 0:
                print("✓ Projet modifié!")
            else:
                print("✗ Projet non trouvé!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_supprimer_projet(self):
        """Admin : Supprimer un projet"""
        print("\n--- Supprimer un projet ---")
        
        titre = input("Titre du projet à supprimer: ").strip()
        
        # Confirmation
        confirmation = input("Êtes-vous sûr? (oui/non): ").strip().lower()
        if confirmation != 'oui':
            print("Suppression annulée.")
            return
        
        try:
            # Supprimer les dépendances d'abord
            query = "DELETE FROM Evaluer WHERE projet = %s"
            self.cursor.execute(query, (titre,))
            
            query = "DELETE FROM Contribution WHERE projet = %s"
            self.cursor.execute(query, (titre,))
            
            query = "DELETE FROM PorterPar WHERE projet = %s"
            self.cursor.execute(query, (titre,))
            
            query = "DELETE FROM SoutenuPar WHERE projet = %s"
            self.cursor.execute(query, (titre,))
            
            # Supprimer les projets spécialisés
            query = "DELETE FROM Projet_technologique WHERE titre = %s"
            self.cursor.execute(query, (titre,))
            
            query = "DELETE FROM Projet_artistique WHERE titre = %s"
            self.cursor.execute(query, (titre,))
            
            query = "DELETE FROM Projet_social WHERE titre = %s"
            self.cursor.execute(query, (titre,))
            
            # Supprimer le projet
            query = "DELETE FROM Projet WHERE titre = %s"
            self.cursor.execute(query, (titre,))
            
            self.conn.commit()
            
            if self.cursor.rowcount > 0:
                print("✓ Projet supprimé!")
            else:
                print("✗ Projet non trouvé!")
        except Error as e:
            self.conn.rollback()
            print(f"✗ Erreur: {e}")
    
    def admin_afficher_projets(self):
        """Admin : Afficher tous les projets"""
        print("\n--- Tous les projets ---")
        query = """
        SELECT titre, description, objectif_financier, date_lancement, incubateur
        FROM Projet
        ORDER BY date_lancement DESC
        """
        
        projets = self.execute_query(query, fetch=True)
        
        if projets:
            print(f"\n{'Titre':<30} {'Objectif':<15} {'Date':<15} {'Incubateur':<25}")
            print("-" * 85)
            for titre, description, objectif, date_lancement, incubateur in projets:
                inc_str = incubateur if incubateur else "N/A"
                print(f"{titre:<30} {objectif:<15.2f}€ {date_lancement:<15} {inc_str:<25}")
        else:
            print("✗ Aucun projet!")
    
    # ===== AFFICHAGE TABLES (ADMIN) =====
    
    def menu_afficher_tables(self):
        """Menu pour afficher les tables"""
        while True:
            print("\n" + "-"*50)
            print("AFFICHAGE DES TABLES")
            print("-"*50)
            print("1. Table Utilisateur")
            print("2. Table Projet")
            print("3. Table MembreEquipe")
            print("4. Table Contribution")
            print("5. Table ONG")
            print("6. Toutes les tables")
            print("7. Retour")
            print("-"*50)
            
            choice = input("Votre choix (1-7): ").strip()
            
            if choice == '1':
                self.afficher_table_utilisateur()
            elif choice == '2':
                self.afficher_table_projet()
            elif choice == '3':
                self.afficher_table_membreequipe()
            elif choice == '4':
                self.afficher_table_contribution()
            elif choice == '5':
                self.afficher_table_ong()
            elif choice == '6':
                self.afficher_toutes_tables()
            elif choice == '7':
                break
            else:
                print("✗ Choix invalide!")
    
    def afficher_table_utilisateur(self):
        """Afficher la table Utilisateur"""
        print("\n--- Table UTILISATEUR ---")
        query = "SELECT id_personne, pseudo, adresse_mail, nom FROM Utilisateur LIMIT 20"
        result = self.execute_query(query, fetch=True)
        self._afficher_resultat(result, ["ID", "Pseudo", "Email", "Nom"])
    
    def afficher_table_projet(self):
        """Afficher la table Projet"""
        print("\n--- Table PROJET ---")
        query = "SELECT titre, description, objectif_financier, date_lancement FROM Projet LIMIT 20"
        result = self.execute_query(query, fetch=True)
        self._afficher_resultat(result, ["Titre", "Description", "Objectif", "Date"])
    
    def afficher_table_membreequipe(self):
        """Afficher la table MembreEquipe"""
        print("\n--- Table MEMBREEQUIPE ---")
        query = "SELECT id_personne, nom, prenom, pays_residence FROM MembreEquipe LIMIT 20"
        result = self.execute_query(query, fetch=True)
        self._afficher_resultat(result, ["ID", "Nom", "Prénom", "Pays"])
    
    def afficher_table_contribution(self):
        """Afficher la table Contribution"""
        print("\n--- Table CONTRIBUTION ---")
        query = """
        SELECT utilisateur, projet, montant, date_heure
        FROM Contribution
        ORDER BY date_heure DESC
        LIMIT 20
        """
        result = self.execute_query(query, fetch=True)
        self._afficher_resultat(result, ["Utilisateur", "Projet", "Montant", "Date/Heure"])
    
    def afficher_table_ong(self):
        """Afficher la table ONG"""
        print("\n--- Table ONG ---")
        query = "SELECT num_ong, nom_ong, pays FROM ONG LIMIT 20"
        result = self.execute_query(query, fetch=True)
        self._afficher_resultat(result, ["ID", "Nom", "Pays"])
    
    def afficher_toutes_tables(self):
        """Afficher un aperçu de toutes les tables"""
        print("\n--- APERÇU DE TOUTES LES TABLES ---")
        tables = [
            ("Utilisateur", "SELECT COUNT(*) FROM Utilisateur"),
            ("Projet", "SELECT COUNT(*) FROM Projet"),
            ("MembreEquipe", "SELECT COUNT(*) FROM MembreEquipe"),
            ("Contribution", "SELECT COUNT(*) FROM Contribution"),
            ("ONG", "SELECT COUNT(*) FROM ONG"),
            ("Contrepartie", "SELECT COUNT(*) FROM Contrepartie"),
            ("Evaluer", "SELECT COUNT(*) FROM Evaluer")
        ]
        
        for table_name, count_query in tables:
            result = self.execute_query(count_query, fetch=True)
            count = result[0][0] if result else 0
            print(f"• {table_name}: {count} enregistrements")
    
    def _afficher_resultat(self, result, headers):
        """Afficher un résultat formaté"""
        if result:
            # Afficher les en-têtes
            header_str = " | ".join(f"{h:<20}" for h in headers)
            print(header_str)
            print("-" * len(header_str))
            
            # Afficher les données
            for row in result:
                row_str = " | ".join(f"{str(cell):<20}" for cell in row)
                print(row_str)
        else:
            print("✗ Aucun résultat!")
    
    # ===== REQUÊTES COMPLEXES (ADMIN) =====
    
    def menu_requetes_complexes(self):
        """Menu pour les requêtes complexes"""
        while True:
            print("\n" + "-"*50)
            print("REQUÊTES COMPLEXES")
            print("-"*50)
            print("RQ1: Projets artistiques avec membres spécifiques")
            print("RQ2: Moyenne des notes des projets sociaux")
            print("RQ3: Utilisateurs avec contrepartie physique par incubateur")
            print("4. Retour")
            print("-"*50)
            
            choice = input("Votre choix (RQ1-RQ3 ou 4): ").strip().upper()
            
            if choice == 'RQ1':
                self.rq1_projets_artistiques()
            elif choice == 'RQ2':
                self.rq2_moyenne_projets_sociaux()
            elif choice == 'RQ3':
                self.rq3_utilisateurs_contrepartie()
            elif choice == '4':
                break
            else:
                print("✗ Choix invalide!")
    
    def rq1_projets_artistiques(self):
        """
        RQ1 : Projets artistiques portés À LA FOIS par Hideo Kojima et Yoji Shinkawa
        et ayant dépassé leur objectif financier (somme des contributions > objectif).
        """
        print("\n--- RQ1: Projets artistiques (Kojima ET Shinkawa) ayant dépassé l'objectif ---")

        # Les contributions sont totalisées dans une sous-requête : joindre directement
        # PorterPar (une ligne par membre) dupliquerait chaque contribution dans la somme.
        query = """
        SELECT p.titre, p.description, p.objectif_financier, pa.medium, tot.total
        FROM Projet p
        JOIN Projet_artistique pa ON p.titre = pa.titre
        JOIN (
            SELECT projet, SUM(montant) AS total
            FROM Contribution
            GROUP BY projet
        ) tot ON tot.projet = p.titre
        WHERE tot.total > p.objectif_financier
          AND EXISTS (
              SELECT 1 FROM PorterPar pp
              JOIN MembreEquipe me ON me.id_personne = pp.membre
              WHERE pp.projet = p.titre AND me.nom = 'Kojima' AND me.prenom = 'Hideo')
          AND EXISTS (
              SELECT 1 FROM PorterPar pp
              JOIN MembreEquipe me ON me.id_personne = pp.membre
              WHERE pp.projet = p.titre AND me.nom = 'Shinkawa' AND me.prenom = 'Yoji')
        ORDER BY tot.total DESC
        """

        result = self.execute_query(query, fetch=True)

        if result:
            print(f"\n{'Titre':<30} {'Medium':<20} {'Objectif':<15} {'Total':<15}")
            print("-" * 80)
            for titre, description, objectif, medium, total in result:
                print(f"{titre:<30} {medium:<20} {objectif:<15.2f} {total:<15.2f}")
        else:
            print("✗ Aucun résultat pour cette requête!")

    def rq2_moyenne_projets_sociaux(self):
        """
        RQ2 : Moyenne des notes des projets sociaux soutenus par Amnesty International
        Seuls les contributeurs ayant donné plus de 50€
        """
        print("\n--- RQ2: Moyenne des notes des projets sociaux d'Amnesty (contributeurs > 50€) ---")
        
        query = """
        SELECT AVG(e.note) as moyenne_notes
        FROM Evaluer e
        JOIN Projet_social ps ON ps.titre = e.projet
        WHERE EXISTS (
            SELECT 1 FROM SoutenuPar sp
            JOIN ONG o ON sp.ong = o.num_ong
            WHERE sp.projet = ps.titre AND o.nom_ong = 'Amnesty International')
          AND EXISTS (
            SELECT 1 FROM Contribution c
            WHERE c.projet = e.projet AND c.utilisateur = e.utilisateur AND c.montant > 50)
        """
        
        result = self.execute_query(query, fetch=True)
        
        if result and result[0][0] is not None:
            moyenne = result[0][0]
            print(f"\n✓ Moyenne des notes: {moyenne:.2f}/5")
        else:
            print("✗ Aucun résultat pour cette requête!")
    
    def rq3_utilisateurs_contrepartie(self):
        """
        RQ3 : Par projet avec incubateur, nombre d'utilisateurs distincts ayant pris une contrepartie physique Chronopost
        """
        print("\n--- RQ3: Utilisateurs avec contrepartie Chronopost par projet (avec incubateur) ---")
        
        query = """
        SELECT p.titre, i.nom_incubateur, COUNT(DISTINCT c.utilisateur) as nb_utilisateurs
        FROM Projet p
        JOIN Incubateur i ON p.incubateur = i.nom_incubateur
        JOIN Contribution c ON p.titre = c.projet
        JOIN Contrepartie cp ON c.contrepartie = cp.id_contrepartie
        JOIN Contrepartie_physique cph ON cp.id_contrepartie = cph.id_contrepartie
        WHERE cph.transporteur = 'Chronopost'
        GROUP BY p.titre, i.nom_incubateur
        ORDER BY nb_utilisateurs DESC
        """
        
        result = self.execute_query(query, fetch=True)
        
        if result:
            print(f"\n{'Titre Projet':<40} {'Incubateur':<25} {'Nb Utilisateurs':<15}")
            print("-" * 80)
            for titre, incubateur, nb_users in result:
                print(f"{titre:<40} {incubateur:<25} {nb_users:<15}")
        else:
            print("✗ Aucun résultat pour cette requête!")
    
    # ===== APPLICATION PRINCIPALE =====
    
    def run(self):
        """Lancer l'application"""
        if self.connect_db():
            try:
                self.menu_principal()
            except KeyboardInterrupt:
                print("\n\nApplication interrompue.")
            finally:
                self.close_db()
        else:
            print("Impossible de démarrer l'application.")


def main():
    """Point d'entrée principal"""
    app = CrowdFundrApp()
    app.run()


if __name__ == "__main__":
    main()
