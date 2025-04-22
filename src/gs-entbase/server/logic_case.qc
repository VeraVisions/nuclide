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

	string m_outputOnCase01;
	string m_outputOnCase02;
	string m_outputOnCase03;
	string m_outputOnCase04;
	string m_outputOnCase05;
	string m_outputOnCase06;
	string m_outputOnCase07;
	string m_outputOnCase08;
	string m_outputOnCase09;
	string m_outputOnCase10;
	string m_outputOnCase11;
	string m_outputOnCase12;
	string m_outputOnCase13;
	string m_outputOnCase14;
	string m_outputOnCase15;
	string m_outputOnCase16;

	string m_outputOnDefault;
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

	m_outputOnCase01 = 
	m_outputOnCase02 = 
	m_outputOnCase03 = 
	m_outputOnCase04 = 
	m_outputOnCase05 = 
	m_outputOnCase06 = 
	m_outputOnCase07 = 
	m_outputOnCase08 = 
	m_outputOnCase09 = 
	m_outputOnCase10 = 
	m_outputOnCase11 = 
	m_outputOnCase12 = 
	m_outputOnCase13 = 
	m_outputOnCase14 = 
	m_outputOnCase15 = 
	m_outputOnCase16 = __NULL__;

	m_outputOnDefault = __NULL__;
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
		m_outputOnCase01 = PrepareOutput(m_outputOnCase01, setValue);
		break;
	case "OnCase02":
		m_outputOnCase02 = PrepareOutput(m_outputOnCase02, setValue);
		break;
	case "OnCase03":
		m_outputOnCase03 = PrepareOutput(m_outputOnCase03, setValue);
		break;
	case "OnCase04":
		m_outputOnCase04 = PrepareOutput(m_outputOnCase04, setValue);
		break;
	case "OnCase05":
		m_outputOnCase05 = PrepareOutput(m_outputOnCase05, setValue);
		break;
	case "OnCase06":
		m_outputOnCase06 = PrepareOutput(m_outputOnCase06, setValue);
		break;
	case "OnCase07":
		m_outputOnCase07 = PrepareOutput(m_outputOnCase07, setValue);
		break;
	case "OnCase08":
		m_outputOnCase08 = PrepareOutput(m_outputOnCase08, setValue);
		break;
	case "OnCase09":
		m_outputOnCase09 = PrepareOutput(m_outputOnCase09, setValue);
		break;
	case "OnCase10":
		m_outputOnCase10 = PrepareOutput(m_outputOnCase10, setValue);
		break;
	case "OnCase11":
		m_outputOnCase11 = PrepareOutput(m_outputOnCase11, setValue);
		break;
	case "OnCase12":
		m_outputOnCase12 = PrepareOutput(m_outputOnCase12, setValue);
		break;
	case "OnCase13":
		m_outputOnCase13 = PrepareOutput(m_outputOnCase13, setValue);
		break;
	case "OnCase14":
		m_outputOnCase14 = PrepareOutput(m_outputOnCase14, setValue);
		break;
	case "OnCase15":
		m_outputOnCase15 = PrepareOutput(m_outputOnCase15, setValue);
		break;
	case "OnCase16":
		m_outputOnCase16 = PrepareOutput(m_outputOnCase16, setValue);
		break;
	case "OnDefault":
		m_outputOnDefault = PrepareOutput(m_outputOnDefault, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_case::Spawned(void)
{
	super::Spawned();

	if (m_outputOnCase01)
		m_outputOnCase01 = CreateOutput(m_outputOnCase01);
	if (m_outputOnCase02)
		m_outputOnCase02 = CreateOutput(m_outputOnCase02);
	if (m_outputOnCase03)
		m_outputOnCase03 = CreateOutput(m_outputOnCase03);
	if (m_outputOnCase04)
		m_outputOnCase04 = CreateOutput(m_outputOnCase04);
	if (m_outputOnCase05)
		m_outputOnCase05 = CreateOutput(m_outputOnCase05);
	if (m_outputOnCase06)
		m_outputOnCase06 = CreateOutput(m_outputOnCase06);
	if (m_outputOnCase07)
		m_outputOnCase07 = CreateOutput(m_outputOnCase07);
	if (m_outputOnCase08)
		m_outputOnCase08 = CreateOutput(m_outputOnCase08);
	if (m_outputOnCase09)
		m_outputOnCase09 = CreateOutput(m_outputOnCase09);
	if (m_outputOnCase10)
		m_outputOnCase10 = CreateOutput(m_outputOnCase10);
	if (m_outputOnCase11)
		m_outputOnCase11 = CreateOutput(m_outputOnCase11);
	if (m_outputOnCase12)
		m_outputOnCase12 = CreateOutput(m_outputOnCase12);
	if (m_outputOnCase13)
		m_outputOnCase13 = CreateOutput(m_outputOnCase13);
	if (m_outputOnCase14)
		m_outputOnCase14 = CreateOutput(m_outputOnCase14);
	if (m_outputOnCase15)
		m_outputOnCase15 = CreateOutput(m_outputOnCase15);
	if (m_outputOnCase16)
		m_outputOnCase16 = CreateOutput(m_outputOnCase16);
	if (m_outputOnDefault)
		m_outputOnDefault = CreateOutput(m_outputOnDefault);
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

	SaveString(handle, "m_outputOnCase01", m_outputOnCase01);
	SaveString(handle, "m_outputOnCase02", m_outputOnCase02);
	SaveString(handle, "m_outputOnCase03", m_outputOnCase03);
	SaveString(handle, "m_outputOnCase04", m_outputOnCase04);
	SaveString(handle, "m_outputOnCase05", m_outputOnCase05);
	SaveString(handle, "m_outputOnCase06", m_outputOnCase06);
	SaveString(handle, "m_outputOnCase07", m_outputOnCase07);
	SaveString(handle, "m_outputOnCase08", m_outputOnCase08);
	SaveString(handle, "m_outputOnCase09", m_outputOnCase09);
	SaveString(handle, "m_outputOnCase10", m_outputOnCase10);
	SaveString(handle, "m_outputOnCase11", m_outputOnCase11);
	SaveString(handle, "m_outputOnCase12", m_outputOnCase12);
	SaveString(handle, "m_outputOnCase13", m_outputOnCase13);
	SaveString(handle, "m_outputOnCase14", m_outputOnCase14);
	SaveString(handle, "m_outputOnCase15", m_outputOnCase15);
	SaveString(handle, "m_outputOnCase16", m_outputOnCase16);
	SaveString(handle, "m_outputOnDefault", m_outputOnDefault);
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

	case "m_outputOnCase01":
		m_outputOnCase01 = ReadString(setValue);
		break;
	case "m_outputOnCase02":
		m_outputOnCase02 = ReadString(setValue);
		break;
	case "m_outputOnCase03":
		m_outputOnCase03 = ReadString(setValue);
		break;
	case "m_outputOnCase04":
		m_outputOnCase04 = ReadString(setValue);
		break;
	case "m_outputOnCase05":
		m_outputOnCase05 = ReadString(setValue);
		break;
	case "m_outputOnCase06":
		m_outputOnCase06 = ReadString(setValue);
		break;
	case "m_outputOnCase07":
		m_outputOnCase07 = ReadString(setValue);
		break;
	case "m_outputOnCase08":
		m_outputOnCase08 = ReadString(setValue);
		break;
	case "m_outputOnCase09":
		m_outputOnCase09 = ReadString(setValue);
		break;
	case "m_outputOnCase10":
		m_outputOnCase10 = ReadString(setValue);
		break;
	case "m_outputOnCase11":
		m_outputOnCase11 = ReadString(setValue);
		break;
	case "m_outputOnCase12":
		m_outputOnCase12 = ReadString(setValue);
		break;
	case "m_outputOnCase13":
		m_outputOnCase13 = ReadString(setValue);
		break;
	case "m_outputOnCase14":
		m_outputOnCase14 = ReadString(setValue);
		break;
	case "m_outputOnCase15":
		m_outputOnCase15 = ReadString(setValue);
		break;
	case "m_outputOnCase16":
		m_outputOnCase16 = ReadString(setValue);
		break;
	case "m_outputOnDefault":
		m_outputOnDefault = ReadString(setValue);
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
		UseOutput(activatorEntity, m_outputOnCase01);
		break;
	case m_strCase02:
		UseOutput(activatorEntity, m_outputOnCase02);
		break;
	case m_strCase03:
		UseOutput(activatorEntity, m_outputOnCase03);
		break;
	case m_strCase04:
		UseOutput(activatorEntity, m_outputOnCase04);
		break;
	case m_strCase05:
		UseOutput(activatorEntity, m_outputOnCase05);
		break;
	case m_strCase06:
		UseOutput(activatorEntity, m_outputOnCase06);
		break;
	case m_strCase07:
		UseOutput(activatorEntity, m_outputOnCase07);
		break;
	case m_strCase08:
		UseOutput(activatorEntity, m_outputOnCase08);
		break;
	case m_strCase09:
		UseOutput(activatorEntity, m_outputOnCase09);
		break;
	case m_strCase10:
		UseOutput(activatorEntity, m_outputOnCase10);
		break;
	case m_strCase11:
		UseOutput(activatorEntity, m_outputOnCase11);
		break;
	case m_strCase12:
		UseOutput(activatorEntity, m_outputOnCase12);
		break;
	case m_strCase13:
		UseOutput(activatorEntity, m_outputOnCase13);
		break;
	case m_strCase14:
		UseOutput(activatorEntity, m_outputOnCase14);
		break;
	case m_strCase15:
		UseOutput(activatorEntity, m_outputOnCase15);
		break;
	case m_strCase16:
		UseOutput(activatorEntity, m_outputOnCase16);
		break;
	default:
		UseOutput(activatorEntity, m_outputOnDefault);
	}
}