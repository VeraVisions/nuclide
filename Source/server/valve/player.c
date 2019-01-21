
/*
=================
Player_SendEntity
=================
*/
float Player_SendEntity(entity ePEnt, float fChanged)
{
	if (self.health <= 0 && ePEnt != self) {
		return FALSE;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteShort(MSG_ENTITY, self.modelindex);
	WriteCoord(MSG_ENTITY, self.origin[0]);
	WriteCoord(MSG_ENTITY, self.origin[1]);
	WriteCoord(MSG_ENTITY, self.origin[2]);
	WriteCoord(MSG_ENTITY, self.v_angle[0]);
	WriteCoord(MSG_ENTITY, self.angles[1]);
	WriteCoord(MSG_ENTITY, self.angles[2]);
	WriteCoord(MSG_ENTITY, self.velocity[0]);
	WriteCoord(MSG_ENTITY, self.velocity[1]);
	WriteCoord(MSG_ENTITY, self.velocity[2]);
	WriteFloat(MSG_ENTITY, self.flags);
	WriteFloat(MSG_ENTITY, self.pmove_flags);
	WriteByte(MSG_ENTITY, self.weapon);
	WriteByte(MSG_ENTITY, self.health);
	WriteFloat(MSG_ENTITY, self.movetype);
	WriteFloat(MSG_ENTITY, self.view_ofs[2]);
	WriteFloat(MSG_ENTITY, self.viewzoom);
	return TRUE;
}
