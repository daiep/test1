/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  epiCalFile.e
 *  
 *  
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 5/11/01
 */
/* do not edit anything above this line */
/***************************************************
  14.5 10/09/2006 TS   MRIhc15304 - coil info related changes for 14.5
  20.0 07/15/2008 SWL  MRIhc38838: B0 dither calibration is removed for DVMR
                       hardware. The EPI PSD no longer checks or reads from
                       b0 dither cal files.
  20.0 08/06/2008 SWL  MRIhc39142: The B0 dither calibration is removed for
                       DVMR hardware. The EPI PSD no longer checks the '
                       delay.esp*' files.
  20.1 12/26/2008 SWL  MRIhc39275: The delay.esp files are reinstated to enable 
                       EPI oblique correction.

       12/31/2009 VSN/VAK MRIhc46886 : SV to DV Apps Sync Up

 ***********************************************************************/

@host epiCalCV

int nodelay=0;                  
int nodelayesp=0;
int b0dither_new = 1 with {0,1,1,VIS,"b0dither calculation. 0= exponential fitting; 1= interpolation.",};

int nob0dither=0;	        /* File existence flags for b0_dither.cal and delay.dat */
int nob0dither_interpo=0;       /* File existence flags for b0vectors.dat.body<head>.
				   b0vectors.dat.body<head> is created during the 
				   B0 dither calibration procedure. It holds the phase 
				   dither values for each axis for 30 different esp 
				   values. The epi psd reads this file to determine 
				   how much phase dither to apply to the receiver to 
				   count act the uncompensated short time constant 
				   B0 eddy current effects. */

				/* bcrvf1.dat: Created during Bandpass Asymmetry cal.
				   It comtains mag. and phase correction vector data 
				   that is applied to epi raw data after the first FFT 
				   to correct for mag. and phase asymmetries induced
				   by the 100kHz LPF in the faster receiver.

                                   bcrvs1.dat: Created during Bandpass Asymmetry cal.
                                   It comtains mag. and phase correction vector data 
                                   that is applied to epi raw data after the first FFT 
                                   to correct for mag. and phase asymmetries induced
                                   by the standard receiver 0. */

int nobcfile=0;		

int number_of_bc_files;                  
int activeReceivers=-1;                  
int flagWarning = TRUE;

@host epiCalFileHost
STATUS epiCalFileCVInit(void);
STATUS epiCalFileCVCheck(void);

STATUS epiCalFileCVInit(void) {

    FILE *fp;
    const char *infile1="b0_dither.cal";
    const char *infile2="delay.dat";
    const char *infile3="delay.esp";
    const char *infile4="b0vectors.dat";

    const char *path="/usr/g/caldir/";
    char basefile1[80], basefile2[80], basefile3[80], basefile4[80];
 
    /* Check for the existence of the epi calibration files */
    strcpy(basefile1, path);
    strcat(basefile1, infile1);
    strcpy(basefile2, path);
    strcat(basefile2, infile2);
    strcpy(basefile3, path);
    strcat(basefile3, infile3);
    strcpy(basefile4, path);
    strcat(basefile4, infile4);
    
    /* Determine which coil is being used */
    switch(getTxCoilType()) {
        case TX_COIL_LOCAL:
            strcat(basefile1, ".head");
            strcat(basefile3, "h.xyz");
            strcat(basefile4, ".head");
            break;
        case TX_COIL_BODY:
        default:
            strcat(basefile1, ".body");
            strcat(basefile3, "b.xyz");
            strcat(basefile4, ".body");
            break;
    }
    

    /* Open the b0_dither.cal file */
    if ((fp=fopen(basefile1, "r")) ==NULL) {
        nob0dither=1;
    } else {
        fclose(fp);
    }

    /* Open the delay.dat file */
    if ((fp=fopen(basefile2, "r")) ==NULL) {
        nodelay=1;
    } else {
        fclose(fp);
    }

    /* Open the delay.esp.xyz file */
    if ((fp=fopen(basefile3, "r")) ==NULL) {
        nodelayesp=1;
    } else {
        fclose(fp);
    }

    /* Open the b0vectors.dat file */
    if ((fp=fopen(basefile4, "r")) ==NULL) {
        nob0dither_interpo=1;
    } else {
        fclose(fp);
    }

    return SUCCESS;
    
} /* end epiCalFileCheck */

 
STATUS epiCalFileCVCheck (void) {

    char calfiles[2560];
    char bccalfiles[2560];       
    char bcfile[80], bcfile2[80];
    const char *bcpath="/usr/g/caldir/";
    int recvnum;		
    FILE *fpbc;

    if (PSDDVMR == psd_board_type)
    {
        /* DVMR does not require B0 dither.  Do not warn user if
         * calibration files are not present */
        nob0dither = 0;
        nob0dither_interpo = 0;
        if (30000 == cffield)
	{
	    nodelayesp = 0;
	}
    }

    /* epi cal files */
    if (((nodelay==1) || (nob0dither==1 && b0dither_new==0) ||
         (nodelayesp==1) || (nob0dither_interpo==1 && b0dither_new==1)
        ) && (exist(opepi)==PSD_ON) ) {
        strcpy(calfiles, "/usr/g/caldir/");
        if (nodelay==1)
            strcat(calfiles, " delay.dat");
        if (nob0dither==1 && b0dither_new==0) {
            /* strcat filename based on which coil is being used */
            switch(getTxCoilType()) {
                case TX_COIL_LOCAL:
                    strcat(calfiles, " b0_dither.cal.head");
                    break;
                case TX_COIL_BODY:
                default:
                    strcat(calfiles, " b0_dither.cal.body");
                    break;
            }
        }
        if (nodelayesp==1) {
            /* strcat filename based on which coil is being used */
            switch(getTxCoilType()) {
                case TX_COIL_LOCAL:
                    strcat(calfiles, " delay.esph.xyz");
                    break;
                case TX_COIL_BODY:
                default:
                    strcat(calfiles, " delay.espb.xyz");
                    break;
            }
        }
        if (nob0dither_interpo==1 && b0dither_new==1) {
            /* strcat filename based on which coil is being used */
            switch(getTxCoilType()) {
                case TX_COIL_LOCAL:
                    strcat(calfiles, " b0vectors.dat.head");
                    break;
                case TX_COIL_BODY:
                default:
                    strcat(calfiles, " b0vectors.dat.body");
                    break;
            }
        }

#ifndef SIM
        epic_warning( "The following files were not found: %s. "
                      "Using default values.", calfiles );
#endif

        nob0dither = 0;
        nodelay = 0;
        nodelayesp = 0;
        nob0dither_interpo = 0;  
        _nob0dither.fixedflag = 1;
        _nodelay.fixedflag = 1;
        _nodelayesp.fixedflag = 1;
        _nob0dither_interpo.fixedflag = 1;
    }

    strcpy(bccalfiles, "/usr/g/caldir/");

    nobcfile = 0;
    for( recvnum = (cfrecvst + 1); recvnum < (cfrecvend + 2); recvnum++ ) {
        sprintf(bcfile,"%sbcrvs%d.dat", bcpath, recvnum);
        if ((fpbc=fopen(bcfile, "r")) ==NULL) {
            nobcfile = nobcfile + 1;
            sprintf(bcfile2,"bcrvs%d.dat ", recvnum);
            strcat(bccalfiles, bcfile2);  
        } else {
            fclose(fpbc);
        }
    }        
    number_of_bc_files = cfrecvend - cfrecvst - nobcfile + 1;
    if(activeReceivers !=  (cfrecvend - cfrecvst + 1)) {
        activeReceivers =  (cfrecvend - cfrecvst + 1); 
        flagWarning = TRUE;
    }


    if ( (cfrecvend - cfrecvst + 1 > number_of_bc_files) && (exist(opepi)==PSD_ON) ) {
    
#ifndef SIM
 
        if((flagWarning == TRUE) && (value_system_flag == NON_VALUE_SYSTEM) && (PSDDVMR != psd_board_type)) {
            epic_warning( "The following files were not found: %s. "
                          "Please have Field Service run bandpass cals.", bccalfiles );
            flagWarning = FALSE;  /* only display error once */
        }

#endif

    }
  
    return SUCCESS;

}
