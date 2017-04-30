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

int iMenuStage;
float fFadeAlpha;
int iButtonSelected;

void drawmenupic( vector vPosition, string sPic, vector vSize, vector vRGB, float fAlpha, float fDrawflag ) {
	vSize = vSize * fMenuScale;
	vPosition = vPosition * fMenuScale;
	drawpic( vPosition + [ iMenuPadding, 0, 0 ], sPic, vSize, vRGB, fAlpha, fDrawflag );
}

void drawmenustring( vector vPosition, string sText, vector vSize, vector vRGB, float fAlpha, float fDrawflag ) {
	vSize = vSize * fMenuScale;
	vPosition = vPosition * fMenuScale;
	drawstring( vPosition + [ iMenuPadding, 0, 0 ], sText, vSize, vRGB, fAlpha, fDrawflag );
}

void m_mainbutton( vector vPos, string sText, int iItem, void() vFunc) {
	static float fSelectionAlpha;
	
	if ( Menu_InputCheckMouse( vPos, '182 14' ) == TRUE ) {
		if ( iButtonSelected != iItem ) {
			iButtonSelected = iItem;
			fSelectionAlpha = 0.0f;
		}
	}

	if ( iButtonSelected == iItem ) {
		if ( fMouseClick == TRUE ) {
			drawmenustring( vPos, sText, '14 14', '1 0.5 0', fSelectionAlpha, 0 );
			vFunc();
			fMouseClick = FALSE;
		} else {
			drawmenustring( vPos, sText, '14 14', '1 1 1', 1 - fSelectionAlpha, 0 );
			drawmenustring( vPos, sText, '14 14', '0.3 0.3 1', fSelectionAlpha, 0 );
		}
	} else {
		drawmenustring( vPos, sText, '14 14', '1 1 1', fFadeAlpha, 0 );
	}
	
	if ( fSelectionAlpha < 1.0f ) {
		fSelectionAlpha += frametime;
		if ( fSelectionAlpha > 1.0f ) {
			fSelectionAlpha = 1.0f;
		}
	}
}

void m_button_findserver( void ) {
	
};

void m_button_createserver( void ) {
	localcmd( "map cs_office\n" );
};

void m_button_options( void ) {
	
};

void m_button_replays( void ) {
	
};

void m_button_quit( void ) {
	localcmd( "quit\n" );
};

void m_drawback( void ) {
	if ( clientstate() == 2 ) {
		drawfill( '0 0', vVideoSize, '0 0 0', 0.75f );
	} else {
		drawmenupic( '0 0 0', "gfx/menu/back1", '720 480', '1 1 1', 1.0f, 0 );
		drawpic( '0 0 0', "menu_static", vVideoSize, '1 1 1', 1.0f, 0 );
		drawmenupic( '0 0 0', "gfx/menu/back2", '720 480', '1 1 1', 1.0f, 0 );
	}
}

void m_draw( vector vScreenSize ) {
	if ( iMenuActive == FALSE ) {
		return;
	}
	
	// we have to create frametime ourselves because menuqc is primitive
	frametime = ( time - fLastTime );
	fLastTime = time;
	
	// only update the videostuff if it's actually worth it
	if ( vVideoSize != vScreenSize ) {
		fFadeAlpha = 0.0f;
		vVideoSize = vScreenSize;
		vVideoAspect = Menu_Util_GetAspect( vVideoSize );
		vMenuSize = Menu_Util_GetMenuSize( vVideoAspect );
		iMenuPadding = Menu_Util_GetMenuPadding();
		fMenuScale = vVideoSize_y / vMenuSize_y;
	}
	
	if ( clientstate() != 2 ) {
		drawfill( '0 0', vVideoSize, '0 0 0', 1.0f );
	}
	
	// for weird Android peeps
	if ( vVideoSize_x < vVideoSize_y ) {
		drawstring( '45 105', "FreeCS is designed for", '16 16', '1 1 1', 1.0f, 0 );
		drawstring( '45 125', "landscape mode. Please", '16 16', '1 1 1', 1.0f, 0 ); 
		drawstring( '45 145', "Switch the orientation.", '16 16', '1 1 1', 1.0f, 0 );
		return;
	}
	
	if ( time < 5 ) {
		iMenuStage = 0;
		drawmenustring( '45 45', "FreeCS (c) 2016, 2017", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 85', "Note that FreeCS is not affiliated", '16 16', '1 1 1', fFadeAlpha, 0 ); 
		drawmenustring( '45 105', "with Steam or Valve.", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 125', "The source code for this is released", '16 16', '1 1 1', fFadeAlpha, 0 ); 
		drawmenustring( '45 145', "under the GPL v2.", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 185', "FreeCS requires the content from:", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 205', "Counter-Strike 1.5", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 225', "Half-Life", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 265', "Please see visit:", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 285', "eukara.github.io/FreeCS", '16 16', '1 1 1', fFadeAlpha, 0 );
		drawmenustring( '45 325', "Developed by Marco Hladik", '16 16', '1 1 1', fFadeAlpha, 0 );
	} else if ( time < 8 ) {
		if ( iMenuStage == 0 ) {
			fFadeAlpha = 0.0f;
			iMenuStage = 1;
		}
		
		m_drawback();
		
		if ( fFadeAlpha < 1.0f ) {
			drawfill( '0 0', vScreenSize, '0 0 0', 1 - fFadeAlpha );
		}
	} else {
		if ( iMenuStage == 1 ) {
			fFadeAlpha = 0.0f;
			iMenuStage = 2;
		}
		
		m_drawback();
		drawmenupic( '25 145 0', "gfx/menu/freecs", '236 43', '1 1 1', fFadeAlpha, 0 );
		
		m_mainbutton( '430 300', "  FIND SERVER", 1, m_button_findserver );
		m_mainbutton( '430 324', "CREATE SERVER", 2, m_button_createserver );
		m_mainbutton( '430 348', "      OPTIONS", 3, m_button_options);
		m_mainbutton( '430 372', "      REPLAYS", 4, m_button_replays );
		m_mainbutton( '430 396', "         QUIT", 5, m_button_quit );
	}
	
	if ( fFadeAlpha < 1.0f ) {
		fFadeAlpha += frametime * 0.5;
		if ( fFadeAlpha > 1.0f ) {
			fFadeAlpha = 1.0f;
		}
	}
}
