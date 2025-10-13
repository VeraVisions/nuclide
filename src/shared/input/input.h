// Actually used by input_button etc.
#define INPUT_BUTTON0 0x00000001	/* attack 1*/
#define INPUT_BUTTON2 0x00000002	/* jumping */
#define INPUT_BUTTON3 0x00000004	/* prone */
#define INPUT_BUTTON4 0x00000008	/* reload */
#define INPUT_BUTTON5 0x00000010	/* secondary */
#define INPUT_BUTTON6 0x00000020	/* use */
#define INPUT_BUTTON7 0x00000040	/* reserved */
#define INPUT_BUTTON8 0x00000080	/* crouching */

#define INPUT_PRIMARY INPUT_BUTTON0
#define INPUT_JUMP INPUT_BUTTON2
#define INPUT_PRONE INPUT_BUTTON3
#define INPUT_RELOAD INPUT_BUTTON4
#define INPUT_SECONDARY INPUT_BUTTON6
#define INPUT_USE INPUT_BUTTON5 /* This can NEVER change. Engine hard-coded. */
#define INPUT_SPRINT INPUT_BUTTON7
#define INPUT_CROUCH INPUT_BUTTON8
