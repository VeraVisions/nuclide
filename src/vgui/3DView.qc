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

noref .vector origin;
noref .vector angles;
noref .vector mins;
noref .vector maxs;
noref .string model;
noref .float frame, frame2, lerpfrac, renderflags, frame1time;

.void(void) tmpvgui3DView1;
.float(float,float,float,float) tmpvgui3DView2;

/** VGUI Widget: 3D View

@ingroup vgui
*/
class vgui3DView:vguiWidget
{
public:
	void vgui3DView(void);

	/** Return the 3D-space position our camera within the 3D view is located at. */
	nonvirtual vector Get3DPos(void);
	/** Return the angle that the camera within the 3D view is aiming at. */
	nonvirtual vector Get3DAngles(void);
	/** Sets the position of the camera within the 3D-space. */
	nonvirtual void Set3DPos(vector);
	/** Sets the angle of the camera within the 3D-space. */
	nonvirtual void Set3DAngles(vector);
	/** Sets the function to call in order to draw the scene. */
	nonvirtual void SetDrawFunc(void(void));
	/** Sets the function to call for when input events happen within the 3D view. */
	nonvirtual void SetInputFunc(float(float, float, float, float));

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vec3DPos;
	vector m_vec3DAngles;
	float m_flFOV;
};

void
vgui3DView::vgui3DView(void)
{
	m_flFOV = 90;
	m_vec3DPos = m_vec3DAngles = [0,0,0];
}

void
vgui3DView::Spawned(void)
{
	SetSize([64,64]);
}

void
vgui3DView::Set3DAngles(vector vecAngles)
{
	m_vec3DAngles = vecAngles;
}

vector
vgui3DView::Get3DAngles(void)
{
	return m_vec3DAngles;
}

void
vgui3DView::Set3DPos(vector vecPos)
{
	m_vec3DPos = vecPos;
}

vector
vgui3DView::Get3DPos(void)
{
	return m_vec3DPos;
}

void
vgui3DView::SetDrawFunc(void(void) vFunc)
{
	tmpvgui3DView1 = vFunc;
}

void
vgui3DView::SetInputFunc(float(float, float, float, float) vFunc)
{
	tmpvgui3DView2 = vFunc;
}

void
vgui3DView::Draw(void)
{
	if (!tmpvgui3DView1) {
		return;
	}

	clearscene();
	setproperty(VF_VIEWPORT, m_vecOrigin + m_parent.m_vecOrigin, m_vecSize);
	setproperty(VF_AFOV, 90);
	setproperty(VF_ORIGIN, m_vec3DPos);
	setproperty(VF_ANGLES, m_vec3DAngles);
#ifndef MENU
	setproperty(VF_DRAWWORLD, false);
#endif
	tmpvgui3DView1();
	renderscene();
}

bool
vgui3DView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (!tmpvgui3DView2) {
		return false;
	}

	return tmpvgui3DView2(flEVType, flKey, flChar, flDevID);
}
