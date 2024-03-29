;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2023                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David Jos� de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		;COLOQUE AQUI SUAS NOVAS VARI�VEIS
		;N�O ESQUE�A COMENT�RIOS ESCLARECEDORES
		
		QTD_CICLOS ;VARIAVEL PARA ARMAZENAR A QUANTIDADE DE CICLOS DE 50 MILISEGUNDOS
		CICLO_FLAG ;VARIAVEL QUE � ATIVADA QUANDO UM CICLO FOI TERMINADO
		
		VARIAVEL_DELAY  ;VARIAVEL UTILIZADA PARA SER DECREMENTADA E GERAR O DEALAY

	ENDC			;FIM DO BLOCO DE DEFINI��O DE VARI�VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	
	INCF CICLO_FLAG	    ;INCREMENTA A VARI�VEL PARA MARCAR QUE MAIS UM CICLO FOI CONCLUIDO
	
	BCF INTCON, T0IF    ;SINALIZA QUE A INTERRUP��O FOI TRATADA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

;ROTINA PARA LIGAR O SINAL AMARELO DO SEMAFARO 1	
LIGA_SINAL_AMA_1

	BSF GPIO, GP4	;ACENDE O SINAL AMARELO DO SEMAFARO 1

	RETURN

;ROTINA PARA TRANSICIONAR ENTRE O VERDE DO SEMAFARO 1 PARA O VERDE DO SEMAFARO 2 (E ZERAR QUANTIDADE DE CICLOS)
TRANSICAO_VERD_1_PARA_VERD_2
	
	BSF GPIO, GP0     ;ACENDE O SINAL VERMELHO DO SEMAFARO 1 E ACENDE O SINAL VERDE DO SEMAFARO 2
	BCF GPIO, GP1	  ;APAGA O SINAL VERDE DO SEMAFARO 1 E APAGA O SINAL VERMELHO DO SEMAFARO 2
	BCF GPIO, GP4     ;APAGA O SINAL AMARELO DO SEMAFARO 1

	CLRF QTD_CICLOS	  ;ZERA A QUANTIDADE CICLOS, POIS SE ESSA ROTINA FOI EXECUTADA, O PROGRAMA EST� NO CENT�SIMO CICLO
	RETURN
	
;ROTINA PARA TRANSICIONAR ENTRE O VERDE DO SEMAFARO 2 PARA O VERDE DO SEMAFARO 1	
TRANSICAO_VERD_2_PARA_VERD_1

	BSF GPIO, GP1     ;ACENDE O SINAL VERMELHO DO SEMAFARO 2 E ACENDE O SINAL VERDE DO SEMAFARO 1
	BCF GPIO, GP0	  ;APAGA O SINAL VERDE DO SEMAFARO 2 E APAGA O SINAL VERMELHO DO SEMAFARO 1
	BCF GPIO, GP5     ;APAGA O SINAL AMARELO DO SEMAFARO 2


	RETURN
	
;ROTINA PARA LIGAR O SINAL AMARELO DO SEMAFARO 2
LIGA_SINAL_AMA_2

	BSF GPIO, GP5  ;ACENDE O SINAL AMARELO DO SEMAFARO 2
	
	RETURN

;ROTINA QUE GERA UM PEQUENO DELAY A FIM DE APROXIMAR CADA CICLO DE 50ms
DELAY
	MOVLW .18         
	MOVWF VARIAVEL_DELAY	;SETA A VARI�VEL COMO 18 DECIMAL POR GERAR UM BOM DELAY (APARTIR DE TESTES EMP�RICOS)
	
	
	DECREMENTO		;DECREMENTA A VERI�VEL AT� CHEGAR EM 0, GERANDO DE FATO O DELAY
	    DECFSZ VARIAVEL_DELAY
	    GOTO DECREMENTO
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	CLRF QTD_CICLOS  ;OS CICLOS COME�AM EM 0
	CLRF CICLO_FLAG  ;NEHUM CICLO FOI CONCLUIDO AINDA, LOGO, A FLAG COME�A DESATIVADA

	BSF GPIO, GP0    ;LIGA O GP0, QUE PRESENTA O SINAL VERMELHO DO SEMAFARO 1 E O SINAL VERDE DO SEMAFARO 2
	BCF GPIO, GP1    ;DESLIGA O GP1, QUE PRESENTA O SINAL VERMELHO DO SEMAFARO 2 E O SINAL VERDE DO SEMAFARO 1
	
	BCF GPIO, GP4    ;DESLIGA O GP4, QUE REPRESENTA O SINAL AMARELO DO SEMAFARO 1
	BCF GPIO, GP5    ;DESLIGA O GP5, QUE REPRESENTA O SINAL AMARELO DO SEMAFARO 2
	
	MOVLW .61
	MOVWF TMR0       ;SETA TMR0 COMO 61 DECIMAL PARA POSIBILITAR A CONTAGEM DE (APROXIMADAMENTE) 50 MILISEGUNDOS
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL
	
	ESPERANDO_CICLO		    ;LOOP QUE ESPERA UM CICLO SER TERMINADO PARA CHECAR OS CASOS
	    BTFSS CICLO_FLAG, B'0'
	    GOTO ESPERANDO_CICLO
	    
	CALL DELAY		    ;CHAMA A ROTINA DE DELAY PARA APROXIMAR CADA CICLO DE 50ms
	
	INCF QTD_CICLOS	    ;INCREMENTA A QUANTIDADE DE CICLOS, J� QUE SE PASSARAM MAIS 50ms
	
	MOVLW .61
	MOVWF TMR0       ;SETA TMR0 COMO 61 DECIMAL PARA POSIBILITAR A CONTAGEM DE (APROXIMADAMENTE) 50 MILISEGUNDOS
	    
	;TESTA SE PASSARAM EXATOS 40 CICLOS, OU SEJA, 2 SEGUNGOS
	MOVLW .40
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtra��o N�O for zero, pula a pr�xima instru��o
	CALL LIGA_SINAL_AMA_2  ;CASO DE FATO PASSARAM 2 SEGUNDOS, LIGA O SINAL AMARELO DO SEMAFARO 2
	
	;TESTA SE PASSARAM EXATOS 50 CICLOS, OU SEJA, 2,5 SEGUNGOS
	MOVLW .50
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtra��o N�O for zero, pula a pr�xima instru��o
	CALL TRANSICAO_VERD_2_PARA_VERD_1  ;CASO DE FATO PASSARAM 2,5 SEGUNDOS, FAZ A TRANSI��O ENTRE OS SEMAFAROS
	
	;TESTA SE PASSARAM EXATOS 90 CICLOS, OU SEJA, 4,5 SEGUNGOS
	MOVLW .90
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtra��o N�O for zero, pula a pr�xima instru��o
	CALL LIGA_SINAL_AMA_1 ;CASO DE FATO PASSARAM 4,5 SEGUNDOS, LIGA O SINAL AMARELO DO SEMAFARO 1
	
	;TESTA SE PASSARAM EXATOS 100 CICLOS, OU SEJA, 5 SEGUNGOS
	MOVLW .100
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtra��o N�O for zero, pula a pr�xima instru��o
	CALL TRANSICAO_VERD_1_PARA_VERD_2  ;CASO DE FATO PASSARAM 5 SEGUNDOS, FAZ A TRANSI��O ENTRE OS SEMAFAROS E ZERA A QTD_CLICOS
	
	
	BCF CICLO_FLAG, B'0'    ;TODAS AS HIPOTESES DA QUANTIDADE ATUAL DE CICLOS FORAM TESTADAS. SENDO ASSIM, ZERAMOS A FLAG
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
