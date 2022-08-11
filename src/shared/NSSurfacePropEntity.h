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
	SRFENT_CHANGED_ORIGIN_X,
	SRFENT_CHANGED_ORIGIN_Y,
	SRFENT_CHANGED_ORIGIN_Z,
	SRFENT_CHANGED_ANGLES_X,
	SRFENT_CHANGED_ANGLES_Y,
	SRFENT_CHANGED_ANGLES_Z,
	SRFENT_CHANGED_MODELINDEX,
	SRFENT_CHANGED_SIZE,
	SRFENT_CHANGED_FLAGS,
	SRFENT_CHANGED_SOLIDMOVETYPE,
	SRFENT_CHANGED_FRAME,
	SRFENT_CHANGED_SKIN,
	SRFENT_CHANGED_EFFECTS,
	SRFENT_CHANGED_BODY,
	SRFENT_CHANGED_SCALE,
	SRFENT_CHANGED_VELOCITY,
	SRFENT_CHANGED_ANGULARVELOCITY,
	SRFENT_CHANGED_RENDERCOLOR,
	SRFENT_CHANGED_RENDERAMT,
	SRFENT_CHANGED_RENDERMODE,
	SRFENT_CHANGED_CONTROLLER
};

class NSSurfacePropEntity:NSRenderableEntity
{
	float m_flBurnNext;

	void(void) NSSurfacePropEntity;

	virtual void(void) Spawned;

	/* overrides */
	virtual void(string) SetModel;
#ifdef SERVER
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) Respawn;
	virtual void(entity, string, string) Input;
	virtual void(string, string) SpawnKey;
	virtual void(void) ParentUpdate;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#else
	virtual float(void) predraw;
	virtual void(void) RenderFire;
	virtual void(float,float) ReceiveEntity;
#endif

	/* new */
#ifdef SERVER
	/* fire/burning */
	entity m_eBurner;
	int m_iBurnWeapon;
	float m_flBurnTime;
	float m_flBurnDmgTime; /* for whenever they touch a hot flame */

	/* I/O */
	string m_strOnBreak;

	nonvirtual void(entity, float, int) Ignite;
	nonvirtual void(void) Extinguish;
	nonvirtual bool(void) IsOnFire;

	/* life, death */
	float m_oldHealth;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual bool(void) IsAlive;

	/* Generic Damage */
	nonvirtual void(float) SetTakedamage;
	nonvirtual void(float) SetHealth;
	nonvirtual void(float) SetMaxHealth;
	nonvirtual float(void) GetHealth;
	nonvirtual float(void) GetMaxHealth;

	/* Surface/PropKit */
	int m_iMaterial;
	int m_iPropData;
	nonvirtual float(void) GetSpawnHealth;
	nonvirtual bool(void) HasPropData;
	nonvirtual __variant(int) GetPropData;
	nonvirtual bool(void) HasSurfaceData;
	nonvirtual __variant(int) GetSurfaceData;

	string m_strSurfData;
	string m_strPropData;
	nonvirtual void(string) SetSurfaceData;
	nonvirtual void(string) SetPropData;
	nonvirtual void(void) SurfaceDataFinish;
	nonvirtual void(void) PropDataFinish;
#endif

	/* misc 'being' methods */
	virtual vector(void) GetEyePos;
};

#ifdef CLIENT
void NSSurfacePropEntity_ReadEntity(bool);
#endif
