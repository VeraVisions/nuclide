/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* We need to save trace infos temporarily in order to figure out what to
 * project the decal against. Half-Life's infodecal entity only stores origin,
 * but not angles. So we have to figure them out ourselves. */
.string texture;

typedef struct {
	float fraction;
	vector normal;
	vector endpos;
} traced_t;

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
	traced_t tmp[6];
	int i = 0;
	int b = 0;
	float frac = 1.0f;
	vector vpos = self.origin;
	
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
	
	/*self.origin[0] = rint(self.origin[0]);
	self.origin[1] = rint(self.origin[1]);
	self.origin[2] = rint(self.origin[2]);*/

	/* Unrolled because I'm lazy */
	makevectors([0, 0, 0]);
	traceline(vpos + (v_forward * -1), vpos + (v_forward * 128), 1, self);
	tmp[0].fraction = trace_fraction;
	tmp[0].normal = trace_plane_normal;
	tmp[0].endpos = trace_endpos;
	traceline(vpos + (v_forward * 1), vpos + (v_forward * -128), 1, self);
	tmp[1].fraction = trace_fraction;
	tmp[1].normal = trace_plane_normal;
	tmp[1].endpos = trace_endpos;
	traceline(vpos + (v_right * -1), vpos + (v_right * 128), 1, self);
	tmp[2].fraction = trace_fraction;
	tmp[2].normal = trace_plane_normal;
	tmp[2].endpos = trace_endpos;
	traceline(vpos + (v_right * 1), vpos + (v_right * -128), 1, self);
	tmp[3].fraction = trace_fraction;
	tmp[3].normal = trace_plane_normal;
	tmp[3].endpos = trace_endpos;
	traceline(vpos + (v_up * -1), vpos + (v_up * 128), 1, self);
	tmp[4].fraction = trace_fraction;
	tmp[4].normal = trace_plane_normal;
	tmp[4].endpos = trace_endpos;
	traceline(vpos + (v_up * 1), vpos + (v_up * -128), 1, self);
	tmp[5].fraction = trace_fraction;
	tmp[5].normal = trace_plane_normal;
	tmp[5].endpos = trace_endpos;

	for (i = 0; i < 6; i++) {
		if ( tmp[i].fraction < frac ) {
			frac = tmp[i].fraction;
			b = i;
		}
	}

	if (frac == 1.0f) {
		dprint(sprintf("infodecal tracing failed at %v\n", self.origin));

		if (self.classname != "tempdecal") {
			remove(self);
		}
		return;
	}

	makevectors(vectoangles(tmp[b].endpos - self.origin ));
	vector cpl = v_forward - (v_forward * tmp[b].normal) * tmp[b].normal;

	if (tmp[b].normal[2] == 0) {
		cpl = [0, 0, 1];
	}

	self.angles = vectoangles(cpl, tmp[b].normal);
	self.solid = SOLID_NOT;
	self.pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
	self.SendEntity = infodecal_send;
	self.SendFlags = 1;
}
