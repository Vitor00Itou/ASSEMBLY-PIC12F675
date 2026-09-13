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
		
		ENDERECO_RECEBIDO     ;VARIÁVEL PARA ARMAZENAR O ENDEREÇO RECEBIDO
		VARIAVEL_DELAY        ;VARIAVEL PARA GERAR UM DELAY

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
	
	BTFSC INTCON, T0IF  ;CHECA SE A INTERRUPÇÃO FOI PELO TIMER0
	GOTO TIMER0_INT	    ;CASO SEJA, VAI PARA O TRATAMENTO DA INTERRUPÇÃO DO TIMER0
	
	;CHECANDO SE A INTERRUPÇÃO FOI POR CONTA DE UM START BIT
	BTFSS GPIO, GP0	    ;SE FOR UM START BIT, GP0(SCL) DEVE SER HIGH
	GOTO LIMPA_PORT_CHANGE
	BTFSC GPIO, GP1	    ;SE FOR UM START BIT, GP1(SDA) DEVE SER LOW
	GOTO LIMPA_PORT_CHANGE
	
	CLRF ENDERECO_RECEBIDO   ;LIMPA A VARIÁVEL ANTES DE PREENCHER O ENDEREÇO
	
	LENDO_O_ENDERECO
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O PRIMEIRO BIT
	    
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 6  ;CASO SEJA HIGH, O BIT SEIS É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O SEGUNDO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 5  ;CASO SEJA HIGH, O BIT CINCO É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O TERCEIRO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 4  ;CASO SEJA HIGH, O BIT QUATRO É 1
	
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O QUARTO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 3  ;CASO SEJA HIGH, O BIT TRÊS É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O QUINTO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 2  ;CASO SEJA HIGH, O BIT DOIS É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O SEXTO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 1  ;CASO SEJA HIGH, O BIT UM É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O SÉTIMO BIT
	
	    BTFSC GPIO, GP1         ;CHECA O SDA
	    BSF ENDERECO_RECEBIDO, 0  ;CASO SEJA HIGH, O BIT ZERO É 1
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
	    CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA LER O BIT DE R/W
		
	    ;NO CASO DESSE PROGRAMA, NÃO HÁ A NECESSIDADDE DE ARMAZENAR O BIT DE R/W
	    
	    CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR PARA ENVIAR O ACK
		
	    BANK1	;ALTERA PARA O BANCO 1
	    BCF TRISIO, TRISIO1  ;MUDA O SDA PARA OUTPUT
	    BANK0       ;ALTERA O BANCO PARA 0 NOVAMENTE
	    
	    ;CHECA SE O ENDEREÇO LIDO FOI O ESPERADO
	    MOVLW 017
	    SUBWF ENDERECO_RECEBIDO, W
	    BTFSS STATUS, Z
	    GOTO ENDERECO_ERRADO
	    
	    ENDERECO_CORRETO
		BCF GPIO, GP1   ;ENVIA O ACK, AVISANDO QUE LEU CORRETAMENTE
		CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA O ACK SER LIDO PELO MASTER
		CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
		
		BANK1	;ALTERA PARA O BANCO 1
		BCF TRISIO, TRISIO0  ;MUDA O SCL PARA OUTPUT
		BSF INTCON, T0IE     ;HABILITA A INTERRUPÇÃO DO TIMER0
		MOVLW	B'00000000'	
		MOVWF	IOC		;DESABILITA A INTERRUPÇÃO DO GP1
		BANK0       ;ALTERA O BANCO PARA 0 NOVAMENTE
		
		MOVLW B'00100000'
		MOVWF GPIO    ;LIGA O LED, E DESCE SDA
		
		BCF INTCON, T0IF  ;CONFIRMA QUE A FLAG DE INTERRUPÇÃO DO TIMER0 ESTÁ ZERADA
		MOVLW .61
		MOVWF TMR0       ;SETA TMR0 COMO 61 DECIMAL PARA POSIBILITAR A CONTAGEM DE (APROXIMADAMENTE) 50 MILISEGUNDOS
		
		GOTO LIMPA_PORT_CHANGE
		
	    ENDERECO_ERRADO
		BSF GPIO, GP1   ;ENVIA O ACK, AVISANDO QUE LEU ERRONEAMENTE
		CALL ESPERA_SCL_HIGH ;ESPERA O SCL SUBIR PARA O ACK SER LIDO PELO MASTER
		CALL ESPERA_SCL_LOW ;ESPERA O SCL ZERAR
		
		BANK1	;ALTERA PARA O BANCO 1
		BSF TRISIO, TRISIO1  ;MUDA O SDA PARA INPUT NOVAMENTE
		BANK0       ;ALTERA O BANCO PARA 0 NOVAMENTE
	    
	LIMPA_PORT_CHANGE
	    BCF INTCON, GPIF   ;LIMPA A FLAG DE INTERRUPÇÃO
	    GOTO SAI_INT
	    
	    
	TIMER0_INT
	    CALL DELAY
	    MOVLW B'00000011'
	    MOVWF GPIO    ;DESLIGA O LED, E SOBE SCL E SDA
	    
	    BANK1	;ALTERA PARA O BANCO 1
	    BSF TRISIO, TRISIO0  ;MUDA O SCL PARA INPUT
	    BSF TRISIO, TRISIO1  ;MUDA O SDA PARA INPUT
	    BCF INTCON, T0IE     ;DESABILITA A INTERRUPÇÃO DO TIMER0
	    BANK0       ;ALTERA O BANCO PARA 0 NOVAMENTE
	    
	    BCF INTCON, GPIF   ;LIMPA A FLAG DE INTERRUPÇÃO GPIO
	    BCF INTCON, T0IF   ;LIMPA A FLAG DE INTERRUPÇÃO TIMER0
	    
	    BANK1	;ALTERA PARA O BANCO 1
	    MOVLW	B'00000010'	
	    MOVWF	IOC		;HABILITA A INTERRUPÇÃO DO GP1
	    BANK0       ;ALTERA O BANCO PARA 0 NOVAMENTE
	    
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

;ROTINA DE DELAY
DELAY
	MOVLW .18         
	MOVWF VARIAVEL_DELAY	;SETA A VARIÁVEL COMO 18 DECIMAL POR GERAR UM BOM DELAY (APARTIR DE TESTES EMPÍRICOS)
	
	
	DECREMENTO		;DECREMENTA A VERIÁVEL ATÉ CHEGAR EM 0, GERANDO DE FATO O DELAY
	    DECFSZ VARIAVEL_DELAY
	    GOTO DECREMENTO
	    
	;3 NOPS PARA COMPLETAR O DELAY NECESSÁRIO
	NOP
	NOP
	NOP
	
	RETURN
	
;ROTINA DE ESPERA OCUPADA PARA EPERAR O SCL SUBIR
ESPERA_SCL_HIGH
	ESPERA_HIGH
	    BTFSS GPIO, GP0	    ;ESPERA O SCL SUBIR PARA SAIR DA ROTINA
	    GOTO ESPERA_HIGH
	
	RETURN
	
;ROTINA DE ESPERA OCUPADA PARA EPERAR O SCL DESCER
ESPERA_SCL_LOW
	ESPERA_LOW
	    BTFSC GPIO, GP0	    ;ESPERA O SCL SUBIR PARA SAIR DA ROTINA
	    GOTO ESPERA_LOW
	
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000011' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS) - GP0 E GP1 COMO INPUT
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'     ;TIMER 0 1:256
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'	;INTERRUPÇÕES DOS GPs
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	
	MOVLW	B'00000010'	
	MOVWF	IOC		;HABILITA A INTERRUPÇÃO DO GP1
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

	;CORPO DA ROTINA PRINCIPAL

	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
