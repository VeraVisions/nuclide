/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* This is one of those leftovers from trying to get a game out in time */
class world_items:CBaseTrigger
{
	void() world_items;
};

void world_items::world_items(void)
{
	int nfields = tokenize(__fullspawndata);
	for (int i = 1; i < (nfields - 1); i += 2) {
		switch (argv(i)) {
		case "type":
			float type = stof(argv(i+1));
			switch (type) {
			case 44:
				spawnfunc_item_battery();
				break;
			case 45:
				spawnfunc_item_suit();
				break;
			default:
			}
		default:
			break;
		}
	}
}
