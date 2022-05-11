/* Returns if the specified client is a NSClientSpectator, doesn't matter if real or fake */
float Client_IsSpectator(NSClient);

/* Returns if we're a permanent NSClientSpectator, USE THIS if you want to access NSClientSpectator class attributes */
float Client_IsRealSpectator(NSClient cl);

/* Returns if we're a fake NSClientSpectator, in case you need to be certain */
float Client_IsFakeSpectator(NSClient cl);

/* Return if the specified client is dead. If they're a NSClientSpectator they're always alive. */
float Client_IsDead(NSClient);

/* Returns if the specified client is a playable client class */
float Client_IsPlayer(NSClient cl);

/* Are we in an intermission? (Match ending screen) */
float Client_InIntermission(void);
