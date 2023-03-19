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

/*! @file crosshair.h
    @brief Crosshair helper functions.

    Helper functions for dealing with crosshairs in games.
    If you don't want to deal with handling accurate crosshairs in
    a variety of view modes (1st-person, 3rd-person, XR) then simply
    use one of the supplied functions.
*/

/** Draws a crosshair on the screen with the desired material and size.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen. */
void Cross_Draw(string materialPath, vector sizeXY);

/** Draw a given crosshair on the screen, with variable color.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen.
@param colorRGB is the normalized color values to tint the surface with.*/
void Cross_DrawRGB(string materialPath, vector sizeXY, vector colorRGB);

/** Draw a given crosshair on the screen, with variable color and alpha.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen.
@param colorRGB is the normalized color values to tint the surface with.
@param alphaValue is the alpha values to use on the whole surface.*/
void Cross_DrawRGBA(string materialPath, vector sizeXY, vector colorRGB, float alphaValue);


/** Draw a given crosshair on the screen, of only a section from a material.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen.
@param sourcePosXY is a normalized starting position within the material from which we should start drawing from.
@param sourceSizeXY is the normalized size within the material from which we should draw from.*/
void Cross_DrawSub(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY);


/** Draw a given crosshair on the screen, of only a section from a material, with variable color.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen.
@param sourcePosXY is a normalized starting position within the material from which we should start drawing from.
@param sourceSizeXY is the normalized size within the material from which we should draw from.
@param colorRGB is the normalized color values to tint the surface with.*/
void Cross_DrawSubRGB(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY, vector colorRGB);

/** Draw a given crosshair on the screen, of only a section from a material, with variable color/alpha.

@param materialPath is the material to use.
@param sizeXY is the size in pixels it is meant to take up on screen.
@param sourcePosXY is a normalized starting position within the material from which we should start drawing from.
@param sourceSizeXY is the normalized size within the material from which we should draw from.
@param colorRGB is the normalized color values to tint the surface with.
@param alphaValue is the alpha values to use on the whole surface.*/
void Cross_DrawSubRGBA(string materialPath, vector sizeXY, vector sourcePosXY, vector sourceSizeXY, vector colorRGB, float alphaValue);