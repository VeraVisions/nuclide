/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

CUIWidget g_uiDesktop; 

void VGUI_Init(void)
{
	g_uiDesktop = spawn( CUIWidget );
	g_uiDesktop.FlagAdd( 1 );
}

int VGUI_Draw(void)
{
	g_uiDesktop.Draw();
	return 1;
}

int VGUI_Input(float flEvType, float flScanX, float flCharY, float flDevID)
{
	g_uiDesktop.Input( flEvType, flScanX, flCharY, flDevID );
	return 1;
}
