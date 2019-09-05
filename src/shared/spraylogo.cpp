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
.float nextspray;
void Spray_RemoveAll(entity entOwner)
{
	for (entity eFind = world;(eFind = find(eFind, classname, "Spray"));) {
		if (eFind.owner == entOwner) {
			remove(eFind);
		}
	}
}

float Spray_SendEntity(entity ePVSEnt, float fChanged)
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

void CSEv_Spraylogo(void)
{
	if (self.nextspray > time) {
		return;
	}
	self.nextspray = time + 30.0f;

	makevectors(self.v_angle);
	traceline(self.origin + self.view_ofs, 
			  self.origin + self.view_ofs + v_forward * 128, FALSE, self);
	
	if (trace_fraction != 1.0f) {
		Spray_RemoveAll(self);
		entity eSpray = spawn(); 
		eSpray.classname = "Spray";
		eSpray.owner = self;
		eSpray.solid = SOLID_NOT;
		setorigin(eSpray, trace_endpos);
		vector vSprayAngles = self.v_angle;
		vSprayAngles[0] *= -1;
		makevectors(vSprayAngles);

		vector vecCoplanar = v_forward -(v_forward * trace_plane_normal) 
							  * trace_plane_normal;

		if (trace_plane_normal[2] == 0) {
			vecCoplanar = '0 0 1';
		}

		eSpray.angles = vectoangles(vecCoplanar, trace_plane_normal);
		eSpray.SendEntity = Spray_SendEntity;
		eSpray.SendFlags = 1;
		sound(self, CHAN_VOICE, "player/sprayer.wav", 1.0, ATTN_NORM);
	}
}
#endif

#ifdef CSQC

class CSpraylogo
{
	vector m_vecPosition;
	vector m_vecAngles;
	int m_iOwnerID;
	string m_strLogoname;
	string m_strLogopath;
	int m_iInitialized;
	virtual float(void) predraw;
};

float CSpraylogo::predraw(void)
{
	int iSize = getplayerkeyblob(m_iOwnerID, "spray", __NULL__, 0);
	
	if (iSize <= 0) {
		return PREDRAW_NEXT;
	}
	if (m_iInitialized == FALSE) {
		void *image;
		m_iInitialized = TRUE;
		image = memalloc(iSize + 1);
		getplayerkeyblob(m_iOwnerID, "spray", image, iSize);
		r_uploadimage(m_strLogopath, 64, 64, image, iSize, 0);
		memfree(image);

		print(sprintf("[CLIENT] Spray from player: %s\n",
			getplayerkeyvalue(m_iOwnerID, "name")));

		shaderforname(m_strLogoname, 
			sprintf("{\ncull disable\npolygonOffset\n{\nmap $rt:%s\nblendfunc gl_one gl_one_minus_src_alpha\nrgbGen vertex\n}\n}", 
				 m_strLogopath));
	} else {
		vector light = getlight(m_vecPosition) / 255;
		makevectors(m_vecAngles);
		adddecal(m_strLogoname, m_vecPosition, 
				 v_up / 64, v_forward / 64, light, 1.0f);
		addentity(this);
	}
	return PREDRAW_NEXT;
}

void Spraylogo_Parse(void)
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
	spSelf.m_strLogoname = sprintf("spray_%i",
		spSelf.m_iOwnerID);
	spSelf.m_strLogopath = sprintf("simg_%i",
		spSelf.m_iOwnerID);
}
#endif
