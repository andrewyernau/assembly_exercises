	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ndatos_por_enviar	EQU	0x20
ndatos_por_recibir	EQU	0x21

ORG 0
goto inicio
ORG 4
goto ISR
ORG 5

inicio
	bsf	STATUS,RP0
	clrf TRISB
	bsf	TRISC,7
	bcf	TRISC,6

	bsf	PIE1,RCIE	
	bcf	TXSTA,TX9
	bsf	TXSTA,TXEN
	bcf	TXSTA,SYNC
	bsf	TXSTA,BRGH
	movlw	.25
	movwf	SPBRG
	bcf	STATUS,RP0

	bsf	RCSTA,SPEN
	bcf	RCSTA,RX9
	bsf	RCSTA,CREN
	bcf	RCSTA,FERR
	bsf	RCSTA,OERR

	bsf	INTCON,PEIE
	bsf	INTCON,GIE
	clrf PORTB

main
	goto main
ISR
	movf	RCREG,0
	movwf	TXREG
	movwf	PORTB
	retfie
END 