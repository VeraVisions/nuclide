/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

string
Colors_RGB8_to_HEX(vector color)
{
	string out = "^x";

	for (int i = 0; i < 3; i++) {
		string a = "";
		float b = rint(color[i] * 15);

		switch (b) {
		case 10:
			a = "A";
			break;
		case 11:
			a = "B";
			break;
		case 12:
			a = "C";
			break;
		case 13:
			a = "D";
			break;
		case 14:
			a = "E";
			break;
		case 15:
			a = "F";
			break;
		default:
			a = ftos(b);
		}
		out = sprintf("%s%s", out, a);
	}
	return out;
}

string
Colors_RGB255_to_HEX(vector color)
{
	return Colors_RGB8_to_HEX(color / 255);
}