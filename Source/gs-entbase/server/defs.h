/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define GS_DEVELOPER

.float gflags;

enumflags
{
	GF_CANRESPAWN,
	GF_USE_RELEASED,
	GF_IN_VEHICLE,
	GF_FROZEN,
	GF_SEMI_TOGGLED
};

void Effect_CreateSpark(vector pos, vector ang);
void Effect_BreakModel(vector mins, vector maxs,vector vel, float mat);

string Util_FixModel(string mdl)
{
	int c = tokenizebyseparator(mdl, "/", "\\ ");
	string newpath = "";

	for (int i = 0; i < c; i++) {
		newpath = sprintf("%s/%s", newpath, argv(i));
	}

	// Kill the first /
	newpath = substring(newpath, 1, strlen(newpath)-1);
#if 1
	return newpath;
#else
	return mdl;
#endif
}
