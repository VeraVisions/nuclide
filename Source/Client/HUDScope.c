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

float fSBOffset;
float fSBScale;

/*
=================
HUD_DrawScope_Pic

The scope borders are split up into multiple parts.
We want to fill the screen, so we gotta do some hacking.
=================
*/
void HUD_DrawScope_Pic( vector vPos, vector vSize, string sSprite ) {
	drawpic( ( vPos * fSBScale ) + [ fSBOffset, 0 ], sSprite, vSize * fSBScale, '1 1 1', 1.0f );
}

/*
=================
HUD_DrawScope

Tries to draw a scope whenever viewzoom < 1.0f
=================
*/
void HUD_DrawScope( void ) {
	static vector vScopePos;
	
	// Draw the scope in the middle, seperately from the border
	vScopePos = ( vVideoResolution / 2 ) + '-128 -128';
	drawpic( vScopePos, "sprites/sniper_scope.spr_0.tga", '256 256', '1 1 1', 1.0f, DRAWFLAG_NORMAL );
	
	// Border scale to fit the screen
	fSBScale = vVideoResolution_y / 480;
	fSBOffset = ( vVideoResolution_x / 2 ) - ( ( 640 * fSBScale ) / 2 );
	
	// Type 1 Border... more coming soon?
	HUD_DrawScope_Pic( '0 0', '192 112', "sprites/top_left.spr_0.tga" );
	HUD_DrawScope_Pic( '192 0', '256 112', "sprites/top.spr_0.tga" );
	HUD_DrawScope_Pic( '448 0', '192 112', "sprites/top_right.spr_0.tga" );
	HUD_DrawScope_Pic( '0 112', '192 256', "sprites/left.spr_0.tga" );
	HUD_DrawScope_Pic( '448 112', '192 256', "sprites/right.spr_0.tga" );
	HUD_DrawScope_Pic( '0 368', '192 112', "sprites/bottom_left.spr_0.tga" );
	HUD_DrawScope_Pic( '192 368', '256 112', "sprites/bottom.spr_0.tga" );
	HUD_DrawScope_Pic( '448 368', '192 112', "sprites/bottom_right.spr_0.tga" );
	
	// Rect borders left and right
	if ( fSBOffset > 0 ) {
		drawfill( '0 0', [ fSBOffset, vVideoResolution_y ], '0 0 0', 1.0f );
		drawfill( [ ( 640 * fSBScale ) + fSBOffset, 0 ], [ fSBOffset, vVideoResolution_y ], '0 0 0', 1.0f );
	}
}
