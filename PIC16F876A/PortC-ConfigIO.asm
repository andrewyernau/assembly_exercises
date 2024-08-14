	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ORG 0
goto inicio

ORG 5

inicio
	bsf	STATUS,RP0
	clrf TRISC
	bcf	STATUS,RP0
	clrf PORTC
	movlw	b'10100101'
	movwf	PORTC
main
	goto main
END 