	LIST p=16F876A
	include "p16F876A.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
ORG 0
goto inicio

ORG 5

inicio
main
	goto main
END 