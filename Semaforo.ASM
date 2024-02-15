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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		
		QTD_CICLOS ;VARIAVEL PARA ARMAZENAR A QUANTIDADE DE CICLOS DE 50 MILISEGUNDOS
		CICLO_FLAG ;VARIAVEL QUE É ATIVADA QUANDO UM CICLO FOI TERMINADO
		
		VARIAVEL_DELAY  ;VARIAVEL UTILIZADA PARA SER DECREMENTADA E GERAR O DEALAY

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
	
	INCF CICLO_FLAG	    ;INCREMENTA A VARIÁVEL PARA MARCAR QUE MAIS UM CICLO FOI CONCLUIDO
	
	BCF INTCON, T0IF    ;SINALIZA QUE A INTERRUPÇÃO FOI TRATADA

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

;ROTINA PARA LIGAR O SINAL AMARELO DO SEMAFARO 1	
LIGA_SINAL_AMA_1

	BSF GPIO, GP4	;ACENDE O SINAL AMARELO DO SEMAFARO 1

	RETURN

;ROTINA PARA TRANSICIONAR ENTRE O VERDE DO SEMAFARO 1 PARA O VERDE DO SEMAFARO 2 (E ZERAR QUANTIDADE DE CICLOS)
TRANSICAO_VERD_1_PARA_VERD_2
	
	BSF GPIO, GP0     ;ACENDE O SINAL VERMELHO DO SEMAFARO 1 E ACENDE O SINAL VERDE DO SEMAFARO 2
	BCF GPIO, GP1	  ;APAGA O SINAL VERDE DO SEMAFARO 1 E APAGA O SINAL VERMELHO DO SEMAFARO 2
	BCF GPIO, GP4     ;APAGA O SINAL AMARELO DO SEMAFARO 1

	CLRF QTD_CICLOS	  ;ZERA A QUANTIDADE CICLOS, POIS SE ESSA ROTINA FOI EXECUTADA, O PROGRAMA ESTÁ NO CENTÉSIMO CICLO
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
	MOVWF VARIAVEL_DELAY	;SETA A VARIÁVEL COMO 18 DECIMAL POR GERAR UM BOM DELAY (APARTIR DE TESTES EMPÍRICOS)
	
	
	DECREMENTO		;DECREMENTA A VERIÁVEL ATÉ CHEGAR EM 0, GERANDO DE FATO O DELAY
	    DECFSZ VARIAVEL_DELAY
	    GOTO DECREMENTO
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10100000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	CLRF QTD_CICLOS  ;OS CICLOS COMEÇAM EM 0
	CLRF CICLO_FLAG  ;NEHUM CICLO FOI CONCLUIDO AINDA, LOGO, A FLAG COMEÇA DESATIVADA

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
	
	INCF QTD_CICLOS	    ;INCREMENTA A QUANTIDADE DE CICLOS, JÁ QUE SE PASSARAM MAIS 50ms
	
	MOVLW .61
	MOVWF TMR0       ;SETA TMR0 COMO 61 DECIMAL PARA POSIBILITAR A CONTAGEM DE (APROXIMADAMENTE) 50 MILISEGUNDOS
	    
	;TESTA SE PASSARAM EXATOS 40 CICLOS, OU SEJA, 2 SEGUNGOS
	MOVLW .40
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	CALL LIGA_SINAL_AMA_2  ;CASO DE FATO PASSARAM 2 SEGUNDOS, LIGA O SINAL AMARELO DO SEMAFARO 2
	
	;TESTA SE PASSARAM EXATOS 50 CICLOS, OU SEJA, 2,5 SEGUNGOS
	MOVLW .50
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	CALL TRANSICAO_VERD_2_PARA_VERD_1  ;CASO DE FATO PASSARAM 2,5 SEGUNDOS, FAZ A TRANSIÇÃO ENTRE OS SEMAFAROS
	
	;TESTA SE PASSARAM EXATOS 90 CICLOS, OU SEJA, 4,5 SEGUNGOS
	MOVLW .90
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	CALL LIGA_SINAL_AMA_1 ;CASO DE FATO PASSARAM 4,5 SEGUNDOS, LIGA O SINAL AMARELO DO SEMAFARO 1
	
	;TESTA SE PASSARAM EXATOS 100 CICLOS, OU SEJA, 5 SEGUNGOS
	MOVLW .100
	SUBWF QTD_CICLOS, W
	BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	CALL TRANSICAO_VERD_1_PARA_VERD_2  ;CASO DE FATO PASSARAM 5 SEGUNDOS, FAZ A TRANSIÇÃO ENTRE OS SEMAFAROS E ZERA A QTD_CLICOS
	
	
	BCF CICLO_FLAG, B'0'    ;TODAS AS HIPOTESES DA QUANTIDADE ATUAL DE CICLOS FORAM TESTADAS. SENDO ASSIM, ZERAMOS A FLAG
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
