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
	TRIGTELE_MONSTERS,
	TRIGTELE_NOCLIENTS,
	TRIGTELE_PUSHABLES
};

/*! \brief Server-Entity: Teleportation Volume */
/*!QUAKED trigger_teleport (.5 .5 .5) ? CLIENTS NPCS PUSHABLES PHYSICS FRIENDLIES CLIENTSINVEHICLES EVERYTHING x x CLIENTSNOTINVEHICLES DEBRIS NPCSINVEHICLES NOBOTS
# OVERVIEW
Teleportation volume. Teleports anything it touches to the position of
any entity set as the "target".

# KEYS
- "targetname" : Name
- "target" : Which target to teleport to.
- "snd_teleport" : SoundDef to play on the entity teleporting.
- "snd_teleport_enter" : SoundDef to play on the teleporter entrance.
- "snd_teleport_exit" : SoundDef to play on the teleporter exit.
- "StartDisabled" : Entity will have to be enabled in order to work when set to 1.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# SPAWNFLAGS
- TF_CLIENTS (1) : Clients can touch it.
- TF_NPCS (2) : NPCs can touch it.
- TF_PUSHABLE (4) : Pushables can touch it.
- TF_PHYSICS (8) : ncPhysicsEntity based classes can touch it.
- TF_FRIENDLIES (16) : Friendly NPCs can touch it.
- TF_CLIENTSINVEHICLES (32) : Clients within vehicles can touch it.
- TF_EVERYTHING (64) : Everything can touch it.
- TF_CLIENTSNOTINVEHICLES (512) : Clients outside vehicles can touch it.
- TF_DEBRIS (1024) : Debris can touch it.
- TF_NPCSINVEHICLES (2048) : NPCs in vehicles can touch it.
- TF_NOBOTS (4096) : Bots are never allowed to touch it.

# SPAWNFLAGS (LEGACY)
These work when 'StartDisabled' is not set in the entity definition.

- TM_MONSTERS (1) : Allow NPCs to activate this entity.
- TM_NOCLIENTS (2) : Don't allow players to activate this entity.
- TM_PUSHABLES (4) : Allow func_pushables to trigger this entity.

# NOTES
Works best with info_teleport_destination, but you can in theory use any other point entity as well.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup brushentity
*/
class
trigger_teleport:ncBrushTrigger
{
public:
	void trigger_teleport(void);
	
	virtual void Touch(entity);

	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);

	nonvirtual bool CanPass(ncEntity);

private:
	bool m_teleporterActive;
	string m_sndTeleport;
	string m_sndTeleportEnter;
	string m_sndTeleportExit;
	bool m_sourceVersion;
	string m_outputOnTeleportingEntity;
	string m_outputOnTeleFrag;
};

void
trigger_teleport::trigger_teleport(void)
{
	m_outputOnTeleportingEntity = __NULL__;
	m_outputOnTeleFrag = __NULL__;
	m_sndTeleport = __NULL__;
	m_sndTeleportEnter = __NULL__;
	m_sndTeleportExit = __NULL__;
	m_teleporterActive = true;
	m_sourceVersion = false;
}

void
trigger_teleport::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "snd_teleport":
		m_sndTeleport = setValue;
		break;
	case "snd_teleport_enter":
		m_sndTeleportEnter = setValue;
		break;
	case "snd_teleport_exit":
		m_sndTeleportExit = setValue;
		break;
	case "StartDisabled":
		m_teleporterActive = ReadBool(setValue);
		m_sourceVersion = true;
		break;
	case "OnTeleportingEntity":
		m_outputOnTeleportingEntity = PrepareOutput(m_outputOnTeleportingEntity, setValue);
		break;
	case "OnTeleFrag":
		m_outputOnTeleFrag = PrepareOutput(m_outputOnTeleFrag, setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
trigger_teleport::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "teleporterActive", m_teleporterActive);
	SaveString(handle, "sndTeleport", m_sndTeleport);
	SaveString(handle, "sndTeleportEnter", m_sndTeleportEnter);
	SaveString(handle, "sndTeleportExit", m_sndTeleportExit);
	SaveBool(handle, "sourceVersion", m_sourceVersion);
}

void
trigger_teleport::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "teleporterActive":
		m_teleporterActive = ReadBool(setValue);
		break;
	case "sndTeleport":
		m_sndTeleport = ReadString(setValue);
		break;
	case "sndTeleportEnter":
		m_sndTeleportEnter = ReadString(setValue);
		break;
	case "sndTeleportExit":
		m_sndTeleportExit = ReadString(setValue);
		break;
	case "sourceVersion":
		m_sourceVersion = ReadBool(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

bool
trigger_teleport::CanPass(ncEntity target)
{
	/* legacy entity check */
	if (m_sourceVersion == false) {
		if (HasSpawnFlags(TRIGTELE_NOCLIENTS) && target.flags & FL_CLIENT)
			return false;
		if (!HasSpawnFlags(TRIGTELE_MONSTERS) && target.flags & FL_MONSTER)
			return false;
		if (!HasSpawnFlags(TRIGTELE_PUSHABLES) && target.classname == "func_pushable")
			return false;
	} else {
		if (CanBeTriggeredBy(target) == false)
			return false;
	}

	return true;
}

void
trigger_teleport::Spawned(void)
{
	super::Spawned();

	precache.Sound(m_sndTeleport);
	precache.Sound(m_sndTeleportEnter);
	precache.Sound(m_sndTeleportExit);

	if (STRING_SET(m_outputOnTeleportingEntity))
		m_outputOnTeleportingEntity = CreateOutput(m_outputOnTeleportingEntity);
	if (STRING_SET(m_outputOnTeleFrag))
		m_outputOnTeleFrag = CreateOutput(m_outputOnTeleFrag);
}

void
trigger_teleport::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_teleport::Touch(entity eToucher)
{
	if (GetMaster(eToucher) == FALSE) {
		return;
	}
	if (m_teleporterActive == false) {
		return;
	}
	if (CanPass((ncEntity)eToucher) == false) {
		return;
	}
	if (is.Sentient(eToucher) == false) {
		return;
	}

	eActivator = (ncEntity)eToucher;
	ncEntity eTarget = (ncEntity)find(world, ::targetname, target);

	if (!eTarget) {
		EntWarning("Failed to teleport %S to %S", eActivator.netname, target);
		return;
	}

	vector endpos = eTarget.origin;
	float flSpeed = vlen(eActivator.velocity);
	makevectors(eTarget.angles);
	eActivator.velocity = (v_forward * flSpeed);
	eActivator.angles = eTarget.angles;

	if (is.Player(eActivator)) {
		Client_FixAngle(eActivator, eActivator.angles);

		/* level designers place destinations where the feet
		   are going to be, because monsters are mainly set up
		   to be that way (0 0 0 being ground). players however 
		   have their it at the center of mass, so nudge it a little. */
		endpos[2] -= eActivator.mins[2]; 
	}

	/* test if something is in the way. */
	tracebox(endpos, eActivator.mins, eActivator.maxs, endpos, MOVE_NORMAL, eActivator);

	/* indeed something is in the way... */
	if (trace_ent && trace_startsolid == true) {
		/* it can be killed, telefrag */
		if (trace_ent.takedamage != DAMAGE_NO) {
			ncSurfacePropEntity killThis = (ncSurfacePropEntity)trace_ent;
			killThis.SetHealth(-100);
			UseOutput(eActivator, m_outputOnTeleFrag);
			killThis.Death(this, eActivator, 1000, g_vec_null, trace_endpos, 0i);
		}
	}

	eActivator.SetOriginUnstick(endpos);
	UseOutput(eActivator, m_outputOnTeleportingEntity);

	if (m_sndTeleport) {
		StartSoundDef(m_sndTeleport, CHAN_VOICE, true);
	}

	if (m_sndTeleportEnter) {
		StartSoundDef(m_sndTeleportEnter, CHAN_VOICE, true);
	}

	if (m_sndTeleportExit) {
		eTarget.StartSoundDef(m_sndTeleportExit, CHAN_VOICE, true);
	}

	EntLog("Teleported %S to %v", eActivator.netname, endpos);
}
