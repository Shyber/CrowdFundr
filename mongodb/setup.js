db = db.getSiblingDB("crowdfundr");

db.projets.drop();
db.contributions.drop();
db.personnes.drop();

db.personnes.createIndex({ id_personne: 1 }, { unique: true });
db.personnes.createIndex({ pseudo: 1 }, { unique: true, sparse: true });
db.projets.createIndex({ titre: 1 }, { unique: true });
db.contributions.createIndex({ date_heure: 1, utilisateur_id: 1, projet_titre: 1 }, { unique: true });
db.contributions.createIndex({ projet_titre: 1 });
db.contributions.createIndex({ utilisateur_id: 1 });

db.personnes.insertMany([
  {
    id_personne: 1,
    type_personne: "membre_equipe",
    nom: "Kojima",
    prenom: "Hideo",
    pays_residence: "Japon",
    date_naissance: ISODate("1963-08-24")
  },
  {
    id_personne: 2,
    type_personne: "membre_equipe",
    nom: "Shinkawa",
    prenom: "Yoji",
    pays_residence: "Japon",
    date_naissance: ISODate("1971-12-25")
  },
  {
    id_personne: 3,
    type_personne: "membre_equipe",
    nom: "Bernard",
    prenom: "Karim",
    pays_residence: "France",
    date_naissance: ISODate("1991-09-25")
  },
  {
    id_personne: 4,
    type_personne: "membre_equipe",
    nom: "Nguyen",
    prenom: "Lina",
    pays_residence: "France",
    date_naissance: ISODate("1996-06-08")
  },
  {
    id_personne: 5,
    type_personne: "membre_equipe",
    nom: "Martin",
    prenom: "Alice",
    pays_residence: "France",
    date_naissance: ISODate("1994-03-12")
  },
  {
    id_personne: 6,
    type_personne: "membre_equipe",
    nom: "Lopez",
    prenom: "Eva",
    pays_residence: "Espagne",
    date_naissance: ISODate("1992-11-22")
  },
  {
    id_personne: 101,
    type_personne: "utilisateur",
    pseudo: "solidSnake",
    adresse_mail: "solid.snake@example.com",
    nom: "Martin",
    date_naissance: ISODate("1995-03-18")
  },
  {
    id_personne: 102,
    type_personne: "utilisateur",
    pseudo: "foxhound",
    adresse_mail: "foxhound@example.com",
    nom: "Durand",
    date_naissance: ISODate("1992-07-09")
  },
  {
    id_personne: 103,
    type_personne: "utilisateur",
    pseudo: "inkFan",
    adresse_mail: "ink.fan@example.com",
    nom: "Petit",
    date_naissance: ISODate("1998-01-11")
  },
  {
    id_personne: 104,
    type_personne: "utilisateur",
    pseudo: "amina",
    adresse_mail: "amina@example.com",
    nom: "Moreau",
    date_naissance: ISODate("1990-05-19")
  },
  {
    id_personne: 105,
    type_personne: "utilisateur",
    pseudo: "leo",
    adresse_mail: "leo@example.com",
    nom: "Lambert",
    date_naissance: ISODate("1997-12-03")
  },
  {
    id_personne: 106,
    type_personne: "utilisateur",
    pseudo: "nora",
    adresse_mail: "nora@example.com",
    nom: "Roux",
    date_naissance: ISODate("1988-04-14")
  },
  {
    id_personne: 107,
    type_personne: "utilisateur",
    pseudo: "mila",
    adresse_mail: "mila@example.com",
    nom: "Faure",
    date_naissance: ISODate("1994-10-02")
  },
  {
    id_personne: 108,
    type_personne: "utilisateur",
    pseudo: "sami",
    adresse_mail: "sami@example.com",
    nom: "Benali",
    date_naissance: ISODate("1993-02-17")
  },
  {
    id_personne: 109,
    type_personne: "utilisateur",
    pseudo: "airwatch",
    adresse_mail: "airwatch@example.com",
    nom: "Garcia",
    date_naissance: ISODate("1991-01-09")
  },
  {
    id_personne: 110,
    type_personne: "utilisateur",
    pseudo: "dataCity",
    adresse_mail: "data.city@example.com",
    nom: "Simon",
    date_naissance: ISODate("1999-08-30")
  },
  {
    id_personne: 111,
    type_personne: "utilisateur",
    pseudo: "greenMap",
    adresse_mail: "green.map@example.com",
    nom: "Colin",
    date_naissance: ISODate("1996-09-15")
  }
]);

db.projets.insertMany([
  {
    titre: "Metal Gear Legacy",
    description: "Projet artistique autour d'une exposition interactive de concept arts et de narration visuelle.",
    type: "artistique",
    medium: "Installation interactive",
    objectif_financier: 10000,
    date_lancement: ISODate("2026-01-10"),
    incubateur: {
      nom_incubateur: "Creative Lab",
      annee_creation: 2015,
      budget: 300000
    },
    membres: [
      { id_personne: 1, role: "chef_projet" },
      { id_personne: 2, role: "designer" }
    ],
    ong: [],
    evaluations: [
      {
        utilisateur_id: 101,
        pseudo: "solidSnake",
        note: 5,
        avis_text: "Exposition ambitieuse et tres coherente.",
        date_avis: ISODate("2026-01-20")
      },
      {
        utilisateur_id: 102,
        pseudo: "foxhound",
        note: 4,
        avis_text: "Tres bon projet artistique.",
        date_avis: ISODate("2026-01-21")
      }
    ]
  },
  {
    titre: "Silent Sketches",
    description: "Recueil illustre et exposition temporaire autour du dessin narratif.",
    type: "artistique",
    medium: "Illustration",
    objectif_financier: 20000,
    date_lancement: ISODate("2026-02-01"),
    incubateur: {
      nom_incubateur: "Tokyo Art Hub",
      annee_creation: 2018,
      budget: 150000
    },
    membres: [
      { id_personne: 1, role: "chef_projet" },
      { id_personne: 2, role: "designer" }
    ],
    ong: [],
    evaluations: [
      {
        utilisateur_id: 103,
        pseudo: "inkFan",
        note: 4,
        avis_text: "Belle direction artistique.",
        date_avis: ISODate("2026-02-12")
      }
    ]
  },
  {
    titre: "Quartiers Solidaires",
    description: "Projet social de soutien alimentaire et culturel pour des familles en difficulte.",
    type: "social",
    region_cible: "Ile-de-France",
    objectif_financier: 5000,
    date_lancement: ISODate("2026-03-05"),
    incubateur: {
      nom_incubateur: "Impact Factory",
      annee_creation: 2019,
      budget: 220000
    },
    membres: [
      { id_personne: 3, role: "chef_projet" }
    ],
    ong: [
      {
        num_ONG: 501,
        nom_ONG: "Amnesty International",
        pays: "Royaume-Uni"
      }
    ],
    evaluations: [
      {
        utilisateur_id: 104,
        pseudo: "amina",
        note: 5,
        avis_text: "Tres utile pour le quartier.",
        date_avis: ISODate("2026-03-12")
      },
      {
        utilisateur_id: 105,
        pseudo: "leo",
        note: 2,
        avis_text: "Projet interessant mais contribution faible.",
        date_avis: ISODate("2026-03-13")
      },
      {
        utilisateur_id: 106,
        pseudo: "nora",
        note: 4,
        avis_text: "Bonne organisation.",
        date_avis: ISODate("2026-03-14")
      }
    ]
  },
  {
    titre: "Droits Pour Tous",
    description: "Projet social de sensibilisation aux droits humains dans les lycees.",
    type: "social",
    region_cible: "Hauts-de-France",
    objectif_financier: 8000,
    date_lancement: ISODate("2026-04-01"),
    incubateur: null,
    membres: [
      { id_personne: 4, role: "chef_projet" }
    ],
    ong: [
      {
        num_ONG: 501,
        nom_ONG: "Amnesty International",
        pays: "Royaume-Uni"
      }
    ],
    evaluations: [
      {
        utilisateur_id: 107,
        pseudo: "mila",
        note: 3,
        avis_text: "Projet important.",
        date_avis: ISODate("2026-04-07")
      },
      {
        utilisateur_id: 108,
        pseudo: "sami",
        note: 4,
        avis_text: "Bonne action educative.",
        date_avis: ISODate("2026-04-08")
      }
    ]
  },
  {
    titre: "Capteur EcoVille",
    description: "Projet technologique de capteurs urbains pour mesurer la qualite de l'air.",
    type: "technologique",
    type_innovation: "IoT environnemental",
    objectif_financier: 12000,
    date_lancement: ISODate("2026-05-01"),
    incubateur: {
      nom_incubateur: "Station Innovation",
      annee_creation: 2016,
      budget: 400000
    },
    membres: [
      { id_personne: 5, role: "chef_projet" },
      { id_personne: 6, role: "developpeur" }
    ],
    ong: [],
    evaluations: [
      {
        utilisateur_id: 109,
        pseudo: "airwatch",
        note: 5,
        avis_text: "Prototype convaincant.",
        date_avis: ISODate("2026-05-07")
      }
    ]
  }
]);

db.contributions.insertMany([
  {
    date_heure: ISODate("2026-01-12T10:00:00Z"),
    projet_titre: "Metal Gear Legacy",
    utilisateur_id: 101,
    montant: 6000,
    contrepartie: {
      id_contrepartie: 1001,
      type: "physique",
      poids: 0.5,
      frais_livraison: 8,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-01-13T14:30:00Z"),
    projet_titre: "Metal Gear Legacy",
    utilisateur_id: 102,
    montant: 5500,
    contrepartie: {
      id_contrepartie: 1002,
      type: "numerique",
      format_fichier: "PDF",
      taille: 18.4
    }
  },
  {
    date_heure: ISODate("2026-01-14T09:20:00Z"),
    projet_titre: "Metal Gear Legacy",
    utilisateur_id: 101,
    montant: 120,
    contrepartie: {
      id_contrepartie: 1003,
      type: "physique",
      poids: 0.8,
      frais_livraison: 9,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-02-02T11:00:00Z"),
    projet_titre: "Silent Sketches",
    utilisateur_id: 103,
    montant: 8000,
    contrepartie: {
      id_contrepartie: 1101,
      type: "physique",
      poids: 1.1,
      frais_livraison: 7,
      transporteur: {
        nom: "Colissimo",
        delai_livraison: 4
      }
    }
  },
  {
    date_heure: ISODate("2026-03-06T08:15:00Z"),
    projet_titre: "Quartiers Solidaires",
    utilisateur_id: 104,
    montant: 70,
    contrepartie: {
      id_contrepartie: 2001,
      type: "physique",
      poids: 0.4,
      frais_livraison: 5,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-03-07T10:40:00Z"),
    projet_titre: "Quartiers Solidaires",
    utilisateur_id: 105,
    montant: 30,
    contrepartie: {
      id_contrepartie: 2002,
      type: "numerique",
      format_fichier: "PDF",
      taille: 4.2
    }
  },
  {
    date_heure: ISODate("2026-03-08T16:30:00Z"),
    projet_titre: "Quartiers Solidaires",
    utilisateur_id: 106,
    montant: 120,
    contrepartie: {
      id_contrepartie: 2003,
      type: "physique",
      poids: 0.7,
      frais_livraison: 6,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-04-02T12:00:00Z"),
    projet_titre: "Droits Pour Tous",
    utilisateur_id: 107,
    montant: 100,
    contrepartie: {
      id_contrepartie: 2101,
      type: "numerique",
      format_fichier: "MP4",
      taille: 650
    }
  },
  {
    date_heure: ISODate("2026-04-03T13:45:00Z"),
    projet_titre: "Droits Pour Tous",
    utilisateur_id: 108,
    montant: 55,
    contrepartie: {
      id_contrepartie: 2102,
      type: "physique",
      poids: 0.3,
      frais_livraison: 4,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-05-02T09:00:00Z"),
    projet_titre: "Capteur EcoVille",
    utilisateur_id: 109,
    montant: 200,
    contrepartie: {
      id_contrepartie: 3001,
      type: "physique",
      poids: 0.9,
      frais_livraison: 7,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-05-03T10:10:00Z"),
    projet_titre: "Capteur EcoVille",
    utilisateur_id: 110,
    montant: 90,
    contrepartie: {
      id_contrepartie: 3002,
      type: "physique",
      poids: 0.6,
      frais_livraison: 6,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-05-04T11:20:00Z"),
    projet_titre: "Capteur EcoVille",
    utilisateur_id: 109,
    montant: 75,
    contrepartie: {
      id_contrepartie: 3003,
      type: "physique",
      poids: 0.5,
      frais_livraison: 5,
      transporteur: {
        nom: "Chronopost",
        delai_livraison: 2
      }
    }
  },
  {
    date_heure: ISODate("2026-05-05T15:00:00Z"),
    projet_titre: "Capteur EcoVille",
    utilisateur_id: 111,
    montant: 60,
    contrepartie: {
      id_contrepartie: 3004,
      type: "physique",
      poids: 0.5,
      frais_livraison: 5,
      transporteur: {
        nom: "Colissimo",
        delai_livraison: 4
      }
    }
  }
]);
