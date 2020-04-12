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

void VGUI_MessageOfTheDay(void)
{
	static int initialized;
	static CUIWindow winMOTD;
	static CUIButton btnOK;

	if (!initialized) {
		initialized = TRUE;
		winMOTD = spawn(CUIWindow);
		winMOTD.SetTitle("Message Of The Day");
		winMOTD.SetSize('420 320');
		winMOTD.SetIcon("textures/ui/icons/cd");

		btnOK = spawn(CUIButton);
		btnOK.SetTitle("Play");
		btnOK.SetPos('8 132');
		//btnPlay.SetFunc(MusicPlayer_Play);

		g_uiDesktop.Add(winMOTD);
		winMOTD.Add(btnOK);
	}

	winMOTD.Show();
	winMOTD.SetPos((video_res / 2) - (winMOTD.GetSize() / 2));
}
