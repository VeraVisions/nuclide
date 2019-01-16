/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class trigger_endsection : CBaseTrigger
{
	virtual void() Trigger;
}

void trigger_endsection :: Trigger ( void )
{
	localcmd( "disconnect\n" );
}
