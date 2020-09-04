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

class hologram_damage:CBaseNPC
{
	void(void) hologram_damage;

	virtual void(void) Respawn;
};

void
hologram_damage::Respawn(void)
{
	//SetRenderMode(RM_ADDITIVE);
}

void
hologram_damage::hologram_damage(void)
{
	int mdltype;

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "creaturetype":
			mdltype = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}

	switch (mdltype) {
	case 1:
		model = "models/tube.mdl";
		break;
	case 2:
		model = "models/raptor.mdl";
		break;
	default:
		model = "models/beak.mdl";
	}

	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
