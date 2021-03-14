/*
 * Copyright:
 * ----------------------------------------------------------------
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 *   (C) COPYRIGHT 2014, 2016 ARM Limited
 *       ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 * ----------------------------------------------------------------
 * File:     main.c
 * Release Information : Cortex-M3 DesignStart-r0p1-00rel0
 * ----------------------------------------------------------------
 *
 */

/*
 * --------Included Headers--------
 */

/*#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>*/

// Xilinx specific headers
#include "xparameters.h"
#include "xil_types.h"
#include "m3_for_arty.h"        // Project specific header




/*******************************************************************/

int main (void)
{

    // Define local variables
	volatile int     i;
	u32 axi_memory_data[8] = {0x01234567, 0x89abcdef, 0xdeadbeef, 0xfeebdaed, 0xa5f03ca5, 0x87654321, 0xfedc0ba9, 0x01020408};
	volatile u32 *pAXImemory = (u32 *) XPAR_MYMEMORY_0_BASEADDR;
	volatile u32 axi_data_read[8] = {0};

		
	  // *****************************************************
    // Test the AXI
    // *****************************************************
 
    // Write to AXI
	for(i=0; i<(sizeof(axi_memory_data)/sizeof(u32)); i++)
        *pAXImemory++ = axi_memory_data[i];

    // Reset the pointer
    pAXImemory = (u32 *)XPAR_MYMEMORY_0_BASEADDR;
	for(i=0; i<(sizeof(axi_memory_data)/sizeof(u32)); i++)
    {
		axi_data_read[i]=*pAXImemory++;
    }

}

