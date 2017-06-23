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


/*
=================
m_drawback

Responsible for the fancy menu background
=================
*/
void m_drawback( void ) {
	drawfill( '0 0', vVideoSize, '0 0 0', 0.75f );
	drawpic( vMenuOffset, "gfx/shell/splash", '640 480', '1 1 1', 1.0f, 0 );
}

/*
=================
m_draw

Run every frame, main loop for the menu
=================
*/
void m_draw( vector vScreenSize ) {
	if ( iMenuActive == FALSE ) {
		return;
	}
	
	if ( vVideoSize != vScreenSize ) {
		vVideoSize = vScreenSize;
		vMenuOffset_x = vVideoSize_x / 2 - 320;
		vMenuOffset_y = vVideoSize_y / 2 - 240;
		Menu_ResetClipArea();
	}
	
	// we have to create frametime ourselves because menuqc is primitive
	frametime = ( time - fLastTime );
	fLastTime = time;
	
	if ( clientstate() != 2 ) {
		drawfill( '0 0', vVideoSize, '0 0 0', 1.0f );
	}

	m_drawback();
	fcsMain[ iMenu ].vMenu();
	Header_Draw();
}
