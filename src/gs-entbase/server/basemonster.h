/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

typedef struct
{
	vector m_vecDest;
	int m_iFlags;
} nodeslist_t;

/* movement states */
enum
{
	MONSTER_IDLE,
	MONSTER_FOLLOWING,
	MONSTER_CHASING,
	MONSTER_AIMING,
	MONSTER_DEAD,
	MONSTER_GIBBED
};

/* scripted sequence states */
enum
{
	SEQUENCESTATE_NONE,
	SEQUENCESTATE_IDLE,
	SEQUENCESTATE_ACTIVE,
	SEQUENCESTATE_ENDING
};

/* monster flags */
enumflags
{
	MSF_WAITTILLSEEN,
	MSF_GAG,
	MSF_MONSTERCLIP,
	MSF_RESERVED1,
	MSF_PRISONER,
	MSF_RESERVED2,
	MSF_RESERVED3,
	MSF_WAITFORSCRIPT,
	MSF_PREDISASTER,
	MSF_FADECORPSE,
	MSF_MULTIPLAYER
};

/* alliance state */
enum
{
	MAL_FRIEND, /* friendly towards the player */
	MAL_ENEMY,  /* unfriendly towards the player */
	MAL_ALIEN,  /* unfriendly towards anyone but themselves */
	MAL_ROGUE   /* no allies, not even amongst themselves */
};

.int m_iAlliance;

class CBaseMonster:CBaseEntity
{
	vector oldnet_velocity;
	float m_flPitch;
	int m_iFlags;
	vector base_mins;
	vector base_maxs;
	int base_health;

	/* sequences */
	string m_strRouteEnded;
	int m_iSequenceRemove;
	int m_iSequenceState;
	float m_flSequenceEnd;
	float m_flSequenceSpeed;
	vector m_vecSequenceAngle;
	vector m_vecTurnAngle;

	/* model events */
	float m_flBaseTime;

	/* attack/alliance system */
	entity m_eEnemy;
	float m_flFOV;
	float m_flAttackThink;
	int m_iMState;
	vector m_vecLKPos; /* last-known pos */

	/* pathfinding */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	vector m_vecLastNode;

	void(void) CBaseMonster;
	virtual void(void) touch;
	virtual void(void) Hide;
	virtual void(void) Respawn;
	virtual void(void) PlayerUse;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) Physics;
	virtual void(void) IdleNoise;
	virtual void(void) Gib;
	virtual void(string) Sound;
	virtual void(float, int, string) ModelEvent;

	/* see/hear subsystem */
	float m_flSeeTime;
	virtual void(void) SeeThink;
	virtual float(void) SeeFOV;

	/* attack system */
	virtual void(void) AttackDraw;
	virtual void(void) AttackHolster;
	virtual void(void) AttackThink;
	virtual int(void) AttackMelee;
	virtual int(void) AttackRanged;

	/* sequences */
	virtual void(void) FreeState;
	virtual void(void) FreeStateMoved;
	virtual void(void) ClearRoute;
	virtual void(void) CheckRoute;
	virtual void(void) WalkRoute;
	virtual void(vector) NewRoute;

	/* animation cycles */
	float m_flAnimTime;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
	virtual void(float) AnimPlay;
};
