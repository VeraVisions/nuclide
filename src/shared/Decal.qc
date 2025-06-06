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

var int autocvar_r_drawdecals = TRUE;
var int autocvar_sp_decals = 128;
var int autocvar_mp_decals = 128;
var int autocvar_cl_decals = 128;

enumflags
{
	DECALFL_ORIGIN,
	DECALFL_ANGLE,
	DECALFL_MATERIAL
};

#ifdef CLIENT
const string g_decal_shader = \
	"{\n" \
		"polygonOffset\n" \
		"{\n" \
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc blend\n" \
		"}\n" \
	"}";
#endif

#ifdef SERVER
float
ncDecal::SendEntity(entity ePEnt, float changedflags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	if (!m_strTexture)
		return (0);

	WriteByte(MSG_ENTITY, ENT_DECAL);
	WriteByte(MSG_ENTITY, changedflags);

	if (changedflags & DECALFL_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (changedflags & DECALFL_ANGLE) {
		WriteCoord(MSG_ENTITY, angles[0]);
		WriteCoord(MSG_ENTITY, angles[1]);
		WriteCoord(MSG_ENTITY, angles[2]);
	}

	if (changedflags & DECALFL_MATERIAL)
		WriteString(MSG_ENTITY, m_strTexture);

	return (1);
}
#else
void
ncDecal::ReceiveEntity(void)
{
	float changedflags = readbyte();

	if (changedflags & DECALFL_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	}

	if (changedflags & DECALFL_ANGLE) {
		angles[0] = readcoord();
		angles[1] = readcoord();
		angles[2] = readcoord();
	}

	if (changedflags & DECALFL_MATERIAL)
		m_strTexture = readstring();

	size = drawgetimagesize(m_strTexture);

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		BuildShader();
	} else {
		m_strShader = m_strTexture;
	}

	makevectors(angles);
	float surf = getsurfacenearpoint(world, origin);
	vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
	vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
	mins = v_up / size[0];
	maxs = t_dir / size[1];
	color = getlight(origin) / 255;
	drawmask = MASK_ENGINE;
}

float
ncDecal::predraw(void)
{
	vector vecPlayer;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	ncDecal dcl = (ncDecal)self;
	if (!autocvar_r_drawdecals) {
		return (PREDRAW_NEXT);
	}

	/* skip empty decals */
	if (!dcl.m_strShader)
		return (PREDRAW_NEXT);

	/* don't draw us, unnecessary */
	if (checkpvs(vecPlayer, this) == FALSE) {
		return (PREDRAW_NEXT);
	}

	adddecal(dcl.m_strShader, dcl.origin, dcl.mins, dcl.maxs, dcl.color, 1.0f);
	addentity(dcl);
	return (PREDRAW_NEXT);
}

void
ncDecal::BuildShader(void)
{
	/* skip empty decals */
	if (!m_strTexture || !m_strTexture)
		return;

	m_strShader = Decal_Precache(m_strTexture);
}
#endif

/* this is like Decal_Parse, but better */
void
ncDecal::PlaceAtScale(vector org, string dname, float sizeScale)
{
	if (!dname)
		return;

	decal_pickwall(this, org);

	/* we never hit any wall. */
	if (g_tracedDecal.fraction == 1.0f) {
		ncWarning("Placing of decal %S failed at %v", dname, org);

		if (classname != "tempdecal")
			remove(this);
		return;
	}

	origin = g_tracedDecal.endpos;
	setorigin(this, origin);

	/* FIXME: more universal check? */
	if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, g_tracedDecal.endpos)) == "sky") {
		return;
	}

	makevectors(vectoangles(g_tracedDecal.endpos - origin));
	vector cpl = v_forward - (v_forward * g_tracedDecal.normal) * g_tracedDecal.normal;

	if (g_tracedDecal.normal[2] == 0) {
		cpl = [0, 0, 1];
	}

	angles = vectoangles(cpl, g_tracedDecal.normal);
	m_strTexture = dname;

#ifdef SERVER
	angles = vectoangles(cpl, g_tracedDecal.normal);
	solid = SOLID_NOT;
	pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
	SendFlags = 1;
#else
	size = drawgetimagesize(m_strTexture) * sizeScale;

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		BuildShader();
	} else {
		m_strShader = m_strTexture;
	}

	makevectors(angles);
	float surf = getsurfacenearpoint(world, origin);
// 	vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
	vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
	mins = v_up / size[0];
	maxs = t_dir / size[1];
	color = getlight(origin) / 255;
	drawmask = MASK_ENGINE;
#endif
}

/* this is like Decal_Parse, but better */
void
ncDecal::Place(vector org, string dname)
{
	PlaceAtScale(org, dname, 1.0f);
}

ncDecal g_decals;
void Decals_Init(void)
{
	int max;

#ifdef SERVER
	max = cvar("sv_playerslots") == 1 ? autocvar_sp_decals : autocvar_mp_decals;
#else
	max = autocvar_cl_decals;
#endif

	/* let's not glitch this up */
	if (max <= 0) {
		max = 5;
	}

	ncDecal nextdecal = spawn(ncDecal);
	g_decals = nextdecal;
	for (int i = 0; i <= max; i++) {
		nextdecal.classname = "tempdecal";
		nextdecal.owner = spawn(ncDecal);

		if (i == max) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = (ncDecal)nextdecal.owner;
		}
	}
}

ncDecal Decals_Next(vector pos)
{
	ncDecal ret = g_decals;
	g_decals = (ncDecal)g_decals.owner;

	/* Check for a tempdecal within a radius of 8 units and overwrite that one
	 * instead */
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		if (vlen(b.origin - pos) < 4) {
			return b;
		}
	}

	return ret;
}

/* Generalized Decal Placing Function */
void Decals_Place(vector pos, string dname)
{
	float bsp_version = serverkeyfloat("*bspversion");

	switch (bsp_version) {
		case BSPVER_HL:
		case BSPVER_RBSP:
		case BSPVER_Q3:
		case BSPVER_RTCW:
			break;
		default:
			return;
	}

	ncDecal x = Decals_Next(pos);
	x.Place(pos, dname);
}

#ifdef CLIENT
string
Decal_Precache(string decalTex)
{
	string shaderName = sprintf("decal_%s", decalTex);
	string shaderBuff = sprintf(g_decal_shader, decalTex);
	precache_pic(decalTex); /* precache */
	shaderforname(shaderName, shaderBuff);
	return shaderName;
}

void
Decal_Reload(void)
{
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		ncDecal d = (ncDecal)b;
		d.BuildShader();
	}
	for (entity b = world; (b = find(b, ::classname, "decal"));) {
		ncDecal d = (ncDecal)b;
		d.BuildShader();
	}
}

void
Decal_Parse(void)
{
	ncDecal new;

	/* convert us to an object of type decal */
	spawnfunc_ncDecal();
	new = (ncDecal)self;
	new.ReceiveEntity();
}

void
Decal_Shutdown(void)
{
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		remove(b);
	}
	for (entity b = world; (b = find(b, ::classname, "decal"));) {
		remove(b);
	}
}
#endif

void
ncDecal::ncDecal(void)
{
	m_strShader = __NULL__;
	m_strTexture = __NULL__;
	setsize(this, [0,0,0], [0,0,0]);
}
