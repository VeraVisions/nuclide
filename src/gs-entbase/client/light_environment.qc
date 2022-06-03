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
 
/*QUAKED light_environment (1 0 0) (-8 -8 -8) (8 8 8) ?
Defines the overall ambient skylight in the map.

-------- KEYS --------
"color" : Normalized RGB color value. Default is [1,1,1]
"color255" : RGB255 color value. e.g. '255 255 255' for white
"ambientcolor" : Shadow color. Normalized RGB color value. Default is [1,1,1]
"ambientcolor255" : Shadow color. RGB255 color value. e.g. '255 255 255' for white
"intensity" : Overall intensity of the sky light. '300' is probably okay for a day level.
"sunangle" : The yaw position of the sun, basically the horizontal direction.
"pitch" : The vertical position of the sun. '-90' means straight down, '-45' is diagonal etc.
"samples" : The amount of passes onto the lightmap, this is required for spread.
"sunspreadangle" : The offset of each sample pass in degrees, basically horizontal jitter.
"filterradius" : Blur amount for each pass. This will make cloud scenes work well.

-------- NOTES --------
Only one is effective per map.
Sun light generally is white, unless the atmosphere/horizon is coloring it.
The ambientcolor should generally be set to that of the skybox for the most
realistic depiction of the world.
As mentioned before, the 'sunspreadangle' and 'filterradius' keys only work
if 'samples' is set to something higher than 1, as those are parameters for
said behaviour. There's no point in setting 'samples' to something higher than
1 if you aren't bothering to supply a valid 'sunspreadangle' and 'filterradius'
key either.

For cloudly/overcast skies, I'd recommend setting the 'pitch' to '-45', then
'samples' to at least '4' and 'sunspreadangle to '360' with a 'filterradius'
of at least '1'. This will ensure that the sunlight will be cast diagonally
from 4 positions across the entire horizon - thus eliminating any harsh shadows.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class light_environment:NSEntity
{
	void(void) light_environment;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
light_environment::Respawn(void)
{
	setorigin(this, origin);
	makevectors(g_vecSunDir);
	cvar_set("r_shadows_throwdirection", sprintf("%v", v_forward));
}

void
light_environment::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "pitch":
		g_vecSunDir[0] = stof(strKey);
		break;
	case "sunangle":
		g_vecSunDir[1] = stof(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
light_environment::light_environment(void)
{
	solid = SOLID_NOT;
	isCSQC = true;
}
