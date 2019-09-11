/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

var int autocvar_cl_decals = TRUE;

#include "decals.h"

#define DECALS_MAX 30

#ifdef SSQC
entity g_decals;
void Decals_Init(void)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
	entity nextdecal = spawn();
	g_decals = nextdecal;
	for (int i = 0; i <= DECALS_MAX; i++) {
		nextdecal.classname = "tempdecal";
		nextdecal.owner = spawn();
		
		if (i == DECALS_MAX) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = nextdecal.owner;
		}
	}
}

entity Decals_Next(vector pos)
{
	entity ret = g_decals;
	g_decals = g_decals.owner;

	/* Check for a tempdecal within a radius of 8 units and overwrite that one
	 * instead */
	for (entity b = world; (b = find(b, ::classname, "tempdecal"));) {
		if (vlen(b.origin - pos) < 8) {
			return b;
		}
	}

	return ret;
}
#endif

void Decals_PlaceSmall(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{shot%d", floor(random(1,6)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceBig(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{bigshot%d", floor(random(1,6)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceGlass(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{break%d", floor(random(1,4)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceScorch(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{scorch%d", floor(random(1,4)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceDent(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = sprintf("{dent%d", floor(random(1,7)));
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

void Decals_PlaceGauss(vector pos)
{
	if (serverkeyfloat("*bspversion") != 30) {
		return;
	}
#ifdef CSQC
	// TODO
#else
	entity decal = Decals_Next(pos);
	setorigin(decal, pos);
	decal.texture = "{gaussshot1";
	decal.think = infodecal;
	decal.nextthink = time /*+ 0.1f*/;
#endif
}

#ifdef CSQC

class decal
{
	string m_strShader;
	string m_strTexture;
};

const string g_decal_shader = \
	"{\n" \
		"polygonOffset\n" \
		"{\n" \
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc GL_ZERO GL_SRC_COLOR\n" \
		"}\n" \
	"}";

const string g_decal_shader_add = \
	"{\n" \
		"polygonOffset\n" \
		"{\n" \
			"clampmap %s\n" \
			"rgbgen vertex\n" \
			"blendfunc add\n" \
		"}\n" \
	"}";

float Decal_PreDraw(void)
{
	decal dcl = (decal)self;
	if (!autocvar_cl_decals) {
		return PREDRAW_NEXT;
	}

	adddecal(dcl.m_strShader, dcl.origin, dcl.mins, dcl.maxs, dcl.color, 1.0f);
	addentity(dcl);
	return PREDRAW_NEXT;
}

void Decal_MakeShader(decal target)
{
	string shader_buff;
	target.m_strShader = sprintf("decal_%s", target.m_strTexture);

	if (target.style & DFLAG_INVERT) {
		int i;
		int *buff;
		vector res;
		int w, h;

		res = drawgetimagesize(target.m_strTexture);
		w = (int)res[0];
		h = (int)res[1];
		buff = r_readimage(target.m_strTexture, w, h);

		/* we can only upload this under a new name */
		target.m_strTexture = sprintf("%s_inv", target.m_strTexture);

		if (buff != __NULL__) {
			for (i = 0; i < ( w * h ); i++) {
				//buff[i] = ~buff[i];
			}
			
			r_uploadimage(target.m_strTexture, w, h, (void*)buff);
			memfree(buff);
		}
	}

	if (target.style & DFLAG_ADDITIVE) {
		shader_buff = sprintf(g_decal_shader_add, target.m_strTexture);
	} else {
		shader_buff = sprintf(g_decal_shader, target.m_strTexture);
	}
	shaderforname(target.m_strShader, shader_buff);
}

void Decal_Reload(void)
{
	for (entity b = world; (b = find(b, ::classname, "decal"));) {
		Decal_MakeShader((decal)b);
	}
}

void Decal_Parse(void)
{
	decal new;

	/* convert us to an object of type decal */
	spawnfunc_decal();
	new = (decal)self;

	new.origin[0] = readcoord();
	new.origin[1] = readcoord();
	new.origin[2] = readcoord();

	new.angles[0] = readcoord();
	new.angles[1] = readcoord();
	new.angles[2] = readcoord();
	new.m_strTexture = readstring();

	new.color = [1,1,1];

	for (int i = 0; i < g_decalwad.length; i++) {
		if (new.m_strTexture == g_decalwad[i].name) {
			new.color[0] = (g_decalwad[i].color[0] / 255);
			new.color[1] = (g_decalwad[i].color[1] / 255);
			new.color[2] = (g_decalwad[i].color[2] / 255);
			new.style = g_decalwad[i].flags;
			break;
		}
	}

	new.size = drawgetimagesize(new.m_strTexture);

	if (serverkeyfloat("*bspversion") == 30) {
		Decal_MakeShader(new);
	}

	makevectors(new.angles);
	float surf = getsurfacenearpoint(world, new.origin);
	vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
	vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
	new.mins = v_up / new.size[0];
	new.maxs = t_dir / new.size[1];

	new.predraw = Decal_PreDraw;
	new.drawmask = MASK_ENGINE;
}
#endif
