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

/** @defgroup font Fonts
    @brief Typeface format loader/handler for rendering bitmap/vector based text and icons.
    @ingroup client

    @{

 */

/** Flags for 2D drawing operations. */
typedef enum
{
	DRAWFLAG_NORMAL = 0, /**< The default. */
	DRAWFLAG_ADDITIVE, /**< Render with an additive blend mode. */
	DRAWFLAG_MODULATE, /**< Not implemented in FTEQW. */
	DRAWFLAG_2XMODULATE /**< Not implemented in FTEQW. */
} drawflag_t;

/** Defines the valid alignment flags for text fields. 
@sa Font_DrawField */
typedef enumflags
{
	AF_LEFT,
	AF_TOP,
	AF_RIGHT,
	AF_BOTTOM
} alignflags_t;
#define AF_NONE 0

/** Representation of a font. */
typedef struct
{
	int iID;	/**< Internal ID, will be passed to 'drawfont' before rendering text. */
	int iScaleX; /**< Suggested maximum width of a character in the font. */
	int iScaleY; /**< Maximum height of a chracter in the font. */
	vector vecColor; /**< Suggested default color of the font. */
	float flAlpha; /**< Suggested default alpha of the font. */
	int iFlags;	/**< Rendering flags that the font posesses. @sa drawflag_t */
	string hexColor;
} font_s;

/** Load a desired .font definition into memory.

@param strFile is the path to the file in question.
@param fntNew is the location of where the font will be stored. */
void Font_Load(string strFile, font_s &fntNew);

/* standard drawing */
/** Draw text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param fnt is the font to be used. */
void Font_DrawText(vector vecOrigin, string strText, font_s fnt);
/** Draw alpha-blended text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
void Font_DrawText_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Draw tinted text on the screen at the desired position with a desired font. 

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param fnt is the font to be used. */
void Font_DrawText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Draw tinted and alpha blended text on the screen at the desired position
with a desired font. 

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
void Font_DrawText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);

/* right aligned variants */
/** Right-aligned variant of Font_DrawText.
@sa Font_DrawText */
void Font_DrawRText(vector vecOrigin, string strText, font_s fnt);
/** Right-aligned variant of Font_DrawText_A.
@sa Font_DrawText_A */
void Font_DrawRText_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Right-aligned variant of Font_DrawText_RGB.
@sa Font_DrawText_RGB */
void Font_DrawRText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Right-aligned variant of Font_DrawText_RGBA.
@sa Font_DrawText_RGBA */
void Font_DrawRText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);

/** Draws a textfield with line wrapping.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
void Font_DrawField(vector vecOrigin, vector vecSize, string strText, font_s fnt, alignflags_t iAlignFlags);

/** Draws a textfield with line wrapping at a custom text height.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param iTextHeight is the desired text height in pixels.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
void Font_DrawFieldAtHeight(vector vecOrigin, vector vecSize, int iTextHeight, string strText, font_s fnt, alignflags_t iAlignFlags);

/** Converts a normalized RGB color vector to a hex color string.

@param vecColor is the normalized input color. E.g. [1.0f, 0.0f, 0.0f]
@return is a hex color string. e.g. "^xF00" */
string Font_RGBtoHex(vector vecColor);

/** @brief Returns the height of a specified font in pixels. 
@param fnt is the font to be queried.
@return is the height of a font in pixels.
@sa Font_StringWidth
*/
int Font_GetHeight(font_s fnt);

/** @brief Returns the width of a series of characters in pixels.

If you have a string with funstring color codes (e.g. ^1 or ^xF00) and want to make
sure those are not interpreted as visible characters, set the parameter hasColor
to true. Rendering may be more expensive this way, but you should generally cache the
result instead of querying it every frame anyway.

The return value is of type float, to be a drop-in replacement for the engine builtin
stringwidth().

@param strText is the text to get the length of. 
@param hasColor hints if funstring color codes are present in the string.
@param fnt is the font used with the text in question. */
float Font_StringWidth(string strText, bool hasColor, font_s fnt);

/** @brief Get the internal font id.

The internal font id is only useful for when you want to assign 'drawfont'
yourself, or have some other use for it. Those id's are meant to be unique,
but may change between vid_reload or other cases where video memory is de-allocated.
Overall you should never need to use this, unless you know what you're doing or are
porting old code.

@param fnt is the font to be queried.
@return the internal 'drawfont' id of the specified font. */
float Font_GetID(font_s fnt);

/** @} */ // end of client
