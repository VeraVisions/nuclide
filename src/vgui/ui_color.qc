
/** Container class that'll deal with handling colors via a variety of different means. */


/** VGUI Widget: Color Container

@ingroup vgui
*/
class vguiColor
{
public:
	void vguiColor(void);

	nonvirtual void SetColor(vector);
	nonvirtual void SetColorWithAlpha(vector, float);
	nonvirtual vector GetColor(void);
	nonvirtual float GetAlpha(void);

private:
	vector m_colorValue;
	float m_alphaValue;
};

void
vguiColor::vguiColor(void)
{
	m_colorValue = [0.0f, 0.0f, 0.0f];
	m_alphaValue = 1.0f;
}

void
vguiColor::SetColor(vector value)
{
	m_colorValue = value;
}

void
vguiColor::SetColorWithAlpha(vector color, float alpha)
{
	m_colorValue = color;
	m_alphaValue = alpha;
}

vector
vguiColor::GetColor(void)
{
	return m_colorValue;
}

float
vguiColor::GetAlpha(void)
{
	return m_alphaValue;
}