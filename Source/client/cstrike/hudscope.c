/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
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
	vScopePos = ( video_res / 2 ) + '-128 -128';
	drawpic( vScopePos, "sprites/sniper_scope.spr_0.tga", '256 256', '1 1 1', 1.0f, DRAWFLAG_NORMAL );
	
	// Border scale to fit the screen
	fSBScale = video_res[1] / 480;
	fSBOffset = ( video_res[0] / 2 ) - ( ( 640 * fSBScale ) / 2 );
	
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
		drawfill( '0 0', [ fSBOffset, video_res[1] ], '0 0 0', 1.0f );
		drawfill( [ ( 640 * fSBScale ) + fSBOffset, 0 ], [ fSBOffset, video_res[1] ], '0 0 0', 1.0f );
	}
}
