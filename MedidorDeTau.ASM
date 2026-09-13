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
		
		TEMPO_TAU  ;VARIAVEL QUE ARMAZENA O TEMPO DO TAU
		SOMA_HIGH  ;VARIAVEL PARA ARMAZENAR A PARTE MAIS SIGNIFICATIVA DA SOMA
		SOMA_LOW   ;VARIAVEL PARA ARMAZENAR A PARTE MENOS SIGNIFICATIVA DA SOMA
		CONTADOR    ;VARIAVEL PARA REALIZAR CONTAGEM
		DADO      ;VARIAVEL PARA GRAVAÇÃO NA EERPOM
		
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
	BTFSS PIR1, TMR1IF   ;CHECA O TIPO DA INTERRUPÇÃO
	GOTO INT_TMR0
	
	INT_TMR1
	    BTFSS GPIO, GP2
	    GOTO ASCENDE_GP2
	    
	    APAGA_GP2
		BCF GPIO, GP2
		GOTO SAI_INT_TMR1
		
	    ASCENDE_GP2
		BSF GPIO, GP2
		
	    SAI_INT_TMR1
		BCF PIR1, TMR1IF
		GOTO SAI_INT
	    
	INT_TMR0
	    INCF TEMPO_TAU    ;INCREMNTA O TEMPO DO TAU EM 1 MILISEGUNDO
	    BCF INTCON, T0IF
	    MOVLW .6
	    MOVWF TMR0

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
	
GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN


SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000010' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS, E GP1 COMO ENTRADA
	MOVLW	B'00010010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O (GP1 COMO ANALOGICO)
	MOVLW	B'00000001'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'	;ATIVA AS INTERRUPÇÕES GLOBAIS E DE PERIFERICOS
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW   B'00000001'     
	MOVWF   PIE1		;DEFINIÇÃO DAS INTERRUPÇÕES DE PERIFERICOS
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00110001'
	MOVWF   T1CON
	
	MOVLW	B'00000101'
	MOVWF	ADCON0		;DEFINE GP1 COMO ENTRADA DO CONVERSOR AD (BITS 2 E 3)
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	BCF GPIO, GP2

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	
	;SETA O INICIO DO FSR
	MOVLW 030
	MOVWF FSR
	
	MEDIR_TAU
	
	    CLRF TEMPO_TAU

	    ;ESPERA GP2 SUBIR PARA CARREGAR O CAPACITOR
	    ESPERA_GP2_HIGH
		BTFSS GPIO, GP2
		GOTO ESPERA_GP2_HIGH

	    ;ESPERA GP2 DESCER PARA MEDIÇÃO DO CAPACITOR    
	    ESPERA_GP2_LOW
		BTFSC GPIO, GP2
		GOTO ESPERA_GP2_LOW


	    PROCURANDO_T0
		MOVLW .154       ;VALOR CORRESPONDENTE A 3,01V
		BSF ADCON0, GO   ;INICIA O A/D

		ESPERA_CONVERTER_0
		    BTFSC ADCON0, GO    ;CHECA SE A CONVERSÃO ANALOG/DIGITAL FOI TERMINADA
		    GOTO ESPERA_CONVERTER_0

		BSF ADCON0, GO   ;INICIA O A/D

		SUBWF ADRESH, F
		BTFSC STATUS, C  ;CHECA SE O RESULTADO DA SUBTRAÇÃO FOI NEGATIVO (OU SEJA, SE A TENSÃO É MENOR QUE 3,01V)
		GOTO ESPERA_CONVERTER_0

		MOVLW .6
		BCF INTCON, T0IF
		MOVWF TMR0    ;SETA O TMR0 PARA 6

		BSF INTCON, T0IE   ;LIGA A INTERRUPÇÃO DO TIMER 0

	    PROCURANDO_TAU
		MOVLW .57       ;VALOR CORRESPONDENTE A 1,116V

		ESPERA_CONVERTER_T
		    BTFSC ADCON0, GO    ;CHECA SE A CONVERSÃO ANALOG/DIGITAL FOI TERMINADA
		    GOTO ESPERA_CONVERTER_T

		BSF ADCON0, GO   ;INICIA O A/D

		SUBWF ADRESH, F
		BTFSC STATUS, C  ;CHECA SE O RESULTADO DA SUBTRAÇÃO FOI NEGATIVO (OU SEJA, SE A TENSÃO É MENOR QUE 1,116V)
		GOTO ESPERA_CONVERTER_T

		BCF INTCON, T0IE   ;DESLIGA A INTERRUPÇÃO DO TIMER 0
		
	    ARMAZENA_TAU
		MOVFW TEMPO_TAU  ;ARMAZENA O VALOR DE TAU NO WORK
		MOVWF INDF      ;PASSA O VALOR DE TAU PARA A POSIÇÃO ATUAL DA MEMORIA
		INCF FSR        ;INCREMENTA FSR
		
	    ;CHECA SE FSR ESTÁ NA POSIÇÃO 32
	    MOVLW 04F
	    SUBWF FSR, W
	    BTFSS STATUS, Z
	    GOTO MEDIR_TAU ;CASO NÃO ESTEJA, MEDE TAU MAIS UMA VEZ
		
		
	SOMA_TAUS
	    ;LIMPA AS VARIÁVEIS QUE ARMAZENARÃO O RESULTADO DA SOMA
	    CLRF SOMA_LOW
	    CLRF SOMA_HIGH

	    ;SETA O INCIO DA POSICAO A SER LIDA NA MEMEORIA
	    MOVLW 030
	    MOVWF FSR

	    PROXIMA_SOMA
		;CHECA SE ESTAMOS NA TRIGESIMA TERCEIRA POSIÇÃO
		MOVLW 050
		SUBWF FSR, W
		BTFSC STATUS, Z   ;SE O RESULTADO FOI 0, ESTAMOS NA POSIÇÃO 32, LOGO FORAM SOMADOS 32 VALORES
		GOTO FIM_SOMA


		MOVFW INDF	         ;MOV O VALOR DA POSIÇÃO ATUAL PARA WORK
		ADDWF SOMA_LOW
		BTFSC STATUS, C     ;CHECA O CARRY
		INCF SOMA_HIGH      ;SE O CARRY APONTA OVERFLOW, INCREMENTA OS BITS MAIS SIGNIFICATIVOS

		INCF FSR             ;PROXIMA POSICAO
		GOTO PROXIMA_SOMA

	FIM_SOMA

	DIVISAO_INTEIRA_32
	    MOVLW .5
	    MOVWF CONTADOR    ;COLOCA O CONTADOR PARA REALIZAR 5 ITERAÇÕES

	    PROXIMA_DIVISAO
		RRF SOMA_HIGH
		RRF SOMA_LOW  ;ROTACIONA OS BITS MENOS SIGNIFICATIVOS
		DECFSZ CONTADOR ;CASO O CONTADOR CHEGUE EM 0, SAI DA DIVISÃO
		GOTO PROXIMA_DIVISAO

	FIM_DIVISAO

	;ARMAZENA A MÉDIA NA POSIÇÃO 0X00
	MOVFW SOMA_LOW
	MOVWF DADO
	MOVLW 02A
	CALL GRAVA_EEPROM
		
	    
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
