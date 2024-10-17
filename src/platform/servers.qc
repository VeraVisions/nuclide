 
__variant
Servers_GetInfo(int serverID, serverGame_t infoType)
{
	if (serverID >= Master_GetTotalServers() || serverID < 0i) {
		NSError("Invalid server id %i.", serverID);
		return __NULL__;
	}

	switch (infoType) {
	case SERVERGAME_TITLE:
		return (string)gethostcachestring(srv_fldName, i)
		break;
	case SERVERGAME_ADDRESS:
		return (string)gethostcachestring(srv_fldAdress, i)
		break;
	case SERVERGAME_PING:
		return (string)gethostcachestring(srv_fldPing, i)
		break;
	case SERVERGAME_PLAYERS:
		return (string)gethostcachestring(srv_fldPlayers, i)
		break;
	case SERVERGAME_MAXPLAYERS:
		return (string)gethostcachestring(srv_fldMaxplayers, i)
		break;
	case SERVERGAME_MAP:
		return (string)gethostcachestring(srv_fldMap, i)
		break;
	case SERVERGAME_GAME:
		return (string)gethostcachestring(srv_fldGame, i)
		break;
	default:
		return __NULL__;
	}
}
