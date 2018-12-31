/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

#define GLOBAL_SETSPAWN 1

enum
{
	GLOBAL_OFF,
	GLOBAL_ON,
	GLOBAL_DEAD
};

const string CENVGLOBAL_CVAR = "env_global_data";

class CEnvGlobal : CBaseTrigger
{
	string m_strGlobalState;
	int m_iTriggerMode;
	int m_iInitialState;
	
	void() CEnvGlobal;
	virtual void() Trigger;
	
	virtual int( string ) GlobalPresent;
	virtual void( string, int ) AddNewGlobal;
	virtual void( string, int ) SetGlobal;
	virtual int( string ) GetGlobal;
};

void CEnvGlobal :: Trigger ( void ) {
	int iOldValue = GetGlobal( m_strGlobalState );
	int iNewValue = 0;
	
	switch( m_iTriggerMode ) {
	case 0:
		iNewValue = GLOBAL_OFF;
		break;
	case 1:
		iNewValue = GLOBAL_ON;
		break;
	case 2:
		iNewValue = GLOBAL_DEAD;
		break;
	default:
		if ( iOldValue == GLOBAL_ON ) {
			iNewValue = GLOBAL_OFF;
		} else if ( iOldValue == GLOBAL_OFF ) {
			iNewValue = GLOBAL_ON;
		} else {
			iNewValue = iOldValue;
		}
	}

	if ( GlobalPresent( m_strGlobalState ) ) {
		SetGlobal( m_strGlobalState, iNewValue );
	} else {
		AddNewGlobal( m_strGlobalState, iNewValue );
	}
}

int CEnvGlobal :: GlobalPresent ( string strName ) {
	for ( int i = 1; i < ( tokenize( cvar_string( CENVGLOBAL_CVAR ) ) - 1 ); i += 2 ) {
		if ( argv( i ) == strName ) {
			return 1;
		}
	}
	return 0;
}

void CEnvGlobal :: AddNewGlobal ( string strName, int iValue ) {
	cvar_set( CENVGLOBAL_CVAR, sprintf( "%s %s %i", cvar_string( CENVGLOBAL_CVAR ), strName, iValue ) );
}

void CEnvGlobal :: SetGlobal ( string strName, int iValue ) {
	string strNewData = "";
	for ( int i = 1; i < ( tokenize( cvar_string( CENVGLOBAL_CVAR ) ) - 1 ); i += 2 ) {
		if ( argv( i ) != strName ) {
			strNewData = sprintf( "%s %s %s", strNewData, argv( i ), argv( i + 1 ) );
		}
	}
	cvar_set( CENVGLOBAL_CVAR, sprintf( "%s %s %i", strNewData, strName, iValue ) );
}

int CEnvGlobal :: GetGlobal ( string strName ) {
	for ( int i = 1; i < ( tokenize( cvar_string( CENVGLOBAL_CVAR ) ) - 1 ); i += 2 ) {
		if ( argv( i ) == strName ) {
			return stoi( argv( i + 1 ) );
		}
	}
	return 0;
}

void CEnvGlobal :: CEnvGlobal ( void )
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "globalstate":
			m_strGlobalState = argv( i + 1 );
			break;
		case "triggermode":
			m_iTriggerMode = stoi( argv( i + 1 ) );
			break;
		case "initialstate":
			m_iInitialState = stoi( argv( i + 1 ) );
			break;
		default:
			break;
		}
	}
	
	if ( !m_strGlobalState ) {
		objerror( "CEnvGlobal: No globalstate name given! Aborting\n" );
	}
	
	if ( spawnflags & GLOBAL_SETSPAWN ) {
		if ( !GlobalPresent( m_strGlobalState ) ) {
			AddNewGlobal( m_strGlobalState, m_iInitialState );
		}
	}
}

CLASSEXPORT( env_global, CEnvGlobal )
