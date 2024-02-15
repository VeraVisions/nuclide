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
- TF_PHYSICS (8) : NSPhysicsEntity based classes can touch it.
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
*/
class
trigger_teleport:NSBrushTrigger
{
public:
	void trigger_teleport(void);
	
	virtual void Touch(entity);

	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string,string);

	nonvirtual bool CanPass(NSEntity);

private:
	bool m_bEnabled;
	string m_sndTeleport;
	string m_sndTeleportEnter;
	string m_sndTeleportExit;
	bool m_bIsModern;
};

void
trigger_teleport::trigger_teleport(void)
{
	m_sndTeleport = __NULL__;
	m_sndTeleportEnter = __NULL__;
	m_sndTeleportExit = __NULL__;
	m_bEnabled = true;
	m_bIsModern = false;
}

void
trigger_teleport::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "snd_teleport":
		m_sndTeleport = strValue;
		break;
	case "snd_teleport_enter":
		m_sndTeleportEnter = strValue;
		break;
	case "snd_teleport_exit":
		m_sndTeleportExit = strValue;
		break;
	case "StartDisabled":
		m_bEnabled = ReadBool(strValue);
		m_bIsModern = true;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_teleport::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveString(handle, "m_sndTeleport", m_sndTeleport);
	SaveString(handle, "m_sndTeleportEnter", m_sndTeleportEnter);
	SaveString(handle, "m_sndTeleportExit", m_sndTeleportExit);
	SaveBool(handle, "m_bIsModern", m_bIsModern);
}

void
trigger_teleport::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	case "m_sndTeleport":
		m_sndTeleport = ReadString(strValue);
		break;
	case "m_sndTeleportEnter":
		m_sndTeleportEnter = ReadString(strValue);
		break;
	case "m_sndTeleportExit":
		m_sndTeleportExit = ReadString(strValue);
		break;
	case "m_bIsModern":
		m_bIsModern = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

bool
trigger_teleport::CanPass(NSEntity target)
{
	/* legacy entity check */
	if (m_bIsModern == false) {
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

	if (m_sndTeleport)
		Sound_Precache(m_sndTeleport);

	if (m_sndTeleportEnter)
		Sound_Precache(m_sndTeleportEnter);

	if (m_sndTeleportExit)
		Sound_Precache(m_sndTeleportExit);
}

void
trigger_teleport::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_teleport::Touch(entity eToucher)
{
	if (GetMaster(eToucher) == FALSE)
		return;
	if (m_bEnabled == false)
		return;
	if (CanPass((NSEntity)eToucher) == false)
		return;

	if (eToucher.movetype != MOVETYPE_NONE) {
		eActivator = eToucher;
		entity eTarget = find(world, ::targetname, target);

		if (eTarget) {
			vector endpos = eTarget.origin;
			float flSpeed = vlen(eToucher.velocity);
			makevectors(eTarget.angles);
			eToucher.velocity = (v_forward * flSpeed);
			eToucher.angles = eTarget.angles;

			if (eToucher.flags & FL_CLIENT) {
				Client_FixAngle(eToucher, eToucher.angles);

				/* level designers place destinations where the feet
				   are going to be, because monsters are mainly set up
				   to be that way (0 0 0 being ground). players however 
				   have their it at the center of mass, so nudge it a little. */
				endpos[2] -= eToucher.mins[2]; 
			}

			setorigin_safe(eToucher, endpos);

			if (m_sndTeleport) {
				Sound_Play(eToucher, CHAN_VOICE, m_sndTeleport);
			}

			if (m_sndTeleportEnter) {
				Sound_Play(this, CHAN_VOICE, m_sndTeleportEnter);
			}

			if (m_sndTeleportExit) {
				Sound_Play(eTarget, CHAN_VOICE, m_sndTeleportExit);
			}

			NSLog("^2trigger_teleport::^3Touch^7: Teleported '%s' to `%v`", 
				eToucher.netname, endpos);
		} else {
			print(sprintf("^2trigger_teleport::^3Touch^7: Failed to teleport '%s'\n", 
				eToucher.netname));
		}
	}
}

/*!QUAKED info_teleport_destination (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Entity designed to designate a destination for a trigger_teleport.

# KEYS
"targetname"    Name

# TRIVIA
This entity was introduced in Quake (1996).
*/
CLASSEXPORT(info_teleport_destination, info_notnull)
