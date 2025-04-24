/** Item Capture Manager.

While not an item itself, it cares about managing
goal/capture items within a game.

An instance of ncCaptureItem will give an item, receive items (capturing)
and assign score points.

It can be configured to look like a flag, will give a (separate) inventory item
that is unique to the map and can be captured at other ncCapturePoint instances or ncCaptureItem instances.
*/
class ncCaptureItem:ncRenderableEntity
{
public:
	void ncCaptureItem(void);

	virtual void Precache(void);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void SpawnKey(string, string);
	nonvirtual void Captured(float teamNumber);
	nonvirtual void WatchPlayer(void);

private:
	string m_desiredItem;
	string m_goalItem;
	string m_requiresItem;
	int m_playerScore;
	int m_teamScore;
	float m_goalNo;
	ncPlayer m_watchPlayer;
	string m_outputOnCapture;
	string m_outputOnTake;
};
