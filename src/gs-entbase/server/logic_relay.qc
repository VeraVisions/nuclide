/*
 * Copyright (c) 2023 Vera Visions LLC.
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

enumflags
{
	LOGICRELAY_ONCE,
	LOGICRELAY_FAST
};

/*! \brief Server-Entity: Relay Trigger */
/*!QUAKED logic_relay (1 0 0) (-8 -8 -8) (8 8 8) ONCE FAST
# OVERVIEW
Triggers outputs within an I/O system chain, which can be enabled/disabled at will.

# KEYS
- "targetname" : Name
- "StartDisabled" : Whether the entity starts disabled.

# INPUTS
- "Enable" : Enable the logic_relay. Allowing it to be triggered.
- "Disable" : Disable the logic_relay. Prevent it from being triggered.
- "Trigger" : Trigger the logic_relay. Will fire the OnTrigger output.
- "Toggle" : Toggle between Enabled/Disabled.
- "CancelPending" : Not yet implemented. Will cancel any outputs currently scheduled to trigger.
- "EnableRefire" : Not yet implemented. Will be called on itself automatically after all outputs finish their job.

# OUTPUTS
- "OnSpawn" : Triggered when the map is loaded for any reason.  
- "OnTrigger" : Triggered only when a new game starts on this level.  

# SPAWNFLAGS
- ONCE (1) : Remove itself from the level permanently when activated.
- FAST (2) : Allow retriggering even when not all outputs are done firing.

# NOTES
When a logic_relay is removed via spawnflag ONCE it won't survive match respawns.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
logic_relay:ncPointTrigger
{
public:
	void logic_relay(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
};

void
logic_relay::logic_relay(void)
{
}

void
logic_relay::Respawn(void)
{
	InitPointTrigger();
}

void
logic_relay::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_relay::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "Trigger":
		if (TriggerEnabled() == true) {
			/* if we don't allow fast retrigger... */
			if (HasSpawnFlags(LOGICRELAY_FAST) == false) {
				if (CheckOutput(m_outputOnTrigger) == false) {
					return;
				}
			}

			UseOutput(activatorEntity, m_outputOnTrigger);

			/* remove forever! */
			if (HasSpawnFlags(LOGICRELAY_ONCE)) {
				Destroy();
			}
		}
		break;
	/* TODO: complete this mess */
	case "CancelPending":
		break;
	case "EnableRefire":
		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}