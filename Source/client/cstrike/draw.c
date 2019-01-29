/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
CSQC_UpdateView

Entry point for drawing on the client
=================
*/
void Cstrike_PreDraw(void)
{

	Nightvision_PreDraw();
}

void Cstrike_PostDraw(int x, int y, int w, int h)
{
	Nightvision_PostDraw(x, y, w, h);
}
