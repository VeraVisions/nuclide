/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifndef PHYSICS_STATIC
#define PRPPHYS_ASLEEP 1

/*!QUAKED prop_physics_multiplayer (1 0 0) (-16 -16 -16) (16 16 16) PRPPHYS_ASLEEP
# OVERVIEW
Physics prop that is optimised for netplay.
It either pushes the player away, or gets pushed away by the player.
The simulation can take place on either client or server.

# KEYS
- "targetname" : Name
- "physicsmode" : Which type of push/simulation model to use. See notes.

# NOTES
'physicsmode' can be one of three things:
    1. push player away
    2. get pushed (server-side)
    3. get pushed (client-side)

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class prop_physics_multiplayer:NSPhysicsEntity
{
public:
	void prop_physics_multiplayer(void);

#ifdef CLIENT
	virtual void Init(void);
#endif
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual void Touch(entity);
	virtual void TouchThink(void);

private:
	int m_iPhysicsMode;
};

void
prop_physics_multiplayer::TouchThink(void)
{
	//super::TouchThink();

	{
		float oldsolid, oldmovetype;
		/* let players collide */
		dimension_solid = 255;
		dimension_hit = 255;
		oldsolid = solid;
		oldmovetype = movetype;
		movetype = MOVETYPE_NONE;
		solid = SOLID_TRIGGER;
		tracebox(origin, mins, maxs, origin, MOVE_NORMAL, this);
		solid = oldsolid;
		movetype = oldmovetype;
		dimension_solid = 1;
		dimension_hit = 1;

		if (trace_ent.flags & FL_CLIENT) {
			//print(sprintf("%s %f\n", trace_ent.classname, trace_fraction));
			Wake();
			makevectors(origin - trace_ent.origin);
			ApplyForceOffset(v_forward * 64, trace_endpos);
			velocity = v_forward * 64;
		}
	}

	if (m_iPhysicsMode == 3) {
	} else {
		if (vlen(velocity) < 2) {
			velocity = [0,0,0];
			Sleep();
		}
	}

	nextthink = time;
}

void
prop_physics_multiplayer::Touch(entity eToucher)
{
	/* we want to push our toucher away */
	if (eToucher && eToucher.flags & FL_CLIENT)
	if (m_iPhysicsMode == 1) {
		makevectors(eToucher.origin - origin);
		eToucher.velocity = v_forward * 256;
	}

	super::Touch(eToucher);
	nextthink = time;
}

void
prop_physics_multiplayer::Respawn(void)
{
#ifdef SERVER
	if (m_iPhysicsMode == 3) {
#else
	if (m_iPhysicsMode != 3) {
#endif
		Destroy();
		return;
	}

#ifdef SERVER
	dimension_solid = 1;
	dimension_hit = 1;
#endif

	super::Respawn();

	if (HasSpawnFlags(PRPPHYS_ASLEEP))
		Sleep();
	else
		Wake();
}

void
prop_physics_multiplayer::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "physicsmode":
		m_iPhysicsMode = stoi(strValue);
		break;
	default:
		NSPhysicsEntity::SpawnKey(strKey, strValue);
	}
}

#ifdef CLIENT
void
prop_physics_multiplayer::Init(void)
{
	super::Init();

	m_oldAngle = angles;
	m_oldOrigin = origin;
	m_oldModel = Util_FixModel(model);

	Respawn();
	drawmask = MASK_ENGINE;
}
#endif

void
prop_physics_multiplayer::prop_physics_multiplayer(void)
{
}

#else
#ifdef SERVER
class prop_physics_multiplayer:NSRenderableEntity
{
	void(void) prop_physics_multiplayer;
	virtual void(void) Respawn;
};

void
prop_physics_multiplayer::Respawn(void)
{
	super::Respawn();
	SetSolid(SOLID_BBOX);
}

void
prop_physics_multiplayer::prop_physics_multiplayer(void)
{
}
#endif
#endif
