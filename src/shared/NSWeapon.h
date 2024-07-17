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
	WEAPONFL_CHANGED_VELOCITY_X,
	WEAPONFL_CHANGED_VELOCITY_Y,
	WEAPONFL_CHANGED_VELOCITY_Z,
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
	WEAPONFL_CHANGED_STATE
} nsweapon_changed_t;

typedef enum
{
	WEAPONSTATE_IDLE,
	WEAPONSTATE_RELOAD_START,
	WEAPONSTATE_RELOAD,
	WEAPONSTATE_RELOAD_END,
} nsweapon_state_t;

typedef enum
{
	WEPEVENT_FIRED,
	WEPEVENT_RELOADED
} nsweapon_event_t;

/*! \brief This entity class represents weapon based items. */
/*!QUAKED NSWeapon (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
This entity class represents weapon based items. 
It is based on NSItem. The only difference is that the attack
related keys get forwarded only to items of this class.

# KEYS
- "targetname" : Name

- "weapon_scriptobject" : mapC progs with the weapon code within.
- "ammoType" : name of the ammo type def entry which the gun uses
- "ammoRequired" : set to 1 if we require ammo. 
- "ammoPerShot" : Amount of ammo to deduct per shot.
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

@ingroup baseclass
*/
class
NSWeapon:NSItem
{
public:
	void NSWeapon(void);

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

#ifdef CLIENT
	virtual void ClientFX(bool);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void ReceiveEvent(float);
#endif

	virtual bool IsWeapon(void);
	virtual bool HasReserveAmmo(void);

	/** Overridable: Called when we switch to this weapon */
	virtual void Draw(void);
	/** Overridable: Called when we are about to switch to another weapon */
	virtual void Holster(void);
	/** Overridable: On +attack execution. */
	virtual void PrimaryAttack(void);
	/** Overridable: On +attack2 execution. */
	virtual void SecondaryAttack(void);
	/** Overridable: On +reload execution. */
	virtual void Reload(void);
	/** Overridable: When no buttons are held. */
	virtual void Release(void);
	/** Overridable: When the HUD is requested to be drawn. */
	virtual void UpdateGUI(void);

	nonvirtual void SetViewModel(string);
	nonvirtual void SetWorldModel(string);
	nonvirtual void SetPlayerModel(string);
	nonvirtual void SetWeaponFrame(float);

	virtual void SetAttackNext(float);
	virtual void SetIdleNext(float);
	virtual bool CanFire(void);
	virtual bool CanIdle(void);
	virtual bool UseAmmo(string);

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
	/** Called to signal that the owner switched to this weapon. */
	nonvirtual void _SwitchedToCallback(void);
	/** Called to signal that the owner switched from this weapon. */
	nonvirtual void _SwitchedFromCallback(void);
	/** Called to cache some entityDef values. */
	nonvirtual void _CacheWeaponDefVariables(void);

#ifdef SERVER
	nonvirtual void _ReloadFinished(void);
#endif

	/* weapon related spawn keys */
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
	float m_muzzleModelIndex;
	float m_altMuzzleModelIndex;
	string m_meleeDef;
	float m_flPrimedFuse;
	float m_flTriggerDelay;
	float m_flZoomFOV;
	bool m_bPowerAmmo;
	bool m_bRemoveOnEmpty;
	string m_strLastFireInfo;
	float m_jointTrailWorld;
	float m_jointTrailView;

	/* cached fireInfo */
	string m_fiDetonateOnFire;
	float m_fiMeleeRange;
	vector m_fiPunchAngle;
	string m_fiSndFire;
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

	NETWORKED_INT(m_iClip)
	NETWORKED_INT(m_iClipSize)
	NETWORKED_FLOAT(m_iMode)
	NETWORKED_MODELINDEX(m_viewModel)
	NETWORKED_MODELINDEX(m_worldModel)
	NETWORKED_MODELINDEX(m_playerModel)
	NETWORKED_FLOAT(m_flFireRate)
	NETWORKED_FLOAT(m_dState)
	NETWORKED_BOOL(m_bFiring)
};

/* Helper functions for plugins, the rest of the codebase etc.

These are, according to IW, common operations. Makes sense to
handle the implementation ourselves as it'll prevent 
entityDefs changing from breaking plugins as a result.
Some of these don't just do direct look-ups of keys. */

/** @return the "attack" type of the weapon.
@param weaponDef the name of the entityDef that defines the weapon.
@return Attack type of the weapon. */
string weaponType(string weaponDef);

/** @return The amount of ammo the specified weapon is meant to start with, when first given to the player. This can be distributed to both clip and reserve ammo types. 
@param weaponDef the name of the entityDef that defines the weapon. */
int weaponStartAmmo(string weaponDef);

/** @return The amount of ammo the weapon can hold in total when it comes to reserve ammo. So this is really returning the max ammo of a given ammo type.
@param weaponDef the name of the entityDef that defines the weapon. */
int weaponMaxAmmo(string weaponDef);

/** @return Whether the weapon is semi automatic.
@param weaponDef the name of the entityDef that defines the weapon. */
bool weaponIsSemiAuto(string weaponDef);

/** @return How this weapon is stored. Usually "item", unless it's temporary.
@param weaponDef the name of the entityDef that defines the weapon. */
string weaponInventoryType(string weaponDef);

/** @return The delay (in seconds) betwen shots of the specified weapon.
@param weaponDef the name of the entityDef that defines the weapon. */
float weaponFireTime(string weaponDef);

/**
@return The delay (in seconds) betwen shots of the specified weapon. 
@param weaponDef the name of the entityDef that defines the weapon. */
int weaponClipSize(string weaponDef);

/** 
@return The 'class' of weapon. Not spawnclass. 
@param weaponDef the name of the entityDef that defines the weapon.*/
string weaponClass(string weaponDef);

/** 
@return true/false whether the weapon takes its ammo only through its clip.
@param weaponDef the name of the entityDef that defines the weapon.*/
bool isWeaponClipOnly(string weaponDef);

/** 
@return true/false whether or not the weapon creates a timed, fused detonating charge of sorts.
@param weaponDef the name of the entityDef that defines the weapon.*/
bool isWeaponDetonationTimed(string weaponDef);

