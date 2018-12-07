/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

#ifdef SSQC
void Effect_RemoveSpray( entity eOwner ) {
	for ( entity eFind = world; ( eFind = find( eFind, classname, "spray" ) ); ) {
		if ( eFind.owner == self ) {
			remove( eFind );
		}
	}
}

void Effect_Spraypaint( string sLogo, float fR, float fG, float fB ) {
	static float Effect_Spraypaint_Send( entity ePVSEnt, float fChanged ) {
		WriteByte( MSG_ENTITY, ENT_SPRAY );
		WriteCoord( MSG_ENTITY, self.origin_x );
		WriteCoord( MSG_ENTITY, self.origin_y );
		WriteCoord( MSG_ENTITY, self.origin_z );
		WriteCoord( MSG_ENTITY, self.angles_x );
		WriteCoord( MSG_ENTITY, self.angles_y );
		WriteCoord( MSG_ENTITY, self.angles_z );
		WriteByte( MSG_ENTITY, self.color_x );
		WriteByte( MSG_ENTITY, self.color_y );
		WriteByte( MSG_ENTITY, self.color_z );
		WriteString( MSG_ENTITY, self.model );
		return TRUE;
	} 
	vector vSrc;
	vector vEnd;
	makevectors( self.v_angle );
	
	if ( self.health <= 0 ) {
		return;
	}
	
	vSrc = self.origin + self.view_ofs;
	vEnd = vSrc + v_forward * 128;
	traceline( vSrc, vEnd, 0, self );
	
	// Found a wall
	if ( trace_fraction != 1.0f ) {
		Effect_RemoveSpray( self );
		
		entity eSpray = spawn();
		eSpray.classname = "spray";
		eSpray.owner = self;
		eSpray.solid = SOLID_NOT;
		eSpray.color_x = fR;
		eSpray.color_y = fG;
		eSpray.color_z = fB;
		eSpray.model = sLogo;
		
		setorigin( eSpray, trace_endpos );
		
		// Align it
		vector vSprayAngles = self.v_angle;
		vSprayAngles_x *= -1;
		makevectors( vSprayAngles );
		
		vector vCoplanar = v_forward - ( v_forward * trace_plane_normal ) * trace_plane_normal;
		
		if ( trace_plane_normal_z == 0 ) {
			vCoplanar = '0 0 1';
		}
		
		eSpray.angles = vectoangles( vCoplanar, trace_plane_normal );
		
		eSpray.SendEntity = Effect_Spraypaint_Send;
		eSpray.SendFlags = 1;
		sound( self, CHAN_VOICE, "player/sprayer.wav", 1.0, ATTN_NORM );
	}
#else
float Effect_Spraypaint( void ) {
	makevectors( self.angles );
	adddecal( self.classname, self.origin, v_up / 32, v_forward / 32, self.color, 1.0f );
	addentity( self );
	return PREDRAW_NEXT;
#endif
}

#ifdef SSQC
void CSEv_EffectSpray_sfff( string sLogo, float fR, float fG, float fB ) {
	Effect_Spraypaint( sLogo, fR, fG, fB );
}
#endif

void Effect_CreateExplosion( vector vPos ) {
#ifdef SSQC
	vPos_z += 48;
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_EXPLOSION );
	WriteCoord( MSG_MULTICAST, vPos_x ); 
	WriteCoord( MSG_MULTICAST, vPos_y ); 
	WriteCoord( MSG_MULTICAST, vPos_z );
	msg_entity = self;
	multicast( vPos, MULTICAST_PVS );
#else
	
	static void Effect_CreateExplosion_Animate( void ) {
		if ( self.frame >= self.maxframe ) {
			remove( self );
		} else {
			self.frame += 1;
		}
		self.nextthink = time + 0.05f;
	}
	
	entity eExplosion = spawn();
	setorigin( eExplosion, vPos );
	setmodel( eExplosion, "sprites/fexplo.spr" );
	sound( eExplosion, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 3 ) + 3 ), 1, ATTN_NORM );
	
	eExplosion.think = Effect_CreateExplosion_Animate;
	eExplosion.nextthink = time + 0.05f;
	eExplosion.effects = EF_ADDITIVE;
	eExplosion.drawmask = MASK_ENGINE;
	eExplosion.maxframe = modelframecount( eExplosion.modelindex );
	
	te_explosion( vPos );
#endif
}

void Effect_CreateSpark( vector vPos, vector vAngle ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_SPARK );
	WriteCoord( MSG_MULTICAST, vPos_x ); 
	WriteCoord( MSG_MULTICAST, vPos_y ); 
	WriteCoord( MSG_MULTICAST, vPos_z );
	WriteCoord( MSG_MULTICAST, vAngle_x ); 
	WriteCoord( MSG_MULTICAST, vAngle_y ); 
	WriteCoord( MSG_MULTICAST, vAngle_z );
	msg_entity = self;
	multicast( vPos, MULTICAST_PVS );
#else
	pointparticles( PARTICLE_SPARK, vPos, vAngle, 1 );
	pointsound( vPos, sprintf( "buttons/spark%d.wav", floor( random() * 6 ) + 1 ), 1, ATTN_STATIC );
#endif
}

#ifdef SSQC
void Effect_CreateFlash( entity eTarget ) {
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_FLASH );
	msg_entity = eTarget;
	multicast( '0 0 0', MULTICAST_ONE );
}
#endif

void Effect_CreateSmoke( vector vPos ) {
#ifdef SSQC
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_SMOKE );
	WriteCoord( MSG_MULTICAST, vPos_x ); 
	WriteCoord( MSG_MULTICAST, vPos_y ); 
	WriteCoord( MSG_MULTICAST, vPos_z );
	msg_entity = self;
	multicast( '0 0 0', MULTICAST_ALL );
#else
	static void Effect_CreateSmoke_Think( void ) {
		// HACK: This should only ever happen when rounds restart!
		// Any way this can go wrong?
		if ( self.skin < getstatf( STAT_GAMETIME ) ) {
			remove( self );
		}
		if ( self.frame <= 0 ) {
			remove( self );
			return;
		} 
	
		pointparticles( PARTICLE_SMOKEGRENADE, self.origin, '0 0 0', 1 );
		self.frame--;
		self.nextthink = time + 0.2f;
		self.skin = getstatf( STAT_GAMETIME );
	}
	
	entity eSmoke = spawn();
	setorigin( eSmoke, vPos );
	eSmoke.think = Effect_CreateSmoke_Think;
	eSmoke.nextthink = time;
	eSmoke.frame = 200;
	eSmoke.skin = getstatf( STAT_GAMETIME );
#endif
}

#ifdef CSQC
.float framerate;
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
	WriteCoord( MSG_MULTICAST, vPos_x ); 
	WriteCoord( MSG_MULTICAST, vPos_y ); 
	WriteCoord( MSG_MULTICAST, vPos_z );
	WriteCoord( MSG_MULTICAST, vNormal_x ); 
	WriteCoord( MSG_MULTICAST, vNormal_y ); 
	WriteCoord( MSG_MULTICAST, vNormal_z );
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
		eGib.classname = "gib";
		
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

#ifdef CSQC
float Effect_Decal( void ) {
	makevectors( self.angles );
	adddecal( self.classname, self.origin, v_up / self.size[0], v_forward / self.size[1], self.color, 1.0f );
	addentity( self );
	return PREDRAW_NEXT;
}
#endif
