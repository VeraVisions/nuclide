/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

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
