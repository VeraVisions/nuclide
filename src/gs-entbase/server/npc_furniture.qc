/*! \brief Server-Entity: NPC: Furniture Item */
/*!QUAKED npc_furniture (0 .5 .8) (-16 -16 -16) (0 0 72)
# OVERVIEW
A piece of furniture or a prop to be included in scripted sequences.
Replacing monster_furniture.

# KEYS
- "targetname" :  Name
- "model" : Model to use in-game.

# INPUTS
- "DisablePlayerCollision" : Will disable collision with all players.
- "EnablePlayerCollision" : Will re-enable collision with all players.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
npc_furniture:ncActor
{
public:
	void npc_furniture(void);
};

void
npc_furniture::npc_furniture(void)
{

}
