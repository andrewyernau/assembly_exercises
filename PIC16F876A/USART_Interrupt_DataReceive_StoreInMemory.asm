	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ndatos_por_enviar	EQU	0x20
ndatos_por_recibir	EQU	0x21
puntero_FSR	EQU	0x22
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
	movlw	.5
	movwf	ndatos_por_recibir
	movlw	0x60
	movwf	puntero_FSR
main
	goto main
ISR
	btfsc	PIR1,RCIF
	goto	ISR_RC
	btfsc	PIR1,TXIF
	goto	ISR_TX
	retfie
ISR_RC
	movf	puntero_FSR,0
	movwf	FSR
	movf	RCREG,0
	movwf	INDF
	decfsz	ndatos_por_recibir,1
	goto	seguir_recibiendo
	goto	paquete_recibido
seguir_recibiendo
	incf	puntero_FSR,1
	retfie
END 