/*
 * Copyright (c) 2024-2025 Vera Visions LLC.
 * Copyright (c) 2017 David Walton
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

class
ncBreakableBrush:ncSurfacePropEntity
{
public:
	void ncBreakableBrush(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void OnRemoveEntity(void);
	virtual void Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody);
private:

	string m_outsideTexture;
#endif
};

void
ncBreakableBrush::ncBreakableBrush(void)
{
#ifdef SERVER
	m_outsideTexture = "gfx/conback";
#endif
}

#ifdef SERVER



void
ncBreakableBrush::OnRemoveEntity(void)
{
}

void
ncBreakableBrush::Spawned(void)
{
	super::Spawned();

#if 0
	/* we want to ideally load out own brush data. however that's not possible yet without engine changes */
	float targetModel = getmodelindex(GetSpawnString("model"), false);
#else
	SetModel(GetSpawnString("model"));

	/* TODO: not even passing inside texture yet */
	ncBreakableBrushManager::CreateBrush(absmin, absmax, m_outsideTexture);
#endif
}

void
ncBreakableBrush::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	SetHealth(99999);
	SetMovetype(MOVETYPE_PUSH);
	//EntError("Ow! %i", damage);
}

void
ncBreakableBrush::Respawn(void)
{
	super::Respawn();

	MakeVulnerable();
	Hide();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetHealth(99999);
}
#endif
