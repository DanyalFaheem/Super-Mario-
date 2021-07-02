.model large
.stack 200h
.data
x dw ? ; Starting axis for the drawing of rectangle
y dw ? ; Starting axis for the drawing of rectangle
With dw ? ; Width of rectangle
Height dw ? ; Height of rectangle
colour db 9 ; Colour of rectangle. Change it for different colours (0 - 15)
xenemy dw ? ;Coordinates for first enemies
xenemy2 dw ? ;Coordinates for the second enemy
enemydirection db 1 ;Checking if moving left or right (1 -> right, 0 -> left)
xbowser dw ?
ybowser dw ?
chng_xbowser dw 0
xcastle dw ?
ycastle dw ?
xmissile dw 300
ymissile dw ?
ymissile_inc dw ?		;increment in ycoordinate of missiles
count_bowser dw 0		;movement of bowser
level db 1 ;For level indicator
msg1 db "Insert Coint to start (Press SPACE)",'$'
msg2 db "Press ESC to exit",'$'
msg3 db "Level: 1",'$'
msg4 db "Level: 2",'$'
msg5 db "Level: 3",'$'
msg6 db "Game Over",'$'
msg7 db "Press SPACE to play again",'$'
msg8 db "Press ESC to exit",'$'
.code
	start:
	mov ax, @data
	mov ds, ax

    main PROC
        startagain:
      	call startscreen ;Calling main menu and screen
        ;call DrawBoard ; Function draws the board
        mov x, 20 ; Setting coordinates for first time use
        mov y, 420
        call DrawMario
        mov xenemy, 95 ; Setting coordinates for first time use
        mov xenemy2, 265
        mov chng_xbowser,10  ; Setting coordinates for first time use
        Untilesc: ; Loop runs until esc key pressed
                call printLevel
                mov AH, 01
                int 16H
                JNZ outta ;If key pressed, otherwise run loop again
                cmp level, 1 ; Checking if level 1 or not to print enemies
                je Untilesc
                call DrawEnemy ; To draw the enemy
                call delay
                cmp level,2 ; Checking if level 3 or not to print monster and castle
                je Untilesc
		    add chng_xbowser,20 
		    cmp chng_xbowser,200			;to keep the movement of bowser before castle
		    jle keep_mov
		    mov chng_xbowser,-200
		    keep_mov:
		    call calling_missiles
		    jmp Untilesc
            outta:
                mov AH,00  ; Clear buffer
                INT 16H
                cmp ah,48h ; If Up Arrow key
                je up_key
                cmp ah,4Bh  ; If left Arrow key
                je left_key
                cmp ah,4Dh ; If right Arrow key
                je right_key
                cmp ah,50h ; If down Arrow key
                je down_key
                cmp AL, 27  ; If EsC key pressed exit
                jne Untilesc  ; If none of these keys pressed, run loop one
                call endprogram
        up_key:
            cmp y, 410 ;If mario already in sky
            jbe upscreen
            sub y, 70
            cmp level, 1 ; If level 1
            je firstlevel
            cmp enemydirection, 0 ; Checking enemy direction to move enemy while mario is in sky
			je leftside
			add xenemy, 20
			add xenemy2, 20
			jmp upscreen1
			leftside:
			sub xenemy, 20
			sub xenemy2, 20
            upscreen1:
            call DrawEnemy
            firstlevel:
                call DrawMario ; Drawing Mario above 100 pixels
            call jumpdown   ;proc to check if mario is on platform
            call delay
            call DrawMario ; Drawing Mario back at bottom
            upscreen:
            jmp Untilesc
        down_key:
            jmp Untilesc
        right_key:
           cmp x, 620
           jae rightscreen
            add x, 15 			;mario moves 15 pixels right
            call rightCollision ;checking for collison while moving right
            call DrawMario ; Drawing Mario right 30 pixels
            call Flagcollision ;Checking if flag reached
            rightscreen:
            jmp Untilesc
        left_key:
            cmp x, 20
            jbe leftscreen
            sub x, 15				;mario moves 15 pixels left
            call leftCollision  ;checking for collison while moving left
            call DrawMario ; Drawing Mario left 30 pixels
            call Flagcollision ;Checking if flag reached
            leftscreen:
            jmp Untilesc
        call endprogram
    main ENDP

    DrawBoard PROC uses AX BX CX DX  ; Main function to Draw our Board
    ; Pushing and popping values to keep them safe
        mov Al, colour
        mov ah, 0
        push AX
        push x
        push y
        push with
        push height
        mov AL, 12H ; Function to clear screen and convert to graphics mode
        mov AH, 0
        int 10h
        mov CX, 3 ;Printing 3 bases of hurdles
        mov x, 100 ;Assigning starting values
        mov y, 440 ;Assigning starting values
        mov with, 20 ;Assigning starting values
        mov height, 50 ;Assigning starting values
        mov AL, colour
        mov AH, 0
        push AX ; Pushing colour to preserve it
        Hurdles:
            call DrawRectangle
            add x, 160 ; Increase this number to increase distance between hurdle but also increase add x line in hurdles by same amount
            add with, 5
            add height, 5 ;Increase to increase height of hurdles. Also make add y in Hurdles too same
            inc colour ;Changing colour
        LOOP Hurdles
        mov x, 90 ;Assigning starting values
        mov y, 400 ;Assigning starting values
        mov with, 40 ;Assigning starting values
        mov height, 10 ;Assigning starting values
        mov cx, 3 ;Printing 3 tops of hurdles
        pop AX ;Using the pre preserved colour
        mov colour, AL
        Hurdles2:
            call DrawRectangle
            add with, 25
            add height, 5
            sub y, 10 ; Keep this value same to add height in hurdles
            add x, 150 ;Keep this number -10 of the value in Hurdles
            inc colour
        LOOP Hurdles2
        cmp level,3		;display castle on lev 3
        je bosslev
        mov colour, 2 ;Changing colour for flagpole
        mov x, 620 ;Assigning starting values
        mov y, 440 ;Assigning starting values
        mov with, 5 ;Assigning starting values
        mov height, 300 ;Assigning starting values
        call DrawRectangle
        mov y, 210 ; Setting positions for y axis of flag
        mov with, 15 ; Size of boxes are 15 x 15
        mov height, 15
        mov cx, 5 ; 5 rows and 6 columns
        Checkerboard: ;Drawing checkerboard style for flag
            mov x, 520
            push cx
            mov ax, cx
            mov bl, 2
            div bl
            cmp ah, 0 ; Checking if even or odd row
            mov cx, 3
            je rows1
                rows: ; Odd rows
                    mov colour, 15 ; Colour white
                    call DrawRectangle
                    add x, 15
                    mov colour, 0 ; Colour Black
                    call DrawRectangle
                    add x, 15
                    loop rows
                jmp rows2 ; Jumping to end after loop completes iterations
                rows1: ; Even rows
                    mov colour, 0 ; Colour Black
                    call DrawRectangle
                    add x, 15
                    mov colour, 15 ; Colour white
                    call DrawRectangle
                    add x, 15
                    loop rows1
                rows2:
                pop cx
            sub y, 15
        loop Checkerboard
        jmp display_flag_only
        bosslev:
        call DrawCastle
        ;;;;;;;;;;;;;;;drawing bowser;;;;;;;;;;;;;;;;;;
        push ax
	inc count_bowser
	cmp count_bowser,21
	jne no_missile
	mov count_bowser,0
	no_missile:		
	mov xbowser, 250
	mov ax,chng_xbowser	
	add xbowser,ax
	mov ybowser, 100
	mov With,60
	mov Height,22
	mov colour,6
	call DrawRectanglebowser	;cheek
	mov xbowser, 255
	mov ybowser, 125
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,50
	mov Height,25
	mov colour,6
	call DrawRectanglebowser	;lower cheeks
	mov xbowser, 270
	mov ybowser, 125
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,20
	mov Height,5
	mov colour,0
	call DrawRectanglebowser	;chin
	mov xbowser, 255
	mov ybowser, 75
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,50
	mov Height,20
	mov colour,2
	call DrawRectanglebowser	;forehead
	mov xbowser, 260
	mov ybowser, 115
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,40
	mov Height,15
	mov colour,4
	call DrawRectanglebowser	;mouth
	mov xbowser, 265
	mov ybowser, 105
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,5
	mov Height,5
	mov colour,15
	call DrawRectanglebowser	;left tooth
	mov xbowser, 290
	mov ybowser, 105
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,5
	mov Height,5
	mov colour,15
	call DrawRectanglebowser	;right tooth
	mov xbowser, 260
	mov ybowser, 75
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,15
	mov Height,15
	mov colour,15
	call DrawRectanglebowser	;left eye
	mov xbowser, 265
	mov ybowser, 75
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,6
	mov Height,6
	mov colour,0
	call DrawRectanglebowser	;left eyeball
	mov xbowser, 285
	mov ybowser, 75
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,15
	mov Height,15
	mov colour,15
	call DrawRectanglebowser	;right eye
	mov xbowser, 290
	mov ybowser, 75
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,6
	mov Height,6
	mov colour,0
	call DrawRectanglebowser	;right eyeball
	mov xbowser, 265
	mov ybowser, 80
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,6
	mov Height,6
	mov colour,2
	call DrawRectanglebowser	;left nostril
	mov xbowser, 290
	mov ybowser, 80
	mov ax,chng_xbowser
	add xbowser,ax
	mov ax,xbowser
	mov count_bowser,ax	;;;;;for missiles;;;;
	mov With,6
	mov Height,6
	mov colour,2
	call DrawRectanglebowser	;right nostril
	mov xbowser, 272
	mov ybowser, 87
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,6
	mov Height,6
	mov colour,0
	call DrawRectanglebowser	;left nostril(black)
	mov xbowser, 284
	mov ybowser, 87
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,6
	mov Height,6
	mov colour,0
	call DrawRectanglebowser	;right nostril(black)
	mov xbowser, 275
	mov ybowser, 100
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,10
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;upper lip
	mov xbowser, 260
	mov ybowser, 55
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,40
	mov Height,10
	mov colour,4
	call DrawRectanglebowser	;drawing first crown
	mov xbowser, 265
	mov ybowser, 45
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,30
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;drawing second crown
	mov xbowser, 270
	mov ybowser, 40
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,20
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;drawing third crown
	mov xbowser, 265
	mov ybowser, 65
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,10
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;left eyebrow
	mov xbowser, 247
	mov ybowser, 60
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,23
	mov Height,10
	mov colour,14
	call DrawRectanglebowser	;left horn	
	mov xbowser, 245
	mov ybowser, 55
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,5
	mov Height,10
	mov colour,14
	call DrawRectanglebowser	;left upper horn			
	mov xbowser, 257
	mov ybowser, 60
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,13
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;left up eyebrow
	mov xbowser, 285
	mov ybowser, 65
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,10
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;right eyebrow
	mov xbowser, 290
	mov ybowser, 60
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,23
	mov Height,10
	mov colour,14
	call DrawRectanglebowser	;right horn
	mov xbowser, 290
	mov ybowser, 60
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,13
	mov Height,5
	mov colour,4
	call DrawRectanglebowser	;right up eyebrow
	mov xbowser, 310
	mov ybowser, 55
	mov ax,chng_xbowser
	add xbowser,ax
	mov With,5
	mov Height,10
	mov colour,14
	call DrawRectanglebowser	;right upper horn
	pop ax
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        display_flag_only: 
        mov x, 0 ; Drawing floor
        mov y, 445
        mov height, 5
        mov with, 640
        mov colour, 6
        call DrawRectangle
        pop height
        pop with
        pop y
        pop x
        pop AX
        mov colour, al
        RET
    DrawBoard ENDP
    
    ;;;;;;;;;;;;Drawing enemy;;;;;;;;;;;;;;;;
    DrawEnemy PROC 
        mov ax, xenemy ;Checking for collision for enemy 1
         sub ax, 10 ;Providing a range of 10 pixels
        cmp ax, x
        jbe checkupper
        jmp eddd
        checkupper:
            add ax, 20
            cmp ax, x
            jae collisionenemy
            jmp eddd
        collisionenemy:
            cmp y, 420 ;Checking if Mario is on floor
            jne eddd	
            call endscreen ;Calling end screen if collision
        eddd:
        mov ax, xenemy2 ; Checking for collision with enemy 2
		  sub ax, 10
        cmp ax, x
        jbe checkupper1
        jmp eddd1
        checkupper1:
            add ax, 20
            cmp ax, x
            jae collisionenemy1
            jmp eddd1
        collisionenemy1:
            cmp y, 420
            jne eddd1
            call endscreen
        eddd1:
        cmp enemydirection, 0 ;Checking if moving left or right (1 -> right, 0 -> left)
        je colissionright ; To check if there is a collision on the right side
        add xenemy, 20 ; Adding to move enemies
        add xenemy2, 20
        cmp xenemy, 245 ; Checking if there is a collision on the left side
        jae colissionleft 
		
   ;;;;;;;;;Draw after this line;;;;;;;;     
       draw:
    ; Pushing and popping values to keep them safe
        mov al, colour
        mov AH, 0
        push AX
        push x
        push y
        call DrawMario ;Calling drawmario to save screen refresh
        mov colour, 15  ; Printing base of enemy 1
        mov ax, xenemy
        mov x, ax
        mov y, 440
        mov height, 10
        mov With, 10
       call DrawRectangle
       mov xcastle, ax  ; Printing head of enemy 1
		add xcastle, 6
		mov ycastle, 430
		mov colour, 6
		mov y, 440
        mov height, 10
        mov With, 10
		call drawtri
		add x, 2 ; Printing eye 1 of enemy 1
		sub y, 12
		mov colour, 0
		mov height, 3
		mov With, 3
		call DrawRectangle
		add x, 4 ; Printing eye 2 of enemy 1
		call DrawRectangle
		mov colour, 15 ; Printing base of enemy 2
        mov y, 440
        mov ax, xenemy2
        mov x, ax
        mov height, 10
        mov with, 10
        call DrawRectangle
        mov height, 10 ; Printing head of enemy 2
		mov colour, 6
		mov xcastle, ax
		add xcastle, 6
		call Drawtri
		add x, 2 ; Printing eye 1 of enemy 2
        sub y, 12
		mov colour, 0
		mov height, 3
		mov With, 3
		call DrawRectangle
		add x, 4 ; Printing eye 2 of enemy 2
		call DrawRectangle
    ;;;;;;;;Draw before this line;;;;;;;;
        pop y
        pop x
        pop AX
        mov colour, al
        RET
        colissionleft:
            mov enemydirection, 0 ; Changing direction as enemy has reached hurdle
            sub xenemy, 20 ; To move the enemies
            sub xenemy2, 20
            RET
        colissionright:
            sub xenemy, 20 ; To move the enemies
            sub xenemy2, 20
            cmp xenemy, 125 ; If there is a collision on right side
            jbe leftt
            jmp draw
            leftt:
            mov enemydirection, 1 ;Changing direction
            add xenemy, 20
            add xenemy2, 20
        RET
    DrawEnemy ENDP
    
;;;;;;;;;;;;;;;;;;;Draw castle ;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawCastle proc
mov xcastle, 530
mov ycastle, 440
mov With,80
mov Height,80
mov colour,8
call Drawrec_castle	;center body of castle
mov xcastle, 605
mov ycastle, 440
mov With,30
mov Height,100
mov colour,9
call Drawrec_castle	;right tower
mov xcastle, 510
mov ycastle, 440
mov With,30
mov Height,100
mov colour,9
call Drawrec_castle	;left tower
mov xcastle, 558
mov ycastle, 360
mov With,30
mov Height,50
mov colour,9
call Drawrec_castle	;middle tower
mov xcastle, 620
mov ycastle, 337
mov Height,25
mov colour,4
call Drawtri	;right tower tri
mov xcastle, 525
mov ycastle, 337
mov Height,25
mov colour,4
call Drawtri	;left tower tri
mov xcastle, 575
mov ycastle, 307
mov Height,25
mov colour,4
call Drawtri	;middle tower tri
mov cx,3
mov xcastle, 548
mov ycastle, 360
fence:
mov With,10
mov Height,10
mov colour,8
call Drawrec_castle	;right tower
add xcastle,20
loop fence
mov xcastle, 618
mov ycastle, 300
mov With,15
mov Height,8
mov colour,15
call Drawrec_castle	;left flag 
mov xcastle, 523
mov ycastle, 312
mov With,1
mov Height,20
mov colour,15
call Drawrec_castle	;left flag pole
mov xcastle, 523
mov ycastle, 300
mov With,15
mov Height,8
mov colour,15
call Drawrec_castle	;right flag 
mov xcastle, 618
mov ycastle, 312
mov With,1
mov Height,20
mov colour,15
call Drawrec_castle	;right flag pole
mov xcastle, 573
mov ycastle, 270
mov With,15
mov Height,8
mov colour,15
call Drawrec_castle	;center flag
mov xcastle, 573
mov ycastle, 282
mov With,1
mov Height,20
mov colour,15
call Drawrec_castle	;center flag pole
mov xcastle, 563
mov ycastle, 440
mov With,20
mov Height,40
mov colour,6
call Drawrec_castle	;door
ret
DrawCastle endp


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Draw Mario;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    DrawMario PROC uses CX AX
        call DrawBoard
    ; Pushing and popping values to keep them safe
        mov al, colour
        mov AH, 0
        push AX
        push height
        push x
        push y
        ;;;;
        mariostart:
        mov colour, 4 ; Drawing Mario's body
        mov with, 20
        mov height, 20
        call DrawRectangle
        mov with,5 ; Drawing Mario's legs
        mov height, 20
        add x, 3
        add y, 20
        mov CX, 2
        mov colour, 3
        Legs:
            call DrawRectangle
            add x, 10
        Loop Legs
        mov with, 10 ; Drawing Mario's Arms
        mov height, 3
        sub x, 3
        sub y, 30
        mov colour, 15
        mov CX, 2
        Arms:
            call DrawRectangle
            sub x, 30
        loop Arms
        add x, 46 ; Drawing Mario's neck
        mov with, 8
        mov height, 5
        sub y, 10
        mov colour, 5
        call DrawRectangle
        sub x, 2 ; Drawing Mario's head
        sub y, 5
        mov with, 12
        mov height, 8
        mov colour, 15
        call DrawRectangle
        pop y
        pop x
        pop height
        pop AX
        mov colour, al
        RET
    DrawMario ENDP
    DrawRectangle PROC uses AX BX CX DX ;Function that draws Rectangle
        mov DX, y ; Moving y axis into variable
        sub DX, Height
        L1:
            mov CX, x ;As we are printing row wise, make sure value of x returns of same in every iteration
            add CX, with
            L2:
            mov AL, colour
            mov AH, 0CH ;Calling function to print pixel
            int 10h
            dec CX
            cmp CX, x
            jne L2
            inc DX
            cmp DX, y ;Once our height has been printed, break loop
            je outt
            jmp L1
        outt:
        RET
    DrawRectangle ENDP
    	drawtri PROC uses AX BX CX DX 			;Function that draws triangle
		push xcastle
		push ycastle
		mov dx,ycastle
		sub dx,Height
		mov cx,xcastle
		dec cx
		push cx
		loop1:
			mov ah,0ch
			mov al,colour
			int 10h
			inc cx
			cmp cx,xcastle
			jne loop1
			inc dx
			pop cx
			dec cx
			inc xcastle
			push cx
			cmp dx,ycastle
			jne loop1
			pop cx
		pop ycastle
		pop xcastle	
		RET
drawtri ENDP
;;;;;;;;;;;;;;;;;;;Rectangle function for bowser;;;;;;;;;;;;;;;;;;;    
    DrawRectanglebowser PROC uses AX BX CX DX 			;Function that draws Rectangle
        mov DX, ybowser ; Moving y axis into variable
        sub DX, Height
        L1:
            mov CX, xbowser 						;As we are printing row wise, make sure value of x returns of same in every iteration
            add CX, with
            L2:
            mov AL, colour
            mov AH, 0CH 					;Calling function to print pixel
            int 10h
            dec CX
            cmp CX, xbowser
            jne L2
            inc DX
            cmp DX, ybowser 						;Once our height has been printed, break loop
            je outt
            jmp L1
        outt:
        RET
    DrawRectanglebowser ENDP
    rightCollision PROC
    cmp x, 90
    jge decX1
    jmp skip


    decX1:        ;collision with 1st hurdle
    cmp x,110
    jg decX2
    cmp y,410
    jle skip
    sub x,15      ;reduce 40 for collision
    jmp skip

    decX2:        ;collision with 2nd hurdle
    cmp x,300
    jg decX3			;mario is to the right of 2nd hurdle
    cmp x,240			;mario is to the left of 2nd hurdle
    jl skip
    cmp y,410     ;mario is jumping
    jle skip
    sub x,15      ;reduce 40 for collision

    decX3:        ;collision with 2nd hurdle
    cmp x,440
    jg skip
    cmp x,410
    jl skip
    cmp y,410
    jle skip
    sub x,15      ;reduce 40 for collision

    skip:
    call jumpdown
    ret
    rightCollision ENDP

    leftCollision PROC
    cmp x, 40
    jge decX1
    jmp skipleft


    decX1:        ;collision with 3rd hurdle
    cmp x,450
    jg skipleft
    cmp x,440      ;mario is to the left of right hurdle
    jl decX2       ;check for collision with 2nd hurdle
    cmp y,410
    jle skipleft  ;mario is jumping
    add x,15      ;add 30 for collision
    jmp skipleft

    decX2:        ;collision with 2nd hurdle
    cmp x,220     ;mario is to the left of 2nd hurdle
    jl decX3      ;check for collison with 1st hurdle
    cmp x,280
    jg skipleft   ;mario is to the right of 2nd hurdle
    cmp y,410     ;mario is jumping
    jle skipleft
    add x,15      ;add 30 for collisions

    decX3:        ;collision with 1st hurdle
    cmp x,100     ;mario is to the left of 1st hurdle
    jl skipleft
    cmp x,110     ;mario is to the right of 1st hurdle
    jg skipleft
    cmp y,410     ;mario is jumping
    jle skipleft
    add x,15      ;add 30 for collision

    skipleft:
    call jumpdown
    ret
    leftCollision endp

    jumpdown proc   ;procedure to check if mario is on platform or not
    cmp y, 410
    jg skip
    decY1:
    cmp x, 70
    jl decrease ;mario drops back down
    cmp x, 140
    jl skip     ;mario is on top of platform
    cmp x, 230
    jl decrease ;mario drops back down
    cmp x, 300
    jl skip     ;mario is on top of platform
    cmp x, 380
    jl decrease ;mario drops back down
    cmp x, 480
    jl skip     ;mario is on top of platform
    decrease:
    add y, 70  ; Drawing Mario back at bottom
    skip:
    ret
    jumpdown endp
    
    Flagcollision PROC
    	cmp level,3 ; If level 3, then no flag but castle
    	je lev3  
        cmp x, 600 ; If Mario has reached the flag
        jae flagreached
        RET ; Returning if not at flag
        flagreached: ; Making mario climb the flag as it does in the orignal game
            cmp y, 260
            jbe flown
            sub y, 30
            call DrawMario
            call delay
        jmp flagreached
        flown:
        inc level ; Changing level as flag reaches
         mov x, 20 ; Redrawing the starting positions for the next level
        mov y, 420
        call DrawMario
        mov xenemy, 95
        mov xenemy2, 265
        jmp gameover
        lev3: ; Comparing if castle reached in level 3
        cmp x,550
        jbe gameover
        call endscreen ; Calling winning screen if castle reaches
        gameover:
        RET
    Flagcollision ENDP
   
    
    ;;;;;;;;;;;;;;;;missiles call;;;;;;;;;;;;;;
calling_missiles PROC uses ax bx cx dx
	cmp ymissile_inc,300
	jle nochnge
	mov ymissile_inc,25
	mov ax,count_bowser	
	mov xmissile,ax 
	sub xmissile,20
	nochnge:
	add ymissile_inc,40		;missle 1
	call Draw_Missile
	call delay
ret
calling_missiles endp

;;;;;;;;;;;;;;;;;;;Rectangle function for castle;;;;;;;;;;;;;;;;;;;    
Drawrec_castle PROC uses AX BX CX DX 			;Function that draws Rectangle
  mov DX, ycastle ; Moving y axis into variable
  sub DX, Height
  L1:
      mov CX, xcastle 						;As we are printing row wise, make sure value of x returns of same in every iteration
      add CX, with
      L2:
      mov AL, colour
      mov AH, 0CH 					;Calling function to print pixel
      int 10h
      dec CX
      cmp CX, xcastle
      jne L2
      inc DX
      cmp DX, ycastle 						;Once our height has been printed, break loop
      je outt
      jmp L1
  outt:
  RET
Drawrec_castle ENDP
;;;;;;;;;;;;;;;;;;;;missile function(singular);;;;;;;;;;;;;;;;;;;
	Draw_Missile proc uses AX			
	mov ymissile,90
	mov ax,ymissile_inc
	add ymissile,ax 
    mov ax, xmissile ; Comparing x axis of missile with Mario
    sub ax, 10 ; Giving it a range of 10 
    cmp ax, x
    jbe checkuppermissile
    jmp edddmissile
    checkuppermissile:
        add ax, 20
        cmp ax, x
        jae collisionmissile
        jmp edddmissile
    collisionmissile:
        mov ax, ymissile ; Comparing y-axis of Mario and missile
        add ax, 30 ; Giving it a range of 30
        cmp ax, y
        jnb collisionmissiley
        jmp edddmissile
            collisionmissiley:
            sub ax, 60
            cmp ax, y
            ja edddmissile
            call endscreen
        edddmissile:
	mov Height,30
	mov With,15
	mov colour,4
	call DrawRectangle_missile
	RET
	Draw_Missile endp



;;;;;;;;;;;;;;;;;;;Rectangle function for bowser missile;;;;;;;;;;;;;;;;;;;    
    DrawRectangle_missile PROC uses AX BX CX DX 				;Function that draws Rectangle
        mov DX, ymissile ; Moving y axis into variable
        mov cx,Height
	  sub ymissile, cx
        L1:
            mov CX, xmissile 						;As we are printing row wise, make sure value of x returns of same in every iteration
            add CX, with
            L2:
            mov AL, colour
            mov AH, 0CH 						;Calling function to print pixel
            int 10h
            dec CX
            cmp CX, xmissile
            jne L2
            dec DX
            cmp DX, ymissile						;Once our height has been printed, break loop
            je outt
            jmp L1
        outt:
        RET
    DrawRectangle_missile ENDP
    delay proc uses ax bx cx dx
mov cx,1000
mydelay:
mov bx,600    ;; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay1:
dec bx
jnz mydelay1
loop mydelay
ret
delay endp
  endprogram PROC  ; Function to return control to Operating system
        mov AH, 4ch
        int 21h
        RET
    endprogram ENDP


startscreen PROC
Untilesc1: ; Loop runs until esc key pressed
mov AL, 12H ; Function to clear screen and convert to graphics mode
mov AH, 0
int 10h

mov dh,8 				; cursor col
mov dl,24 			; cursor row
mov ah,02h 			; move cursor to the right place
xor bh,bh 			; video page 0
int 10h 				; call bios service

mov dx,OFFSET msg1		; DS:DX points to message
mov ah,9 							; function 9 - display string
int 21h 							; call dos service

mov dh,10 				; cursor col
mov dl,32 			; cursor row
mov ah,02h 			; move cursor to the right place
xor bh,bh 			; video page 0
int 10h 				; call bios service

mov dx,OFFSET msg2		; DS:DX points to message
mov ah,9 							; function 9 - display string
int 21h 							; all dos service

;;;;Checking for key press;;;;
				mov AH, 01
				int 16H
				JNZ outta1 ;If key pressed, otherwise run loop again
				call delay
				jmp Untilesc1
		outta1:
				mov AH,00  ; Clear buffer
				INT 16H
				cmp AL, 27  ; If EsC key pressed exit
				je endprogram
				cmp Al, 32			;if SPACE is pressed
				je skip
				jne Untilesc1  ; If none of these keys pressed, run loop one


				skip:
				ret
startscreen endp

printLevel proc
	cmp level, 1
	je lvl1
	cmp level, 2
	je lvl2
	cmp level, 3
	je lvl3

	lvl1:
	mov dh,1 				; cursor col
	mov dl,1 			; cursor row
	mov ah,02h 			; move cursor to the right place
	xor bh,bh 			; video page 0
	int 10h 				; call bios service

	mov dx,OFFSET msg3		; DS:DX points to message
	mov ah,9 							; function 9 - display string
	int 21h 							; call dos service
	jmp skip

	lvl2:
	mov dh,1 				; cursor col
	mov dl,1 			; cursor row
	mov ah,02h 			; move cursor to the right place
	xor bh,bh 			; video page 0
	int 10h 				; call bios service

	mov dx,OFFSET msg4		; DS:DX points to message
	mov ah,9 							; function 9 - display string
	int 21h 							; call dos service
	jmp skip

	lvl3:
	mov dh,1				; cursor col
	mov dl,1 			; cursor row
	mov ah,02h 			; move cursor to the right place
	xor bh,bh 			; video page 0
	int 10h 				; call bios service

	mov dx,OFFSET msg5		; DS:DX points to message
	mov ah,9 							; function 9 - display string
	int 21h 							; call dos service
	jmp skip




skip:
ret
printLevel endp



endscreen PROC
Untilesc1: ; Loop runs until esc key pressed
mov AL, 12H ; Function to clear screen and convert to graphics mode
mov AH, 0
int 10h

mov dh,8 				; cursor col
mov dl,36 			; cursor row
mov ah,02h 			; move cursor to the right place
xor bh,bh 			; video page 0
int 10h 				; call bios service

mov dx,OFFSET msg6		; DS:DX points to message
mov ah,9 							; function 9 - display string
int 21h 							; call dos service

mov dh,10 				; cursor col
mov dl,29 			; cursor row
mov ah,02h 			; move cursor to the right place
xor bh,bh 			; video page 0
int 10h 				; call bios service

mov dx,OFFSET msg7		; DS:DX points to message
mov ah,9 							; function 9 - display string
int 21h 							; all dos service


mov dh,12 				; cursor col
mov dl,33 			; cursor row
mov ah,02h 			; move cursor to the right place
xor bh,bh 			; video page 0
int 10h 				; call bios service

mov dx,OFFSET msg8		; DS:DX points to message
mov ah,9 							; function 9 - display string
int 21h 							; all dos service


;;;;Checking for key press;;;;
				mov AH, 01
				int 16H
				JNZ outta1 ;If key pressed, otherwise run loop again
				call delay
				jmp Untilesc1
		outta1:
				mov AH,00  ; Clear buffer
				INT 16H
				cmp AL, 27  ; If EsC key pressed exit
				je endprogram
				cmp Al, 32			;if SPACE is pressed
				je skip
				jne Untilesc1  ; If none of these keys pressed, run loop one


				skip:
				mov level,1
				jmp start
				ret
endscreen endp


end start

