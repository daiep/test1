/*
 *  GE Medical Systems
 *  Copyright 2017 General Electric Company. All rights reserved.
 *  
 *  epiImage2OptionCheck.e
 *  
 *  Inline file that contains imaging options checks
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 5/8/01
 *
 */
/* do not edit anything above this line */

@host epi2ImageCheck

/* Function Delcaration */
STATUS checkEpi2ImageOptions( void );

/* Function Body */
STATUS
checkEpi2ImageOptions( void )
{
    int cardcv;                   /* Cardiac Gating Flag */

    /* Sequence Type Check - SE and GRE Only */
    if ( (exist(oppseq) != 1) && (exist(oppseq) != 2) ) { /* lockout IR,SSFP,SPGR,TOF,PC,TOFSP,PCSP */
	epic_error( use_ermes, "The EPI option is not supported in this scan", EM_PSD_EPI_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* No 3D yet */
    if (exist(opimode) == PSD_3D) {
	epic_error( use_ermes, "EPI is not compatible with the 3D Image Mode.  Please select 2D", EM_PSD_EPI_VOLUME_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* No Spectro-EPI Yet */
    if (exist(opimode) == PSD_SPECTRO) {
	epic_error( use_ermes, "Spectroscopy prescription failed.", EM_PSD_SPECTRO_FAILURE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* No CINE EPI */
    if ((exist(opimode) == PSD_CINE) && existcv(opimode)) {
        epic_error( use_ermes, "Cine is not available with this PSD", EM_PSD_CINE_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }
    
    /* POMP is not supported with EPI */
    if ((exist(oppomp) == PSD_ON) && existcv(oppomp)) {
        epic_error( use_ermes, "The POMP option is not supported in this scan.", EM_PSD_POMP_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }
    
    /* Tailored RF is only for FSE-based scans */  
    if (exist(optlrdrf) == PSD_ON) {
	epic_error( use_ermes, "The Tailored RF option is not supported in this scan.", EM_PSD_TLRDRF_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* Resp. Comp Check */
    if (exist(opexor) == PSD_ON) {
	epic_error( use_ermes, "Respiratory Compensation and EPI and incompatible features.", EM_PSD_EPI_RESP_COMP_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* Driven Equilibrium Prep not Supported */
    if (exist(opdeprep) == PSD_ON) {
	epic_error( use_ermes, "The DE Prep Option is not available with this pulse sequence.", EM_PSD_OPDEPREP_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
    
    /* No Mag. Transfer */
    if (exist(opmt)==PSD_ON && existcv(opmt)==PSD_ON) {
        epic_error( use_ermes, "MT not Supported", EM_PSD_MT_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }    
    
    /* IR Prep is not used with epi2 */
    if ((exist(opirprep) == PSD_ON) && (irprep_support == PSD_OFF)) {
        epic_error( use_ermes, "The IR Prep Option is not available with this pulse sequence.", EM_PSD_OPIRPREP_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }
    
    /* Can't use a graphic ROI */
    if ((exist(opgrxroi) == PSD_ON) && existcv(opgrxroi)) {
        epic_error( use_ermes, "The Graphic ROI Option is not available with this sequence.", EM_PSD_OPGRXROI_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    /* YMSmr07221, YMSmr07315 */
    if (existcv(opptsize) && (exist(opptsize) > 2) && (edr_support == PSD_OFF)) {
        epic_error(use_ermes,"EDR is not supported in this PSD.",EM_PSD_EDR_INCOMPATIBLE,0);
        return FAILURE;
    }

    /* EPI and SSFSE are not compatible */
    if (exist(opepi)==PSD_ON && exist(opssfse)==PSD_ON){
	epic_error( use_ermes, "EPI is incompatible with the Single-Shot button. Please use # of Shots = 1 for SS-EPI.", EM_PSD_EPI_SSFSE_INCOMPATIBLE, EE_ARGS(0) );
	return FAILURE;
    }
       
    /* Lock out diffusion wuth other sequence types */
    if((opdiffuse==PSD_ON) && (oppseq!=PSD_SE)) {
	epic_error( use_ermes, "Spin Echo Must Be Selected With Diffusion", EM_PSD_EPI_SEDIFFUSE, EE_ARGS(0) );
	return FAILURE;
    } 
  
    if((opdiffuse==PSD_ON)&&(oppseq==PSD_GE)) {
        epic_error( use_ermes, "Gradient Echo Not Compatible With Diffusion", EM_PSD_EPI_GEDIFFUSE, EE_ARGS(0) );
        return FAILURE;
    } 

    if((opdiffuse==PSD_ON)&&(opfcomp==PSD_ON)) {
        epic_error( use_ermes, "Flow Comp Not Compatible With Diffusion", EM_PSD_EPI_FCOMPDIFFUSE, EE_ARGS(0) );
        return FAILURE;
    }

    /* Multiphase-Diffusion is not compatible */
    if ((opmph == PSD_ON) && (opdiffuse == PSD_ON)) {
        epic_error( use_ermes, "Multi Phase not supported with diffusion", EM_PSD_EPI_MULTIPHASEDIFFUSE, EE_ARGS(0) );
        return FAILURE;
    } 

    /* MRIge51451 - Square pixel is not compatible with EZDWI. PH */
    if ( (existcv(opsquare)) && (exist(opsquare) == PSD_ON) && (EZflag == PSD_ON) ) {
        epic_error( use_ermes, "The square pixel option is not supported.", EM_PSD_SQUARE_INCOMPATIBLE, 0 );
        return FAILURE;
    }

#ifdef UNDEF
    /* MRIge57060 - lock out IIC w/ Flair or DWI */
    if( (exist(opscic) == PSD_ON) && ( (exist(opdiffuse)==PSD_ON) || (exist(opflair)==PSD_ON)) ) {
        epic_error(use_ermes,"This prescription is not allowed", EM_PSD_INVALID_RX, 0);
        return FAILURE;
    }
#endif /* UNDEF */

    /* The FAST option is not supported */
    if(opfast==PSD_ON) {
        epic_error( use_ermes, "Fast Option Not Compatible With This Pulse Sequence", EM_PSD_FAST_NOT_SUPPORTED, EE_ARGS(0) );
        return FAILURE;
    } 

    /* MRIge53672 - Make Concat SAT and multiphase EPI incompatible */
    if ( (PSD_ON == mph_flag) && (PSD_ON == exist(opccsat)) ) {
        epic_error( use_ermes, "%s is incompatible with %s ", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Concat SAT", STRING_ARG, "multiphase EPI" );
        return FAILURE;
    }
    
    /* No rect. FOV */
    if (exist(oprect) == PSD_ON) {
	epic_error( use_ermes, "Rectangular FOV is not allowed with this scan.", EM_PSD_RECT_NOT_SUPPORTED, EE_ARGS(0) );
	return FAILURE; 
    }

    /* More than 1.0 of No Phase Wrap is not supported */
    if( (exist(opnpwfactor) > 1.0) && existcv(opnpwfactor) )                                   
    {
        epic_error(use_ermes, "%s is incompatible with %s ",
                   EM_PSD_INCOMPATIBLE, 2, STRING_ARG, "More than 1.0 of No Phase Wrap",
                   STRING_ARG, "this pulse sequence");
        return FAILURE;
    }
 
    /* Caridac Gating Checks */
    cardcv = (exist(opcgate) && existcv(ophrate) && existcv(ophrep) 
              && existcv(opphases) && existcv(opcardseq) && existcv(optdel1)
              && existcv(oparr));
    
    /* MRIge65081 */
    if (exist(opcgate)) {

        if ((exist(opslquant) > avmaxslquant) && existcv(opslquant)) {
            epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxslquant );
            return ADVISORY_FAILURE;
        }
    }

    if (!exist(opcgate)) {
        if ((opautotr == 0) && (exist(optr) < avmintr) && existcv(optr) &&
            !((PSD_ON == exist(opinrangetr)) && ((PSD_OFF == existcv(opslquant)) || (PSD_AUTO_TR_MODE_ADVANCED_IN_RANGE_TR == piautotrmode)))) {
            epic_error( use_ermes, "The selected TR needs to be increased to %d ms for the current prescription.", EM_PSD_TR_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, (avmintr/1ms) );
            return ADVISORY_FAILURE;
        }
        
        if ((opautotr == 0) && (exist(optr) > avmaxtr) && existcv(optr) &&
            !((PSD_ON == exist(opinrangetr)) && ((PSD_OFF == existcv(opslquant)) || (PSD_AUTO_TR_MODE_ADVANCED_IN_RANGE_TR == piautotrmode)))) {
            epic_error( use_ermes, "The selected TR needs to be decreased to %d ms for the current prescription.", EM_PSD_TR_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG,(avmaxtr/1ms) );
            return ADVISORY_FAILURE;
        }
    } else {
   
        if ((piait < avmintseq) && (existcv(optdel1))) {
                epic_error( use_ermes, "The available imaging time is insufficient. Decrease the trigger window or the trigger delay.", EM_PSD_AIT_OUT_OF_RANGE, EE_ARGS(0) );
                return FAILURE;
        }
                
        if ((existcv(optdel1))&& ((exist(optdel1) < avmintdel1) || (exist(optdel1) > 1.6s))) {
            epic_error( use_ermes, "The trigger delay must be between %d ms and 1600 ms for the current prescription.", EM_PSD_TD_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, (avmintdel1/1ms) );
            return FAILURE;
        }
    }
    
    if (cardcv) {

        if (exist(opphases) > avmaxphases) {
            epic_error( use_ermes, "Maximum number of phases exceeded, reduce # of slices or phases", EM_PSD_MAXPHASE_EXCEEDED, EE_ARGS(1), INT_ARG, avmaxphases );
            return FAILURE;
        }

        if ((psd_tseq < avmintseq) && (existcv(opfov)) && (existcv(opcardseq))) {
            epic_error( use_ermes, "The inter-sequence delay must be increased to %d ms due to the FOV/ slice thickness selected.", EM_PSD_TSEQ_FOV_OUT_OF_RANGE, EE_ARGS(1), INT_ARG,(avmintseq/1ms) );
            return FAILURE;
        }
        
        if ((psd_tseq < avmintseq) && (existcv(opcardseq))) {
            epic_error( use_ermes, "The inter-sequence delay must be increased to %d ms.", EM_PSD_TSEQ_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, (avmintseq/1ms) );
            return FAILURE;
        }

        if (seq_type == TYPMPMP) {
            if((exist(opslquant) > 1) && (opphases != opslquant) && (opphases != 2*opslquant) && (opphases != 3* opslquant) )
            {
                epic_error( use_ermes, "The number of phases divided by locations must equal 1, 2, or 3.", EM_PSD_SLCPHA_INCOMPATIBLE, EE_ARGS(0) );
                return FAILURE;
            }
            
            if (exist(opphases)*exist(opslquant)*dwi_fphases > DATA_ACQ_MAX) {
                epic_error( use_ermes, "The number of locations * phases has exceeded %d.", EM_PSD_SLCPHA_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, DATA_ACQ_MAX );
                return FAILURE;
            }
        }
    }

    if ((exist(oprtcgate) == PSD_ON) || (navtrig_flag == PSD_ON))
    {
        if ((pirtait < avminrttseq) && (existcv(oprtarr)))  /* MRIge63264/MRIge63355 */
        {
            epic_error(use_ermes,
                       "The available imaging time is insufficient. Decrease the trigger window",
                        EM_PSD_AIT_OUT_OF_RANGE2,EE_ARGS(0));
            return FAILURE;
        }
    }    

    if (existcv(oprtarr) &&((exist(oprtarr) > MAX_RESP_WINDOW) || (exist(oprtarr) < MIN_RESP_WINDOW))) {
        epic_error(use_ermes, "The range for the trigger window is %d to %d",
                   EM_PSD_RESPTRIG_WINDOW_RANGE,EE_ARGS(2),INT_ARG,MIN_RESP_WINDOW, INT_ARG,MAX_RESP_WINDOW);
        return FAILURE;
    }

    if (existcv(oprtpoint)&&((exist(oprtpoint) > MAX_RESP_POINT) || (exist(oprtpoint) < MIN_RESP_POINT))) {
        epic_error(use_ermes, "The range for the trigger point is %d to %d",
                   EM_PSD_RESPTRIG_POINT_RANGE,EE_ARGS(2),INT_ARG,MIN_RESP_POINT,INT_ARG,MAX_RESP_POINT);
        return FAILURE;
    }

    if (existcv(oprtcardseq)&& (exist(oprtcardseq) == PSD_CARD_INTER_OTHER) && (exist(oprttseq) < avminrttseq)) {
        epic_error(use_ermes, "The inter-sequence delay must be increased to %dms",
                   EM_PSD_RESPTRIG_MIN_INTERSEQ,EE_ARGS(1),INT_ARG,(avminrttseq/1ms));
        return FAILURE;

    }

    if (((exist(opcgate) == PSD_ON) && existcv(opcgate)) &&
        ((exist(oprtcgate) == PSD_ON) && existcv(oprtcgate))) {
        epic_error(use_ermes, "Respiratory triggering and gating are not compatible",
                   EM_PSD_GATING_RESPTRIG_INCOMPATIBLE,0);
        return FAILURE;
    }

    if ((exist(opileave) == PSD_ON) && (exist(oprtcgate) == PSD_ON)) {
        epic_error(use_ermes,
                   "The interleave option and respiratory triggering cannot be selected at the same time.",
                   EM_PSD_ILEAV_RESPTRIG_INCOMPATIBLE, EE_ARGS(0));
        return FAILURE;
    }

    if ((exist(opileave) == PSD_ON) && (navtrig_flag == PSD_ON)) {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "The interleave option", STRING_ARG, "Navigator");
        return FAILURE;
    }

    if((exist(opirmode) == PSD_ON) && (exist(oprtcgate) == PSD_ON)) {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Sequential", STRING_ARG, "Respiratory Triggering");
        return FAILURE; 
    }

    if((exist(opirmode) == PSD_ON) && (navtrig_flag == PSD_ON)) {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Sequential", STRING_ARG, "Navigator");
        return FAILURE; 
    }

    if ((VALUE_SYSTEM_SVEM == value_system_flag) || (VALUE_SYSTEM_SVDM == value_system_flag) || (PSD_ON == k15_system_flag))
    {
        if ((exist(oprtcgate) == PSD_ON) &&
             existcv(oprtrate) && existcv(oprtrep) && existcv(oprtarr)) {
            if ((exist(opslquant) > avmaxslquant) && existcv(opslquant)) {
                epic_error(use_ermes,"Maximum slice quantity is %-d",
                           EM_PSD_SLQUANT_OUT_OF_RANGE,EE_ARGS(1),INT_ARG,avmaxslquant);
                return ADVISORY_FAILURE;
            }
        }

        if ((navtrig_flag == PSD_ON) &&
             existcv(oprtrate) && existcv(oprtrep) && existcv(oprtarr)) {
            if ((exist(opslquant) > avmaxslquant) && existcv(opslquant)) {
                epic_error(use_ermes,"Maximum slice quantity is %-d",
                           EM_PSD_SLQUANT_OUT_OF_RANGE,EE_ARGS(1),INT_ARG,avmaxslquant);
                return FAILURE;
            }
        }
    }

    if ((exist(opileave) == PSD_ON) && (exist(opcgate) == PSD_ON)) {
        epic_error(use_ermes,
                   "The interleave option and cardiac gating cannot be selected at the same time.",
                   EM_PSD_ILEAV_CGAT_INCOMPATIBLE, EE_ARGS(0));
        return FAILURE;
    }

    /* MRIhc07638/MRIhc07639 - Merge of fix from Value 1.5T for SPRs
    YMSmr06637/YMSmr06638 - Removed the check for the existence
    setting for the epi_flair flag */
    /* MRIge51503 - Gating is not compatible with DWI or flair. */
    /* MRIge57057 - Gating is available for DW-EPI in 84 */
    if ( (exist(opcgate) == PSD_ON) && (epi_flair == PSD_ON) )
    {
        epic_error( use_ermes, "Cardiac Gating is not supported by this pulse sequence.", EM_PSD_GATING_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    if ( (exist(oprtcgate) == PSD_ON) && (epi_flair == PSD_ON) )
    {
        epic_error( use_ermes, "Respiratory triggering is not supported by this pulse sequence.", EM_PSD_RESPTRIG_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    if ( (navtrig_flag == PSD_ON) && (epi_flair == PSD_ON) )
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Navigator", STRING_ARG, "FLAIR");
        return FAILURE;
    }

    /* YMSmr09726 */
    if( exist(opasset) && (val15_lock == PSD_ON) ){
        if(!strcmp( coilInfo[0].coilName, "GE_HDx 8NVARRAY_A")){
            epic_error( use_ermes, "%s is incompatible with %s.",
                            EM_PSD_INCOMPATIBLE, 2,
                            STRING_ARG, "EPI ASSET",
                            STRING_ARG, "8NVARRAY_A");
            return FAILURE;
        } else if(!strcmp( coilInfo[0].coilName, "GE_HDx 8NVANGIO_A")){ 
            epic_error( use_ermes, "%s is incompatible with %s.",
                            EM_PSD_INCOMPATIBLE, 2,
                            STRING_ARG, "EPI ASSET",
                            STRING_ARG, "8NVANGIO_A");
            return FAILURE;
        }
    }

    /* HCSDM00150820 */
    if (NON_SELECTIVE == exist(opexcitemode))
    {
        epic_error( use_ermes, "%s excitation is incompatible with %s.",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Non-selective", STRING_ARG, "EPI" );
        return FAILURE;
    }

    /* Focus diffusion not compatible with ASSET */
    if (rfov_flag && (exist(opasset) > PSD_OFF))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Focus", STRING_ARG, "ASSET" );
        return FAILURE;
    }

    /* Focus diffusion not compatible with FLAIR */
    if (rfov_flag && (exist(opflair) == PSD_ON))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Focus", STRING_ARG, "FLAIR" );
        return FAILURE;
    }

    /* Focus diffusion not compatible with gradient moment nulling */
    if (rfov_flag && (exist(opfcomp) ==  PSD_ON))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Focus", STRING_ARG, "Flow Compensation" );
        return FAILURE;
    }

    return SUCCESS;

}   /* end checkEpi2ImageOptions() */

