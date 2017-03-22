/*

This file is part of the test suite of lfsr-generator.
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

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

unsigned int shift_lfsr(unsigned int);

static void print_binary_number(
	FILE* const fp, const unsigned int width, const unsigned int v)
{
	typedef unsigned int S;
	S i;
	for (i = 0; i != width; ++i) {
		fputc(((v >> (width - 1 - i)) & 1) == 0 ? '0' : '1', fp);
	}
}

int main(const int argc, char** argv)
{
	typedef unsigned int T;
	typedef unsigned int S;

	S display_width = sizeof(T) * CHAR_BIT;
	S state_width = sizeof(T) * CHAR_BIT;
	int verbose = 0;
	int failed = 0;

	(void)(argc); /* ignore warning */
	while (*++argv) {
		if (**argv != '-') continue;
		switch (*(*argv + 1)) {
		case 'v':
			verbose = 1;
			break;
		case 'd':
			{
				char* p;
				unsigned long result = strtoul(*argv + 2, &p, 0);
				if (p != *argv + 2) display_width = (S)(result);
			}
			break;
		case 's':
			{
				char* p;
				unsigned long result = strtoul(*argv + 2, &p, 0);
				if (p != *argv + 2) state_width = (S)(result);
			}
			break;
		case 'w':
			{
				char* p;
				unsigned long result = strtoul(*argv + 2, &p, 0);
				if (p != *argv + 2) {
					display_width = state_width = (S)(result);
				}
			}
			break;
		default:
			break;
		}
	}

	{
		const T init = (T)(1), zero = (T)(0);
		T v = init;
		S count = (S)(1);
		while (1) {
			if (verbose) {
				print_binary_number(stderr, display_width, v);
				fputc('\n', stderr);
			}
			v = shift_lfsr(v);
			{
				const T state = (v & ~(~zero << state_width));
				if (state == init) break;
				if (state == zero) { failed = 1; break; }
			}
			++count;
		}
		if (!failed) printf("period:%u\n", count);
	}

	return failed ? 1 : 0;
}
