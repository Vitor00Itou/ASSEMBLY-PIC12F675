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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

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
		CONTADOR
		FLAGS           ;BIT 0  ------  1 - TENSÃO MAIOR QUE VBAT
				;		0 - TENSÃO MENOR QUE VBAT

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

_DELAY

	MOVLW .5
	MOVWF CONTADOR
	
	ESPERANDO1
	    DECFSZ CONTADOR
	    GOTO ESPERANDO1

	RETURN
	
_DORME_5S
	
	MOVLW .2
	MOVWF CONTADOR
	CLRWDT
	
	ESPERANDO2
	    SLEEP
	    NOP
	    DECFSZ CONTADOR
	    GOTO ESPERANDO2
	    
	;DIMINUI O WTD PARA PRÓXIMO DE 600ms
	BANK1
	MOVLW	B'00001101'
	MOVWF	OPTION_REG
	BANK0
	
	SLEEP
	NOP
	
	;RETORNA PARA A CONFIGURAÇÃO PADRÃO
	BANK1
	MOVLW	B'00001111'
	MOVWF	OPTION_REG
	BANK0
	
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00111111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO ENTRADAS PARA CONSUMO MÍNIMO
	MOVLW	B'00000000'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O (GP0 COMO ANALOGICO)
	MOVLW	B'00001111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	; 3,86 * (3/5) = 2,316
	;VALOE MAIS PRÓXIMO: LOW RANGE 11 = 2,2916666
	MOVLW	B'00101011'
	MOVWF	VRCON
	BANK0				;RETORNA PARA O BANCO	
	MOVLW	B'00000111'	;menor consumo
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000000'
	MOVWF   ADCON0


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	;APARTIR DO MODO DE ECONOMIA MÁXIMA INICIA AS CHECAGENS
	;CADA CHECAGEM DURA CERCA DE 8µs
	INICIO_CHECAGENS
	    ;LIMPA AS FLAGS E O WTF
	    CLRF FLAGS
	
	    CHECAGEM0_0000
		CLRWDT
		BTFSC GPIO, GP5   ;CHECA SE GP5 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP0   ;CHECA SE GP0 É 0
		GOTO CHECAGEM0_0000
		
	    CHECAGEM1_0000
		BTFSC GPIO, GP5   ;CHECA SE GP5 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP0   ;CHECA SE GP0 É 0
		GOTO CHECAGEM0_0000
	
	    CHECAGEM2_0000
		BTFSC GPIO, GP5   ;CHECA SE GP5 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP0   ;CHECA SE GP0 É 0
		GOTO CHECAGEM0_0000
	
	    CHECAGEM3_0000
		BTFSC GPIO, GP5   ;CHECA SE GP5 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
		GOTO CHECAGEM0_0000
		BTFSC GPIO, GP0   ;CHECA SE GP0 É 0
		GOTO CHECAGEM0_0000

		
	;SE CHEGOU AQUI, É PORQUE DE FATO O ENDEREÇO 0000 FOI LANÇADO. ESPERA PARA LER O ENDEREÇO
	MOVLW .3
	MOVWF CONTADOR
	ESPERA_ENDERECO
	    CLRWDT
	    BTFSC GPIO, GP5   ;CHECA SE GP5 É 0
	    GOTO LENDO_ENDERECO
	    BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
	    GOTO LENDO_ENDERECO
	    BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
	    GOTO LENDO_ENDERECO
	    BTFSC GPIO, GP0   ;CHECA SE GP0 É 0
	    GOTO LENDO_ENDERECO
	    
	    DECFSZ CONTADOR
	    GOTO ESPERA_ENDERECO ;SE O ENDEREÇO AINDA FOR 0000,E O LIMITE DE ESPERA AINDA NÃO TIVER ESTOURADO, VOLTA PARA A ESPERA
	    
	;SE CHEGOU AQUI, É PORQUE FOI PASSADO O ENDEREÇO 0000, E AGORA ESTÁ SENDO PASSADO O ENDEREÇO DO ESCRAAVO
	;CASO O ENDEREÇO DO ESCRAVO NÃO SEJA O ENDEREÇO ESPERADO (1001), VOLTA AO INICIO DAS CHECAGENS
	LENDO_ENDERECO
	    BTFSS GPIO, GP5   ;CHECA SE GP5 É 1
	    GOTO INICIO_CHECAGENS
	    BTFSC GPIO, GP3   ;CHECA SE GP3 É 0
	    GOTO INICIO_CHECAGENS
	    BTFSC GPIO, GP2   ;CHECA SE GP2 É 0
	    GOTO INICIO_CHECAGENS
	    BTFSS GPIO, GP0   ;CHECA SE GP0 É 1
	    GOTO INICIO_CHECAGENS
	    
	;SE CHEGOU AQUI, É PORQUE O ENDEREÇO FOI IDENTIFICADO CORRENTAMENE
	ENDERECO_CORRETO
	    BANK1
	    BSF VRCON, VREN ;LIGA O VREF
	    BSF ANSEL, ANS1 ;ALTERA GP1 PARA ANALOGICO
	    BANK0
	    
	    ;ACIONA O COMPRADOR PARA O MODE DE COMPARAÇÃO COM REFERENCIA.
	    MOVLW B'00000100'
	    MOVWF CMCON
	    
	    ;CHAMA UM DELAY PARA ESPERAR O TEMPO DE APROXIMADAMENTE 10µs NECESSÁRIOS PARA 
	    ;A MEDIÇÃO DO COMPARADOR APÓS ALTERAÇÃO DE MODO COMO EXPECIFICADO NO DATASHEET
	    CALL _DELAY
	    
	    BTFSS CMCON, COUT
	    BSF FLAGS, 0        ;SE FOR MAIOR, SETA A FLAG
	    
	    ;DESLIGA O COMPARADOR
	    MOVLW B'00000100'
	    MOVWF CMCON
	    
	    BANK1
	    BCF VRCON, VREN ;DESLIGA O VREF
	    BCF ANSEL, ANS1 ;ALTERA GP1 PARA DIGITAL
	    BANK0
	    
	    
	    ;TESTA A FLAG
	    BTFSC FLAGS, 0
	    GOTO INICIO_CHECAGENS  ;CASO A FLAG ESTEJA EM 1, É PORQUE A TENSÃO É MAIOR QUE VBAT.
	    
	    ;CASO SEJA MENOR
	    BANK1
	    BCF TRISIO, GP4  ;COLOCA GP4 COMO SAIDA
	    BANK0
	    BSF GPIO, GP4   ;LIGAA GP4
	    
	    CALL _DORME_5S
	    
	    BCF GPIO, GP4   ;DESLIGAA GP4
	    BANK1
	    BSF TRISIO, GP4  ;COLOCA GP4 COMO ENTRADA
	    BANK0
	
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
