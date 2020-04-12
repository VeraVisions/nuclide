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

/*QUAKED light (1 0 0) (-8 -8 -8) (8 8 8) OFF_OR_LINEAR
"targetname"    Name

Infinitely small point of light illuminating the scene.

idTech 3 BSP relevant keys:
"light"         Light intensity value. Default is '300'.
"_color"        Normalized RGB color value. Default is '1 1 1'.
"radius"        Sets the light cone radius. Default is '64'.
"target"        When set, targets an enity instead, becoming a spotlight.

If OFF_OR_LINEAR is set, the light will be cast with a linear falloff instead
of inverse square. This is useful for bright lights that'll travel long
distances.

idTech 2 BSP relevant keys:
"light"         Defines the brightness of the light.
"style"         Light style ID. 0-11 are defined, 12-32 are reserved for switched
                lights. List of pre-defined styles:
                    0 = Normal
                    1 = Flicker A
                    2 = Slow strong pulse
                    3 = Candle A
                    4 = Fast strobe
                    5 = Gentle pulse
                    6 = Flicker B
                    7 = Candle B
                    8 = Candle C
                    9 = Slow strobe
                    10 = Fluorescent flicker
                    11 = Slow pulse, no black
"pattern"       Custom light style pattern. Needs unique light style ID.
                Patterns are defined with letters of the alphabet.
                'a' being dark. 'z' being fully lit. Can be a string of characters
                that'll interpolate between at 10 FPS ingame.

If OFF_OR_LINEAR is set, it starts off/disabled.
*/

class light:CBaseTrigger
{
	int m_iEnabled;
	float m_flStyle;
	string m_strPattern;

	void(void) light;
	virtual void(void) Trigger;
	virtual void(void) Respawn;
};

void light::Trigger(void)
{
	if (m_iEnabled == TRUE) {
		lightstyle(m_flStyle, "a");
		m_iEnabled = FALSE;
	} else {
		lightstyle(m_flStyle, m_strPattern);
		m_iEnabled = TRUE;
	}
}

void light::Respawn(void)
{
	if (spawnflags & 1) {
		lightstyle(m_flStyle, "a");
		m_iEnabled = FALSE;
	} else {
		lightstyle(m_flStyle, m_strPattern);
		m_iEnabled = TRUE;
	}
}

void light::light(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "pattern":
			m_strPattern = argv(i+1);
			break;
		case "style":
			m_flStyle = stof(argv(i+1));
			style = __NULL__;
			break;
		default:
			break;
		}
	}

	if (!m_strPattern) {
		m_strPattern = "m";
	}
}

CLASSEXPORT(light_spot, light)
CLASSEXPORT(light_environment, light)

