/*
OpenCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

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
#ifdef CSQC
.float framerate;
.float maxframe;
void Effect_AnimatedSprite( vector vPos, float fIndex, float fFPS, float fScale, float fAlpha, float fEffects ) {
	
	static void Effect_AnimatedSprite_Animate( void ) {
		if( self.frame >= self.maxframe ) {
			self.frame = 0;
		} else {
			self.frame += 1;
		}
		
		self.nextthink = time + ( 1 / self.framerate );
	}
	self.modelindex = fIndex;
	setorigin( self, vPos );
	self.scale = fScale;
	self.alpha = fAlpha;
	self.effects = fEffects;
	self.framerate = fFPS;
	self.think = Effect_AnimatedSprite_Animate;
	self.drawmask = MASK_ENGINE;
	self.nextthink = time + ( 1 / self.framerate );
	self.maxframe = modelframecount( self.modelindex );
}
#endif

void Effect_Impact( int iType, vector vPos, vector vNormal ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_IMPACT );
	WriteByte( MSG_MULTICAST, (float)iType );
	WriteCoord( MSG_MULTICAST, vPos_x); 
	WriteCoord( MSG_MULTICAST, vPos_y); 
	WriteCoord( MSG_MULTICAST, vPos_z);
	WriteCoord( MSG_MULTICAST, vNormal_x); 
	WriteCoord( MSG_MULTICAST, vNormal_y); 
	WriteCoord( MSG_MULTICAST, vNormal_z);
	msg_entity = self;
	multicast( vPos, MULTICAST_PVS );
#else

	switch ( iType ) {
		case IMPACT_MELEE:
			pointparticles( DECAL_SHOT, vPos, vNormal, 1 );
			pointparticles( PARTICLE_PIECES_BLACK, vPos, vNormal, 1 );
			pointsound( vPos, "weapons/knife_hitwall1.wav", 1, ATTN_STATIC );
			break;
		case IMPACT_EXPLOSION:
			break;
		case IMPACT_GLASS:
			pointparticles( DECAL_GLASS, vPos, vNormal, 1 );
			pointparticles( PARTICLE_PIECES_BLACK, vPos, vNormal, 1 );
			break;
		case IMPACT_WOOD:
			pointparticles( DECAL_SHOT, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SPARK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_PIECES_BLACK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SMOKE_BROWN, vPos, vNormal, 1 );
			break;
		case IMPACT_METAL:
			pointparticles( DECAL_SHOT, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SPARK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SPARK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_PIECES_BLACK, vPos, vNormal, 1 );
			break;
		case IMPACT_FLESH:
			pointparticles( PARTICLE_BLOOD, vPos, vNormal, 1 );
			break;
		case IMPACT_DEFAULT:
			pointparticles( DECAL_SHOT, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SPARK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_PIECES_BLACK, vPos, vNormal, 1 );
			pointparticles( PARTICLE_SMOKE_GREY, vPos, vNormal, 1 );
			break;
		default:
	}
	
	switch ( iType ) {
		case IMPACT_METAL:
			pointsound( vPos, sprintf( "weapons/ric_metal-%d.wav", floor( ( random() * 2 ) + 1 ) ), 1, ATTN_STATIC );
			break;
		case IMPACT_FLESH:
			break;
		default:
			pointsound( vPos, sprintf( "weapons/ric%d.wav", floor( ( random() * 5 ) + 1 ) ), 1, ATTN_STATIC );
			break;
	}
	
#endif
}

void Effect_BreakModel( vector vMins, vector vMaxs, vector vVel, float fStyle ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_MODELGIB );
	WriteCoord( MSG_MULTICAST, vMins_x); 
	WriteCoord( MSG_MULTICAST, vMins_y); 
	WriteCoord( MSG_MULTICAST, vMins_z);
	WriteCoord( MSG_MULTICAST, vMaxs_x); 
	WriteCoord( MSG_MULTICAST, vMaxs_y); 
	WriteCoord( MSG_MULTICAST, vMaxs_z);
	WriteByte( MSG_MULTICAST, fStyle );

	msg_entity = self;
	
	vector vWorldPos;
	vWorldPos_x = vMins_x + ( 0.5 * ( vMaxs_x - vMins_x ) );	
	vWorldPos_y = vMins_y + ( 0.5 * ( vMaxs_y - vMins_y ) );	
	vWorldPos_z = vMins_z + ( 0.5 * ( vMaxs_z - vMins_z ) );
	multicast( vWorldPos, MULTICAST_PVS );
#else
	static void Effect_BreakModel_Remove( void ) { remove( self ) ; }
	
	float fModelCount;
	vector vPos;
	string sModel = "";
	float fCount = 20;
	
	switch ( fStyle ) {
		case MATERIAL_GLASS:
		case MATERIAL_GLASS_UNBREAKABLE:
			sModel = "models/glassgibs.mdl";
			fModelCount = 8;
			break;
		case MATERIAL_WOOD:
			sModel = "models/woodgibs.mdl";
			fModelCount = 3;
			break;
		case MATERIAL_METAL:
			sModel = "models/metalplategibs.mdl";
			fModelCount = 13;
			break;
		case MATERIAL_FLESH:
			sModel = "models/fleshgibs.mdl";
			fModelCount = 4;
			break;
		case MATERIAL_TILE:
			sModel = "models/ceilinggibs.mdl";
			fModelCount = 4;
			break;
		case MATERIAL_COMPUTER:
			sModel = "models/computergibs.mdl";
			fModelCount = 15;
			break;
		case MATERIAL_ROCK:
			sModel = "models/rockgibs.mdl";
			fModelCount = 3;
			break;
		default:
		case MATERIAL_CINDER:
			sModel = "models/cindergibs.mdl";
			fModelCount = 9;
			break;
	}
	
	vector vWorldPos;
	vWorldPos_x = vMins_x + ( 0.5 * ( vMaxs_x - vMins_x ) );	
	vWorldPos_y = vMins_y + ( 0.5 * ( vMaxs_y - vMins_y ) );	
	vWorldPos_z = vMins_z + ( 0.5 * ( vMaxs_z - vMins_z ) );
	
	switch ( fStyle ) {
		case MATERIAL_GLASS:
			pointsound( vWorldPos, sprintf( "debris/bustglass%d.wav", random( 1, 4 ) ), 1.0f, ATTN_NORM );
			break;
		case MATERIAL_WOOD:
			pointsound( vWorldPos, sprintf( "debris/bustcrate%d.wav", random( 1, 4 ) ), 1.0f, ATTN_NORM );
			break;
		case MATERIAL_METAL:
		case MATERIAL_COMPUTER:
			pointsound( vWorldPos, sprintf( "debris/bustmetal%d.wav", random( 1, 3 ) ), 1.0f, ATTN_NORM );
			break;
		case MATERIAL_FLESH:
			pointsound( vWorldPos, sprintf( "debris/bustflesh%d.wav", random( 1, 3 ) ), 1.0f, ATTN_NORM );
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			pointsound( vWorldPos, sprintf( "debris/bustconcrete%d.wav", random( 1, 4 ) ), 1.0f, ATTN_NORM );
			break;
		case MATERIAL_TILE:
			pointsound( vWorldPos, "debris/bustceiling.wav", 1.0f, ATTN_NORM );
			break;
	}
	
	while ( fCount > 0 ) {
		entity eGib = spawn();
		
		vPos_x = vMins_x + ( random() * ( vMaxs_x - vMins_x ) );	
		vPos_y = vMins_y + ( random() * ( vMaxs_y - vMins_y ) );	
		vPos_z = vMins_z + ( random() * ( vMaxs_z - vMins_z ) );	
		
		setorigin( eGib, vPos );
		setmodel( eGib, sModel );
		setcustomskin( eGib, "", sprintf( "geomset 0 %f\n", random( 1, fModelCount + 1 ) ) );
		eGib.movetype = MOVETYPE_BOUNCE;
		eGib.solid = SOLID_NOT;
		
		eGib.avelocity_x = random()*600;
		eGib.avelocity_y = random()*600;
		eGib.avelocity_z = random()*600;
		eGib.think = Effect_BreakModel_Remove;
		eGib.nextthink = time + 10;
		
		if ( ( fStyle == MATERIAL_GLASS ) || ( fStyle == MATERIAL_GLASS_UNBREAKABLE ) ) {
			eGib.effects = EF_ADDITIVE;
			eGib.alpha = 0.3;
		}
		
		fCount--;
		eGib.drawmask = MASK_ENGINE;
	}
#endif
}
