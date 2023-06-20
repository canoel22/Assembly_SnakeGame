;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR                EQU     0Ah
FIM_TEXTO         EQU     '@'
IO_READ           EQU     FFFFh
IO_WRITE          EQU     FFFEh
IO_STATUS         EQU     FFFDh
INITIAL_SP        EQU     FDFFh
CURSOR		      EQU     FFFCh
CURSOR_INIT	  	  EQU	  FFFFh

;padrão de geração de bits
RND_MASK			EQU   8016h
LSB_MASK			EQU   0001h
PRIME_NUMER_1       EQU   11d
PRIME_NUMER_2       EQU   13d

ROW_POSITION	    EQU		0d
COL_POSITION	    EQU		0d
ROW_SHIFT		    EQU	    8d
COLUMN_SHIFT	    EQU  	8d

LINE_SIZE	        EQU     80d
COLUMN_SIZE       	EQU     24d

TIMER_UNITS       EQU     FFF6h
TIMER_SET         EQU     FFF7h

ON                EQU     1d
OFF               EQU     0d

LEFT_KEY_PRESSED  EQU     0d
RIGHT_KEY_PRESSED EQU     1d
UP_KEY_PRESSED    EQU     2d
DOWN_KEY_PRESSED  EQU     3d

TIME_TO_MOVE      EQU     5d

FALSE 				EQU 0d
TRUE 			EQU 1d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).b
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

;------------ mapa ------------- 

                ORIG    	8000h
Line0Map		STR			'PONTUACAO: 00                     SNAKE GAME                TENHA UM BOM JOGO :)'                                                                               '
Line1Map		STR			'################################################################################'
Line2Map		STR			'#                                                                              #'
Line3Map		STR			'#                                                                              #'
Line4Map		STR			'#                                                                              #'
Line5Map		STR			'#                                                                              #'
Line6Map		STR			'#                                                                              #'
Line7Map		STR			'#                                                                              #'
Line8Map		STR			'#                                                                              #'
Line9Map		STR			'#                                                                              #'
Line10Map		STR			'#                                                                              #'
Line11Map		STR			'#                                    o *                                       #'
Line12Map		STR			'#                                                                              #'
Line13Map		STR			'#                                                                              #'
Line14Map		STR			'#                                                                              #'
Line15Map		STR			'#                                                                              #'
Line16Map		STR			'#                                                                              #'
Line17Map		STR			'#                                                                              #'
Line18Map		STR			'#                                                                              #'
Line19Map		STR			'#                                                                              #'
Line20Map		STR			'#                                                                              #'
Line21Map		STR			'#                                                                              #'
Line22Map		STR			'#                                                                              #'
Line23Map		STR			'################################################################################',FIM_TEXTO

                                                                           #'
LoseLine		STR			'################################# GAME OVER :( ################################',FIM_TEXTO
WinLine			STR			'####################### QUE INCRIVEL, VOCE VENCEU! :D #########################',FIM_TEXTO

StringToPrint 		 WORD 0d  ;endereco da string
LineNumberToPrint    WORD 0d  ;linha que vai ser printada
PrintLoseLine		 WORD 0d
PrintWinLine		 WORD 0d

GameOver			WORD FALSE

LineSnakeHead		 WORD 11d
ColumnSnakeHead	  	 WORD 37d

LineFruit            WORD 11d
ColumnFruit          WORD 40d

LastKeyPressed       WORD RIGHT_KEY_PRESSED

PreviousTailLine     WORD 0d
PreviousColumnLine   WORD 0d

LineArg              WORD 0d
ColumnArg            WORD 0d

;------------ score ------------- 
ScoreDez			WORD '0'
ScoreUnid			WORD '0'

ScoreUndidLine 		WORD 0d
ScoreUnidColumn		WORD 12d

SnakeScore 			WORD 0d


;------------ random ------------- 
Random_Var			WORD A5A5h
Radom_State			WORD 1d


;------------ lista ------------- 
LineArgShiftList     WORD 0d
ColumnArgShiftList   WORD 0d


ListTail             WORD 0d
ListHead             WORD 0d


;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    RightKeyPressed
INT1            WORD    UpKeyPressed
INT2            WORD    DownKeyPressed
INT3            WORD    LeftKeyPressed

                ORIG    FE0Fh
INT15           WORD    Timer


;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidasw
;------------------------------------------------------------------------------
		ORIG    0000h
		JMP     Main


;----------------------------------------------------------------
; Rotina: EsqueletoRotina
;----------------------------------------------------------------
EsqueletoRotina: PUSH R1
		PUSH R2
		PUSH R3

		POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Rotina: 	SnakeColision
;----------------------------------------------------------------
SnakeColision: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6

	MOV R1, M[ SnakeScore ]
	CMP R1, 5d 
	JMP.Z DebugSnakeCollision
	JMP EndColision

DebugSnakeCollision: NOP


ContinueSnakeCollision:	MOV R1, M[LineSnakeHead]
	MOV R2, M[ColumnSnakeHead]
	
	MOV R3, ListHead
	MOV R4, M[ListTail]
	INC R3

CicloCompara: INC R3
	CMP R3, R4
	JMP.Z EndColision
	MOV R5, M[R3]
	INC R3
	CMP R5, R1
	JMP.NZ CicloCompara
	MOV R6, M[R3]
	CMP R6, R2
	CALL.Z 	Lose
	JMP CicloCompara

	EndColision: POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1

	RET



;----------------------------------------------------------------
; Rotina: ShiftListAndIncreaseList
;----------------------------------------------------------------
ShiftListAndIncreaseList: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R5
		PUSH R6

		MOV R1, M[ListTail]
		MOV R2, 1d
		MOV R6, ListHead 
		SUB R1, R2 ; r1 ORIGEM
				
 
;------------------- faz o shift da lista toda pro lado ----------------------
CicloShift:MOV R4, M[R1]
		MOV R5, R1
		MOV R2, 2d
		ADD R5, R2 ; R5 DESTINO
		MOV M[R5], R4			
		DEC R1
		DEC R5
		MOV R4, M[R1]
		MOV M[R5], R4
		CMP R1, R6
		JMP.NZ CicloShift

;--------------------- adiciona a nova pos da cabeça ------------------------

		MOV R1, M[ LineArgShiftList ] ; linha da nova cabeca
		MOV R2, M[ ColumnArgShiftList ] ; coluna da nova cabeca
		MOV M[R6], R1
		INC R6
		MOV M[R6], R2

		MOV M[LineSnakeHead], R1
		MOV M[ColumnSnakeHead], R2

		INC M[ListTail]
		INC M[ListTail]

		SHL R1, 8d 
OrShift:OR  R1, R2
		MOV M[ CURSOR ], R1
		MOV R1, 'o'
		MOV M[ IO_WRITE ], R1

		MOV R1, M[ListTail]
		MOV M[R1], R0
		INC R1
		MOV M[R1], R0

		POP R6
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Rotina: ShiftListAndMaitainSize
;----------------------------------------------------------------
ShiftListAndMaintainSize: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R5
		PUSH R6

		MOV R1, M[ListTail]
		MOV R2, 1d
		MOV R6, ListHead 
		SUB R1, R2 ; r1 ORIGEM
				
 
;------------------- faz o shift da lista toda pro lado ----------------------
CicloShiftAndMaintainSize:MOV R4, M[R1]
		MOV R5, R1
		MOV R2, 2d
		ADD R5, R2 ; R5 DESTINO
		MOV M[R5], R4			
		DEC R1
		DEC R5
		MOV R4, M[R1]
		MOV M[R5], R4
		CMP R1, R6
		JMP.NZ CicloShiftAndMaintainSize

;--------------------- adiciona a nova pos da cabeça ------------------------

		MOV R1, M[ LineArgShiftList ] ; linha da nova cabeca
		MOV R2, M[ ColumnArgShiftList ] ; coluna da nova cabeca
		MOV M[R6], R1
		INC R6
		MOV M[R6], R2

		MOV M[LineSnakeHead], R1
		MOV M[ColumnSnakeHead], R2
		
		SHL R1, 8d 
		OR  R1, R2
		MOV M[ CURSOR ], R1
		MOV R1, 'o'
		MOV M[ IO_WRITE ], R1


		MOV R1, M[ListTail] ; Tail line
		MOV R1, M[ R1 ]
		MOV R2, M[ListTail]
		INC R2
		MOV R2, M[ R2 ]              ; Tail Column

		SHL R1, 8d 
		OR  R1, R2
		MOV M[ CURSOR ], R1
		MOV R1, ' '
		MOV M[ IO_WRITE ], R1

		MOV R1, M[ListTail]
		MOV M[R1], R0
		INC R1
		MOV M[R1], R0

		POP R6
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1

		RET


;----------------------------------------------------------------
; Rotina: EatFruit
;----------------------------------------------------------------
EatFruit: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R5

		MOV R1, M[ LineFruit]
		MOV R2, M[ LineSnakeHead]
		CMP R1, R2
		JMP.NZ EatFruitEnd

		MOV R1, M[ ColumnFruit]
		MOV R2, M[ ColumnSnakeHead ]
		CMP R1, R2
		JMP.NZ EatFruitEnd

		CALL Score

;------------------ atualiza a lista e printa------------	

	DebugShift: MOV R1, M[ LineSnakeHead ]
		MOV M[ LineArgShiftList], R1

		INC M[ ColumnSnakeHead ]
		MOV R1, M[ ColumnSnakeHead ]
		MOV M[ ColumnArgShiftList], R1
		CALL ShiftListAndIncreaseList

;------------------calcula a nova pos da comida------------				  

NewFruitPosition:CALL RandomV1
		MOV R1, M[ Random_Var]
		MOV R2, 21d ;criar const
		DIV R1, R2
		ADD R2, 2
		MOV M[ LineFruit], R2

		CALL RandomV1
		MOV R1, M[ Random_Var]
		MOV R2, 78d ;criar const
		DIV R1, R2
		ADD R2, 1
		MOV M[ ColumnFruit], R2

		MOV R1, M [ LineFruit]
		MOV R2, M [ ColumnFruit]

		MOV R4, M[ ListHead]

		CMP R1, R4
		JMP.NZ Endif

		INC R4
		CMP R2, R4
		JMP.Z NewFruitPosition

		Endif: SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV R3, '*'
		MOV M[ IO_WRITE ],R3


EatFruitEnd:	 POP R5
		POP R4
		POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Função: RandomV1
;----------------------------------------------------------------
RandomV1: PUSH R1

		MOV R1, LSB_MASK
		AND R1, M[ Random_Var]
		BR.Z  Rnd_Rotate
		MOV R1, RND_MASK
		XOR M[Random_Var], R1

Rnd_Rotate: ROR M[Random_Var], 1

		POP R1

		RET


;----------------------------------------------------------------
; Rotina: Score
;----------------------------------------------------------------
Score:  PUSH R1
		PUSH R2
		PUSH R3

		INC M[ SnakeScore ]

		MOV R1, M[ ScoreUnid ]
		MOV R2, M[ ScoreDez ]
		MOV R3, 57d

		CMP R1, R3 ;compara se a unidade é 9 (em ASCII)
		JMP.Z AtualizaDezena 
		JMP.NZ AtualizaUnid 

		;------------zera a unidade---------
AtualizaDezena: MOV R1, '0' 
		MOV M[ ScoreUnid], R1
		MOV R3, 12d
		MOV R2, R3 ;posição na tela
		MOV M[ CURSOR], R2
		MOV M[ IO_WRITE], R1
		;---------aumenta a dezena----------
		INC M[ ScoreDez]
		MOV R1, M[ ScoreDez]
		MOV R3, 11d
		MOV R2, R3
		MOV M[ CURSOR], R2
		MOV M[ IO_WRITE], R1
		MOV R3, 57d ;-> CHEGANDO AOS 99 PONTOS, O JOGO É GANHO!
		CMP R1, R3
		CALL.Z Win 
		JMP EndScore

		;------------ aumenta a unidade---------
AtualizaUnid:  INC M[ ScoreUnid]
		MOV R1, M[ ScoreUnid]
		MOV R2, 12d
		MOV M[ CURSOR], R2
		MOV M[ IO_WRITE], R1
		NOP

EndScore:POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Rotina: InsertList
;----------------------------------------------------------------
InsertList:  PUSH R1
		PUSH R2
		PUSH R3

		MOV R1, M[LineArg]
		MOV R2, M[ColumnArg]
		MOV R3, M[ListTail]
		MOV M[R3], R1
		INC R3
		MOV M[R3], R2
		INC R3
		MOV M[ListTail], R3

		POP R3
		POP R2
		POP R1

		RET
;----------------------------------------------------------------
; Rotina: ConfigureTimer
;----------------------------------------------------------------
ConfigureTimer:  PUSH R1

		MOV R1, TIME_TO_MOVE
		MOV M[ TIMER_UNITS ], R1
		MOV R1, ON
		MOV M[ TIMER_SET ], R1

		POP R1

		RET


 ;----------------------------------------------------------------
 ; Rotina: RightKeyPressed
 ;----------------------------------------------------------------
 RightKeyPressed:     PUSH R1

		MOV R1, RIGHT_KEY_PRESSED
		MOV M[LastKeyPressed], R1

		POP R1

		RTI

;----------------------------------------------------------------
; Rotina: LeftKeyPressed
;----------------------------------------------------------------
LeftKeyPressed:     PUSH R1

		MOV R1, LEFT_KEY_PRESSED
		MOV M[LastKeyPressed], R1

		POP R1

		RTI

;----------------------------------------------------------------
; Rotina: UpKeyPressed
;----------------------------------------------------------------
UpKeyPressed:      PUSH R1

		MOV R1, UP_KEY_PRESSED
		MOV M[LastKeyPressed], R1

		POP R1

		RTI

;----------------------------------------------------------------
; Rotina: DownKeyPressed
;----------------------------------------------------------------
DownKeyPressed:    PUSH R1

		MOV R1, DOWN_KEY_PRESSED
		MOV M[LastKeyPressed], R1

		POP R1

		RTI
;----------------------------------------------------------------
; Rotina: Timer
;----------------------------------------------------------------
Timer:   PUSH R1
		 PUSH R2
		 PUSH R3

         MOV R1, M[ LastKeyPressed ]

         CMP R1, RIGHT_KEY_PRESSED
         CALL.Z MoveSnakeRight

         CMP R1, LEFT_KEY_PRESSED
         CALL.Z MoveSnakeLeft

         CMP R1, UP_KEY_PRESSED
         CALL.Z MoveSnakeUp

         CMP R1, DOWN_KEY_PRESSED
         CALL.Z MoveSnakeDown

         CALL ConfigureTimer

		 POP R3
		 POP R2
		 POP R1

		 RTI


;----------------------------------------------------------------
; Rotina: MoveSnakeRight
;----------------------------------------------------------------
MoveSnakeRight: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4

		;------------ colisão com a parede ---------
		MOV R1, M[ ColumnSnakeHead ]
		CMP R1, 78d
		JMP.NZ CheckEatFruitRight

		MOV R1, TRUE
		MOV M[ GameOver ], R1
		CALL Lose

		;------------ cresce a cobrinha ---------
CheckEatFruitRight: CALL EatFruit

		;------------ colisão com a cobrinha ---------
		CALL SnakeColision

		;-------------- movimentação -----------

UpdateSnakeToRight: MOV R1, M[ LineSnakeHead ]
		MOV M[ LineArgShiftList], R1

		INC M[ ColumnSnakeHead ]
		MOV R1, M[ ColumnSnakeHead ]
		MOV M[ ColumnArgShiftList], R1
		CALL ShiftListAndMaintainSize

		POP R4
		POP R3
		POP R2
		POP R1

	RET


;----------------------------------------------------------------
; Rotina: MoveSnakeUp
;----------------------------------------------------------------
MoveSnakeUp:  PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		
		;------------ colisão com a parede ---------
		MOV R1, M[ LineSnakeHead ]
		CMP R1, 2d
		JMP.NZ CheckEatFruitUp

		MOV R1, TRUE
		MOV M[ GameOver ], R1
		CALL Lose

		;------------ cresce a cobrinha ---------
CheckEatFruitUp: CALL EatFruit

		;------------ colisão com a cobrinha ---------
		CALL SnakeColision

		;-------------- movimentação -----------

UpdateSnakeUp: MOV R1, M[ ColumnSnakeHead ]
		MOV M[ ColumnArgShiftList], R1

		DEC M[ LineSnakeHead ]
		MOV R1, M[ LineSnakeHead ]
		MOV M[ LineArgShiftList], R1
		CALL ShiftListAndMaintainSize

		POP R4
		POP R3
		POP R2
		POP R1

	RET

;----------------------------------------------------------------
; Rotina: MoveSnakeDown
;----------------------------------------------------------------
MoveSnakeDown:  PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		
		;------------ colisão com a parede ---------
		MOV R1, M[ LineSnakeHead ]
		CMP R1, 22d
		JMP.NZ CheckEatFruitDown

		MOV R1, TRUE
		MOV M[ GameOver ], R1
		CALL Lose


		;------------ cresce a cobrinha ---------
CheckEatFruitDown: CALL EatFruit

		;------------ colisão com a cobrinha ---------
		CALL SnakeColision

		;-------------- movimentação -----------

UpdateSnakeDown: MOV R1, M[ ColumnSnakeHead ]
		MOV M[ ColumnArgShiftList], R1

		INC M[ LineSnakeHead ]
		MOV R1, M[ LineSnakeHead ]
		MOV M[ LineArgShiftList], R1
		CALL ShiftListAndMaintainSize

		POP R4
		POP R3
		POP R2
		POP R1

	RET

;----------------------------------------------------------------
; Rotina: MoveSnakeLeft
;----------------------------------------------------------------
MoveSnakeLeft:  PUSH R1
						PUSH R2
		PUSH R3
		PUSH R4
		
		;------------ colisão com a parede ---------
		MOV R1, M[ ColumnSnakeHead ]
		CMP R1, 1d
		JMP.NZ CheckEatFruitLeft

		MOV R1, TRUE
		MOV M[ GameOver ], R1
		CALL Lose

		;------------ cresce a cobrinha ---------
CheckEatFruitLeft: CALL EatFruit

		;------------ colisão com a cobrinha ---------
		CALL SnakeColision

		;-------------- movimentação -----------

UpdateSnakeToLeft: MOV R1, M[ LineSnakeHead ]
		MOV M[ LineArgShiftList], R1

		DEC M[ ColumnSnakeHead ]
		MOV R1, M[ ColumnSnakeHead ]
		MOV M[ ColumnArgShiftList], R1
		CALL ShiftListAndMaintainSize

		POP R4
		POP R3
		POP R2
		POP R1

	RET

;----------------------------------------------------------------
; Rotina: PrintLine
; printa caracter por caracter de cada linha
;----------------------------------------------------------------
PrintLine:   PUSH R1 ;linha
		PUSH R2 ;coluna
		PUSH R3 ;caracter da string pra imprimir
		PUSH R4
		MOV R4, M[ StringToPrint ]

while_PrintColumn:	MOV R2, 0d ;coluna

while_PrintLine: 	MOV R1, M[ LineNumberToPrint] ;linha
		MOV R3, M[ R4 ] ;pega caracter atual da string
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV M[ IO_WRITE ], R3
		INC R2
		INC R4
		CMP R2, LINE_SIZE
		JMP.NZ while_PrintLine	;repete o while caso o cmp seja !=0
		MOV R1, M[ LineNumberToPrint]
		INC R1
		MOV M[ LineNumberToPrint], R1
		CMP R1, COLUMN_SIZE
		JMP.NZ while_PrintColumn


		POP R4
		POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Rotina: PrintMap
; printa as linhas
;----------------------------------------------------------------
PrintMap: PUSH R1
		  PUSH R2
		  PUSH R3

		  MOV  R1, Line0Map
		  MOV  M[ StringToPrint ], R1
		  MOV  R1, 0d
   		  MOV  M[ LineNumberToPrint ], R1
		  CALL PrintLine

		  POP R3
		  POP R2
		  POP R1

		  RET;
		  
;----------------------------------------------------------------
; Rotina: Lose
;----------------------------------------------------------------
Lose : PUSH R1
		PUSH R2 
		PUSH R3
		PUSH R4

		MOV R1, LoseLine
		MOV M[ PrintLoseLine ], R1

		MOV R4, M[ PrintLoseLine ]			 
		MOV R2, 0d

PrintLose: MOV R1, 12d
		MOV R3, M[ R4 ]
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV M[ IO_WRITE ], R3

		INC R2
		INC R4
		CMP R2, 79d
		JMP.NZ PrintLose

LoseForever: JMP LoseForever

		POP R4
		POP R3
		POP R2
		POP R1

		RET

;----------------------------------------------------------------
; Rotina: Win
;----------------------------------------------------------------
Win : PUSH R1
		PUSH R2 
		PUSH R3
		PUSH R4

		MOV R1, WinLine
		MOV M[ PrintWinLine ], R1

		MOV R4, M[ PrintWinLine ]			 
		MOV R2, 0d

PrintWin: MOV R1, 12d
		MOV R3, M[ R4 ]
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV M[ IO_WRITE ], R3

		INC R2
		INC R4
		CMP R2, 79d
		JMP.NZ PrintWin

WinForever: JMP WinForever

		POP R4
		POP R3
		POP R2
		POP R1

		RET

;-----------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main:	ENI
		MOV		R1, INITIAL_SP
		MOV		SP, R1		 		; We need to initialize the stack
		MOV		R1, CURSOR_INIT		; We need to initialize the cursor
		MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

		MOV     R1, ListHead
		MOV     M[ListTail], R1

		MOV R1, M[LineSnakeHead]
		MOV M[ LineArg], R1
		MOV R1, M[ ColumnSnakeHead]
		MOV M [ColumnArg], R1
		CALL InsertList

		CALL ConfigureTimer
		CALL PrintMap
	

Cycle: 			BR		Cycle
Halt:           BR		Halt