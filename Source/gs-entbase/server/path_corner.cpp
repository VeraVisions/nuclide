/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class path_corner:CBaseTrigger
{
	float m_flSpeed;
	float m_flWait;

	void() path_corner;
};

void path_corner::path_corner(void)
{
	CBaseTrigger::CBaseTrigger();
	m_flSpeed = 100;
	m_flWait = 1.0f;
}
