/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class light:CBaseTrigger
{
	int m_iEnabled;
	float m_flStyle;
	string m_strPattern;

	void() light;
	virtual void() Trigger;
	virtual void() Respawn;
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

	light::Respawn();
}

CLASSEXPORT(light_spot, light)
CLASSEXPORT(light_environment, light)

