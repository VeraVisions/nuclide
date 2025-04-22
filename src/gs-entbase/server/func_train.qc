/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Linear Moving Brush */
/*!QUAKED func_train (0 .5 .8) ? WAIT x x NOT_SOLID
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
- WAIT (1) : Stop at each path_corner until we're triggered again.
- NOT_SOLID (8) : Don't do collision testing against this entity.

# NOTES
Upon level entry, the func_train will spawn right where its first path_corner
node is. This is so you can light the func_train somewhere else - like a lonely
box somewhere outside the playable area.

If no targetname is specified, the train will move on its own at map-launch.

Marking the func_train with the spawnflag NOT_SOLID will make entities not
collide with the train. This is best used for things in the distance or for
when lasers are following this train as a sort of guide.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
func_train:ncRenderableEntity
{
	float m_flWait;
	float m_flSpeed;
	float m_flDamage;
	float m_flCurrentSpeed;

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

	nonvirtual void SoundMove(void);
	nonvirtual void SoundStop(void);
	nonvirtual void AfterSpawn(void);
	nonvirtual void PathNext(void);
	nonvirtual void PathMove(void);
	nonvirtual void PathDone(void);
	virtual void Blocked(entity);
};

void
func_train::func_train(void)
{
	m_flWait = 0.0f;
	m_flSpeed = 0.0f;
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
	SaveFloat(handle, "m_flCurrentSpeed", m_flCurrentSpeed);
	SaveString(handle, "m_strMoveSnd", m_strMoveSnd);
	SaveString(handle, "m_strStopSnd", m_strStopSnd);
}

void
func_train::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flWait":
		m_flWait = ReadFloat(setValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(setValue);
		break;
	case "m_flDamage":
		m_flDamage = ReadFloat(setValue);
		break;
	case "m_flCurrentSpeed":
		m_flCurrentSpeed = ReadFloat(setValue);
		break;
	case "m_strMoveSnd":
		m_strMoveSnd = ReadString(setValue);
		break;
	case "m_strStopSnd":
		m_strStopSnd = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_train::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "dmg":
		m_flDamage = stof(setValue);
		break;
	case "snd_move":
		m_strMoveSnd = setValue;
		break;
	case "snd_stop":
		m_strStopSnd = setValue;
		break;
	case "speed":
		m_flSpeed = ReadFloat(setValue);
		break;
	/* compatibility */
	case "movesnd":
		m_strMoveSnd = sprintf("func_train.move_%i", stoi(setValue) + 1i);
		break;
	case "stopsnd":
		m_strStopSnd = sprintf("func_train.stop_%i", stoi(setValue) + 1i);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_train::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_strMoveSnd);
	precache.Sound(m_strStopSnd);
}

void
func_train::Respawn(void)
{
	super::Respawn();

	SetSolid(HasSpawnFlags(TRAIN_NOTSOLID) ? SOLID_NOT : SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);

	/* let's wait 1/4 a second to give the path_corner entities a chance to
	 * spawn in case they're after us in the ent lump */
	SetTriggerTarget(GetSpawnString("target"));
	ScheduleThink(AfterSpawn, 0.25f);
}

void
func_train::Blocked(entity eBlocker)
{
	vector center;
	vector dmgDir;
	ncDict damageDecl;
	ncSurfacePropEntity toAttack = (ncSurfacePropEntity)eBlocker;

	/* HACK: Make corpses gib instantly */
	if (is.Sentient(eBlocker) && eBlocker.solid == SOLID_CORPSE) {
		center = WorldSpaceCenter();
		dmgDir = dirFromTarget(center, eBlocker.origin);
		damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", "500");
		toAttack.Damage(this, eBlocker, damageDecl, 1.0f, center, dmgDir, eBlocker.origin);
		remove(damageDecl);
		return;
	}

	if (eBlocker.takedamage != DAMAGE_NO) {
		center = WorldSpaceCenter();
		dmgDir = dirFromTarget(center, eBlocker.origin);
		damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", ftos(m_flDamage));
		toAttack.Damage(this, eBlocker, damageDecl, 1.0f, center, dmgDir, eBlocker.origin);
		remove(damageDecl);
	} else {
		/* remove(eBlocker); */
	}
}

void
func_train::SoundMove(void)
{
	if (m_strMoveSnd) {
		StartSoundDef(m_strMoveSnd, CHAN_VOICE, true);
	}
}

void
func_train::SoundStop(void)
{
	if (m_strStopSnd) {
		StartSoundDef(m_strStopSnd, CHAN_BODY, true);
	}

	if (m_strMoveSnd) {
		sound(this, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM);
	}
}

void
func_train::PathMove(void)
{
	path_corner eNode;
	float flTravelTime;
	vector vecVelocity;
	vector vecWorldPos;

	if (!target)
		return;

	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	vecWorldPos = WorldSpaceCenter();
	vecVelocity = (eNode.origin - vecWorldPos);
	flTravelTime = (vlen(vecVelocity) / m_flCurrentSpeed);

	if (!flTravelTime) {
		print("^1func_train::^3PathMove^7: Distance short, going next\n");
		ClearVelocity();
		ScheduleThink(PathNext, 0.0f);
		return;
	}

	SoundMove();
	EntLog("Travelling at %f up/s", m_flSpeed);

	SetVelocity(vecVelocity * (1 / flTravelTime));
	ScheduleThink(PathNext, flTravelTime);
}

void
func_train::PathDone(void)
{
	path_corner eNode = __NULL__;

	eNode = (path_corner)find(world, ::targetname, target);

	if (!eNode) {
		return;
	}

	if (HasTargetname()) {
		EntLog("func_train (id %d, name %S): Touched base with path_corner %S", num_for_edict(this), targetname, target);
	} else {
		EntLog("func_train (id %d): Touched base with path_corner %S", num_for_edict(this), target);
	}

	/* fire the path_corners' target */
	eNode.PathPassTrigger(this, TRIG_TOGGLE);
	SoundStop();
}

void
func_train::PathNext(void)
{
	path_corner eNode = __NULL__;

	/* it's not as critical here to not have a target anymore */
	if (HasTriggerTarget() == false) {
		return;
	}

	eNode = (path_corner)find(world, ::targetname, target);

	/* a little more serious, but we don't want to break the map. */
	if (eNode == __NULL__) {
		ncError("func_tracktrain (id %d) target %S does not exist.", num_for_edict(this), target);
		return;
	}

	SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	PathDone();
	m_flWait = eNode.DesiredWaitTime();
	SetTriggerTarget(eNode.target);
	ClearVelocity();

	if (eNode.DesiredTrainSpeed() > 0.0f) {
		m_flCurrentSpeed = eNode.DesiredTrainSpeed();
	} else {
		m_flCurrentSpeed = m_flSpeed;
	}

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
	path_corner eNode = __NULL__;

	if (HasTriggerTarget() == false) {
		print(sprintf("func_tracktrain (id %d) has no target.\n", num_for_edict(this)));
		Destroy();
		return;
	}

	eNode = (path_corner)find(world, ::targetname, target);

	if (eNode == __NULL__) {
		print(sprintf("func_tracktrain (id %d) target %S does not exist.\n", num_for_edict(this), target));
		Destroy();
		return;
	}

	/* place us to the first node. */
	SetOrigin(eNode.origin - (mins + maxs) * 0.5);
	SetTriggerTarget(eNode.target);
	ClearVelocity();
	PathDone();

	/* FIXME: Is this authentic? */
	if (eNode.DesiredTrainSpeed() > 0.0f) {
		m_flCurrentSpeed = eNode.DesiredTrainSpeed();
	} else {
		m_flCurrentSpeed = m_flSpeed;
	}

	m_flSpeed = m_flCurrentSpeed;

	/* if we're unable to be triggered by anything, begin moving */
	if (HasTargetname() == false) {
		PathMove();
	}
}
