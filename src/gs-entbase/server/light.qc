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

/*! \brief Tool/Server-Entity: Light Source */
/*!QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) LFL_LINEAR x LFL_DARK LFL_NOGRID x x
# OVERVIEW
Infinitely small point of light illuminating the scene.

# KEYS
- "targetname" : Name
- "target" : When set, targets an enity instead, becoming a spotlight
- "light" : Light intensity value. Default is '300'
- "color" : Normalized RGB color value. Default is [1,1,1]
- "color255" : RGB255 color value. e.g. '255 255 255' for white
- "extradist" : The additional distance it should attempt to travel.
- "radius" : Sets the light cone radius for spotlights. Default is '64'
- "fade" : Sets the fade-distance of a light when LFL_LINEAR is set
- "anglescale" : Sets the light angle scale of non-linear lights
- "deviance" : Sets the deviance, jitter effect for each light sample.
- "samples" : Number of light samples. This also needs to be set > 0.0 for deviance to work.
- "filter" : Setting to blur the light/shadows resulting from this light.
- "start_active" : Set to either 0 or 1 to tell the light in what mode to start in.
- "style" : Light style ID. 0-11 are defined, 12-32 are reserved for switched  
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
- "pattern" : Custom light style pattern. Needs unique light style ID set in the "style" field (numbers above 32).
            Patterns are defined with letters of the alphabet.  
            'a' being dark. 'z' being fully lit. Its string of characters  
            get interpreted as brightness values and are interpolated between at 10 frames-per-second in the game.

# SPAWNFLAGS
- LFL_LINEAR (1) : Use linear distance falloff instead of inverse-square falloff.
- LFL_DARK (4) : Darken, instead of illuminating the lightmap.
- LFL_NOGRID (8) : This light does not affect the lightgrid.

# NOTES
In idTech 2/GoldSrc etc. `"spawnflag" "1"` in the light entity data means it starts off, disabled, dark.  
This uses the lightstyle feature from Quake, where an area of a level can be handled by up to 4 overlapping
lightmap sheets from lights with different "style" values.

This doesn't exist in idTech3 because lightstyles were not a thing originally. While there are Q3 BSP compilers that try to address this, it's a significant source of of lightmap abuse. As a general piece of advice, please consider using light_dynamic or env_projectedtexture for toggled or flickering lights.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup pointentity
*/
class
light:ncPointTrigger
{
public:
	void light(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void RestoreComplete(void);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
	virtual void DebugDraw(void);

private:
	int m_iEnabled;
	int m_iStartActive;
	float m_flStyle;
	float m_flSwitchStyle;
	string m_strPattern;

	vector _lightColor;
};

void
light::light(void)
{
	m_iEnabled = 0;
	m_iStartActive = TRUE;
	m_strPattern = "m";
	m_flStyle = 0;
	m_flSwitchStyle = 0;
	_lightColor = [1,1,1];
}

void
light::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iEnabled", m_iEnabled);
	SaveInt(handle, "m_iStartActive", m_iStartActive);
	SaveFloat(handle, "m_flStyle", m_flStyle);
	SaveFloat(handle, "m_flSwitchStyle", m_flSwitchStyle);
	SaveString(handle, "m_strPattern", m_strPattern);
}

void
light::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iEnabled":
		m_iEnabled = ReadInt(setValue);
		break;
	case "m_iStartActive":
		m_iStartActive = ReadInt(setValue);
		break;
	case "m_flStyle":
		m_flStyle = ReadFloat(setValue);
		break;
	case "m_flSwitchStyle":
		m_flSwitchStyle = ReadFloat(setValue);
		break;
	case "m_strPattern":
		m_strPattern = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
light::RestoreComplete(void)
{
	/* not switchable */
	if (m_flStyle < 12)
		return;

	if (m_iEnabled == 0) {
		lightstyle(m_flStyle, "a");
	} else {
		lightstyle(m_flStyle, m_strPattern);
	}
}

void
light::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "pattern":
		m_strPattern = setValue;
		break;
	case "switch_style":
		m_flSwitchStyle = stof(setValue);
		break;
	case "style":
		m_flStyle = stof(setValue);
		style = __NULL__;
		break;
	case "start_active":
		m_iStartActive = stoi(setValue);
		break;
	/* level-compiler keys we don't really use right now */
	case "_cone":
	case "_cone2":
	case "_sky":
	/* mostly for light_environment */
	case "pitch":
		angles[0] = ReadFloat(setValue);
		break;
	case "sunangle":
		angles[1] = ReadFloat(setValue);
		break;
	case "color":
		_lightColor = ReadVector(setValue);
		break;
	case "_light":
	case "color255":
		_lightColor = ReadVector(setValue) / 255;
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
light::Input(entity theActivator, string inputName, string dataString)
{
	switch (inputName) {
	case "TurnOn":
		Trigger(theActivator, TRIG_ON);
		break;
	case "TurnOff":
		Trigger(theActivator, TRIG_OFF);
		break;
	default:
		super::Input(theActivator, inputName, dataString);
	}
}

void
light::Spawned(void)
{
	super::Spawned();

	/* switch styles before 12 are builtins from Quake. */
	if (m_flSwitchStyle > 0 && m_flSwitchStyle <= 11) {
		m_strPattern = getlightstyle(m_flSwitchStyle);
	}
}

void
light::Respawn(void)
{
	InitPointTrigger();

	switch (serverkeyfloat("*bspversion")) {
	case BSPVER_PREREL:
	case BSPVER_Q1:
	case BSPVER_HL:
	case BSPVER_Q2:
	case BSPVER_Q2W:
		if (HasSpawnFlags(1) && targetname) {
			m_iEnabled = 0;
		} else {
			m_iEnabled = 1;
		}
		break;
	case BSPVER_Q3:
	case BSPVER_RTCW:
	case BSPVER_RBSP:
		if (!m_iStartActive && targetname) {
			m_iEnabled = 0;
		} else {
			m_iEnabled = 1;
		}
		break;
	default:
		m_iEnabled = 1;
	}

	RestoreComplete();
}

void
light::Trigger(entity act, triggermode_t state)
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

	RestoreComplete();
}

void
light::DebugDraw(void)
{
#ifdef SERVER
	string debugIcon;

	if (m_iEnabled) {
		debugIcon = "gfx/icon16/lightbulb";
	} else {
		debugIcon = "gfx/icon16/lightbulb_off";
	}

	R_BeginPolygon(debugIcon, 0, 0);
		R_PolygonVertex(GetOrigin() + v_right * 8 - v_up * 8, [1,1], _lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 8 - v_up * 8, [0,1], _lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 8 + v_up * 8, [0,0], _lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() + v_right * 8 + v_up * 8, [1,0], _lightColor, 1.0f);
	R_EndPolygon();
#endif
}


class
light_spot:light
{
	void light_spot(void);
};

void
light_spot::light_spot(void)
{

}

class
light_environment:light
{
public:
	void light_environment(void);

	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
};

void
light_environment::light_environment(void)
{

}

void
light_environment::Spawned(void)
{
	super::Spawned();
	//sunLight.m_vecLightColor = _lightColor;
	classname = "light_environment";
}

void
light_environment::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "pitch":
		angles[0] = stof(strKey);
		break;
	case "angle":
	case "sunangle":
		angles[1] = stof(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

/*! \brief Tool/Server-Entity: Light Emitting Materials */
/*!QUAKED light_surface (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Material property modifier related to lighting. Available in our vmap compiler.

# KEYS
- "targetname" : Name
- "surfacename" : Material to make a light emitting surface.
- "light" : Light intensity value.
- "color" : Normalized RGB color value. E.g. '1.0 1.0 1.0'
- "color255" : RGB255 color value. E.g. '255 255 255'
- "subdivisions" : Defines how many surfacelights are spawned for this surface.
- "bouncescale" : How strong photons will bounce for radiosity operations. Default is 1.0.
- "backsplash_fraction" : When > 0, creates a backsplash light that illuminates our material. Default is 5 (percent).
- "backsplash_distance" : How many units away from the surface the backsplash light will be placed. Default is 23 (units).
- "style" : What lightstyle group the emitted light will belong to.

# NOTES
Instead of having hundreds of off-shoot materials for your level, you can use
this to quickly make sure an existing material is adjusted for your level.

The backsplash_fraction key can be set to 100 (percent) to ensure it's mostly
illuminated, however since the lights are round you might have some slightly
darker parts in the corners of a perfectly square surface. Keep this in mind.

If you have round surfaces, especially patches, you should definitely adjust the
backsplash_distance key to make sure the light is spawning out far enough.
One giant, half circle patch surface might see issues otherwise. Not tested
though.

# TRIVIA
This entity was introduced in Nuclide (2021).
*/
class light_surface:light
{

};
