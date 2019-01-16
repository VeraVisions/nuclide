/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{ 
	RM_NORMAL,
	RM_COLOR,
	RM_TEXTURE,
	RM_GLOW,
	RM_SOLID,
	RM_ADDITIVE
};

class CBaseEntity
{
	string m_oldModel;
	float m_oldSolid;
	float m_oldHealth;
	vector m_oldOrigin;
	vector m_oldAngle;
	
	float m_rendermode;
	float m_renderamt;
	vector m_rendercolor;
	
	void() CBaseEntity;
	virtual void() Respawn;
	virtual void() Hide;
	virtual void() RendermodeUpdate;
};

void CBaseEntity :: CBaseEntity ( void )
{
	/* Not in Deathmatch */
	if (spawnflags & 2048) {
		if (cvar("sv_playerslots") > 1) {
			remove(this);
			return;
		}
	}
	
	/*m_renderamt = 255;
	m_rendercolor = [1,1,1];
	m_rendermode = 0;*/

	gflags |= GF_CANRESPAWN;
	m_oldModel = Util_FixModel(model);
	m_oldSolid = solid;
	m_oldHealth = health;
	m_oldOrigin = origin;
	m_oldAngle = angles;

	int nfields = tokenize( __fullspawndata );
	for ( int i = 1; i < ( nfields - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "renderamt":
			m_renderamt = stof( argv( i + 1 ) );
			break;
		case "rendercolor":
			m_rendercolor = stov( argv( i + 1 ) );
			break;
		case "rendermode":
			m_rendermode = stof( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}

	RendermodeUpdate();
}

void CBaseEntity::RendermodeUpdate(void)
{
	if (m_rendermode == RM_NORMAL) {
		return;
	}
	
	if (m_rendermode == RM_SOLID && m_renderamt != 0) {
		return;
	}

	colormod = m_rendercolor / 255;
	alpha = bound(0.001, ( m_renderamt / 255 ), 1.0);

	if ( m_rendermode == RM_ADDITIVE ) {
		effects = EF_ADDITIVE; // QWSSQC: EF_FLAG2
	} else if ( m_rendermode == RM_GLOW ) {
		effects = EF_ADDITIVE | EF_FULLBRIGHT;
	}
	
}

void CBaseEntity :: Respawn ( void )
{
	model = m_oldModel;
	solid = m_oldSolid;
	health = m_oldHealth;
	origin = m_oldOrigin;
	angles = m_oldAngle;
	setorigin( this, origin );
	setmodel( this, model );
}

void CBaseEntity :: Hide ( void )
{
	setmodel( this, "" );
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
}
