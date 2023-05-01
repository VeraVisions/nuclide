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
	TRIGTELE_NOCLIENTS
};

/*!QUAKED trigger_teleport (.5 .5 .5) ? MONSTERS NOCLIENTS
# OVERVIEW
Teleportation volume. Teleports anything it touches to the position of
any entity set as the "target". Works best with info_teleport_destination.

# KEYS
- "targetname" : Name
- "target" : Which target to teleport to.

# SPAWNFLAGS
- MONSTERS (1) : Allow monsters to use this teleporter.
- NOCLIENTS (2) : Disallow clients from using this teleporter.

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

private:
	string m_sndTeleport;
	string m_sndTeleportEnter;
	string m_sndTeleportExit;
};

void
trigger_teleport::trigger_teleport(void)
{
	m_sndTeleport = __NULL__;
	m_sndTeleportEnter = __NULL__;
	m_sndTeleportExit = __NULL__;
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
	default:
		super::SpawnKey(strKey, strValue);
	}
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
	if (GetMaster() == FALSE)
		return;
	if (HasSpawnFlags(TRIGTELE_NOCLIENTS) && eToucher.flags & FL_CLIENT)
		return;
	if (!HasSpawnFlags(TRIGTELE_MONSTERS) && eToucher.flags & FL_MONSTER)
		return;

	if (eToucher.movetype != MOVETYPE_NONE) {
		eActivator = eToucher;
		entity eTarget = find(world, ::targetname, target);

		if (eTarget) {
			vector endpos = eTarget.origin + [0,0,16];
			float flSpeed = vlen(eToucher.velocity);
			makevectors(eTarget.angles);
			eToucher.velocity = (v_forward * flSpeed);
			eToucher.angles = eTarget.angles;
			setorigin_safe(eToucher, endpos);

			if (eToucher.flags & FL_CLIENT)
				Client_FixAngle(eToucher, eToucher.angles);

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
"targetname"    Name

Entity designed to designate a destination for a trigger_teleport.
*/
CLASSEXPORT(info_teleport_destination, info_notnull)
