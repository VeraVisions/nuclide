/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

float ConsoleCmd(string cmd)
{
#ifdef CSTRIKE
	return Cstrike_ConsoleCmd(cmd);
#else
	return Valve_ConsoleCmd(cmd);
#endif
}
