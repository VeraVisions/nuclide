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

#warning vguiWidget needs methods to deal with .res/.gui type files.

.string classname;
.bool isVGUI;

font_s g_fntDefault;
font_s g_fntTitle;
font_s g_fntSubTitle;
font_s g_fntMenuButton;
var int g_vguiWidgetCount;
vector g_lastmousepos;

/** @defgroup vgui Vera GUI
    @brief Truly versatile user interface, for menus and in-game surfaces.

    Nuclide ships with this component as the default interface library.

![Menu using Vera GUI](nuclide-base.png)

Its design goals were to be easily customizable through some common parameters,
and a per-object based [theme engine](@ref vguiTheme) for anything more advanced.
It also needed to be usable on in-game surfaces.

![Interactive surfaces](vgui-interactive.png)

## Customization

You can make trivial changes using external **UI** styling files, this is not
following any specific spec and may be subject to change some day to
adopt something more standardized.

Currently however you can modify the file (create them if they don't exist)
named `scripts/ui_style.txt`. Said file will contain a variety of key/value pairs:


- "BG_COLOR" : Background color.
- "FG_COLOR" : Foreground color. Used by text.
- "HILIGHT_COLOR" : Highlighted  text color.
- "SHADOW_COLOR" : Shadow color.
- "BORDER_COLOR" : Border color.
- "FILL_COLOR" : Fill color, used by progress bars elements and the like.
- "BORDER_ALPHA" : Border alpha value.
- "HOVER_COLOR" : Hover overlay color. Active when hovering over elements.
- "HOVER_ALPHA" : Hover overlay alpha. Set this to 0 if you don't want them.
- "BG_ALPHA" : Background alpha.
- "ROUNDED" : Use rounded borders on windows.
- "NOICONS" : Disable the use of most icons.

@note Color and alpha values target channels with values between 0 and 255.

If a file named `scripts/client_style.txt` exists, it will be read instead by the client-game - but not by the main menu. That way you can have different colorschemes for both modules at the same time.

### Example Style File

This file will give you a grey menu, with white text that's slightly transparent and has no icons, but rounded corners:

```
COLOR=200 200 200
FG_COLOR=255 255 255
ALPHA=196
NOICONS=1
ROUNDED=1

```

## Advanced Themes

Theming an object through more advanced means is possible with vguiTheme.
vguiTheme is responsible for theming everything, but it is also designed to
co-exist with other theme engines.

Use vguiWidget::SetTheme() to override the theme engine any of your widgets are using
with an instance of your own.
For that, make a child-class of vguiTheme and override the methods you want changed within it.
Then use the aforementioned method to override it on a per-object basis.

While you can theme individual elements, all of their child-widgets (e.g. the close button
on a window) will inherit the theme of their parent by default.

@note For most use-cases, you will want to call vguiWidget::SetTheme() on the very first vguiWidget, the one
everything else will be added to using vguiWidget::Add()

@{
*/

/** Return whether a VGUI panel is active on the 2D overlay level. */
bool
VGUI_Active(void)
{
	return (g_vguiWidgetCount > 0i) ? (true) : (false);
}

/** Returns whether our mouse cursor is in a specific region of the screen. */
bool
Util_MouseAbove(vector vecMousePos, vector vecPos, vector vecSize)
{
	if (vecMousePos[0] >= vecPos[0] && vecMousePos[0] <= vecPos[0] + vecSize[0]) {
		if (vecMousePos[1] >= vecPos[1] && vecMousePos[1] <= vecPos[1] + vecSize[1]) {
			return (true);
		}
	}

	return (false);
}

/** @brief The base VGUI widget class.

Every VGUI widget is based off of this. */
class vguiWidget
{
public:
	void vguiWidget(void);

	/** Adds a widget into this one. */
	virtual void Add(vguiWidget);
	/** Add a flag to the widget. */
	nonvirtual void FlagAdd(int);
	/** Remove a flag from the widget. */
	nonvirtual void FlagRemove(int);
	/** Check if the vguiWidget has a flag attached. */
	nonvirtual bool HasFlag(int);

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
	nonvirtual int GetWidth(void);
	/** Returns the height of the widget, in pixels. */
	nonvirtual int GetHeight(void);

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

	/** Sets the vguiTheme to use on this widget (and any children it may have) */
	nonvirtual void SetTheme(vguiTheme);
	/** Returns the VGUI that will be used on this widget. */
	nonvirtual vguiTheme GetTheme(void);

	/** Called when the position of the widget was changed in any capacity. */
	virtual void PositionChanged(vector, vector);
	/** Called when the size of the widget has changed in any capacity. */
	virtual void SizeChanged(vector, vector);

	virtual void NowVisible(void);
	virtual void NowHidden(void);

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
	/* why are these 3D vectors? because drawpic() etc. take it. ..you never know what that may be used for some day! */
	vector m_vecOrigin;
	vector m_vecSize;
	vector m_vecMinSize;
	vector m_vecMaxSize;

	vguiWidget m_next;
	vguiWidget m_parent;
	vguiWidget m_children;
	int m_iFlags;
	bool m_bVisible;
	vguiTheme m_theme;
};

void
vguiWidget::vguiWidget(void)
{
	m_vecOrigin = [0.0f, 0.0f];
	m_vecSize = [0.0f, 0.0f];
	m_vecMinSize = [0.0f, 0.0f];
	m_vecMaxSize = [9999.0f, 9999.0f];
	m_next = __NULL__;
	m_parent = __NULL__;
	m_iFlags = 0i;
	m_bVisible = true;
	isVGUI = true;

	Spawned();
}

void
vguiWidget::SetTheme(vguiTheme theme)
{
	m_theme = theme;
}

vguiTheme
vguiWidget::GetTheme(void)
{
	/* if no theme set, but we have a parent... inherit the parents' theme recursively */
	if (!m_theme && m_parent) {
		return m_parent.GetTheme();
	}

	/* we have nothing, use the default one. */
	if (!m_theme) {
		m_theme = spawn(vguiTheme);
	}

	return (m_theme);
}

bool
vguiWidget::Visible(void)
{
	return (m_bVisible);
}

void
vguiWidget::Hide(void)
{
	m_bVisible = false;
	NowHidden();
}

void
vguiWidget::NowHidden(void)
{
}


void
vguiWidget::NowVisible(void)
{
}


void
vguiWidget::Show(void)
{
	m_bVisible = true;
	NowVisible();
}

void
vguiWidget::PositionChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SizeChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SetPos(vector vecNewPos)
{
	vector vecOld = m_vecOrigin;
	m_vecOrigin[0] = bound(0, vecNewPos[0], 9999.0);
	m_vecOrigin[1] = bound(0, vecNewPos[1], 9999.0);
	PositionChanged(vecOld, m_vecOrigin);
}

vector
vguiWidget::GetPos(void)
{
	return (m_vecOrigin);
}

int
vguiWidget::GetPosWidth(void)
{
	return (m_vecOrigin[0]);
}

int
vguiWidget::GetPosHeight(void)
{
	return (m_vecOrigin[1]);
}

void
vguiWidget::SetSize(vector vecNewSize)
{
	vector vecOld = m_vecSize;
	m_vecSize[0] = bound(m_vecMinSize[0], vecNewSize[0], m_vecMaxSize[0]);
	m_vecSize[1] = bound(m_vecMinSize[1], vecNewSize[1], m_vecMaxSize[1]);
	SizeChanged(vecOld, m_vecSize);
}

vector
vguiWidget::GetSize(void)
{
	return (m_vecSize);
}

int
vguiWidget::GetWidth(void)
{
	return (m_vecSize[0]);
}

int
vguiWidget::GetHeight(void)
{
	return (m_vecSize[1]);
}

void
vguiWidget::SetMinSize (vector vecNewSize)
{
	m_vecMinSize = vecNewSize;
}

vector
vguiWidget::GetMinSize(void)
{
	return (m_vecMinSize);
}

void
vguiWidget::SetMaxSize (vector vecNewSize)
{
	m_vecMaxSize = vecNewSize;
}

vector
vguiWidget::GetMaxSize(void)
{
	return (m_vecMaxSize);
}

void
vguiWidget::FlagAdd(int iFlag)
{
	m_iFlags |= iFlag;
}

void
vguiWidget::FlagRemove(int iFlag)
{
	m_iFlags -= (m_iFlags & iFlag);
}

bool
vguiWidget::HasFlag(int flag)
{
	return (m_iFlags & flag) ? (true) : (false);
}

void
vguiWidget::Reposition(void)
{
	vguiWidget wNext = this;

	do {
		wNext = wNext.m_next;

		if (wNext) {
			wNext.Reposition();
		}
	} while (wNext);
}

void
vguiWidget::Add(vguiWidget wNew)
{
	vguiWidget wNext = this;
	vguiWidget wParent;

	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while (wNext);

	wParent.m_next = wNew;
	wNew.m_parent = this;
}

void
vguiWidget::Draw(void)
{
	vguiWidget wNext = this;
	g_vguiWidgetCount = 0;

	do {
		wNext = wNext.m_next;
		if (wNext && wNext.Visible() && wNext.m_parent.Visible()) {
			g_vguiWidgetCount++;
			wNext.Draw();
		}
	} while (wNext);
}

bool
vguiWidget::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	vguiWidget wNext = this;
	vguiWidget wLast = __NULL__;
	vguiWidget wLastBefore = __NULL__;

	/* figure out the last window in the chain... */
	do {
		wLastBefore = wNext;
		wNext = wNext.m_next;

		if (wNext) {
			wLast = wNext;
		}
	} while (wNext);

	//print(sprintf("Last widget: %S\n", wLast.classname)); 

	/* we've found a window, let's test inputs backwards. */
	while (wLast.classname) {
		bool test = false;

		if (wLast.Visible())
			test = wLast.Input(flEVType, flKey, flChar, flDevID);

		//print(sprintf("Testing input for... widget: %S %d\n", wLast.classname, test));

		/* input successful */
		if (test == true) {
			return (true);
		}

		/* select the former input */
		for (vguiWidget a = this; a != __NULL__; a = a.m_next) {
			/* we've reached the end, take one from before */
			if (a == wLast) {
				wLast = wLastBefore;
				break;
			}
			wLastBefore = a;
		}

		/* the end of the world. */
		if (wLast == this)
			return (false);
	}

	return (false);
}

void
vguiWidget::Spawned(void)
{
}

void
UISystem_Init(void)
{
	string strTemp;

#ifdef CLIENT
	string strUIFile = "scripts/client_style.txt";
#else
	string strUIFile = "scripts/menu_style.txt";
#endif

	filestream fileUI = fopen(strUIFile, FILE_READ);

	if (fileUI < 0) {
		strUIFile = "scripts/ui_style.txt";
		fileUI = fopen(strUIFile, FILE_READ);
	}

	UI_MAINCOLOR = [68,68,68] / 255;
	UI_FGCOLOR = [255,255,255] / 255;
	UI_MAINALPHA = 1.0f;
	UI_ROUNDED = false;
	UI_NOICONS = false;
	UI_HICOLOR = [255,255,255] / 255;
	UI_LOCOLOR = [0,0,0] / 255;
	UI_BORDERCOLOR = [255,255,255] / 255;
	UI_BORDERALPHA = 0 / 255;
	UI_FILLCOLOR = [255,255,255] / 255;
	UI_HOVERCOLOR = [255,255,255] / 255;
	UI_HOVERALPHA = 0;

	if (fileUI >= 0) {
		while ((strTemp = fgets(fileUI))) {
			if (tokenizebyseparator(strTemp, "=") == 2) {
				switch (argv(0)) {
					case "BG_COLOR":
					case "COLOR":
						UI_MAINCOLOR = stov(argv(1)) / 255;
						break;
					case "FG_COLOR":
						UI_FGCOLOR = stov(argv(1)) / 255;
						break;
					case "HILIGHT_COLOR":
						UI_HICOLOR = stov(argv(1)) / 255;
						break;
					case "SHADOW_COLOR":
						UI_LOCOLOR = stov(argv(1)) / 255;
						break;
					case "BORDER_COLOR":
						UI_BORDERCOLOR = stov(argv(1)) / 255;
						break;
					case "FILL_COLOR":
						UI_FILLCOLOR = stov(argv(1)) / 255;
						break;
					case "BORDER_ALPHA":
						UI_BORDERALPHA = stof(argv(1)) / 255;
						break;
					case "HOVER_COLOR":
						UI_HOVERCOLOR = stov(argv(1)) / 255;
						break;
					case "HOVER_ALPHA":
						UI_HOVERALPHA = stof(argv(1)) / 255;
						break;
					case "BG_ALPHA":
					case "ALPHA":
						UI_MAINALPHA = stof(argv(1)) / 255;
						break;
					case "ROUNDED":
						UI_ROUNDED = (bool)stof(argv(1));
						break;
					case "NOICONS":
						UI_NOICONS = (bool)stof(argv(1));
						break;
				}
			}
		}
		fclose(fileUI);
	} else {
		NSError(sprintf("[MENU] Cannot load UI file %s!", strUIFile));
	}

	Font_Load("fonts/ui.font", g_fntDefault);
	Font_Load("fonts/title.font", g_fntTitle);
	Font_Load("fonts/subtitle.font", g_fntSubTitle);
	Font_Load("fonts/menu_button.font", g_fntMenuButton);

	if (g_fntMenuButton.iID == 0) {
		g_fntMenuButton = g_fntDefault;
	}

	if (g_fntSubTitle.iID == 0) {
		g_fntSubTitle = g_fntDefault;
	}

	if (g_fntTitle.iID == 0) {
		g_fntTitle = g_fntDefault;
	}
}

#ifdef CLIENT
vguiWidget
UIClass_Spawn(string cname)
{
	string func = strcat("spawnfunc_", cname);

	if (isfunction(func)) {
		vguiWidget new_uiclass = __NULL__;
		entity oldself = self;
		void(void) vFunc;

		vFunc = externvalue(-2, func);
		new_uiclass = spawn(vguiWidget);

		self = new_uiclass;
		vFunc();
		self = oldself;

		return (new_uiclass);
	} else {
		error("UIClass_Spawn: failed loading designated UI class\n");
	}

	return (__NULL__);
}
#endif

/** @} */ // end of vgui
