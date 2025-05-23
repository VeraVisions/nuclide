/*
 * Copyright (c) 2023-2024 Marco Cawthorne <marco@icculus.org>
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

typedef struct
{
	string m_strImage;
	vector m_vecSize;
	vector m_vecCanvasSize;
	vector m_vecCanvasPos;
} hlsprite_t;

class
ncInterfaceSpriteSheet
{
	nonvirtual void Initialize(void);
	nonvirtual void Draw_RGBA(string spriteName, vector spritePos, vector spriteColor, float spriteAlpha, bool isAdditive);
	nonvirtual void Draw(string spriteName, vector spritePos, bool isAdditive);
	nonvirtual void Draw_A(string spriteName, vector spritePos, float spriteAlpha, bool isAdditive);
	nonvirtual void Draw_RGB(string spriteName, vector spritePos, vector spriteColor, bool isAdditive);
	nonvirtual void DrawCrosshair(string spriteName);
};
