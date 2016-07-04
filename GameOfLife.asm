				; =================================
				;	Init Vectors
				; =================================
				
				org		$0
vector_000		dc.l 	$FFB500 ; Init Pile
vector_001		dc.l	Main
vector_002_255	dcb.l	254,break_exception
break_exception	illegal

				; =================================
				;	Main
				; =================================

				org		$1000

Main			move.l	#25,d2
				move.l	#25,d3
				jsr		CreateTab
				jsr		TestPlane
\Loop			jsr		PrintTab
			;	jsr		Wait
			;	jsr		Wait
			;	jsr		Wait
				jsr		PlayTab
				jsr		CopyTab
				bra		\Loop
				illegal

				; ================================
				;	Subroutines
				; ================================

				;CREATETAB (d2,d3) -> a0
CreateTab		movem.l	d0-d5,-(a7)
				lea		sTab,a0
				mulu.l	d3,d2	;	d2 <- Nb Cases du Tableau
				sub.l	#1,d2	;	N-1
\Boucle			move.b	#'-',(a0)+
				dbra	d2,\Boucle
				move.b	#0,(a0)
				lea		sTab,a0
\End			movem.l	(a7)+,d0-d5
				rts

				;COPYTAB	Copy sTemp to sTab
CopyTab			movem.l	a0/a1,-(a7)
				lea		sTab,a0
				lea		sTemp,a1
\Boucle			tst		(a1)
				beq		\End
				move.l	(a1)+,(a0)+
				bra		\Boucle
\End			movem.l	(a7)+,a0/a1
				rts

				;PLAYTAB	Compute Next Generation in a1
PlayTab			movem.l	d0-d3/a0,-(a7)
				move.l	#1,d1 ; Y
\ForY			move.l	#1,d0 ; X
\ForX	  			jsr		PlayCell
					cmp.l	d2,d0
					beq		\EndForX
					addq.l	#1,d0
					bra		\ForX
\EndForX		cmp.l	d3,d1
				beq		\End
				addq.l	#1,d1
				bra		\ForY
\End			movem.l	(a7)+,d0-d3/a0
				rts

				;MOVEA0ANDA1  Set a0 and a1 to (d0,d1) in sTab and sTemp
MoveA0AndA1		move.l	a2,-(a7)
				jsr		GetCase
				move.l	a0,a2
				move.l  a1,a0
				jsr		GetCase
				move.l	a0,a1
				move.l	a2,a0
\End			move.l	(a7)+,a2
				rts
				

				;PLAYCELL	; Set d0,d1 to New State
PlayCell		movem.l	d0-d6/a0/a2,-(a7)
				lea		sTab,a0
				lea		sTemp,a1
				jsr		MoveA0AndA1
				;
				jsr		NumberCells
				jsr		TestCase
				bne     \DeadCell
\LivingCell		cmp.l	#2,d4
				blo		\DiePotatoe
				cmp.l	#3,d4
				bhi     \DiePotatoe
				move.b	#'O',(a1)+
				bra		\End
\DiePotatoe		move.b	#'-',(a1)+
				bra		\End
\DeadCell		cmp.l	#3,d4
				beq		\LifeAppear
				move.b	#'-',(a1)+
				bra		\End
\LifeAppear		move.b	#'O',(a1)+
				bra		\End
\End			movem.l	(a7)+,d0-d6/a0/a2
				rts

				;NUMBERCELLS 	(a0)	Return D4 : Number of living Cells Around	;	ooo
				; D0 = xCase ; D2 = Xmax 	; A0 = Case to Test						;	oxo
				; D1 = yCase ; D3 = Ymax	; A1 = sTab								;	ooo
				; D4 = living cells counter
NumberCells		movem.l	d0-d3/d5/d6/a0-a2,-(a7)
				lea		sTab,a1
				clr.l	d4
				move.l	d0,d5 ; D5 (Absolute) = D0 (Relative)
				move.l	d1,d6 ; D6 (Absolute) = D1 (Relative)
\CaseUpLeft		;
				cmp.l	#1,d5
				beq		\CaseUp
				cmp.l	#1,d6
				beq		\CaseLeft
				move.l	d5,d0
				move.l	d6,d1
				subq.l	#1,d0
				subq.l	#1,d1
				jsr		TestAndInc
\CaseUp			;
				cmp.l	#1,d6
				beq		\CaseLeft
				move.l	d5,d0
				move.l	d6,d1
				subq.l	#1,d1
				jsr		TestAndInc
\CaseUpRight	;
				cmp.l	d2,d5
				beq		\CaseLeft
				cmp.l	#1,d6
				beq		\CaseLeft
				move.l	d5,d0
				move.l	d6,d1
				addq.l	#1,d0
				subq.l	#1,d1
				jsr		TestAndInc
\CaseLeft		;
				cmp.l	#1,d5
				beq		\CaseRight
				move.l	d5,d0
				move.l	d6,d1
				subq.l	#1,d0
				jsr		TestAndInc
\CaseRight		;
				cmp.l	d2,d5
				beq		\CaseDownLeft
				move.l	d5,d0
				move.l	d6,d1
				addq.l	#1,d0
				jsr		TestAndInc
\CaseDownLeft	;
				cmp.l	#1,d5
				beq		\CaseDown
				cmp.l	d3,d6
				beq		\End
				move.l	d5,d0
				move.l	d6,d1
				subq.l	#1,d0
				addq.l	#1,d1
				jsr		TestAndInc
\CaseDown		;
				cmp.l	d3,d6
				beq		\End
				move.l	d5,d0
				move.l	d6,d1
				addq.l	#1,d1
				jsr		TestAndInc
\CaseDownRight	;
				cmp.l	d2,d5
				beq		\End
				cmp.l	d3,d6
				beq		\End
				move.l	d5,d0
				move.l	d6,d1
				addq.l	#1,d0
				addq.l	#1,d1
				jsr		TestAndInc
\End

				movem.l	(a7)+,d0-d3/d5/d6/a0-a2
				rts

TestAndInc		jsr		TestCase		;Sub-Routine : If d0,d1 is a living cell, d4++
				bne		\End
				addq.l	#1,d4
\End			rts


				;TESTCASE	Return Z = 1 if (d0,d1) is living ; Else Z = 0
TestCase		move.l	a0,-(a7)
				lea		sTab,a0 ;;;;;;;;;;;;; Test
				jsr		GetCase
				cmp.b	#'O',(a0)
				beq		\OK
				andi.b 	#%11111011,ccr ; Positionne le flag Z à 0
				bra		\End
\OK				ori.b 	#%00000100,ccr ; Positionne le flag Z à 1
\End			move.l	(a7)+,a0
				rts

				;GETCASE 	D0 = xCase, D1 = YCase, Set (a0) to d0,d1 Case
GetCase			movem.l	d0-d4,-(a7)
				sub.l	#1,d0
				add.l	d0,a0
				sub.l	#1,d1
				mulu.l	d2,d1
				add.l	d1,a0
\End			movem.l	(a7)+,d0-d4
				rts

				; ==============================
 				; Display
 				; ==============================
 				
				;AskPlayer
AskPlayer		movem.l	d0-d5/a0,-(a7)
				move.l	d2,d4	; Save Xmax
\Boucle			lea		sTab,a1
				lea		sBuffer,a0
				move.l	#2,d1
				move.l  #2,d2
				jsr		GetInput
				cmp.b	#'1',(a0)
				blo		\End
				cmp.b	#'9',(a0)
				bhi		\End
				move.b	(a0)+,d0
				sub.l	#$30,d0
				cmp.b	#'1',(a0)
				blo		\End
				cmp.b	#'9',(a0)
				bhi		\End
				move.b	(a0)+,d1
				sub.l	#$30,d1
				lea		sTab,a0
				move.l	d4,d2	; Get Xmax
				jsr		GetCase
				move.b	#'O',(a0)
				bra		\Boucle
\End			movem.l	(a7)+,d0-d5/a0
				rts

				; ==============================
 				; Prints
 				; ==============================

				;PRINTTAB d2 = Xmax, d3 = Ymax
PrintTab		movem.l	d0-d4/a0,-(a7)
				lea		sTab,a0
				move.l	d2,d3
				subq.l	#1,d3
				move.l	#1,d2
\Loop1			tst.b	(a0)
				beq		\End
				move.l	d3,d4
				addq.l	#1,d2
				move.l	#2,d1
\Loop2				move.b	(a0)+,d0
					jsr		PrintChar
					addq.l	#1,d1
					dbra	d4,\Loop2
				bra		\Loop1
\End			movem.l	(a7)+,d0-d4/a0
				rts

				; ==============================
 				; Tests
 				; ==============================

TestFlorish		movem.l	d0/d1/a0,-(a7) ; Beautiful
				lea		sTab,a0
				move.l	#10,d0
				move.l	#10,d1
				jsr		GetCase
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
				lea		sTab,a0
				move.l	#9,d0
				move.l	#11,d1
				jsr		GetCase
				move.b	#'O',(a0)+
				addq.l	#1,a0
				move.b	#'O',(a0)+
				addq.l	#1,a0
				move.b	#'O',(a0)+
				lea		sTab,a0
				move.l	#10,d0
				move.l	#12,d1
				jsr		GetCase
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
\End			movem.l	(a7)+,d0/d1/a0
				rts

TestPourri		movem.l	d0/d1/a0,-(a7) ; Alternative Cross
				move.l	#1,d0
				move.l 	#2,d1
				lea		sTab,a0
				jsr		GetCase
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
				move.b	#'O',(a0)
\End			movem.l	(a7)+,d0/d1/a0
				rts
				
TestPlane		movem.l	d0/d1/a0,-(a7) ; Plane
				move.l	#3,d0
				move.l	#2,d1
				lea		sTab,a0
				jsr		GetCase
				move.b	#'O',(a0)
				move.l	#4,d0
				move.l	#3,d1
				lea		sTab,a0
				jsr		GetCase
				move.b	#'O',(a0)
				move.l	#2,d0
				move.l	#4,d1
				lea		sTab,a0
				jsr		GetCase
				move.b	#'O',(a0)+
				move.b	#'O',(a0)+
				move.b	#'O',(a0)

\End			movem.l	(a7)+,d0/d1/a0
				rts
				; ==============================
 				; Sous-Routines Annexes
 				; ==============================

				;PRINT
Print			movem.l	d0-d2/a0,-(a7)
\Boucle			tst.b	(a0)
				beq		\End
				move.b	(a0)+,d0
				addq.l	#1,d1
				jsr		PrintChar
				bra		\Boucle
\End			movem.l	(a7)+,d0-d2/a0
				rts

				;CLEARALL
ClearAll		clr.l	d0
				clr.l	d1
				clr.l	d2
				clr.l	d3
				clr.l	d4
				clr.l	d5
				rts

				;ABS
Abs				tst.l	d0
				bpl.s	quit
				neg.l	d0
quit			rts

				;WAIT
Wait			move.l	d0,-(a7)
				move.l	#$FFFFFFFF,d0
\Loop			nop
				dbra	d0,\Loop
\End			move.l	(a7)+,d0
				rts

				;PRINTCHAR
PrintChar		incbin	"PrintChar.bin"
				;GETINPUT
GetInput		incbin	"GetInput.bin"

				; ==============================
 				; Données
 				; ==============================

sBuffer			ds.b	60
sTab			ds.b	10240
sTemp			ds.b	10240


