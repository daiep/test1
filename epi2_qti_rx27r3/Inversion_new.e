/*@Start***********************************************************/
/* GEMSBG C source File
 * Copyright (C) 1992 The General Electric Company
 *
 *	File Name:  Inversion.e
 *	Developer:  Mohammed H. Naseem
 *	Date:  08/17/92
 *
 */

/*@Synopsis 

  Inversion.e contains the code for adding Sequential IR pulse to any
pulse sequence database.

*/

/*@Description
Different sections of inline code are defined with an explanation
that where that section should be placed within the similar section of
pulse sequence database. If no such explanation is provided, it can be
placed without restriction in that section.

InversionGlobal
---------------
Pulse width and resolution for Inversion pulse is defined.

InversionCV
-----------
Defines some CVs used in internal calculation for IR time. Defined
bandwidth for inversion pulse.

InversionInit
-------------
TI buttons, min-max value for TI, advisory support, and other CVs used
in pulse defination are initialized.

This section should be placed in cvinit() after `piadmin` CV has been
initialized. It should also be placed in cveval() after variable
declarations. This is required to support system safety checks.
TI button number, TI advisory support, rfpulse[] structure for IR
pulse, gradient pulse structure are set, pulse parameters
(bandwidth, pulsewidth, amplitude) are calculated.

InversionEval
-------------
Start time for IR gradient pulses, and total time for IR is determined.
This section should be placed in cveval() after calculation of
cs_sattime, sp_sattime, satdelay, and t_exa.

InversionCheck
--------------
Check for min-max TI time. This is a routine.

InversionPredownload
--------------------
Calculates full scale amplitude for IR pulse, and sets image header CV
for TI. Changes prescan1_tr based on TI time.

InversionPG
-----------
Gradient pulses for IR are generated here, and external RF file for IR is
copied to hardware.

InversionRSPinit
----------------
Phase, frequency offsets are initialized.

InversionPG1
------------
Wave pointer is set to external RF pulse for IR. Phase/freq offsets
are calculated, and phase/freq look-up table is generated using
setupslices()/setupphases() call.

Should be placed after buildinstr() in pulsegen() section.

InversionRSPcore
----------------
Transmit frequency is loaded in frq packet. 

Should be placed in core() in the slice loop.

*/

/*@End*********************************************************/


/* **********************************************************
   Inline File: Inversion.e
   Author:  Mohammed H. Naseem
   Date:    08/17/92


	  Author    Date       Comments
____________________________________________________________________________

sccs1.19  VB       06/19/97   Initial LX2 version       

          GFN    12/24/1998   Closed comment after declaration of invseqlen.

/main/mr_main/3          
          PH       05/11/99   MRIge52235 - use opflair instead of opuser6 for flair mode.
          LS       04/04/04     MRIge92242 - CFH IR pulse stretching problem.
          KK       06/15/05   Value1.5T DW-EPI supports IR Prep & slice overlap
          WGH/ZZ/SXZ   12/15/10   MRIhc54025 Breast DWI enhancement:
                              a. Increased flip angle to 220 for STIR
                              b. Implemented flip angle scaling for high patient weight

HD23      JM       02/04/13   HCSDM00175770: Enabling FA scaling for SPSP pulse and IR pulse for
                              3T HDx Body Transmit coil having patient weight greater than 150 Kg.

25        JM       11/21/13   HCSDM00251643: Syncup from HD23

PX25      YT      22/Apr/14   HCSDM00282488: Added support for VRMW gradient
MR27      ZZ      07/Sep/17   HCSDM00477013: Reduce Inversion pulse flip angle to reduce SAR on MR750
   ****************************************************** */


@global InversionGlobal

#undef NEWERMES			/* Define this when the new ermes */
				/* message is defined  */
#define PSD_INV_RF0_PW    8.64ms
#define RES_SILVER     432

@cv InversionCV

float yk0_killer_area = 4140.0;
/* based on 5.4 .9*4600us */
int ir_on        = 0 with {0,1,0,INVIS, "Flag for IR.",};
int ir_start     = 0 with {0,,,INVIS, "Start time for IR.",};
int irk_start    = 0 with {0,,,INVIS, "Start time for IR killer. ",};
int ir_grad_time = 0 with {0,,,INVIS, "Play time for IR gradients.",};
int ir_time      = 0 with {0,,,INVIS, "Total IR time without SATs.",};
int ir_time_total= 0 with {0,,,INVIS, "Total IR time with SATs.",};
int ext_ir_pulse = 1 with {0,1,0,INVIS, "Flag for IR pulse selection.",};
float rf0_phase  = 0 with {0.0,,0.0,INVIS,"Relative phase of 180 in cyc",};
int irslquant;
int pos_ir_start; /* irprep_support */

int bw_rf0     = 0 with {0,,,INVIS, "Bandwidth of IR pulse",};
int hrf0       = 0 with {0,,,INVIS, "Half of IR pulse width",}; 
int ir_index;	/* index for ir pulsegen */
float csf_fact=0.5;	/* gscale_rf0 scale factor for flair2  */

int ir_fa_scaling_flag = 0 with {0, 1, 0, VIS, "Scale IR pulse flip angle: 0-no, 1 yes",};

/* t1flair_stir */
int inner_spacing;
int post_spacing;

int invseqlen;     /* min time played out for inversion sequence */

/* **********************************************************
 These cvs are defined by sliceselz, and trapezoid macro in epic.h 
int pw_rf0        "Pulse width of IR pulse"
float a_rf0       "Amplitude of RF0 for IR"
float cyc_rf0     "# of cyc of RF0 for IR"
int pw_gzrf0      "Pulse width of GZ for IR"
int pw_gzrf0a     "Pulse width of ramps on GZ for IR"
int pw_gzrf0d     "Pulse width of ramps on GZ for IR"
float a_gzrf0     "Amplitude of GZ for IR"
short res_rf0     "Resolution of IR pulse"  
float gscale_rf0  "G scale factor for SLR-IR pulse"
int pw_gyk0       "Pulse width of killer for IR on Y"
int pw_gyk0a      "Pulse width of ramps for IR killer"
int pw_gyk0d      "Pulse width of ramps for IR killer"
float a_gyk0      "Amplitude of killer for IR on Y"
********************************************************** */

/* vmx 3/13/95 YI */
 int ir_rfupa    = -600 with {-1000,1000,,INVIS,"Corresponds to rfupa",};
 int ir_sys_type = 0  with{0,2,0,INVIS,"System Type 0:Standard Signa 1:VMX",};
/* end vmx */

/* dummy CVs */
int invThickOpt = 0 with {0,0,0,INVIS, "invThickOptimization mode 1==ON ",};
int invThickOpt_seqtime = 0 with {0,0,0,INVIS, "DeltaTime of IR Pulse",};
int t2flair_extra_ir_flag = 0 with {0,0,0, INVIS, "T2FLAIR Extra IR flag",};
int packs = 0 with {0,0,0, INVIS, "number of packs that can be interleaved per acq",};

/* FA scaling */
int ir_fa_scale_debug = 0 with {0, 1, 0, VIS, "Debug IR Flip angle scaling: 1-Yes, 0-No",};
 
@host InversionInit
    { /* Start of code inlined from Inversion_new.e InversionInit */
        /* vmx 3/13/95 YI */
        if( cfpwrmontyp == PMTYP_VMX ) 
        {
            ir_sys_type = 1;
            rfupa = ir_rfupa;
        }
        /* end vmx */

        /* Initialize rf structure */
        pw_rf0     = PSD_INV_RF0_PW; 
        cyc_rf0    = 2.0;
        pw_gzrf0   = pw_rf0;
        pw_gzrf0a  = loggrd.zrt;
        pw_gzrf0d  = loggrd.zrt;
        gscale_rf0 = 0.87*csf_fact;	
        res_rf0    = RES_SILVER;

        if ( (cffield == B0_30000) && (PSD_OFF == exist(opflair)) )
        {
            if( (PSD_XRMB_COIL == cfgcoiltype) 
                && ( ((TX_POS_XIPHOID == getTxPosition()) || (TX_POS_HEAD_XIPHOID == getTxPosition()) || (TX_POS_BODY == getTxPosition())) 
                     || ((TX_COIL_BODY == getTxCoilType()) && (RX_COIL_BODY == getRxCoilType())) ) )
            {
                flip_rf0 = 180.0;
            }
            else
            {
                flip_rf0 = 220.0;
            }
        }
        else
        {
            flip_rf0 = 180.0;
        }

        /* set num fields and activity for RF0 based on IR flag */
        if (ir_on == PSD_ON)
        {
            rfpulse[RF0_SLOT].num = 1;
            rfpulse[RF0_SLOT].activity = PSD_SCAN_ON;
           /*  rfpulse[RF0_CFH_SLOT].activity = PSD_PULSE_OFF; */ /*MRIge92242 - set in Prescan.e */
            gradz[GZRF0_SLOT].num = 1;   
            grady[GYK0_SLOT].num = 1;   
        }
        else
        { 
            rfpulse[RF0_SLOT].num = 0;
            rfpulse[RF0_SLOT].activity = PSD_PULSE_OFF;
           /*  rfpulse[RF0_CFH_SLOT].activity = PSD_PULSE_OFF; */
            gradz[GZRF0_SLOT].num = 0;   
            grady[GYK0_SLOT].num = 0;   
        }

        /* Round to gradient update time*/
        pw_rf0 = RUP_RF((int)rint((double)pw_rf0/(double)res_rf0))*res_rf0;

    } /* End of code inlined from Inversion_new.e InversionInit */

@host InversionEval2
    { /* Start of code inlined from Inversion_new.e InversionEval2 */

        /* **************************************************************
           RF0  CVs and bookkeeping
           ************************************************************* */
        rfpulse[RF0_SLOT].abswidth = 0.4634;
        rfpulse[RF0_SLOT].area = 0.4634;
        rfpulse[RF0_SLOT].effwidth = 0.3099;
        rfpulse[RF0_SLOT].dtycyc = 1.00;
        rfpulse[RF0_SLOT].maxpw = 1.00;
        rfpulse[RF0_SLOT].max_b1 = 0.02934;
     
        rfpulse[RF0_SLOT].nom_fa = 43.82; /* flip angle to make a_rf0/a_rf2=0.825*/
        rfpulse[RF0_SLOT].act_fa = &flip_rf0;
        rfpulse[RF0_SLOT].nom_pw = PSD_INV_RF0_PW;
        rfpulse[RF0_SLOT].max_rms_b1=0.0163276;
        rfpulse[RF0_SLOT].max_int_b1_sq=0.00230333;

        if ( (cffield == B0_30000) && (PSD_OFF == exist(opflair)) )
        {
            if( (PSD_XRMB_COIL == cfgcoiltype) 
                && ( ((TX_POS_XIPHOID == getTxPosition()) || (TX_POS_HEAD_XIPHOID == getTxPosition()) || (TX_POS_BODY == getTxPosition())) 
                     || ((TX_COIL_BODY == getTxCoilType()) && (RX_COIL_BODY == getRxCoilType())) ) )
            {
                flip_rf0 = 180;
            }
            else
            {
                flip_rf0 = 220;
            }
        }
        else
        {
            flip_rf0 = 180;
        }

        /* limit to DV platform */
        /* Open it up for HDx- HCSDM00175770 */
        if ( (cfgcoiltype == PSD_XRMB_COIL || cfgcoiltype == PSD_XRMW_COIL || cfgcoiltype == PSD_HRMW_COIL || cfgcoiltype == PSD_VRMW_COIL) || 
             (opweight > 150 && cffield >= B0_30000 && getTxCoilType() == TX_COIL_BODY &&
              cfgcoiltype == PSD_TRM_COIL && ir_on == PSD_ON) )
        {
            float fa_scaling_factor;
            fa_scaling_factor = get_fa_scaling_factor_ir(flip_rf0, rfpulse[RF0_SLOT].nom_fa, rfpulse[RF0_SLOT].max_b1);

            if (ir_fa_scaling_flag)
            {
                flip_rf0 = flip_rf0*fa_scaling_factor;
                rfpulse[RF0_SLOT].extgradfile = PSD_ON; /* MRIhc18659: No Stretching for Inversion Pulse */
            }
            else if (fa_scaling_factor < 1.0)
            {
                rfpulse[RF0_SLOT].extgradfile = PSD_OFF;
            }
            else
            {
                rfpulse[RF0_SLOT].extgradfile = PSD_ON; /* MRIhc18659: No Stretching for Inversion Pulse */
            }

            if (ir_fa_scale_debug == PSD_ON)
            {
                FILE *fp;
                fp = fopen("/usr/g/service/log/fa_scale","ab");
                if (fp!=NULL)
                {
                    fprintf(fp,"\n *********** IR FA scaling ********************");
                    fprintf(fp,"\n fa_scaling_factor  = %f", fa_scaling_factor);
                    fprintf(fp,"\n New FA             = %f", flip_rf0);
                    fprintf(fp,"\n Initial FA         = %f", (flip_rf0/fa_scaling_factor));
                    fclose(fp);
                }
            }
        }
        else
        {
            rfpulse[RF0_SLOT].extgradfile = PSD_ON; /* MRIhc18659: No Stretching for Inversion Pulse */
        }

    } /* End of code inlined from Inversion_new.e InversionEval2 */

@host InversionEval
    { /* Start of code inlined from Inversion_new.e InversionEval */
        hrf0 = (pw_rf0)/2;  
        pw_gzrf0 = pw_rf0;

        /* determine the bandwidth of IR pulse */
        bw_rf0 = 5.12*cyc_rf0/((FLOAT)pw_rf0/(FLOAT)1.0s);

        if(ir_on==PSD_ON)
        {
            /* determine the amplitude of IR pulse */
            if (ampslice(&a_gzrf0, bw_rf0, 
                         ((exist(opimode) == PSD_3D) ? exist(opvthick) : invthick),
                         gscale_rf0,TYPDEF)
                == FAILURE)
            {
                epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,
                           1,STRING_ARG,"ampslice");
            }

            /* Y Killer CVs */
            if (amppwgrad(yk0_killer_area, loggrd.ty_yz, 0.0, 0.0, loggrd.yrt,
                          MIN_PLATEAU_TIME, &a_gyk0, &pw_gyk0a,
                          &pw_gyk0, &pw_gyk0d) == FAILURE) {
                epic_error(use_ermes, "%s failed in InversionEval.",
                           EM_PSD_SUPPORT_FAILURE,1,STRING_ARG,"amppwgrad:gyk0"); 
                return FAILURE;
            }
        }

        a_gyk0 = a_gyk0 * (ir_on);

        ir_grad_time  = RUP_GRD( (ir_on)*(pw_gzrf0a + pw_rf0 + 
                                          IMax(2,pw_gzrf0d,pw_gyk0a) + 
                                          pw_gyk0 + pw_gyk0d) );

        /* irprep_support */
        pos_ir_start = RUP_GRD(GRAD_UPDATE_TIME + (int)tlead);  

        if (exist(opirprep) == PSD_ON) /* same as Inversion.e */
           ir_start = RUP_GRD(GRAD_UPDATE_TIME + tlead + 
                         IMax (2, (48us + pw_gzrf0a), minimumPreRfSspTime() - psd_rf_wait));
        else
           ir_start = RUP_GRD(GRAD_UPDATE_TIME + (int)tlead + pw_gzrf0a);

        irk_start = RUP_GRD(ir_start + pw_rf0 + pw_gyk0a);
        ir_time  = RUP_GRD( (ir_on)*(opti + pw_gzrf0a + hrf0 - cs_sattime - sp_sattime - satdelay - (hrf1a + IMax(2,pw_gzrf1a,DAB_length[bd_index]+minimumPreRfSspTime()))));
        ir_time_total = RUP_GRD( (ir_on)*(opti + pw_gzrf0a + hrf0 - t_exa) );

        if(exist(opflair) == PSD_ON)  /*recalculate ir_time*/
        { 
            ir_time = 0;
            ir_time_total = ir_time; 
        }
      
        /* t1flair_stir */
        if( t1flair_flag == PSD_ON )
        {
            ir_time = RUP_GRD( (ir_on)*(GRAD_UPDATE_TIME + (int)tlead + pw_gzrf0a + pw_rf0 +
                                        IMax(2,pw_gzrf0d,pw_gyk0a) + pw_gyk0 + pw_gyk0d) );
        }

    } /* End of code inlined from Inversion_new.e InversionEval */

@host InversionEval1
    { /* Start of code inlined from Inversion_new.e InversionEval1 */

        /* t1flair_stir */
        if( t1flair_flag == PSD_ON )
        {
            ir_time  = RUP_GRD(ir_grad_time + inner_spacing);
        }

    } /* End of code inlined from Inversion_new.e InversionEval1 */

@host InversionEvalFunc
float get_fa_scaling_factor_ir(float act_fa, float nom_fa, float nom_max_b1)
{
    double max_b1_limit, cur_b1_limit, act_b1;
    INT txIndex[MAX_TX_COIL_SETS];
    INT exciterIndex[MAX_TX_COIL_SETS];
    INT exciterUsed[MAX_TX_COIL_SETS];
    INT numTxIndexUsed = 0;
    INT i;

    if (act_fa <= 0.0 || nom_fa <= 0.0 || nom_max_b1 <= 0.0)
    {
        return 1.0;
    }

    getTxAndExciter(txIndex, exciterIndex, exciterUsed, &numTxIndexUsed, coilInfo, opncoils);
    coilB1Limit(&max_b1_limit, txCoilInfo[txIndex[0]]);

    /* handle cases with multiple transmit coils (not supposed to be executed for now) */
    for (i = 1; i < numTxIndexUsed; i++)
    {
        coilB1Limit(&cur_b1_limit, txCoilInfo[txIndex[i]]);

        if (cur_b1_limit < max_b1_limit)
        {
            max_b1_limit = cur_b1_limit;
        }
    }

    max_b1_limit = max_b1_limit/100; /* uT to Gauss conversion */
    act_b1 = nom_max_b1*act_fa/nom_fa;

    if (act_b1 <= max_b1_limit)
    {
        return 1.0;
    }

    return (float)(max_b1_limit/act_b1);
}

@host InversionPredownload
    { /* Start of code inlined from Inversion_new.e InversionPredownload */

        if(exist(opflair))
            irslquant = false_slquant1;
        else
            irslquant = 1;

        if(PSD_ON == exist(opspecir))
        {
            ihti = exist(opti);
            setexist(ihti, PSD_ON);
        }
        else if (ir_on == PSD_ON)
        {
            if (!opflair)
                ihti = opti;
            setexist(ihti,PSD_ON);

            if ( existcv(opti) && (exist(opti) > 1500ms) )
                prescan1_tr = opti + 500ms;
            else
                prescan1_tr = 2s; 

            ia_rf0 = max_pg_iamp*(*rfpulse[RF0_SLOT].amp);
            pw_omegarf0=pw_rf0;
            ia_omegarf0=-max_pg_iamp;
            rf0_phase = 0.25;
        }
        else
        {
            setexist(ihti,PSD_OFF);
        }
        rf0_phase = 0.25;
    } /* End of code inlined from Inversion_new.e InversionPredownload */

@pg InversionPG
    { /* Start of code inlined from Inversion_new.e InversionPG */
        if (ir_on == PSD_ON)
        {

            for (ir_index=0;ir_index<irslquant;ir_index = ir_index + 1) {

	        /*MRIhc26154 Support Routine Failure PopUp.*/
                SLICESELZEXT2(rf0, ir_start+ir_index*psd_seqtime,
                             pw_rf0, invthick, flip_rf0, cyc_rf0, 0,
                             1,NULL, RES_SILVER , shNvrg5b.rho, RF0_SLOT, TYPNDEF, loggrd);

                EXTWAVE2(THETA,omegarf0,ir_start+ir_index*psd_seqtime,pw_omegarf0,0,RES_SILVER,shNvrg5b.pha,
                        0,RF0_SLOT);

                TRAPEZOID(YGRAD, gyk0,RUP_GRD( pend(&rf0,"rf0",ir_index)+pw_gyk0a)+((rfupd>>2)<<2), 0, TYPNDEF,loggrd);
            }
 
        }
    } /* End of code inlined from Inversion_new.e InversionPG */
@rsp InversionPGinit

/* Frequency offsets */
int *rf0_freq;
int *rf0_pha;

@pg InversionPG1
    { /* Start of code inlined from Inversion_new.e InversionPG */
        if( ir_sys_type == 1 )
        {
            rfupa = ir_rfupa; /* vmx 3/13/95 YI */
        }

        if( ir_on == PSD_ON )
        {
            int newres;

            newres = res_rf0;
            if(PSD_ON == rfpulseInfo[RF0_SLOT].change) {
                newres = rfpulseInfo[RF0_SLOT].newres;
            }

            setperiod((int)pw_rf0/newres, &rf0, 0);

            rf0_freq = (int *)AllocNode((opphases*opslquant + 2)*sizeof(int));
            rf0_pha = (int *)AllocNode((opphases*opslquant + 2)*sizeof(int));

            setupslices(rf0_freq, rsp_info, opslquant, a_gzrf0,
                        (float)1, rhfreqscale*opfov, TYPTRANSMIT);

            for (i=0; i<opslquant; i++)
                setupphases(rf0_pha, rf0_freq, i, rf0_phase, 0, freqSign);
        }
    } /* End of code inlined from Inversion_new.e InversionPG */

/* irprep_support */
@rsp InversionRSPcore
    { /* Start of code inlined from Inversion.e InversionRSPcore */
        if (ir_on == PSD_ON)
        {
            /* Load Transmit Frequency */
	    /* MF B0 correction */
	    setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
            setiphase(rf0_pha[sliceindex], &rf0, 0);
        }
    } /* End of code inlined from Inversion.e InversionRSPcore */
