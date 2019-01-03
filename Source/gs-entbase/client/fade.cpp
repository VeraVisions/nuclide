/***
*
*   Copyright (c) 2000-2019, Vera Visions. All rights reserved.
*
****/

float g_flFadeDuration;
float g_flFadeHold;
float g_flFadeMaxAlpha;
float g_flFadeStyle;
float g_flFadeAlpha;
float g_flFadeTime;
vector g_vecFadeColor;
int g_iFadeActive;

/*enum
{
	DRAWFLAG_NORMAL,
	DRAWFLAG_ADDITIVE,
	DRAWFLAG_MODULATE, // FTE doesn't support this
	DRAWFLAG_2XMODULATE // FTE doesn't support this
};*/

enumflags
{
	EVF_FADEDROM,
	EVF_MODULATE,
	EVF_ONLYUSER
};

void Fade_Init(void)
{
	shaderforname("fade_modulate","{\n{\nmap $whiteimage\nrgbGen vertex\nblendFunc GL_DST_COLOR GL_ONE_MINUS_SRC_ALPHA\nalphaGen vertex\n}\n}\n");
}

void Fade_Update (int x, int y, int w, int h)
{
	if (g_iFadeActive == FALSE) {
		return;
	}
	if (g_flFadeStyle & EVF_FADEDROM) {
		if (g_flFadeTime > g_flFadeHold) {
			g_flFadeAlpha -= (frametime * (1.0f / g_flFadeDuration)) * g_flFadeMaxAlpha;
		}
	} else {
		if (g_flFadeTime < g_flFadeDuration) {
			g_flFadeAlpha += (frametime * (1.0f / g_flFadeDuration)) * g_flFadeMaxAlpha;
		} else {
			g_flFadeAlpha -= (frametime * (1.0f / g_flFadeHold)) * g_flFadeMaxAlpha;
		}
	}

	if (g_flFadeAlpha > 1.0f) {
		g_flFadeAlpha = 1.0f;
	} else if (g_flFadeAlpha < 0.0f) {
		g_flFadeAlpha = 0.0f;
	}

	if (g_flFadeAlpha <= 0) {
		g_iFadeActive = FALSE;
		return;
	}

	if (g_flFadeStyle & EVF_MODULATE) {
		drawpic([x, y], "fade_modulate", [w, h], g_vecFadeColor, g_flFadeAlpha, 0);
	} else {
		drawfill([x, y], [w, h], g_vecFadeColor, g_flFadeAlpha, 0);
	}

	g_flFadeTime += frametime;
}

void Fade_Parse (void)
{
	g_vecFadeColor[0] = readbyte() / 255;
	g_vecFadeColor[1] = readbyte() / 255;
	g_vecFadeColor[2] = readbyte() / 255;
	g_flFadeMaxAlpha = readbyte() / 255;
	g_flFadeDuration = readfloat();
	g_flFadeHold = readfloat();
	g_flFadeStyle = readbyte();
	g_flFadeTime = 0.0f;

	if (g_flFadeStyle & EVF_FADEDROM) {
		g_flFadeAlpha = 1.0f;
	} else {
		g_flFadeAlpha = 0.0f;
	}

	g_iFadeActive = TRUE;
}
