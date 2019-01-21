/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void CSQC_DrawText(vector pos, string txt, vector sz, vector col, float a, 
					float fl, float fnt)
{
	drawfont = fnt;
	drawstring(pos, txt, sz, col, a, fl);
}
