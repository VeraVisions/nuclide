/** We basically follow what GMod does. https://wiki.facepunch.com/gmod/Enums/TEAM */
enum
{
	TEAM_CONNECTING = 0,/**< Set upon ClientConnect. Player is not done joining. */
	/* this is where games can set up whatever they want */
	TEAM_UNASSIGNED = 1001,	/**< set on PutClientInServer (first time only) */
	TEAM_SPECTATOR = 1002, /**< spectator. can be real (never playable) or fake (see CS, inbetween rounds) */
};
