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

#include <cstdio>
#include <cstdlib>
#include "shift_lfsr_cplusplus.h"
#include "config.h"

namespace {

template <typename T>
inline T min(T x, T y)
{
	return (x < y) ? x : y;
}

} // end of unnamed namespace

int main(int argc, char** const argv)
{
	enum { sizeof_T = 4 };
	typedef unsigned long T;
	typedef std::size_t S;

	const S buffer_size = 8 * 1024;
	const S initial_shuffle = 32;

	S size = 0;
	bool failed = false;

	if (argc <= 1) return 1;
	{
		char* p = 0; // set later
		const unsigned long result = std::strtoul(argv[1], &p, 0);
		if (p != argv[1]) size = static_cast<S>(result);
	}
	if (size == 0) return 0;

	unsigned char* const buf = new unsigned char[buffer_size * sizeof_T];
	if (!buf) return 1;

	{
		T v = static_cast<T>(1);
		S chunk_size = min(buffer_size, ((size + sizeof_T - 1) / sizeof_T));
		S filled = 0;
		for (S i = 0; i < initial_shuffle; ++i) v = lfsr::shift_lfsr(v);
		while (1) {
			v = lfsr::shift_lfsr(v);
#if (SIZEOF_LONG == 4)
			*(reinterpret_cast<T*>(&buf[filled * 4])) = v;
#else /* !(SIZEOF_LONG == 4) */
			buf[filled * 4 + 0] = static_cast<unsigned char>( v        & 0xff);
			buf[filled * 4 + 1] = static_cast<unsigned char>((v >>  8) & 0xff);
			buf[filled * 4 + 2] = static_cast<unsigned char>((v >> 16) & 0xff);
			buf[filled * 4 + 3] = static_cast<unsigned char>((v >> 24) & 0xff);
#endif /* !(SIZEOF_LONG == 4) */
			++filled;
			if (filled < chunk_size) continue;
			{
				const std::size_t n = min(filled * sizeof_T, size);
				const std::size_t result = std::fwrite(buf, 1, n, stdout);
				if (result < n) {
					failed = true;
					break;
				}
				size -= n;
			}
			if (size == 0) break;
			chunk_size = min(buffer_size, ((size + sizeof_T - 1) / sizeof_T));
			filled = 0;
		}
	}

	delete[] buf;

	return failed ? 1 : 0;
}
