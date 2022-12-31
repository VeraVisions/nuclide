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

/* compatibility wrappers */
#define CUI3DView VGUI3DView
#define CUIButton VGUIButton
#define CUICheckbox VGUICheckbox
#define CUILabel	VGUILabel
#define CUIList VGUIList
#define CUIListBox VGUIListBox
#define CUIMenuButton VGUIMenuButton
#define CUIPic VGUIPic
#define CUIRadio VGUIRadio
#define CUIScrollbar VGUIScrollbar
#define CUISlider VGUISlider
#define CUITabView VGUITabView
#define CUITextBox VGUITextBox
#define CUIWidget VGUIWidget
#define CUIWindow VGUIWindow

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

/** Return whether a VGUI panel is active on the 2D overlay level. */
int
VGUI_Active(void)
{
	return (g_vguiWidgetCount > 0) ? TRUE : FALSE;
}

/** Returns whether our mouse cursor is in a specific region of the screen. */
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

/** @brief The base VGUI widget class.

Every VGUI widget is based off of this. */
class VGUIWidget
{
public:
	void VGUIWidget(void);

	/** Adds a widget into this one. */
	nonvirtual void Add(VGUIWidget);
	/** Add a flag to the widget. */
	nonvirtual void FlagAdd(int);
	/** Remove a flag from the widget. */
	nonvirtual void FlagRemove(int);
	/** Set the position within its context. */
	nonvirtual void SetPos(vector);
	/** Return the position of the widget within its context. */
	nonvirtual vector GetPos(void);
	/** Returns the X coordinate of the widget position within its context. */
	nonvirtual int GetPosWidth(void);
	/** Returns the Y coordinate of the widget position within its context. */
	nonvirtual int GetPosHeight(void);

	/** Set the size of the widget to a new one. */
	nonvirtual void SetSize(vector);
	/** Returns the size of the widget, in pixels. */
	nonvirtual vector GetSize(void);

	/** Returns the width of the widget, in pixels. */
	nonvirtual int GetSizeWidth(void);
	/** Returns the height of the widget, in pixels. */
	nonvirtual int GetSizeHeight(void);

	/** Sets the minimum size of the widget. */
	nonvirtual void SetMinSize(vector);
	/** Returns the minimum size of the widget. */
	nonvirtual vector GetMinSize(void);

	/** Sets the maximum size of the widget. */
	nonvirtual void SetMaxSize(vector);
	/** Returns the maximum size of the widget. */
	nonvirtual vector GetMaxSize(void);

	/** Returns true/false depending on if the widget is visible. */
	nonvirtual bool Visible(void);
	/** Show the widget. */
	nonvirtual void Show(void);
	/** Hide the widget. */
	nonvirtual void Hide(void);

	/** Called when the position of the widget was changed in any capacity. */
	virtual void PositionChanged(vector, vector);
	/** Called when the size of the widget has changed in any capacity. */
	virtual void SizeChanged(vector, vector);

	/** Called in order to draw the widget. */
	virtual void Draw(void);
	/** Called whenever the physical properties of the display change. */
	virtual void Reposition(void);
	/** Called whenever an input event gets directed to the widget. */
	virtual bool Input(float, float, float, float);
	/** Called when the widget has fully initialized.
       When you override this, you may call `super::Spawned();` to ensure
       the parent classes get to finish initializing also. */
	virtual void Spawned(void);

private:
	vector m_vecOrigin;
	vector m_vecSize;
	vector m_vecMinSize;
	vector m_vecMaxSize;
	VGUIWidget m_next;
	VGUIWidget m_parent;
	int m_iFlags;
	bool m_bVisible;
};

void
VGUIWidget::VGUIWidget(void)
{
	m_vecOrigin = [0.0f, 0.0f];
	m_vecSize = [0.0f, 0.0f];
	m_vecMinSize = [0.0f, 0.0f];
	m_vecMaxSize = [9999.0f, 9999.0f];
	m_next = __NULL__;
	m_parent = __NULL__;
	m_iFlags = 0i;
	m_bVisible = true;

	Spawned();
}

bool
VGUIWidget::Visible(void)
{
	return m_bVisible;
}

void
VGUIWidget::Hide(void)
{
	m_bVisible = false;
}

void
VGUIWidget::Show(void)
{
	m_bVisible = true;
}

void
VGUIWidget::PositionChanged(vector vecOld, vector vecNew)
{

}

void
VGUIWidget::SizeChanged(vector vecOld, vector vecNew)
{

}

void
VGUIWidget::SetPos(vector vecNewPos)
{
	m_vecOrigin[0] = bound(0, vecNewPos[0], 9999.0);
	m_vecOrigin[1] = bound(0, vecNewPos[1], 9999.0);
}

vector
VGUIWidget::GetPos(void)
{
	return m_vecOrigin;
}

int
VGUIWidget::GetPosWidth(void)
{
	return m_vecOrigin[0];
}

int
VGUIWidget::GetPosHeight(void)
{
	return m_vecOrigin[1];
}

void
VGUIWidget::SetSize(vector vecNewSize)
{
	vector vecOld = m_vecSize;
	m_vecSize = vecNewSize;
	m_vecSize[0] = bound(m_vecMinSize[0], vecNewSize[0], m_vecMaxSize[0]);
	m_vecSize[1] = bound(m_vecMinSize[1], vecNewSize[1], m_vecMaxSize[1]);

	SizeChanged(vecOld, m_vecSize);
}

vector
VGUIWidget::GetSize(void)
{
	return m_vecSize;
}

int
VGUIWidget::GetSizeWidth(void)
{
	return m_vecSize[0];
}

int
VGUIWidget::GetSizeHeight(void)
{
	return m_vecSize[1];
}

void
VGUIWidget::SetMinSize (vector vecNewSize)
{
	m_vecMinSize = vecNewSize;
}

vector
VGUIWidget::GetMinSize(void)
{
	return m_vecMinSize;
}

void
VGUIWidget::SetMaxSize (vector vecNewSize)
{
	m_vecMaxSize = vecNewSize;
}

vector
VGUIWidget::GetMaxSize(void)
{
	return m_vecMaxSize;
}

void
VGUIWidget::FlagAdd(int iFlag)
{
	m_iFlags |= iFlag;
}

void
VGUIWidget::FlagRemove(int iFlag)
{
	m_iFlags -= (m_iFlags & iFlag);
}

void
VGUIWidget::Reposition(void)
{

}

void
VGUIWidget::Add(VGUIWidget wNew)
{
	VGUIWidget wNext = this;
	VGUIWidget wParent;
	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while (wNext);
	wParent.m_next = wNew;
	wNew.m_parent = this;
}

.string classname;
void
VGUIWidget::Draw(void)
{
	VGUIWidget wNext = this;
	g_vguiWidgetCount = 0;
	do {
		wNext = wNext.m_next;
		if (wNext && wNext.Visible() && wNext.m_parent.Visible()) {
			g_vguiWidgetCount++;
			wNext.Draw();
		}
	} while (wNext);
}

typedef struct
{
	VGUIWidget member;
} vgui_input_scene_t;

bool
VGUIWidget::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	VGUIWidget wNext = this;

	/* this is garbage, but it'll work */
	int c = 0;
	do {
		wNext = wNext.m_next;
		c++;
	} while (wNext);

	/* we got the count of valid items */
	vgui_input_scene_t *tree = memalloc(sizeof(vgui_input_scene_t) * c);

	int i = 0;
	wNext = this;
	do {
		wNext = wNext.m_next;
		tree[i].member = wNext;
		i++;
	} while (wNext);

	/* traverse the list in reverse */
	for (int x = c-1; x >= 0; x--) {
		wNext = tree[x].member;

		if (wNext && wNext.Visible() && wNext.m_parent.Visible())
			if (wNext.Input(flEVType, flKey, flChar, flDevID) == true) {
				memfree(tree);
				return (true);
			}
	}

	memfree(tree);
	return (false);
}

void
VGUIWidget::Spawned(void)
{
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

#ifdef CLIENT
VGUIWidget
UIClass_Spawn(string cname)
{
	string func = strcat("spawnfunc_", cname);

	if (isfunction(func)) {
		entity oldself = self;
		void(void) vFunc;
		vFunc = externvalue(-2, func);
		VGUIWidget new_uiclass = spawn(VGUIWidget);
		self = new_uiclass;
		vFunc();
		self = oldself;
		return (new_uiclass);
	} else {
		error("UIClass_Spawn: failed loading designated UI class\n");
	}

	return __NULL__;
}
#endif
