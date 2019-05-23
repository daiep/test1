/*  @Start **************************************************************************** */

/*  GEMSBG C source File
 *
 *  Copyright (C) 2010 The General Electric Company
 *
 *  File Name:  T1flair.e
 *
 *  Developer:  Zhiqian Li, Xiaoli Shawlee Zhao, Zhenghui Zhang
 *
 *  Date: 12/15/2010
 */

/*  @Synopsis 
 *
 *  T1flair.e is copied from T1flair.e used in FSE
 *
 *  Original Developer:  Steve Tan
 *  Date:       06/13/99
 *
 *  T1flair.e contains the code for the fast inversion recovery
 *  feature. Please see System Technote 9906-SE-01, and the requirement
 *  and design document T1FLAIR SRS, T1FLAIR SDD.
 *
 */

/*  @Description */

/*  @End ****************************************************************************** */

/* ************************************************************************************
  
    Inline File:    T1flair.e
    Author:         Steve Tan
    Date:           07/13/99

    Author      Date        Comments
    ---------------------------------------------------------------------------------------

    SGT         07/13/99    Initial version.

    PH          09/17/99    Changed epic_serror to epic_error for 83.

    PH          09/22/99    MRIge55955 - Remove slquant_in_ti definition.  Put 
                            it into PhaseCorr.e so that other fse family can see it. 

    AMR         01/17/00    Changes that were necessary to merge the functionality 
                            of the T1FLAIR PSD into acq_seq-XL.
                            
                            This is referred to by the comments: AMR-fsemerge 
                            
                            Brought in the SPR fix from ASP2- MRIge62566

    YH  06/27/2000  Field strength compatibility

    AF          03/26/01    MRIge65020 - Made the following changes.
    
                            T1flairGlobal:  Allowed the ability to activate
                                            t1flair_flag, opphsen and opflair cvs.
                            
                            T1flair_setup():    Enabled T1flair and PSIR features.
                            
                            T1flairPredownload():   Set bit 13 of rhformat when
                                                    opphsen is enabled.

    AF          04/20/01    MRIge65020 - Changes for unlock T1flair Leo1 Feature.

                            1.  Added code for reading the AP Processor Type and 
                                number of AP processors from the medcam.cfg file.
                            2.  Activated Fixed Imaging Options and Intermediate CVs.
                            3.  Define t1flair_flag.
                            4.  Moved all error checks in T1flairCheck function to
                                T1flair_setup function.  Deleted T1flairCheck function.
                            5.  Setup Imaging Options for T1flair in T1flair_setup function.
                            6.  Setup Effective TE, Effective TE2, TR, TI, ETL, Frequency
                                Resolution, and Phase Resolution for T1flair in
                                T1flair_setup function.
                            7.  Setup advisory panel code for Number of Echoes, ETL,
                                TR, TI, Receiver Bandwidth, Frequency Resolution, and
                                Phase Resolution for T1flair in T1flair_option function.

    AF          05/10/01    MRIge65020 - Changes for unlock T1flair Leo1 Feature.

                            1.  Added PSIR option key constraint on Phase Sensitive
                                Imaging Option control variable.
                            2.  Defined a gain variable on the auto TI algorithm.
                            3.  Limited auto TI value between 400ms and 1300ms.

    AF          05/18/01    MRIge65020 - Changes for unlock T1flair Leo1 Feature.

                            1.  Added error message to t1flair_flag definition if not
                                all conditions are met.

    AF          07/24/01    MRIge65985 - Changed autoti_scale to autoti_scale1 and established
                            new limits and default values. Defined autoti_scale2.  Adjusted
                            Auto TI algorithm with new scale factors.

    AF          07/24/01    MRIge67045, MRIge68005, MRIge68010 - Moved the definition of
                            t1flair_flag and declaration of opphsen from T1flairEval to
                            T1flairInit because scan does not execute cveval for saved
                            protocols.

    AF          08/02/01    MRIge67045, MRIge68005, MRIge68315 - For protocol retrieval,
                            scan does not set oppseq on the first pass and so t1flair_flag
                            does not get set.  Removed all conditions but opflair == 2 to
                            activate t1flair_flag.  T1flair is the only psd at this point
                            that uses opflair == 2.

    AF          08/14/01    MRIge67045, MRIge68005, MRIge68315 - Add opimode, oppseq, opfast
                            and opirmode conditions back  to t1flair_flag definition.
                            Located t1flair_flag definition at end of T1flair_Init.

                            Moved opphsen, opzip512 and opzip1024 initialization from
                            T1flair_setup to T1flair_init since the maximum value of
                            these variables is set to zero in epic.h and made them available
                            without t1flair_flag condition.

                            MRIge68157 - Default Phase Correction off and Auoshim on.

                            MRIge66933, MRIge66313, MRIge68792 - Moved avminnex condition for 
                            opphsen and opnopwrap from t1flair.e to part of opnopwrap intialization 
                            in T1flair_setup.  Corrected typo error which caused nex error message 
                            to be displayed.

                            Limited minimum nex to 1 with opphsen = 1 otherwise Phoenix artifact shows up.  
                            Adjusted Nex menu.

                            For Phase Sensitive option, increased etl limit from 10 to 32,
                            tr limit from 3s to 10s and ti limit from 1.3s to 2s.

    AF          08/22/01    MRIge68765, MRIge65985 - Modified auto TI algorithm to be 
                            bloch equation with only TR as the dependent variable.

    AF          08/24/01    MRIge68609 - Lock out Zip512 imaging option for Phase Sensitive
                            and I860 combination.

    DCZ         01/29/02    MRIge70596: Allow the type-in PSD name to turn on T1FLAIR flag 
                            also. Remove error check on how to launch T1FLAIR since it is
                            part of the merged fsemaster.
                            Transfer the incompatible error check for the Fast Recovery 
                            Option from the fsemaster.

    DCZ         05/30/02    MRIge74947: Pick up the fix from 91.merge view.
                            MRIge73471 (from 91) - Fix to solve download failures with T1flair.
			    The SPR is logged to report a download failure with T1flair with 
			    the Fat Sat imaging option. However, there are many other cases where 
			    such download failures would occur. Please refer to the enclosures
			    in DDTS for more details.
			    Inner spacing and post_spacing are needed for efficient packing 
			    (optimized interleaving) of the IR and acq_seq echotrain repetitive units
			    while simultaneoulsy maintaining the correct value of Inversion time.
			    A common trend observed in all such occurences of download failures 
			    is that the download of the pulse sequence fails due to post_spacing 
			    becoming negative for cases when slquant_in_ti is 0. slquant_in_ti = 0 
			    implies that there are no slices that can be interleaved in the inversion
			    time and in such cases the IR will be played out in a sequential manner.
			    In such cases, the post_spacing will not be of any significance. 
			    Hence for cases when slquant_in_ti is 0, post_spacing is made zero.

    JAH         07/10/02    MRIge63623: Move slquant_in_ti/slquant adjustment
                            code into a subroutine for reusability, but
                            remove the same call from the code that is used
                            to calculate the maximum slice quantity. Changed
                            the nomenclature of the slquant_in_ti value in
                            the T1flair_slquant() function to indicate that
                            this calculation is really the maximum possible
                            slquant_in_ti which doesn't need to be adjusted
                            based on the actual number of slices. Still call
                            the new slquant_in_ti update function in the 
                            T1flair_seqtime() function to adjust slquant_in_ti
                            to avoid the bad combinations.

    AMR        12/13/02     MRIge79721 - Merge from 9.1 to MGD for MGD2 - This
                            involves getting in SPR fixes from 9.1.
			    1. MRIge70354 - 07/11/02 - The maximum limit of auto TI was 1300ms 
			    when Phase Sensitive option was not enabled and 2000ms when the 
			    Phase sensitive option was enabled in the previous implementation.
                            With the present set of changes the maximum value of Auto TI is
                            2000ms irrespective of whether Phase Sensitive option is enabled or not.
                            The SPR enclosures have more details.
			    2. epic_error routine calls retained as in 9.1
    NDG        08/28/02     Merge VH3 with MGD for Corona 3T.
    NU         03/03/03     MRIge81267 - fixed improper display for opuser6.                               

    NU         03/18/03     MRIge76099 - fixed the miscalculation about sequence time.

    RS         09/05/03     MRIge81396 - Removal of Auto N Coil (opuser24)
    
    LS          3/17/04     MRIge91707 - force oppseq set to PSD_IR if type-in "t1flair".

    AK         09/02/04     MRIhc03113 - Integrating the higher max TI limits for PSIR 
                            at Edison into the product.

    YT         05/22/09     GEHmr01540 - In-range autoTR support

    YT         08/04/09     GEHmr01822 - moved TR range definition
                                         from T1flair_options() to T1flair_setup()

VSN/VAK        12/31/2009   MRIhc46886 : SV to DV Apps Sync Up

    YT         12/18/2009   GEHmr03574 - autoTI model parameters was changed to avoid 
                                         CSF banding artifact

YT/SXZ/KK      01/13/2010   MRI46824: Merge SV features/codes back to DV. Refer 
                                      the comments in fsemaster.e for the details

    YT         01/12/2010   GEHmr03616 - TI value should be displayed on UI.     

    SXZ	       05/20/2010   MRIhc49788 - Change the logic of analytical solution to handle extreme parameters
                          
    SXZ/ZQL/ZZ 12/01/2010   MRIhc54025 - Change for DWI interleaved STIR

    KM         16/03/2015   HCSDM00334071 -  Turned off T1flair_flag and introduced a new flag,
                                             ir_prep_manual_tr_mode for DWI STIR to make act_tr 
                                             consistent with input TR.       
*************************************************************************************** */


#include <T1flair.h>


@cv T1flairCV

/* epi_t1flair_stir: to make it thru compilation */
int slquant_in_ti;
int act_esp = 4ms;
int autotr_flair_debug = PSD_OFF;

int T1FLAIR_MIN_TI = 50ms;

/* MRIge70354 - Changed to 2000ms from 1300ms */
int T1FLAIR_MAX_TI = 2000ms;

int ir_prep_manual_tr_mode = 0 with {0,1,0,VIS," Flag for manual TR mode in DWI STIR",};

@host T1flairInit

/* epi_t1flair_stir */
STATUS T1flairInit( void )
{
    avminti_t1flair = T1FLAIR_MIN_TI;
    avmaxti_t1flair = T1FLAIR_MAX_TI;

    /*** T1flair Enabler ***/
    /* epi_t1flair_stir */
    /* Always use interleaved stir */

    cvmax( t1flair_flag, PSD_ON );

    cvdef( t1flair_flag, PSD_OFF );

    return SUCCESS;
}

@host T1flairEval

/* epi_t1flair_stir */
STATUS T1flair_setup( void )
{
    /* for Fat Suppression */
    autoti_model = T1FLAIR_EFFECTIVE_TR_MODEL_FAT; 
    
    if (t1flair_flag)
    {
        /* epi_t1flair_stir */
        t1flair_slice_uniformity_flag = PSD_OFF;
        req_edge_slice_enh_flag = PSD_OFF;
        act_edge_slice_enh_flag = PSD_OFF;
        force_odd_even_slquant = 0;
        t1flair_seqtime_method = ANALYTICAL_SEQTIME;
        t1flair_autotr_flag = PSD_ON;
    }
    else
    {
        /* Reset internal CVs for non T1Flair PSD */
        t1flair_slice_uniformity_flag = PSD_OFF;
        req_edge_slice_enh_flag = PSD_OFF;
        act_edge_slice_enh_flag = PSD_OFF;
        force_odd_even_slquant = 0;
        t1flair_autotr_flag = PSD_OFF;
    }

    return SUCCESS;
}


STATUS T1flair_options( void )
{
    if ((PSD_ON == t1flair_flag) || (PSD_ON == ir_prep_manual_tr_mode))
    {
        avminti = IMax(2, avminti_t1flair, T1FLAIR_MIN_TI);
        avmaxti = IMin(2, avmaxti_t1flair, T1FLAIR_MAX_TI);

        if ( (exist( opti ) < avminti) && (exist( opautoti ) == PSD_OFF) && (existcv( opti )) )
        {
            epic_error( use_ermes, "Minimum TI is %-d.",
                        EM_PSD_TI_OUT_OF_RANGE1, 1, INT_ARG, avminti / 1ms );

            return ADVISORY_FAILURE;
        }

        if ( (exist( opti ) > avmaxti) && (existcv( opti )) )
        {
            epic_error( use_ermes, "Maximum TI is %-d.",
                        EM_PSD_TI_OUT_OF_RANGE2, 1, INT_ARG, avmaxti / 1ms );

            return ADVISORY_FAILURE;
        }
    }

    return SUCCESS;
}


@host T1flairPredownload

STATUS
T1flairPredownload (void)
{
    if ( PSD_ON == t1flair_flag )
    {
        if ( ( false_slquant1 != 0 ) && ( seqtime_t1flair != 0 ) )
        {
            act_tr = false_slquant1 * seqtime_t1flair;
        }
    }
  
    return SUCCESS;

} /* end T1flairPredownload() */

