/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CTriggerEnd : CBaseTrigger
{
	virtual void() Trigger;
}

void CTriggerEnd :: Trigger ( void )
{
	localcmd( "disconnect\n" );
}

CLASSEXPORT( trigger_endsection, CTriggerEnd )
