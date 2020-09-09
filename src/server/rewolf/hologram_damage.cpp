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
	int m_iType;

	void(void) hologram_damage;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
hologram_damage::Respawn(void)
{
	SetRenderMode(RM_ADDITIVE);

	switch (m_iType) {
	case 1:
		model = "models/tube.mdl";
		break;
	case 2:
		model = "models/raptor.mdl";
		break;
	default:
		model = "models/beak.mdl";
	}

	SetModel(model);
}

void
hologram_damage::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "creaturetype":
		m_iType = stoi(strValue);
		break;
	default:
		CBaseNPC::SpawnKey(strKey, strValue);
	}
}

void
hologram_damage::hologram_damage(void)
{
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
}
