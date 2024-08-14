	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
guarda	EQU	0x20
ORG 0
goto inicio

ORG 5

inicio
	bsf	STATUS,RP0
	movlw 0xFF ;HACEMOS SALIDA PORTB
	movwf TRISB
	bcf	STATUS,RP0
copiar
	
	movf	PORTB,0
	andlw	b'01000000'
	movwf	guarda
	goto	cambiar_entrada_salida ;PASAMOS DE SALIDA A ENTRADA
seguir
	btfsc	guarda,6
	bsf	PORTB,RB2
main
	goto inicio
cambiar_entrada_salida
	bsf	STATUS,RP0
	clrf TRISB	;HACEMOS ENTRADA PUERTOB
	bcf	STATUS,RP0
	clrf PORTB
	goto seguir
END 