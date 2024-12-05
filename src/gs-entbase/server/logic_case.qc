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

/*! \brief Server-Entity: Comparison Trigger */
/*!QUAKED logic_case (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Compares an input value sent from another entity with one of the constant values defined within this entity. When it matches a given 'case', that same numbered output will get triggered. You can have 16 different cases to test against.

# KEYS
- "targetname" : Name
- "Case01" : Constant value 1.
- "Case02" : Constant value 2.
- "Case03" : Constant value 3.
- "Case04" : Constant value 4.
- "Case05" : Constant value 5.
- "Case06" : Constant value 6.
- "Case07" : Constant value 7.
- "Case08" : Constant value 8.
- "Case09" : Constant value 9.
- "Case10" : Constant value 10.
- "Case11" : Constant value 11.
- "Case12" : Constant value 12.
- "Case13" : Constant value 13.
- "Case14" : Constant value 14.
- "Case15" : Constant value 15.
- "Case16" : Constant value 16.

# INPUTS
- "InValue" : Compares the input in the data field with one of the constant values, then firing a matching output.
- "PickRandom" : Triggers a random, valid output.
- "PickRandomShuffle" : Triggers a random, valid output, but without repeats.

# OUTPUTS
- "OnCase01" - Triggered when Case01 matches the InValue input data.
- "OnCase02" - Triggered when Case02 matches the InValue input data.
- "OnCase03" - Triggered when Case03 matches the InValue input data.
- "OnCase04" - Triggered when Case04 matches the InValue input data.
- "OnCase05" - Triggered when Case05 matches the InValue input data.
- "OnCase06" - Triggered when Case06 matches the InValue input data.
- "OnCase07" - Triggered when Case07 matches the InValue input data.
- "OnCase08" - Triggered when Case08 matches the InValue input data.
- "OnCase09" - Triggered when Case09 matches the InValue input data.
- "OnCase10" - Triggered when Case10 matches the InValue input data.
- "OnCase11" - Triggered when Case11 matches the InValue input data.
- "OnCase12" - Triggered when Case12 matches the InValue input data.
- "OnCase13" - Triggered when Case13 matches the InValue input data.
- "OnCase14" - Triggered when Case14 matches the InValue input data.
- "OnCase15" - Triggered when Case15 matches the InValue input data.
- "OnCase16" - Triggered when Case16 matches the InValue input data.

# NOTES

Since we compare strings, case sensitivity and formatting needs to be identical between the InValue data and the entity defined constant values.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
logic_case:ncPointTrigger
{
public:
	void logic_case(void);

	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity, string, string);

	nonvirtual void CompareCase(entity, string);
	nonvirtual void PickRandom(entity);
	nonvirtual void PickRandomShuffle(entity);

private:

	string m_strCase01;
	string m_strCase02;
	string m_strCase03;
	string m_strCase04;
	string m_strCase05;
	string m_strCase06;
	string m_strCase07;
	string m_strCase08;
	string m_strCase09;
	string m_strCase10;
	string m_strCase11;
	string m_strCase12;
	string m_strCase13;
	string m_strCase14;
	string m_strCase15;
	string m_strCase16;

	string m_strOnCase01;
	string m_strOnCase02;
	string m_strOnCase03;
	string m_strOnCase04;
	string m_strOnCase05;
	string m_strOnCase06;
	string m_strOnCase07;
	string m_strOnCase08;
	string m_strOnCase09;
	string m_strOnCase10;
	string m_strOnCase11;
	string m_strOnCase12;
	string m_strOnCase13;
	string m_strOnCase14;
	string m_strOnCase15;
	string m_strOnCase16;

	string m_strOnDefault;
};

void
logic_case::logic_case(void)
{
	m_strCase01 = 
	m_strCase02 = 
	m_strCase03 = 
	m_strCase04 = 
	m_strCase05 = 
	m_strCase06 = 
	m_strCase07 = 
	m_strCase08 = 
	m_strCase09 = 
	m_strCase10 = 
	m_strCase11 = 
	m_strCase12 = 
	m_strCase13 = 
	m_strCase14 = 
	m_strCase15 = 
	m_strCase16 = __NULL__;

	m_strOnCase01 = 
	m_strOnCase02 = 
	m_strOnCase03 = 
	m_strOnCase04 = 
	m_strOnCase05 = 
	m_strOnCase06 = 
	m_strOnCase07 = 
	m_strOnCase08 = 
	m_strOnCase09 = 
	m_strOnCase10 = 
	m_strOnCase11 = 
	m_strOnCase12 = 
	m_strOnCase13 = 
	m_strOnCase14 = 
	m_strOnCase15 = 
	m_strOnCase16 = __NULL__;

	m_strOnDefault = __NULL__;
}

void
logic_case::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	/* gulp */
	case "Case01":
		m_strCase01 = ReadString(setValue);
		break;
	case "Case02":
		m_strCase02 = ReadString(setValue);
		break;
	case "Case03":
		m_strCase03 = ReadString(setValue);
		break;
	case "Case04":
		m_strCase04 = ReadString(setValue);
		break;
	case "Case05":
		m_strCase05 = ReadString(setValue);
		break;
	case "Case06":
		m_strCase06 = ReadString(setValue);
		break;
	case "Case07":
		m_strCase07 = ReadString(setValue);
		break;
	case "Case08":
		m_strCase08 = ReadString(setValue);
		break;
	case "Case09":
		m_strCase09 = ReadString(setValue);
		break;
	case "Case10":
		m_strCase10 = ReadString(setValue);
		break;
	case "Case11":
		m_strCase11 = ReadString(setValue);
		break;
	case "Case12":
		m_strCase12 = ReadString(setValue);
		break;
	case "Case13":
		m_strCase13 = ReadString(setValue);
		break;
	case "Case14":
		m_strCase14 = ReadString(setValue);
		break;
	case "Case15":
		m_strCase15 = ReadString(setValue);
		break;
	case "Case16":
		m_strCase16 = ReadString(setValue);
		break;

	case "OnCase01":
		m_strOnCase01 = PrepareOutput(m_strOnCase01, setValue);
		break;
	case "OnCase02":
		m_strOnCase02 = PrepareOutput(m_strOnCase02, setValue);
		break;
	case "OnCase03":
		m_strOnCase03 = PrepareOutput(m_strOnCase03, setValue);
		break;
	case "OnCase04":
		m_strOnCase04 = PrepareOutput(m_strOnCase04, setValue);
		break;
	case "OnCase05":
		m_strOnCase05 = PrepareOutput(m_strOnCase05, setValue);
		break;
	case "OnCase06":
		m_strOnCase06 = PrepareOutput(m_strOnCase06, setValue);
		break;
	case "OnCase07":
		m_strOnCase07 = PrepareOutput(m_strOnCase07, setValue);
		break;
	case "OnCase08":
		m_strOnCase08 = PrepareOutput(m_strOnCase08, setValue);
		break;
	case "OnCase09":
		m_strOnCase09 = PrepareOutput(m_strOnCase09, setValue);
		break;
	case "OnCase10":
		m_strOnCase10 = PrepareOutput(m_strOnCase10, setValue);
		break;
	case "OnCase11":
		m_strOnCase11 = PrepareOutput(m_strOnCase11, setValue);
		break;
	case "OnCase12":
		m_strOnCase12 = PrepareOutput(m_strOnCase12, setValue);
		break;
	case "OnCase13":
		m_strOnCase13 = PrepareOutput(m_strOnCase13, setValue);
		break;
	case "OnCase14":
		m_strOnCase14 = PrepareOutput(m_strOnCase14, setValue);
		break;
	case "OnCase15":
		m_strOnCase15 = PrepareOutput(m_strOnCase15, setValue);
		break;
	case "OnCase16":
		m_strOnCase16 = PrepareOutput(m_strOnCase16, setValue);
		break;
	case "OnDefault":
		m_strOnDefault = PrepareOutput(m_strOnDefault, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_case::Spawned(void)
{
	super::Spawned();

	if (m_strOnCase01)
		m_strOnCase01 = CreateOutput(m_strOnCase01);
	if (m_strOnCase02)
		m_strOnCase02 = CreateOutput(m_strOnCase02);
	if (m_strOnCase03)
		m_strOnCase03 = CreateOutput(m_strOnCase03);
	if (m_strOnCase04)
		m_strOnCase04 = CreateOutput(m_strOnCase04);
	if (m_strOnCase05)
		m_strOnCase05 = CreateOutput(m_strOnCase05);
	if (m_strOnCase06)
		m_strOnCase06 = CreateOutput(m_strOnCase06);
	if (m_strOnCase07)
		m_strOnCase07 = CreateOutput(m_strOnCase07);
	if (m_strOnCase08)
		m_strOnCase08 = CreateOutput(m_strOnCase08);
	if (m_strOnCase09)
		m_strOnCase09 = CreateOutput(m_strOnCase09);
	if (m_strOnCase10)
		m_strOnCase10 = CreateOutput(m_strOnCase10);
	if (m_strOnCase11)
		m_strOnCase11 = CreateOutput(m_strOnCase11);
	if (m_strOnCase12)
		m_strOnCase12 = CreateOutput(m_strOnCase12);
	if (m_strOnCase13)
		m_strOnCase13 = CreateOutput(m_strOnCase13);
	if (m_strOnCase14)
		m_strOnCase14 = CreateOutput(m_strOnCase14);
	if (m_strOnCase15)
		m_strOnCase15 = CreateOutput(m_strOnCase15);
	if (m_strOnCase16)
		m_strOnCase16 = CreateOutput(m_strOnCase16);
	if (m_strOnDefault)
		m_strOnDefault = CreateOutput(m_strOnDefault);
}

void
logic_case::Respawn(void)
{
	InitPointTrigger();
}

void
logic_case::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strCase01", m_strCase01);
	SaveString(handle, "m_strCase02", m_strCase02);
	SaveString(handle, "m_strCase03", m_strCase03);
	SaveString(handle, "m_strCase04", m_strCase04);
	SaveString(handle, "m_strCase05", m_strCase05);
	SaveString(handle, "m_strCase06", m_strCase06);
	SaveString(handle, "m_strCase07", m_strCase07);
	SaveString(handle, "m_strCase08", m_strCase08);
	SaveString(handle, "m_strCase09", m_strCase09);
	SaveString(handle, "m_strCase10", m_strCase10);
	SaveString(handle, "m_strCase11", m_strCase11);
	SaveString(handle, "m_strCase12", m_strCase12);
	SaveString(handle, "m_strCase13", m_strCase13);
	SaveString(handle, "m_strCase14", m_strCase14);
	SaveString(handle, "m_strCase15", m_strCase15);
	SaveString(handle, "m_strCase16", m_strCase16);

	SaveString(handle, "m_strOnCase01", m_strOnCase01);
	SaveString(handle, "m_strOnCase02", m_strOnCase02);
	SaveString(handle, "m_strOnCase03", m_strOnCase03);
	SaveString(handle, "m_strOnCase04", m_strOnCase04);
	SaveString(handle, "m_strOnCase05", m_strOnCase05);
	SaveString(handle, "m_strOnCase06", m_strOnCase06);
	SaveString(handle, "m_strOnCase07", m_strOnCase07);
	SaveString(handle, "m_strOnCase08", m_strOnCase08);
	SaveString(handle, "m_strOnCase09", m_strOnCase09);
	SaveString(handle, "m_strOnCase10", m_strOnCase10);
	SaveString(handle, "m_strOnCase11", m_strOnCase11);
	SaveString(handle, "m_strOnCase12", m_strOnCase12);
	SaveString(handle, "m_strOnCase13", m_strOnCase13);
	SaveString(handle, "m_strOnCase14", m_strOnCase14);
	SaveString(handle, "m_strOnCase15", m_strOnCase15);
	SaveString(handle, "m_strOnCase16", m_strOnCase16);
	SaveString(handle, "m_strOnDefault", m_strOnDefault);
}

void
logic_case::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_strCase01":
		m_strCase01 = ReadString(setValue);
		break;
	case "m_strCase02":
		m_strCase02 = ReadString(setValue);
		break;
	case "m_strCase03":
		m_strCase03 = ReadString(setValue);
		break;
	case "m_strCase04":
		m_strCase04 = ReadString(setValue);
		break;
	case "m_strCase05":
		m_strCase05 = ReadString(setValue);
		break;
	case "m_strCase06":
		m_strCase06 = ReadString(setValue);
		break;
	case "m_strCase07":
		m_strCase07 = ReadString(setValue);
		break;
	case "m_strCase08":
		m_strCase08 = ReadString(setValue);
		break;
	case "m_strCase09":
		m_strCase09 = ReadString(setValue);
		break;
	case "m_strCase10":
		m_strCase10 = ReadString(setValue);
		break;
	case "m_strCase11":
		m_strCase11 = ReadString(setValue);
		break;
	case "m_strCase12":
		m_strCase12 = ReadString(setValue);
		break;
	case "m_strCase13":
		m_strCase13 = ReadString(setValue);
		break;
	case "m_strCase14":
		m_strCase14 = ReadString(setValue);
		break;
	case "m_strCase15":
		m_strCase15 = ReadString(setValue);
		break;
	case "m_strCase16":
		m_strCase16 = ReadString(setValue);
		break;

	case "m_strOnCase01":
		m_strOnCase01 = ReadString(setValue);
		break;
	case "m_strOnCase02":
		m_strOnCase02 = ReadString(setValue);
		break;
	case "m_strOnCase03":
		m_strOnCase03 = ReadString(setValue);
		break;
	case "m_strOnCase04":
		m_strOnCase04 = ReadString(setValue);
		break;
	case "m_strOnCase05":
		m_strOnCase05 = ReadString(setValue);
		break;
	case "m_strOnCase06":
		m_strOnCase06 = ReadString(setValue);
		break;
	case "m_strOnCase07":
		m_strOnCase07 = ReadString(setValue);
		break;
	case "m_strOnCase08":
		m_strOnCase08 = ReadString(setValue);
		break;
	case "m_strOnCase09":
		m_strOnCase09 = ReadString(setValue);
		break;
	case "m_strOnCase10":
		m_strOnCase10 = ReadString(setValue);
		break;
	case "m_strOnCase11":
		m_strOnCase11 = ReadString(setValue);
		break;
	case "m_strOnCase12":
		m_strOnCase12 = ReadString(setValue);
		break;
	case "m_strOnCase13":
		m_strOnCase13 = ReadString(setValue);
		break;
	case "m_strOnCase14":
		m_strOnCase14 = ReadString(setValue);
		break;
	case "m_strOnCase15":
		m_strOnCase15 = ReadString(setValue);
		break;
	case "m_strOnCase16":
		m_strOnCase16 = ReadString(setValue);
		break;
	case "m_strOnDefault":
		m_strOnDefault = ReadString(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}

void
logic_case::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "InValue":
		CompareCase(activatorEntity, dataField);
		break;
	case "PickRandom":
		PickRandom(activatorEntity);
		break;
	case "PickRandomShuffle":
		PickRandomShuffle(activatorEntity);
		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}

void
logic_case::PickRandom(entity activatorEntity)
{
	EntWarning("Not implemented.");
}

void
logic_case::PickRandomShuffle(entity activatorEntity)
{
	EntWarning("Not implemented.");
}

void
logic_case::CompareCase(entity activatorEntity, string inputValue)
{
	switch (inputValue) {
	case m_strCase01:
		UseOutput(activatorEntity, m_strOnCase01);
		break;
	case m_strCase02:
		UseOutput(activatorEntity, m_strOnCase02);
		break;
	case m_strCase03:
		UseOutput(activatorEntity, m_strOnCase03);
		break;
	case m_strCase04:
		UseOutput(activatorEntity, m_strOnCase04);
		break;
	case m_strCase05:
		UseOutput(activatorEntity, m_strOnCase05);
		break;
	case m_strCase06:
		UseOutput(activatorEntity, m_strOnCase06);
		break;
	case m_strCase07:
		UseOutput(activatorEntity, m_strOnCase07);
		break;
	case m_strCase08:
		UseOutput(activatorEntity, m_strOnCase08);
		break;
	case m_strCase09:
		UseOutput(activatorEntity, m_strOnCase09);
		break;
	case m_strCase10:
		UseOutput(activatorEntity, m_strOnCase10);
		break;
	case m_strCase11:
		UseOutput(activatorEntity, m_strOnCase11);
		break;
	case m_strCase12:
		UseOutput(activatorEntity, m_strOnCase12);
		break;
	case m_strCase13:
		UseOutput(activatorEntity, m_strOnCase13);
		break;
	case m_strCase14:
		UseOutput(activatorEntity, m_strOnCase14);
		break;
	case m_strCase15:
		UseOutput(activatorEntity, m_strOnCase15);
		break;
	case m_strCase16:
		UseOutput(activatorEntity, m_strOnCase16);
		break;
	default:
		UseOutput(activatorEntity, m_strOnDefault);
	}
}