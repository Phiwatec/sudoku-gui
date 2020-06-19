.text
.global _start

_start:
	ldr r1, =hello
	ldr r2, =lh
	bl print		@ print welcome message

loop:
	bl prints		@ print sudoku field
read:
	ldr r1, =input		@ input = //all zeros
	mov r0, #0
	str r0, [r1], #4
	str r0, [r1]
	ldr r1, =input		@ read(STDIN, *input, 8);
	mov r2, #6 @6 chars
	mov r7, #3 @read
	svc 0
	bl print		@ print input
	ldr r1, =input		@ r8 = input[0];
	ldrb r8, [r1], #2
	cmp r8, #120 @'x'	@ if(r8 == 'x')
	beq exit		@   exit();
magic:			@ store input
	ldrb r9, [r1], #2	@ r9  = input[2];
	ldrb r10, [r1]		@ r10 = input[4];
	sub r8, #49		@ r8 -= 0x31;	//ascii to int
	sub r9, #49		@ r9 -= 0x31;
	sub r10, #49		@ r10-= 0x31; ascii und eins weniger
	mov r0, #1		@ r0 = 1 << r10
	lsl r0, r10
  orr r0, #0x4000     @set bit 14 to check
	bl stnr
magic2: 		@ solve SUDOKU
	mvn r8, #0	@  for(i = 0;i<9;i++){
m2x:
	add r8, #1
	cmp r8, #9
	beq dat_out
	mvn r9, #0	@    for(j = 0;j<9;j++){
m2y:
	add r9, #1
	cmp r9, #9
	beq m2x
	bl ldnr		@      if(ldnr.toCheck){
	tst r0, #0x4000
	beq m2y
	bl check	@        check();
	b magic2	@        goto magic 2;
			@      }
			@    }
			@  }

dat_out:		@ daten in Text umwandeln
	ldr r1, =dat
	ldr r2, =message
	mov r5, #3		@3 Zeilen
dat_l1:
	mov r4, #9		@9 Blöcke, dann eins weiter
dat_l2:
	mov r3, #3		@3 Zeichen pro Block
dat_l3:
	ldrh r0, [r1], #2
	bl countbits		@convert...
	bne dat_d
	sub r1, #2
	ldrh r0, [r1]
	orr r0, #0x8000		@set bit 15 finished
	strh r0, [r1], #2
	mov r0, r6
	b dat_st
dat_d:
	cmp r0, #0
	mov r0, #88		@'X'
	beq dat_st
	mov r0, #95		@'_'
dat_st:
	strb r0, [r2], #2	@eins weiter und noch eins für leerzeichen
	subs r3, #1
	bne dat_l3
	add r2, #1		@Leerzeichen zw Blöcken
	subs r4, #1
	bne dat_l2
	add r2, #1		@zusätzlicher Umbruch
	subs r5, #1
	bne dat_l1
	b loop

exit:
	mov r0, #0
return:
	mov r7, #1
	svc 0


prints: @no args
  push {r11, lr}
	ldr r1, =message
	ldr r2, =len
	b p1
print:	@r1 str. addr, r2 len
  push {r11, lr}
p1:
  mov r0, #1
  mov r7, #4
  svc 0
  pop {r11, pc}


countbits:	@ r0 result in r0, eq flag falls eindeutig und char in r6
	push {r1, r2, r3, r11, lr}
	mov r1, r0
	mov r0, #0
	mov r2, #9
	mov r3, #0
	mov r6, #49
c1:
	push {r3}
	ands r3, r1, #1
	pop {r3}
	beq c2
	add r0, #1
	add r3, #1
c2:
	cmp r3, #0
	bne c3
	add r6, #1
c3:
	lsr r1, #1
	subs r2, #1
	bne c1
	cmp r0, #1	@set eq flag falls eindeutig
	pop {r1, r2, r3, r11, pc}


stnr:	@r0 dat, r8 x coord, r9 y coord
  push {r1, r8, r11, lr}
	ldr r1, =dat
  add r1, r9, LSL#1       @ dat[r9 * 18 + (r8)<<1] = r0;
  add r1, r9, LSL#4
  lsl r8, #1              @...
  strh r0, [r1, r8]       @x direction
  pop {r1, r8, r11, pc}

ldnr:	@r8 x coord, r9 y coord, r0: erg
	push {r1, r8, r11, lr}
  ldr r1, =dat
  add r1, r9, LSL#1       @ dat[r9 * 18 + (r8)<<1] = r0;
  add r1, r9, LSL#4
  lsl r8, #1              @...
  ldrh r0, [r1, r8]       @x direction
  pop {r1, r8, r11, pc}

check:
  push {r11, lr}
	bl ldnr
	eor r0, #0x4000		@clear bit 14 to check
	push {r0}
	bl countbits		@falls finished
	pop {r0}
	bne cs
	bl influence
	bl heur
cs:
	bl stnr
  pop {r11, pc}


influence:	@r8 x coord, r9 y coord
	push {r0, r5, r6, r7, r8, r9, r11, lr}
	@reg usage: r0: ldnr()/stnr(), r5: k, r6/7: i/j
	bl ldnr
	mvn r6, #0
ix:
	add r6, #1
	cmp r6, #9
	beq ixf
	cmp r6, r8
	beq ix
	push {r8}
	mov r8, r6
	bl inr
	pop {r8}
	b ix
ixf:
	mvn r7, #0
iy:
	add r7, #1
	cmp r7, #9
	beq iyf
	cmp r7, r9
	beq iy
	push {r9}
	mov r9, r7
	bl inr
	pop {r9}
	b iy
iyf:
	mov r6, #0
	mov r7, #0
ibxc:
	cmp r8, #3		@ carry flag is cleared on borrow
	blo ibyc
	add r6, #3
	sub r8, #3
	b ibxc
ibyc:
	cmp r9, #3
	blo ibcf
	add r7, #3
	sub r9, #3
	b ibyc
ibcf:
	mvn r5, #0
ibl:
	add r5, #1
	cmp r5, #3
	beq ibf
	mov r8, r6
	add r9, r7, r5
	bl inr
	add r8, #1
	bl inr
	add r8, #1
	bl inr
	b ibl
ibf:
	pop {r0, r5, r6, r7, r8, r9, r11, pc}


inr:	@r0: orignr, r8 x coord, r9 y coord
	push {r0, r6, r7, r11, lr}
	@reg usage: r7 orig nr, r6: 0x1ff
	mov r7, r0
  bl ldnr
	tst r0, #0x8000
	bne inrf
	mov r6, #511
  and r7, r6
  bic r0, r0, r7
	push {r0}
	bl countbits
	pop {r0}
	ite eq
	orreq r0, #0xC000	@this was the bug
	orrne r0, #0x4000	 @set bit 14 to check
  bl stnr
inrf:
	pop {r0, r6, r7, r11, pc}


heur:
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r11, lr}
	@reg usage: r0: stnr()/ldnr(), r1: 0x8000, r2: a, r3: amask, r4: t, r5: o, r6/7: i/j, r8/9: x, y
	mov r1, #0x8000
reheur:
	mvn r2, #0
hal:						@for every number
	add	r2, #1
	cmp	r2, #9
	beq hf
	mov r3, #1
	lsl r3, r2	@amask = 1<<a;
	mvn r7, #0
hjl1:						@for every row
	add r7, #1
	cmp r7, #9
	beq hrf
	mov r5, #0	@o = 0;
	mvn r6, #0
hil1:
	add r6, #1
	cmp r6, #9
	beq hif1
	push {r8, r9}
	mov r8, r6
	mov r9, r7
	bl ldnr
	pop {r8 ,r9}
	mov r4, r0	@t = ldnr(j, i);
	tst r4, r3	@if(t & amask)
	beq hil1
	tst r4, r1	@if(t & 0x8000)
	bne already_there_r		@goto already_there_r
	add r5, #1	@o++;
	mov r8, r6	@ x = j;
	mov r9, r7	@ y = i;
	b hil1
hif1:
	cmp r5, #1	@if(o == 1)
	bne already_there_r
	mov r0, r3
	orr r0, r1
	bl stnr
	bl influence
	b reheur
already_there_r:
	b hjl1

hrf:
	mvn r7, #0
hjl2:						@for every column
	add r7, #1
	cmp r7, #9
	beq hcf
	mov r5, #0	@o = 0;
	mvn r6, #0
hil2:
	add r6, #1
	cmp r6, #9
	beq hif2
	push {r8, r9}
	mov r8, r7
	mov r9, r6
	bl ldnr
	pop {r8, r9}
	mov r4, r0	@t = ldnr(j, i);
	tst r4, r3	@if(t & amask)
	beq hil2
	tst r4, r1	@if(t & 0x8000)
	bne already_there_c		@goto already_there_r
	add r5, #1	@o++;
	mov r8, r7	@ x = j;
	mov r9, r6	@ y = i;
	b hil2
hif2:
	cmp r5, #1	@if(o == 1)
	bne already_there_c
	mov r0, r3
	orr r0, r1
	bl stnr
	bl influence
	b reheur
already_there_c:
	b hjl2
hcf:
	b hal
hf:
	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r11, pc}


@-----------------------------------

.data

message:
	.ascii "_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n"
	.ascii "_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n"
	.asciz "_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n"
 len = .-message

hello:
	.ascii "SUDOKU-solver by gedobbles   \n"
	.ascii "Format: x y n where x,y are coordinates (1-9) and n is the number.\n"
	.asciz "Enter x to exit.\n\n"
lh = .-hello

input:
	.byte 1,2,3,4,5,6,7,8,0
dat:	@ bit31:finished,bit30:to check,bit 8-0:nr possible
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
