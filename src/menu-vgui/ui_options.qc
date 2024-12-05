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

#warning Options menu: Complete me.

int g_iOptionsInitialized;

void UI_Options_Show ( void )
{
	static vguiWindow winCreate;
	static vguiTabView tvOptions;
	static vguiTabViewItem btnTabMultiplayer;
	static vguiTabViewItem btnTabKeyboard;
	static vguiTabViewItem btnTabMouse;
	static vguiTabViewItem btnTabAudio;
	static vguiTabViewItem btnTabVideo;
	static vguiTabViewItem btnTabVoice;
	static vguiTabViewItem btnTabLock;
	static vguiButton btnOK;
	static vguiButton btnCancel;
	static vguiButton btnApply;

	if ( !g_iOptionsInitialized ) {
		vector shiftPos = [4,31];
		g_iOptionsInitialized = TRUE;
		winCreate = spawn( vguiWindow );
		winCreate.SetTitle( "Options (NOT IMPLEMENTED)" );
		winCreate.SetSize( '512 406' );
		winCreate.SetIcon( "gfx/icon16/cog" );

		tvOptions = spawn(vguiTabView);
		tvOptions.SetPos([5,31]);
		tvOptions.SetSize([502,338]);

		btnTabMultiplayer = spawn( vguiTabViewItem );
		btnTabMultiplayer.SetTitle("Multiplayer");
		btnTabKeyboard = spawn( vguiTabViewItem );
		btnTabKeyboard.SetTitle("Keyboard");
		btnTabMouse = spawn( vguiTabViewItem );
		btnTabMouse.SetTitle("Mouse");
		btnTabAudio = spawn( vguiTabViewItem );
		btnTabAudio.SetTitle("Audio");
		btnTabVideo = spawn( vguiTabViewItem );
		btnTabVideo.SetTitle("Video");
		btnTabVoice = spawn( vguiTabViewItem );
		btnTabVoice.SetTitle("Voice");
		btnTabLock = spawn( vguiTabViewItem );
		btnTabLock.SetTitle("Lock");

		tvOptions.AddItem(btnTabMultiplayer);
		tvOptions.AddItem(btnTabKeyboard);
		tvOptions.AddItem(btnTabMouse);
		tvOptions.AddItem(btnTabAudio);
		tvOptions.AddItem(btnTabVideo);
		tvOptions.AddItem(btnTabVoice);
		tvOptions.AddItem(btnTabLock);


		btnOK = spawn(vguiButton);
		btnOK.SetTitle("OK");
		btnOK.SetPos([267,373]);
		btnOK.SetSize([72,24]);
		btnCancel = spawn(vguiButton);
		btnCancel.SetTitle("Cancel");
		btnCancel.SetPos([347,373]);
		btnCancel.SetSize([72,24]);
		btnApply = spawn(vguiButton);
		btnApply.SetTitle("Apply");
		btnApply.SetPos([427,373]);
		btnApply.SetSize([72,24]);

		g_uiDesktop.Add( winCreate );
		winCreate.Add(tvOptions);
		winCreate.Add(btnOK);
		winCreate.Add(btnCancel);
		winCreate.Add(btnApply);
	}

	winCreate.Show();
	winCreate.SetPos( ( g_vidsize / 2 ) - ( winCreate.GetSize() / 2 ) );
}
