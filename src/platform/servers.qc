 
__variant
Servers_GetInfo(int serverID, serverGame_t infoType)
{
	if (serverID >= Master_GetTotalServers() || serverID < 0i) {
		NSError("Invalid server id %i.", serverID);
		return __NULL__;
	}

	switch (infoType) {
	case SERVERGAME_TITLE:
		return (string)gethostcachestring(srv_fldName, serverID);
		break;
	case SERVERGAME_ADDRESS:
		return (string)gethostcachestring(srv_fldAdress, serverID);
		break;
	case SERVERGAME_PING:
		return (int)gethostcachenumber(srv_fldPing, serverID);
		break;
	case SERVERGAME_PLAYERS:
		return (int)gethostcachenumber(srv_fldPlayers, serverID);
		break;
	case SERVERGAME_MAXPLAYERS:
		return (int)gethostcachenumber(srv_fldMaxplayers, serverID);
		break;
	case SERVERGAME_MAP:
		return (string)gethostcachestring(srv_fldMap, serverID);
		break;
	case SERVERGAME_GAME:
		return (string)gethostcachestring(srv_fldGame, serverID);
		break;
	default:
		return __NULL__;
	}
}
