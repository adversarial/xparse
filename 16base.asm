; base 16 conversion algorithms for xparse

; Copyright (c) 2013 x8esix

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.

format MS COFF

include '%lib%\win32a.inc'

public h2x as '__htoa@12'
public x2h as '__atoh@12'

;======== Code =========================
section '.text' code readable executable
;=======================================

; lowercase to uppercase
;
; extern stdcall void l2u(char* szStr, uint32_t strlen);
l2u:
  ; rest of c callable stuff
        push eax ecx edx esi edi
  ; variables
  virtual at esp+18
    .szStr   dd ?
    .len     dd ?
  end virtual
  ; start main function
        mov ecx, [.len]
        mov esi, [.szStr]
        mov edi, esi

        cld

  .toupper:
        lodsb
        xor edx, edx
        test al, $20
        jnz .catch
        mov edx, $20
  .catch:
        xor al, dl
        stosb
        loop .toupper

  ; end main function
        pop edi esi edx ecx eax
        ret 2*4

; uppercase to lowercase
;
; extern stdcall void u2l(char* szStr, uint32_t len);
u2l:
  ; variables
  virtual at esp+$18
    .szStr   dd ?
    .len     dd ?
  end virtual
  ; rest of c callable stuff
        push eax ecx edx esi edi
  ; start main function
        mov ecx, [.len]
        mov esi, [.szStr]
        mov edi, esi

        cld

  .toupper:
        lodsb
        xor edx, edx
        test al, $20
        jnz .catch
        mov edx, $32
  .catch:
        xor al, dl
        stosb
        loop .toupper



  ; end main function
        pop edi esi edx ecx eax
        ret 2*4

; typedef enum { false, true } LOGICAL;
;
; 153 bytes unoptimized
;
; extern stdcall LOGICAL _h2x(void* lpIn, char* szOut, uint32_t len);
;
; szOut must allocated for at least size 2*numbytes(lpIn)+1 for null termination
; ex dword = 9, word = 5, byte = 3
;
; translates bytes literally (big endianness)
h2x:
  ; set up stack frame for stdcallable
        push ebp
        mov ebp, esp
  ; variables
  virtual at ebp+8
    .lpIn    dd  ?
    .szOut   dd  ?
    .len     dd  ?
  end virtual
  ; rest of c callable stuff
        push ebx ecx edx esi edi        ; push all for my own purposes... fts
  ; start main function
        mov eax, [.len]
        mov esi, [.lpIn]        
        mov edi, [.szOut]

        cld

  ; for(split into dword segments ecx)){}
  ; used: eax edi esi
  ; volatile: ebx ecx edx
  .nextdword:
        xor edx, edx
        push $4                         ; sizeof(reg32)
        pop ebx
        mov ecx, eax                    ; ecx = total number of outbytes left
        div ebx                         ; number of reg32 left in eax, % in edx
        test eax, eax                   ; check if down to % bytes left
        jz .lastlap
        cmp eax, $1
        ja ..nothappening               ; if we have 4 bytes left
        test edx, edx                   ; % will be 0
        jz .lastlap
  ..nothappening:
        mov eax, ecx                    ; else restore the number of bytes left
        sub eax, $4                     ; after subtracting sizeof(reg32)
        mov ecx, $8                     ; and moving sizeof(reg32) into ecx
        jmp .letsgo
        
  .lastlap:
        shl edx, 1
        mov ecx, $8
        test edx, edx                   ; edx = eax % 4
        cmovnz ecx, edx                 ; else ecx = eax % 4
        xor eax, eax                    ; signal we're on our last lap
        
  ; transformation prep
  ; ecx = number of bytes
  ; esi = &in
  ; edi = &out
  .letsgo:
        mov edx, dword [esi]
        xchg dl, dh
        rol edx, 16
        xchg dl, dh
        push eax                        ; we want you!
  ; transformation
  ; edx = byte to transform
  ; eax = volatile
  ; ecx = number of bytes to transform
  .nextbyte:
        rol edx, 4             ; next nibble, eax = $xxyyzzww
        mov al, $0f            ; mask first nibble of al       ; $ww
        and al, dl             ; copy first nibble from lpIn   ; $0w
        or al, $90             ; add high bit to each nibble   ; $0w
        daa                    ; exploit high-bit dcb to remove hex from dcb
        adc al, $40            ; $41 == 'A'
        daa                    ; wrap hex dcb for numerals
        stosb                  ; store in buffer
        loopnz .nextbyte
  ; advance pointers 'n shit
  .advance:
        pop eax
        test eax, eax
        jz .weredone
        add esi, $4            ; note: edi is already moved forward 8 from stos
        jmp .nextdword
  ; if we've completed the buffer
  .weredone:
        stosb                  ; eax should be 0
        add eax, 1

  ; end main function
        pop edi esi edx ecx ebx; restore regs
        pop ebp
        ret 3*4

; typedef enum { false, true } LOGICAL;
;
; extern stdcall LOGICAL _x2h(void* szIn, void* lpOut, uint32_t len);
;
; 89 bytes unoptimized
;
; lpOut must allocated for at least size numbytes/2
; ex strlen(lpIn / 2)
;
; translates bytes literally (big endianness)
x2h:
  ; set up stack frame for stdcallable
        push ebp
        mov ebp, esp
  ; variables
  virtual at ebp+8
    .szIn    dd  ?
    .lpOut   dd  ?
    .len     dd  ?
  end virtual
  ; rest of c callable stuff
        push ebx ecx edx esi edi        ; push all for my own purposes... fts
  ; start main function
        mov ecx, [.len]
        mov esi, [.szIn]
        mov edi, [.lpOut]

        push edi
        push eax
        call l2u

        shr ecx, 1                      ; number of bytes = ascii bytes / 2 (derp)

        push $7
        pop ebx

        cld

  .nextbyte:
        lodsw
  ; eax = volatile (al is result)
  ; edx = volatile
  ; ebx = 7 (ascii letters to numbers difference)
  ; start with xX
        xor edx, edx
        sub al, $30                     ; ascii '0'
        cmp al, $a
        cmova edx, ebx                  ; if not a number
        sub al, dl                      ; subtract 7 to make a literal number
  ; next nibble
        xor edx, edx
        sub ah, $30
        cmp ah, $a
        cmova edx, ebx
        sub ah, dl
  ; merge
        shl al, $4
        or al, ah
  ; store
        stosb
        loop .nextbyte

  ; end main function
        pop edi esi edx ecx ebx         ; restore regs
        pop ebp
        ret 3*4