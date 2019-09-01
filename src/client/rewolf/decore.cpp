/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

class CBaseDecor:CBaseEntity
{
	int m_iBody;
	virtual void(string, string) SpawnKey;
};

void CBaseDecor::Initialized(void)
{
	setmodel(this, model);
	setorigin(this, origin);
	setcustomskin(this, "", sprintf("geomset 0 %i\n", m_iBody));
	drawmask = MASK_ENGINE;
}

void CBaseDecor::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "body":
			m_iBody = stoi(strKey);
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
			break;
	}
}

/* Let's begin */
class decore_asteroid:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/asteroid.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_baboon:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/baboon.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_bodygib:CBaseDecor
{
	void() decore_bodygib = {
		model = "models/bodygib.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_butterflyflock:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/butterfly.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_explodable:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/EXPLODABLE!!!!";
		CBaseDecor::Initialized();
	};
};

class decore_foot:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/FOOT!!!!";
		CBaseDecor::Initialized();
	};
};

class decore_goldskull:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/goldskull.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_hatgib:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/hatgib.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_nest:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/ornest.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_pteradon:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/pteradon2.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_torch:CBaseDecor
{
	virtual void() Initialized = {
		precache_model("sprites/torch.spr");
		model = "models/torch.mdl";
		CBaseDecor::Initialized();
		this.effects |= EF_FULLBRIGHT;

		sprite flame = spawn(sprite);
		setorigin(flame, origin + [0,0,24]);
		setmodel(flame, "sprites/torch.spr");
		flame.effects = EF_ADDITIVE;
		flame.drawmask = MASK_ENGINE;
		flame.maxframe = modelframecount(flame.modelindex);
		flame.loops = 1;
		flame.framerate = 10;
		flame.nextthink = time + 0.05f;
	};
};

class decore_spacedebris:CBaseDecor
{
	virtual void() Initialized = {
		CBaseDecor::Initialized();
	};

	virtual void(string strField, string strKey) SpawnKey = {
		switch (strField) {
			case "modelname":
				model = strKey;
				break;
			default:
				CBaseEntity::SpawnKey(strField, strKey);
				break;
		}
	};
};

class decore_swampplants:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/swampstuff.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_mushroom:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/mushroom.mdl";
		CBaseDecor::Initialized();
	};
};

class decore_mushroom2:CBaseDecor
{
	virtual void() Initialized = {
		model = "models/mushroom2.mdl";
		CBaseDecor::Initialized();
	};
};
