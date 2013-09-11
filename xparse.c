// xparse
//
// A c translation of xparse.asm. Untested, may or may not compile

/*
 * Copyright (c) 2013 x8esix
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

void atoh(unsigned char* szIn, unsigned char* lpOut, unsigned int strlen) {
	unsigned int ecx;

	for(; strlen; ++lpOut) {
		if(strlen <= 8)
			ecx = strlen;
		else ecx = 8;
		strlen -= ecx;
		for(; ecx; --ecx) {
			*lpOut |= (*szIn - 30) + (((*szIn - 30) < 0x0A) ? + 0 : - 7) << ecx;
		}
	}
}

void htoa(unsigned char* lpIn, unsigned char* szOut, unsigned int bytelen) {
	for(; bytelen; --bytelen) {
		*szOut++ = ((*lpIn & 0x0f) > 0x09) ? + 40 : + 30;
		*szOut++ = ((*lpIn & 0xf0) > 0x09) ? + 40 : + 30;
	}
	*szOut = '\0';
}

void atob(unsigned char* szIn, unsigned char* lpOut, unsigned int strlen) {
	unsigned int ecx;

	for(; strlen; ++lpOut) {
		if(strlen <= 8)
			ecx = strlen;
		else ecx = 8;
		strlen -= ecx;
		for(; ecx; --ecx) {
			*lpOut |= (*szIn++ - 30) << (ecx-1);
		}
	}
}

void btoa(unsigned char* lpIn, unsigned char* szOut, unsigned int bytelen) {
	for(; bytelen; --bytelen, ++lpIn) {
		int i;
		for(i = 8; i > 0; --i) {
			*szOut++ = ((*lpIn >> (i - 1)) & 1) + 30;
		}
	}
	*szOut = '\0';
}