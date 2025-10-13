/*
 * Copyright (c) 2025 Vera Visions LLC
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

env_cascade_light g_sun;

class
ncSunEdit:vguiWindow
{
public:
	void ncSunEdit(void);

	virtual void Spawned(void);
	virtual void Reposition(void);

private:

	vguiScrollBar m_redColorSlider;
	vguiScrollBar m_greenColorSlider;
	vguiScrollBar m_blueColorSlider;

	vguiScrollBar m_pitchSlider;
	vguiScrollBar m_yawSlider;
	vguiScrollBar m_rollSlider;

	vguiScrollBar m_distanceSlider;
};

void
ncSunEdit::ncSunEdit(void)
{

}

void
ncSunEdit::RedColorChanged(void)
{
	float normalizedRedValue = (float)m_redColorSlider.GetValue();
	g_sun.SetRedColor(normalizedRedValue);
}

void
ncSunEdit::GreenColorChanged(void)
{
	float normalizedGreenValue = (float)m_greenColorSlider.GetValue();
	g_sun.SetGreenColor(normalizedGreenValue);
}

void
ncSunEdit::BlueColorChanged(void)
{
	float normalizedBlueValue = (float)m_blueColorSlider.GetValue();
	g_sun.SetBlueColor(normalizedBlueValue);
}

void
ncSunEdit::PitchChanged(void)
{
	g_sun.SetPitch((float)m_pitchSlider.GetValue() - 180.0f);
}

void
ncSunEdit::YawChanged(void)
{
	g_sun.SetYaw((float)m_yawSlider.GetValue() - 180.0f);
}

void
ncSunEdit::RollChanged(void)
{
	g_sun.SetRoll((float)m_rollSlider.GetValue() - 180.0f);
}

void
ncSunEdit::DistanceChanged(void)
{
	g_sun.SetShadowDistance((float)m_distanceSlider.GetValue());
}


void
ncSunEdit::Spawned(void)
{
	super::Spawned();


	SetTitle("Sun/Time Of Day Editor");
	SetIcon("gfx/icon16/weather");

	m_redColorSlider = spawn(vguiScrollBar);
	m_redColorSlider.CallOnChangeWithDelegate(RedColorChanged, this);
	m_redColorSlider.SetStep(1);
	m_redColorSlider.SetMin(1);
	m_redColorSlider.SetMax(255);
	m_redColorSlider.SetLength(255);

	m_greenColorSlider = spawn(vguiScrollBar);
	m_greenColorSlider.CallOnChangeWithDelegate(GreenColorChanged, this);
	m_greenColorSlider.SetStep(1);
	m_greenColorSlider.SetMin(1);
	m_greenColorSlider.SetMax(255);
	m_greenColorSlider.SetLength(255);

	m_blueColorSlider = spawn(vguiScrollBar);
	m_blueColorSlider.CallOnChangeWithDelegate(BlueColorChanged, this);
	m_blueColorSlider.SetStep(1);
	m_blueColorSlider.SetMin(1);
	m_blueColorSlider.SetMax(255);
	m_blueColorSlider.SetLength(255);

	m_pitchSlider = spawn(vguiScrollBar);
	m_pitchSlider.CallOnChangeWithDelegate(PitchChanged, this);
	m_pitchSlider.SetStep(1);
	m_pitchSlider.SetMin(1);
	m_pitchSlider.SetMax(359);
	m_pitchSlider.SetLength(359);

	m_yawSlider = spawn(vguiScrollBar);
	m_yawSlider.CallOnChangeWithDelegate(YawChanged, this);
	m_yawSlider.SetStep(1);
	m_yawSlider.SetMin(1);
	m_yawSlider.SetMax(359);
	m_yawSlider.SetLength(359);

	m_rollSlider = spawn(vguiScrollBar);
	m_rollSlider.CallOnChangeWithDelegate(RollChanged, this);
	m_rollSlider.SetStep(1);
	m_rollSlider.SetMin(1);
	m_rollSlider.SetMax(359);
	m_rollSlider.SetLength(359);

	m_distanceSlider = spawn(vguiScrollBar);
	m_distanceSlider.CallOnChangeWithDelegate(DistanceChanged, this);
	m_distanceSlider.SetMin(0);
	m_distanceSlider.SetMax(4096);
	m_distanceSlider.SetLength(359);

	Add(m_redColorSlider);
	Add(m_greenColorSlider);
	Add(m_blueColorSlider);

	Add(m_pitchSlider);
	Add(m_yawSlider);
	Add(m_rollSlider);

	Add(m_distanceSlider);

	Reposition();
}

void
ncSunEdit::Reposition(void)
{
	m_redColorSlider.SetPos([2,16]);
	m_greenColorSlider.SetPos(m_redColorSlider.GetPos() + [32 + 2, 0]);
	m_blueColorSlider.SetPos(m_greenColorSlider.GetPos() + [32 + 2, 0]);

	m_pitchSlider.SetPos(m_blueColorSlider.GetPos() + [32 + 18, 0]);
	m_yawSlider.SetPos(m_pitchSlider.GetPos() + [32 + 2, 0]);
	m_rollSlider.SetPos(m_yawSlider.GetPos() + [32 + 2, 0]);

	m_distanceSlider.SetPos(m_rollSlider.GetPos() + [32 + 18, 0]);
}

/* Called by `showSunEditor` command */
void
VGUI_ShowSunEditor(void)
{
	static bool initialized;
	static ncSunEdit winEditor;

	if (!initialized) {
		initialized = true;
		g_sun = spawn(env_cascade_light);
		g_sun.SetOrigin([0,0,2048]);
		g_sun.ReloadVideoResources();

		winEditor = spawn(ncSunEdit);
		winEditor.SetSize([320,320]);
		g_uiDesktop.Add(winEditor);
		
	}

	winEditor.Show();
}
