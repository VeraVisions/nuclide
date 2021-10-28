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

#define PREDICTED_INT(x) int x; int x ##_net
#define PREDICTED_FLOAT(x) float x; float x ##_net
#define PREDICTED_VECTOR(x) vector x; vector x ##_net
#define PREDICTED_ENT(x) entity x; entity x ##_net

#define PREDICTED_INT_N(x) int x ##_net
#define PREDICTED_FLOAT_N(x) float x ##_net
#define PREDICTED_VECTOR_N(x) vector x ##_net

#define ROLL_BACK(x) x = x ##_net
#define SAVE_STATE(x) x ##_net = x
#define ATTR_CHANGED(x) (x ##_net != x)
#define VEC_CHANGED(x,y) (x ##_net[y] != x[y])

class
#ifdef SERVER
base_player:NSSurfacePropEntity
#else
base_player
#endif
{
	PREDICTED_FLOAT(health);
	PREDICTED_FLOAT(armor);

	PREDICTED_FLOAT_N(modelindex);
	PREDICTED_VECTOR_N(origin);
	PREDICTED_VECTOR_N(velocity);
	PREDICTED_VECTOR_N(angles);
	PREDICTED_FLOAT_N(colormap);
	PREDICTED_FLOAT_N(flags);
	PREDICTED_FLOAT_N(gflags);
	PREDICTED_FLOAT(viewzoom);
	PREDICTED_VECTOR_N(view_ofs);
	PREDICTED_FLOAT_N(movetype);
	PREDICTED_VECTOR(v_angle);
	PREDICTED_FLOAT_N(pmove_flags);

	PREDICTED_FLOAT(w_attack_next);
	PREDICTED_FLOAT(w_idle_next);
	PREDICTED_FLOAT(teleport_time);
	PREDICTED_FLOAT(weapontime);
	PREDICTED_VECTOR(punchangle);

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	PREDICTED_INT(g_items);
	PREDICTED_FLOAT(activeweapon);

	/* vehicle info */
	PREDICTED_ENT(vehicle);

	/* these are NOT networked */
	int a_ammo1;
	int a_ammo2;
	int a_ammo3;

	/* any mods that use hooks */
	entity hook;

	void(void) base_player;

	virtual void(float) Physics_Fall;
	virtual void(void) Physics_Crouch;
	virtual void(void) Physics_Jump;
	virtual void(float) Physics_CheckJump;
	virtual void(void) Physics_SetViewParms;
	virtual void(void) Physics_WaterJump;
	virtual void(void) Physics_WaterMove;
	virtual float(void) Physics_MaxSpeed;
	virtual void(void) Physics_InputPreMove;
	virtual void(void) Physics_InputPostMove;
	virtual void(void) Physics_Run;

#ifdef CLIENT
	int sequence;
	float pitch;

	virtual void(float, float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	
	int voted;
	int step;
	float step_time;

	float underwater_time;
	float underwater_dmg;
	float pain_time;

	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(void) Respawn;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};
