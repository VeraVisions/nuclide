class
TestWeapon:NSWeapon
{
public:
	void TestWeapon(void);

	virtual string GetWorldModel(void);
};

void
TestWeapon::TestWeapon(void)
{

}

string
TestWeapon::GetWorldModel(void)
{
	return "models/error.vvm";
}