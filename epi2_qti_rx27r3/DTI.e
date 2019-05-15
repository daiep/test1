/*
 *  GE Medical Systems
 *  Copyright (C) 2001 The General Electric Company
 *  
 *  DTI.e    "Diffusion Tensor Inline File"
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Product  : Anila Lingamneni
 *  Date     : 1/26/01
 */
/* do not edit anything above this line */

/* This inline file contains all the code for the DTI option.  
 * The code located within this file is responsible for the following:
 *   1) setting up any error messages related to DTI
 *   2) setting up the "pi" variables that control the new Diffusion ImOpt Screen
 *   3) setting up for host-based tensor processing  (HBP)
 *   4) determining the diffusion orientations from tensor.dat
 *   5) calculating and adjusting the b-value using the logical waveforms
 *
 *   This file inlines sections of code directly into the epi2.e source and also 
 *   inlines functions for DTI support.

12/31/2009   VSN/VAK     MRIhc46886 : SV to DV Apps Sync Up

12/03/2012   YI          HCSDM00150228 : Changed for oblique 3in1 optimization.
03/05/2013   YI          HCSDM00188912 : Changed scale_all for gradient optimization mode for XRMB and XRMW.
SV24.0 07/31/2013   WJZ  eco-MPG: initial version of eco-MPG implemented;
22/Apr/2014  YT          HCSDM00282488 : Added support for DTI axis file for VRMW and scale_all setting for VRMW
24/Apr/2015  YT          HCSDM00348265 : Use common file name for DTI axis in all products.

 */

@global DTI_Global

/* Local header files */
#include "DTI.h"
#include "pgen_calcbval.h"
#include "ftde.h" /* granty edit include code for full time diffusion encoding */

#define MAXCHAR 150
#define MAX_TENSOR_VECTOR_MAG 1.01 /*In the product tensor.dat, the maximum vector is even less than 1.001*/
#define MIN_DTI_DIRECTIONS 6
#define MAX_DTI_LEGACY 150
#define MAX_DTI_CLINICAL 300 /* requires maxtensor option key */


#define TENSOR_FILE_MAX 99              /* Reserve for GE definitions */ 
#define TENSOR_FILE_RSRCH_START 100     /* Research use start from here */
#define TENSOR_FILE_RSRCH_MAX 65536     /* Research use end here */

int gCoilType = PSD_XRMW_COIL;

@host DTI_host_funcs
static INT get_diffusion_time( void );
static INT update_sse_diffusion_time( void );
static FLOAT calc_incdif(float *DELTA, float *delta, int Delta_time, int pw_gdl, int pw_gdld, int pw_gdla, int pw_gdra, float bvaltemp);
static INT set_tensor_orientations( void );
static INT sort_tensor_orientations(void);
static INT calc_orientations( void );
static INT derate_diffusion_amplitude(void);
static INT get_sse_waittime( void );
static STATUS update_opmintedif(void);
/* Local Cvs */
@cv DTI_cvs

float scale_ramp = 1.0 with {1.0, 100, 1.0, VIS, "scale factor for ramp time for diffusion",};

int debugTensor = 0 with {0,1,0,VIS,"Tensor Debugging Flag",};
int tensor_flag = 0 with {0,1,0,VIS,"Tensor flag based off option key check",};
int ftde_flag = 0 with { 0,1,0, VIS, "full time diffusion encoding option",};/* granty edit for full time diffusion encoding */
int num_tensor = MIN_DTI_DIRECTIONS with {0,MAX_DIRECTIONS,MIN_DTI_DIRECTIONS,VIS,"Number of Diffusion Directions",};
int validTensorFile = 0; /* HCSDM00476194 */
int validTensorFileAndEntry = 0; /* HCSDM00476194 */
int num_B0 = 1 with {1,10,5,VIS,"Number of B = 0 Images",};
int sep_time = 0 with {0,10ms,0,VIS,"Delay between 1 & 2nd diffusion lobes",};
int min180_echo_tim = 2ms with {0,50ms,2ms,VIS,"Minimum Time for dr2 Dif Lobes",};
int min180_echo_tim2 = 2ms with {0,50ms,2ms,VIS,"Minimum Time for dl1 Dif Lobes",};
int calc_bmatrix_flag = 0 with {0,1,0,VIS,"Flag to trigger b-matrix calculations.",};
int bmax_fixed;              /* maximum b-value given fixed diffusion timing */
int pgen_calc_bval_flag = 0 with {0,1,0,VIS,"Flag to indicate call to getCornerpoints from pgen_calcbvalues.",};

int tensor_host_sort_flag = 0 with {0, 1, 0, INVIS, "Sort tensor vectors to generate cornerPoints: 0: off, 1: on",};
int tensor_host_sort_debug = 0;

int sse_manualte_derating = 1 with {0, 1, 1, VIS, "Shift and further derating the left diffusion gradient for SSE diffusion: 0: off, 1: on",};
int sse_manualte_derating_debug = 0;

float spherical_derating_limit = 5.0 with {0, 7.0, 5.0, VIS, "Gradient amplitude limit for spherical derating",};
/* BJM: added cv's for each axis */
int collect_six_sigma = 0;   /* flag to dump exact b-value calcs and errors */
float per_err_orig_x = 0.0;  /* Error between target bvalue  */
float per_err_orig_y = 0.0;  /* and integrated result before scaling the dif lobe amps */
float per_err_orig_z = 0.0;  
float per_err_corr_x = 0.0;  /* Error between target bval and integrated result */
float per_err_corr_y = 0.0;  /* after scaling dif lobe amps and using bistection */
float per_err_corr_z = 0.0;  /* Will be less than the specified tolerance */

int sse_enh = PSD_ON with {PSD_OFF, PSD_ON, PSD_ON, VIS, "Flag for SSE enhancement of TE reduction: 1-yes, 0-no",};

int optimizedTEFlag = 0 with {0, 1, 0, VIS, "Flag for optimized TE",};

int act_numdir_clinical = MAX_DTI_LEGACY with {MIN_DTI_DIRECTIONS, 2000, MAX_DTI_LEGACY, INVIS, "Max number of DTI dirs in Clinical Mode",};

@host DTIarrays
float TENSOR_HOST[3][MAX_DIRECTIONS + MAX_T2];        /* Tensor Amplitude Array (directions + t2) */
float B_MATRIX[6][MAX_DIRECTIONS + MAX_T2];           /* B-Matrix */
int sort_index[MAX_DIRECTIONS + MAX_T2];
float mag[MAX_DIRECTIONS + MAX_T2];
float scale_gmax;

@host DTI_Init
#ifdef __STDC__ 
STATUS DTI_Init( void )
#else /* !__STDC__ */
STATUS DTI_Init() 
#endif /* __STDC__ */
{   
   gCoilType = cfgcoiltype;

   /* Make sure DTI+ is OFF */
    cvmax(dti_plus_flag,PSD_OFF);

    if( exist(optensor) > 0 )
    {
        tensor_flag = PSD_ON;    
#ifdef PSD_HW
        /* Option key check */
        if ( checkOptionKey( SOK_TENSOR ) != KEY_PRESENT )
            tensor_flag = PSD_OFF;
#endif
    }
    else
        tensor_flag = PSD_OFF;

    pidualspinechonub = 1;
    cvdef(opdualspinecho, PSD_OFF);

    /* ACGD_PLUS is the default mode and inittargets:setupConfig
       will check to see if it is really ACGD Plus compatible */
    config_update_mode = CONFIG_UPDATE_TYPE_ACGD_PLUS;

    /* TENSOR UI related initializations */    
    if (tensor_flag == PSD_ON) {

        if( existcv(opepi) && (PSD_ON == exist(opepi)) &&
            existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) && 
            existcv(optensor) ) {

            config_update_mode = CONFIG_UPDATE_TYPE_TENSOR;
        }

        /* Remove interleave slice spacing */
        piisil = PSD_OFF;

        cvdef(opuser0, PSD_ON); 

        if (!vrgf_bwctrl)
        {
            pircbnub = 0;
        }

        pidiffproctype = 1;

        /* MRIge71899 (AC) - remove DTI+ if non-CRM & ACGD system */
        /*MRIge92832 - add HFD 8916 to this*/ 
        /*MRIhc05807 add HFD-S 8917 to this*/
                                               
        if( ((8915 <= cfgradamp && 8925 > cfgradamp) && (PSD_CRM_COIL == gCoilType)) || ((8915 < cfgradamp || 8925 > cfgradamp) && (PSD_TRM_COIL == gCoilType) && (TRM_ZOOM_COIL == opgradmode) ) ) {
            piuset |= use10; /* opuser for gradient switching for tensor ALP */
            cvmod(opuser10, 0.0, 1.0, 0.0, "DTI+ (1=on, 0=off)",0," ");
            opuser10 = _opuser10.defval;
            cvmax(dti_plus_flag,PSD_ON);
        } else {
           
            piuset &= ~use10;
            cvmod( opuser10, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 10", 0, "" );
            cvoverride(opuser10, _opuser10.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }

        /* screen for diffusion directions */
        pidifnumdirsnub = 15;       
        pidifnumdirsval2 = MIN_DTI_DIRECTIONS;
        pidifnumdirsval3 = 15;
        pidifnumdirsval4 = 25;

        /* screen for number of T2 images */
        opautodifnumt2 = 0;
        pidifnumt2nub = 15;    
        pidifnumt2val2 = 1;
        pidifnumt2val3 = 2;
        pidifnumt2val4 = 3;

        pibvalstab = 1; /* show bvalue table */
        pidifnextab = 1; /* show NEX table */
        avmindifnextab = 1;
        avmaxdifnextab = max_difnex_limit;

        pinumbnub = 0;  /* number of b value allowed only 1 */
        avminnumbvals = 1;
        avmaxnumbvals = 1;
        cvoverride(opnumbvals, 1, PSD_FIX_ON, PSD_EXIST_ON);

        pidifnext2nub = 0;   /* NEX for T2 disabled */
        avmindifnext2 = difnextab[0];
        avmaxdifnext2 = difnextab[0];
        cvoverride(opdifnext2, difnextab[0], PSD_FIX_ON, PSD_EXIST_ON);

        pinexnub = 0; /* disable opnex */

        if (PSD_ON == maxtensor_status)
        {
            cvoverride(act_numdir_clinical, MAX_DTI_CLINICAL, PSD_FIX_ON, PSD_EXIST_ON);
        }
        else
        {
            cvoverride(act_numdir_clinical, MAX_DTI_LEGACY, PSD_FIX_ON, PSD_EXIST_ON);
        }

    } else {

        /* turn interleave slice spacing field back on */
        piisil = PSD_ON;

        piuset &= ~use10;
        cvmod( opuser10, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 10", 0, "" );
        cvoverride(opuser10, _opuser10.defval, PSD_FIX_OFF, PSD_EXIST_OFF);


        if(exist(opdiffuse) == PSD_ON)
        {
            if(edwi_status == PSD_ON)
            {
                /* screen for number of T2 images */
                opautodifnumt2 = 0;
                pidifnumt2nub = 7;    
                pidifnumt2val2 = 0;   
                pidifnumt2val3 = 1;  

                pibvalstab = 1;  /* show bvalue table */
                pidifnextab = 1; /* show NEX table */
                avmindifnextab = 1;
                avmaxdifnextab = max_difnex_limit;

                pinumbnub = 63;
                pinumbval2 = 1;
                pinumbval3 = 5;
                pinumbval4 = 10;
                pinumbval5 = 20;
                pinumbval6 = 40;
                avminnumbvals = 1;
                avmaxnumbvals = MAX_NUM_BVALS_PSD;

                if(exist(opdifnumt2) == 1)
                {
                    /* T2 image acquisition on.  Enable NEX for T2 control */
                    pidifnext2nub = 63;
                    if(exist(opdifnext2) < 1.0)
                    {
                        cvoverride(opdifnext2, 1.0, PSD_FIX_ON, PSD_EXIST_ON);
                    }
                    avmindifnext2 = 1;
                    avmaxdifnext2 = max_difnex_limit;
                }
                else if(exist(opdifnumt2) == 0)
                {
                    /* T2 image acquisition off.  Disable NEX for T2 control */
                    cvoverride(opdifnext2, 0.0, PSD_FIX_ON, PSD_EXIST_ON);
                    pidifnext2nub = 0;
                    avmindifnext2 = 0;
                    avmaxdifnext2 = 0;
                }
                pidifnext2val2 = 1;
                pidifnext2val3 = 2;
                pidifnext2val4 = 4;
                pidifnext2val5 = 8;
                pidifnext2val6 = 16;
            }
            else
            {
                /* No eDWI support */
                avmindifnextab = 1;
                avmaxdifnextab = max_difnex_limit;

                /* Always acquire single T2 image */
                opautodifnumt2 = 1;
                pidifnumt2nub = 0;
                cvoverride(opdifnumt2, 1, PSD_FIX_ON, PSD_EXIST_ON);

                /* Use name NEX for T2 and DW images */ 
                pidifnext2nub = 0;
                cvoverride(opdifnext2, difnextab[0], PSD_FIX_ON, PSD_EXIST_ON);

                /* Only supports 1 b-value */
                pinumbnub = 0;
                cvoverride(opnumbvals, 1, PSD_FIX_ON, PSD_EXIST_ON);

            }

            pinexnub = 0; /* disable opnex */

        }

    }
    dti_plus_flag = (int)exist(opuser10);

    update_opmintedif();

    return SUCCESS;
} /* end DTI_Init */

@host DTI_Eval
#ifdef __STDC__ 
STATUS DTI_Eval( void )
#else /* !__STDC__ */
STATUS DTI_Eval() 
#endif /* __STDC__ */ 
{
    update_opmintedif();

    optimizedTEFlag = (isRioSystem()) ? PSD_ON : exist(opmintedif);

    if( (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON) )
    {
        if((exist(opdfaxx) == PSD_OFF) && (exist(opdfaxy) == PSD_OFF) && (exist(opdfaxz) == PSD_OFF) &&
           (exist(opdfaxtetra) == PSD_OFF) && (exist(opdfax3in1) == PSD_OFF) && (exist(opdfaxall) == PSD_OFF) &&
           (tensor_flag == PSD_OFF))
        {
            float allowed_min_bval;
            float allowed_max_bval = bmax_fixed;

            if ( PSD_OFF == optimizedTEFlag )
            {
                allowed_max_bval = bmax_fixed;
            }
            else
            {
                /* b-value limits based on coil type and slew rate */
                switch ( gCoilType )
                {
                case PSD_CRM_COIL:
                case PSD_XRMB_COIL:
                case PSD_XRMW_COIL:
                case PSD_VRMW_COIL:
                case PSD_HRMW_COIL:
                    allowed_max_bval = MAXB_10000;
                    break;

                case PSD_60_CM_COIL:
                    switch ( cfsrmode )
                    {
                    case PSD_SR100:
                    case PSD_SR120:
                        allowed_max_bval = MAXB_7000;
                        break;
                    case PSD_SR77:
                        allowed_max_bval = MAXB_4000;
                        break;
                    case PSD_SR50:
                        allowed_max_bval = MAXB_2500;
                        break;
                    default:
                        allowed_max_bval = MAXB_1000;
                        break;
                    }
                    break;

                case PSD_BRM2_COIL:
                    switch ( cfsrmode )
                    {
                    case PSD_SR50:
                    case PSD_SR100:
                    case PSD_SR120:
                        allowed_max_bval = MAXB_7000;
                        break;
                    case PSD_SR77:
                        allowed_max_bval = MAXB_4000;
                        break;
                    default:
                        allowed_max_bval = MAXB_1000;
                        break;
                    }
                    break;

                case PSD_TRM_COIL:
                    if ( cfsrmode == PSD_SR77 || ( exist( opgradmode ) == TRM_BODY_COIL && existcv( opgradmode ) ) )
                        allowed_max_bval = MAXB_4000;
                    else if ( cfsrmode == PSD_SR150 || ( exist( opgradmode ) == TRM_ZOOM_COIL && existcv( opgradmode ) ) )
                        allowed_max_bval = MAXB_10000;
                    break;
                default:
                    allowed_max_bval = MAXB_1000;
                    break;
                }
            }

            if (tensor_flag == PSD_ON)
            {
                if ((PSD_XRMB_COIL == gCoilType) || (PSD_XRMW_COIL == gCoilType) || (PSD_VRMW_COIL == gCoilType) || (PSD_HRMW_COIL == gCoilType))
                    allowed_max_bval = FMin(2, allowed_max_bval, (float)MAXB_10000);
                else
                    allowed_max_bval = FMin(2, allowed_max_bval, (float)MAXB_4000);
            }

            allowed_min_bval = MINB_VALUE;
            avminbvalstab = allowed_min_bval;
            avmaxbvalstab = allowed_max_bval;
        }
    }

    if( PSD_ON == tensor_flag ) {

        piuset &= ~use0;
        cvoverride(opuser0, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        cvoverride(rampsamp, PSD_ON, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvoverride(vrgfsamp, PSD_ON, PSD_FIX_OFF, PSD_EXIST_OFF);

        if (!vrgf_bwctrl)
        {
            pircbnub = 0;
        }

        /* Prevent users from selecting interleave w/ tensor */
        if( exist(opileave) == PSD_ON) {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Tensor", STRING_ARG, "Interleaved Slice Spacing" );
            return FAILURE;
        }

        if( exist(opflair) == PSD_ON ) {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "FLAIR OPTION" );
            pitinub = 0;
            return FAILURE;
        }

        if( PSD_ON == navtrig_flag) {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "Navigator" );
            return FAILURE;
        }

        if ((exist(opslquant) > avmaxslquant) && existcv(opslquant))
        {
            epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxslquant );
            return ADVISORY_FAILURE;
        }

        /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support
           below check is already in cvcheck(). Disable it to avoid conflict with autoTR */
        if ( (act_acqs > 1) && (piautotrmode != PSD_AUTO_TR_MODE_MANUAL_TR) ) {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "Multiple acquisitions" );
            return FAILURE;

        }

        /* check for valid number of t2 images */
        if( exist(opdifnumt2) > MAX_T2)  {
            cvoverride(opdifnumt2, MAX_T2, PSD_FIX_ON, PSD_EXIST_ON);
        }

        if( exist(opdifnumt2) < 1)  {
            cvoverride(opdifnumt2, 1, PSD_FIX_ON, PSD_EXIST_ON);
        }
        if (PSD_ON == exist(opresearch)) 
        {
            cvmax(num_tensor, MAX_DIRECTIONS);
        }
        else
        {
            cvmax(num_tensor, act_numdir_clinical);
        }

        num_tensor = exist(opdifnumdirs);
        num_B0 = exist(opdifnumt2);

        if ( (exist(oprtcgate) == PSD_ON) ) { 
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "Respiratory triggering" ); 
            return FAILURE; 
        }

        if ( (exist(opirprep) == PSD_ON) ) { 
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "IR prep" ); 
            return FAILURE; 
        }

        /* Tensor only supports a single b-value */
        pinumbnub = 0;
        avminnumbvals = 1;
        avmaxnumbvals = 1;
        cvoverride(opnumbvals, 1, PSD_FIX_ON, PSD_EXIST_ON);

        opautodifnumt2 = 0;
        pidifnumt2nub=15;
        pidifnumt2val2 = 1;
        pidifnumt2val3 = 2;
        pidifnumt2val4 = 3;

        /* Use same NEX for T2 and DW images */
        pidifnext2nub=0;
        avmindifnext2 = difnextab[0];
        avmaxdifnext2 = difnextab[0];
        cvoverride(opdifnext2, difnextab[0], PSD_FIX_ON, PSD_EXIST_ON);

        /*
         * NEED Code for Setting up Header Stamping Here 
         * opuser 20-25 will be used by DTI feature
         * usage_tag.h in /vobs/lx/include has the defn for DTI_PROC
         * rhuser 20,21,22 will be set by recon after reading in tensor.dat
         * 20,21,22 represent the diffusion direction coeffs
         */

        /* Please note that currently opuser 23 and 24 are passed by recon 
         * to TIR..this is because scan needs piuset set for all opusers
         * psd wants to use, else they will not passthrough.
         * Hence recon will set the mapLSW to also pass on 23 and 24 */

        /* Inform recon that we are doing DTI */
        opuser_usage_tag = DTI_PROC;
        rhuser_usage_tag = DTI_PROC;
        rhFillMapMSW = 0;
        rhFillMapLSW = 0;

        opuser23 = opdifnumt2;
        opuser24 = opdifnumdirs;
        rhuser23 = opdifnumt2;     /* rhuser 23 and 24 needed by recon to read tensor.dat */
        rhuser24 = opdifnumdirs;

        /* MRIge67233 Added functionality to support tensor processing on host */
        rhapp_option = opdifproctype;
    } 
    else if(exist(opdiffuse) == PSD_ON)
    {
         if(edwi_status == PSD_ON)
         {
             opautodifnumt2 = 0;
             pidifnumt2nub=7;
             pidifnumt2val2 = 0;
             pidifnumt2val3 = 1;
             if(exist(opdifnumt2) < 0)
             {
                 cvoverride(opdifnumt2, 0, PSD_FIX_ON, PSD_EXIST_ON);
             }
             else if(exist(opdifnumt2) > 1)
             {
                 cvoverride(opdifnumt2, 1, PSD_FIX_ON, PSD_EXIST_ON);
             }
             if(exist(opdifnumt2) == 0)
             {
                 /* T2 image acquisition off.  Disable NEX for T2 */
                 pidifnext2nub=0;
                 avmindifnext2 = 0.0;
                 avmaxdifnext2 = 0.0;
                 cvoverride(opdifnext2, 0, PSD_FIX_ON, PSD_EXIST_ON);
             }
             else if(exist(opdifnumt2)==1)
             {
                 /* T2 image acquisition on.  Enable NEX for T2 */
                 pidifnext2nub=63;
                 avmindifnext2 = 1.0;
                 avmaxdifnext2 = max_difnex_limit;
                 if( !floatIsInteger(exist(opdifnext2)) )
                 {
                     epic_error(use_ermes, "Fractional NEX is not allowed with this scan.", EM_PSD_FNEX_INCOMPATIBLE, EE_ARGS(0        ));

                     return FAILURE;
                 }
                 if(exist(opdifnext2) < avmindifnext2)
                 {
                     cvoverride(opdifnext2, avmindifnext2, PSD_FIX_ON, PSD_EXIST_ON);
                 }
                 else if(exist(opdifnext2) > avmaxdifnext2)
                 {
                     cvoverride(opdifnext2, avmaxdifnext2, PSD_FIX_ON, PSD_EXIST_ON);
                 }
             }
             pinumbnub=63;
             avminnumbvals = 1;
             avmaxnumbvals = MAX_NUM_BVALS_PSD;
             if(exist(opnumbvals) < avminnumbvals)
             {
                 cvoverride(opnumbvals, avminnumbvals, PSD_FIX_ON, PSD_EXIST_ON);
             }
             else if(exist(opnumbvals) > avmaxnumbvals)
             {
                 cvoverride(opnumbvals, avmaxnumbvals, PSD_FIX_ON, PSD_EXIST_ON);
             }
        }
        else
        {
            /* No eDWI support */
            avmindifnextab = 1.0;
            avmaxdifnextab = max_difnex_limit;

            /* Always acquire single T2 image */
            opautodifnumt2 = 1;
            pidifnumt2nub = 0;
            cvoverride(opdifnumt2, 1, PSD_FIX_ON, PSD_EXIST_ON);

            /* Use name NEX for T2 and DW images */ 
            pidifnext2nub = 0;
            cvoverride(opdifnext2, difnextab[0], PSD_FIX_ON, PSD_EXIST_ON);

            /* Only supports 1 b-value */
            pinumbnub = 0;
            cvoverride(opnumbvals, 1, PSD_FIX_ON, PSD_EXIST_ON);
        }
         
    }  /* end opdiffuse check */

    /* dualspinecho option valid for diffusion or tensor, annotation is DSE */
    if ( (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON) ) {
        opuser25 = dualspinecho_flag; /* opuser25 should passthrough directly to TIR */      
    }

    if( PSD_ON == weighted_avg_grad && ((opdiffuse == PSD_ON && tensor_flag == PSD_OFF) || 
        (tensor_flag == PSD_ON && num_tensor >= MIN_DTI_DIRECTIONS && 
         ((num_tensor <= act_numdir_clinical) || 
         ((PSD_ON == exist(opresearch)) && (rhtensor_file_number > 0) && (num_tensor <= MAX_DIRECTIONS)))))) 
    {
        if ( FAILURE == set_tensor_orientations() ){
            return FAILURE;
        }
    }

    return SUCCESS;

}  /* end DTI_Eval */

/*
 * Update "Optimzie TE" button label and value
 * */
static STATUS update_opmintedif()
{
    if(isRioSystem())
    {
        if(superG_key_status == PSD_ON)
        { /*if option key exists, shown as Super G, enabled, and default is ON*/
            pimintediflabel = 1;
            pimintedifvis = 1;
            pimintedifnub = 1;
            pimintedifdef = 1;
        }
        else
        { /*if option key does not exist, shown as Super G, in gray, and default is OFF*/
            pimintediflabel = 1;
            pimintedifvis = 1;
            pimintedifnub = 0;
            pimintedifdef = 0;
        }
    }
    else
    {
        /*non-Rio, shown as  Optimize TE, enabled and default ON*/
        pimintediflabel = 0;
        pimintedifvis = 1;
        pimintedifnub = 1;
        pimintedifdef = 1;
    }
    return SUCCESS;
}

@host DTI_Check
#ifdef __STDC__ 
STATUS DTI_Check( void )
#else /* !__STDC__ */
STATUS DTI_Check() 
#endif /* __STDC__ */ 
{
    INT mindir;  /*MRIhc05854*/
    INT maxdir;
    
    if (tensor_flag == PSD_ON) {

        maxdir = (PSD_ON == exist(opresearch) && (rhtensor_file_number > 0)) ? MAX_DIRECTIONS : act_numdir_clinical;

        /* check for valid number of directions */
        if( existcv(opdifnumdirs) && (exist(opdifnumdirs) > maxdir) ) {
            epic_error( use_ermes, "The maximum number of directions allowed is %d in tensor acquisition.", EM_PSD_TENSOR_MAX_DIRS, EE_ARGS(1), INT_ARG, maxdir );
            return FAILURE;
        }

        mindir = MIN_DTI_DIRECTIONS;

        if( existcv(opdifnumdirs) && (exist(opdifnumdirs) < mindir) ) {
            epic_error( use_ermes, "The minimum number of directions allowed is %d in tensor acquisition.", EM_PSD_TENSOR_MIN_DIRS, EE_ARGS(1), INT_ARG, mindir );
            return FAILURE;
        }
       
        /* HCSDM00476194 */
        if((validTensorFile == 0) && (rhtensor_file_number >0)) {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "Tensor file number (CV11)" );
            return FAILURE;
        }   
        
        /* HCSDM00476194 */
        if( existcv(opdifnumdirs) && ((validTensorFileAndEntry == 0) && (rhtensor_file_number > 0)) ) {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "# of Diffusion Directions" );
            return FAILURE;
        }   
        
        if ( !floatsAlmostEqualEpsilons(exist(opuser0), 1.0, 2) ) 
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "Ramp Sampling OFF" );
            return FAILURE;
        }

        if ( (num_tensor + num_B0)  > avmaxpasses )
        {
            epic_error( 0, "Maximum number of phases exceeded, reduce # of phases or b-values to %d", EM_PSD_MAXPHASE_EXCEEDED, EE_ARGS(1), INT_ARG, avmaxpasses );
            return FAILURE;
        }

        if( existcv(opuser10) &&
            ((int)exist(opuser10) != 0) && ((int)exist(opuser10) != 1) ) {
            epic_error( use_ermes, "%s must be set to either 0 or 1.", EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, _opuser10.descr );
            return FAILURE;
        } 

   
    } /* end tensor_flag check */  

    return SUCCESS;
}  /* end DTI_Check */


@host DTI_Predownload
/*
 * DTI_Predownload:
 *
 *  This is inlined into Predownload of epi2.e to set up the CERD for multi-nex diffusion 
 *  and also to perform the exact b-value calculations
 */
#ifdef __STDC__ 
STATUS DTI_Predownload( void )
#else /* !__STDC__ */
STATUS DTI_Predownload() 
#endif /* __STDC__ */
{
    if ( tensor_flag == PSD_ON ) {

        /* MRIge67233 Added functionality to support tensor processing on host */
        /* rhapp gets set in loarheader init call for scic, hence moved initialization for tensor here */
        /* rhapp = 2 initiates tensor processing (app), rhapp_option defines choices ADC/FA/Combined */
        if(rhapp_option != 0) {

            rhapp = 2;

        } else {

            /* If user doesn't select any maps on DW-UI (ADC/FA/T2-Combined) */
            /* might as well not kick off an app process... */
            rhapp = 0;
        }

    }
    
    /* BJM: for multi-nex DW-EPI - override rhnavs so CERD thinks */
    /* have a single NEX scan */
    if ( (opdiffuse == PSD_ON || tensor_flag == PSD_ON) && nex > 1 ) {
        rhnavs = 1;
        rhtype1 = rhtype1 | 512;
    } else {
        rhtype1 = rhtype1 & ~512;
    }

    /***************************************/
    /* Exact Diffusion B-value Calculation */
    /***************************************/
    /* CRM: 2000-12-06 */
    /* Calculate and adjust the b-values on each axis for the correct b-values */

    if ( (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON) ){
        /* Variables for b-value calculation */
        FLOAT curr_bvalue[6];     /* b-value for each gradient waveform */
        FLOAT rf_excite_location; /* Location of isocenter of excitation pulse (usec) */
        FLOAT rf_180_location[2]; /* Location of isocenter of 180 pulses (usec) pulses 
                                     MAX of 2 can be increased for other applications */
        INT num_180s;             /* Number of 180s */
        INT seq_entry_index = 0;  /* Core sequence = 0 */
        INT bmat_flag = FALSE;    /* flag to do full blown matrix calcs (need to be zero for verify_bvalue() */
        STATUS status;            /* Status variable to catch errors from function calls */
        INT hte = opte/2;         /* Half te */  

        /* ---Calculate timing parameters--- */
        /* MUST MATCH THE TIMING IN PULSEGEN TO GIVE ACCURATE RESULTS */
        /* MRIhc27253, MRIhc27365 : updated pulse params to current values*/
        if ( FAILURE == calcPulseParams(AVERAGE_POWER) ) 
        { 
            return FAILURE; 
        }

        /* Calculate magnetic isocenter of excitation pulse */
        rf_excite_location = (psd_rf_wait + pos_start + pw_gzrf1a + pw_rf1 - rfExIso);
        /* fprintf(stdout,"rf_excite_location = %12.8f\n",rf_excite_location); */

        /* SVBranch: HCSDM00259122 - walk sat case */
        if (rfov_flag && walk_sat_flag)
        {
            rf_excite_location = (psd_rf_wait + pos_start + pw_gzrf1a + pw_rf1 - rfExIso) + pw_wksat_tot;
        }

        /* Calculate location of 180s */
        /* Note: To get the correct rounding, subtract pw_rf2/2 as in pulsegen, */
        /*       do the rounding, and then add it back                          */
        if (PSD_ON == dualspinecho_flag) /* Set # of 180s */
        {
            num_180s = 2;
            rf_180_location[0] = RUP_GRD((INT)rf_excite_location + hte/2 - pw_rf2/2) + pw_rf2/2;
            rf_180_location[1] = RUP_GRD((INT)rf_excite_location + 3*hte/2 - pw_rf2/2) + pw_rf2/2;
            /* fprintf(stdout,"rf_180_location[0] = %12.8f\n",rf_180_location[0]);
               fprintf(stdout,"rf_180_location[1] = %12.8f\n",rf_180_location[1]); */
        }
        else{
            num_180s = 1;
            rf_180_location[0] = RUP_GRD((INT)rf_excite_location + hte - pw_rf2/2) + pw_rf2/2;
            /* fprintf(stdout,"rf_180_location[0] = %12.8f\n",rf_180_location[0]); */
        }

        /* Calculate the bvalue for the original estimates--- */
        /* and adjust if necessary.... */
        /* MRIge61617, to enable DWEPIQ tool to run without
           download failures..note this is a kludge fix */
        /* In case epi2gspec, set diff_amp<x,y,z>[] here. */
        if (PSD_ON == different_mpg_amp_flag)
        {
            diff_ampx[0] = incdifx;
            diff_ampy[0] = incdify;
            diff_ampz[0] = incdifz;
        }
        else if (b0calmode != 1) {
            status = verify_bvalue(curr_bvalue, rf_excite_location, rf_180_location,
                                   num_180s,seq_entry_index,bmat_flag,seg_debug);
            if(status == FAILURE || status == SKIP) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "verify_bvalue()" );
                return FAILURE;
            }
        }


        /* calculate the b-matrix is allowed only for TENSOR for multi b
         * incompatibility */
        if( (calc_bmatrix_flag == TRUE) && (tensor_flag == TRUE)) bmat_flag = TRUE;

        status = calc_b_matrix(curr_bvalue, rf_excite_location, rf_180_location, 
                               num_180s, seq_entry_index, bmat_flag, seg_debug); 

        if(status == FAILURE || status == SKIP) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calc_b_matrix()" );
            return FAILURE;
        }

    } /* End exact bvalue calculation */

    return SUCCESS;
}  /* end DTI_Predownload */


@host Diffusion_Timing
/* 
 * Diffusion_Timing:
 *
 * This function is used on the host side to set up the diffusion lobe timing
 * It was moved to a function since the diffusion lobe timing is required to
 * for calculating the min and minfull TEs (avmintecalc()) on the host.  This also
 * sets up the diffusion lobe timing for the dual-spin echo case assuming the ST equ.
 * gives a reasonable timing estimate for the total width of one diffusion lobe.  It turns 
 * this provides more diffusion weighting than prescribed but it is taken care of when the 
 * actual waveforms are integrated in predownload and the dif lobe amps are adjusted.
 *
 */
static STATUS
get_diffusion_time( void )
{
    /***** Diffusion timing ****************************************/ 
    if ((opdiffuse == PSD_ON)|| (tensor_flag == PSD_ON)) {
        int tot_diff_time = 0;
        int Delta_time = 0;
        int pw_diff, pw_diffr; /* local var for calcdelta() */
        float ramp;            /* ramp time for the diff lobes */
        float bvaltemp;
        float bvaltemp_x,bvaltemp_y,bvaltemp_z;
        float gsqrsum;
        float bmax_x, bmax_y, bmax_z; /* in case the b-value is not isotropic */
        float MaxAmpx = loggrd.tx_xyz;
        float MaxAmpy = loggrd.ty_xyz;
        float MaxAmpz = loggrd.tz_xyz;
        float time_to_echo = pw_gxwad+tdaqhxa+pw_gx1_tot;
        float minMaxAmp_log = 0,minMaxAmp = 0;

        INT minRamp;

        minMaxAmp_log = FMin(3,loggrd.tx,loggrd.ty,loggrd.tz);

        derate_diffusion_amplitude(); /* Limiting the scale_all based on the max bval selected */

        if ( use_maxloggrad )
        {
            minMaxAmp = minMaxAmp_log * scale_all;
            MaxAmpx = minMaxAmp_log * scale_all;
            MaxAmpy = minMaxAmp_log * scale_all;
            MaxAmpz = minMaxAmp_log * scale_all;
        }
        else 
        {
            MaxAmpx = loggrd.tx_xyz * scale_all;
            MaxAmpy = loggrd.ty_xyz * scale_all;
            MaxAmpz = loggrd.tz_xyz * scale_all;
        }

        if((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF) || ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
        {
            /* Obl 3in1 opt */
            if (obl_3in1_opt)
            {
                MaxAmpx = target_mpg_inv * scale_all;
                MaxAmpy = target_mpg_inv * scale_all;
                MaxAmpz = target_mpg_inv * scale_all;
            }
            else
            {
                if (isRioSystem() && ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                {
                    MaxAmpx = loggrd.tx_xy * scale_all;
                    MaxAmpy = loggrd.ty_yz * scale_all;
                    MaxAmpz = loggrd.tz_xz * scale_all;
                }
                else
                {
                    MaxAmpx = loggrd.tx_xyz * scale_all;
                    MaxAmpy = loggrd.ty_xyz * scale_all;
                    MaxAmpz = loggrd.tz_xyz * scale_all;
                }
                if( !((mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag)
                    && different_mpg_amp_flag && (opdfax3in1 > PSD_OFF)) )
                {
                    MaxAmpx = FMin(3, MaxAmpx, MaxAmpy, MaxAmpz);
                    MaxAmpy = MaxAmpx;
                    MaxAmpz = MaxAmpx;
                }
            }
        }

        /* MRIhc05854: set temp variable to prescribed bvalue */
        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
        {
            bvaltemp = max_bval/3.0;
        }
        else if ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
        {
            bvaltemp = max_bval/2.0;
        }
        else
        {
            bvaltemp = max_bval;
        }

        if( (mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag) && different_mpg_amp_flag && (opdfax3in1 > PSD_OFF) )
        {
            gsqrsum = MaxAmpx*MaxAmpx + MaxAmpy*MaxAmpy + MaxAmpz*MaxAmpz;
            bvaltemp_x = MaxAmpx*MaxAmpx /  gsqrsum * max_bval;
            bvaltemp_y = MaxAmpy*MaxAmpy /  gsqrsum * max_bval;
            bvaltemp_z = MaxAmpz*MaxAmpz /  gsqrsum * max_bval;
        }
        else
        {
            bvaltemp_x = bvaltemp;
            bvaltemp_y = bvaltemp;
            bvaltemp_z = bvaltemp;
        }

        /* BJM: protect against power supply droop */
        /*      this code may seem redundant but we are calculating the diffusion */
        /*      pulse width assuming full scale amp.  If the duration is larger   */
        /*      than the spec for the CRM (~ 35ms) then the amplitude will be     */
        /*      derated to prevent power supply droop */
        
        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) || ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
        {
            minRamp = loggrd.xrta.xyz*scale_ramp;
        }
        else
        {
            minRamp = loggrd.xrta.x*scale_ramp;
        }

        /*** SVBranch: HCSDM00259119 -  mpg opt ***/
        /* For mpg opt, we may want
           to use the max grad; */
        if(mpg_opt_flag)
        {
            mpg_opt_derate = mpg_opt_glimit_orig / FMin(3, cfxfs, cfyfs, cfzfs);
            MaxAmpx = MaxAmpx * mpg_opt_derate;
            MaxAmpy = MaxAmpy * mpg_opt_derate;
            MaxAmpz = MaxAmpz * mpg_opt_derate;
            if(!isStarterSystem()) minRamp = minRamp * mpg_opt_derate;
        }
        else
        {
            mpg_opt_derate = 1.0;
        }
        /**********************/        
        
        if( gCoilType == PSD_CRM_COIL ) {
            /* X diffusion pulses */
            if (optramp(&pw_gxdla, MaxAmpx, MaxAmpx, minRamp,TYPDEF) == FAILURE) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gxdla" );
                return FAILURE;
            } 
            
            /* store ramp time in pw_diffr */
            pw_diffr = pw_gxdla;
            pw_wgxdl = get_sse_waittime();
            pw_wgxdr = 4;

            if (PSD_OFF == dualspinecho_flag)
            {
                Delta_time = pw_wgxdl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgxdr;
            } else {
                /*MRIhc06452 back to CNV4 implementation to avoid the
                 * b-value error for DSE*/ 
                Delta_time = sep_time;
            }

            if (calcdelta(optimizedTEFlag, &pw_diff, &pw_diffr,
                          Delta_time,(INT)bvaltemp, loggrd.tx_xyz) == FAILURE) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calcdelta()" );
                return FAILURE;
            }
            
            /* derate max amplitude by ratio of currents */
            if(pw_diff > MAX_CRM_DW) { 
                MaxAmpx = (FLOAT)loggrd.tx_xyz*(BRM_PEAK_AMP/cfxipeak);
                MaxAmpy = (FLOAT)loggrd.ty_xyz*(BRM_PEAK_AMP/cfyipeak);
                MaxAmpz = (FLOAT)loggrd.tz_xyz*(BRM_PEAK_AMP/cfzipeak);
            }  
        }  /* end CRM coil check */
        
        /* X diffusion pulses */
        if (optramp(&pw_gxdla, MaxAmpx, MaxAmpx, minRamp, TYPDEF) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gxdla" );
            return FAILURE;
        }
        
        /* store ramp time in pw_diffr */
        pw_diffr = pw_gxdla;
        pw_wgxdl = get_sse_waittime();
        pw_wgxdr = 4;
                  
        if (PSD_OFF == dualspinecho_flag)
        {
            Delta_time = pw_wgxdl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgxdr;
        } else {
            /*MRIhc06452 back to CNV4 implementation to avoid the
             * b-value error in DSE*/
            Delta_time =  sep_time;
        }


        /* BJM - calcdelta() - using the Stejskal-Tanner equ. */
        /*       calculate the min pulse width for the prescribed b-value */
        /*  84 update - added ramps to solution of ST equ. */
        if (calcdelta(optimizedTEFlag, &pw_diff, &pw_diffr,
                      Delta_time,(INT)bvaltemp_x, MaxAmpx) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calcdelta()" );
            return FAILURE;
        }
        
        /* set decay from attack for left lobe */
        pw_gxdla = pw_diffr;
        pw_gxdld = pw_gxdla;
        a_gxdr = a_gxdl;
        
        /* set flattop of both diffusion gradient lobes */ 
        pw_gxdl = pw_diff-pw_gxdla;
        pw_gxdr = pw_gxdl;
        
        /* set decay and attack for right lobe */
        pw_gxdra = pw_diffr;
        pw_gxdrd = pw_gxdra;
        a_gxdl = a_gxdr;            
        
        incdifx = calc_incdif(&DELTAx, &deltax, Delta_time, pw_gxdl, pw_gxdld, pw_gxdla, pw_gxdra, bvaltemp_x);

        /* MRIge49153 */
        if(incdifx > MaxAmpx)
            incdifx = MaxAmpx;

        /* BJM MRIge46730: set up the gradient ampltiude for gradient heating */
        /*     calcs use largest diffusion set if multiple b-value scan       */
        a_gxdl = incdifx;
        a_gxdr = a_gxdl;

        /* BJM: DSE timing */
        /* This code  sets up the diffusion lobes for the Dual-Spin Echo case         */
        /* The crude timing diagram is:                                               */
        /*       90 t1 A 180  -B   B  180 A t2 echo     (rough but not too bad)       */
        /*          tau1    tau2   tau3  tau4                                         */
        /*  We want:                                                                  */
        /*                    t1 + A  = B (or tau1 = tau2)                            */
        /*                       or                                                   */
        /*                     B = A + t2 (tau3 = tau4)                               */
        /*                                                                            */
        /*       the latter equ. is more restrictive since the time2echo > rfExIso    */
        /*       We are going to approximate the total diffusion time                 */
        /*       using the non-dual spin echo case (ST equ) to calculate the initial  */
        /*       diffusion time estimate.  Thus, A + B = (pw_gxdl + pw_gxdr)/2        */
        /*       which reduces to A + B = pw_gxdl since pw_gxdl = pw_gxdr             */
        /*       If you plug this in to the last equ. above, then.......              */
        /*                   A = (pw_gxdl - t2)/2                                     */
        /*                                  where t2 = tdaqhxa+gx1 timing             */

        if (PSD_ON == dualspinecho_flag)
        {
            /* 1st dif lobe pair */
            a_gxdl1 = incdifx;
            a_gxdr1 = -a_gxdl1;

            pw_gxdl1a = pw_diffr;
            pw_gxdl1d = pw_gxdl1a;

            pw_gxdl1 = RUP_GRD((pw_gxdl - time_to_echo )/2);

            pw_gxdr1a = pw_diffr;
            pw_gxdr1d = pw_gxdr1a;

            pw_gxdr1 = RUP_GRD(pw_gxdl - pw_gxdl1);

            tot_diff_time = pw_gxdl1 + pw_gxdr1;
 
            if(pw_gxdl1 < min180_echo_tim2) {
                pw_gxdl1 = min180_echo_tim2;
                pw_gxdr1 =  tot_diff_time - pw_gxdl1;
                if(pw_gxdr1 < GRAD_UPDATE_TIME)
                {
                    pw_gxdl1 = RUP_GRD(tot_diff_time/2);
                    pw_gxdr1 = RUP_GRD(tot_diff_time-pw_gxdl1);
                }
            }
          
            /* second pair */
            a_gxdl2 = incdifx;
            a_gxdr2 = -a_gxdl2;

            pw_gxdr2a = pw_diffr;
            pw_gxdr2d = pw_gxdr2a;

            pw_gxdr2 = RUP_GRD((pw_gxdr - time_to_echo)/2);

            pw_gxdl2a = pw_diffr;
            pw_gxdl2d = pw_gxdl2a;

            pw_gxdl2 = RUP_GRD(pw_gxdr - pw_gxdr2);

            tot_diff_time = pw_gxdl2 + pw_gxdr2;
 
            if(pw_gxdr2 < min180_echo_tim) {
                pw_gxdr2 = min180_echo_tim;
                pw_gxdl2 =  tot_diff_time - pw_gxdr2;
                if(pw_gxdl2< GRAD_UPDATE_TIME)
                {
                    pw_gxdr2 = RUP_GRD(tot_diff_time/2);
                    pw_gxdl2 = RUP_GRD(tot_diff_time-pw_gxdr2);
                }
            }

            /*** SVBranch: HCSDM00259119 -  DSE opt ***/
            if (dse_opt_flag)
            {
                Delta_time = GRAD_UPDATE_TIME;
                if ( FAILURE == 
                     dse_opt_timing(bvaltemp, pw_gxdl1, pw_gxdl1a, Delta_time, MaxAmpx) )
                {
                    return FAILURE;                    
                }
                /* round the pulse width to multiple of GRAD_UPDATE_TIME */               
                pw_gxdl1 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gxdr1 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gxdl2 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gxdr2 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
            }
            /************************/            
            
        }
        
        /*** SVBranch: HCSDM00259119 -  mpg opt ***/
        if (mpg_opt_flag) 
        {
            if(FAILURE == mpg_opt_timing(0, Delta_time, MaxAmpx, bvaltemp))
                return FAILURE;
        }    
        /*********************/        
        
        /* Now, get maximum b-value for fixed timing - using old limits */ 
        ramp = (1200/1.0e6);
        
        DELTAx = (float)(31000 + 1200 + Delta_time + 1200)/1.0e6;
        
        deltax = (float)(31000 + 1200)/1.0e6;
        
        /*  84 update - added ramps to solution of ST equ. */
        bmax_x = (MaxAmpx*MaxAmpx/100)*(TWOPI_GAMMA*TWOPI_GAMMA)*
            (deltax*deltax*(DELTAx - deltax/3.0)
             +(ramp*ramp*ramp)/30.0 - deltax*(ramp*ramp)/6.0 );
      
        /*MRIhc05854*/
        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF)  || ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
        {
            minRamp = loggrd.yrta.xyz*scale_ramp;
        }
        else
        {
            minRamp = loggrd.yrta.y*scale_ramp;
        }
        
        /*** SVBranch: HCSDM00259119 -  mpg opt ***/
        if(mpg_opt_flag && (!isStarterSystem())) minRamp = minRamp * mpg_opt_derate;
        /**********************/

        if (optramp(&pw_gydla, MaxAmpy, MaxAmpy,minRamp , TYPDEF) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gydla" );
            return FAILURE;
	} 
        
        /* store ramp time in pw_diffr */
        pw_diffr = pw_gydla;
        pw_wgydl = get_sse_waittime();
        pw_wgydr = 4;    
        
        if (PSD_OFF == dualspinecho_flag)
        {
            Delta_time = pw_wgydl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgydr;
        } else {
               /*MRIhc06452 bacl to CNV4 implementation to avoid the
                * b-value error in DSE*/ 
                Delta_time = sep_time;
              }



        /* BJM - calcdelta() - using the Stejskal-Tanner equ. */
        /*       calculate the min pulse width for the prescribed b-value */
        /*  84 update - added ramps to solution of ST equ. */
        if (calcdelta(optimizedTEFlag, &pw_diff, &pw_diffr,
                      Delta_time,(INT)bvaltemp_y, MaxAmpy) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calcdelta()" );
            return FAILURE;
	} 
        
        /* ramps of left lobe */ 
        pw_gydla = pw_diffr;
        pw_gydld = pw_gydla;
        
        /* flat top of both lobes */
        pw_gydl = pw_diff - pw_gydla;
        pw_gydr = pw_gydl;
        
        /* set ramps for right lobe */
        pw_gydra = pw_diffr;
        pw_gydrd = pw_gydra;

        pw_wgydl = get_sse_waittime();
        pw_wgydr = 4;
        
        /* Calculate initial amplitude estimate */

        incdify = calc_incdif(&DELTAy, &deltay, Delta_time, pw_gydl, pw_gydld, pw_gydla, pw_gydra, bvaltemp_y);

        /* MRIge49153 */
        if(incdify> MaxAmpy)
            incdify = MaxAmpy;
        
        /* Now, get maximum b-value for fixed timing - using old limits */ 
        ramp = (1200/1.0e6);
        
        DELTAy = (float)(31000 + 1200 + Delta_time + 1200)/1.0e6;
        
        deltay = (float)(31000 + 1200)/1.0e6;
        
        /*  84 update - added ramps to solution of ST equ. */
        bmax_y = (MaxAmpy*MaxAmpy/100)*(TWOPI_GAMMA*TWOPI_GAMMA)*
            (deltay*deltay*(DELTAy - deltay/3.0)
             +(ramp*ramp*ramp)/30.0 - deltay*(ramp*ramp)/6.0 );
        
        /* BJM MRIge46730: set up the gradient ampltiude for gradient heating */
        /*     calcs use largest diffusion set if multiple b-value scan       */
        a_gydl = incdify;
        a_gydr = a_gydl;
        
        /* BJM: dsp timing */
        if (PSD_ON == dualspinecho_flag)
        {
            /* 1st dif lobe pair */
            a_gydl1 = incdify;
            a_gydr1 = -a_gydl1;

            pw_gydl1a = pw_diffr;
            pw_gydl1d = pw_gydl1a;

            pw_gydl1 = RUP_GRD((pw_gydl - time_to_echo)/2);

            pw_gydr1a = pw_diffr;
            pw_gydr1d = pw_gydr1a;

            pw_gydr1 = RUP_GRD(pw_gydr - pw_gydl1);

            tot_diff_time = pw_gydl1 + pw_gydr1;
 
            if(pw_gydl1 < min180_echo_tim2) {
                pw_gydl1 = min180_echo_tim2;
                pw_gydr1 =  tot_diff_time - pw_gydl1;
                if(pw_gydr1 < GRAD_UPDATE_TIME)
                {
                    pw_gydl1 = RUP_GRD(tot_diff_time/2);
                    pw_gydr1 = RUP_GRD(tot_diff_time-pw_gydl1);
                }
            }

            /* second pair */
            a_gydl2 = incdify;
            a_gydr2 = -a_gydl2;
 
            pw_gydr2a = pw_diffr;
            pw_gydr2d = pw_gydr2a;

            pw_gydr2 = RUP_GRD((pw_gydr - time_to_echo)/2);

            pw_gydl2a = pw_diffr;
            pw_gydl2d = pw_gydl2a;

            pw_gydl2 = RUP_GRD(pw_gydr - pw_gydr2);

            tot_diff_time = pw_gydl2 + pw_gydr2;
 
            if(pw_gydr2 < min180_echo_tim) {
                pw_gydr2 = min180_echo_tim;
                pw_gydl2 =  tot_diff_time - pw_gydr2;
                if(pw_gydl2 < GRAD_UPDATE_TIME)
                {
                    pw_gydr2 = RUP_GRD(tot_diff_time/2);
                    pw_gydl2 = RUP_GRD(tot_diff_time-pw_gydr2);
                }
            }
            
            /*** SVBranch: HCSDM00259119 -  DSE opt ***/
            if (dse_opt_flag)
            {
                Delta_time = GRAD_UPDATE_TIME;
                if ( FAILURE == 
                     dse_opt_timing(bvaltemp, pw_gydl1, pw_gydl1a, Delta_time, MaxAmpy) )
                {
                    return FAILURE;                    
                }
                /* round the pulse width to multiple of GRAD_UPDATE_TIME */
                pw_gydl1 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gydr1 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gydl2 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gydr2 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
            }
            /************************/            
            
        }

        /*** SVBranch: HCSDM00259119 -  mpg opt ***/
        if (mpg_opt_flag)
        {
            if(FAILURE == mpg_opt_timing(1, Delta_time, MaxAmpy, bvaltemp))
                return FAILURE;
        } 
        /*********************/        
        
        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) || ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
        {
            minRamp = loggrd.zrta.xyz*scale_ramp;
        }
        else
        {
            minRamp = loggrd.zrta.z*scale_ramp;
        }

        /*** mpg opt ***/
        if(mpg_opt_flag && (!isStarterSystem())) minRamp = minRamp * mpg_opt_derate;
        /**********************/        
        
        if (optramp(&pw_gzdla, MaxAmpz, MaxAmpz, minRamp, TYPDEF) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gzdla" );
            return FAILURE;
	} 
        
        /* store ramp time in pw_diffr */
        pw_diffr = pw_gzdla;
        pw_wgzdl = get_sse_waittime();
        pw_wgzdr = 4;    
   
        if (PSD_OFF == dualspinecho_flag)
        {
            Delta_time = pw_wgzdl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgzdr;
        } else {
           /*MRIhc06452 back to the implementation of CNV4 to avoid the
            * b-value error in DSE*/
                Delta_time = sep_time;
              }


           
        /* BJM - calcdelta() - using the Stejskal-Tanner equ. */
        /*       calculate the min pulse width for the prescribed b-value */
        /*  84 update - added ramps to solution of ST equ. */
        if (calcdelta(optimizedTEFlag, &pw_diff, &pw_diffr,
                      Delta_time,(INT)bvaltemp_z, MaxAmpz) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calcdelta()" );
            return FAILURE;
	} 
        
        /* set ramps for left lobe */
        pw_gzdla = pw_diffr;
        pw_gzdld = pw_gzdla;
        
        /* set flat top for both lobes */
        pw_gzdl = pw_diff - pw_gzdla;
        pw_gzdr = pw_gzdl;
        
        /* set ramps for right lobe */
        pw_gzdra = pw_diffr;
        pw_gzdrd = pw_gzdra;

        pw_wgzdl = get_sse_waittime();
        pw_wgzdr = 4;
        
        /* Calculate initial amplitude estimate */
        
        incdifz = calc_incdif(&DELTAz, &deltaz, Delta_time, pw_gzdl, pw_gzdld, pw_gzdla, pw_gzdra, bvaltemp_z);
	   
        /* MRIge49153 */
        if(incdifz> MaxAmpz)
            incdifz = MaxAmpz;
        
        /* BJM MRIge46730: set up the gradient ampltiude for gradient heating */
        /*     calcs use largest diffusion set if multiple b-value scan       */
        a_gzdl = incdifz;
        a_gzdr = a_gzdl;

    	/* granty temporary edit to to calculate timings for full time diffusion encoding.*/
    	if(ftde_flag == PSD_ON){
		/* compute minimum gradient durations */
		calcpwabc(max_bval, get_sse_waittime(), pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot,MaxAmpx/100, pw_gxdla, &pw_gxdl, &pw_gxde, &pw_gxdr);
		pw_gxdr = RUP_GRD(pw_gxdr);
		pw_gxdl = RUP_GRD((get_sse_waittime() - pw_gxdla + 2*pw_gxdr)/2);
		pw_gxde = RUP_GRD(pw_gxdl - pw_gxdr - pw_gxdla);
		pw_gxdea = pw_gxdla;
		pw_gxded = pw_gxdld;

		pw_gydr = pw_gxdr;
		pw_gydl = pw_gxdl;
		pw_gyde = pw_gxde;
		pw_gydea = pw_gxdea;
		pw_gyded = pw_gxded;

		pw_gzdr = pw_gxdr;
		pw_gzdl = pw_gxdl;
		pw_gzde = pw_gxde;
		pw_gzdea = pw_gxdea;
		pw_gzded = pw_gxded;

		pw_wgzdl = 4;
		pw_wgydl = 4;
		pw_wgxdl = 4;
    	}
        
        /* BJM: (dsp) get diffusion lobe timing */
        if (PSD_ON == dualspinecho_flag)
        {
            /* 1st dif lobe pair */
            a_gzdl1 = incdifz;
            a_gzdr1 = -a_gzdl1;

            pw_gzdl1a = pw_diffr;
            pw_gzdl1d = pw_gzdl1a;

            pw_gzdl1 = RUP_GRD((pw_gzdl - time_to_echo)/2);

            pw_gzdr1a = pw_diffr;
            pw_gzdr1d = pw_gzdr1a;

            pw_gzdr1 = RUP_GRD(pw_gzdl - pw_gzdl1);

            tot_diff_time = pw_gzdl1 + pw_gzdr1;
 
            if(pw_gzdl1 < min180_echo_tim2) {
                pw_gzdl1 = min180_echo_tim2;
                pw_gzdr1 =  tot_diff_time - pw_gzdl1;
                if(pw_gzdr1 < GRAD_UPDATE_TIME)
                {
                    pw_gzdl1 = RUP_GRD(tot_diff_time/2);
                    pw_gzdr1 = RUP_GRD(tot_diff_time-pw_gzdl1);
                }
            }

            /* second pair */
            a_gzdl2 = incdifz;
            a_gzdr2 = -a_gzdl2;
       
            pw_gzdr2a = pw_diffr;
            pw_gzdr2d = pw_gzdr2a;

            pw_gzdr2 =  RUP_GRD((pw_gzdr - time_to_echo)/2);

            pw_gzdl2a = pw_diffr;
            pw_gzdl2d = pw_gzdl2a;

            pw_gzdl2 =  RUP_GRD(pw_gzdr -pw_gzdr2);

            tot_diff_time = pw_gzdl2 + pw_gzdr2;
 
            if(pw_gzdr2 < min180_echo_tim) {
                pw_gzdr2 = min180_echo_tim;
                pw_gzdl2 =  tot_diff_time - pw_gzdr2;
                if(pw_gzdl2 < GRAD_UPDATE_TIME)
                {
                    pw_gzdr2 = RUP_GRD(tot_diff_time/2);
                    pw_gzdl2 = RUP_GRD(tot_diff_time-pw_gzdr2);
                }
            }
            
            /*** DSE opt ***/
            if (dse_opt_flag)
            {
                Delta_time = GRAD_UPDATE_TIME;            
                if ( FAILURE == 
                     dse_opt_timing(bvaltemp, pw_gzdl1, pw_gzdl1a, Delta_time, MaxAmpz) )
                {
                    return FAILURE;                    
                }
                /* round the pulse width to multiple of GRAD_UPDATE_TIME */
                pw_gzdl1 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gzdr1 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gzdl2 = (int)((pw_d2+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
                pw_gzdr2 = (int)((pw_d1+GRAD_UPDATE_TIME)/GRAD_UPDATE_TIME)*GRAD_UPDATE_TIME;
            }
            /************************/           
           
        }
        
        /*** mpg opt ***/
        if (mpg_opt_flag)
        {
            if(FAILURE == mpg_opt_timing(2, Delta_time, MaxAmpz, bvaltemp))
                return FAILURE;
        }
        /*********************/        

        /* Obl 3in1 opt */
        norot_incdifx = incdifx;
        norot_incdify = incdify;
        norot_incdifz = incdifz;

        /* Now, get maximum b-value for fixed timing using old limits */ 
        ramp = (1200/1.0e6);
        
        DELTAz = (float)(31000 + 1200 + Delta_time + 1200)/1.0e6;
        
        deltaz = (float)(31000 + 1200)/1.0e6;
        
        /*  84 update - added ramps to solution of ST equ. */
        bmax_z = (MaxAmpz*MaxAmpz/100)*(TWOPI_GAMMA*TWOPI_GAMMA)*
            (deltaz*deltaz*(DELTAz - deltaz/3.0)
             +(ramp*ramp*ramp)/30.0 - deltaz*(ramp*ramp)/6.0 );

        bmax_fixed = (INT)FMin(3, bmax_x, bmax_y, bmax_z);
        
        /* round this to nearest 100 s/mm2 */
        bmax_fixed = (int)(100.0*floor((double)bmax_fixed/100.0));
    }

    if (PSD_OFF == dualspinecho_flag)
    {/* granty edit */
	if(PSD_OFF == ftde_flag){
        xdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_gxdla + pw_gxdl + pw_gxdld + pw_wgxdl : 0);
        xdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_wgxdr + pw_gxdra + pw_gxdr + pw_gxdrd : 0);
        ydiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_gydla + pw_gydl + pw_gydld + pw_wgydl : 0);
        ydiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_wgydr + pw_gydra + pw_gydr + pw_gydrd : 0);
        zdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_gzdla + pw_gzdl + pw_gzdld + pw_wgzdl : 0);
        zdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_wgzdr + pw_gzdra + pw_gzdr + pw_gzdrd : 0);
    }else{
            xdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                    pw_gxdla + pw_gxdl + pw_gxdld + pw_wgxdl + pw_gxde + pw_gxdea + pw_gxded : 0);
            xdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                        pw_wgxdr + pw_gxdra + pw_gxdr + pw_gxdrd : 0);
            ydiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_gydla + pw_gydl + pw_gydld + pw_wgydl + pw_gyde + pw_gydea + pw_gyded : 0);
            ydiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_wgydr + pw_gydra + pw_gydr + pw_gydrd : 0);
            zdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_gzdla + pw_gzdl + pw_gzdld + pw_wgzdl + pw_gzde + pw_gzdea + pw_gzded : 0);
            zdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       pw_wgzdr + pw_gzdra + pw_gzdr + pw_gzdrd : 0);
    }
    } 
    else {
        xdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_gxdl1a + pw_gxdl1 + pw_gxdl1d + pw_wgxdl1) + 
                       (pw_gxdl2a + pw_gxdl2 + pw_gxdl2d + pw_wgxdl2) : 0);
        xdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_wgxdr1 + pw_gxdr1a + pw_gxdr1 + pw_gxdr1d) + 
                       (pw_wgxdr2 + pw_gxdr2a + pw_gxdr2 + pw_gxdr2d) : 0);
        ydiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_gydl1a + pw_gydl1 + pw_gydl1d + pw_wgydl1) + 
                       (pw_gydl2a + pw_gydl2 + pw_gydl2d + pw_wgydl2) : 0);
        ydiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_wgydr1 + pw_gydr1a + pw_gydr1 + pw_gydr1d) + 
                       (pw_wgydr2 + pw_gydr2a + pw_gydr2 + pw_gydr2d) : 0);
        zdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_gzdl1a + pw_gzdl1 + pw_gzdl1d + pw_wgzdl1) + 
                       (pw_gzdl2a + pw_gzdl2 + pw_gzdl2d + pw_wgzdl2) : 0);
        zdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ? 
                       (pw_wgzdr1 + pw_gzdr1a + pw_gzdr1 + pw_gzdr1d) + 
                       (pw_wgzdr2 + pw_gzdr2a + pw_gzdr2 + pw_gzdr2d) : 0);
    }

    return SUCCESS;
} /* end diffusion_timing */

#include "ftde.c" /* granty edit */

/*
 * Update SSE manual TE Diffusion_Timing:
 *
 * This function is will update pw_wgx(y,z)dl and incdifx(y,z,) for single-spinecho diffusion in manual TE mode
 *
 */
static STATUS update_sse_diffusion_time( void )
{
    int Delta_time;
    float bvaltemp;
    float bvaltemp_x,bvaltemp_y,bvaltemp_z;

    float gsqrsum;

    float MaxAmpx = loggrd.tx_xyz;
    float MaxAmpy = loggrd.ty_xyz;
    float MaxAmpz = loggrd.tz_xyz;

    if(sse_manualte_derating_debug == PSD_ON)
    {
        FILE *fp= NULL;
#ifdef PSD_HW
        const char *dir_log = "/usr/g/service/log";
#else
        const char *dir_log = ".";
#endif
        char fname[255];

        sprintf(fname, "%s/epi2_diffusion_derating.txt", dir_log);
        if ( NULL != (fp = fopen(fname, "w")) )
        {
            fprintf(fp, "Before update_sse_diffusion_time(): \n");
            fprintf(fp, "pw_wgxdl: %d, pw_wgydl:%d, pw_wgzdl:%d \n", pw_wgxdl, pw_wgydl, pw_wgzdl);
            fprintf(fp, "a_gxdl: %f, pw_gxdl:%d\n", a_gxdl, pw_gxdl);
            fprintf(fp, "tmin_total: %d\n\n", tmin_total);

            fclose(fp);
        }
    }

    /***** Update Diffusion timing ****************************************/

    /* MRIhc05854: set temp variable to prescribed bvalue */
    if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
    {
        bvaltemp = max_bval/3.0;
    }
    else if ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
    {
        bvaltemp = max_bval/2.0;
    }
    else
    {
        bvaltemp = max_bval;
    }

    if( (mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag) && different_mpg_amp_flag && (opdfax3in1 > PSD_OFF) )
    {
        gsqrsum = MaxAmpx*MaxAmpx + MaxAmpy*MaxAmpy + MaxAmpz*MaxAmpz;
        bvaltemp_x = MaxAmpx*MaxAmpx /  gsqrsum * max_bval;
        bvaltemp_y = MaxAmpy*MaxAmpy /  gsqrsum * max_bval;
        bvaltemp_z = MaxAmpz*MaxAmpz /  gsqrsum * max_bval;
    }
    else
    {
        bvaltemp_x = bvaltemp;
        bvaltemp_y = bvaltemp;
        bvaltemp_z = bvaltemp;
    }

    int cur_minte;
    if (exist(opte) >= avmintefull)
    {
        cur_minte = avmintefull;
    }
    else
    {
        cur_minte = avminte;
    }

    if(smart_numoverscan == PSD_ON)
    {
        pw_wgxdl = IMax(2, RDN_GRD(get_sse_waittime() + (exist(opte) - cur_minte)/2 - psd_rf_wait), 4);
        pw_wgydl = pw_wgxdl;
        pw_wgzdl = pw_wgxdl;
    }
    else /*for debug and testing purpose, when smart_numoverscan is OFF*/
    {
        pw_gxdl += RDN_GRD((exist(opte) - cur_minte)/2);
        pw_gxdr = pw_gxdl;

        pw_gydl = pw_gxdl;
        pw_gydr = pw_gydl;

        pw_gzdl = pw_gxdl;
        pw_gzdr = pw_gzdl;
    }

    Delta_time = pw_wgxdl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgxdr;

    incdifx = calc_incdif(&DELTAx, &deltax, Delta_time, pw_gxdl, pw_gxdld, pw_gxdla, pw_gxdra, bvaltemp_x);

    a_gxdl = incdifx;
    a_gxdr = a_gxdl;

    Delta_time = pw_wgydl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgydr;

    incdify = calc_incdif(&DELTAy, &deltay, Delta_time, pw_gydl, pw_gydld, pw_gydla, pw_gydra, bvaltemp_y);

    a_gydl = incdify;
    a_gydr = a_gydl;

    Delta_time = pw_wgzdl + pw_gzrf2l1_tot + pw_gzrf2 + pw_gzrf2r1_tot + pw_wgzdr;

    incdifz = calc_incdif(&DELTAz, &deltaz, Delta_time, pw_gzdl, pw_gzdld, pw_gzdla, pw_gzdra, bvaltemp_z);

    a_gzdl = incdifz;
    a_gzdr = a_gzdl;

    xdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_gxdla + pw_gxdl + pw_gxdld + pw_wgxdl : 0);
    xdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_wgxdr + pw_gxdra + pw_gxdr + pw_gxdrd : 0);
    ydiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_gydla + pw_gydl + pw_gydld + pw_wgydl : 0);
    ydiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_wgydr + pw_gydra + pw_gydr + pw_gydrd : 0);
    zdiff_time1 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_gzdla + pw_gzdl + pw_gzdld + pw_wgzdl : 0);
    zdiff_time2 = (((opdiffuse==1)|| tensor_flag == PSD_ON) ?
        pw_wgzdr + pw_gzdra + pw_gzdr + pw_gzdrd : 0);

    if(sse_manualte_derating_debug == PSD_ON)
    {
        FILE *fp= NULL;
#ifdef PSD_HW
        const char *dir_log = "/usr/g/service/log";
#else
        const char *dir_log = ".";
#endif
        char fname[255];

        sprintf(fname, "%s/epi2_diffusion_derating.txt", dir_log);
        if ( NULL != (fp = fopen(fname, "a")) )
        {
            fprintf(fp, "After update_sse_diffusion_time(): \n");
            fprintf(fp, "pw_wgxdl: %d, pw_wgydl:%d, pw_wgzdl:%d \n", pw_wgxdl, pw_wgydl, pw_wgzdl);
            fprintf(fp, "opte: %d, cur_minte: %d, RUP_GRD((exist(opte) - cur_minte)/2):%d \n",exist(opte), cur_minte, RDN_GRD((exist(opte) - cur_minte)/2));
            fprintf(fp, "a_gxdl: %f, pw_gxdl:%d\n\n", a_gxdl, pw_gxdl);
            fprintf(fp, "tmin_total: %d\n", tmin_total);
            fclose(fp);
        }
    }

    return SUCCESS;
} /* end SSE manual TE diffusion_timing */

/* calculate incdifx,y,z */
static FLOAT calc_incdif(float *DELTA, float *delta, int Delta_time, int pw_gdl, int pw_gdld, int pw_gdla, int pw_gdra, float bvaltemp)
{
    float ramp;
    FLOAT incdif;
    *DELTA = (float)(pw_gdl + pw_gdld + Delta_time + pw_gdra)/1.0e6;
    *delta = (float)(pw_gdl + pw_gdla)/1.0e6;
    ramp = pw_gdla/1.0e6;
    /*  84 update - added ramps to solution of ST equ. */
    incdif = 10.0*sqrt((float)bvaltemp /
                        (TWOPI_GAMMA*TWOPI_GAMMA*
                            ((float)*delta * (float)*delta*((float)*DELTA - (float)*delta/3.0)+
                                ((ramp*ramp*ramp)/30.0) - (float)*delta*(ramp*ramp)/6.0 )));
    return incdif;
}

/* Get gap time between the left diffusion gradient lobe and refocusing pulse */
static INT get_sse_waittime(void)
{
    INT waittime;
    float temp_area_gy1; /* HCSDM00194511 */
    int extra_tetime;

    if((exist(opdiffuse) == PSD_OFF) || (dualspinecho_flag == PSD_ON) || (sse_enh == PSD_OFF))
    {
        return 4;
    }

    temp_area_gy1 = area_gy1;
    get_gy1_time();
    area_gy1 = temp_area_gy1;

    get_flowcomp_time();
    extra_tetime = get_extra_dpc_tetime();

    if (gx1pos == PSD_POST_180) {
        avminxa = rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) +
                    pw_gzrf2l1_tot + (pw_rf2/2);
        avminxb = 8us + pw_rf2/2 + pw_gzrf2r1_tot + pw_wgx + pw_gxwad + tdaqhxa +
                    IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot);
    } else {
        avminxa = rfExIso + IMax(2, pw_gx1_tot, pw_gyex1_tot);
        avminxb = tdaqhxa + pw_wgx + pw_rf2/2;
    }
    avminxa += extra_tetime;

    if (gy1pos == PSD_POST_180) {
        avminya = rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) +
                    pw_gzrf2l1_tot + (pw_rf2/2);
        avminyb = 8us + pw_rf2/2 + pw_gzrf2r1_tot + pw_wgy + pw_gxwad +  tdaqhxa +
                    IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot);
    } else {
        avminya = rfExIso + pw_gyex1_tot + pw_gy1_tot + pw_wgy;
        avminyb = pw_rf2/2 + pw_gxwad + IMax(2, pw_gx1_tot, pw_gzrf2r1_tot);
    }
    avminya += extra_tetime;

    avminza = rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) +
                pw_gzrf2l1_tot + (pw_rf2/2);
    avminzb = 8us + pw_rf2/2 + pw_gzrf2r1_tot +  pw_wgz + pw_gxwad +  tdaqhxa +
                IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot);
    avminza += extra_tetime;

    waittime = IMin(3, (avminxb > avminxa ? RDN_GRD(avminxb-avminxa) : 4),
                       (avminyb > avminya ? RDN_GRD(avminyb-avminya) : 4),
                       (avminzb > avminza ? RDN_GRD(avminzb-avminza) : 4));
    waittime = IMax(2, RDN_GRD(waittime-psd_rf_wait), 4);

    return waittime;
}

static INT 
derate_diffusion_amplitude(void)
{
    if ( ((isRioSystem()) && (exist(opdiffuse)==PSD_ON)) || ((!epi2spec_mode) &&
          ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) ||
          ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))) )
    {
        switch(gCoilType)
        {
        case PSD_HRMW_COIL:
            scale_all = 1.0;

            if (exist(opmintedif) == PSD_OFF)
            {
                if((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF) ||
                    ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                {
                    scale_gmax = 1.0;
                }
                else if (((opdfaxx > PSD_OFF) || (opdfaxy > PSD_OFF) || (opdfaxz > PSD_OFF)) &&
                    (superG_key_status == PSD_ON) && (opdfaxall == PSD_OFF))
                { /*single direction diffusion, allow spherical derating when superG is available*/
                    float comp_max;
                    comp_max = FMax(3,cfxfs,cfyfs,cfzfs); /*orthogonal plane*/
                    
                    if (exist(opplane) == PSD_OBL)/*oblique plane: calculate the projection of logical Z on the physical axis*/
                    {
                        comp_max *= FMax(3, fabs(scan_info[0].oprot[2]),
                                            fabs(scan_info[0].oprot[5]),
                                            fabs(scan_info[0].oprot[8]));                        
                    }
                    scale_gmax = FMin(2, 1.0, spherical_derating_limit / comp_max);
                }
                else
                {
                    if (diff_order_flag == 2)
                    {
                        scale_gmax = FMin(2, 1.0, (268.6*pow(max_bval/1000, -0.5389)+613.4)/FMin(3,cfxipeak,cfyipeak,cfzipeak));
                    }
                    else if (diff_order_flag == 1)
                    {
                        scale_gmax = FMin(2, 1.0, (219.6*pow(max_bval/1000, -0.6208)+619.6)/900);
                    }
                    else
                    {
                        scale_gmax = 1.0;
                    }
                }
                scale_all *= scale_gmax;
            }
            break;
        case PSD_XRMB_COIL:
            if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
            {
                scale_all = 0.9;
            }
            else
            { 
                scale_all = 0.8;
            }
            break;

        case PSD_XRMW_COIL:
            if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
            {
                scale_all = 0.9;
            }
            else
            { 
                scale_all = 0.75;
            }
            break;

        case PSD_VRMW_COIL:
            if( mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag )
            {
                scale_all = 1.0;
            }
            else if(PSD_ON == adaptive_mpg_glim_flag)
            {
                scale_all = adaptive_mpg_glim / FMin(3, cfxfs, cfyfs, cfzfs);
            }
            else
            {
                if((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
                {
                    scale_all = 2.02 / 3.3;
                }
                else
                {
                    scale_all = 2.4 / 3.3;
                }
            }

            break;

        case PSD_TRM_COIL:
            if ( cfsrmode == PSD_SR150 || ( exist( opgradmode ) == TRM_ZOOM_COIL && existcv( opgradmode ) ) )
            {
                if(max_bval <= 700)
                {
                    if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                    {
                        scale_all = 0.78;
                    }
                    else if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                    {
                        scale_all = 0.9;
                    }
                }
                else /* bval > 700 */
                { 
                    if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                    {
                        scale_all = 0.76;
                    }
                    else if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                    {
                        scale_all = 0.88;
                    }
                }
            }
            else
            {
                if ( cfsrmode == PSD_SR77 || ( exist( opgradmode ) == TRM_BODY_COIL && existcv( opgradmode ) ) )
                {
                    if(max_bval <= 700) 
                    {
                        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                        {
                            scale_all = 0.68;
                        }
                        else if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                        {
                            scale_all = 0.8;
                        }
                    }
                    else /* bval > 700 */
                    { 
                        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                        {
                            scale_all = 0.68;
                        }
                        else if((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                        {
                            scale_all = 0.78;
                        }
                    }
                }
            }
            break;

        case PSD_60_CM_COIL:
        case PSD_BRM2_COIL:
            if(max_bval <=700)
            {
                if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                {
                    scale_all = 0.7;
                }
                else if ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                {
                    scale_all = 0.8;
                }
            }
            else /* bval > 700 */
            {
                if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF ))
                {
                    scale_all = 0.68;
                }
                else if ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
                {
                    scale_all = 0.8;
                }
            }
            break;

        default:
            scale_all = 1.0;
            break;
        }
        if(isStarterSystem() && ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) ||
          ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))))
        {
            scale_all = 0.818;
        }
    }
    else if (epi2spec_mode)
    {
        scale_all = 1.0;
    }
    else
    {
        if (5550 == cfgradamp) /* SSSD */
        {
            if(PSD_ON == adaptive_mpg_glim_flag)
            {
                scale_all = adaptive_mpg_glim / FMin(3, cfxfs, cfyfs, cfzfs);
            }
            else
            {
                scale_all = 3.16 / 3.3;
            }
        }
        else
        {
            scale_all = 1.0;
        }
    }

   return SUCCESS;
}

@host DTI_Orientations
/*
 * BJM 4/25/00 - set_tensor_orientations()
 *
 * This function is designed to either read the tensor directions from a
 * file on disk called tensor.dat (/usr/g/bin) or call calc_orientations()
 * to generate a distribution of points on a hemisphere using a method
 * developed by Joe Zhou and Aziz Poonwalla from MDACC.
 * This function is called @ the end of predownload since we only need
 * this information just prior to download.
 */
static INT
set_tensor_orientations( void )
{
    int read_from_file = PSD_ON;
    int j;

    if( (read_from_file == PSD_ON)  && (tensor_flag == PSD_ON )) {
        FILE *fp;                           /* file pointer */
        char filestring[MAXCHAR];           /* buffer used to open data file */ 
        char compstring[MAXCHAR];           /* buffer used to open data file */ 
        char tempstring[MAXCHAR];           /* buffer to access file */
        int max_chars_per_line = MAXCHAR;   /* lines in tensor.dat header */ 
        int num_tensor_len;
#ifndef SIM
        const char *tensor_datapath="/usr/g/bin/";/* path to tensor.dat files - hw  */
        char tensor_datafile[80]; /* filename of tensor.dat file */
        if (rhtensor_file_number == 0)
        {
            sprintf(tensor_datafile, "tensor.dat");
        }
        else 
        {
            sprintf(tensor_datafile, "tensor%d.dat", rhtensor_file_number);
        }
#else /* !SIM */
        const char *tensor_datapath="./";         /* path to tensor.dat files - sim */
        char tensor_datafile[80];                    /* filename of tensor.dat file */

        if (rhtensor_file_number == 0)
        {
            if(PSD_VRMW_COIL == gCoilType)
            {
                sprintf(tensor_datafile, "tensor.dat.VRMW");
            }
            else
            {
                sprintf(tensor_datafile, "tensor.dat.default");
            }
        }
        else 
        { 
            sprintf(tensor_datafile, "tensor%d.dat", rhtensor_file_number);
        }
#endif /* SIM */
        
        /* Check tensor file. Move check here to get the right response to user. */
        if (PSD_ON == exist(opresearch))
        {
            if ( ((0 != rhtensor_file_number) && (rhtensor_file_number < TENSOR_FILE_RSRCH_START))  ||
                    (rhtensor_file_number > TENSOR_FILE_RSRCH_MAX) )
            {
                epic_error( use_ermes, "%s is out of range", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _rhtensor_file_number.descr);
                return FAILURE;
            }
        }
        else
        {   /* Not available in Clinical Mode */
            if ( 0 != rhtensor_file_number )
            {
                epic_error( use_ermes, "%s is out of range", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _rhtensor_file_number.descr);
                return FAILURE;
            }
        }
        
        
        /* Setup for file search - set the number of directions requested */
        sprintf( compstring, "%d", num_tensor );
        num_tensor_len = strlen( compstring );

        /* Set tensor.dat file path and append filename base and suffix */
        strcpy( filestring, tensor_datapath );
        strcat( filestring, tensor_datafile );

        /* Open file */
        if( (fp = fopen( filestring, "r" )) == NULL ) {
            char err_string[300];
            sprintf(err_string, "Can't read %s\n", filestring);
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, err_string );
            validTensorFile = 0;
            return ADVISORY_FAILURE;
        }
        validTensorFile = 1;

        /*
         * The tensor.dat file is a concatanation of several files.
         * We need to skip over all the lines until we reach the location
         * that stores the "num_tensor" orientations.
         */
        {
            int read_skip = 1;

            while( read_skip ) {
                if (fgets( tempstring, max_chars_per_line, fp ) == NULL)
                {   /* Error response to user if the file cannot be read for the user-desired entry */
                    fclose(fp); /* PWW */
                    epic_error( use_ermes, supfailfmt, 
                            EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "Can't find entry in tensor file");
                    validTensorFileAndEntry = 0;
                    return ADVISORY_FAILURE;
                }
                read_skip = strncmp( compstring, tempstring, num_tensor_len );
            }
            validTensorFileAndEntry = 1;
        }
 
        if(debugTensor == PSD_ON) {
           printf( "Tensor Directions Read (Host) = %d\n", num_tensor );
        }

        /*
         * Next, after reaching the desired point in the file           
         * iterate over num_tensor & put the data in TENSOR_HOST[i][j] 
         */

        /* BJM: assign the T2 images first - want multiple B = 0 images */
        for( j = 0; j < num_B0; ++j ) {
            TENSOR_HOST[0][j] = TENSOR_HOST[1][j] = TENSOR_HOST[2][j] = 0.0;

            if(debugTensor == PSD_ON) {
                printf( "Tensor direction on \n");
                printf( "T2 #%d, X = %f, Y=%f, Z= %f\n", j, TENSOR_HOST[0][j], TENSOR_HOST[1][j], TENSOR_HOST[2][j] );
                fflush( stdout );
            }

        }

        /* Now do the rest of the shots */
        /*  Skip the multiple B = 0 images.  Start at num_B0 plus 1 in
            the TENSOR_HOST[][] array. */
        for ( j = num_B0; j < num_tensor + num_B0; ++j ) {          
            if( fgets( tempstring, MAXCHAR, fp ) == NULL ) { 
                printf( "ERROR: invalid tensor.dat file format!\n" ); 
            }          
            sscanf( tempstring, "%f %f %f", &TENSOR_HOST[0][j], &TENSOR_HOST[1][j], &TENSOR_HOST[2][j] );

            if(debugTensor == PSD_ON) {
                printf( "Shot = %d, X = %f, Y=%f, Z= %f\n", j, TENSOR_HOST[0][j], TENSOR_HOST[1][j], TENSOR_HOST[2][j] );
                fflush( stdout );
            }
        }

        fclose(fp); 

        /*Confirm the magnitude of the vectors are less than MAX_TENSOR_VECTOR_MAG*/
        int i;
        for(i= num_B0; i < num_tensor + num_B0; i++)
        {
            mag[i] = sqrt(TENSOR_HOST[0][i]*TENSOR_HOST[0][i] +
                          TENSOR_HOST[1][i]*TENSOR_HOST[1][i] +
                          TENSOR_HOST[2][i]*TENSOR_HOST[2][i] );

            if (mag[i]> MAX_TENSOR_VECTOR_MAG)
            {
                epic_error( use_ermes, "Support routine %s failed: tensor vectors shall not have magnitudes > 1.0",
                            EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "set_tensor_orientations()" );
                return FAILURE;
            }
        }

        if ( (isRioSystem()) && (num_tensor > MAX_NUM_ITERS))
        {
            tensor_host_sort_flag = PSD_ON;
        }
        else
        {
            tensor_host_sort_flag = PSD_OFF;
        }

        if ( (isRioSystem()) && (PSD_ON == tensor_host_sort_flag))
        {
            int status;

            if ( (status = sort_tensor_orientations()) != SUCCESS)
            {
                return status;
            }
        }


    } else if ( (read_from_file == PSD_ON)  && (opdiffuse == PSD_ON) && (tensor_flag == PSD_OFF) && (opdfaxtetra == PSD_OFF) && (opdfax3in1 == PSD_OFF )) 
    { /* DWI */
       for( j = 0; j < opdifnumt2; ++j ) {
            TENSOR_HOST[0][j] = TENSOR_HOST[1][j] = TENSOR_HOST[2][j] = 0.0;

            if(debugTensor == PSD_ON) {
                printf( "Tensor direciton on \n");
                printf( "T2 #%d, X = %f, Y=%f, Z= %f\n", j, TENSOR_HOST[0][j], 
                        TENSOR_HOST[1][j], TENSOR_HOST[2][j] );
                fflush( stdout );
            }

        }
        if( opdfaxall > PSD_OFF ) {
            j = opdifnumt2;

            if(gradopt_diffall == PSD_OFF)
            {
                TENSOR_HOST[0][j] = 1.0;
                TENSOR_HOST[1][j] = 0.0;
                TENSOR_HOST[2][j] = 0.0;
                TENSOR_HOST[0][j+1] = 0.0;
                TENSOR_HOST[1][j+1] = 1.0;
                TENSOR_HOST[2][j+1] = 0.0;
                TENSOR_HOST[0][j+2] = 0.0;
                TENSOR_HOST[1][j+2] = 0.0;
                TENSOR_HOST[2][j+2] = 1.0;
            }
            else
            {
                TENSOR_HOST[0][j] = 1.0;
                TENSOR_HOST[1][j] = 1.0;
                TENSOR_HOST[2][j] = 0.0;
                TENSOR_HOST[0][j+1] = 1.0/sqrt(2.0);
                TENSOR_HOST[1][j+1] = -1.0/sqrt(2.0);
                TENSOR_HOST[2][j+1] = 1.0;
                TENSOR_HOST[0][j+2] = -1.0/sqrt(2.0);
                TENSOR_HOST[1][j+2] = 1.0/sqrt(2.0);
                TENSOR_HOST[2][j+2] = 1.0;
            }
           
        }
        else if( opdfaxx > PSD_OFF ) {
            j = opdifnumt2;

            TENSOR_HOST[0][j] = 1.0;
            TENSOR_HOST[1][j] = 0.0;
            TENSOR_HOST[2][j] = 0.0;
        }
        else if( opdfaxy > PSD_OFF ) {
            j = opdifnumt2;

            TENSOR_HOST[0][j] = 0.0;
            TENSOR_HOST[1][j] = 1.0;
            TENSOR_HOST[2][j] = 0.0;
        }
        else if( opdfaxz > PSD_OFF ) {
            j = opdifnumt2;

            TENSOR_HOST[0][j] = 0.0;
            TENSOR_HOST[1][j] = 0.0;
            TENSOR_HOST[2][j] = 1.0;
        } 
     } else if ( (read_from_file == PSD_ON)  && (opdiffuse == PSD_ON) && (tensor_flag == PSD_OFF) && (opdfaxtetra > PSD_OFF) && (opdfax3in1 == PSD_OFF )) 
     { /* tetrahedral */
         for( j = 0; j < opdifnumt2; ++j ) { 
             TENSOR_HOST[0][j] = TENSOR_HOST[1][j] = TENSOR_HOST[2][j] = 0.0;

             if(debugTensor == PSD_ON) { 
                 printf( "Tensor direciton on \n"); 
                 printf( "T2 #%d, X = %f, Y=%f, Z= %f\n", j, TENSOR_HOST[0][j], 
                         TENSOR_HOST[1][j], TENSOR_HOST[2][j] ); 
                 fflush( stdout ); 
             } 
         } 
         j = opdifnumt2; 
         
         TENSOR_HOST[0][j]   = 1.0; TENSOR_HOST[1][j]   = 1.0; TENSOR_HOST[2][j]   = 1.0; 
         TENSOR_HOST[0][j+1] = 1.0; TENSOR_HOST[1][j+1] =-1.0; TENSOR_HOST[2][j+1] =-1.0; 
         TENSOR_HOST[0][j+2] =-1.0; TENSOR_HOST[1][j+2] =-1.0; TENSOR_HOST[2][j+2] = 1.0; 
         TENSOR_HOST[0][j+3] =-1.0; TENSOR_HOST[1][j+3] = 1.0; TENSOR_HOST[2][j+3] =-1.0; 
     } else if ( (read_from_file == PSD_ON)  && (opdiffuse == PSD_ON) && (tensor_flag == PSD_OFF) && (opdfaxtetra == PSD_OFF) && (opdfax3in1 > PSD_OFF ))
     { /* 3 in 1 */
       for( j = 0; j < opdifnumt2; ++j ) { 
           TENSOR_HOST[0][j] = TENSOR_HOST[1][j] = TENSOR_HOST[2][j] = 0.0;

           if(debugTensor == PSD_ON) { 
               printf( "Tensor direciton on \n"); 
               printf( "T2 #%d, X = %f, Y=%f, Z= %f\n", j, TENSOR_HOST[0][j], 
                       TENSOR_HOST[1][j], TENSOR_HOST[2][j] ); 
               fflush( stdout ); 
           } 
       }

       j = opdifnumt2; 

       TENSOR_HOST[0][j] = 1.0; 
       TENSOR_HOST[1][j] = 1.0; 
       TENSOR_HOST[2][j] = 1.0;

     } else {
        /* Assign the T2 image first */
        TENSOR_HOST[0][0] = TENSOR_HOST[1][0] = TENSOR_HOST[2][0] = 0.0;

        /*
         * BJM: Generate tensor directions by parsing the unit hemisphere.
         *      This is a implmenetation of Aziz and Joe's perl script from
         *      MDACC.
         */
        calc_orientations();
    }

    return SUCCESS;

}   /* end set_tensor_orientations() */


/*
 * sort_tensor_orientations():
 *
 * This function sorts the amplitudes of TENSOR_HOST vectors and
 * save their indexes in to sort_index array
 *
 */
static INT sort_tensor_orientations(void)
{
    int used_index[MAX_DIRECTIONS + MAX_T2] = {0};

    int i, j, k;
    int max_index = 0;
    float max = 0.0;

    for(i = num_B0; i < num_tensor + num_B0; i++)
    {
        used_index [i] = 0;
    }

    for (j=0; j< num_iters; j++)
    {
        /*find the first untaken element for starting the comparison*/
        for(k= num_B0; k < num_tensor + num_B0; k++)
        {
            if(used_index[k] == 0)
            {
                max = mag[k];
                max_index = k;
                break;
            }
        }
        /*start from the next for searching*/
        for(i= k+1; i < num_tensor + num_B0; i++)
        {
            /*find the largest un-taken one*/
            if((mag[i]> max) && (used_index[i]== 0))
            {
                max = mag[i];
                max_index = i;
            }
        }
        /*save the max index and flag this index as used*/
        sort_index[j] = max_index;
        used_index[max_index] = 1;
    }

    if(tensor_host_sort_debug == PSD_ON)
    {
        FILE *fp2= NULL;

#ifdef PSD_HW
        const char *dir_log = "/usr/g/service/log";
#else
        const char *dir_log = ".";
#endif
        char fname[255];

        sprintf(fname, "%s/tensor_host_sort.log", dir_log);
        if (NULL != (fp2 = fopen(fname, "w")))
        {
            fprintf(fp2,"\n========\n");
            fprintf(fp2, "num_iters = %d \n", num_iters);
            fprintf(fp2, "num_tensor = %d \n", num_tensor);
            fprintf(fp2, "TENSOR_HOST:\n");

            for (i = 0; i< num_B0 + num_tensor; i++)
            {
                fprintf(fp2,"%d: :%2.6f %2.6f %2.6f\n", i,
                        TENSOR_HOST[0][i], TENSOR_HOST[1][i],TENSOR_HOST[2][i]);
            }

            fprintf(fp2,"\nActual order of tensor vectors used in cornerPoints\n");
            fprintf(fp2, "num_iters = %d \n", num_iters);
            fprintf(fp2, "num_tensor = %d \n", num_tensor);

            for (i = 0; i< num_iters; i++)
            {
                fprintf(fp2,"%d: index:%d\t, host:%2.6f %2.6f %2.6f, mag:%1.5f\n", i, sort_index[i],
                        TENSOR_HOST[0][sort_index[i]], TENSOR_HOST[1][sort_index[i]],
                        TENSOR_HOST[2][sort_index[i]], mag[sort_index[i]]);
            }
            fclose(fp2);
        }
    }

    return SUCCESS;

}/* End sort_tensor_orientations() */

/* THIS IS NOT USED BUT IS KEPT FOR HISTORICAL REASONS 
 * WE ARE USING POINTS THAT ARE UNIFORMLY DISTRIBUTED ABOUT A UNIT SPHERE 
 * BJM: this function generates the b-vector orientations via a simple geometric method 
 * the goal is to produce a set of b-vectors that are evenly distributed about the 
 * unit sphere.  This is done by assigning each vector with a solid angle or patch area 
 * on the unit sphere.  The patch area is determined by dividing the solid angle of the 
 * the hemisphere by the number of b-vectors desired.  Using this patch area, the number 
 * latitude increment (theta) is determined.  Each theta defines an area of a spherical 
 * "cap".  The difference in area between caps given by (theta) and (theta+dt) define a 
 * "band" of surface area around the sphere.  Dividing this band of area by the patch area 
 * provides the number of phi increments (vectors for that band).  This process is repeated 
 * until all the vectors are assigned. Note: this process is not perfect but is close enough 
 * for most government work plus its much faster than some non-linear minimization of forces!! 
 * Credits: MDACC's Joe Zhou and Aziz Poonawalla for the original PERL script (thanks guys)
 */
static INT
calc_orientations( void )
{
    int i,j;
    int num_lat, num_phi; 
    int index = 2;                            /* This starts at 2 since t2 and 1st b-vector assigned */

    float area_hemi = TWO_PI;                 /* Area of half unit sphere */
    float area_patch = area_hemi/num_tensor;  /* How much area per vector ? */     
    float Theta = 0.0;                        /* Theta describing each B vector */
    float Phi = 0.0;                          /* Phi describing each B vector */
    float dphi;
    float td, dt;                             /* td: latitude angle, dt: latitude increment */
    float ha, hb, hdiff;                      /* heights of spherical caps and difference */
    float area_cap1, area_cap2, area_band;    /* area of two caps, area_band = the difference */


    td = acos(1 - 1.0/(num_tensor));   /* solve for theta using solid angle formula: */
    /*   2*pi/(num b-vector) = 2*pi(1-cos(theta)) */
    dt = 2*td;                         /* increment will be twice theta */
    num_lat = floor(PI/dt);            /* how many latitude angles should we expect */

    /* recompute the latitude increment */
    dt = (TWO_PI/2.0)/num_lat;

    /* start with first b-vector along z-axis */
    TENSOR_HOST[0][1] =  0.0;  /* X gradient Amp */
    TENSOR_HOST[1][1] =  0.0;  /* Y gradient Amp */
    TENSOR_HOST[2][1] =  1.0;  /* Z gradient Amp */

    if(debugTensor) {
        printf("Shot Number = %d\n",0);
        printf("Theta = %f\n",0.);
        printf("Delta Theta = %f\n", dt);
        printf("Phi = %f\n", 0.);
        printf("Delta Phi = %f\n",0.);
        printf("X-Diffusion Amp = %f\n",TENSOR_HOST[0][0]);
        printf("Y-Diffusion Amp = %f\n",TENSOR_HOST[1][0]);
        printf("Z-Diffusion Amp = %f\n\n",TENSOR_HOST[2][0]);

        printf("Shot Number = %d\n",1);
        printf("Theta = %f\n",0.);
        printf("Delta Theta = %f\n", dt);
        printf("Phi = %f\n", 0.);
        printf("Delta Phi = %f\n",0.);
        printf("X-Diffusion Amp = %f\n",TENSOR_HOST[0][1]);
        printf("Y-Diffusion Amp = %f\n",TENSOR_HOST[1][1]);
        printf("Z-Diffusion Amp = %f\n\n",TENSOR_HOST[2][1]);


    }
    /* loop over the latitudes */
    for (i = 1; i <= num_lat; i++) {      

        /* Increment Theta (T) by an amount dt - since we've assigned z already */
        Theta += dt; 

        /* calc. two heights and their difference using simple geometry */
        ha = cos(Theta);
        hb = cos(Theta+dt);
        hdiff = (ha - hb);

        /* area_a = the surface area of a spherical cap (= 2pi*rad*height) */
        /* and so is area_b with a different height.  The */
        /* difference is the area of a band around the sphere */
        area_cap1 = TWO_PI*(1-ha);
        area_cap2 = TWO_PI*(1-hb);

        /* find the total area of the band */
        area_band = area_cap2 - area_cap1;

        /* now that we have the band area, how many patches will fit? */
        /* this will determine how many phi angles...*/
        num_phi = floor(area_band/area_patch); 
        dphi = TWO_PI/num_phi;

        for(j = 1; j<= num_phi; j++) {

            if(debugTensor) {
                printf("Shot Number = %d\n",index);
                printf("Theta = %f\n",Theta);
                printf("Delta Theta = %f\n", dt);
                printf("Phi = %f\n", Phi);
                printf("Delta Phi = %f\n",dphi);
            }

            TENSOR_HOST[0][index] =  sin(Theta)*cos(Phi);  /* X gradient Amp */
            TENSOR_HOST[1][index] =  sin(Theta)*sin(Phi);  /* Y gradient Amp */
            TENSOR_HOST[2][index] =  cos(Theta);           /* Z gradient Amp */

            if(debugTensor) {
                printf("X-Diffusion Amp = %f\n",TENSOR_HOST[0][index]);
                printf("Y-Diffusion Amp = %f\n",TENSOR_HOST[1][index]);
                printf("Z-Diffusion Amp = %f\n\n",TENSOR_HOST[2][index]);
                fflush(stdout);
            }

            Phi += dphi;   /* increment phi (rad) */
            index++;       /* increment count */
        }

        Phi = 0;  
    }

    return SUCCESS;
}   /* end calc_orientations() */



@host DTI_Check_Bval_Func
/*
 *  verify_bvalue():
 *
 *  This function checks the b-value of the gradient waveforms on each axis by 
 *  generating the waveforms using a call to pulsegen(), integrating each axis, and
 *  computing the b-value at the echo time.  This value is compared with the prescribed 
 *  b-value (opbval).  If it does not conform to the tolerance (1.5%), then the dif lobes
 *  are adjusted (roughly) using the ratio of the sqrt() of the b-values.  This usually puts you
 *  in the tolerance range.  If not, bisection is used for further refinement.  
 *  
 */

STATUS
#ifdef __STDC__
verify_bvalue( FLOAT * curr_bvalue, 
                      const FLOAT rf_excite_location, 
                      const FLOAT * rf_180_location, 
                      const INT num180s, 
                      const INT seq_entry_index, 
                      const INT bmat_flag, 
                      const INT seg_debug)
#else /* !__STDC__ */
verify_bvalue( curr_bvalue, rf_excite_location, 
               rf_180_location, num180s,
               seq_entry_index, bmat_flag, seg_debug)
    FLOAT * curr_bvalue; 
    const FLOAT rf_excite_location; 
    const FLOAT * rf_180_location;
    const INT num180s;
    const INT seq_entry_index; 
    const INT bmat_flag;
    const INT seg_debug;
#endif /* __STDC__ */
{
    
    /* Variables for b-value calculation */
    STATUS status;            /* Status variable to catch errors from function calls */
    FLOAT dif_amp[3];         /* Vector of amplitudes of diffusion gradient on all three axes */
    FLOAT orig_dif_amp[3];    /* Vector of amplitudes of diffusion gradient - 
                                 original values when starting calculation */
    INT m, n, iter_count = 0;    /* Counter */
    INT k;                       /* multi b */
    FILE *six_sigma_fp = NULL;
    FLOAT ref_bval = 0.0;

    float tolerance = 0.015;     /* Maximum deviation from prescribed bvalue = +/- tolerance */ 
    
    FLOAT scalx_A, scalx_B, scalx_mid;
    FLOAT scaly_A, scaly_B, scaly_mid;
    FLOAT scalz_A, scalz_B, scalz_mid;
    
    float MaxAmpx = loggrd.tx_xyz;
    float MaxAmpy = loggrd.ty_xyz;
    float MaxAmpz = loggrd.tz_xyz;
    float minMaxAmp_log = 0;

    INT bvalue_iter_flag = TRUE;
    INT x_iter_flag, y_iter_flag, z_iter_flag;

    INT user_bval[1+MAX_NUM_BVALS_PSD];
    float orig_incdifx, orig_incdify, orig_incdifz;

    /* Obl 3in1 opt */
    INT i;
    FLOAT current_bval,b_val_ratio,b_val_ratio_final;
    FLOAT verified_dif_amp_x,verified_dif_amp_y,verified_dif_amp_z;
    FLOAT gx_norm,gy_norm,gz_norm;
    FLOAT gx_hw,gy_hw,gz_hw;
    INT gx_bd,gy_bd,gz_bd;
    FLOAT xpscale,ypscale,zpscale;

    minMaxAmp_log = FMin(3,loggrd.tx,loggrd.ty,loggrd.tz);

    derate_diffusion_amplitude(); /* Limiting the scale_all based on the max bval selected */

    if ( use_maxloggrad)
    {
        MaxAmpx = minMaxAmp_log * scale_all;
        MaxAmpy = minMaxAmp_log * scale_all;
        MaxAmpz = minMaxAmp_log * scale_all;
    }
    else 
    {
        MaxAmpx = loggrd.tx_xyz * scale_all;
        MaxAmpy = loggrd.ty_xyz * scale_all;
        MaxAmpz = loggrd.tz_xyz * scale_all;
    }

    if((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) || (opdfaxall > PSD_OFF && gradopt_diffall == PSD_ON))
    {
        MaxAmpx = loggrd.tx_xyz * scale_all;
        MaxAmpy = loggrd.ty_xyz * scale_all;
        MaxAmpz = loggrd.tz_xyz * scale_all;
        MaxAmpx = FMin(3, MaxAmpx, MaxAmpy, MaxAmpz);
        MaxAmpy = MaxAmpx;
        MaxAmpz = MaxAmpx;
    }
 
    /* initial values */
    x_iter_flag = y_iter_flag = z_iter_flag = TRUE;
    
    /* This will dump a file with actual b's, errors, etc. */
    /* NOTE: it appends to the file so it will continue to grow if not removed !!! */ 
    if(collect_six_sigma) {
        six_sigma_fp = fopen("b-value.txt","a+");
        if(!six_sigma_fp){
            printf("Could not open b-value.txt");
            return FAILURE;
        }
    } 
   
    /* Initialize diff_amp vector */
    for (n=0; n < MAX_NUM_BVALS_PSD; n++)
    {
        diff_ampx[n] = 0.0;
        diff_ampy[n] = 0.0;
        diff_ampz[n] = 0.0;
        user_bval[n] = bvalstab[n];

        for (m=0; m < NUM_DWI_DIRS; m++)
        {
            diff_ampx2[n][m] = 0.0;
            diff_ampy2[n][m] = 0.0;
            diff_ampz2[n][m] = 0.0;
        }
    }
    
    /* --- Calculate the bvalue for the original estimates--- */      
    /* Store the current gradient amplitudes */
    if (PSD_OFF == dualspinecho_flag)
    {
        orig_dif_amp[0] = a_gxdl;
        orig_dif_amp[1] = a_gydl;
        orig_dif_amp[2] = a_gzdl;
    } else {
        orig_dif_amp[0] = a_gxdl1;
        orig_dif_amp[1] = a_gydl1;
        orig_dif_amp[2] = a_gzdl1;
    }

    orig_incdifx = incdifx; 
    orig_incdify = incdify; 
    orig_incdifz = incdifz;

    /* Obl 3in1 opt */
    if (PSD_ON == obl_3in1_opt)
    {
        for (k=0; k<opnumbvals; k++)
        {
            ref_bval = user_bval[k];
            scalx_mid = sqrt(ref_bval/max_bval);
            scaly_mid = scalx_mid;
            scalz_mid = scalx_mid;
            amp_difx_bverify = log_incdifx[0]*scalx_mid;
            amp_dify_bverify = log_incdify[0]*scaly_mid;
            amp_difz_bverify = log_incdifz[0]*scalz_mid;

            b_val_ratio_final = 1.0;
            bvalue_iter_flag = TRUE;
            iter_count = 0;

            while( (bvalue_iter_flag == TRUE) && (iter_count < 15) && (ref_bval > 0.0) )
            {
                pgen_calc_bval_flag = PSD_ON;

                /* Calculate bvalue using pulsegen */
                status =  pgen_calcbvalue( curr_bvalue, rf_excite_location, rf_180_location,
                                           num180s, opte, GAM, &loggrd, seq_entry_index, tsamp,
                                           act_tr, use_ermes, seg_debug, bmat_flag);

                if (status == FAILURE || status == SKIP)
                {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "pgen_calcbvalue()" );
                    return FAILURE;
                }

                pgen_calc_bval_flag = PSD_OFF;

                current_bval = curr_bvalue[0] + curr_bvalue[1] + curr_bvalue[2];
                b_val_ratio = current_bval / ref_bval;

                if (collect_six_sigma && (iter_count == 0))
                {
                    fprintf (six_sigma_fp,"First b-value estimate: %f  %f  %f  %f\n",
                             curr_bvalue[0],curr_bvalue[1],curr_bvalue[2],current_bval);
                    fprintf (six_sigma_fp,"Target b-value: %f, multi-b index k=%d\n",
                             ref_bval,k);
                    fprintf (six_sigma_fp,"error estimate: %f\n",
                             (1.0 - b_val_ratio)*100.0);
                }

                if( (b_val_ratio >= (1.0 - tolerance)) && (b_val_ratio <= (1.0 + tolerance)) )
                {
                    bvalue_iter_flag = FALSE;

                    if (obl_3in1_opt_debug)
                    {
                        printf("Obl3in1: Iteration converged\n");
                    }

                    if (collect_six_sigma)
                    {
                        fprintf (six_sigma_fp,"Last b-value estimate at iter %d: %f  %f  %f %f\n",iter_count, curr_bvalue[0],
                                 curr_bvalue[1], curr_bvalue[2], current_bval );
                        fprintf (six_sigma_fp,"error estimate: %f\n\n\n",
                                 (1.0 - b_val_ratio)*100.0);
                    }
                }

                if (obl_3in1_opt_debug)
                {
                    printf("Obl3in1:  \n");
                    printf("Obl3in1: k=%d iter_count=%d\n", k, iter_count);
                    printf("Obl3in1: curr_bvalue x=%f curr_bvalue y=%f curr_bvalue z=%f\n", curr_bvalue[0], curr_bvalue[1], curr_bvalue[2]);
                    printf("Obl3in1: ref_bval=%f  current_bval=%f b_val_ratio=%f\n", ref_bval, current_bval, b_val_ratio);
                }

                if (bvalue_iter_flag == TRUE)
                {
                    verified_dif_amp_x = amp_difx_bverify/sqrt(b_val_ratio);
                    verified_dif_amp_y = amp_dify_bverify/sqrt(b_val_ratio);
                    verified_dif_amp_z = amp_difz_bverify/sqrt(b_val_ratio);

                    if ((abs(verified_dif_amp_x) > abs(log_incdifx[0])) ||
                        (abs(verified_dif_amp_y) > abs(log_incdify[0])) ||
                        (abs(verified_dif_amp_z) > abs(log_incdifz[0])))
                    {
                        bvalue_iter_flag = FALSE;

                        if (obl_3in1_opt_debug)
                        {
                            printf("Obl3in1: MPG exceeds max amplitude, so no adjustment on diffusion pulses\n");
                        }
                    }

                    b_val_ratio_final *= b_val_ratio;
                    amp_difx_bverify = verified_dif_amp_x;
                    amp_dify_bverify = verified_dif_amp_y;
                    amp_difz_bverify = verified_dif_amp_z;

                    if (obl_3in1_opt_debug)
                    {
                        printf("Obl3in1: New updated amplitude\n");
                    }
                }

                if (obl_3in1_opt_debug)
                {
                    printf("Obl3in1: log_incdifx[0]=%f\n", log_incdifx[0]);
                    printf("Obl3in1: log_incdify[0]=%f\n", log_incdify[0]);
                    printf("Obl3in1: log_incdifz[0]=%f\n", log_incdifz[0]);
                }

                iter_count++;

            } /* end while */

            for (i=0; i<num_dif; i++)
            {
                if (ref_bval > 0.0)
                {
                    diff_ampx2[k][i] = scalx_mid*log_incdifx[i]/sqrt(b_val_ratio_final);
                    diff_ampy2[k][i] = scaly_mid*log_incdify[i]/sqrt(b_val_ratio_final);
                    diff_ampz2[k][i] = scalz_mid*log_incdifz[i]/sqrt(b_val_ratio_final);
                }
                else
                {
                    diff_ampx2[k][i] = 0.0;
                    diff_ampy2[k][i] = 0.0;
                    diff_ampz2[k][i] = 0.0;
                }

                if (obl_3in1_opt_debug)
                {
                    printf("Obl3in1: Final amplitude of MPG\n");
                    printf("Obl3in1: b_val_ratio_final=%f\n", b_val_ratio_final);
                    printf("Obl3in1: k=%d user_bval=%f diff_ampx2=%f diff_ampy2=%f diff_ampz2=%f\n", k, ref_bval, diff_ampx2[k][i], diff_ampy2[k][i], diff_ampz2[k][i]);
                }

                if (collect_six_sigma)
                {
                        fprintf(six_sigma_fp, "diff_ampx2[%d][%d]=%f, diff_ampy2[%d][%d]=%f, diff_ampz2[%d][%d]=%f,\n",k,i,diff_ampx2[k][i],k,i,diff_ampy2[k][i],k,i,diff_ampz2[k][i]);
                }
            }
        } /* end k loop */

        if (obl_3in1_opt_debug)
        {
            xpscale=(float)phygrd.xfull/(phygrd.xfs *(float)max_pg_iamp);
            ypscale=(float)phygrd.yfull/(phygrd.yfs *(float)max_pg_iamp);
            zpscale=(float)phygrd.zfull/(phygrd.zfs *(float)max_pg_iamp);
            printf("Obl3in1: \n");
            printf("Obl3in1: Predicted MPG amplitude in each axis in G/cm.\n");
            for (k=0; k<opnumbvals; k++)
            {
                for(i=0; i<num_dif; i++)
                {
                    gx_norm = diff_ampx2[k][i] / loggrd.tx;
                    gy_norm = diff_ampy2[k][i] / loggrd.ty;
                    gz_norm = diff_ampz2[k][i] / loggrd.tz;
                    gx_bd =(int)((float)rsprot[0][0]*gx_norm+(float)rsprot[0][1]*gy_norm+(float)rsprot[0][2]*gz_norm);
                    gy_bd =(int)((float)rsprot[0][3]*gx_norm+(float)rsprot[0][4]*gy_norm+(float)rsprot[0][5]*gz_norm);
                    gz_bd =(int)((float)rsprot[0][6]*gx_norm+(float)rsprot[0][7]*gy_norm+(float)rsprot[0][8]*gz_norm);
                    gx_hw = (float)gx_bd / (xpscale*(float)max_pg_iamp);
                    gy_hw = (float)gy_bd / (ypscale*(float)max_pg_iamp);
                    gz_hw = (float)gz_bd / (zpscale*(float)max_pg_iamp);
                    printf("Obl3in1: b[%d]dir[%d] gx_hw= %f gy_hw= %f gz_hw= %f\n",k,i,gx_hw,gy_hw,gz_hw);
                }
            }
        }
    } /* end obl_3in_opt */
    else
    {
        for (k=0; k<opnumbvals; k++) {    
            x_iter_flag = y_iter_flag = z_iter_flag = TRUE;

            /* Set the gradients to the current estimates for the Rx bvalue */
            incdifx = orig_incdifx;
            incdify = orig_incdify;
            incdifz = orig_incdifz;
            dif_amp[0] = incdifx;
            dif_amp[1] = incdify;
            dif_amp[2] = incdifz;      

            if (PSD_OFF == dualspinecho_flag)
            {
                a_gxdl = dif_amp[0];
                a_gxdr = dif_amp[0];
                a_gydl = dif_amp[1];
                a_gydr = dif_amp[1];
                a_gzdl = dif_amp[2];
                a_gzdr = dif_amp[2];

            } else {
                a_gxdl1 = dif_amp[0];
                a_gxdr1 = (-dif_amp[0]);
                a_gxdl2 = dif_amp[0];
                a_gxdr2 = (-dif_amp[0]);

                a_gydl1 = dif_amp[1];
                a_gydr1 = (-dif_amp[1]);
                a_gydl2 = dif_amp[1];
                a_gydr2 = (-dif_amp[1]);

                a_gzdl1 = dif_amp[2];
                a_gzdr1 = (-dif_amp[2]);
                a_gzdl2 = dif_amp[2];
                a_gzdr2 = (-dif_amp[2]);
            }

            /* MRIhc19235 */ 
            pgen_calc_bval_flag = PSD_ON; 

            /* Calculate bvalue using pulsegen */
            status =  pgen_calcbvalue( curr_bvalue, rf_excite_location, rf_180_location, 
                                       num180s, opte, GAM, &loggrd, seq_entry_index, tsamp, 
                                       act_tr, use_ermes, seg_debug, bmat_flag);
            if(status == FAILURE || status == SKIP) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "pgen_calcbvalue()" );
                return FAILURE;
            }

            pgen_calc_bval_flag = PSD_OFF;

            if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
            {
                ref_bval = user_bval[k]/3.0;
            }
            else if ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON))
            {
                ref_bval = user_bval[k]/2.0;
            }
            else
            {
                ref_bval = user_bval[k];
            }

            per_err_orig_x = 100.0*( ref_bval - curr_bvalue[0])/ref_bval;
            per_err_orig_y = 100.0*( ref_bval - curr_bvalue[1])/ref_bval;
            per_err_orig_z = 100.0*( ref_bval - curr_bvalue[2])/ref_bval;

            if (collect_six_sigma) {
                fprintf (six_sigma_fp,"First b-value estimate: %f  %f  %f\n", 
                         curr_bvalue[0],curr_bvalue[1],curr_bvalue[2]); 
                fprintf (six_sigma_fp,"Target b-value: %f, multi-b index k=%d\n", 
                         ref_bval,k); 
                fprintf (six_sigma_fp,"error estimate: %f  %f  %f\n", 
                         per_err_orig_x, per_err_orig_y, per_err_orig_z); 
            }

            /* Bisection to get the to proper b-value */
            /* Set initial upper and mid scale for bisection */
            scalx_A = scalx_mid = 1.0;   
            scaly_A = scaly_mid = 1.0;
            scalz_A = scalz_mid = 1.0;

            /* If the b-value calculated above is outside the tolerance, 
               then we will guess that the diffusion lobes will need to be 
               increased/decreased by the sqrt(test_opbval/curr_bvalue[0]). 
               If the scaled factor * amp, exceeds the MaxAmp, set the scale factor 
               to 1.0 and dont iterate    */

            /* Check X-axis */
            if(curr_bvalue[0] > ref_bval*(1+tolerance) || curr_bvalue[0] < ref_bval*(1-tolerance) ) {
                scalx_mid = sqrt(ref_bval/curr_bvalue[0]); 

                /* protect against overrange */
                if(incdifx*scalx_mid > MaxAmpx) {
                    scalx_mid = 1.0;
                    x_iter_flag = 0;
                }
            }

            /* Check Y-Axis */
            if(curr_bvalue[1] > ref_bval*(1+tolerance) || curr_bvalue[1] < ref_bval*(1-tolerance) ) {
                scaly_mid = sqrt(ref_bval/curr_bvalue[1]); 

                /* protect against overrange */
                if(incdify*scaly_mid > MaxAmpy) {
                    scaly_mid = 1.0;
                    y_iter_flag = 0;
                }
            }

            /* Check Z-Axis */
            if(curr_bvalue[2] > ref_bval*(1+tolerance) || curr_bvalue[2] < ref_bval*(1-tolerance) ) {
                scalz_mid = sqrt(ref_bval/curr_bvalue[2]); 

                /* protect against overrange */
                if(incdifz*scalz_mid > MaxAmpz) {
                    scalz_mid = 1.0;
                    z_iter_flag = 0;
                }
            }

            /* Set up bracketing for bisection search */
            /* Note: there may be more sophisticated searches we could do */
            /* but this is guaranteed to converge and with the intial guess */
            /* rarely takes longer than 5-6 iterations (in most cases 0)    */

            /* Set upper scale */ 
            scalx_A = (1.5*scalx_mid > 1.0) ? 1.0 : 1.5*scalx_mid;   
            scaly_A = (1.5*scaly_mid > 1.0) ? 1.0 : 1.5*scaly_mid;
            scalz_A = (1.5*scalz_mid > 1.0) ? 1.0 : 1.5*scalz_mid;

            /* Set lower scale for bisection */
            scalx_B = 0.5*scalx_mid;  
            scaly_B = 0.5*scaly_mid;
            scalz_B = 0.5*scalz_mid;

            /* Check to see if we need to iterate */
            bvalue_iter_flag = (x_iter_flag || y_iter_flag || z_iter_flag); 
            /* For low bvalues if convergence within tolerance range
               fails in 15 iterations, then force exit out of loop
               and continue..this is a kludge to prevent download
               failures and psd timeouts observed when sat is turned on 
               usually for very low b-value Rx */        
            iter_count = 0;
            while( (bvalue_iter_flag == TRUE) && (iter_count < 15) && (ref_bval > 0.0) ) {

                if (PSD_OFF ==  dualspinecho_flag)
                {
                    a_gxdl = scalx_mid*dif_amp[0];
                    a_gxdr = scalx_mid*dif_amp[0];
                    a_gydl = scaly_mid*dif_amp[1];
                    a_gydr = scaly_mid*dif_amp[1];
                    a_gzdl = scalz_mid*dif_amp[2];
                    a_gzdr = scalz_mid*dif_amp[2];

                } else {
                    a_gxdl1 = scalx_mid*dif_amp[0];
                    a_gxdr1 = scalx_mid*(-dif_amp[0]);
                    a_gxdl2 = scalx_mid*dif_amp[0];
                    a_gxdr2 = scalx_mid*(-dif_amp[0]);

                    a_gydl1 = scaly_mid*dif_amp[1];
                    a_gydr1 = scaly_mid*(-dif_amp[1]);
                    a_gydl2 = scaly_mid*dif_amp[1];
                    a_gydr2 = scaly_mid*(-dif_amp[1]);

                    a_gzdl1 = scalz_mid*dif_amp[2];
                    a_gzdr1 = scalz_mid*(-dif_amp[2]);
                    a_gzdl2 = scalz_mid*dif_amp[2];
                    a_gzdr2 = scalz_mid*(-dif_amp[2]);
                }

                /* MRIhc19235 */
                pgen_calc_bval_flag = PSD_ON;

                /* Check results */
                /* Calculate bvalue using pulsegen */
                status =  pgen_calcbvalue( curr_bvalue, rf_excite_location, rf_180_location, 
                                           num180s, opte, GAM, &loggrd, seq_entry_index, 
                                           tsamp, act_tr, use_ermes, seg_debug, bmat_flag);
                if(status == FAILURE || status == SKIP) {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "pgen_calcbvalue()" );
                    return FAILURE;
                }

                pgen_calc_bval_flag = PSD_OFF;

                /* axis - X */
                if(curr_bvalue[0] < ref_bval*(1-tolerance)) {

                    /* Set new lower bound X */ 
                    scalx_B = scalx_mid;
                    x_iter_flag = TRUE; 

                    scalx_mid = scalx_B + 0.5*(scalx_A - scalx_B);

                } else if( curr_bvalue[0] > ref_bval*(1+tolerance)) {

                    /* Set new upper bound X */ 
                    scalx_A = scalx_mid;
                    x_iter_flag = TRUE;

                    scalx_mid = scalx_B + 0.5*(scalx_A - scalx_B);

                    /* protect against overrange */
                    if(incdifx*scalx_mid > MaxAmpx) {
                        scalx_mid = 1.0;
                        x_iter_flag = FALSE;
                    }

                } else {

                    /* call it good */                  
                    x_iter_flag = FALSE;                
                }

                /* axis - Y */
                if(curr_bvalue[1] < ref_bval*(1-tolerance)) {

                    /* Set new lower bound Y */
                    scaly_B = scaly_mid;
                    y_iter_flag = TRUE;

                    scaly_mid = scaly_B + 0.5*(scaly_A - scaly_B);

                } else if( curr_bvalue[1] > ref_bval*(1+tolerance)) {

                    /* Set new upper bound Y */
                    scaly_A = scaly_mid;
                    y_iter_flag = TRUE;

                    scaly_mid = scaly_B + 0.5*(scaly_A - scaly_B);

                    /* protect against overrange */
                    if(incdify*scaly_mid > MaxAmpy) {
                        scaly_mid = 1.0;
                        y_iter_flag = FALSE;
                    }

                } else {                
                    /* call it good */
                    y_iter_flag = FALSE;
                }

                /* axis - Z */
                if(curr_bvalue[2] < ref_bval*(1-tolerance)) {

                    /* Set new lower bound Z */
                    scalz_B = scalz_mid;
                    z_iter_flag = TRUE;

                    scalz_mid = scalz_B + 0.5*(scalz_A - scalz_B);

                } else if( curr_bvalue[2] > ref_bval*(1+tolerance)) {

                    /* Set new upper bound Z */
                    scalz_A = scalz_mid;
                    z_iter_flag = TRUE;

                    scalz_mid = scalz_B + 0.5*(scalz_A - scalz_B);

                    /* protect against overrange */
                    if(incdifz*scalz_mid > MaxAmpz) {
                        scalz_mid = 1.0;
                        z_iter_flag = FALSE;
                    }

                } else {
                    /* call it good */
                    z_iter_flag = FALSE;
                }

                bvalue_iter_flag = (x_iter_flag || y_iter_flag || z_iter_flag);
                iter_count++;

            } /* end while */

#ifdef UNDEF
            /* Check that new results are within tolerance */
            if ( curr_bvalue[0] < ref_bval*(1-tolerance) || curr_bvalue[1] < ref_bval*(1-tolerance) 
                 || curr_bvalue[2] < ref_bval*(1-tolerance) || curr_bvalue[0] > ref_bval*(1+tolerance) 
                 || curr_bvalue[1] > ref_bval*(1+tolerance) ||  curr_bvalue[2] > ref_bval*(1+tolerance) ) {

                /* NOTE: Could use an iterative technique here to find the proper gradients */
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "bvalue adjustment" );
                printf("Actual b-values: x = %12.8f, y = %12.8f, z = %12.8f\n",
                       curr_bvalue[0], curr_bvalue[1], curr_bvalue[2]);
                return FAILURE;
            } 
#endif   

            per_err_corr_x = 100.0*( ref_bval - curr_bvalue[0])/ref_bval;
            per_err_corr_y = 100.0*( ref_bval - curr_bvalue[1])/ref_bval;
            per_err_corr_z = 100.0*( ref_bval - curr_bvalue[2])/ref_bval;

            if (collect_six_sigma) { 
                fprintf (six_sigma_fp,"Last b-value estimate at iter %d: %f  %f  %f\n",iter_count, curr_bvalue[0], 
                         curr_bvalue[1], curr_bvalue[2] ); 
                fprintf (six_sigma_fp,"error estimate: %f  %f  %f\n\n\n", per_err_corr_x, 
                         per_err_corr_y, per_err_corr_z); 
            }

            /* Update the incdif CVs and put results in diff_amp arrays to pass to the Tgt */
            if (ref_bval > 0.0){
                incdifx = scalx_mid*dif_amp[0];
                incdify = scaly_mid*dif_amp[1];
                incdifz = scalz_mid*dif_amp[2];
            }
            else 
            {
                incdifx = 0.0;
                incdify = 0.0;
                incdifz = 0.0;
            }

            diff_ampx[k] = incdifx; 
            diff_ampy[k] = incdify;
            diff_ampz[k] = incdifz;

        }  /* end of multi b loop k */

        if (collect_six_sigma) { 
            for(k=0;k<opnumbvals;k++) 
            { 
                fprintf(six_sigma_fp, "diff_ampx[%d]=%f, diff_ampy[%d]=%f, diff_ampz[%d]=%f\n",k,diff_ampx[k],k,diff_ampy[k],k,diff_ampz[k]); 
            } 
        } 

        /* Put the original amplitudes back */
        /* These are used for pulsegen purposes and we want */
        /* them to be there largest */
        if (PSD_OFF == dualspinecho_flag)
        {
            a_gxdl = orig_dif_amp[0];
            a_gxdr = orig_dif_amp[0];
            a_gydl = orig_dif_amp[1];
            a_gydr = orig_dif_amp[1];
            a_gzdl = orig_dif_amp[2];
            a_gzdr = orig_dif_amp[2];

        } else {
            a_gxdl1 = orig_dif_amp[0];
            a_gxdr1 = -orig_dif_amp[0];
            a_gxdl2 = orig_dif_amp[0];
            a_gxdr2 = -orig_dif_amp[0];

            a_gydl1 = orig_dif_amp[1];
            a_gydr1 = -orig_dif_amp[1];
            a_gydl2 = orig_dif_amp[1];
            a_gydr2 = -orig_dif_amp[1];

            a_gzdl1 = orig_dif_amp[2];
            a_gzdr1 = -orig_dif_amp[2];
            a_gzdl2 = orig_dif_amp[2];
            a_gzdr2 = -orig_dif_amp[2];
        }
    }

    if (collect_six_sigma) {
        fclose(six_sigma_fp);
    }

    return SUCCESS;
    
} /* end of verify_bvalue() */

/*
 *  calc_b_matrix:
 *
 *  This function will calculate the b-matrix (on and off-axis terms).  Its include for completeness
 *  and may be used in the future.  For this to work properly, the b-matrix must be recompumted for
 *  every diffusion direction.  Thus, this loops over all the shots in a DTI scan and uses the X,Y,Z 
 *  components of the b-vector for the computation.  These are stored in the TENS[] array.
 *  
 */

STATUS calc_b_matrix( FLOAT * curr_bvalue,
                      const FLOAT rf_excite_location, 
                      const FLOAT * rf_180_location, 
                      const INT num180s, 
                      const INT seq_entry_index, 
                      const INT bmat_flag, 
                      const INT seg_debug)
{

    /* Variables for b-value calculation */
      STATUS status;            /* Status variable to catch errors from function calls */
      static INT num_dirs = -1; /* static variable that keeps track of updated to dirs */
      static INT bval = -1;
      INT i, j;
      FLOAT dif_amp[3];         /* Vector of amplitudes of diffusion gradient on all three axes */
        
      /* Set the gradients to the current estimates for the Rx bvalue */
      dif_amp[0] = incdifx;
      dif_amp[1] = incdify;
      dif_amp[2] = incdifz;    
 
      /* BJM: see if number of direcitons has changed */
      /*      If yes, then read orientations and recompute */
      /*      b-matrix.  If not, simply return....*/

      if( (num_dirs != (num_tensor + num_B0) || !floatsAlmostEqualEpsilons(bval, bvalstab[0], 2)) &&
          (bmat_flag == TRUE) ) {
          num_dirs = num_tensor + num_B0;
          bval = max_bval;
          
          /* set up tensor orientations */
          if ( FAILURE == set_tensor_orientations() ){
              return FAILURE;
          }           
          
      } else {
          /* no need */
          return SUCCESS;
      }
     
      /* loop over each direction */
      for( i = 0; i<num_dirs; i++) {
            
            if (PSD_OFF == dualspinecho_flag)
            {
                a_gxdl = TENSOR_HOST[0][i]*dif_amp[0];
                a_gxdr = TENSOR_HOST[0][i]*dif_amp[0];
                a_gydl = TENSOR_HOST[1][i]*dif_amp[1];
                a_gydr = TENSOR_HOST[1][i]*dif_amp[1];
                a_gzdl = TENSOR_HOST[2][i]*dif_amp[2];
                a_gzdr = TENSOR_HOST[2][i]*dif_amp[2];
                
            } else {
                a_gxdl1 = TENSOR_HOST[0][i]*dif_amp[0];
                a_gxdr1 = TENSOR_HOST[0][i]*(-dif_amp[0]);
                a_gxdl2 = TENSOR_HOST[0][i]*dif_amp[0];
                a_gxdr2 = TENSOR_HOST[0][i]*(-dif_amp[0]);
                
                a_gydl1 = TENSOR_HOST[1][i]*dif_amp[1];
                a_gydr1 = TENSOR_HOST[1][i]*(-dif_amp[1]);
                a_gydl2 = TENSOR_HOST[1][i]*dif_amp[1];
                a_gydr2 = TENSOR_HOST[1][i]*(-dif_amp[1]);
                
                a_gzdl1 = TENSOR_HOST[2][i]*dif_amp[2];
                a_gzdr1 = TENSOR_HOST[2][i]*(-dif_amp[2]);
                a_gzdl2 = TENSOR_HOST[2][i]*dif_amp[2];
                a_gzdr2 = TENSOR_HOST[2][i]*(-dif_amp[2]);
            }
           
            /* MRIhc19235 */
            pgen_calc_bval_flag = PSD_ON;
 
            /* Check results */
            /* Calculate bvalue using pulsegen */
            status =  pgen_calcbvalue( curr_bvalue, rf_excite_location, rf_180_location, 
                                       num180s, opte, GAM, &loggrd, seq_entry_index, 
                                       tsamp, act_tr, use_ermes, seg_debug, bmat_flag);
            if(status == FAILURE || status == SKIP) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "pgen_calcbvalue()" );
                return FAILURE;
            }

            pgen_calc_bval_flag = PSD_OFF;
 
            /* fill b-matirx */
            for(j = 0; j < 6; j++) {
                B_MATRIX[j][i] = curr_bvalue[j];
            }
   
            /* out put of b-matrix */
            if( i < num_B0) {
                fprintf(stdout,"T2 Image\n");
            } else {
                fprintf(stdout,"Diffusion Image\n");
            }
            fprintf(stdout,"Repetition = %d\n",i);
            fprintf(stdout,"X Comp = %12.8f, Y Comp = %12.8f, Z Comp = %12.8f\n",
                    TENSOR_HOST[0][i], TENSOR_HOST[1][i], TENSOR_HOST[2][i]);
            fprintf(stdout,"Matrix b-values: xy = %12.8f, xy = %12.8f, xz = %12.8f\n",
                    curr_bvalue[0],curr_bvalue[3],curr_bvalue[4]);
            fprintf(stdout,"Matrix b-values: yx = %12.8f, yy = %12.8f, yz = %12.8f\n",
                    curr_bvalue[3],curr_bvalue[1],curr_bvalue[5]);
            fprintf(stdout,"Matrix b-values: zx = %12.8f, zy = %12.8f, zz = %12.8f\n",
                    curr_bvalue[4],curr_bvalue[5],curr_bvalue[2]);
            fflush(stdout);

        } /* end for loop */           

        return SUCCESS;
        
} /* end of calc_b_matrix() */


/* BJM: added 5/20/03 for Linux */
@rsp rspDTI
float TENSOR_AGP[3][MAX_DIRECTIONS + MAX_T2];  /* Tensor Dif Amp Array (directions + t2) */
float TENSOR_AGP_temp[3][MAX_DIRECTIONS + MAX_T2]; /*MRIhc05854*/

@rsp rspPrototypes 
static INT set_tensor_orientationsAGP( void );

@rsp readTensorOrientationsFunc 
/*
 * BJM 4/25/00 - set_tensor_orientationsAGP()
 *
 * This function is designed to either read the tensor directions from a
 * file on disk called tensor.dat (/usr/g/bin).  It was added during Linux
 * development since it was found that the TENS[][] array was corrupted during
 * download.  Thus, the quick solution was to re-read the tensor.dat file from the
 * AGP and re-fill the TENSOR_AGP[][] array...
 *
 */
static INT set_tensor_orientationsAGP( void )
{
    int read_from_file = PSD_ON;
    int j;

    if( read_from_file == PSD_ON  && tensor_flag == PSD_ON ) {

        FILE *fp;                           /* file pointer */
        char filestring[MAXCHAR];           /* buffer used to open data file */ 
        char compstring[MAXCHAR];           /* buffer used to open data file */ 
        char tempstring[MAXCHAR];           /* buffer to access file */
        int max_chars_per_line = MAXCHAR;   /* lines in tensor.dat header */ 
        int num_tensor_len;
#ifndef SIM
        const char *tensor_datapath="/usr/g/bin/";/* path to tensor.dat files - hw  */
        char tensor_datafile[80]; /* filename of tensor.dat file */
        if (rhtensor_file_number == 0)
        {
            sprintf(tensor_datafile, "tensor.dat");
        }
        else
        {
            sprintf(tensor_datafile, "tensor%d.dat", rhtensor_file_number);
        }
#else /* !SIM */
        const char *tensor_datapath="./";         /* path to tensor.dat files - sim */
        char tensor_datafile[80];                    /* filename of tensor.dat file */

        if (rhtensor_file_number == 0)
        {
            if(PSD_VRMW_COIL == gCoilType)
            {
                sprintf(tensor_datafile, "tensor.dat.VRMW");
            }
            else
            {
                sprintf(tensor_datafile, "tensor.dat.default");
            }
        }
        else 
        {
            sprintf(tensor_datafile, "tensor%d.dat", rhtensor_file_number);
        }
#endif /* SIM */

        /* Setup for file search - set the number of directions requested */
        sprintf( compstring, "%d", num_tensor );
        num_tensor_len = strlen( compstring );

        /* Set tensor.dat file path and append filename base and suffix */
        strcpy( filestring, tensor_datapath );
        strcat( filestring, tensor_datafile );

        /* Open file */
        if( (fp = fopen( filestring, "r" )) == NULL ) { 
            printf( "Cant read %s", filestring );
            fflush( stdout );
            return FAILURE;
        }

        /*
         * The tensor.dat file is a concatanation of several files.
         * We need to skip over all the lines until we reach the location
         * that stores the "num_tensor" orientations.
         */
        {
            int read_skip = 1;

            while( read_skip ) {
                fgets( tempstring, max_chars_per_line, fp );
                read_skip = strncmp( compstring, tempstring, num_tensor_len );
            }
        }

        if(debugTensor == PSD_ON) {
            printf( "Tensor Directions Read (AGP) = %d\n", num_tensor );
        }

        /*
         * Next, after reaching the desired point in the file           
         * iterate over num_tensor & put the data in TENS[i][j] 
         */

        /* BJM: assign the T2 images first - want multiple B = 0 images */
        for( j = 0; j < num_B0; ++j ) {

            TENSOR_AGP[0][j] = TENSOR_AGP[1][j] = TENSOR_AGP[2][j] = 0.0;
            
            if(debugTensor == PSD_ON) {
                printf( "T2 #%d, X = %f, Y=%f, Z= %f\n", j, TENSOR_AGP[0][j], TENSOR_AGP[1][j], TENSOR_AGP[2][j] );
                fflush( stdout );
            }

        }

        /* Now do the rest of the shots */
        /*  Skip the multiple B = 0 images.  Start at num_B0 plus 1 in
            the TENSOR_AGP[][] array. */
        for ( j = num_B0; j < num_tensor + num_B0; ++j ) {          
            if( fgets( tempstring, MAXCHAR, fp ) == NULL ) { 
                printf( "ERROR: invalid tensor.dat file format!\n" ); 
            }          
            sscanf( tempstring, "%f %f %f", &TENSOR_AGP_temp[0][j], &TENSOR_AGP_temp[1][j], &TENSOR_AGP_temp[2][j] );

            TENSOR_AGP[0][j] = TENSOR_AGP_temp[0][j];
            TENSOR_AGP[1][j] = TENSOR_AGP_temp[1][j];
            TENSOR_AGP[2][j] = TENSOR_AGP_temp[2][j];

            if(debugTensor == PSD_ON)
            {
                printf( "Shot = %d, X = %f, Y=%f, Z= %f\n", j, TENSOR_AGP[0][j], TENSOR_AGP[1][j], TENSOR_AGP[2][j] );
                fflush( stdout );
            }

        }

        fclose(fp); 

    } 
    else {

        /* Assign the T2 image first */
        TENSOR_AGP[0][0] = TENSOR_AGP[1][0] = TENSOR_AGP[2][0] = 0.0;

    }

    return SUCCESS;

}   /* end set_tensor_orientationsAGP() */

