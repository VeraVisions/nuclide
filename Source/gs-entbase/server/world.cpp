/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CWorld
{
	 void() CWorld;
	 virtual void() Precaches;
	 virtual void() SetupLight;
};
 
void CWorld :: Precaches ( void )
{
	Material_Init();
	Weapon_Init();
}
 
void CWorld :: SetupLight ( void )
{
	// Valve BSP only
	if ( serverkeyfloat( "*bspversion" ) == 30 ) {
		lightstyle( 0, "m" );
		lightstyle( 1, "mmnmmommommnonmmonqnmmo" );
		lightstyle( 2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba" );
		lightstyle( 3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg" );
		lightstyle( 4, "mamamamamama" );
		lightstyle( 5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj" );
		lightstyle( 6, "nmonqnmomnmomomno" );
		lightstyle( 7, "mmmaaaabcdefgmmmmaaaammmaamm" );
		lightstyle( 8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa" );
		lightstyle( 9, "aaaaaaaazzzzzzzz" );
		lightstyle( 10, "mmamammmmammamamaaamammma" );
		lightstyle( 11, "abcdefghijklmnopqrrqponmlkjihgfedcba" );
	}

	clientstat( 16, EV_FLOAT, ::view_ofs[2] );
}
 
void CWorld :: CWorld ( void )
{
	CWorld::Precaches();
	CWorld::SetupLight();
}

//CLASSEXPORT( worldspawn, CWorld )
