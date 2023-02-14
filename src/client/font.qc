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

float
Font_GetID(font_s fnt)
{
	return (float)fnt.iID;
}

void
Font_Load(string strFile, font_s &fntNew)
{
	string strTemp = "";
	string strFontPath = "";
	string strRenderSize = "";

	filestream fileFont = fopen(strFile, FILE_READ);
	fntNew.iID = 0;
	fntNew.iScaleX = fntNew.iScaleY = -1;
	fntNew.vecColor = [1,1,1];
	fntNew.flAlpha = 1.0f;
	fntNew.iFlags = 0;

	if (fileFont >= 0) {
		int argc;
		while ((strTemp = fgets(fileFont))) {
			argc = tokenize_console(strTemp);
			if (argc != 2)
				continue;

			switch (argv(0)) {
			case "color":
				fntNew.vecColor = stov(argv(1)) / 255;
				break;
			case "alpha":
				fntNew.flAlpha = stof(argv(1)) / 255;
				break;
			case "size_x":
				fntNew.iScaleX = (int)stof(argv(1));
				break;
			case "size_y":
				fntNew.iScaleY = (int)stof(argv(1));
				break;
			case "size":
				fntNew.iScaleY = fntNew.iScaleX = (int)stof(argv(1));
				break;
			case "path":
				strFontPath = argv(1);
				break;
			case "rendersize":
				strRenderSize = argv(1);
				break;
			case "flags":
				fntNew.iFlags = (int)stof(argv(1));
				break;
			case "additive":
				if (stof(argv(1)) == 1)
					fntNew.iFlags = DRAWFLAG_ADDITIVE;
				break;
			default:
				break;
			}
		}
		fclose(fileFont);
	} else {
		error(sprintf("cannot load font file %s!", strFile));
	}

	if (!fntNew.iScaleX || !fntNew.iScaleY) {
		error(sprintf("no valid size defined for %s!", strFile));
	}

	print(sprintf("loaded font definition for %s\n", strFile));

	if (strRenderSize != "") {
		print(sprintf("rendersize: %S\n", strRenderSize));
		fntNew.iID = (int)loadfont("", strFontPath, strRenderSize, -1, 0, 0);
	} else
		fntNew.iID = (int)loadfont("", strFontPath, ftos((float)fntNew.iScaleY), -1, 0, 0);
}

void
Font_DrawText(vector vecOrigin, string strText, font_s fnt)
{
	drawfont = (float)fnt.iID;
	drawstring(vecOrigin, strText, [fnt.iScaleX, fnt.iScaleY], fnt.vecColor, fnt.flAlpha, (float)fnt.iFlags);
	drawfont = 0;
}

void
Font_DrawText_A(vector vecOrigin, string strText, float a, font_s fnt)
{
	drawfont = (float)fnt.iID;
	drawstring(vecOrigin, strText, [fnt.iScaleX, fnt.iScaleY], fnt.vecColor, a, (float)fnt.iFlags);
	drawfont = 0;
}

void
Font_DrawText_RGB(vector vecOrigin, string strText, vector rgb, font_s fnt)
{
	drawfont = (float)fnt.iID;
	drawstring(vecOrigin, strText, [fnt.iScaleX, fnt.iScaleY], rgb, fnt.flAlpha, (float)fnt.iFlags);
	drawfont = 0;
}

void
Font_DrawText_RGBA(vector vecOrigin, string strText, vector rgb, float a, font_s fnt)
{
	drawfont = (float)fnt.iID;
	drawstring(vecOrigin, strText, [fnt.iScaleX, fnt.iScaleY], rgb, a, (float)fnt.iFlags);
	drawfont = 0;
}

void
Font_DrawRText(vector vecOrigin, string strText, font_s fnt)
{
	vecOrigin[0] -= Font_StringWidth(strText, TRUE, fnt);
	Font_DrawText(vecOrigin, strText, fnt);
}

void
Font_DrawRText_A(vector vecOrigin, string strText, float a, font_s fnt)
{
	vecOrigin[0] -= Font_StringWidth(strText, TRUE, fnt);
	Font_DrawText_A(vecOrigin, strText, a, fnt);
}

void
Font_DrawRText_RGB(vector vecOrigin, string strText, vector rgb, font_s fnt)
{
	vecOrigin[0] -= Font_StringWidth(strText, TRUE, fnt);
	Font_DrawText_RGB(vecOrigin, strText, rgb, fnt);
}

void
Font_DrawRText_RGBA(vector vecOrigin, string strText, vector rgb, float a, font_s fnt)
{
	vecOrigin[0] -= Font_StringWidth(strText, TRUE, fnt);
	Font_DrawText_RGBA(vecOrigin, strText, rgb, a, fnt);
}

void
Font_DrawField(vector vecOrigin, vector vecSize, string strText, font_s fnt, alignflags_t iAlignFlags)
{
	drawfont = (float)fnt.iID;
	drawfontscale[0] = (float)fnt.iScaleX / 8;
	drawfontscale[1] = (float)fnt.iScaleY / 8;
	drawtextfield(vecOrigin, vecSize, (float)iAlignFlags, strText);
	drawfont = 0;
	drawfontscale = [1,1,0];
}

string
Font_RGBtoHex(vector vecColor)
{
	static string numtohex(float x) {
		x = rint(x * 15);
		if (x <= 9)
			return ftos(x);
		else {
			x -= 10;
			return sprintf("%c", 'A' + x);
		}
		
	}

	return sprintf("^x%s%s%s", numtohex(vecColor[0]), numtohex(vecColor[1]), numtohex(vecColor[2]));
}

int
Font_GetHeight(font_s fnt)
{
	return (float)fnt.iScaleY;
}

float
Font_StringWidth(string strText, bool hasColor, font_s fnt)
{
	float w;
	drawfont = (float)fnt.iID;
	w = stringwidth(strText, (float)hasColor, [fnt.iScaleX, fnt.iScaleY]);
	drawfont = 0;
	drawfontscale = [1,1,0];
	return w;
}
