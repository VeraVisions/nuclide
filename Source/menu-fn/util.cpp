/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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

float lerp( float fA, float fB, float fPercent ) {
	return ( fA * ( 1 - fPercent ) ) + ( fB * fPercent );
}
