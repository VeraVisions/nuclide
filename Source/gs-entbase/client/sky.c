/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var string g_skyname = "desert";

void Sky_Update(void)
{
	localcmd(sprintf("sky %s\n", g_skyname));
}

void Sky_Set(string name)
{
	g_skyname = name;
	print(sprintf("[SKY] Set to %s", g_skyname));
	Sky_Update();
}
