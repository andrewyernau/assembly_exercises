	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
guarda	EQU	0x20
ORG 0
goto inicio

ORG 5

inicio
	bsf	STATUS,RP0
	movlw	b'00000110'
	movwf	ADCON1
	movlw	b'11111111' ;HACEMOS SALIDA PORTA
	movwf	TRISA
	clrf	TRISC ;HACEMOS ENTRADA PORTC

	bcf	STATUS,RP0
	clrf	PORTC
copiar
	
	movf	PORTA,0
	movwf	guarda
	btfsc	guarda,1
	bsf	PORTC,RC3
main
	goto inicio

END 