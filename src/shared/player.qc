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
/*
=================
base_player::ReceiveEntity

Receive the generic client attributes from the server.
If you want to override this, do not call this
at the top of player::ReceiveEntity
=================
*/
void
base_player::ReceiveEntity(float new, float fl)
{
	/* store which input sequence we're on, this helps us
	 * later when we run prediction again between last/latest
	 * servercommandframe */
	sequence = servercommandframe;

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = 1.0f;
	}

	if (fl & PLAYER_MODELINDEX)
		modelindex = readshort();

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X) {
		v_angle[0] = pitch = readshort() / (32767 / 360);
		v_angle[1] = pitch = readshort() / (32767 / 360);
		v_angle[2] = pitch = readshort() / (32767 / 360);
	}
	if (fl & PLAYER_ANGLES_Y) {
		angles[0] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
		angles[1] = readshort() / (32767 / 360);
	}
	if (fl & PLAYER_COLORMAP)
		colormap = readbyte();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
		pmove_flags = readfloat();
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
	vehicle = findfloat(world, ::entnum, readentitynum());
}

/*
=================
base_player::PredictPreFrame

Save the state of the last server-confirmed attributes.
If you want to override this, do not call this
at the top of player::PredictPreFrame
=================
*/
void
base_player::PredictPreFrame(void)
{
	/* base player attributes/fields we're going to roll back */
	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(v_angle);
	SAVE_STATE(colormap);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(pmove_flags);
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
	SAVE_STATE(vehicle);
}

/*
=================
base_player::PredictPostFrame

After running prediction on the client, roll back the values
to the server's confirmed saved attributes from PredictPreFrame.
If you want to override this, do not call this
at the top of player::PredictPostFrame
=================
*/
void
base_player::PredictPostFrame(void)
{
	/* finally roll the values back */
	ROLL_BACK(modelindex);
	ROLL_BACK(origin);
	ROLL_BACK(angles);
	ROLL_BACK(v_angle);
	ROLL_BACK(colormap);
	ROLL_BACK(velocity);
	ROLL_BACK(flags);
	ROLL_BACK(gflags);
	ROLL_BACK(pmove_flags);
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
	ROLL_BACK(vehicle);
}
#else
void
base_player::Save(float handle)
{
	SaveFloat(handle, "health", health);
	SaveFloat(handle, "armor", armor);
	SaveFloat(handle, "modelindex", modelindex);
	SaveVector(handle, "origin", origin);
	SaveVector(handle, "velocity", velocity);
	SaveVector(handle, "angles", angles);
	SaveFloat(handle, "colormap", colormap);
	SaveFloat(handle, "flags", flags);
	SaveFloat(handle, "gflags", gflags);
	SaveFloat(handle, "viewzoom", viewzoom);
	SaveVector(handle, "view_ofs", view_ofs);
	SaveVector(handle, "v_angle", v_angle);
	SaveVector(handle, "punchangle", punchangle);
	SaveFloat(handle, "movetype", movetype);
	SaveFloat(handle, "pmove_flags", pmove_flags);
	SaveFloat(handle, "w_attack_next", w_attack_next);
	SaveFloat(handle, "w_idle_next", w_idle_next);
	SaveFloat(handle, "teleport_time", teleport_time);
	SaveFloat(handle, "weapontime", weapontime);
	SaveInt(handle, "g_items", g_items);
	SaveFloat(handle, "activeweapon", activeweapon);
	SaveFloat(handle, "vehicle", num_for_edict(vehicle));
}

void
base_player::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		health = ReadFloat(strValue);
		break;
	case "armor":
		armor = ReadFloat(strValue);
		break;
	case "modelindex":
		modelindex = ReadFloat(strValue);
		break;
	case "origin":
		origin = ReadVector(strValue);
		break;
	case "velocity":
		velocity = ReadVector(strValue);
		break;
	case "angles":
		angles = ReadVector(strValue);
		break;
	case "colormap":
		colormap = ReadFloat(strValue);
		break;
	case "flags":
		flags = ReadFloat(strValue);
		break;
	case "gflags":
		gflags = ReadFloat(strValue);
		break;
	case "view_ofs":
		view_ofs = ReadVector(strValue);
		break;
	case "v_angle":
		v_angle = ReadVector(strValue);
		break;
	case "punchangle":
		punchangle = ReadVector(strValue);
		break;
	case "movetype":
		movetype = ReadFloat(strValue);
		break;
	case "pmove_flags":
		pmove_flags = ReadFloat(strValue);
		break;
	case "w_attack_next":
		w_attack_next = ReadFloat(strValue);
		break;
	case "w_idle_next":
		w_idle_next = ReadFloat(strValue);
		break;
	case "teleport_time":
		teleport_time = ReadFloat(strValue);
		break;
	case "weapontime":
		weapontime = ReadFloat(strValue);
		break;
	case "g_items":
		g_items = ReadInt(strValue);
		break;
	case "activeweapon":
		activeweapon = ReadFloat(strValue);
		break;
	case "vehicle":
		vehicle = edict_num(ReadFloat(strValue));
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

/*
=================
base_player::Respawn

it'd be pretty unfortunate if 'sv respawn_ents' or something called this
=================
*/
void
base_player::Respawn(void)
{
	/* make sure nothing happens here */
}

/*
=================
base_player::EvaluateEntity

Check which attributes have changed and flag the ones that did.
If you want to override this, do not call this
at the top of player::EvaluateEntity
=================
*/
void
base_player::EvaluateEntity(void)
{
	SetSendFlags(PLAYER_KEEPALIVE);

	if (ATTR_CHANGED(modelindex))
		SetSendFlags(PLAYER_MODELINDEX);

	if (VEC_CHANGED(origin, 0))
		SetSendFlags(PLAYER_ORIGIN);

	if (VEC_CHANGED(origin, 1))
		SetSendFlags(PLAYER_ORIGIN);

	if (VEC_CHANGED(origin, 2))
		SetSendFlags(PLAYER_ORIGIN_Z);

	if (VEC_CHANGED(v_angle, 0) || VEC_CHANGED(v_angle, 1) || VEC_CHANGED(v_angle, 2))
		SetSendFlags(PLAYER_ANGLES_X);

	if (VEC_CHANGED(angles, 0) || VEC_CHANGED(angles, 1) || VEC_CHANGED(angles, 2))
		SetSendFlags(PLAYER_ANGLES_Y);

	if (ATTR_CHANGED(colormap))
		SetSendFlags(PLAYER_COLORMAP);

	if (VEC_CHANGED(velocity, 0))
		SetSendFlags(PLAYER_VELOCITY);

	if (VEC_CHANGED(velocity, 1))
		SetSendFlags(PLAYER_VELOCITY);

	if (VEC_CHANGED(velocity, 2))
		SetSendFlags(PLAYER_VELOCITY_Z);

	if (ATTR_CHANGED(flags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(gflags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(pmove_flags))
		SetSendFlags(PLAYER_FLAGS);

	if (ATTR_CHANGED(activeweapon))
		SetSendFlags(PLAYER_WEAPON);

	if (ATTR_CHANGED(g_items))
		SetSendFlags(PLAYER_ITEMS);

	if (ATTR_CHANGED(health))
		SetSendFlags(PLAYER_HEALTH);

	if (ATTR_CHANGED(armor))
		SetSendFlags(PLAYER_ARMOR);

	if (ATTR_CHANGED(movetype))
		SetSendFlags(PLAYER_MOVETYPE);

	if (ATTR_CHANGED(view_ofs))
		SetSendFlags(PLAYER_VIEWOFS);

	SAVE_STATE(modelindex);
	SAVE_STATE(origin);
	SAVE_STATE(angles);
	SAVE_STATE(colormap);
	SAVE_STATE(velocity);
	SAVE_STATE(flags);
	SAVE_STATE(gflags);
	SAVE_STATE(pmove_flags);
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
	SAVE_STATE(vehicle);
}

/*
=================
base_player::SendEntity

Network any attributes that have been flagged for networking.
If you want to override this, do not call this
at the top of player::SendEntity
=================
*/
float
base_player::SendEntity(entity ePEnt, float fChanged)
{
	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);

	/* if origin[0] changes, it's very likely [1] changes too, since
	 * we rarely ever walk in a straight line on the world grid */
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	/* the height doesn't change as much */
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);

	if (fChanged & PLAYER_ANGLES_X) {
		WriteShort(MSG_ENTITY, v_angle[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, v_angle[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, v_angle[2] * 32767 / 360);
	}
	if (fChanged & PLAYER_ANGLES_Y) {
		WriteShort(MSG_ENTITY, angles[0] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[1] * 32767 / 360);
		WriteShort(MSG_ENTITY, angles[2] * 32767 / 360);
	}
	if (fChanged & PLAYER_COLORMAP)
		WriteByte(MSG_ENTITY, colormap);

	/* similar as with origin, we separate x/y from z */
	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}
	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);

	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
		WriteFloat(MSG_ENTITY, pmove_flags);
	}
	if (fChanged & PLAYER_WEAPON)
		WriteByte(MSG_ENTITY, activeweapon);

	/* g_items is a proper integer, so we can't let WriteFloat truncate it (hence __variant) */
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);

	/* only got byte precision, clamp to avoid weird values on the client-side */
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, bound(0, armor, 255));

	if (fChanged & PLAYER_MOVETYPE)
		WriteByte(MSG_ENTITY, movetype);

	/* the view_ofs[0] and [1] are rarely changed */
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

	if (vehicle)
		WriteEntity(MSG_ENTITY, vehicle);
	else
		WriteEntity(MSG_ENTITY, __NULL__);

	return (1);
}
#endif

void
base_player::base_player(void)
{
	vehicle = __NULL__;
}
