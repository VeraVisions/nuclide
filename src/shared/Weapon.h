/*
 * Copyright (c) 2022 Vera Visions LLC.
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

typedef enumflags
{
	WEAPONFL_CHANGED_MODELINDEX,
	WEAPONFL_CHANGED_ORIGIN,
	WEAPONFL_CHANGED_ANGLES,
	WEAPONFL_CHANGED_VELOCITY,
	WEAPONFL_CHANGED_ANGULARVELOCITY,
	WEAPONFL_CHANGED_SIZE,
	WEAPONFL_CHANGED_FLAGS,
	WEAPONFL_CHANGED_SOLID,
	WEAPONFL_CHANGED_FRAME,
	WEAPONFL_CHANGED_SKIN,
	WEAPONFL_CHANGED_MOVETYPE,
	WEAPONFL_CHANGED_EFFECTS,
	WEAPONFL_CHANGED_BODY,
	WEAPONFL_CHANGED_SCALE,
	WEAPONFL_CHANGED_ENTITYDEF,
	WEAPONFL_CHANGED_CLIP,
	WEAPONFL_CHANGED_CHAIN,
	WEAPONFL_CHANGED_STATE,
	WEAPONFL_CHANGED_NEXTWEAPON,
	WEAPONFL_CHANGED_PREVWEAPON,
} nsweapon_changed_t;

typedef enum
{
	WEAPONSTATE_IDLE,
	WEAPONSTATE_COCK,
	WEAPONSTATE_CHARGING,
	WEAPONSTATE_FIRELOOP,
	WEAPONSTATE_RELEASED,
	WEAPONSTATE_OVERHEATED,
	WEAPONSTATE_DRAW,
	WEAPONSTATE_RELOAD_START,
	WEAPONSTATE_RELOAD,
	WEAPONSTATE_RELOAD_END,
	WEAPONSTATE_BURSTFIRING
} nsweapon_state_t;

string nsweapon_state_s[] =
{
	"WEAPONSTATE_IDLE",
	"WEAPONSTATE_RELOAD_START",
	"WEAPONSTATE_RELOAD",
	"WEAPONSTATE_RELOAD_END",
	"WEAPONSTATE_CHARGING",
	"WEAPONSTATE_FIRELOOP",
	"WEAPONSTATE_RELEASED",
	"WEAPONSTATE_OVERHEATED"
};

typedef enum
{
	WEPEVENT_FIRED,
	WEPEVENT_RELEASED,
	WEPEVENT_RELOADED
} nsweapon_event_t;

#define CHAN_LOOP 5

/*! \brief This entity class represents weapon based items. */
/*!QUAKED ncWeapon (0 0.8 0.8) (-16 -16 0) (16 16 32)
# OVERVIEW
This entity class represents weapon based items. 
It is based on ncItem. The only difference is that the attack
related keys get forwarded only to items of this class.

This is not a class that you can instantiate using level entity data due to its complexity,
you will almost exclusively enter the data using [entityDef](@ref entitydef) instead.

## FireInfo
Weapon firing events are split into optional decl titled 'FireInfo'
that are queried for implemented attack types.

The "def_fireInfo" key points to the decl containing the primary-attack
FireInfo. If that doesn't exist, the keys that would be queried from
there are read from the main decl. This goes for any key that is not
present in a FireInfo.

The "def_altFireInfo" key points to the decl containing the secondary-attack
FireInfo. If that does not exist, secondary attacks are not possible.

# KEYS
- "model" : Item/pickup model in world.
- "model_view" : First-person view model.
- "model_flash" : muzzleflash model/sprite to use. 
- "flashColor" : muzzleflash dlight color
- "flashRadius" : muzzleflash dlight radius
- "def_dropItem" : when this item is dropped from someones inventory, will spawn this entityDef item instead.
- "snd_acquire" : pickup noise
- "snd_respawn" : respawn noise
- "snd_hum" : idle shader
- "smoke_muzzle" : smoke particle effect name
- "continuousSmoke" : whether the particle effect is continous
- "clipSize" : maximum clip size
- "clipSizeDefault" : Initial clip size on pickup.
- "animPrefix" : Alternative set of animations to use by the weapon. See the ncPlayer documentation for details about the set of activities that will be picked from.

## FireInfo related keys
- "def_onFire" : Def to spawn when the weapon is fired.
- "def_onRelease" : Def to spawn when the weapon has been released.
- "fireUnderwater" : Default is 1, will set if the weapon can be fired underwater.

### Ammo management related keys
- "ammoType" : name of the ammo type def entry which the weapon uses
- "ammoRequired" : set to 1 if we require ammo. 
- "ammoPerShot" : Amount of ammo to deduct per successful shot.

### Charging/Overcharging
For an overcharge effect, spawn a self-destructive explosion on "def_onFire", and rely on "def_onRelease"
for delivering a lethal charge to other enemies.
- "chargeTime" : Amount of time the weapon has to charge before "def_onFire" is spawned.

### Overheating weapons
Overheating of the weapon is done when both keys are set.
- "overheatLength"	 : Time in which it takes for the weapon to cool down.
- "overheatPerShot" : Time added against "overheatLength" when a shot is fired.

### Mode switching
- "altMode" : When 1, then secondary-attack will toggle between "def_fireInfo" and "def_altFireInfo" on primary-attack.

### Burst Fire
- "burstCount" : Number of bursts to fire. Default is "0".
- "burstTime" : Once we've fired "burstCount" number of times, we'll add this delay after.

### Act overrides
Activities are used to decide which animation gets played and which actions are available for this object. If a model does not define them, you can override them here.
This system is SUBJECT to change. It may be removed altogether when FTEQW adds a proper
activity override format for existing models.
- "act_idle" : Sequences to play when idle.
- "act_idleEmpty" : Sequences to play when idle and with an empty clip.
- "act_draw" : Sequences to play when drawing the weapon.
- "act_drawEmpty" : Sequences to play when drawing the empty weapon.
- "act_holster" : Sequences to play when holstering the weapon.
- "act_holsterEmpty" : Sequences to play when holstering the empty weapon.
- "act_fire" : Sequences to play when "def_onFire" fires.
- "act_fireLast" : Sequences to play when firing the last shot in the weapon.
- "act_fireEmpty" : Sequences to play when failing to fire the weapon.
- "act_reload" : Sequences to play when reloading the weapon.
- "act_reloadEmpty" : Sequences to play when reloading the empty weapon.
- "act_reloadStart" : When set will play sequences for the start of a shotgun-style reload.
- "act_reloadEnd" : Like "actReloadStart" but for the end of the shotgun-style reload.
- "act_delay" : Sequence to play while the weapon is charging (see "chargeTime")
- "act_loop" : Sequence to play while the weapon is still charging, or in a firing-loop.
- "act_detonate" : Sequences to play when "detonateOnFire" is triggered.
- "act_fireFailed" : Sequences to play when the melee attack fails.
- "act_fireStart" : Sequences to play at the start of a loop/charge attack.
- "act_fireStop" : Sequences to play at the end of a loop/charge attack.
- "act_release" : Sequences to play when "def_onRelease" fires.

### Misc keys
- "reloadTime" : Time in seconds between the start/end of a reload.
- "detonateOnFire" : When set, will detonate all entities of specified classname.
- "punchAngle" : Weapon punchangle to be applied to the camera when shooting "def_onFire".
- "fireRate" : Firing rate between shots.
- "semiAuto" : If not set to "1", the weapon will be fully automatic.

# EXAMPLES

Here's some examples of weapons that you can declare via [entityDef](@ref entityDef)

A baseball bat:

```
// Baseball Bat
entityDef weapon_bat
{
	"spawnclass"		"ncWeapon"					// any weapon has to be at least this class, or a child-class
	"model_view"		"models/weapons/v_bat.vvm"	// the first-person view model
	"model"				"models/weapons/w_bat.vvm"	// the world/pickup/item model
	"inv_name"			"Baseball Bat" 				// the name for the inventory/log display
	"ammoRequired"		"0"							// Will never charge or check for ammo

	"def_onFire"		"damage_bat"				// Spawn this projectile upon successful fire
	"testDistance"		"-32"						// Fire can only be successful if we collide with something within 32 units. The value being positive would mean the opposite (success only when there's nothing in the way)

	"meleeRateMiss"		"0.6"						// The firing rate if "testDistance" fails
	"meleeRateHit"		"0.75"						// The firing rate if "testDistance" succeeds

	"act_idle"			"0,2"						// a set of idle sequences to play, when idle
	"act_draw"			"4"							// the animation sequence to play when deploying the weapon
	"act_holster"		"6"							// the animation sequence to play when putting the weapon away.
	"act_fireFailed"	"9,11,13"					// the animation sequences to pick from for when "testDistance" fails
	"act_fire"			"8,10,12"					// the animation sequences to pick from for when "testDistance" succeeds
}

entityDef damage_bat
{
	"spawnclass"		"ncProjectile"				// attacks can be either this, or ncAttack
	"is_bullet"			"1"							// make it hitscan based
	"damage"			"15"						// we make 15 damage with a hit
	"push"				"300"						// apply this much push force to the target
}
```

You will notice how the above example has no mention of fireInfo whatsoever. That's because anything that
can be defined within a fireInfo entry, can also be inherited from the main weapon decl.

FireInfo exists mainly so that multiple modes of operation can be defined, like for example a distinct secondary firing mode.

Here's an example for a gun that fires both bullets and grenades:

```
entityDef weapon_rifle
{
	"editor_color"			".3 .3 1"
	"editor_mins"			"-16 -16 -16"
	"editor_maxs"			"16 16 16"
	"editor_usage"			"Rifle with Grenade Launcher Attachment"
	"editor_rotatable"		"1"

	"spawnclass"			"ncWeapon"
	"model"					"models/weapons/w_rifle.vvm"
	"model_view"			"models/weapons/v_rifle.vvm"

	// ncWeapon specific
	"def_fireInfo"			"fireInfo_rifleBullets"
	"def_altFireInfo"		"fireInfo_rifleGrenade"
	"inv_name"				"Cool Rifle"
	"clipSize"				"50"
	"clipSizeDefault"		"45"

	"act_fire"				"5,6,7"
	"act_holster"			"4"
	"act_reload"			"3"
	"act_draw"				"4"
	"act_idle"				"0,1"
	"weight"				"15"
}

entityDef projectile_rifleBullets
{
	"spawnclass"			"ncProjectile"
	"is_bullet"				"1"
	"damage"				"15"
}

entityDef fireInfo_rifleBullets
{
	"def_onFire"			"projectile_rifleBullets"
	"ammoType"				"ammo_bullets"
	"ammoRequired"			"1"
	"ammoPerShot"			"1"
	"fireRate"				"0.1"
	"punchAngle"			"-4 0 0"
}

entityDef fireInfo_rifleGrenade
{
	"def_onFire"			"projectile_grenade"
	"ammoType"				"ammo_grenade"
	"ammoRequired"			"1"
	"ammoPerShot"			"1"
	"fireRate"				"1"
	"punchAngle"			"-15 0 0"
	"act_fire"				"2"
}

entityDef projectile_grenade
{
	"spawnclass"			"ncProjectile"
	"model"					"models/projectiles/grenade.vvm"
	"offset"				"16 0 0"
	"velocity"				"1000 0 0"
	"angular_velocity"		"-300 0 0"
	"gravity"				"0.5"
	"bounce"				"1"
	"mins"					"0 0 0"
	"maxs"					"0 0 0"
	"detonate_on_fuse"		"0"
	"detonate_on_death"		"1"
	"detonate_on_world"		"1"
	"detonate_on_actor"		"1"
	"damage"				"150"
	"splash_damage"			"80"
}
```

In the above example, defining **def_fireInfo** in **weapon_rifle** will isolate definitions
affecting the primary attack mode of the weapon into the fireInfo decl **fireInfo_rifleBullets**, whereas
the secondary attack is defined within **fireInfo_rifleGrenade**.

As you can see given the previous baseball-bat example, you don't have to define these at all, unless you desire said extra functionality.

@ingroup baseclass
*/
class
ncWeapon:ncItem
{
public:
	void ncWeapon(void);

	virtual void InputFrame(void);
	virtual void AddedToInventory(void);
	virtual void RemovedFromInventory(void);

	/* overrides */
#ifdef SERVER
	virtual void Spawned(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void RestoreComplete(void);
#endif

	virtual bool TestFireAbility(string);

#ifdef CLIENT
	virtual void ClientFX(bool);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void ReceiveEvent(float);
#endif

	virtual bool UsesSecondaryAmmo(void);
	virtual bool IsEmpty(void);
	virtual bool IsWeapon(void);
	virtual bool HasReserveAmmo(void);

	/** Overridable: Called when we switch to this weapon from another. */
	virtual void Draw(void);
	/** Overridable: Called when we are about to switch to another weapon */
	virtual void Holster(void);
	/** Overridable: On +attack execution. */
	virtual void PrimaryAttack(void);
	/** Overridable: On +attack2 execution. */
	virtual void SecondaryAttack(void);
	/** Overridable: On +reload execution. */
	virtual void Reload(void);
	/** Overridable: When no buttons are held, or you forcefully want to stop firing. */
	virtual void Release(void);
	/** Overridable: When the weapon is supposed to be doing something on its own. */
	virtual void Idle(void);
	/** Overridable: When the HUD is requested to be drawn. */
	virtual void UpdateGUI(void);

	nonvirtual void SetViewModel(string);
	nonvirtual void SetWorldModel(string);
	nonvirtual void SetPlayerModel(string);
	nonvirtual void SetWeaponFrame(float);
	nonvirtual void PlaySound(string, float, bool);

	/* state */
	nonvirtual nsweapon_state_t GetWeaponState(void);

	virtual void SetAttackNext(float);
	virtual void SetReloadNext(float);
	virtual void SetIdleNext(float);
	virtual bool CanFire(void);
	virtual bool CanIdle(void);
	virtual bool CanReload(void);
	virtual bool UseAmmo(string);

	/** Overridable: Called once when the weapon started firing. */
	virtual void WeaponStartedFiring(void);
	/** Overridable: Called once when the weapon stopped firing. */
	virtual void WeaponStoppedFiring(void);

	/** Returns whether the weapon is being actively fired by the owner. */
	nonvirtual bool WeaponIsFiring(void);

	/** Overridable: Controls def_onFire event. */
	virtual void FiredWeaponAttack(string);
	/** Overridable: Controls def_onRelease event. */
	virtual void ReleasedWeaponAttack(string);

	/** Overridable: Called when we've switched to this weapon successfully. */
	virtual void SwitchedToWeapon(void);
	/** Overridable: Called when we've switched from this weapon successfully. */
	virtual void SwitchedFromWeapon(void);

	/** Overridable: Called when requesting to cache values from decl to attributes. */
	virtual void UpdateFireInfoCache(void);
	/** Overridable: Called when the active fireInfo changed. */
	virtual void FireInfoChanged(void);

	/** Set the active fire Info of the weapon to this one. */
	nonvirtual void SwitchFireInfo(string);
	nonvirtual bool DetonateDef(string);
	nonvirtual void Attack(string);
	
	nonvirtual int GetClip(void);
	nonvirtual int GetClipSize(void);
	nonvirtual bool RequiresAmmo(void);
	nonvirtual int FireInfoSelected(void);
	nonvirtual float OverheatingProgress(void);
	nonvirtual float PlayerSpeedMod(void);

	/** Called to cache some entityDef values. */
	virtual void ReloadCachedAttributes(void);

private:
	/** Internal use Sets/overrides the weapon state. Subclasses track your own state! */
	nonvirtual void _SetWeaponState(nsweapon_state_t);
	/** Called to signal that the owner switched to this weapon. */
	nonvirtual void _SwitchedToCallback(void);
	/** Called to signal that the owner switched from this weapon. */
	nonvirtual void _SwitchedFromCallback(void);
	nonvirtual void _WeaponStartedFiring(void);
	nonvirtual void _WeaponStoppedFiring(void);
	nonvirtual void _PrimaryAttack(void);
	nonvirtual void _SecondaryAttack(void);
	nonvirtual void _SwitchedWeaponMode(void);
	virtual void _AddedCallback(void);
	virtual void _RemovedCallback(void);

	/** Returns the weapon in the next slot of the owners' inventory. */
	nonvirtual ncWeapon GetNextWeapon(void);
	/** Returns the weapon in the previous slot of the owners' inventory. */
	nonvirtual ncWeapon GetPreviousWeapon(void);
	/** Plays the weapon empty sound. */
	nonvirtual void EmptySound(void);
	/** Sets the viewzoom on its owner. */
	nonvirtual void SetViewZoom(float);

#ifdef CLIENT
	virtual void HandleAnimEvent(float, int, string);
#endif

#ifdef SERVER
	nonvirtual void _ReloadFinished(void);
#endif

	/* weapon related spawn keys */
	string m_weaponTitle;
	int m_weaponHUDSlot;
	int m_weaponHUDSlotPos;
	string m_weaponHUDIcon;
	string m_weaponHUDIconSel;
	string m_weaponViewModelPath;
	string m_weaponPlayerModelPath;
	string m_weaponScript;
	string m_weaponAmmoType;
	bool m_weaponRequiresAmmo;
	int m_weaponClipStartSize;
	string m_weaponDropsItem;

	NETWORKED_INT(m_weaponClip)
	NETWORKED_INT(m_weaponClipSize)
	NETWORKED_FLOAT(m_weaponFireInfoValue)
	NETWORKED_MODELINDEX(m_viewModel)
	NETWORKED_MODELINDEX(m_worldModel)
	NETWORKED_MODELINDEX(m_playerModel)
	NETWORKED_FLOAT(m_weaponFireRate)
	NETWORKED_FLOAT(m_weaponState)
	NETWORKED_BOOL(m_weaponIsFiring)
	NETWORKED_BOOL(m_weaponOverheating)
	NETWORKED_FLOAT(m_burstCount)

	/* cached variables. don't save - recalculate! */
	string m_weaponLastFireInfo;
	string m_primaryFireInfo;
	string m_secondaryFireInfo;
	int m_primaryAmmoType;
	int m_secondaryAmmoType;
	float m_jointTrailWorld;
	float m_jointTrailView;
	float m_weaponAmmoRegenTime;
	float m_weaponAmmoDepleteTime;
	string m_animPrefix;
	bool m_altAlternates;

	/* extra networking */
	float m_nextWeapon_entnum;
	float m_prevWeapon_entnum;
	ncWeapon m_nextWeapon_net;
	ncWeapon m_prevWeapon_net;

	/* cached fireInfo */
	string m_fiMuzzleFlashMaterial;
	string m_fiMuzzleFlashModelPath;
	vector m_fiMuzzleFlashColor;
	float m_fiMuzzleFlashRadius;
	string m_fiFXSmokeParticle;
	bool m_fiFXSmokeContinous;
	float m_fiFXTrail;
	bool m_fiAmmoRequired;
	bool m_fiCocks;
	bool m_fiDrawAfterRelease;
	bool m_fiFireUnderwater;
	bool m_fiLoopingFire;
	bool m_fiSemiAuto;
	bool m_fiWillRelease;
	float m_fiBrassDelay;
	float m_fiCartridgeDelay;
	float m_fiChargeTime;
	float m_fiFireRate;
	float m_fiOverheatLength;
	float m_fiOverheatPoints;
	float m_fiReloadTime;
	int m_fiAmmoPerShot;
	int m_fiAmmoType;
	float m_fiPrimedFuse;
	float m_fiZoomFOV;
	bool m_fiPowerAmmo;
	bool m_fiRemoveOnEmpty;
	string m_fiBrassDef;
	string m_fiCartridgeDef;
	string m_fiDetonateOnFire;
	string m_fiOnFire;
	string m_fiOnRelease;
	string m_fiSndCock;
	string m_fiSndEmpty;
	string m_fiSndFailed;
	string m_fiSndFire;
	string m_fiSndFireLast;
	string m_fiSndFireLoop;
	string m_fiSndFireLoop;
	string m_fiSndFireStart;
	string m_fiSndFireStop;
	string m_fiSndRelease;
	vector m_fiPunchAngle;
	vector m_fiPunchSpring;
	float m_fiSpeedMod;
	bool m_fiAltModeSwitch;
	bool m_fiBuggyIdleAnim;
	int m_fiRegenAmmo;
	float m_fiRegenRate;
	int m_fiDepleteAmmo;
	float m_fiDepleteRate;
	float m_fiMaxBurst;
	float m_fiBurstTime;
	float m_fiKnockBack;
	float m_fiKnockBackRelease;
	float m_fiTestDistance;
};

.ncWeapon m_nextWeapon;
.ncWeapon m_prevWeapon;

