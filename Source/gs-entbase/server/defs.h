/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

//#define GS_DEVELOPER

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
void Effect_BreakModel(int count, vector mins, vector maxs,vector vel, float mat);

/* This is required because people who use Hammer do awful things
   to get their models to update. We get a multitude of juicy
   hacks and symbols that Half-Life's engine strips and now we have to
   replicate this behaviour. Be thankful this is not done in-engine for
   every game/mod ever.
*/
string Util_FixModel(string mdl)
{	
	if (!mdl) {
		return "";
	}

	int c = tokenizebyseparator(mdl, "/", "\\ ", "!");
	string newpath = "";

	for (int i = 0; i < c; i++) {
		newpath = sprintf("%s/%s", newpath, argv(i));
	}

	// Kill the first /
	newpath = substring(newpath, 1, strlen(newpath)-1);

	/* Now we need to fix \/ because I hate people */
	c = tokenizebyseparator(newpath, "\\/");
	mdl = "";
	for (int i = 0; i < c; i++) {
		mdl = sprintf("%s/%s", mdl, argv(i));
	}
	// Kill the first / again
	mdl = substring(mdl, 1, strlen(mdl)-1);

	return mdl;
}
