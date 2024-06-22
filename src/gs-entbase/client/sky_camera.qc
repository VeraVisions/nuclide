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

var int autocvar_dev_skyscale = 0;
var vector g_skypos;
var int g_skyscale;

/*! \brief Client-Entity: Skybox Camera Controller */
/*!QUAKED sky_camera (1 0.3 1) (-8 -8 -8) (8 8 8)
# OVERVIEW
Defines the position of a skyroom camera.

# KEYS
- "scale" : Scale modifier. Default is "16".

# NOTES
You want to put this into a dedicated room that contains a 3D skybox.
The scale modifier is more like a divider. You want to keep these
divisable by 2 to avoid any precision funkyness.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup client
@ingroup pointentity
*/
class
sky_camera:NSEntity
{
public:
	void sky_camera(void);

	virtual void SpawnKey(string, string);
	virtual bool CanSpawn(bool);
};

void
sky_camera::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "scale":
		g_skyscale = stoi(strKey);
		break;
	case "origin":
		origin = stov(strKey);
		setorigin(this, origin);
		g_skypos = origin;
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

bool
sky_camera::CanSpawn(bool clientSide)
{
	return true;
}

void
sky_camera::sky_camera(void)
{
	g_skyscale = 16;
	isCSQC = true;
}

void
SkyCamera_Setup(vector org)
{
	if (g_skyscale != 0 && g_skypos) {
		vector realpos;
			
		if (autocvar_dev_skyscale) {
			realpos[0] = org[0] / autocvar_dev_skyscale;
			realpos[1] = org[1] / autocvar_dev_skyscale;
			realpos[2] = org[2] / autocvar_dev_skyscale;
		} else {
			realpos[0] = org[0] / g_skyscale;
			realpos[1] = org[1] / g_skyscale;
			realpos[2] = org[2] / g_skyscale;
		}
		setproperty(VF_SKYROOM_CAMERA, g_skypos + realpos);
	}
}
