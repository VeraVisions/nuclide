/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class path_track:CBaseTrigger
{
	float m_flSpeed;
	float m_flWait;

	void() path_track;
};

void path_track::path_track(void)
{
	CBaseTrigger::CBaseTrigger();
	m_flSpeed = 100;
	m_flWait = 1.0f;
}
