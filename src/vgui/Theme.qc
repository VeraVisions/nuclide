/* For vguiTheme, we want to allow everyone some basic overrides to handle most of the drawing
tasks. However, this is matter that will slowly expand to encompass more features.
If you plan on doing something really 'out there' that you can't do within this Theme framework,
I encourage you to just maintain your own objects with overridden draw functions for best
forward compatibility.

Why does this exist? Because the support for VGUI type elements needs variable appearances
and we can't rely on ifdefs to do the bulk of the work, that's why. The official inspiration
also referred to as TrackerUI has changed many times in appearance and we'd like to offer
means of handling any such styles.
*/


var vector UI_MAINCOLOR;
var vector UI_FGCOLOR;
var float UI_MAINALPHA;
var vector UI_HICOLOR;
var vector UI_FILLCOLOR;
var vector UI_LOCOLOR;
var vector UI_BORDERCOLOR;
var float UI_BORDERALPHA;
var bool UI_ROUNDED;
var bool UI_NOICONS;
var vector UI_HOVERCOLOR;
var float UI_HOVERALPHA;

/** State of the widget we're going to draw. */
typedef enum
{
	VGUI_STATE_NORMAL,		/** The widget is in normal operation. */
	VGUI_STATE_ACTIVE,		/** The widget is active. */
	VGUI_STATE_HOVER,		/** The mouse or another pointing device is hovering over the widget. */
	VGUI_STATE_FOCUSED,		/** The widget is focused. */
	VGUI_STATE_DISABLED,	/** The widget is disabled. */
	VGUI_STATE_CHECKED		/** The widget is pressed or enabled. */
} VGUIDrawState_t;

/** Style of the border to be drawn within the vguiTheme. */
typedef enum
{
	VGUI_BORDER_LINE,		/**< Thin line border. */
	VGUI_BORDER_INSET,		/**< Inset border, used for control elements. */
	VGUI_BORDER_OUTSET,		/**< Outset border, often used for windows. */
	//VGUI_BORDER_DOTTED,	
	//VGUI_BORDER_DASHED,
	//VGUI_BORDER_RIDGE,
	//VGUI_BORDER_GROOVE
	VGUI_BORDER_NONE		/**< No border */
} VGUIBorderStyle_t;

/** Abstract class than can be set/overriden to customize to final appearance of GUI widgets */
class
vguiTheme
{
public:
	virtual void vguiTheme(void);

	/** Draw a border at the specified position, size and VGUIBorderStyle_t. */
	virtual void DrawBorder(vector, vector, VGUIBorderStyle_t, vguiColor);
	/** Draw a control item background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawControlBackground(vector, vector, VGUIDrawState_t);
	/** Draw a text field background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawTextBackground(vector, vector, VGUIDrawState_t);
	/** Draw a window background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawWindowBackground(vector, vector, VGUIDrawState_t);
	/** Draw a window background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawWindowTitle(vector, vector, string, string, font_s, VGUIDrawState_t);
	/** Draw a button body at the specified position, size and VGUIDrawState_t. */
	virtual void DrawButton(vector, vector, VGUIDrawState_t);
	/** Draw a scroller at the specified position, size and VGUIDrawState_t. */
	virtual void DrawScroller(vector, vector, VGUIDrawState_t);
	/** Draw a scrollbar at the specified position, size and VGUIDrawState_t. */
	virtual void DrawScrollbar(vector, vector, VGUIDrawState_t);
	/** Draw a progress indicator at the specified position, size and VGUIDrawState_t. */
	virtual void DrawProgressIndicator(vector, vector, float, VGUIDrawState_t);
	/** Draws generic text onto a widget. */
	virtual void DrawText(vector, string, vector, font_s);
	/** Draw a window body. */
	virtual void DrawWindow(vector, vector, VGUIDrawState_t);

private:
	vguiColor m_controlBackgroundColor;
	vguiColor m_windowBackgroundColor;
	vguiColor m_textBackgroundColor;
	vguiColor m_textColor;
	vguiColor m_windowBorderColor;
	vguiColor m_hilightColor;
	vguiColor m_shadowColor;
};

void
vguiTheme::vguiTheme(void)
{
	m_controlBackgroundColor = spawn(vguiColor);
	m_controlBackgroundColor. SetColorWithAlpha(UI_MAINCOLOR, 0.0f);

	m_windowBackgroundColor = spawn(vguiColor);
	m_windowBackgroundColor.SetColorWithAlpha(UI_MAINCOLOR, UI_MAINALPHA);

	m_textBackgroundColor = spawn(vguiColor);
	m_textBackgroundColor.SetColor(UI_MAINCOLOR);

	m_textColor = spawn(vguiColor);
	m_textColor.SetColor(UI_FGCOLOR);

	m_windowBorderColor = spawn(vguiColor);
	m_windowBorderColor.SetColor(UI_BORDERCOLOR);

	m_hilightColor = spawn(vguiColor);
	m_hilightColor.SetColorWithAlpha(UI_HICOLOR, 0.5f);

	m_shadowColor = spawn(vguiColor);
	m_shadowColor.SetColorWithAlpha(UI_LOCOLOR, 0.5f);
}

void
vguiTheme::DrawBorder(vector atPos, vector withSize, VGUIBorderStyle_t borderStyle, vguiColor color)
{
	switch (borderStyle) {
	case VGUI_BORDER_INSET:
		drawfill(atPos + [1, 1], withSize + [-2, -2], [0,0,0], 0.25f);
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
		drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
		break;
	case VGUI_BORDER_OUTSET:
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), 0.5f);
		drawfill(atPos, [withSize[0], 1], m_hilightColor.GetColor(), 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), 0.5f);
		break;
	case VGUI_BORDER_LINE:
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], color.GetColor(), color.GetAlpha());
		drawfill(atPos, [withSize[0], 1], color.GetColor(), color.GetAlpha());
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], color.GetColor(), color.GetAlpha());
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], color.GetColor(), color.GetAlpha());
		break;
	default:
	case VGUI_BORDER_NONE:
		break;
	}
}

void
vguiTheme::DrawControlBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	if (drawStyle == VGUI_STATE_DISABLED) {
		drawfill(atPos, withSize, m_controlBackgroundColor.GetColor(), m_controlBackgroundColor.GetAlpha());
	} else {
		drawfill(atPos, withSize, m_controlBackgroundColor.GetColor(), m_controlBackgroundColor.GetAlpha());
	}
}

void
vguiTheme::DrawTextBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, withSize, m_textBackgroundColor.GetColor(), m_textBackgroundColor.GetAlpha());
}

void
vguiTheme::DrawWindowBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, withSize, m_windowBackgroundColor.GetColor(), m_windowBackgroundColor.GetAlpha());
}

void
vguiTheme::DrawButton(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawControlBackground(atPos, withSize, drawStyle);

	if (drawStyle == VGUI_STATE_DISABLED) {
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha() * 0.5f);
		drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha() * 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha() * 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha() * 0.5f);
	} else if (drawStyle == VGUI_STATE_ACTIVE) {
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
		drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
	} else {
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
		drawfill(atPos, [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
	}

	if (drawStyle == VGUI_STATE_HOVER) {
		drawfill(atPos, withSize, UI_HOVERCOLOR, UI_HOVERALPHA);
	}
}

void
vguiTheme::DrawScroller(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawControlBackground(atPos, withSize, drawStyle);
	drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
	drawfill(atPos, [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
	drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
	drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
}

void
vguiTheme::DrawScrollbar(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawTextBackground(atPos, withSize, drawStyle);
}

void
vguiTheme::DrawProgressIndicator(vector atPos, vector withSize, float progressValue, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
	drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
	drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
	drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_hilightColor.GetColor(), m_hilightColor.GetAlpha());
	drawfill(atPos + [1,1], [withSize[0] - 2, withSize[1]-2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());

	vector drawPos = [4,4];
	float max = floor(((withSize[0] - 8) * progressValue) / 12);

	for (float i = 0; i < max; i++ ) {
		drawfill(atPos + drawPos, [8, 16], UI_FILLCOLOR, 1.0f);
		drawPos[0] += 12;
	}
}

void
vguiTheme::DrawText(vector atPos, string withText, vector boundSize, font_s textFont)
{
	//drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
	//drawfill(atPos, boundSize, [1,1,1], 0.5f);
	Font_DrawText_RGB(atPos, withText, UI_FGCOLOR, textFont);
	//drawresetcliparea();
}

void
vguiTheme::DrawWindow(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	static void
	DRB(vector pos, vector size, vector rgb, float a)
	{
		drawpic(pos, "gfx/ui/m_topleft.tga", [16,16], rgb, a, 0);
		drawpic(pos + [size[0] - 16, 0], "gfx/ui/m_topright.tga", [16,16], rgb, a, 0);
		drawpic(pos + [0, size[1] - 16], "gfx/ui/m_bottomleft.tga", [16,16], rgb, a, 0);
		drawpic(pos + [size[0] - 16, size[1] - 16], "gfx/ui/m_bottomright.tga", [16,16], rgb, a, 0);

		if (size_x > 32) {
			drawpic(pos + [16, 0], "gfx/ui/m_top.tga", [size[0] - 32, 16], rgb, a, 0);
			drawpic(pos + [16, size[1] - 16], "gfx/ui/m_bottom.tga", [size[0] - 32, 16], rgb, a, 0);
		}

		if (size_y > 32) {
			drawpic(pos + [0, 16], "gfx/ui/m_left.tga", [16, size[1] - 32], rgb, a, 0);
			drawpic(pos + [size[0] - 16, 16], "gfx/ui/m_right.tga", [16, size[1] - 32], rgb, a, 0);
			drawpic(pos + [16, 16], "gfx/ui/m_mid.tga", [size[0] - 32, size[1] - 32], rgb, a, 0);
		}
	}

	static void
	DRB2(vector pos, vector size, vector rgb, float a)
	{
		drawpic(pos, "gfx/ui/m_linetopleft.tga", [16,16], rgb, a, 0);
		drawpic(pos + [size[0] - 16, 0], "gfx/ui/m_linetopright.tga", [16,16], rgb, a, 0);
		drawpic(pos + [0, size[1] - 16], "gfx/ui/m_linebottomleft.tga", [16,16], rgb, a, 0);
		drawpic(pos + [size[0] - 16, size[1] - 16], "gfx/ui/m_linebottomright.tga", [16,16], rgb, a, 0);

		if (size_x > 32) {
			drawpic(pos + [16, 0], "gfx/ui/m_linetop.tga", [size[0] - 32, 16], rgb, a, 0);
			drawpic(pos + [16, size[1] - 16], "gfx/ui/m_linebottom.tga", [size[0] - 32, 16], rgb, a, 0);
		}

		if (size_y > 32) {
			drawpic(pos + [0, 16], "gfx/ui/m_lineleft.tga", [16, size[1] - 32], rgb, a, 0);
			drawpic(pos + [size[0] - 16, 16], "gfx/ui/m_lineright.tga", [16, size[1] - 32], rgb, a, 0);
			drawpic(pos + [16, 16], "gfx/ui/m_linemid.tga", [size[0] - 32, size[1] - 32], rgb, a, 0);
		}
	}

	if (UI_ROUNDED == true) {
		DRB(atPos, withSize, m_windowBackgroundColor.GetColor(), m_windowBackgroundColor.GetAlpha());

		if (UI_BORDERALPHA > 0.0f) {
			DRB2(atPos, withSize, m_windowBorderColor.GetColor(), m_windowBorderColor.GetAlpha());
		}
	} else {
		DrawWindowBackground(atPos, withSize, drawStyle);
		DrawBorder(atPos, withSize, VGUI_BORDER_OUTSET, m_windowBorderColor);
	}
}

void
vguiTheme::DrawWindowTitle(vector atPos, vector withSize, string titleText, string withIcon, font_s textFont, VGUIDrawState_t drawStyle)
{
	if (STRING_SET(titleText)) {
		if (STRING_SET(withIcon) && UI_NOICONS == false) {
			DrawText(atPos + [26, 8], titleText, withSize, textFont);
			drawpic(atPos + [4, 4], withIcon, [16,16], [1,1,1], 1.0f, 0);
		} else {
			DrawText(atPos + [8, 8], titleText, withSize, textFont);
		}
	}
}
