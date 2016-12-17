/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include "VGUI.h"

// Menus with their window titles and draw functions
vguiwindow_t vguiMenus[11] = {
	{ "Message Of The Day", VGUI_MessageOfTheDay },
	{ "Team Selection", VGUI_TeamSelect_Main },
	{ "Terrorist Selection", VGUI_TeamSelect_T },
	{ "Counter-Terrorist Selection", VGUI_TeamSelect_CT },
	{ "Buy Menu", VGUI_BuyMenu_Main },
	{ "Handguns", VGUI_BuyMenu_Handguns },
	{ "Shotgun", VGUI_BuyMenu_Shotguns },
	{ "Sub-Machine-Guns", VGUI_BuyMenu_SMGs },
	{ "Rifles", VGUI_BuyMenu_Rifles },
	{ "Machineguns", VGUI_BuyMenu_Machineguns },
	{ "Equipment", VGUI_BuyMenu_Equipment }
};

/*
=================
CSQC_VGUI_Draw

This is the entry point for OpenCS own VGUI implementation
Run every frame
=================
*/
void CSQC_VGUI_Draw( void ) {
	if ( fVGUI_Display == VGUI_NONE ) {
		setcursormode( FALSE );
		return;
	}
	
	vVGUIColor = autocvar_vgui_color * ( 1 / 255 );

	setcursormode( TRUE );

	// Align the window to the center
	vVGUIWindowPos_x = ( vVideoResolution_x / 2 ) - 320;
	vVGUIWindowPos_y = ( vVideoResolution_y / 2 ) - 240;
	VGUI_Window( vguiMenus[ fVGUI_Display - 1 ].sTitle, vVGUIWindowPos, '640 480 0' );
	
	// Display the contents of whatever we have selected
	vguiMenus[ fVGUI_Display - 1 ].vDraw( vVGUIWindowPos );
}

/*
=================
CSQC_VGUI_Init

Initialize all there is
=================
*/
void CSQC_VGUI_Init( void ) {
	string sTemp;
	
	// First load the MESSAGE OF THE DAY
	// TODO: Move this to the server and put strings into infokeys
	filestream fmMOTD = fopen( "motd.txt", FILE_READ);
	for ( int i = 0; i < 25; i++ ) {
		sTemp = fgets( fmMOTD );
		if not ( sTemp ) {
			break;
		} 
		sMOTDString[ i ] = sTemp;
	}
	fclose( fmMOTD );
	
	// Now load the MAP DESCRIPTION
	fmMOTD = fopen( sprintf( "maps/%s.txt", mapname ), FILE_READ);
	for ( int i = 0; i < 35; i++ ) {
		sTemp = fgets( fmMOTD );
		if not ( sTemp ) {
			break;
		} 
		sMapString[ i ] = sTemp;
	}
	fclose( fmMOTD );
	
	// We start on the MOTD, always
	fVGUI_Display = VGUI_MOTD;
}
