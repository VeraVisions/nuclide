/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

#include "VGUI.h"

// Menus with their window titles and draw functions
vguiwindow_t vguiMenus[11] = {
	{ _("VGUI_TITLE_MOTD"), VGUI_MessageOfTheDay },
	{ _("VGUI_TITLE_TEAMS"), VGUI_TeamSelect_Main },
	{ _("VGUI_TITLE_TSEL"), VGUI_TeamSelect_T },
	{ _("VGUI_TITLE_CTSEL"), VGUI_TeamSelect_CT },
	{ _("VGUI_TITLE_BUY"), VGUI_BuyMenu_Main },
	{ _("VGUI_TITLE_HANDGUN"), VGUI_BuyMenu_Handguns },
	{ _("VGUI_TITLE_SHOTGUN"), VGUI_BuyMenu_Shotguns },
	{ _("VGUI_TITLE_SMG"), VGUI_BuyMenu_SMGs },
	{ _("VGUI_TITLE_RIFLE"), VGUI_BuyMenu_Rifles },
	{ _("VGUI_TITLE_MG"), VGUI_BuyMenu_Machineguns },
	{ _("VGUI_TITLE_EQUIPMENT"), VGUI_BuyMenu_Equipment }
};

/*
=================
CSQC_VGUI_Draw

This is the entry point for FreeCS own "VGUI" implementation
Run every frame
=================
*/
float CSQC_VGUI_Draw( void ) {
	if ( pSeat->fVGUI_Display == VGUI_NONE ) {
		setcursormode( FALSE );
		return FALSE;
	}
	
	vVGUIColor = autocvar_vgui_color * ( 1 / 255 );

	if ( pSeat->fVGUI_Display >= VGUI_RADIO1 ) {
		VGUI_Radio_Draw();
		return FALSE;
	}

	// Align the window to the center
	vVGUIWindowPos = vVideoMins;
	vVGUIWindowPos_x += ( vVideoResolution_x / 2 ) - 320;
	vVGUIWindowPos_y += ( vVideoResolution_y / 2 ) - 240;
	VGUI_Window( vguiMenus[ pSeat->fVGUI_Display - 1 ].sTitle, vVGUIWindowPos, '640 480 0' );
	
	iVGUIKey = 48;
	// Display the contents of whatever we have selected
	vguiMenus[ pSeat->fVGUI_Display - 1 ].vDraw( vVGUIWindowPos );
	
	return TRUE;
}

/*
=================
CSQC_VGUI_Init

Initialize all there is
=================
*/
void CSQC_VGUI_Init( void ) {
	string sTemp;
	int iMOTDLength;
	filestream fmMapDescr;
	
	// First load the MESSAGE OF THE DAY
	// TODO: Move this to the server and put strings into infokeys
	
	iMOTDLength = stof( serverkey( "motdlength" ) );
	for ( int i = 0; i < iMOTDLength; i++ ) {
		sMOTDString[ i ] = serverkey( sprintf( "motdline%i", i ) );
	}
	
	// Now load the MAP DESCRIPTION
	fmMapDescr = fopen( sprintf( "maps/%s.txt", mapname ), FILE_READ );
	if ( fmMapDescr != -1 ) {
		for ( int i = 0; i < 35; i++ ) {
			sTemp = fgets( fmMapDescr );
			if not ( sTemp ) {
				break;
			} 
			sMapString[ i ] = sTemp;
		}
		fclose( fmMapDescr );
	}
	
	if (serverkeyfloat("slots") == 1) {
		pSeat->fVGUI_Display = VGUI_NONE;
		return;
	}
	// We start on the MOTD, always
	for (int s = 0; s < seats.length; s++)
	{
		pSeat = &seats[s];
		pSeat->fVGUI_Display = VGUI_MOTD;
	}
}
