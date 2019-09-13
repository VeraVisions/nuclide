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

/* TODO: Move these into the player info struct! */
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

const string mat_fade_modulate =
	"{\n" \
		"{\n" \
			"map $whiteimage\n" \
			"rgbGen vertex\n" \
			"blendFunc GL_DST_COLOR GL_ONE_MINUS_SRC_ALPHA\n" \
			"alphaGen vertex\n" \
		"}\n" \
	"}\n";

void Fade_Init(void)
{
	shaderforname("fade_modulate", mat_fade_modulate);
}

void Fade_Update (int x, int y, int w, int h)
{
	if (g_iFadeActive == FALSE) {
		return;
	}
	if (g_flFadeStyle & EVF_FADEDROM) {
		if (g_flFadeTime > g_flFadeHold) {
			g_flFadeAlpha -= (clframetime * (1.0f / g_flFadeDuration)) * g_flFadeMaxAlpha;
		}
	} else {
		if (g_flFadeTime < g_flFadeDuration) {
			g_flFadeAlpha += (clframetime * (1.0f / g_flFadeDuration)) * g_flFadeMaxAlpha;
		} else {
			g_flFadeAlpha -= (clframetime * (1.0f / g_flFadeHold)) * g_flFadeMaxAlpha;
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

	g_flFadeTime += clframetime;
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
