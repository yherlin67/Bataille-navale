# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
    nb_coups_but:   .word 0
    nb_coups:       .word 0
    
# ===== Section code =====  
.text

# ----- Main ----- 
main:
   
    jal initPartie
    jal displayGrille
    jal simulationJeu
    jal displayGrille
    j   exit 

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, 5
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, 4  
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, 3
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, 3
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, 2
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    lw      $ra, 0($sp)                 # On recharge la reference 
    add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb      $t3, 0($t2)	# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j boucle_initGrille
    end_initGrille:
        jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    jal displayLettres
    jal addNewLine
    la      $t0, grille     #Charge l'adresse de la grille dans $t0
    li      $t1, 0          #Initialisation du compteur de boucle dans $t1
    li      $t3, 10         #Compteur de colonnes
    boucle_displayGrille:
        bge     $t1, 100, end_displayGrille     # Si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
        beq     $t3, 10,  addLineCount          
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 11                 # code pour l'affichage d'un caractère (char)
            syscall
            addi    $t1, $t1, 1            # $t1 += 1;
            addi    $t3, $t3, 1            # $t3 += 1;
            move    $a1, $t1
        j boucle_displayGrille
    
    end_displayGrille:
        jal     addNewLine
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, $v0, $a0

displayLettres:
#Fait par Yanis

    li $a0, 32          # 32 = code ascii du caractère ' '
    li $v0, 11          # Fonction pour afficher un caractère
    syscall
    li $a0, 32          # 32 = code ascii du caractère ' '
    li $v0, 11          # Fonction pour afficher un caractère
    syscall
    li $t0, 65          # 65 = code ascii de 'A'
boucle_lettres:
    bgt $t0, 74, fin_displayLettres  # Pour arrêter après 'J'
    move $a0, $t0       # Pour Charger la lettre dans $a0
    li $v0, 11     
    syscall
    li $a0, 32          
    li $v0, 11          
    syscall
    addi $t0, $t0, 1    # Pour aller à la lettre suivante
    j boucle_lettres

fin_displayLettres:
    jr $ra
    
# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    jr      $ra             # Retour à la fonction précendente

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:
    #Fait par Baptiste
    
    li $t3, 0

    jal     addNewLine      # retour à la ligne

    move    $a0, $a1        # préparer a pour getModulo (a0 = position)
    li      $a1, 10         
    jal     getModulo      

    move    $a0, $v0        # ligne = quotient
    addi    $a0, $a0, 1     # ligne affichée = quotient + 1
    li      $v0, 1          # print_int
    syscall

    j boucle_displayGrille
    
#addLineCount:
    #Fait par Baptiste
 #   add $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
  #  sw  $ra, 0($sp)
    
   # li $t3, 0
    
    #jal addNewLine
    #li $t0, 0          # compteur de ligne
    #li $a1, 11         # diviseur pour le modulo

#boucleInt:
    #bge $t0, 10, finDisplayLigne  # stop après 10 lignes

    #move $a0, $t0
    #jal getModulo                 # v0 = t0 mod 11
    
    #addi $a0, $v0, 1              # ligne affichée = res modulo + 1
    #li $v0, 1                     # print int
    #syscall

    #jal addNewLine

    #addi $t0, $t0, 1              # t0++
    #j boucleInt

#finDisplayLigne:
    #lw $ra, 0($sp)                 # On recharge la reference 
    #add $sp, $sp, 4                 # du dernier jump
    #jr $ra

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo: 
    li $v1, 0
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
        addi $v1, $v1, 1
        sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caractère pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip:
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

    move    $s0, $a0	    # On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move $s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip:
        lw      $ra, 0($sp)
        add     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
        
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
#Fait par Baptiste
    li $t0, 0
    move $v0, $t0
    li $a1, 11        #taille navire

    jal getAleatoire
    move $s2, $a0
    
    jal getAleatoire
    move $s3, $a0
    
    move $s0, $a1
    
    j verifPlaceHorizontale
    


# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:
#Fait par Baptiste
# $s0 = taille du bateau
# $s2 = ligne
# $s3 = colonne

    li   $t1, 10
    mult $s2, $t1
    mflo $t2
    add  $t2, $t2, $s3     # case

    la   $t3, grille       # adresse tableau pour recup valeur
    li   $t4, 0            # compteur

    add  $t0, $s3, $s0     # colonne + taille ! important pour tester si on sors du tab
    bgt  $t0, 10, erreurH   # test dépassement (colone choisit > a 10)

    verifH:
        beq  $t4, $s0, bonH

        add  $t1, $t2, $t4     # test du suivant indice + i
        add  $t1, $t1, $t3     # test de la case

        lb   $t0, 0($t1)       # case
        li   $t1, '.'          # valeur attendue
        bne  $t0, $t1, erreurH  # test si la case est vide

        addi $t4, $t4, 1       # on test avec un autre i
        j    verifH


    bonH:
        li $v0, 0
        j finH

    erreurH:
        li $v0, 1


    finH:
        jr $ra


# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:
#Fait par Baptiste et Yanis
    li $t0, 0
    move $v0, $t0
    li $a1, 11          # taille

    jal getAleatoire
    move $s3, $a0       # colonne

    jal getAleatoire
    move $s2, $a0       # ligne

    move $s0, $a1       # taille

    j verifPlaceVerticale
# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale:
#Fait par Baptiste

    li   $t1, 10
    mult $s2, $t1
    mflo $t2
    add  $t2, $t2, $s3      # case

    la   $t3, grille        # adresse du tab
    li   $t4, 0             # compteur

    add  $t0, $s2, $s0      # ligne + taille permet a la ligne suivante de tester si l'on sors
    bgt  $t0, 10, erreurV

    verifV:
        beq  $t4, $s0, bonV

        mul  $t1, $t4, 10    # permet de monter d'une case
        add  $t1, $t1, $t2   # index
        add  $t1, $t1, $t3   # adresse case suivante

        lb   $t0, 0($t1)     # case
        li   $t1, '.'        # test si case vide
        bne  $t0, $t1, erreurV

        addi $t4, $t4, 1
        j    verifV

    bonV:
        li $v0, 0
        j finV

    erreurV:
        li $v0, 1

    finV:
        jr $ra

# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3]

simulationJeu:
    
    lw $s0, nb_coups_but
    li $s0, 0 #initialisation de nb_coups_but à 0
    
    lw $s1 nb_coups
    li $s1, 0  #initialisation de nb_coups à 0
    
boucle_simulation:
    
    bgt $s0, 17, exit #Tant que nb_coups_but inférieur ou égal 17 :
    
    li $a1, 10
    jal getAleatoire
    move $s2, $a0  #stockage du résultat de getAleatoire dans $s2 (ligne) 
    
    li $a1, 10
    jal getAleatoire
    move $s3, $a0  #stockage du résultat de getAleatoire dans $s3 (colonne)    
    
    jal traque
    j boucle_simulation
    
# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[8-9], $s[0-3]

traque:
    add $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw  $ra, 0($sp)
    
#<<<<<<< HEAD
    #calcul de la case : ligne * 10 + colonne
    li $t0, 10
    mult $s2, $t0
    mflo $t1
    add $t1, $t1, $s3
#=======
    li $t8, 10
    mult $s2, $t8 #calcul de la case : ligne * 10 + colonne
    mflo $t9
    add $t9, $t9, $s3
#>>>>>>> 1400cbbbc5c423408ce1ff43d6abffcf7c80c476
    
    la  $t8, grille
    add $t8, $t8, $t9
    lb  $t9, 0($t8)
    
    beq $t9, '~', retour_chasse
    
    addi $s1, $s1, 1 #Incrémente nb_coups de 1
    beq $t9, '.', tir_loupe
    
#<<<<<<< HEAD
    #beq $t3 #est un navire
#=======
    addi $s0, $s0, 1 #Incrémente nb_coups_buts de 1
#>>>>>>> 1400cbbbc5c423408ce1ff43d6abffcf7c80c476
    
    li $t9, 'X'
    sb $t9, 0($t8)
    sub $s2, $s2, 1
    jal traque
    sub $s3, $s3, 1
    jal traque
    add $s2, $s2, 1
    jal traque
    add $s3, $s3, 1
    jal traque
      
tir_loupe:
    li $t9, '~'
    sb $t9, 0($t8)
    j retour_chasse
    
     
    addi $s0, $s0, 1  #Incrémente nb_coups_but de 1
    
retour_chasse:
    lw $ra, 0($sp)
    add $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra



#   Fonction traque (grille, ligne, colonne):

 #       position = ligne * nombre_de_colonnes + colonne 
 #      case = grille[position]
        
  #      Si case == '~' ou case == 'X' :
   #         Retourner
        
    #    nb_coup += 1 

     #   Si case == '.' :
      #      case = '~'
       #     Retourner
        
        #Sinon 
         #   nb_coup_but += 1 
          #  case = 'X'

          #  traque(grille, ligne-1, colonne)
          #  traque(grille, ligne, colonne-1)
          #  traque(grille, ligne+1, colonne)
          #  traque(grille, ligne, colonne+1)

        #Retourner

exit: 
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
