/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

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

	if ( fVGUI_Display >= VGUI_RADIO1 ) {
		VGUI_Radio_Draw();
		return;
	}
	
	setcursormode( TRUE, "gfx/cursor", '0 0 0', 1.0f );

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
	if ( fmMOTD != -1 ) {
		for ( int i = 0; i < 35; i++ ) {
			sTemp = fgets( fmMOTD );
			if not ( sTemp ) {
				break;
			} 
			sMapString[ i ] = sTemp;
		}
		fclose( fmMOTD );
	}
	
	// We start on the MOTD, always
	fVGUI_Display = VGUI_MOTD;
}
