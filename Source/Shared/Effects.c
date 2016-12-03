/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

void Effect_BreakModel( vector vPos, vector vSize, vector vVel, float fStyle ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_MODELGIB );
	WriteCoord( MSG_MULTICAST, vPos_x); 
	WriteCoord( MSG_MULTICAST, vPos_y); 
	WriteCoord( MSG_MULTICAST, vPos_z);
	WriteCoord( MSG_MULTICAST, vSize_x); 
	WriteCoord( MSG_MULTICAST, vSize_y); 
	WriteCoord( MSG_MULTICAST, vSize_z);
	WriteByte( MSG_MULTICAST, fStyle );

	msg_entity = self;
	multicast( '0 0 0', MULTICAST_PVS );
#else
	float fCount = 20; // TODO: Generate gibcount based around size.
	vector vRandPos;
	
	while ( fCount > 0 ) {
		entity eGib = spawn();
		
		vRandPos_x = random() * vSize_x;
		vRandPos_y = random() * vSize_y;
		vRandPos_z = random() * vSize_z;
		vRandPos = vRandPos - ( vSize / 2 );
		
		setorigin( eGib, vPos + vRandPos );
		setmodel( eGib, "models/head.mdl" ); // Placeholder
		fCount--;
		eGib.drawmask = MASK_ENGINE;
	}
#endif
}
