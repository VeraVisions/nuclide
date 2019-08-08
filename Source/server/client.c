/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Client_TriggerCamera(entity target, vector pos, vector end, float wait)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CAMERATRIGGER);
	WriteCoord(MSG_MULTICAST, pos[0]);
	WriteCoord(MSG_MULTICAST, pos[1]);
	WriteCoord(MSG_MULTICAST, pos[2]);
	WriteCoord(MSG_MULTICAST, end[0]);
	WriteCoord(MSG_MULTICAST, end[1]);
	WriteCoord(MSG_MULTICAST, end[2]);
	WriteFloat(MSG_MULTICAST, wait);
	msg_entity = target;
	multicast([0,0,0], MULTICAST_ONE);
}

void CSEv_Taunt_f(float num)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_TAUNT);
	WriteEntity(MSG_MULTICAST, self);
	WriteByte(MSG_MULTICAST, num);
	msg_entity = self;
	multicast(self.origin, MULTICAST_PVS);

#ifdef SCIHUNT
	for (entity b = world; (b = find(b, ::classname, "monster_scientist"));) {
		if (vlen(b.origin - self.origin) < 256) {
			monster_scientist sci = (monster_scientist)b;
			sci.m_iFlags |= SCIF_FEAR | SCIF_SEEN;
			sci.m_eUser = world;
			sci.m_eRescuer = world;
		}
	}
#endif
}