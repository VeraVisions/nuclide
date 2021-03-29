/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

.float subblend2frac; // Up/Down

void
player::gun_offset(void)
{
	vector v1, v2;
	/* Set it to something consistent */
	this.p_model.angles = this.angles;

	/* Updates the v_ globals for the player hand bone angle */
	gettaginfo(this, this.p_hand_bone);

	/* Create angles from the v_ matrix */
	v1 = vectoangles(v_right, v_up);

	/* Updates the v_ globals for the weapon hand bone angle */
	gettaginfo(this.p_model, this.p_model_bone); 
	v2 = vectoangles(v_right, v_up);

	/* The difference is applied */
	this.p_model.angles = this.angles + (v1 - v2);

	/* Fix the origin */
	setorigin(this.p_model, this.origin);
	vector ofs = gettaginfo(this.p_model, this.p_model_bone) - gettaginfo(this, this.p_hand_bone);
	setorigin(this.p_model, this.origin - ofs);
}

string Weapons_GetPlayermodel(int);

void
player::draw(void)
{
	if (!this.p_model) {
		this.p_model = spawn();
		this.p_model.classname = "pmodel";
		this.p_model.owner = this;
	}

	this.subblendfrac =
	this.subblend2frac = (this.pitch / 90);

	Animation_PlayerUpdate();

	makevectors([0, this.angles[1], 0]);
	float fDirection = dotproduct(this.velocity, v_forward);

	if (fDirection < 0) {
		this.baseframe1time -= clframetime;
		this.baseframe2time -= clframetime;
		this.frame2time -= clframetime;
		this.frame1time -= clframetime;
	} else {
		this.baseframe1time += clframetime;
		this.baseframe2time += clframetime;
		this.frame2time += clframetime;
		this.frame1time += clframetime;
	}
	this.bonecontrol5 = getplayerkeyfloat(this.entnum - 1, "voiploudness");

	makevectors([0, this.angles[1], 0]);
	float fCorrect = dotproduct(this.velocity, v_right) * 0.25f;

#ifdef CSTRIKE
	/* hack, we can't play the animations in reverse the normal way */
	if (this.frame1time < 0.0f) {
		this.frame1time = 10.0f;
	}
	
	this.subblendfrac = -fCorrect * 0.05f;
	//this.subblend2frac *= -0.1f;
	this.angles[1] -= fCorrect;
#else
	/* hack, we can't play the animations in reverse the normal way */
	if (this.baseframe1time < 0.0f) {
		this.baseframe1time = 10.0f;
	}

	/* Turn torso */
	this.bonecontrol1 = fCorrect;
	this.bonecontrol2 = this.bonecontrol1 * 0.5;
	this.bonecontrol3 = this.bonecontrol2 * 0.5;
	this.bonecontrol4 = this.bonecontrol3 * 0.5;

	/* Correct the legs */
	this.angles[1] -= fCorrect;
#endif

	if (cvar("bonetest") == 1) {
		this.bonecontrol1 = cvar("bonecontrol1");
		this.bonecontrol2 = cvar("bonecontrol2");
		this.bonecontrol3 = cvar("bonecontrol3");
		this.bonecontrol4 = cvar("bonecontrol4");
		this.bonecontrol5 = cvar("bonecontrol5");
		this.subblendfrac = cvar("subblendfrac");
		this.subblend2frac = cvar("subblend2frac");
		this.basesubblendfrac = cvar("basesubblendfrac");
		this.basesubblend2frac = cvar("basesubblend2frac");
	}
}

float
player::predraw(void)
{
	/* Run animations regardless of rendering the player */
	draw();
	gun_offset();
	effects &= ~EF_NOSHADOW;

	if (autocvar_cl_thirdperson == TRUE || this.entnum != player_localentnum) {
		Voice_Draw3D(this);
		Player_PreDraw(this, TRUE);
		addentity(this);
		addentity(this.p_model);
	} else {
		Player_PreDraw(this, FALSE);
		removeentity(this);
		removeentity(this.p_model);
	}
	return PREDRAW_NEXT;
}

void
player::postdraw(void)
{
}
