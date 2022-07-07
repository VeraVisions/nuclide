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

enum
{
	PHYSM_BOX,
	PHYSM_SPHERE,
	PHYSM_CAPSULE,
	PHYSM_TRIMESH,
	PHYSM_CYLINDER
};

enumflags
{
	BPHY_NODMGPUSH,
	BPHY_SHARP
};


enumflags
{
	PHYENT_CHANGED_ORIGIN_X,
	PHYENT_CHANGED_ORIGIN_Y,
	PHYENT_CHANGED_ORIGIN_Z,
	PHYENT_CHANGED_ANGLES_X,
	PHYENT_CHANGED_ANGLES_Y,
	PHYENT_CHANGED_ANGLES_Z,
	PHYENT_CHANGED_MODELINDEX,
	PHYENT_CHANGED_SIZE,
	PHYENT_CHANGED_FLAGS,
	PHYENT_CHANGED_SOLID,
	PHYENT_CHANGED_FRAME,
	PHYENT_CHANGED_SKIN,
	PHYENT_CHANGED_MOVETYPE,
	PHYENT_CHANGED_EFFECTS,
	PHYENT_CHANGED_BODY,
	PHYENT_CHANGED_SCALE,
	PHYENT_CHANGED_VELOCITY,
	PHYENT_CHANGED_RENDERCOLOR,
	PHYENT_CHANGED_RENDERAMT,
	PHYENT_CHANGED_RENDERMODE,
};

class NSPhysicsEntity:NSSurfacePropEntity
{
	int m_iEnabled;
	int m_iShape;
	int m_iMaterial;
	int m_iFlags;
	float m_flInertiaScale;

	void(void) NSPhysicsEntity;

	/* overrides */
	virtual void(void) Respawn;
	virtual void(void) TouchThink;
#ifdef SERVER
	PREDICTED_VECTOR(m_vecNetAngles);

	virtual void(void) Pain;
	virtual void(void) Death;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#else
	virtual void(float, float) ReceiveEntity;
#endif
	virtual void(string, string) SpawnKey;

	virtual void(float) SetMass;
	virtual float(void) GetMass;
	virtual void(float) SetFriction;
	virtual float(void) GetFriction;
	virtual void(float) SetBounceFactor;
	virtual float(void) GetBounceFactor;
	virtual void(float) SetBounceStop;
	virtual float(void) GetBounceStop;
	virtual void(void) PhysicsEnable;
	virtual void(void) PhysicsDisable;
	virtual void(vector) ApplyForceCenter;
	virtual void(vector, vector) ApplyForceOffset;
	virtual void(vector) ApplyTorqueCenter;
	virtual float(int, int) CalculateImpactDamage;
};
