
/*
=================
Player_SendEntity
=================
*/
float Player_SendEntity( entity ePEnt, float fChanged ) {
	if ( self.health <= 0 && ePEnt != self ) {
		return FALSE;
	}

	WriteByte( MSG_ENTITY, ENT_PLAYER );
	WriteShort( MSG_ENTITY, self.modelindex );
	WriteCoord( MSG_ENTITY, self.origin_x );
	WriteCoord( MSG_ENTITY, self.origin_y );
	WriteCoord( MSG_ENTITY, self.origin_z );
	WriteCoord( MSG_ENTITY, self.v_angle_x );
	WriteCoord( MSG_ENTITY, self.angles_y );
	WriteCoord( MSG_ENTITY, self.angles_z );
	WriteCoord( MSG_ENTITY, self.velocity_x );
	WriteCoord( MSG_ENTITY, self.velocity_y );
	WriteCoord( MSG_ENTITY, self.velocity_z );
	WriteFloat( MSG_ENTITY, self.flags );
	WriteFloat( MSG_ENTITY, self.pmove_flags );
	WriteByte( MSG_ENTITY, self.weapon );
	WriteByte( MSG_ENTITY, self.health );
	WriteFloat( MSG_ENTITY, self.movetype );
	WriteFloat( MSG_ENTITY, self.view_ofs[2] );
	return TRUE;
}
