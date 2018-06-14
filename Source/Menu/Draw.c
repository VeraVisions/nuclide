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
	
	//drawstring( '16 16', , FONTSIZE, '1 1 1', 1.0f, 0 );
	Object_Label_Right( [ 640 - 16, 480 - 16 ], sprintf( "FreeCS Version: %s", __DATE__ ), FONTSIZE );
}
