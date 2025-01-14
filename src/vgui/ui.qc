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

#include "Widget.h"

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
