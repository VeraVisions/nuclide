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

	nonvirtual void TurnLightOn(void);
	nonvirtual void TurnLightOff(void);
	nonvirtual void ToggleLight(void);
	nonvirtual vector GetLightColor(void);

private:
	bool m_lightIsOn;
	bool m_lightStartsOn;
	float m_lightStyle;
	float m_lightStyleSwitch;
	string m_lightPattern;

	vector m_lightColor;
	vector m_lightStyleColor;
	bool m_lightLastState;
};

void
light::light(void)
{
	m_lightIsOn = true;
	m_lightStartsOn = true;
	m_lightPattern = "m";
	m_lightStyle = 0;
	m_lightStyleSwitch = 0;
	m_lightColor = [1,1,1];
	m_lightStyleColor = [1,1,1];
}

vector
light::GetLightColor(void)
{
	return (m_lightColor);
}

void
light::Save(float handle)
{
	super::Save(handle);
	SaveBool(handle, "m_lightIsOn", m_lightIsOn);
	SaveBool(handle, "m_lightStartsOn", m_lightStartsOn);
	SaveFloat(handle, "m_lightStyle", m_lightStyle);
	SaveFloat(handle, "m_lightStyleSwitch", m_lightStyleSwitch);
	SaveString(handle, "m_lightPattern", m_lightPattern);
}

void
light::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_lightIsOn":
		m_lightIsOn = ReadBool(setValue);
		break;
	case "m_lightStartsOn":
		m_lightStartsOn = ReadBool(setValue);
		break;
	case "m_lightStyle":
		m_lightStyle = ReadFloat(setValue);
		break;
	case "m_lightStyleSwitch":
		m_lightStyleSwitch = ReadFloat(setValue);
		break;
	case "m_lightPattern":
		m_lightPattern = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
light::RestoreComplete(void)
{
	if (m_lightLastState != m_lightIsOn) {
		m_lightLastState = m_lightIsOn;

		if (m_lightIsOn) {
			EntLog("Light now on.");
		} else {
			EntLog("Light now off.");
		}
	}

	/* not switchable */
	if (m_lightStyle < 12) {
		return;
	}

	if (m_lightIsOn == false) {
		lightstyle(m_lightStyle, "a", m_lightStyleColor);
	} else {
		lightstyle(m_lightStyle, m_lightPattern, m_lightStyleColor);
	}
}

void
light::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "pattern":
		m_lightPattern = ReadString(setValue);
		break;
	case "switch_style":
		m_lightStyleSwitch = ReadFloat(setValue);
		break;
	case "style":
		m_lightStyle = ReadFloat(setValue);
		style = __NULL__;
		break;
	case "start_active":
		m_lightStartsOn = ReadBool(setValue);
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
		m_lightColor = ReadVector(setValue);
		break;
	case "_light":
	case "color255":
		m_lightColor = ReadVector(setValue) / 255;
		break;
	default:
		super::SpawnKey(keyName, setValue);
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
	case "Color":
		m_lightStyleColor = ReadVector(dataString) / 255;
		EntLog("Changed lightStyle %d color to %s", m_lightStyle, dataString);
		RestoreComplete();
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
	if (m_lightStyleSwitch > 0 && m_lightStyleSwitch <= 11) {
		m_lightPattern = getlightstyle(m_lightStyleSwitch);
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
		if (HasSpawnFlags(1) && HasTargetname()) {
			m_lightIsOn = false;
		} else {
			m_lightIsOn = true;
		}
		break;
	case BSPVER_Q3:
	case BSPVER_RTCW:
	case BSPVER_RBSP:
		if (!m_lightStartsOn && HasTargetname()) {
			m_lightIsOn = false;
		} else {
			m_lightIsOn = true;
		}
		break;
	default:
		m_lightIsOn = true;
	}

	m_lightLastState = !m_lightIsOn;
	RestoreComplete();
}

void
light::TurnLightOn(void)
{
	m_lightIsOn = true;
	RestoreComplete();
}

void
light::TurnLightOff(void)
{
	m_lightIsOn = false;
	RestoreComplete();
}

void
light::ToggleLight(void)
{
	m_lightIsOn = true - m_lightIsOn;
	RestoreComplete();
}

void
light::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		TurnLightOff();
		break;
	case TRIG_ON:
		TurnLightOn();
		break;
	default:
		ToggleLight();
	}
}

void
light::DebugDraw(void)
{
#ifdef SERVER
	string debugIcon;

	if (m_lightIsOn) {
		debugIcon = "gfx/icon16/lightbulb";
	} else {
		debugIcon = "gfx/icon16/lightbulb_off";
	}

	R_BeginPolygon(debugIcon, 0, 0);
		R_PolygonVertex(GetOrigin() + v_right * 8 - v_up * 8, [1,1], m_lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 8 - v_up * 8, [0,1], m_lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() - v_right * 8 + v_up * 8, [0,0], m_lightColor, 1.0f);
		R_PolygonVertex(GetOrigin() + v_right * 8 + v_up * 8, [1,0], m_lightColor, 1.0f);
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
	//sunLight.m_vecLightColor = m_lightColor;
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
