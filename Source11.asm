;Developer : M. Wissam
;github: Wissam117
INCLUDE Irvine32.inc
INCLUDE Macros.inc
includelib winmm.lib


;todo:

;1. 1st page – Name of game , Name of user (as an input) , 2nd page – Menu ----- 5 marks ,
;   Pause screen  , Instruction’s screen ----- 2 marks , 3rd page – Game Setup -----3 marks
;2. Make procedures and use stack calls
;3. levels
;4. bonus features e.g sound

PlaySound PROTO, pszSound:PTR BYTE, hmod:DWORD, fdwSound:DWORD


.data  

comma BYTE ',', 0
score2digits dd ?

digit2 db ?
;buffer
numu byte ?           
  bufferu BYTE ?   
  newlineu BYTE 0DH, 0AH, 0   

BUFFER_SIZE=501
buffer BYTE ?
xb byte 11 dup(0)
bufSize db ?

errMsg BYTE "Cannot open file",0dh,0ah,0
filename     BYTE "names.txt",0
filename2    byte "scores.txt",0        
fileHandle   DWORD ?	; handle to output file
bytesWritten DWORD ?    	; number of bytes written


;sound feature
sounder BYTE "sounder",0
SND_ALIAS    DWORD 00010000h
SND_RESOURCE DWORD 00040005h
SND_FILENAME0 DWORD 00020400h
SND_FILENAME1 DWORD 00030000h
SND_FILENAME2 DWORD 00040000h
SND_FILENAME3 DWORD 00050000h
SoundFileName0 db "gamestart.wav", 0
SoundFileName1 db "pacmansoundeat.wav", 0
SoundFileName2 db "livelost.wav", 0

;color palette
ytog = yellow + (Blue *16); Yellow Text On Green
mtob=Magenta + (brown* 16);Magenta Text On Brown
lctoc=lightCyan+ (Cyan*16) ;Light Cyan Text On Cyan
ctor= Cyan+(red*16) ;Cyan Text On Red
rtog = red+(Gray*16);Red Text On Grey
btoy=Blue+(yellow * 16) ;Blue Text On Yellow
 
;filehandling

name1 db ?
sofname=12

score1 db ?
sofscore=10

;gob
gob1 db 0
gob2 db 0
gob3 db 0
gob4 db 0
gob5 db 0
gob6 db 0
gobf db 0
;input vars
name_i dword 12

;file handling

;ground making
ground BYTE "------------------------------------------------------------------------------------------------------------------------",0
ground1 BYTE "|",0ah,0
ground2 BYTE "|",0

;temp variable
temp byte ?

;score
strScore BYTE "Your score is: ",0
sstrscore byte "Score is "
score BYTE 0,0ah,0dh,0


;player position
xPos BYTE 20
yPos BYTE 20

;ghosts
g1ix db 43
g1x db 43
g1lx db 65
g1y db 15
g2x db 35
g2iy db 4
g2y db 4
g2ly db 26
g3x db 66
g3iy db 4
g3y db 4
g3ly db 26
g4x db 2
g4lx db 24
g4y db 11
g5x db 68
g5lx db 90
g5y db 19


;coin position
xCoinPos BYTE ?
yCoinPos BYTE ?

;fruit position
xfruitpos byte ?
yfruitpos byte ?

;input from keyboard
inputChar BYTE ?

;Wall Coordinates and blocks of map
wx byte ?
wy byte ?
no_blocks dword ?
og_x byte ?

;levelling
levelno db 1
strlevelno db "Level :",0ah

;lives
lives db 2
strlives db " Lives : "

;progressbar helpers
pgx byte ?
pggy byte ?
delaytime dword ?
nohash dword ?

;range definition
lower dword ?
upper dword ?
coin_help db ?
;lvl1walls
lmhelp dword ?
hpx byte ?
hpy byte ?

.code
;vertical wall proc
draw_vwall  proc uses ecx
mov ecx,0
mov ecx,no_blocks
mGotoxy wx,wy
mWrite " _"
w1:
inc wy
mgotoxy wx,wy
mWrite "| |"
inc wy
mgotoxy wx,wy
mWrite "| |"
loop w1
inc wy
mgotoxy wx,wy
mWrite "|_|"
ret 0
draw_vwall endp

;horizontal wall proc
draw_hwall proc uses ecx
mov ecx,0
mov ecx,no_blocks
add ecx,no_blocks
add ecx,no_blocks
mov bl, wx
mov  og_x,bl
mGotoxy wx,wy
mWrite "|"
dec wy
dec wx
wh1:
add wx,2
mgotoxy wx,wy
mWrite "__"
loop wh1
inc wy
mov ecx,no_blocks
add ecx,no_blocks
add ecx,no_blocks
dec og_x
wh2:
add og_x,2
mgotoxy og_x,wy
mWrite "__"
loop wh2
add og_x,2
mGotoxy og_x,wy
mWrite "|"
ret 0
draw_hwall endp 

;progress bar making
progressbar_ proc uses ecx
push eax
mov ecx,nohash
pgl1:
mGotoxy pgx, pggy
mWrite "###"
mov eax,delaytime
call delay
add pgx,3
loop pgl1
pop eax
ret 0
progressbar_ endp
;better random range
BetterRandomRange PROC
mov eax,upper
mov ebx,lower
sub eax, ebx
call RandomRange
add eax, ebx
ret
BetterRandomRange ENDP

pause_screen proc

mgotoxy 20,0
mwrite "Your game is paused"
mgotoxy 45,0
call waitmsg
mgotoxy 20,0
mwrite "                                                        "
call UpdatePlayer
call DrawPlayer
jmp gameLoopp

pause_screen endp

game_over_screen proc

call clrscr
mov eax,red
call settextcolor

mgotoxy 40,15
mwrite "Game over! you lost!"
mgotoxy 40,17
mwrite "Your final score was : "
movzx eax,score
call writedec
mgotoxy 80,26
comment @
 mov edx, offset score
    mov ax, [edx]
    mov bl, 10
    div bl
    mov digit2, ah
    cmp al, 0
    je OneDigit
    add al, 48
   mov bufferu,al

    OneDigit:
    mov edx, offset score2digits
    mov ah, digit2
    add ah, 48
    mov bufferu,ah
  
    akff:
    @
INVOKE CreateFile,
	  ADDR filename2, GENERIC_WRITE, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov fileHandle,eax	
	INVOKE SetFilePointer,
	  fileHandle,0,0,FILE_END
	INVOKE WriteFile, fileHandle, ADDR bufferu,5, ADDR bytesWritten, 0
	INVOKE CloseHandle, fileHandle

call exitproc

game_over_screen endp

win_screen proc

call clrscr
mov eax,red
call settextcolor

mgotoxy 40,15
mwrite "YOU WON!! CONGRATULATIONS!!!"
mgotoxy 80,26
comment @
 mov edx, offset score
    mov ax, [edx]
    mov bl, 10
    div bl
    mov digit2, ah
    cmp al, 0
    je OneDigit
    add al, 48
   mov bufferu,al

    OneDigit:
    mov edx, offset score2digits
    mov ah, digit2
    add ah, 48
    mov bufferu,ah
  
    akff:
    @
INVOKE CreateFile,
	  ADDR filename2, GENERIC_WRITE, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov fileHandle,eax	
	INVOKE SetFilePointer,
	  fileHandle,0,0,FILE_END
	INVOKE WriteFile, fileHandle, ADDR bufferu,5, ADDR bytesWritten, 0
	INVOKE CloseHandle, fileHandle



call exitproc

win_screen endp


gameloopp proc
  jmp gameloop
lvl1wallsu: ;wh1: 1,15  , wh2 : 85,15 , wv1: 57,2 , wv2: 57,16
mov eax,0
mov ebx,0
mov al,xpos
mov bl,ypos
cmp bl,2
jle nomov ;boundary
jmp mutu

lvl1wallsd:
mov eax,0
mov al,ypos
cmp al,27
jge nomov
jmp mutd 

lvl1wallsl:
mov eax,0
mov al,xpos
cmp al,2
jle nomov
jmp mutl  

lvl1wallsr:
mov eax,0
mov al,xpos
cmp al,115
jge nomov
jmp mutr

lvl2wallsu:
mov eax,0
mov al,ypos
cmp al,2
jle nomov
jmp mutu
 
lvl2wallsd:
mov eax,0
mov al,ypos
cmp al,28
jge nomov
jmp mutd 

lvl2wallsl:
mov eax,0
mov al,xpos
cmp al,2
jle nomov
jmp mutl 

lvl2wallsr:
mov eax,0
mov al,xpos
cmp al,115
jge nomov
jmp mutr

lvl3wallsu:
mov eax,0
mov al,ypos
cmp al,2
jle nomov
jmp mutu


lvl3wallsd:
mov eax,0
mov al,ypos
cmp al,28
jge nomov
jmp mutd 
 

lvl3wallsl:
mov eax,0
mov al,xpos
cmp al,2
jle nomov
jmp mutl 

lvl3wallsr:
mov eax,0
mov al,xpos
cmp al,115
jge nomov
jmp mutr
 
 
  fruita:
  call CreateRandomfruitb
  jmp comeback

  fruitb:
 call createRandomfruita
  jmp comeback
  
   coinb:
  call CreateRandomCoinb
  jmp comeback
  coina:
  call createRandomCoina
  jmp comeback

gameLoop:
mov ecx,1000000000
 nomov:

; getting points:

cmp levelno,2
jl ltl2
jge lplpl2
lplpl2:
mov bl,xPos
cmp bl,xfruitPos
jne ltl2
mov bl,yPos
cmp bl,yfruitPos
jne ltl2

; player is intersecting fruit
add score,3
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen

cmp score,4
jl ll1
cmp score,8
jl ll2
jge ll3

ll2:
mov levelno,2
jmp ll1
ll3:
mov levelno,3
ll1:
;win and loose condition
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen
ltl2:
  

mov bl,xPos
cmp bl,xCoinPos
jne notCollecting
mov bl,yPos
cmp bl,yCoinPos
jne notCollecting

; player is intersecting coin:
 
inc score

INVOKE PlaySound, OFFSET SoundFileName1, NULL, SND_FILENAME1
    
;level number increasing
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen

cmp score,4
jl ill1
cmp score,8
jl ill2
jge ill3

ill2:
mov levelno,2
jmp ill1
ill3:
mov levelno,3
ill1:
;win and loose condition
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen
;alternating random location for coin and fruit

test score,01
jz coinb
jnz coina

cmp levelno,2
jl ncmpc
jge ppcp
ppcp:
test score,01
jz fruitb
jnz fruita

ncmpc:

; checking collision with ghosts and decrementing score


jmp continueGameLoop


dec lives
call updatelifedisplay
invoke PlaySound, addr SoundFileName2, 0, SND_FILENAME3

; Check if score is greater than 0 before decrementing
cmp score, 0
jle noScoreDecrement
dec score


   
noScoreDecrement:
nolivedecrement:
; Continue with the game loop
jmp continueGameLoop

; Add any additional logic you want to perform on collision, like sound or effects.

continueGameLoop:
   comeback:
call DrawCoin
cmp levelno,2
jge l23ff
jl l1ff
l23ff:
call drawfruit
l1ff:

notCollecting:
mov eax,red
call SetTextColor

; draw score:
mov dl,0
mov dh,0
call Gotoxy
mov edx,OFFSET strScore
call WriteString
mov al,score
call WriteInt
;change level number
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen
cmp score,4
jl ll11
cmp score,8
jl ll22
jge ll33

ll22:
mov levelno,2
jmp ll11
ll33:
mov levelno,3
ll11:
;draw level number


;draw lives
mov dl,75
mov dh,0
call Gotoxy
mov eax,red
call SetTextColor
 
mov edx, OFFSET strlives
call WriteString
push ebx
movzx  ebx,lives
li:
mwrite 3
dec ebx
cmp ebx,0
jg li
mwrite " "
pop ebx

mov dl, 111
mov dh,0
call Gotoxy
mwrite "Level :"
mov al,levelno
call WriteInt

   
cmp levelno,1
je aa
jne bb 
aa:
cmp gob2,0
jg aaaaa

mov gob2,1
aaaaa:
call dm_ghosts1
 jmp eee
bb:
cmp levelno,2
je cc
jne ddd
cc: 
cmp gob3,0
jg cccc
   
mov gob3,1
cccc:
call dm_ghosts2
jmp eee
ddd:
cmp levelno,3
je dddd
jne eee
dddd:
cmp gob4,0
jg ddddd

mov gob4,1
ddddd:
call dm_ghosts3
eee:
; get user key input:
call ReadChar
mov inputChar,al


;xpos,ypos

; exit game if user types 'x':
cmp inputChar,"x"
je exitGame

cmp inputChar,"w"
je moveUp

cmp inputChar,"s"
je moveDown

cmp inputChar,"a"
je moveLeft

cmp inputChar,"d"
je moveRight

cmp inputchar,"p"
je pause_screen

cmp inputchar,"r"
je kkk
jne kkl
kkk:
mgotoxy xcoinpos,ycoinpos
mwrite " "

cmp levelno,2
jl less1
mgotoxy xfruitpos,yfruitpos
mwrite " "
test score,01
jz fruitb
jnz fruita

less1:
test score,01
jz coinb
jnz coina

kkl:
cmp lives,0
jle game_over_screen

cmp score,30
jge win_screen

dec ecx
jnz gameloop


moveUp:
; allow player to jump:

   ; jumpLoop:
   ; mov ecx,1
cmp levelno,1
je lvl1wallsu
cmp levelno,2
je lvl2wallsu
cmp levelno,3
je lvl3wallsu
mutu:
call UpdatePlayer

mov al, ypos
cmp al, 17
jl moveuu
cmp al, 33
je moveuuuu
dec ypos
jmp movenu


moveuu:
    mov al, ypos
    cmp al, 15
    jg moveuuu
    cmp al,15
    jl movetu

    dec ypos
    jmp movenu


movetu:
mov al,xpos
cmp al,56
jg movetuu

dec ypos
jmp movenu

movetuu:
mov al,xpos
cmp al,60
jl movenu
dec ypos
jmp movenu

moveuuu:
    mov al,xpos
    cmp al,33
    jl movenu
    cmp al,84
    jg movenu
    dec ypos
    jmp movenu

    movenu:
    call DrawPlayer
    jmp gameLoop


moveuuuu:
    mov al, ypos
    cmp al, 13
    jg moveuuuuu
    dec ypos
    jmp movenu

moveuuuuu:
    mov al, ypos
    cmp al, 16
    jl moveuuu
    dec ypos
    jmp moveuuu


moveDown:
cmp levelno,1
je lvl1wallsd
cmp levelno,2
je lvl2wallsd
cmp levelno,3
je lvl3wallsd
mutd:
call UpdatePlayer


mov al, ypos
cmp al, 14
jg movedd

mov al,xpos
cmp al, 33
jl movedddd
cmp al,84
jg movedddd
inc ypos
jmp movend


movedd:
    mov al, xpos
    cmp al, 56
    jg moveddd
    inc ypos
    jmp movend


moveddd:
    cmp al,60
    jl movend
    cmp al,84
    jg movedddd
    inc ypos
    jmp movend

    movend:
    call DrawPlayer
    jmp gameLoop


movedddd:
    mov al, ypos
    cmp al, 12
    jg moveddddd
    inc ypos
    jmp movend

moveddddd:
    mov al, ypos
    cmp al, 16
    jl movend
    inc ypos
    jmp movend
    
moveLeft:
cmp levelno,1
je lvl1wallsl
cmp levelno,2
je lvl2wallsl
cmp levelno,3
je lvl3wallsl
mutl:
call UpdatePlayer

mov al, xpos
cmp al, 60
je movell
cmp al, 33
je movellll
dec xpos
jmp movelll


movell:
    mov al, ypos
    cmp al, 15
    jg movelll
    cmp al, 14
    jl movelll
    dec xpos
    jmp movelll


movelll:
    call DrawPlayer
    jmp gameLoop


movellll:
    mov al, ypos
    cmp al, 13
    jg movelllll
    dec xpos
    jmp movelll

movelllll:
    mov al, ypos
    cmp al, 16
    jl movelll
    dec xpos
    jmp movelll





moveRight:
cmp levelno,1
je lvl1wallsr
cmp levelno,2
je lvl2wallsr
cmp levelno,3
je lvl3wallsr
mutr:
call UpdatePlayer
mov al, xpos
cmp al, 56
je moverr
cmp al, 84
je moverrrr
inc xpos
jmp moverrr


moverr:
    mov al, ypos
    cmp al, 15
    jg moverrr
    cmp al, 14
    jl moverrr
    inc xpos
    jmp moverrr


moverrr:
    call DrawPlayer
    jmp gameLoop


moverrrr:
    mov al, ypos
    cmp al, 13
    jg moverrrrr
    inc xpos
    jmp moverrr

moverrrrr:
    mov al, ypos
    cmp al, 16
    jl moverrr
    inc xpos
    jmp moverrr



    
jmp gameLoop
 exitGame:
exit

gameloopp endp

exitproc proc
exit
exitproc endp

dm_ghosts1 PROC
; Move ghosts forward if gob1 is 0
cmp gob1, 0
je forward

; Move ghosts backward if gob1 is 1
cmp gob1, 1
je backward

; If gob1 is neither 0 nor 1, return
ret

forward:
mov bl,0
mov bl,g1lx
; Check if ghosts are within the forward range
cmp g1x, bl
jae set_gob1_backward  ; If g1x >= g1lx, set gob1 to 1 (backward)

; Move ghosts forward
mgotoxy g1x, g1y
mwrite " "
inc g1x

mgotoxy g2x, g2y
mwrite " "
inc g2y

mgotoxy g3x, g3y
mwrite " "
inc g3y

; Here, before drawing the ghosts, we check for collision:
call check_collision

call drawlvl1and2ghosts


mov eax, 40
call delay
jmp check_gob1

set_gob1_backward:
mov gob1, 1
jmp backward

backward:
; Check if ghosts are within the backward range
mov bl,0
mov bl,g1ix
cmp g1x, bl
jb set_gob1_forward  ; If g1x < g1ix, set gob1 to 0 (forward)

; Move ghosts backward
mgotoxy g1x, g1y
mwrite " "
dec g1x

mgotoxy g2x, g2y
mwrite " "
dec g2y

mgotoxy g3x, g3y
mwrite " "
dec g3y

; Here, before drawing the ghosts, we check for collision:
call check_collision

call drawlvl1and2ghosts
mov eax, 40
call delay
jmp check_gob1

set_gob1_forward:
mov gob1, 0

check_gob1:
ret

check_collision:
; Check collision with ghost 1
mov al, xPos
cmp al, g1x
je collision
jmp no_collision_g1
collision:
; Check collision with ghost 1
mov al, yPos
cmp al, g1y
je decrement_score
jmp no_collision_g1

no_collision_g1:
; Check collision with ghost 2
mov al, xPos
cmp al, g2x
je collision_g2
jmp no_collision_g2
collision_g2:
mov al, yPos
cmp al, g2y
je decrement_score
jmp no_collision_g2

no_collision_g2:
; Check collision with ghost 3
mov al, xPos
cmp al, g3x
je collision_g3
jmp no_collision_g3
collision_g3:
mov al, yPos
cmp al, g3y
je decrement_score
jmp no_collision_g3

no_collision_g3:
ret

decrement_score:
 dec lives
 call updatelifedisplay
 invoke PlaySound, addr SoundFileName2, 0, SND_FILENAME3
 
cmp score, 0
jle no_decrement
dec score   


no_decrement:
ret


dm_ghosts1 ENDP



dm_ghosts2 proc
; Move ghosts forward if gob5 is 0


call drawlvl2map

cmp gob5,0
je forward

; Move ghosts backward if gob5 is 1
cmp gob5,1
je backward

; If gob5 is neither 0 nor 1, return
ret

forward:
mov bl,0
mov bl,g1lx
; Check if ghosts are within the forward range
cmp g1x, bl
jae set_gob5_backward  ; If g1x >= g1lx, set gob5 to 1 (backward)

; Move ghosts forward
mgotoxy g1x, g1y
mwrite "  "
add g1x,2   ;complexity in behavior by increase in speed

mgotoxy g2x, g2y
mwrite "  "
add g2y,1

mgotoxy g3x, g3y
mwrite "  "
add g3y,1

; Here, after drawing the ghosts, we check for collision:
call drawlvl1and2ghosts

call check_collision

mov eax, 35
call delay
jmp check_gob5

set_gob5_backward:
mov gob5, 1
jmp backward

backward:
; Check if ghosts are within the backward range
mov bl,0
mov bl,g1ix
cmp g1x, bl
jb set_gob5_forward  ; If g1x < g1ix, set gob1 to 0 (forward)

; Move ghosts backward
mgotoxy g1x, g1y
mwrite "  "
sub g1x,2

mgotoxy g2x, g2y
mwrite "  "
dec g2y

mgotoxy g3x, g3y
mwrite "  "
dec g3y

; Here, before drawing the ghosts, we check for collision:
call check_collision

call drawlvl1and2ghosts
mov eax, 40
call delay
jmp check_gob5

set_gob5_forward:
mov gob5, 0

check_gob5:
ret

check_collision:
; Check collision with ghost 1
mov al, xPos
cmp al, g1x
je collision
jmp no_collision_g1
collision:
; Check collision with ghost 1
mov al, yPos
cmp al, g1y
je decrement_score
jmp no_collision_g1

no_collision_g1:
; Check collision with ghost 2
mov al, xPos
cmp al, g2x
je collision_g2
jmp no_collision_g2
collision_g2:
mov al, yPos
cmp al, g2y
je decrement_score
jmp no_collision_g2

no_collision_g2:
; Check collision with ghost 3
mov al, xPos
cmp al, g3x
je collision_g3
jmp no_collision_g3
collision_g3:
mov al, yPos
cmp al, g3y
je decrement_score
jmp no_collision_g3

no_collision_g3:
ret

decrement_score:
 dec lives
 call updatelifedisplay
 invoke PlaySound, addr SoundFileName2, 0, SND_FILENAME3
 
cmp score, 0
jle no_decrement
dec score   

no_decrement:
ret

dm_ghosts2 endp

ghost12gone proc
push bx
mgotoxy g1x,g1y
mwrite " "

mgotoxy g2x,g2y
mwrite " "

mgotoxy g3x,g3y
mwrite " "

mov bh,g1ix
mov g1x,bh

mov bh,g2iy
mov g2y,bh

mov bh,g3iy
mov g3y,bh

pop bx

ghost12gone endp

drawlvl2map proc
mov wx,1
mov wy,7
mov no_blocks,5

call draw_hwall

mov wx,80
mov wy,23
mov no_blocks,5

call draw_hwall
ret

drawlvl2map endp

drawlvl3map proc
mov wx,1
mov wy,23
mov no_blocks,5

call draw_hwall

mov wx,80
mov wy,7
mov no_blocks,5

call draw_hwall
ret

ret
drawlvl3map endp
dm_ghosts3 PROC ;drawlvl1ghosts
    call drawlvl3ghosts
    call drawlvl3map

    cmp gobf,0
    jne kif

    call ghost12gone
    mov gobf,1
    kif:

  cmp gob6, 0
je forward

; Move ghosts backward if gob6 is 1
cmp gob6, 1
je backward

; If gob6 is neither 0 nor 1, return
ret

forward:
mov bl,0
mov bl,g1lx
; Check if ghosts are within the forward range
cmp g1x, bl
jae set_gob6_backward  ; If g1x >= g1lx, set gob6 to 1 (backward)

; Move ghosts forward
mgotoxy g1x, g1y
mwrite " "
add g1x,2  ;complex behavior is the varying speed

mgotoxy g2x, g2y
mwrite " "
inc g2y

mgotoxy g3x, g3y
mwrite " "
inc g3y

mgotoxy g4x, g4y
mwrite " "
inc g4x

mgotoxy g5x, g5y
mwrite " "
add g5x,2


; Here, before drawing the ghosts, we check for collision:
call check_collision

call drawlvl1and2ghosts
call drawlvl3ghosts


mov eax, 40
call delay
jmp check_gob6

set_gob6_backward:
mov gob6, 1
jmp backward

backward:
; Check if ghosts are within the backward range
mov bl,0
mov bl,g1ix
cmp g1x, bl
jb set_gob6_forward  ; If g1x < g1ix, set gob6 to 0 (forward)

; Move ghosts backward
mgotoxy g1x, g1y
mwrite " "
sub g1x,2

mgotoxy g2x, g2y
mwrite " "
dec g2y

mgotoxy g3x, g3y
mwrite " "
dec g3y

mgotoxy g4x, g4y
mwrite " "
dec g4x

mgotoxy g5x, g5y
mwrite " "
sub g5x,2

; Here, before drawing the ghosts, we check for collision:
call check_collision

call drawlvl1and2ghosts
call drawlvl3ghosts
mov eax, 40
call delay
jmp check_gob6

set_gob6_forward:
mov gob6, 0

check_gob6:
ret

check_collision:
; Check collision with ghost 1
mov al, xPos
cmp al, g1x
je collision
jmp no_collision_g1
collision:
; Check collision with ghost 1
mov al, yPos
cmp al, g1y
je decrement_score
jmp no_collision_g1

no_collision_g1:
; Check collision with ghost 2
mov al, xPos
cmp al, g2x
je collision_g2
jmp no_collision_g2
collision_g2:
mov al, yPos
cmp al, g2y
je decrement_score
jmp no_collision_g2

no_collision_g2:
; Check collision with ghost 3
mov al, xPos
cmp al, g3x
je collision_g3
jmp no_collision_g3
collision_g3:
mov al, yPos
cmp al, g3y
je decrement_score
jmp no_collision_g3

no_collision_g3:


mov al, xPos
cmp al, g4x
je collision_g4
jmp no_collision_g4
collision_g4:
mov al, yPos
cmp al, g4y
je decrement_score
jmp no_collision_g4

no_collision_g4:

mov al, xPos
cmp al, g5x
je collision_g5
jmp no_collision_g5
collision_g5:
mov al, yPos
cmp al, g5y
je decrement_score
jmp no_collision_g5

no_collision_g5:
ret

decrement_score:
 dec lives
 call updatelifedisplay
 invoke PlaySound, addr SoundFileName2, 0, SND_FILENAME3
 
cmp score, 0
jle no_decrement
dec score   


no_decrement:
ret
dm_ghosts3 ENDP



UpdatelifeDisplay PROC
cmp lives, 0
jle noLifeUpdate
mov eax, red 
call SetTextColor
mov dl, 75  
mov dh, 0   
call Gotoxy
mov edx,0
mov edx, OFFSET strlives
call WriteString

movzx ecx, lives
mov al, 3  
uloop:
call WriteChar 
loop uloop

noLifeUpdate:
ret
UpdatelifeDisplay ENDP

ConvertIntToStr PROC
  push ebx                 
  push ecx               
  push edx                 

  mov ecx, 10               
  mov ebx, 0                

convert_loop:
  xor edx, edx             
  div ecx                   
  add dl, '0'              
  dec edi                   
  mov [edi], dl            

  test eax, eax            
  jnz convert_loop          

  pop edx                   
  pop ecx                   
  pop ebx                   
  ret

ConvertIntToStr ENDP

main PROC
;Game Start
;-----------------------------------------------------------------------------------------
;Starting Screens

call Clrscr
mov eax,ytog
call SetTextColor
;GAME LOGO Screen

mGotoxy 30, 11
mWrite "#####      #       ####     #     #     #     ## ## ", 0ah
mGotoxy 30,12
mWrite "#   #     # #     ###       ##   ##    # #    ##### ", 0ah
mGotoxy 30, 13  
mWrite "#####    #####    ###       #######   #####   #  ## ", 0ah
mGotoxy 30, 14
mWrite "##      ##   ##    ####     #  #  #  ##   ##  #   # ", 0ah
;loading progress bar
INVOKE PlaySound, OFFSET SoundFileName0, NULL, SND_FILENAME2
mov pgx,30
mov pggy,17
mov delaytime,250
mov nohash,16
call progressbar_

;Game and Developer Name Screen
 call ClrScr
 mGotoxy 30, 9
 mWrite "Let's Play Pacman!!"
 mGotoxy 30, 10
 mWrite "Developed By Muhammad Wissam"
 mGotoxy 50, 20

 call waitmsg

 call clrscr
  push eax
  push edx
  push ecx 

;Name Input Screen
mGotoxy 30, 9
mWrite "Dear Player, Please Enter Your Name(11 characters max) : "
mov edx, OFFSET buffer
mov ecx, sofname
call ReadString 


INVOKE CreateFile,
	  ADDR filename, GENERIC_WRITE, DO_NOT_SHARE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov fileHandle,eax	
	INVOKE SetFilePointer,
	  fileHandle,0,0,FILE_END
	INVOKE WriteFile, fileHandle, ADDR buffer,sofname , ADDR bytesWritten, 0
	INVOKE CloseHandle, fileHandle



 push eax
 push edx
  push ecx 

  mov edx,offset buffer

mov eax,yellow
call setTextcolor

call clrscr
call clrscr

mGotoxy 2, 6
mWrite "--------------------------------------------------------MENU--------------------------------------------------------"
mGotoxy 2, 11
mWrite "Welcome to Pacman! "
mGotoxy 2, 12
mWrite "Choose an option by pressing one of the numbers on your keyboard : "
mGotoxy 2, 13
mWrite "1. Start Game"
mGotoxy 2, 14
mWrite "2. Show Scores "
mGotoxy 2, 15
mWrite "3. Show Instructions "
mGotoxy 2, 16
mWrite "4. Exit "
mGotoxy 2, 17
mWrite "Enjoy! :) "
mgotoxy 30,20
mov edx, OFFSET buffer 
mov ecx, BUFFER_SIZE
mgotoxy 30,20
call ReadChar ; read a character
mov inputChar,al
cmp al,'1'
je game_start_screen
cmp al,'2'
je show_scores
cmp al,'3'
je show_instructions
cmp al,'4'
je exitproc

call clrscr
call clrscr
call clrscr

game_start_screen:
;game screen

show_instructions:
call clrscr
call clrscr
mGotoxy 2, 2
mWrite "-----------------------------------------------------INSTRUCTIONS-----------------------------------------------------"
mGotoxy 2, 5
mWrite "1. use 'W' to move up, 'S' to move down, 'A' to move left, 'D' to move right. "
mGotoxy 2, 6
mWrite "2. During gameplay, press 'P' to pause the game and 'r' to re randomize coin's location' "
mGotoxy 2, 7
mWrite "3. Press 'X' to exit the game at any time"
mGotoxy 2, 8
mWrite "4. Eat the coins and you will gain points, and Avoid the ghosts else you will lose your lives!"
mGotoxy 2, 10
call waitmsg
call clrscr
call clrscr

show_scores:
call clrscr
call clrscr
mGotoxy 2, 2
mWrite "-------------------------------------------------------SCORES-------------------------------------------------------"
mGotoxy 2, 4
mWrite "Muhammad Wissam , Score is 30"
mGotoxy 2, 6
call waitmsg
 
call clrscr
call clrscr

boundary_draw:

;horizontal boundaries
call clrscr
call clrscr
mov eax,blue
call SetTextColor
mov dl,0
mov dh,29
call Gotoxy
mov edx,OFFSET ground
call WriteString
mov dl,0
mov dh,1
call Gotoxy
mov edx,OFFSET ground
call WriteString

;vertical boundaries
mov ecx,28
mov dh,2
mov temp,dh
ll2:
mov dh,temp
mov dl,119
call Gotoxy
mov edx,OFFSET ground2
call WriteString
inc temp
loop ll2
mov ecx,27
mov dh,2
mov temp,dh
ll1:
mov dh,temp
mov dl,0
call Gotoxy
mov edx,OFFSET ground2
call WriteString
inc temp
loop ll1

;LEVEL 1 MAZE  ; ROLL NUMBER IS 0709 
;so I will make 5555 patterned block becuase we can't make 0,7,9 blocks 
;and a space of 2 blocks between the walls spread out across the screen
;1 wall panel is equal to 2 | | characters vertically and 2 __ horizontally attached to fill the screen  

;first wall
mov wx,1
mov wy,15
mov no_blocks,5
call draw_hwall

;second wall
mov wx,57
mov wy,2
mov no_blocks,5
call draw_vwall

;third wall
mov wx,57
mov wy,16
mov no_blocks,5
call draw_vwall

;fourth wall
   
mov wx,85
mov wy,15
mov no_blocks,5
call draw_hwall

;gamefunc
;1.collision
;2. different collision for different levels
;3.coins on non walls
;4. ghosts



call CreateRandomCoina
call DrawCoin
cmp levelno,2
jge l23f
jl l1f
l23f:
call createrandomfruita
call drawfruit
l1f:
call Randomize
call gameLoopp

 
   
main ENDP

DrawPlayer PROC
; draw player at (xPos,yPos):
mov eax,yellow ;(blue*16)
call SetTextColor
mov dl,xPos
mov dh,yPos
call Gotoxy
mwrite "8"
ret
DrawPlayer ENDP

UpdatePlayer PROC
mov dl,xPos
mov dh,yPos
call Gotoxy
mov al," "
call WriteChar
ret
UpdatePlayer ENDP

drawlvl1and2ghosts PROC 
   
mov eax, yellow
call SetTextColor
mov dl,g1x
mov dh,g1y
call Gotoxy
mwrite "G"

mov dl,g2x
mov dh,g2y
call Gotoxy
mwrite "G"

mov dl,g3x
mov dh,g3y
call Gotoxy
mwrite "G"
ret
 
drawlvl1and2ghosts ENDP

Drawlvl3ghosts proc
mov dl,g4x
mov dh,g4y
call Gotoxy
mwrite "G"

mov dl,g5x
mov dh,g5y
call Gotoxy
mwrite "G"
ret 
Drawlvl3ghosts ENDP

Updatelvl1ghost1 PROC
mov dl,g1x
mov dh,g1y
mwrite " "
ret
Updatelvl1ghost1 ENDP

Updatelvl1ghost2 PROC
mov dl,g2x
mov dh,g2y
mwrite " "

ret
Updatelvl1ghost2 ENDP

Updatelvl1ghost3 PROC
mov dl,g3x
mov dh,g3y
mwrite " "
ret
Updatelvl1ghost3 ENDP

DrawCoin PROC
mov eax,yellow ;(red * 16)
call SetTextColor
mov dl,xCoinPos
mov dh,yCoinPos
call Gotoxy
mov al,"."
call WriteChar
ret
DrawCoin ENDP
Drawfruit PROC
mov eax,yellow ;(red * 16)
call SetTextColor
mov dl,xfruitPos
mov dh,yfruitPos
call Gotoxy
mov al,"F"
call WriteChar
ret
Drawfruit ENDP

CreateRandomCoina PROC
mov lower,37
mov upper,55
call betterrandomrange
mov xCoinPos,al

mov lower,5
mov upper,25
call betterrandomrange
mov yCoinPos,al
ret
CreateRandomCoina ENDP
CreateRandomCoinb PROC
mov lower,66
mov upper,79
call betterrandomrange
mov xCoinPos,al

mov lower,4
mov upper,25
call betterrandomrange
mov yCoinPos,al
ret
CreateRandomCoinb ENDP

CreateRandomfruita PROC
mov lower,55
mov upper,56
call betterrandomrange
mov xfruitPos,al

mov lower,16
mov upper,18
call betterrandomrange
mov yfruitPos,al
ret
CreateRandomfruita ENDP
CreateRandomfruitb PROC
mov lower,60
mov upper,61
call betterrandomrange
mov xfruitPos,al

mov lower,13
mov upper,14
call betterrandomrange
mov yfruitPos,al
ret
CreateRandomfruitb ENDP


END main

