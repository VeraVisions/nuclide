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

static bool droptofloorwrapper( entity foo ) {
	bool result;
	entity old_self = self;
	self = foo;
	result = droptofloor();
	self = old_self;
	return result;
}

void NSEntity::NSEntity( void ) {
	identity = 1;
	m_flSpawnTime = time;
}

void NSEntity::Spawned( void ) {
	super::Spawned();

	m_oldAngle = angles;
	m_oldOrigin = origin;
	m_oldModel = Util_FixModel( model );
	m_oldSolid = solid;

#ifdef SERVER
	m_oldstrTarget = target;

	if ( m_oldModel && m_oldModel != "" ) {
		precache_model( GetSpawnModel() );
	}

	if ( m_strOnTrigger ) {
		m_strOnTrigger = CreateOutput( m_strOnTrigger );
	}
#endif
}

float NSEntity::EntIndex( void ) {
	return ( num_for_edict( this ) );
}

bool NSEntity::DropToFloor( void ) {
	return droptofloorwrapper( this );
}

vector NSEntity::GetForward( void ) {
	makevectors( angles );
	return ( v_forward );
}

vector NSEntity::GetRight( void ) {
	makevectors( angles );
	return ( v_right );
}

vector NSEntity::GetUp( void ) {
	makevectors( angles );
	return ( v_up );
}

vector NSEntity::WorldSpaceCenter( void ) {
	return ( absmin + ( 0.5 * ( absmax - absmin ) ) );
}

float NSEntity::WaterLevel( void ) {
	return ( waterlevel );
}

bool NSEntity::VisibleVec( vector org ) {
	vector flDelta;
	float flFoV;

	makevectors( angles );
	flDelta = normalize( org - origin );
	flFoV = flDelta * v_forward;

	if ( flFoV > 0.3f ) {
		traceline( origin, org, TRUE, this );
		if ( trace_fraction == 1.0f ) {
			return ( true );
		}
	}
	return ( false );
}

bool NSEntity::Visible( entity ent ) {
	/* is it in our field of view? */
	if ( DistanceFromYaw(ent.origin) > 0.3f ) {
		traceline( origin, ent.origin, MOVE_NORMAL, this );
		if ( trace_fraction == 1.0f || trace_ent == ent ) {
			print( sprintf( "%s can see %s\n", classname, ent.classname ) );
			return ( true );
		}
	}
	print( sprintf( "%s can not see %s\n", classname, ent.classname ) );
	return ( false );
}

float NSEntity::DistanceFromYaw( vector targetPos ) {
	vector vecDelta;
	makevectors( angles );
	vecDelta = normalize( targetPos - origin );
	return vecDelta * v_forward;
}

bool NSEntity::HasSpawnFlags( float sf ) {
	return ( spawnflags & sf ) ? true : false;
}

bool NSEntity::IsOnGround( void ) {
	return ( flags & FL_ONGROUND ) ? true : false;
}

bool NSEntity::IsSolid( void ) {
	return ( solid != SOLID_NOT ) ? true : false;
}

entity NSEntity::GetGroundEntity( void ) {
	return ( groundentity );
}

bool NSEntity::CreatedByMap( void ) {
	return ( _mapspawned );
}



#ifdef CLIENT
void NSEntity::RendererRestarted( void ) {

}

void NSEntity::ReceiveEntity( float flNew, float flChanged ) {
	READENTITY_COORD( origin[0], BASEFL_CHANGED_ORIGIN_X )
		READENTITY_COORD( origin[1], BASEFL_CHANGED_ORIGIN_Y )
		READENTITY_COORD( origin[2], BASEFL_CHANGED_ORIGIN_Z )
		READENTITY_ANGLE( angles[0], BASEFL_CHANGED_ANGLES_X )
		READENTITY_ANGLE( angles[1], BASEFL_CHANGED_ANGLES_Y )
		READENTITY_ANGLE( angles[2], BASEFL_CHANGED_ANGLES_Z )
		READENTITY_SHORT( modelindex, BASEFL_CHANGED_MODELINDEX )
		READENTITY_BYTE( solid, BASEFL_CHANGED_SOLID )
		READENTITY_BYTE( movetype, BASEFL_CHANGED_FLAGS )
		READENTITY_INT( flags, BASEFL_CHANGED_FLAGS )
		READENTITY_COORD( mins[0], BASEFL_CHANGED_SIZE )
		READENTITY_COORD( mins[1], BASEFL_CHANGED_SIZE )
		READENTITY_COORD( mins[2], BASEFL_CHANGED_SIZE )
		READENTITY_COORD( maxs[0], BASEFL_CHANGED_SIZE )
		READENTITY_COORD( maxs[1], BASEFL_CHANGED_SIZE )
		READENTITY_COORD( maxs[2], BASEFL_CHANGED_SIZE )
		READENTITY_BYTE( frame, BASEFL_CHANGED_FRAME )
		READENTITY_FLOAT( skin, BASEFL_CHANGED_SKIN )
		READENTITY_FLOAT( effects, BASEFL_CHANGED_EFFECTS )
		READENTITY_FLOAT( scale, BASEFL_CHANGED_SCALE )
		READENTITY_COORD( velocity[0], BASEFL_CHANGED_VELOCITY_X )
		READENTITY_COORD( velocity[1], BASEFL_CHANGED_VELOCITY_Y )
		READENTITY_COORD( velocity[2], BASEFL_CHANGED_VELOCITY_Z )
		READENTITY_COORD( avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY )
		READENTITY_COORD( avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY )
		READENTITY_COORD( avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY )
		if ( modelindex ) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	if ( scale == 0.0f )
		scale = 1.0f;

	if ( flChanged & BASEFL_CHANGED_SIZE )
		setsize( this, mins, maxs );
}

void NSEntity::postdraw( void ) {
}


#else
void
NSEntity::DebugDraw(void)
{

}

/* Make sure StartFrame calls this */
float NSEntity::SendEntity( entity ePEnt, float flChanged ) {
	if ( !modelindex )
		return ( 0 );

	if ( clienttype( ePEnt ) != CLIENTTYPE_REAL )
		return ( 0 );

	if ( alpha == 0.0f )
		return ( 0 );

	WriteByte( MSG_ENTITY, ENT_ENTITY );

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~BASEFL_CHANGED_VELOCITY_X;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Y;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Z;
			flChanged &= ~BASEFL_CHANGED_ANGULARVELOCITY;
		}

		if (m_bIsBrush == true) {
			flChanged &= ~BASEFL_CHANGED_FLAGS;
			flChanged &= ~BASEFL_CHANGED_SCALE;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat( MSG_ENTITY, flChanged );

	SENDENTITY_COORD( origin[0], BASEFL_CHANGED_ORIGIN_X )
		SENDENTITY_COORD( origin[1], BASEFL_CHANGED_ORIGIN_Y )
		SENDENTITY_COORD( origin[2], BASEFL_CHANGED_ORIGIN_Z )
		SENDENTITY_ANGLE( angles[0], BASEFL_CHANGED_ANGLES_X )
		SENDENTITY_ANGLE( angles[1], BASEFL_CHANGED_ANGLES_Y )
		SENDENTITY_ANGLE( angles[2], BASEFL_CHANGED_ANGLES_Z )
		SENDENTITY_SHORT( modelindex, BASEFL_CHANGED_MODELINDEX )
		SENDENTITY_BYTE( solid, BASEFL_CHANGED_SOLID )
		SENDENTITY_BYTE( movetype, BASEFL_CHANGED_FLAGS )
		SENDENTITY_INT( flags, BASEFL_CHANGED_FLAGS )
		SENDENTITY_COORD( mins[0], BASEFL_CHANGED_SIZE )
		SENDENTITY_COORD( mins[1], BASEFL_CHANGED_SIZE )
		SENDENTITY_COORD( mins[2], BASEFL_CHANGED_SIZE )
		SENDENTITY_COORD( maxs[0], BASEFL_CHANGED_SIZE )
		SENDENTITY_COORD( maxs[1], BASEFL_CHANGED_SIZE )
		SENDENTITY_COORD( maxs[2], BASEFL_CHANGED_SIZE )
		SENDENTITY_BYTE( frame, BASEFL_CHANGED_FRAME )
		SENDENTITY_FLOAT( skin, BASEFL_CHANGED_SKIN )
		SENDENTITY_FLOAT( effects, BASEFL_CHANGED_EFFECTS )
		SENDENTITY_FLOAT( scale, BASEFL_CHANGED_SCALE )
		SENDENTITY_COORD( velocity[0], BASEFL_CHANGED_VELOCITY_X )
		SENDENTITY_COORD( velocity[1], BASEFL_CHANGED_VELOCITY_Y )
		SENDENTITY_COORD( velocity[2], BASEFL_CHANGED_VELOCITY_Z )
		SENDENTITY_COORD( avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY )
		SENDENTITY_COORD( avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY )
		SENDENTITY_COORD( avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY )
		return ( 1 );
}

void NSEntity::EvaluateEntity( void ) {
	EVALUATE_VECTOR( origin, 0, BASEFL_CHANGED_ORIGIN_X )
		EVALUATE_VECTOR( origin, 1, BASEFL_CHANGED_ORIGIN_Y )
		EVALUATE_VECTOR( origin, 2, BASEFL_CHANGED_ORIGIN_Z )
		EVALUATE_VECTOR( angles, 0, BASEFL_CHANGED_ANGLES_X )
		EVALUATE_VECTOR( angles, 1, BASEFL_CHANGED_ANGLES_Y )
		EVALUATE_VECTOR( angles, 2, BASEFL_CHANGED_ANGLES_Z )
		EVALUATE_FIELD( modelindex, BASEFL_CHANGED_MODELINDEX )
		EVALUATE_FIELD( solid, BASEFL_CHANGED_SOLID )
		EVALUATE_FIELD( movetype, BASEFL_CHANGED_FLAGS )
		EVALUATE_FIELD( flags, BASEFL_CHANGED_FLAGS )
		EVALUATE_VECTOR( mins, 0, BASEFL_CHANGED_SIZE )
		EVALUATE_VECTOR( mins, 1, BASEFL_CHANGED_SIZE )
		EVALUATE_VECTOR( mins, 2, BASEFL_CHANGED_SIZE )
		EVALUATE_VECTOR( maxs, 0, BASEFL_CHANGED_SIZE )
		EVALUATE_VECTOR( maxs, 1, BASEFL_CHANGED_SIZE )
		EVALUATE_VECTOR( maxs, 2, BASEFL_CHANGED_SIZE )
		EVALUATE_FIELD( frame, BASEFL_CHANGED_FRAME )
		EVALUATE_FIELD( skin, BASEFL_CHANGED_SKIN )
		EVALUATE_FIELD( effects, BASEFL_CHANGED_EFFECTS )
		EVALUATE_FIELD( scale, BASEFL_CHANGED_SCALE )
		EVALUATE_VECTOR( velocity, 0, BASEFL_CHANGED_VELOCITY_X )
		EVALUATE_VECTOR( velocity, 1, BASEFL_CHANGED_VELOCITY_Y )
		EVALUATE_VECTOR( velocity, 2, BASEFL_CHANGED_VELOCITY_Z )
		EVALUATE_VECTOR( avelocity, 0, BASEFL_CHANGED_ANGULARVELOCITY )
		EVALUATE_VECTOR( avelocity, 1, BASEFL_CHANGED_ANGULARVELOCITY )
		EVALUATE_VECTOR( avelocity, 2, BASEFL_CHANGED_ANGULARVELOCITY )
}

/* Make sure StartFrame calls this */
void NSEntity::ParentUpdate( void ) {
	EvaluateEntity();

	frame1time += frametime;

	if ( m_parent ) {
		NSEntity parent;
		entity p = find( world, ::targetname, m_parent );

		if ( p ) {
			if ( !m_parent_attachment ) {
				parent = ( NSEntity ) p;
				vector ofs = parent.origin - parent.GetSpawnOrigin();

				SetOrigin( GetSpawnOrigin() + ofs );
			} else if ( m_parent_attachment == "origin" ) {
				SetOrigin( p.origin );
			}
		}
	}

	/* handle end-touch */
	if ( m_beingTouched == true )
		if ( m_flTouchTime < GetTime() ) {
			EndTouch( m_eTouchLast );
			m_beingTouched = false;
			m_eTouchLast = __NULL__;
		}
}

entity NSEntity::GetParent( void ) {
	return ( find( world, ::targetname, m_parent ) );
}

void NSEntity::SetParent( string name ) {
	m_parent = name;
}

void NSEntity::SetParentAttachment( string name ) {
	m_parent_attachment = name;
}

void NSEntity::ClearParent( void ) {
	m_parent = __NULL__;
	m_parent_attachment = __NULL__;
}

void NSEntity::RestoreAngles( void ) {
	angles = GetSpawnAngles();
}

void NSEntity::ClearAngles( void ) {
	angles = [0, 0, 0];
}

void NSEntity::ForceNetworkUpdate( void ) {
	SendFlags = -1;
}
#endif

void NSEntity::SetEffects( float newEffects ) {
	effects = newEffects;
}

void NSEntity::SetFrame( float newFrame ) {
	if ( newFrame == frame )
		return;

	frame = newFrame;
	frame1time = 0.0f;


#ifdef SERVER
	/* check if an event callback exists */
	{
		int eDefEvents = tokenize(m_strModelEventCB);
		string ourName = frametoname(modelindex, frame);

		for (int i = 0; i < eDefEvents; i+=3) {
			string testName = argv(i+0);
			string testInput = argv(i+1);
			string testData = argv(i+2);

			if (ourName == testName) {
				if (testData != "")
					Input(this, testInput, testData);
				else
					Input(this, testInput, ""); /* no parms passed. */

				tokenize(m_strModelEventCB); /* ensure argv() is 'rewound'... */
			}
		}
	}
#endif
}

void NSEntity::SetSkin( float newSkin ) {
	skin = newSkin;
}

void NSEntity::SetOwner( entity newOwner ) {
	owner = newOwner;
}

void NSEntity::SetVelocity( vector vecNew ) {
	velocity = vecNew;
}

void NSEntity::SetTouch( void ()newTouch ) {
	touch = newTouch;
}

/* we want to really use those set functions because they'll notify of any
 * networking related changes. otherwise we'll have to keep track of copies
 * that get updated every frame */
void NSEntity::SetSendFlags( float flSendFlags ) {
#ifdef SERVER
	SendFlags |= flSendFlags;
#endif
}

void NSEntity::SetMovetype( float newMovetype ) {
	movetype = newMovetype;
}

void NSEntity::SetGravity( float newGrav ) {
	gravity = newGrav;
}

void NSEntity::SetSolid( float newSolid ) {
	solid = newSolid;
}

void NSEntity::SetScale( float newScale ) {
	if ( newScale == scale )
		return;

	scale = newScale;
	setsize( this, m_vecMins * scale, m_vecMaxs * scale );
}

void NSEntity::UpdateBounds( void ) {
	vector newMins, newMaxs;
	float flScale = 1.0f;

	newMins = m_vecMins;
	newMaxs = m_vecMaxs;

	/* avoid useless computation */
	if ( angles !=[0, 0, 0] ) {
		/* adjust bbox according to rotation */
		vector vecCorner[8];

		newMins = newMaxs =[0, 0, 0];
		for ( int i = 0; i < 8; i++ ) {
			vecCorner[i][0] = ( i & 1 ) ? m_vecMins[0] : m_vecMaxs[0];
			vecCorner[i][1] = ( i & 2 ) ? m_vecMins[1] : m_vecMaxs[1];
			vecCorner[i][2] = ( i & 4 ) ? m_vecMins[2] : m_vecMaxs[2];
			vecCorner[i] += origin;
			vecCorner[i] = Math_RotateAroundPivot( vecCorner[i], origin, angles[1] );
			vecCorner[i] -= origin;

			if ( !( vecCorner[i][0] <= newMaxs[0] ) )
				newMaxs[0] = vecCorner[i][0];
			if ( !( vecCorner[i][1] <= newMaxs[1] ) )
				newMaxs[1] = vecCorner[i][1];
			if ( !( vecCorner[i][2] <= newMaxs[2] ) )
				newMaxs[2] = vecCorner[i][2];

			if ( !( vecCorner[i][0] >= newMins[0] ) )
				newMins[0] = vecCorner[i][0];
			if ( !( vecCorner[i][1] >= newMins[1] ) )
				newMins[1] = vecCorner[i][1];
			if ( !( vecCorner[i][2] >= newMins[2] ) )
				newMins[2] = vecCorner[i][2];
		}
	}

	/* 0.0 is never valid, if you want it to disappear do something else */
	if ( scale != 0.0 )
		flScale = scale;

	setsize( this, newMins * flScale, newMaxs * flScale );
}

void NSEntity::SetAngles( vector newAngles ) {
	angles = newAngles;
}

void NSEntity::SetAngularVelocity( vector newAvel ) {
	avelocity = newAvel;
}

void NSEntity::SetSize( vector newMins, vector newMaxs ) {
	float flScale = 1.0f;

	m_vecMins = newMins;
	m_vecMaxs = newMaxs;

	/* 0.0 is never valid, if you want it to disappear do something else */
	if ( scale != 0.0f )
		flScale = scale;

	setsize( this, newMins * flScale, newMaxs * flScale );
}

void NSEntity::SetOrigin( vector newOrigin ) {
	setorigin( this, newOrigin );
}

void NSEntity::SetModel( string newModel ) {
	m_bIsBrush = substring(newModel, 0, 1) == "*" ? true : false;
	model = newModel;
	setmodel( this, newModel );

	/* mins/maxs have been updated by setmodel */
	SetSize( mins, maxs );
}
void NSEntity::SetModelindex( float newModelIndex ) {
	if ( newModelIndex == modelindex )
		return;

	modelindex = newModelIndex;
	SetSize( mins, maxs );

}

void
NSEntity::AddAngularVelocity(vector addVel)
{
	avelocity += addVel;
}

void
NSEntity::AddVelocity(vector addVel)
{
	velocity += addVel;
}

void NSEntity::AddEffects( float fl ) {
	effects |= fl;
}

void NSEntity::RemoveEffects( float fl ) {
	effects &= ~fl;
}


void NSEntity::AddFlags( float fl ) {
	flags |= fl;
}

void NSEntity::RemoveFlags( float fl ) {
	flags &= ~fl;
}

void NSEntity::TurnTo( float targetAngle ) {
	angles[1] = targetAngle;
}

void NSEntity::TurnToPos( vector targetPos ) {
	angles = vectoangles(targetPos - WorldSpaceCenter());
}

void NSEntity::SetThink( void ( void ) func ) {
	think = func;
}

void NSEntity::SetNextThink( float fl ) {
	float flTime = GetTime() + fl;

	/* HACK: to make sure things happen post-spawn */
	if ( flTime == 0.0f )
		flTime = 0.001f;

	if ( flTime >= 0 )
		nextthink = flTime;
	else
		EntError( "%s sets bogus nextthink value %f", classname, flTime );
}

void NSEntity::ScheduleThink( void ( void ) func, float fl ) {
	SetThink( func );
	SetNextThink( fl );
}

vector NSEntity::GetSpawnOrigin( void ) {
	return ( m_oldOrigin );
}

vector NSEntity::GetSpawnAngles( void ) {
	return ( m_oldAngle );
}

string NSEntity::GetSpawnModel( void ) {
	return ( m_oldModel );
}

float NSEntity::GetEffects( void ) {
	return ( effects );
}

float NSEntity::GetFrame( void ) {
	return ( frame );
}

float NSEntity::GetSkin( void ) {
	return ( skin );
}

float NSEntity::GetScale( void ) {
	return ( scale );
}

entity NSEntity::GetOwner( void ) {
	return ( owner );
}

vector NSEntity::GetVelocity( void ) {
	return ( velocity );
}

float NSEntity::GetSolid( void ) {
	return ( solid );
}

string NSEntity::GetModel( void ) {
	return ( model );
}

float NSEntity::GetModelindex( void ) {
	return ( modelindex );
}

float NSEntity::GetMovetype( void ) {
	return ( movetype );
}

float NSEntity::GetGravity( void ) {
	return ( gravity );
}

vector NSEntity::GetAngles( void ) {
	return ( angles );
}

vector NSEntity::GetAngularVelocity( void ) {
	return ( avelocity );
}

vector NSEntity::GetOrigin( void ) {
	return ( origin );
}

vector NSEntity::GetMins( void ) {
	return ( mins );
}

vector NSEntity::GetMaxs( void ) {
	return ( maxs );
}

vector NSEntity::GetRealMins( void ) {
	return ( m_vecMins );
}

vector NSEntity::GetRealMaxs( void ) {
	return ( m_vecMaxs );
}

vector NSEntity::GetAbsoluteMins( void ) {
	return ( absmin );
}

vector NSEntity::GetAbsoluteMaxs( void ) {
	return ( absmax );
}

float NSEntity::GetFlags( void ) {
	return ( flags );
}

bool NSEntity::HasFlags(float bits) {
	if ( flags & bits )
		return (true);

	return (false);
}

float NSEntity::GetNextThinkTime( void ) {
	return ( nextthink );
}

bool NSEntity::IsThinking( void ) {
	return ( nextthink > GetTime() )? true : false;
}

void NSEntity::ReleaseThink( void ) {
	think = __NULL__;
	nextthink = 0.0f;
}

void NSEntity::ClearVelocity( void ) {
	velocity = avelocity =[0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
void NSEntity::Respawn( void ) {
	super::Respawn();
	SetSolid( m_oldSolid );
	SetAngles( GetSpawnAngles() );
	SetOrigin( GetSpawnOrigin() );
	SetModel( GetSpawnModel() );
}

void NSEntity::Save( float handle ) {
	super::Save( handle );
	SaveFloat( handle, "pvsflags", pvsflags );
	SaveFloat( handle, "_mapspawned", _mapspawned );
	SaveFloat( handle, "scale", scale );
	SaveFloat( handle, "friction", friction );
	SaveVector( handle, "m_vecMins", m_vecMins );
	SaveVector( handle, "m_vecMaxs", m_vecMaxs );
	SaveVector( handle, "m_oldOrigin", m_oldOrigin );
	SaveVector( handle, "m_oldAngle", m_oldAngle );
	SaveString( handle, "m_oldModel", m_oldModel );
	SaveFloat( handle, "m_oldSolid", m_oldSolid );
	SaveFloat( handle, "m_flTouchTime", m_flTouchTime );
	SaveBool( handle, "m_beingTouched", m_beingTouched );
	SaveEntity( handle, "m_eTouchLast", m_eTouchLast );
	SaveString( handle, "m_parent", m_parent );
	SaveString( handle, "m_parent_attachment", m_parent_attachment );
}

void NSEntity::Restore( string strKey, string strValue ) {
	switch ( strKey ) {
	case "pvsflags":
		pvsflags = stof( strValue );
		break;
	case "_mapspawned":
		_mapspawned = stof( strValue );
		break;
	case "scale":
		scale = ReadFloat( strValue );
		break;
	case "friction":
		friction = ReadFloat( strValue );
		break;
	case "m_vecMins":
		m_vecMins = ReadVector( strValue );
		break;
	case "m_vecMaxs":
		m_vecMaxs = ReadVector( strValue );
		break;
	case "m_oldOrigin":
		m_oldOrigin = ReadVector( strValue );
		break;
	case "m_oldAngle":
		m_oldAngle = ReadVector( strValue );
		break;
	case "m_oldModel":
		m_oldModel = ReadString( strValue );
		break;
	case "m_oldSolid":
		m_oldSolid = ReadFloat( strValue );
		break;
	case "m_flTouchTime":
		m_flTouchTime = ReadFloat( strValue );
		break;
	case "m_beingTouched":
		m_beingTouched = ReadBool( strValue );
		break;
	case "m_eTouchLast":
		m_eTouchLast = ReadEntity( strValue );
		break;
	case "m_parent":
		m_parent = ReadString( strValue );
		break;
	case "m_parent_attachment":
		m_parent_attachment = ReadString( strValue );
		break;
	default:
		super::Restore( strKey, strValue );
		break;
	}
}

void NSEntity::Input( entity eAct, string strInput, string strData ) {
	switch ( strInput ) {
	case "Kill":
		Destroy();
		break;
	case "KillHierarchy":
		/* this works because ents are basically just entnums */
		for ( entity e = world; ( e = findfloat( e, ::owner, this ) ); ) {
			NSEntity ent = ( NSEntity ) e;

			ent.Destroy();
		}
		Destroy();
		break;
	case "SetParent":
		SetParent( strData );
		break;
	case "SetParentAttachment":
		SetParentAttachment( strData );
		break;
	case "ClearParent":
		ClearParent();
		break;
	case "Use":
		eActivator = eAct;

		if ( PlayerUse )
			PlayerUse();
		break;
	case "SpawnDef":
		break;
	case "SpawnProjectileDef":
		if (EntityDef_HasSpawnClass(strData)) {
			NSProjectile_SpawnDefAttachment(strData, this, 0);
		} else {
			float rangedDmg = Skill_GetDefValue(EntityDef_GetKeyValue(strData, "damage"));
			TraceAttack_FireBullets(1, origin + view_ofs, rangedDmg, [0.01,0.01], 0);
		}
		break;
	case "StartSoundDef":
		StartSoundDef(strData, CHAN_VOICE, true);
		break;
	case "AddVelocity":
		vector velAdd = stov(strData);
		makevectors(angles);
		velocity += v_forward * velAdd[0];
		velocity += v_right * velAdd[1];
		velocity += v_up * velAdd[2];
		break;
	case "Shockwave":
		int c = tokenize(strData);
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_BEAMCYLINDER);
		WriteCoord(MSG_MULTICAST, origin[0]);
		WriteCoord(MSG_MULTICAST, origin[1]);
		WriteCoord(MSG_MULTICAST, origin[2]);
		WriteCoord(MSG_MULTICAST, angles[0]);
		WriteCoord(MSG_MULTICAST, stof(argv(1)));
		WriteCoord(MSG_MULTICAST, angles[2]);
		WriteShort(MSG_MULTICAST, getmodelindex(argv(0)));
		WriteByte(MSG_MULTICAST, stof(argv(2)));
		WriteByte(MSG_MULTICAST, stof(argv(3)));
		WriteByte(MSG_MULTICAST, stof(argv(4)));
		WriteByte(MSG_MULTICAST, stof(argv(5)));
		WriteByte(MSG_MULTICAST, stof(argv(6)));
		WriteByte(MSG_MULTICAST, stof(argv(7)));
		WriteByte(MSG_MULTICAST, stof(argv(8)));
		WriteByte(MSG_MULTICAST, stof(argv(9)));
		WriteByte(MSG_MULTICAST, stof(argv(10)));
		WriteByte(MSG_MULTICAST, stof(argv(11)));

		msg_entity = this;
		multicast(origin, MULTICAST_PVS);
		break;
	default:
		NSTrigger::Input( eAct, strInput, strData );
	}
}
#endif

void NSEntity::SpawnKey( string strKey, string strValue ) {
	bool tempCheck = false;
	/* we do re-read a lot of the builtin fields in case we want to set
	   defaults. just in case anybody is wondering. */
	switch ( strKey ) {
	case "spawnflags":
		spawnflags = ReadFloat( strValue );
		break;
	case "origin":
		origin = ReadVector( strValue );
		break;
	case "model":
		model = ReadString(strValue);
		break;
	case "angles":
		angles = ReadVector( strValue );
		break;
	case "angle":
		angles[1] = ReadFloat( strValue );
		break;
	case "solid":
		solid = ReadFloat( strValue );
		break;
	case "friction":
		friction = ReadFloat( strValue );
		break;
#ifdef SERVER
	case "health":
		health = ReadFloat( strValue );
		break;
	case "movewith":
	case "parentname":
		SetParent( ReadString(strValue) );
		break;
	case "ignorepvs":
		tempCheck = ReadBool(strValue);

		if (tempCheck == true)
			pvsflags = PVSF_IGNOREPVS;
		else
			pvsflags &= ~PVSF_IGNOREPVS;

		break;
#endif
	case "_minlight":
		break;
	default:
		super::SpawnKey( strKey, strValue );
		break;
	}
}

void NSEntity::OnRemoveEntity( void ) {
}

void NSEntity::Destroy( void ) {
	removed = 1; /* mark this as cleanly removed */
	OnRemoveEntity();
	customphysics = __NULL__;
	modelindex = 0;
	solid = 0;
	movetype = 0;
	classname = 0;
	ScheduleThink(Util_Destroy, 0.0f );
}

void NSEntity::Show( void ) {
	effects &= ~EF_NODRAW;
}

void NSEntity::Hide( void ) {
	effects |= EF_NODRAW;
}

bool NSEntity::IsHidden( void ) {
	return ( effects & EF_NODRAW ) ? true : false;
}

void NSEntity::Disappear( void ) {
	modelindex = 0;
	solid = SOLID_NOT;
}

void NSEntity::MakeStatic( void ) {
	makestatic( this );
}

bool
NSEntity::CanSpawn(bool clientSide)
{
	/* in most cases, we don't need these to spawn on the client-side */
	if (clientSide)
		return false;
	else
		return true;
}

bool NSEntity::WithinBounds( entity check ) {
	if not ( check.absmin[0] >= absmin[0] && check.absmax[0] <= absmax[0] )
			return ( false );
	if not ( check.absmin[1] >= absmin[1] && check.absmax[1] <= absmax[1] )
			return ( false );
	if not ( check.absmin[2] >= absmin[2] && check.absmax[2] <= absmax[2] )
			return ( false );

	return ( true );
}

bool NSEntity::IntersectsWith( entity check ) {
	if not ( check.origin[0] >= absmin[0] && check.origin[0] <= absmax[0] )
			return ( false );
	if not ( check.origin[1] >= absmin[1] && check.origin[1] <= absmax[1] )
			return ( false );
	if not ( check.origin[2] >= absmin[2] && check.origin[2] <= absmax[2] )
			return ( false );

	return ( true );
}

bool NSEntity::StartSound( string strSample, float channel, float flags, bool broadcast ) {
	if not ( whichpack( strcat( "sound/", strSample ) ) ) 
		return ( false );

	if ( broadcast ) {
		sound( this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_FOLLOW );
	} else {
#ifdef SERVER
		msg_entity = this;
		sound( this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_UNICAST | SOUNDFLAG_FOLLOW);
		msg_entity = __NULL__;
#else
		sound( this, channel, strSample, 1.0f, ATTN_NORM, 0, SOUNDFLAG_FOLLOW );
#endif
	}

	SndEntLog( "%s (chan: %d bcast: %d) (%v)", strSample, channel, broadcast, origin );

	return ( true );
}

bool NSEntity::StartSoundDef( string strSample, float channel, bool broadcast ) {
	SndEntLog( "%s (chan: %d bcast: %d)", strSample, channel, broadcast );
	Sound_Play( this, channel, strSample );
	return ( true );
}

void NSEntity::StopSound( float channel, bool broadcast ) {
	sound( this, channel, "common/null.wav", 0.1f, ATTN_NORM );
}

vector NSEntity::NearestWallPointForRadius(float radius)
{
	vector vecRadius = [radius, radius, radius];
	tracebox(origin, -vecRadius, vecRadius, origin, MOVE_EVERYTHING, this);

	if (trace_fraction <= 1.0) {
		return trace_endpos;
	} else {
		return origin;
	}
}

void NSEntity::HandleThink( void ) {
	/* support for think/nextthink */
	if ( think && nextthink > 0.0f ) {
		if ( nextthink < time ) {
			nextthink = 0.0f;
			think();
		}
	}
}

bool NSEntity::IsFacing(entity target)
{
	vector vecDiff = normalize(target.origin - origin);
	makevectors(angles);
	return ((vecDiff * v_forward) > 0 ) ? true : false;
}

bool NSEntity::IsFacingPosition(vector targetPos)
{
	vector vecDiff = normalize(targetPos - origin);
	makevectors(angles);
	return ((vecDiff * v_forward) > 0 ) ? true : false;
}

float
NSEntity::GetSpawnAge(void)
{
	return time - m_flSpawnTime;
}

float
NSEntity::GetSpawnTime(void)
{
	return m_flSpawnTime;
}

void
NSEntity::Transport(vector new_pos, vector new_ang)
{
	float flSpeed = vlen(this.GetVelocity());
	makevectors(new_ang);
	SetVelocity(v_forward * flSpeed);

	SetOrigin(new_pos);
	SetAngles(new_ang);

#ifdef SERVER
	if (flags & FL_CLIENT)
		Client_FixAngle(this, new_ang);
#endif
}

void
NSEntity::Relink(void)
{
	setorigin(this, origin);
}

vector
NSEntity::GetNearbySpot(void)
{
	vector testPos;
	float minDist = maxs[0];
	makevectors([0,0,0]);

	/* space in front? */
	testPos = GetOrigin() + v_forward * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* behind? */
	testPos = GetOrigin() - v_forward * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;
	/* left? */
	testPos = GetOrigin() - v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* right? */
	testPos = GetOrigin() + v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* front left? */
	testPos = GetOrigin() + v_forward * minDist - v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* front right? */
	testPos = GetOrigin() + v_forward * minDist + v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* back left? */
	testPos = GetOrigin() - v_forward * minDist - v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	/* back right? */
	testPos = GetOrigin() - v_forward * minDist + v_right * minDist;
	tracebox(testPos, mins, maxs, testPos, MOVE_NORMAL, this);

	if (trace_fraction == 1.0f)
		return testPos;

	return g_vec_null;
}
