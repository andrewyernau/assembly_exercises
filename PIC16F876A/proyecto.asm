	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ndatos_por_enviar	EQU	0x20
ndatos_por_recibir	EQU	0x21
puntero_FSR	EQU	0x22
PWM	EQU	0x23
TH	EQU	0x24
STATUS_LED	EQU	0x25
SAVE_TH	EQU	0x26
PUNTERO	EQU	0x27
SAVE_TH_REMOTE	EQU	0x28
XOR_TH_AD	EQU	0x29
PUNTERO_TX	EQU	0x2A
ORG 0
goto inicio
ORG 4
goto ISR
ORG 5
inicio
	;configuracion general de puertos
	bsf	STATUS,RP0
	clrf	TRISC;led
	clrf	TRISB;on/off led
	clrf	TRISA;AD del led
	bsf	TRISB,0
	bsf	TRISA,0
	bsf	OPTION_REG,INTEDG
	bcf	OPTION_REG,T0CS
	bsf	OPTION_REG,T0SE
	bcf	OPTION_REG,PSA
	bcf	OPTION_REG,PS2
	bcf	OPTION_REG,PS1
	bcf	OPTION_REG,PS0
	bcf	STATUS,RP0
	;configuracion de AD
	bsf ADCON0,ADCS1
	bcf ADCON0,ADCS0
	bcf ADCON0,CHS2
	bcf ADCON0,CHS1
	bcf ADCON0,CHS0
	bsf ADCON0,ADON
	bsf STATUS,RP0
	bcf ADCON1,ADFM
	bsf ADCON1,PCFG3
	bsf ADCON1,PCFG2
	bsf ADCON1,PCFG1
	bcf ADCON1,PCFG0
	bcf	STATUS,RP0
	;configuramos RC
	bsf	RCSTA,SPEN
	bcf	RCSTA,RX9
	bsf	RCSTA,CREN
	bcf	RCSTA,FERR
	bsf	RCSTA,OERR
	;configuramos TX sin activarlo
	bsf	STATUS, RP0
	bcf	TXSTA,TX9
	bsf	TXSTA,TXEN
	bcf	TXSTA,SYNC
	bsf	TXSTA,BRGH
	movlw	.25
	movwf	SPBRG
	bcf	STATUS,RP0
	;configuracion tiempo TMR0
	movlw	.56
	movwf	TMR0
	;configuracion general de interrupciones
	bsf INTCON,T0IE
	bsf INTCON,INTE
	bsf STATUS,RP0
	bsf	PIE1,ADIE	;activamos AD
	bsf	PIE1,RCIE	;activamos RC
	bcf STATUS,RP0
	bsf INTCON,PEIE	;activamos interrupciones externas
	;bsf INTCON,RBIE
	bsf INTCON,GIE

	;configuracion de valores
	clrf	XOR_TH_AD
	movlw	.10
	movwf	SAVE_TH
	movwf	TH
	movlw	.32
	movwf	PWM
	clrf	PORTB
	clrf	PORTA
	clrf	PORTC
	clrf	STATUS_LED
	movlw	.6
	movwf	ndatos_por_recibir
	call mensajes
	movlw	0x90
	movwf	PUNTERO

main
	goto main
ISR
	btfsc	INTCON,INTF
	goto ISR_RB0
;	btfsc	INTCON,RBIF
;	goto ISR_RB
	btfsc	INTCON,T0IF
	goto ISR_TMR0
	btfsc	PIR1,ADIF
	goto ISR_AD
	btfsc	PIR1,RCIF
	goto ISR_RX
	btfsc	PIR1,TXIF
	goto ISR_TX
	retfie
ISR_RB0
	btfss	STATUS_LED,0
	goto activar_led
	bcf	PORTC,0
	bcf	STATUS_LED,0
	bcf	INTCON,INTF
	retfie
activar_led	
	bcf	INTCON,INTF
	bsf	STATUS_LED,0
	bsf	PORTC,0
	retfie
ISR_TMR0
	bcf	INTCON,T0IF
	movlw	.56
	movwf	TMR0
	bsf	ADCON0,GO ;queremos que paralelamente AD funcione
	btfsc	STATUS_LED,0; si está activo el led a través de RB0 haz funcionar el programa
	goto funcion_PWM
	retfie
funcion_PWM
	decfsz	PWM,1
	goto PWM_vale_otro
	goto PWM_vale_cero
PWM_vale_cero
	movlw .32
	movwf PWM
	bsf	PORTC,0; al final de cada ciclo siempre PORTC valdrá 0 sin importar el valor de TH
	movf	SAVE_TH,0
	movwf	TH
	retfie
PWM_vale_otro
	decfsz	TH,1; mientras que TH valga mas que 0 el led se mantiene activo
	goto TH_continua
	bcf	PORTC,0; TH ya vale 0 quiere decir que ahora el led ha de estar apagado
	retfie
TH_continua
	retfie
ISR_AD
	bcf	PIR1,ADIF
	movf	ADRESH,0
	andwf	b'11111000',0
	xorwf	XOR_TH_AD,0 ;XOR con el resultado anterior de AD para hacer que funcione la USART
	btfss	STATUS,Z ;si da 0 quiere decir que es el mismo resultado por lo tanto podemos hacer skip
	retfie
	movwf	SAVE_TH
	movwf	XOR_TH_AD ;actualizamos el valor para el siguiente XOR
	rrf	SAVE_TH,1
	rrf	SAVE_TH,1
	rrf	SAVE_TH,1
	movf	SAVE_TH,0
	movwf	TH
	subwf	1,0
	btfsc	STATUS,Z ;comprobemos que TH no vale 0
	goto	transformar_TH_a_uno
	retfie
transformar_TH_a_uno
	movlw	.1
	movwf	SAVE_TH
	movwf	TH
	retfie
ISR_RX
	movf	PUNTERO,0
	movwf	FSR
	movf	RCREG,0
	movwf	INDF
	decfsz	ndatos_por_recibir,1
	goto	sigue_recibiendo
	goto	completada_recepcion
sigue_recibiendo
	incf	PUNTERO,1
	retfie
completada_recepcion
	movf	0x90,0
	sublw 's'
	btfss	STATUS,Z
	goto	enviar_notfound
	
	movf	0x91,0
	sublw 'd'
	btfss	STATUS,Z
	goto	enviar_notfound

	movf	0x92,0
	sublw 'b'
	btfss	STATUS,Z
	goto	enviar_notfound

	movf	0x93,0
	sublw 'm'
	btfss	STATUS,Z
	goto	enviar_notfound

	movf	0x94,0
	sublw 'S'
	btfss	STATUS,Z
	goto	comprobarT

	movf	0x95,0
	sublw '1'
	btfss	STATUS,Z
	goto	comprobar0
	bsf	STATUS_LED,0 ;es sbdmS1 encendemos led
	bsf	PORTC,0
	retfie
comprobar0
	movf	0x95,0
	sublw '0'
	btfss	STATUS,Z
	goto	comprobarA
	bcf	STATUS_LED,0 ;es sbdmS0 apagamos led	
	bcf	PORTC,0
	retfie
comprobarA
	movf	0x95,0
	sublw 'A'
	btfss	STATUS,Z
	goto	enviar_invalidcommand
	;es sbdmSA  enviamos estado L1 encendido o apagado
	btfss	STATUS_LED,0
	goto enviar_L10
	movf 0x53,0 ;envia L11
	movwf	PUNTERO_TX
	movlw	.5
	movwf	ndatos_por_enviar
	call	activar_tx
	retfie
enviar_L10
	movf 0x4E,0
	movwf	PUNTERO_TX
	movlw	.5
	movwf	ndatos_por_enviar
	call	activar_tx
	retfie
comprobarT
	movf	0x94,0
	sublw 'T'
	btfss	STATUS,Z
	goto	enviar_invalidcommand
;analizamos ahora el 6o digito
	movf	0x95,0
	andlw	b'00011111'
	movwf	SAVE_TH_REMOTE
	subwf	1,0
	btfsc	STATUS,Z ;comprobemos que TH no vale 0
	goto	transformar_TH_a_uno_REMOTE

transformar_TH_a_uno_REMOTE
	movlw	.1
	movwf	SAVE_TH_REMOTE
	movwf	TH
	retfie
enviar_notfound
	movf 0x69,0
	movwf	PUNTERO_TX
	movlw	.11
	movwf	ndatos_por_enviar
	call	activar_tx
	retfie
enviar_invalidcommand
	movf 0x58,0
	movwf	PUNTERO_TX
	movlw	.17
	movwf	ndatos_por_enviar
	call	activar_tx
	retfie
activar_tx
	bsf	STATUS,RP0
	bsf	PIE1,TXIE
	bcf	STATUS,RP0
	return
ISR_TX
	movf	PUNTERO_TX,0
	movwf	FSR
	movf	INDF,0
	movwf	TXREG
	decfsz	ndatos_por_enviar,1
	goto	continuar_envio
	
	bsf	STATUS,RP0
	bcf	PIE1,TXIE
	bcf	STATUS,RP0
	retfie
continuar_envio
	incf	FSR,1
	retfie
mensajes
	movlw 'L'
	movwf	0x4E
	movlw '1'
	movwf	0x4F
	movlw '0'
	movwf	0x50
	movlw .10
	movwf	0x51
	movlw .13
	movwf	0x52
	movlw 'L'
	movwf	0x53
	movlw '1'
	movwf	0x54
	movlw '1'
	movwf	0x55
	movlw .10
	movwf	0x56
	movlw .13
	movwf	0x57
	movlw 'I'
	movwf	0x58
	movlw 'n'
	movwf	0x59
	movlw 'v'
	movwf	0x5A
	movlw 'a'
	movwf	0x5B
	movlw 'l'
	movwf	0x5C
	movlw 'i'
	movwf	0x5D
	movlw 'd'
	movwf	0x5E
	movlw ' '
	movwf	0x5F
	movlw 'c'
	movwf	0x60
	movlw 'o'
	movwf	0x61
	movlw 'm'
	movwf	0x62
	movlw 'm'
	movwf	0x63
	movlw 'a'
	movwf	0x64
	movlw 'n'
	movwf	0x65
	movlw 'd'
	movwf	0x66
	movlw .10
	movwf	0x67
	movlw .13
	movwf	0x68
	movlw 'N'
	movwf	0x69
	movlw 'o'
	movwf	0x6A
	movlw 't'
	movwf	0x6B
	movlw ' '
	movwf	0x6C
	movlw 'f'
	movwf	0x6D
	movlw 'o'
	movwf	0x6E
	movlw 'u'
	movwf	0x6F
	movlw 'n'
	movwf	0x70
	movlw 'd'
	movwf	0x71
	movlw .10
	movwf	0x72
	movlw .13
	movwf	0x73
	return	
END