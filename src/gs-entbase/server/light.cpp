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

/*QUAKED light (1 0 0) (-8 -8 -8) (8 8 8) LFL_LINEAR LFL_NOANGLE LFL_DARK LFL_NOGRID x LFL_DISTATTN
"targetname"    Name
"target"        When set, targets an enity instead, becoming a spotlight
"light"         Light intensity value. Default is '300'
"_color"        Normalized RGB color value. Default is [1,1,1]
"_color255"     RGB255 color value. e.g. '255 255 255' for white
"_extradist"    The additional distance it should attempt to travel.
"radius"        Sets the light cone radius for spotlights. Default is '64'
"fade"          Sets the fade-distance of a light when LFL_LINEAR is set
"_anglescale"   Sets the light angle scale of non-linear lights
"_deviance"     Sets the deviance, jitter effect for each light sample.
"_samples"      Number of light samples. This also needs to be set > 1 for deviance to work.
"_filter"       Setting to blur the light/shadows resulting from this light.
"start_active"  Set to either 0 or 1 to tell the light in what mode to start in.

Infinitely small point of light illuminating the scene.

If LFL_LINEAR is set, the light will be cast with a linear falloff instead
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

In idTech 2/GoldSrc etc. spawnflag 1 means a light starts off.
This doesn't exist in idTech3 because lightstyles were not a thing.

Trivia:
This entity was introduced in Quake (1996).
*/

class light:CBaseTrigger
{
	int m_iEnabled;
	float m_flStyle;
	float m_flSwitchStyle;
	string m_strPattern;
	int m_iStartActive;

	void(void) light;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
light::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iEnabled = 0;
		break;
	case TRIG_ON:
		m_iEnabled = 1;
		break;
	default:
		m_iEnabled = 1 - m_iEnabled;
	}

	if (m_iEnabled == 0) {
		lightstyle(m_flStyle, "a");
	} else {
		lightstyle(m_flStyle, m_strPattern);
	}
}

void
light::Respawn(void)
{
	switch (serverkeyfloat("*bspversion")) {
	case BSPVER_PREREL:
	case BSPVER_Q1:
	case BSPVER_HL:
	case BSPVER_Q2:
	case BSPVER_Q2W:
		if (spawnflags & 1 && targetname) {
			lightstyle(m_flStyle, "a");
			m_iEnabled = 0;
		} else {
			lightstyle(m_flStyle, m_strPattern);
			m_iEnabled = 1;
		}
		break;
	case BSPVER_Q3:
	case BSPVER_RTCW:
	case BSPVER_RBSP:
		if (!m_iStartActive && targetname) {
			lightstyle(m_flStyle, "a");
			m_iEnabled = 0;
		} else {
			lightstyle(m_flStyle, m_strPattern);
			m_iEnabled = 1;
		}
		break;
	}
}

void
light::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "pattern":
		m_strPattern = strValue;
		break;
	case "switch_style":
		m_flSwitchStyle = stof(strValue);
		break;
	case "style":
		m_flStyle = stof(strValue);
		style = __NULL__;
		break;
	case "start_active":
		m_iStartActive = stoi(strValue);
		break;
	/* level-compiler keys we don't really use right now */
	case "_cone":
	case "_cone2":
	case "_sky":
	case "pitch":
	case "_light":
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
light::light(void)
{
	m_iStartActive = TRUE;
	m_strPattern = "m";
	CBaseTrigger::CBaseTrigger();

	/* switch styles before 12 are builtins from Quake. */
	if (m_flSwitchStyle > 0 && m_flSwitchStyle <= 11) {
		m_strPattern = getlightstyle(m_flSwitchStyle);
	}
}

CLASSEXPORT(light_spot, light)
CLASSEXPORT(light_environment, light)
