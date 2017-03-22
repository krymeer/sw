/*

This file is a sample program using lfsr-generator.
Copyright (C) 2007  Wakabayashi Masaki

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

*/

#include <stdio.h>
#include <stdlib.h>
#include "shift_lfsr_c.h"
#include "config.h"

static unsigned long min(const unsigned long x, const unsigned long y)
{
	return (x < y) ? x : y;
}

int main(int argc, char** const argv)
{
	enum { sizeof_T = 4 };
	typedef unsigned long T;
	typedef size_t S;

	const S buffer_size = 8 * 1024;
	const S initial_shuffle = 32;

	unsigned char* buf = 0; /* set later */
	S size = 0;
	int failed = 0;

	if (argc <= 1) return 1;
	{
		char* p = 0; /* set later */
		const unsigned long result = strtoul(argv[1], &p, 0);
		if (p != argv[1]) size = (S)(result);
	}
	if (size == 0) return 0;

	buf = (unsigned char*)(malloc(buffer_size * sizeof_T));
	if (!buf) return 1;

	{
		T v = (T)(1);
		S chunk_size = min(buffer_size, ((size + sizeof_T - 1) / sizeof_T));
		S filled = 0;
		{
			S i;
			for (i = 0; i < initial_shuffle; ++i) v = shift_lfsr(v);
		}
		while (1) {
			v = shift_lfsr(v);
#if (SIZEOF_LONG == 4)
			*((T*)(&buf[filled * 4])) = v;
#else /* !(SIZEOF_LONG == 4) */
			buf[filled * 4 + 0] = (unsigned char)( v        & 0xff);
			buf[filled * 4 + 1] = (unsigned char)((v >>  8) & 0xff);
			buf[filled * 4 + 2] = (unsigned char)((v >> 16) & 0xff);
			buf[filled * 4 + 3] = (unsigned char)((v >> 24) & 0xff);
#endif /* !(SIZEOF_LONG == 4) */
			++filled;
			if (filled < chunk_size) continue;
			{
				const size_t n = (size_t)(min(filled * sizeof_T, size));
				const size_t result = fwrite(buf, 1, n, stdout);
				if (result < n) {
					failed = 1;
					break;
				}
				size -= n;
			}
			if (size == 0) break;
			chunk_size = min(buffer_size, ((size + sizeof_T - 1) / sizeof_T));
			filled = 0;
		}
	}

	free(buf);

	return failed ? 1 : 0;
}
