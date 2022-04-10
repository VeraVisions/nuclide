/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
player::draw(void)
{
	/* mouth flapping */
	this.bonecontrol5 = getplayerkeyfloat(this.entnum - 1, "voiploudness");

	/* DEBUG! */
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
	int this_us = 0;

	super::predraw();

	/* run animations regardless of rendering the player */
	draw();

	/* make sure we're enabling shadow rendering on us */
	effects &= ~EF_NOSHADOW;
	base_client cl = (base_client)pSeat->m_ePlayer;

	RenderFire();

	/* it's either us or us spectating */
	if (Client_IsSpectator(cl)) {
		spectator spec = (spectator)pSeat->m_ePlayer;
		if (entnum == spec.spec_ent && spec.spec_mode == SPECMODE_FIRSTPERSON) {
			this_us = 1;
		}
	} else {
		if (entnum == player_localentnum) {
			this_us = 1;
		}
	}

	if (autocvar_cl_thirdperson == TRUE || !this_us) {
		Voice_Draw3D(this);
		Player_PreDraw(this, TRUE);
		if (p_model)
			addentity(p_model);
		addentity(this);
	} else {
		Player_PreDraw(this, FALSE);
		if (p_model)
			removeentity(p_model);
		removeentity(this);
	}

	return (PREDRAW_NEXT);
}

void
player::postdraw(void)
{
}
