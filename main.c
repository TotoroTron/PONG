/*top_level.c*/

//PS = processing system
//PL = programmable logic

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include "xil_printf.h"

void reset();
void processGameLogic();
void processImage();
void drawScore(int s, int n);
void drawWinScreen(int p);
void wait(int w);

typedef struct
{
	int x, y; //position in space
	int dx, dy; //vector components
	int w, h; //size dimensions
} sBall;

typedef struct
{
	int y; //position in space
	int h; //size dimensions
} sPaddle;

static sBall ball;
static sPaddle pad1;
static sPaddle pad2;

//instantiate XGpio data
XGpio io_data; //data for lower half of display
XGpio io_addr; //PL display ram interface (address, enable, clock)
XGpio io_clock; //
XGpio io_playerInputs; //player buttons, reset switch

//instantiate global variables
//int dataUpper;
//int dataLower;
int addr;
//int clock;
int playerInputs;
int image[32][32] = {0}; //image[y][x]
int score1 = 0;
int score2 = 0;
int scoreFlag = 0;
int winFlag = 0;
int col1 = 0x00000000;
int col2 = 0x000000FF; //score color
int col3 = 0x00220022; //background color
int col4 = 0x00FF22FF; //paddle + ball color
int col5 = 0x00FF0000; //ball miss color

void reset()
{
	//resets the image and game logic
	score1 = 0;
	score2 = 0;
	pad1.y = 10;
	pad1.h = 5;
	pad2.y = 10;
	pad2.h = 5;
	ball.x = 16;
	ball.y = 10;
	ball.dx = -1;
	ball.dy = 1;
}

void processGameLogic()
{
	playerInputs = XGpio_DiscreteRead(&io_playerInputs, 1);

	if((playerInputs & 16) == 16)
	{
		reset();
	}
	else if(winFlag > 0)
	{
		reset();
		winFlag = 0;
	}
	else if(scoreFlag > 0)
	{
		if(scoreFlag == 1)
		{
			if(score1 < 8)
			{
				score1++;
				ball.x = 16;
				ball.y = 10;
			}
			else
			{
				winFlag = 1;
			}
		}
		if(scoreFlag == 2)
		{
			if(score2 < 8)
			{
				score2++;
				ball.x = 16;
				ball.y = 10;
			}
			else
			{
				winFlag = 2;
			}
		}
		scoreFlag = 0;
	}
	else
	{
		//REGISTER PLAYER INPUTS
		if((playerInputs & 1) == 1)
		{
			if(pad1.y > 0)
			{
				pad1.y--;
			}
		}
		if((playerInputs & 2) == 2)
		{
			if(pad1.y < 17)
			{
				pad1.y++;
			}
		}
		if((playerInputs & 4) == 4)
		{
			if(pad2.y > 0)
			{
				pad2.y--;
			}
		}
		if((playerInputs & 8) == 8)
		{
			if(pad2.y < 17)
			{
				pad2.y++;
			}
		}

		//DETECT PADDLE COLLISION
		if((ball.x == 1) && ((pad1.y <= ball.y) && ((pad1.y + pad1.h) >= ball.y)))
		{
			ball.dx = ball.dx * -1;
		}
		if((ball.x == 30) && ((pad2.y <= ball.y) && ((pad2.y + pad2.h) >= ball.y)))
		{
			ball.dx = ball.dx * -1;
		}
		//DETECT WALL COLLISION
		if( (ball.y == 0) || (ball.y == 21) )
		{
			ball.dy = ball.dy * -1;
		}

		ball.y += ball.dy;
		ball.x += ball.dx;


		//DETECT PADDLE MISS
		if(ball.x == 0)
		{
			scoreFlag = 2;
		}
		if(ball.x == 31)
		{
			scoreFlag = 1;
		}

	}
}

void processImage()
{
	//reset image
	for(int i = 0; i < 32; i++)
	{
		for(int j = 0; j < 32; j++)
		{
//			if(i < 22)
//			{
//				image[i][j] = col3;
//			}
//			else
//			{
//				image[i][j] = col3;
//			}
			image[i][j] = col3;
		}
	}

	if(winFlag > 0)
	{
		drawWinScreen(winFlag);
	}

	//draw ball
	if(scoreFlag > 0)
	{
		image[ball.y][ball.x] = col5;
	}
	else
	{
		image[ball.y][ball.x] = col4; //white
	}
	//draw paddle 1
	for(int i = 0; i < pad1.h; i++)
	{
		image[i+pad1.y][0] = col4; //white
	}

	//draw paddle 2
	for(int i = 0; i < pad2.h; i++)
	{
		image[i+pad2.y][31] = col4; //white
	}

	//score section
	for(int j = 0; j < 32; j++)
	{
		image[22][j] = col2; //green
	}
	for(int i = 23; i <= 32; i++)
	{
		image[i][6] = col2; //green
		image[i][25] = col2; //green
	}
	drawScore(score1, 0);
	drawScore(score2, 1);
}

void drawWinScreen(int p)
{
	for(int i = 3; i <= 9; i++)
	{
		image[i][11] = col2;
	}
	image[3][12] = col2;
	image[3][13] = col2;
	image[3][14] = col2;
	image[4][15] = col2;
	image[5][12] = col2;
	image[5][13] = col2;
	image[5][14] = col2;

	if(p == 1)
	{
		for(int i = 3; i <= 9; i++)
		{
			image[i][19] = col2;
		}
		image[4][18] = col2;
		image[9][17] = col2;
		image[9][18] = col2;
		image[9][20] = col2;
		image[9][21] = col2;
	}

	if(p == 2)
	{
		for(int i = 17; i <= 21; i++)
		{
			image[9][i] = col2;
		}
		image[8][17] = col2;
		image[7][18] = col2;
		image[6][19] = col2;
		image[6][20] = col2;
		image[5][21] = col2;
		image[4][21] = col2;
		image[3][20] = col2;
		image[3][19] = col2;
		image[3][18] = col2;
		image[4][17] = col2;
	}

	for(int i = 11; i <= 17; i++)
	{
		image[i][4] = col2;
		image[i][8] = col2;
		image[i][11] = col2;
		image[i][14] = col2;
		image[i][18] = col2;
	}
	image[16][5] = col2;
	image[15][6] = col2;
	image[16][7] = col2;
	image[11][10] = col2;
	image[11][12] = col2;
	image[17][10] = col2;
	image[17][12] = col2;
	image[12][15] = col2;
	image[13][16] = col2;
	image[14][17] = col2;

	for(int i = 21; i <= 23; i++)
	{
		image[11][i] = col2;
		image[13][i] = col2;
		image[17][i] = col2;
	}
	image[12][20] = col2;
	image[11][24] = col2;
	image[14][24] = col2;
	image[15][24] = col2;
	image[16][24] = col2;
	image[16][20] = col2;

	for(int i = 11; i <= 15; i++)
	{
		image[i][26] = col2;
	}
	image[17][26] = col2;
}

void drawScore(int s, int i)
{
	int n;
	n = 26*i;
	switch(s)
	{
		case 0:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			image[25][1+n] = col2;
			image[25][4+n] = col2;
			image[26][1+n] = col2;
			image[26][4+n] = col2;
			//image[27][2+n] = 0;
			//image[27][3+n] = 0;
			image[28][1+n] = col2;
			image[28][4+n] = col2;
			image[29][1+n] = col2;
			image[29][4+n] = col2;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
		case 1:
			//image[24][2+n] = 0;
			//image[24][3+n] = 0;
			//image[25][1+n] = 0;
			image[25][4+n] = col2;
			//image[26][1+n] = 0;
			image[26][4+n] = col2;
			//image[27][2+n] = 0;
			//image[27][3+n] = 0;
			//image[28][1+n] = 0;
			image[28][4+n] = col2;
			//image[29][1+n] = 0;
			image[29][4+n] = col2;
			//image[30][2+n] = 0;
			//image[30][3+n] = 0;
			break;
		case 2:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			//image[25][1+n] = 0;
			image[25][4+n] = col2;
			//image[26][1+n] = 0;
			image[26][4+n] = col2;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			image[28][1+n] = col2;
			//image[28][4+n] = 0;
			image[29][1+n] = col2;
			//image[29][4+n] = 0;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
		case 3:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			//image[25][1+n] = 0;
			image[25][4+n] = col2;
			//image[26][1+n] = 0;
			image[26][4+n] = col2;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			//image[28][1+n] = 0;
			image[28][4+n] = col2;
			//image[29][1+n] = 0;
			image[29][4+n] = col2;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
		case 4:
			//image[24][2+n] = 0;
			//image[24][3+n] = 0;
			image[25][1+n] = col2;
			image[25][4+n] = col2;
			image[26][1+n] = col2;
			image[26][4+n] = col2;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			//image[28][1+n] = 0;
			image[28][4+n] = col2;
			//image[29][1+n] = 0;
			image[29][4+n] = col2;
			//image[30][2+n] = 0;
			//image[30][3+n] = 0;
			break;
		case 5:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			image[25][1+n] = col2;
			//image[25][4+n] = 0;
			image[26][1+n] = col2;
			//image[26][4+n] = 0;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			//image[28][1+n] = 0;
			image[28][4+n] = col2;
			//image[29][1+n] = 0;
			image[29][4+n] = col2;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
		case 6:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			image[25][1+n] = col2;
			//image[25][4+n] = 0;
			image[26][1+n] = col2;
			//image[26][4+n] = 0;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			image[28][1+n] = col2;
			image[28][4+n] = col2;
			image[29][1+n] = col2;
			image[29][4+n] = col2;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
		case 7:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			//image[25][1+n] = 0;
			image[25][4+n] = col2;
			//image[26][1+n] = 0;
			image[26][4+n] = col2;
			//image[27][2+n] = 0;
			//image[27][3+n] = 0;
			//image[28][1+n] = 0;
			image[28][4+n] = col2;
			//image[29][1+n] = 0;
			image[29][4+n] = col2;
			//image[30][2+n] = 0;
			//image[30][3+n] = 0;
			break;
		case 8:
			image[24][2+n] = col2;
			image[24][3+n] = col2;
			image[25][1+n] = col2;
			image[25][4+n] = col2;
			image[26][1+n] = col2;
			image[26][4+n] = col2;
			image[27][2+n] = col2;
			image[27][3+n] = col2;
			image[28][1+n] = col2;
			image[28][4+n] = col2;
			image[29][1+n] = col2;
			image[29][4+n] = col2;
			image[30][2+n] = col2;
			image[30][3+n] = col2;
			break;
	}
}

void outputImage() //outputs the image to the dual-port BRAM in PL
{
	//image format in PL BRAM (not to be confused with DDR3 RAM in PS):
	//512 address locations in BRAM
	//each location holds RGB data for 2 pixels
	//each location holds 48-bit data, 24-bits for each pixel
	//each pixel has 8-bits Red, 8-bits Green, 8-bits Blue
	//RGB pixel format: 0xRRGGBB
	//BRAM data format: 0xRRGGBBRRGGBB

	//image format in PS:
	//32x32 array of 32-bit integers
	//each array element represents a 24-bit pixel
	//RGB pixel format: 0x00RRGGBB

	for(int i = 0; i < 32; i++) //i = pixel vertical coordinate (pixel row)
	{
		for(int j = 0; j < 32; j++) //j = pixel horizontal coordinate (pixel column)
		{
			addr = i*32 + j;
			//xil_printf("%d\n", addr );
	    	//read variables into xgpio outputs
	    	XGpio_DiscreteWrite(&io_data, 1, image[i][j]);
	    	//print("1\n");
	    	XGpio_DiscreteWrite(&io_addr, 1, addr);
	    	//print("2\n");
	    	wait(1);
	    	XGpio_DiscreteWrite(&io_clock, 1, 1);
	    	//print("3\n");
	    	wait(1);
	    	XGpio_DiscreteWrite(&io_clock, 1, 0);
	    	//print("4\n");
		}
	}
	if (winFlag > 0)
	{
		wait(380000000);
	}
	if (scoreFlag > 0)
	{
		wait(64000000);
	}
}

void wait(int w)
{
	while (--w > 0) { }
}

int main()
{
    init_platform(); //initialize the platform

    //initialize axi gpio (make sure deviceID matches hdl instance)
    XGpio_Initialize(&io_data, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&io_addr, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_Initialize(&io_clock,	XPAR_AXI_GPIO_2_DEVICE_ID);
    XGpio_Initialize(&io_playerInputs, XPAR_AXI_GPIO_3_DEVICE_ID);

    //data direction reg (input is 1, output is 0)
    XGpio_SetDataDirection(&io_data, 1, 0);
    XGpio_SetDataDirection(&io_addr, 1, 0);
    XGpio_SetDataDirection(&io_clock, 1, 0);
    XGpio_SetDataDirection(&io_playerInputs, 1, 1);

    print("i am alive\n"); //debug statement to UART to see if code is running

    reset();

    while(1)
    {
		processGameLogic();
		processImage();
		outputImage();
		wait(4000000);
    }
    cleanup_platform();
    return 0;
}
