/* For VGUITheme, we want to allow everyone some basic overrides to handle most of the drawing
tasks. However, this is matter that will slowly expand to encompass more features.
If you plan on doing something really 'out there' that you can't do within this Theme framework,
I encourage you to just maintain your own objects with overridden draw functions for best
forward compatibility.

Why does this exist? Because the support for VGUI type elements needs variable appearances
and we can't rely on ifdefs to do the bulk of the work, that's why. The official inspiration
also referred to as TrackerUI has changed many times in appearance and we'd like to offer
means of handling any such styles.
*/

#ifdef CLASSIC_VGUI
	#ifndef UI_MAINCOLOR
		#define UI_MAINCOLOR [255,170,0] / 255
	#endif
	#ifndef UI_MAINALPHA
		#define UI_MAINALPHA 255
	#endif
#else
	var vector UI_MAINCOLOR;
	var float UI_MAINALPHA;
#endif

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

/** Style of the border to be drawn within the VGUITheme. */
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
VGUITheme
{
public:
	virtual void VGUITheme(void);

	/** Draw a border at the specified position, size and VGUIBorderStyle_t. */
	virtual void DrawBorder(vector, vector, VGUIBorderStyle_t, VGUIColor);
	/** Draw a control item background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawControlBackground(vector, vector, VGUIDrawState_t);
	/** Draw a text field background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawTextBackground(vector, vector, VGUIDrawState_t);
	/** Draw a window background at the specified position, size and VGUIDrawState_t. */
	virtual void DrawWindowBackground(vector, vector, VGUIDrawState_t);
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
	VGUIColor m_controlBackgroundColor;
	VGUIColor m_windowBackgroundColor;
	VGUIColor m_textBackgroundColor;
	VGUIColor m_textColor;
	VGUIColor m_windowBorderColor;
};

void
VGUITheme::VGUITheme(void)
{
	m_controlBackgroundColor = spawn(VGUIColor);
	//m_controlBackgroundColor.SetColor([0.298, 0.345, 0.267]);
	m_controlBackgroundColor.SetColor(UI_MAINCOLOR);
	m_windowBackgroundColor = spawn(VGUIColor);
	//m_windowBackgroundColor.SetColor([0.298, 0.345, 0.267]);
	m_windowBackgroundColor.SetColor(UI_MAINCOLOR);
	m_textBackgroundColor = spawn(VGUIColor);
	//m_textBackgroundColor.SetColor([0.243, 0.275, 0.216]);
	m_textBackgroundColor.SetColor(UI_MAINCOLOR);
	m_textColor = spawn(VGUIColor);
	//m_textColor.SetColor([0.847, 0.871, 0.827]);
	m_textColor.SetColor(UI_MAINCOLOR);
	m_windowBorderColor = spawn(VGUIColor);
	//m_windowBorderColor.SetColor([0.533, 0.569, 0.502]);
	m_windowBorderColor.SetColor(UI_MAINCOLOR);
}

void
VGUITheme::DrawBorder(vector atPos, vector withSize, VGUIBorderStyle_t borderStyle, VGUIColor color)
{
	switch (borderStyle) {
	case VGUI_BORDER_INSET:
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [1,1,1], 0.5f);
		drawfill(atPos, [withSize[0], 1], [0,0,0], 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
		break;
	case VGUI_BORDER_OUTSET:
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [0,0,0], 0.5f);
		drawfill(atPos, [withSize[0], 1], [1,1,1], 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
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
VGUITheme::DrawControlBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, withSize, m_controlBackgroundColor.GetColor(), m_controlBackgroundColor.GetAlpha());
}

void
VGUITheme::DrawTextBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, withSize, m_textBackgroundColor.GetColor(), m_textBackgroundColor.GetAlpha());
}

void
VGUITheme::DrawWindowBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	drawfill(atPos, withSize, m_windowBackgroundColor.GetColor(), m_windowBackgroundColor.GetAlpha());
}

void
VGUITheme::DrawButton(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawControlBackground(atPos, withSize, drawStyle);

	if (drawStyle == VGUI_STATE_ACTIVE) {
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [1,1,1], 0.5f);
		drawfill(atPos, [withSize[0], 1], [0,0,0], 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
	} else {
		drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [0,0,0], 0.5f);
		drawfill(atPos, [withSize[0], 1], [1,1,1], 0.5f);
		drawfill(atPos + [0, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
		drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
	}
}

void
VGUITheme::DrawScroller(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawControlBackground(atPos, withSize, drawStyle);
	drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [0,0,0], 0.5f);
	drawfill(atPos, [withSize[0], 1], [1,1,1], 0.5f);
	drawfill(atPos + [0, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
	drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
}

void
VGUITheme::DrawScrollbar(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawTextBackground(atPos, withSize, drawStyle);
}

void
VGUITheme::DrawProgressIndicator(vector atPos, vector withSize, float progressValue, VGUIDrawState_t drawStyle)
{
	float barLength = (withSize[0] - 4) * progressValue;
	DrawTextBackground(atPos, withSize, drawStyle);
	drawfill(atPos + [2, 2], [barLength, withSize[1] - 4], [1,1,1], 1.0f); 
}

void
VGUITheme::DrawText(vector atPos, string withText, vector boundSize, font_s textFont)
{
	//drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
	//drawfill(atPos, boundSize, [1,1,1], 0.5f);
	Font_DrawText(atPos, withText, textFont);
	//drawresetcliparea();
}

void
VGUITheme::DrawWindow(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
	DrawWindowBackground(atPos, withSize, drawStyle);
	DrawBorder(atPos, withSize, VGUI_BORDER_OUTSET, m_windowBorderColor);
}