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

#ifdef SSQC
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
Spray_SendEntity(entity ePVSEnt, float fChanged)
{
	WriteByte(MSG_ENTITY, ENT_SPRAY);
	WriteCoord(MSG_ENTITY, self.origin[0]);
	WriteCoord(MSG_ENTITY, self.origin[1]);
	WriteCoord(MSG_ENTITY, self.origin[2]);
	WriteCoord(MSG_ENTITY, self.angles[0]);
	WriteCoord(MSG_ENTITY, self.angles[1]);
	WriteCoord(MSG_ENTITY, self.angles[2]);
	WriteEntity(MSG_ENTITY, self.owner);
	return TRUE;
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
	sound(self, CHAN_VOICE, "player/sprayer.wav", 1.0, ATTN_NORM);
}
#endif

#ifdef CSQC
class CSpraylogo
{
	vector m_vecPosition;
	vector m_vecAngles;
	int m_iOwnerID;
	string m_strName;
	string m_m_strPath;
	int m_iInitialized;
	virtual float(void) predraw;
};

const string g_spray_mat = \
	"{\n" \
		"cull disable\n" \
		"polygonOffset\n" \
		"{\n" \
			"map $rt:%s\n" \
			"blendfunc blend\n" \
			"rgbGen vertex\n" \
		"}\n" \
	"}";

float
CSpraylogo::predraw(void)
{
	int iSize;

	/* TODO: Don't query this & width/height every frame */
	iSize = getplayerkeyblob(m_iOwnerID, "spray", __NULL__, 0);

	if (iSize <= 0) {
		return PREDRAW_NEXT;
	}

	if (m_iInitialized == FALSE) {
		void *image;
		m_iInitialized = TRUE;

		/* load the blob */
		image = memalloc(iSize + 1);
		getplayerkeyblob(m_iOwnerID, "spray", image, iSize);
		r_uploadimage(m_m_strPath, 64, 64, image, iSize, 0);
		memfree(image);

		/* push the material into memory */
		shaderforname(m_strName, sprintf(g_spray_mat, m_m_strPath));
	} else {
		vector width;
		vector height;
		vector light;

		light = getlight(m_vecPosition) / 255;

		/* TODO: handle spray dimensions independently */
		makevectors(m_vecAngles);
		width = v_up / 64;
		height = v_forward / 64;
		adddecal(m_strName, m_vecPosition, width, height, light, 1.0f);
		addentity(this);
	}
	return PREDRAW_NEXT;
}

void
Spray_Parse(void)
{
	spawnfunc_CSpraylogo();
	CSpraylogo spSelf =(CSpraylogo)self;
	spSelf.drawmask = MASK_ENGINE;
	spSelf.m_vecPosition[0] = readcoord();
	spSelf.m_vecPosition[1] = readcoord();
	spSelf.m_vecPosition[2] = readcoord();
	spSelf.m_vecAngles[0] = readcoord();
	spSelf.m_vecAngles[1] = readcoord();
	spSelf.m_vecAngles[2] = readcoord();
	spSelf.m_iInitialized = FALSE;
	spSelf.m_iOwnerID = readentitynum() - 1;
	spSelf.m_strName = sprintf("spray_%i", spSelf.m_iOwnerID);
	spSelf.m_m_strPath = sprintf("simg_%i", spSelf.m_iOwnerID);
}
#endif
