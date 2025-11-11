class
ncServerGame
{
	nonvirtual void Init(void);
	nonvirtual void InitEnts(void);
	nonvirtual void InitPostEnts(void);
	nonvirtual void Shutdown(void);
	
	nonvirtual void StartFrame(void);
	nonvirtual void ClientConnect(ncClient connectingClient);
	nonvirtual void ClientDisconnect(ncClient disconnectingClient);
	nonvirtual void ClientKill(ncClient targetClient);
	nonvirtual void SpectatorConnect(ncSpectator thinkingSpectator);
	nonvirtual void SpectatorDisconnect(ncSpectator thinkingSpectator);
	nonvirtual void SpectatorThink(ncSpectator thinkingSpectator);

	nonvirtual void PutClientInServer(ncPlayer joiningPlayer);
	nonvirtual void PlayerPreThink(ncPlayer thinkingPlayer);
	nonvirtual void PlayerPostThink(ncPlayer thinkingPlayer);
};
