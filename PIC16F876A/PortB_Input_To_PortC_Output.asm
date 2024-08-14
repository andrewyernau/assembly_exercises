	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ORG 0
goto inicio

ORG 5

inicio
	bsf	STATUS,RP0
	clrf TRISC
	movlw b'11111111'
	movwf TRISB
	bcf	STATUS,RP0
copiar
	clrf PORTC
	movf	PORTB,0
	movwf	PORTC
main
	goto copiar
END 