/*@Start******************************************************************************************/
/* GEMSBG C source File
 * Copyright (C) 2010 The General Electric Company
 *
 *  File Name:  HoecCorr.e
 *  Author:  Dan Xu
 *
 * $Source: HoecCorr.e $
 * $Revision: 0.0 $  $Date: 10/07/2010$
 */

/*@Synopsis
Based on GRAFIMAGE HOEC measurements and DWI gradient shape/timing, this file contains functions/code
to calculate the amount of read and blip gradient as well as frequency correction needed for PSD;
in addition, recon HOEC correction coefficients are also calculated. Both the PSD and recon correction
outputs are saved in files. Functions/code that apply the HOEC correction as well as CF/TG corrections
are also included. Various sections of this file are inlined into epi2.e to enable HOEC correction.
The key function in this file is CalcPsdReconHoecCorr().
*/

/* ************************************************************************************************
Rev        Date          Person    Comments
0.1           10/07/2010    DX     Created.
0.2           02/06/2012    GW     Replaced hardcoded form of basis rotation matrix with
                                   a recursive form. Implemented a separate config file to handle
                                   the manual mode.
0.3           01/20/2013    DX     Added support to the new RDB_HEADER_REC and RDB_GRAD_DATA_TYPE
                                   header variables. Moved hoec.cal reading to host. Introduced
                                   hoec_cal_data_sign to accommodate the sign convention assumed
                                   in the HOEC system tool
SV25          18-FEB-2014   WJZ    HCSDM00267592: Disable HOECC for SV25 platform;
SV25 0.1      10-Jan-2013   WJZ    Implemented eco-MPG case;
ML1.0         06/30/2015    ZZ     Multiband can only do recon correction
MR27          06-Apr-2017   AG     HCSDM00453765: account for readout shifts to compute HOECC coefficients for MultiShot DWI
MR27          23-May-2017   AG     HCSDM00460600: use effective echo spacing for MultiShot DWI to account for opnshots>1
MR27          11-Sep-2017   GW     HCSDM00477919  Added ref_in_scan_flag and rpg_in_scan_flag consideration when calling getDiffGradAmp()
                                   to generate diffusion gradient amplitude table for Recon to do HOEC correction

*/

/*@End********************************************************************************************/

@global HoecGlobal

#include "HoecCorr.h"

/* File to determine how HOEC terms should be distributed for PSD and recon correction under the manual mode */
#ifdef SIM
#define HOEC_CORRTERMS_FILE "hoecCorrTerms.txt"
#else
#define HOEC_CORRTERMS_FILE "/usr/g/bin/hoecCorrTerms.txt"
#endif

#define HOEC_MAX_ILEAVE 8  /* for now...*/
/* File to store debug information for HOEC correction */
#ifdef SIM
#define HOEC_DEBUG_FILE "hoecDebug.txt"
#else
#define HOEC_DEBUG_FILE "/usr/g/bin/hoecDebug.txt"
#endif

/* File containing HOEC recon coefficients, dumped only in debug mode */
#ifdef SIM
#define HOEC_COEF_RECON_FILE "hoecCoefRecon.txt"
#else
#define HOEC_COEF_RECON_FILE "/usr/g/bin/hoecCoefRecon.txt"
#endif

@host HoecIpgexport

/* slice-dependent HOEC contrinutions on each echo, based on logic axis */
float dwi_hoec_gcor_XonX[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};
float dwi_hoec_gcor_YonX[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}}; 
float dwi_hoec_gcor_ZonX[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};

float dwi_hoec_gcor_XonY[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};
float dwi_hoec_gcor_YonY[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};
float dwi_hoec_gcor_ZonY[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};

float dwi_hoec_bcor_XonB0[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};
float dwi_hoec_bcor_YonB0[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};
float dwi_hoec_bcor_ZonB0[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL]={{{0}}};

@cv HoecCV

int hoecc_flag = 0 with {0,3,0,VIS,"HOEC correction flag: 0=Off, 1=On, 2=Manual(from hoecCorrTerms.txt), 3=Recon for All",};
int hoecc_psd_flag = 0 with {0,1,0,INVIS,"PSD HOEC correction flag: 0=Off, 1=On",};
int hoecc_recon_flag = 0 with {0,1,0,INVIS,"Recon HOEC corrrrection flag: 0=Off, 1=On",};
int hoecc_debug = 0 with {0, 1, 0, INVIS, "Flag for HOEC correction debug",};
int hoecc_support = 0 with {0,1,0,VIS,"HOEC correction support flag: 0=not support, 1=support",};
int hoecc_enable = 0 with {0,1,0,VIS,"HOEC correction enabling status: 0=not enabled, 1=enabled",};

int necho_before_te = 0 with {0,,0,VIS,"number of echoes before t=TE",};

int psd_per_echo_corr = 1 with {0,1,1,VIS,"1 = per echo PSD HOEC correction, 0 = DC correction",};
int read_corr_option = 1 with {0,2,1,VIS,"Correct RO by substracting DC (0), DC*ESP/(pw_gxw+pwgxwad) (1) or DC*ESP/pw_gxw (2)",};

int psd_debug_echo_index = -1 with {-2,1024,-1,VIS,"echo index to save result. -1 = center echo, -2 = last echo, n = nth echo",};
int psd_echo_for_debug = 0;  /* actual echo index for debug, depending on psd_debug_echo_index */
int psd_ileave_for_debug = 0;  /* actual interleave index for debug, depending on psd_debug_echo_index */
int psd_slice_for_debug = 0; /* actual slice index for debug */
float hoec_cal_data_sign = 1.0 with {-1.0,1.0,1.0,VIS,"sign for the amplitudes given in hoec.cal",};
int hoecc_manual_mode_warning_flag = 0 with {0, 1, 0, INVIS, "Flag for the warning message in manual mode",};
int hoecc_manual_mode_psd_override_flag = 0 with {0, 1, 0, INVIS, "Flag for overriding PSD corrected terms in manual mode",};

@host HoecReadFileFunctions

/* in manual mode, which bases are included in PSD/recon
   are set in hoecCorrTerms.txt and loaded into this array */
int ext_corr_term[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES] = {{0}};

/* in manual mode, depending on the config file, some terms may not be
   designed to be compensated, in which case alpha_scale would be 0 */
float alpha_scale[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES][HOEC_MAX_NUM_TERMS] = {{{0}}};

/* Note: Z gradients are not corrected. */
/* HCSDM00195152: This should be moved to HoecIpgexport to correct Z gradients */
float dwi_hoec_gcor_XonZ[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL] = {{{0}}};
float dwi_hoec_gcor_YonZ[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL] = {{{0}}};
float dwi_hoec_gcor_ZonZ[HOEC_MAX_ILEAVE][HOEC_MAX_SLQUANT][HOEC_MAX_ETL] = {{{0}}};

/* Function to read HOEC compensation configuration in manual mode */
STATUS ReadHoecCorrTerms(void)
{
    FILE *fp;
    FILE *debug_file_ptr;
    char tempStr[257];
    int i,j;
 
    /* Intiialization */
    for (i=0;i<HOEC_TOTAL_NUM_AXES;i++)
    {
        for (j=0;j<HOEC_MAX_NUM_BASES;j++)
        {
            ext_corr_term[i][j] = 0;  /* basis correction option in manual mode */
        }
    }

    if ((fp = fopen(HOEC_CORRTERMS_FILE, "r")) == NULL)
    {
        return FAILURE;
    }
 
    /* Read correction flag for bases in case manual mode is selected (hoecc_psd_flag=2) */
    /* basis correction option: 0 = no correction, 1 = psd, 2 = recon */
    for (i=0;i<HOEC_TOTAL_NUM_AXES;i++)
    {
        for (j=0;j<HOEC_MAX_NUM_BASES;j++)
        {
            do
            {
                if (fgets (tempStr, 256, fp) == NULL) return failureClose(fp);
            } while(isCommentOrBlankLine(tempStr));

            if (sscanf(tempStr, "%d %*s", &(ext_corr_term[i][j])) < 1) return failureClose(fp);

            if (j<hoec_cal_info.total_bases_per_axis)
            {
                if (ext_corr_term[i][j] < 0 || ext_corr_term[i][j] > 2)
                    return failureClose(fp);
            }
        }
    }

    fclose(fp);

    /* In debug mode, write all the variables into a file */
    if (hoecc_debug == PSD_ON)
    {
        debug_file_ptr = fopen(HOEC_DEBUG_FILE, "a");
        if (debug_file_ptr != NULL)
        {
            fprintf(debug_file_ptr, "\nCorrection Terms - Manual Mode\n");
            fprintf(debug_file_ptr, "Donor Base Flag(0-off, 1-PSD, 2-Recon\n");
            
            for (i=0;i<HOEC_TOTAL_NUM_AXES;i++)
            {
                for (j=0;j<HOEC_MAX_NUM_BASES;j++)
                {
                    fprintf(debug_file_ptr, "%d %2d %d\n", i, j, ext_corr_term[i][j]);
                }
            }
            fclose(debug_file_ptr);
        }
        else
        {        	
            printf("Failed to open %s.\n", HOEC_DEBUG_FILE);
        }            
    }

    return SUCCESS;
}

/* Supporting function to handle file reading failure */
STATUS failureClose(FILE * fp)
{
    if(fp != NULL) fclose(fp);
    return FAILURE;
}

/* Supporting function to determine if current line is blank */
int isCommentOrBlankLine(char * str)
{
    int i;

    i = -1;
    while(isspace(str[++i]));
    if(( i == (int)strlen(str)) || (str[i] == '#')) return 1;
    return 0;
}

/* Determine if HOEC is supported or not */
@host HoecSupportMode
{ /* Start of code inlined from HoecCorr.e HoecSupportMode */

    /* Determine if HOECC feature is supported. Currently it is supported unconditionally;
       if some future program decides to not support HOECC, hoecc_support can be set to PSD_OFF */    
    /* SVBranch HCSDM00267592: Disable HOECC in SV25 platform */
    if ((VALUE_SYSTEM_SVEM == value_system_flag) || (VALUE_SYSTEM_SVDM == value_system_flag))       
    {
        hoecc_support = PSD_OFF;
    }
    else
    {
        hoecc_support = PSD_ON;
    }

} /* End of code inlined from HoecCorr.e HoecSupportMode */

/* Initialize HOEC correction configuration */
@host HoecEval
{ /* Start of code inlined from HoecCorr.e HoecEval */

    /* Determine is HOECC feature is enabled in the current configuration */
    if ((hoecc_support == PSD_ON) && (exist(opdiffuse) == PSD_ON) && (dualspinecho_flag == PSD_OFF) && (opnumgroups <= 1) )
    {
        hoecc_enable = PSD_ON;
    }
    else
    {
        hoecc_enable = PSD_OFF;
    }

    /* Show/hide HOECC checkbox according to hoecc_enable value */
    if (hoecc_enable)
    {
        pihoeccvis = 1;
        pihoeccnub = 1;
        hoecc_flag = ophoecc; /* hoecc_flag determines HOECC is on or off; ophoecc is input from UI */
        if (mux_flag && ophoecc){
            hoecc_flag = 3; /* ZZ: multiband use recon correction for all the terms*/
        }
    }
    else
    {
        pihoeccvis = 0;
        pihoeccnub = 0;
        hoecc_flag = 0;
    }

    /* turn on the option of SSE for the tensor case, which overrides HCSDM00155198 */
    if (hoecc_support == PSD_ON && muse_flag == PSD_OFF)
    {
        pidualspinechonub = 1;
        _opdualspinecho.fixedflag = 0;
    }

    /* read in high order eddy current alphas and taus. These coefficients are split into PSD and recon
       correction coefficients in cveval() */
    if (hoecc_flag != PSD_OFF)
    {
        int i, j, k;
        int xorder, yorder, zorder;

        for (i=0; i<HOEC_TOTAL_NUM_AXES; i++)
        {
            for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
            {
                for (k=0; k<hoec_cal_info.num_terms[i][j]; k++)
                {
                    alpha_scale[i][j][k] = 1.0;  /* Initialize alpha_scale to 1; some of them can be set to 0 in manual mode;
                                                    all of them stay as 1 for auto mode */
                }
            }
        }

        if (hoecc_flag == 2) /* Manual mode for HOEC correction */
        {
            if (ReadHoecCorrTerms() == FAILURE)
            {
#ifndef SIM
                if (hoecc_manual_mode_warning_flag == 0)
                {
                    epic_warning("Reading hoecCorrTerms.txt failed. Manual Mode ignored.");
                    hoecc_manual_mode_warning_flag = 1;
                }
#endif
                cvoverride(hoecc_flag, ophoecc, PSD_FIX_OFF, PSD_EXIST_ON);
                hoecc_psd_flag = hoecc_flag;
                hoecc_recon_flag = hoecc_flag;
            }
            else
            {
                int changeFlag = PSD_OFF;

                hoecc_psd_flag = PSD_OFF;
                hoecc_recon_flag = PSD_OFF;

                for (i=0; i<HOEC_TOTAL_NUM_AXES; i++)
                    for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                    {
                        xorder = hoec_cal_info.termIndex2xyzOrderMapping[0][j];
                        yorder = hoec_cal_info.termIndex2xyzOrderMapping[1][j];
                        zorder = hoec_cal_info.termIndex2xyzOrderMapping[2][j];

                        /* PSD correction terms should be those type-A terms, otherwise set the
                           correspoinding terms to no-correction */
                        if (ext_corr_term[i][j] == 1) /* intended for PSD correction */
                        {
                            if (xorder+yorder>1)
                            {
                                ext_corr_term[i][j] = 0;
                                changeFlag = PSD_ON;
                            }
                        }
                        if (ext_corr_term[i][j] == 1) hoecc_psd_flag = PSD_ON;
                        else if (ext_corr_term[i][j] == 2) hoecc_recon_flag = PSD_ON;
                    }
#ifndef SIM
                if (changeFlag == PSD_ON && hoecc_manual_mode_psd_override_flag == 0)
                {
                    epic_warning("PSD only can correct X or Y linear terms. Correction terms modified.");
                    hoecc_manual_mode_psd_override_flag = 1;
                }
#endif
                if (hoecc_psd_flag == PSD_OFF && hoecc_recon_flag == PSD_OFF)
                {
                    cvoverride(hoecc_flag, PSD_OFF, PSD_FIX_OFF, PSD_EXIST_ON);
                }
                else
                {
                    /* set alpha to 0 if the term is not intended to correct */
                    for (i=0; i<HOEC_TOTAL_NUM_AXES; i++)
                        for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                            for (k=0; k<hoec_cal_info.num_terms[i][j]; k++)
                            {
                                if (ext_corr_term[i][j] == 0)
                                {
                                    alpha_scale[i][j][k] = 0.0;
                                }
                            }
                }
            }
        }

        if (hoecc_flag == 1) /* correct all terms */
        {
            for (i=0; i<HOEC_TOTAL_NUM_AXES; i++)
                for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                {
                    xorder = hoec_cal_info.termIndex2xyzOrderMapping[0][j];
                    yorder = hoec_cal_info.termIndex2xyzOrderMapping[1][j];
                    zorder = hoec_cal_info.termIndex2xyzOrderMapping[2][j];

                    if (xorder+yorder < 2) /* for PSD correction */
                    {
                       ext_corr_term[i][j] = 1;
                    }
                    else /* for recon correction */
                    {
                       ext_corr_term[i][j] = 2;
                    }
                }
            hoecc_psd_flag = PSD_ON;
            hoecc_recon_flag = PSD_ON;
        }

        if (hoecc_flag == 3) /* correct all terms with recon*/
        {
            for (i=0; i<HOEC_TOTAL_NUM_AXES; i++)
                for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                {
                    ext_corr_term[i][j] = 2;
                }
            hoecc_psd_flag = PSD_OFF;
            hoecc_recon_flag = PSD_ON;
        }
    }
    else
    {
        hoecc_psd_flag = PSD_OFF;
        hoecc_recon_flag = PSD_OFF;
    }

    /* if HOEC compensation is on, turn off linear correction */
    dwicntrl = 0;

} /* End of code inlined from HoecCorr.e HoecEval */

/* cvcheck for HOEC correction */
@host HoecCheck
{ /* Start of code inlined from HoecCorr.e HoecCheck */

    if (hoecc_flag != PSD_OFF)
    {
        if (exist(opslquant) > HOEC_MAX_SLQUANT)
        {
            avmaxslquant = HOEC_MAX_SLQUANT;
            epic_error(use_ermes, "Number of slices must be reduced to %d for the current prescription.",
                       EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, HOEC_MAX_SLQUANT);
            return ADVISORY_FAILURE;
        }

        if (tot_etl > HOEC_MAX_ETL)
        {
            epic_error(use_ermes, "The echo train length must be decreased to %d.",
                       EM_PSD_ETL_TOO_BIG, EE_ARGS(1), INT_ARG, HOEC_MAX_ETL - (iref_etl+iref_etl%2));
            return FAILURE;
        }

        if (intleaves > HOEC_MAX_ILEAVE)
        {
            epic_error( use_ermes, "Max. Number of Shots for DW-EPI is %d.",
                       EM_DWEPI_MAX_SHOT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, HOEC_MAX_ILEAVE);
            return FAILURE;
        }
        
        if (pass_reps > HOEC_MAX_DIFFGRADAMP_SIZE)
        {
            epic_error(use_ermes, "The number of phases must be reduced to %-d.",
                       EM_PSD_FMPVAS_PHASES_EXCEEDED, EE_ARGS(1), INT_ARG, HOEC_MAX_DIFFGRADAMP_SIZE);
            return FAILURE;
        }
 
        if ((exist(opdiffuse) == PSD_OFF) && (exist(opflair) == PSD_ON))
        {
            epic_error(use_ermes, "Real Time Field Adjustment is not compatible with FLAIR EPI.",
                       EM_PSD_HOECC_FLAIREPI_INCOMPATIBLE, EE_ARGS(0));
            return FAILURE;
        }

        if ((exist(opdiffuse) == PSD_ON) && (dualspinecho_flag == PSD_ON) && existcv(ophoecc))
        {
            epic_error(use_ermes, "Real Time Field Adjustment is not compatible with Dual Spin Echo.",
                       EM_PSD_HOECC_DSE_INCOMPATIBLE, EE_ARGS(0));
            return FAILURE;
        }
    }
    else
    {
        if ((tensor_flag == PSD_ON) && (dualspinecho_flag == PSD_OFF) && (rfov_flag == PSD_OFF) && existcv(ophoecc))
        {
            epic_error(use_ermes, 
                       "For the current prescription, either Dual Spin Echo or Real Time Field Adjustment needs to be turned on.",
                       EM_PSD_HOECC_DSE_BOTH_OFF, EE_ARGS(0));
            
            return FAILURE;
        }
    }

    setexist(ophoecc, PSD_OFF);

} /* End of code inlined from HoecCorr.e HoecCheck */

/* Calculate per unit (1 G/cm), per axis contribution to delta gradient and frequency
   and set HOEC rh- and ih- CVs */
@host HoecCalcCorrectionPredownload
{
    int i, j;

    /* HCSDM00190686: Disallow the case when DSE and HOECC are both off under clinical 
       mode with Tensor, if FOCUS is not selected. Note that we need to repeat this 
       check in predownload to make sure the impact on various workflow can be fully 
       captured */
    if ((tensor_flag == PSD_ON) && (hoecc_flag == PSD_OFF) && (dualspinecho_flag == PSD_OFF) 
        && (rfov_flag == PSD_OFF) && (opresearch == PSD_OFF)) /*daiep begin 190319 */
    {
        epic_error(use_ermes, 
                   "For the current prescription, either Dual Spin Echo or Real Time Field Adjustment needs to be turned on.", 
                   EM_PSD_HOECC_DSE_BOTH_OFF, EE_ARGS(0));
        
        return FAILURE;
    }

    /* Some initialization */
    for (i=0; i<HOEC_MAX_DIFFGRADAMP_SIZE; i++)
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
        {
            rhdiffusion_grad_amp[i][j] = 0.0;
        }

    for (i=0; i<HOEC_MAX_NUM_BASES; i++)
    {
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
        {
            rhhoec_bases.hoec_coef[i][j] = 0.0;
        }
        rhhoec_bases.hoec_xorder[i] = hoec_cal_info.termIndex2xyzOrderMapping[0][i];
        rhhoec_bases.hoec_yorder[i] = hoec_cal_info.termIndex2xyzOrderMapping[1][i];
        rhhoec_bases.hoec_zorder[i] = hoec_cal_info.termIndex2xyzOrderMapping[2][i];
    }

    if (fract_ky == PSD_FULL_KY)
    {
        necho_before_te = (int)(etl/2);
    }
    else
    {
        necho_before_te = (muse_flag) ? num_overscan/intleaves : num_overscan;
    }

    if (hoecc_flag == PSD_ON && psd_per_echo_corr == 1)  /* determine which echo to plot result */
    {
        if (psd_debug_echo_index == -1)  /* echo index for k-space center */
        {
            psd_echo_for_debug = necho_before_te-1;  /* -1 is because we start with index 0 */
        }
        else if (psd_debug_echo_index == -2)  /* last echo */
        {
            psd_echo_for_debug = tot_etl - 1;
        }
        else if (psd_debug_echo_index>=0 && psd_debug_echo_index<=tot_etl-1)  /* nth echo */
        {
            psd_echo_for_debug = psd_debug_echo_index;
        }
        else
        {
            psd_echo_for_debug = necho_before_te-1;  /* default to the k-space center echo */
        }
    }
    else
    {
        psd_echo_for_debug = 0;
    }

    /* Set DWI timing array, which is used later for HOEC (or linear EC in epi2.e) calculation
       Meanings of the timing array (all units are us):
       t_array[0]: ramp time of DW gradient
       t_array[1]: flat-top time of the DW gradient
       t_array[2]: interval between the end of the first gradient lobe and the begining
                   of the 2nd gradient lobe
       t_array[3]: interval between the very begining of the first DW gradient pulse and the
                   center of the 180 degree pulse
       t_array[4]: interval between the end of the 2nd DW gradient pulse and the begining of
                   the read-out starting point
       t_array[5]: interval between the begining of the read-out and the time where the center
                   of the k-space data is acquired
       t_array[6]: interleave shift for opnshots > 1
    */

    t_array[0]=pw_gxdla;
    t_array[1]=pw_gxdl;
    t_array[2]=pw_wgxdl+pw_gzrf2l1a+pw_gzrf2l1+pw_gzrf2l1d+pw_gzrf2+
               pw_gzrf2r1a+pw_gzrf2r1+pw_gzrf2r1d+pw_wgxdr;
    t_array[3]=pw_gxdla+pw_gxdl+pw_gxdld+pw_wgxdl+pw_gzrf2l1a+pw_gzrf2l1+
               pw_gzrf2l1d+pw_gzrf2/2.0;
    t_array[4]=(opte/2)-(necho_before_te*esp+pw_gzrf2/2+pw_gzrf2r1a+pw_gzrf2r1+
               pw_gzrf2r1d+pw_wgxdr+pw_gxdra+pw_gxdr+pw_gxdrd); /* removed a pw_wgxdr from the original code */
    t4_tmp=t_array[4];
    if (t_array[4]<0) t_array[4]=0.0;
    t_array[5]=necho_before_te*esp;  /* change num_overscan to necho_before_te to cover the full ky case */
    t_array[6] = delt * tfon;  /* this will affect t_array[4] as the interleaves shift */
    /* Calculate HOEC impact on gradient and frequency */
    if (hoecc_flag != PSD_OFF)
    {
        CalcPsdReconHoecCorr(hoecc_psd_flag, hoecc_recon_flag, psd_per_echo_corr,
                            (mux_flag?mux_slquant:opslquant), rsprot_unscaled, t_array, esp, necho_before_te, tot_etl, intleaves);

        /* set rh-CVs */
        rhhoecc = hoecc_recon_flag; /* HOCE correction flag for recon */
        rhhoec_fit_order = hoec_cal_info.fit_order; /* fit order of HOEC */
    }
    else
    {
        /* set rh-CVs */
        rhhoecc = PSD_OFF;
        rhhoec_fit_order = 0;
    }

    if (muse_flag == PSD_OFF)
	{
    	rhesp = esp; /* echo spacing */
	} 
	else 
	{
		rhesp = eesp; /* effective echo spacing accounts for interleaving */
	}
}
 
/* Functions that calculate per unit, per axis contribution to delta grad and freq */
@host HoecDeltaGradFreqCalFunctionsPredownload

/* Some arrays used in CalcPsdReconHoecCorr() and SaveHoecDebugInfo() */
float ****dwi_hoec_coef_phy = NULL;
float ****dwi_hoec_coef_phy_R = NULL;
float ****dwi_hoec_coef_log = NULL;
float **phy2log_F = NULL;

/*
   CalcPsdReconHoecCorr() takes (alpha, tau) HOEC basis coefficients and gradient timing
   (simplified to 2 DW gradients) as input to calculate correction gradients and frequencies
   for PSD as well as the correction coefficients for recon. PSD correction is done on a per
   slice per echo basis, and here we only calculate the contribution from each gradient axis
   assuming unit gradient (ie. 1 G/cm). In diffstep(), actual gradient amplitude is multiplied
   to the numbers calculated here and summed over all 3 axes to get the total contribution to
   delta gradients and frequencies. The PSD correction is similar to partially linearie the
   HOEC bases at a given slice. For recon correction, no linearization is needed as recon can
   handle arbitrary bases. The contribution of the remaining terms after PSD correction is
   calculated using the actual DW gradient amplitudes (one setting for each rep) and saved in
   a file later read by recon. Note all the calculation here takes into account of rotation as
   well, ie. logical gradients are first converted to physical coordinates to compute HOEC and
   then combined and converted back to logical gradients. Final outputs for PSD and recon are
   both in logical coordinates.

Input:
  All the input parameters of the function (see below for detailed comments)
  Global variables or arrays (their meanings are in the HoecGlobal section):
    hoec_cal_info.fit_order;
    hoec_cal_info.total_bases_per_axis;
    hoec_cal_info.num_terms[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES];
    hoec_cal_info.alpha[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES][HOEC_MAX_NUM_TERMS];
    hoec_cal_info.tau[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES][HOEC_MAX_NUM_TERMS];
    ext_corr_term[HOEC_TOTAL_NUM_AXES][HOEC_MAX_NUM_BASES];

Output:
  dwi_hoec_gcor_XonX[ileave][nslice][necho], dwi_hoec_gcor_YonX[nslice][necho], dwi_hoec_gcor_ZonX[nslice][necho],
  dwi_hoec_gcor_XonY[ileave][nslice][necho], dwi_hoec_gcor_YonY[nslice][necho], dwi_hoec_gcor_ZonY[nslice][necho],
  dwi_hoec_bcor_XonB0[ileave][nslice][necho], dwi_hoec_bcor_YonB0[nslice][necho], and dwi_hoec_bcor_ZonB0[nslice][necho],
  for PSD correction (per slice, echo and donor axis; assume unit gradient amplitude), which are applied 
  in diffstep(). Note that dwi_hoec_gcor_XonZ, dwi_hoec_gcor_YonZ, and dwi_hoec_gcor_ZonZ are also defined
  but not used in the current implementation.
  
  rhhoec_bases.hoec_coef[hoec_cal_info.total_bases_per_axis][3] for recon correction (not per slice as
  recon deals high order bases directly; only k-space center; all donors with actual amplitudes are
  calculated and summed).
*/

STATUS
CalcPsdReconHoecCorr(
    int control_psd, /* same as the cv hoecc_psd_flag */
    int control_recon, /* same as the cv hoecc_recon_flag */
    int per_echo_corr,  /* same as the cv psd_per_echo_corr */
    int numSlices,
    long rsprot[DATA_ACQ_MAX][9],  /* unscaled rotation matrices */
    float t_array[7],  /* DW gradient timing parametrers */
    int echoSpacing,
    int nechoBeforeTE,  /* this determines location of the k-space center */
    int echoTrainLength,
    int interleaves)
{
    int i, j, k, m, n, pp;    /* counter */
    float r[3][3];        /* normalized rotation matrix */
    float t1, t2, t3, t4, t5, t9, t10, d4;   /* timing parameters */
    float curEchoCenter;  /* time between start of first diffusion gradient lobe and the center of the current echo */
    float R = 0.0;            /* normalized slew-rate in 1.0/us */
    float amp, tau;     /* subroutine variables */
    float cur_dw_gx, cur_dw_gy, cur_dw_gz;  /* DW gradient amplitude in G/cm of the current pass */
    int xorder, yorder, zorder;
    int ileave_shift;
    int status;

    /*** SVBranch: HCSDM00259119  -eco mpg case:
         In eco-MPG case, the down-ramp
         and up-ramp of MPG are not the same ***/
    float R1 = 0.0; /* ramp-up SR of 1st diff, abs value */
    float R2 = 0.0; /* ramp-down SR of 1st diff, abs value */
    float R3 = 0.0; /* ramp-up SR of 2nd diff, abs value */
    float R4 = 0.0; /* ramp-down SR of 2nd diff, abs value */
    float t6 = 0.0; /* start time of plateau of 2nd diff */
    float t7 = 0.0; /* end time of plateau of 2nd diff */
    float t8 = 0.0; /* end time of 2nd diff */
    /*******************************************/        
    
    /* I. Initialization */
    /* Initialize PSD correction coefficients as zeros. The recon correction coefficients 
       rhhoec_bases.hoec_coef are already initialized as zeros in the HoecCalcCorrectionPredownload
       section before the CalcPsdReconHoecCorr() call. */
    for (pp=0; pp<interleaves; pp++)
    { 
        for (i=0; i<numSlices; i++) /* slice */
        {
            for (j=0; j<echoTrainLength; j++)  /* echo */
            {
                dwi_hoec_gcor_XonX[pp][i][j] = 0.0;
                dwi_hoec_gcor_YonX[pp][i][j] = 0.0;
                dwi_hoec_gcor_ZonX[pp][i][j] = 0.0;
                dwi_hoec_gcor_XonY[pp][i][j] = 0.0;
                dwi_hoec_gcor_YonY[pp][i][j] = 0.0;
                dwi_hoec_gcor_ZonY[pp][i][j] = 0.0;
                dwi_hoec_gcor_XonZ[pp][i][j] = 0.0;
                dwi_hoec_gcor_YonZ[pp][i][j] = 0.0;
                dwi_hoec_gcor_ZonZ[pp][i][j] = 0.0;
                dwi_hoec_bcor_XonB0[pp][i][j] = 0.0;
                dwi_hoec_bcor_YonB0[pp][i][j] = 0.0;
                dwi_hoec_bcor_ZonB0[pp][i][j] = 0.0;
            }
        }
    }
    
    /* Initialize status to be returned */
    status = SUCCESS;
        
    /* allocate memory for dwi_hoec_coef_phy[hoec_cal_info.total_bases_per_axis][HOEC_TOTAL_NUM_AXES][interleaves] [necho] */
    dwi_hoec_coef_phy = (float ****)malloc(hoec_cal_info.total_bases_per_axis*sizeof(float ***));
    if (dwi_hoec_coef_phy == NULL) 
    {
        status = FAILURE;
        goto graceful_exit;
    } 
    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
    {
        dwi_hoec_coef_phy[i] = (float ***)malloc(HOEC_TOTAL_NUM_AXES*sizeof(float **));
        if (dwi_hoec_coef_phy[i] == NULL) 
        {
            status = FAILURE;
            goto graceful_exit;
        }
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
        {
            dwi_hoec_coef_phy[i][j] = (float **)malloc(interleaves*sizeof(float *));
            if (dwi_hoec_coef_phy[i][j] == NULL)
            {
                status = FAILURE;
                goto graceful_exit;
            }
           for (pp=0; pp<interleaves; pp++)
           {
                dwi_hoec_coef_phy[i][j][pp] = (float *)malloc(echoTrainLength*sizeof(float));
                if (dwi_hoec_coef_phy[i][j][pp] == NULL) 
                {
                    status = FAILURE;
                    goto graceful_exit;
                }
            }            
        }
    }

    /* allocate memory for dwi_hoec_coef_phy_R[hoec_cal_info.total_bases_per_axis][HOEC_TOTAL_NUM_AXES][necho] */
    dwi_hoec_coef_phy_R = (float ****)malloc(hoec_cal_info.total_bases_per_axis*sizeof(float ***));
    if (dwi_hoec_coef_phy_R == NULL) 
    {
        status = FAILURE;
        goto graceful_exit;
    }     
    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
    {
        dwi_hoec_coef_phy_R[i] = (float ***)malloc(HOEC_TOTAL_NUM_AXES*sizeof(float **));
        if (dwi_hoec_coef_phy_R[i] == NULL) 
        {
            status = FAILURE;
            goto graceful_exit;
        }         
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
        {
            dwi_hoec_coef_phy_R[i][j] = (float **)malloc(interleaves*sizeof(float *));
            if (dwi_hoec_coef_phy_R[i][j] == NULL) 
            {
                status = FAILURE;
                goto graceful_exit;
            }
            for (pp=0; pp<interleaves; pp++)
            {
                dwi_hoec_coef_phy_R[i][j][pp] = (float *)malloc(echoTrainLength*sizeof(float));
                if (dwi_hoec_coef_phy_R[i][j][pp] == NULL)
                {
                    status = FAILURE;
                    goto graceful_exit;
                }
            }
               
        }
    }

    /* allocate memory for dwi_hoec_coef_log[hoec_cal_info.total_bases_per_axis][HOEC_TOTAL_NUM_AXES][interleaves][necho] */
    dwi_hoec_coef_log = (float ****)malloc(hoec_cal_info.total_bases_per_axis*sizeof(float ***));
    if (dwi_hoec_coef_log == NULL) 
    {
        status = FAILURE;
        goto graceful_exit;
    }     
    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
    {
        dwi_hoec_coef_log[i] = (float ***)malloc(HOEC_TOTAL_NUM_AXES*sizeof(float **));
        if (dwi_hoec_coef_log[i] == NULL) 
        {
            status = FAILURE;
            goto graceful_exit;
        }             
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
        {
            dwi_hoec_coef_log[i][j] = (float **)malloc(interleaves*sizeof(float *));
            if (dwi_hoec_coef_log[i][j] == NULL)
            {
                status = FAILURE;
                goto graceful_exit;
            }
            for (pp=0; pp<interleaves; pp++)
            {
                dwi_hoec_coef_log[i][j][pp] = (float *)malloc(echoTrainLength*sizeof(float));
                if (dwi_hoec_coef_log[i][j][pp] == NULL)
                {
                    status = FAILURE;
                    goto graceful_exit;
                }
            }
 
        }
    }

    /* allocate memory for phy2log_F[hoec_cal_info.total_bases_per_axis][HOEC_TOTAL_NUM_AXES] */
    phy2log_F = (float **)malloc(hoec_cal_info.total_bases_per_axis*sizeof(float *));
    if (phy2log_F == NULL) 
    {
        status = FAILURE;
        goto graceful_exit;
    }        
    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
    {
        phy2log_F[i] = (float *)malloc(hoec_cal_info.total_bases_per_axis*sizeof(float));
        if (phy2log_F[i] == NULL) 
        {
            status = FAILURE;
            goto graceful_exit;
        }        
    }

    /* Initialize dwi_hoec_coef_phy, dwi_hoec_coef_phy_R, dwi_hoec_coef_log, and phy2log_F as zeros */
    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++) /* basis */
    {
        for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)  /* donor */
        {
            for (pp=0; pp<interleaves; pp++)
            {
                for (k=0; k<echoTrainLength; k++)  /* echo */
                {
                    dwi_hoec_coef_phy[i][j][pp][k] = 0.0;
                    dwi_hoec_coef_phy_R[i][j][pp][k] = 0.0;
                    dwi_hoec_coef_log[i][j][pp][k] = 0.0;
                }
            }
        }
    }

    for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
    {
        for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
        {
            phy2log_F[i][j] = 0.0;
        }
    }

    if (control_psd != 0 || control_recon != 0)  /* when correction is needed (no matter if it's at PSD or recon or both */
    {
        /* II. Calculate the timing paramters */
        /***  SVBranch: HCSDM00259119  eco mpg case:
             In eco-MPG case, the down-ramp
             and up-ramp of MPG are not the
             same ***/
        if (mpg_opt_flag) 
        {
            t1 = t_array[0];         /* all time units are in us */
            t2 = t_array[0] + t_array[1];
            t3 = t_array[0] + t_array[1] + (float)pw_gxdld;
            t4 = t_array[3];
            t5 = t3 + t_array[2];
            t6 = t5 + (float)pw_gxdra;
            t7 = t6 + (float)pw_gxdr;
            t8 = t7 + (float)pw_gxdrd;
            t9= 2*t3 + t_array[2] + t_array[4];
            d4= t_array[4];
            t10 = t9+t_array[5];
            ileave_shift = t_array[6];
            R1 = 1.0 / t1;
            R2 = 1.0 / (t3-t2);
            R3 = 1.0 / (t6-t5); 
            R4 = 1.0 / (t8-t7); 
        }
        else /* original case */
        {
            t1= t_array[0];         /* all time units are in us */
            t2= t_array[0]+t_array[1];
            t3= 2*t_array[0]+t_array[1];
            t4= t_array[3];
            t5= t3+t_array[2];
            t9= 2*t3+t_array[2]+t_array[4];
            d4= t_array[4];
            t10 = t9+t_array[5];
            ileave_shift = t_array[6];
            R = 1.0/t1;         /* slew rate in 1.0/us */
        }

        /* III. Compute the E(t) matrix (hoec_cal_info.total_bases_per_axis-by-3-by-necho), i.e. fill in
                the dwi_hoec_coef_phy array */
        for (i=0; i<HOEC_TOTAL_NUM_AXES; i++) /* donor */
        {
            for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)  /* basis */
            {
                for (m=0; m<hoec_cal_info.num_terms[i][j]; m++)  /* term */
                {
                    amp = hoec_cal_info.alpha[i][j][m]*alpha_scale[i][j][m];  /* alpha_scale is 1 for auto mode,
                                                                                 and can be 0 for some terms in manual mode */
                    tau = hoec_cal_info.tau[i][j][m];
                    for (pp=0; pp<interleaves; pp++)
                    {
                        for (n=0; n<echoTrainLength; n++)  /* echo */
                        {
                            if(n < iref_etl) continue; /* interref echoes played out before diffusion gradient */
    
                            if (per_echo_corr == 0)  /* same compensation for all echoes (DC model) */
                            {
                                curEchoCenter = (t10+(pp*ileave_shift))-(float)(echoSpacing)/2.0;
                            }
                            else  /* per echo compensation (piece-wise constant model) */
                            {
                                curEchoCenter = (t10+(pp*ileave_shift))-(float)(echoSpacing)*((float)(nechoBeforeTE-1-n)+0.5);
                            }

                            /* Note that dwi_hoec_coef_phy means the correction coefficients (i.e. these
                               coefficients, when added to the nominal gradient/frequency, will correct
                               the HOEC error). There is a difference in sign convention between the product
                               and ATD prototype HOEC cal tool, and hoec_cal_data_sign is used to adjust for
                               such difference (1.0 for product, -1.0 for the ATD prototype; default to 1.0) */
                            if (mpg_opt_flag) /*  SVBranch: HCSDM00259119  eco mpg case */
                            {
                                dwi_hoec_coef_phy[j][i][pp][n] = dwi_hoec_coef_phy[j][i][pp][n] + 
                                                         hoec_cal_data_sign *
                                                         g_error_kcenter2(R1, R2, 
                                                                          R3, R4, 
                                                                          amp, tau, 
                                                                          t1, t2, t3, 
                                                                          t5, t6, t7, 
                                                                          t8, curEchoCenter);                            
                            }
                            else /* original case */
                            {
                                dwi_hoec_coef_phy[j][i][pp][n] = dwi_hoec_coef_phy[j][i][pp][n] + 
                                                         hoec_cal_data_sign *
                                                         g_error_kcenter(R, amp, tau, 
                                                                         t1, t2, t5, 
                                                                         curEchoCenter);
                            }
                        }  /* end for echo */
                    } /* end for interleave */
                }  /* end for term */
            }  /* end for basis */
        }  /* end for donor */

        /* IV. Obtain normalized rotation matrix R */
#ifdef SIM
        /* just for test purpose */
        r[0][0] = r[1][1] = r[2][2] = 1.0;
        r[0][1] = r[0][2] = r[1][0] = r[1][2] = r[2][0] = r[2][1] = 1.0;
#else   /* Note: multigroup acquisition is locked out for HOEC correction */
        r[0][0] = (float)rsprot[0][0]/(float)max_pg_iamp;
        r[0][1] = (float)rsprot[0][1]/(float)max_pg_iamp;
        r[0][2] = (float)rsprot[0][2]/(float)max_pg_iamp;
        r[1][0] = (float)rsprot[0][3]/(float)max_pg_iamp;
        r[1][1] = (float)rsprot[0][4]/(float)max_pg_iamp;
        r[1][2] = (float)rsprot[0][5]/(float)max_pg_iamp;
        r[2][0] = (float)rsprot[0][6]/(float)max_pg_iamp;
        r[2][1] = (float)rsprot[0][7]/(float)max_pg_iamp;
        r[2][2] = (float)rsprot[0][8]/(float)max_pg_iamp;
#endif

        /* V. Compute the F matrix (phy to log matrix, hoec_cal_info.total_bases_per_axis-by-hoec_cal_info.total_bases_per_axis,
               actual form given by the output "phy2LogStrNonZeroOneCol" in GetPolyPhy2LogMat.m. Here we use a recursive formula
               to fill in the F matrix) */
        {
            int matPos;
            int numTerms;
            int orderIndex, termIndex;

            matPos = 0;
            for (orderIndex=0; orderIndex<=hoec_cal_info.fit_order; orderIndex++)
            {
                numTerms = (orderIndex+1)*(orderIndex+2)/2;
                for (termIndex=0; termIndex<numTerms; termIndex++)
                {
                    convertPhy2Log(phy2log_F[matPos+termIndex], termIndex+matPos, orderIndex, r);
                }
                matPos += numTerms;
            }
        }

        /* VI. Compute E(t)*R */
        for (pp=0; pp<interleaves; pp++)
        {
            for (n=0; n<echoTrainLength; n++)
            {
                for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
                {
                    for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
                    {

                        for (k=0; k<HOEC_TOTAL_NUM_AXES; k++)
                        {
                            dwi_hoec_coef_phy_R[i][j][pp][n] += dwi_hoec_coef_phy[i][k][pp][n]*r[k][j];
                        }
                    }
                }
            }
        }

        /* VII. Compute D = transpose(F)*(E(t)*R), result is hoec_cal_info.total_bases_per_axis-by-3 matrix */
        for (pp=0; pp<interleaves; pp++)
        {
            for (n=0; n<echoTrainLength; n++)  /* echo */
            {
                for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)  /* basis */
                {
                    for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)  /* donor */
                    {
                        for (k=0; k<hoec_cal_info.total_bases_per_axis; k++)
                        {
                            dwi_hoec_coef_log[i][j][pp][n] += phy2log_F[k][i]*dwi_hoec_coef_phy_R[k][j][pp][n];
                        }
                    }
                }
            }
        }
        /* VIII. Split dwi_hoec_coef_log into PSD corr, recon corr, and no corr (in some hoec_comp mode)
           coefficients according to basis_correction_mode set up in the previous section.
           dwi_hoec_coef_log[nbases][ndonors][nechoes] is the input array. For those bases corrected
           in PSD, we evaluate them at their slice location and add bases that are linearized to Gx
           together (same for Gy, B0), and finally get dwi_hoec_bcor_XonB0, dwi_hoec_bcor_YonB0, 
           dwi_hoec_bcor_ZonB0 for B0 term, dwi_hoec_gcor_XonX, dwi_hoec_gcor_YonX, dwi_hoec_gcor_ZonX for Gx, 
           and dwi_hoec_gcor_XonY, dwi_hoec_gcor_YonY, dwi_hoec_gcor_ZonY for Gy. For bases corrected in recon, 
           we directly take the high order bases coefficients dwi_hoec_coef_log because the linearization
           is done in recon processing and not here. The only difference is that we only use the echo
           at the k-space center. The end result for recon is rhhoec_bases.hoec_coef[nbases][ndonors],
           which will be passed to recon for processing later. Note all the calculate here assumes 1G/cm
           driver gradient amplitude, so the actual DW gradient amplitudes need to be multiplied to get
           the true eddy current amplitude. For PSD correction, this is done in diffstep(), where the
           instruction amplitude ia_incdifx of the DW Gx amplitude incdifx is multiplied to the proper 
           dwi_hoec_gcor before adding to the ideal instruction amplitude (same for Gy, B0). For recon
           correction, this is done by saving the DW X, Y, Z gradient amplitude components for each rep to
           rhdiffusion_grad_amp and multiplying them to rhhoec_bases.hoec_coef in recon processing */

        for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)  /* bases */
        {
            xorder = hoec_cal_info.termIndex2xyzOrderMapping[0][i];
            yorder = hoec_cal_info.termIndex2xyzOrderMapping[1][i];
            zorder = hoec_cal_info.termIndex2xyzOrderMapping[2][i];

            for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)  /* donor */
            {
                switch (ext_corr_term[j][i])
                {
                    case 0:  /* no correction */
                        break;

                    case 1:  /* PSD correction: per-slice linearization, per echo */
                        for (pp=0; pp<interleaves; pp++)
                        {
                            for (k=0; k<numSlices; k++)  /* slice */
                            {
                                for (n=0; n<echoTrainLength; n++)  /* echo */
                                {
                                    if(n < iref_etl) continue; /* interref echoes played before diffusion gradients */

                                    if (xorder==0 && yorder==0) /* donor  (X, Y, Z) on Z and B0 */
                                    {
                                        switch(j)
                                        {
                                            case 0:
                                                dwi_hoec_bcor_XonB0[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);

                                                if (zorder==0) break;
                                                dwi_hoec_gcor_XonZ[pp][k][n] +=
                                                         zorder*dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder-1);

                                                break;
                                            case 1:
                                                dwi_hoec_bcor_YonB0[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);

                                                if (zorder==0) break;
                                                dwi_hoec_gcor_YonZ[pp][k][n] +=
                                                        zorder*dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder-1);

                                                break;
                                            case 2:
                                                dwi_hoec_bcor_ZonB0[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);

                                                if (zorder==0) break;
                                                dwi_hoec_gcor_ZonZ[pp][k][n] +=
                                                        zorder*dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder-1);

                                                break;
                                        }
                                    }
                                    else if (xorder==1 && yorder==0) /* donor (X, Y, Z) on logical X */
                                    {
                                        switch(j)
                                        {
                                            case 0:
                                                dwi_hoec_gcor_XonX[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                            case 1:
                                                dwi_hoec_gcor_YonX[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                            case 2:
                                                dwi_hoec_gcor_ZonX[pp][k][n] +=
                                                         dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                        }
                                    }
                                    else if (xorder==0 && yorder==1) /* donor (X, Y, Z) on logical Y */
                                    {
                                        switch(j)
                                        {
                                            case 0:
                                                dwi_hoec_gcor_XonY[pp][k][n] += 
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                            case 1:
                                                dwi_hoec_gcor_YonY[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                            case 2:
                                                dwi_hoec_gcor_ZonY[pp][k][n] +=
                                                        dwi_hoec_coef_log[i][j][pp][n]*pow(rsp_info[k].rsptloc/10.0, zorder);
                                                break;
                                        }
                                    }
                                }  /* end for n, echo */
                            }  /* end for k, slice */
                        }  /* end for pp, interleave */

                        break;

                    case 2:  /* recon correction */
                    /* recon only uses the coef at the center echo, whose index is nechoBeforeTE-1.
                       Note that for PSD we calculate the correction amplitudes and not the offset amplitudes.
                       However, recon correction assumes the input to be the offset amplitudes, so we need
                       the extra minus sign here.     */

                        rhhoec_bases.hoec_coef[i][j] = -dwi_hoec_coef_log[i][j][interleaves/2][nechoBeforeTE-1];
                        break;

                    default:
                        break;

                }  /* end switch (basis_correction_mode[j][i]) */

            }  /* end for j, donor */

            rhhoec_bases.hoec_xorder[i] = xorder;
            rhhoec_bases.hoec_yorder[i] = yorder;
            rhhoec_bases.hoec_zorder[i] = zorder;
        }  /* end for i, basis */

        /* IX. Calculate diffusion gradient amplitudes */
        if (inversRspRot(inversRR, rsprot[0]) == FAILURE)  /* HOECC needs inversRR in the getDiffGradAmp call*/
        {
            epic_error(use_ermes,"inversRspRot failed", EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," inversRspRot");
            status = FAILURE;
            goto graceful_exit;        
        }   
        
        for (i=0; i<pass_reps; i++)
        {
            if (opdiffuse == PSD_ON && tensor_flag == PSD_OFF)  /* non tensor DWI */
            {
                getDiffGradAmp(&cur_dw_gx, &cur_dw_gy, &cur_dw_gz, i - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
            }
            else if (tensor_flag == PSD_ON)  /* DTI */
            {
                if (ref_in_scan_flag && i==0) /* ref */
                {
                    cur_dw_gx = 0;
                    cur_dw_gy = 0;
                    cur_dw_gz = 0;
                }
                else if (rpg_in_scan_flag && (i<(ref_in_scan_flag ? 1:0)+rpg_in_scan_num))
                {
                    cur_dw_gx = 0;
                    cur_dw_gy = 0;
                    cur_dw_gz = 0;
                }
                else
                {
                    int pass_offset = (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag?rpg_in_scan_num:0);
                    cur_dw_gx = incdifx*TENSOR_HOST[0][i-pass_offset];
                    cur_dw_gy = incdify*TENSOR_HOST[1][i-pass_offset];
                    cur_dw_gz = incdifz*TENSOR_HOST[2][i-pass_offset];
                }
            }

            rhdiffusion_grad_amp[i][0] = cur_dw_gx;
            rhdiffusion_grad_amp[i][1] = cur_dw_gy;
            rhdiffusion_grad_amp[i][2] = cur_dw_gz;
        }

        /* X. Save intermediate results for debug purpose */
        SaveHoecDebugInfo(control_psd, control_recon, numSlices, t_array, r);

    }  /* end if control_psd or control_recon flags */

    /* Free allocated memory */
    graceful_exit:
    if (dwi_hoec_coef_phy != NULL)
    {
        for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
        {
            if (dwi_hoec_coef_phy[i] != NULL)
            {            
                for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
                {
                    if (dwi_hoec_coef_phy[i][j] != NULL)
                    {
                        for(pp=0; pp<interleaves; pp++)
                        {
                            if (dwi_hoec_coef_phy[i][j][pp] != NULL)
                            {
                                free(dwi_hoec_coef_phy[i][j][pp]);
                                dwi_hoec_coef_phy[i][j][pp] = NULL;
                            }
                        }
                        free(dwi_hoec_coef_phy[i][j]);
                        dwi_hoec_coef_phy[i][j] = NULL;
                    }
                } 
                free(dwi_hoec_coef_phy[i]);
                dwi_hoec_coef_phy[i] = NULL;
            }
        }       
        
        free(dwi_hoec_coef_phy);
        dwi_hoec_coef_phy = NULL;        
    }

    if (dwi_hoec_coef_phy_R != NULL)
    {
        for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
        {
            if (dwi_hoec_coef_phy_R[i] != NULL)
            {            
                for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
                {
                    if (dwi_hoec_coef_phy_R[i][j] != NULL)
                    {
                        for(pp=0; pp<interleaves; pp++)
                        {
                            if (dwi_hoec_coef_phy_R[i][j][pp] != NULL)
                            {
                                free(dwi_hoec_coef_phy_R[i][j][pp]);
                                dwi_hoec_coef_phy_R[i][j][pp] = NULL;
                            }
                        }

                        free(dwi_hoec_coef_phy_R[i][j]);
                        dwi_hoec_coef_phy_R[i][j] = NULL;
                    }
                }
                free(dwi_hoec_coef_phy_R[i]);
                dwi_hoec_coef_phy_R[i] = NULL;
            }
        }       
        
        free(dwi_hoec_coef_phy_R);
        dwi_hoec_coef_phy_R = NULL;        
    }
    
    if (dwi_hoec_coef_log != NULL)
    {
        for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
        {
            if (dwi_hoec_coef_log[i] != NULL)
            {            
                for (j=0; j<HOEC_TOTAL_NUM_AXES; j++)
                {
                    if (dwi_hoec_coef_log[i][j] != NULL)
                    {
                        for(pp=0; pp<interleaves; pp++)
                        {
                            if (dwi_hoec_coef_log[i][j][pp] != NULL)
                            {
                                free(dwi_hoec_coef_log[i][j][pp]);
                                dwi_hoec_coef_log[i][j][pp] = NULL;
                            }
                        }
                        free(dwi_hoec_coef_log[i][j]);
                        dwi_hoec_coef_log[i][j] = NULL;
                    }
                }
                free(dwi_hoec_coef_log[i]);
                dwi_hoec_coef_log[i] = NULL;
            }
        }       
        free(dwi_hoec_coef_log);
        dwi_hoec_coef_log = NULL;        
    }                       
    
    if (phy2log_F != NULL)
    {
        for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
        {
            if (phy2log_F[i] != NULL)
            {
                free(phy2log_F[i]);
                phy2log_F[i] = NULL;
            }
        }
        
        free(phy2log_F);
        phy2log_F = NULL;
    }
    
    if (status == FAILURE)
    {
        printf("CalcPsdReconHoecCorr() failed.\n");
    }
    
    return status;
}  /* end of the CalcPsdReconHoecCorr routine */

void convertPhy2Log(float * output, int logTermIndex, int orderIndex, float rotm[3][3])
{
    int i, j, k;
    int nx, ny, nz;
    int numTerms_x, numTerms_y, numTerms_z;

    float xCoef[HOEC_MAX_BASES_PER_ORDER]; /* coeffients of trinomial expansion for x axis */
    float yCoef[HOEC_MAX_BASES_PER_ORDER]; /* coeffients of trinomial expansion for y axis */
    float zCoef[HOEC_MAX_BASES_PER_ORDER]; /* coeffients of trinomial expansion for z axis */
    int xIndex[3][HOEC_MAX_BASES_PER_ORDER]; /* base index of trinomial expansion for x axis */
    int yIndex[3][HOEC_MAX_BASES_PER_ORDER]; /* base index of trinomial expansion for y axis */
    int zIndex[3][HOEC_MAX_BASES_PER_ORDER]; /* base index of trinomial expansion for z axis */

    nx = hoec_cal_info.termIndex2xyzOrderMapping[0][logTermIndex];
    ny = hoec_cal_info.termIndex2xyzOrderMapping[1][logTermIndex];
    nz = hoec_cal_info.termIndex2xyzOrderMapping[2][logTermIndex];

    numTerms_x = (nx+1)*(nx+2)/2;
    numTerms_y = (ny+1)*(ny+2)/2;
    numTerms_z = (nz+1)*(nz+2)/2;

    for (i=0; i<numTerms_x; i++)
    {
        xCoef[i] = 0;
    }
    for (i=0; i<numTerms_y; i++)
    {
        yCoef[i] = 0;
    }
    for (i=0; i<numTerms_z; i++)
    {
        zCoef[i] = 0;
    }
    
    expandTrinomial(xCoef, xIndex, nx, rotm[0]);
    expandTrinomial(yCoef, yIndex, ny, rotm[1]);
    expandTrinomial(zCoef, zIndex, nz, rotm[2]);

    for (i=0; i<numTerms_x; i++)
        for (j=0; j<numTerms_y; j++)
            for (k=0; k<numTerms_z; k++)
            {
                nx = xIndex[0][i]+yIndex[0][j]+zIndex[0][k];
                ny = xIndex[1][i]+yIndex[1][j]+zIndex[1][k];
                nz = xIndex[2][i]+yIndex[2][j]+zIndex[2][k];

                output[hoec_cal_info.xyzOrder2termIndexMapping[nx][ny][nz]] += xCoef[i]*yCoef[j]*zCoef[k];
            }
}

void expandTrinomial(float output[HOEC_MAX_BASES_PER_ORDER], int index[3][HOEC_MAX_BASES_PER_ORDER], int num, float rotm[3])
{
    int i, j;
    int cc1, cc2;
    int count;
    
    count = 0;
    for (i=0; i<=num; i++)
    {
        cc1 = fractorial(num)/(fractorial(num-i)*fractorial(i));
        for (j=0; j<=i; j++)
        {
            cc2 = fractorial(i)/(fractorial(i-j)*fractorial(j));
            index[0][count] = num-i;
            index[1][count] = i-j;
            index[2][count] = j;
            output[count] = cc1*pow(rotm[0], num-i)*cc2*pow(rotm[1], i-j)*pow(rotm[2], j);
            count++;
        }
    }
}

int fractorial(int n)
{
    if(n<=0) return 1;
    return n*fractorial(n-1);
}

/* g_error_kcenter: compute the HOEC amplitude (normalized to donar gradient amplitude at k-space center)
   Assume the output is a, then G*a*basisFunction would give the EC magnitude field. a is dimensionless.
   This function assumes a singla spin echo model with two diffusion gradients. It approximately equals
   a more accurate calculation using gradient cornder point file and convolution */

float g_error_kcenter(float R,
                      float amp,
                      float tau,
                      float t1,
                      float t2,
                      float t5,
                      float t10)
{
    double error_a, error_b, error_c, error_d;

    error_a = 0.01*(double)R*(double)(amp*tau);  /* 0.01 comes from the percentage expression of amp */
    error_b = 1-exp((double)(t1/tau));
    error_c = 1-exp((double)(t2/tau));
    error_d = (1+exp((double)(t5/tau)))*exp(-(double)(t10/tau));

    return((float)(error_a*error_b*error_c*error_d));
}

/*  SVBranch: HCSDM00259119  eco mpg:
   g_error_kcenter2: computes the HOEC normalized amplitude in eco-MPG 
                     case, where diff grad has multiple slew rate; */
float g_error_kcenter2(float R1,
                       float R2,
                       float R3,
                       float R4,
                       float amp,
                       float tau,
                       float t1, float t2, 
                       float t3, float t5, 
                       float t6, float t7, 
                       float t8, float t10)
{
    /* R1: abs slew rate for ramp-up of left diff grad;
       R2: abs slew rate for ramp-down of left diff grad;
       R3: abs slew rate for ramp-up of right diff grad;
       R4: abs slew rate for ramp-down of right diff grad; */
       
    float error_a, error_b, error_c, error_d, error_sum;
    
    amp = amp * 0.01; /* 0.01 comes from the percentage expression of amp */
    
    error_a = -R1 * amp * tau * ( exp((t1-t10)/tau) - exp(-t10/tau) );   
    error_b =  R2 * amp * tau * ( exp((t3-t10)/tau) - exp((t2-t10)/tau) );
    error_c = -R3 * amp * tau * ( exp((t6-t10)/tau) - exp((t5-t10)/tau) );
    error_d =  R4 * amp * tau * ( exp((t8-t10)/tau) - exp((t7-t10)/tau) );
    
    /* error terms standard for different meanings here,
       comparing to those in g_error_kcenter(). So plus
       is used here, not multiply. The difference comes
       from the fact that R1, R2, R3, and R4 may be not
       identical in this function */
    error_sum = error_a + error_b + error_c + error_d;
    
    return error_sum;
}

/* SaveHoecDebugInfo: Save intermediate results for debug purposes.
                      Two files are saved:
                      HOEC_DEBUG_FILE contains the main debug information, including
                      the rotation matrices, HOEC coefficients, HOEC PSD/recon correction schedule etc.
                      HOEC_COEF_RECON_FILE contains recon specific information, which is primarily
                      used for debugging recon code, and is only available when hoecc_recon_flag is 1. */

void SaveHoecDebugInfo(int control_psd, int control_recon, int numSlices, float t_array[7], float r[3][3])
{
    FILE *dwi_outfile;
    int i,j, k;
    int xorder, yorder, zorder;
    float start_val, inc_val, end_val;  /* some variables for defining X, Y, and Z grids */
    char basisStr[32], tempStr[32], corrScheduleStr[32], linearizedAxisInPsdStr[32], extraZExpInPsdStr[10];

    /* HOEC_COEF_RECON_FILE file: saves recon specific information */
    if (control_recon == 1 && hoecc_debug == PSD_ON)
    {
        dwi_outfile = fopen(HOEC_COEF_RECON_FILE, "w");

        if (dwi_outfile != NULL)
        {
            /* determine if recon based distortion is needed */
            fprintf(dwi_outfile, "Section 1: Flag for recon based distortion correction (1 = on, 0 = off)\n");
            fprintf(dwi_outfile, "1\n");
            fprintf(dwi_outfile, "\n");
            
            /* stores parameters which recon need for distortion correction */
            fprintf(dwi_outfile, "Section 2: Parameters that are related to recon processing\n");
            if (ky_dir == 2)
            {
                fprintf(dwi_outfile, "1     // acquisition mode (1=bottom-up 0=top-down)\n");
            }
            else
            {
                fprintf(dwi_outfile, "0     // acquisition mode (1=bottom-up 0=top-down)\n");
            }
            fprintf(dwi_outfile, "%d     // fit order\n", hoec_cal_info.fit_order);
            fprintf(dwi_outfile, "%d     // hoecc_flag (0=off, 1=on, 2=manual, 3=recon for all)\n", hoecc_flag);
            fprintf(dwi_outfile, "%d     // ASSET acceleration\n", (int)(ceil(1.0/asset_factor)));
            fprintf(dwi_outfile, "%.1f  // fov in cm\n", opfov*opphasefov/10.0);
            fprintf(dwi_outfile, "%d   // echo spacing in us\n", esp);
            fprintf(dwi_outfile, "%d     // patient entry (1=head first, 2=feet first)\n", opentry);
            fprintf(dwi_outfile, "%d     // patient position (1=supine, 2=prone, 3=left decub, 4=right decub)\n", oppos);
            fprintf(dwi_outfile, "%d     // scan plane (1=ax, 2=sag, 3=cor, 4=obl, 5=3plane)\n", opplane);
            fprintf(dwi_outfile, "%d     // most like plane for obliques (1=ax, 2=sag, 3=cor)\n", opobplane);
            fprintf(dwi_outfile, "%d     // swap phase and frequency (0=no swap, 1=swap)\n", opspf);
            fprintf(dwi_outfile, "%d     // hoec_recon_debug (1 = save intermediate recon result, 0 = do not save)\n", 0);
            fprintf(dwi_outfile, "%d     // recon_debug_slice_index (slice index to save recon result)\n", 0);
            fprintf(dwi_outfile, "\n");
            
            fprintf(dwi_outfile, "Section 3: X, Y, Z DW gradient vector in Gauss/cm\n");  /* HOEC coefficients at k-space center */
            fprintf(dwi_outfile, "%d     // Number of reps (T2, DW Z, X, Y etc.) \n", pass_reps);
            
            for (i=0; i<pass_reps; i++) /* Each row is a length-3 vector representing X, Y, and Z DW
                                           gradients for each pass */
            {
                fprintf(dwi_outfile, "%7.5f  \t  %7.5f  \t  %7.5f\n", rhdiffusion_grad_amp[i][0],
                        rhdiffusion_grad_amp[i][1], rhdiffusion_grad_amp[i][2]);
            }   /* end for*/
            fprintf(dwi_outfile, "\n");
            
            /* HOEC coefficients at k-space center */
            fprintf(dwi_outfile, "Section 4: HOEC coefficients at TE for recon based correction (logical axes)\n");
            for (i=0; i<3; i++) /* donor axes */
            {
                for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                {
                    xorder = hoec_cal_info.termIndex2xyzOrderMapping[0][j];
                    yorder = hoec_cal_info.termIndex2xyzOrderMapping[1][j];
                    zorder = hoec_cal_info.termIndex2xyzOrderMapping[2][j];
            
                    strcpy(basisStr, "");    /* start with empty string */
            
                    switch (xorder)  /* add x component */
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "x"); break;
                        default: sprintf(tempStr, "x%d", xorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    switch (yorder)  /* add y component */
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "y"); break;
                        default: sprintf(tempStr, "y%d", yorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    switch (zorder)  /* add z component */
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "z"); break;
                        default: sprintf(tempStr, "z%d", zorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    if (strcmp(basisStr, "")==0)  /* set the basis name to "1" if there is no x,y, or z component */
                    {
                        strcpy(basisStr, "1");
                    }
            
                    if (j==0)
                    {
                        switch (i)
                        {
                            case 0:
                                fprintf(dwi_outfile, "%.4e   // %s; starting row of donor X\n",
                                        rhhoec_bases.hoec_coef[j][i], basisStr);
                                break;
                            case 1:
                                fprintf(dwi_outfile, "%.4e   // %s; starting row of donor Y\n",
                                        rhhoec_bases.hoec_coef[j][i], basisStr);
                                break;
                            case 2:
                                fprintf(dwi_outfile, "%.4e   // %s; starting row of donor Z\n",
                                        rhhoec_bases.hoec_coef[j][i], basisStr);
                                break;
                        }
                    }
                    else
                    {
                        fprintf(dwi_outfile, "%.4e   // %s\n", rhhoec_bases.hoec_coef[j][i], basisStr);
                    }
                } /* end for j*/
            }  /* end for i*/
            fprintf(dwi_outfile, "\n");
            
            /* save logical X, Y, Z coordinates so that recon based post processing can use */
            fprintf(dwi_outfile, "Section 5: Logical X, Y, Z coordinates\n");
            start_val = (float)(rhrcxres/2)*get_act_freq_fov()/(10.0*(float)rhrcxres)+rsp_info[0].rsprloc/10.0-
                        (float)(rhrcxres-1)*get_act_freq_fov()/(10.0*(float)rhrcxres);  /* 10.0 is to convert mm to cm */
            inc_val = opfov/(10.0*(float)rhrcxres);
            end_val = start_val + ((float)(rhrcxres-1))*inc_val;
            fprintf(dwi_outfile, "%d          // Number of pixels in X axis\n", rhrcxres); /* X axis */
            fprintf(dwi_outfile, "%.4f   // Start X loc\n", start_val);
            fprintf(dwi_outfile, "%.4f   // End X loc\n", end_val);
            
            start_val = (float)(rhrcyres/2)*get_act_phase_fov()/(10.0*(float)rhrcyres)+rsp_info[0].rspphasoff/10.0;
            inc_val = -get_act_phase_fov()/(10.0*(float)rhrcyres);
            end_val = start_val + ((float)(rhrcyres-1))*inc_val;
            fprintf(dwi_outfile, "%d          // Number of pixels in Y axis\n", rhrcyres); /* Y axis */
            fprintf(dwi_outfile, "%.4f   // Start Y loc\n", start_val);
            fprintf(dwi_outfile, "%.4f   // End Y loc\n", end_val);
            
            if (rsp_info[0].rsptloc > 0)
            {
                start_val = (float)(opslquant-1)*(opslthick+opslspace)/(10.0*2);
                inc_val = -(opslthick+opslspace)/10.0;
            }
            else
            {
                start_val = -(float)(opslquant-1)*(opslthick+opslspace)/(10.0*2);
                inc_val = (opslthick+opslspace)/10.0;
            }
            end_val = start_val + ((float)(opslquant-1))*inc_val;
            fprintf(dwi_outfile, "%d          // Number of slices in Z axis\n", opslquant);  /* Z axis */
            fprintf(dwi_outfile, "%.4f   // Start Z loc\n", start_val);
            fprintf(dwi_outfile, "%.4f   // End Z loc\n", end_val);
            
            fclose(dwi_outfile); 
        }
        
        else
        {        	
            printf("Failed to open %s.\n", HOEC_COEF_RECON_FILE);
        }        
    }
    
    /* HOEC_DEBUG_FILE: save intermediate matrices that convert physical to logical axes, rotation matrix,
                        and psd/recon corr schedule*/
    if (hoecc_debug == PSD_ON)
    {
        dwi_outfile = fopen(HOEC_DEBUG_FILE, "a");  /* phy to log matrices*/
 
        if (dwi_outfile != NULL)
        {
            fprintf(dwi_outfile, "\nNormalized rotation matrix:\n");
            fprintf(dwi_outfile, "%5.2f %5.2f %5.2f\n", r[0][0], r[0][1], r[0][2]);
            fprintf(dwi_outfile, "%5.2f %5.2f %5.2f\n", r[1][0], r[1][1], r[1][2]);
            fprintf(dwi_outfile, "%5.2f %5.2f %5.2f\n", r[2][0], r[2][1], r[2][2]);
            fprintf(dwi_outfile, "\n\n");
            
            fprintf(dwi_outfile, "F Matrix (physical to logical conversion matrix)\n");
            for (k=0; k<hoec_cal_info.total_bases_per_axis; k++)
            {
                for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
                {
                    fprintf(dwi_outfile, "%5.2f ", phy2log_F[k][i]);
                }
                fprintf(dwi_outfile, "\n");
            }
            fprintf(dwi_outfile, "\n\n");

            fprintf(dwi_outfile, "E Matrix - Interleave %d  Echo %d:\n", psd_ileave_for_debug, psd_echo_for_debug);
            for (i=0; i<hoec_cal_info.total_bases_per_axis; i++) /* basis */
            {
                fprintf(dwi_outfile, "%2d  %12.3e %12.3e %12.3e\n", i,
                    dwi_hoec_coef_phy[i][0][psd_ileave_for_debug][psd_echo_for_debug], 
                    dwi_hoec_coef_phy[i][1][psd_ileave_for_debug][psd_echo_for_debug],
                    dwi_hoec_coef_phy[i][2][psd_ileave_for_debug][psd_echo_for_debug]);
            }
            fprintf(dwi_outfile, "\n\n");

            fprintf(dwi_outfile, "E*r Matrix - - Interleave %d Echo %d:\n", psd_ileave_for_debug,psd_echo_for_debug);
            for (i=0; i<hoec_cal_info.total_bases_per_axis; i++) /* basis */
            {
                fprintf(dwi_outfile, "%2d  %12.3e %12.3e %12.3e\n", i,
                        dwi_hoec_coef_phy_R[i][0][psd_ileave_for_debug][psd_echo_for_debug], 
                        dwi_hoec_coef_phy_R[i][1][psd_ileave_for_debug][psd_echo_for_debug],
                        dwi_hoec_coef_phy_R[i][2][psd_ileave_for_debug][psd_echo_for_debug]);
            }
            fprintf(dwi_outfile, "\n\n");
            
            fprintf(dwi_outfile, "D Matrix - Interleave %d  Echo %d:\n", psd_ileave_for_debug,psd_echo_for_debug);
            for (i=0; i<hoec_cal_info.total_bases_per_axis; i++) /* basis */
            {
                fprintf(dwi_outfile, "%2d  %12.3e %12.3e %12.3e\n", i,
                        dwi_hoec_coef_log[i][0][psd_ileave_for_debug][psd_echo_for_debug], 
                        dwi_hoec_coef_log[i][1][psd_ileave_for_debug][psd_echo_for_debug],
                        dwi_hoec_coef_log[i][2][psd_ileave_for_debug][psd_echo_for_debug]);
            }
            fprintf(dwi_outfile, "\n\n");
            
            fprintf(dwi_outfile, "time array elements:\n\n");
            for (i=0; i<7; i++)
            {
                fprintf(dwi_outfile, "t[%d]=%d\n", i, (int)t_array[i]);
            }
            
            fprintf(dwi_outfile, "\nHOEC control_psd = %d\n", control_psd);
            fprintf(dwi_outfile, "HOEC control_recon = %d\n", control_recon);
            
            fprintf(dwi_outfile, "\nLamda matrix for gradient and B0 (PSD) - Ileave  %d Echo %d:\n", psd_ileave_for_debug,psd_echo_for_debug);
            for (i=0; i<numSlices; i++) /* note dwi_hoec_gcor is the same for all echoes when per_echo_corr = 0,
                                           which enables us to use the same code below for per_echo_corr = 1 and 0 */
            {
                fprintf(dwi_outfile, "Slice %d:\n", i);
                fprintf(dwi_outfile, "onX =%12.3e XonY =%12.3e XonZ =%12.3e\n", dwi_hoec_gcor_XonX[psd_ileave_for_debug][i][psd_echo_for_debug],
                        dwi_hoec_gcor_XonY[psd_ileave_for_debug][i][psd_echo_for_debug], dwi_hoec_gcor_XonZ[psd_ileave_for_debug][i][psd_echo_for_debug]);
                fprintf(dwi_outfile, "YonX =%12.3e YonY =%12.3e YonZ =%12.3e\n", dwi_hoec_gcor_YonX[psd_ileave_for_debug][i][psd_echo_for_debug],
                        dwi_hoec_gcor_YonY[psd_ileave_for_debug][i][psd_echo_for_debug], dwi_hoec_gcor_YonZ[psd_ileave_for_debug][i][psd_echo_for_debug]);
                fprintf(dwi_outfile, "ZonX =%12.3e ZonY =%12.3e ZonZ =%12.3e\n", dwi_hoec_gcor_ZonX[psd_ileave_for_debug][i][psd_echo_for_debug],
                        dwi_hoec_gcor_ZonY[psd_ileave_for_debug][i][psd_echo_for_debug], dwi_hoec_gcor_ZonZ[psd_ileave_for_debug][i][psd_echo_for_debug]);
                fprintf(dwi_outfile, "XonB0=%12.3e YonB0=%12.3e ZonB0=%12.3e\n", dwi_hoec_bcor_XonB0[psd_ileave_for_debug][i][psd_echo_for_debug],
                        dwi_hoec_bcor_YonB0[psd_ileave_for_debug][i][psd_echo_for_debug], dwi_hoec_bcor_ZonB0[psd_ileave_for_debug][i][psd_echo_for_debug]);
            }
            
            fprintf(dwi_outfile, "\n\nLamda matrix for all bases (recon):\n");
            for (i=0; i<hoec_cal_info.total_bases_per_axis; i++)
            {
                fprintf(dwi_outfile, "%2d %12.3e %12.3e %12.3e\n",
                        i, rhhoec_bases.hoec_coef[i][0], rhhoec_bases.hoec_coef[i][1], rhhoec_bases.hoec_coef[i][2]);
            }
            
            /* save how psd and recon split up the bases */
            
            /* HOEC coefficients at k-space center */
            fprintf(dwi_outfile, "\n\n");
            fprintf(dwi_outfile, "PSD and recon HOEC correction schedule (all bases are in logical axes):\n");
            fprintf(dwi_outfile, "Polyorder = %d\n", hoec_cal_info.fit_order);
            fprintf(dwi_outfile, "Number of bases per donor axis = %d\n", hoec_cal_info.total_bases_per_axis);
            fprintf(dwi_outfile, "Max number of PSD correctable (type A) bases = %d\n", 3*hoec_cal_info.fit_order+1);
            fprintf(dwi_outfile, "HOEC correction flag = %d  // 0=off, 1=no, 2=manual, 3=recon for all\n", hoecc_flag);
            fprintf(dwi_outfile, "\n");
            for (i=0; i<3; i++) /* donor axes */
            {
                switch (i)
                {
                    case 0: fprintf(dwi_outfile, "X Donor\n"); break;
                    case 1: fprintf(dwi_outfile, "Y Donor\n"); break;
                    case 2: fprintf(dwi_outfile, "Z Donor\n"); break;
                }
            
                fprintf(dwi_outfile, "-------------------------------------------------------------------------\n");
                fprintf(dwi_outfile, "Index    Basis      CorrSchedule      GradAxisPsdCorr    ExtraZExpPsdCorr\n");
                fprintf(dwi_outfile, "-------------------------------------------------------------------------\n");
                for (j=0; j<hoec_cal_info.total_bases_per_axis; j++)
                {
                    xorder = hoec_cal_info.termIndex2xyzOrderMapping[0][j];
                    yorder = hoec_cal_info.termIndex2xyzOrderMapping[1][j];
                    zorder = hoec_cal_info.termIndex2xyzOrderMapping[2][j];
            
                    strcpy(basisStr, "");    /* start with empty string */
            
                    switch (xorder)  /* add x component */
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "x"); break;
                        default: sprintf(tempStr, "x%d", xorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    switch (yorder)  /* add y component*/
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "y"); break;
                        default: sprintf(tempStr, "y%d", yorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    switch (zorder)  /* add z component */
                    {
                        case 0: strcpy(tempStr, ""); break;
                        case 1: strcpy(tempStr, "z"); break;
                        default: sprintf(tempStr, "z%d", zorder); break;
                    }
                    strcat(basisStr, tempStr);
            
                    if (strcmp(basisStr, "")==0)  /* set the basis name to "1" if there is no x,y, or z component */
                    {
                        strcpy(basisStr, "1");
                    }
            
                    strcpy(corrScheduleStr, "");
                    strcpy(linearizedAxisInPsdStr, "");
                    strcpy(extraZExpInPsdStr, "");
                    switch(ext_corr_term[i][j])
                    {
                        case 0: strcpy(corrScheduleStr, "NoCorr"); break;
                        case 1:
                            strcpy(corrScheduleStr, "PSD");
                            if (xorder==0 && yorder==0)
                            {
                                strcpy(linearizedAxisInPsdStr, "B0");
                            }
                            else if (xorder==1 && yorder==0)
                            {
                                strcpy(linearizedAxisInPsdStr, "X");
                            }
                            else if (xorder==0 && yorder==1)
                            {
                                strcpy(linearizedAxisInPsdStr, "Y");
                            }
                            sprintf(extraZExpInPsdStr, "%d", zorder);
                        break;
                        case 2:
                            strcpy(corrScheduleStr, "Recon");
                            break;
                        default:
                            strcpy(corrScheduleStr, "UnknownState");
                            break;
                    }
            
                    fprintf(dwi_outfile, "%-5d    %-10s %-17s %-15s    %-10s      \n", j+1, basisStr,
                              corrScheduleStr, linearizedAxisInPsdStr, extraZExpInPsdStr);
                } /* end for j*/
                fprintf(dwi_outfile, "\n\n");
            }  /* end for i*/
            fclose(dwi_outfile);    
        }
        else
        {        	
            printf("Failed to open %s.\n", HOEC_DEBUG_FILE);
        }
        
    }  /* if (hoecc_debug == PSD_ON) */
}

/* defined in pg section */
@pg HoecArrayDefPG

/* delta grad and freq arrays */
int ***ia_gx_hoec_comp, ***ia_gy_hoec_comp;  /* final value for gradient amplitude correction */
double ***recv_phase_b0_hoec_comp;  /* final value for frequency correction */

/* Allocate memory for PSD correction in AGP */
@pg HoecAllocateMemPG
{   int pp;

    ia_gx_hoec_comp = (int ***)AllocMem(intleaves*sizeof(int **));
    ia_gy_hoec_comp = (int ***)AllocMem(intleaves*sizeof(int **));
    recv_phase_b0_hoec_comp = (double ***)AllocMem(intleaves*sizeof(double **));

    for (pp=0; pp<intleaves; pp++)
    {

        ia_gx_hoec_comp[pp] = (int **)AllocMem(opslquant*sizeof(int *));
        for (i=0; i<opslquant; i++)
        {
            ia_gx_hoec_comp[pp][i] = (int *)AllocMem(tot_etl*sizeof(int));
        }
        ia_gy_hoec_comp[pp] = (int **)AllocMem(opslquant*sizeof(int *));
        for (i=0; i<opslquant; i++)
        {
            ia_gy_hoec_comp[pp][i] = (int *)AllocMem(tot_etl*sizeof(int));
        }
        recv_phase_b0_hoec_comp[pp] = (double **)AllocMem(opslquant*sizeof(double *));
        for (i=0; i<opslquant; i++)
        {
             recv_phase_b0_hoec_comp[pp][i] = (double *)AllocMem(tot_etl*sizeof(double));
        }
    }
}

/* functions that set blip amplitude and receiver phase */
@rsp HoecRspFunctionsInRsp

/* calculate per slice receiver phase adjustment needed for B0 compensation (called in
   diffstep(), and then dabrbaload in core() actually applies recv_phase) */
STATUS HoecCalcReceiverPhase(void)
{
    int ii,jj,kk;
    /* accumulated phase from start of echo train to the center of current echo (allowing echo dependent phase) */
    double accumulated_recv_phase_b0_hoec_comp;

    for (ii=0; ii<opslquant; ii++)
        for (jj=0; jj<intleaves; jj++)
            for (kk=0; kk<tot_etl; kk++)
            {
                recv_phase_angle[ii][jj][kk] = recv_phase_ang_nom[ii][jj][kk];

                if(kk < iref_etl) continue;

                if (kk == iref_etl)
                {
                    /* 1/2.0 is because we assume the phase accumulation happens at center of echo */
                    accumulated_recv_phase_b0_hoec_comp= recv_phase_b0_hoec_comp[jj][ii][0]/2.0;
                }
                else
                {
                    /* add phase from half of current and half of last echoes*/
                    accumulated_recv_phase_b0_hoec_comp += recv_phase_b0_hoec_comp[jj][ii][kk-1]/2.0 + recv_phase_b0_hoec_comp[jj][ii][kk]/2.0;
                }

                recv_phase_angle[ii][jj][kk] += accumulated_recv_phase_b0_hoec_comp;

                recv_phase[ii][jj][kk] = calciphase(recv_phase_angle[ii][jj][kk]);
            }

    return SUCCESS;
}


/* per slice per echo instruction amplitude update for echo train readout gradients */
STATUS HoecSetEchoTrainAmp(void)
{
    int polarity;

    if (iref_etl%2 == 1) {
        polarity = -1;
    }
    else {
        polarity = 1;
    }

    tia_gx1 = gradpol[ileave]*ia_gx1;  /* temporary x dephaser amp */
    tia_gxw = polarity*gradpol[ileave]*ia_gxw;  /* temporary x readout amp  */
    tia_gxk = polarity*gradpol[ileave]*ia_gxk;  /* temporary x killer amp   */
    
    setiamp(tia_gx1, &gx1a, 0);        /* x dephaser attack */
    setiamp(tia_gx1, &gx1, 0);         /* x dephaser middle */
    setiamp(tia_gx1, &gx1d, 0);        /* x dephaser decay  */

    if(iref_etl > 0)
    {
        tia_gxiref1 = polarity*gradpol[ileave]*ia_gxiref1; /* temporary interref x dephaser amp */ 
        tia_gxirefr = (iref_etl%2 ? 1 : -1)*polarity*gradpol[ileave]*ia_gxirefr; /* temporary interref x rephaser amp */
        setiampt(tia_gxiref1, &gxiref1, 0);  /* interref x dephaser */
        setiampt(tia_gxirefr, &gxirefr, 0);  /* interref x rephaser */
    }

    setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][0],&gxwa, tot_etl-1);   /* attack, beginning of echo
                                                                        train (but the last pulse index) */
    setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][0], &gxw, 0); /* index 0 of gxw (begining of echo train */
 
    for (echo=1; echo < tot_etl; echo++)
    {
        if ((echo % 2) == 1)
        {  /* Even echo within interleave */
            setiamp(-tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo], &gxwa, echo-1); /* sliceindex1 is an rsp variable used in core
                                                                                    and HoecSetEchoTrainAmp is called in core */
            setiamp(-tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo-1], &gxwd, echo-1);
            setiamp(-tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo], &gxw, echo);
        }
        else
        {  /* Odd echo within interleave */
            setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo], &gxwa, echo-1); /* (echo-1)th gxwa and echo-th gxw belong to
                                                                                   the echo-th view, while (echo-1)th gxwd
                                                                                   belongs to the (echo-1)th view */
            setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo-1], &gxwd, echo-1);
            setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][echo], &gxw, echo);
        }
    }
 
    if ((tot_etl % 2) == 1)
    {
        setiamp(-tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][tot_etl-1],&gxwde, 0);  /* decay,end */
        if (eosxkiller == 1)
        {
            setiamp(-tia_gxk,&gxka, 0); /* killer attack */
            setiamp(-tia_gxk,&gxk, 0);  /* killer flattop */
            setiamp(-tia_gxk,&gxkd, 0); /* killer decay  */
        }
    }
    else
    {
        setiamp(tia_gxw-ia_gx_hoec_comp[ileave][sliceindex1][tot_etl-1],&gxwde, 0);   /* decay,end */
        if (eosxkiller == 1)
        {
            setiamp(tia_gxk,&gxka, 0);  /* killer attack */
            setiamp(tia_gxk,&gxk, 0);   /* killer flattop */
            setiamp(tia_gxk,&gxkd, 0);  /* killer decay  */
        }
    }

    return SUCCESS;
} /* end HoecSetEchoTrainAmp */

/* per slice phase blip compensation */
STATUS HoecSetBlipAmp(int blipsw)  /* blipsw = 0 means ref scan where all phase blips and prephaser
                                      are set to 0, 1 means normal scan */
{
    int bcnt;
    int dephaser_amp;
    int gmn_amp;
    int parity;

    parity = gradpol[ileave];
  
    if (blipsw == 0)
    {
        dephaser_amp = 0;
        gmn_amp = 0;
        for (bcnt=0;bcnt<etl-1;bcnt++)
            setiampt((short)0, &gyb, bcnt);
    }
    else
    {
        gmn_amp = ia_gymn2;
        if (rsppepolar == PSD_OFF)
        {
            dephaser_amp = -gy1f[0];
            for (bcnt=0;bcnt<etl-1;bcnt++) /* there are no blips for interref echoes */
            {
                if (oblcorr_perslice == 1)  /* HOEC correction is per sliceindex1 in either case */
                    setiampt((short)(-blippol[ileave] + parity*rspia_gyboc[sliceindex1]-
                                ia_gy_hoec_comp[ileave][sliceindex1][bcnt+iref_etl]), &gyb, bcnt);
                else
                    setiampt((short)(-blippol[ileave] + parity*rspia_gyboc[0]-
                                ia_gy_hoec_comp[ileave][sliceindex1][bcnt+iref_etl]), &gyb, bcnt);
                parity *= -1;
            }
        }
        else
        {
            dephaser_amp = gy1f[0];
            for (bcnt=0;bcnt<etl-1;bcnt++)
            {
                if (oblcorr_perslice == 1)
                    setiampt((short)(blippol[ileave] + parity*rspia_gyboc[sliceindex1]-
                                ia_gy_hoec_comp[ileave][sliceindex1][bcnt+iref_etl]), &gyb, bcnt);
                else
                    setiampt((short)(blippol[ileave] + parity*rspia_gyboc[0]-
                                ia_gy_hoec_comp[ileave][sliceindex1][bcnt+iref_etl]), &gyb, bcnt);
                parity *= -1;
            }
        }
    }
  
    setiampt((short)dephaser_amp, &gy1, 0);
    if (ygmn_type == CALC_GMN1)
    {
        setiampt((short)-gmn_amp, &gymn1, 0);
        setiampt((short)gmn_amp, &gymn2, 0);
    }

    if (blipsw == 1 && rspent != L_REF && rspent != L_MPS2 && rspent != L_APS2)
    {
        setiampt(invertGy1*gy1f[ileave], &gy1, 0);
        if (ygmn_type == CALC_GMN1)
        {
            setiampt(gymn[ileave], &gymn1, 0);
            setiampt(-gymn[ileave], &gymn2, 0);
        }
    }

    return SUCCESS;

} /* End HoecSetBlipAmp */

/* Calculate read, blip grad and receiver freq compensation; update receiver phase in diffstep() */
@rsp HoecCalcAmpUpdateReceiverPhaseRsp
{ /* Start of code inlined from HoecCorr.e HoecCalcAmpUpdateReceiverPhaseRsp */
    if (hoecc_psd_flag == PSD_ON)
    {
        int ii, jj, pp;

        /* per-slice per-echo gradient instruction amplitude and receiver phase needed for HOEC compensation */
        for (pp=0; pp<intleaves; pp++)
        {
            for (ii=0; ii<opslquant; ii++)
            {
                for (jj=0; jj<tot_etl; jj++)
                {
                    if(jj < iref_etl) /* interref echoes played out before diffusion gradients */
                    {
                        ia_gx_hoec_comp[pp][ii][jj] = 0;
                        ia_gy_hoec_comp[pp][ii][jj] = 0;
                        recv_phase_b0_hoec_comp[pp][ii][jj] = 0;
                        continue;
                    }
                    
                    /* X grad */
                    ia_gx_hoec_comp[pp][ii][jj] = (int)((double)(ia_incdifx)*dwi_hoec_gcor_XonX[pp][ii][jj] +
                                                (double)(ia_incdify)*dwi_hoec_gcor_YonX[pp][ii][jj] +
                                                (double)(ia_incdifz)*dwi_hoec_gcor_ZonX[pp][ii][jj]);
                    if (read_corr_option == 1)
                    {
                        /* pw_gxwl and pw_gxwd are wait time at the beginning and end of the plateau (typically zero) */
                        ia_gx_hoec_comp[pp][ii][jj] = ia_gx_hoec_comp[pp][ii][jj]*esp/(pw_gxwl+pw_gxw+pw_gxwr+pw_gxwad);
                    }
                    else if (read_corr_option == 2)
                    {
                        ia_gx_hoec_comp[pp][ii][jj] = ia_gx_hoec_comp[pp][ii][jj]*esp/(pw_gxwl+pw_gxw+pw_gxwr);
                    }

                    /* Y grad */
                    ia_gy_hoec_comp[pp][ii][jj] = (int)((double)(ia_incdifx)*dwi_hoec_gcor_XonY[pp][ii][jj] +
                                                (double)(ia_incdify)*dwi_hoec_gcor_YonY[pp][ii][jj] +
                                                (double)(ia_incdifz)*dwi_hoec_gcor_ZonY[pp][ii][jj]);
                    ia_gy_hoec_comp[pp][ii][jj] = ia_gy_hoec_comp[pp][ii][jj]*esp/(pw_gyb + pw_gyba);

                    /* B0 (through adjustment of receiver phase where the adjusted phase at a given echo is the
                       integration of recv_phase_b0_hoec_comp from begining of echo train to center of the given echo) */
                    recv_phase_b0_hoec_comp[pp][ii][jj] = (TWO_PI*GAM*(double)esp/(1.0e6))*
                                                          ((double)ia_incdifx/
                                                           (double)max_pg_iamp*loggrd.tx*dwi_hoec_bcor_XonB0[pp][ii][jj] +
                                                           (double)ia_incdify/(double)max_pg_iamp*loggrd.ty*dwi_hoec_bcor_YonB0[pp][ii][jj] +
                                                           (double)ia_incdifz/(double)max_pg_iamp*loggrd.tz*dwi_hoec_bcor_ZonB0[pp][ii][jj]);
                }
            }
        }

        /* save intermediate results */
        if (hoecc_debug == PSD_ON)
        {
            printf("HOEC realtime correction: pass_rep=%d ileave=%d slice=%d echo=%d\n",
                    dshot, psd_ileave_for_debug, psd_slice_for_debug, psd_echo_for_debug);
            printf("gx=%6d gy=%6d recv_phase=%12.3e\n",
                    ia_gx_hoec_comp[psd_ileave_for_debug][psd_slice_for_debug][psd_echo_for_debug],
                    ia_gy_hoec_comp[psd_ileave_for_debug][psd_slice_for_debug][psd_echo_for_debug],
                    recv_phase_b0_hoec_comp[psd_ileave_for_debug][psd_slice_for_debug][psd_echo_for_debug]);
        }

        /* update recv_phase array that is used in dabrbaload() call later in core() */
        HoecCalcReceiverPhase();  /* in core(), dabrbaload() actually applies recv_phase that is calculated here */
    }
} /* End of code inlined from HoecCorr.e HoecCalcAmpUpdateReceiverPhaseRsp */

/* Update read and blip instruction amplitudes in core() */
@rsp HoecUpdateReadoutBlipAmpRsp
{ /* Start of code inlined from HoecCorr.e HoecUpdateReadoutBlipAmpRsp */

    if (hoecc_psd_flag == PSD_ON)  /* note b0 compensation is done through earlier in slice loop of core() */
    {
        HoecSetEchoTrainAmp();
        HoecSetBlipAmp(rspgyc); /* in ref scan mode (rspgyc = 0), this function sets
                                   phase blips and prephaser to 0; in scan mode, it compensates
                                   HOEC by changing phase blip amplitude */
    }
} /* End of code inlined from HoecCorr.e HoecUpdateReadoutBlipAmpRsp */
