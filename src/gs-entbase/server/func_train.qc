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

enumflags
{
	TRAIN_WAIT,
	TRAIN_UNUSED1,
	TRAIN_UNUSED2,
	TRAIN_NOTSOLID
};

/*!QUAKED func_train (0 .5 .8) ? TRAIN_WAIT x x TRAIN_NOTSOLID
# OVERVIEW
Moving platform following along path_corner entities, aka nodes.
Most of its behaviour is controlled by the path_corner entities it passes over.
See the entity definition for path_corner to find out more.

# KEYS
- "targetname" : Name
- "target" : First node.
- "killtarget" : Target to kill when triggered.
- "dmg" : Damage to inflict upon a person blocking the way.
- "snd_move" : Path to sound sample which plays when it's moving.
- "snd_stop" : Path to sound sample which plays when it stops moving.

# SPAWNFLAGS
- TRAIN_WAIT (1) : Stop at each path_corner until we're triggered again.
- TRAIN_NOTSOLID (8) : Don't do collision testing against this entity.

# NOTES
Upon level entry, the func_train will spawn right where its first path_corner
node is. This is so you can light the func_train somewhere else - like a lonely
box somewhere outside the playable area.

If no targetname is specified, the train will move on its own at map-launch.

Marking the func_train with the flag TRAIN_NOTSOLID will make entities not
collide with the train. This is best used for things in the distance or for
when lasers are following this train as a sort of guide.

# TRIVIA
This entity was introduced in Quake (1996).
*/
class
func_train:NSRenderableEntity
{
	float m_flWait;
	float m_flSpeed;
	float m_flDamage;
	string m_strMoveSnd;
	string m_strStopSnd;

public:
	void func_train(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	
	virtual void SoundMove(void);
	virtual void SoundStop(void);
	virtual void AfterSpawn(void);
	virtual void PathNext(void);
	virtual void PathMove(void);
	virtual void PathDone(void);
	virtual void Blocked(entity);
};

void
func_train::func_train(void)
{
	m_flWait = 0.0f;
	m_flSpeed = 100.0f; /* FIXME: This is all decided by the first path_corner pretty much */
	m_flDamage = 0.0f;
	m_strMoveSnd = __NULL__;
	m_strStopSnd = __NULL__;
}

void
func_train::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flDamage", m_flDamage);
	SaveString(handle, "m_strMoveSnd", m_strMoveSnd);
	SaveString(handle, "m_strStopSnd", m_strStopSnd);
}

void
func_train::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flDamage":
		m_flDamage = ReadFloat(strValue);
		break;
	case "m_strMoveSnd":
		m_strMoveSnd = ReadString(strValue);
		break;
	case "m_strStopSnd":
		m_strStopSnd = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_train::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "dmg":
		m_flDamage = stof(strValue);
		break;
	case "snd_move":
		m_strMoveSnd = strValue;
		break;
	case "snd_stop":
		m_strStopSnd = strValue;
		break;
	/* compatibility */
	case "movesnd":
		m_strMoveSnd = sprintf("func_train.move_%i", stoi(strValue) + 1i);
		break;
	case "stopsnd":
		m_strStopSnd = sprintf("func_train.stop_%i", stoi(strValue) + 1i);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_train::Spawned(void)
{
	super::Spawned();

	if (m_strMoveSnd)
		Sound_Precache(m_strMoveSnd);
	if (m_strStopSnd)
		Sound_Precache(m_strStopSnd);
}

void
func_train::Respawn(void)
{
	SetSolid(HasSpawnFlags(TRAIN_NOTSOLID) ? SOLID_NOT : SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());

	/* let's wait 1/4 a second to give the path_corner entities a chance to
	 * spawn in case they're after us in the ent lump */
	SetTriggerTarget(m_oldstrTarget);
	ScheduleThink(AfterSpawn, 0.25f);
}

void
func_train::Blocked(entity eBlocker)
{
	/* HACK: Make corpses gib instantly */
	if (other.solid == SOLID_CORPSE) {
		Damage_Apply(eBlocker, this, 500, 0, DMG_EXPLODE);
		return;
	}

	if (other.takedamage != DAMAGE_NO) {
		Damage_Apply(eBlocker, this, m_flDamage, 0, DMG_CRUSH);
	} else {
		remove(eBlocker);
	}
}

void
func_train::SoundMove(void)
{
	if (m_strMoveSnd) {
		Sound_Play(this, CHAN_VOICE, m_strMoveSnd);
	}
}

void
func_train::SoundStop(void)
{
	if (m_strStopSnd) {
		Sound_Play(this, CHAN_BODY, m_strStopSnd);
	}

	if (m_strMoveSnd) {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}
}

void
func_train::PathMove(void)
{
	entity eNode;
	float flTravelTime;
	vector vecVelocity;
	vector vecWorldPos;

	eNode = find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	vecWorldPos = WorldSpaceCenter();
	vecVelocity = (eNode.origin - vecWorldPos);
	flTravelTime = (vlen(vecVelocity) / m_flSpeed);

	if (!flTravelTime) {
		print("^1func_train::^3PathMove^7: Distance short, going next\n");
		ClearVelocity();
		ScheduleThink(PathNext, 0.0f);
		return;
	}

	SoundMove();

	SetVelocity(vecVelocity * (1 / flTravelTime));
	ScheduleThink(PathNext, flTravelTime);
}

void
func_train::PathDone(void)
{
	path_corner eNode;
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	NSLog("func_train (%s): Touched base with path_corner %S", targetname, target);

	/* fire the path_corners' target */
	if (eNode.m_strMessage) {
		eNode.Trigger(this, TRIG_TOGGLE);
	}
	SoundStop();
}

void
func_train::PathNext(void)
{
	path_corner eNode;
	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	PathDone();

	/* if speed is 0, retain current speed */
	if (eNode.m_flSpeed > 0)
		m_flSpeed = eNode.m_flSpeed;

	m_flWait = eNode.m_flWait;
	SetTriggerTarget(eNode.target);
	ClearVelocity();

	/* warp */
	if (eNode.HasSpawnFlags(PC_TELEPORT)) {
		SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	}

	/* stop until triggered again */
	if (eNode.HasSpawnFlags(PC_WAIT) || HasSpawnFlags(TRAIN_WAIT)) {
		SoundStop();
		return;
	}

	/* move after delay, or instantly when none is given */
	if (m_flWait > 0) {
		ScheduleThink(PathMove, m_flWait);
	} else {
		PathMove();
	}
}

/* TODO: Handle state? */
void
func_train::Trigger(entity act, triggermode_t state)
{
	PathMove();
}

void
func_train::AfterSpawn(void)
{
	PathNext();

	/* if we're unable to be triggered by anything, begin moving */
	if (HasTargetname() == false) {
		PathMove();
	}
}
