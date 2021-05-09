/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

#ifdef CLIENT
void
base_player::ReceiveEntity(float new, float fl)
{
	/* seed for our prediction table */
	sequence = servercommandframe;

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = __NULL__;
	}

	if (fl & PLAYER_MODELINDEX)
		modelindex = readshort();

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X)
		pitch = readfloat();
	if (fl & PLAYER_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & PLAYER_ANGLES_Z)
		angles[2] = readfloat();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
	}
	if (fl & PLAYER_WEAPON)
		activeweapon = readbyte();
	if (fl & PLAYER_ITEMS)
		g_items = (__variant)readfloat();
	if (fl & PLAYER_HEALTH)
		health = readbyte();
	if (fl & PLAYER_ARMOR)
		armor = readbyte();
	if (fl & PLAYER_MOVETYPE)
		movetype = readbyte();
	if (fl & PLAYER_VIEWOFS)
		view_ofs[2] = readfloat();

	/* TO OPTIMISE */
	teleport_time = readfloat();
	viewzoom = readfloat();
	weapontime = readfloat();
	w_attack_next = readfloat();
	w_idle_next = readfloat();
	punchangle[0] = readfloat();
	punchangle[1] = readfloat();
	punchangle[2] = readfloat();
}

void
base_player::PredictPreFrame(void)
{
	/* base player attributes/fields we're going to roll back */
	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(activeweapon);
	SAVE_STATE(g_items);
	SAVE_STATE(health);
	SAVE_STATE(armor);
	SAVE_STATE(movetype);
	SAVE_STATE(view_ofs);

	/* TO OPTIMISE */
	SAVE_STATE(teleport_time);
	SAVE_STATE(viewzoom);
	SAVE_STATE(weapontime);
	SAVE_STATE(w_attack_next);
	SAVE_STATE(w_idle_next);
	SAVE_STATE(punchangle);
}

void
base_player::PredictPostFrame(void)
{
	/* finally roll the values back */
	ROLL_BACK(modelindex);
	ROLL_BACK(origin);
	ROLL_BACK(angles);
	ROLL_BACK(velocity);
	ROLL_BACK(flags);
	ROLL_BACK(gflags);
	ROLL_BACK(activeweapon);
	ROLL_BACK(g_items);
	ROLL_BACK(health);
	ROLL_BACK(armor);
	ROLL_BACK(movetype);
	ROLL_BACK(view_ofs);

	/* TO OPTIMISE */
	ROLL_BACK(teleport_time);
	ROLL_BACK(viewzoom);
	ROLL_BACK(weapontime);
	ROLL_BACK(w_attack_next);
	ROLL_BACK(w_idle_next);
	ROLL_BACK(punchangle);
}

#else
void
base_player::EvaluateEntity(void)
{
	SendFlags |= PLAYER_KEEPALIVE;

	if (ATTR_CHANGED(modelindex))
		SendFlags |= PLAYER_MODELINDEX;

	if (VEC_CHANGED(origin, 0))
		SendFlags |= PLAYER_ORIGIN;

	if (VEC_CHANGED(origin, 1))
		SendFlags |= PLAYER_ORIGIN;

	if (VEC_CHANGED(origin, 2))
		SendFlags |= PLAYER_ORIGIN_Z;

	if (VEC_CHANGED(v_angle, 0))
		SendFlags |= PLAYER_ANGLES_X;

	if (VEC_CHANGED(angles, 1))
		SendFlags |= PLAYER_ANGLES_Y;

	if (VEC_CHANGED(angles, 2))
		SendFlags |= PLAYER_ANGLES_Z;

	if (VEC_CHANGED(velocity, 0))
		SendFlags |= PLAYER_VELOCITY;

	if (VEC_CHANGED(velocity, 1))
		SendFlags |= PLAYER_VELOCITY;

	if (VEC_CHANGED(velocity, 2))
		SendFlags |= PLAYER_VELOCITY_Z;

	if (ATTR_CHANGED(flags))
		SendFlags |= PLAYER_FLAGS;

	if (ATTR_CHANGED(gflags))
		SendFlags |= PLAYER_FLAGS;

	if (ATTR_CHANGED(activeweapon))
		SendFlags |= PLAYER_WEAPON;

	if (ATTR_CHANGED(g_items))
		SendFlags |= PLAYER_ITEMS;

	if (ATTR_CHANGED(health))
		SendFlags |= PLAYER_HEALTH;

	if (ATTR_CHANGED(armor))
		SendFlags |= PLAYER_ARMOR;

	if (ATTR_CHANGED(movetype))
		SendFlags |= PLAYER_MOVETYPE;

	if (ATTR_CHANGED(view_ofs))
		SendFlags |= PLAYER_VIEWOFS;

	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(activeweapon);
	SAVE_STATE(g_items);
	SAVE_STATE(health);
	SAVE_STATE(armor);
	SAVE_STATE(movetype);
	SAVE_STATE(view_ofs);

	/* TO OPTIMISE */
	SAVE_STATE(teleport_time);
	SAVE_STATE(viewzoom);
	SAVE_STATE(weapontime);
	SAVE_STATE(w_attack_next);
	SAVE_STATE(w_idle_next);
	SAVE_STATE(punchangle);
}

float
base_player::SendEntity(entity ePEnt, float fChanged)
{
	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);
	if (fChanged & PLAYER_ANGLES_X)
		WriteFloat(MSG_ENTITY, v_angle[0]);
	if (fChanged & PLAYER_ANGLES_Y)
		WriteFloat(MSG_ENTITY, angles[1]);
	if (fChanged & PLAYER_ANGLES_Z)
		WriteFloat(MSG_ENTITY, angles[2]);

	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}

	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);

	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
	}
	if (fChanged & PLAYER_WEAPON)
		WriteByte(MSG_ENTITY, activeweapon);
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, bound(0, armor, 255));
	if (fChanged & PLAYER_MOVETYPE)
		WriteByte(MSG_ENTITY, movetype);
	if (fChanged & PLAYER_VIEWOFS)
		WriteFloat(MSG_ENTITY, view_ofs[2]);

	/* TO OPTIMISE */
	WriteFloat(MSG_ENTITY, teleport_time);
	WriteFloat(MSG_ENTITY, viewzoom);
	WriteFloat(MSG_ENTITY, weapontime);
	WriteFloat(MSG_ENTITY, w_attack_next);
	WriteFloat(MSG_ENTITY, w_idle_next);
	WriteFloat(MSG_ENTITY, punchangle[0]);
	WriteFloat(MSG_ENTITY, punchangle[1]);
	WriteFloat(MSG_ENTITY, punchangle[2]);

	return TRUE;
}
#endif