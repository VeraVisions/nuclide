/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

font_s g_fntDefault;
var int g_vguiWidgetCount;

#ifdef CLASSIC_VGUI
	#ifndef UI_MAINCOLOR
		#define UI_MAINCOLOR [255,200,0] / 255
	#endif
	#ifndef UI_MAINALPHA
		#define UI_MAINALPHA 255
	#endif
#else
	var vector UI_MAINCOLOR;
	var float UI_MAINALPHA;
#endif

int
VGUI_Active(void)
{
	return (g_vguiWidgetCount > 0) ? TRUE : FALSE;
}

int
Util_MouseAbove(vector vecMousePos, vector vecPos, vector vecSize)
{
	if (vecMousePos[0] >= vecPos[0] && vecMousePos[0] <= vecPos[0] + vecSize[0]) {
		if (vecMousePos[1] >= vecPos[1] && vecMousePos[1] <= vecPos[1] + vecSize[1]) {
			return (1);
		}
	}
	return (0);
}

class CUIWidget
{
	vector m_vecOrigin;
	CUIWidget m_next;
	CUIWidget m_parent;
	int m_iFlags;

	virtual void(CUIWidget) Add;
	virtual void(int) FlagAdd;
	virtual void(int) FlagRemove;
	virtual void(vector) SetPos;
	virtual vector() GetPos;
	virtual int(void) GetPosWidth;
	virtual int(void) GetPosHeight;
	virtual void(void) Draw;
	virtual void(void) Reposition;
	virtual bool(float, float, float, float) Input;
};

void
CUIWidget::SetPos(vector vecPos)
{
	m_vecOrigin = vecPos;
}

vector
CUIWidget::GetPos(void)
{
	return m_vecOrigin;
}

int
CUIWidget::GetPosWidth(void)
{
	return m_vecOrigin[0];
}

int
CUIWidget::GetPosHeight(void)
{
	return m_vecOrigin[1];
}

void
CUIWidget::FlagAdd(int iFlag)
{
	m_iFlags |= iFlag;
}

void
CUIWidget::FlagRemove(int iFlag)
{
	m_iFlags -= (m_iFlags & iFlag);
}

void
CUIWidget::Reposition(void)
{

}

void
CUIWidget::Add(CUIWidget wNew)
{
	CUIWidget wNext = this;
	CUIWidget wParent;
	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while (wNext);
	wParent.m_next = wNew;
	wNew.m_parent = this;
}

void
CUIWidget::Draw(void)
{
	CUIWidget wNext = this;
	g_vguiWidgetCount = 0;
	do {
		wNext = wNext.m_next;
		if (wNext && wNext.m_iFlags & 1 && wNext.m_parent.m_iFlags & 1) {
			g_vguiWidgetCount++;
			wNext.Draw();
		}
	} while (wNext);
}

typedef struct
{
	CUIWidget member;
} vgui_input_scene_t;

bool
CUIWidget::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	CUIWidget wNext = this;

#if 0
	do {
		wNext = wNext.m_next;
		if (wNext && wNext.m_iFlags & 1 && wNext.m_parent.m_iFlags & 1) {
			if (wNext.Input(flEVType, flKey, flChar, flDevID) == true)
				return;
		}
	} while (wNext);
#else
	/* this is garbage, but it'll work */
	int c = 0;
	do {
		wNext = wNext.m_next;
		c++;
	} while (wNext);

	/* we got the count of valid items */
	vgui_input_scene_t *tree = memalloc(sizeof(vgui_input_scene_t) * c);

	int i = 0;
	CUIWidget wNext = this;
	do {
		wNext = wNext.m_next;
		tree[i].member = wNext;
		i++;
	} while (wNext);

	/* traverse the list in reverse */
	for (int i = c-1; i >= 0; i--) {
		wNext = tree[i].member;

		if (wNext && wNext.m_iFlags & 1 && wNext.m_parent.m_iFlags & 1)
			if (wNext.Input(flEVType, flKey, flChar, flDevID) == true)
				return;
	}

	memfree(tree);

#endif
}

void
UISystem_Init(void)
{
	/* we support fancier stuff in non-classic mode */
#ifndef CLASSIC_VGUI
	string strTemp;
	string strUIFile = "scripts/ui_style.txt";
	filestream fileUI = fopen(strUIFile, FILE_READ);

	UI_MAINCOLOR = [68,68,68] / 255;
	UI_MAINALPHA = 1.0f;

	if (fileUI >= 0) {
		while ((strTemp = fgets(fileUI))) {
			if (tokenizebyseparator(strTemp, "=") == 2) {
				switch (argv(0)) {
					case "COLOR":
						UI_MAINCOLOR = stov(argv(1)) / 255;
						break;
					case "ALPHA":
						UI_MAINALPHA = stof(argv(1)) / 255;
						break;
				}
			}
		}
		fclose(fileUI);
	} else {
		error(sprintf("[MENU] Cannot load UI file %s!", strUIFile));
	}
#endif

	Font_Load("fonts/ui.font", g_fntDefault);
	precache_pic("textures/ui/steam/icon_radiosel");
	precache_pic("textures/ui/steam/icon_radiounsel");
	precache_pic("textures/ui/steam/icon_checked");
	precache_pic("textures/ui/steam/icon_emptybox");
	precache_pic("textures/ui/steam/icon_down");
	precache_pic("textures/ui/steam/icon_up");
	precache_pic("textures/ui/steam/icon_close");
}
