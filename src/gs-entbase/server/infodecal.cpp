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

/*QUAKED infodecal (1 0 0) (-8 -8 -8) (8 8 8)
"texture"    Name of the texture inside decals.wad it projects onto a surface.

This entity only works on BSP version 30 levels.
Projects a decals.wad texture onto the nearest surface.
It'll automatically figure out the surface based on distance.
The texture will be aligned along the surface texture normals.
*/

/* We need to save trace infos temporarily in order to figure out what to
 * project the decal against. Half-Life's infodecal entity only stores origin,
 * but not angles. So we have to figure them out ourselves. */
.string texture;

float infodecal_send(entity pvsent, float cflags)
{
	WriteByte(MSG_ENTITY, ENT_DECAL);
	WriteCoord(MSG_ENTITY, self.origin[0]);
	WriteCoord(MSG_ENTITY, self.origin[1]);
	WriteCoord(MSG_ENTITY, self.origin[2]);
	WriteCoord(MSG_ENTITY, self.angles[0]);
	WriteCoord(MSG_ENTITY, self.angles[1]);
	WriteCoord(MSG_ENTITY, self.angles[2]);
	WriteString(MSG_ENTITY, self.texture);
	return TRUE;
}

void infodecal(void)
{
#ifdef WASTES
	remove(self);
	return;
#endif
	
	if (serverkeyfloat("*bspversion") != 30) {
#if 1
		remove(self);
		return;
#else
		/* Source Engine Material support */
		self.texture = sprintf( "materials/%s", self.texture );
#endif
	}

	if (!self.texture) {
		dprint("^1ERROR:^7 infodecal with no .texture\n");		
		/* Tempdecals == decals that are not spawned by the map, but by the
		 * decal-que (see shared/decals.c), so you can't remove them without
		 * causing a pointer error - just abort. */
		if (self.classname != "tempdecal") {
			remove(self);
		}
		return;
	}
	
	/* Some maps have everything set to full-on uppercase */
	self.texture = strtolower(self.texture);
	decal_pickwall(self, self.origin);

	if (g_tracedDecal.fraction == 1.0f) {
		dprint(sprintf("infodecal tracing failed at %v\n", self.origin));

		if (self.classname != "tempdecal") {
			remove(self);
		}
		return;
	}

	self.origin = g_tracedDecal.endpos;

	/* FIXME: more universal check? */
	if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, g_tracedDecal.endpos)) == "sky") {
		return;
	}

	makevectors(vectoangles(g_tracedDecal.endpos - self.origin ));
	vector cpl = v_forward - (v_forward * g_tracedDecal.normal) * g_tracedDecal.normal;

	if (g_tracedDecal.normal[2] == 0) {
		cpl = [0, 0, 1];
	}

	self.angles = vectoangles(cpl, g_tracedDecal.normal);
	self.solid = SOLID_NOT;
	self.pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
	self.SendEntity = infodecal_send;
	self.SendFlags = 1;
}
