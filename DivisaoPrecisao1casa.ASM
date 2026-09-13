;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      OUTUBRO DE 2022                            *
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
		WORK
		DADO
		RESTO
		INTEIRA
		DECIMAL1
		DECIMAL2
		RESULT_MULT
		CONTAGEM_MULT
		CONTAGEM_DIV

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
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	;Setando as variaves para divisão
	MOVLW .22
	MOVWF DADO
	MOVLW .13
	MOVWF WORK
	
	;Setando as variaveis para o calculo
	MOVFW WORK
	MOVWF RESULT_MULT  ;Multiplicação por 1
	MOVLW .1
	MOVWF CONTAGEM_DIV
	MOVWF CONTAGEM_MULT
	
	
	REALIZA_DIVISAO
	    MOVFW RESULT_MULT
	    SUBWF DADO, 0    ;Subtrai W(equivalente ao resultado da multiplicação) do DADO e armazena em W
	    BTFSS STATUS, C  ;Se o resultado da subtração for não-negativa, pule a próxima instrução
	    GOTO PASSOU_DO_DIVIDENDO  ;Se o resultado é negativo, significa que passamos o valor do dividendo
	    BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	    GOTO VALOR_EXATO
	    
	    ;Aumenta a contagem da multiplicação
	    INCF CONTAGEM_MULT
	    MOVFW WORK
	    ADDWF RESULT_MULT, 1  ;Soma o W(divisor) ao result_mullt, aumentando o multuplicador em 1 (O '1' quer dizer que o resultaado vai para F)
	    GOTO REALIZA_DIVISAO
	    
	PASSOU_DO_DIVIDENDO
	
	    ;Achando o resto
	    MOVWF RESTO ;O resto recebe o valor NEGATIVO que estava em W;
	    MOVFW WORK
	    ADDWF RESTO, 1  ;Adicionamos o divisor ao valor negativo obtido da subtração para obter o resto da divisão
	    
	    ;Localizando etapa da divisão
	    MOVLW .2
	    SUBWF CONTAGEM_DIV, 0 ;Subtrai W(2) do CONTAGEM_DIV e armazena em W
	    BTFSS STATUS, C  ;Se o resultado da subtração for não-negativa, pule a próxima instrução
	    GOTO PD_ETAPA1
	    BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	    GOTO PD_ETAPA2
	    GOTO PD_ETAPA3
	    
	    PD_ETAPA1
		MOVFW CONTAGEM_MULT
		MOVWF INTEIRA
		DECF INTEIRA ;O valor da parte inteira será o CONTAGEM_MULT que ultrapassou o valor, decrementado 1
		GOTO MULTIPLICA_RESTO
		
	    PD_ETAPA2
		MOVFW CONTAGEM_MULT
		MOVWF DECIMAL1
		DECF DECIMAL1 ;O valor da parte DECIMAL1 será o resultado da multiplicação que ultrapassou o valor, decrementado 1
		GOTO MULTIPLICA_RESTO
		
	    PD_ETAPA3
		MOVFW CONTAGEM_MULT
		MOVWF DECIMAL2
		DECF DECIMAL2 ;O valor da parte DECIMAL1 será o resultado da multiplicação que ultrapassou o valor, decrementado 1
		GOTO CALCULA_RESULTADO
	    
	    MULTIPLICA_RESTO
		MOVLW 9
		MOVWF CONTAGEM_MULT
		
		MOVFW RESTO

		; Multiplica o resto po 10
		SOMANDO
		    ADDWF RESTO, 1
		    DECFSZ CONTAGEM_MULT, 1
		    GOTO SOMANDO
		
		MOVFW RESTO
		MOVWF DADO
		
		MOVFW WORK
		MOVWF RESULT_MULT  ;Multiplicação por 1
		MOVLW .1
		MOVWF CONTAGEM_MULT
		INCF CONTAGEM_DIV
		GOTO REALIZA_DIVISAO
	

	VALOR_EXATO
	    ;Localizando etapa da divisão
	    MOVLW .2
	    SUBWF CONTAGEM_DIV, 0 ;Subtrai W(2) do CONTAGEM_DIV e armazena em W
	    BTFSS STATUS, C  ;Se o resultado da subtração for não-negativa, pule a próxima instrução
	    GOTO VE_ETAPA1
	    BTFSC STATUS, Z  ;Se o resultado da subtração NÃO for zero, pula a próxima instrução
	    GOTO VE_ETAPA2
	    GOTO VE_ETAPA3
	    
	    VE_ETAPA1
		MOVFW CONTAGEM_MULT
		MOVWF INTEIRA ;O valor da parte DECIMAL1 será o resultado da multiplicação
		CLRF DECIMAL1
		CLRF DECIMAL2
		GOTO CALCULA_RESULTADO
		
	    VE_ETAPA2
		MOVFW CONTAGEM_MULT
		MOVWF DECIMAL1;O valor da parte DECIMAL1 será o resultado da multiplicação
		CLRF DECIMAL2
		GOTO CALCULA_RESULTADO
		
	    VE_ETAPA3
		MOVFW CONTAGEM_MULT
		MOVWF DECIMAL2 ;O valor da parte DECIMAL1 será o resultado da multiplicação
		GOTO CALCULA_RESULTADO
	
		
        CALCULA_RESULTADO
	    MOVLW .5
	    SUBWF DECIMAL2, 0
	    BTFSC STATUS, C  ;Se o resultado da subtração for negativa, pule a próxima instrução
	    INCF DECIMAL1 ;Arredonda o decimal1 para cima
	    MOVFW DECIMAL1
	    MOVWF WORK
	    
	    MOVFW INTEIRA
	    MOVWF DADO
	
	MOVFW DECIMAL1
	NOP ;FIM DO LOOP.
         
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
