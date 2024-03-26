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

typedef enum
{
	PUSHABLESIZE_POINT,
	PUSHABLESIZE_PLAYER,
	PUSHABLESIZE_BIG,
	PUSHABLESIZE_DUCKING,
	PUSHABLESIZE_CUSTOM,
} pushSize_t;


#define PUSH_SIZE_POINT_MIN [-8,-8,-8]
#define PUSH_SIZE_POINT_MAX [8,8,8]

#define PUSH_SIZE_PLAYER_MIN [-16,-16,-36]
#define PUSH_SIZE_PLAYER_MAX [16,16,36]

#define PUSH_SIZE_BIG_MIN [-32,-32,-72]
#define PUSH_SIZE_BIG_MAX [32,32,72]

#define PUSH_SIZE_DUCKING_MIN [-16,-16,-18]
#define PUSH_SIZE_DUCKING_MAX [16,16,18]

#define FNCPUSHABLE_BREAKABLE 128

/*!QUAKED func_pushable (0 .5 .8) ? SF_TRIGGER SF_TOUCH SF_PRESSURE x x x x BREAKABLE
# OVERVIEW
This is essentially the same entity as a func_breakable, but
a player can push and pull it around the level.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "friction" : Friction of the pushable. Default is 50.
- "size" : Hull size to use. 0: Point, 1: Player, 2: Big, 3: Player Crouched

# SPAWNFLAGS
- SF_TRIGGER (1) : Break only when triggered.
- SF_TOUCH (2) : Touch can break.
- SF_PRESSURE (4) : Standing on top can break.

# NOTES
It uses stepping player physics to move around.
Please look at func_breakable for more entity keys, inputs and outputs.

The 'size' key only has to be specified when you use levels with hull-sizes.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
func_pushable:func_breakable
{
public:
	void func_pushable(void);

	virtual void Spawned(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void customphysics(void);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void OnPlayerUse(void);
	virtual void OnRemoveEntity(void);

private:
	entity m_pPuller;
	entity m_eCollBox;
	pushSize_t m_dHullSize;
	float m_flPushFriction;
	bool m_bIsMoving;
};

void
func_pushable::func_pushable(void)
{
	m_pPuller = __NULL__;
	m_eCollBox = __NULL__;
	m_dHullSize = PUSHABLESIZE_CUSTOM;
	m_flPushFriction = 0.5;
}

void
func_pushable::Spawned(void)
{
	super::Spawned();
}

void
func_pushable::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "size":
		switch (ReadFloat(setValue)) {
		case 1:
			m_dHullSize = PUSHABLESIZE_PLAYER;
			break;
		case 2:
			m_dHullSize = PUSHABLESIZE_BIG;
			break;
		case 3:
			m_dHullSize = PUSHABLESIZE_DUCKING;
			break;
		default:
			m_dHullSize = PUSHABLESIZE_POINT;
			break;
		}
		break;
	case "friction":
		m_flPushFriction = ReadFloat(setValue) / 100;
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
func_pushable::Save(float saveHandle)
{
	super::Save(saveHandle);
	SaveEntity(saveHandle, "m_pPuller", m_pPuller);
	SaveEntity(saveHandle, "m_eCollBox", m_eCollBox);
	SaveFloat(saveHandle, "m_dHullSize", m_dHullSize);
	SaveFloat(saveHandle, "m_flPushFriction", m_flPushFriction);
}

void
func_pushable::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_pPuller":
		m_pPuller = ReadEntity(setValue);
		break;
	case "m_eCollBox":
		m_eCollBox = ReadEntity(setValue);
		break;
	case "m_dHullSize":
		m_dHullSize = ReadFloat(setValue);
		break;
	case "m_flPushFriction":
		m_flPushFriction = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
func_pushable::Respawn(void)
{
	super::Respawn();
	SetSolid(SOLID_BSP);
	SetOrigin(GetSpawnOrigin());
	SetMovetype(MOVETYPE_STEP);
	PlayerUse = OnPlayerUse;

	if (HasSpawnFlags(FNCPUSHABLE_BREAKABLE) == true) {
		SetTakedamage(DAMAGE_YES);
	} else {
		SetTakedamage(DAMAGE_NO);
	}

	if (!m_eCollBox) {
		m_eCollBox = spawn();
		m_eCollBox.classname = "func_pushable_bbox";
		m_eCollBox.solid = SOLID_TRIGGER;
		m_eCollBox.owner = this;
		setsize(m_eCollBox, -(size/2) * 0.9f, (size/2) * 0.9f);
		setorigin(m_eCollBox, WorldSpaceCenter());
	}

	/* size overrides for Q1 BSP */
	if (m_dHullSize != PUSHABLESIZE_CUSTOM) {
		switch (m_dHullSize) {
		case PUSHABLESIZE_PLAYER:
			setsize(m_eCollBox, PUSH_SIZE_PLAYER_MIN, PUSH_SIZE_PLAYER_MAX);
			break;
		case PUSHABLESIZE_BIG:
			setsize(m_eCollBox, PUSH_SIZE_BIG_MIN, PUSH_SIZE_BIG_MAX);
			break;
		case PUSHABLESIZE_DUCKING:
			setsize(m_eCollBox, PUSH_SIZE_DUCKING_MIN, PUSH_SIZE_DUCKING_MAX);
			break;
		default:
			setsize(m_eCollBox, PUSH_SIZE_POINT_MIN, PUSH_SIZE_POINT_MAX);
		}
	}

	/* force it to move around abit by the next frame */
	SetVelocity([0,0,1]);
}

void
func_pushable::OnRemoveEntity(void)
{
	if (m_eCollBox)
		remove(m_eCollBox);
}

void
func_pushable::customphysics(void)
{
	bool wasMoving;
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;
	input_angles = [0,0,0];
	input_timelength = frametime;

	/* we're destroyed, most likely */
	if (m_eCollBox)
	if (modelindex == 0) {
		m_eCollBox.solid = SOLID_NOT;
	} else {
		m_eCollBox.solid = SOLID_TRIGGER;
	}

	wasMoving = m_bIsMoving;

	if (vlen(velocity) <= 0.0) {
		m_bIsMoving = false;
	} else {
		m_bIsMoving = true;
	}

	if (m_bIsMoving != wasMoving && m_bIsMoving == true) {
		StartSoundDef(GetSurfaceData(SURFDATA_SND_SCRAPESOFT), CHAN_BODY, true);
	}

	/* when we pull the box, it'll follow us whereever we go, just not too fast so it doesn't clip into us! */
	if (!m_pPuller.button5) {
		m_pPuller = world;
	} else {
		/* drag us, make sure we don't collide */
		velocity[0] = m_pPuller.velocity[0];// * 0.9f;
		velocity[1] = m_pPuller.velocity[1];// * 0.9f;
	}

	/* see if we're clipping against entities or other func_pushable_bbox helper entities */
	vector position = WorldSpaceCenter();

	/* if we're too far away from our box, split */
	if ((vlen(m_pPuller.origin - position) - vlen(size)) > 64)
		m_pPuller = world;

	tracebox(position, m_eCollBox.mins, m_eCollBox.maxs, \
		position + (velocity * input_timelength), MOVE_NORMAL, this);

	if (trace_fraction < 1.0f)
		return;

	/* run the physics, then fix our helper bbox! */
	friction = m_flPushFriction;

	if (vlen(velocity))
		runstandardplayerphysics(this);

	if (m_eCollBox)
		setorigin(m_eCollBox, position);
}

void
func_pushable::Touch(entity eToucher)
{
	vector pusherPosition = eToucher.origin;
	vector pushableOrigin;

	/* don't cause bounces */
	if (eToucher.movetype == MOVETYPE_NONE) {
		return;
	}

	/* check if we're inside the pushable */
	if (eToucher.origin[0] >= absmin[0] && eToucher.origin[0] <= absmax[0])
	if (eToucher.origin[1] >= absmin[1] && eToucher.origin[1] <= absmax[1])
		return;

	/* check if we're above the pushable... */
	if ((eToucher.absmin[2] + 16) >= absmax[2]) {
		return;
	}

	pushableOrigin = WorldSpaceCenter();
	pusherPosition[2] = pushableOrigin[2];

	/* get the direction of the pushing player towards the pushable, then get a matrix */
	makevectors(vectoangles(pusherPosition - pushableOrigin));

	/* add forward direction times speed */
	velocity = v_forward * -64;
}

void
func_pushable::OnPlayerUse(void)
{
	m_pPuller = eActivator;
}
