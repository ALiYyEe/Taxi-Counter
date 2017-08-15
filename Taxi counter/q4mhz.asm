;
;			QUARTZ : 4MHz	(cycle : 1us)			V1.0e
;
;									O.REZE	06/2003
;-----------------------------------------------------------------------------------------
;
;	constantes a definir dans le programme principal:
;			- temp3, temp2, temp1
;
;
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
	decfsz	temp3,1		;2 cycles si temp1=0 sinon 1 cycle
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
	decfsz	temp2,1		;2 cycles si temp1=0 sinon 1 cycle
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
;	goto	tempo		;2 cycles
 	
tempo:
	nop			;1 cycle
	decfsz	temp1,1		;2 cycles si temp1=0 sinon 1 cycle
	goto	tempo		;2 cycles
	return


;-----------------------------------------------------------------------------------------
; Temporisation 11us, 39us, 43us
;-----------------------------------------------------------------------------------------

Tempo_43us:			;43us soit 43 cycles	(temp1*3)+2
	movlw	d'14'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_43:
	decfsz	temp1,1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_43	;2 cycles
	return


Tempo_39us:			;39us soit 39 cycles	(temp1*3)+2
	movlw	d'12'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_39:
	decfsz	temp1,1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_39	;2 cycles
	return

Tempo_12us:			;11us soit 11 cycles	(temp1*3)+3
	movlw	d'3'		;1 cycle
	movwf	temp1		;1 cycle
	nop
Tempo_12:
	decfsz	temp1,1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_11	;2 cycles
	return


Tempo_11us:			;11us soit 11 cycles	(temp1*3)+2
	movlw	d'3'		;1 cycle
	movwf	temp1		;1 cycle
Tempo_11:
	decfsz	temp1,1		;2 cycles si temp1=0 sinon 1 cycle
	goto	Tempo_11	;2 cycles
	return

