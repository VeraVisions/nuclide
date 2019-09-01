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

#define INTRO_TIME 6
float g_intro_progress;

void m_intro_draw(void)
{
	
	if (clientstate() == 2) {
		g_intro_progress = INTRO_TIME;
	}

	if (g_intro_progress > 5.0f) {
		float alpha = (6 - g_intro_progress);
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH8BIT],
				[640,480], [1,1,1], alpha, 0);
	} else {
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH8BIT],
				[640,480], [1,1,1], 1.0f);
	}

	if (g_intro_progress < 2.0f) {
		drawfill([0,0], [g_vidsize[0],g_vidsize[1]], [0,0,0], 2-g_intro_progress);
	}

	g_intro_progress += frametime;
}


void m_intro_input(float evtype, float scanx, float chary, float devid)
{	
	if (evtype == IE_KEYDOWN) {
		if (scanx == K_ESCAPE) {
			g_intro_progress = INTRO_TIME;
		} else if (scanx == K_ENTER) {
			g_intro_progress = INTRO_TIME;
		}
	}
}
