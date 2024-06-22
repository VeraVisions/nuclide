/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

#define COST_INFINITE 99999

/** @ingroup bot

   @{
*/

/** The desired target destination has been reached. */
#define BOTROUTE_DESTINATION	-1
/** Unloading of the route in progress. */
#define BOTROUTE_END			-2

/** Bot Personality */
typedef enum
{
	BOT_PERSONALITY_NORMAL,		/**< this bot will be dynamic */
	BOT_PERSONALITY_AGRESSIVE,	/**< this bot will always prefer to be attacking */
	BOT_PERSONALITY_DEFENSIVE	/**< this bot will always prefer to stay behind */
} botpersonality_t;

/** Bot State */
typedef enum
{
	BOT_STATE_IDLE,			/**< this should rarely happen */
	BOT_STATE_PATROLLING,	/**< this is basically most deathmatch cases */
	BOT_STATE_DEFENDING,	/**< this is for when bots stay put and stay around spawn, or their teams goalitem */
	BOT_STATE_ATTACKING,	/**< this is for when bots go to the enemy spawn, or to the enemy team's goalitem */
	BOT_STATE_FLEEING		/**< this is for when the AI should just get as far away as possible */
} botstate_t;

/** A virtual multiplayer opponent. Base class for all bots.

@ingroup bot
@ingroup baseclass
*/
class NSBot:NSNavAI
{
public:

	void NSBot(void);

#ifdef SERVER
	virtual void SetState(botstate_t);
	virtual botstate_t GetState(void);
	virtual botpersonality_t GetPersonality(void);

	virtual float GetForwardSpeed(void);
	virtual float GetSideSpeed(void);
	virtual float GetBackSpeed(void);

	virtual void ChatSay(string);
	virtual void ChatSayTeam(string);
	virtual void Pain(entity, entity, int, vector, int);
	virtual void RouteClear(void);
	virtual void WeaponThink(void);
	virtual void WeaponAttack(void);
	virtual void SeeThink(void);
	virtual void BrainThink(int, int);
	virtual void RunAI(void);
	virtual void CreateObjective(void);
	virtual void CheckRoute(void);
	virtual void PreFrame(void);
	virtual void PostFrame(void);
	virtual void UseButton(void);
	virtual void SetEnemy(entity);
	virtual float GetRunSpeed(void);
	virtual float GetWalkSpeed(void);
	nonvirtual void ForceWeaponAttack(vector, float);

	virtual void SetName(string);


	/** Server: Set the value of an InfoKey. */
	nonvirtual void SetInfoKey(string, string);

	/** Server: Floating point based version of SetInfoKey(). */
	nonvirtual void SetInfoKeyFloat(string, float);
#endif

	/** Get the string value of an InfoKey. */
	nonvirtual string GetInfoKey(string);
	/** Floating point based version of GetInfoKey(). */
	nonvirtual float GetInfoKeyFloat(string);

#ifdef SERVER
private:
	/* routing */
	float m_flLastDist;

	float m_flNodeGiveup;
	entity m_eDestination;

	/* combat */
	entity m_eTarget;
	int m_iAttackMode;
	float m_flAttackTime;

	/* items */
	int m_iOldItems;

	/* visual */
	float m_flSeeTime;

	/* personality and state */
	botstate_t m_bsState;
	botpersonality_t m_bpPersonality;

	/* cache, these are just here so we won't have to calc them often */
	float m_flEnemyDist;
	weapontype_t m_wtWeaponType;
	vector m_vecLastPOI;
	float m_flForceWeaponAttack;
	vector m_vecForceWeaponAttackPos;
#endif
};

#ifdef SERVER
/** Adds a bot to the game with some basic info. Returns the resulting entity. __NULL__ if unavailable. */
entity Bot_AddQuick(void);
void BotLib_Init(void);

/** Applies random custom colors to the given bot entity. */
void
Bot_RandomColormap(NSBot target)
{
	vector x = hsvToRGB(random() * 360, 100, 100);
	float top = x[2] + (x[1] << 8) + (x[0] << 16);
	x = hsvToRGB(random() * 360, 100, 100);
	float bottom = x[2] + (x[1] << 8) + (x[0] << 16);
	forceinfokey(target, "topcolor", sprintf("0x%x", top));
	forceinfokey(target, "bottomcolor", sprintf("0x%x", bottom));
}
#endif

/** @} */ // end of bot
