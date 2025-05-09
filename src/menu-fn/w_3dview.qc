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

noref .float colormap;
noref .float frame, frame2, lerpfrac, renderflags, frame1time;
noref .vector angles;
noref .vector colormod;

enumflags
{
	VIEW_VISIBLE
};

class CUI3DView:CWidget
{
	vector m_vecSize;
	vector m_vec3DPos;
	vector m_vec3DAngles;
	float m_flFOV;

	void(void) CUI3DView;
	virtual void(void) m_vDrawFunc = 0;
	virtual void(float, float, float, float) m_vInputFunc = 0;
	virtual void(void) Draw;
	virtual vector() GetSize;
	virtual vector() Get3DPos;
	virtual vector() Get3DAngles;
	virtual void(vector) SetSize;
	virtual void(vector) Set3DPos;
	virtual void(vector) Set3DAngles;
	virtual void(void(void)) SetDrawFunc;
	virtual void(void(float, float, float, float)) SetInputFunc;
	virtual void(float, float, float, float) Input;
};

void
CUI3DView::CUI3DView(void)
{
	m_flFOV = 90;
	m_vecSize = [64,64];
	m_vec3DPos = m_vec3DAngles = [0,0,0];
}

void
CUI3DView::SetSize(vector vecSize)
{
	m_vecSize = vecSize;
}

vector
CUI3DView::GetSize(void)
{
	return m_vecSize;
}

void
CUI3DView::Set3DAngles(vector vecAngles)
{
	m_vec3DAngles = vecAngles;
}

vector
CUI3DView::Get3DAngles(void)
{
	return m_vec3DAngles;
}

void
CUI3DView::Set3DPos(vector vecPos)
{
	m_vec3DPos = vecPos;
}

vector
CUI3DView::Get3DPos(void)
{
	return m_vec3DPos;
}

void
CUI3DView::SetDrawFunc(void(void) vFunc)
{
	m_vDrawFunc = vFunc;
}

void
CUI3DView::SetInputFunc(void(float, float, float, float) vFunc)
{
	m_vInputFunc = vFunc;
}

void
CUI3DView::Draw(void)
{
	if (!m_vDrawFunc) {
		return;
	}

	clearscene();
	setproperty(VF_VIEWPORT, [m_x + g_menuofs[0],m_y + g_menuofs[1]], m_vecSize);
	setproperty(VF_AFOV, 90.0f);
	setproperty(VF_ORIGIN, m_vec3DPos);
	setproperty(VF_ANGLES, m_vec3DAngles);

	if (m_vDrawFunc) {
		m_vDrawFunc();
		renderscene();
	}
}

void
CUI3DView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (!m_vInputFunc) {
		return;
	}

	m_vInputFunc(flEVType, flKey, flChar, flDevID);
}

/* 3D helper functions */


// menuqc doesn't have access to makevectors... screw you, guys
noref vector v_forward;
noref vector v_up;
noref vector v_right;