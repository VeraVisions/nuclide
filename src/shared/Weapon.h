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
	WEAPONSTATE_RELOAD_END
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
	WEPEVENT_RELOADED
} nsweapon_event_t;

#define CHAN_LOOP 5

/*! \brief This entity class represents weapon based items. */
/*!QUAKED ncWeapon (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
This entity class represents weapon based items. 
It is based on ncItem. The only difference is that the attack
related keys get forwarded only to items of this class.

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
- "targetname" : Name

- "weapon_scriptobject" : mapC progs with the weapon code within.
- "clipSize" : maximum clip size
- "mtr_flashShader" : muzzleflash material to Use.
- "model_flash" : muzzleflash model/sprite to use.
- "flashColor" : muzzleflash dlight color
- "flashRadius" : muzzleflash dlight radius
- "def_dropItem" : when this item is dropped from someones inventory, will spawn this entityDef item instead.
- "snd_acquire" : pickup noise
- "snd_respawn" : respawn noise
- "snd_hum" : idle shader
- "smoke_muzzle" : smoke particle effect name
- "continuousSmoke" : whether the particle effect is continous
- "clipSizeDefault" : CUSTOM: Default clip size on pickup.

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

	/** Overridable: Called when the fireInfo changed. Cache values here. */
	virtual void UpdateFireInfoCache(void);

	/** Set the active fire Info of the weapon to this one. */
	nonvirtual void SwitchFireInfo(string);
	nonvirtual bool DetonateDef(string);
	nonvirtual void Attack(string);

private:
	/** Internal use Sets/overrides the weapon state. Subclasses track your own state! */
	nonvirtual void _SetWeaponState(nsweapon_state_t);
	/** Called to signal that the owner switched to this weapon. */
	nonvirtual void _SwitchedToCallback(void);
	/** Called to signal that the owner switched from this weapon. */
	nonvirtual void _SwitchedFromCallback(void);
	/** Called to cache some entityDef values. */
	nonvirtual void _CacheWeaponDefVariables(void);
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

#ifdef CLIENT
	virtual void HandleAnimEvent(float, int, string);
#endif

#ifdef SERVER
	nonvirtual void _ReloadFinished(void);
#endif

	/* weapon related spawn keys */
	string m_strWeaponTitle;
	int m_iHudSlot;
	int m_iHudSlotPos;
	string m_icon;
	string m_iconSel;

	string m_strWeaponViewModel;
	string m_strWeaponPlayerModel;
	string m_strWeaponScript;
	string m_strAmmoType;
	bool m_bAmmoRequired;
	int m_iClipStartSize;
	string m_strFlashShader;
	string m_strFlashModel;
	vector m_vecFlashColor;
	float m_flFlashRadius;
	string m_strDropItemDef;
	string m_strSmokeParticle;
	bool m_bSmokeContinous;
	float m_fxTrail;

	/* extra networking */
	bool m_bFiring;

	/* cached variables. don't save - recalculate! */
	string m_primaryFireInfo;
	string m_secondaryFireInfo;
	int m_primaryAmmoType;
	int m_secondaryAmmoType;
	float m_flPrimedFuse;
	float m_flTriggerDelay;
	float m_flZoomFOV;
	bool m_bPowerAmmo;
	bool m_bRemoveOnEmpty;
	string m_strLastFireInfo;
	float m_jointTrailWorld;
	float m_jointTrailView;
	float m_flSpeedMod;
	bool m_bAltModeSwitch;
	bool m_bBuggyIdleAnim;

	float m_nextWeapon_entnum;
	float m_prevWeapon_entnum;
	ncWeapon m_nextWeapon_net;
	ncWeapon m_prevWeapon_net;

	/* cached fireInfo */
	string m_fiDetonateOnFire;
	vector m_fiPunchAngle;
	vector m_fiPunchSpring;
	string m_fiSndFire;
	string m_fiSndFailed;
	string m_fiSndFireLast;
	string m_fiSndRelease;
	string m_fiSndEmpty;
	int m_fiAmmoType;
	int m_fiAmmoPerShot;
	bool m_fiAmmoRequired;
	float m_fiFireRate;
	string m_fiOnFire;
	string m_fiOnRelease;
	bool m_fiWillRelease;
	bool m_fiSemiAuto;
	string m_fiSndFireLoop;
	float m_flReloadSpeed;
	float m_fiChargeTime;
	bool m_bHasLoop;
	string m_fiSndFireStart;
	string m_fiSndFireStop;
	string m_fiSndFireLoop;
	bool m_fiDrawAfterRelease;
	bool m_fireUnderwater;

	bool m_fiCocks;
	string m_fiSndCock;

	string m_fiBrassDef;
	float m_fiBrassDelay;

	/* overheating */
	float m_fiOverheatLength;
	float m_fiOverheatPoints;

	NETWORKED_INT(m_iClip)
	NETWORKED_INT(m_iClipSize)
	NETWORKED_FLOAT(m_iMode)
	NETWORKED_MODELINDEX(m_viewModel)
	NETWORKED_MODELINDEX(m_worldModel)
	NETWORKED_MODELINDEX(m_playerModel)
	NETWORKED_FLOAT(m_flFireRate)
	NETWORKED_FLOAT(m_dState)
	NETWORKED_BOOL(m_bFiring)
	NETWORKED_BOOL(m_flOverheating)
};

.ncWeapon m_nextWeapon;
.ncWeapon m_prevWeapon;

