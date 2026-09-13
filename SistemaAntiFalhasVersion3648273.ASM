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

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		DADO
		
		CONTADOR   ;VARIAVEL PARA CONTAR ATÉ 10 = 5 SEGUNDOS
		FLAGS    ;BIT 0 --- BIT QUE DIZ SE O TIMER DE 5 SEGUNDOS ESTOROU OU NÃO
			 ;BIT  1-7 ---- NÃO IMPLEMENTADO

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
	
	;CHECA SE A INTERRUPÇÃO FOI CAUSADA AO ACORDAR O PIC
	BTFSC INTCON, GPIF
	GOTO ACORDANDO
	
	;CHECA SE A INTERRUPÇÃO FOI CAUSADA PELO COMPARADOR
	BTFSC PIR1, CMIF
	GOTO ALERTA_DE_TENSAO
	
	;CHECA SE A INTERRUPÇÃO FOI CAUSADA PELO TIMER1
	BTFSC PIR1, TMR1IF
	GOTO CICLO_DO_TIMER
	
	ALERTA_DE_TENSAO
	    ;LIMPA A FLAG   
	    BCF PIR1, CMIF
	
	    BTFSS CMCON, COUT ;TESTA SE A INTERRUPÇÃO FOI POR UMA QUEDA DE TENSÃO, OU RETORNANDO PARA A TENSÃO NORMAL
	    GOTO SAI_INT      ;SAI CASO A TENSÃO APENAAS TIVER VOLTADO AO NORMAL
	    
	    INCF DADO     ;INCREMENTA DADO
	    MOVLW 01F
	    
	    ;GRAVA O NOVO VALOR NA EEPROM
	    CALL GRAVA_EEPROM
	    
	    GOTO SAI_INT
	    
	
	CICLO_DO_TIMER
	    BCF PIR1, TMR1IF
	    
	    ;SETANDO O VALOR PARA CONTAR 500ms
	    MOVLW B'00001011'
	    MOVWF TMR1H
	    MOVLW B'11011011'
	    MOVWF TMR1L
	    
	    ;DECREMENTA O CONTADOR ATÉ QUE CHEGUE EM 0 E POSSA SETAR A FLAG
	    DECFSZ CONTADOR
	    GOTO SAI_INT
	    BSF FLAGS, 0
	    GOTO SAI_INT
	
	ACORDANDO
	
	    BANK1
	    BCF IOC, GP4 ;DESATIVA INTERRUPÇÃO DO GP4
	    BANK0
	    BCF INTCON, GPIE  ;DESATIVA A INTERRUPÇÃO DOS GP
	
	    ;FAZ UMA LEITURA NO GPIO APENAS PARA POSSIBILITAR O CLEAR DA INTERRUOÇÃO
	    BTFSS GPIO, GP0
	    NOP

	    BCF INTCON, GPIF  ;LIMPA A FLAG DE INTERRUPÇÃO
	    
	    GOTO SAI_INT
	
	
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

	
TOMANDO_CONTROLE

	BANK1
	BCF TRISIO, GP5	 ;COLOCA GP5 COMO SAIDA PARA LIGAR O LED QUE SINALIZA QUE ESTÁ NO CONTROLE
	BCF TRISIO, GP2  ;COLOCA GP2 COMO SAIDA PARA PODER LIGAR O LED QUE SINALIZA A QUEDA DE TENSÃO
	BSF VRCON, VREN  ;LIGA VREF
	BANK0
	BSF GPIO, GP5    ;LIGA O LED QUE SINALIZA ESTAR NO CONTROLE
	
	;LIGA O COMPARADOR
	MOVLW	B'00000011'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	
	RETURN
	
SEDENDO_CONTROLE	
	;DESATIVA A INTERRUPÇÃO DO COMPARADOR E DO TIMER
	BANK1
	BCF PIE1, CMIE
	BCF PIE1, TMR1IE
	;DESATIVA A INTERRUPÇÃO DE PERIFERICOS
	BCF INTCON, PEIE
	
	MOVLW	B'00111111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO ENTRADAS PARA CONSUMO MÍNIMO
	BCF	VRCON, VREN     ;GARANTINDO QUE O VREF ESTÁ DESLIGADO
	BANK0
	
	MOVLW	B'00000111'	;menor consumo
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	
	RETURN
	
ATIVANDO_TIMER1
	 ;SETA O CONTADOR PARA CONTAR 10 CICLOS DE 500 MILISEGUNDOS
	MOVLW .10
	MOVWF CONTADOR
	BCF FLAGS, 0  ;ZERA O BIT DE SAIR DA ESPERA

	;LIMPA A INTERRUPÇÃO DO TIMER1
	BCF PIR1, TMR1IF

	;SETANDO O VALOR PARA CONTAR 500ms NO TIMER1
	MOVLW B'00001011'
	MOVWF TMR1H
	MOVLW B'11011011'
	MOVWF TMR1L

	;ATIVA A INTERRUPÇÃO DO TIMER1
	BANK1
	BSF PIE1, TMR1IE
	BANK0

	;LIGA O TIMER1
	BSF T1CON, 0
	
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00111111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO ENTRADAS PARA CONSUMO MÍNIMO
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O (GP1 COMO ANALOGICO)
	MOVLW	B'01001110'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	MOVLW	B'00001011'	;HIGH RANGE, 11
	MOVWF	VRCON		;TENSÃO DE VRCON = 2,9687V
	
	CLRF	PIE1
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'	;menor consumo
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00000000'
	MOVWF   ADCON0
	
	MOVLW	B'00110000'
	MOVWF   T1CON


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	CLRF DADO     ;DADO SERVIRÁ PARA CONTAR AS QUEDAS DE TENSÃO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
;GP5 - LED PARA INDICAR QUE O MICROCONTROLADOR ESTÁ EXECUTANDO E REALIZANDO O MONITORAMENTO DO SISTEMA
;GP2 - LED INDICADOR LIGADO AOS DOIS MICROCONTROLADORES
;GP4 - PORTA PARA COMUNICAÇÃO ENTRE OS DOIS MICROCONTROLADORES (EM PULL-UP POR UM RESISTOR)
;GP1 - ENTRADA DA TENSÃO PARA COMPARAR
	
;O SISTEMA UTILIZADO SOLUCIONAR O PROBLEMA DE DETECÇÃO DE TENSÃO DE 9V FOI UM DIVISOR DE TENSÃO.
;UM RESISTOR DE 2K SERÁ LIGADO EM SÉRIE COM UM RESISTOR DE 1K, E A PORTA GP1 SERÁ CONECTADA ENTRE OS DOIS RESISTORES.
;SEGUE ABAIXO A REPRESENTAÇÃO:
;      Vx (Tensão testada)
;	|
;	R1 = 2KOhm
;	|
;	+---- Vout (GP1)
;	|
;	R2 = 1Kohm
;	|
;       GND
;
;DESSA FORMA, QUANDO A TENSÃO MÁXIMA = 15V FOR APLICADA NO CIRCUITO, O PIC PERCEBERÁ 5V.
;JÁ QUANDO A TENSÃO LIMIAR = 9V FOR APLICADA, O PIC PERCCEBERÁ 3V.
;O CALCULO DO VCREF FOI FEITO BASEANDO-SE NISSO.
	
	
MAIN
	
	;INICIA GRAVANDO 0 NA EEPROM
	MOVLW .0
	MOVWF DADO
	MOVLW 01F
	CALL GRAVA_EEPROM
	CLRWDT
	
	;DORMINDO POR 1S PARA AUMENTAAR AS CHANCES DE UM DOS PICS TOMAR O CONTROLE PRIMEIRO
	SLEEP
	NOP

	CICLO_PRINCIPAL
	    ;APARTIR DAS CONFIGURAÇÕES DE CONSUMO MÍNIMO, TESTA SE PODE TOMAR O CONTROLE DA CHECAGEM
	    BTFSS GPIO, GP4
	    GOTO DORMINDO
	    
	    ;SINALIZA PARA O OUTRO PIC, O MAIS RÁPIDO POSSÍVEL, QUE VAI TOMAR O CONTROLE
	    BANK1
	    BCF TRISIO, GP4
	    BANK0
	    BCF GPIO, GP4

	    ;SE PODE, TOMA O CONTROLE
	    CALL TOMANDO_CONTROLE
	    
	    ;ATIVA A INTERRUPÇÃO DE PERIFERICOS
	    BSF INTCON, PEIE
	
	    ;CONFIGURA E ATIVA O TIMER1
	    CALL ATIVANDO_TIMER1
	    
	    ;LIMPA FLAG COMPARADOR
	    BCF PIR1, CMIF
	    ;ATIVA A INTERRUPÇÃO DO COMPARADOR
	    BANK1
	    BSF PIE1, CMIE
	    BANK0
	    
	    ESPERANDO5
		CLRWDT
		BTFSS FLAGS, 0
		GOTO ESPERANDO5
		
		
	    ;DESATIVA A INTERRUPÇÃO DO TIMER1
	    BANK1
	    BSF PIE1, TMR1IE
	    BANK0
	    
	    LIBERAR_CONTROLE
		;SINALIZA PARA O OUTRO PIC QUE ELE ESTÁ SEDENDO O CONTROLE
		BANK1
		BSF TRISIO, GP4
		BANK0
		
		ESPERAR_OUTRO_PIC
		    CLRWDT
		    BTFSC GPIO, GP4   ;ESPERANDO O OUTRO PIC TOMAR O CONTROLE
		    GOTO ESPERAR_OUTRO_PIC
		    
		CALL SEDENDO_CONTROLE
		
	;ESPERANDO SER ACORDADO PELO OUTRO PIC (QUANDO GP2 SUBIR NOVAMENTE)
	DORMINDO
	    BSF INTCON, GPIE ;HABILITANDO INTERRUPÇÃO DOS GP
	    BANK1
	    BSF IOC, GP4     ;HABILITANDO INTERUPÇÃO DE GP4
	    BANK0
	    
	    ;DORMINDO ATÉ QUE A INTERRUPÇÃO DE GP4 ACORDE OU ATÉ QUE O WDT ACORDE PARA FAZER UMA CHECAGEM
	    SLEEP
	    NOP
	    
	    ;DESATIVANDO AS INTERRUPÇÕES CASO TENHA SIDO ACORDADO PELO WDT
	    BANK1
	    BCF IOC, GP4 ;DESATIVA INTERRUPÇÃO DO GP4
	    BANK0
	    BCF INTCON, GPIE  ;DESATIVA A INTERRUPÇÃO DOS GP
	    
	GOTO CICLO_PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
