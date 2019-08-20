/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef VALVE
void() w_snark_deploy;
#endif

class monstermaker : CBaseTrigger
{
	void() monstermaker;
	virtual void() Trigger;
};

void monstermaker :: Trigger ( void )
{
#ifdef VALVE
	w_snark_deploy();
#endif
}

void monstermaker :: monstermaker ( void )
{
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < (  tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		default:
			break;
		}
	}
}
