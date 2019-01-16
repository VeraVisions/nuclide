/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class info_map_parameters
{
	void() info_map_parameters;
};

void info_map_parameters::info_map_parameters(void)
{
	for (int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2) {
		switch ( argv( i ) ) {
		case "bombradius":
			iBombRadius = stoi(argv(i + 1));
#ifdef GS_DEVELOPER
			print(sprintf("info_map_parameters: Set C4 radius to %i\n", iBombRadius));
#endif
			break;
		case "buying":
			iBuyRestriction = stoi(argv(i + 1));
#ifdef GS_DEVELOPER
			print(sprintf("info_map_parameters: Set buy restriction to %i\n", iBuyRestriction));
#endif
			break;
		default:
			break;
		}
	}

#ifndef GS_DEVELOPER
	remove(this);
#endif
}
