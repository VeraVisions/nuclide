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

int g_iConsoleInitialized;

void UI_Console_Show ( void )
{
	static CUIWindow winConsole;
	static CUIButton btnSend;
	static void Console_Send ( void ) {
	}

	if ( !g_iConsoleInitialized ) {
		g_iConsoleInitialized = TRUE;
		winConsole = spawn( CUIWindow );
		winConsole.SetTitle( "Console" );
		winConsole.SetSize( '320 240' );

		btnSend = spawn( CUIButton );
		btnSend.SetTitle( "Send" );
		btnSend.SetSize( '48 24' );
		btnSend.SetPos( winConsole.GetSize() - '64 32' );
		btnSend.SetFunc( Console_Send );
		
		winConsole.Add( btnSend );
		g_uiDesktop.Add( winConsole );
	}

	winConsole.Show();
}
