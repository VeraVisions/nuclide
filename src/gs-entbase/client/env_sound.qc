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

/* this is causing crashes on OpenAL 1.19.1 when enabled */
//#define DSP_LERP

static string g_hlefx[] = {
	"default",
	"gs_generic",
	"gs_metal_s",
	"gs_metal_m",
	"gs_metal_l",
	"gs_tunnel_s",
	"gs_tunnel_m",
	"gs_tunnel_l",
	"gs_chamber_s",
	"gs_chamber_m",
	"gs_chamber_l",
	"gs_bright_s",
	"gs_bright_m",
	"gs_bright_l",
	"gs_water1",
	"gs_water2",
	"gs_water3",
	"gs_concrete_s",
	"gs_concrete_m",
	"gs_concrete_l",
	"gs_big1",
	"gs_big2",
	"gs_big3",
	"gs_cavern_s",
	"gs_cavern_m",
	"gs_cavern_l",
	"gs_weirdo1",
	"gs_weirdo2",
	"gs_weirdo3"
};

/*!QUAKED env_sound (0 1 0.5) (-8 -8 -8) (8 8 8)
# OVERVIEW
Client-side environmental reverb modifier.

# KEYS
- "radius" : Radius in units.
- "efx_file" : Name of the OpenAL EFX definiton to use.
- "roomtype" : Legacy enumeration for GoldSrc support. Please don't use this.

# NOTES
This works only with the OpenAL sound backend.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class env_sound:NSEntity
{
public:
	void env_sound(void);
	
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	virtual bool CanSpawn(bool);

private:
	int m_iRoomType;
	int m_iRadius;
};

bool
env_sound::CanSpawn(bool clientSide)
{
	return true;
}

void
env_sound::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "efx_file":
			m_iRoomType = EFX_Load(strKey);
			break;
		case "radius":
			m_iRadius = stoi(strKey);
			break;
		/* GoldSrc, legacy */
		case "roomtype":
			int efx_alias = stoi(strKey);

			if (efx_alias >= g_hlefx.length) {
				print("^1env_sound::SpawnKey: Invalid roomtype!\n");
				m_iRoomType = 0;
			} else
				m_iRoomType = EFX_Load(g_hlefx[efx_alias]);
			break;
		default:
			super::SpawnKey(strField, strKey);
	}
}

void
env_sound::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
}

void
env_sound::env_sound(void)
{
	m_iRadius = 256;
	isCSQC = true;
}
