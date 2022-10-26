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

void
bot::Pain(void)
{
	CGameRules rules = g_grMode;

	super::Pain();

	if (rules.IsTeamplay()) {
		if (g_dmg_eAttacker.flags & FL_CLIENT && g_dmg_eAttacker.team == team) {
			ChatSayTeam("Stop shooting me!");
			return;
		}
	}

	/* make this pain our new enemy! */
	if (g_dmg_eAttacker && g_dmg_eAttacker != this) {
		float enemydist = vlen(origin - m_eTarget.origin);
		float newdist = vlen(origin - g_dmg_eAttacker.origin);

		if (m_eTarget) 
			if (newdist < enemydist)
				SetEnemy(g_dmg_eAttacker);
		else
			SetEnemy(g_dmg_eAttacker);
	}
}

void
bot::SetEnemy(entity en)
{
	m_eTarget = en;

	if (m_eTarget)
		m_flEnemyDist = vlen(origin - m_eTarget.origin);
	else
		m_flEnemyDist = -1;
}

void
bot::WeaponThink(void)
{
	int r = Weapons_IsEmpty(this, activeweapon);

	/* clip empty, but the whole weapon isn't */
	if (r == 0 && a_ammo1 <= 0) {
		input_buttons &= ~INPUT_BUTTON0;
		input_buttons |= INPUT_BUTTON4;
	} else if (r == 1) {
		Weapons_SwitchBest(this, activeweapon);
	}

	m_wtWeaponType = Weapons_GetType(this, activeweapon);
}

void
bot::WeaponAttack(void)
{
	int should_attack = 0;

	/* only attack when the type's suggested distance makes sense to */
	if (m_wtWeaponType == WPNTYPE_RANGED) {
		if (m_flEnemyDist <= 1024)
			should_attack = 1;
	} else if (m_wtWeaponType == WPNTYPE_THROW) {
		if (m_flEnemyDist <= 512)
			should_attack = 1;
	} else if (m_wtWeaponType == WPNTYPE_CLOSE) {
		if (m_flEnemyDist <= 128)
			should_attack = 1;
	} else {
		if (m_flEnemyDist <= 1024)
			should_attack = 1;
	}

	if (should_attack && m_flAttackTime < time) {
		if (!m_iAttackMode) {
			input_buttons |= INPUT_BUTTON0;
		}

		/* this might not affect much */
		if (m_wtWeaponType != WPNTYPE_FULLAUTO) {
			switch (cvar("bot_skill")) {
			case 1:
				m_flAttackTime = time + 0.25f;
				break;
			case 2:
				m_flAttackTime = time + 0.10f;
				break;
			case 3:
				m_flAttackTime = time + 0.05f;
				break;
			default:
				m_flAttackTime = time + 1.0;
			}
		}
	} else {
		input_buttons &= ~INPUT_BUTTON0;
		input_buttons &= ~INPUT_BUTTON4;
		input_buttons &= ~INPUT_BUTTON5;
	}

	if (m_wtWeaponType != WPNTYPE_FULLAUTO)
		m_iAttackMode = 1 - m_iAttackMode;
	else
		m_iAttackMode = 0;
}

var float g_botalert_timer;

void
BotLib_Alert(vector pos, float radius, float t)
{
	CGameRules rules = g_grMode;

	/* sometimes many alert-sounds happen at once... we don't really want
	 * that */
	if (g_botalert_timer > time)
		return;

	for (entity w = world; (w = find(w,::targetname, "_nuclide_bot_"));) {
		/* out of radius */
		if (vlen(pos - w.origin) > radius)
			continue;

		bot f = (bot) w;

		/* they already got a target of some kind */
		if (f.m_eTarget)
			continue;

		/* if they're our friend... ignore */
		if (rules.IsTeamplay())
			if (w.team == t)
				continue;

		/* if the bot is dead... ignore */
		if (f.health <= 0)
			continue;

		/* we've heard a noise. investigate the location */
		print(sprintf("bot alerted by noise at %v\n", pos));
		f.RouteClear();
		f.RouteToPosition(pos);
	}

	g_botalert_timer = time + 0.5f;
}
