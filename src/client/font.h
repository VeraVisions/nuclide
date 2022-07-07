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

/* flags for 2d drawing */
#define DRAWFLAG_NORMAL		0
#define DRAWFLAG_ADDITIVE	1
#define DRAWFLAG_MODULATE	2
#define DRAWFLAG_2XMODULATE	3

enumflags
{
	AF_LEFT,
	AF_TOP,
	AF_RIGHT,
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

/* standard drawing */
void Font_DrawText(vector vecOrigin, string strText, font_s fnt);
void Font_DrawText_A(vector vecOrigin, string strText, float a, font_s fnt);
void Font_DrawText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
void Font_DrawText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);

/* right aligned variants */
void Font_DrawRText(vector vecOrigin, string strText, font_s fnt);
void Font_DrawRText_A(vector vecOrigin, string strText, float a, font_s fnt);
void Font_DrawRText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
void Font_DrawRText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);

void Font_DrawField(vector vecOrigin, vector vecSize, string strText, font_s fnt, int iAlignFlags);

/* returns a 0xFFFFFF type color code you can put into your strings */
string Font_RGBtoHex(vector vecColor);

/* gets the height for a single character of the specified font */
int Font_GetHeight(font_s);

/* gets the width of a series of characters */
float Font_StringWidth(string strText, float flColors, font_s fnt);

/* get the 'drawfont' ID, only use this when porting old code quickly. */
float Font_GetID(font_s fnt);
