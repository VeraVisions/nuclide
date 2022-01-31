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

enumflags
{
	AF_RIGHT,
	AF_TOP,
	AF_LEFT,
	AF_BOTTOM
};

typedef struct
{
	int iID;
	int iScaleX;
	int iScaleY;
	vector vecColor;
	float flAlpha;
	int iFlags;
} font_s;

void Font_Load(string strFile, font_s &fntNew);
void Font_DrawText(vector vecOrigin, string strText, font_s fnt);
void Font_DrawText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);
void Font_DrawField(vector vecOrigin, vector vecSize, string strText, font_s fnt, int iAlignFlags);
string Font_RGBtoHex(vector vecColor);
int Font_GetHeight(font_s);
float Font_StringWidth(string strText, float flColors, font_s fnt);
float Font_GetID(font_s fnt);
