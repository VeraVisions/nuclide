/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

int Util_CheckMouse(int x, int y, int sx, int sy) {
	int mins[2];
	int maxs[2];

	x += g_menuofs[0];
	y += g_menuofs[1];

	mins[0] = x;
	mins[1] = y;
	maxs[0] = x + sx;
	maxs[1] = y + sy;

	if (g_mousepos[0] >= mins[0] && g_mousepos[0] <= maxs[0]) {
		if (g_mousepos[1] >= mins[1] && g_mousepos[1] <= maxs[1]) {
			return TRUE;
		}
	}

	return FALSE;
}

string Util_CmdToKey(string cmd)
{
	float fBindKey = tokenize( findkeysforcommand( cmd ) );
	string sBindTx = "";
	float j, k;
	
	for( j = 0; j < fBindKey; ++j ) {
		k = stof( argv( j ) );
		if( k != -1 ) {
			if( sBindTx != "" ) {
				sBindTx = strcat( sBindTx, ", " );
			}
			sBindTx = strcat( sBindTx, keynumtostring( k ) );
		}
	}

	return sBindTx;
}

float lerp( float fA, float fB, float fPercent ) {
	return ( fA * ( 1 - fPercent ) ) + ( fB * fPercent );
}
