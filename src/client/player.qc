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
	super::predraw();

	/* run animations regardless of rendering the player */
	draw();

	/* make sure we're enabling shadow rendering on us */
	effects &= ~EF_NOSHADOW;

	if (autocvar_cl_thirdperson == TRUE || this.entnum != player_localentnum) {
		Voice_Draw3D(this);
		Player_PreDraw(this, TRUE);
		addentity(this);
	} else {
		Player_PreDraw(this, FALSE);
		removeentity(this);
	}

	return (PREDRAW_NEXT);
}

void
player::postdraw(void)
{
}
