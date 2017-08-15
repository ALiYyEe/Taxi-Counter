

	LIST      p=16F876A            ; Définition de processeur
	#include <p16F876A.inc>        ; fichier include
    
	__CONFIG   _CP_OFF & _DEBUG_OFF  & _CPD_OFF & _LVP_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC 


;*****************************************************************************
;                               ASSIGNATIONS SYSTEME                         *
;*****************************************************************************

; REGISTRE OPTION_REG (configuration)
; -----------------------------------
OPTIONVAL	EQU	B'00000111'
			; RBPU     b7 : 1= Résistance rappel +5V hors service
			; INTEDG   b6 : 1= Interrupt sur flanc montant de RB0
			;               0= Interrupt sur flanc descend. de RB0
			; TOCS      b5 : 1= source clock = transition sur RA4
			;                0= horloge interne
			; TOSE      b4 : 1= Sélection flanc montant RA4(si B5=1)
			;                0= Sélection flanc descendant RA4
			; PSA       b3 : 1= Assignation prédiviseur sur Watchdog
			;                0= Assignation prédiviseur sur Tmr0
			; PS2/PS0   b2/b0 valeur du prédiviseur
                        ;           000 =  1/1 (watchdog) ou 1/2 (tmr0)
			;           001 =  1/2               1/4
			;           010 =  1/4		     1/8
			;           011 =  1/8		     1/16
			;           100 =  1/16		     1/32
			;           101 =  1/32		     1/64
			;           110 =  1/64		     1/128
			;           111 =  1/128	     1/256


; REGISTRE INTCON (contrôle interruptions standard)
; -------------------------------------------------
INTCONVAL	EQU	B'01100000'
			; GIE       b7 : masque autorisation générale interrupt
                        ;                ne pas mettre ce bit à 1 ici
                        ;                sera mis en temps utile
			; PEIE      b6 : masque autorisation générale périphériques
			; T0IE      b5 : masque interruption tmr0
			; INTE      b4 : masque interuption RB0/Int
			; RBIE      b3 : masque interruption RB4/RB7
			; T0IF      b2 : flag tmr0
			; INTF      b1 : flag RB0/Int
			; RBIF      b0 : flag interruption RB4/RB7

; REGISTRE PIE1 (contrôle interruptions périphériques)
; ----------------------------------------------------
PIE1VAL		EQU	B'00000000'
			; PSPIE     b7 : Toujours 0 sur PIC 16F786
			; ADIE      b6 : masque interrupt convertisseur A/D
			; RCIE      b5 : masque interrupt réception USART
			; TXIE      b4 : masque interrupt transmission USART
			; SSPIE     b3 : masque interrupt port série synchrone
			; CCP1IE    b2 : masque interrupt CCP1
			; TMR2IE    b1 : masque interrupt TMR2 = PR2
			; TMR1IE    b0 : masque interrupt débordement tmr1

; REGISTRE PIE2 (contrôle interruptions particulières)
; ----------------------------------------------------
PIE2VAL		EQU	B'00000000'
			; UNUSED    b7 : inutilisé, laisser à 0
			; RESERVED  b6 : réservé, laisser à 0
			; UNUSED    b5 : inutilisé, laisser à 0
			; EEIE      b4 : masque interrupt écriture EEPROM
			; BCLIE     b3 : masque interrupt collision bus
			; UNUSED    b2 : inutilisé, laisser à 0
			; UNUSED    b1 : inutilisé, laisser à 0
			; CCP2IE    b0 : masque interrupt CCP2

; REGISTRE ADCON1 (ANALOGIQUE/DIGITAL)
; ------------------------------------
ADCON1VAL	EQU	B'00000110' ; PORTA en mode digital

; DIRECTION DES PORTS I/O
; -----------------------

;DIRPORTA	EQU	B'00111111'	; Direction PORTA (1=entrée)
DIRPORTB	EQU	B'00000000'	; Direction PORTB
DIRPORTC	EQU	B'00000000'	; Direction PORTC


;*****************************************************************************
;                           ASSIGNATIONS PROGRAMME                           *
;*****************************************************************************

; exemple
;   segment        HGFEDCBA
val0	EQU	  B'11000000'
val1    EQU   B'11111001'
val2    EQU   B'10100100'
val3    EQU   B'10110000'
val4    EQU   B'10011001'
val5    EQU   B'10010010'
val6    EQU   B'10000010'
val7    EQU   B'11111000'
val8    EQU   B'10000000'
val9    EQU   B'10010000'
valv    EQU   B'11111111'
; -------




;*****************************************************************************
;                                  DEFINE                                    *
;*****************************************************************************

; exemple
; -------
#DEFINE    onoff    PORTA,0
#DEFINE    tarif    PORTA,1
#DEFINE    clien    PORTA,2
#DEFINE    efface   PORTA,3
#DEFINE    senser   PORTA,4

;*****************************************************************************
;                             MACRO                                          *
;*****************************************************************************

			; Changement de banques
			; ----------------------

BANK0	macro				; passer en banque0
		bcf	STATUS,RP0
		bcf	STATUS,RP1
	endm

BANK1	macro				; passer en banque1
		bsf	STATUS,RP0
		bcf	STATUS,RP1
	endm

BANK2	macro				; passer en banque2
		bcf	STATUS,RP0
		bsf	STATUS,RP1
	endm

BANK3	macro				; passer en banque3
		bsf	STATUS,RP0
		bsf	STATUS,RP1
	endm



			; opérations en mémoire eeprom
			; -----------------------------

REEPROM macro				; lire eeprom(adresse & résultat en w)
		clrwdt			; reset watchdog
		bcf	STATUS,RP0	; passer en banque2
		bsf	STATUS,RP1
		movwf	EEADR		; pointer sur adresse eeprom
		bsf	STATUS,RP0	; passer en banque3
		bcf	EECON1,EEPGD	; pointer sur eeprom
		bsf	EECON1,RD	; ordre de lecture
		bcf	STATUS,RP0	; passer en banque2
		movf	EEDATA,w	; charger valeur lue
		bcf	STATUS,RP1	; passer en banque0
	endm


WEEPROM	macro	addwrite	; la donnée se trouve dans W
	LOCAL	loop
	bcf	STATUS,RP0	; passer en banque2
	bsf	STATUS,RP1
	movwf	EEDATA		; placer data dans registre
	movlw	addwrite	; charger adresse d'écriture
	movwf	EEADR		; placer dans registre
	bsf	STATUS,RP0	; passer en banque3
	bcf	EECON1 , EEPGD	; pointer sur mémoire data
	bsf	EECON1 , WREN	; autoriser accès écriture
	bcf	INTCON , GIE	; interdire interruptions
	movlw	0x55		; charger 0x55
	movwf	EECON2		; envoyer commande
	movlw	0xAA		; charger 0xAA
	movwf	EECON2		; envoyer commande
	bsf	EECON1 , WR	; lancer cycle d'écriture
	bsf	INTCON , GIE	; réautoriser interruptions
loop
	clrwdt				; effacer watchdog
	btfsc	EECON1 , WR	; tester si écriture terminée
	goto	loop		; non, attendre
	bcf	EECON1 , WREN	; verrouiller prochaine écriture
	bcf	STATUS , RP0	; passer en banque0
	bcf	STATUS , RP1
	endm




;*****************************************************************************
;                        VARIABLES BANQUE 0                                  *
;*****************************************************************************

; Zone de 80 bytes
; ----------------

	CBLOCK	0x30		; Début de la zone (0x20 à 0x6F)
    temp3 :1
    temp2 :1
    temp1 :1
    disptable:1
    ct1    :5
    ct2    :5
    ct3    :5
    sw
    compt
    compt1
    compt2
    compt3
    tarif_f
    senser_c
    


        ENDC			; Fin de la zone                        

var1 	EQU H'006E'		; adresse imposée

;*****************************************************************************
;                      VARIABLES ZONE COMMUNE                                *
;*****************************************************************************

; Zone de 16 bytes
; ----------------

	CBLOCK 0x70		; Début de la zone (0x70 à 0x7F)
	w_temp : 1		; Sauvegarde registre W
	status_temp : 1		; sauvegarde registre STATUS
	FSR_temp : 1		; sauvegarde FSR (si indirect en interrupt)
	PCLATH_temp : 1		; sauvegarde PCLATH (si prog>2K)

	ENDC

;*****************************************************************************
;                        VARIABLES BANQUE 1                                  *
;*****************************************************************************

; Zone de 80 bytes
; ----------------

	CBLOCK	0xA0		; Début de la zone (0xA0 à 0xEF)

	ENDC			; Fin de la zone                        

;*****************************************************************************
;                        VARIABLES BANQUE 2                                  *
;*****************************************************************************

; Zone de 96 bytes
; ----------------

	CBLOCK	0x110		; Début de la zone (0x110 à 0x16F)

	ENDC			; Fin de la zone                        

;*****************************************************************************
;                        VARIABLES BANQUE 3                                  *
;*****************************************************************************

; Zone de 96 bytes
; ----------------

	CBLOCK	0x190		; Début de la zone (0x190 à 0x1EF)

	ENDC			; Fin de la zone                        

;*****************************************************************************
;                      DEMARRAGE SUR RESET                                   *
;*****************************************************************************

	org 0x000 		; Adresse de départ après reset
  	goto    init		; Initialiser

; ////////////////////////////////////////////////////////////////////////////

;                         I N T E R R U P T I O N S

; ////////////////////////////////////////////////////////////////////////////

;*****************************************************************************
;                     ROUTINE INTERRUPTION                                   *
;*****************************************************************************
;-----------------------------------------------------------------------------
; Si on n'utilise pas l'adressage indirect dans les interrupts, on se passera
; de sauvegarder FSR
; Si le programme ne fait pas plus de 2K, on se passera de la gestion de 
; PCLATH
;-----------------------------------------------------------------------------
			;sauvegarder registres	
			;---------------------
	org 0x004		; adresse d'interruption
	movwf   w_temp  	; sauver registre W
	swapf	STATUS,w	; swap status avec résultat dans w
	movwf	status_temp	; sauver status swappé
	movf	FSR , w		; charger FSR
	movwf	FSR_temp	; sauvegarder FSR
	movf	PCLATH , w	; charger PCLATH
	movwf	PCLATH_temp	; le sauver
	clrf	PCLATH		; on est en page 0
	BANK0			; passer en banque0

			; switch vers différentes interrupts
			; inverser ordre pour modifier priorités
			; mais attention alors au test PEIE
			; effacer les inutiles
			;----------------------------------------
	
			; Interruption TMR0
			; -----------------

	btfsc	INTCON,T0IE	; tester si interrupt timer autorisée
	btfss	INTCON,T0IF	; oui, tester si interrupt timer en cours
	goto 	intsw1		; non test suivant
	call	inttmr0		; oui, traiter interrupt tmr0
	bcf	    INTCON,T0IF	; effacer flag interrupt tmr0
	goto	restorereg	; et fin d'interruption
				; SUPPRIMER CETTE LIGNE POUR
				; TRAITER PLUSIEURS INTERRUPT
				; EN 1 SEULE FOIS

			; Interruption RB0/INT
			; --------------------
intsw1
	btfsc	INTCON,INTE	; tester si interrupt RB0 autorisée
	btfss	INTCON,INTF	; oui, tester si interrupt RB0 en cours
	goto 	intsw2		; non sauter au test suivant
	call	intrb0		; oui, traiter interrupt RB0
	bcf	INTCON,INTF	; effacer flag interupt RB0
	goto	restorereg	; et fin d'interruption
				; SUPPRIMER CETTE LIGNE POUR
				; TRAITER PLUSIEURS INTERRUPT
				; EN 1 SEULE FOIS

			; interruption RB4/RB7
			; --------------------
intsw2
	btfsc	INTCON,RBIE	; tester si interrupt RB4/7 autorisée
	btfss	INTCON,RBIF	; oui, tester si interrupt RB4/7 en cours
	goto 	intsw3		; non sauter
	call	intrb4		; oui, traiter interrupt RB4/7
	bcf	INTCON,RBIF	; effacer flag interupt RB4/7
	goto	restorereg	; et fin d'interrupt

			; détection interruptions périphériques
			; le test peut être supprimé si une seule
			; interrupt est traitée à la fois
			; --------------------------------------
intsw3
	btfss	INTCON,PEIE	; tester interruption périphérique autorisée
	goto	restorereg	; non, fin d'interruption

			; Interruption convertisseur A/D
			; ------------------------------

	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,ADIE	; tester si interrupt autorisée
	goto 	intsw4		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,ADIF	; tester si interrupt en cours
	goto 	intsw4		; non sauter
	call	intad		; oui, traiter interrupt
	bcf	PIR1,ADIF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; Interruption réception USART
			; ----------------------------
intsw4
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,RCIE	; tester si interrupt autorisée
	goto 	intsw5		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,RCIF	; oui, tester si interrupt en cours
	goto 	intsw5		; non sauter
	call	intrc		; oui, traiter interrupt
				; LE FLAG NE DOIT PAS ETRE REMIS A 0
				; C'EST LA LECTURE DE RCREG QUI LE PROVOQUE
	goto	restorereg	; et fin d'interrupt

			; Interruption transmission USART
			; -------------------------------
intsw5
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,TXIE	; tester si interrupt autorisée
	goto 	intsw6		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,TXIF	; oui, tester si interrupt en cours
	goto 	intsw6		; non sauter
	call	inttx		; oui, traiter interrupt
				; LE FLAG NE DOIT PAS ETRE REMIS A 0
				; C'EST L'ECRITURE DE TXREG QUI LE PROVOQUE
	goto	restorereg	; et fin d'interrupt

			; Interruption SSP
			; ----------------
intsw6
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,SSPIE	; tester si interrupt autorisée
	goto 	intsw7		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,SSPIF	; oui, tester si interrupt en cours
	goto 	intsw7		; non sauter
	call	intssp		; oui, traiter interrupt
	bcf	PIR1,SSPIF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; Interruption CCP1
			; -----------------
intsw7
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,CCP1IE	; tester si interrupt autorisée
	goto 	intsw8		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,CCP1IF	; oui, tester si interrupt en cours
	goto 	intsw8		; non sauter
	call	intccp1		; oui, traiter interrupt
	bcf	PIR1,CCP1IF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt


			; Interruption TMR2
			; -----------------
intsw8
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,TMR2IE	; tester si interrupt autorisée
	goto 	intsw9		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,TMR2IF	; oui, tester si interrupt en cours
	goto 	intsw9		; non sauter
	call	inttmr2		; oui, traiter interrupt
	bcf	PIR1,TMR2IF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; Interruption TMR1
			; -----------------
intsw9
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE1,TMR1IE	; tester si interrupt autorisée
	goto 	intswA		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR1,TMR1IF	; oui, tester si interrupt en cours
	goto 	intswA		; non sauter
	call	inttmr1		; oui, traiter interrupt
	bcf	PIR1,TMR1IF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; Interruption EEPROM
			; -------------------
intswA
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE2,EEIE	; tester si interrupt autorisée
	goto 	intswB		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR2,EEIF	; oui, tester si interrupt en cours
	goto 	intswB		; non sauter
	call	inteprom	; oui, traiter interrupt
	bcf	PIR2,EEIF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; Interruption COLLISION
			; ----------------------
intswB
	bsf	STATUS,RP0	; sélectionner banque1
	btfss	PIE2,BCLIE	; tester si interrupt autorisée
	goto 	intswC		; non sauter
	bcf	STATUS,RP0	; oui, sélectionner banque0
	btfss	PIR2,BCLIF	; oui, tester si interrupt en cours
	goto 	intswC		; non sauter
	call	intbc		; oui, traiter interrupt
	bcf	PIR2,BCLIF	; effacer flag interupt 
	goto	restorereg	; et fin d'interrupt

			; interruption CCP2
			; -----------------
intswC
	bcf	STATUS,RP0	; oui, sélectionner banque0
	call	intccp2		; traiter interrupt
	bcf	PIR2,CCP2IF	; effacer flag interupt 

			;restaurer registres
			;-------------------
restorereg
	movf	PCLATH_temp , w	; recharger ancien PCLATH
	movwf	PCLATH		; le restaurer
	movf	FSR_temp , w	; charger FSR sauvé
	movwf	FSR		; restaurer FSR
	swapf	status_temp,w	; swap ancien status, résultat dans w
	movwf   STATUS		; restaurer status
	swapf   w_temp,f	; Inversion L et H de l'ancien W
                       		; sans modifier Z
	swapf   w_temp,w  	; Réinversion de L et H dans W
				; W restauré sans modifier status
	retfie  		; return from interrupt

;*****************************************************************************
;                        INTERRUPTION TIMER 0                                *
;*****************************************************************************
inttmr0 
       decfsz compt3
       goto   e20
       movlw  0x50
       movwf  compt3
       movlw  0x01
       movwf  compt2
       btfss  tarif_f,0
       goto   e41
       goto   e40
 e41   movlw  ct1
       addlw  0x03
       movwf  FSR
       movfw  INDF
       btfss  STATUS,Z
       goto   e40
       bcf    tarif_f,0
       movlw  ct1
       movwf  sw
 e10   movfw  sw
       addlw  0x03
       movwf  FSR
       movlw  0x02
       decf   FSR 
       addwf  INDF
       movfw  INDF
       sublw  0x0A 
       btfss  STATUS,Z
       goto   e6
       clrf   INDF
       decf   FSR
       movlw  0x01
       addwf  INDF
       movfw  INDF
       sublw  0x0A
       btfss  STATUS,Z
       goto   e6
       clrf   INDF
       decf   FSR
       movlw  0x01
       addwf  INDF
       
       movfw  INDF
       sublw  0x0A
       btfss  STATUS,Z
       goto   e6
       call   reset
              
e6     movlw  0x05
       addwf  sw,f
       rlf    compt2
       btfss  compt2,3
       goto   e10
       goto   e20

 e40   bsf    tarif_f,0
       movlw  ct1
       movwf  sw
 e61   movfw  sw
       addlw  0x03
       movwf  FSR
       movlw  0x05
       addwf  INDF
       movfw  INDF
       sublw  0x0A
       btfss  STATUS,Z
       goto   e30
       clrf   INDF
       decf   FSR
       movlw  0x03 
  e31  addwf  INDF
       movfw  INDF
       sublw  0x0A 
       btfss  STATUS,Z
       goto   e50
       clrf   INDF
       decf   FSR
       movlw  0x01
       addwf  INDF
       movfw  INDF
       sublw  0x0A
       btfss  STATUS,Z
       goto   e50
       clrf   INDF
       decf   FSR
       movlw  0x01
       addwf  INDF

       movfw  INDF
       sublw  0x0A
       btfss  STATUS,Z
       goto   e50
       call   reset

e50    movlw  0x05
       addwf  sw,f
       rlf    compt2
       btfss  compt2,3
       goto   e61
       goto   e20
 e30   movlw  0x02
       decf   FSR
       goto   e31 
       

       
 e20   
       return			
                ; fin d'interruption timer
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                        INTERRUPTION RB0/INT                                *
;*****************************************************************************
intrb0
	return			; fin d'interruption RB0/INT
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                         INTERRUPTION RB4/RB7                               *
;*****************************************************************************
intrb4
	movf	PORTB,w		; indispensable pour pouvoir resetter RBIF
	return			; fin d'interruption RB4/RB7
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION CONVERTISSEUR A/D                         *
;*****************************************************************************
intad
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION RECEPTION USART                           *
;*****************************************************************************
intrc
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION TRANSMISSION USART                        *
;*****************************************************************************
inttx
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                       INTERRUPTION SSP                                     *
;*****************************************************************************
intssp
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                       INTERRUPTION CCP1                                    *
;*****************************************************************************
intccp1
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION TIMER 2                                   *
;*****************************************************************************
inttmr2
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION TIMER 1                                   *
;*****************************************************************************
inttmr1
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION EEPROM                                    *
;*****************************************************************************
inteprom
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                     INTERRUPTION COLLISION                                 *
;*****************************************************************************
intbc
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

;*****************************************************************************
;                        INTERRUPTION CCP2                                   *
;*****************************************************************************
intccp2
	return			; fin d'interruption
				; peut être remplacé par 
				; retlw pour retour code d'erreur

; ////////////////////////////////////////////////////////////////////////////

;                           P R O G R A M M E

; ////////////////////////////////////////////////////////////////////////////

;*****************************************************************************
;                          INITIALISATIONS                                   *
;*****************************************************************************
init

			; initialisation PORTS (banque 0 et 1)
			; ------------------------------------
	BANK0			; sélectionner banque0
	clrf	PORTA		; Sorties PORTA à 0
	clrf	PORTB		; sorties PORTB à 0
	clrf	PORTC		; sorties PORTC à 0
	bsf	    STATUS,RP0	; passer en banque1
	movlw	ADCON1VAL	; PORTA en mode digital/analogique
	movwf	ADCON1		; écriture dans contrôle A/D
	movlw	0x3F    	; Direction PORTA
	movwf	TRISA		; écriture dans registre direction
	movlw	DIRPORTB	; Direction PORTB
	movwf	TRISB		; écriture dans registre direction
	movlw	DIRPORTC	; Direction PORTC
	movwf	TRISC		; écriture dans registre direction

			; Registre d'options (banque 1)
			; -----------------------------
	movlw	OPTIONVAL	; charger masque
	movwf	OPTION_REG	; initialiser registre option

			; registres interruptions (banque 1)
			; ----------------------------------
	movlw	INTCONVAL	; charger valeur registre interruption
	movwf	INTCON		; initialiser interruptions
	movlw	PIE1VAL		; Initialiser registre 
	movwf	PIE1		; interruptions périphériques 1
	movlw	PIE2VAL		; initialiser registre
	movwf	PIE2		; interruptions périphériques 2



			; autoriser interruptions (banque 0)
			; ----------------------------------
	clrf	PIR1		; effacer flags 1
	clrf	PIR2		; effacer flags 2
	bsf	INTCON,GIE	; valider interruptions
	goto	start		; programme principal


;*****************************************************************************
;                      PROGRAMME PRINCIPAL                                   *
;*****************************************************************************

start

   BANK0
    movlw 0x05
    movwf senser_c
    movlw 0x50
    movwf compt3
    movlw 0xFF
    movwf PORTB
    movwf PORTC
    call  Tempo_350ms
    movlw 0x01
    movwf compt
    btfsc onoff
    goto  $-1
    clrf  PORTB
    call  Tempo_350ms
    call  jour
    movlw 0x7F
    movwf PORTB
    
    movlw 0x05
    movwf compt1
    
n6  btfsc tarif
    goto  n7
    goto  n8
    
n7  call   Tempo_100ms
    decfsz compt1
    goto   n6
    goto   n2
n8  call  nuit
    
    bsf   INTCONVAL,GIE
    
n2  movlw ct1
    movwf disptable
    movlw 0x01
    movwf PORTC 
n9  btfsc clien
    goto  n5
    movlw 0xFF
    movwf PORTB
    call  Tempo_100ms
    movlw 0x01
    addwf compt
    btfss compt,2
    goto  n3
    goto  n4
n3  movlw 0x05
    addwf disptable,f
    goto  n5
n4  movlw 0x01
    movwf compt
    movlw ct1
    movwf disptable
n5  btfsc onoff
    goto  s1
    goto  start
s1  btfsc efface
    goto  s2
    call  reset
s2  btfsc senser
    goto  b1
    movlw 0x30
    movwf compt3
    call  Tempo_1ms
    call  inc
         
b1  movlw 0x01
    movwf PORTC
    movfw disptable
    movwf FSR
b2  movfw INDF
    call  convert
    btfss PORTC,1
    goto  d1
    andlw 0x7F
d1  movwf PORTB
    call  Tempo_1ms
    incf  FSR
    bcf   STATUS,C
    rlf   PORTC,f
    btfss PORTC,5
    goto  b2
    goto  n9

    
    
    
convert
         movwf sw
         sublw 0x00
         btfss STATUS,Z
         goto  c1
         goto  c2
c1       movfw sw
         sublw 0x01
         btfss STATUS,Z
         goto  c3
         goto  c4
c3       movfw sw
         sublw 0x02
         btfss STATUS,Z
         goto  c5
         goto  c6
c5       movfw sw
         sublw 0x03
         btfss STATUS,Z
         goto  c7
         goto  c8
c7       movfw sw
         sublw 0x04
         btfss STATUS,Z
         goto  c9
         goto  c10
c9       movfw sw
         sublw 0x05
         btfss STATUS,Z
         goto  c11
         goto  c12
c11      movfw sw
         sublw 0x06
         btfss STATUS,Z
         goto  c13
         goto  c14
c13      movfw sw
         sublw 0x07
         btfss STATUS,Z
         goto  c15
         goto  c16
c15      movfw sw
         sublw 0x08
         btfss STATUS,Z
         goto  c17
         goto  c18
c17      movfw sw
         sublw 0x09
         btfss STATUS,Z
         goto  c19
         goto  c20
c19      movlw 0xFF
         return
         goto  c20
c2       retlw val0
c4       retlw val1
c6       retlw val2
c8       retlw val3
c10      retlw val4
c12      retlw val5
c14      retlw val6
c16      retlw val7
c18      retlw val8
c20      retlw val9
    
inc      decfsz senser_c
         goto  h1
         movlw 0x05
         movwf  senser_c
         movlw 0x01
         movwf compt3
         movwf 0xFE
         movwf TMR0
h1       return
                       
reset
    movfw compt
    sublw 0x01
    btfss STATUS,Z
    goto  g1
    call  reset1
g1  movfw compt
    sublw 0x02
    btfss STATUS,Z
    goto  g2
    call  reset2
g2  movfw compt
    sublw 0x03
    btfss STATUS,Z
    goto  g3
    call  reset3
g3  return 

reset1
    btfss tarif_f,0
    goto  g11
    goto  g10
g10 movlw ct1
    call  resetnuit
    return
g11 movlw ct1
    call  resetjour
    return

reset2
    btfss tarif_f,0
    goto  g13
    goto  g12
g12 movlw ct2
    call  resetnuit
    return
g13 movlw ct2
    call  resetjour
    return

reset3
    btfss tarif_f,0
    goto  g15
    goto  g14
g14 movlw ct3
    call  resetnuit
    return
g15 movlw ct3
    call  resetjour
    return

resetnuit   
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x07
    movwf INDF
    incf  FSR
    movlw 0x05
    movwf INDF
    return

resetjour
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x04
    movwf INDF
    incf  FSR
    movlw 0x00
    movwf INDF
    return

nuit 
    movlw ct1
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x07
    movwf INDF
    incf  FSR
    movlw 0x05
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF

    movlw ct2
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x07
    movwf INDF
    incf  FSR
    movlw 0x05
    movwf INDF
    incf  FSR
    movlw 0x02
    movwf INDF

    movlw ct3
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x07
    movwf INDF
    incf  FSR
    movlw 0x05
    movwf INDF
    incf  FSR
    movlw 0x03
    movwf INDF

   
    return
jour    
    bcf   tarif_f,0
    movlw ct1
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x04
    movwf INDF
    incf  FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF

    movlw ct2
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x04
    movwf INDF
    incf  FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x02
    movwf INDF

    movlw ct3
    movwf FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x01
    movwf INDF
    incf  FSR
    movlw 0x04
    movwf INDF
    incf  FSR
    movlw 0x00
    movwf INDF
    incf  FSR
    movlw 0x03
    movwf INDF

   
    return
    
    
   

    
    
 

    

   ;-----------------------------------------------------------------------------------------
; Temporisation 350ms, 500ms, 1s
;-----------------------------------------------------------------------------------------

Tempo_1s:
	movlw	d'100'		;1 cycle
	movwf	temp3		;1 cycle
	goto	tempo2		;2 cycles

Tempo_500ms:
	movlw	d'50'		;1 cycle
	movwf	temp3		;1 cycle
	goto	tempo2		;2 cycles

Tempo_350ms:
	movlw	d'35'		;1 cycle
	movwf	temp3		;1 cycle
	goto	tempo2		;2 cycles

tempo2:
	call    Tempo_10ms	;
	decfsz	temp3		;2 cycles si temp1=0 sinon 1 cycle
	goto	tempo2		;2 cycles
	return			

;-----------------------------------------------------------------------------------------
; Temporisation 10ms, 30ms, 100ms, 150ms, 200ms
;-----------------------------------------------------------------------------------------

Tempo_200ms:
	movlw	d'200'		;1 cycle
	movwf	temp2		;1 cycle
	goto	tempo1		;2 cycles

Tempo_150ms:
	movlw	d'150'		;1 cycle
	movwf	temp2		;1 cycle
	goto	tempo1		;2 cycles

Tempo_100ms:
	movlw	d'100'		;1 cycle
	movwf	temp2		;1 cycle
	goto	tempo1		;2 cycles

Tempo_30ms:
	movlw	d'30'		;1 cycle
	movwf	temp2		;1 cycle
	goto	tempo1		;2 cycles

Tempo_10ms:
	movlw	d'10'		;1 cycle
	movwf	temp2		;1 cycle
	
tempo1:
	call	Tempo_1ms	;
	decfsz	temp2		;2 cycles si temp1=0 sinon 1 cycle
	goto	tempo1		;2 cycles
	return			

;-----------------------------------------------------------------------------------------
; Temporisation 1530us
;-----------------------------------------------------------------------------------------



Tempo_1530us:			;1530us soit 1530 cycles	(temp1*4)+4
	call	Tempo_1ms
	call	Tempo_530us

	return



;-----------------------------------------------------------------------------------------
; Temporisation 1ms, 530us, 250us
;-----------------------------------------------------------------------------------------



Tempo_1ms:			;1ms soit 1000 cycles	(temp1*4)+4
	movlw	d'249'		;1 cycle
	movwf	temp1		;1 cycle
	goto	tempo		;2 cycles

Tempo_530us:			;532us soit 532 cycles	(temp1*4)+4
	movlw	d'132'		;1 cycle
	movwf	temp1		;1 cycle
 	goto	tempo		;2 cycles

Tempo_250us:			;532us soit 532 cycles	(temp1*4)+4
	movlw	d'62'		;1 cycle
	movwf	temp1		;1 cycle
	goto	tempo		;2 cycles
 	
tempo:
	nop			;1 cycle
	decfsz	temp1		;2 cycles si temp1=0 sinon 1 cycle
	goto	tempo		;2 cycles
	return


;-----------------------------------------------------------------------------------------
; Temporisation 11us, 39us, 43us
;-----------------------------------------------------------------------------------------

Tempo_43us:			;43us soit 43 cycles	(temp1*3)+2
	movlw	d'14'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_43:
	decfsz	temp1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_43	;2 cycles
	return


Tempo_39us:			;39us soit 39 cycles	(temp1*3)+2
	movlw	d'12'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_39:
	decfsz	temp1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_39	;2 cycles
	return

Tempo_12us:			;11us soit 11 cycles	(temp1*3)+3
	movlw	d'3'		;1 cycle
	movwf	temp1		;1 cycle
	nop
Tempo_12:
	decfsz	temp1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_11	;2 cycles
	return


Tempo_11us:			;11us soit 11 cycles	(temp1*3)+2
	movlw	d'3'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_11:
	decfsz	temp1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_11	;2 cycles
	return
 
    

    

	END 			; directive fin de programme

