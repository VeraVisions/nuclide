/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CMultiSource : CBaseTrigger
{
	void() CMultiSource;
	virtual int() GetValue;
	virtual void() Trigger;
};

int CMultiSource :: GetValue ( void )
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

void CMultiSource :: Trigger ( void )
{
	if ( GetValue() == FALSE ) {
		return;
	}
	
	//dprint( sprintf( "CMultiSource: Trigger of %s\n", m_strTarget ) );
	CBaseTrigger::UseTargets();
}

void CMultiSource :: CMultiSource ( void )
{
	CBaseTrigger::CBaseTrigger();
}

CLASSEXPORT( multisource, CMultiSource )
