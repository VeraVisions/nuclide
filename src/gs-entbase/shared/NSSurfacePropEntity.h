/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

class NSSurfacePropEntity:NSRenderableEntity
{
	float m_flBurnNext;

	void(void) NSSurfacePropEntity;

	/* overrides */
	virtual void(string) SetModel;
#ifdef SERVER
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) Respawn;
	virtual void(entity, string, string) Input;
	virtual void(string, string) SpawnKey;
	virtual void(void) ParentUpdate;
#else
	virtual float(void) predraw;
#endif

	/* new */
#ifdef SERVER
	/* fire/burning */
	entity m_eBurner;
	int m_iBurnWeapon;
	float m_flBurnTime;

	/* I/O */
	string m_strOnBreak;

	nonvirtual void(entity, float, int) Ignite;
	nonvirtual void(void) Extinguish;
	nonvirtual bool(void) IsOnFire;

	/* life, death */
	float m_oldHealth;
	virtual void(void) Pain;
	virtual void(void) Death;

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

};
