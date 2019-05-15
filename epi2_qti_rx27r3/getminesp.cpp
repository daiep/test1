/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  getminesp.c
 *  
 *  This function returns the minimum echo spacing based on the data
 *  acquisition window and the XTR packet position.  It replaces 
 *  getfiltparams.c which was used in Lx/Cerd to set decimation, taps,
 *  prefills, etc. and the minesp.
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 2/27/2001
 */
/* do not edit anything above this line */

/*
 Version      Date      Author    Description
------------------------------------------------------------------------------
             2/27/10    BJM       Created.

 */

#include "epi2.h"

/* System includes */
#include <stdlib.h>

/* Local includes */
#include "support_decl.h"
#include "filter.h"

/*
 *  getminesp
 *  
 *  Type: Public Function
 *  
 *  Description:
 *    This function return the min esp for EPI given the hardware period, number of
 *    interleaves, readout duration and XTR packet offset.
 *
 *  Type and Call:
 *    STATUS getminesp( echo1_filt, xtr_pkt_off, ileave, hrd_per, vrgfsamp, &minesp )
 *
 *  Parameters Passed:
 *  (I: for input parameter, O: for output parameter)
 *
 *    (I) FILTER_INFO: filter structure (should be filled in by calcfilt already!)
 *    (I) INT xtr_pkt_off: time of xtr packet relative to RBA
 *    (I) INT ileaves: number of interleaves
 *    (I) INT hrd_per: hardware period (GRAD_UPDATE_TIME)
 *    (I) INT vrgf_on: flag passed to indicate ramp sampling 
 *    (O) INT *minesp: minimum echo spacing
 */
STATUS  getminesp( FILTER_INFO epi_filt,
               INT xtr_pkt_off,
               INT ileaves,
               INT hrd_per,
               INT vrgf_on,
               INT *minesp )
{
     
    int tmp;

    /* BJM -> add xtr_pkt offset to minesp */
    *minesp = epi_filt.tdaq + abs( xtr_pkt_off );

    /* make the min esp a function of the interleaves and hardware period */
    tmp = ileaves * hrd_per;
    
    if( (*minesp % tmp) != 0) {
        *minesp = (*minesp / tmp + 1) * tmp;
    }
    
    /* If ramp samp is on, minesp = 0 */
    if(vrgf_on == PSD_ON) {
        *minesp = 0;
    } 

    return SUCCESS;
}   /* end getfiltparams() */

