; Atari Breakout
[org 0x0100]
jmp start


start:
	call clrscr
	call welcomeScr
	call boxCaller ; --> creates ball and pad
	;call ballCreator
xyz:
	call ballCreator
	call PadCreator
	call boundarycreator
	;call directionTester
	xor ax,ax
	mov es,ax
	cli
	mov word[es:9*4],padMovement
	mov [es:9*4+2],cs
	sti
	;int 0x16
	;call delay
	;call delay
	mov byte [direction],1
	;mov cx,20
	;jmp terminate
kik:
	;call directionTester
	call ballMover	
	call delay
	call delay
	call delay
	call delay
	call delay


	call collisionChecker
	jmp kik
	;cmp byte [missed],1
	;je yz
	;jmp kik
yz:
	mov byte[direction],1
	call ballCreator
	call PadCreator
zz:
	call ballMover
	call delay
	
	call delay
	call delay
	call delay
	call collisionChecker
	
	call ballMover
	call delay
	
	call delay
	call delay
	call delay
	call collisionChecker
	jmp zz
	
	jmp terminate
	

collisionChecker: ;checks if ball has hit a box
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push di
	push es
	
	mov ax,0xb800
	mov es,ax
	mov word di,[ballInd]
	
;---------------------------------Obstacle Checks--------------------------------------

.top: ;check if ball has hit a box right above it
	sub di,160
	push di
	call collisionBool
	pop di
	mov ax,[collisionColor]
	;mov word[es:2500],ax
	;mov al,[colBoool]
	;mov byte[es:2700],al
	cmp byte [colBoool],1
	je topCollision
	jmp rightCheck
	;jmp topCollision
	;mov word di,[ballInd]
	;jmp noCollision

topCollision:
	mov word di,[ballInd]
	sub di,160
	mov word [collisionIndex],di
	call boxDestroyer
	;call oppDirection
	push 0
	call TopRandGen
	pop cx
	mov byte [direction],cl
	jmp noCollision	
	;jmp deflectionTop
	
rightCheck:
	mov word di,[ballInd]
	sub di,2
	push di
	call collisionBool
	pop di
	cmp byte [colBoool],1
	je rightCollision
	mov word di,[ballInd]
	jmp belowCheck

rightCollision:
	mov word di,[ballInd]
	add di,2
	mov word [collisionIndex],di
	call boxDestroyer
	call oppDirection
	jmp noCollision
	;jmp deflectionRight


belowCheck:
	mov word di,[ballInd]
	add di,160
	push di
	call collisionBool
	pop di
	cmp byte [colBoool],1
	je bottomCollision
	jne leftCheck
	;jmp noCollision

bottomCollision:
	mov word di,[ballInd]
	add di,160
	mov word [collisionIndex],di
	call boxDestroyer
	call oppDirection
	jmp noCollision
	;jmp deflectionBottom

leftCheck:
	mov word di,[ballInd]
	sub di,2
	push di
	call collisionBool
	pop di
	cmp byte [colBoool],1
	je leftCollision
	mov word di,[ballInd]
	jmp rightBoundaryCheck
	
leftCollision:
	mov word di,[ballInd]
	sub di,2
	mov word [collisionIndex],di
	call boxDestroyer
	call oppDirection
	jmp noCollision

	;jmp deflectionLeft

rightBoundaryCheck:
	mov word ax,[RborderVal]
	cmp word[es:di+2],ax
	je rBoundaryDeflection
	mov word di,[ballInd]
	
leftBoundaryCheck:
	mov word ax,[LborderVal]
	cmp word[es:di-2],ax
	je lBoundaryDeflection
	mov word di,[ballInd]
	
roofCheck:
	mov word ax,[RoofVal]
	cmp word[es:di-160],ax
	je roofDeflection

padCheck:
	mov ax,[padColor]
	cmp word[es:di+160],ax
	je padDeflection
	jmp missedBall
	
missedBall:
	call missedChecker
	cmp byte [missed],1 ;bool 1 if ball missed
	je resetBall
	jmp noCollision
;------------------------------Deflections--------------------------------------
rBoundaryDeflection:
	;call oppDirection
	call boundaryNewDirection
	jmp noCollision
	
lBoundaryDeflection:
	;call oppDirection
	call boundaryNewDirection
	jmp noCollision
	
roofDeflection:
	;mov byte [direction],2
	push 0
	call TopRandGen
	pop cx
	mov byte [direction],cl
	jmp noCollision
padDeflection:
	;mov word di,[ballInd]
	;add di,160
	;push di
	call padNewDirection
	;call padRandGen
	;pop cx
	;mov byte [direction],cl
	jmp noCollision	

resetBall:
	call STARTSOUND
	call delay
	call delay
	call STOPSOUND
	;mov word ax,[red]
	;mov word [es:2000],ax
	mov word di,[ballInd]
	mov word[es:di],0x0720 
	;call clr2LastRow
	;call ballmakerTemp
	;call PadCreator
	call ballCreator
	call resetPad
	mov byte [direction],1
	mov byte [missed],0
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	jmp noCollision
noCollision:	
	pop es
	pop di
	pop cx
	pop bx
	pop ax
	pop bp
	ret

resetPad:
	push di
	mov di,3900
	mov word[padX1],3900
	mov bx,[padColor]
.Pad:
	mov word[es:di],bx
	add di,2
	cmp di,3920
	jne .Pad
	mov word[padX2],3920
	pop di
	ret	
	
ballMover:
	push di
	push es
	push ax
	mov ax,0xb800
	mov es,ax
	
thisLine:
	;1 = 90, 2=-90, 3=45, 4=135, 5=225, 6=315
	cmp byte [direction],1
	je up90
	jmp dir2
	;jmp ender
up90: ;x,y-1
	mov word di,[ballInd]
	mov ax,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;sub byte [ballY],1
	;call indexCalculator
	;mov word di,[ballInd]
	sub di,160
	mov word[es:di],ax
	mov word [ballInd],di
	;mov word[es:di],ax
	jmp ender
	
dir2:
	cmp byte[direction],2
	je down90
	jmp dir3
down90: ;x, y+1
	mov word di,[ballInd]
	mov bx,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;add byte [ballY],1
	;call indexCalculator
	add di,160
	mov word [ballInd],di
	mov word[es:di],bx
	jmp ender
	
dir3:	
	cmp byte [direction],3
	je ang45
	jmp dir4
	
ang45: ;x+1,y-1
	mov word di,[ballInd]
	mov bx,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;sub byte [ballY],1
	;add byte[ballX],1
	;call indexCalculator
	sub di,158
	mov word [ballInd],di
	mov word[es:di],bx
	jmp ender

dir4:
	cmp byte [direction],4
	je ang135
	jmp dir5
	
ang135: ;x-1,y-1
	mov word di,[ballInd]
	mov bx,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;sub byte [ballY],1
	;sub byte[ballX],1
	;call indexCalculator
	sub di,162
	mov word [ballInd],di
	mov word[es:di],bx
	jmp ender

dir5:
	cmp byte [direction],5
	je ang225
	jmp dir6
	
ang225: ;x-1,y+1
	mov word di,[ballInd]
	mov bx,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;add byte [ballY],1
	;sub byte[ballX],1
	;call indexCalculator
	add di,158
	mov word [ballInd],di
	mov word[es:di],bx
	jmp ender
	
dir6:	
ang315: ;x+1,y+1
	mov word di,[ballInd]
	mov bx,[ballCol] ;color loaded in ax
	mov word[es:di],0x0720 ;clear prev position
	;add byte [ballY],1
	;add byte[ballX],1
	;call indexCalculator
	add di,162
	mov word [ballInd],di
	mov word[es:di],bx
	jmp ender
	
ender:	
	pop ax
	pop es
	pop di
	ret

ballCreator:
	push di
	push es
	push ax
	mov ax,0xb800
	mov es,ax
	;mov byte[ballX],35
	;mov byte[ballY],23
	;call indexCalculator
	mov word [ballInd],3750
	mov word di,[ballInd]
	mov word[es:di],0x7020;ax;0x7020
	;add di,2
	pop ax
	pop es
	pop di
	ret

firstMove:
	push di
	push es
	push ax
	mov ax,0xb800
	mov es,ax
	
	;cmp byte [missed],1
	;jne thisLine
	;jmp ender
	
	;mov word di,[ballInd]
	;mov ax,[ballCol] ;color loaded in ax
	;mov word[es:di],0x0720 ;clear prev position
	;sub byte [ballY],1
	;call indexCalculator
	;mov word di,[ballInd]
	sub di,160
	;mov word[es:di],ax
	mov word [ballInd],di
	;mov word[es:di],ax
	pop ax
	pop es
	pop di
	ret


missedChecker: ;check if ball is in last row, no need to check for pad
	push di
	mov word di,[ballInd]
	add di,160
	cmp word di,3840
	ja check2
	pop di
	ret
check2:
	mov byte [missed],1
	sub byte[lives],1
	push word [lives]
	call printLives
	cmp byte [lives],0
	jne rettt
	call gameEnd ;jmp endgame
rettt:	
	pop di
	ret

padRandGen:
			push bp
            mov bp, sp

            push ax		
            push cx
            push dx

regennum:
            mov ah,0h                       ; interrupts to get system time
			call delay;
			call delay
			;call delay
            int 1ah                         ; CX:DX now hold number of clock ticks since midnight
            mov ax,dx
            xor dx,dx
            mov cx,6
            div cx                          ; here dx contains the remainder of the division - from 0 to 9
			
			;jmp tester
			cmp dx,1
			je end_function2
			cmp dx,3
			je end_function2
			cmp dx,4
			je end_function2
			jmp regennum
			
			
			cmp dx,9
			je sub9
			cmp dx, 4
            ja sub4
			cmp dx,2
			je add2
			jmp end_function2
add2:
			add dx,1
			jmp end_function2

sub4:
            sub dx, 4
			jmp end_function2

sub9: 
			sub dx,5
end_function2:
			mov [bp +4], dx                ; saves number in premade space
			;mov word[es:si],dx
			;add si,2
tester:
			;cmp byte dx,1
			;je test2
			;mov byte [bp+4],3
			;jmp test2
test2:
			
			pop dx
            pop cx
            pop ax
            pop bp
            ret	
			
			
boundaryNewDirection:
	cmp byte [direction],3
	je ang3to4
	cmp byte [direction],4
	je ang4to3
	cmp byte [direction],5
	je ang5to6
	cmp byte [direction],6
	je ang6to5

ang3to4:
	mov byte[direction],4
	ret
ang4to3:
	mov byte[direction],3
	ret
ang5to6:
	mov byte[direction],6
	ret
ang6to5:
	mov byte[direction],5
	ret	
	
padNewDirection: ;di pushed at bp+4
	push bp
	;mov bp,sp
	push ax
	push cx ;ballInd+160
	push di ;ballind+160
	push dx ;
	;mov word cx,[bp+4]
	mov word ax,[ballInd]
	add ax,160
	mov di,ax
	mov word cx,[padX1]
	
	sub word di,cx ;di-x1 <=6
	cmp word di,7
	jl deflect135
	
	mov di,ax
	;mov word cx,[bp+4]
	mov word cx,[padX2]
	sub word cx,di ;x2-di <=6
	cmp word cx,7
	jl deflect45
	
	mov byte [direction],1
	jmp enddir
deflect45:
	mov byte [direction],3
	jmp enddir
deflect135:
	mov byte [direction],4
	jmp enddir
enddir:	
	pop dx
	pop di
	pop cx
	pop ax
	pop bp 
	ret


oppDirection: ;changes direction to opposite side
		
	cmp byte [direction],1
	je .dir1
	
	cmp byte[direction],2
	je .dir2
	
	cmp byte [direction],3
	je .dir3
	
	cmp byte[direction],4
	je .dir4
	
	cmp byte[direction],5
	je .dir5
	
	cmp byte[direction],6
	je .dir6
	
.dir1:
	mov byte[direction],2
	jmp endOP
.dir2:
	mov byte[direction],1
	jmp endOP
.dir3:
	mov byte[direction],5
	jmp endOP
.dir4:
	mov byte[direction],6
	jmp endOP
.dir5:
	mov byte[direction],3
	jmp endOP
.dir6:
	mov byte[direction],4
	jmp endOP
		
endOP:
	ret

boxDestroyer: ;point of intersection passed at collisionIndex
	push bp
	mov bp,sp
	push ax
	push es
	push di 

	call STARTSOUND
	
	mov ax,0xb800
	mov es,ax
	mov di,[collisionIndex] ;point at which box needs to get destroyed

leftDestroyer: ;destroy left side of initial impact
	mov word[es:di],0x0720
	sub di,2
	cmp word[es:di],0x0720
	jne leftDestroyer
	
	mov di,[collisionIndex]

rightDestroyer: ;destroy right side of initial impact
	add di,2
	cmp word[es:di],0x0720;keep destroying till blank space is found
	je destroyerExit
	mov word[es:di], 0x0720
	jmp rightDestroyer	
	
destroyerExit:
	;call ballmakerTemp
	;call STARTSOUND
	pop di
	pop es
	pop ax
	pop bp
	add word [score],25
	push word [score]
	call printScore
	call delay
	call STOPSOUND
	ret

ballmakerTemp:
	push es
	push ax
	push di
	
	mov ax,0xb800
	mov es,ax
	mov word [ballInd],3590;3750
	mov word di,[ballInd]
	mov word ax,[ballCol]
	mov [es:di],ax
	pop di
	pop ax
	pop es
	ret
clrLastRow:
	push es
	push ax
	push di
	
	mov di,3840 ;last row col one
	mov ax,0xb800
	mov es,ax
	
.clrLastRow
	mov word[es:di],0x0720
	add di,2
	cmp di,4000
	jne .clrLastRow
	
	pop di
	pop ax
	pop es
	ret
clr2LastRow:
	push es
	push ax
	push di
	
	mov di,3680 ;2nd last row
	mov ax,0xb800
	mov es,ax
	
.clrLastRow
	mov word[es:di],0x0720
	add di,2
	cmp di,4000
	jne .clrLastRow
	
	pop di
	pop ax
	pop es
	ret	
padMovement:
	push es
	push ax
	push di
	push cx
	push bx
	
keyCheck:	
	;pad length 20
	;int 0x16
	;mov ah,0x1
	in al,0x60 ;keyboard scan code check
	
	cmp al,1 ;esc pressed
	je termmm
	
	cmp al,77 ;right key
	je right
	cmp al,75 ;left key
	je left 
	jmp nokey
termmm:
	call clrscr
	mov ax, 0x4c00		;terminate the program
	int 0x21
right: ;shift pad 4 units right means move 4 units of x1 to x2
	mov cx,2
	mov ax,0xb800
	mov es,ax
	cmp word[padX2],3998 ;boundarycheck
	jl r1
	jmp nokey	
	
r1:
	call clrLastRow
	add word[padX1],2
	add word[padX2],2
	mov word di,[padX1]
	mov ax,[padColor]
r2:
	mov word[es:di],ax
	add di,2
	cmp word di,[padX2]
	jne r2
	jmp nokey
	
.r1:
	;mov di,[padX1]
	;mov word[es:di],0x0720
	;add word[padX2],2
	;mov di,[padX2]
	;mov bx,[padColor]
	;mov word[es:di],bx
	;add word[padX1],2
	;cmp word[padX2],3998 ;boundarycheck
	;je nokey
	;loop .r1 
	
left:
	;mov cx,2
	mov ax,0xb800
	mov es,ax
	cmp word[padX1],3840 ;boundarycheck
	jbe nokey
	jmp l1
	;jmp nokey
l1:
	call clrLastRow
	sub word[padX1],2
	sub word[padX2],2
	mov word di,[padX1]
	mov ax,[padColor]
l2:
	mov word[es:di],ax
	add di,2
	;cmp word di,3842
	;jb nokey
	cmp word di,[padX2]
	jne l2
	jmp nokey

nokey:
	mov al,0x20
	out 0x20,al
	
	pop bx
	pop cx
	pop di
	pop ax
	pop es
	iret
	
	

collisionBool: ;bp+4 di+offset
	push bp
	mov bp,sp
	push ax
	push di
	
	mov word di,[bp+4]
	
	mov word ax,[red]
	cmp word [es:di],ax
	je MatchXY
	
	mov word ax,[blue]
	cmp word [es:di],ax
	je MatchXY
	
	mov word ax,[nBlue]
	cmp word [es:di],ax
	je MatchXY
	
	mov word ax,[green]
	cmp word [es:di],ax
	je MatchXY
	
	mov byte [colBoool],0
	jmp endXY
	
MatchXY:
	mov byte [colBoool],1
	mov word [collisionColor],ax
	jmp endXY
	
	
endXY:
	pop di
	pop ax
	pop bp
	ret
	
	
indexCalculator: ;convert x,y coordinate to di index (x*80+y)*2
	;return value at bp+4
	push bp
	mov bp,sp
	push ax
	
	mov ax,0
	mov al,80
	mul byte[ballY] ;80*Y
	add byte al,[ballX] ;(80*Y)+X
	shl ax,1 ;2((80*Y)+X)
	mov word[ballInd],ax
	;mov word[bp+4],ax 
	pop ax
	pop bp
	ret

	;int 0x16
	
	;in al, 0x60
	;in al, 0x60
	;cmp al, 109 ;rigth key pressed
	;je right

saveBox:
	;push si
	push di
	push cx
	
	mov cx,di
	mov di,[memIndex] ;starting coordinate of box
	mov [boxMem+di],cx
	mov cx,[boxMem+di]
	mov word [es:si],cx
	add si,2
	inc di
	
	add dx,4 ;for space
	mov [boxMem+di],dx ;length of box + space
	add byte[memIndex],2
	
	mov cx,[boxMem+di]
	mov word [es:si],cx
	add si,2
	
	call delay
	pop cx
	pop di
	;pop si
	ret





nextBox:
	push 0
	;call RANDGEN
	call random_box
	pop dx
	;mov word[es:si],dx
	;add si,2
	;mov dx,[rand]
	;mov dl,
	;cmp dx,0 ;if randNum = 0 then call again
	;je RANDGEN
pbox:
	;call saveBox
	mov word [es:di],bx; [color]
	add di, 2
	sub cx,2 ;160 count line
	sub dx,2 ;rand val
	cmp cx,0
	jle nextRow
	;cmp cx,0
	;jle nextRow
	cmp dx,1
	jg pbox
	jmp nxtBox
	;jle nxtBox
	;jmp pbox
nxtBox:
	call spacePrint
	;call delay
	sub cx,4 ;4 units substracted for space 
	cmp cx,0
	jle nextRow
	jmp nextBox
	;jmp terminate
nextRow:
	ret
boxCaller:;for each row 
;green 2A, red 46, blue 13 
	push es
	push ax
	push di
	push cx
	push dx ;dx contains random number
	push si
	call STARTSOUND
	CALL STOPSOUND
	mov dx,0
	mov ax,0xb800
	mov es,ax
	mov di,480
	mov si,0
	mov cx,160

row1: ;each box has length 20 then space for 10 units
	mov bx,[green]
	mov [color],bx
	call nextBox
	mov di,640
	;add si,2
	mov cx,160
	;jmp terminate
row2: ;each box has length 20 then space for 10 units
	mov bx,[blue]
	mov [color],bx
	call nextBox
	mov di,800
	mov cx,160
	
row3: ;each box has length 20 then space for 10 units
	mov bx,[nBlue]
	mov [color],bx
	call nextBox
	mov di,960
	mov cx,160
	
row4: ;each box has length 20 then space for 10 units
	mov bx,[red]
	mov [color],bx
	call nextBox
	mov di,1120
	mov cx,160
	
	mov ax, 0
	push ax				; push r position............[bp+12]
	mov ax, 1
	push ax				; push c position............[bp+10]
	mov ax, 7			; normal attribute
	push ax				; push attribute............[bp+8]
	mov ax, scoreTxt
	push ax				; push address of message............[bp+6]
	push word [length1]	; push message length ....[bp+4]
	
	call printstr ; call the printstr subroutine	

	mov ax, 0
	push ax				; push r position............[bp+12]
	mov ax,70 
	push ax				; push c position............[bp+10]
	mov ax, 7			; normal attribute
	push ax				; push attribute............[bp+8]
	mov ax, livesTxt
	push ax				; push address of message............[bp+6]
	push word [length2]	; push message length ....[bp+4]
	
	call printstr ; call the printstr subroutine

	mov ax, 0
	push ax				; push r position............[bp+12]
	mov ax,30 
	push ax				; push c position............[bp+10]
	mov ax, 7			; normal attribute
	push ax				; push attribute............[bp+8]
	mov ax, arr1
	push ax				; push address of message............[bp+6]
	mov ax,13
	push ax	; push message length ....[bp+4]
	
	call printstr ; call the printstr subroutine
	
	
	mov ax,[score]
	push ax
	call printScore
	mov ax,[lives]
	push ax
	call printLives





strScore: ;Score:
;	mov ah, 0x13 ; service 13 - print string
;	mov al, 1 ; subservice 01 – update cursor
;	mov bh, 0 ; output on page 0
;	mov bl, 14 ; attribute
;	mov dx, 0x0192; row 0 column 20
;	mov cx, 6 ; length of string
;	push cs
	;pop es ; segment of string
	;mov bp, scoreTxt ; offset of string
	;int 0x10
	;call PadCreator
	;call ballCreator
	
	pop si
	pop dx
	pop cx
	pop di
	pop ax
	pop es
	ret
	
PadCreator:
	push di
	mov di,3900
	mov word[padX1],3900
	mov bx,[padColor]
.Pad:
	mov word[es:di],bx
	add di,2
	cmp di,3920
	jne .Pad
	mov word[padX2],3920
	pop di
	ret
	
spacePrint:

	;push cx
	;mov cl,0
x1:	
	mov word[es:di],0x0720
	add di,2
	mov word[es:di],0x0720
	add di,2
	;add cl,2
	;cmp cl,4
	;jne x1
	;pop cx
	ret 	
delay:     
            push cx
			mov cx, 0xFFFF
loop1:		loop loop1
			pop cx
			ret	
random_box:              ; creates random size of box from 5 to 9

            push bp
            mov bp, sp

            push ax		
            push cx
            push dx

            mov ah,0h                       ; interrupts to get system time
			call delay;
			call delay
			call delay
            int 1ah                         ; CX:DX now hold number of clock ticks since midnight
            mov ax,dx
            xor dx,dx
            mov cx,6
            div cx                          ; here dx contains the remainder of the division - from 0 to 9
            cmp dx, 4
            jnb end_function

add_4:
            add dx, 4

end_function:
			shl dx,2
            mov [bp +4], dx                ; saves number in premade space
			;mov word[es:si],dx
			;add si,2
			pop dx
            pop cx
            pop ax
            pop bp
            ret	



clrscr:	
	push es
	push ax
	push di

	mov ax, 0xb800
	mov es, ax					; point es to video base
	mov di, 0					; point di to top left column

nextloc:	
	mov word [es:di], 0x0720	; clear next char on screen
	add di, 2					; move to next screen location
	cmp di, 4000				; has the whole screen cleared
	jne nextloc					; if no clear next position			
	pop di
	pop ax
	pop es
	ret
boundarycreator:
	push ax
	push es
	push di
	
	mov ax,0x0b800
	mov es,ax
	
leftBorder:
	mov di,0 
	mov ax,[LborderVal]
lb:
	mov word[es:di],ax
	add di,160
	cmp di,3680
	jl lb
	
rightBorder:
	mov di,158
	mov ax,[RborderVal]
.rb:
	mov word[es:di],ax
	add di,160
	cmp di,3838
	jl .rb

roofBorder:
	mov di,160
	mov ax,[RoofVal]
roofb:
	mov word[es:di],ax
	add di,2
	cmp di,320
	jl roofb		
	
	pop di
	pop es
	pop ax
	ret

directionTester:
	push ax
	push cx
	
	add byte[direction],1
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
x11:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x11
	
	;cmp di,0
	;jne op2
	;jmp terminate
	
	mov byte[direction],2
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
	
	;jmp terminate
x2:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x2
	
	mov byte[direction],3
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
x3:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x3
	mov byte[direction],4
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
x4:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x4
	mov byte[direction],5
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
x5:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x5
	mov byte[direction],6
	mov cx,5
	mov ah,0
	int 0x16 ;press any key to start
x6:
	call ballMover
	;call keyCheck
	call delay
	;call delay
	;call delay
	loop x6	
	
	pop cx
	pop ax
	ret

TopRandGen:
			push bp
            mov bp, sp

            push ax		
            push cx
            push dx
regenrand:
            mov ah,0h                       ; interrupts to get system time
			call delay;
			;call delay
			call delay
            int 1ah                         ; CX:DX now hold number of clock ticks since midnight
            mov ax,dx
            xor dx,dx
            mov cx,6
            div cx                          ; here dx contains the remainder of the division - from 0 to 9
           
			cmp dx,2
			je end_function3
			cmp dx, 5
            ja end_function3
			cmp dx,6
			je end_function3
			jmp regenrand
;add2:
			add dx,1
			jmp end_function2

;sub4:
            sub dx, 4
			jmp end_function2

;sub9: 
			sub dx,5
end_function3:
			mov [bp +4], dx                ; saves number in premade space
			;mov word[es:si],dx
			;add si,2
			pop dx
            pop cx
            pop ax
            pop bp
            ret	

welcomeScr:
	push ax
	call welc2

w2:
	mov ah,0
	int 0x16 			; keyboard activated	
	cmp al,27	;esc pressed
	je term
	in al, 0x60
	in al, 0x60
	cmp al,0x64 ;esc scancode
	je term
	cmp al, 0x1c
	jne w2
	;cmp al,0x1B ;enter pressed
	;je gback
	;jmp w2
gback:
	pop ax
	call clrscr
	ret
term:
	mov ax, 0x4c00		;terminate the program
	int 0x21
;==================================== Introduction screen ============================================

welc2:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx				;pushing into stack
	push dx
	push es
	push di
	push si
	
	
str1: ;developed by
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x0115; row 1 column 15
	mov cx, 39 ; length of string
	push cs
	pop es ; segment of string
	mov bp, arr ; offset of string
	int 0x10

str2: ;COALE
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x0223; row 2 column 23
	mov cx, 8 ; length of string
	push cs
	pop es ; segment of string
	mov bp, arr0 ; offset of string
	int 0x10

str3: ;Atari Breakout
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x920; row 9 column 20
	mov cx, 13 ; length of string
	push cs
	pop es ; segment of string
	mov bp, arr1 ; offset of string
	int 0x10

str4: ;Press Enter/Escape
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x1013; row 9 column 20
	mov cx, 38 ; length of string
	push cs
	pop es ; segment of string
	mov bp, arr2 ; offset of string
	int 0x10

str5: ;break bricks....
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x1113; row 11 column 13
	mov cx, 35 ; length of string
	push cs
	pop es ; segment of string
	mov bp, arr3 ; offset of string
	int 0x10		

str6: ;keyboard nav
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x1219; row 12 column 13
	mov cx, 24	; length of string
	push cs
	pop es ; segment of string
	mov bp, arr4 ; offset of string
	int 0x10	

	
	mov ax , 0x0b800		
	mov es , ax
	mov di,1634
	mov al,'*'	
	mov ah, 0xcc
end11:
	mov word[es:di],ax
	add di,2
	cmp di,1714
	jne end11
	mov al,'*'
	mov ah, 0xcc
	mov di,1794
end22:
	mov al,'*'
	mov ah, 0xcc
	mov word [es:di],ax	
	add di,78
	mov word[es:di],ax
	add di,82
	cmp di,2434
	jne end22
	mov di,2434
end33:
	mov al,'*'
	mov ah, 0xcc
	mov word[es:di],ax
	add di,2
	cmp di,2514
	jne end33

	mov ax , 0x0b800		
	mov es , ax
	mov di,160
	mov ah,0x0e
	mov si,0

	
	pop si
	pop di
	pop es
	pop dx				;clearing entire stack
	pop cx
	pop bx
	pop ax
	pop bp
	ret
	

printstr:	push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di

			mov ax, 0xb800
			mov es, ax				; point es to video base

			mov al, 80				; load al with columns per row
			mul byte [bp+12]		; 80 x r
			add ax, [bp+10]			; word number (80xr) + c
			shl ax, 1				; byte no (((80xr) + c)x2)

			mov di, ax				; point di to required location
			mov si, [bp+6]			; point si to string
			mov cx, [bp+4]			; load length of string in cx
			mov ah, [bp+8]			; load attribute in ah

nextchar:	mov al, [si]			; load next char of string
			mov [es:di], ax			; show this char on screen
			add di, 2				; move to next screen location
			add si, 1				; move to next char in string
			call delay
			loop nextchar			; repeat the operation cx times

			pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 10

printScore: 
				push bp
				mov bp, sp
				push es
				push ax
				push bx
				push cx
				push dx
				push di

				mov ax, 0xb800
				mov es, ax			; point es to video base

				mov ax, [bp+4]		; load number in ax= 4529
				mov bx, 10			; use base 10 for division
				mov cx, 0			; initialize count of digits

.nextdigit:		mov dx, 0			; zero upper half of dividend
				div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
				add dl, 0x30		; convert digit into ascii value
				push dx				; save ascii value on stack

				inc cx				; increment count of values
				cmp ax, 0			; is the quotient zero
				jnz .nextdigit		; if no divide it again


				mov di, 14			; point di to top left column
nextpos:		pop dx				; remove a digit from the stack
				mov dh, 0x07		; use normal attribute
				mov [es:di], dx		; print char on screen
				add di, 2			; move to next screen location
				loop nextpos		; repeat for all digits on stack

				pop di
				pop dx
				pop cx
				pop bx
				pop ax
				pop es
				pop bp
				ret 2
				
printScore2: 
				push bp
				mov bp, sp
				push es
				push ax
				push bx
				push cx
				push dx
				push di

				mov ax, 0xb800
				mov es, ax			; point es to video base

				mov ax, [bp+4]		; load number in ax= 4529
				mov bx, 10			; use base 10 for division
				mov cx, 0			; initialize count of digits

.nextdigit:		mov dx, 0			; zero upper half of dividend
				div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
				add dl, 0x30		; convert digit into ascii value
				push dx				; save ascii value on stack

				inc cx				; increment count of values
				cmp ax, 0			; is the quotient zero
				jnz .nextdigit		; if no divide it again


				mov di, 2000			; point di to top left column
.nextpos:		pop dx				; remove a digit from the stack
				mov dh, 0x07		; use normal attribute
				mov [es:di], dx		; print char on screen
				add di, 2			; move to next screen location
				loop .nextpos		; repeat for all digits on stack

				pop di
				pop dx
				pop cx
				pop bx
				pop ax
				pop es
				pop bp
				ret 2
printLives: 
				push bp
				mov bp, sp
				push es
				push ax
				push bx
				push cx
				push dx
				push di

				mov ax, 0xb800
				mov es, ax			; point es to video base

				mov ax, [bp+4]		; load number in ax= 4529
				mov bx, 10			; use base 10 for division
				mov cx, 0			; initialize count of digits

.nextdigit:		mov dx, 0			; zero upper half of dividend
				div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
				add dl, 0x30		; convert digit into ascii value
				push dx				; save ascii value on stack

				inc cx				; increment count of values
				cmp ax, 0			; is the quotient zero
				jnz .nextdigit		; if no divide it again


				mov di, 154			; point di to top left column
.nextpos:		pop dx				; remove a digit from the stack
				mov dh, 0x07		; use normal attribute
				mov [es:di], dx		; print char on screen
				add di, 2			; move to next screen location
				loop .nextpos		; repeat for all digits on stack

				pop di
				pop dx
				pop cx
				pop bx
				pop ax
				pop es
				pop bp
				ret 2


gameEnd:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx				;pushing into stack
	push dx
	push es
	push di
	push si
	
	call STARTSOUND
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call STOPSOUND
	
	call clrscr
	
endStr: db 'Game Over',0
	
endString: ;Game Over
	mov ah, 0x13 ; service 13 - print string
	mov al, 1 ; subservice 01 – update cursor
	mov bh, 0 ; output on page 0
	mov bl, 14 ; attribute
	mov dx, 0x0920; row 1 column 15
	mov cx, 9 ; length of string
	push cs
	pop es ; segment of string
	mov bp, endStr ; offset of string
	int 0x10
	
	
	mov ax, 12
	push ax				; push r position............[bp+12]
	mov ax, 27
	push ax				; push c position............[bp+10]
	mov ax, 7			; normal attribute
	push ax				; push attribute............[bp+8]
	mov ax, scoreTxt
	push ax				; push address of message............[bp+6]
	mov word ax,7
	push ax ; word [length1]	; push message length ....[bp+4]
	
	call printstr ; call the printstr subroutine
	
	push word [score]
	call printScore2
	
	
	mov ax , 0x0b800		
	mov es , ax
	mov di,1634
	mov al,'*'	
	mov ah, 0xcc
.end11:
	mov word[es:di],ax
	add di,2
	cmp di,1714
	jne .end11
	mov al,'*'
	mov ah, 0xcc
	mov di,1794
.end22:
	mov al,'*'
	mov ah, 0xcc
	mov word [es:di],ax	
	add di,78
	mov word[es:di],ax
	add di,82
	cmp di,2434
	jne .end22
	mov di,2434
.end33:
	mov al,'*'
	mov ah, 0xcc
	mov word[es:di],ax
	add di,2
	cmp di,2514
	jne .end33

	mov ax , 0x0b800		
	mov es , ax
	mov di,160
	mov ah,0x0e
	mov si,0

	jmp terminate
	
	pop si
	pop di
	pop es
	pop dx				;clearing entire stack
	pop cx
	pop bx
	pop ax
	pop bp
	ret


STARTSOUND:	;CX=FREQUENCY IN HERTZ. DESTROYS AX & DX
CMP CX, 014H
JB STARTSOUND_DONE
;CALL STOPSOUND
IN AL, 061H
;AND AL, 0FEH
;OR AL, 002H
OR AL, 003H
DEC AX
OUT 061H, AL	;TURN AND GATE ON; TURN TIMER OFF
MOV DX, 00012H	;HIGH WORD OF 1193180
MOV AX, 034DCH	;LOW WORD OF 1193180
DIV CX
MOV DX, AX
MOV AL, 0B6H
PUSHF
CLI	;!!!
OUT 043H, AL
MOV AL, DL
OUT 042H, AL 
MOV AL, DH
OUT 042H, AL
POPF
IN AL, 061H
OR AL, 003H
OUT 061H, AL
	STARTSOUND_DONE:
RET

	STOPSOUND:	;DESTROYS AL
IN AL, 061H
AND AL, 0FCH
OUT 061H, AL
RET


arr: db 'Developed by Nehal and  Minahil  ',0
arr0: db 'COAL   ',0
arr1: db 'Atari Breakout',0
arr2: db 'Press Enter to Continue or Esc to Exit',0
arr3: db 'Break Bricks and Dont Miss the Ball',0
arr4: db 'Use Keyboard to Navigate',0
scoreTxt: db 'Score:',0
green: dw 0x2A20
red: dw 0x4020
blue: dw 0x1320 ;1320
nBlue: dw 0x3520
color: dw 0 ;current color code placed here
padX1: dw 0 ;pad length 20
padX2: dw 0
padColor: dw 0x3620
ballX: db 0
ballY: db 0
ballInd: dw 0
ballCol: dw 0x7020
collisionIndex: dw 0 ;index at which collision occurs 
colBoool: db 0 ;checks whether ball is about to hit coloured block
collisionColor: dw 0 ;collision with which color box
direction: db 0 ;1 = 90, 2=-90, 3=45, 4=135, 5=225, 6=315
score: dw 0 ;game score
length1: db 6 ;Score:
missed: db 0 ;bool variable set to 1 if ball is missed
lives: dw 3 ;3 lives
livesTxt: db 'Lives:'
length2: db 6
LborderVal: dw 0x00;0x7020 ;border left value
RborderVal: dw 0x00;7020 ;right border value
RoofVal: dw 0x7020;0x7020;roof val
rand: dw 0;
memIndex: db 0
boxMem: db 0
testvrb: dw 0
testval: dw 2500

terminate:
	mov ax, 0x4c00		;terminate the program
	int 0x21