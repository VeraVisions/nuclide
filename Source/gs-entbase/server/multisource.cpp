/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class multisource : CBaseTrigger
{
	void() multisource;
	virtual int() GetValue;
	virtual void() Trigger;
};

int multisource :: GetValue ( void )
{
	int iWillTrigger = TRUE;
	
	for ( entity eTemp = world; ( eTemp = find( eTemp, CBaseTrigger::m_strTarget, m_strTargetName ) ); ) {
		CBaseTrigger tTemp = (CBaseTrigger) eTemp;
		if ( tTemp.GetValue() == FALSE ) {
			iWillTrigger = FALSE;
			break;
		}
	}
	
	return iWillTrigger;
}

void multisource :: Trigger ( void )
{
	if ( GetValue() == FALSE ) {
		return;
	}
	
	//dprint( sprintf( "multisource: Trigger of %s\n", m_strTarget ) );
	CBaseTrigger::UseTargets();
}

void multisource :: multisource ( void )
{
	CBaseTrigger::CBaseTrigger();
}
