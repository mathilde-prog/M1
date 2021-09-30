#include <stdio.h>
#include <stdlib.h>
#include <sys/msg.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>

#include <commun.h>
#include <liste.h>
#include <piste.h>

/**
 * TP PETITS CHEVAUX (PROG CONC - M1 INFORMATIQUE)
 * Etudiante : Mathilde MOTTAY
 */

/**
 * POUR FAIRE LES TESTS PENDANT LE TP A LA FAC :
 * machine : ic2s130-19.univ-lemans.fr
 * Commande : ssh nom_machine
 * clés shm + sem piste : 11
 * clés shm + sem liste : 12
*/

/**
 * Verrouille la case 
 * Paramètres : 
 * semid --> Identifiant du segment de mémoire partagée 
 * numSemaphore --> Numéro du sémaphore 
 */
void verrouille_cell(int semid, int numSemaphore){
  struct sembuf op_p = {numSemaphore, -1, 0};
  semop(semid, &op_p, 1);
}

/**
 * Déverrouille la case 
 * Paramètres : 
 * semid --> Identifiant du segment de mémoire partagée 
 * numSemaphore --> Numéro du sémaphore 
 */
void deverrouille_cell(int semid, int numSemaphore){
  struct sembuf op_v = {numSemaphore, 1, 0};
  semop(semid, &op_v, 1);
}

int
main (int nb_arg, char * tab_arg[]){

  int cle_piste;
  piste_t * piste = NULL;

  int cle_liste;
  liste_t * liste = NULL;

  char marque;

  booleen_t fini = FAUX;
  piste_id_t deplacement = 0;
  piste_id_t depart = 0;
  piste_id_t arrivee = 0;

  cell_t cell_cheval;

  elem_t elem_cheval;

  /*-----*/

  if(nb_arg != 4){
    fprintf(stderr,"usage : %s <clé de piste> <clé de liste> <marque>\n", tab_arg[0]);
    exit(-1);
  }

  if(sscanf(tab_arg[1],"%d",&cle_piste) != 1){
    fprintf(stderr,"%s : erreur , mauvaise clé de piste (%s)\n", tab_arg[0], tab_arg[1]);
    exit(-2);
  }

  if(sscanf(tab_arg[2],"%d",&cle_liste) != 1){
    fprintf(stderr,"%s : erreur , mauvaise clé de liste (%s)\n", tab_arg[0], tab_arg[2]);
    exit(-2);
  }

  if(sscanf(tab_arg[3],"%c",&marque) != 1){
    fprintf(stderr,"%s : erreur , mauvaise marque de cheval (%s)\n", tab_arg[0], tab_arg[3]);
    exit(-2);
  }

  /*--- Mes déclarations ---*/

  // Indice du cheval (qui fait la course) dans la liste
  int ind_cheval_lst;

  // Identifiant du segment de mémoire partagée pour la liste
  int shmid_lst;

  // Identifiant du segment de mémoire partagée pour la piste 
  int shmid_piste;

  // Identifiant de l'ensemble des sémaphores pour la liste 
  int semid_lst;

  // Identifiant de l'ensemble des sémaphores pour la piste 
  int semid_piste;

  // Opération P sur les sémaphores 
  struct sembuf op_p = {0, -1, 0};

  // Opération V sur les sémaphores 
  struct sembuf op_v = {0, 1, 0};

  // Cheval à décaniller 
  elem_t cheval_a_decaniller;

  // Cell arrivée 
  cell_t c_arrivee;

  // Indice du cheval à décaniller dans la liste 
  int ind_cheval_a_decaniller;

  /*----------------------*/

  /**
   * Initialisation du segment de mémoire partagée de la liste pour les chevaux
   */

  if((shmid_lst = shmget(cle_liste, sizeof(liste_t), 0666)) == -1){
    fprintf(stderr, "Problème lors du shmget pour la liste\n");
    exit(-1);
  }

  liste = shmat(shmid_lst, 0, 0); // Attache le segment

  /**
   * Initialisation du segment de mémoire partagée de la piste pour les chevaux
   */
  if((shmid_piste = shmget(cle_piste, sizeof(piste_t), 0666)) == -1){
    fprintf(stderr, "Problème lors du shmget pour la piste\n");
    exit(-1);
  }

  piste = shmat(shmid_piste, 0, 0); // Attache le segment

  /**
   * Initialisation des sémaphores de la liste et de la piste pour les chevaux
   */
  semid_lst = semget(cle_liste, 1, 0666);
  semid_piste = semget(cle_piste, PISTE_LONGUEUR, 0666);

  /* Init de l'attente */
  commun_initialiser_attentes();

  /* Init de la cellule du cheval pour faire la course */
  cell_pid_affecter(&cell_cheval, getpid());
  cell_marque_affecter(&cell_cheval, marque);

  /* Init de l'élément du cheval pour l'enregistrement */
  elem_cell_affecter(&elem_cheval, cell_cheval);
  elem_etat_affecter(&elem_cheval, EN_COURSE);

  /*
   * Enregistrement du cheval dans la liste
   */

  // Création du sémaphore pour le cheval
  elem_sem_creer(&elem_cheval);

  // Verrouille la liste 
  semop(semid_lst, &op_p, 1);
  // Ajout du cheval dans la liste
  liste_elem_ajouter(liste, elem_cheval);
  // Déverrouille la liste 
  semop(semid_lst, &op_v, 1);

  // Récupération de l'indice du cheval dans la liste 
  if(liste_elem_rechercher(&ind_cheval_lst, liste, elem_cheval) == FAUX){
    fprintf(stderr, "Le cheval est introuvable dans la liste.\n");
    exit(-1);
  }

  // Affichage de la liste 
  #ifdef _DEBUG_
      liste_afficher(liste); 
  #endif

  while(!fini){
    /* Attente entre 2 coup de dé */
    commun_attendre_tour() ;

    /*
      * Vérif si pas décanillé
      */

    // Verrouille la liste 
    semop(semid_lst, &op_p, 1);

    // Recherche le cheval dans la liste pour récupérer son indice actualisé 
    liste_elem_rechercher(&ind_cheval_lst, liste, elem_cheval);
    // Récupère le cheval au bon indice 
    elem_cheval = liste_elem_lire(liste,ind_cheval_lst);

    // Déverouille la liste 
    semop(semid_lst, &op_v, 1);

    // On vérifie si le cheval est décanillé 
    if(elem_decanille(elem_cheval)){
      printf("\n--> Je suis décanillé\n");
      break;
    }

    /*
      * Avancée sur la piste
      */

    /* Coup de dé */
    deplacement = commun_coup_de_de();
    #ifdef _DEBUG_
      printf(" Lancement du Dé --> %d\n", deplacement );
    #endif

    arrivee = depart + deplacement;

    if(arrivee > PISTE_LONGUEUR-1){
	    arrivee = PISTE_LONGUEUR-1;
	    fini = VRAI;
	  }

    if(depart != arrivee){
      // Verrouillage du sémaphore du cheval
      elem_sem_verrouiller(&elem_cheval);
      // Verrouille la piste 
      semop(semid_piste,&op_p,1);
     /*
      * Si case d'arrivée est occupée alors on décanille le cheval existant
      */
      if(piste_cell_occupee(piste,arrivee)){
        // Je récupère la cell d'arrivée 
        piste_cell_lire(piste, arrivee, &c_arrivee);
        // J'affecte la marque et le pid de la cell d'arrivée au cheval à décaniller 
        cell_marque_affecter(&cheval_a_decaniller.cell, cell_marque_lire(c_arrivee));
        cell_pid_affecter(&cheval_a_decaniller.cell, cell_pid_lire(c_arrivee));

        // Verrouille la liste (pendant le décanillage)
        semop(semid_lst, &op_p, 1);

        // Récupère l'indice du cheval à décaniller dans la liste 
        liste_elem_rechercher(&ind_cheval_a_decaniller, liste, cheval_a_decaniller);
        // Récupération dans la liste du cheval à décaniller à partir de son indice 
        cheval_a_decaniller = liste_elem_lire(liste, ind_cheval_a_decaniller);

        #ifdef _DEBUG_
          printf("--> Je suis le cheval ");
          elem_afficher(elem_cheval);
          printf(" et je veux décaniller le cheval ");
          elem_afficher(cheval_a_decaniller);
          printf("\n");
        #endif
        
        // Verrouille le sémaphore du cheval à décaniller
        elem_sem_verrouiller(&cheval_a_decaniller);
        // Décanillage du cheval 
        liste_elem_decaniller(liste, ind_cheval_a_decaniller);

        // Pour vérifier si l'état du cheval est bien passé à DECANILLE
        // cheval_a_decaniller =  liste_elem_lire(liste, ind_cheval_a_decaniller);
        // elem_afficher(cheval_a_decaniller);

        // Déverouillage du sémaphore du cheval à décaniller
        elem_sem_deverrouiller(&cheval_a_decaniller);

        // Déverouille la liste après le décanillage.
        semop(semid_lst, &op_v, 1);
      }

    // Déverouille la piste 
    semop(semid_piste,&op_v,1);

	  /*
	   * Déplacement: effacement case de depart, affectation case d'arrivée
	   */

    // Verrouille les cases de départ et d'arrivée 
    verrouille_cell(semid_piste, arrivee);
    verrouille_cell(semid_piste, depart);

    // Efface la cell de départ 
    piste_cell_effacer(piste,depart);

    commun_attendre_fin_saut();

    // Déverouille le sémaphore du cheval 
    elem_sem_deverrouiller(&elem_cheval);

    // Affecte le cheval à la case d'arrivée 
    piste_cell_affecter(piste, arrivee, cell_cheval);

    // Déverrouille les cases de départ et d'arrivée 
    deverrouille_cell(semid_piste, arrivee);
    deverrouille_cell(semid_piste, depart);

    #ifdef _DEBUG_
	    printf("Déplacement du cheval \"%c\" de %d a %d\n", marque, depart, arrivee);
    #endif

	}
    /* Affichage de la piste  */
    piste_afficher_lig(piste);

    depart = arrivee;
  }

  // L'affichage diffère selon si le cheval a franchit la ligne d'arrivée ou a fini décanillé 
  if(elem_decanille(elem_cheval)){
    printf("Le cheval \"%c\" A FINI DECANILLE\n", marque);
  }
  else {
    printf("Le cheval \"%c\" A FRANCHIT LA LIGNE D ARRIVEE\n", marque);
  }

  /*
   * Suppression du cheval de la liste
   */

  // Verrouille la cell de départ 
  verrouille_cell(semid_piste,depart);
  // Efface la cell de départ 
  piste_cell_effacer(piste, depart);
  // Déverrouille la cell de départ 
  deverrouille_cell(semid_piste, depart);

  // Verrouille la liste 
  semop(semid_lst, &op_p, 1);
  // Recherche le cheval dans la liste pour récupérer son indice actualisé 
  liste_elem_rechercher(&ind_cheval_lst, liste, elem_cheval);
  // Récupère le cheval au bon indice 
  elem_cheval = liste_elem_lire(liste,ind_cheval_lst);
  // Supprime le cheval dans la liste 
  liste_elem_supprimer(liste, ind_cheval_lst);
  // Déverrouille la liste 
  semop(semid_lst, &op_v, 1);

  // Détruit le sémaphore du cheval 
  elem_sem_detruire(&elem_cheval);

  exit(0);
}
