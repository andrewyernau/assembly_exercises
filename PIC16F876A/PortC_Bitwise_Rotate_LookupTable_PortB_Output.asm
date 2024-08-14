	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
cero	EQU	0x50
uno	EQU	0x51
dos	EQU	0x52
tres	EQU	0x53
cuatro	EQU	0x54
cinco	EQU	0x55
seis	EQU	0x56
siete	EQU	0x57
ocho	EQU	0x58
nueve	EQU	0x59
a	EQU	0x5A
be	EQU	0x5B
c	EQU	0x5C
d	EQU	0x5D
e	EQU	0x5E
f	EQU	0x5F
valor	EQU	0x60
ORG 0
goto inicio

ORG 5

inicio
	bsf	STATUS,RP0

	movlw	b'00111100'
	movwf	TRISC
	clrf	TRISB

	bcf	STATUS,RP0
	call subrutina

main
	movf	PORTC,0
	movwf	valor
	rrf	valor,1
	rrf	valor,1

	movlw	b'00001111'
	andwf	valor,1

	movlw	0x50
	addwf	valor,0

	movwf	FSR
	movf	INDF,0

	movwf	PORTB

	goto main
subrutina
	MOVLW 0xFC
	MOVWF cero
	MOVLW 0x60
	MOVWF uno
	MOVLW 0xDA
	MOVWF dos
	MOVLW 0xF2
	MOVWF tres
	MOVLW 0x66
	MOVWF cuatro
	MOVLW 0xB6
	MOVWF cinco
	MOVLW 0xBE
	MOVWF seis
	MOVLW 0xE0
	MOVWF siete
	MOVLW 0xFE
	MOVWF ocho
	MOVLW 0xE6
	MOVWF nueve
	MOVLW 0xEE
	MOVWF a
	MOVLW 0x3E
	MOVWF be
	MOVLW 0x9C
	MOVWF c
	MOVLW 0x7A
	MOVWF d
	MOVLW 0x9E
	MOVWF e
	MOVLW 0x8E
	MOVWF f
return
END 