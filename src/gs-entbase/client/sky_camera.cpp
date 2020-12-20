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

/*QUAKED sky_camera (1 0.3 1) (-8 -8 -8) (8 8 8)
"scale"    Scale modifier. Default is '16'.

Defines the position of a skyroom camera.
You want to put this into a dedicated room that contains a 3D skybox.
The scale modifier is more like a divider. You want to keep these
divisable by 2 to avoid any precision funkyness.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

var int autocvar_dev_skyscale = 0;
var vector g_skypos;
var int g_skyscale;

class
sky_camera:CBaseEntity
{
	void(void) sky_camera;
	virtual void(string, string) SpawnKey;
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
			CBaseEntity::SpawnKey(strField, strKey);
	}
}

void
sky_camera::sky_camera(void)
{
	g_skyscale = 16;
	Init();
}

void
SkyCamera_Setup(vector org)
{
	if (g_skyscale != 0 && g_skypos) {
		vector porg;
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
