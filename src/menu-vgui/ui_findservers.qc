/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

int g_iFindServersInitialized;

void UI_FindServers_Show ( void )
{
	static CUIWindow winFind;

	if ( !g_iFindServersInitialized ) {
		g_iFindServersInitialized = TRUE;
		winFind = spawn( CUIWindow );
		winFind.SetTitle( "Find Servers" );
		winFind.SetSize( '600 400' );
		winFind.SetIcon( "gfx/icon16/world" );

		g_uiDesktop.Add( winFind );
	}

	winFind.Show();
	winFind.SetPos( ( g_vidsize / 2 ) - ( winFind.GetSize() / 2 ) );
}
