; base 2 conversion algorithms for xparse

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

; exports
public b2a as '__btoa@12'
public a2b as '__atob@12'

;======== Code =========================
section '.text' code readable executable
;=======================================

; typedef enum { false, true } LOGICAL;
;
; LOGICAL btoa(void* lpIn, char* szOut, uint32_t len);
;
; szOut must allocated for at least size 2*numbytes(lpIn)+1 for null termination
; ex dword = 9, word = 5, byte = 3
;
; translates bytes literally (big endianness)
b2a:
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
        push ebx ecx edx esi edi        ; pushad
  ; start main function
        mov esi, [.lpIn]
        mov edi, [.szOut]
        mov ecx, [.len]

  .loadloop:
        lodsb
        mov edx, eax
        xor ebx, ebx
        mov bl, $1
        push ecx
        mov ecx, $8                    ; sizeof(reg8)
  .bittestloop:
        xor edx, edx
        test eax, ebx                   ; check for and bit
        jz .doesntmatch
        mov dl, $1
     .doesntmatch:
        add dl, $30                     ; ascii '0'
        xchg eax, edx
        stosb                           ; output '0'/'1'
        xchg eax, edx
        shl ebx, $1
        loop .bittestloop
        pop ecx
        loop .loadloop

        xor eax, eax                    ; zero terminate
        stosb

  ; end main function
        pop edi esi edx ecx ebx; restore regs
        pop ebp
        ret 3*4

; typedef enum { false, true } LOGICAL;
;
; LOGICAL atob(char* szIn, void* lpOut, uint32_t strlen);
;
; lpOut must allocated for at least size len/8-1
; ex dword = 4, word = 2, byte = 1
;
; translates bytes literally (big endianness)
a2b:
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
        push ebx ecx edx esi edi        ; pushad
  ; start main function
        mov esi, [.szIn]
        mov edi, [.lpOut]
        mov ecx, [.len]

        cld
  .loadnextbyte:
        xor edx, edx
        push ecx
        cmp ecx, $8
        jbe .smallbyte
        mov ecx, $8
  .smallbyte:
  .getbyte:
        xor eax, eax
        xor ebx, ebx

        lodsb
        sub al, $30                     ; ascii '0'
        shl eax, cl                     ; offset
        shr eax, $1                     ; fix 0-index
        or edx, eax
        loop .getbyte
        xchg eax, edx
        stosb
        pop ecx
        cmp ecx, $8
        jbe .done
        sub ecx, $8
        jmp .loadnextbyte
  .done:

  ; end main function
        pop edi esi edx ecx ebx; restore regs
        pop ebp
        ret 3*4