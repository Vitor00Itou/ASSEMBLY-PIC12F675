;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT ;WDT LIGADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00111111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO ENTRADAS PARA CONSUMO MÍNIMO
	MOVLW	B'00010000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O (GP0 COMO ANALOGICO)
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BCF	VRCON, VREN     ;GARANTINDO QUE O VREF ESTÁ DESLIGADO
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'	;menor consumo
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000000'
	MOVWF   ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*           CALCULO ESTIMADO DA ENERGIA CONSUMIDA                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA CICLO DE PROGRAMA DURA 2199933µs ------------------------------------
; O PIC PASSA 2199886µs EM MODO SLEEP COM WDT LIGADO	- 5V - 17µA
; O PIC PASSA 47-58µs LIGADO EM 4MHz INSTOSC		- 5V - 1.100µA
; O PIC PASSA 2199877µs COM UMA SAIDA ALIMENTAZNDO UM LED	- 5V - 25.000µA
; O PIC PASSA 28µs COM O CONVERSOR A/D LIGADO              - 5V - 0,005µA (1 - 0,995) 
;
;UMA EM UMA HORA OCORRERÁ APROXIMADAMENTE 1.636,41347259213 CICLOS
;
;
; CADA CICLO DE HORA DURA 3.600,000000000022s = 1h  ------------------------------------
; O PIC PASSA 3.599,92308856681s = 0,9999786357130029h EM MODO SLEEP COM WDT LIGADO	- 5V - 17µA = 85µW
; O PIC PASSA 0,0850935005747908s = 0,000023637083492997h LIGADO EM 4MHz INSTOSC		- 5V - 1.100µA = 5.500µw
; O PIC PASSA 3.599,908360845557s = 0,9999745446793214h COM UMA SAIDA ALIMENTAZNDO UM LED	- 5V - 25.000µA = 125.000µW
; O PIC PASSA 0,0458195772325796s = 0,000012727660342383h COM O CONVERSOR A/D LIGADO              - 5V - 0,005µA (1 - 0,995) = 0,025µW 
	
; O PIC CONSOME 85µW*0,9999786357130029h  EM MODO SLEEP COM WDT LIGADO DURANTE UMA HORA
; O PIC CONSOME 5.500µw*0,000023637083492997h LIGADO EM 4MHz INSTOSC DURANTE UMA HORA		
; O PIC CONSOME 125.000µW*0,9999745446793214h COM UMA SAIDA ALIMENTAZNDO UM LED DURANTE UMA HORA
; O PIC CONSOME 0,025µW*0,000012727660342383h COM O CONVERSOR A/D LIGADO DURANTE UMA HORA

; O PIC CONSOME 84,99745µWh  EM MODO SLEEP COM WDT LIGADO DURANTE UMA HORA
; O PIC CONSOME 0,11µWh LIGADO EM 4MHz INSTOSC DURANTE UMA HORA		
; O PIC CONSOME 124996.25µWh COM UMA SAIDA ALIMENTAZNDO UM LED DURANTE UMA HORA
; O PIC CONSOME 0.00025µWh COM O CONVERSOR A/D LIGADO DURANTE UMA HORA
	

;84,99745µWh+0,11µWh+124996.25µWh+0.00025µWh=125081.3577µWh
;O PIC CONSOME 125081.3577µWh em uma hora de execução considerando o consumo do led
	
;DESCONSIDERANDO O CONSUMO DO LED:
;84,99745µWh+0,11µWh+0.00025µWh=85,1077µWh
;O PIC CONSOME 85,1077µWh em uma hora de execução desconsiderando o consumo do led
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	;CORPO DA ROTINA PRINCIPAL
	
	BSF ADCON0, ADON   ;LIGA O CONVERSOR ANALOGICO/DIGITAL
	BANK1				;ALTERA PARA O BANCO 1
	BSF ANSEL, 0                    ;ALTERA O GP0 PARA ANALOGICO
	BANK0
	
	
	BSF ADCON0, GO     ;COMEÇA A CONVERSÃO
	CONVERTENDO
	    BTFSC ADCON0, GO
	    GOTO CONVERTENDO
	    
	BCF ADCON0, ADON   ;DESLIGA O CONVERSOR ANALOGICO/DIGITAL
	BANK1				;ALTERA PARA O BANCO 1
	BCF ANSEL, 0                    ;ALTERA O GP0 PARA DIGITAL
	BANK0
	
	;TESTE 2V
	MOVLW .102
	SUBWF ADRESH, W
	BTFSC STATUS, C   ;SE O RESULTADO FOR NEGATIVO (MENOS QUE 2V) PULA
	GOTO PROXIMO_TESTE1
	
	MENOR_2V
	    BANK1				;ALTERA PARA O BANCO 1
	    BCF TRISIO, 1                    ;ALTERA O GP1 PARA SAIDA
	    BANK0
	    
	    BSF GPIO, GP1                   ;LIGA GP1 INDICANDO TENSÃO V<2
	    
	    SLEEP
	    NOP				     ;NOP POR CONTA DO PRE-FETCH DA PROXIMA INSTRUÇÃO NO SLEEP
	    
	    BCF GPIO, GP1                   ;DESLIGA GP1
	    
	    BANK1				;ALTERA PARA O BANCO 1
	    BSF TRISIO, 1                    ;ALTERA O GP1 PARA ENTRADA
	    BANK0
	    
	    GOTO MAIN
	    
	    
	PROXIMO_TESTE1
	MOVLW .153
	SUBWF ADRESH, W
	BTFSC STATUS, C   ;SE O RESULTADO FOR NEGATIVO (MAIOR OU IGUAL A 2V E MENOR QUE 3) PULA
	GOTO PROXIMO_TESTE2
	
	MAIOR_OU_IGUAL_2V_MENOR_3V
	    BANK1				;ALTERA PARA O BANCO 1
	    BCF TRISIO, 2                    ;ALTERA O GP2 PARA SAIDA
	    BANK0
	    
	    BSF GPIO, GP2                   ;LIGA GP2 INDICANDO A TENSÃO 2<=V<3
	    
	    SLEEP
	    NOP				 ;NOP POR CONTA DO PRE-FETCH DA PROXIMA INSTRUÇÃO NO SLEEP
	    
	    BCF GPIO, GP2                   ;DESLIGA GP2
	    
	    BANK1			    ;ALTERA PARA O BANCO 1
	    BSF TRISIO, 2                    ;ALTERA O GP2 PARA ENTRADA
	    BANK0
	    
	    GOTO MAIN
	
	
	PROXIMO_TESTE2
	MOVLW .204
	SUBWF ADRESH, W
	BTFSC STATUS, Z   ;SE O RESULTAOD FOR DIFERENTE 0 (DIFERENTE DE 4V) PULA
	GOTO MAIOR_OU_IGUAL_3V_MENOR_OU_IGUAL_4V
	BTFSC STATUS, C   ;SE O RESULTADO FOR NEGATIVO (MAIOR OU IGUAL A 3V E MENOR QUE 4) PULA
	GOTO MAIOR_4V
	
	MAIOR_OU_IGUAL_3V_MENOR_OU_IGUAL_4V
	    BANK1				;ALTERA PARA O BANCO 1
	    BCF TRISIO, 4                    ;ALTERA O GP4 PARA SAIDA
	    BANK0
	    
	    BSF GPIO, GP4                   ;LIGA GP2 INDICANDO A TENSÃO 3<=V<=4
	    
	    SLEEP
	    NOP				     ;NOP POR CONTA DO PRE-FETCH DA PROXIMA INSTRUÇÃO NO SLEEP
	    
	    BCF GPIO, GP4                   ;DESLIGA GP4
	    
	    BANK1			    ;ALTERA PARA O BANCO 1
	    BSF TRISIO, 4                   ;ALTERA O GP4 PARA ENTRADA
	    BANK0
	    
	    GOTO MAIN
	
	
	MAIOR_4V
	    BANK1				;ALTERA PARA O BANCO 1
	    BCF TRISIO, 5                    ;ALTERA O GP5 PARA SAIDA
	    BANK0
	    
	    BSF GPIO, GP5                   ;LIGA GP2 INDICANDO A TENSÃO V<4
	    
	    SLEEP
	    NOP				    ;NOP POR CONTA DO PRE-FETCH DA PROXIMA INSTRUÇÃO NO SLEEP
	    
	    BCF GPIO, GP5                   ;DESLIGA GP5
	    
	    BANK1			    ;ALTERA PARA O BANCO 1
	    BSF TRISIO, 5                    ;ALTERA O GP5 PARA ENTRADA
	    BANK0
	
	    GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
