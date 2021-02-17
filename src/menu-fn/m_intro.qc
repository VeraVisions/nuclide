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

enum
{
	INTRO_START,
	INTRO_FADETOWHITE,
	INTRO_FADETOMENU,
	INTRO_DONE
};

#define INTRO_TIME 8
float g_intro_progress;
int g_intro_stage;

void
m_intro_skip(void)
{
	g_intro_progress = INTRO_TIME;
	g_intro_stage = INTRO_DONE;
}

void
m_intro_draw(void)
{
	float alpha;
	if (clientstate() == 2) {
		g_intro_progress = INTRO_TIME;
		g_intro_stage = INTRO_DONE;
	}

	if (g_intro_progress > 7.0f) {
		alpha = (8 - g_intro_progress);
		drawfill([0,0], [g_vidsize[0],g_vidsize[1]], [1,1,1], alpha);
		
		if (g_intro_stage != INTRO_FADETOMENU) {
			g_intro_stage = INTRO_FADETOMENU;
		}
	} else if (g_intro_progress > 5.0f) {
		alpha = (6 - g_intro_progress);
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH8BIT],
				[640,480], [1,1,1], 1.0f, 0);
		drawfill([0,0], [g_vidsize[0],g_vidsize[1]], [1,1,1], 1.0 - alpha);
		
		if (g_intro_stage != INTRO_FADETOWHITE) {
			localcmd("play debris/beamstart5.wav\n");
			localcmd("menu_musicloop 3\n");
			g_intro_stage = INTRO_FADETOWHITE;
		}
	} else {
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH8BIT],
				[640,480], [1,1,1], 1.0f);
	}

	if (g_intro_progress < 2.0f) {
		drawfill([0,0], [g_vidsize[0],g_vidsize[1]], [0,0,0], 2-g_intro_progress);
	}

	g_intro_progress += frametime;
}

void
m_intro_input(float evtype, float scanx, float chary, float devid)
{
	if (evtype == IE_KEYDOWN) {
		if (scanx == K_ESCAPE) {
			m_intro_skip();
		} else if (scanx == K_ENTER) {
			m_intro_skip();
		} else if (scanx == K_SPACE) {
			m_intro_skip();
		}
	}
}
