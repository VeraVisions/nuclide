/* Returns if the specified client is a spectator, doesn't matter if real or fake */
float Client_IsSpectator(base_client);

/* Returns if we're a permanent spectator, USE THIS if you want to access spectator class attributes */
float Client_IsRealSpectator(base_client cl);

/* Returns if we're a fake spectator, in case you need to be certain */
float Client_IsFakeSpectator(base_client cl);

/* Return if the specified client is dead. If they're a spectator they're always alive. */
float Client_IsDead(base_client);

/* Returns if the specified client is a playable client class */
float Client_IsPlayer(base_client cl);

/* Are we in an intermission? (Match ending screen) */
float Client_InIntermission(void);
