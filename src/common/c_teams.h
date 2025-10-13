/** We basically follow what GMod does. https://wiki.facepunch.com/gmod/Enums/TEAM */
typedef enum
{
	TEAM_CONNECTING = 0,/**< Set upon ClientConnect. Player is not done joining. */
	/* this is where games can set up whatever they want */
	TEAM_UNASSIGNED = 1001,	/**< set on PutClientInServer (first time only) */
	TEAM_SPECTATOR = 1002, /**< spectator. can be real (never playable) or fake (see CS, inbetween rounds) */
} team_t;

#define TEAM_ANY 0 /* not used for clients. */

/** Defines available modes when spectating a game. */
typedef enum
{
	SPECMODE_DEATHCAM,		/**< We're dying, game specific camera movements */
	SPECMODE_LOCKEDCHASE,	/**< Fixed angle chase camera */
	SPECMODE_THIRDPERSON,	/**< Free angle chase camera */
	SPECMODE_FREE,			/**< Free noclipped movement camera */
	SPECMODE_FIRSTPERSON,	/**< First-person camera of another player */
	SPECMODE_FREEOVERVIEW,	/**< Free map overview */
	SPECMODE_CHASEOVERVIEW	/**< Map overview chasing another player */
} ncSpectatorMode_t;
