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

string __fullspawndata;

// keep in sync with client/baseentity.cpp
enumflags
{
	BASEFL_CHANGED_ORIGIN,
	BASEFL_CHANGED_ANGLES,
	BASEFL_CHANGED_MODELINDEX,
	BASEFL_CHANGED_SIZE,
	BASEFL_CHANGED_SOLID,
	BASEFL_CHANGED_FRAME,
	BASEFL_CHANGED_SKIN,
	BASEFL_CHANGED_MOVETYPE,
	BASEFL_CHANGED_ALPHA,
	BASEFL_CHANGED_EFFECTS
};

class CBaseEntity
{
	string targetname;
	string target;

	void() CBaseEntity;

	virtual void() Init;
	virtual void() Initialized;
	virtual void(string, string) SpawnKey;
	virtual void(float flChanged) ReadEntity;
};

void CBaseEntity::ReadEntity(float flChanged)
{
	if (flChanged & BASEFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		modelindex = readshort();
	}
	if (flChanged & BASEFL_CHANGED_SOLID) {
		solid = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_MOVETYPE) {
		movetype = readbyte();

		if (movetype == MOVETYPE_PHYSICS) {
			movetype = MOVETYPE_NONE;
		}
	}
	if (flChanged & BASEFL_CHANGED_SIZE) {
		mins[0] = readcoord();
		mins[1] = readcoord();
		mins[2] = readcoord();
		maxs[0] = readcoord();
		maxs[1] = readcoord();
		maxs[2] = readcoord();
	}
	if (flChanged & BASEFL_CHANGED_FRAME) {
		frame = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_SKIN) {
		skin = readbyte();
	}
	if (flChanged & BASEFL_CHANGED_ALPHA) {
		alpha = readfloat();
	}
	if (flChanged & BASEFL_CHANGED_EFFECTS) {
		effects = readfloat();
	}

	if (modelindex) {
		drawmask = MASK_ENGINE;
	} else {
		drawmask = 0;
	}

	setorigin(this, origin);
	setsize(this, mins, maxs);
}

void CBaseEntity::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "targetname":
			targetname = strKey;
			break;
		case "target":
			target = strKey;
			break;
		case "origin":
			origin = stov(strKey);
			setorigin(this, origin);
			break;
		case "angles":
			angles = stov(strKey);
			break;
		case "model":
			model = strKey;
			break;
		case "style":
			style = stof(strKey);
			break;
		case "color":
			color = stov(strKey);
			break;
		case "movetype":
			movetype = stof(strKey);
			break;
		case "solid":
			solid = stof(strKey);
			break;
		case "scale":
			scale = stof(strKey);
			break;
		default:
			//dprint(sprintf("Unknown field %s, value %s\n", strField, strKey));
	}
}

void CBaseEntity::Init(void)
{
	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2) {
		//dprint(sprintf("SpawnData: %s %s\n", argv(i), argv(i+1)));
		SpawnKey(argv(i), argv(i+1));
	}
	Initialized();
}

void CBaseEntity::Initialized(void)
{
}

void CBaseEntity::CBaseEntity(void)
{
}
