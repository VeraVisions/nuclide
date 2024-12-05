/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#define BACKGROUND_IMG "gfx/background"

typedef enum
{
	BACK_AUTO = 0,
	BACK_MATERIAL,
	BACK_VGUI1,
	BACK_WON
} bgMode_t;

var bgMode_t g_bgMode;
var float autocvar_menu_forceBGMode = 0;

typedef struct
{
	string strMat;
	vector vecSize;
	vector vecPos;
} backResource_t;

backResource_t g_back800[] =
{
	{"resource/background/800_1_a_loading",[256,256,0],[0,0,0]},
	{"resource/background/800_1_b_loading",[256,256,0],[256,0,0]},
	{"resource/background/800_1_c_loading",[256,256,0],[512,0,0]},
	{"resource/background/800_1_d_loading",[32,256,0],[768,0,0]},
	{"resource/background/800_2_a_loading",[256,256,0],[0,256,0]},
	{"resource/background/800_2_b_loading",[256,256,0],[256,256,0]},
	{"resource/background/800_2_c_loading",[256,256,0],[512,256,0]},
	{"resource/background/800_2_d_loading",[32,256,0],[768,256,0]},
	{"resource/background/800_3_a_loading",[256,88,0],[0,512,0]},
	{"resource/background/800_3_b_loading",[256,88,0],[256,512,0]},
	{"resource/background/800_3_c_loading",[256,88,0],[512,512,0]},
	{"resource/background/800_3_d_loading",[32,88,0],[768,512,0]}
};

void
Background_RendererRestarted(void)
{
	if (Platform_FileInCurrentGamedir("resource/background/800_1_a_loading.tga")) {
		g_bgMode = BACK_VGUI1;
	} else if (Platform_FileInCurrentGamedir("gfx/shell/splash.bmp")) {
		g_bgMode = BACK_WON;
	} else {
		g_bgMode = BACK_MATERIAL;
	}

	/* issue `vid_reload` after changing this cvar */
	if (autocvar_menu_forceBGMode) {
		g_bgMode = autocvar_menu_forceBGMode;
	}

	if (g_bgMode == BACK_VGUI1) {
		for (int i = 0; i < g_back800.length; i++) {
			precache_pic(g_back800[i].strMat);
		}
	} else if (g_bgMode == BACK_WON)  {
		precache_pic("gfx/shell/splash.bmp");
	} else if (g_bgMode == BACK_MATERIAL) {
		precache_pic(BACKGROUND_IMG);
	}
}

void
drawpic_flip(vector pos, string mat, vector size, vector color, float alpha)
{
	drawsubpic(pos, size, mat, [1,0], [-1,1], color, alpha, 0);
}

void
Background_WON(vector vecPos, vector vecSize)
{
	drawpic(vecPos, "gfx/shell/splash.bmp", vecSize, [1,1,1], 1.0f);
	/*drawpic_flip(vecPos + [vecSize[0], 0], "gfx/shell/splash.bmp", vecSize, [1,1,1] * 0.5f, 1.0f);
	drawpic_flip(vecPos - [vecSize[0], 0], "gfx/shell/splash.bmp", vecSize, [1,1,1] * 0.5f, 1.0f);*/
}

void
Background_Steam(vector vecPos, vector vecSize)
{
	for (int i = 0; i < g_back800.length; i++) {
		vector pos = [0.0f, 0.0f, 0.0f];
		vector size = [0.0f, 0.0f, 0.0f];

		/* scale down 800x600 to 640x480 */
		float scaleX = vecSize[0] / 800;
		float scaleY = vecSize[1] / 600;
		size[0] = g_back800[i].vecSize[0] * scaleX;
		size[1] = g_back800[i].vecSize[1] * scaleY;
		pos[0] = (g_back800[i].vecPos[0] * scaleX);
		pos[1] = (g_back800[i].vecPos[1] * scaleY);

		drawpic(vecPos + pos, \
		g_back800[i].strMat, \
		size, \
		[1,1,1], \
		1.0f);
	}
}

void
Background_Draw(vector vecPos, vector vecSize)
{
	/* when ingame, we'll draw a slight black tint... */
	if (clientstate() == 2) {
		/* ...unless we're in background map mode. */
		if (!g_background) {
			drawpic([0,0], "menutint", g_vidsize, [1,1,1], 1.0f);
		}
	} else {
		/* clear screen */
		drawfill([0,0], g_vidsize, [0,0,0], 1.0f);

		switch (g_bgMode) {
		case BACK_VGUI1:
			Background_Steam(vecPos, vecSize);
			break;
		case BACK_WON:
			Background_WON(vecPos, vecSize);
			break;
		case BACK_MATERIAL:
		default:
			drawpic(vecPos, BACKGROUND_IMG, vecSize, [ 1, 1, 1 ], 1.0f);
			break;
		}
	}
}
