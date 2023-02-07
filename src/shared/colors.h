/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/** Takes a normalized color vector and returns the hexadecimal equivalent
    for "funstrings". E.g. '1.0 0.0 0.0' becomes "^xF00". */
string
Colors_RGB8_to_HEX(vector color)
{
	return sprintf("^x%x%x%x", color[0] * 15, color[1] * 15, color[2] * 15);
}

/** Takes a 0-255 based color vector and returns the hexadecimal equivalent
    for "funstrings". E.g. '255 0 0' becomes "^xF00". */
string
Colors_RGB255_to_HEX(vector color)
{
	return Colors_RGB8_to_HEX(color / 255);
}
