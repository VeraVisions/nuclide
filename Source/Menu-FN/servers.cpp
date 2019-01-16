/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

int Server_IsLan(string address)
{
#if 0
	return FALSE;
#endif
	tokenizebyseparator(address, ".");
	
	if (argv(0) == "192" && argv(1) == "168") {
		return TRUE;
	} else {
		return FALSE;
	}
}
