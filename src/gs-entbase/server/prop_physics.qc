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
	PHYSPROPSFL_ASLEEP,
	PHYSPROPSFL_NOPHYSDMG,
	PHYSPROPSFL_DEBRIS,
	PHYSPROPSFL_NOMOTION,
	PHYSPROPSFL_UNUSED1,
	PHYSPROPSFL_UNUSED2,
	PHYSPROPSFL_PHYSDEVICE,
	PHYSPROPSFL_NOROTOR,
	PHYSPROPSFL_USEOUT,
};

/*! \brief Server-Entity: Physics Prop Model */
/*!QUAKED prop_physics (1 0 0) (-16 -16 -16) (16 16 16) ASLEEP NOPHYSDMG DEBRIS NOMOTION x x PHYSDEVICE NOROTOR USEOUT
# OVERVIEW
Physics model

# KEYS
- "targetname" : Name

# SPAWNFLAGS
- ASLEEP (1) : Prop starts without physics and stays until it is impacted.
- NOPHYSDMG (2) : Will not take physics damage.
- DEBRIS (4) : Will not collide with players, or other types of debris
- NOMOTION (8) : Disable motion
- PHYSDEVICE (64) : Enable motion when grabbed with a physics device.
- NOROTOR (128) : Unaffected by rotor contraptions.
- USEOUT (256) : Generate output on +use.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
@ingroup physics
*/
class
prop_physics:ncPhysicsEntity
{
public:
	void prop_physics(void);
	
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void OnPlayerUse(void);
};

void
prop_physics::prop_physics(void)
{
}

void
prop_physics::OnPlayerUse(void)
{
	ncPlayer thePlayer = (ncPlayer)eActivator;

	if (HeldByPlayer() == true) {
		return;
	}

	/* disallow +use */
	if (HasSpawnFlags(PHYSPROPSFL_PHYSDEVICE)) {
		return;
	}

	if (thePlayer.CanPickupEntity(this, 35, 128) == true) {
		Wake();
		EntLog("Picked up by %S", thePlayer.netname);
		thePlayer.PickupEntity(this);
	}
}

void
prop_physics::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
prop_physics::Respawn(void)
{
	bool startAwake = false;

	super::Respawn();

	/* the least priority one of them all */
	if (HasSpawnFlags(PHYSPROPSFL_ASLEEP)) {
		startAwake = false;
	} else {
		startAwake = true;
	}

	if (HasSpawnFlags(PHYSPROPSFL_NOMOTION)) {
		startAwake = false;
	}

	if (HasSpawnFlags(PHYSPROPSFL_PHYSDEVICE)) {
		startAwake = false;
	}


	if (startAwake == true) {
		setorigin_safe(this, origin);
		Wake();
	} else {
		Sleep();
	}

	if (HasSpawnFlags(PHYSPROPSFL_DEBRIS)) {
		SetSolid(SOLID_NOT);
	}

	PlayerUse = OnPlayerUse;
}

CLASSEXPORT(prop_physics_override, prop_physics)
CLASSEXPORT(prop_physics_respawnable, prop_physics)
CLASSEXPORT(prop_physics_multiplayer, prop_physics)
