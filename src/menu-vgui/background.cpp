/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

#ifdef GAME_TW
	#define BACKGROUND_IMG "textures/gfx/background"
#elif GAME_CS
	#define BACKGROUND_IMG "textures/gfx/background"
#else
	#define BACKGROUND_IMG "gfx/conback"
#endif

var int g_iBackgroundLoaded = FALSE;

void Background_Init ( void )
{
	precache_pic( BACKGROUND_IMG );

	if ( iscachedpic( BACKGROUND_IMG ) ) {
		g_iBackgroundLoaded = TRUE;
	}
}

void Background_Draw ( vector vecSize )
{
	if ( clientstate() == 2 ) {
		drawfill( [ 0, 0 ], vecSize, [ 0, 0, 0 ], 0.5f );
	} else {
		if ( g_iBackgroundLoaded == TRUE ) {
			drawpic( [ 0, 0 ], BACKGROUND_IMG, vecSize, [ 1, 1, 1 ], 1.0f );
		} else {
			drawfill( [ 0, 0 ], vecSize, [ 0, 0, 0 ], 1.0f );
			drawfill( [ 0, 0 ], vecSize, UI_MAINCOLOR, 0.5f );
		}
	}
}
