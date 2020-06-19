.intel_syntax noprefix

.text
.global _start

_start:
  lea rsi, hello
  lea rdx, lh
  call print

loop:
  call prints
read:
  lea rsi, input
  xor rdi, rdi    # STDIN
  mov [rsi], rdi
  mov rdx, 6
  xor rax, rax    # read
  syscall       # read(STDIN, input, 6)
  call print
  lea rsi, input
  xor r8, r8
  mov r8b, [rsi]
  cmp r8, 120       # 'x'
  je exit
magic:
  xor r9, r9
  xor r10, r10
  mov r9b, [rsi+2]
  mov r10b, [rsi+4]
  sub r8, 49
  sub r9, 49
  sub r10, 49
  mov rdi, 1
  push rcx
  mov rcx, r10
  shl rdi, cl
  pop rcx
  or rdi, 0x4000
  call stnr
magic2:
  xor r8, r8
  dec r8
m2x:
  inc r8
  cmp r8, 9
  je dat_out
  xor r9, r9
  dec r9
m2y:
  inc r9
  cmp r9, 9
  je m2x
  call ldnr
  test di, 0x4000
  je m2y
  call check
  jmp magic2

dat_out:
  xor rdi, rdi
  lea rsi, dat
  lea rdx, message
  mov r11, 3
dat_l1:
  mov rbx, 9
dat_l2:
  mov rcx, 3
dat_l3:
  mov di, [rsi]
  inc rsi
  inc rsi
  call countbits
  jne dat_d
  dec rsi
  dec rsi
  mov di, [rsi]
  or di, 0x8000
  mov [rsi], di
  inc rsi
  inc rsi
  mov rdi, r13
  jmp dat_st
dat_d:
  cmp rdi, 0
  mov rdi, 88
  je dat_st
  mov rdi, 95
dat_st:
  mov [rdx], dil
  inc rdx
  inc rdx
  dec ecx
  jne dat_l3
  inc rdx
  dec ebx
  jne dat_l2
  inc rdx
  dec r11
  jne dat_l1
  jmp loop

exit:
  xor rdi, rdi
return:
  mov rax, 60
  syscall


prints: # no args
  lea rsi, message
  lea rdx, len
print:
  mov rdi, 1  # STDOUT
  mov rax, 1  # write
  syscall
  ret


countbits:
  push rsi
  push rdx
  push rcx
  mov rsi, rdi
  xor rdi, rdi
  mov rdx, 9
  xor rcx, rcx
  mov r13, 49
c1:
  push rsi
  and rsi, 1
  pop rsi
  je c2
  inc rdi
  inc rcx
c2:
  cmp rcx, 0
  jne c3
  inc r13
c3:
  shr rsi
  dec rdx
  jne c1
  cmp rdi, 1
  pop rcx
  pop rdx
  pop rsi
  ret


stnr:
  push rsi
  push r8
  push r9
  lea rsi, dat
  shl r9
  add rsi, r9
  shl r9, 3
  add rsi, r9
  shl r8
  mov [rsi+r8], di
  pop r9
  pop r8
  pop rsi
  ret

ldnr:
  push rsi
  push r8
  push r9
  lea rsi, dat
  shl r9
  add rsi, r9
  shl r9, 3
  add rsi, r9
  shl r8
  xor rdi, rdi
  mov di, [rsi+r8]
  pop r9
  pop r8
  pop rsi
  ret

check:
  call ldnr
  xor di, 0x4000
  push di
  call countbits
  pop di
  jne chs
  call influence
  call heur
chs:
  call stnr
  ret


influence:
  push rdi
  push r11
  push r13
  push rax
  push r8
  push r9
  call ldnr
  xor r13, r13
  dec r13
ix:
  inc r13
  cmp r13, 9
  je ixf
  cmp r13, r8
  je ix
  push r8
  mov r8, r13
  call inr
  pop r8
  jmp ix
ixf:
  xor rax, rax
  dec eax
iy:
  inc eax
  cmp rax, 9
  je iyf
  cmp rax, r9
  je iy
  push r9
  mov r9, rax
  call inr
  pop r9
  jmp iy
iyf:
  xor r13, r13
  xor rax, rax
ibxc:
  cmp r8, 3
  jc ibyc
  add r13, 3
  sub r8, 3
  jmp ibxc
ibyc:
  cmp r9, 3
  jc ibcf
  add eax, 3
  sub r9, 3
  jmp ibyc
ibcf:
  xor r11, r11
  dec r11
ibl:
  inc r11
  cmp r11, 3
  je ibf
  mov r8, r13
  push rax
  add rax, r11
  mov r9, rax
  pop rax
  call inr
  inc r8
  call inr
  inc r8
  call inr
  jmp ibl
ibf:
  pop r9
  pop r8
  pop rax
  pop r13
  pop r11
  pop rdi
  ret


inr:
  push rdi
  push r13
  push rax
  mov rax, rdi
  call ldnr
  test di, 0x8000
  jne inrf
  mov r13, 511
  and rax, r13
  not rax
  and rdi, rax
  push rdi
  call countbits
  pop rdi
  jne inr1
  or di, 0xC000
inr1:
  or di, 0x4000
  call stnr
inrf:
  pop rax
  pop r13
  pop rdi
  ret


heur:
  push rdi  # r0
  push rsi  # r1
  push rdx  # r2
  push rcx  # r3
  push rbx  # r4
  push r11  # r5
  push r13  # r6
  push rax  # r7
  push r8
  push r9
  mov rsi, 0x8000
reheur:
  xor rdx, rdx
  dec edx
hal:
  inc edx
  cmp edx, 9
  je hf
  xor rcx, rcx
  inc ecx
  xchg rdx, rcx
  shl rdx, cl
  xchg rdx, rcx
  xor rax, rax
  dec eax
hjl1:
  inc eax
  cmp eax, 9
  je hrf
  xor r11, r11
  xor r13, r13
  dec r13
hil1:
  inc r13
  cmp r13, 9
  je hif1
  push r8
  push r9
  mov r8, r13
  mov r9, rax
  call ldnr
  pop r9
  pop r8
  mov rbx, rdi
  test rbx, rcx
  je hil1
  test rbx, rsi
  jne already_there_r
  inc r11
  mov r8, r13
  mov r9, rax
  jmp hil1
hif1:
  cmp r11, 1
  jne already_there_r
  mov rdi, rcx
  or rdi, rsi
  call stnr
  call influence
  jmp reheur
already_there_r:
  jmp hjl1

hrf:
  xor rax, rax
  dec eax
hjl2:
  inc eax
  cmp eax, 9
  je hcf
  xor r11, r11
  xor r13, r13
  dec r13
hil2:
  inc r13
  cmp r13, 9
  je hif2
  push r8
  push r9
  mov r8, rax
  mov r9, r13
  call ldnr
  pop r9
  pop r8
  mov rbx, rdi
  test rbx, rcx
  je hil2
  test rbx, rsi
  jne already_there_c
  inc r11
  mov r8, rax
  mov r9, r13
  jmp hil2
hif2:
  cmp r11, 1
  jne already_there_c
  mov rdi, rcx
  or rdi, rsi
  call stnr
  call influence
  jmp reheur
already_there_c:
  jmp hjl2
hcf:
  jmp hal
hf:
  pop r9
  pop r8
  pop rax
  pop r13
  pop r11
  pop rbx
  pop rcx
  pop rdx
  pop rsi
  pop rdi
  ret

# -----------------------------------


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
dat:	# bit31:finished,bit30:to check,bit 8-0:nr possible
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
	.byte 255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1,255,1
