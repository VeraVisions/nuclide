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

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;

/* main entry */
void
HUD_Init(void)
{
}

/* main entry */
void
HUD_Draw(void)
{
	vector hudSize = g_view.GetHUDCanvasSize();
	vector iconPos = g_view.GetHUDCanvasPos() + (hudSize / 2);
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;

	/* health, armor icons */
	Font_DrawRText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], "100", FONT_16);
	drawpic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f);
	Font_DrawText(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], "100", FONT_16);
	drawpic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f);

	/* little point in not drawing these, even if you don't have a suit */
	if (pl.m_activeWeapon) {
		pl.m_activeWeapon.UpdateGUI();
	}

	Textmenu_Draw();
}

/* specatator main entry */
void
HUD_DrawSpectator(void)
{
	
}
