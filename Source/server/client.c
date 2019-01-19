/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Client_TriggerCamera( entity eTarget, vector vPos, vector vEndPos, float fResetTime )
{
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_CAMERATRIGGER );
	WriteCoord( MSG_MULTICAST, vPos_x );
	WriteCoord( MSG_MULTICAST, vPos_y );
	WriteCoord( MSG_MULTICAST, vPos_z );
	WriteCoord( MSG_MULTICAST, vEndPos_x );
	WriteCoord( MSG_MULTICAST, vEndPos_y );
	WriteCoord( MSG_MULTICAST, vEndPos_z );
	WriteFloat( MSG_MULTICAST, fResetTime );
	msg_entity = eTarget;
	multicast( '0 0 0', MULTICAST_ONE );
}
