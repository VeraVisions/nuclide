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

class CBaseMonster:CBaseEntity
{
	void() CBaseMonster;

	virtual void() touch;
	virtual void() Hide;
	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) vPain;
	virtual void(int) vDeath;
	virtual void() Physics;
	virtual void() Gib;
};

void CBaseMonster::Gib(void)
{
	takedamage = DAMAGE_NO;
	Effect_GibHuman(this.origin);
	Hide();
}

void CBaseMonster::Physics(void)
{
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;

	input_angles = angles = v_angle;
	input_timelength = frametime;
	movetype = MOVETYPE_WALK;

	runstandardplayerphysics(this);
	movetype = MOVETYPE_NONE;
}

void CBaseMonster::touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void CBaseMonster::PlayerUse(void)
{

}

void CBaseMonster::vPain(int iHitBody)
{

}

void CBaseMonster::vDeath(int iHitBody)
{
	customphysics = __NULL__;

	if (health < -50) {
		Gib();
		return;
	}

	solid = SOLID_CORPSE;
}

void CBaseMonster::Hide(void)
{
	setmodel(this, "");
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	customphysics = __NULL__;
}

void CBaseMonster::Respawn(void)
{
	setorigin(this, m_oldOrigin);
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_NONE;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	customphysics = Physics;
	health = 100;
	velocity = [0,0,0];
}

void CBaseMonster::CBaseMonster(void)
{
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
}
