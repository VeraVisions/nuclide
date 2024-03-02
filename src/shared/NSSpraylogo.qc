/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#ifdef CLIENT
void
NSSpraylogo::RendererRestarted(void)
{
	m_bInitialized = false;
}

float
NSSpraylogo::predraw(void)
{
	int iSize;

	/* TODO: Don't query this & width/height every frame */
	iSize = getplayerkeyblob(m_iOwnerID, "spray", __NULL__, 0);

	if (iSize <= 0) {
		return (PREDRAW_NEXT);
	}

	if (m_bInitialized == false) {
		void *image;
		m_bInitialized = true;

		/* load the blob */
		image = memalloc(iSize + 1);
		getplayerkeyblob(m_iOwnerID, "spray", image, iSize);
		r_uploadimage(m_m_strPath, 64, 64, image, iSize, 0);
		memfree(image);

		/* push the material into memory */
		if (m_bMonochrome == true)
			shaderforname(m_strName, sprintf(g_spray_mat_1, m_m_strPath));
		else
			shaderforname(m_strName, sprintf(g_spray_mat_0, m_m_strPath));
	} else {
		vector width;
		vector height;
		vector light;
		vector color;
		vector combined;
		color = stov(getplayerkeyvalue(m_iOwnerID, "spraycolor"));
		light = (getlight(m_vecPosition) / 255);

		/* unrolling this because the compiler spat out garbage */
		combined[0] = m_vecColor[0] * light[0];
		combined[1] = m_vecColor[1] * light[1];
		combined[2] = m_vecColor[2] * light[2];

		/* TODO: handle spray dimensions independently */
		makevectors(m_vecAngles);
		width = v_up / 64;
		height = v_forward / 64;
		adddecal(m_strName, m_vecPosition, width, height, combined, 1.0f);
	}
	return (PREDRAW_NEXT);
}

void
NSSpraylogo::NSSpraylogo(void)
{
	// boo
	m_vecColor = [1,1,1];
	m_bMonochrome = false;
	isCSQC = true;
	m_bInitialized = false;
}

void
Spray_Parse(void)
{
	spawnfunc_NSSpraylogo();
	NSSpraylogo spSelf =(NSSpraylogo)self;
	spSelf.drawmask = MASK_ENGINE;
	spSelf.m_vecPosition[0] = readcoord();
	spSelf.m_vecPosition[1] = readcoord();
	spSelf.m_vecPosition[2] = readcoord();
	spSelf.m_vecAngles[0] = readcoord();
	spSelf.m_vecAngles[1] = readcoord();
	spSelf.m_vecAngles[2] = readcoord();
	spSelf.m_iOwnerID = readentitynum() - 1;
	spSelf.m_bMonochrome = getplayerkeyfloat(spSelf.m_iOwnerID, "spraytype");
	spSelf.m_strName = sprintf("spray_%i_%d", spSelf.m_iOwnerID, spSelf.m_bMonochrome);
	spSelf.m_m_strPath = sprintf("simg_%i_%d", spSelf.m_iOwnerID, spSelf.m_bMonochrome);
	spSelf.m_vecColor = stov(getplayerkeyvalue(spSelf.m_iOwnerID, "spraycolor"));
}

#else

void
Spray_RemoveAll(entity entOwner)
{
	for (entity eFind = world;(eFind = find(eFind, classname, "Spray"));) {
		if (eFind.owner == entOwner) {
			remove(eFind);
		}
	}
}

float
Spray_SendEntity(entity ePEnt, float fChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_SPRAY);
	WriteCoord(MSG_ENTITY, self.origin[0]);
	WriteCoord(MSG_ENTITY, self.origin[1]);
	WriteCoord(MSG_ENTITY, self.origin[2]);
	WriteCoord(MSG_ENTITY, self.angles[0]);
	WriteCoord(MSG_ENTITY, self.angles[1]);
	WriteCoord(MSG_ENTITY, self.angles[2]);
	WriteEntity(MSG_ENTITY, self.owner);
	return (1);
}

void
CSEv_Spraylogo(void)
{
	entity spray;
	vector src;
	vector co;

	src = self.origin + self.view_ofs;

	makevectors(self.v_angle);
	traceline(src, src + v_forward * 128, FALSE, self);

	if (trace_fraction >= 1.0f) {
		return;
	}

	/* we only allow one active spray */
	Spray_RemoveAll(self);

	/* spawn the new one */
	spray = spawn(); 
	spray.classname = "Spray";
	spray.owner = self;
	spray.solid = SOLID_NOT;
	setorigin(spray, trace_endpos);

	/* calculate the rotation by taking our current view and mapping it
	 * against the surface we're looking at */
	makevectors([self.v_angle[0] * -1, self.v_angle[1], self.v_angle[2]]);
	co = v_forward -(v_forward * trace_plane_normal) * trace_plane_normal;

	/* quick fix */
	if (trace_plane_normal[2] == 0) {
		co = '0 0 1';
	}

	/* apply the angles and apply networking */
	spray.angles = vectoangles(co, trace_plane_normal);
	spray.SendEntity = Spray_SendEntity;
	spray.SendFlags = 1;

	Sound_Play(self, CHAN_VOICE, "SprayCan.Paint");
}
#endif
