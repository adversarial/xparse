// xparse

// Contains C callable functions that convert numbers to and from base 16 ascii format and
// raw numbers. 

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

//typedef enum { FALSE, TRUE } LOGICAL;
typedef void LOGICAL;

#ifdef __cplusplus
	extern "C" {
#endif

LOGICAL __stdcall _htoa(void* lpIn, char* szOut, unsigned int len);
LOGICAL __stdcall _atoh(char* szIn, void* lpOut, unsigned int len);

LOGICAL __stdcall _btoa(void* lpIn, char* szOut, unsigned int len);
LOGICAL __stdcall _atob(char* szIn, void* lpOut, unsigned int len);

#ifdef __cplusplus
	}
#endif