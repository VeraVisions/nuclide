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

/*QUAKED NSInteractiveSurface (1 0 0) (-8 -8 -8) (8 8 8)
Fully interactive surface

-------- KEYS --------
"angles" : Sets the pitch, yaw and roll angles of the surface.
"ui_class" : Which UI class to use
"ui_res" : Resolution of the interface
"ui_size" : Size of the interface in world coordinates

-------- SPAWNFLAGS --------
None yet

-------- NOTES --------
Similar to surfaces in Doom III and Duke 4

-------- TRIVIA --------
This entity was introduced in Nuclide (2022).
*/

#ifdef CLIENT
/** This entity class represents fully interactive surfaces.

Place one around a map and you can render any UI class of your choosing.
*/
class
NSInteractiveSurface:NSEntity
{
private:
	CUIWidget m_UIChain;
	string m_strSurfaceMat;
	bool m_bInFocus;
	float m_flSurfaceMat;
	vector m_vecCursorPos;
	bool m_bCached;
	float m_flScale;
	string m_strUIClass;
	vector m_vecUIRes;
	vector m_vecWorldSize;
	float m_flUseDistance;

public:
	void NSInteractiveSurface(void);

	virtual float predraw(void);
	virtual void postdraw(void);
	
	virtual bool Input(float,float,float,float);
	virtual void Spawned(void);
	virtual void SpawnKey(string,string);
	virtual void RenderScene(void);
	
	virtual bool FocusCheck(vector,vector);
	
	virtual void RendererRestarted(void);
	virtual bool CanSpawn(bool);

};

bool
NSInteractiveSurface::CanSpawn(bool clientSide)
{
	return true;
}

bool
NSInteractiveSurface::FocusCheck(vector vecViewPos, vector vecViewAng)
{
	vector vecPlayerForward;
	vector vecNormal, vecTangent, vecBitTangent;
	vector vecNear, vecFar, vecImpact;
	vector vecTestOrg;
	float fs, fe, f, s, t;

	/* are we within the use-distance of our UI even? */
	if (vlen(origin - vecViewPos) > m_flUseDistance) {
		/* cancel out early */
		m_bInFocus = false;
		return m_bInFocus;
	}

	/* get client forward vector */
	makevectors(vecViewAng);
	vecPlayerForward = v_forward;

	/* get surface normals etc. */
	makevectors(angles);
	vecNormal = v_forward;
	vecTangent = v_right;
	vecBitTangent = v_up;

	/* get our reference points, near being the corner */
	vecNear = vecViewPos - (origin - (vecTangent * (m_vecWorldSize[0]/2)) + vecBitTangent * (m_vecWorldSize[1]/2));
	vecFar = vecNear + vecPlayerForward * 512;

	/* calculate our impact, which in turns gives us surface/texture coordinates */
	fs = dotproduct(vecNear, vecNormal);
	fe = dotproduct(vecFar, vecNormal);
	f = fs / (fs - fe);
	vecImpact = vecNear + (vecFar - vecNear) * f;
	s = dotproduct(vecImpact, vecTangent);
	t = dotproduct(vecImpact, vecBitTangent);

	/* our aim-pos in world units */
	vecTestOrg = [s,-t,0];

	/* bounds check for our in-world aim-pos */
	if (vecTestOrg[0] >= 0 && vecTestOrg[0] <= m_vecWorldSize[0]) {
		if (vecTestOrg[1] >= 0 && vecTestOrg[1] <= m_vecWorldSize[1]) {
			m_bInFocus = true;

			/* cursors need to be scaled according to the UI */
			m_vecCursorPos = [s, -t, 0] / m_flScale;

			/* widgets query this instead of getmousepos() */
			g_vecMousePos = m_vecCursorPos;
			return true;
		}
	}

	m_bInFocus = false;
	return m_bInFocus;
}

void
NSInteractiveSurface::RendererRestarted(void)
{
	m_flSurfaceMat = shaderforname(m_strSurfaceMat, sprintf("{\nsurfaceParm nolightmap\n{\nmap $rt:%s\n}\n}", m_strSurfaceMat));
	m_bCached = true;
}

void
NSInteractiveSurface::postdraw(void)
{
	RenderScene();
}

float
NSInteractiveSurface::predraw(void)
{
	vector fsize = m_vecWorldSize / 2;

	if (m_bCached == false)
		return (PREDRAW_NEXT);

	makevectors(angles);
	R_BeginPolygon(m_strSurfaceMat, 0, 0);
	R_PolygonVertex(origin + v_right * fsize[0] - v_up * fsize[1],
		[1,1], [1,1,1], 1.0f);
	R_PolygonVertex(origin - v_right * fsize[0] - v_up * fsize[1],
		[0,1], [1,1,1], 1.0f);
	R_PolygonVertex(origin - v_right * fsize[0] + v_up * fsize[1],
		[0,0], [1,1,1], 1.0f);
	R_PolygonVertex(origin + v_right * fsize[0] + v_up * fsize[1],
		[1,0], [1,1,1], 1.0f);
	R_EndPolygon();

	addentity(this);
	return (PREDRAW_NEXT);
}

/* we just forward input events to our UI chain */
bool
NSInteractiveSurface::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (m_UIChain)
		m_UIChain.Input(flEVType, flKey, flChar, flDevID);

	return true;
}

/* called whenever we are in the proximity of a surface */
void
NSInteractiveSurface::RenderScene(void)
{
	if (m_bCached == false)
		return;

	clearscene();

	setviewprop(VF_RT_DESTCOLOUR, m_strSurfaceMat, (float)1, m_vecUIRes);
	setviewprop(VF_SIZE, m_vecUIRes);
	setviewprop(VF_DRAWENGINESBAR, (float)0);
	setviewprop(VF_ORIGIN, [0,0,0]);
	setviewprop(VF_ANGLES, [0,0,0]);
	setviewprop(VF_AFOV, 90.0f);

	drawfill([0,0], m_vecUIRes, [sin(cltime),sin(cltime*2),sin(cltime*0.5f)], 1.0f);

	/* draw the chain */
	if (m_UIChain)
		m_UIChain.Draw();

	/* render cursor */
	if (m_bInFocus)
		drawpic(m_vecCursorPos, "gfx/cursor", [32,32], [1,1,1], 1.0f);

	/* reset */
	setviewprop(VF_RT_DESTCOLOUR, "");
}

void
NSInteractiveSurface::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "ui_class":
		m_strUIClass = strValue;
		break;
	case "ui_res":
		m_vecUIRes = stov(strValue);
		break;
	case "ui_scale":
		m_flScale = stof(strValue);
		break;
	case "ui_dist":
		m_flUseDistance = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

/* once all spawn parms have been initialized */
void
NSInteractiveSurface::Spawned(void)
{
	CUIWidget child;

	super::Spawned();
	m_vecWorldSize = m_vecUIRes * m_flScale;

	RendererRestarted();

	/* initialize UI panel here */
	m_UIChain = spawn(CUIWidget);
	m_UIChain.m_iFlags = 1;

	child = UIClass_Spawn(m_strUIClass);

	if (m_UIChain)
		m_UIChain.Add(child);
	else
		error("Unable to allocate NSInteractiveSurface");
}

void
NSInteractiveSurface::NSInteractiveSurface(void)
{
	m_UIChain = __NULL__;
	m_strUIClass = "TestUI";
	m_vecUIRes = [320, 240];
	m_flScale = 0.25f;
	m_flUseDistance = 64;
	m_strSurfaceMat = sprintf("UISurface%d", num_for_edict(this));
	print(sprintf("Surface mat: %S\n", m_strSurfaceMat));
	drawmask = MASK_ENGINE;
	m_bCached = false;
	isCSQC = true;
}

/* test interface */
class
TestUI:CUIWindow
{
	CUIButton testbutton;

	void(void) TestUI;

	virtual void(void) TestTrigger;
	virtual void(void) Spawned;
};

void
TestUI::TestTrigger(void)
{
	sendevent("TriggerTarget", "s", "testtrigger");
}

void
TestUI::Spawned(void)
{
	super::Spawned();
	
	testbutton = spawn(CUIButton);
	testbutton.SetPos([32,48]);
	testbutton.SetTitle("Test Button!");
	testbutton.SetFunc(TestTrigger);
	Add(testbutton);
	testbutton.Show();
	SetSize([256,200]);
	SetTitle("Test Window Interface");
}

void
TestUI::TestUI(void)
{
}
#endif
