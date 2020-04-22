/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
decal::SendEntity(entity pvsent, float changedflags)
{
	WriteByte(MSG_ENTITY, ENT_DECAL);
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteCoord(MSG_ENTITY, angles[0]);
	WriteCoord(MSG_ENTITY, angles[1]);
	WriteCoord(MSG_ENTITY, angles[2]);
	WriteString(MSG_ENTITY, m_strTexture);
	return TRUE;
}
#else
void
decal::ReadEntity(void)
{
	origin[0] = readcoord();
	origin[1] = readcoord();
	origin[2] = readcoord();

	angles[0] = readcoord();
	angles[1] = readcoord();
	angles[2] = readcoord();
	m_strTexture = readstring();

	size = drawgetimagesize(m_strTexture);

	if (serverkeyfloat("*bspversion") == 30) {
		BuildShader();
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
decal::predraw(void)
{
	decal dcl = (decal)self;
	if (!autocvar_r_drawdecals) {
		return PREDRAW_NEXT;
	}

	/* don't draw us, unnecessary */
	/*if (checkpvs(getproperty(VF_ORIGIN), this) == FALSE) {
		return PREDRAW_NEXT;
	}*/

	adddecal(dcl.m_strShader, dcl.origin, dcl.mins, dcl.maxs, dcl.color, 1.0f);
	addentity(dcl);
	return PREDRAW_NEXT;
}

void
decal::BuildShader(void)
{
	string shader_buff;
	m_strShader = sprintf("decal_%s", m_strTexture);
	shader_buff = sprintf(g_decal_shader, m_strTexture);
	shaderforname(m_strShader, shader_buff);
}
#endif

/* this is like Decal_Parse, but better */
void
decal::Place(vector org, string dname)
{
	decal_pickwall(this, org);

	/* we never hit any wall. */
	if (g_tracedDecal.fraction == 1.0f) {
		print(sprintf("^1infodecal tracing failed at %v\n", org));
		if (classname != "tempdecal")
			remove(this);
		return;
	}

	origin = g_tracedDecal.endpos;

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
	size = drawgetimagesize(m_strTexture);

	if (serverkeyfloat("*bspversion") == 30) {
		BuildShader();
	}

	makevectors(angles);
	float surf = getsurfacenearpoint(world, origin);
	vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
	vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
	mins = v_up / size[0];
	maxs = t_dir / size[1];
	color = getlight(origin) / 255;
	drawmask = MASK_ENGINE;
#endif
}

decal g_decals;
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

	decal nextdecal = spawn(decal);
	g_decals = nextdecal;
	for (int i = 0; i <= max; i++) {
		nextdecal.classname = "tempdecal";
		nextdecal.owner = spawn(decal);

		if (i == max) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = (decal)nextdecal.owner;
		}
	}
}

decal Decals_Next(vector pos)
{
	decal ret = g_decals;
	g_decals = (decal)g_decals.owner;

	/* Check for a tempdecal within a radius of 8 units and overwrite that one
	 * instead */
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		if (vlen(b.origin - pos) < 2) {
			return b;
		}
	}

	return ret;
}

/* Generalized Decal Placing Function */
void Decals_Place(vector pos, string dname)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}

	decal x = Decals_Next(pos);
	x.Place(pos, dname);
}

#ifdef CLIENT
void Decal_Reload(void)
{
	for (entity b = world; (b = find(b, ::classname, "decal"));) {
		decal d = (decal)b;
		d.BuildShader();
	}
}

void Decal_Parse(void)
{
	decal new;

	/* convert us to an object of type decal */
	spawnfunc_decal();
	new = (decal)self;
	new.ReadEntity();
}
#endif
