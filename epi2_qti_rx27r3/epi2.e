/* GEMSBG C source File
 * @Copyright 2017 General Electric Company. All rights reserved.
 *
 *	File Name:  @filename@   
 *	Developer:  P. Licato, F. Epstein
 *
 * $Source: epi.e $
 * $Revision: 1.183 $  $Date: 12/14/95 16:45:25 $
 */

/*@Synopsis 
  Spin or gradient recalled echo planar imaging sequence.
*/     

/* **************************************************************************
 int
 rev#   date        person  comments
 -----  --------    ------  -------------------------------------------------
 6/01/01    BJM: MGD Related changes:
            Changed setfilter calls to support new interface.
            Stripped most fast receiver code.  
            Moved Old 5x/LX comments to Comments file
            Added SetHWMem() call in pulsegen
            Added dummylinks call on MGD side
 5/10/01    Moved common code to inlines (calibration checks, rtd loop,
            maxwell correction, PSD compatibility checks)
            Removed more fast receiver code.
            Got rid of #ifdef MGD conditional code
            Added Omega Scale for 24Bit sequencers
            Increased default TE so pulsegen succeeds on first iteration thru
           
 11.0   02/25/03    NU    MRIge71092: check UserCVs 

 11.0   24/04/03    RS    MRIge83258 Turned ON opvbw for both epi.e and epi2.e

 11.0   04/09/03    HD    MRIge81510 Added Delay_insensitive SpSp pulse for 1.5T  

G3 Jan/29/04 SXZ MRIge90940: modify setreadpolarity() to adapt to the 
                 EP_TRAIN() change of always using two ramp pulses.

12.0    03/04/04    HKC   MRIge90803: Reduced MINB_VALUE to 10 (from 100).

12.0    03/12/04    SVR   MRIge91727: Changes for supporting > 1024 im/ser

12.0    05/19/04    AMR   MRIge93847: PSD override functionality for ASSET.
                          Only a phase acceleration factor of 2 which is 
			  also the default will be allowed. Type-in is not 
			  allowed as per the requirement.

12.0    06/23/04    SVR   MRIhc00610: Limit rhnpasses to 512.

12.0    12/03/04    TRS   MRIhc05227: Removed the slice variation seen in DTI
                          + DSE images by adding X and Y crushers around the
                          first 180.  Crushers were added to the left 180 to
                          avoid any performance derating.

12.0    12/03/04    TRS   MRIhc05228: Corrected scan time for DTI by setting
                          dda_pack to dda for non flair sequences.

12.0    12/13/04    TRS   MRIhc05259: Adjusted positioning and pws of the left
                          and right x and y axis crushers to avoid 
                          gradient faults for very thin slices for dse.

14.0    03/10/05    ZL    MRIhc06452: the applied the b-value in DSE case was
                          10% lower than opbval, due to the miscalculation
                          of Delta_time in DTI.e, fix has been made.

Value1.5T 04/08/05  KK    YMSmr06515: # of slice locations expansion
                          Max # of slice is 512 for EPI.
Value1.5T 05/19/05  YI    Added Mild Note(Silent Mode) support changes.

14.0    05/30/05    AMR   Merge of fix for YMSmr06637/YMSmr06638 - Flair EPI
                          should be incompatible with Cardiac gating.

Value1.5T 05/31/05  KK    Value1.5T with DCERD2 does not support BACC.
                          Value1.5T Ghost Check (ghost_check)

Value1.5T 06/15/05  KK    Value1.5T DW-EPI supports IR Prep & slice overlap

14.0    06/08/05    LS    MRIge91793 cal files moved to /usr/g/caldir

14.0    06/06/05    ZL    MRIhc05854 and MRIhc14931

14.0	06/27/2005	 MRIhc08159: Added initializations of SCAN_INFO, RF_PULSE_INFO, PHYS_GRAD 
                         and LOG_GRAD. Also added explicit braces around if..else constructs the 
                         Vxworks compiler complained about

14.0  07/16/05 ZL        MRIhc05898: EPI sequence download failure for patient weight above 130kg  
                         with BODY or SURFACE coil on long bore system. This is caused by spsp pulse
                         , we can not stretch spsp pulse. The fix is to reduce flip angle when  
                         patient weight is above 130kg. This is a short term fix, a better
                         one would be designing a better spsp pulse.       

14.0  08/04/05 ZL      MRIhc09115 - YMSmr07202 - Gating + MPH + rhpcspacial = 0 
                                    causing refscan hang, due to
                                    improper setting of rhreps. fixed.

14.0  08/04/05 ZL      MRIhc09116 - YMSmr06685 - Add support for opsldelay>15s for FLAIR EPI+MPH

Value1.5T 08/08/05 KK  YMSmr07455 - Add support for Auto Voice

Value1.5T 08/09/05 KK  YMSmr07471 - fixed scan time calculation for Flair EPI

14.2  04/12/06 ARI     MRIhc14923 - Remove GRAM model.

14.2  06/27/06 SHM     MRIhc16090 - Assigning esp to minseqcoil_esp.

14.2  07/10/06 ARI     MRIhc16496 - Change minseq() function interface.

14.2  08/21/06 ARI     MRIhc17250 - Moved scale_dif* calculations to calcPulseParams().
                                    This is for diffusion gradients scaling.

14.2  09/08/06 ARI     MRIhc18055 - Remove pgen_debug flag.

14.2  10/17/06 TRS     MRIhc19235 - Resolved issue with b-value.txt output.

14.5 10/09/06  TS      MRIhc15304 - coil info related changes for 14.5

14.0  28 Jan 2007 HT   MRIhc30240: xtarg and vrgf_targ need to be readjusted
                       when tsp is below the hardware limit to prevent
                       frequency direction aliasing artifact at big FOV (as in MRIhc23123).

20.0  03/22/07 SWL     MRIhc21901,MRIhc23348, MRIhc23349 - new BAM model 
                       supports multi phase, dynaplan phase, and requires 
                       less input arguments in maxslquanttps().

14.0  05/30/2007 SWL MRIhc24523: the scan time calculation should include
                     TR_SLOP only in the case of using line gating: TRIG_LINE

20.0  06/27/2007 LS  MRIhc24436, MRIhc20970: Supports for displaying grayed out fields: RBW.

14.0  08/16/2007 SWL MRIhc24247, MRIhc24896, MRIhc25363 : wormhole artifact :
                     Increased number of overscan for ASSET to 16

20.0  08/24/2007 KK  MRIhc26000: Corrected the position of gz1.

20.0  10/10/2007 SWL MRIhc27256, MRIhc27357: 
                                 The scan time needs to exclude TR_SLOP when 
                                 line triggering is not used.

20.0  10/10/2007 SWL MRIhc27257, MRIhc27350:  
                                 xtarg and vrgf_targ need to be readjusted 
                                 when tsp is below the hardware limit to prevent frequency 
                                 direction aliasing artifact at big FOV.  

20.0  10/11/2007 SWL MRIhc27255, MRIhc27359:  
                                 The num_overscan needs to be increased to 16
                                 for ASSET to reduce wormhole artifafct.

20.0  10/11/2007 SWL MRIhc27254, MRIhc27361:  
                                 The slice ordering for cardiac gating should
                                 be interleaved instead of being block sequential.

20.0  10/17/2007 ARI MRIhc27631 Change obloptimize to obloptimize_epi function

20.0  10/29/2007 SWL MRIhc27872 : Increase max number of slices to 50k.

14.0  11/02/2007 SWL MRIhc24903 : slice to slice variation for cardiac gating is reduced by reordering
                                  slice acquisition.

20.0  11/30/2007 KK  MRIhc19114 : Fixed rounding for asset_factor

20.0  10/24/2007 HT MRIhc24730:  Bandpass asymmetry correction will not be applied on DVMR receive chain hardware 
                                 and hence change was made to have the correction run only for non-DVMR systems.

20.0  12/4/2007  SRW MRIhc28734  Use weighted diffusion averaging when diffusion
                                 lobes are active for less than 5 minutes on a 
                                 single axis.
                            
20.0  12/20/2007 RVB MRIhc27551 Pititle was set according to piuset.

20.0  01/08/2008 SWL MRIhc30004  The disdaq for DW EPI and DTI need to be changed to 1, 
                                 and the disdaq algorithm needs to be fixed, as the
                                 second disdaq and all of the subsequent slices are 
                                 mistaken as dummy slices for single acquisition.

20.0  01/10/2008 KK  MRIhc32172 Corrected the number of count down for Gating. Disdaq runs only in 1st pass.

20.0  01/23/2008 SWL MRIhc32437 Corrected the core for FLAIR to have the correct scan time, and added debug_core for the core debugging functionality.

20.0  01/23/2008 SWL MRIhc32438 The rotation matrix for FLAIR inversion needs to be updated in a correct way.

14.0  02/19/2008 HT  MRIhc32357: disdaq is executed only in 1st pass (for T2 images) on DT-EPI.
                     Removed extra disdaqs from the calculation of nreps, as in MRIhc32172.

15.0  04/16/2008 SWL MRIhc35936: rampopt is turned on for all configurations to reduce edge ghosting

20.0  06/04/2008 SWL MRIhc37103: For patient weight higher than 158kg, spsp pulse is disabled, 
                                 and fat sat is forced to prevent download failure. For research mode, 
                                 this can be overrided via a CV override_fatsat_high_weight.

20.0  06/10/2008 SWL MRIhc35951: The removal of SPSP RF pulse 3024850 caused minimum slice 
                                 thickness increase. The pull down menu for slice thickness 
                                 was adjusted. 

20.0  07/15/2008 SWL MRIhc38838: B0 dither calibration is removed for DVMR hardware. The EPI2
                                 PSD no longer checks or reads from b0 dither cal files.

15.0  08/18/2008 SWL MRIhc39443: IR prep and Respiratory triggering is enabled for 15.0. 

15.0  08/27/2008 SWL MRIhc39583: opuser6 was made invisible for FLAIR EPI. And the algorithm to 
                                 determine max TI was changed.

20.1  09/17/2008 GW MRIhc39849:  Flair EPI with Dyna-Plan failed to prep scan.  Reset rhnphases   
                                 equal to opfphases when enable_1024 is off.

20.1  10/22/2008 KK MRIhc40140:  Limited the input into setperiod() less than MAX_INST_PERIOD.

20.1  10/31/2008  GW MRIhc38807: Set rspnex=2 in mps2 and aps2 to fix ScanTR noise issue

20.1  11/24/2008  GW MRIhc40249: Added maxavslquant limitation check for DTI

20.1  12/09/2008  GW MRIhc40043: Turned on support of min Full TE and type-in TE for
                                 DWI/DTI in research mode

20.1  12/11/2008 GW MRIhc41215:  Increased maximum allowed b-value to 10,000 for DTI

20.1  02/02/2009 GW MRIhc41700:  Added num of tensor directions check in DTI_Eval when calling
                                 set_tensor_orientations() for DTI 

20.1  02/05/2009  GW MRIhc41862: Modified calculation of Rf2Location to avoid double
                                 psd_rf_wait shift of rf2 pulse

20.1  02/20/2009 SWL MRIhc42143: Moved DTI_eval() to the end of the cveval() in order to avoid
                                 acq check error during protocol load.

20.1  02/24/2009  GW MRIhc42202: Removed gap between slice selection gradient and
                                 z-direction flow comp gradient when ss_rf1 = 1

SV20.1 03/10/2009 Lai GEHmr01484: Psd support for "In range Auto TR"

SV20.1 04/03/2009 DQY GEHmr01498: To support new XFD ID and SR100

21.0   04/24/2009 GW  MRIhc43183: Applied different ways to calculate end of slice selection
                                 gradient for target and host to avoid pulsegen failure
                                 in host side (MRIhc42387 on 20.1)

SV20.1 06/11/2009 Lai GEHmr01641: Flair EPI and DWI+Flair do not support in-range autoTR.

21.0   06/23/2009 SWL MRIhc43857: Derate the max gradient for DWI down to 3.21G/cm per XPS 
                                 performance spec.

21.0   06/23/2009 SWL MRIhc43907: Increased max b value to 10000 for DWI and DTI. 

21.0   07/28/2009 GW  MRIhc44186: Corrected the value of ia_gy1 for corner point generation
                                 in pgen_on_host

SV20.1 07/29/2009 DQY GEHmr01828: Maximum B-value is wrong for DTI

SV20.1 07/29/2009 Lai GEHmr01831: When changing from DWI to DTI, cvinit() does not run, 
                                   add similar code as cvinit() in cveval() to initial TR popup menu.

SV20.1 07/30/2009 KK GEHmr01833: Lower XFD power limit for DW-EPI

SV20.1 07/30/2009 KK GEHmr01834: Increase num_overscan for ASSET and derate Gmax for DW-EPI

21.0   08/14/2009 GW  MRIhc44763: Removed the max gradient derating (3.21G/cm) code in cveval.

22.0  01/11/2009 RBA MRIhc42465: Put in support for new Parallel Imaging UI

22.0  12/18/2009 GW  MRIhc46827: eDWI feature promote

22.0  12/31/2009 VSN/VAK  MRIhc46886: SV to DV Apps Sync Up

22.0  01/06/2010 GW  MRIhc46915: Changed CV7 description and error message

22.0  01/06/2010 GW  MRIhc46916: Fixed Diffusion ALL noise image issue

22.0  01/06/2010 GW  MRIhc46917: Fixed the issue that TENSOR imaging could not be prescribed

22.0  01/20/2010 GW  MRIhc47056: set rhnumdifdirs for both DWI and DTI. 
                                 Recon will use rhnumdifdirs to tell scan is DWI or DTI:
                                 if rhnumdifdir < 6, it is DWI, and >=6, DTI.

22.0  01/25/2010 GW MRIhc46720: Fixed the cornerpoint file error when Gradient Optimization
                                for Diffussion ALL is on. Implemented b-value weighted gradient 
                                scale calculation

22.0  01/25/2010 GW MRIhc47275: Set opdifnumt2 to 1 if opdifnumt2 > 1

22.0  02/08/2010 GW MRIhc47601: Changed disdaq to the second FLAIR pack for Flair EPI.

22.0  02/08/2010 GW MRIhc47064: Corrected the rhreps value for Flair EPI

22.0  02/08/2010 GW MRIhc47065: Set the RHTYP1DIFFUSIONEPI bit of rhtype1

22.0  02/15/2010 GW MRIhc47421: Set avmindifnextab and avmaxdifnextab correctly when edwi option key
                                is absent.

22.0  02/16/2010 GW MRIhc46287: Enabled IR prep (STIR) for 3T 

22.0  02/17/2010 GW MRIhc46720: Implemented b-value weighted gradient scale calculation
                                based on b-value itself instead of diffusion gradient amplitude

22.0  03/01/2010 GW MRIhc46718: Increased max slice limit to 50,000 for DWI

22.0  03/01/2010 GW MRIhc48152: Added range change on # of T2 images

22.0  03/05/2010 GW MRIhc46623: Added more check on opnex for Flair EPI

22.0  03/31/2010 GW MRIhc48349: Added autocvs for #b-values, NEX for T2,
                    MRIhc48927: and # of T2 of images. Applied the new PSD/Scan
                                communication mechanism: PSD sets opcvs and
                                Scan reads them to update UI.
                                
22.0  03/31/2010 ZZ MRIhc48885  Added ASPIR fatsat support to DWI.
                                Added CV5 to allow chosing between Homodyne or Zero-Filling recon

22.0  04/07/2010 ZZ MRIhc48883  Increased time_ssi based on firmware recommendation

22.0  05/07/2010 GW MRIhc49589  For Tetrahedral, 3in1 and Grad Opt for Diff ALL, turned on 
                                invertSliceSelectZ by default and adjusted polarity of XY crushers 
                                to maximize crusher amount for killing unwanted signals

22.0  05/24/2010 GW MRIhc50121  added defensive fix in epi2.e and blipcorrdel.c

22.0  06/22/2010 GW MRIhc51386  set invertSliceSelectZ off by default

22.0  07/19/2010 GW MRIhc52013  added a warning message for ADC map creation if skip T2 and one 
                                single bvalue are prescribed

22.0  09/07/2010 GW MRIhc52673  added CV invertSliceSelectZ2 to control inverting SliceSel Grad and Z Crusher 
                                based on polarity of Z Crusher

22.0  09/10/2010 GW MRIhc52716  Used minimum of tx,y,z_xyz to calculated the crusher amplitude for 180 RF if
                                X and Y crushers are enabled

22.0  09/16/2010 GW MRIhc52785  Added limitation for 3in1, Tetra and Diffusion All GradOpt to deal with 
                                low line setting

16.0  10/10/2010 SR MRIhc52977  eDWI feature promote to HDxt-Apps.

22.0  11/16/2010 SXZ/ZQL/GW/LS/ZZ MRIhc54025
                                Implement t1flair for epi, this feature can also be used
                                for interleaved STIR to same scanning time
                                Keyword: t1flair_stir

16.0  12/07/2010 SR MRIhc53929  TI button shows up in the DWI UI even when its not compatible. 
                                FLAIR+ASSET is not compatible for NON_VALUE_SYSTEM. 

22.0_RELI 12/08/2010 XZ MRIhc53613 UPDATE FGRE/EFGRE3D/EPI2/FSEMASTER for spec mode

16.0  12/16/2010 GW MRIhc54224  Inverted slice gradient and frequency of rf0 when rf1 is inverted

22.0_RELI 01/11/2011 KK MRIhc54476 Overwrite opdifnumdirs using num_dif for non-DTI.

16.0  01/13/2011 SR MRIhc54480: Overwrite opdifnumdirs using num_dif for non-DTI

22.1  02/04/2011 GW MRIhc53096: Made ASSET factor editable and maximum allowed value depending on coil setting.

23.0  03/29/2011 KK MRIhc56084: Min Full TE and type-in TE for DWI/DTI in clinical mode.

23.0  03/30/2011 GW MRIhc55375  Increased time_ssi to 2ms when etl > 192

23.0  04/05/2011 GW MRIhc56035: smart # of overscan lines: num_overscan is determined based on the
                                difference between minTE and given TE when the given TE is between minTE
                                and min Full TE.

23.0  04/06/2011 SR MRIhc56268: Use dualspinecho_flag for DSE.

23.0  04/18/2011 YI MRIhc56453: Supported XRMW coilse case for ART.

23.0  04/28/2011 UNO MRIhc56520: Image distortion in EPI with ART on 750w.
                                 SR is set to 50 instead of 20 for EPI family with ART.

23.0  06/01/2011 GW MRIhc51912:  When max b1 is exceeded, scale flip angle of rf1 spsp pulse to its max 
                                 allowed value (if < 90 degree) and stretched inversion pulse rf0

23.0  06/01/2011 KK MRIhc57164: Disabled Interleaved STIR with Sequential.

23.0  06/08/2011 GW MRIhc57367: PSD changes for the workflow issues of switching between 
                                Diffusion Direction and changing #bvalues.

23.0  06/13/2011 GW MRIhc57278: added a new spsp pulse for Breast Enhance Fat Suppression to get min slice
                                thickness 4mm for 750W.

23.0  06/13/2011 KK MRIhc57184: Corrected logic for rf chopping.

23.0  06/15/2011 KK HCSDM00077127: Added epi2is type-in psd to allow reduced image size


23.0  06/20/2011 GW HCSDM00081978: Forced cfaccel_ph_maxstride as 2 if it is < 2 and cleaned up the Parallel
                                   Imaging UI -related code.

23.0  07/14/2011 YI HCSDM00086557: Replaced aspir_flag with opspecir for CV18 availability condition
                                   to avoid returnig value to 0 in protocol loading. 

23.0  07/14/2011 GW HCSDM00086245: Moved full k #frames calculation to cveval() and changed ceil()
                                   to ceilf().

23.0  08/02/2011 GW HCSDM00089979: Enabled negative slice spacing.

23.0  08/17/2011 GW HCSDM00093061: Corrected nreps calculation for smart NEX.

23.0  10/13/2011 GW HCSDM00103468: Added 1) calling set_tensor_orientations() and 2) comparison of weighted 
                                   average gradient flag and average b-values to their previous values,
                                   to ensure minseq() is called with the latest diffusion gradient settings.

23.0  10/18/2011 KK HCSDM00104217: Use rhpccoil=0 for DW EPI ASSET with 16ch Breast coil.

23.0  10/18/2011 KK HCSDM00104219: Disallowed 2nd shim volume with CV9 = OFF.

HD23  10/28/2011 SR HCSDM00095279: Setting avmin and avmaxnshots = 1 for Diffusion and Tensor.

HD23  10/28/2011 SR HCSDM00101381: Bandwidth field displayed on UI with ramp sampling for Diffusion cases.

HD23  10/28/2011 SR HCSDM00076110: Whole mode max FOV opened up to 60cm, similar to zoom mode for HD systems.

23.1  11/22/2011 GW HCSDM00106987: added type-in PSD epi2wwwl to set rhnew_wnd_level_flag=1.

23.0  02/28/2012 KK HCSDM00125360: Corrected position of SpSat with Gating and Minimum Trigger Delay. 

23.0  02/29/2012 KK HCSDM00125504: Inserted adequate delay time for MPH with auto voice.

24.0  07/19/2012 YT HCSDM00147804: Body Navigator feature promote

DVVCP 06/06/2012 GW HCSDM00140157: redudced flip angles of rf1 and rf2 for 8BRBrain, Head 24, 32CH Head, 
                                   NV Head, and HNS Head coils. Type-in PSD epi2cl to get back to legacy.

24.0  07/19/2012 YT HCSDM00147804: Body Navigator feature promote

24.0  08/23/2012 YT HCSDM00153103: skip first reference scan for sequence with RR measusrement

24.0  08/20/2012 PW HCSDM00150820: Focus reduced FOV feature promote

24.0  08/24/2012 MK HCSDM00079558: Changed the display of Auto TI.
                    HCSDM00079165: Changed CVs to apply In-Range TR.

24.0  08/23/2012 YT HCSDM00153381: scan time calculation was modified in Body Navigator

24.0  09/27/2012 PW HCSDM00155198: DSE UI-related changes for Focus. 

24.0  10/10/2012 MK HCSDM00160749: Moved the calculation of other_slice_limit

24.0  10/11/2012 MK HCSDM00157147: Set the default value of min/maxTR for In-Range TR

23.0  10/30/2012 DX KK HCSDM00168191: Added refless EPI support with CV17, where ref entry point is removed and
                                      actual ref is moved into scan entry point.

24.0  11/14/2012 PW HCSDM00155513: Focus DWI incompatible with vrgf_bwctrl. 

23.0  11/15/2012 KK HCSDM00168896: Updated default of TGenh to -5.5. Added HNS Head.

24.0  12/03/2012 YI HCSDM00150228: Changed for oblique 3in1 optimization.

24.0  12/21/2012 YT HCSDM00176499: moved skip_navigator_prescan setting

HD23  02/04/2013 JM HCSDM00175770: Enabling FA scaling for SPSP pulse and IR pulse for
                                   3T HDx Body Transmit coil having patient weight greater than 150 Kg.

24.0  02/19/2013 KK HCSDM00186497: Made refless EPI compatible with Body Navigator.

24.0  02/19/2013 GW HCSDM00186215: enabled EDR for DWI.

24.0  03/05/2013 DX HCSDM00187748: High Order Eddy Current Correction (HOECC) feature promote

24.0  03/06/2013 KK HCSDM00188569: set optr for Respiratory triggering/Body Nav/Cardiac Gating.

24.0  03/07/2013 DX HCSDM00189818: Enable HOECC for Refless EPI.

24.0  03/08/2013 YT HCSDM00182858: navigator prescan cannot be skipped in LSQ method if RtpEnd is called after refscan 

24.0  03/13/2023 GW HCSDM00190972: SSE TE reduction enhancement.

24.0  03/13/2013 ZZ HCSDM00190926: Auto TI model for ASPIR

24.0  03/14/2013 DX HCSDM00190686: Error checking for DTI with both DSE and HOECC off, in absence
                                   of HOEC calibration file, with FOCUS off and under clinical mode.

24.0  03/20/2013 GW HCSDM00192305: Called get_diffusion_time once more after minTE and minFullTE are calculated
                                  when fract_ky == PSD_FULL_KY for SSE TE reduction enhancement.

24.0  03/22/2013 ZZ HCSDM00192858: Insufficient Fat Suppression for DWI ASPIR

24.0  04/05/2013 KK HCSDM00195152: Reduced HOEC_MAX_SLQUANT to 150 to improve PSD download time.

24.1  04/15/2013 GW HCSDM00196688: added type-in PSD epi2alt to reserve phase encoding polarity

24.0  05/10/2013 DX HCSDM00199755: Disallowed bridging of gx1 and the first readout ramp for HOECC

24.0  05/14/2013 DX HCSDM00199374: Increased time_ssi for HOECC

24.0  05/24/2013 KK HCSDM00202538: Set act_acqs for Auto TR calculation.

SV23  09/21/2011 WJZ HCSDM00097735: Enhance the upper limit of the maximum b-value for 16Beat system
                                    under certain cases, at the request from the sales team.

23.0  10/09/2011 Lai HCSDM00102521: Update cfxfd_power/temp_limit by modify CVs xfd_power/temp_limit.

24.0  08/28/2013 KK HCSDM00232516: Increased maximum TR for triggering.

25.0  10/03/2013 DX HCSDM00241747: HOECC code improvement to address comments from static analysis

25.0  11/21/2013 JM HCSDM00251643: Syncup from HD23

25.0  11/12/2013 DX HCSDM00249865: Initializes inversRR for HOECC under Tetra, 3in1, or Diff All with gradopt

25.0  02/14/2014 GW HCSDM00266616: Moved rfpulse parameter setting of inversion pulse prior to scalerfpulses calling

25.0  03/13/2014 GW HCSDM00254124: added a op-cv opnumgroups to get number of MSMA groups which is used for
                                   compaibility control between MultiGroup Rx and FOCUS or RFTA.

PX25 22/Apr/2014 YT HCSDM00282488: Added support for KIZUNA gradient thermal models

SV25 28-JAN-2014 WJZ HCSDM00259122: 1. a Type I pulse is added with accordant calculations;
                                      2. walking-saturation band added out of pFOV;

SV25 28-Jan-2014 WJZ HCSDM00259119: eco-MPG implementation;

MP24 05/29/2014 GW HCSDM00284732: added user CV16 to enable the new phase correction algorithm and research CV
                                    ref_volrecvcoil_flag to switch to volume receive coile for reference scan

25.0  07/10/2014 GW HCSDM00300892: set act_acqs for Interleaved IR-Prep + Auto TR

PX25 19/Aug/2014 KA HCSDM00304929: Changed code related to coil name for KIZUNA

PX25 25/Jul/2014 YT HCSDM00289004: support APx for breathhold scan

25.0  09/04/2014 GW HCSDM00310060: Locked out FOCUS for type-in PSD epi2alt

SV25  03/18/2015 MXX HCSDM00339822: deactivate new PC for Mulan SV systems.    

25.0  10/28/2014 GW HCSDM00317500: Set the RHPCCTRL_NN_PROJ bit of rhpcctrl for Breast coils

25.0  02/05/2015 YS HCSDM00332834: Support PX25 coil name

PX25 16/Feb/2015 YT HCSDM00335525 HCSDM00341446: Limit MPG Gmax and EPI Gmax based on HW requirement change

PX25 27/Feb/2015 YI HCSDM00337293: Fixed loading error of epi2gspec.

PX25 08/Mar/2015 YI HCSDM00339202: Fixed SR deviation on blip pulses.

PX25 17/Mar/2015 KM HCSDM00334071: Turned off T1flair_flag and introduced a new flag,
                                   ir_prep_manual_tr_mode for DWI STIR to make act_tr consistent with input TR.

PX25 26/Mar/2015 YT HCSDM00342577: Set brain TGenh to -8.0 for KIZUNA system

PX25 26/Mar/2015 YT HCSDM00342579: set the RHPCCTRL_NN_PROJ bit of rhpcctrl for Neck coils for KIZUNA system.

PX25 27/Mar/2015 KM HCSDM00267375: Changed to set aspir_auto_ti to pitival2 for both On and Off for ASPIR Auto TI
                                   to keep a displayed TI value consistent with an actual set value.

PX25 08/Apr/2015 KM/YT HCSDM00267350: Stabilized opti, #acqs and avmaxslquant for ASPIR Auto TI.

PX25 18/Jul/2015 YI HCSDM00361682: Detected oscillation of results of cveval() and
                                   avoided to acquire noise images on FOCUS.
PX25 24/Jul/2015 YI HCSDM00363791: Fixed image lost problem.

PX25 11/Aug/2015 YI HCSDM00365336: Set num_autotr_cveval_iter for in-range auto TR.

ML1.0 06/30/2015 ZZ HCSDM00359612: Multiband Diffusion feature promote

PX25 26/Aug/2015 YT HCSDM00341147: Support image cut reduction

PX25 10/Sep/2015 YI HCSDM00361688: Changed FOCUS cveval oscillation handling.

PX25 15/Sep/2015 KM HCSDM00341147  Make spacial phase correction incompatible
                                   with in-plane shift.

26.0  01/12/2016 RV HCSDM00348704: Enable (in-plane) pixel Size, RBW/pixel and ESP informational display

MR26 21/Jan/2016 MXX HCSDM00388767: fixed Focus yFoV issue, in range of 0.65~0.68 protocol couldn't be saved. 

MR26 29-Jan-2016 MXX HCSDM00388769: fixed issue: Focus retrieved wrong rfov_type waveforms on non-value-systems.

MR26.0 10/Feb/2016 TW HCSDM00390891: Synthetic Diffusion feature promote

MR26 17-Feb-2016 SB HCSDM00393279: Relaxed 16 slice limitation for FOCUS DWI when TR >=4500 ms.

MR26 23/Feb/2015 MXX HCSDM00394803: increase reserved tmin_total margin to avoid XFD under voltage issue for Mulan_Plus.

MR26 22-Feb-2016 KL HCSDM00391991: Always turn on t1flair_flag for IR prep DWEPI at 3.0T (legacy behavior)

MR26 22-Feb-2016 KL HCSDM00388564: Fix the issue that manual TI values are not accepted for auto TR mode in IR prep DWEPI

MR26 05/MAR/2016 GW HCSDM00397194: Set rfov_maxnslices back to its default value when changing TR to <4500ms

MR26 05/MAR/2016 YI HCSDM00398231: Fixed the problem on #acqs and max #slices in case of TR < 4500ms on FOCUS.

MR26 10-Mar-2016 YT HCSDM00393185: Support Multi Acq DWI with Resp/Nav trigger

MR26 11-Mar-2016 MF HCSDM00393999: Realtime B0 Correction feature promote

MR26 08/Mar/2016 NLS HCSDM00396145: Optimized APx parameters boundary for 1.5T: 96<=Phase<=192;
                                    Minimal NEX=2 for higher b value (>=500);3000ms <= TR <= 6000ms with STIR on;
MR26 18-Mar-2016 MXX HCSDM00397660 : Disable RTB0 and Relaxation of Focus 16 max slice number limitation for Kizuna1.5T and Mulan_plus. 

MR26 18/MAR/2016 GW HCSDM00398923: Enabled SSGR for DSE and SSE, corrected crusher parameters, and increased crusher 
                                   area for thin slice thickness. 

MR26 25-Mar-2016 RV HCSMD00399762 Fix issue with BW/pixel with ramp sampling - it is meaningless, hence don't display

MR26 26/Apr/2016 MXX HCSDM00404107 involved FoV scaling factor FOV_MAX_SCALE for max ivslthick value to fix
                                   epi2spec download failed issue.

MR26 24/Jun/2016 GW HCSDM00413046  Check existflag of opfat and opspecir when checking compatibility between Classic and SpSp pulse

MR26 31/Aug 2016 GW HCSDM00419736  Moved the ss_fa_scaling_flag setting code to after where ss_rf1 is set.

MR26 08/Sep/2016 GW HCSDM00423499  Increased time_ssi for Hyperband when RTFA is off

RX26 8/Sep/2016 KL HCSDM00423477   Rio Diffusion Gradient Cyclcing Feature

MR26 09/Sep 2016 LS HCSDM00423832  Added support for 48ch Head coil (Head 34, new for Gemini) for TGenh setting.

PX25 06/Oct/2016 YI HCSDM00398133, HCSDM00419770: scn removed HCSDM00398133 fix for HCSDM00419770.
                                   So added setUserCVs() for setting CV6,CV8 and CV18
                                   so that they could be set in cveval() for correct UI update.

MR27 06/Oct/2016 KL HCSDM00425850     Hyperband diffusion cycling order fix

MR27 20/Oct/2016 KL HCSDM00423868  Diffusion minseq()strategy revision to improve UI response

MR27 28/Oct/2016 KL HCSDM00429143  Implementation of new Diffusion Hyper DAB

MR26 18/Nov/2016 MO HCSDM00429470  Set trigger timing correctly for Multi Acq DWI with Resp/Nav trigger.

MR27 24/Feb/2017 PW HCSDM00446000  Distortion (B0-induced) Correction using reverse polarity gradient introduced for DWI.

MR27 10/Mar/2017 KL HCSDM00449718  Diffusion gradient derating in non-minimal TE mode for Rio SSE DWI

DV26 10/Mar/2016 GW HCSDM00446989  Increased rtb0dummy_time from 1s to 1.2s to avoid SSP EOS error

MR27 31/Mar/2017 KL HCSDM00444171  "Super G" mode for Rio DWI

MR27 06/Apr/2017 AG HCSDM00445759  Rio Muse for MultiShot Diffusion support. 

MR27 07/Apr/2017 GW HCSDM00429007  Increased diffusion maximum NEX limit to 64

MR27 07/Apr/2017 GW HCSDM00431818  Dynamic phase correction promote

PX26 14/Apr/2017 YT HCSDM00441404  Show Classic as available option regardless of spsp or not

PX26 09/May/2017 MO HCSDM00434877  Changed slice group order to interleave for Multi Acq DWI with Resp/Nav trigger.

MR27 23/May/2017 KL HCSDM00450881  Add logic for amplitude checking in ESP lock-out

MR27 23/May/2017 AG HCSDM00460608  Enable Dynamic Phase Correction (DPC) for Muse

PX26 28/Apr/2017 YUK HCSDM00456890 Added support for RTB0 option to use Linear fit residual as confidence metric
                                   Enabled RTB0 when SPSP=Off

MR27 13/June/2017 AG HCSDM00457528 Add logic to lock out phase acceleration depending on coil capabilities.

MR27 10/Jul/2017 GW HCSDM00468511  Replaced the HB2 and HB3 rf2 verse pulses and added logic to limit minimum slice thickness

MR27 12/Jul/2017 PW HCSDM00469094  Add logic to enable >150 (max 300) number of DTI directions in clinical mode based on
                                   maxtensor option key.

MR27 28/Jul/2017 VSN HCSDM00471707 Acoustic Noise Prediction model feature promote

PX26 28/Jul/2017 YT HCSDM00467217  Introduced focus_B0_robust_mode to avoid signal loss by susceptibility.

MR27 07/Sep/2017 KL HCSDM00477882 Fix issue in DTI applications time out when # of diffusion directions is empty for diffusion cycling

MR27 08/Sep/2017 AE HCSDM00478130 Changed difnextab from short to float in epic.h to support Lx DW Propeller and made the necessary
                                  changes in epi2

MR27 18/Sep/2017 KL HCSDM00479475 update the logic to ensure slice selective gradient polarity of the inversion pulse is same as
                                  that of the excitation pulse in STIR-DWI with SSGR and diffusion cycling.

MR27 20/Sep/2017 AG HCSDM00479041 Locked out multi-acq for MUSE.

MR27 25/Oct/2017 AG HCSDM00484758 Fix autotr issue for MUSE.

MR27 08/Nov/2017 ZT HCSDM00479162 Change the core_time calculation method for K15TSystem

MR27 04/Dec/2017 GW HCSDM00490110 Disabled DPC for FOCUS

MR27 08/Dec/2017 GW HCSDM00490730 Increased the maximum value of CV pw_wgxdl and pw_wgxdr

MR27 22/Jan/2017 GW HCSDM00495153 Made Hyperband rf2 scaling same as rf1

MR27 18/APR/2017 WHB HCSDM00455295 For performance ICE, data type is 32bits float data, to enable EDR for all applications and disable non-EDR error message.

MR27 08/Feb/2018 GW HCSDM00486599 Enabled high-order(cubic) phase correction for non-head DWI and retired CV16 and CV17 on Rio

MR27 25/May/2018 ZT HCSDM00515659 Make FOCUS more slice than 16 in one TR available in K15T and SV

RX27 29/Jun/2018 KL HCSDM00516239 Update num_dif to 1 for diffusion to avoid divided by zero when calculating avg_bval

MR27 02/Aug/2018 GW HCSDM00521799 Implemented FatSat killer cycling

MR27 17/Aug/2018 GW HCSDM00522007 Forced FatSat ON for FOCUS when focus_B0_robust_mode is ON

MR27 17/Aug/2018 ZZ HCSDM00520200 CV9 Shim mode update

MR27 29/Jun/2018 WHB HCSDM00502541 Promote gradient safety model code.

MR27 14/Sep/2018  KL HCSDM00515243 Strong satband implementation and set fskillercycling ON for FOCUS only

MR27 14/Sep/2018 GW HCSDM00525284 FOCUS rf2 slice spacing fix

MR27 05/Oct/2018 GW HCSDM00529102 Added consideration of psd_rf_wait to set pw_wgxdl

****************************************************************************/

@inline epic.h

/* omega/theta modulation support */
@inline omegathetamod.eh

@global 
/*********************************************************************
 *                       EPI2.E GLOBAL SECTION                        *
 *                                                                   *
 * Common code shared between the Host and Tgt PSD processes.  This  *
 * section contains all the #define's, global variables and function *
 * declarations (prototypes).                                        *
 *********************************************************************/

/* System includes */
#include <string.h>
#include <stdio.h>

/*
 * EPIC header files
 */
#include "em_psd_ermes.in"

#include "stddef_ep.h"
#include "epicconf.h"
#include "pulsegen.h"
#include "support_func.h"
#include "epic_error.h"
#include "epicfuns.h"
#include "psdutil.h" 
#include "acousticResponse.h" /* Should move to a common header file */
#include "acousticLockout.h"
#include "ReconHostPSDShared.h"

#ifdef PSD_HW   /* Auto Voice */
#include "broadcast_autovoice_timing.h"
#endif

/* HOEC */
@inline HoecCorr.e HoecGlobal

@inline Muse.e MuseGlobal

#include "filter_defs.h"
#include "ChemSat.h"

#include "epi2.h"
#include "psd_proto.h"
#include "epic_iopt_util.h"

#include "grad_rf_epi2.globals.h"

#define EPI2_FLAG    /* Identifies the PSD as EPI2 */

#define MAXFRAMESIZE_DPC 1024 /* max frame size limited by recon when dynamic phace correction is needed */

#ifndef PSD_CFH_CHEMSAT
#define PSD_CFH_CHEMSAT
#endif

#ifndef KEY_PRESENT
#define KEY_PRESENT 0
#endif /* KEY_PRESENT */

/* Some spsp RF1 definitions */
#define PSD_SE_RF1_PW   5ms    /* Pulse width */
#define PSD_SE_RF1_fPW  5.0ms
#define PSD_SE_RF1_LEFT  3100us
#define PSD_SE_RF1_RIGHT 1900us
#define PSD_SE_RF1_R     250   /* Resolution of FL90mc pulse */
#define PSD_GR_RF1_PW   3200us    /* Pulse width */
#define PSD_GR_RF1_fPW  3200.0us
#define PSD_GR_RF1_LEFT  1600us
#define PSD_GR_RF1_RIGHT 1600us
#define PSD_GR_RF1_R     400   /* Resolution of GR30l pulse */

/* Nominal pulse width definition */
#define PSD_NOM_PW_SE1B4 3200us      /* SE1B4 pulse */
#define PSD_NOM_PW_FL901MC 4000us    /* FL901MC pulse */
#define PSD_NOM_PW_GR30 3200us       /* GR30 pulse */

/* needed for Inversion.e inline */
#define PSD_FSE_RF2_fPW   4.0ms
#define PSD_FSE_RF2_R     400

#define RUP_HRD(A)  (((A)%hrdwr_period) ? (int)((A) + hrdwr_period) & ~(hrdwr_period - 1) : (A))

#define NAV_EPI

#undef TR_MAX
#define TR_MAX 30000000
#define TR_MAX_EPI2 17000000 /* Used for avmaxtr, cvmax and In-Range TR */
#define FOV_MAX_EPI2 600
#undef RBW_MIN
#define RBW_MIN 15.625
#undef RBW_MAX
#define RBW_MAX 250.0

#undef MAX_RFPULSE_NUM

/* Maximum b-Value for Scanner Config. */
#undef MAXB_1000
#define MAXB_1000 1000
#undef MAXB_1500
#define MAXB_1500 1500
#undef MAXB_2500
#define MAXB_2500 2500
#undef MAXB_4000
#define MAXB_4000 4000
#undef MAXB_7000
#define MAXB_7000 7000
#undef MAXB_10000
#define MAXB_10000 10000
#undef MAX_CRM_DW
#define MAX_CRM_DW 35000
#undef MINB_VALUE
#define MINB_VALUE 10
#undef BRM_PEAK_AMP
#define BRM_PEAK_AMP 200.0
#undef MAX_DIFF_NEX
#define MAX_DIFF_NEX 16
#undef MAX_DIFF_NEX_64
#define MAX_DIFF_NEX_64 64

/* Range for synthetic bvalue prescription */
#undef LOWER_SYNB_LIMIT_IVIM
#define LOWER_SYNB_LIMIT_IVIM 100.0
#undef UPPER_SYNB_LIMIT_RESTRICT_DIFF
#define UPPER_SYNB_LIMIT_RESTRICT_DIFF 2500.0
#undef SYNBVAL_EXPAND_FACTOR
#define SYNBVAL_EXPAND_FACTOR 2.5
#undef UPPER_SYNB_LIMIT_RESEARCH_MODE
#define UPPER_SYNB_LIMIT_RESEARCH_MODE 4000.0

/* minimum number of additional ky lines to acquire beyond opyres/2: */
#define MIN_HNOVER_DWI 16
#define MIN_HNOVER_DEF 8
#define MIN_HNOVER_GRE 20
#define MIN_HNOVER_RFOV 8 /* HCSDM00150820 */

/* dephaser pulse position definitions */
#define PSD_PRE_180 0
#define PSD_POST_180 1

/* Flow Comp */
#define NO_GMN 0
#define CALC_GMN1 1
#define CALC_GMN2 2

/* YMSmr06515: # of slice locations expansion 
#undef DATA_ACQ_MAX
#define DATA_ACQ_MAX 512
*/

#define MAXSLQUANT_EPI 512

#define TWOPI_GAMMA 26748.0   /* 2*PI*GAMMA */
#define TWO_PI 2.0*PI         /*  added by XJZ  */
#define NUM_DWI_DIRS 4
#define NUM_DWI_AXES 3

/* Diffusion */
#define T2_IMAGE 1
#define ALL_AXIS 3
#define ALL_AXIS_TETRA 4
#define ONE_AXIS 1
#define Z 1
#define X 2
#define Y 3
#define DIR1 0
#define DIR2 1
#define DIR3 2
#define DIR4 3
#define AXIS_X 0
#define AXIS_Y 1
#define AXIS_Z 2

#define HIB_MIN_TR 1s
#define MAX_SLICES_DTI 50000

#define MAX_NUM_ITERS 40 /* max number of iters for Multi-TR CornerPoints*/

/* FLAIR */
#define FLAIR_MAX_TI 2.8s
#define FLAIR_MIN_TI 1.5s
#define FLAIR_MIN_TR 6s
#define EPI_STIR_TI_MAX 500ms

/* ASPIR for DWI */
#define ASPIR_DWI_MIN_TI  30000
#define ASPIR_DWI_MAX_TI  290000
#define ASPIR_DWI_1HT_TI      60000
#define ASPIR_DWI_3T_TI       110000
#define ASPIR_DWI_T1EFF_1HT   260000
#define ASPIR_DWI_BCOEFF_1HT  0.95
#define ASPIR_DWI_T1EFF_3T    360000
#define ASPIR_DWI_BCOEFF_3T   0.95

/* For aspir_auto_ti_model */
#define ASPIR_AUTO_TI_FIXED 0
#define ASPIR_AUTO_TI_ADAPTIVE 1 

#define INT_INPUT_NOT_USED 0

#define MAX_FOCUS_EVAL_WATCH 4
#define NUM_EVAL_IN_PREDOWNLOAD 3

/* Big Patient Weight */
#define BIG_PATIENT_WEIGHT 160

@inline ChemSat.e ChemSatGlobal
@inline SpSat.e SpSatGlobal
@inline Inversion_new.e InversionGlobal
@inline Prescan.e PSglobal
@inline ss.e ssGlobal
@inline DTI.e DTI_Global
@inline Asset.e AssetGlobal
@inline ARC.e ARCGlobal
@inline RfovFuncs.e RfovGlobal
/* @inline MK_GradSpec.e GspecGlobal */ /* granty maybe */
@inline MultibandFuncs.e MultibandGlobal

/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptGlobal

/* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e AutoAdjustTRGlobal

/***SVBranch: HCSDM00259119  eco mpg ***/
@inline eco_mpg.e eco_mpg_global
/**********************/

/* SXZ::MRIge72411: for edge ghost optimization */
#define NODESIZE 3
#define VRGF_AFTER_PCOR_ALT 32768
#define FAST_VRGF_ALT 2048
#define DEBUG_CORE 

/* RPG volume acquisition for Distortion Correction (rpg_flag) */
#define RPG_REV_THEN_FWD  1
#define RPG_FWD_THEN_REV  2

/* GEHmr01833, GEHmr02647: XFD Power Limit */
#define XFD_POWER_LIMIT          8.5 /* kW */
#define XFD_POWER_LIMIT_DWI_BASE 6.5 /* kW */

/* GEHmr01834, GEHmr02647: GMAX for DWI */
#define XFD_GMAX_DTI 3.0 /* G/cm */
#define XFD_GMAX_DWI 2.8 /* G/cm */

/*SVBranch: GEHmr04247 */
#define XFD_MINSEQ_LIMIT_DWI   15000000 /* us * kW */
#define XFD_MINSEQ_LIMIT_FLAIR 13000000 /* us * kW */

FILE *fp_coreinfo;
FILE *fp_diff_order; /*Diffusion cycling*/
FILE *fp_cfdata; /*RTB0 correction*/
FILE *fp_utloopinfo; /*RTB0 correction*/

#define DEFAULT_IREF_ETL 3

/* MRIhc56520: SR for EPI with ART on 750w */
#define XRMW_3T_EPI_ART_SR 5.0
#define VRMW_3T_EPI_ART_SR 5.0

#define SR_DERATING_MAX_ITER 5

@inline Monitor.e MonitorGlobal

/************************************************************************/
@ipgexport
@inline Prescan.e PSipgexport
@inline RfovFuncs.e RfovIPGexport
@inline MultibandFuncs.e MultibandIPGexport

/*RTB0 correction */
int slloc2sltime[SLICE_FACTOR*DATA_ACQ_MAX];
int sltime2slloc[SLICE_FACTOR*DATA_ACQ_MAX];
float f_sltime2slloc[SLICE_FACTOR*DATA_ACQ_MAX]; /*floating point array*/
int act_slquant1;

long rsprot_unscaled[DATA_ACQ_MAX][9]; /* a copy of the roation matrices
                                          unscaled by cf<x,y,z.full, targets,
                                          or full scale values */
/* Obl 3in1 opt */
float inversRR[9];
float D[NUM_DWI_DIRS][NUM_DWI_AXES];     /* Diffusion Vector Matrix */
float log_incdifx[NUM_DWI_DIRS];
float log_incdify[NUM_DWI_DIRS];
float log_incdifz[NUM_DWI_DIRS];
float diff_ampx2[MAX_NUM_BVALS_PSD][NUM_DWI_DIRS];
float diff_ampy2[MAX_NUM_BVALS_PSD][NUM_DWI_DIRS];
float diff_ampz2[MAX_NUM_BVALS_PSD][NUM_DWI_DIRS];

int off_rfcsz[DATA_ACQ_MAX];

float dwigcor[9] = {0,0,0,0,0,0,0,0,0};         /* output grad correction matrix */
float dwibcor[3] = {0,0,0};                     /* output b0 (freg) correction matrix */
float dwikcor[9] = {0,0,0,0,0,0,0,0,0};         /* output pre-phaser area correction matrix */

/* HOEC */
@inline HoecCorr.e HoecIpgexport

/* BJM: declare these here so they can be set on host and used by ipg */
float diff_ampx[MAX_NUM_BVALS_PSD];
float diff_ampy[MAX_NUM_BVALS_PSD];
float diff_ampz[MAX_NUM_BVALS_PSD];

/* for b-value weighted gradient scale calculation */
float diff_bv_weight[MAX_NUM_BVALS_PSD];

/* define physical and gradient characterisitics for epi read train.
   Physical limits are actual hardware limits, not limited by dB/dt
   constraints.  dB/dt constraints are applied within epigradopt function. */
/* MRIhc08159 */
/* physical gradient characteristics */
PHYS_GRAD epiphygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };    
/* logical gradient characteristics */
LOG_GRAD  epiloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };

/* Obl 3in1 opt */
PHYS_GRAD orthphygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
LOG_GRAD  orthloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };

RF_PULSE_INFO rfpulseInfo[RF_FREE] = { {0,0} };

/* variables used as buffers to read in static data from external file; 
   these buffers are used by functions for on-the-fly calculations, etc.    RK */
float delay_buffer[10];
float dither_buffer[12];
float ccinx[50];
float cciny[50];
float ccinz[50];
float fesp_in[50];
int esp_in[50];
float g0;
int num_elements;
int file_exist;

/* SXZ::MRIge72411: edge ghost optimization */
float taratio_arr[NODESIZE];
float totarea_arr[NODESIZE];

float agxdif_tmp, agydif_tmp, agzdif_tmp;
int difnextab_rsp[MAX_NUM_BVALS];

int ctlend_last[SLTAB_MAX]; /* dead time of last temporal cardiac slice */
int ctlend_fill[SLTAB_MAX]; /* dead time of last slice in a filled R-R interval */
int ctlend_unfill[SLTAB_MAX]; /* dead time of a last slice in an unfilled R-R interval */

/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptIpgexport

@inline ss.e ssIPGexport

@inline Monitor.e MonitorIpgexport

@inline ARC.e ARCIpgexport

/* Obl 3in1 opt */
@export
SCAN_INFO orth_info[1];
float gx_log,gy_log,gz_log,gx_phys,gy_phys,gz_phys;

/************************************************************************/
@cv

@inline ChemSat.e ChemSatCV
@inline SpSat.e SpSatCV
@inline loadrheader.e rheadercv
@inline Prescan.e PScvs
@inline Inversion_new.e InversionCV
@inline ss.e ssCV
@inline vmx.e SysCVs
@inline epi_esp_opt.e epi_esp_opt_cvs
@inline DTI.e DTI_cvs
@inline epiMaxwellCorrection.e epiMaxwellCV     /* CVs for Maxwell Compensation      */
@inline epiCalFile.e epiCalCV                   /* CVs for calibration file check    */
@inline RfovFuncs.e RfovCV
@inline MultibandFuncs.e MultibandCV

/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptCV
@inline T1flair.e T1flairCV

@inline Asset.e AssetCVs                        /* Asset Scan Cvs */
@inline ARC.e ARCCV

@inline Monitor.e MonitorCV
@inline SlabTracking.e SlabTrackCV

/* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e AutoAdjustTRCVs

/*RTB0 correction*/
@inline RTB0.e RTB0cv

/* HCSDM00361682 */
int focus_eval_oscil = 0 with {0,2,0,VIS,"flag of oscillation of cveval on FOCUS",};
int focus_eval_oscil_hist = 0 with {0,1,0,VIS,"History flag of oscillation of cveval on FOCUS",};
int isPredownload = 0 with {0,1,0,VIS,"0:cveval 1:predownload",};
int keep_focus_eval_oscil = 0 with {0,2,0,VIS,"Flag to keep focus_eval_oscil",};
int reset_oscil_in_eval = 0 with {0,1,0,VIS,"Flag to reset focus_eval_oscil in cveval()",};
int force_acqs = 0 with {,,,VIS,"Forced acq",};
int force_avmaxslquant = 0 with {,,,VIS,"Forced avmaxslquant",};
int oscil_eval_count = 0;
int optr_save = 0 with {,,,VIS,"optr_tr in previous cveval",};
int opslquant_save = 0 with {,,,VIS,"opslquant in previous cveval",};
int save_avmintr = 0;
int save_pitracqval4 = 0;



/* MRIhc09116 */
int num_passdelay = 1 with {1,,1,VIS,"number of pass delay sequence",};

int use_maxloggrad = 0 with {0,1,0,VIS,"use maxgrad for dwi traditional sampling scheme",};
int max_grad = 0;
float scale_dif = 0.0;

int debug_core = 0 with {0,1,0,VIS,"Flag to enable logging scancore data",};
int debug_unitTest = 0 with {0,1,0,VIS,"Flag to enable logging unit test data",}; /*RTB0 correction*/

/* SXZ::MRIge72411: top area vs. total area ratio */
float taratio = 0.0 with {0.0,0.90005,0.0,VIS, "Minimal top area ratio in readout gradient",};
int rampopt = 1 with {0,1,1,VIS,"1: enable ramp sampling optimization",};

/* SXZ::MRIge72411: following cvs show useful info */
float totarea = 0;       /* G*usec/cm */
float actratio = 0;

/* internref: internal reference scan */
int dpc_flag = 0 with {0,1,0,VIS, "Flag for dynamic phase correction",};
int sndpc_flag = 1 with {0,1,1,VIS, "Flag for self-navigated dynamic phase correction",};
int iref_etl = 0 with {0,,0,VIS, "Internal reference echoes for dynamic phase correction",};
int iref_frames = 0;
int tot_etl = 1 with {1,,1,VIS,"total echo train length including interref echoes",};
int pw_gxiref1_tot;
int pw_gxiref_tot;
int pw_gxirefr_tot;

int MinFram2FramTime =  30us;

int maxslice_per_ti = 0 with {0,1000,0,VIS,"Slices fit in one TI period",};
int invseqtime;

int false_acqs;         /* psuedo acquisitions for flair slice ordering */
/* number of slices in first psuedo pass for flair */
int false_slquant1 = 1 with {0,SLTAB_MAX,1,INVIS,"# of locs in first pass for flair",};  
int max_slice_ti;        /* maximum # slices that can fit in ti */
int flair_min_tr = 10s;  /* minimum TR for flair option */
int dda_packb, dda_pack, dda_packe; /*range of false_acqs for disdaq loop */
int dda_passb, dda_pass; /* range of act_acqs for disdaq loop */
int deadlast;            /*deadtime for last slice in pack */
int tmp_deadlast;        /* extra time to be added to scan time  */

float phase_dither = 0.0 with {,,0.0,VIS, "B0 phase dither value (degrees)",};
int spgr_flag = 0 with {0,1,0,VIS,"SPGR flag",};

int rhhnover_max = 0;	 /* Maximum allowed rhhnovers due to physical space on the boards */
int rhhnover_min = 16;   /* minimum number of overscans *//*LX - 8*/
int rhhnover_min_per_ilv = 16;   /* minimum number of overscans per shot */
int newyres= 0;		 /* New yres if opnshots/opte/opyres is incompatible. */
int num_overscan = 8;    /* BJM: this was added for multi-shot EPI */

int smart_numoverscan = 1 with {0,1,1,VIS,"flag for smart number of over-scan lines",};

int avmintefull = 0 with {0,,0,VIS, "Minimum te with full ky coverage",};   
int cvrefindex1;
float gx1_area;
int avmintetemp; 

int fast_rec = 0 with { 0, 1, 0, VIS,
 "receiver selected: 0=standard recvr, 1=fast recvr",};

/* Given n baselines, use bl_acq_tr1 for first n-1 baselines, bl_acq_tr2
   for nth baseline.  This is to minimize baseline acq. time while
   avoiding sequence preparation failures for the scan that follows. */

int bl_acq_tr1 = 1ms with {1ms,6s, 10ms, MODIFIABLE,"Fast Baseline acquisition sequence length",};
int bl_acq_tr2 = 300ms with {1ms,6s, 100ms, MODIFIABLE,"Baseline acquisition sequence length",};

float fecho_factor; /*SNR*/
float tsp   =  2.0 with { 1.0, 1000.0, 2, VIS, "Sampling period (1us).",};
int intleaves =  1 with { 1,256, 1,VIS,"Interleaves to get yres.",};

int ky_dir = 2 with {0,2,2,VIS,"Ky samp dir:0=top/down,1=cent/out,2=bottom/up",};
int kx_dir = 0 with {0,3,0,VIS,"Kx samp dir:0=same,1=alt w/intleave,2=halfset,3=quarterset.",};

int dc_chop   =  1 with {0,1,1,VIS,"Receiver phase chop flag: 1=on,0=off",};
/*	  0 = same start polarity (+) for all intleaves.
 	  1 = odd intleaves start +, even start -
 	  2 = 1st half of intleaves start +, second half interleaves start -
 	  3 = 1st & 3rd quarters start +, 2nd & 4th quarters start -.  */


int etot = 0 with {0,,0,VIS,"Total echoes required to feed MPS.",};
int emid = 0 with {0,,0,VIS,"1st echo right of TE midpoint.",};
int e1st = 0 with {0,,0,VIS,"1st echo to turn on.",};

int seq_data  = 0 with {0,1,0,VIS,"0=std sorting,1=time seq order.",};

float msamp = 0.0 with {,,0.0,VIS,"Default echo shift, samp per, +=R,-=L.",};
float dsamp = 0.0 with {,,0.0,VIS,"Delta echo shift, samp per, +=R,-=L.",};
float delpw;

int num_dif=0 with {0,4,0,VIS,"Number of diffusion axis.",}; /*MRIhc05854*/
int incr = 0 with {0,1,0,VIS,"Diff grad auto increment:0=off,1=on.",};
int df_encode = 0 with {0,1,0,VIS,"diffusion encoding",};
int i_bval = 0 with {0,18,0,VIS,"Number intermediate b values",};
int df_refscn = 0 with {0,1,0,VIS,"Dif ref scan select",};
int dwi_fphases;
int max_slice_dfaxall = 256; /* YMSmr06650 */
int dualspinecho_flag = 0 with {0,1,0,VIS,"flag for Dual Spin Echo",};

/* BJM: USER CV's for DW-EPI in NO */
int derate_amp = 1 with {0,1,1,VIS,"Derate Dif. Amp. for heating calcs",};
/* MRIge58521 */
float scale_difx = 1.0 with {0.0,1.0,1.0,VIS,"Derate Factor for X Dif. Amp. for heating calcs",};
/* MRIhc05854*/
float scale_dify = 1.0 with {0.0,1.0,0.0,VIS,"Derate Factor for Y&Z Dif. Amp. for heating calcs",};
float scale_difz = 1.0 with {0.0,1.0,0.0,VIS,"Derate Factor for Y&Z Dif. Amp. for heating calcs",};
int unbalanceCrusher = 1 with {0,1,1,VIS,"Unbalance crushers for DSE",};
float crusherFactorLeft = 1.0 with {0.1,8.0,1.0,VIS,"Crusher factor for Left 180 in DSE",};
float crusherFactorRight = 2.0 with {0.1,8.0,2.0,VIS,"Crusher factor for Right 180 in DSE",};

/* for 3in1, tetrahedral and gradient optimization for diffusion ALL if needed */
int invertSliceSelectZ = 0 with {0,1,0,VIS,"Invert SliceSel Grad and Z Crusher based on polarity of Diff Grad: 1=on,0=off",};
/* for S/I, A/P, R/L, Slice, and ALL */
int invertSliceSelectZ2 = 0 with {0,1,0,VIS,"Invert SliceSel Grad and Z Crusher based on polarity of Z Crusher: 1=on,0=off",};

/* MRIhc05227 Flags for X and Y crushers on left and right 180s */
int xygradRightCrusherFlag = 0 with {0,1,0,VIS,"Turns on X,Y Grad Crusher for Right 180 in DSE",};
int xygradLeftCrusherFlag = 0 with {0,1,0,VIS,"Turns on X,Y Grad Crusher for Left 180 in DSE",};
int xygradCrusherFlag = 0 with {0,1,0,VIS,"Turns on X,Y Grad Crusher for non-DSE",};

/* MRIhc49589 */
int invertCrusherXY = 0 with {0,1,0,VIS,"Invert XY Grad Crushers based on polarity of Diff Grad: 1=on, 0=0ff",};

int ssgr_mux = 0 with {0, 1, 0, VIS, "Slice Select Gradient Reversal for MultiBand: 0-off, 1-on",};
int ssgr_flag = 0 with {0, 1, 0, VIS, "Slice Select Gradient Reversal: 0-off, 1-on",};
int ssgr_bw_update = 0 with {0, 1, 0, VIS, "Flag for BW update for SSGR: 0-off, 1-on",};
int freqSign_rf2right = 1;
int freqSign_rf2left = 1;
int freqSign_rf2 = 1;
float fat_cs = 220.0; /* fat offset in Hz on 1.5T */
float rf1_bw_ratio = 2.0;  /* relative to fat offset */
float rf2_bw_ratio = 2.0;  /* relative to fat offset */
float b0_offset = 100.0; /* in Hz */

/* MRIhc05259 Bookkeeping for additional time caused by X, Y crushers */
int RightCrusherLSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",}; 
int RightCrusherRSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",}; 
int LeftCrusherLSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",}; 
int LeftCrusherRSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",};
int CrusherRSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",};
int CrusherLSlop = 0 with {0, ,0,VIS,"Add'l time for X,Y crushers",};

int epi2spec_mode = 0 with {0, ,0, INVIS, "flag to activate sepc mode",};

int weighted_avg_grad = 1 with {0,1,1,VIS,"weight gradients on weighted avg.",};
int weighted_avg_debug = 0 with {0,1,0,VIS,"weighted avg. debug flag",};


float DELTAx;
float DELTAy;
float DELTAz;

float deltax;
float deltay;
float deltaz;

/***********************************************************************************/
/*      eddy correction variables for Zhou cross term correction                   */
/***********************************************************************************/

float a_gx_dwi=0.0000;
                        /* the read-out gradient correction value in Gauss/cm */

float a_gy_dwi = 0.0000 with {-0.1,0.1,0.0,VIS,"phase-encoding grad correction",};
                         /*encoding direction.  unit: g/cm.ms */
float a_gz_dwi = 0.0000 with {-0.1,0.1,0.0,VIS,"slice grad correction",};
                         /*encoding direction.  unit: g/cm.ms */

float freq_dwi = 0.0 with {-1000.0,1000.0,0.0,VIS,"frequency offset for DWI",};
                      /* the B0 freq. correction value unit: Hz */
 
float phase_dwi = 0.0 with {-1000.0,1000.0,0.0,VIS,"phase offset for DWI",};
                      /* the B0 phase correction value unit: radian */

int ia_gx_dwi = 0;
int ia_gy_dwi = 0;
int ia_gz_dwi = 0;

int dwicntrl=0;                /*control cvs for dwicorrcal    */
int dwidebug=0;                /*control cvs for dwicorrcal    */
int tmp_ileave;
int tmp_ygrad_sw;
float t4_tmp;
/***********************************************************************************/



float incdifx = 1.0 with {,,,VIS,"X diffusion grad step size, g/cm.",};
float incdify = 1.0 with {,,,VIS,"Y diffusion grad step size, g/cm.",};
float incdifz = 1.0 with {,,,VIS,"Z diffusion grad step size, g/cm.",};
int ia_incdifx, ia_incdify, ia_incdifz;

float bincr; /* increment of b-value for each repetition */
float invthick = 1.0; /* thickness of inversion slice */
float xerror, yerror, zerror;

/* Obl 3in1 opt */
int obl_3in1_opt_debug
  = 0 with {0,1,0,VIS,"oblique 3in1 improvement debugging flag,0:Off 1:On",};
int obl_3in1_opt
  = 0 with {0,1,0,VIS,"oblique 3in1 improvement flag",};
float norot_incdifx;
float norot_incdify;
float norot_incdifz;
float target_mpg_inv;
float target_mpg;
float amp_difx_bverify,amp_dify_bverify,amp_difz_bverify;

int different_mpg_amp_flag = 0;

int act_acqs = 1;               /* true number of passes needed; acts/packs */
int min_acqs;                   /* min number of acqs; insure inv thickness */
int maxslq_titime;              /* time in opti time available to interleave sliles */
int maxslq_ilir;

int epi_flair = 0 with {0,1,0,VIS,"Epi flair on=1, off=0",};		
int flair_flag = PSD_OFF; /* pass_rep specific flag for flair inversion */
float dda_fact;       /* multiplier to correct scan time for lack of disdaqs durring dwi and flair  */
 
/* Number of repeated scans at each slice */ 
int reps        = 1 with {1,2000,1,VIS,"# scan repetitions.",};
int pass_reps   = 1 with {1,2000,1,VIS,"# pass repetitions.",};
int max_dsht    = 7 with {1,256,8,VIS,"# diff grad amps in increment cycle.",};
int avg_at_loc  = 0 with {0,1,0,VIS,"0=don't avg,1=avg over reps.",};

int filtfix = 0 with {0,1,0,VIS,"1=apply asym filter fix,0=don't.",};
int rf_chop = 1 with {0,1,1,VIS,"1=chop RF for intleaves>1,0=don't.",};

 /*spsp*/
int rftype = 1 with {0,1,1,VIS,"1=extern rfpulse, 0=sinc rfpulse",};
int thetatype = 0 with {0,1,0,VIS,"1=play extern theta pulse, 0=no theta",};
int gztype = 1 with {0,1,1,VIS,"1=extern grad, 0=create by macro",};

int hsdab   = 1 with {0,2,1,VIS,"0=std dab packets,1=EPI dab packets, 2-EPI DIFF dab packets.",};
int slice_num = 1 with {1,DATA_ACQ_MAX,1,VIS,"slice number within rep.",};
int rep_num = 1 with {1,256,1,VIS,"rep number within total reps.",};

int endview_iamp;  /* end instruction phase amp */
int endview_scale; /* ratio of last instruction amp to maximum value */

int gx1pos   = 1 with {0,1,1,VIS,"gx1 placement: 0=pre-180, 1=post-180.",};
int gy1pos   = 1 with {0,1,1,VIS,"gy1 placement: 0=pre-180, 1=post-180.",};

int eosxkiller  = 0 with {0,1,1,VIS,"eos x killer pulses: 0=off, 1=on.",};
int eosykiller  = 1 with {0,1,1,VIS,"eos y killer pulses: 0=off, 1=on.",};
int eoszkiller  = 1 with {0,1,1,VIS,"eos z killer pulses: 0=off, 1=on.",};
int eoskillers  = 1 with {0,1,1,VIS,"eos killer pulses: 0=off, 1=on.",};
int eosrhokiller  = 1 with {0,1,1,VIS,"eos rho killer pulses: 0=off, 1=on.",};

int gyctrl = 1 with {0,1,1,VIS, "GY control: 1=on, 0=off",};
int gxctrl = 1 with {0,1,1,VIS, "GX control: 1=on, 0=off.",};
int gzctrl = 1 with {0,1,1,VIS, "GZ control: 1=on, 0=off.",};

int ygmn_type;   /* specifies degree of FC on Y */
int zgmn_type;   /* specifies degree of FC on Z */

int   rampsamp  = 0 with {0,1,0,VIS,"0=flat top sampling,1=VRGF ramp sampling.",};
int   final_xres = 0 with {0,1024,0,VIS,"Final VRGF frequency direction resolution.",};
int   autovrgf = 1 with {0,1,1,VIS,"1=vrgf program called automatically in predownload, 0=manual mode.",};
float vrgf_targ = 2.0 with {0.2,16.0,2.0,VIS,"vrgf oversampling ratio target value.",};
int vrgf_reorder = 1 with {0,1,1,VIS, "1=vrgf->PC (new), 0=PC->vrgf (old)",};

float fbhw = 1.0 with {0.0,1.0,1.0,VIS,"Fraction of blip half width excluded from sampling.",};

/* Note this should always be ZERO for MGD */
int osamp = 0 with {0,1024,0,VIS,"Fractional echo oversamples.",};

int etl = 1 with {1,,1,VIS,"echo train length",};
int eesp = 0 with {0,,0,VIS,"effective echo spacing",};
int nblips, blips2cent;   /* total number of blips and number of blips
							  to the center of ky offset */
int ep_alt = 0 with {0,2,0,VIS,"Alt read sign:0=no,1=odd/evn,2=halves,3=pairs",};

int tia_gx1, tia_gxw, tia_gxk;  /*temp internal amps that flip in polarity*/
int tia_gxiref1, tia_gxirefr;
float ta_gxwn; /* temp value for negative a_gxw value */
float rbw; /* in Hz */
int   avminxa, avminxb, avminx, avminya, avminyb, avminy;
int   avminza, avminzb, avminz, avminssp;
float avminfovx, avminfovy;

int   hrdwr_period =  4us with {4us,128us,32us,VIS,"Hardware specific base period.",};
int   samp_period = 8us with {0,,0,VIS,"sample period generated by epigradopt.",};
int   pwmin_gap = 2*4; /*=2*GRAD_UPDATE_TIME*/

float frqx = 200.0 with {0.0,1000.0,200.0,VIS,"Kx sampling freq peak (KHz).",};
float frqy = 2.0   with {0.0,1000.0,2.0,VIS,"Ky sampling freq peak (KHz).",};

int dacq_offset = 14us with {0,,14us,VIS, "dacq packet offset relative to gxw (us)",};

int   pepolar = 0 with {0,1,0,VIS,"1= flip phase encoding polarity, 0=don't.",};
int rpg_flag = 0 with {0,2,0,VIS,"0=Off, 1=Reverse PG then Forward, 2=Forward PG then Reverse",};
/* We have rpg_in_scan_flag here because rpg_flag can potentially have more choices */
int rpg_in_scan_flag = 0 with {0,1,0,VIS,"1=Collect RPG (and FPG if needed) volume behind user's back by adding paases.",};
/* In case of DWI with zero T2s, we add two shots for one reverse and one forward */
int rpg_in_scan_num = 1 with {0,10,1,VIS,"Number of extra passes for distortion correction.",}; 

int   tdaqhxa, tdaqhxb;
int   xdiff_time1, xdiff_time2;
int   ydiff_time1, ydiff_time2;
int   zdiff_time1, zdiff_time2;
float delt;

/* ASPIR auto TI model */
int T1eff;
float bcoeff;
int aspir_auto_ti_model;

/* sliding data acquisition window control: */
int   tfon = 1 with {0,1,1,VIS,"Time shift interleaves:0=off,1=on.",};

int   fract_ky = 0 with {0,1,0,VIS, "Fractional ky space acquisition flag:0=off,1=on",};
float ky_offset = 0.0 with {-256,256,0,VIS,"# Ky lines to offset echo peak, -=early, +=later",};
float gy1_offset = 0.0 with {,,0.0,VIS, "gy1 dephaser area difference for ky shift",};

/* needed for Inversion.e */
int satdelay = 0ms with {0,,0,INVIS, "Delay between last SAT and 90",};
/*Sat band type*/
int sp_sattype = 0 with {0, 2, 0, VIS, "Spatial Sat Type: 0=Light, 1=Medium, 2=Strong",};

int   td0       = 4 with {0,,1,INVIS, "Init deadtime",};
int   t_exa     = 0 with {0,,0,INVIS,"time from start of 90 to mid 90"};
int   te_time   = 0 with {0,,0,INVIS," te * opnecho ",};
int   pos_start = 0 with {0,,0,INVIS, "Start time for sequence. ",};
int   pos_start_init = 0 with {0,,0,INVIS, "Initial start time for sequence. ",}; /* HCSDM00361682 */
int   post_echo_time = 0 with {0,,,INVIS, "time from te to end of seq",};
int   psd_tseq = 0 with {0,,,INVIS, " intersequence delay time for cardiac",};
int   time_ssi  = 1000us with {0,,8000us,INVIS,"time from eos to ssi in intern trig",};

float dacq_adjust = 0.0 with {,,,VIS, "dacq starting time fine tuning adjustment",};

int   watchdogcount = 10 with{1,15,2,INVIS,"Pulsegen execution time (x5sec) b/4 timeout",};
int   dabdelay = 0 with {,,,INVIS,"Extra time for dab packet (negative is more)",};
int   tlead     = 25us with {0,,25us,INVIS, "Init deadtime",};
int   act_tr    = 0 with {0,,,INVIS, "actual tr",};
int   rfconf    = ENBL_RHO1 + ENBL_THETA + ENBL_OMEGA + ENBL_OMEGA_FREQ_XTR1;
int   ctlend = 0 with {0,,0,INVIS,"card deadtime when next slice in intern gated",};
int dda = 0 with {0,,4,INVIS," number of disdaqs in scan (not pairs)",};/*LX - short to int*/
int debug = 0 with {0,1,0,VIS,"1 if debug is on ",};
int debug_dbdt = 0 with {0,1,0,VIS,"1 to debug dbdtderate() ",};
int debugipg = 0 with {0,1,0,VIS,"1 if debugipg is on ",};
int debugepc = 0 with {0,1,0,VIS,"1 to turn on exciter phase debug",};
int debugdither = 0 with {0,1,0,VIS,"1 to turn on b0dither debug",};
int debugdelay = 0 with {0,1,0,VIS,"1 to turn on delay debug",};
int dex = 0 with {,,0,INVIS, "num of discarded excitations",};
int   gating = 0 with {0,,0,INVIS,"gating - TRIG_INTERN, TRIG_LINE, etc.",};
int   ipg_trigtest = 1 with {0,1,1,INVIS, "if 0 use internal trig always",};

int   gxktime = 0 with {0,,,INVIS, "x Killer Time.",};
int   gyktime = 0 with {0,,,INVIS, "y Killer Time.",};
int   gzktime = 0 with {0,,,INVIS, "z Killer Time.",};
int   gktime = 0 with {0,,,INVIS, "Max Killer Time.",};
int   gkdelay = 100us with {0,,,INVIS,"Time to delay killers from end of readout train.",};

float scanbw = 62.5 with {,,,VIS, "Scan filter bw. in KHz",};
int   scanslot = 0 with {0,7,4,VIS, "Scan filter slot number",};/*LX - 4 in epi2*/

/* temp crusher amplitudes */
float a_lcrush_cfh;              /* amp of left crush */
float area_gxw;                  /* readout pulse area of constant portion */
float area_gx1;                  /* readout dephaser pulse area */
float area_readramp;             /* area of left readout ramp */
float area_r1, area_gz1, area_gzrf2l1, area_r1_cfh; 
float area_std, area_stde;       /* crusher calcs */

/* gradient echo refocus */
int avail_pwgz1;		/* avail time for gz1 pulse */

int   prescan1_tr = 2s with {0,,,INVIS,"1st pass prescan time",};
int ps2_dda     =  0 with {0,,,INVIS,"Number of disdaq in 2nd pass prescan.",};
int   avail_pwgx1;               /* avail time for gx1 pulse */
int   avail_image_time;          /* act_tr for norm scans*/
int   beg_nontetime;             /* effect time zero of 90 rf pulse */
int   pos_start_rf0;             /* time of start of inv pulse */
int   beg_nontitime;             /* effect time zero of inv pulse */
int   avail_se_time;		 /* tr - inversion times */
int   avail_tdaqhxa;             /* available time for sampling prior
									to te point */
int   full_irtime;                 /* ti - lead time difference of se and inv sequence */
int   avail_yflow_time=0;        /* time available for gymn1, gymn2 pulses */
int   avail_zflow_time;          /* time available for gz1, gzmn pulses */
int   nviews;                    /* # views in readout train prior to te point */

int test_getecg = 1;
int premid_rf90 = 0 with {,,0, INVIS,"Time from beg. of seq. to mid 90", };

float c1_scale, c2_scale;        /* crusher ratio */
float crusher_cycles = 4.0;

int sar_amp;  /* debug variable for power monitor granty maybe */
int sar_cycle;
int sar_width;

/*    min sequence times based on coil heating */
int   max_seqtime;               /* nax time/slice for max av panel routines */
int   max_slicesar;              /* min slices based on sar */
int   max_seqsar;
float myrloc = 0 with {0,,,INVIS, "Value for scan_info[0].oprloc",};
int   other_slice_limit;         /* temp av panel value */

float target_area;      /* temp area */
float start_amp;       /* temp amp */
float end_amp;         /* temp amp */

int pre_pass  = 0 with {0,,0,INVIS, "prescan slice pass number",};
int nreps     = 0 with {0,,0,INVIS, "number of sequences played out",};

/* Scaling CVs */
float xmtaddScan;

/* needed for Inversion.e */
float rfscale = 1.0 with {,,1.0,INVIS,"Rf pulse width scaling factor",};

/* Offset from end of excitation pulse to magnetic isocenter */
int rfExIso;

/* CV's for echo train phase correction */
int frq2sync_dly = 9 with {,,,INVIS,"Time from begin of frq to sync phase",};
float rf1_phase = 0 with {0.0,,0.0,INVIS,"Relative phase of 90 in cyc",};
float rf2_phase = 0 with {0.0,,0.0,INVIS,"Relative phase of 180 in cyc",};
int hrf1a, hrf1b;               /* location of rf1 center */
int hrf2a, hrf2b;               /* location of rf2 center */

/* Inner volume flag */
int innerVol = 0 with {0, 0, 0, VIS, "Inner volume flag",};
float ivslthick = 5 with {1,FOV_MAX_EPI2*FOV_MAX_SCALE,480,VIS, "Inner Volume Slice thickness in mm.",};

/* These CVs are used to override the triggering scheme in testing. */
int psd_mantrig = 0 with {0,1,0, INVIS, "manual trigger override",};
int trig_mps2 = TRIG_LINE with {0,,TRIG_INTERN, VIS, " mps2 trigger",};
int trig_aps2 = TRIG_LINE with {0,,TRIG_INTERN, VIS, " aps2 trigger",};
int trig_scan = TRIG_LINE with {0,,TRIG_INTERN, VIS, " scan trigger",};
int trig_prescan = TRIG_LINE with {0,,TRIG_INTERN, INVIS, "prescan trigger",};
int read_truncate = 1 with {0,,1,INVIS, "Truncate extra readout on fract echo",};

int tmin_flair;		/* tmin used for maxslquant when flair is used */
int trigger_time = 0 with {0,,0,INVIS, "Time for cardiac trigger window",};
int use_myscan = 0 with {0,,0,INVIS,"On(=1) to use my scan setup",};

/* needed for Inversion.e */
int t_postreadout = 0;

int initnewgeo = PSD_ON;    /* force obloptimize_epi() call in cvinit */
int obl_debug = 0 with {0,1,0,INVIS, "On(=1) to print messages for obloptimize_epi",};
int obl_method = 1 with {0,1,1,INVIS, "1=optimal, 0=to force targets to worst case",};
int debug_order = 0 with {0,,0,INVIS,"On(=1) to print data acq order table",};
int debug_tdel = 0 with {0,1,0,VIS,"On(=1) to print ihtdeltab table",};
int debug_scan = 0 with {0,,0,INVIS,"On(=1) to print scan & rsp info tables",};
int postsat;
int order_routine = 0 with {,,0,INVIS, " slice ordering routine",};
int scan_offset;		 /* adds 'x' mm to all scan locations */

int dither_control = 0;		 /* 1 means turn dither on  */
int dither_value = 0 with {0,15,6,VIS, "Value for dither",};

int slquant_per_trig = 0 with {0,,0,INVIS, "slices in first pass or slices in first R-R for XRR scans",};

int non_tetime;                  /* time outside te time */
int slice_size;                  /* bytes per slice */
int max_bamslice;                /* max slices that can fit into bam */

/* Switch for RF 2 pulse shape */
int rf2PulseType = 0;

int bw_rf1, bw_rf2;      /* bandwidth of rf pulses */

/* x dephaser attributes */
float a_gx1;
int ia_gx1;
int pw_gx1a;
int pw_gx1d;
int pw_gx1;
int single_ramp_gx1d;      /* "bridge" decay ramp of gx1 into echo train */

/* y dephaser attributes */
float area_gy1;

/* Blip attributes */
float area_gyb;

/* Omega Pulse Attributes */
float a_omega;
int ia_omega;

float bline_time = 0;  /* time to play baseline acquistions */
float scan_time;   /* time to play out scan (without burst recovery) */
float t1flair_disdaq_time = 0.0; /* time for t1flair disdaq */

int pw_gx1_tot;
int pw_gy1_tot;
int pw_gymn1_tot, pw_gymn2_tot;
float gyb_tot_0thmoment;
float gyb_tot_1stmoment;

int pw_gz1_tot;
int pw_gzrf2l1_tot;
int pw_gzrf2r1_tot;
int pw_gzrf2l1_tot_bval;
int pw_gzrf2l2_tot_bval; /*MRIhc05259 added to include l2 crusher time*/
int pw_gzrf2r1_tot_bval;
int pw_gzrf2r2_tot_bval;

int dab_offset = 0;
int xtr_offset = -56;
int rcvr_ub_off = -100;  /* receiver unblank offset from beg of echo0000 packet */

int temprhfrsize;

int pw_wgxdl = 0;
int pw_wgxdr = 0;
int pw_wgydl = 0;
int pw_wgydr = 0;
int pw_wgzdl = 0;
int pw_wgzdr = 0;

/* DTI BJM: dual spin echo (dsp) */
int pw_wgxdl1 = 4;
int pw_wgxdr1 = 4;
int pw_wgydl1 = 4;
int pw_wgydr1 = 4;
int pw_wgzdl1 = 4;
int pw_wgzdr1 = 4;

int pw_wgxdl2 = 4;
int pw_wgxdr2 = 4;
int pw_wgydl2 = 4;
int pw_wgydr2 = 4;
int pw_wgzdl2 = 4;
int pw_wgzdr2 = 4;
/* end dsp changes */

/* variables used in gradient moment nulling */
float zeromoment;
float firstmoment;
float zeromomentsum;
float firstmomentsum;
int pulsepos;
int invertphase;

float xtarg = 1.0 with {0.0,10.0,1.0,VIS, "EPI read train logical x target",};
float ytarg = 1.0 with {0.0,10.0,1.0,VIS, "EPI read train logical y target",};
float ztarg = 1.0 with {0.0,10.0,1.0,VIS, "EPI read train logical z target",};

int ditheron = 1 with {0,1,1,VIS, "1=use b0 values from /usr/g/caldir/b0_dither.cal, 0=don't",};
float dx = 0.0 with {,,0.0,VIS, "phys X dither in deg (dx shift to + readout, -dx shift to -",};
float dy = 0.0 with {,,0.0,VIS, "phys Y dither in deg (dy shift to + readout, -dy shift to -",};
float dz = 0.0 with {,,0.0,VIS, "phys Z dither in deg (dz shift to + readout, -dz shift to -",};

/* Used by dwepiq tool */
int b0calmode = 0 with {0,1,0,VIS,"1=enable dwepiq mode, 0=disabled",};
/* Slice reset - ability to perform multi-slice scans all at a single location.  Needed for testing. */
int slice_reset = 0 with {0,1,0,VIS,"Perform multi-slice at single location, 0=off,1=on",};
float slice_loc = 0.0 with {,,0.0,VIS,"Slice offset (mm), when slice_reset=1.",};

int delayon = 1 with {0,1,1,VIS,"1=use delay values from /usr/g/caldir/dealy.dat, 0=don't",};

/* Gradient Delays */
int   gxdelay = 0us with {-1ms,1ms,-40us,VIS,"X grad delay (us).",};
int   gydelay = 0us with {-1ms,1ms,-40us,VIS,"Y grad delay (us).",};

/* Logical Delays */
float gldelayx = 0us with {-10.0ms,10.0ms, 0.0,VIS,"Logic delay (us).",};
float gldelayy = 0us with {-10.0ms,10.0ms, 0.0,VIS,"Logic delay (us).",};
float gldelayz = 0us with {-10.0ms,10.0ms, 0.0,VIS,"Logic delay (us).",};
float pckeeppct = 100.0 with {0.0, 100.0, 100.0, VIS,"Percentange of post-RFT array to use in phase correction",};
int pkt_delay = 0us with {0,1ms,0,VIS,"Hrdwr Delay between RBA & 1st Sample Acquired (us).",};

/* multi-phase */
int mph_flag = 1 with {0,1,0,INVIS,"on(=1) flag for FAST Multi-Phase option",};
int acqmode = 0 with {0,1,0,INVIS, "acq. mode, 0=interleave, 1=sequential",};
int max_phases with {0,512,,INVIS,"Maximum number of phases",};
int opslquant_old = 1 with {1,SLTAB_MAX,1,VISONLY, "Slice quantity",};
int piphases with {0,512,,INVIS,"Number of phases",};

/* echo spacing and gap */
int reqesp = 0 with {0,,0,VIS,"Requested echo spacing: 0=auto, nonzero=explicit",};
int autogap = 0 with {0,2,0,VIS,"1:auto set read gap = blip duration, 0:don't, 2:compute dB/dt sep.",};
int minesp;

/* reduced image size */
int fft_xsize = 0 with {0,1024,0,VIS, "Row FT size",};
int fft_ysize = 0 with {0,1024,0,VIS, "Column FT size",};
int image_size = 0 with {0,1024,0,VIS, "Image size",};
             
/* off-center FOV control */
float xtr_rba_time = XTRSETLNG + XTR_TAIL with {,,XTRSETLNG + XTR_TAIL,VIS, "phase accumulation interval for off-center FOV (usec)",};
float frtime = 0.0 with {,,,VIS,"read window phase accumulation interval for off-center FOV (usec)",};
int readpolar = 1 with {-1,1,1,VIS, "readout gradient base polarity: 1=positive, -1=negative.",};
int blippolar = 1 with {-1,1,1,VIS,"blipo gradient base polarity: 1=positive, -1=negative.",};

/* ref scan control */
int ref_mode = 1 with {0,2,0,VIS, "ref scan type: 0=all slices, 1=loop to center slice, 2=center slice only",};
int refnframes = 256 with {1,YRES_MAX,256,INVIS,"# of recon frames for ref scan.",};

/* ref correction */
/* This variable is pass to epiRecvFrqPhs() and enables/disables the freq offset in the */
/* receiver (to offset the FOV) for ref scanning */
int ref_with_xoffset = 1 with {-1,1,1,VIS, "Ref Correction: 0=off, 1 = include freq offset x.",};
int noRefPrePhase = 0 with {0,1,0,VIS, "Turn off ref.dat linear pre-correction ",};
int setDataAcqDelays = 1 with {0,1,1,VIS, "Turn On SSP delays (0 = no setperiod() in core)",};
int refSliceNum = -1 with {-1,256,-1,VIS, "Spatial Ref Scan Slc (0=all,-1=isocenter slc)",};

int core_shots;
int disdaq_shots;
int pass_shots;
int passr_shots;
int pass_time;    /* total time for pass packets */
int scan_deadtime; /* deadtime in scan entry point */

int pw_gxwl1 = 0;
int pw_gxwl2 = 0;
int pw_gxwr1 = 0;
int pw_gxwr2 = 0;
int pw_gxw_total = 0 with {0ms,,0ms,VIS, "pw_gxwl + pw_gxw + pw_gxwr",};

int pass_delay = 1us with {0us,,1us,VIS, "ssp delay prior to sending pass packet",};

int nshots_locks  = 0 with {0,1,0,VIS, "1=lockout opnshots<min_nshots, 0=allow all opnshots values.",};
int min_nshots = 1 with {1,MUSE_MAX_NSHOTS,1,VIS, "Minimum number of shots allowed.",};
int max_nshots = 1 with {1,MUSE_MAX_NSHOTS,1,VIS, "Maximum number of shots allowed.",};

/* phase-encoding blip oblique correction (for oblique scan planes) cvs */
float da_gyboc = 0.0 with {0.0,2.2,0.0,VIS, "Tweaking value for a_gyboc.",};

/*Ghosting lower with oc_fact of 2 - VB */
float oc_fact = 2.0 with {-10.0,10.0,1.0,VIS, "Multiplication factor for a_gyboc.",};
int oblcorr_on = 0 with {0,1,0,VIS, "Control switch for use of oblique plane  blip correction [0=off,1=on].",};

/* default oblcorr_perslice off because ipg sequence update times become
   prohibitively long when updating blip instruction amplitudes on a per-slice
   basis */
int oblcorr_perslice = 0 with {0,1,0,VIS, "Perform oblique correction on per slice basis [0=off,1=on].",};
int debug_oblcorr = 0 with {0,1,0,VIS, "Debug switch for phase-encoding blip correction [0=off,1=on].",};
float bc_delx = 0.0 with {-1000.0,1000.0,0.0,VIS, "Interpolated x delay for blip correction.",};
float bc_dely = 0.0 with {-1000.0,1000.0,0.0,VIS, "Interpolated y delay for blip correction.",};
float bc_delz = 0.0 with {-1000.0,1000.0,0.0,VIS, "Interpolated z delay for blip correction.",};
int   cvxfull = MAX_PG_IAMP;
int   cvyfull = MAX_PG_IAMP;
int   cvzfull = MAX_PG_IAMP;

/* cvs for modified rbw annotation for vrgf */
/* Deleted the definition of 3 unused CVs. ufi2_ypd */
float bw_flattop;
float area_usedramp;
float pw_usedramp;
float area_usedtotal;

int EZflag = PSD_OFF with {PSD_OFF,PSD_ON,PSD_OFF,VIS, "ezdwi indicator",};

/* Omega Scale (8 bit shift = 256)*/
float omega_scale= 256.0 with {1.0,4096,256,VIS, "Instruction amplitude scaling",};
int rba_act_start = 0;

/* APS2 rsp settings */
int aps2_rspslq;
int aps2_rspslqb;

/* Value1.5T May 2005 KK */
int ghost_check = 0 with {0,2,0,VIS,"0:off 1:phase cor. off mode(check for epi calibration) 2:phase cor. on mode",};
int gck_offset_fov = 1 with {0,1,0,VIS,"1/4 FOV offset in ghost_check 0:off 1:on",};

/* IR Prep Support Jun 2005 KK */
int irprep_flag = 0 with {0,1,0,VIS,"Epi ir prep on=1, off=0",};
int irprep_support = 0 with {0,1,0,VIS,"0:not support 1:support",};

int enhanced_fat_suppression = 0 with {0,4,0,VIS,"Enhanced Fat Suppression",};
int global_shim_method = 0 with {0,2,0,VIS,"Shim Volume Method",};
int d_cf = 0; 

/* RTG support Nov 2005 KK */
int rt_opphases = 1 with {1,DATA_ACQ_MAX,1,VIS,
                              "Number of phases of the respiratory cycle to image",};

int debugileave;

float rup_factor = 2.0; /* MRIhc19114: round factor for asset */
float min_phasefov = 0.5 with {0.1,1.0,0.5, INVIS, "Minimum phase FOV holder",};

/* MRIhc28734: core_time CV to check single axis dwell time */
float core_time = 0 with {0.0,,0.0, INVIS, "single axis dwell time for core loop",};

/* high patient weight */
int override_fatsat_high_weight = 0 with {0,1,0,INVIS,"Override forcicng fat sat use for high patient weight (1=ON, 0=OFF)",};

/* eDWI CVs */
float scale_all = 1.0 with {0.0, 1.0, 1.0, VIS, "Diffusion gradient scaling factor", };
float default_bvalue = 1000;
int default_difnex = 1;
int use_phygrad=1;
int total_difnex = 0;
int max_difnex = 0;
int max_nex = 0;
float max_bval = 0;
int gradopt_diffall = PSD_OFF;
int ADC_warning_flag = PSD_ON;
int edwi_extra_time = 40ms; 
int bigpat_warning_flag = PSD_ON;
float avg_bval = 0.0; /* including T2 */
int max_difnex_limit = MAX_DIFF_NEX;

/* Synthtic DWI */
int syndwi_flag = PSD_OFF with {PSD_OFF,PSD_ON,PSD_OFF,VIS, "Flag for synthetic DWI",};
float prescribed_max_bval=0;
float prescribed_min_bval=1000000;
float prescribed_bval_range=0.0;

int fullk_nframes = 1;

/* SVBranch: HCSDM00102521 */
float xfd_power_limit = 8.5 with { 2.0, 15.0, 8.5, INVIS, "XFD PS limitation", };
float xfd_temp_limit = 8.5  with { 2.0, 15.0, 8.5, INVIS, "XFA temperature power limitation", };

float TGenh = 0.0 with {-30.0,0.0,0.0, INVIS, "TG enhancement",};

int vrgf_bwctrl = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "Flag for enabling RBW control with VRGF",};

/* Refless EPI */
/* we have ref_in_scan_flag here because refless_option can potentially have more choices
   where multiple choices can correspond to the same ref_in_scan_flag value */
int ref_in_scan_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "0 = ref as a separate entry point, 1 = ref becomes the first pass of scan", ""};
int refless_option = 1 with {0, 1, 1, VIS, "0 = with ref, 1 = integrated ref", ""};
int ref_dda = 0 with {0, , 0, INVIS, "number of disdaqs in ref scan", ""};
int scan_dda = 0 with {0, , 0, INVIS, "number of disdaqs in scan", ""};

/* int edr_support = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "Flag for EDR support: 1-yes, 0-no",}; */ /* granty maybe */

int pc_enh = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "Phase Correction Enhancement: 1-yes, 0-no",};
int ref_volrecvcoil_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "Switch to volume receive coil for reference scan: 1-yes, 0-no",};

int hopc_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "High-order phase correction: 1-yes, 0-no",};

/*To evenly distribute power on 3 axes for diffusion gradient, diffusion direction and bval is alternating slice by slice within each TR.*/
int diff_order_flag = 0 with {0, 2, 0, VIS, "Intra-TR diffusion direction cycling mode: 0 = No cycling(Legacy), 1 = each b-value, 2 = all b-values"};
int diff_order_debug = 0;
int diff_order_verify = 0;
int diff_order_nslices = 0;
int diff_order_size = 0;
int diff_pass_counter = 0;
int diff_pass_counter_save = 0;

int skip_ir = 0;

int num_iters = 0 with {0,MAX_NUM_ITERS,0,VIS, "number of TRs in cornerpoint generation. 0 = OFF", ""};
/* margin scaling factor to avoid Under-Voltage for SV system -HCSDM00379157 HCSDM00394803 */
float dti_dse_ecoon_scaling_factor = 1.07;                 /* scaling_factor for DTI with dual spin echo and Eco_mpg on */
float dti_sse_ecoon_scaling_factor = 1.03;                 /* scaling_factor for DTI with single spin echo and Eco_mpg on */
float dti_sse_ecooff_scaling_factor = 1.0175;              /* scaling_factor for DTI with single spin echo and Eco_mpg off */
float dwi_single_all_dse_ecoon_scaling_factor = 1.04;      /* scaling_factor for DWI R_L A_P S_I SLICE ALL with dual spin echo and Eco_mpg on */
float dwi_single_all_sse_ecoon_scaling_factor = 1.01;      /* scaling_factor for DWI R_L A_P S_I SLICE ALL with single spin echo and Eco_mpg on */
float dwi_3in1_dse_ecoon_scaling_factor = 1.03;            /* scaling_factor for DWI 3in1 with dual spin echo and Eco_mpg on */

/* Kizuna 1.5T system flag */
int k15_system_flag = 0 with {0, 1, 0, VIS, "Kizuna 1.5T system flag, 0 = off, 1 = on", ""};       
 
/* HOEC */
@inline HoecCorr.e HoecCV

@inline Muse.e MuseCV

/* Gmax and SR control for EPI readout gradient */
float epi_srderate_factor = 1.0;
int epi_loggrd_glim_flag = PSD_OFF;
float epi_loggrd_glim = 0.0;

/* Adaptive Gmax control for MPG */
int adaptive_mpg_glim_flag = PSD_OFF;
float adaptive_mpg_glim = 0.0;

int avmaxpasses = MAX_DTI_LEGACY+MAX_T2 with {1,2000,MAX_DTI_LEGACY+MAX_T2,VIS,"Max # of passes",}; 

int nav_image_interval = 0;

int focus_B0_robust_mode = 0 with { 0, 1, 0, VIS, "Flag to set bw_rf2 close to bw_rf1 to avoid signal loss", };
float focus_unwanted_delta_f = 440 with {0, 1000, 440, VIS, "Delta frequency of unwanted signal in focus [Hz]", };

/***SVBranch: HCSDM00259119  eco mpg ***/
@inline eco_mpg.e eco_mpg_cv
/*********************/

int fskillercycling = 0 with { 0, 1, 0, VIS, "Flag to cycle FatSat killer", };

/****************************************************************************/

@host

/* System includes */
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> /*RTB0 correction*/
#include <sys/stat.h>

/* Local includes */
#include "calcdelta.h"
#include "dBdt.h"
#ifndef SIM
/* Needed for epic_warning() */
#include "epic_warning.h"
#endif /* SIM */
#include "grad_rf_epi2.h"
#include "grad_navmonitor.h"
#include "printDebug.h"
#include "psd.h"
#include "psdIF.h"
#include "psdopt.h"
#include "rfsspsummary.h"
#include "sar_burst_api.h"
#include "sar_display_api.h"
#include "sar_limit_api.h"
#include "sar_pm.h"
#include "sokPortable.h"   /* includes for option key functionality */
#include "supp_macros.h"
#include "sysDep.h"
#include "sysDepSupport.h"
/* t1flair_stir */
#include "T1flair.h"
#include "time_profiler_client.h"

#ifdef EMULATE_HW
#define checkOptionKey(x) 0
#endif

@inline loadrheader.e rheaderhost

/* Private function prototypes */
static INT setEpiEsp(void);

static void SetCyclingCVs(void);

/* Private function prototypes for ASPIR TI */
static void init_ASPIR_TI(void);
static INT calc_ASPIR_TI(int);
static void set_ASPIR_TI(int);

@inline epi_esp_opt.e epi_esp_opt_host_funcs
@inline DTI.e DTI_host_funcs
@inline DTI.e DTIarrays
@inline RfovFuncs.e RfovHost
@inline MultibandFuncs.e MultibandHost

/*softkey checks*/
int dwepi_status = PSD_OFF;
int flairepi_status = PSD_OFF;
int edwi_status = PSD_OFF;
int bodynav_status = PSD_OFF;
int focus_status = PSD_OFF;
int multiband_status = PSD_OFF;
int apx_status = PSD_OFF;
int syndwi_status = PSD_OFF;
int superG_key_status = PSD_OFF;
int distcorr_status = PSD_OFF;
int muse_status = PSD_OFF;
int maxtensor_status = PSD_OFF;

int save_newgeo;
/* needed for Inversion.e */
FILTER_INFO scan_filt;         /* parameters for xres=256 filter */
FILTER_INFO echo1_filt;         /* Used by epi.e */

/* Array to hold max B1 for each entry point. */
float maxB1[MAX_ENTRY_POINTS], maxB1Seq;
int   entry, pulse;           /* loop counters */

int   crusher_type;             /* Vrg or non vrg type define */
float crusher_scale[NECHO_MAX];  /* reserve space for crusher scale factors*/

int av_temp_int;                 /* temp placement for advisory panel return values */
float av_temp_float;             /* temp placement for advisory panel return values */

OPT_GRAD_INPUT gradin;     /* gradient input paramters */
OPT_GRAD_PARAMS gradout;   /* gradient output paramters for optimal grads */

/* HCSDM00361682 */
int avmaxslquant_hist[MAX_FOCUS_EVAL_WATCH] = {0,0,0,0};
int acqs_hist[MAX_FOCUS_EVAL_WATCH] = {0,0,0,0};
int tmin_hist[MAX_FOCUS_EVAL_WATCH] = {0,0,0,0};

static const char supfailfmt[] = "Support routine %s failed.";

int old_weighted_avg_grad = -1;
float old_avg_bval = -1.0;
int old_num_dirs = -1;
int old_opdifnumt2 = -1;
int old_dualspinecho_flag = -1;
int old_diff_order_flag = -1;
int old_opdfax3in1 = -1;

int cur_num_iters;
int xamp_iters[MAX_NUM_ITERS];
int yamp_iters[MAX_NUM_ITERS];
int zamp_iters[MAX_NUM_ITERS];

int ss_rf1_compatible = PSD_ON;
int opfat_on_UI = PSD_OFF;

/* MGD inlines */
@inline epi2ImageOptionCheck.e epi2ImageCheck
@inline epiCalFile.e epiCalFileHost

/* MGD: needed for filter changes */
@inline Prescan.e PShostVars

@inline epi_esp_opt.e epi_esp_opt_host_vars

/* For enabling more than 1024 im/ser -Venkat */
int enable_1024 = 0; 
int max_slice_limit = DATA_ACQ_MAX;

@inline epi2_iopts.e AllSupportedIopts
@inline epi2_iopts.e ImagingOptionFunctions

@inline vmx.e HostDef

/***SVBranch: HCSDM00259119  eco mpg ***/
@inline eco_mpg.e eco_mpg_host
/*********************/

/* load up psd header */
abstract("Spin or gradient recalled echo planar imaging sequence (rev113)");
psdname("EPI2");

/* HOEC: Functions to read HOEC compensation configuration in manual mode */
@inline HoecCorr.e HoecReadFileFunctions

/* parab() for b_fact calculation */
/* BJM: all this is is the result of the indefinite integral */
/* of b(t) = integral of (k(t)k(t))dt from x to t where....  */
/*         k(t) = (2pi*gamma)(g*t+c) (assumes g(t) = g)      */
/* Thus, parab = (2pi*gamma)^2*integral(g^2t^2 + 2gtc +c^2) evaluated */
/* over some interval x -> x'. c is the initial condition for each    */ 
/* time interval.... */
#ifdef __STDC__
FLOAT parab( FLOAT amp, FLOAT time, FLOAT offset )
#else /* !__STDC__ */
    FLOAT parab(amp,time,offset)
    FLOAT amp; 
    FLOAT time;
    FLOAT offset;
#endif /* __STDC__ */
{
    FLOAT tmp;

    tmp = pow(amp, 2.0) * pow(time, 3.0) / 3.0;
    tmp += amp * pow(time, 2.0) * offset;
    tmp += time * pow(offset, 2.0);

    return tmp;
}


/* ****************************************
   MYSCAN
   myscan sets up the scan_info table for a hypothetical scan.
   It is controlled by the cv opslquant, and opslthick, and opfov. 
   ************************************** */
void
myscan( void )
{
    int i,j;
    int num_slice;
    float z_delta;		/* change in z_loc between slices */
    float r_delta;		/* change in r_loc between slices */
    double alpha, beta, gamma; /* rotation angles about x, y, z respectively */
    
    num_slice = exist(opslquant);
    
    r_delta = exist(opfov)/num_slice;
    z_delta = exist(opslthick)+exist(opslspace);
    
    scan_info[0].optloc = 0.5*z_delta*(num_slice-1);
    scan_info[0].oprloc = myrloc;

    for (i=1;i<9;i++)
        scan_info[0].oprot[i]=0.0;
    
    switch (exist(opplane)) {
    case PSD_AXIAL:
        scan_info[0].oprot[0] = 1.0;
        scan_info[0].oprot[4] = 1.0;
        scan_info[0].oprot[8] = 1.0;
        break;
    case PSD_SAG:
        scan_info[0].oprot[2] = 1.0;
        scan_info[0].oprot[4] = 1.0;
        scan_info[0].oprot[6] = 1.0;
        break;
    case PSD_COR:
        scan_info[0].oprot[1] = 1.0;
        scan_info[0].oprot[5] = 1.0;
        scan_info[0].oprot[6] = 1.0;
        break;
    case PSD_OBL:
        alpha = PI/4.0;  /* rotation about x (applied first) */
        beta = PI/8.0;   /* rotation about y (applied 2nd) */
        gamma = PI/4.0;  /* rotation about z (applied 3rd) */
        scan_info[0].oprot[0] = cos(gamma)*cos(beta);
        scan_info[0].oprot[1] = cos(gamma)*sin(beta)*sin(alpha) -
                                       sin(gamma)*cos(alpha);
        scan_info[0].oprot[2] = cos(gamma)*sin(beta)*cos(alpha) +
                                       sin(gamma)*sin(alpha);
        scan_info[0].oprot[3] = sin(gamma)*cos(beta);
        scan_info[0].oprot[4] = sin(gamma)*sin(beta)*sin(alpha) +
                                       cos(gamma)*cos(alpha);
        scan_info[0].oprot[5] = sin(gamma)*sin(beta)*cos(alpha) -
                                       cos(gamma)*sin(alpha);
        scan_info[0].oprot[6] = -sin(beta);
        scan_info[0].oprot[7] = cos(beta)*sin(alpha);
        scan_info[0].oprot[8] = cos(beta)*cos(alpha);
        break;
    }
  
    for(i=1;i<num_slice;i++) {
        scan_info[i].optloc = scan_info[i-1].optloc - z_delta;
        scan_info[i].oprloc = i*r_delta;
        for(j=0;j<9;j++)
            scan_info[i].oprot[j] = scan_info[0].oprot[j];
    }
    
    return;
    
}

/*
 * Override coil acceleration capabilties
 */
void epi_asset_override(void)
{
    if(existcv(opasset) && (1 == exist(opassetscan)))
    {
        /* To replicate legacy behavior, allow ASSET R=2 even if the coil
         * doesn't support it. */
         cfaccel_ph_maxstride = FMax(2, 2.0, cfaccel_ph_maxstride);
    }

    return;
}

/*
 * Setup parallel imaging UI to only show integer step sizes
 */
void epi_asset_set_dropdown(void)
{
    if(existcv(opasset) && (1 == exist(opassetscan)))
    {
        if(muse_flag)
        {
            float temp_maxaccel = 1.0;

            temp_maxaccel = floor(avmaxaccel_ph_stride/exist(opnshots)*4.0)*0.25;
            piaccel_phval2 = 1.0;
            piaccel_phval3 = FMin(2, avmaxaccel_ph_stride/2.0, temp_maxaccel);
            if(piaccel_phval3 > piaccel_phval2)
            {
                piaccel_phnub = 3;
            }
            else
            {
                piaccel_phnub = 2;
            } 
        }
        else
        {
            if(avmaxaccel_ph_stride > 2.0)
            {
                piaccel_phnub = 4;
                piaccel_phval2 = 1.0;
                piaccel_phval3 = 2.0;
                piaccel_phval4 = avmaxaccel_ph_stride;
            }
            else
            {
                piaccel_phnub = 3;
                piaccel_phval2 = 1.0;
                piaccel_phval3 = 2.0;
            }
        }

        piaccel_ph_step = 1.0;
    }

    return;
}

/*
 * Setup ARC parallel imaging UI to only show integer step sizes
 */
void epi_arc_set_dropdown(void)
{
    if( existcv(oparc) && (exist(oparc)) && (PSD_ON == mux_flag) )
    {
        /*Multiband only supports up to factor of 2 in-plane acceleration*/
        if(avmaxaccel_ph_stride >= 2.0)
        {
            piaccel_phedit = 0; /* do not allow user manually input acceleration factor */
            if  (avmaxaccel_ph_stride >2.0)
            {
                piaccel_phnub = 4;
                piaccel_phval2 = 1.0;
                piaccel_phval3 = 2.0;
                piaccel_phval4 = avmaxaccel_ph_stride;
            }
            else
            {
                piaccel_phnub = 3;
                piaccel_phval2 = 1.0;
                piaccel_phval3 = 2.0;
            }
            piaccel_ph_step = 1.0;
        }
        else
        {
            piaccel_phnub = 0;
            avmaxaccel_ph_stride = 1.0;
        }
    }

    return;
}

/*
 * Only allow integer acceleration factors
 */
STATUS epi_arc_override(void)
{
    if(existcv(oparc) && (exist(oparc)))
    {
        if (!floatIsInteger(exist(opaccel_ph_stride)))
        {
            cvoverride(opaccel_ph_stride, (int)ceil(exist(opaccel_ph_stride)), PSD_FIX_ON, PSD_EXIST_ON);
            epic_error( use_ermes, "Only integer acceleration factor allows for ARC EPI. The integer value of %d should be used.",
                        EM_PSD_INT_ACCEL, EE_ARGS(1),
                        INT_ARG, (int)(ceil(opaccel_ph_stride)) );
            return ADVISORY_FAILURE;
        }
        if(cfaccel_ph_maxstride < 2.0)
        {
            cvoverride(opaccel_ph_stride, 1.0, PSD_FIX_ON, PSD_EXIST_ON);
        }
    }

    return SUCCESS;
}

/****************************************************************************/
/*  CVINIT                                                                  */
/****************************************************************************/
STATUS
cvinit( void )
{
    int status_flag = SUCCESS;

    cvmax(vrgfsamp, PSD_ON);
    cvdef(esp, 0);
    esp = 0;

    if ((PSDDVMR == psd_board_type) && (value_system_flag == NON_VALUE_SYSTEM))
    {
        /* B0 dither calibration is removed for DVMR hardware */
        ditheron = 0;
    }
    else
    {
        ditheron = 1;
    }

    OpenDelayFile(delay_buffer);
    if (ditheron)
    {
        OpenDitherFile(txCoilInfo[getTxIndex(coilInfo[0])].txCoilType,
                       dither_buffer);
        OpenDitherInterpoFile(txCoilInfo[getTxIndex(coilInfo[0])].txCoilType,
                              ccinx, cciny, ccinz, esp_in, fesp_in, &g0,
                              &num_elements, &file_exist);
    }

    /* RAK: MRIge55889 - removed GRAD_UPDATE_TIME being used during the */
    /*                   initialization of CVs.                         */ 
    pwmin_gap     = 2*GRAD_UPDATE_TIME;
    td0           = GRAD_UPDATE_TIME;
    hrdwr_period = GRAD_UPDATE_TIME;
 
    /* SXZ::MRIge72411: init the optimization arr */
    taratio_arr[0] = 0.7; 
    taratio_arr[1] = 0.65; 
    taratio_arr[2] = 0.5;
    totarea_arr[0] = 1127.4; /* fov=20; xres=96 */
    totarea_arr[1] = 1503.2; /* fov=20; xres=128 */
    totarea_arr[2] = 2254.8; /* fov=20; xres=192 */

    if ( !strncasecmp("epi2spec",get_psd_name(),8) ) {
        epi2spec_mode = PSD_ON;
    } else {
        epi2spec_mode = PSD_OFF;
    }

    epi_asset_override();
    epi_arc_override();

@inline Asset.e AssetCVInit
    if(mux_flag)
    {
@inline ARC.e ARCInit
    }
    epi_asset_set_dropdown();
    epi_arc_set_dropdown();

    /* MRIhc19114 */
    if ( (fract_ky == PSD_FRACT_KY) && (intleaves == 1) ) {
        rup_factor = 4.0;
    } else {
        rup_factor = 2.0;
    }

    if ( (existcv(opasset) && (exist(opasset) == ASSET_SCAN_PHASE)) || (existcv(oparc) && (exist(oparc))) ) {
        int temp_nframes;

        if(arc_extCal && oparc){
            asset_factor = arc_ph_factor;
        }
        if (num_overscan > 0) {
            temp_nframes = (short)(ceilf((float)exist(opyres)*asset_factor/rup_factor)*rup_factor*fn*nop - ky_offset);
            asset_factor = FMin(2, 1.0, floorf((temp_nframes + ky_offset)*1.0e5/((float)exist(opyres)*fn*nop))/1.0e5);
        } else {
            temp_nframes = (short)(ceilf((float)exist(opyres)*asset_factor/rup_factor)*rup_factor*fn*nop);
            asset_factor = FMin(2, 1.0, floorf(temp_nframes*1.0e5/((float)exist(opyres)*fn*nop))/1.0e5);
        }
    } else {
        asset_factor = 1.0;
        arc_ph_factor = 1.0;
    }

    /* BJM - gating */
    cvmax(ophrep, 10);
    ophrep = 10;
    cvdef(ophrep, 10);
    cvmin(ophrep, 1);
    pihrepnub = 2;
    
    opautorbw = PSD_OFF;

#ifdef ERMES_DEBUG
    
    use_ermes = 0;
    
#else /* !ERMES_DEBUG */
    use_ermes = 1;
#endif /* ERMES_DEBUG */
    /* MRIge52416 - ezdwi can't be run on SR120 and SR150, lock it out. PH */
    if ( strncasecmp("ezdwi",get_psd_name(),5) == 0 ) {
        if ( ((cfsrmode == PSD_SR50) && (isStarterSystem())) || (cfsrmode == PSD_SR100) || (cfsrmode == PSD_SR120) || (cfsrmode == PSD_SR150) ) {
            epic_error( use_ermes, "EZDWI is not compatible with SR50(Starter System),SR100, SR120 or SR150", EM_PSD_EZDWI_INCOMPATIBLE, EE_ARGS(0) ); 
            return FAILURE;
        } else {
            EZflag = PSD_ON;
        }
    } else {
        EZflag = PSD_OFF;
    }

#ifdef PSD_HW
    if ( (checkOptionKey( SOK_DWEPI ) == KEY_PRESENT)
         || (checkOptionKey( SOK_DWEPIEZ ) == KEY_PRESENT) )
    {   /* any problem reading option key? */
        dwepi_status = PSD_ON;     /* no-then flag key as present */
    }
    else
    {
        dwepi_status = PSD_OFF;    /* yes-then flag key as absent */
    }
    
    if ( (checkOptionKey( SOK_FLAIREPI ) == KEY_PRESENT)
         || (checkOptionKey( SOK_DWEPIEZ ) == KEY_PRESENT) )
    {   /* any problem reading option key? */
        flairepi_status = PSD_ON;  /* no-then flag key as present */
    } 
    else
    {
        flairepi_status = PSD_OFF; /* yes-then flag key as absent */
    } 

    if (checkOptionKey( SOK_EDWI ) == KEY_PRESENT)
    {   /* any problem reading option key? */
        edwi_status = PSD_ON;      /* no-then flag key as present */
    }
    else
    {
        edwi_status = PSD_OFF;     /* yes-then flag key as absent */
    }

    if (checkOptionKey( SOK_BODYNAV ) == KEY_PRESENT)
    {
        bodynav_status = PSD_ON;   /* no-then flag key as present */
    }
    else
    {
        bodynav_status = PSD_OFF;  /* yes-then flag key as absent */
    }

    if (checkOptionKey( SOK_FOCUS ) == KEY_PRESENT)
    {
        focus_status = PSD_ON;
    }
    else
    {
        focus_status = PSD_OFF;
    }

    if ( checkOptionKey( SOK_SYNDWI ) == KEY_PRESENT )
    {
        syndwi_status = PSD_ON;
    }
    else
    {
        syndwi_status = PSD_OFF;
    }

    if (checkOptionKey( SOK_APX ) == KEY_PRESENT)
    {
        apx_status = PSD_ON;
    }
    else
    {
        apx_status = PSD_OFF;
    }

    if (checkOptionKey( SOK_HYPERBAND ) == KEY_PRESENT)
    {
        multiband_status = PSD_ON;
    }
    else
    {
        multiband_status = PSD_OFF;
    }
    
    if (checkOptionKey( SOK_DISTCORR ) == KEY_PRESENT)
    {
        distcorr_status = PSD_ON;
    }
    else
    {
        distcorr_status = PSD_OFF;
    }

    if (checkOptionKey( SOK_SUPERG ) == KEY_PRESENT)
    {
        superG_key_status = PSD_ON;
    }
    else
    {
        superG_key_status = PSD_OFF;
    }
    if (checkOptionKey( SOK_MUSE ) == KEY_PRESENT) 
    {
        muse_status = PSD_ON;
    }
    else
    {
        muse_status = PSD_OFF;
    }
    if (checkOptionKey( SOK_MAXTENSOR ) == KEY_PRESENT) 
    {
        maxtensor_status = PSD_ON;
    }
    else
    {
        maxtensor_status = PSD_OFF;
    }

#else
    dwepi_status = PSD_ON;
    flairepi_status = PSD_ON;
    edwi_status = PSD_ON;
    bodynav_status = PSD_ON;
    focus_status = PSD_ON;
    syndwi_status = PSD_ON;
    apx_status = PSD_ON;
    multiband_status = PSD_ON;
    distcorr_status  = PSD_ON;
    superG_key_status = PSD_ON;
    muse_status = PSD_ON;
    maxtensor_status = PSD_ON;
#endif

    /***********************************************************************/
    /*	Init some flair  variables					*/
    /************************************************************************/
    cvmax(opepi, PSD_ON);  /* enable epi flag selection */
    cvdef(opepi, PSD_ON);

    cvmax(opdiffuse,PSD_ON);
    cvmax(opflair, PSD_ON);

    cvmin(opexcitemode, SELECTIVE);
    cvmax(opexcitemode, FOCUS);
    cvdef(opexcitemode, SELECTIVE);
    pidefexcitemode = SELECTIVE;

    SetCyclingCVs();

    /***SVBranch: HCSDM00259119  eco mpg ***/
    if (FAILURE == eco_mpg_cvinit())
    {
        epic_error(use_ermes, "ECO-MPG cvinit Failed",
                   EM_PSD_SUPPORT_FAILURE, 1, STRING_ARG, "eco_mpg_cvinit()");
        return FAILURE;
    }
    /**********************/

    if( (PSD_ON == focus_status) && 
        existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) &&
        (PSD_OFF == exist(opflair)) && (PSD_OFF == exist(opasset)) &&
        (opnumgroups <= 1) && (strcmp(get_psd_name(), "epi2alt")) && (mux_flag == PSD_OFF) && (muse_flag == PSD_OFF))
    {
        /* Allow RFOV Focus DWI */
        piexcitemodenub = 1 + 4; /* 1:Selective + 4:Focus */
    }
    else
    {
        piexcitemodenub = 1;     /* Selective only */
    }

    /* MRIhc56268: Dual Spin Echo */
    if( existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) &&
        existcv(opdualspinecho) && (PSD_ON == exist(opdualspinecho)) )
    {
        dualspinecho_flag = 1;
    }
    else
    {
        dualspinecho_flag = 0;
    }

    if((PSD_ON == exist(opdiffuse)) && (PSD_OFF == rfov_flag))
    {
        pioverlap = PSD_ON;
    }
    else
    {
        pioverlap = PSD_OFF;
    }

    if(exist(opdiffuse) == PSD_ON)
    {
        irprep_support = PSD_ON;
        edr_support = PSD_ON;
    }
    else
    {
        irprep_support = PSD_OFF;
        edr_support = PSD_OFF;
    }

    if (DATA_ACQ_TYPE_FLOAT == dacq_data_type)  /* if data type is float(32bits), edr need to be turned on for 32bits data */
    {
        edr_support = PSD_ON;
    }

    /* MRIge65081 */
    if(opcgate==PSD_ON)
        setexist(opcgate,PSD_ON); 
    else
        setexist(opcgate,PSD_OFF); 

    
    /*JAH: MRIge59726 -- added existcv(opuser6) to prevent nuisance failures
      when switching between DW and FLAIR */
    /* irprep_support */
    if ( (exist(opdiffuse) == PSD_ON) && existcv(opuser6) && !exist(opirprep))
    {
        setexist(opflair,PSD_ON);
        _opflair.fixedflag = 0;
        opflair = (int)opuser6;     /* MRIge56912 - TAA */
        _opflair.fixedflag = 1;
        setexist(opuser6,(opflair == 1)); /*MRIge59726 -- I don't exist when
                                            you don't see me.*/
    }
    
        
    /* MRIge52235 - use opflair instead of opuser6. */ 
    epi_flair = exist(opflair);
    flair_flag = exist(opflair);

    if(irprep_support == PSD_OFF){
        ir_on = exist(opflair);
        irprep_flag = PSD_OFF;
    } else {
        ir_on = exist(opflair) | exist(opirprep); 
        irprep_flag = exist(opirprep); 
    }

    if ( !strncmp(get_psd_name(), "epi2_stircl",11) )
    {
        /* non-interleaved STIR */
        t1flair_flag = PSD_OFF;
        ir_prep_manual_tr_mode = PSD_OFF;
    }
    else
    {
        if (irprep_flag)
        {
            if ((exist(opcgate) == PSD_ON) || (exist(oprtcgate) == PSD_ON) ||
                (navtrig_flag == PSD_ON) || (exist(opirmode) == PSD_ON) ||
                (rfov_flag == PSD_ON))
            {
                t1flair_flag = PSD_OFF;
                ir_prep_manual_tr_mode = PSD_OFF;
            }
            else
            {
                /* T1flair STIR and Auto TI support only 3T at this time. */
                /* Need evaluation for 1.5T to make them compatible.      */
                if (B0_30000 == cffield)
                {
                    t1flair_flag = PSD_ON;
                    ir_prep_manual_tr_mode = PSD_OFF;
                }
                else
                {
                    /* Non 3T cases */
                    t1flair_flag = PSD_OFF;
                    ir_prep_manual_tr_mode = PSD_OFF;
                }
            }
        }
        else
        {
            t1flair_flag = PSD_OFF;
            ir_prep_manual_tr_mode = PSD_OFF;
        }
    }

    if ((t1flair_flag == PSD_ON) && (ir_prep_manual_tr_mode == PSD_ON))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE,
                   EE_ARGS(2), STRING_ARG, "T1flair mode",STRING_ARG, "Manual TR mode");
        return FAILURE;
    }

    if(epi_flair == PSD_ON)
    {
        false_acqs=2;	/* Force false_acqs=2  */
        cvdef(opslquant,4);
    }

    /* flag for cross term correction */
    dwicntrl=0;
    
    /* Initialize B0 field for maxwell compensation */
    B0_field=cffield;

@inline vmx.e SysParmInit
@inline vmx.e AcrxScanVolumeInit

    /* default opslquant to 4 slices for the benefit of flair */
    cvdef(opslquant,4);


    cvmod(rhpcspacial, 0, DATA_ACQ_MAX, 1,
          "temporal index of ref scan slice (0=all slices).",0," ");
    cvmod(rhref, 0, 5, 2, "Ref Alg. 0=old, 1=new, 2=N-N sub, 5=integrated",0," ");
    cvmod(opirmode, 0, 1, 0, "Sequential (1) or interleaved (0) mode.",0," ");
    opirmode = 0;
  
    scan_offset = 0;
    postsat = PSD_OFF;
    
    /*
     * Set the gradient calc mode here for selecting the right gradsafety
     * calc technique.
     * NOTE: The gradHeatMethod CV is used in minseq() to decide whether to call
     *       minseqseg() (gradHeatMethod = TRUE -> Linear Segment Method) or
     *       minseqgrad() (gradHeatMethod = FALSE -> Traditional Method).
     */
    gradHeatMethod = PSD_ON;

    /* YMSmr07133 */
    if( value_system_flag == VALUE_SYSTEM_HDE ){
        gradDriverMethod = PSD_ON;
    }

    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e PulsegenonhostSwitch

    if( (piautotrmode != PSD_AUTO_TR_MODE_MANUAL_TR) && ( (PSD_ON == tensor_flag) || (PSD_ON == mux_flag) || (PSD_ON == muse_flag) ) )
    {
        cvmax(optracq, 1);
    }
    else
    {
        cvmax(optracq,1000);
    }


    /* initialize configurable variables */
    EpicConf();

    opautodifnext2 = 1;
    opautonumbvals = 1;

    opautoti = PSD_OFF;

    /* ZZ, activate ASPIR through SPECIAL fat sat option */
    if( PSD_ON == exist(opdiffuse) )
    {
        if (exist(opirprep))
        {
            pichemsatopt = 0;
        }
        else
        {
            pichemsatopt = 2;
        }
    }
    else {
        pichemsatopt = 0;
    }

    /* set max nex limit */
    max_difnex_limit = MAX_DIFF_NEX;
    if(!value_system_flag && (PSD_ON == exist(opdiffuse)) && (PSD_ON == edwi_status))
    {
        max_difnex_limit = MAX_DIFF_NEX_64;
    }

    if ( FAILURE == DTI_Init() ) {
        return FAILURE;
    } 

    cvmax(rhreps, 512); /* YMSmr06649 */

    /* Enable > 1024 im/ser only for DTI and Multiphase scans
     * and NOT for DW-Epi since host/recon don't support it
     * -Venkat
     */
    /* MRIhc46718: set enable_1024 ON and increase max_slice_limit to 50,000 for DWI */
    if (PSD_ON == opdiffuse)
    {
        enable_1024 = PSD_ON;
        max_slice_limit = MAX_SLICES_DTI;
        /* Update to number of diffusion directions for Clinical and Research Modes */
        avmaxpasses = (((PSD_ON == exist(opresearch)) && (rhtensor_file_number > 0))? MAX_DIRECTIONS : act_numdir_clinical) + MAX_T2; 
    }
    else if (PSD_ON == exist(opmph))
    {
        enable_1024 = PSD_ON;
        max_slice_limit = RHF_MAX_IMAGES_MULTIPHASE;
        avmaxpasses = PHASES_MAX; 
    }
    else
    {
        enable_1024 = PSD_OFF;
        max_slice_limit = DATA_ACQ_MAX * SLICE_FACTOR;
        avmaxpasses = PHASES_MAX; 
    }

    cvmod(rhnslices, 0, max_slice_limit, 1, "opslquant*optphases*opfphases.", 0, " ");


    /* Silent Mode  05/19/2005 YI */
    /* Save configurable variables after conversion by setupConfig() */
    if(set_grad_spec(CONFIG_SAVE,glimit,srate,PSD_ON,debug_grad_spec) == FAILURE)
    {
      epic_error(use_ermes,"Support routine set_grad_spec failed",
        EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"set_grad_spec");
        return FAILURE;
    }

@inline MK_GradSpec.e GspecInit

    if(PSD_ON == mkgspec_epi2_flag)
    {
        piuset |= use22;
        opuser22 = 3.0;
        cvmod(opuser22, 0.0, 3.0, 3.0, "MK Gradient Spec Control (0=Off, 1=Gmax, 2=SR, 3=Gmax&SR)",0," ");

        if (existcv(opuser22) && 
            ((exist(opuser22) > 3) || (exist(opuser22) < 0) || (!floatIsInteger(exist(opuser22)))))
        {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser22.descr );
            return FAILURE;
        }

        mkgspec_flag = (int)opuser22;
    }
    else
    {
        piuset &= ~use22;
        cvmod( opuser22, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 22", 0, "" );
        cvoverride(opuser22, _opuser22.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        mkgspec_flag = PSD_OFF;
    }

@inline MK_GradSpec.e GspecInit2

    if (PSD_XRMW_COIL == cfgcoiltype)
    {
        config_update_mode = CONFIG_UPDATE_TYPE_DVW_AMP321SR120;
    }

    if( (mkgspec_x_sr_flag & MK_SPEC_SR_CHANGE) || (mkgspec_y_sr_flag & MK_SPEC_SR_CHANGE) || (mkgspec_z_sr_flag & MK_SPEC_SR_CHANGE) || 
         mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag )
    {
        config_update_mode = CONFIG_UPDATE_TYPE_SKIP;
    }

    if( mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag )
    {
        different_mpg_amp_flag = PSD_ON;
    }
    else
    {
        different_mpg_amp_flag = PSD_OFF;
    }

    /* Obl 3in1 opt */
    {
        int i;
        orth_info[0].optloc = 0.0;
        orth_info[0].oprloc = 0.0;
        orth_info[0].opphasoff = 0.0;

        for (i=0; i<9; i++)
        {
            orth_info[0].oprot[i]=0.0;
        }

        orth_info[0].oprot[0] = 1.0;
        orth_info[0].oprot[4] = 1.0;
        orth_info[0].oprot[8] = 1.0;
    }

    inittargets(&loggrd, &phygrd);
    inittargets(&epiloggrd, &epiphygrd);
    inittargets(&orthloggrd, &orthphygrd); /* Obl 3in1 opt */

    /* Get gradient spec for silent mode */
    getSilentSpec(exist(opsilent), &grad_spec_ctrl, &glimit, &srate);

    /* MRIhc56520: for EPI with ART on 750w. */
    if (exist(opsilent) && (cffield == B0_30000) && (cfgcoiltype == PSD_XRMW_COIL))
    {
        srate = XRMW_3T_EPI_ART_SR;
    }
    else if (exist(opsilent) && (cffield == B0_30000) && (cfgcoiltype == PSD_VRMW_COIL))
    {
        srate = VRMW_3T_EPI_ART_SR;
    }

    if ((cffield == B0_15000) && (cfgcoiltype == PSD_VRMW_COIL))
    {
        k15_system_flag = PSD_ON;        
    }
    else 
    {
        k15_system_flag = PSD_OFF;
    }

@inline MK_GradSpec.e GspecEval

    /* Update configurable variables */
    if(set_grad_spec(grad_spec_ctrl,glimit,srate,PSD_ON,debug_grad_spec) == FAILURE)
    {
      epic_error(use_ermes,"Support routine set_grad_spec failed",
        EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"set_grad_spec");
        return FAILURE;
    }

    /* Skip setupConfig() if grad_spec_ctrl is turned on */
    if(grad_spec_change_flag) {
        if(grad_spec_ctrl)config_update_mode = CONFIG_UPDATE_TYPE_SKIP;
        else {
            /* MRIhc56453 supported XRMW coil case  Apr 18,2011 YI */
            if (PSD_XRMW_COIL == cfgcoiltype) config_update_mode = CONFIG_UPDATE_TYPE_DVW_AMP321SR120;
            else if(tensor_flag)config_update_mode = CONFIG_UPDATE_TYPE_TENSOR;
            else           config_update_mode = CONFIG_UPDATE_TYPE_ACGD_PLUS;
        }
        inittargets(&loggrd, &phygrd);
        inittargets(&epiloggrd, &epiphygrd);
        inittargets(&orthloggrd, &orthphygrd); /* Obl 3in1 opt */
    }
    /* End Silent Mode */

    epiphygrd.xrt = cfrmp2xfs;
    epiphygrd.yrt = cfrmp2yfs;
    epiphygrd.zrt = cfrmp2zfs;
    epiphygrd.xft = cffall2x0;
    epiphygrd.yft = cffall2y0;
    epiphygrd.zft = cffall2z0;
    epiloggrd.xrt = epiloggrd.yrt = epiloggrd.zrt = IMax(3,cfrmp2xfs,cfrmp2yfs,cfrmp2zfs);
    epiloggrd.xft = epiloggrd.yft = epiloggrd.zft = IMax(3,cffall2x0,cffall2y0,cffall2z0);

    /* MRIhc18005 */

    /* always set initnewgeo=1 since cvinit (including inittargets) is called on transition
       to scan ops page in 5.5 */
    initnewgeo = PSD_ON;
   
    /* save this for next call since oblopt set this to zero upon return */
    save_newgeo = initnewgeo;

    if (obloptimize_epi(&loggrd, &phygrd, scan_info, exist(opslquant),
                        exist(opplane), exist(opcoax), obl_method,
                        obl_debug, &initnewgeo, cfsrmode)==FAILURE) { 
        /* maybe rot matrices not set */
        epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cvinit()" );
        return FAILURE;
 
    }

    /* Obl 3in1 opt */
    initnewgeo = save_newgeo;
    if (obloptimize_epi(&orthloggrd, &orthphygrd, orth_info, 1,
                        PSD_AXIAL, 1, obl_method,
                        obl_debug, &initnewgeo, cfsrmode)==FAILURE) {
        epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cvinit()" );
        return FAILURE;
    }

    /* BJM: MRIge47073 derate non readout waveforms */
    dbdtderate(&loggrd, dbdt_debug);
    dbdtderate(&orthloggrd, dbdt_debug); /* Obl 3in1 opt */
 
    initnewgeo = save_newgeo;
    if (obloptimize_epi(&epiloggrd, &epiphygrd, scan_info, exist(opslquant),
                        exist(opplane), exist(opcoax), obl_method,
                        obl_debug, &initnewgeo, cfsrmode)==FAILURE) { 
        /* maybe rot matrices not set */
        epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cvinit()" );
        return FAILURE;

    }    

    cvmod(pw_wgxdl, 0, 1s, 4, "Diffgrad end to RF2 start delay,us.",0," ");
    cvmod(pw_wgxdr, 0, 1s, 4, "RF2 end to diffgrad start delay,us.",0," ");
  
    if (use_myscan==1) myscan();

    /* spsp FL90mc or GR30l for excitation, and se1b4 for 
       refocussing */
    cyc_rf1 = 1;
    cyc_rf2 = 1;
  
    if(exist(opdiffuse) == PSD_ON)
        sp_sattype = 2;
    else
        sp_sattype = 0;

    switch( sp_sattype )
    {
        case 1:
        case 2:
            vrgsat = 3;
            satgap_opt_flag = PSD_OFF;
            break;
        default:
            vrgsat = 2;
            satgap_opt_flag = PSD_ON;
            break;
    }
    
    if (SpSatInit(vrgsat) == FAILURE) return FAILURE;

    if (PSD_ON == exist(opdiffuse))
    {
        piuset |= use5;
        opuser5 = 1.0;
        cvmod(opuser5, 0.0, 1.0, 1.0, "Recon Type (0=Zero Filling, 1=Homodyne)",0," ");

        if (existcv(opuser5) && ((exist(opuser5) > 1) || (exist(opuser5) < 0) || (!floatIsInteger(exist(opuser5)))))
        {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser5.descr );
            return FAILURE;
        }

        /* HCSDM00398133 HCSDM00419770 */
        /* Moved setting CV8 to setUserCVs() */

        if (tensor_flag)
        {
            /* Add user CV for tensor filename. Research can use >99. */
            if ((PSD_ON == exist(opresearch)) && (isRioSystem() || isDVSystem()))
            {
                piuset |= use11;
                cvmod(opuser11,0,TENSOR_FILE_RSRCH_MAX,0, "Tensor filename = tensor[n].dat (research use >99)",0," ");
                opuser11 = _opuser11.defval;
                if (!floatIsInteger(exist(opuser11)))
                {
                    /* Check user-defined opuser11 is an integer */
                    epic_error( use_ermes, "User CV 11 is out of range (has to be an a rounded float)", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1),STRING_ARG, _opuser11.descr);
                    return FAILURE;
                }
                rhtensor_file_number = opuser11;

		/* granty edit for full time diffusion encoding */
                piuset |= use20;
                cvmod(opuser20,0,1,0, "full time diffusion encoding",0," ");
                opuser20 = _opuser20.defval;
                /* if (ceilf(exist(opuser11)) != exist(opuser11)) */
                if (!floatIsInteger(exist(opuser11))) /* comment by dai */
                {
                    /* Check user-defined opuser11 is an integer */
                    epic_error( use_ermes, "User CV 20 is out of range (has to 0 or 1)", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1),STRING_ARG, _opuser20.descr);
                    return FAILURE;
                }
                ftde_flag = opuser20;

            }
            else
            {
                piuset &= ~use11;
                cvmod( opuser11, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 11", 0, "" );
                cvoverride(opuser11, _opuser11.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
                rhtensor_file_number = 0;
            }
        }
        else
        {
            piuset &= ~use11;
            cvmod( opuser11, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 11", 0, "" );
            cvoverride(opuser11, _opuser11.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            rhtensor_file_number = 0;
        }

        if(!isRioSystem())
        {
            piuset |= use17;
            opuser17 = 1.0;
            cvmod(opuser17, 0.0, 1.0, 1.0, "Integrated Reference Scan (1=on, 0=off)", 0 ," ");
            cvoverride(refless_option, (int)opuser17, PSD_FIX_OFF, PSD_EXIST_ON);

            if (existcv(opuser17) && ((exist(opuser17) > 1) || (exist(opuser17) < 0) || (!floatIsInteger(exist(opuser17)))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser17.descr );
                return FAILURE;
            }
        }
        else
        {
            refless_option = 1;
        }

        /* HCSDM00398133 HCSDM00419770 */
        /* Moved setting CV18 to setUserCVs() */
        {
            int rtnval;
            rtnval = setUserCVs();
            if(rtnval != SUCCESS)
            {
                return rtnval;
            }
        }

        piuset |= use9;
        opuser9 = 0.0;
        cvmod(opuser9, 0.0, 2.0, 0.0, "Shim Volume Mode (0=Default, 1=Breast)", 0, " ");

        if ((exist(opuser9) > 0.51) || (exist(opuser9) < 0.49))
        {
            if (existcv(opuser9) && ((exist(opuser9) > 2) || (exist(opuser9) < 0) || (!floatIsInteger(exist(opuser9)))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser9.descr );
                return FAILURE;
            }

            /* Method 0: Slice Mode CFH + localized Shim */
            /* Method 1: Shim volume Mode CFH + localized shim, on 3T
             * use STEAM instead of PRESS */

            global_shim_method = PSD_OFF;

            if ((1 <= (int)exist(opuser9)) && (int)(oppscvquant))
            {
                if (B0_30000 == cffield)
                {
                    cfh_steam_flag = PSD_ON;
                }
                else
                {
                    cfh_steam_flag = PSD_OFF;
                }
                presscfh_override = 3; /* shim volume mode CFH */
            }
            else
            {
                cfh_steam_flag = PSD_OFF;
                presscfh_override = PSD_OFF; /* set to default: slice mode CFH */
            }
        }
        else
        {
            /* Method 2: opuser9 = 0.5 -- Shim volume Mode CFH + Global Shim */
            global_shim_method = PSD_ON;
            if ((int)(oppscvquant))
            {
                cfh_steam_flag = PSD_ON;
                presscfh_override = 3;
            }
            else
            {
                cfh_steam_flag = PSD_OFF;
                presscfh_override = PSD_OFF;
            }
        }

        if ( mux_flag && use_slice_fov_shift_blips )
        {
            slice_fov_shift = exist(opaccel_mb_stride)*(INT)ceil(exist(opaccel_ph_stride));
        }
        else
        {
            slice_fov_shift = 1;
        }

        /* SVBranch: HCSDM00339822 */
        if((!isValueSystem()) 
           && (!isRioSystem()) && (!isDVSystem()) && (!(isKizunaSystem()&&(B0_30000==cffield))))
        {
            piuset |= use16;
            opuser16 = 0.0;
            cvmod(opuser16, 0.0, 1.0, 0.0, "Legacy Phase Correction (1=on, 0=off)",0," ");

            if (existcv(opuser16) && ((exist(opuser16) > 1) || (exist(opuser16) < 0) || (!floatIsInteger(exist(opuser16)))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser16.descr );
                return FAILURE;
            }

            if ((int)exist(opuser16) == 0)
            {
                pc_enh = PSD_ON;
            }
            else
            {
                pc_enh = PSD_OFF;
            }
            hopc_flag = PSD_OFF;
        }
        else if(isRioSystem() || isDVSystem() || (isKizunaSystem()&&(B0_30000==cffield)))
        {
            pc_enh = PSD_ON;
            if((!isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_HEAD)) && opanatomy)
            {
                hopc_flag = PSD_ON;
            }
            else
            {
                hopc_flag = PSD_OFF;
            }
        }
        else
        {
            pc_enh = PSD_OFF;
            hopc_flag = PSD_OFF;
        } 

        /***SVBranch: HCSDM00259122 -  For FOCUS Type I pulse ***/
        if (FAILURE == type1_control())
        {
            return FAILURE;
        }

        /* HCSDM00272549: type1 pulse control CV is set invisible to non-FOCUS case; */
        /* HCSDM00522509: Starter use the walk-saturation as default, and make CV21 invisible */
        if ( (PSD_ON == type1_support) && (rfov_flag) && (!isStarterSystem()) )
        {
            piuset |= use21;
            opuser21 = 1;
            cvmod(opuser21, 0, 1, 1, "Homogeneity: 1 = ON, 0 = OFF", 0, " ");

            if (existcv(opuser21) && ((exist(opuser21) > 1) || (exist(opuser21) < 0) || (!floatIsInteger(exist(opuser21)))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser21.descr );
                return FAILURE;
            }
            if ((int)exist(opuser21) == 1)
            {
                homogeneity_flag = PSD_ON;
            }
            else
            {
                homogeneity_flag = PSD_OFF;
            }
        }
        else
        {
            piuset &= ~use21;
            cvmod( opuser21, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 21", 0, ""  );
            cvoverride(opuser21, _opuser21.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            homogeneity_flag = PSD_OFF;
            if(isStarterSystem())
            {
                homogeneity_flag = PSD_ON;
            }
        }

        /* HCSDM00272549: eco-MPG control CV is set invisible to non-diffusion case; */
        if ( (PSD_ON == eco_mpg_support) && (PSD_ON == exist(opdiffuse)) && existcv(opdiffuse) )
        {
            piuset |= use1;
            opuser1  = 1;
            cvmod(opuser1, 0, 1, 1, "ECO-MPG (0=OFF, 1=ON)", 0, "");

            if (existcv(opuser1) && ((exist(opuser1) > 1) || (exist(opuser1) < 0) || (!floatIsInteger(exist(opuser1)))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser1.descr );
                return FAILURE;
            }
            /* turn on ECO-MPG */
            if ( PSD_ON == (int)exist(opuser1) )
            {
                eco_mpg_flag = PSD_ON;
            }
            else
            {
                eco_mpg_flag = PSD_OFF;
            }
        }
        else
        {
            piuset &= ~use1;
            cvmod( opuser1, -MAXFLOAT, MAXFLOAT, 1.0, "User CV variable 1", 0, "" );
            cvoverride(opuser1, _opuser1.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            eco_mpg_flag = PSD_OFF;
        }
    }
    else
    {
        piuset &= ~use5;
        piuset &= ~use9;
        piuset &= ~use11;
        piuset &= ~use16;
        piuset &= ~use17;
        cvmod( opuser5, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 5", 0, "" );
        cvoverride(opuser5, _opuser5.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser9, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 9", 0, "" );
        cvoverride(opuser9, _opuser9.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser11, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 11", 0, "" );
        cvoverride(opuser11, _opuser11.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser16, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 16", 0, "" );
        cvoverride(opuser16, _opuser16.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser17, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 17", 0, "" );
        cvoverride(opuser17, _opuser17.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        global_shim_method = PSD_OFF;
        presscfh_override = PSD_OFF;
        cfh_steam_flag = PSD_OFF;
        cvoverride(refless_option, PSD_OFF, PSD_FIX_OFF, PSD_EXIST_ON);
        pc_enh = PSD_OFF;
        hopc_flag = PSD_OFF;
    }

    /* we add ref_in_scan_flag because potentially more refless options can be added
       and multiple ones would correspond to ref in scan */
    ref_in_scan_flag = refless_option;

@inline ChemSat.e ChemSatInit
@inline Prescan.e PScvinit
@inline Muse.e MuseCVInit
      
#include "cvinit.in"

    pw_sspshift = 400;   /* pulse with of spring for sspwait */
    a_rfcssat = .50;
    
    gscale_rf2 = 0.9;

    /* ****************************************************
       Advisory Panel 
       
       If piadvise is 1, the advisory panel is supported.
       pimax and pimin are bitmaps that describe which
       advisory panel routines are supported by the psd.
       Scan Rx will activate cardiac gating advisory panel
       values if gating is chosen from the gating screen onward.
       Scan Rx will display the minte2 and maxte2 values 
       if 2 echos are chosen.
       
       Constants for the bitmaps are defined in epic.h
       *********************************************** */
    piadvise = 1; /* Advisory Panel Supported */
    
    /* bit mask for minimum adv. panel values.
     * Scan Rx will remove TE2 entry automatically if 
     * 1 or 4 echos selected. */
    piadvmin = (1<<PSD_ADVECHO) +
        (1<<PSD_ADVTE) + (1<<PSD_ADVTR) +	(1<<PSD_ADVFOV);
    piadvmax = (1<<PSD_ADVECHO) +
        (1<<PSD_ADVTE) + (1<<PSD_ADVTR) +	(1<<PSD_ADVFOV);
  
    /* bit mask for cardiac adv. panel values */
    piadvcard = (1<<PSD_ADVISEQDELAY)
        + (1<<PSD_ADVMAXPHASES) + (1<<PSD_ADVEFFTR) + (1<<PSD_ADVMAXSCANLOCS)
        + (1<<PSD_ADVAVAILIMGTIME);
  
    /* bit mask for scan time adv. panel values */
    piadvtime = (1<<PSD_ADVMINTSCAN) + (1<<PSD_ADVMAXLOCSPERACQ) +
        (1<<PSD_ADVMINACQS) + (1<<PSD_ADVMAXYRES);
  
    /* THE FOLLOWING CODE HAS BEEN REORGANIZED TO FOLLOW */
    /* THE LX INTERFACE LAYOUT - Search on UI to view each section*/
    cvdef(opplane, PSD_AXIAL);
    opplane = PSD_AXIAL;

    /***** ECHO UI Button Control *******/
    /* Epi2 -> Single echo Only */
    piechnub  = 0;
    opnecho = 1;
    avminnecho =1;
    avmaxnecho =1;
    
    cvmax(opetl, MAXINT);

	if (muse_flag == PSD_OFF){
            cvdef(opnshots, 1);
            cvmin(opnshots, 1);
            opnshots = 1;
	}

    /**** Number of SHOTS ******/
    if ((opdiffuse == PSD_ON) || (tensor_flag == PSD_ON)){
        if (muse_flag) {
@inline Muse.e MuseCVInitNumberOfShots
        }
        else 
        {	
            min_nshots = 1;
            max_nshots = 1;
            pishotnub = 2;
            pishotval2 = 1;
        }
    }
    else {
        pishotnub = 63;   /* display "other" + 5 shot buttons (bitmask) */
        pishotval2 = 1;
        pishotval3 = 2;
        pishotval4 = 4;
        pishotval5 = 8;
        pishotval6 = 16;
    }

    /***** TE UI Button Control *********/
    /* te button bitmask:
       1       2          4       8 16 32
       other, automin, autominfull, x, x, x */
    /*  For diffusion MIN TE only */
    if( (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON) ) {
        pite1nub = 63;
        cvdef(opautote,PSD_MINTE);
    } else {
        pite1nub = 63;
    }
    pite1val2 = PSD_MINIMUMTE;    /* 2nd button is autominte */
    pite1val3 = PSD_MINFULLTE;    /* 3rd button is autominte full */
    pitetype = PSD_LABEL_TE_EFF;  /* label te buttons as
                                     "Effective Echo Time" */
    /* Displayed TE Values */
    if (exist(oppseq) == PSD_SE) {

        if ((exist(opdiffuse) == PSD_ON) || (tensor_flag == PSD_ON))
        {
            int min_te1val = (int)ceilf((float)avminte/10ms)*10ms;

            if (avmintefull > min_te1val + 20ms)
            {
                pite1val3 = min_te1val;
                pite1val4 = min_te1val + 10ms;
                pite1val5 = min_te1val + 20ms;
                pite1val6 = PSD_MINFULLTE;
            }
            else if (avmintefull > min_te1val + 10ms)
            {
                pite1val3 = min_te1val;
                pite1val4 = min_te1val + 5ms;
                pite1val5 = min_te1val + 10ms;
                pite1val6 = PSD_MINFULLTE;
            }
            else
            {
                pite1val3 = PSD_MINFULLTE;
                pite1val4 = min_te1val;
                pite1val5 = min_te1val + 10ms;
                pite1val6 = min_te1val + 20ms;
            }
        }
        else
        {
            pite1val4 = 20ms;
            pite1val5 = 60ms;
            pite1val6 = 100ms;
        }

        /* No flip angle on UI for SE */
        pifanub = 0;
        acq_type = TYPSPIN;
    } else {
        pite1val4 = 20ms;
        pite1val5 = 30ms;
        pite1val6 = 40ms;

        /* GRE: flip angle buttons */
        pifanub = 6;
        pifaval2 = 10;
        pifaval3 = 20;
        pifaval4 = 30;
        pifaval5 = 60;
        pifaval6 = 90;
        acq_type = TYPGRAD;
    }

  
    /* Reasonable TE Defaults */
    cvdef(opte, 175ms);
    opte = 175ms;
    
    /* UI Fields TR & TI (FLAIR) */
    if (epi_flair == PSD_ON) {
        
        pitinub = 2;
        pitrnub = 2;
        
        if(cffield==B0_15000) {
            pitival2 = 2200ms;
            pitrval2 = 10000ms;
        } else if (cffield==B0_10000) {
            pitival2 = 2000ms;
            pitrval2 = 8000ms;
        } else if(cffield==B0_5000) {
            pitival2 = 1800ms; 
            pitrval2 = 6800ms;
        }
        else if (cffield == B0_40000) {
            pitival2 = 2200ms;
            pitrval2 = 10000ms;
            DEBUG_4_0(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_30000) {
            pitival2 = 2200ms;
            pitrval2 = 10000ms;
            DEBUG_3_0(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_7000) {
            pitival2 = 1800ms; 
            pitrval2 = 6800ms;
            DEBUG_0_7(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_2000) {
            SDL_PrintFStrengthWarning(SD_PSD_EPI2,cffield,__FILE__,__LINE__);
        }
        else {
            SDL_PrintFStrengthWarning(SD_PSD_EPI2,cffield,__FILE__,__LINE__);
        }

        opautoti = PSD_OFF;

        avminti=FLAIR_MIN_TI;
        avmaxti=FLAIR_MAX_TI;
        avmintr=FLAIR_MIN_TR;
        
        cvmin(opti,FLAIR_MIN_TI);
        cvmax(opti,FLAIR_MAX_TI);
        cvmin(optr,FLAIR_MIN_TR);
        
        cvdef(opti,1.5s);
    } else {

        /* TR field */
        pitrnub=6;
        pitrval2 = 2s;
        pitrval3 = 4s;
        pitrval4 = 6s;
        pitrval5 = 8s;
        pitrval6 = 10s;
 
        avmintr=TR_MIN;
        cvmin(optr,TR_MIN);
        cvmin(opti,TI_MIN);

        /* irprep_support */
        if(irprep_flag == PSD_ON)
        {
            /* Activate advisory panel checks for TI */
            piadvmin = (piadvmin | (1<<PSD_ADVTI));
            piadvmax = (piadvmax | (1<<PSD_ADVTI));

            pitinub = 5;

            if(cffield == B0_15000)
            {
                pitival2 = 160ms;
                pitival3 = 170ms;
                pitival4 = 180ms;
                pitival5 = 190ms;
            }
            else
            {
                pitival2 = 220ms;
                pitival3 = 230ms;
                pitival4 = 240ms;
                pitival5 = 250ms;
            }

            if ((PSD_ON == t1flair_flag) || (PSD_ON == ir_prep_manual_tr_mode))
            {
                /* turn on Auto TI for t1flair interleaved STIR */
                piautoti = PSD_ON;
            }
            else
            {
                piautoti = PSD_OFF;
            }

            avmaxti = EPI_STIR_TI_MAX;
            cvmax(opti,EPI_STIR_TI_MAX);
        }
        else if(PSD_ON == exist(opspecir))
        {
            init_ASPIR_TI();
        }
        else
        {
          /* turn off TI field, flair = 0 */
          pitinub=0;
          piautoti = PSD_OFF;
          avmaxti = TI_MAX;
          cvmax(opti,TI_MAX);
        }
    }

    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e AutoAdjustTRInit

    if((exist(opflair) == PSD_ON) || ((PSD_ON == aspir_flag) && (PSD_ON == exist(opautoti))))
    {
        piautotrmode = PSD_AUTO_TR_MODE_MANUAL_TR;
    }

    /* Set min/maxTR for In-Range TR */
    if(PSD_ON == irprep_flag)
    {
        piinrangetrmin = 2500ms;
    }
    else
    {
        piinrangetrmin = 2000ms;
    }

    piinrangetrmax = TR_MAX_EPI2;
 
    /* Use a large default value for tr */
    cvmax(optr,TR_MAX_EPI2);
    cvdef(optr, 10s);

    /* RBW UI Choices */
    pircb2nub = 0;    /* turn off 2nd echo rbw buttons */
     
    /* MGD: +/- 250 Digital */
    cvdef(oprbw, 62.5);
    oprbw = 62.5;
   
    pidefrbw = 62.5;
    pircbnub = 5;
    pircbval2 = 250.0;
    pircbval3 = 166.6;
    pircbval4 = 125.0;
    pircbval5 = 62.5;
    
    /* FOV UI Buttons */
    pifovnub = 6;
    pifovval2 = 240;
    pifovval3 = 260;
    pifovval4 = 280;
    pifovval5 = 320;
    pifovval6 = 360;

    /* Xres & Yres UI Options */
    if (muse_flag==PSD_OFF)
    {
        oprect = 0;
        cvmin(opxres, 64);
        cvmax(opxres, 256);
        cvdef(opxres, 64);
        opxres = 64;

        cvmin(opyres,32);
        cvmax(opyres,256);
        cvdef(opyres, 64);
        opyres = 64;
  
        pixresnub = 15; /* bitmask */
        pixresval2 = 64;
        pixresval3 = 128;
        pixresval4 = 256;

        piyresnub = 63;
        piyresval2 = 32;
        piyresval3 = 64;
        piyresval4 = 128;
        piyresval5 = 192;
        piyresval6 = 256;             /* MRIge52734 - lockout 512 yres. */
    }
    else
    {
@inline Muse.e MuseCVInitXYResUIOptions
    }
      
    /* The following are the restrictions for SR20 systems */
    if (( cfsrmode == PSD_SR20 ) || ( cfsrmode == PSD_SR25 ))   /* HOUP */
    {
        pifovnub = 2;
        pifovval2 = 360;
        avminfov = 360;
        avmaxfov = 360;
        
        pistnub = 4;
        pistval2 = 5;
        pistval3 = 7;
        pistval4 = 10;
        avminslthick = 5;
        
        pixresnub = 7;
        pixresval2 = 96;
        pixresval3 = 128;
        cvmin(opxres,96);
        cvmax(opxres,128);
        cvdef(opxres,128);
        opxres=128;
        
        piyresnub = 2;
        piyresval2 = 128;
        cvmin(opyres,128);
        cvmax(opyres,128);
        cvdef(opyres, 128);
        opyres = 128;
    }
    
    /* Ramp Sampled DW & Flair at SR50 & SR77 protocol limits */
    if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON) )
    {
        pifovnub = 6;
        pifovval2 = 240;
        pifovval3 = 280;
        pifovval4 = 320;
        pifovval5 = 360;
        pifovval6 = 400;
        avminfov = 240;
        if(cfsrmode == PSD_SR77)
        {
            avmaxfov = 600;
        }
        else
        {
            avmaxfov = 400;    
        }

        if ( cfsrmode == PSD_SR50 ) {
            pixresnub = 63;
            pixresval2 = 96;
            pixresval3 = 128;
            pixresval4 = 160;
            pixresval5 = 192;
            pixresval6 = 256;
            cvmin(opxres,96);
            cvmax(opxres,256);
            cvdef(opxres,128);
            opxres=128;
        }
        else
        {
            pixresnub = 63;
            pixresval2 = 128;
            pixresval3 = 160;
            pixresval4 = 192;
            pixresval5 = 224;
            pixresval6 = 256;
            cvmin(opxres,128);
            cvmax(opxres,256);
            cvdef(opxres,128);
            opxres=128;
        }
        
        piyresnub = 15;
        piyresval2 = 128;
        piyresval3 = 192;
        piyresval4 = 256;
        cvmin(opyres,128);
        cvmax(opyres,256);           /* MRIge52734 - max yres = 256 */
        cvdef(opyres, 128);
        opyres = 128;
    }
    

    /* MRIge51174 - Check typein EZDWI, PH */
    if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (EZflag == PSD_ON) )
    {  
        pifovnub = 2;
        pifovval2 = 360;
        avminfov = 360;
        avmaxfov = 360;

        pistnub = 4;
        pistval2 = 5;
        pistval3 = 7;
        pistval4 = 10;
        avminslthick = 5;

        if ( cfsrmode == PSD_SR50 )
        {
            pixresnub = 7;
            pixresval2 = 96;
            pixresval3 = 128;
            cvmin(opxres,96);
            cvmax(opxres,128);
            cvdef(opxres,128);
            opxres=128;
        }
        else
        {
            pixresnub = 3;
            pixresval2 = 128;
            cvmin(opxres,128);
            cvmax(opxres,128);
            cvdef(opxres,128);
            opxres=128;
        }

        piyresnub = 2;
        piyresval2 = 128;
        cvmin(opyres,128);
        cvmax(opyres,128);
        cvdef(opyres, 128);
        opyres = 128;
    }
    
    if ((cfsrmode == PSD_SR20) || (cfsrmode == PSD_SR25)) {
        cvdef(opslthick, 10.0); 
        opslthick = 5.0; 
    }
    else
    {
        cvdef(opslthick, 10.0);
        opslthick = 10.0;
    }

    if (PSD_SR200 == cfsrmode) 
    { 
        if (ss_rf1 == PSD_ON)
        {
            pistnub = 6; 
            pistval2 = 4; 
            pistval3 = 5; 
            pistval4 = 6; 
            pistval5 = 7; 
            pistval6 = 10; 
        }
        else
        {
            pistnub = 6; 
            pistval2 = 2; 
            pistval3 = 3; 
            pistval4 = 4; 
            pistval5 = 7; 
            pistval6 = 10; 
        }
    }

    cvmax(rhfrsize, 8192);
    cvmax(rhdaxres, 8192);
    
    if (rfov_flag)
    {
        cvmin(opfov, FMax(2, (float)FOV_MIN, (float)(MIN_RFOV/exist(opphasefov))));      /*HCSDM00388767*/
    }
    else
    {
        cvmin(opfov, FOV_MIN);
    }

    cvmax(opfov, FOV_MAX_EPI2);
    cvdef(opfov, FOV_MAX_EPI2);
    opfov = FOV_MAX_EPI2;

    /* RTG */
    if(exist(opcgate)==PSD_ON || exist(oprtcgate)==PSD_ON || navtrig_flag==PSD_ON || rfov_flag==PSD_ON || mux_flag == PSD_ON)
    {
        piisil = 0;
    } else {
        piisil = 1;
    }
    
    /* multi-phase CVs */
    cvmax(opmph,1);
    cvdef(opmph,0); /* default to MPH off */
    cvdef(opacqo,0);  /* default to interleaved */
    cvdef(opfphases, PHASES_MIN);
    cvmin(opsldelay, -MAXINT); /* YMSmr07177 */
    cvmax(opsldelay,  MAXINT); /* YMSmr07177 */
    cvdef(opsldelay, 1us);
    opsldelay = 1us;
    opautosldelay = 1;

    /* init epigradopt output structure to point to appropriate CVs */
    gradout.agxw = &a_gxw;
    gradout.pwgxw = &pw_gxw;
    gradout.pwgxwa = &pw_gxwad;
    gradout.agyb = &a_gyb;
    gradout.pwgyb = &pw_gyb;
    gradout.pwgyba = &pw_gyba;
    gradout.agzb = &a_gzb;
    gradout.pwgzb = &pw_gzb;
    gradout.pwgzba = &pw_gzba;
    gradout.frsize = &temprhfrsize;
    gradout.pwsamp = &samp_period;
    gradout.pwxgap = &pw_gxgap;
    
    /* Turn off EP_TRAIN macro elements we don't want */
    pw_gxcla = 0;
    pw_gxcl = 0;
    pw_gxcld = 0;
    a_gxcl = 0;
    pw_gxwl = 0;
    pw_gxwr = 0;
    pw_gxgap = 0;
    pw_gxcra = 0;
    pw_gxcr = 0;
    pw_gxcrd = 0;
    a_gxcr = .0;
  
    /* Enable only the prescan autoshim button and default on, 
     * always keep phase correction on and grey it out */
    pipscoptnub = 1;
    pipscdef = 3;
    _opphcor.fixedflag = PSD_OFF;
    opphcor = PSD_ON;
    cvdef(opphcor, PSD_ON);
    _opphcor.fixedflag = PSD_ON;
    _opphcor.existflag = PSD_ON;
  
    /* OPUSER CV PAGE control */       
    /* Turn on page */      
    pititle = 1;
    cvdesc(pititle, "EPI II Feature Controls:");

    /* Only 30 characters per CV are displayed on user CV screen, thats it!
       "123456789012345678901234567890" */

    /* Show ramp Sampling Option */
    piuset |= use0;
    opuser0 = 1.0;
    cvmod(opuser0, 0.0, 1.0, 1.0, "Ramp Sampling (1=on, 0=off)",0," ");

    /* MRIge59852: opuser0 range check */
    /* MRIge71092 */
    if( existcv(opuser0) && ((exist(opuser0) > 1) || (exist(opuser0) < 0) || (!floatIsInteger(exist(opuser0))))) 
    {
        epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser0.descr );
        return FAILURE;
    }

    /* HCSDM00398133 HCSDM00419770 */
    /* Moved setting CV6 to setUserCVs() */

    /* t1flair_stir */
    if ( ( status_flag = T1flairInit() ) != SUCCESS )
    {
        return status_flag;
    }

    /************************************************************************/
    /*	Init some diffusion  variables					*/
    /************************************************************************/
    pidifrecnub=1;

    if(exist(opdiffuse)==PSD_ON) {
        pidifpage=1; 	/* turn on diffusion page */
    } else {
        pidifpage=0;
    }
    
    num_dif=0;
    acqmode=0;	/* default acmode to 0 */
    
    /************************************************************************/
    
    /* Needed for blipcorr() */ 
    cvxfull = cfxfull;
    cvyfull = cfyfull;
    cvzfull = cfzfull;
    

    /* Phase of refocussing pulse shifted by pi/2 relative to alpha pulse
       to compensate for B1 impefections. pi/2 is 0.25 of a cycle. */
    rf1_phase = 0.25;
    rf2_phase = 0.0;

    if (FAILURE == Monitor_Cvinit(rfpulse))
    {
        epic_error(use_ermes,supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "Monitor_Cvinit");
        return FAILURE;
    }

    if (FAILURE == Multiband_cvinit())
    {
        epic_error(use_ermes,supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "Multiband_cvinit");
        return FAILURE;
    }

    /* Check for Cal files */
    status_flag = epiCalFileCVInit(); 
    if(status_flag != SUCCESS) return status_flag;

    if( (PSD_OFF == pircbnub) && (PSD_OFF == exist(opautorbw)) )
    {
        opautorbw = PSD_ON;
    }


    if((!isRioSystem()) && (exist(opdiffuse) == PSD_ON) && (exist(opdfaxall) > PSD_OFF) && (edwi_status == PSD_ON))
    {
       /* Show gradopt_diffall Option */
       piuset |= use7;
       opuser7 = 0.0;
       cvmod(opuser7, 0.0, 1.0, 0.0, "Gradient Optimization for Diffusion ALL (1=on, 0=off)",0," ");

       if( existcv(opuser7) && ((exist(opuser7) > 1) || (exist(opuser7) < 0) || (!floatIsInteger(exist(opuser7))))) 
       {
            epic_error( use_ermes, "%s must be set to either 0 or 1.", EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, _opuser7.descr );
            return FAILURE;
       }
       if( floatsAlmostEqualEpsilons(exist(opuser7), 1.0, 2) && (opsavedf != 1))
       {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Recon All Images", STRING_ARG, "Gradient Optimization" );
            return FAILURE;
       }
       gradopt_diffall = (int)exist(opuser7);
    }
    else
    {
       piuset &= ~use7;
       cvoverride(opuser7, 0.0, PSD_FIX_ON, PSD_EXIST_ON);
       gradopt_diffall = PSD_OFF;
    }

    if( (cfgcoiltype == PSD_XRMB_COIL || cfgcoiltype == PSD_XRMW_COIL || cfgcoiltype == PSD_VRMW_COIL || isRioSystem())  ||
        (opweight > 150 && cffield >= B0_30000 && getTxCoilType() == TX_COIL_BODY &&
         cfgcoiltype == PSD_TRM_COIL) )
    {
       if (ss_rf1 == PSD_ON)
       {
           ss_fa_scaling_flag = PSD_ON;
       }
       else
       {
           ss_fa_scaling_flag = PSD_OFF;
       }

       if (ir_on == PSD_ON && opweight > 150 && cffield >= B0_30000 &&
           getTxCoilType() == TX_COIL_BODY && cfgcoiltype == PSD_TRM_COIL)
       {
           ir_fa_scaling_flag = PSD_ON;
       }
       else
       {
           ir_fa_scaling_flag = PSD_OFF;
       }
    }
    else
    {
        ss_fa_scaling_flag = PSD_OFF;
        ir_fa_scaling_flag = PSD_OFF;
    }

    /* enable Fixed RG feature */
    rgfeature_enable = PSD_ON;
 
    /* Reversed Phase Encoding polarity is applied for the following conditions
     * 1) using type-in PSD: epi2alt no matter it is regular DWI or Multiband DWI
     * 2) for Multiband DWI, reversed PE polarity is always used unless it is a type-in PSD: epi2altoff */
    if( (!strcmp(get_psd_name(), "epi2alt")) || ((PSD_ON == mux_flag) && strcmp(get_psd_name(), "epi2altoff")) )
    {
        pepolar = PSD_ON;
    }
    else
    {
        pepolar = PSD_OFF;
    }
    
    /* HCSDM00453434 reset rhdistcorr_ctrl so that cvcheck later is effective. */
    rhdistcorr_ctrl = 0;

    if (PSD_ON == exist(opdiffuse))
    {
        if ((PSD_ON == distcorr_status) && /* option key and HW check */
            (PSD_OFF == rfov_flag) && ((asset_factor/(float)(opnshots))<=0.5)) /* PSD options check */
        {
            pidistcorrnub = 2; /* Controls show/hide */
        }
        else
        {
            pidistcorrnub = 0; /* Controls show/hide */
        }
    }
    else
    {
        pidistcorrnub = 0;
    }

    /* turn on opcalrequired CV for ASSET, Multiband and MUSE scan */
    if ( (existcv(opasset) && (PSD_ON == exist(opassetscan))) || (existcv(opmb) && (PSD_ON == exist(opmb)) && (cfaccel_ph_maxstride*cfaccel_sl_maxstride > 1)) || muse_flag ) 
    {
        cvoverride(opcalrequired, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        override_opcalrequired = PSD_ON;
    }
    else
    {
        /* set opcalrequired value in loadrheader.e */
        override_opcalrequired = PSD_OFF;
    }

    if(existcv(opblim) && (PSD_ON == exist(opblim)))
    {
        if(mux_flag)
        {
            ssgr_flag = PSD_OFF;
            ssgr_mux = PSD_ON;
        }
        else
        {
            ssgr_flag = PSD_ON;
            ssgr_mux = PSD_OFF;
        }
    }
    else
    {
        ssgr_flag = PSD_OFF;
        ssgr_mux = PSD_OFF;
    }

    if (rfov_flag && (cffield >= B0_30000) &&
        (isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_NECK) ||
         isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_SPINE)))
    {
        focus_B0_robust_mode = PSD_ON;
    }
    else
    {
        focus_B0_robust_mode = PSD_OFF;
    }

    /* Set flags for scan volume scale */
    set_vol_scale_cvs(cfgcoiltype,
                      VOL_SCALE_FREQ_DIR_ALLOWED | VOL_SCALE_PHASE_DIR_ALLOWED,
                      VOL_SCALE_CONSTRAINT_NONE,
                      &vol_scale_type,
                      &vol_scale_constraint_type);

    return SUCCESS;
    
}   /* end cvinit() */

@inline DTI.e DTI_Init
@inline SpSat.e SpSatInit
@inline SpSat.e SpSatCheck
@inline ss.e ssInit
/* 4/21/96 RJL: Init all new Advisory Cvs */
@inline InitAdvisories.e InitAdvPnlCVs
/* t1flair_stir */
@inline T1flair.e T1flairInit
@inline Monitor.e MonitorInit

@inline epi_esp_opt.e epi_esp_opt_host_functions

/**************************************************************************/
/* CVEVAL                                                                 */
/**************************************************************************/
STATUS
cveval( void )
{
    double ave_sar;
    double peak_sar; /* temp sar value locations */
    double cave_sar;
    double b1rms;

    struct stat file_status[1];
    
    float scale = 1.0; /*MRIhc05854 : 1*/

    int bval_counter = 0;
    float total_bval = 0.0;
    int valid_numbvals_forsyndwi = 0;

    /*RTB0 correction*/
    int pack_ix;

    /* HCSDM00398133 HCSDM00419770 */
    {
        int rtnval;
        rtnval = setUserCVs();
        if(rtnval != SUCCESS)
        {
            return rtnval;
        }
    }

    if ( (PSD_ON == exist(opdiffuse)) && (FOCUS == exist(opexcitemode)) )
    {
        rfov_flag = PSD_ON;
        rf_chop = PSD_OFF;
    }
    else
    {
        rfov_flag = PSD_OFF;
        rf_chop = PSD_ON;
    }

    if ( exist(optensor) > 0 )
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

   if( (PSD_ON == focus_status) &&
        existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) &&
        (PSD_OFF == exist(opflair)) && (PSD_OFF == exist(opasset)) &&
        (opnumgroups <= 1) && (strcmp(get_psd_name(), "epi2alt")) && (mux_flag == PSD_OFF) && (muse_flag == PSD_OFF)) /*disable FOCUS for Multiband and MUSE */
    {
        /* Allow RFOV Focus DWI */
        piexcitemodenub = 1 + 4; /* 1:Selective + 4:Focus */
    }
    else
    {
        piexcitemodenub = 1;     /* Selective only */
    }


    /* Determine if HOEC is supported or not */
@inline HoecCorr.e HoecSupportMode
    /* Determine if RTB0 is supported or not */
@inline RTB0.e RTB0SupportMode

    /* HCSDM00155198 */
    if ((PSD_ON == tensor_flag) && (PSD_OFF == rfov_flag) &&
        (PSD_OFF == hoecc_support) && (PSD_OFF == muse_flag)) /* Make DSE selectable if HOECC is supported. */
    {
        cvoverride(opdualspinecho, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        pidualspinechonub = 0;
    }
    else if (PSD_ON == muse_flag)
    {
        cvoverride(opdualspinecho, PSD_OFF, PSD_FIX_OFF, PSD_EXIST_OFF);
        pidualspinechonub = 0;
    }
    else
    {
        pidualspinechonub = 1;
    }
    
    /***SVBranch: HCSDM00259119  eco mpg ***/
    if (FAILURE == eco_mpg_cveval())
    {
        epic_error(use_ermes, "ECO-MPG cveval Failed",
                   EM_PSD_SUPPORT_FAILURE, 1, STRING_ARG, "eco_mpg_cveval()");    
        return FAILURE;
    }        
    /*********************/    
    
    /* MRIhc56268: Dual Spin Echo */
    if( existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) &&
        existcv(opdualspinecho) && (PSD_ON == exist(opdualspinecho)) )
    {
        dualspinecho_flag = 1;
    }
    else
    {
        dualspinecho_flag = 0;
    }

    piseparatesynbnub = 0;
    cvoverride(opseparatesynb,1, PSD_FIX_ON, PSD_EXIST_ON);
    if(syndwi_status!=PSD_ON)
    {
        cvoverride(syndwi_flag, PSD_OFF, PSD_FIX_ON, PSD_EXIST_ON);
        cvoverride(opnumsynbvals, 0, PSD_FIX_ON, PSD_EXIST_ON);
        pinumsynbnub = 0;
    }
    else if( existcv(opdiffuse) && (PSD_ON == exist(opdiffuse)) &&
        ( (exist(opdifnumt2) > 0) || (exist(opnumbvals) > 1) ) &&
        (PSD_OFF == tensor_flag))
    {
        /* Multi b-values case (including T2 or more than 1  b-values) */
        prescribed_min_bval=1000000;
        prescribed_max_bval=0;
        valid_numbvals_forsyndwi = 0;
        for(bval_counter=0;bval_counter< exist(opnumbvals);bval_counter++){
            if(bvalstab[bval_counter] <= UPPER_SYNB_LIMIT_RESTRICT_DIFF){
                valid_numbvals_forsyndwi++;
                if (bvalstab[bval_counter] < prescribed_min_bval)
                    prescribed_min_bval=bvalstab[bval_counter];
                if (bvalstab[bval_counter] > prescribed_max_bval)
                    prescribed_max_bval=bvalstab[bval_counter];
            }
        }
        if(exist(opdifnumt2)>0){
            valid_numbvals_forsyndwi++;
            prescribed_min_bval=0.0;
        }
        prescribed_bval_range = prescribed_max_bval - prescribed_min_bval;

        if(valid_numbvals_forsyndwi > 1 && prescribed_bval_range > 0.0)
        {
            syndwi_flag = PSD_ON;
            /* Synthetic b-vals */
            pinumsynbnub = 1 + 2 + 4 + 8 + 16;
            pinumsynbval2 = 0;
            pinumsynbval3 = 1;
            pinumsynbval4 = 2;
            pinumsynbval5 = 3;
        }
        else
        {
            syndwi_flag = PSD_OFF;
            pinumsynbnub = 0;
            cvoverride(opnumsynbvals, 0, PSD_FIX_ON, PSD_EXIST_ON);
        }
    }
    else
    {
        syndwi_flag = PSD_OFF;
        pinumsynbnub = 0;
        cvoverride(opnumsynbvals, 0, PSD_FIX_ON, PSD_EXIST_ON);
    }

    avminsynbvalstab = LOWER_SYNB_LIMIT_IVIM;
    avmaxsynbvalstab = UPPER_SYNB_LIMIT_RESTRICT_DIFF;
    avminnumbvals = MIN_NUM_SYNBVALS;
    avmaxnumbvals = MAX_NUM_SYNBVALS;

    /* Initialize HOEC correction configuration */
@inline HoecCorr.e HoecEval

@inline RTB0.e RTB0Cveval

    /* HCSDM00155636: copied t1flair_flag setting from cvinit() */
    if ( !strncmp(get_psd_name(), "epi2_stircl",11) )
    {
        /* non-interleaved STIR */
        t1flair_flag = PSD_OFF;
        ir_prep_manual_tr_mode = PSD_OFF;
    }
    else
    {
        if (irprep_flag)
        {
            if ((exist(opcgate) == PSD_ON) || (exist(oprtcgate) == PSD_ON) ||
                (navtrig_flag == PSD_ON) || (exist(opirmode) == PSD_ON) ||
                (rfov_flag == PSD_ON))
            {
                t1flair_flag = PSD_OFF;
                ir_prep_manual_tr_mode = PSD_OFF;
            }
            else
            {
                /* T1flair STIR and Auto TI support only 3T at this time. */
                /* Need evaluation for 1.5T to make them compatible.      */
                if (B0_30000 == cffield)
                {
                    t1flair_flag = PSD_ON;
                    ir_prep_manual_tr_mode = PSD_OFF;
                }
                else
                {
                    /* Non 3T cases */
                    t1flair_flag = PSD_OFF;
                    ir_prep_manual_tr_mode = PSD_OFF;
                }
            }
        }
        else
        {
            t1flair_flag = PSD_OFF;
            ir_prep_manual_tr_mode = PSD_OFF;
        }
    }

    if ((t1flair_flag == PSD_ON) && (ir_prep_manual_tr_mode == PSD_ON))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE,
                   EE_ARGS(2), STRING_ARG, "T1flair mode",STRING_ARG, "Manual TR mode");
        return FAILURE;
    }

    epi_asset_override();
    epi_arc_override();

@inline Asset.e AssetEval
@inline Muse.e MuseEval
    if(mux_flag)
    {
@inline ARC.e ARCEval
    }
    epi_asset_set_dropdown();
    epi_arc_set_dropdown();

    /* DTI */
    if ( (exist(opdiffuse) == PSD_ON) && (tensor_flag == PSD_OFF) )
    {
        /* Load Diffusion Vector Matrix */
        loadDiffVecMatrix();
    }

    /* HCSDM00365336 */
    if (PSD_ON == exist(opdiffuse))
    {
        num_autotr_cveval_iter = 2;
    }
    else
    {
        num_autotr_cveval_iter = 1;
    }

    /* Obl 3in1 opt */
    if( ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF) ||
         ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON))) &&
        (exist(opplane) == PSD_OBL) && (exist(opcoax) != PSD_OFF) )
    {
        /*Turn off obl_3in1_opt on Rio due to spherical gradient model enforced*/
        if (isRioSystem())
            obl_3in1_opt = PSD_OFF;
        else
            obl_3in1_opt = PSD_ON;
    }
    else
    {
        obl_3in1_opt = PSD_OFF;
    }

    if (PSD_XRMW_COIL == cfgcoiltype)
    {
        config_update_mode = CONFIG_UPDATE_TYPE_DVW_AMP321SR120;
        inittargets(&loggrd, &phygrd); 
        inittargets(&epiloggrd, &epiphygrd); 

        /* Obl 3in1 opt */
        if (obl_3in1_opt)
        {
            inittargets(&orthloggrd, &orthphygrd);
        }

        epiphygrd.xrt = cfrmp2xfs; 
        epiphygrd.yrt = cfrmp2yfs; 
        epiphygrd.zrt = cfrmp2zfs; 
        epiphygrd.xft = cffall2x0; 
        epiphygrd.yft = cffall2y0; 
        epiphygrd.zft = cffall2z0; 
        epiloggrd.xrt = epiloggrd.yrt = epiloggrd.zrt = IMax(3,cfrmp2xfs,cfrmp2yfs,cfrmp2zfs); 
        epiloggrd.xft = epiloggrd.yft = epiloggrd.zft = IMax(3,cffall2x0,cffall2y0,cffall2z0); 
    }
    
    /* GEHmr01833, GEHmr02647 */
    if( (isSVSystem()) && (epi_flair == PSD_OFF) )
    {
        if( exist(opbval) < 300 )
        {
            cfxfd_power_limit = XFD_POWER_LIMIT_DWI_BASE;
        }
        else if( exist(opbval) < 900 )
        {
            cfxfd_power_limit = XFD_POWER_LIMIT_DWI_BASE + 0.5;
        }
        else
        {
            cfxfd_power_limit = XFD_POWER_LIMIT_DWI_BASE + 0.8;
        }

        if( PSD_ON == dualspinecho_flag )
        {
            cfxfd_power_limit += 0.5;
        }

        if( cfxfd_power_limit > XFD_POWER_LIMIT )
        {
            cfxfd_power_limit = XFD_POWER_LIMIT;
        }

        /* increase the reserved margin to avoid Under-Voltage for SV systems  -HCSDM00379157 HCSDM00394803*/
        if ((PSD_ON == opdiffuse) && (PSD_ON == tensor_flag) && (PSD_ON == dualspinecho_flag) && (PSD_ON == eco_mpg_flag))
        {
           cfxfd_power_limit = cfxfd_power_limit / dti_dse_ecoon_scaling_factor;
        }
        else if ((PSD_ON == opdiffuse) && (PSD_ON == tensor_flag) && (PSD_OFF == dualspinecho_flag) && (PSD_ON == eco_mpg_flag))
        {
           cfxfd_power_limit = cfxfd_power_limit / dti_sse_ecoon_scaling_factor;
        }
        else if ((PSD_ON == opdiffuse) && (PSD_ON == tensor_flag) && (PSD_OFF == dualspinecho_flag) && (PSD_OFF == eco_mpg_flag))
        {
           cfxfd_power_limit = cfxfd_power_limit / dti_sse_ecooff_scaling_factor;
        }
        else if ((PSD_ON == opdiffuse) && (PSD_ON == dualspinecho_flag) && (PSD_ON == eco_mpg_flag) && (opdfax3in1 > PSD_OFF ))
        {
           cfxfd_power_limit = cfxfd_power_limit / dwi_3in1_dse_ecoon_scaling_factor;
        }
        else if ((PSD_ON == opdiffuse) && ((opdfaxx > PSD_OFF) || (opdfaxy > PSD_OFF) || (opdfaxz > PSD_OFF)
                || (opdfaxall > PSD_OFF )) && (PSD_ON == dualspinecho_flag) && (PSD_ON == eco_mpg_flag))
        {
           cfxfd_power_limit = cfxfd_power_limit / dwi_single_all_dse_ecoon_scaling_factor;
        }
        else if ((PSD_ON == opdiffuse) && ((opdfaxx > PSD_OFF) || (opdfaxy > PSD_OFF) || (opdfaxz > PSD_OFF)
                || (opdfaxall > PSD_OFF )) && (PSD_OFF == dualspinecho_flag) && (PSD_ON == eco_mpg_flag))
        {
           cfxfd_power_limit = cfxfd_power_limit / dwi_single_all_sse_ecoon_scaling_factor;
        }
    }
    else
    {
        cfxfd_power_limit = XFD_POWER_LIMIT;
    }

    /* SVBranch: HCSDM00102521 */
    if( isSVSystem() )
    {
        /* xfd_power/temp_limit has fix flag, but cfxfd_power/temp_limit has no.
           below code can let cfxfd_power/temp_limit has pseudo fix flag.
           cfxfd_power/temp_limit can be updated by modifying xfd_power/temp_limit*/
        xfd_power_limit = cfxfd_power_limit;
        xfd_temp_limit  = cfxfd_temp_limit;
        cfxfd_power_limit = xfd_power_limit;
        cfxfd_temp_limit  = xfd_temp_limit;
    }

    /* Silent Mode  05/19/2005 YI */
    /* Get gradient spec for silent mode */
    getSilentSpec(exist(opsilent), &grad_spec_ctrl, &glimit, &srate);

    /* GEHmr01834, GEHmr02647 */
    if( (isSVSystem()) && (exist(opdiffuse) == PSD_ON) &&
        (!mpg_opt_flag)) /* for mpg opt, use max grad */
                         /***SVBranch: HCSDM00259119  eco mpg ***/
    {
        grad_spec_ctrl |= GMAX_CHANGE;

        if( exist(optensor) > 0 )
        {
            glimit = XFD_GMAX_DTI;
        }
        else
        {
            glimit = XFD_GMAX_DWI;
        }
    }
    else
    {
        grad_spec_ctrl &= ~GMAX_CHANGE;
        
        /***SVBranch: HCSDM00259119  eco mpg ***/
        /* start diff grad in mpg opt */
        if (mpg_opt_flag)
        {
            if( exist(optensor) > 0 )
            {
                mpg_opt_glimit_orig = XFD_GMAX_DTI;
            }
            else
            {
                mpg_opt_glimit_orig = XFD_GMAX_DWI;
            }         
        }
    }

    /* MRIhc56520: for EPI with ART on 750w. */
    if (exist(opsilent) && (cffield == B0_30000) && (cfgcoiltype == PSD_XRMW_COIL))
    {
        srate = XRMW_3T_EPI_ART_SR;
    }
    else if (exist(opsilent) && (cffield == B0_30000) && (cfgcoiltype == PSD_VRMW_COIL))
    {
        srate = VRMW_3T_EPI_ART_SR;
    }

@inline MK_GradSpec.e GspecEval

    /* Update configurable variables */
    if(set_grad_spec(grad_spec_ctrl,glimit,srate,PSD_ON,debug_grad_spec) == FAILURE)
    {
      epic_error(use_ermes,"Support routine set_grad_spec failed",
        EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"set_grad_spec");
        return FAILURE;
    }
    
    /* Skip setupConfig() if grad_spec_ctrl is turned on */
    if(grad_spec_change_flag) {
        if(grad_spec_ctrl)config_update_mode = CONFIG_UPDATE_TYPE_SKIP;
        else {
            /* MRIhc56453 supported XRMW coil case  Apr 18,2011 YI */
            if (PSD_XRMW_COIL == cfgcoiltype) config_update_mode = CONFIG_UPDATE_TYPE_DVW_AMP321SR120;
            else if(tensor_flag)config_update_mode = CONFIG_UPDATE_TYPE_TENSOR;
            else           config_update_mode = CONFIG_UPDATE_TYPE_ACGD_PLUS;
        }
        inittargets(&loggrd, &phygrd);
        inittargets(&epiloggrd, &epiphygrd);

        /* Obl 3in1 opt */
        if (obl_3in1_opt)
        {
            inittargets(&orthloggrd, &orthphygrd);
        }

        epiphygrd.xrt = cfrmp2xfs;
        epiphygrd.yrt = cfrmp2yfs;
        epiphygrd.zrt = cfrmp2zfs;
        epiphygrd.xft = cffall2x0;
        epiphygrd.yft = cffall2y0;
        epiphygrd.zft = cffall2z0;
        epiloggrd.xrt = epiloggrd.yrt = epiloggrd.zrt = IMax(3,cfrmp2xfs,cfrmp2yfs,cfrmp2zfs);
        epiloggrd.xft = epiloggrd.yft = epiloggrd.zft = IMax(3,cffall2x0,cffall2y0,cffall2z0);
    }
    /* End Silent Mode */

    if((!rfov_flag) && (!rtb0_flag) && (exist(opdiffuse) == PSD_ON) && isRioSystem())
    {
        dpc_flag = PSD_ON;
    }
    else
    {
        dpc_flag = PSD_OFF;
    }

    /* granty turn off dpc_flag by default */
    dpc_flag = PSD_OFF;

    if(dpc_flag)
    {
        iref_etl = DEFAULT_IREF_ETL;
    }
    else
    {
        iref_etl = 0;
    }

    /*RTB0 correction*/
    rtb0_comp_flag = rtb0_flag?1:0;
    rtb0_recvphase_comp_flag = rtb0_comp_flag;
    if(psd_board_type == PSDCERD || psd_board_type == PSDDVMR) 
    {
        pack_ix = PSD_XCVR2;
    }
    else 
    {
        pack_ix = 0;
    }
    rtb0_minintervalb4acq = IMax(3, DABSETUP, 
                                    XTRSETLNG + XTR_length[pack_ix] + DAB_length[pack_ix], 
                                    XTRSETLNG + XTR_length[pack_ix] - rcvr_ub_off);

    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
    /* when change from DWI to DTI, the cvinit() does not run, 
       so add below codes to initial TR popup menu */ 
    if( (epi_flair == PSD_OFF) && (piautotrmode != PSD_AUTO_TR_MODE_MANUAL_TR) )
    {
        pitrnub=6;
        pitrval2 = 2s;
        pitrval3 = 4s;
        pitrval4 = 6s;
        pitrval5 = 8s;
        pitrval6 = 10s;
        tr_acq_val2 = pitrval2;
        tr_acq_val3 = pitrval3;
        tr_acq_val4 = pitrval4;
    }

@inline AutoAdjustTR.e AutoAdjustTREval

    if( (piautotrmode != PSD_AUTO_TR_MODE_MANUAL_TR) && ( (PSD_ON == tensor_flag) || (PSD_ON == mux_flag) || (PSD_ON == muse_flag) ) )
    {
        cvmax(optracq, 1);
    }
    else
    {
        cvmax(optracq,1000);
    }

    /* 4/21/96 RJL: Init all new Advisory Cvs from InitAdvisories.e */
    InitAdvPnlCVs();
    
    /* HCSDM00232516 */
    if ((existcv(oprtcgate) && (oprtcgate == PSD_ON)) || (navtrig_flag == PSD_ON) ||
        (existcv(opcgate) && (opcgate == PSD_ON)))
    {
        avmaxtr = _act_tr.maxval;
        cvmax(optr, avmaxtr);
        cvmax(ihtr, avmaxtr);
    }
    else
    {
        avmaxtr = TR_MAX_EPI2;
        cvmax(optr, TR_MAX_EPI2);
        cvmax(ihtr, 31s);
    }

    avminnecho = 1; 
    avmaxnecho = 1;
    avminsldelay = 0us;
    avmaxsldelay = 20s; /* YMSmr06685 */
    
    /* MRIhc56462 : overwrite initialization by InitAdvPnlCVs */
    if ((t1flair_flag || ir_prep_manual_tr_mode) && existcv(opuser8) && floatsAlmostEqualEpsilons(exist(opuser8), 2.0, 2))
    {
        avminslquant = 2;
    }

    if ( mux_flag )
    {
        avminslquant = 9;
    }

    /* YMSmr06831 */
    if((exist(opdiffuse) == PSD_ON) && (existcv(opbval) == PSD_OFF)) {
        cvoverride(opbval, pidefbval, PSD_FIX_ON, PSD_EXIST_ON);
    }

    if (vrgfsamp == PSD_ON) {
        /* If Ramp Sampling is ON, set the max RBW to 500 kHz always */
        avmaxrbw = RBW_MAX;
    } else {
        float tsptmp;   /* min possible sampling period in micro seconds. */
        
        /* Calculate maximum RBW when ramp samp is not ON */
        /* MRIge51408 - Set max RBW based on max FOV */
        tsptmp = 10.0 / (GAM * xtarg * avmaxfov * 1.0e-6);
        /* round up to nearest 50 nanoseconds */
        tsptmp = (int)(5+100*tsptmp)/100.0;
        tsptmp -= ((int)(100*tsptmp)%5)/100.0;
        avmaxrbw = (1.0 / (2.0 * (tsptmp / 1000.0)));
        avmaxrbw = (avmaxrbw > RBW_MAX) ? RBW_MAX : avmaxrbw;
    }       
    avmaxrbw2 = avmaxrbw;		/* avmaxrbw2 is not used in epi. But this value will be
                                           displayed in the insensitive field of bandwidth2 */
    
    if(PSD_ON != exist(opdiffuse) && PSD_ON != tensor_flag) {
        avminrbw = 31.25;
    } else {
        /* MRIge56895: limit RBW to 62.5 for diffusion since single shot */
        avminrbw = 62.5;
    }

    /* Make sure Y res is within a valid range */
    if( opyres < avminyres ) {
        epic_error( use_ermes, "The phase encoding steps must be increased to %d for the current prescription.", EM_PSD_YRES_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, avminyres );
        return ADVISORY_FAILURE;
    }
    if( opyres > avmaxyres ) {
        epic_error( use_ermes, "The phase encoding steps must be decreased to %d for the current prescription.", EM_PSD_YRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxyres );
        return ADVISORY_FAILURE;
    }

    /* SXZ::MRIge80335 */
    if( floatsAlmostEqualEpsilons(exist(opuser0), 1.0, 2) )
    {
        vrgfsamp = 1;

        if((dbdt_model == DBDTMODELCONV) || ( (cffield == B0_15000)
            && (PSD_XRMB_COIL == cfgcoiltype) ) )
        {
            rampopt = 0;
        }
        else
        {
            rampopt = 1;
        }

    }
    else
    {
        vrgfsamp = 0;
        rampopt = 0;
    }

    if( opdiffuse == PSD_ON && tensor_flag == PSD_OFF )
    {
        max_grad = 1;
    }
    else 
    {
        max_grad = 0;
    }

    if (isRioSystem())
    {
        max_grad = 1;
    }

    if (max_grad == 1) 
    {
        use_maxloggrad = PSD_ON;
    }
    else 
    {
        use_maxloggrad = PSD_OFF;
    }

    if(PSD_ON == different_mpg_amp_flag)
    {
         use_maxloggrad = PSD_OFF;
    }

    /******************************************************/
    /*	check for grafidy.dwi file		      */
    /******************************************************/
    if( hoecc_flag == PSD_OFF && dwicntrl==0 )   /* skip additional linear correction if HOEC is on */
    {
        if(stat("/usr/g/caldir/grafidy.dwi",file_status)==0)dwicntrl=1;
    }
    
    /******************************************************/
    /*	init opflip				      */
    /******************************************************/
    if(oppseq==PSD_SE)
    {
        cvoverride(opflip, 90, PSD_FIX_OFF, PSD_EXIST_ON);
    }
    
    /*MRIhc05898 limit flip angle to 70 degree for longbore 3T with
     *      * BODY or surface coil with spsp pulse*/
    if ((PSD_CRM_COIL == cfgcoiltype) && 
        (TX_COIL_BODY == getTxCoilType()) &&
        exist(opweight) > 130 && PSD_OFF == exist(opfat)  && 
        cffield == B0_30000) 
    {
        pifanub = 0; 
        cvoverride(opflip, 70, PSD_FIX_ON, PSD_EXIST_ON);
    }   


    /* Setsysparms sets the psd_grd_wait and psd_rf_wait
       parameters for the particular system. */
    if (_psd_rf_wait.fixedflag == 0) 
    {
        if (setsysparms() == FAILURE) 
	{
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "setsysparms" );
            return FAILURE;
	}
    }
    
    /* JAH: Force SR20 systems to select ezdwi before selecting anything else */
    if( (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25) && (EZflag != PSD_ON)
        && ( existcv(opnshots) ||existcv(opte) || existcv(opautote) || existcv(optr)) ) {
        epic_error( use_ermes, "Only ezdwi can be run at sr%d. Please type ezdwi", EM_PSD_DWEPI_SRMODE_INCOMPATIBLE, EE_ARGS(1), INT_ARG, cfsrmode );
        return FAILURE;
    }
    
    /************************************************************************/
    
    /* Just in case...MRIge93923-Venkat*/
    if(exist(opmph) == PSD_OFF)
    {
        _opfphases.fixedflag = 0;
        opfphases = 1;
        _opfphases.fixedflag = 1;
        setexist(opfphases,PSD_ON);
        pimphscrn = 0; 
    }
    /* ***************************
       Diffussion parameters
       *************************** */
    
    if((exist(opdiffuse)==PSD_ON) || (tensor_flag ==PSD_ON)) {
        if(opdfaxall==0) rhdptype=0;
        if((opdfaxall>0) && (opsavedf==1)) rhdptype=1;
        if((opdfaxall>0) && (opsavedf==2)) rhdptype=3;
        if((opdfaxtetra>0) && (opsavedf==1)) rhdptype=1;
        if((opdfaxtetra>0) && (opsavedf==2)) rhdptype=3;
        if(tensor_flag>0) rhdptype = 0;

        max_bval = 0;
        pidifavgnex = 0;
        total_difnex = 0;
        max_nex = 0;
        total_bval = 0.0;
        
        for (bval_counter = 0; bval_counter < opnumbvals; bval_counter++)
        {
            if (bvalstab[bval_counter] > max_bval) max_bval = bvalstab[bval_counter];
            if (difnextab[bval_counter] > max_nex) max_nex = (int)difnextab[bval_counter];
            total_difnex += (int)difnextab[bval_counter];
            total_bval += difnextab[bval_counter]*bvalstab[bval_counter];
        }
        max_difnex = max_nex;
        if(opdifnext2 > max_nex) max_nex = opdifnext2;
        pidifavgnex = (total_difnex + opdifnext2*opdifnumt2 + (rpg_in_scan_flag?rpg_in_scan_num:0)) / 
                        ( (float)(rpg_in_scan_flag?rpg_in_scan_num:0) + (float)opdifnumt2 + FMax(2, 1.0, opnumbvals));

        for (bval_counter = 0; bval_counter < opnumbvals; bval_counter++)
        {
            diff_bv_weight[bval_counter] = bvalstab[bval_counter]/max_bval;
        }

        num_dif = ONE_AXIS; /*HCSDM00516239*/

        /*MRIhc05854*/
        /*Update opdifnumdirs default value to avoid PSD timeout*/
        if((opdfaxx>PSD_OFF) || (opdfaxy>PSD_OFF) || (opdfaxz>PSD_OFF)) {
            num_dif=ONE_AXIS;
            scale = (float)total_difnex/(opdifnext2+total_difnex*num_dif);
            cvdef(opdifnumdirs,1);
        }
        if(opdfaxall>PSD_OFF) {
            num_dif = ALL_AXIS;
            scale = (float)total_difnex/((rpg_in_scan_flag?rpg_in_scan_num:0)+opdifnext2+total_difnex*num_dif);
            if(gradopt_diffall == PSD_ON)
            {
                scale = (float)total_difnex*2/((rpg_in_scan_flag?rpg_in_scan_num:0)+opdifnext2+total_difnex*num_dif);
            }
            cvdef(opdifnumdirs,3);
        }
        if (tensor_flag == PSD_ON) {
            num_dif = ALL_AXIS;
            scale = (float)total_difnex/(opdifnext2*opdifnumt2+total_difnex*num_dif);
            cvdef(opdifnumdirs,6);
        }
        if(opdfax3in1>PSD_OFF) {
            num_dif = ONE_AXIS;
            scale = (float)total_difnex*num_dif/(opdifnext2+total_difnex*num_dif);
            cvdef(opdifnumdirs,1);
        }
        if(opdfaxtetra>PSD_OFF) {
            num_dif = ALL_AXIS_TETRA;
            scale = (float)total_difnex*num_dif/(opdifnext2+total_difnex*num_dif);
            cvdef(opdifnumdirs,4);
        }

        scale_dif = scale; /*MRIhc05854*/
        
        /* MRIhc54476 */
        if ((tensor_flag == PSD_OFF) && (num_dif > 0))
        {
            cvoverride (opdifnumdirs, num_dif, PSD_FIX_ON, PSD_EXIST_ON);
        }

        avg_bval = total_bval/(total_difnex*num_dif+(rpg_in_scan_flag?rpg_in_scan_num:0)+opdifnext2*opdifnumt2);

        rhnumdifdirs = exist(opdifnumdirs);

        rhdifnext2 = opdifnext2;
        rhnumbvals = exist(opnumbvals);

        /* BJM: MRIge47630 turn on Diffusion gradients for RMS and heating calcs */
        /* and scale by frequency of occurence */
        /* MRIge57853 added opdfaxall cond. */
        if((opdfaxx != PSD_OFF) || (opdfaxall != PSD_OFF) || (tensor_flag == PSD_ON) || (opdfax3in1 != PSD_OFF) || (opdfaxtetra != PSD_OFF)) {
            gradx[GXDR_SLOT].num = 1;
            gradx[GXDL_SLOT].num = 1;
            gradx[GXDR_SLOT].scale = scale; 
            gradx[GXDL_SLOT].scale = scale; 
            
            /* This is ONLY for SR20 SGD systems */
            if (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25)
            {
                gradx[GXDL_SLOT].scale = 1.0/(1 + 0.8);  /* Per McFarland'd measurement - MRIge48184, */
                gradx[GXDR_SLOT].scale = 1.0/(1 + 0.8);  /* HOUP */
            }

        } else {
            gradx[GXDR_SLOT].num = 0;
            gradx[GXDL_SLOT].num = 0;
        }
        
        if((opdfaxy != PSD_OFF) || (opdfaxall != PSD_OFF) || (tensor_flag == PSD_ON) || (opdfax3in1 != PSD_OFF) || (opdfaxtetra != PSD_OFF) ) {
            grady[GYDR_SLOT].num = 1;
            grady[GYDL_SLOT].num = 1;
            grady[GYDR_SLOT].scale = scale; 
            grady[GYDL_SLOT].scale = scale; 
            
            if (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25)
            {
                grady[GYDL_SLOT].scale = 1.0/(1 + 0.8);
                grady[GYDR_SLOT].scale = 1.0/(1 + 0.8);
            }

        } else {
            grady[GYDR_SLOT].num = 0;
            grady[GYDL_SLOT].num = 0;
        }
        
        if((opdfaxz != PSD_OFF) || (opdfaxall != PSD_OFF) || (tensor_flag == PSD_ON) || (opdfax3in1 != PSD_OFF) || (opdfaxtetra != PSD_OFF)) {
            gradz[GZDR_SLOT].num = 1;
            gradz[GZDL_SLOT].num = 1;
            gradz[GZDR_SLOT].scale = scale; 
            gradz[GZDL_SLOT].scale = scale; 
            
            if (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25)
            {
                gradz[GZDL_SLOT].scale = 1.0/(1 + 0.8);
                gradz[GZDR_SLOT].scale = 1.0/(1 + 0.8);
            }

        } else {
            gradz[GZDR_SLOT].num = 0;
            gradz[GZDL_SLOT].num = 0;
        } /* end opdfax checks */

        incr = PSD_ON;
        
        mph_flag=1;
        
        /* DTI BJM: pass_reps is used for DW-EPI control */

        if(tensor_flag == PSD_OFF) {
            pass_reps = opdifnumt2 + opnumbvals*num_dif;
        } else {
            pass_reps = exist(opdifnumdirs) + exist(opdifnumt2);
        }
        
        /* Refless EPI: add in the pass for ref, which is always the first pass */
        pass_reps += (ref_in_scan_flag ? 1:0);

        /* RPG: Add another pass for distortion correction */
        pass_reps += (rpg_in_scan_flag ? rpg_in_scan_num : 0); 

        reps = 1;
        dwi_fphases = IMax(2, pass_reps, 1);

    }
    else
    {
        incr = PSD_OFF; 
        pass_reps =  1;
        reps = 1;

        dwi_fphases = exist(opfphases);
        
        num_dif=0;
        rhdptype=0;
    }
    
    /* ***************************
       Multi-Phase parameters
       *************************** */
    
    if((exist(opdiffuse)==PSD_OFF) && (tensor_flag == PSD_OFF))
    { 
        mph_flag = (exist(opmph)==PSD_ON ? PSD_ON : PSD_OFF);
        
        if ( (exist(opmph)==PSD_ON) && (exist(opacqo)==0) && (exist(opcgate)==PSD_ON) ) 
        { /* multi-rep cardiac gated */
            pass_reps = exist(opfphases);
            reps = 1;
        }
        else 
            if ( (exist(opmph)==PSD_ON) && (exist(opacqo)==0) ) 
            {  /* interleaved multi-phase */
                pass_reps =  exist(opfphases);
                reps = 1;
            }
            else 
                if ( (exist(opmph)==PSD_ON) && (exist(opacqo)==1) ) 
                { /* sequential multi-phase */
                    reps = exist(opfphases);
                    pass_reps = 1;
                }
                else 
                {  /* default */
                    pass_reps = 1;
                    reps =  1;
                }
        acqmode =  exist(opacqo); /* acq mode, 0=interleaved, 1=def=sequential */
        rhuser4 = acqmode;
        
    }
   
    if (PSD_ON == mux_flag)
    {
        cvmax(rhchannel_combine_method, RHCCM_ASSET_COMBINE);
        rhchannel_combine_method = RHCCM_ASSET_COMBINE;
        rhcal_options = CAL_OPTIONS_EXT3DCAL + CAL_OPTIONS_EXT2DCAL + CAL_OPTIONS_CACHE; /* for multiband, bit4-Cache Calibration, bit1-Ext 2D Cal, bit0-Ext 3D Cal */
    }
    else if (PSD_ON == rfov_flag)
    {
        cvmax(rhchannel_combine_method, RHCCM_C3_RECON_FOR_PHASE_I_Q_IMAGES);
        rhchannel_combine_method = RHCCM_C3_RECON_FOR_PHASE_I_Q_IMAGES;
        rhcal_options = CAL_OPTIONS_EXT3DCAL + CAL_OPTIONS_EXT2DCAL; /* Phase ASSET , bit1-Ext 2D Cal, bit0-Ext 3D Cal*/
    }
    else
    {
        cvmax(rhchannel_combine_method, RHCCM_C3_RECON_FOR_PHASE_I_Q_IMAGES);
        rhchannel_combine_method = RHCCM_SUM_OF_SQUARES;
        rhcal_options = CAL_OPTIONS_EXT3DCAL + CAL_OPTIONS_EXT2DCAL; /* Phase ASSET , bit1-Ext 2D Cal, bit0-Ext 3D Cal*/
    }


    if (exist(opmph)==PSD_OFF)
        opsldelay = avminsldelay;
         
    if (existcv(opsldelay) && (exist(opsldelay) == avminsldelay) && (avminsldelay <= 1us) ) {

        /* set pass_delay to min. = 1 us which is effectively    */
        /* a delay = 0us between passes since the delay between */
        /* each null pass is also 1 us.                         */
        pass_delay = 1us;
        num_passdelay = 1;
        
    } else {

        /* Else...set the delay to the prescribed value */
        pass_delay = exist(opsldelay);
        if (pass_delay > 15s) {
            num_passdelay = pass_delay/15s+((pass_delay%15s==0)?0:1);
        }
        else {
            num_passdelay = 1;
        }
        pass_delay = pass_delay/num_passdelay+1;
    }

    piphases = exist(opphases);
    max_phases = piphases;
    
    piadvmin |= (1<<PSD_ADVTI);
    piadvmax |= (1<<PSD_ADVTI);
    
    if (( mph_flag == PSD_ON )&&(opdiffuse==PSD_OFF)&&(tensor_flag == PSD_OFF)) 
    {
        /* screen for MPH option */
        pimphscrn = 1;
        pifphasenub = 6;
        pifphaseval2 = 1;
        pifphaseval3 = 2;
        pifphaseval4 = 5;
        pifphaseval5 = 10;
        pifphaseval6 = 15;
        
        pisldelnub = 6;
        pisldelval3 = 500ms;
        pisldelval4 = 1000ms;
        pisldelval5 = 2000ms;
        pisldelval6 = 5000ms;
        
        /* Changed piacqnub from 2 to 3 for Linux-MGD. WGEbg17457 -Venkat*/
        piacqnub = 3; /* acquisition order buttons */
        
    } 
    else 
    {
        pimphscrn = 0; /* do not display the Multi-Phase Parameter screen */
        pifphasenub = 0;
        pisldelnub = 0;
        piacqnub = 0; /* acquisition order buttons */
        
    }
  
    /***** TI UI Button Control *********/
    if( (PSD_ON == exist(opdiffuse)) &&
        ((PSD_ON == exist(opspecir)) || (PSD_ON == exist(opirprep))) )
    {
        pitinub=2;
    }
    else
    {
        pitinub=0;
        cvoverride(opautoti, PSD_OFF, PSD_FIX_OFF, PSD_EXIST_OFF);
    }
   
    /* UI Fields TR & TI (FLAIR) */
    if (epi_flair == PSD_ON) {
        
        pitinub = 2;
        
        if(cffield==B0_15000) {
            pitival2 = 2200ms;
        } else if (cffield==B0_10000) {
            pitival2 = 2000ms;
        } else if(cffield==B0_5000) {
            pitival2 = 1800ms; 
        }
        else if (cffield == B0_40000) {
            pitival2 = 2200ms;
            DEBUG_4_0(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_30000) {
            pitival2 = 2200ms;
            DEBUG_3_0(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_7000) {
            pitival2 = 1800ms; 
            DEBUG_0_7(SD_PSD_EPI2,__FILE__,__LINE__);
        }
        else if (cffield == B0_2000) {
            SDL_PrintFStrengthWarning(SD_PSD_EPI2,cffield,__FILE__,__LINE__);
        }
        else {
            SDL_PrintFStrengthWarning(SD_PSD_EPI2,cffield,__FILE__,__LINE__);
        }

 
        avminti=FLAIR_MIN_TI;
        avmaxti=FLAIR_MAX_TI;
        
        cvmin(opti,FLAIR_MIN_TI);
        cvmax(opti,FLAIR_MAX_TI);
        
        cvdef(opti,1.5s);
    } else {

        cvmin(opti,TI_MIN);

        /* irprep_support */
        if(irprep_flag == PSD_ON)
        {
          /* Activate advisory panel checks for TI */
          piadvmin = (piadvmin | (1<<PSD_ADVTI));
          piadvmax = (piadvmax | (1<<PSD_ADVTI));

          pitinub = 5;

          if(cffield == B0_15000)
          {
              pitival2 = 160ms;
              pitival3 = 170ms;
              pitival4 = 180ms;
              pitival5 = 190ms;
          }
          else
          {
              pitival2 = 220ms;
              pitival3 = 230ms;
              pitival4 = 240ms;
              pitival5 = 250ms;
          }

          if ((PSD_ON == t1flair_flag) || (PSD_ON == ir_prep_manual_tr_mode))
          {
              /* turn on Auto TI for t1flair interleaved STIR */
              piautoti = PSD_ON;
          }
          else
          {
              piautoti = PSD_OFF;
          }

          avmaxti = EPI_STIR_TI_MAX;
          cvmax(opti,EPI_STIR_TI_MAX);
        }
        else if(PSD_ON == exist(opspecir))
        {
          init_ASPIR_TI();
        }
        else 
        {
          /* turn off TI field, flair = 0 */
          pitinub = 0;
          piautoti = PSD_OFF;
          avmaxti = TI_MAX;
          cvmax(opti,TI_MAX);
        }
    }

    /* 0.5T -> turn on fatsat, turn off spsp */
    if (cffield == B0_5000) { 
        cvoverride(opsat, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        cvoverride(opfat, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        ss_rf1 = 0;
    }

    if (PSD_OFF == enhanced_fat_suppression)
    {
        if (irprep_flag || aspir_flag || exist(opfat) || (ss_rf1_compatible == PSD_OFF))
        {
            ss_rf1 = 0;
            eosykiller = 0;
        }
        else
        {
            /* MRIge48532 - turn on eosykiller if ss_rf1 = PSD_ON */
            ss_rf1 = 1;        
            eosykiller = 1;
        }

        breast_spsp_flag = 0;
        d_cf = 0;
    }
    else
    {
            /* set up enhanced fat suppression */
            if (cffield == B0_30000)
            {
                if (enhanced_fat_suppression == 1)
                {
                    ss_rf1 = 1;
                    eosykiller = 1;
                    breast_spsp_flag = 0;
                    d_cf = 0;
                }
                else if (enhanced_fat_suppression == 2)
                {
                    ss_rf1 = 1;
                    eosykiller = 1;
                    breast_spsp_flag = 1; /* broad pass band spsp */
                    d_cf = (int)( 50 / TARDIS_FREQ_RES);
                }
                else
                {
                    ss_rf1 = 1;
                    eosykiller = 1;
                    breast_spsp_flag = 2; /*Type II broad pass band spsp */
                    d_cf = (int)( 50 / TARDIS_FREQ_RES);
                }
                /*RTB0 correction: set d_cf to 0 to prevent spine signal drop off at shoulder*/
                if (rtb0_spsp_flag)
                {
                    d_cf = 0;
                } 
            }
            else /*1.5T*/
            {
                ss_rf1 = 1;
                eosykiller = 1;
                breast_spsp_flag = 0;
                d_cf = 0;
            }
    }

    if( (cfgcoiltype == PSD_XRMB_COIL || isRioSystem() || cfgcoiltype == PSD_XRMW_COIL || cfgcoiltype == PSD_VRMW_COIL) ||
        (opweight > 150 && cffield >= B0_30000 && getTxCoilType() == TX_COIL_BODY &&
         cfgcoiltype == PSD_TRM_COIL) )
    {
       if (ss_rf1 == PSD_ON)
       {
           ss_fa_scaling_flag = PSD_ON;
       }
       else
       {
           ss_fa_scaling_flag = PSD_OFF;
       }

       if (ir_on == PSD_ON && opweight > 150 && cffield >= B0_30000 &&
           getTxCoilType() == TX_COIL_BODY && cfgcoiltype == PSD_TRM_COIL)
       {
           ir_fa_scaling_flag = PSD_ON;
       }
       else
       {
           ir_fa_scaling_flag = PSD_OFF;
       }
    }
    else
    {
        ss_fa_scaling_flag = PSD_OFF;
        ir_fa_scaling_flag = PSD_OFF;
    }

    fast_rec = 0;
     
    /* just add cvcheck to trap this and eliminate this code: */
    /* gxdelay and gydelay must lie on 4us boundaries */
    if (gxdelay % GRAD_UPDATE_TIME != 0) {
        cvoverride(gxdelay,RUP_GRD(gxdelay),_gxdelay.fixedflag, _gxdelay.existflag);
    }
    
    if (gydelay % GRAD_UPDATE_TIME != 0) {
        cvoverride(gydelay,RUP_GRD(gydelay),_gydelay.fixedflag, _gydelay.existflag);
    }   
    
    intleaves = exist(opnshots);
   
    piphasfovnub = 0;
    /* Variable FOV buttons on or off depending on square pixels */
    if (exist(opsquare) == PSD_ON)
    {
        piphasfovnub2 = 0;
    }
    else 
    {
        if (rfov_flag)
        {
            piphasfovnub2 = 31;
            piphasfovval2 = 1.0;
            piphasfovval3 = 0.75;
            piphasfovval4 = 0.5;
            piphasfovval5 = 0.2;
        }
        else
        {
            piphasfovnub2 = 7;
            piphasfovval2 = 1.0;
            piphasfovval3 = 0.5;
        }

        cvmax(opphasefov,1.0);

        if (rfov_flag)
        {
            min_phasefov = 0.2;
        }
        else
        {
            min_phasefov = 0.5;
        }

        cvmin(opphasefov, min_phasefov);
    }
       
    if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77 ) && (EZflag == PSD_ON) )
    {
        piphasfovnub = 1;
        piphasfovval1 = 0.6;
    }
   
    /* Set default frequency encoding direction for head R/L  QT*/
    if (( TX_COIL_LOCAL == getTxCoilType() &&
          (exist(opplane) == PSD_AXIAL || exist(opplane)== PSD_COR) ) ||
        ( TX_COIL_LOCAL == getTxCoilType() &&
          exist(opplane) == PSD_OBL && existcv(opplane) 
          && (exist(opobplane) == PSD_AXIAL || exist(opobplane) == PSD_COR) )) 
    {
        piswapfc = 1;
    }
    else 
    {
        piswapfc = 0;
    }
    
    /****  Asymmetric Fov  ****/
    /* handling for phase (y) resolution and recon scale factor.*/
    setexist(opphasefov,PSD_ON);   /* MRIge51075 - set exist flag so that the value won't be 1. */
    if ( !floatsAlmostEqualEpsilons(exist(opphasefov), 1.0, 2) && existcv(opphasefov) && ((exist(opsquare) != PSD_ON) && existcv(opsquare)) ) 
    {
        rhphasescale = exist(opphasefov);
        eg_phaseres = exist(opyres);
    } else { 
        if ( (exist(opsquare) == PSD_ON) && existcv(opsquare) ) 
        {
            /* MRIge51504 - opyres can't be greater than opxres with square pixel. */
            if ( exist(opyres) > exist(opxres) )
            {
                epic_error( use_ermes, "This YRES cannot be achieved with current prescription", EM_PSD_YRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, exist(opxres) );
                avminyres = exist(opxres);
                avmaxyres = exist(opxres);
                return ADVISORY_FAILURE;
            }
            rhphasescale = (float)exist(opyres)/(float)exist(opxres);
            setexist(opphasefov,PSD_ON);
            _opphasefov.fixedflag = 0;
            opphasefov = rhphasescale;
            _opphasefov.fixedflag = 1;
            eg_phaseres = exist(opxres);
        } 
        else 
        {
            rhphasescale = 1.0;
            _opphasefov.fixedflag = 0;
            opphasefov = 1.0;
            _opphasefov.fixedflag = 1;
            eg_phaseres = exist(opyres);
        }
    }

    /* t1flair_stir */
    if ( T1flair_setup()  == FAILURE )
    {
        return FAILURE;
    }

    /* MRIge51174 - EZDWI, ramp sampling is ON, PH */
    if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem())) || cfsrmode == PSD_SR77) && (EZflag == PSD_ON) )
        vrgfsamp = 1;
    
    rhfreqscale = 1.0;
    dfg = 2;
    dfscale = 1;
    freq_scale = rhfreqscale;
    
    /**********************************************************************
      Initialize RF System Safety Information.  This must be re-initialized
      in eval section since CV changes may lead to scaling of rfpulse.
    *********************************************************************/
    for (pulse=0; pulse<RF_FREE; pulse++) 
    {
        rfpulseInfo[pulse].change=PSD_OFF;
        rfpulseInfo[pulse].newres=0;
    }
    /* Reinitialize Prescan CV's for cveval. Done so rf system safety check
       can be performed with each OPIO change. */

    /* PURE Mix */
    model_parameters.epi.rfov_flag = rfov_flag;

@inline vmx.e SysParmEval
@inline vmx.e AcrxScanVolumeEval

    /* reinitialize sat and prescan vars in case loggrd changed */
    if(SpSatInit(vrgsat) == FAILURE) return FAILURE;

@inline ChemSat.e ChemSatInit
@inline Prescan.e PScvinit
@inline Inversion_new.e InversionInit

    if (mux_flag == PSD_OFF) {
        if ( (exist(oppseq) == PSD_SE) || (exist(opflip) > 30) )
        {
            pw_rf1 = PSD_SE_RF1_PW;
            res_rf1 = PSD_SE_RF1_R;
            gscale_rf1 = .90;
            flip_rf1 = 90.0;
            hrf1a = PSD_SE_RF1_LEFT;
            hrf1b = PSD_SE_RF1_RIGHT;
            a_rf1 = 0.5;
            rftype = PLAY_RFFILE;
            sprintf(ssrffile, "/usr/g/bin/rffl901mc.rho");
            sprintf(ssgzfile, "/usr/g/bin/rfempty1.gz");
        }
        else
        {
            pw_rf1 = PSD_GR_RF1_PW;
            res_rf1 = PSD_GR_RF1_R;
            gscale_rf1 = .90;
            flip_rf1 = 30.0;
            hrf1a = PSD_GR_RF1_LEFT;
            hrf1b = PSD_GR_RF1_RIGHT;
            a_rf1 = 0.5;
            rftype = PLAY_RFFILE;
            sprintf(ssrffile, "/usr/g/bin/rfgr30l.rho");
            sprintf(ssgzfile, "/usr/g/bin/rfempty1.gz");
        }
        mux_slices_rf1 = 1;
        mux_slices_rf2 = 1;
    }
    else {
        gscale_rf1 = 1.0;
    }

    /* HCSDM00361682 */
    /* Pulse width of FOCUS RF pulse for 1 acq is longer than for 2 acqs.
       rfov_type is determined in rfov_cveval() depending on acqs.
       But acqs is calculated in cveval1().
       If the condition is under marginally condition between 1acq and 2acqs
       the result of selection of rfov_type and acqs had conflict.
       That caused oscillation of results of cveval(), long UI response, wrong excitation
       and resulted in acquireing noise images.
       Detect oscillation here and set condition to larger acqs and smaller avmaxslquant.
       In predownload() no parameters should be changed, keep the oscillation mode flag
       and call cveval() from predownload() once oscillation is detected.
       Fix for HCSDM00361682 is rather tricky fix so appropriate fix with structual design change
       will be desired in the future. */
    if(rfov_flag)
    {
        focus_eval_oscil= 0;
        oscil_eval_count = oscil_eval_count + 1;
        if( ((exist(optr) != optr_save) || (exist(opslquant) != opslquant_save)) && (0 == isPredownload) )
        {
            reset_oscil_in_eval = 1;
            oscil_eval_count = 1;
        }
        if(MAXINT == oscil_eval_count)
        {
            oscil_eval_count = 0;
        }
        if(keep_focus_eval_oscil)
        {
            focus_eval_oscil = keep_focus_eval_oscil;
        }
        else
        {
            if((avmaxslquant_hist[0] == avmaxslquant_hist[2]) && (acqs_hist[0] == acqs_hist[2]) &&
                (avmaxslquant_hist[0] != avmaxslquant_hist[1]) && (acqs_hist[0] != acqs_hist[1]))
            {
                focus_eval_oscil = 1;
            }
            if( (((avmaxslquant_hist[0] == avmaxslquant_hist[1]) && (avmaxslquant_hist[2] == avmaxslquant_hist[3]) && (avmaxslquant_hist[1] != avmaxslquant_hist[2])) ||
                  ((avmaxslquant_hist[0] == avmaxslquant_hist[3]) && (avmaxslquant_hist[1] == avmaxslquant_hist[2]) && (avmaxslquant_hist[0] != avmaxslquant_hist[1]))) &&
                 (((acqs_hist[0] == acqs_hist[1]) && (acqs_hist[2] == acqs_hist[3]) && (acqs_hist[1] != acqs_hist[2])) ||
                  ((acqs_hist[0] == acqs_hist[3]) && (acqs_hist[1] == acqs_hist[2]) && (acqs_hist[0] != acqs_hist[1]))) )
            {
                if(oscil_eval_count > 3)
                {
                    focus_eval_oscil = 2;
                }
            }
        }
        if(focus_eval_oscil)
        {
            focus_eval_oscil_hist = 1;
            if(1 == focus_eval_oscil)
            {
                force_acqs = IMax(2,acqs_hist[0],acqs_hist[1]);
                force_avmaxslquant = IMin(2,avmaxslquant_hist[0],avmaxslquant_hist[1]);
            }
            else if(2 == focus_eval_oscil)
            {
                force_acqs = IMax(3,acqs_hist[0],acqs_hist[1],acqs_hist[2]);
                force_avmaxslquant = IMin(3,avmaxslquant_hist[0],avmaxslquant_hist[1],avmaxslquant_hist[2]);
            }
            if(1 == reset_oscil_in_eval)
            {
                focus_eval_oscil = 0;
            }
            else
            {
                acqs = force_acqs;
                avmaxslquant = force_avmaxslquant;
            }
            if( (1 == isPredownload) || ((0 == isPredownload) && (0 == reset_oscil_in_eval) && (PSD_OFF == exist(opinrangetr))) )
            {
                keep_focus_eval_oscil = focus_eval_oscil;
            }
            else
            {
                keep_focus_eval_oscil = 0;
            }
            oscil_eval_count = 0;
        }
    }
    else
    {
        focus_eval_oscil = 0;
        keep_focus_eval_oscil = 0;
        focus_eval_oscil_hist = 0;
        oscil_eval_count = 0;
    }

    /* Initialize RFOV parameters, and set hrf1a & hrf1b, etc. */
    if (FAILURE == rfov_cveval())
    {
        return FAILURE;
    }


    gztype = PLAY_TRAP;
    thetatype = NO_THETA;
    pw_rf2 = 3.2ms; 
    res_rf2 = RES_SE1B4_RF2;
    gscale_rf2 = .90;
    flip_rf2 = 180.0;
    hrf2a = pw_rf2/2;
    hrf2b = pw_rf2/2;
    a_rf2 = 1.0;
    alpha_rf2 = 0.46;
  
    /* MRIge81510 (HD) spsp pulse for 1.5T */
    /* BJM: change pulse if possible */
    if (cfsrmode >= PSD_SR100 || ((cfsrmode == PSD_SR50) && (isStarterSystem()))) {
        /* turn on 1.5T delay insensitive RF pulse */
        if (cffield ==  B0_15000) {
            ss_override = 1;
        } else {
	    ss_override = 0;   /* 3T is already delay insensitive */
        }

    } else {

        ss_override  = 0;

    }
								    
    if (exist(oppseq) == PSD_SE || (exist(opflip)>30) ) 
    { 
        INT num_rf2 = 1.0;
        
        /* DTI BJM: (dsp) count pulses correctly */
        if (PSD_ON == dualspinecho_flag)
        {
            num_rf2 = 2.0;

            if (ssgr_flag && ssgr_bw_update)
            {
                int temp_pw;
                temp_pw = RUP_GRD((int)(NOM_BW_SE1B4 * (float)PSD_NOM_PW_SE1B4/
                                  (rf2_bw_ratio*fat_cs*cffield/B0_15000-2.0*b0_offset)));

                if(temp_pw > pw_rf2)
                {
                    pw_rf2 = temp_pw;
                }
            }
        }
        else
        {
            num_rf2 = 1.0;
            if (ssgr_flag && ssgr_bw_update)
            {
                int temp_pw;
                temp_pw = RUP_GRD((int)(NOM_BW_FL901MC_RF1 * (float)PSD_NOM_PW_FL901MC/
                                  (rf1_bw_ratio*fat_cs*cffield/B0_15000-2.0*b0_offset)));
                if(temp_pw > pw_rf1)
                {        
                    pw_rf1 = temp_pw; 
                } 
                temp_pw = RUP_GRD((int)(NOM_BW_SE1B4 * (float)PSD_NOM_PW_SE1B4/
                                  (rf2_bw_ratio*fat_cs*cffield/B0_15000-2.0*b0_offset)));
                if(temp_pw > pw_rf2)
                {
                    pw_rf2 = temp_pw;
                }
            }
        }

        if (rfov_flag)
        {
            setuprfpulse(RF1_SLOT, &pw_rf1, &a_rf1, ex_abswidth, ex_effwidth, ex_area,
                         ex_dtycyc, ex_maxpw, 1, ex_max_b1, ex_max_int_b1_sqr, ex_max_rms_b1,
                         ex_nom_flip, &flip_rf1, (float) pw_rf1, bw_rf1,
                         PSD_APS2_ON+PSD_MPS2_ON+PSD_SCAN_ON, (char ) 0, hrf1b, 1.0,
                         &res_rf1, 1, &wg_rf1, 1, rfpulse);
            /*** SVBranch: HCSDM00259122  - FOCUS walk sat ***/         
            if ( (walk_sat_flag) && (rfov_flag) )
            {          
                setuprfpulse(RFWK_SLOT,             /* index into rfpulse structure array */
                             &pw_rfwk,              /* pointer to pulse width (us) */
                             &a_rfwk,               /* pointer to amplitude (relative) */
                             SAR_ABSWIDTH_RFWK,
                             SAR_EFFWIDTH_RFWK,
                             SAR_AREA_RFWK,         
                             SAR_DTYCYC_RFWK,       
                             SAR_MAXPW_RFWK, 
                             1,                       /* quantity of this type of RF pulse */
                             SAR_MAX_B1_RFWK, 
                             SAR_MAX_INT_B1_SQ_RFWK, 
                             SAR_MAX_RMS_B1_RFWK,
                             SAR_NOM_FA_RFWK, 
                             &flip_rfwk,             /* pointer to actual flip angle */
                             SAR_NOM_PW_RFWK, 
                             SAR_NOM_BW_RFWK,
                             PSD_APS2_ON+PSD_MPS2_ON+PSD_SCAN_ON,
                             (char) 0,                /* flag for pulse used in TG setting */
                             hrfwkb,                  /* iso-delay */
                             1.0,                     /* duty cycle scale factor */
                             &res_rfwk,            
                             0,                       /* external grad wave or not */
                             &wg_rfwk,                /* pointer to sequencer type */
                             2,                       /* Hadamard Factor */
                             rfpulse);                               
            }                             
            /****************************/                         

            if (focus_B0_robust_mode)
            {
                float bw_rf2_temp = 0.0;

                focus_unwanted_delta_f = SDL_GetChemicalShift(cffield);
                bw_rf2_temp = bw_rf1 * focus_unwanted_delta_f / (focus_unwanted_delta_f - bw_rf1);
                pw_rf2 = RUP_GRD((int)(rfpulse[RF2_SLOT].nom_bw * rfpulse[RF2_SLOT].nom_pw / bw_rf2_temp));
                hrf2a = pw_rf2/2;
                hrf2b = pw_rf2/2;
            }
        }
        else
        {
            if (mux_flag == PSD_OFF) {
                setuprfpulse(RF1_SLOT, &pw_rf1, &a_rf1, SAR_ABS_FL901MC, SAR_PFL901MC,
                             SAR_AFL901MC, SAR_DTYCYC_FL901MC, SAR_MAXPW_FL901MC, 1,
                             MAX_B1_FL901MC_90, MAX_INT_B1_SQ_FL901MC_90,
                             MAX_RMS_B1_FL901MC_90, 90.0, &flip_rf1, (float)PSD_NOM_PW_FL901MC,
                             NOM_BW_FL901MC_RF1, PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON,
                             0, hrf1b, 1.0, &res_rf1, 0, &wg_rf1, 1, rfpulse);
            }
        }
        if (mux_flag == PSD_OFF) {
            setuprfpulse(RF2_SLOT, &pw_rf2, &a_rf2, SAR_ABS_SE1B4, SAR_PSE1B4,
                         SAR_ASE1B4, SAR_DTYCYC_SE1B4, SAR_MAXPW_SE1B4, 1,
                         MAX_B1_SE1B4_180, MAX_INT_B1_SQ_SE1B4_180,
                         MAX_RMS_B1_SE1B4_180, 180.0, &flip_rf2, (float)PSD_NOM_PW_SE1B4,
                         NOM_BW_SE1B4, PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON, 0,
                         hrf2b, 1.0, &res_rf2, 0, &wg_rf2, 1, rfpulse);
            verse_rf2 = 0;
        } 

        /* DTI BJM: (dsp) set up rf waveform amps */
        if (PSD_ON == dualspinecho_flag)
        {
            a_rf2left = a_rf2;
            a_rf2right = a_rf2left;
        }

    } 
    else 
    {
        setuprfpulse(RF1_SLOT, &pw_rf1, &a_rf1, SAR_ABS_GR30L, SAR_PGR30L,
                     SAR_AGR30L, SAR_DTYCYC_GR30L, SAR_MAXPW_GR30L, 1,
                     MAX_B1_GR30L, MAX_INT_B1_SQ_GR30L, MAX_RMS_B1_GR30L,
                     30.0, &flip_rf1, (float)PSD_NOM_PW_GR30, NOM_BW_GR30L,
                     PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON, 0,
                     hrf1b, 1.0, &res_rf1, 0, &wg_rf1, 1, rfpulse);

        if (PSD_OFF == mux_flag)
        {
            setuprfpulse(RF2_SLOT, &pw_rf2, &a_rf2, SAR_ABS_SE1B4, SAR_PSE1B4,
                         SAR_ASE1B4, SAR_DTYCYC_SE1B4, SAR_MAXPW_SE1B4, 1,
                         MAX_B1_SE1B4_180, MAX_INT_B1_SQ_SE1B4_180,
                         MAX_RMS_B1_SE1B4_180, 180.0, &flip_rf2, (float)PSD_NOM_PW_SE1B4,
                         NOM_BW_SE1B4, PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON, 0,
                         hrf2b, 1.0, &res_rf2, 0, &wg_rf2, 1, rfpulse);
        }
    }

    /* Initialize Multiband parameters, setup rf1 & rf2 pulses etc. */
    if (FAILURE == Multiband_cveval(ssgr_mux))
    {
        return FAILURE;
    }

    if (ssInit() == FAILURE) return FAILURE;	

@inline Inversion_new.e InversionEval2
    
    /* Check to see if rf pw's need scaling for large patients */
    for (entry=0; entry<MAX_ENTRY_POINTS; entry ++)
        scalerfpulses(opweight,cfgcoiltype,RF_FREE,rfpulse,entry,rfpulseInfo);
        
    /*** SVBranch: HCSDM00259122 - FOCUS walk sat calc ***/
    if ( (walk_sat_flag) && (rfov_flag) )
    {
        if ( FAILURE == walk_sat_cveval() ) return FAILURE;      
    }  
    /*********************************/        
  
    /* DTI BJM: (dsp) dual spin echo */
    if (PSD_ON == dualspinecho_flag)
    {
        pw_rf2left = pw_rf2;
        pw_rf2right = pw_rf2left;
        
        res_rf2left = res_rf2;
        res_rf2right = res_rf2left;

        flip_rf2left = flip_rf2;
        flip_rf2right = flip_rf2left;

        /* MRIge70042 set value back to 0.9 */
        /* gscale_rf2 = 1.1; */
    }
       
  
    /* If pulse width of 90 scaled, then scale off90 accordingly */
    if (rfpulseInfo[RF1_SLOT].change==PSD_ON)
        off90 *= (int) rint(pw_rf1 / rfpulse[RF1_SLOT].nom_pw);
    
    /*	iso_delay = pw_rf1/2 + off90; */
    
    /* Inner volume selective pulse */
    pw_gyrf2iv = pw_rf2;
    off90 = 0;
   
    pw_gzrf1 = pw_rf1;
    pw_gzrf2 = pw_rf2;

    /* DTI BJM (dsp) */ 
    pw_gzrf2left = pw_rf2left;
    pw_gzrf2right = pw_rf2right;

    /* HCSDM00190059 */
    if(rfov_flag == PSD_OFF && mux_flag == PSD_OFF)
    {
        flip_rf1 = exist(opflip);
    }
    
    if (ssEval1() == FAILURE) return FAILURE;  /* Redefine area_gz1, bw_rf1, 
                                                  hrf1a, hrf1b and other parameters for spectral-spatial pulse. */

    /* Make sure the true bandwidths are up to date. */
    bw_rf1 = rfpulse[RF1_SLOT].nom_bw*rfpulse[RF1_SLOT].nom_pw/pw_rf1;
    bw_rf2 = rfpulse[RF2_SLOT].nom_bw*rfpulse[RF2_SLOT].nom_pw/pw_rf2;
    
    /* time from the start of the excitation pulse to the magnetic isocenter */
    t_exa = hrf1a - off90;
 
    rfExIso = hrf1b + off90;
    
    /* auto min te and tr */
    
    if ( exist(opautote) == PSD_MINTE || exist(opautote) == PSD_MINTEFULL )
    {
        setexist(opte,PSD_OFF);
    }
    
    if (exist(opfcomp) == PSD_ON && existcv(opfcomp)) 
    {
        zgmn_type = CALC_GMN1;
        ygmn_type = CALC_GMN1;
    } 
    else 
    {
        zgmn_type = NO_GMN;
        ygmn_type = NO_GMN;
    }
    
    pw_gzrf2a = RUP_GRD(loggrd.zrt);
    pw_gzrf2d = RUP_GRD(loggrd.zrt);
    pw_gzrf2r1a = RUP_GRD(loggrd.zrt); 
    pw_gzrf2r1d = RUP_GRD(loggrd.zrt);

    /* Seqtype(MPMP, XRR, NCAT,CAT  needed for several routines */
    if (seqtype(&seq_type) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "seqtype" );
        return FAILURE;
    }
    
    /* Set the fract_ CVs */
    fract_ky = PSD_FULL_KY;
    ky_dir = PSD_TOP_DOWN;
    
    if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY)
        ep_alt = 2;   /*1st half +, second half - */
    else
        ep_alt = 0;
    
    nexcalc();
    
    /* X readout train */
    
    if (vrgfsamp == 0) 
    {  /* epigradopt will set this properly for vrg */
        rhfrsize = exist(opxres);
    }
    rampsamp = vrgfsamp;
    
    if (vrgfsamp == 1 && !vrgf_bwctrl)
    {   /* turn off bandwidth buttons & rbw advisory */
        pircbnub = 0;
        piadvmax = (piadvmax & ~(1<<PSD_ADVRCVBW)); 
        piadvmin = (piadvmin & ~(1<<PSD_ADVRCVBW)); 
        
        _oprbw.existflag = PSD_OFF;  /* BJM MRIge50916 */
    }
    else
    {
        pircbnub = 5;
        piadvmax = (piadvmax | (1<<PSD_ADVRCVBW));
        piadvmin = (piadvmin | (1<<PSD_ADVRCVBW));
    }

    /* MPG and EPI readout gradient needs to be derated for SSSPS lifetime */
    if ( (5550 == cfgradamp) && (!mkgspec_x_gmax_flag && !mkgspec_y_gmax_flag && !mkgspec_z_gmax_flag) )
    {
        int MAX_ITER = 5;             /* number of iteration for MPG pulse width estimation */

        int iter = 0;                 /* iteration index for MPG pulse width estimation */
        float est_epi_duration = 0.0; /* Estimated EPI duration [ms] */
        float est_mpg_duration = 0.0; /* Estimated MPG duration [ms] */
        float temp_gmax = 0.0;        /* Highest gradient amplitude limit [G/cm] */
        float temp_gmin = 0.0;        /* Lowest gradient amplitude limit [G/cm] */
        float temp_glim = 0.0;        /* Temporary gradient amplitude limit [G/cm] */
        float time_thresh = 0.0;      /* Time threshold to start derating [ms] */
        float time_const = 0.0;       /* Time constant in derating equation [ms] */
        float c1 = 0.0;               /* 1st fitting parameter for MPG pulse width */
        float c2 = 0.0;               /* 2nd fitting parameter for MPG pulse width */

        if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) || ((opdfaxall > PSD_OFF) && (PSD_ON == gradopt_diffall)))
        {
            if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
            {
                temp_gmax = 3.0;
                temp_gmin = 2.02;
                time_thresh = 25.0;
                time_const = 18.0;

                if (PSD_ON == dualspinecho_flag)
                {
                    c1 = 1692.7;
                    c2 = 0.3498;
                }
                else if (PSD_ON == rfov_flag)
                {
                    c1 = 972.00;
                    c2 = 0.4060;
                }
                else
                {
                    c1 = 543.51;
                    c2 = 0.4598;
                }
            }
            else /* gradopt */
            {
                temp_gmax = 3.0;
                temp_gmin = 2.4;
                time_thresh = 40.0;
                time_const = 18.0;

                if (PSD_ON == dualspinecho_flag)
                {
                    c1 = 1994.9;
                    c2 = 0.3465;
                }
                else if (PSD_ON == rfov_flag)
                {
                    c1 = 1225.0;
                    c2 = 0.3958;
                }
                else
                {
                    c1 = 717.68;
                    c2 = 0.4459;
                }
            }

            adaptive_mpg_glim = temp_gmax;

            /* empirical MPG duration under MPG amplitude is temp_gmax */
            est_mpg_duration = 0.001 * 2.0 * c1 * powf(max_bval, c2);

            if (est_mpg_duration > time_thresh)
            {
                for (iter = 0; iter < MAX_ITER; iter++)
                {
                    temp_glim = adaptive_mpg_glim;

                    adaptive_mpg_glim = temp_gmin + (temp_gmax - temp_gmin)
                                      * exp(- (est_mpg_duration - time_thresh) / time_const);

                    /* suppose MPG area doesn't change a lot by MPG derating */
                    est_mpg_duration = est_mpg_duration * temp_glim / adaptive_mpg_glim;
                }
            }

            epi_loggrd_glim = 3.0;
        }
        else
        {
            temp_gmax = 3.3;
            temp_gmin = 2.8;
            time_thresh = 113.5;
            time_const = 30.0;

            adaptive_mpg_glim = temp_gmin;

            if (PSD_ON == vrgfsamp)
            {
                /* empirical ESP value times ETL */
                est_epi_duration = 0.001 * (4.3 * exist(opxres) + 480) * (3.9 * powf(get_act_freq_fov() / 10.0, -0.5))
                    * (num_overscan + (int)(ceilf(exist(opyres) * asset_factor / rup_factor) * rup_factor) / 2) / intleaves;

                if (PSD_ON == dualspinecho_flag)
                {
                    c1 = 2578.4;
                    c2 = 0.3368;
                }
                else if (PSD_ON == rfov_flag)
                {
                    c1 = 1893.3;
                    c2 = 0.3649;
                }
                else
                {
                    c1 = 1488.6;
                    c2 = 0.3852;
                }

                adaptive_mpg_glim = temp_gmax;

                /* empirical MPG duration under MPG amplitude is temp_gmax */
                est_mpg_duration = 0.001 * 2.0 * c1 * powf(max_bval, c2);

                if (est_mpg_duration + est_epi_duration > time_thresh)
                {
                    for (iter = 0; iter < MAX_ITER; iter++)
                    {
                        temp_glim = adaptive_mpg_glim;

                        adaptive_mpg_glim = temp_gmin + (temp_gmax - temp_gmin)
                                          * exp(- (est_mpg_duration + est_epi_duration - time_thresh) / time_const);

                        /* suppose MPG area doesn't change a lot by MPG derating */
                        est_mpg_duration = est_mpg_duration * temp_glim / adaptive_mpg_glim;
                    }
                }
            }

            epi_loggrd_glim = adaptive_mpg_glim;
        }

        adaptive_mpg_glim_flag = PSD_ON;
        epi_loggrd_glim_flag = PSD_ON;
    }
    else
    {
        adaptive_mpg_glim_flag = PSD_OFF;
        epi_loggrd_glim_flag = PSD_OFF;
    }

    /* Adaptive SR derating of readout gradient for SSSD */
    if( ((5550 == cfgradamp) && (PSD_ON == exist(opdiffuse))) &&
        (!(mkgspec_x_sr_flag & MK_SPEC_SR_CHANGE) && !(mkgspec_y_sr_flag & MK_SPEC_SR_CHANGE) && !(mkgspec_z_sr_flag & MK_SPEC_SR_CHANGE)) )
    {
        int iter = 0;
        int run_cveval1 = PSD_ON;
        float preset_derate = 1.0;
        static float extra_derate = 1.0;
        static float extra_derate_pre = 1.0;
        float delta_derate = 0.0;

        while(PSD_ON == run_cveval1 && iter < SR_DERATING_MAX_ITER)
        {
            iter = iter + 1;

            epi_srderate_factor = preset_derate * extra_derate;
            extra_derate_pre = extra_derate;

            if(epi_srderate_factor < 0.99)
            {
                epiphygrd.xrt = RUP_GRD(cfrmp2xfs / epi_srderate_factor);
                epiphygrd.yrt = RUP_GRD(cfrmp2yfs / epi_srderate_factor);
                epiphygrd.zrt = RUP_GRD(cfrmp2zfs / epi_srderate_factor);
                epiphygrd.xft = RUP_GRD(cffall2x0 / epi_srderate_factor);
                epiphygrd.yft = RUP_GRD(cffall2y0 / epi_srderate_factor);
                epiphygrd.zft = RUP_GRD(cffall2z0 / epi_srderate_factor);
                epiloggrd.xrt = epiloggrd.yrt = epiloggrd.zrt
                    = RUP_GRD(IMax(3, cfrmp2xfs, cfrmp2yfs, cfrmp2zfs) / epi_srderate_factor);
                epiloggrd.xft = epiloggrd.yft = epiloggrd.zft
                    = RUP_GRD(IMax(3, cffall2x0, cffall2y0, cffall2z0) / epi_srderate_factor);

                opnewgeo = 1;
            }

            if (cveval1()==FAILURE) {
                /* don't send ermes so that underlying ermes will be displayed */
                return FAILURE;
            }

            if(FALSE == skip_minseqseg)
            {
                /* Return extra_derate to 1.0 when it's less than 1.0 in 1st iteration.
                   extra_derate should be reduced if required voltage is larger than estimated one.
                   In other cases, quit the loop since under voltage won't occur by reducing EPI SR. */

                if(1 == iter && extra_derate_pre < 0.99)
                {
                    extra_derate = 1.0;
                    run_cveval1 = PSD_ON;
                    iter = 0;
                }
                else if(vol_ratio_est_req < 1.0 && iter < SR_DERATING_MAX_ITER)
                {
                    delta_derate = FMax(2, 0.05, 1.0 - vol_ratio_est_req);
                    delta_derate = FMin(2, 0.1, delta_derate);
                    extra_derate = extra_derate_pre - delta_derate / preset_derate;
                    run_cveval1 = PSD_ON;
                }
                else
                {
                    run_cveval1 = PSD_OFF;
                }
            }
            else
            {
                /* If waveform and rotation matrix are not updated, it's not necesary to repeat cveval1(). */
                run_cveval1 = PSD_OFF;
            }

            if(PSD_ON == run_cveval1 && iter < SR_DERATING_MAX_ITER)
            {
                enforce_minseqseg = PSD_ON;
            }
            else
            {
                enforce_minseqseg = PSD_OFF;
            }

            if((fabs(extra_derate_pre - extra_derate) > 0.01) && (vol_ratio_est_req < 1.0))
            {
                FILE *fp;
                fp = fopen("/usr/g/service/log/GradientSafetyResults.log","a");
                fprintf(fp,"EPI SR derating: iter=%d, preset_derate=%4.2f, extra_derate=%4.2f, derate_factor=%4.2f\n",
                        iter, preset_derate, extra_derate, preset_derate * extra_derate);
                fclose(fp);
            }
        }
    }
    else
    {
        if (cveval1()==FAILURE) {
            /* don't send ermes so that underlying ermes will be displayed */
            return FAILURE;
        }
    }

    /* Under voltage prediction for SSSD */
    /* HCSDM00337293 */
    if( (5550 == cfgradamp && vol_ratio_est_req < 1.0) &&
        (!mkgspec_x_gmax_flag && !mkgspec_y_gmax_flag && !mkgspec_z_gmax_flag) )
    {
        if(pircbnub > 0)
        {
            epic_error(use_ermes,
                       "Too much Gradient Power is required.",
                       EM_PSD_GRADPOWER_FOV_B_BW_FREQ_PHASE, EE_ARGS(0));
        }
        else
        {
            epic_error(use_ermes,
                       "Too much Gradient Power is required.",
                       EM_PSD_GRADPOWER_FOV_B_FREQ_PHASE, EE_ARGS(0));
        }

        return FAILURE;
    }


    if( peakAveSars( &ave_sar, &cave_sar, &peak_sar, &b1rms, (int)RF_FREE,
                     rfpulse, L_SCAN, (int)(act_tr/((mux_flag)?mux_slquant:slquant1)) ) == FAILURE )
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "peakAveSars" );
        return FAILURE;

    }

    piasar = (float)ave_sar; /* Report to plasma */
    picasar = (float)cave_sar; /* Coil SAR report to plasma */
    pipsar = (float)peak_sar; /* Report to plasma */
    pib1rms = (float)b1rms; /* Report predicted b1rms value on the UI */
    if (FAILURE == Monitor_Eval( rfpulse, (int)RF_FREE, &monave_sar, &moncave_sar, &monpeak_sar ))
    {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "Monitor_Eval");
        return FAILURE;
    }

    /* Report the greater of the scan and Navigator SAR values */
    if (PSD_ON == navtrig_flag)
    {
        if (monave_sar > piasar) {
            piasar = monave_sar;
        }
        if (moncave_sar > picasar) {
            picasar = moncave_sar;
        }
        if (monpeak_sar > pipsar) {
            pipsar = monpeak_sar;
        }
    }

    fecho_factor = (float)(rhnframes + rhhnover)/fullk_nframes;
    
    /* SNR monitor */
    _pifractecho.fixedflag = 0;
    pifractecho = fecho_factor;
    setexist(pifractecho,_opte.existflag);
    _pifractecho.fixedflag = _opte.fixedflag;

    if (rfov_flag)
    {
        /* HCSDM00150820 - avminslthick based on designed 2DRF pulse */
        av_temp_float = ceil((ex_a_gzs*ex_nom_thkz/loggrd.zfs - exist(opslspace))*10.0)/10.0;
        avminslthick = FMax(3, avminslthick, av_temp_float, ceil(ex_nom_thkz*10.0)/10.0);
    }
    else
    {
        /* MRIge56926 - Calculation of avminslthick - TAA */
        minslicethick(&av_temp_float, bw_rf1, loggrd.tz, gscale_rf1,TYPDEF);
        av_temp_float = ceil(av_temp_float*10.0)/10.0;
        avminslthick = FMax(3,avminslthick,av_temp_float,ss_rf1*ss_min_slthk);
    }
 
    minslicethick(&av_temp_float, bw_rf2, loggrd.tz, gscale_rf2,TYPDEF);
    av_temp_float = ceil(av_temp_float*10.0)/10.0;
    avminslthick = FMax(2,avminslthick,av_temp_float);

    if(mux_flag && verse_rf2)
    {
        avminslthick = FMax(2, avminslthick, mux_min_verserf2_slthk);
    }

    /* MRIge56898 - Calculation of avminnshots and avmaxnshots out of error
       conditions - TAA */

    if (existcv(opnex)!=PSD_OFF) { 
        avmaxnshots = exist(opyres);
    }

    if (nshots_locks == PSD_ON) {
        if ( (cfsrmode==PSD_SR17) || (cfsrmode==PSD_SR20) || (cfsrmode==PSD_SR25) )
            min_nshots = 1;
        else if (cfsrmode==PSD_SR77)
            if (exist(opxres)<=128)
                min_nshots = 1;
            else
                min_nshots = 1;
        else if (((cfsrmode == PSD_SR50) && (isStarterSystem())) || (cfsrmode==PSD_SR100) || (cfsrmode==PSD_SR120))
            if (exist(opxres)==512)
                min_nshots = 1;
            else
                min_nshots = 1;
        else
            min_nshots = 1;
    }

    if  (exist(opdiffuse) == PSD_ON || tensor_flag == PSD_ON)  {
        avminnshots = min_nshots;
        avmaxnshots = max_nshots;
    }
 
    /* MRIge53114 - popup maximum TI for the selected TR. */
    /* AMR for MRIge62721; Moved the calculation of avmaxti from within the error
       check ( to ensure that TR is 4 times longer than TI ) to cveval( ) */
    if ( epi_flair == PSD_ON )
        avmaxti = exist(optr)/(false_acqs*2);

    if( (exist(opslspace)<0) && (tensor_flag == PSD_ON) )
    {
         epic_error( use_ermes, "Increase the slice spacing to %.1f mm", EM_PSD_SLSPACING_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, 0.0);
         return FAILURE;
    }

    /* Multiband is incompatible with negative spacing*/
    if( (exist(opslspace)<0) && (mux_flag == PSD_ON) )
    {
         epic_error( use_ermes, "Increase the slice spacing to %.1f mm", EM_PSD_SLSPACING_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, 0.0);
         return FAILURE;
    }

    /* irprep_support */ 
    if( (PSD_ON == pi_neg_sp || PSD_ON == pioverlap ) &&
        (exist(opslspace)<0) && existcv(opslthick) &&
        (fabs( exist(opslspace) ) > (exist(opslthick) * 0.8)) )
    {
        epic_error( use_ermes, "Overlap should be less than 80%% of the "
                    "prescribed slice thickness.",
                    EM_PSD_SLICE_OVERLAP_EXCEEDED, EE_ARGS(0) );
        return FAILURE;
    }
    
    if( (PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype) )
    {
        /* MRIhc28734 - 
         * Use weighted diffusion averaging when diffusion lobes are active 
         * for less than 5 minutes on a single axis.
         * If the scan calls for 5 minutes of DWI/DTI scanning on a
         * single axis, turn gradient optimization off 
         * gradient optimization = weighted_avg_grad (1 = on)
         * 5 min = 300000000 us
         */

        /* For SSSD, realtime over current check is introduced to avoid burning.
         * The time constant should be 60sec for the gradient optimization.
         */

        if ((PSD_ON == opdiffuse) || (PSD_ON == tensor_flag))
        {
            if(5550 == cfgradamp)
            {
                if(isK15TSystem())
                {   
                    /* HCSDM00479162: Insure the correct weighted_avg_grad value and keep the same performance as autoTR */
                    core_time = (float)intleaves * max_difnex * tmin_total * opslquant;
                }
                else
                {
                    core_time = (float)intleaves * max_difnex * (float)act_tr * act_acqs;
                }
            }
            else
            {
                if(((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_OFF)) || (tensor_flag == PSD_ON))
                {
                    core_time = (float)intleaves * max_difnex * (float)act_tr * act_acqs;
                }
                else
                {
                    core_time = (float)intleaves * total_difnex * opdifnumdirs * (float)act_tr * act_acqs;
                }
            }

            if(5550 == cfgradamp)
            {
                if((core_time >= 60000000.0) || (exist(opdifnumdirs) > 40))
                {
                    weighted_avg_grad = PSD_OFF;
                }
                else
                {
                    weighted_avg_grad = PSD_ON;
                }
            }
            else
            {
                if (core_time >= 300000000.0)
                {
                    weighted_avg_grad = PSD_OFF;
                }
                else
                {
                    weighted_avg_grad = PSD_ON;
                }
            }
        }
        else
        {
            weighted_avg_grad = PSD_ON;
        }
    }
    else
    {
        /* MRIhc 34431 - turn weighted_avg_grad off for non XRMB
         * systems */
        weighted_avg_grad = PSD_OFF;
    }

    if((mkgspec_x_sr_flag & MK_SPEC_SR_CHANGE) || (mkgspec_y_sr_flag & MK_SPEC_SR_CHANGE) || (mkgspec_z_sr_flag & MK_SPEC_SR_CHANGE) ||
        mkgspec_x_gmax_flag || mkgspec_y_gmax_flag || mkgspec_z_gmax_flag )
    {
        weighted_avg_grad = PSD_OFF;
    }

    if ((isRioSystem()) &&(exist(opdiffuse)==PSD_ON))
    {
            weighted_avg_grad = PSD_ON;
    }

    if (FAILURE == NavigatorEval())
    {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "NavigatorEval");
        return FAILURE;
    }

    if( (PSD_OFF == pircbnub) && (PSD_OFF == exist(opautorbw)) )
    {
        opautorbw = PSD_ON;
    }

    if(FAILURE == DTI_Eval()) {
        return FAILURE;
    } 


    /* HCSDM00455043 Set pidistcorr before setting rpg_flag */
    if (PSD_ON == exist(opdiffuse))
    {
        if ((PSD_ON == distcorr_status) && /* option key and HW check */
            (PSD_OFF == rfov_flag) && ((asset_factor/(float)(opnshots))<=0.5)) /* PSD options check */
        {
            pidistcorrnub = 2; /* Controls show/hide */
        }
        else
        {
            cvoverride(opdistcorr, PSD_OFF, PSD_FIX_ON, PSD_EXIST_ON);
            pidistcorrnub = 0; /* Controls show/hide */
        }
    }
    else
    {
        cvoverride(opdistcorr, PSD_OFF, PSD_FIX_ON, PSD_EXIST_ON);
        pidistcorrnub = 0;
    }
 
    /* Distortion correction using RPG based on pepolar. */
    if (PSD_ON == exist(opdistcorr))
    {
        rpg_flag = (PSD_ON == pepolar) ? RPG_FWD_THEN_REV : RPG_REV_THEN_FWD; /* Init according to bulk of scan */
    }
    else
    {
        rpg_flag = 0;   
    }
    
    /* Distortion Correction - set number of hidden T2 passes */
    rpg_in_scan_flag = (rpg_flag > 0) ? 1 : 0;
    if ((PSD_ON == rpg_in_scan_flag) && (PSD_ON == exist(opdiffuse)))
    {
        rpg_in_scan_num = (0 == exist(opdifnumt2)) ? 2: 1;
    }
    else
    {
        rpg_in_scan_num = 0;
    }


    /* Turn off >1 prescription group with rfov or HOECC */
    if (rfov_flag || hoecc_flag != PSD_OFF || mux_flag || rpg_flag || muse_flag )
        pimultigroup = PSD_OFF;
    else
        pimultigroup = PSD_ON;

    /* MRIhc27551 Pititle was set according to piuset */
    pititle = (piuset != 0);

    /* HCSDM00129469 */
    TGenh = 0.0;

    if ( PSD_OFF == mux_flag)
    {
    if ((opdiffuse == PSD_ON) && (cffield == B0_30000) &&
            ((cfgcoiltype == PSD_XRMB_COIL) || (cfgcoiltype == PSD_XRMW_COIL) || 
             (isRioSystem()) || (cfgcoiltype == PSD_VRMW_COIL)) &&
            ((TX_COIL_BODY == getTxCoilType()) && (isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_HEAD))))
    {
        if (!strcmp(get_psd_name(), "epi2cl"))
        {
            if (opentry == 1) /* Head first */
            {
                TGenh = -9.0;
            }
        }
        else
        {
            if (cfgcoiltype == PSD_VRMW_COIL)
            {
                TGenh = -8.0;
            }
            else
            {
                TGenh = -5.5; /* default */
            }
        }
    }
    }
    else
    {
        TGenh = 0.0; /* multiband */
    }

    if( (PSD_ON == exist(oprtcgate)) || (PSD_ON == exist(opnav)) )
    {
        piautovoice = 0;
    }
    else
    {
        piautovoice = 1;
    }

    info_fields_display(&piinplaneres,&pirbwperpix,&piesp,&ihinplanexres,
                        &ihinplaneyres,&ihrbwperpix,&ihesp,
                        DISP_INPLANERES|DISP_RBWPERPIX|DISP_ESP,
                        esp,
                        SCALE_INPLANEYRES_SQP);

    if(PSD_ON == vrgfsamp)
    {
       pirbwperpix = 0;
       ihrbwperpix = 0;
    }

    /* HCSDM00361682 */
    if(rfov_flag)
    {
        int i;
        for(i=MAX_FOCUS_EVAL_WATCH-1; i>0; i--)
        {
            avmaxslquant_hist[i] = avmaxslquant_hist[i-1];
            acqs_hist[i] = acqs_hist[i-1];
            tmin_hist[i] = tmin_hist[i-1];
        }
        avmaxslquant_hist[0] = avmaxslquant;
        acqs_hist[0] = acqs;
        tmin_hist[0] = tmin;
        if( ((tmin != tmin_hist[1])&&(tmin != tmin_hist[2])&&(tmin != tmin_hist[3])) && (0 == isPredownload) )
        {
            reset_oscil_in_eval = 1;
            oscil_eval_count = 0;
        }
        else
        {
            reset_oscil_in_eval = 0;
        }
        optr_save = exist(optr);
        opslquant_save = exist(opslquant);
    }
    else
    {
        int i;
        for(i=0; i<MAX_FOCUS_EVAL_WATCH; i++)
        {
            avmaxslquant_hist[i] = 0;
            acqs_hist[i] = 0;
            tmin_hist[i] = 0;
        }
        reset_oscil_in_eval = 0;
    }
    
    return SUCCESS;

}   /* end cveval() */

@inline ARC.e ARCsetup

void
init_ASPIR_TI( void )
{
    /* Activate advisory panel checks for TI */
    piadvmin = (piadvmin | (1<<PSD_ADVTI));
    piadvmax = (piadvmax | (1<<PSD_ADVTI));

    /* Set TI annotation */
    pititype = PSD_LABEL_TE_PREP;

    /* Only show Auto TI */
    pitinub = 2;
    piautoti = PSD_ON;  /* show Auto as an option */
    avmaxti = ASPIR_DWI_MAX_TI;
    cvmax(opti,ASPIR_DWI_MAX_TI);
    avminti = IMax(2, ASPIR_DWI_MIN_TI, aspir_minti);
    cvmin(opti,avminti);
    cvdef(opti, ASPIR_DWI_MIN_TI);
    pitidefval = ASPIR_DWI_MIN_TI;
    if(cffield == B0_15000)
    {
        T1eff = ASPIR_DWI_T1EFF_1HT;
        bcoeff = ASPIR_DWI_BCOEFF_1HT;
    }
    else
    {
        /* use 3T values for all other cffield */
        T1eff = ASPIR_DWI_T1EFF_3T;
        bcoeff = ASPIR_DWI_BCOEFF_3T;
    }

    /* Set Auto TI model for ASPIR. */
    /* ASPIR Auto TI for GAT/RTG/Navi uses fixed value. */
    if (exist(opcgate) || exist(oprtcgate) || navtrig_flag)
    {
        aspir_auto_ti_model = ASPIR_AUTO_TI_FIXED;
    }
    else
    {
        /* Auto TI caluculation will be performed by calc_ASPIR_TI() */
        aspir_auto_ti_model = ASPIR_AUTO_TI_ADAPTIVE;
    }
}

/**
 * @brief Computes fat nulling TI value for ASPIR.
 *
 * The function calculates null TI of ASPIR. This function refers #aspir_auto_ti_model 
 * to determine whether null TI uses predefined value or adaptive value with #act_tr.
 *
 * @param[in] num_slices    Total number of slices that are scanned per pass.
 * @return   Null TI for ASPIR with current discription.
 * 
 */
INT
calc_ASPIR_TI( int num_slices )
{
    int aspir_null_ti = 0;

    if (ASPIR_AUTO_TI_FIXED == aspir_auto_ti_model)
    {
        if (cffield == B0_15000)
        {
            aspir_null_ti =  ASPIR_DWI_1HT_TI;
        }
        else
        {
            /* use 3T value (110ms) for all other cffield for now */
            aspir_null_ti =  ASPIR_DWI_3T_TI;
        }
    }
    else
    {
        /* Adaptive Auto TI */
        aspir_null_ti = (int)(T1eff*log(2.0/(1.0+exp(-bcoeff*act_tr/num_slices/T1eff))));
        aspir_null_ti = aspir_null_ti/1000*1000; /*rounded to ms*/
    }

    return aspir_null_ti;
}

/**
 * @brief Sets TI value to pull down menu
 *
 * This function set input aspir TI value to pull down menu (#pitival2).
 * And if Auto TI is used (#opautoti), then overwrites #act_ti and #opti 
 * with the input ASPIR TI.
 * 
 * @param[in]    TI value that would be set.
 * @return    Void.
 *
 */
void
set_ASPIR_TI(int aspir_ti)
{
    /* display auto TI in pitival2 */
    pitival2 = aspir_ti;

    if (exist(opautoti))
    {
        act_ti = aspir_ti;
        cvoverride(opti, act_ti, PSD_FIX_OFF, PSD_EXIST_ON);
    }
}

/*
 * Set diffusion cyling related flags, called by cvinit and cveval()
 * */
static void SetCyclingCVs(void)
{
    if ((isRioSystem()) && (exist(opdiffuse)==PSD_ON))
    {
        dbdt_model = DBDTMODELRECT;
        if ( (exist(opdfaxall) >= PSD_ON) || (exist(optensor) >= PSD_ON) || (exist(opdfaxtetra) >= PSD_ON) )
        {
            diff_order_flag = 1;
        }
    }
    else
    {
        diff_order_flag = 0;
        dbdt_model = DBDTMODELRECT;
    }

    if (diff_order_flag > 0)
    {
        hsdab = 2;
    }
    else
    {
        hsdab = 1;
    }

    num_iters = 0;

    if (diff_order_flag == 1)
    {
        if ((exist(opdfaxtetra) >= PSD_ON) || (exist(optensor) >= PSD_ON) || (exist(opdfaxall) >= PSD_ON) )
        {
            num_iters = IMin(2, exist(opdifnumdirs), MAX_NUM_ITERS);
        }
    }
    else if (diff_order_flag == 2)
    {
        if ( (exist(opdfaxtetra) >= PSD_ON) || (exist(optensor) >= PSD_ON) || (exist(opdfaxall) >= PSD_ON) )
        {
            if ( exist(opdifnumt2) > 0)
            {
                num_iters = IMin(2, exist(opdifnumdirs) + 1, MAX_NUM_ITERS);
            }
            else
            {
                num_iters = IMin(2, exist(opdifnumdirs), MAX_NUM_ITERS);
            }
        }
    }

    /* Obl 3in1 opt */
    if( ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF) ||
         ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON))) &&
        (exist(opplane) == PSD_OBL) && (exist(opcoax) != PSD_OFF) )
    {
        /*Turn off obl_3in1_opt on Rio due to spherical gradient model enforced*/
        if (isRioSystem())
            obl_3in1_opt = PSD_OFF;
        else
            obl_3in1_opt = PSD_ON;
    }
    else
    {
        obl_3in1_opt = PSD_OFF;
    }
}


STATUS 
#ifdef __STDC__
setEpiEsp( void )
#else
    setEpiEsp()
#endif
{
    /* Minimum time between the endof one frame and beginning */
    /* of next is 50us in MGD DRF. */

    /* modify pw_gxwl,r1 to satisfy esp constraints */
    pw_gxwl1 = 0;
    pw_gxwr1 = 0;
    pw_gxwl2 = 0;
    pw_gxwr2 = 0;
    pw_gxwl = pw_gxwl1;
    pw_gxwr = pw_gxwr1;

    esp  = pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr + pw_gxgap;

    if (esp < minesp) {  /* is esp long enough? - if not, adjust pw_gxwl1,r2 */
        pw_gxwl1 = (minesp - esp)/2;
        pw_gxwr1 = pw_gxwl1;
        pw_gxwl = pw_gxwl1;
        pw_gxwr = pw_gxwr1;
        esp  = pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr + pw_gxgap;
    }

    if (vrgfsamp != PSD_ON) 
    {
        if ( (2*pw_gxwad + pw_gxwl1 + pw_gxwr1) < (pw_gyba + pw_gyb + pw_gybd) ) 
        {
            pw_gxwl1 = pw_gxwl1 + RUP_GRD(pw_gyb/2 + pw_gyba - pw_gxwad);
            pw_gxwr1 = pw_gxwr1 + RUP_GRD(pw_gyb/2 + pw_gyba - pw_gxwad);
            pw_gxwl = pw_gxwl1;
            pw_gxwr = pw_gxwr1;
            esp  = pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr + pw_gxgap;
        }

        {  
            /* make sure esp/intleaves is a multiple of (hardware period)*intleaves by adjusting pw_gxwl1,r1 */
            int tmp, esp_new;

            esp_new = esp;
            tmp = intleaves * hrdwr_period;
            if( (esp % tmp) != 0) esp_new = (esp/tmp + 1) * tmp;
            esp_new = IMax(2, esp_new, minesp);

            if( esp_new > esp ) {
                pw_gxwl1 = pw_gxwl1 + (esp_new - esp)/2;
                pw_gxwr1 = pw_gxwl1;
                pw_gxwl = pw_gxwl1;
                pw_gxwr = pw_gxwr1;
                esp  = pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr + pw_gxgap;
            }
        }
    } /* end if vrgfsamp != PSD_ON */

    /* Last check: Make sure the echo-spacing */
    /* does not violate the minimum time from the end */
    /* of one data frame to the beginning of the next */
    if( (esp - rhfrsize*tsp) <  MinFram2FramTime) {      
        pw_gxgap  = RUP_GRD((int)(MinFram2FramTime-(esp - rhfrsize*tsp)));

        /* Make sure added pw_gxgap/2 is on 4 us boundary */
        if ((pw_gxgap % pwmin_gap) != 0)
            pw_gxgap = (int)ceil((double)pw_gxgap / (double)pwmin_gap) * pwmin_gap;    
    } 

    /* Do the following in case pw_gxwl2 was modified by modify cvs */
    pw_gxwr2 = pw_gxwl2;
    pw_gxwl = pw_gxwl1 + pw_gxwl2;
    pw_gxwr = pw_gxwr1 + pw_gxwr2;
    esp  = pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr + pw_gxgap;

    /* total readout flat-top */
    pw_gxw_total = pw_gxwl + pw_gxw + pw_gxwr;  

    return SUCCESS;
}

STATUS
cveval1( void )
{
    const CHAR funcName[] = "cveval1";
    int icount;
    float xtarg_org = 0.0;

    if (exist(opslquant) == 3 && b0calmode == 1) {
        setb0rotmats();

        save_newgeo = opnewgeo;

        if (obloptimize_epi(&loggrd, &phygrd, scan_info, exist(opslquant),
                            PSD_OBL, 0, 1, obl_debug, &opnewgeo, cfsrmode)==FAILURE) {
            psd_dump_scan_info();
            epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cveval()" ); 
            return FAILURE;
        }
        
        /* BJM: MRIge47073 derate non readout waveforms */
        dbdtderate(&loggrd, 0);  
        
        /* call for epiloggrd */
        opnewgeo = save_newgeo;
        if (obloptimize_epi(&epiloggrd, &epiphygrd, scan_info, exist(opslquant),
                            PSD_OBL, 0, 1, obl_debug, &opnewgeo, cfsrmode)==FAILURE) {
            psd_dump_scan_info();
            epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cveval()" );
            return FAILURE;
        }    
        
    } else {
        
        save_newgeo = opnewgeo;
        if (obloptimize_epi(&loggrd, &phygrd, scan_info, exist(opslquant),
                            exist(opplane), exist(opcoax), obl_method,
                            obl_debug, &opnewgeo, cfsrmode)==FAILURE) {
            psd_dump_scan_info();
            epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cveval()" );
            return FAILURE; 
        }

        /* Obl 3in1 opt */
        if (obl_3in1_opt)
        {
            opnewgeo = save_newgeo;
            if (obloptimize_epi(&orthloggrd, &orthphygrd, orth_info, 1,
                                PSD_AXIAL, 1, obl_method,
                                obl_debug, &opnewgeo, cfsrmode)==FAILURE) { 
                epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cveval()" );
                return FAILURE;
            }
        }

        /* BJM: MRIge47073 derate non readout waveforms */
        dbdtderate(&loggrd, 0);

        /* Obl 3in1 opt */
        if (obl_3in1_opt)
        {
            dbdtderate(&orthloggrd, 0);
        }

        opnewgeo = save_newgeo;
        if (obloptimize_epi(&epiloggrd, &epiphygrd, scan_info, exist(opslquant),
                            exist(opplane), exist(opcoax), obl_method,
                            obl_debug, &opnewgeo, cfsrmode)==FAILURE) {
            psd_dump_scan_info();
            epic_error( use_ermes, "%s failed in %s.", EM_PSD_FUNCTION_FAILURE, EE_ARGS(2), STRING_ARG, "obloptimize_epi()", STRING_ARG, "cveval()" );
            return FAILURE; 
        }

    } /* end if (exist(opslquant) == 3 && b0calmode == 1) */

    /* Fill in the epigradopt input structure */
    if (autogap == 1) 
    {
        xtarg = epiloggrd.tx;
        ytarg = epiloggrd.ty;
        ztarg = epiloggrd.tz;
    } 
    else 
    {
        xtarg = epiloggrd.tx_xyz;
        ytarg = epiloggrd.ty_xyz;
        ztarg = epiloggrd.tz_xyz;
    }

    if(arc_extCal && oparc){
        asset_factor = arc_ph_factor;
    }

    xtarg_org = xtarg;

    if (PSD_ON == epi_loggrd_glim_flag)
    {
        xtarg = FMin(2, xtarg, epi_loggrd_glim);
    }

    /* Local block for calcualting tsp */
    {
        /* HALF_KHZ_USEC is from filter.h - need to change from cfcerdbw1 when */
        /* config name changes */
        float tsp_min = (HALF_KHZ_USEC /RBW_MAX);
        float act_rbw;
        float decimation;
        float max_rbw;
        int vrgf_rescale = 0; 
        float vrgf_ratio = 1.0; 
        float xtarg_temp = 0; 
 
        if (vrgfsamp == PSD_ON) 
        {
            
            rbw = 0.0;  /* calculate this for the vrgf case */
            
            /* Do this so rhfrsize remains low enough for current recon limitations */
            if (exist(opxres) <= 128) {
                vrgf_targ = 2.0;
            } else {
                vrgf_targ = 1.6;
            }

            /* 4x oversampling ratio desired */
            tsp = 1.0 / (GAM * xtarg * get_act_freq_fov() / 10.0) / (vrgf_targ / 1.0e6); /* parasoft-suppress BD-PB-ZERO  "divide by zero avoided by CV minimum value setting" */
                       
            /* Cant go lower than hardware sample period */
            if (tsp < tsp_min) 
            {
                tsp = tsp_min;
            }  

            /* Calculate desired RBW in kHz. */
            /* Note: this might not be valid if the */
            /* decimation required is not supported by */
            /* MGD.  Thus, we will check this calculation */
            /* below with calcvalidrbw() */
            /* Hz to kHz */
            rbw = ( 1.0 /(2.0*(tsp / 1.0s)) )/ 1000.0; /* parasoft-suppress BD-PB-ZERO  "divide by zero avoided by CV minimum value setting" */

            /* Check for a valid RBW */
            /* Calculate the rbw, decimation based on the */
            /* the supported MGD configuration */
            /* This function will return act_rbw with the nearest */
            /* valid value and also overwrite the value of oprbw  */

            if (vrgf_bwctrl)
            {
                rbw = exist(oprbw);
            }

            if (SUCCESS != calcvalidrbw(rbw, &act_rbw, &max_rbw, 
                                        &decimation, OVERWRITE_OPRBW, vrgfsamp))
            {
                return FAILURE;
            }
            
            /* Recalculate tsp now that we have a valid RBW */
            tsp = 1.0s*(1.0/(2.0*(1000.0*act_rbw)));
            /* MRIhc27257, MRIhc27350 : adjust vrgf oversampling factor according to the new tsp */
                
            vrgf_targ = 1/(tsp * GAM * xtarg * get_act_freq_fov() / 10.0) * 1.0e6;
            if (vrgf_targ < 1.0)
            {
                vrgf_targ = 1.0;
                xtarg_temp = xtarg;

                /* MRIhc27257, MRIhc27350: this process can compete with the
                 * taratio logic below by lowering the target amplitude. 
                 * However, taratio logic always
                 * reduces the target amplitude. Therefore, taratio 
                 * does not have
                 * impact on the frequency direction aliasing.   - SWL
                 */
                xtarg = 1.0 / (GAM * tsp * get_act_freq_fov() / 10.0) / (vrgf_targ / 1.0e6);
                if ( (xtarg <= cfxfs) && (xtarg >=0 ) )
                {
                    vrgf_ratio = xtarg / xtarg_temp;
                    vrgf_rescale = 1;
                }
                else
                {
                    return FAILURE;
                }
            }

            /* reset rbw */
            rbw = act_rbw;

        }   /* end if(vrgfsamp == PSD_ON) */ 
        else 
        {   /* non VRGF */ 
            
            /* first, check for a valid RBW */
            /* calculate the rbw, decimation based on the */
            if (SUCCESS != calcvalidrbw(exist(oprbw), &act_rbw, &max_rbw, 
                                        &decimation, OVERWRITE_OPRBW, vrgfsamp)) {
                return FAILURE;
            }

            /* tsp = echo1_filt.tsp;*/
            rbw = exist(oprbw); 

            /* Need to calculate tsp for epigradopt */
            tsp = 1.0s*(1.0/(2.0*(1000.0*rbw)));
            
        } 
    
        /* Round tsp (removes any small RO error) */
        tsp = (float)((floor)((tsp*10.0) + 0.5)/ 10.0);

        gradin.xfs = xtarg;
        gradin.yfs = ytarg;
        gradin.zfs = ztarg;
        gradin.xrt = ceil((float)epiloggrd.xrt*epiloggrd.scale_3axis_risetime * xtarg / xtarg_org);
        gradin.yrt = ceil((float)epiloggrd.yrt*epiloggrd.scale_3axis_risetime); /* HCSDM00339202 */
        gradin.zrt = ceil((float)epiloggrd.zrt*epiloggrd.scale_3axis_risetime);
        gradin.xbeta = epiloggrd.xbeta;
        gradin.ybeta = epiloggrd.ybeta;
        gradin.zbeta = epiloggrd.zbeta;
        gradin.xfov = rhfreqscale*exist(opfov)/10.0;   /* convert to cm */
        gradin.yfov = exist(opphasefov)*exist(opfov)*asset_factor/10.0; /* convert to cm */
    } /* end local block */
 
    if (vrgfsamp == PSD_OFF)
    {
        gradin.xres = rhfrsize;
    }
    else
    {
        gradin.xres = exist(opxres);
    }
    gradin.yres = (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor);
    
    if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY)
    {
        gradin.ileaves = intleaves/2;
    }
    else
    {
        gradin.ileaves = intleaves;
    }
    gradin.xdis = cfdbdtdx;
    gradin.ydis = cfdbdtdy;
    gradin.zdis = cfdbdtdz;
    gradin.tsp = tsp;
    gradin.osamps = osamp;
    gradin.fbhw = fbhw;
    gradin.vvp = hrdwr_period;
    pw_gxgap = 0;
 

    /* SXZ::MRIge72411: find taratio value for the current prescription */
    /* max k value */
    totarea = 1.0e6 * gradin.xres / (rhfreqscale * get_act_freq_fov() / 10.0 * (FLOAT)GAM);
    if( vrgfsamp == PSD_ON && rampopt == 1 ){
        int indx;
        for(indx = 0; indx < NODESIZE; indx++){
            if(totarea <= totarea_arr[indx]){
                if( indx == 0 ){
                    taratio = taratio_arr[indx];
                }else{ 
                    taratio = taratio_arr[indx-1] 
                        + (totarea-totarea_arr[indx-1])
                        /(totarea_arr[indx]-totarea_arr[indx-1])
                        *(taratio_arr[indx]-taratio_arr[indx-1]);
                }

                break;

            } else if(indx==NODESIZE-1) {

                taratio = taratio_arr[indx];
            }
        }
        if(isStarterSystem() && (isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_ABDOMEN))) 
        {
            taratio = 0.4;
        }
    }
    else{

        taratio = 0;
    }

    gradin.taratio = taratio;

    if ((use_slice_fov_shift_blips) && (mux_flag == PSD_ON) && (mux_slices_rf1 > 1)) {
        slice_fov_shift_cycles = (slice_fov_shift-1) / ((float) slice_fov_shift);
        slice_fov_shift_area = 1.0e6 * slice_fov_shift_cycles / (GAM * mux_slice_shift_mm_rf1 / 10.0);
        gradin.zarea = slice_fov_shift_area;
    }
    else
    {
        slice_fov_shift_area = 0.0;
        gradin.zarea = 0.0;
    }

    each_gradopt_count = 0;

    if((cffield >= B0_30000) && (PSD_HRMW_COIL == cfgcoiltype))
    {
        esprange_check = 1;
        espamp_check = 1;
    }
    else
    {
        esprange_check = 0;
        espamp_check = 0;
    }

    if(esprange_check == 1)
    {
        if(FAILURE == readEspRange())
        {
            return FAILURE;
        }
    }

    if((dbdt_model == DBDTMODELCONV) && isdbdtper())
    {
        if(optGradAndEsp_conv() == FAILURE)
        {
            reopt_flag = PSD_ON;
            return FAILURE;
        }
    }
    else if(esprange_check && isdbdtper())
    {
        if(optGradAndEsp_rect() == FAILURE)
        {
            reopt_flag = PSD_ON;
            return FAILURE;
        }
    }
    else
    {
        pw_gxgap = 0;
        dbdtper_new = cfdbdtper;
        if(epigradopt_rect(dbdtper_new, 0) == FAILURE)
        {
            reopt_flag = PSD_ON;
            return FAILURE;
        }
        if(epigradopt_debug) printEpigradoptLog();
    }

    rhfrsize = temprhfrsize;
    pidbdtper = FMax(2, pidbdtper, rfov_dbdtper); /* HCSDM00150820 */

    /* SXZ::MRIge72411: calc actual ratio */
    if(vrgfsamp == 1 && rampopt == 1){
        int tempvar;
        /* ramp area */
        tempvar = ((float)a_gxw*pw_gxwad-a_gxw*(pw_gyba+pw_gyb/2)*(pw_gyba+pw_gyb/2)/pw_gxwad);
        /* top area */
        tempvar = totarea - tempvar;

        actratio = tempvar/totarea;

    } else {

        actratio = 1;

    }

    /* MGD: call calcfilter() */
    if( FAILURE == (calcfilter(&echo1_filt, oprbw, rhfrsize, OVERWRITE_OPRBW)) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "calcfilter" );
        return FAILURE;
    }

    getminesp(echo1_filt, xtr_offset, intleaves, hrdwr_period, vrgfsamp, &minesp);

    /* There is a bug in epigradopt for non-vrg.  Bump up pw_gxwad */
    pw_gxwad = RUP_GRD(pw_gxwad);

    /* Also, epigradopt does not make pw_gxgap a mult. of 2*GRAD_UPDATE_TIME,
       so do it here (MRIge23911) */
    if ((pw_gxgap % pwmin_gap) != 0)
        pw_gxgap = (int)ceil((double)pw_gxgap / (double)pwmin_gap) * pwmin_gap;

    /* Need to set the decay of the blip to = the attack found in epgradopt() */
    pw_gybd = pw_gyba;

    /* Call to calculate the echo-sapcing (esp) */
    if( FAILURE == setEpiEsp() ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "setEpiEsp" );
        return FAILURE;
    }
    msamp = 0.0;
    dsamp = 0.0;                             /* Delta echo shift (tuning) */
    
    /* PW_GXW delta for GW1 calc */ 
    delpw = (msamp+dsamp)*tsp;
  
    /* Position of dephaser pulses: pre- or post- 180 */
    /* For GRE - the positions are post-180 to get the proper sign */  
    if (exist(oppseq) != PSD_SE) {              
        /* set the gx1 and gy1 position flags */
        cvoverride(gx1pos, PSD_POST_180,_gx1pos.fixedflag,_gx1pos.existflag);
        cvoverride(gy1pos, PSD_POST_180,_gy1pos.fixedflag,_gy1pos.existflag);
    }
    
    /* X dephaser pulse */
    
    gx1_area = a_gxw * ((float)pw_gxwad/2.0 + (float)pw_gxwl +
                        (float)pw_gxw/2.0 + delpw);
    
    /* The GRAM circuit may require shaped attack and decay ramps to
       facilitate a smooth transition between the ramp transition and
       adjacent pulse seqments.  A mechanism is provided in 5.5 to shape
       the waveform such that it begins as a parabola, transitions smoothly
       into a linear segment covering the center portion of the transition,
       and transitions smoothly into a parabolic segment (a mirror of the
       first parabolic component) to terminate the transition.  This
       composite waveform and its first deriviative are continuous from
       start to end.   A parameter called "beta," ranging form 0 to 1,
       specifies the portion of the ramp that is linear.  If beta is 1,
       the ramp is completely linear; if zero, the ramp is completely
       parabolic.  As a greater portion of the waveform becomes parabolic,
       the slope of the linear segment increases.  The absolute area under
       the "ramp" transition remains constant for any value of beta over
       its range [0..1].
       
       Please refer to the 5.5 General PSD Enhancements SRS.
       
       The wave shaping is performed at the low level ramp generation
       routine (w_ramp funciton in wg_linear.c, PGEN_WAVE project).
       
       In the readout echo planar pulse train, the first attack and last
       decay ramp will have different shapes than the other ramps.
       For VRG sampling, this results in an assymmetry in the first and
       last view of the train.  To circumvent this, the dephaser pulse
       can be moved up against the readout train, and the dephaser's
       decay and be combined with the first readout attack ramp.
       
       The following code make this determination.  */
    
    /* If epiloggrd.xrt == loggrd.xrt then dB/dt is not an issue and
       a single ramp is legal. */
    if (( gx1_area >= a_gxw*(float)pw_gxwad) && gx1pos == PSD_POST_180 &&
        epiloggrd.xrt == loggrd.xrt && hoecc_flag == PSD_OFF && (iref_etl == 0))
        single_ramp_gx1d = 1;
    else
        single_ramp_gx1d = 0;
    
    if (single_ramp_gx1d == PSD_ON) 
    {
        pw_gx1a = pw_gxwad;
        pw_gx1d = pw_gxwad;
        /* pw_gx1 must >= MIN_PLATEAU_TIME */
        pw_gx1 = IMax(2, RUP_GRD((int)(gx1_area/a_gxw - (float)pw_gx1a)), MIN_PLATEAU_TIME);
        a_gx1 = -gx1_area/(float)(pw_gx1a + pw_gx1);
    } 
    else 
    {
        if (gx1pos == PSD_POST_180)
            gx1_area *= -1;
        start_amp = 0.0;
        end_amp = 0.0;
        if (amppwgradmethod(&gradx[GX1_SLOT], gx1_area, loggrd.tx_xyz, start_amp,
                            end_amp, loggrd.xrt*loggrd.scale_3axis_risetime, MIN_PLATEAU_TIME) == FAILURE) 
	{
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gx1" );
            return FAILURE;
	}
    }
    
    pw_gx1_tot = pw_gx1a + pw_gx1 + pw_gx1d;
    
    if(iref_etl > 0)
    {
        if (amppwgradmethod(&gradx[GXDPC1_SLOT], gx1_area, loggrd.tx_xz, 0.0,
                    0.0, loggrd.xrt*loggrd.scale_2axis_risetime, MIN_PLATEAU_TIME) == FAILURE)
        {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxiref1" );
            return FAILURE;
        }
        if (amppwgradmethod(&gradx[GXDPCR_SLOT], gx1_area, loggrd.tx, 0.0,
                    0.0, loggrd.xrt, MIN_PLATEAU_TIME) == FAILURE)
        {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxirefr" );
            return FAILURE;
        }
        pw_gxiref1_tot = pw_gxiref1a + pw_gxiref1 + pw_gxiref1d;
        pw_gxiref_tot = esp*iref_etl;
        pw_gxirefr_tot = pw_gxirefra + pw_gxirefr + pw_gxirefrd;
    }
    else
    {
        pw_gxiref1_tot = 0;
        pw_gxiref_tot = 0;
        pw_gxirefr_tot = 0;
    }
    
    /* At this point, we know the timing for the basic parameters for
       the echo planar gradient train: amplitudes and pulse widths of
       readout and phase encoding trapezoids, excluding the y axis
       dephaser.
       
       To compute the advisory panel minimum TE, first calculate the
       other timing elements, such as slice select axis timing, killer
       pulses, diffusion, etc.  Then proceed with advisory calculations,
       finishing up with calculation of the phase encoding dephaser,
       ky_offset, rhhnover, etc. */
    
    
    /***** Slice select timing ****************************************/

    if (ssgr_mux && (a_gzrf1 > 0.0)) 
    {
        a_gzrf1 = -a_gzrf1;
    }

    if ((PSD_OFF == rfov_flag) && (PSD_OFF == mux_flag))
    {
        if (ampslice(&a_gzrf1, bw_rf1, exist(opslthick), gscale_rf1, TYPDEF)
            == FAILURE)
        {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "ampslice" );
            return FAILURE;
        }
        /* optimize attack and decay ramps */
        if (optramp(&pw_gzrf1d, a_gzrf1, loggrd.tz_xyz, loggrd.zrt*loggrd.scale_3axis_risetime, TYPDEF) == FAILURE)
        {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gzrf1d" );
            return FAILURE;
        }
        if (pw_gzrf1d < 300)
            pw_gzrf1a = RUP_GRD(300);
        else
            pw_gzrf1a = pw_gzrf1d;
    }

    /* For RFOV, we change the RF2 thickness to balance between the slice aliasing and SNR. */
    if (rfov_flag && (exist(opslspace) > 0))
    {
        temp_slthick = exist(opslthick) + (exist(opslspace) > 1.0 ? 1.0 : exist(opslspace));
    }
    else
    {
        temp_slthick = exist(opslthick);
    }

    if (ampslice(&a_gzrf2, bw_rf2, temp_slthick, gscale_rf2, TYPDEF)== FAILURE)
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "ampslice:a_gzrf2" );
        return FAILURE;
    }

    /* DTI BJM: (dsp) set gradient amps for refocusing */
    if (PSD_ON == dualspinecho_flag)
    {
        a_gzrf2left = a_gzrf2;
        a_gzrf2right = a_gzrf2;
    }

    ivslthick = get_act_phase_fov();
    if (ampslice(&a_gyrf2iv, bw_rf2, ivslthick, gscale_rf2, TYPDEF) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "ampslice:a_gyrf2iv" );
        return FAILURE;
    }
    
    gradz[GZRF1_SLOT].num = 1;
    gradz[GZK_SLOT].num = 1;
    
    if (exist(oppseq) == PSD_SE) 
    {
        if (innerVol == PSD_ON) 
	{  /* refocus pulse on logical Y */
            gradz[GZRF2_SLOT].num = 0;
            grady[GYRF2IV_SLOT].num = 1;
            if (optramp(&pw_gyrf2iva, loggrd.ty_xyz, loggrd.ty, loggrd.yrt*loggrd.scale_3axis_risetime, TYPDEF)
                == FAILURE) 
	    {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gyrf2iva" );
                return FAILURE;
	    }
            pw_gyrf2ivd = pw_gyrf2iva;
	} 
        else 
	{  /* refocus pulse on logical Z */
            gradz[GZRF2_SLOT].num = 1;
            grady[GYRF2IV_SLOT].num = 0;
	}
        gradz[GZRF2L1_SLOT].num = 1;
        gradz[GZRF2R1_SLOT].num = 1;
        gradz[GZRF2_SLOT].num = 1;

        /* DTI need to accout for extra RF2 pulse */
        if (PSD_ON == dualspinecho_flag)
        {
            rfpulse[RF2_SLOT].num = 2;
        }
        else
        {
            rfpulse[RF2_SLOT].num = 1;
        }
    } 
    else 
    {
        gradz[GZRF2_SLOT].num = 0;
        grady[GYRF2IV_SLOT].num = 0;
        gradz[GZRF2L1_SLOT].num = 0;
        gradz[GZRF2R1_SLOT].num = 0;
        gradz[GZRF2_SLOT].num = 0;
        rfpulse[RF2_SLOT].num = 0;
    }
    
    rfpulse[RF1_SLOT].num = 1;
	
    if (optramp(&pw_gzrf2l1a, loggrd.tz_xyz, loggrd.tz, loggrd.zrt*loggrd.scale_3axis_risetime, TYPDEF) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "optramp:pw_gzrf2l1a" );
        return FAILURE;
    }
    
    if (optramp(&pw_gzrf2l1d, fabs(a_gzrf2l1-a_gzrf2), loggrd.tz_xyz*loggrd.scale_3axis_risetime,
                loggrd.zrt*loggrd.scale_3axis_risetime, TYPDEF) == FAILURE)
        return FAILURE;
    
    crusher_type = PSD_TYPCMEMP;
    if (crusherutil(crusher_scale, crusher_type) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "crusherutil" );
        return FAILURE;
    }
    
    /* The CVs c1_scale, c2_scale, ... are maintained for bay testing. */
    c1_scale = FMax(2, crusher_scale[0], 3.0);
    area_std = pw_gzrf2*a_gzrf2/2;   
    /* c1_scale = (crusher_cycles*1e7)/(area_std*GAM*opslthick); */
    
    if(exist(oppseq)==PSD_SE)  /* call only is spin echo sequence  */
    {
        if(((PSD_OFF == dualspinecho_flag) && (xygradCrusherFlag == PSD_ON)) ||
           ((PSD_ON == dualspinecho_flag) && ((xygradLeftCrusherFlag == PSD_ON) || (xygradRightCrusherFlag == PSD_ON))))
        {
            if ((amppwcrush(&gradz[GZRF2R1_SLOT], &gradz[GZRF2L1_SLOT],
                            (int)1, c1_scale, FMin(3, loggrd.tx_xyz, loggrd.ty_xyz, loggrd.tz_xyz), 
                            a_gzrf2, area_std, MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime) == FAILURE))
            {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwcrush" );
                return FAILURE;
            }
        }
        else
        {
            if ((amppwcrush(&gradz[GZRF2R1_SLOT], &gradz[GZRF2L1_SLOT],
                            (int)1, c1_scale, loggrd.tz_xyz, a_gzrf2, area_std,
                            MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime) == FAILURE)) 
            {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwcrush" );
                return FAILURE;
            }
        }
    }

    /* Include gz1 and gzmn in gradient duty cycle calc. MRIge37148 YP Du */
    gradz[GZ1_SLOT].num = 1;
    
    if ( existcv(opfcomp) && exist(opfcomp) == PSD_ON)
        gradz[GZMN_SLOT].num = 1;
    
    /* *******************************************************
       Left Crusher for 1st 180 (handles 90 pulse rephasing)
       Calc area needed for z rephaser for amppwlcrsh routine.
    *******************************************************/

    if (rfov_flag)
    {
        area_gz1 = a_gzrf1 * (ex_pw_constantz + ex_pw_rampz) * ex_refocus_ratioz;
    }
    else
    {   
        /* spsp area needed for rephaser */
        avail_pwgz1 = TR_MAX;
        area_gz1 = ((float)rfExIso + (float)pw_gzrf1d/2.0)*a_gzrf1;
        if(PSD_OFF == mux_flag)
        {
            if (ssEval1() == FAILURE) return FAILURE;  /* redefine area_gz1 for spectral-spatial pulse */

            if(ss_rf1 == PSD_OFF)
                area_gz1 = ((float)rfExIso + (float)pw_gzrf1d/2.0)*a_gzrf1;
        }
    }
    
    /* Find modification needed for gz1 to take into account need to incorporate first Gz blip */
    if ((use_slice_fov_shift_blips) && (mux_flag == PSD_ON) && (mux_slices_rf1 > 1)) {
        /* Modification of Gz blip area for user CV FOV shift control */
        slice_fov_shift_cycles = (slice_fov_shift-1) / ((float) slice_fov_shift);
        slice_fov_shift_area = 1.0e6 * slice_fov_shift_cycles / (GAM * mux_slice_shift_mm_rf1 / 10.0);


        if (floatsAlmostEqualEpsilons(area_gz1, 0.0, 2) || floatsAlmostEqualEpsilons(slice_fov_shift_area, 0.0, 2) )
        {
            factor_gz1 = 0.0;
        }
        else
        {
            factor_gz1 = 1.0;
        }
    }
    else
    {
        factor_gz1 = 1.0;
    }
 
    if (zgmn_type == CALC_GMN1) 
    {
        /* Set time origin for moment calculation at end of gzrf1d decay ramp.
           Therefore the gzrf1 pulse is time reversed. */
        pulsepos = 0;
        zeromomentsum = 0.0;
        firstmomentsum = 0.0;
        invertphase = 0;
        
        if (ss_rf1 == PSD_ON) 
        {
            zeromomentsum = gz1_zero_moment;
            firstmomentsum = gz1_first_moment;
        }
        else 
        {
            rampmoments(0.0, a_gzrf1, pw_gzrf1d, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf1, a_gzrf1, rfExIso, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
        }

        if (exist(oppseq) == PSD_SE) 
        {
            /* Make left and right crushers mirror images of each other */
            a_gzrf2l1 = a_gzrf2r1;
            pw_gzrf2l1d = pw_gzrf2r1a;
            pw_gzrf2l1 = pw_gzrf2r1;
            pw_gzrf2l1a = pw_gzrf2r1d;
            pulsepos = -(rfExIso + pw_gzrf1d) + exist(opte) -
                (pw_gzrf2l1a + pw_gzrf2l1 + pw_gzrf2l1d + pw_gzrf2/2);
            rampmoments(0.0, a_gzrf2l1, pw_gzrf2l1a, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2l1, a_gzrf2l1, pw_gzrf2l1, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2l1, a_gzrf2, pw_gzrf2l1d, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2, a_gzrf2, pw_gzrf2/2, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            invertphase = 1;
            rampmoments(a_gzrf2, a_gzrf2, pw_gzrf2/2, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2, a_gzrf2r1, pw_gzrf2r1a, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2r1, a_gzrf2r1, pw_gzrf2r1, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gzrf2r1, 0.0, pw_gzrf2r1d, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            avail_zflow_time = exist(opte) - (rfExIso + pw_gzrf1d + pw_gzrf2l1a +
                pw_gzrf2l1 + pw_gzrf2l1d +
                pw_gzrf2/2);
            firstmomentsum *= -1.0;
        }
        else 
        {  /* gradient recalled echo */
            avail_zflow_time = exist(opte) - (rfExIso + pw_gzrf1d);
        }

        /* Calculate the z moment nulling pulses: gz1, gzmn */
        if (amppwgmn(zeromomentsum, firstmomentsum, 0.0, 0.0, avail_zflow_time,
                     loggrd.zbeta, loggrd.tz_xyz, loggrd.zrt*loggrd.scale_3axis_risetime, MIN_PLATEAU_TIME,
                     &a_gz1, &pw_gz1a, &pw_gz1, &pw_gz1d, &a_gzmn, &pw_gzmna,
                     &pw_gzmn, &pw_gzmnd) == FAILURE) {
            /* don't trap the failure here; this will drive minimum te */
        }
        a_gz1 *= -1.0;  /* Invert gz1 pulse */
    } 
    else 
    {        /* zgmn_type != CALC_GMN1 */
        pw_gzmna = 0;
        pw_gzmn = 0;
        pw_gzmnd = 0;

        if (exist(oppseq) != PSD_SE) 
        {
            if (amppwgz1(&a_gz1, &pw_gz1, &pw_gz1a, &pw_gz1d, area_gz1,
                         avail_pwgz1, MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime,
                         loggrd.tz_xyz) == FAILURE) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgz1" );
                return FAILURE;
            }
        }
        else 
        {
            if ((use_slice_fov_shift_blips) && (mux_flag == PSD_ON) && (mux_slices_rf1 > 1) && (slice_fov_shift_area > 0.0)) {
                if(dpc_flag)
                {
                    if (amppwgz1(&a_gz1, &pw_gz1, &pw_gz1a, &pw_gz1d, fabs(slice_fov_shift_area/2) + fabs(area_gz1),
                                avail_pwgz1, MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime,
                                loggrd.tz_xyz) == FAILURE)
                    {
                        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgz1" );
                        return FAILURE;
                    }
                }
                else
                {
                    if (amppwgz1(&a_gz1, &pw_gz1, &pw_gz1a, &pw_gz1d, slice_fov_shift_area/2,
                                avail_pwgz1, MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime,
                                loggrd.tz_xyz) == FAILURE) {
                        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgz1" );
                        return FAILURE;
                    }
                }
            }
            else if(rtb0_flag || dpc_flag)
            {
                if (amppwgz1(&a_gz1, &pw_gz1, &pw_gz1a, &pw_gz1d, area_gz1,
                             avail_pwgz1, MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime,
                             loggrd.tz_xyz) == FAILURE) {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgz1" );
                    return FAILURE;
                }
            }
            else
            {
                a_gz1 = 0.0;
                pw_gz1a = 0;
                pw_gz1 = 0;
                pw_gz1d = 0;
            }

            if(!dpc_flag)
            {
                if(((PSD_OFF == dualspinecho_flag) && (xygradCrusherFlag == PSD_ON)) ||
                        ((PSD_ON == dualspinecho_flag) && ((xygradLeftCrusherFlag == PSD_ON) || (xygradRightCrusherFlag == PSD_ON))))
                {
                    if (amppwlcrsh(&gradz[GZRF2L1_SLOT], &gradz[GZRF2R1_SLOT],
                                area_gz1*((ssgr_flag && (!dualspinecho_flag)) ? -1 : 1), 
                                a_gzrf2, FMin(3, loggrd.tx_xyz, loggrd.ty_xyz, loggrd.tz_xyz),
                                MIN_PLATEAU_TIME, loggrd.zrt*loggrd.scale_3axis_risetime, &pw_gzrf2a) == FAILURE)
                    {
                        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwlcrush" );
                        return FAILURE;
                    }
                }
                else
                {
                    if (amppwlcrsh(&gradz[GZRF2L1_SLOT], &gradz[GZRF2R1_SLOT],
                                area_gz1*((ssgr_flag && (!dualspinecho_flag)) ? -1 : 1), 
                                a_gzrf2, loggrd.tz_xyz, MIN_PLATEAU_TIME,
                                loggrd.zrt*loggrd.scale_3axis_risetime, &pw_gzrf2a) == FAILURE) 
                    {
                        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwlcrush" );
                        return FAILURE;
                    }
                }
            }
        }
    }  /* 	if (zgmn_type == CALC_GMN1) */

    pw_gz1_tot = pw_gz1a + pw_gz1 + pw_gz1d + pw_gzmna + pw_gzmn + pw_gzmnd;
    
    if (!rfov_flag && !mux_flag)
    {
        if (ssEval2() == FAILURE) return FAILURE;
    }

    /* DTI */
    if (PSD_OFF == dualspinecho_flag)
    {
        /* MRIhc05259 Insure that X, Y Crushers are off for non DSE case */
        xygradLeftCrusherFlag = PSD_OFF;
        xygradRightCrusherFlag = PSD_OFF;
        xygradCrusherFlag = PSD_OFF;
        if(opslthick < 3.0) {
            xygradCrusherFlag = PSD_ON;
        } else {
            xygradCrusherFlag = PSD_OFF;
        }
        LeftCrusherRSlop=0;
        LeftCrusherLSlop=0;
        RightCrusherLSlop=0;
        RightCrusherRSlop=0;

        if( PSD_OFF == xygradCrusherFlag ) {
            a_xgradCrusherL = 0;
            a_xgradCrusherR = 0;
            a_ygradCrusherL = 0;
            a_ygradCrusherR = 0;
        } else {
            a_xgradCrusherL = a_gzrf2r1;
            a_xgradCrusherR = a_gzrf2r1;
            a_ygradCrusherL = a_gzrf2r1;
            a_ygradCrusherR = a_gzrf2r1;
        }

        if( PSD_ON == xygradCrusherFlag ) {
            CrusherLSlop=0;
            CrusherRSlop=0;
            pw_xgradCrusherL = IMax(2,pw_gzrf2r1, pw_gzrf2l1);
            pw_xgradCrusherR = IMax(2,pw_gzrf2r1, pw_gzrf2l1);
            pw_xgradCrusherLa = IMax(2,pw_gzrf2r1a,pw_gzrf2r1d);
            pw_xgradCrusherRa = IMax(2,pw_gzrf2r1a,pw_gzrf2r1d);
            pw_xgradCrusherLd = pw_xgradCrusherLa;
            pw_xgradCrusherRd = pw_xgradCrusherRa;
            pw_ygradCrusherL = IMax(2,pw_gzrf2r1, pw_gzrf2l1);
            pw_ygradCrusherR = IMax(2,pw_gzrf2r1, pw_gzrf2l1);
            pw_ygradCrusherLa = IMax(2,pw_gzrf2r1a,pw_gzrf2r1d);
            pw_ygradCrusherRa = IMax(2,pw_gzrf2r1a,pw_gzrf2r1d);
            pw_ygradCrusherLd = pw_ygradCrusherLa;
            pw_ygradCrusherRd = pw_ygradCrusherRa;
            if(pw_xgradCrusherL-pw_gzrf2l1 > 0) {
                 CrusherLSlop += (pw_xgradCrusherL-pw_gzrf2l1);
            }
            if(pw_xgradCrusherR-pw_gzrf2r1 > 0) {
                 CrusherRSlop += (pw_xgradCrusherR-pw_gzrf2r1);
            }
            if(pw_xgradCrusherLa-pw_gzrf2l1a > 0) {
                 CrusherLSlop += (pw_xgradCrusherLa-pw_gzrf2l1a);
            }
            if(pw_xgradCrusherRa-pw_gzrf2r1a > 0) {
                 CrusherRSlop += (pw_xgradCrusherRa-pw_gzrf2r1a);
            }
            if(pw_xgradCrusherLd-pw_gzrf2l1d > 0) {
                 CrusherLSlop += (pw_xgradCrusherLd-pw_gzrf2l1d);
            }
            if(pw_xgradCrusherRd-pw_gzrf2r1d > 0) {
                 CrusherRSlop += (pw_xgradCrusherRd-pw_gzrf2r1d);
            }
        } else {
            CrusherLSlop=0;
            CrusherRSlop=0;
            pw_xgradCrusherL = 0;
            pw_xgradCrusherR = 0;
            pw_xgradCrusherLa = 0;
            pw_xgradCrusherRa = 0;
            pw_xgradCrusherLd = 0;
            pw_xgradCrusherRd = 0;
            pw_ygradCrusherL = 0;
            pw_ygradCrusherR = 0;
            pw_ygradCrusherLa = 0;
            pw_ygradCrusherRa = 0;
            pw_ygradCrusherLd = 0;
            pw_ygradCrusherRd = 0;
        }

        pw_gzrf2a = pw_gzrf2l1d;
        pw_gzrf2d = pw_gzrf2r1a;
        pw_gzrf2l1_tot = pw_gzrf2l1a + pw_gzrf2l1 + pw_gzrf2l1d + CrusherLSlop;
        pw_gzrf2r1_tot = pw_gzrf2r1a + pw_gzrf2r1 + pw_gzrf2r1d + CrusherRSlop;

        pw_gzrf2l1_tot_bval = pw_gzrf2l1a + pw_gzrf2l1 + pw_gzrf2l1d + CrusherLSlop;
        pw_gzrf2r1_tot_bval = pw_gzrf2r1a + pw_gzrf2r1 + pw_gzrf2r1d + CrusherRSlop;

    } else {
        /* MRIhc05259 Require Left side crusher only if opslthick < 4.0 */
        xygradLeftCrusherFlag = PSD_ON;
        xygradRightCrusherFlag = PSD_OFF;
        xygradCrusherFlag = PSD_OFF;

        CrusherLSlop=0;
        CrusherRSlop=0;

        /* MRIhc05259 Require Right side crusher only if opslthick < 2.1 mm */
        if(opslthick < 2.1) {
        xygradRightCrusherFlag = PSD_ON;
        }
        else {
        xygradRightCrusherFlag = PSD_OFF;
        }

        /* BJM: this section sets the pulse widths and amps for */
        /* the 180 refocusing pulses. Since the code already sets these up */
        /* for normal spin-echo epi, I use those results.  The "left" gzrf2 */
        /* pulse is closest to the 90 while the "right" gzrf2 pulse is closest to */
        /* the readout.  While I realize this is not the most intuitive naming convention */
        /* at least it is consistent with previous non-intutivie epic naming conventions */
        /* Note: the gz1 area is combined with the "l1" crusher under */
        /* normal conditions.  The same is done here except it is only done for the */
        /* "l1" cursher associated witht the "left" gzrf2 pulse */

        /* amps of non-symmetric left pulse - account for area_gz1 */
        a_gzrf2leftl1 = a_gzrf2l1;
        a_gzrf2leftr1 = a_gzrf2r1;

        /* amps of symmetric right pulse */
        a_gzrf2rightl1 = a_gzrf2r1;
        a_gzrf2rightr1 = a_gzrf2r1;


        /* MRIhc05227 */
        /* Duplicate amps of Z right 180 right-side crusher for X and Y to  */
        /* avoid unequal amplitude associated with including area_gz1 on */
        /* left 180 left-side crusher */

        if( PSD_OFF == xygradRightCrusherFlag ) {
            a_xgradRightCrusherL = 0;
            a_xgradRightCrusherR = 0;
            a_ygradRightCrusherL = 0;
            a_ygradRightCrusherR = 0; 
        } else {
            a_xgradRightCrusherL = a_gzrf2rightr1;
            a_xgradRightCrusherR = a_gzrf2rightr1;
            a_ygradRightCrusherL = a_gzrf2rightr1;
            a_ygradRightCrusherR = a_gzrf2rightr1;
        }
        if( PSD_OFF == xygradLeftCrusherFlag ) {
            a_xgradLeftCrusherL = 0;
            a_xgradLeftCrusherR = 0;
            a_ygradLeftCrusherL = 0;
            a_ygradLeftCrusherR = 0;
        } else {
            a_xgradLeftCrusherL = a_gzrf2leftr1;
            a_xgradLeftCrusherR = a_gzrf2leftr1;
            a_ygradLeftCrusherL = a_gzrf2leftr1;
            a_ygradLeftCrusherR = a_gzrf2leftr1;
        } 


        /* pw_gzrf2leftl1 = pw_gzrf2l1 since gz1 pulse combine with crusher */
        /* left crusher on "left" pulse */
        pw_gzrf2leftl1a = pw_gzrf2l1a;   /* r1d */
        pw_gzrf2leftl1d = pw_gzrf2l1d;   /* r1a */

        {

            /* Area of crusher */  
            float AreaLeftl1 = a_gzrf2l1*(pw_gzrf2l1+(pw_gzrf2l1a+pw_gzrf2l1d)/2);           

            /* Added ability to double the area */
            if(unbalanceCrusher == PSD_OFF) {
               
                pw_gzrf2leftl1 = pw_gzrf2l1;
               
            } else {
               
                /* Recalc flattop */                
                pw_gzrf2leftl1 = RUP_GRD((crusherFactorLeft*AreaLeftl1)/a_gzrf2l1 - (pw_gzrf2l1a+pw_gzrf2l1d)/2);
                if(pw_gzrf2leftl1 < GRAD_UPDATE_TIME) pw_gzrf2leftl1 = GRAD_UPDATE_TIME; 
               
            }
           
            /* right crusher on "left" pulse */
            pw_gzrf2leftr1a = pw_gzrf2r1a;
            pw_gzrf2leftr1d = pw_gzrf2r1d;
            pw_gzrf2leftr1 = pw_gzrf2r1;
           
            /* Added ability to double the area */
            if(unbalanceCrusher == PSD_OFF) {
               
                pw_gzrf2leftr1 = pw_gzrf2r1;
               
            } else {
                         
                /* Calculate original area of r1 crusher & add any additional area from l1 */
                float origAreaLeftr1 = a_gzrf2r1*(pw_gzrf2r1+(pw_gzrf2r1a+pw_gzrf2r1d)/2);
                float area2Add = (crusherFactorLeft-1)*AreaLeftl1;

                pw_gzrf2leftr1 = RUP_GRD((origAreaLeftr1+area2Add)/a_gzrf2r1 - (pw_gzrf2r1a+pw_gzrf2r1d)/2);
                if(pw_gzrf2leftr1 < GRAD_UPDATE_TIME) pw_gzrf2leftr1 = GRAD_UPDATE_TIME; 
               
            }
           
        }

        pw_gzrf2lefta = pw_gzrf2leftl1d;
        pw_gzrf2leftd = pw_gzrf2leftr1a;

        /* left crusher on "right" pulse */
        pw_gzrf2rightl1a = pw_gzrf2r1d;
        pw_gzrf2rightl1d = pw_gzrf2r1a;

        /* Added ability to double the area */
        if(unbalanceCrusher == PSD_OFF) {

            pw_gzrf2rightl1 = pw_gzrf2r1;

        } else {
            
            float origAreaRightl1 =  a_gzrf2r1*(pw_gzrf2r1+(pw_gzrf2r1a+pw_gzrf2r1d)/2);         
            pw_gzrf2rightl1 = RUP_GRD((crusherFactorRight*origAreaRightl1)/a_gzrf2r1-(pw_gzrf2r1a+pw_gzrf2r1d)/2);
            if(pw_gzrf2rightl1 < GRAD_UPDATE_TIME) pw_gzrf2rightl1 = GRAD_UPDATE_TIME; 

        }

        /* right crusher on "right" pulse */
        pw_gzrf2rightr1a = pw_gzrf2r1a;
        pw_gzrf2rightr1d = pw_gzrf2r1d;

        /* Added ability to double the area */
        if(unbalanceCrusher == PSD_OFF) {

            pw_gzrf2rightr1 = pw_gzrf2r1;

	} else {
       
            float origAreaRightr1 =  a_gzrf2r1*(pw_gzrf2r1+(pw_gzrf2r1a+pw_gzrf2r1d)/2);         
            pw_gzrf2rightr1 = RUP_GRD((crusherFactorRight*origAreaRightr1)/a_gzrf2r1-(pw_gzrf2r1a+pw_gzrf2r1d)/2);
            if(pw_gzrf2rightr1 < GRAD_UPDATE_TIME) pw_gzrf2rightr1 = GRAD_UPDATE_TIME; 

	}			
  
        pw_gzrf2righta = pw_gzrf2rightl1d;
        pw_gzrf2rightd = pw_gzrf2rightr1a;
        pw_gzrf2l1_tot = (pw_gzrf2leftl1a + pw_gzrf2leftl1 + pw_gzrf2leftl1d) + 
            (pw_gzrf2leftr1a + pw_gzrf2leftr1 + pw_gzrf2leftr1d);
        pw_gzrf2r1_tot = (pw_gzrf2rightl1a + pw_gzrf2rightl1 + pw_gzrf2rightl1d) + 
            (pw_gzrf2rightr1a + pw_gzrf2rightr1 + pw_gzrf2rightr1d);
      
        /* MRIhc05227 */
        /* Duplicate pulse widths of Z crushers for X and Y crushers */
        /* Use longer attack/decay pulse width to avoid gradient faults */
        /* for very thin slices.  Calculate add'l time and add to Slop */
        if( PSD_ON == xygradRightCrusherFlag ) {
            RightCrusherLSlop=0;
            RightCrusherRSlop=0;
            pw_xgradRightCrusherL = IMax(2,pw_gzrf2rightr1, pw_gzrf2rightl1);
            pw_xgradRightCrusherR = IMax(2,pw_gzrf2rightr1, pw_gzrf2rightl1);
            pw_xgradRightCrusherLa = IMax(2,pw_gzrf2rightr1a,pw_gzrf2rightr1d);
            pw_xgradRightCrusherRa = IMax(2,pw_gzrf2rightr1a,pw_gzrf2rightr1d);
            pw_xgradRightCrusherLd = pw_xgradRightCrusherLa;
            pw_xgradRightCrusherRd = pw_xgradRightCrusherRa;
            pw_ygradRightCrusherL = IMax(2,pw_gzrf2rightr1, pw_gzrf2rightl1);
            pw_ygradRightCrusherR = IMax(2,pw_gzrf2rightr1, pw_gzrf2rightl1);
            pw_ygradRightCrusherLa = IMax(2,pw_gzrf2rightr1a,pw_gzrf2rightr1d);
            pw_ygradRightCrusherRa = IMax(2,pw_gzrf2rightr1a,pw_gzrf2rightr1d);
            pw_ygradRightCrusherLd = pw_ygradRightCrusherLa;
            pw_ygradRightCrusherRd = pw_ygradRightCrusherRa;
            if(pw_xgradRightCrusherL-pw_gzrf2rightl1 > 0) {
                 RightCrusherLSlop += (pw_xgradRightCrusherL-pw_gzrf2rightl1);
            }
            if(pw_xgradRightCrusherR-pw_gzrf2rightr1 > 0) {
                 RightCrusherRSlop += (pw_xgradRightCrusherR-pw_gzrf2rightr1);
            }
            if(pw_xgradRightCrusherLa-pw_gzrf2rightl1a > 0) {
                 RightCrusherLSlop += (pw_xgradRightCrusherLa-pw_gzrf2rightl1a);
            }
            if(pw_xgradRightCrusherRa-pw_gzrf2rightr1a > 0) {
                 RightCrusherRSlop += (pw_xgradRightCrusherRa-pw_gzrf2rightr1a);
            }
            if(pw_xgradRightCrusherLd-pw_gzrf2rightl1d > 0) {
                 RightCrusherLSlop += (pw_xgradRightCrusherLd-pw_gzrf2rightl1d);
            }
            if(pw_xgradRightCrusherRd-pw_gzrf2rightr1d > 0) {
                 RightCrusherRSlop += (pw_xgradRightCrusherRd-pw_gzrf2rightr1d);
            }
        } else {
            RightCrusherLSlop=0;
            RightCrusherRSlop=0;
            pw_xgradRightCrusherL = 0;
            pw_xgradRightCrusherR = 0;
            pw_xgradRightCrusherLa = 0;
            pw_xgradRightCrusherRa = 0;
            pw_xgradRightCrusherLd = 0;
            pw_xgradRightCrusherRd = 0;
            pw_ygradRightCrusherL = 0;
            pw_ygradRightCrusherR = 0;
            pw_ygradRightCrusherLa = 0;
            pw_ygradRightCrusherRa = 0;
            pw_ygradRightCrusherLd = 0;
            pw_ygradRightCrusherRd = 0;
        }
        if( PSD_ON == xygradLeftCrusherFlag ) {
            LeftCrusherLSlop=0;
            LeftCrusherRSlop=0;
            pw_xgradLeftCrusherL = IMax(2,pw_gzrf2leftl1,pw_gzrf2leftr1);
            pw_xgradLeftCrusherR = IMax(2,pw_gzrf2leftl1,pw_gzrf2leftr1);
            pw_xgradLeftCrusherLa = IMax(2,pw_gzrf2leftr1a,pw_gzrf2leftr1d);
            pw_xgradLeftCrusherRa = IMax(2,pw_gzrf2leftr1a,pw_gzrf2leftr1d);
            pw_xgradLeftCrusherLd = pw_xgradLeftCrusherLa;
            pw_xgradLeftCrusherRd = pw_xgradLeftCrusherRa;
            pw_ygradLeftCrusherL = IMax(2,pw_gzrf2leftl1,pw_gzrf2leftr1);
            pw_ygradLeftCrusherR = IMax(2,pw_gzrf2leftl1,pw_gzrf2leftr1);
            pw_ygradLeftCrusherLa = IMax(2,pw_gzrf2leftr1a,pw_gzrf2leftr1d);
            pw_ygradLeftCrusherRa = IMax(2,pw_gzrf2leftr1a,pw_gzrf2leftr1d);
            pw_ygradLeftCrusherLd = pw_ygradLeftCrusherLa;
            pw_ygradLeftCrusherRd = pw_ygradLeftCrusherRa;
            if(pw_xgradLeftCrusherL-pw_gzrf2leftl1 > 0) {
                 LeftCrusherLSlop += (pw_xgradLeftCrusherL-pw_gzrf2leftl1);
            }
            if(pw_xgradLeftCrusherR-pw_gzrf2leftr1 > 0) {
                 LeftCrusherRSlop += (pw_xgradLeftCrusherR-pw_gzrf2leftr1);
            }
            if(pw_xgradLeftCrusherLa-pw_gzrf2leftl1a > 0) {
                 LeftCrusherLSlop += (pw_xgradLeftCrusherLa-pw_gzrf2leftl1a);
            }
            if(pw_xgradLeftCrusherRa-pw_gzrf2leftr1a > 0) {
                 LeftCrusherRSlop += (pw_xgradLeftCrusherRa-pw_gzrf2leftr1a);
            }
            if(pw_xgradLeftCrusherLd-pw_gzrf2leftl1d > 0) {
                 LeftCrusherLSlop += (pw_xgradLeftCrusherLd-pw_gzrf2leftl1d);
            }
            if(pw_xgradLeftCrusherRd-pw_gzrf2leftr1d > 0) {
                 LeftCrusherRSlop += (pw_xgradLeftCrusherRd-pw_gzrf2leftr1d);
            }

        } else {
            LeftCrusherLSlop=0;
            LeftCrusherRSlop=0;
            pw_xgradLeftCrusherL = 0;
            pw_xgradLeftCrusherR = 0;
            pw_xgradLeftCrusherLa = 0;
            pw_xgradLeftCrusherRa = 0;
            pw_xgradLeftCrusherLd = 0;
            pw_xgradLeftCrusherRd = 0;
            pw_ygradLeftCrusherL = 0;
            pw_ygradLeftCrusherR = 0;
            pw_ygradLeftCrusherLa = 0;
            pw_ygradLeftCrusherRa = 0;
            pw_ygradLeftCrusherLd = 0;
            pw_ygradLeftCrusherRd = 0;
        }
        /* MRIhc05259 bval calc is based on time between start of 1st diff lobe
           and start of second.  Hence, l1_tot_bval and r1_tot_bval alone
           contribute to bval.  The LeftCrusherSlop is the amount of 
           additional time that is added to the sequence to add the x, y
           crushers on the left 180.  This time will increase the Delta_Time
           of the bval calculation.  The _tot_bval values are also used for 
           avminte calc.  Adding l2_tot_bval accounts for the fact that the
           pulse widths between the leftr1 and rightl1 crushers may be different
           at thin slices.  This should allow proper calculation of TE. 
        */
        pw_gzrf2l1_tot_bval = (pw_gzrf2leftl1a + pw_gzrf2leftl1 
                              + pw_gzrf2leftl1d + LeftCrusherLSlop);
        pw_gzrf2l2_tot_bval = (pw_gzrf2rightl1a + pw_gzrf2rightl1 
                              + pw_gzrf2rightl1d + RightCrusherLSlop);
        pw_gzrf2r1_tot_bval = (pw_gzrf2leftr1a + pw_gzrf2leftr1 
                              + pw_gzrf2leftr1d + LeftCrusherRSlop);
        pw_gzrf2r2_tot_bval = (pw_gzrf2rightr1a + pw_gzrf2rightr1 
                              + pw_gzrf2rightr1d + RightCrusherRSlop);
    }    
   
    /* Calculate z blip gradient parameters */
    /* Always use max blip area in accelerated time points(slice_fov_shift_area) to set up gzb amplitude and width, because calibration time points never use gzb */
    if ((use_slice_fov_shift_blips) && (mux_flag) && (mux_slices_rf1 > 1) && (slice_fov_shift_area > 0.0)) {

      /* Store blip amplitude */
      gzb_amp = a_gzb;
      pw_gzbd = pw_gzba;

      /* Recalculate pw_gxgap for Slice FOV Shift. */
      /* NOTE - This happens after call to epigradopt_rect, and
         optGradAndEsp_rect -- each which call setEpiEsp -- so esp should
         not be calculated again */
      if(slice_fov_shift_extra_gap_flag)
      {
          slice_fov_shift_extra_gap = pw_gzba + pw_gzbd + pw_gzb - (pw_gyba + pw_gybd + pw_gyb);
          if(slice_fov_shift_extra_gap > 0)
          {
              pw_gxgap += slice_fov_shift_extra_gap;
              if(slice_fov_shift_calc_new_esp)
              {
                  esp += pw_gxgap;
              }
          }
      }

      /* Calculate slice_fov_shift_blip_start so that we start with Kz ~= 0 for encoding */
      slice_fov_shift_blip_start = FLOOR_DIV(slice_fov_shift, 2);

      /* Set slice_fov_shift_blip_inc equal to the arc factor */
      slice_fov_shift_blip_inc = (INT)exist(opaccel_ph_stride);

    } else {
      /* Make sure Z blips are not created */
      pw_gzba = 0;
      pw_gzb = 0;
      pw_gzbd = 0;
      a_gzb = 0.0;
    }
 
    /***** End of sequences (eos) killer pulses *****************/

    if (eoskillers == PSD_ON) 
    {
        target_area = a_gxw*(float)(pw_gxwad + pw_gxw/2);
        if (eosxkiller == PSD_ON) 
	{   /* X killer pulse */
            if (amppwgradmethod(&gradx[GXK_SLOT], target_area, loggrd.tx_xyz,
                                start_amp, end_amp,
                                loggrd.xrt*loggrd.scale_3axis_risetime, MIN_PLATEAU_TIME)==FAILURE) 
	    {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxk" );
                return FAILURE;
	    }
	}
        if (eosykiller == PSD_ON) 
	{   /* Y killer pulse */
            if (amppwgradmethod(&grady[GYK_SLOT], target_area, loggrd.ty_xyz,
                                start_amp, end_amp,
                                loggrd.yrt*loggrd.scale_3axis_risetime, MIN_PLATEAU_TIME)==FAILURE) 
	    {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gyk" );
                return FAILURE;
	    }
	}
        if (eoszkiller == PSD_ON) 
	{   /* Z killer pulse */
            if (amppwgradmethod(&gradz[GZK_SLOT], target_area, loggrd.tz_xyz,
                                start_amp, end_amp,
                                loggrd.zrt*loggrd.scale_3axis_risetime, MIN_PLATEAU_TIME)==FAILURE) 
	    {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwgradmethod:gzk" );
                return FAILURE;
	    }
	}
        
        gxktime = pw_gxk + pw_gxka + pw_gxkd;
        gyktime = pw_gyk + pw_gyka + pw_gykd;
        gzktime = pw_gzk + pw_gzka + pw_gzkd;
    } 
    else 
    {
        gxktime = 0;
        gyktime = 0;
        gzktime = 0;
    }
	  
    gktime  = IMax(3,gxktime, gyktime, gzktime);
    
    /***** Cardiac and advisory panel control *********************************/

    if (aspir_flag)
    {
        if (ASPIR_AUTO_TI_FIXED == aspir_auto_ti_model)
        {
            /* ASPIR Auto TI for fixed TI model */
            int null_ti_temp = 0;

            null_ti_temp = calc_ASPIR_TI(INT_INPUT_NOT_USED);

            set_ASPIR_TI(null_ti_temp);
        }
        else
        {
            /* For ASPIR adaptive TI model cases where Auto TI value depends on TR value,
               calculation of TI would be performed later. 
               But some initialization is necessary so set avminti here by set_ASPIR_TI().*/
            set_ASPIR_TI(avminti);
        }
    }

    if (ChemSatEval(&cs_sattime) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "ChemSatEval" );
        return FAILURE;
    }
    
    switch (sp_sattype) {
        case 1:
            flip_rfse1 = 105;
            flip_rfse2 = 105;
            flip_rfse3 = 105;
            flip_rfse4 = 105;
            flip_rfse5 = 105;
            flip_rfse6 = 105;
            break;
        case 2:
            if (cffield == B0_30000)
            {
                flip_rfse1 = 130;
                flip_rfse2 = 130;
                flip_rfse3 = 130;
                flip_rfse4 = 130;
                flip_rfse5 = 130;
                flip_rfse6 = 130;
            }
            else
            {
                flip_rfse1 = 120;
                flip_rfse2 = 120;
                flip_rfse3 = 120;
                flip_rfse4 = 120;
                flip_rfse5 = 120;
                flip_rfse6 = 120;
            }
            break;
        default:
            flip_rfse1 = 90;
            flip_rfse2 = 90;
            flip_rfse3 = 90;
            flip_rfse4 = 90;
            flip_rfse5 = 90;
            flip_rfse6 = 90;
            break;
    }
    
    if (SpSatEval(&sp_sattime) == FAILURE) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "SpSatEval" );
        return FAILURE;
    }

    SetCyclingCVs();

    /* Obl 3in1 opt */
    if (obl_3in1_opt)
    {
        float abs_gx_log,abs_gy_log,abs_gz_log;
        float target_mpg_x,target_mpg_y,target_mpg_z;
        float target_mpg_inv_min;
        int i,j;

        if (orderslice(seq_type, 1, 1, gating) == FAILURE)
        {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "orderslice" );
            return FAILURE;
        }

        for (j=0; j<9; j++)
        {
            rsprot_unscaled[0][j] = rsprot[0][j];
        }

        if (obl_3in1_opt_debug)
        {
            printf("Obl3in1:  \n");
            printf("Obl3in1: loggrd.tx= %f phygrd.xfull= %d phygrd.xfs= %f\n", loggrd.tx, phygrd.xfull, phygrd.xfs);
            printf("Obl3in1: loggrd.ty= %f phygrd.yfull= %d phygrd.yfs= %f\n", loggrd.ty, phygrd.yfull, phygrd.yfs);
            printf("Obl3in1: loggrd.tz= %f phygrd.zfull= %d phygrd.zfs= %f\n", loggrd.tz, phygrd.zfull, phygrd.zfs);
            printf("Obl3in1: orthloggrd.tx= %f orthloggrd.ty= %f orthloggrd.tz= %f\n", orthloggrd.tx, orthloggrd.ty, orthloggrd.tz);
        }

        if (inversRspRot(inversRR, rsprot_unscaled[0]) == FAILURE)
        {
            epic_error(use_ermes,"inversRspRot failed",
                       EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG," inversRspRot");
            return FAILURE;
        }

        target_mpg_inv_min = FMax(3, orthloggrd.tx, orthloggrd.ty, orthloggrd.tz);

        for (i=0; i<num_dif; i++)
        {
            gx_log = orthloggrd.tx;
            gy_log = orthloggrd.ty;
            gz_log = orthloggrd.tz;

            rotateToLogical(&gx_log, &gy_log, &gz_log, i);

            abs_gx_log = fabs(gx_log);
            abs_gy_log = fabs(gy_log);
            abs_gz_log = fabs(gz_log);

            target_mpg_x = orthloggrd.tx * loggrd.tx / abs_gx_log;
            target_mpg_y = orthloggrd.ty * loggrd.ty / abs_gy_log;
            target_mpg_z = orthloggrd.tz * loggrd.tz / abs_gz_log;

            target_mpg_inv = FMin(3, target_mpg_x, target_mpg_y, target_mpg_z);
            target_mpg_inv = (float)((int)(target_mpg_inv * 1000))/1000.0;
            target_mpg_inv_min = FMin(2, target_mpg_inv, target_mpg_inv_min);

            if (obl_3in1_opt_debug)
            {
                /* g<x,y,z>_log       : Logical amplitude inverse rotation matrix is applied.
                   target_mpg_<x,y,z> : Logical target scaled by absolute target_mpg_<x,y,z>
                                        to avoid amplitude overflow in pulsegen().
                   target_mpg_inv     : Final logical target which is used in get_diffusion_time(). 
                                        target_mpg_inv is obtained after checking all diffusion directions. */
                printf("Obl3in1:  \n");
                printf("Obl3in1: Dir= %d\n",i);
                printf("Obl3in1: Calculated logical MPG amplitude\n");
                printf("Obl3in1: gx_log= %f gy_log= %f gz_log= %f\n", gx_log, gy_log, gz_log);
                printf("Obl3in1: abs_gx_log= %f abs_gy_log= %f abs_gz_log= %f\n", abs_gx_log, abs_gy_log, abs_gz_log);
                printf("Obl3in1: target_mpg_x= %f target_mpg_y= %f target_mpg_z= %f\n", target_mpg_x, target_mpg_y, target_mpg_z);
            }
        }

        target_mpg_inv = target_mpg_inv_min;

        if (obl_3in1_opt_debug)
        {
            printf("Obl3in1: Final Max traget amp for inverse MPG\n");
            printf("Obl3in1: target_mpg_inv= %f\n", target_mpg_inv);
        }
    }

    if (FAILURE == Monitor_CvevalInit(rfpulse))
    {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "Monitor_CvevalInit");
        return FAILURE;
    }

    if (FAILURE == NavigatorCvevalInit())
    {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "NavigatorCvevalInit");
        return FAILURE;
    }

    /* Multiband is incompatible with negative spacing*/
    if( (exist(opslspace)<0) && (mux_flag == PSD_ON) )
    {
         epic_error( use_ermes, "Increase the slice spacing to %.1f mm", EM_PSD_SLSPACING_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, 0.0);
         return FAILURE;
    }
        tlead = RUP_GRD(24us);

    /*RTB0 correction*/
    if(rtb0_flag) tlead += pw_dynr1+GRAD_UPDATE_TIME;
    tlead = RUP_GRD(tlead);

    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e AutoAdjustTRDebug

    psd_card_hdwr_delay = 10ms;  
    if ((exist(opcgate) == PSD_ON) && existcv(opcgate)) 
    {
        avmintdel1 = psd_card_hdwr_delay + tlead + t_exa + GRAD_UPDATE_TIME;
        avmintdel1 = avmintdel1 + ir_time_total;
        if (ir_on == PSD_ON)
        {
            pitdel1 = avmintdel1;
        }
        else
        {
            pitdel1 = avmintdel1 + sp_sattime + cs_sattime + satdelay;
        }
        advroundup(&avmintdel1); /* round up to ms */
        advroundup(&pitdel1); /* round up to ms */
 
        /* Override Trigger Delay value if user prescribes Minimum or Recommended */
        if( existcv(opautotdel1) ) 
        { 
            if( PSD_TDEL1_MINIMUM == exist(opautotdel1) ) 
            { 
                cvdef(optdel1, avmintdel1); 
                cvoverride(optdel1, _optdel1.defval, PSD_FIX_ON, PSD_EXIST_ON); 
            } 
            else if( PSD_TDEL1_RECOMMENDED == exist(opautotdel1) ) 
            { 
                cvdef(optdel1, pitdel1); 
                cvoverride(optdel1, _optdel1.defval, PSD_FIX_ON, PSD_EXIST_ON); 
            } 
        }

        if (optdel1 < pitdel1)
            td0 = RUP_GRD((int)(exist(optdel1) - (psd_card_hdwr_delay 
                                                  + tlead + t_exa)));
        else
            td0 = RUP_GRD((int)(exist(optdel1) - (psd_card_hdwr_delay + tlead 
                                                  + t_exa + sp_sattime + cs_sattime + ir_time + satdelay)));

        gating = TRIG_ECG;
        piadvmin = (piadvmin & ~(1<<PSD_ADVTR));
        piadvmax = (piadvmax & ~(1<<PSD_ADVTR));
        pitrnub = 0;
    }
    else if (((exist(oprtcgate) == PSD_ON) && existcv(oprtcgate)) || /* RTG */
             (navtrig_flag == PSD_ON) ) 
    {
        _opphases.fixedflag = 0;
        opphases = 1;
        avmintdel1 = 0;
        td0 = GRAD_UPDATE_TIME;
        if (navtrig_flag == PSD_OFF)
        {
            /* ALP ECG and RESP have separate hardware lines in MGD */
            gating = TRIG_RESP;
        } else {
            gating = TRIG_INTERN;
        }
        piadvmin = (piadvmin & ~(1<<PSD_ADVTR));
        piadvmax = (piadvmax & ~(1<<PSD_ADVTR));
        pitrnub = 0;
    }  
    else 
    {
        _opphases.fixedflag = 0;
        opphases = 1;
        avmintdel1 = 0;
        td0 = GRAD_UPDATE_TIME;
        piadvmin = (piadvmin | (1<<PSD_ADVTR));
        piadvmax = (piadvmax | (1<<PSD_ADVTR));
        gating = TRIG_INTERN;
    }

    /* find the avail time for freq dephaser */

    /* need fix here for trapezoidal phase encoding */

    if (exist(oppseq) == PSD_SE)
        avail_pwgx1 = (int)(exist(opte)/2 - rfExIso - pw_rf2/2 
                            - RUP_GRD(rfupd));
    else
        avail_pwgx1 = (int)(exist(opte) - rfExIso -
                            (pw_gxwad + pw_gxw/2) - RUP_GRD(rfupd));

    /* Calculate minimum FOV ********************************/

    avminfovx = 1.0/(GAM*xtarg*tsp*1.0e-6);
    avminfovx = (vrgfsamp == PSD_ON) ? 4 : avminfovx;

    avminfovy = 0.0;

    avminfov = (avminfovx > avminfovy) ? avminfovx : avminfovy; 
    avminfov = ceil(avminfov)*10.0;

    /* This is the best scan can do on the advisory panel.  The psd supports
       a larger fov than 99cm, but the advisory panel won't reflect it. */
    avmaxfov = 600;

    if ( (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25 ) || ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (EZflag == PSD_ON)) )
    {
        avminfov = 360;
        avmaxfov = 360;
    }
    else if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON)) 
    {
        avminfov = 240;
        if(cfsrmode == PSD_SR77)
        {
            avmaxfov = 600;
        }
        else
        {
            avmaxfov = 400;
        }
    }

    if (rfov_flag)
    {
        avminfov = FMax(2, avminfov, MIN_RFOV/exist(opphasefov));
    }

    fullk_nframes = (int)(ceilf(opyres*asset_factor/rup_factor)*rup_factor);

    /* Begin Minimum TE *****************************************************/  
    area_gyb = (float)(pw_gyba + pw_gyb)*a_gyb;  /* G usec / cm */

    /* Compute minimum te with full ky coverage first *************************/
    etl = (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/intleaves;
    num_overscan = 0;

    /* Set the fract_ CVs */
    fract_ky = 0;
    ky_dir = PSD_BOTTOM_UP;

    /* BJM: setup ky_offset, dont allow mods below if single etl */
    if ((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor) == exist(opnshots)) {
        cvoverride(ky_offset, 0, PSD_FIX_ON, PSD_EXIST_ON);
        cvoverride(delt, 0, PSD_FIX_ON, PSD_EXIST_ON);
    } else {
        cvoverride(ky_offset, 0, PSD_FIX_OFF, PSD_EXIST_ON);
        cvoverride(delt, 0, PSD_FIX_OFF, PSD_EXIST_ON);
    }

    if (intleaves == 1) 
    {
        delt = 0;
        ky_offset = 0.0;
        pw_wgx = GRAD_UPDATE_TIME;
    } 
    else 
        if ( ky_dir==PSD_BOTTOM_UP ) 
        {
            delt = RUP_HRD((int)((float)esp/(float)(intleaves)));
	    	if (muse_flag) {
				ky_offset = 0.0;
			} 
			else 
			{
            if (etl % 2 == 0) 
            {
                if ((etl/2) % 2 == 0)
                    ky_offset = (float)(ceil(-(double)intleaves/2.0));
                else
                    ky_offset = (float)(ceil((double)intleaves/2.0));
            } 
            else 
            {
                ky_offset = (float)(ceil((double)-intleaves));
            }
			}
            pw_wgx = (intleaves-1)*delt/2 + GRAD_UPDATE_TIME;
        } 
        else 	
        {    /* full ky CENTER-OUT */
            delt = RUP_HRD((int)((float)esp/(float)(intleaves*2)));
            ky_offset = 0.0;
            pw_wgx = GRAD_UPDATE_TIME;
        }

    blips2cent = etl/2 + ky_offset/intleaves;

    pw_wgx = RUP_GRD(pw_wgx);
    pw_wgy = pw_wgx;
    pw_wgz = pw_wgx;
    pw_wssp = pw_wgx;
    pw_womega = pw_wgx;   /* ufi2_ypd */


    tdaqhxa = ((float)etl/2.0 + ky_offset/(float)intleaves)*(float)esp;
    area_gy1 = area_gyb * (ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor/2.0 - 0.5)/(float)intleaves;
    /* DTI BJM: dsp change */
    if(FAILURE == get_diffusion_time()) {
        return FAILURE;
    }

    avmintecalc();

    /* round up to 0.1 ms, ufi2_ypd */
    avmintefull = (int)(100.0*ceil((double)avmintetemp/100.0));

    /* Compute minimum te with fractional ky coverage or full ky with center/out
       coverage next ******************/

    /* Set the fract_ CVs */
    fract_ky = PSD_FRACT_KY;
    ky_dir = PSD_BOTTOM_UP;

    /* New rhhnover calculation - use minimum number of overscans (based
       on opnshots and fract_ky).  Leave old algorithm in, but use it to
       calc. rhhnover_max, which is not currently used, but may be in the
       future to maximize s/n. */
    if ( (exist(oppseq) == PSD_GE) )
        rhhnover_min = MIN_HNOVER_GRE;
    else
        rhhnover_min = MIN_HNOVER_DEF;

    if( ((opdiffuse==PSD_ON)&&(oppseq==PSD_SE)) || ((tensor_flag == PSD_ON)&&(oppseq==PSD_SE)) )
    {
        if (rfov_flag)
        {
            rhhnover_min = MIN_HNOVER_RFOV;
        }
        else
        {
            rhhnover_min = MIN_HNOVER_DWI;
        }
    }

    if( (intleaves < (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)) && (PSD_OFF == epi2spec_mode) ) {
        for (icount=0; icount<=rhhnover_min; icount++) {
            if (icount*intleaves>=rhhnover_min) {
                num_overscan = (icount*intleaves);
                break;
            }
        }
        if (muse_flag && (num_overscan < rhhnover_min_per_ilv*intleaves)) 
		{
            num_overscan = rhhnover_min_per_ilv*intleaves;
        }
    } else if ( epi2spec_mode ) {
        
        num_overscan = 2;

    } else {

        num_overscan = rhhnover_min;

    } 

    if( (value_system_flag == VALUE_SYSTEM_HDE) && (tensor_flag == PSD_OFF) )
    {
        /* asset = 2 for scans, 1 for calibration */
        if(exist(opasset) == 2)
        {
            /* reduce the overscans by the asset_factor */
            num_overscan = num_overscan*asset_factor;

            /* limit the overscan reduction */
            if(num_overscan < MIN_HNOVER_DWI*asset_factor)
                num_overscan = MIN_HNOVER_DWI*asset_factor ;
        }
    }

    etl = ((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/2 + num_overscan)/intleaves;

    /* Determine ky offsets */
    if (intleaves == 1) 
    {
        delt = 0;
        ky_offset = 0.0;
        tdaqhxa = (float)num_overscan*(float)esp;
        pw_wgx = GRAD_UPDATE_TIME;
    } 
    else 
    {
        delt = RUP_HRD((int)((float)esp/(float)(intleaves)));

		if (muse_flag) 
		{
			ky_offset = 0.0;
		} 
		else 
		{
        if ((num_overscan/intleaves) % 2 == 0)
            ky_offset = (float)(ceil((double)-intleaves/2.0));
        else
            ky_offset = (float)(ceil((double)intleaves/2.0));
		}

        if (fullk_nframes == exist(opnshots))
            ky_offset = 0.0;

        /* BJM: MRIge60610 */ 
        if(num_overscan > 0) {
            /* BJM: the true number of overscans */
            rhhnover = num_overscan + ky_offset;

            /* MRIge61204 & MRIge61702 */
            /* Here's da deal: we are trying to put the echo peak */
            /* at the center of the group of flow comped echoes.   */
            /* It's desirable to place the peak early instead of late */
            /* to minimize TE.  However, if we can't, then place the */
            /* echo peak "late" instead for min TE */
            if(fabs(ky_offset) > 0) {
                if (exist(oppseq) == PSD_GE && rhhnover < MIN_HNOVER_GRE) {
                    ky_offset = (float)(ceil(3.0*(double)intleaves/2.0));
                    rhhnover = MIN_HNOVER_GRE + ky_offset;
                } else if (rhhnover < MIN_HNOVER_DEF) {
                    ky_offset = (float)(ceil(3.0*(double)intleaves/2.0));
                    rhhnover = MIN_HNOVER_DEF + ky_offset;
                }
            } /* end fabs(ky_offset) > 0 */
        }

        tdaqhxa = ((float)num_overscan + ky_offset)*(float)esp/(float)intleaves;

        etl = ((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/intleaves)/2 + IMax(2, num_overscan/intleaves, 1);

        if (ky_dir==PSD_BOTTOM_UP)
        {
            pw_wgx = (intleaves-1)*delt/2 + GRAD_UPDATE_TIME;
        }
        else    /* full ky CENTER-OUT */
        {
            pw_wgx = GRAD_UPDATE_TIME;
        }
    }

    pw_wgx = RUP_GRD(pw_wgx);
    pw_wgy = pw_wgx;
    pw_wgz = pw_wgx;
    pw_wssp = pw_wgx;
    pw_womega = pw_wgx;   /* ufi2_ypd */

    area_gy1 = area_gyb * ((float)num_overscan - 0.5) / (float)intleaves;

    /* DTI BJM: dsp change */
    if(FAILURE == get_diffusion_time()) {
        return FAILURE;
    }

    avmintecalc();

    /* round up to 0.1ms, ufi2_ypd */
    if (exist(opautote) == PSD_MINTEFULL)
    {
        avminte = avmintefull;
    }
    else
    {
        avminte = (int)(100.0*ceil((double)avmintetemp/100.0));
    }

    if (exist(opautote) == PSD_MINTE || exist(opautote) == PSD_MINTEFULL) 
    {
        setexist(opte,PSD_ON);
        _opte.fixedflag = 0;
        opte = ceil((float)avminte/100.0)*100;
        _opte.fixedflag = 1;
    }
    else if ((existcv(opte) == PSD_ON) && smart_numoverscan)
    {
        if ((exist(opte) > avminte) && (exist(opte) < avmintefull))
        {
            int extra_os_time;
            if (exist(opdiffuse) == PSD_ON)
            {
                if (PSD_OFF == dualspinecho_flag)
                {
                    extra_os_time = (exist(opte) - avminte)/2;
                }
                else
                {
                    extra_os_time = (exist(opte) - avminte)/4;
                }
            }
            else
            {
                if(oppseq == PSD_GE)
                {
                    extra_os_time = exist(opte) - avminte;
                }
                else
                {
                    extra_os_time = (exist(opte) -avminte)/2;
                }
            }
            num_overscan += (extra_os_time/esp/2)*2;
            etl = (num_overscan + (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/2)/intleaves;
        }
    }
    /* End Minimum TE *******************************************************/

    /* Now recompute everything based on operator selected parameters *******/

    ky_dir = PSD_BOTTOM_UP;
    if (exist(opte) >= avmintefull) 
    {
        fract_ky = PSD_FULL_KY;
    } 
    else 
    {
        fract_ky = PSD_FRACT_KY;
    }

    nexcalc();

    if (intleaves == 1) 
    {
        delt = 0;
    } 
    else 
        if ( ky_dir==PSD_BOTTOM_UP ) 
        {
            delt = RUP_HRD((int)((float)esp/(float)(intleaves)));
        } 
        else 	
        {
            delt = RUP_HRD((int)((float)esp/(float)(intleaves*2)));
        }

    /* Wait pulses */
    if (intleaves == 1)
        pw_wgx = GRAD_UPDATE_TIME;
    else 
        if ( ky_dir==PSD_BOTTOM_UP ) 
            pw_wgx = (intleaves-1)*delt/2 + GRAD_UPDATE_TIME;
        else    /* full ky CENTER-OUT */
            pw_wgx = GRAD_UPDATE_TIME;

    pw_wgx = RUP_GRD(pw_wgx);
    pw_wgy = pw_wgx;
    pw_wgz = pw_wgx;
    pw_wssp = pw_wgx;
    pw_womega = pw_wgx;   /* ufi2_ypd */


    if ((intleaves > 1))		
    {
        if ( ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FRACT_KY ) 
        {
            if (muse_flag == PSD_ON)
                ky_offset = 0.0;
            else if (etl % 2 == 0)
                ky_offset = (float)(ceil((double)-intleaves/2.0));
            else
                ky_offset = (float)(ceil((double)intleaves/2.0));
        } 
        else 
            if ( (ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FULL_KY) ||
                 ky_dir == PSD_TOP_DOWN ) 
            {
                etl = (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/intleaves;
                if (muse_flag == PSD_ON)
                {
                    ky_offset = 0.0;
                }
                else if (etl % 2 == 0)
                {
                    if ((etl/2) % 2 == 0)
                        ky_offset = (float)(ceil((double)-intleaves/2.0));
                    else
                        ky_offset = (float)(ceil((double)intleaves/2.0));
                } 
                else 
                {
                    ky_offset = (float)(ceil((double)-intleaves/2.0));
                }
            } 
            else 
                if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY)
                    ky_offset = 0.0;
    } 
    else 
    {             /* single interleave */
        ky_offset = 0.0;
    }

    if (fract_ky == PSD_FULL_KY) 
    {
        rhhnover = 0;
        num_overscan = 0;
        etl = (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/intleaves;
    } 
    else
    {
        if (exist(oppseq) == PSD_SE) 
        {
            avail_tdaqhxa = exist(opte)/2 - (pw_rf2/2 + xdiff_time2 + pw_wgx +
                                             IMax(3,
                                                  pw_gx1_tot,
                                                  pw_gymn1_tot + pw_gymn2_tot +
                                                  pw_gy1_tot + ydiff_time2,
                                                  pw_gzrf2r1_tot + zdiff_time2));
        } 
        else 
        {
            avail_tdaqhxa = exist(opte) -
                (rfExIso + pw_wgx + IMax(3, pw_gzrf1d + pw_gz1_tot, pw_gx1_tot,
                                         pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot + pw_gyex1_tot));
        }

        /* number of views that will fit in the available time slot.
           2nd term accounts for time shifting of echo train,
           3rd term accounts for ky_offset.  Assume nviews is odd initially. */

        nviews = (avail_tdaqhxa - delt*(intleaves-1)/2 -
                  ky_offset*esp/intleaves)/esp;

        etl = (num_overscan + (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/2)/intleaves;

        if (num_overscan >= fullk_nframes/2) 
        {
            rhhnover = 0;
            num_overscan = 0;
            fract_ky = 0;
            ky_dir = PSD_BOTTOM_UP;
            etl = (int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)/intleaves;

            /* MRIge41484 BJM: modify ky_offset and set fn = 1.0 to prevent */
            /*                 download failure of Min TE, multi-shot, */
            /*                 spin-echo epi */
            ky_offset *= -1;
            fn = 1.0;         /* reset fractional nex value */

        }
    } /* partial ky */

    /* since opetl is written into the header */
    opetl = etl;
    tot_etl = etl + iref_etl;

    /* BJM: MRIge60610 */ 
    if(num_overscan > 0) {
        /* BJM: the true number of overscans */
        rhhnover = num_overscan + ky_offset;   

        /* MRIge61204 & MRIge61702 */
        if(fabs(ky_offset) > 0) {
            if (exist(oppseq) == PSD_GE && rhhnover < MIN_HNOVER_GRE) {
                ky_offset = (float)(ceil(3.0*(double)intleaves/2.0));
                rhhnover = MIN_HNOVER_GRE + ky_offset;
            } else if (rhhnover < MIN_HNOVER_DEF) {
                ky_offset = (float)(ceil(3.0*(double)intleaves/2.0));
                rhhnover = MIN_HNOVER_DEF + ky_offset;
            }
        } /* end fabs(ky_offset) > 0 */
    }

    nblips = etl - 1;

    /* Y phase encode prephaser */

    if (etl == 1) {
        area_gy1 = area_gyb/2.0;
        blips2cent = 0;
    } else {
        if (ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FRACT_KY) {
            area_gy1 = area_gyb * ((float)num_overscan - 0.5) / (float)intleaves;
            blips2cent = (num_overscan + ky_offset) / intleaves;
        } else if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY) {
            area_gy1 = area_gyb * ((float)intleaves/2.0 - 0.5);
            blips2cent = 0;
        } else if ( (ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FULL_KY) ||
                    (ky_dir == PSD_TOP_DOWN && fract_ky == PSD_FULL_KY) ) {
            area_gy1 = area_gyb * (ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor/2.0 - 0.5) /
                (float)intleaves;
            blips2cent = etl/2 + ky_offset/intleaves;
        }
    }

    if ((fract_ky == PSD_FULL_KY) && ((PSD_ON == dualspinecho_flag) || 
         ((PSD_OFF == dualspinecho_flag) && (PSD_ON == sse_enh))))
    {
        /* set diffusion timing for full ky and dual spin echo*/
        tdaqhxa = ((float)etl/2.0 + ky_offset/(float)intleaves)*(float)esp;
        if(FAILURE == get_diffusion_time()) {
            return FAILURE;
        }
    }

    /*update SSE diffusion manual TE timing after avminte is fully determinted*/
    if ( isRioSystem() && (PSD_ON == sse_manualte_derating)
        && ((exist(opdiffuse) == PSD_ON)|| (tensor_flag == PSD_ON))
        && (dualspinecho_flag == PSD_OFF) && (exist(opautote) == 0) )
    {
        if(FAILURE == update_sse_diffusion_time()) {
            return FAILURE;
        }
    }

    gy1_offset = ky_offset*fabs(area_gyb)/intleaves;

    /* Shift ky=0 point to center of x flow comp'd echoes */
    if (etl > 1)
        area_gy1 += gy1_offset;

    /* Scale the waveform amps for the phase encodes 
     * so each phase instruction jump is an integer step */

    if (ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FRACT_KY) {
        if (intleaves <= 1)
            endview_iamp = max_pg_wamp;
        else {
            if (num_overscan >= 2)
                endview_iamp = (int)((int)( 2*max_pg_wamp/
                    (num_overscan-1 + 2*ky_offset) )/2)*
                    2*(num_overscan-1+2*ky_offset)/2;
            else
                endview_iamp = max_pg_wamp;
        }
    } else if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY) {
        if (intleaves <= 2)
            endview_iamp = max_pg_wamp;
        else
            endview_iamp = (int)((int)(2*max_pg_wamp/
                ((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)-1 + 2*ky_offset))/2)*
                2*((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)-1 + 2*ky_offset)/2;
    } else if ((ky_dir == PSD_TOP_DOWN || ky_dir == PSD_BOTTOM_UP) &&
        fract_ky == PSD_FULL_KY) {
        if (intleaves <= 1)
            endview_iamp = max_pg_wamp;
        else
            endview_iamp = (int)((int)(2*max_pg_wamp/
                ((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)-1 + 2*ky_offset))/2)*
                2*((int)(ceilf(exist(opyres)*asset_factor/rup_factor)*rup_factor)-1 + 2*ky_offset)/2;
    }

    endview_scale = (float)max_pg_iamp / (float)endview_iamp;

    /* Find the amplitudes and pulse widths of the trapezoidal
       phase encoding pulse. */

    if (amppwtpe(&a_gy1a,&a_gy1b,&pw_gy1,&pw_gy1a,&pw_gy1d,
                 loggrd.ty_xyz/endview_scale,loggrd.yrt*loggrd.scale_3axis_risetime,
                 area_gy1) == FAILURE)
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwtpe" );
        return FAILURE;
    } 

    pw_gy1_tot = pw_gy1a + pw_gy1 + pw_gy1d;
    a_gy1a = ((exist(oppseq) == PSD_SE && gy1pos == PSD_PRE_180) ?
              a_gy1a : -a_gy1a);
    a_gy1b = ((exist(oppseq) == PSD_SE && gy1pos == PSD_PRE_180) ?
              a_gy1b : -a_gy1b);

    get_flowcomp_time();

    /* internref: pw_iref_gxwait is defined in EP_TRAIN() */
    pw_iref_gxwait = 0;

    /* Actual inter echo time */
    if (etl == 1)
        esp = 0;  /* can't define an echo spacing with an etl of 1! */

    if (esp % GRAD_UPDATE_TIME != 0) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "esp not an integral multiple of grad hardware period." );
        return FAILURE;
    }

    if (etl == 1) {
        tdaqhxa = (pw_gxw + 2*pw_gxwad + pw_gxwl + pw_gxwr)/2;
        tdaqhxb = tdaqhxa;
        pw_gxgap = 0;
    } else {
        if ((ky_dir==PSD_TOP_DOWN || ky_dir==PSD_BOTTOM_UP) &&
            fract_ky == PSD_FULL_KY) {
            tdaqhxa = ((float)etl/2.0 + ky_offset/(float)intleaves)*(float)esp;
            tdaqhxb = ((float)etl/2.0 - ky_offset/(float)intleaves)*(float)esp;
        } else if (ky_dir == PSD_BOTTOM_UP && fract_ky == PSD_FRACT_KY) {
            /* Do overscans first */
            tdaqhxa = ((float)num_overscan - ky_offset)*(float)esp/(float)intleaves;
            tdaqhxb = ((float)etl-(((float)num_overscan+ky_offset)/(float)intleaves))
                *(float)esp;
        } else if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY) {
            /* Put the middle of the first echo at the nominal TE */
            tdaqhxa = pw_gxwad + pw_gxwl + (pw_gxw/2);
            tdaqhxb = etl*esp + pw_gxgap + pw_gxwad + pw_gxwl + (pw_gxw/2);
        } 
    }

    if (etl % 2 == 0)       /* odd number of views, so negate killer ampl. */
        a_gxk = -a_gxk;

    if (etl >= 256) 
    {
        if (PSDDVMR == psd_board_type)
        {
			time_ssi = muse_flag? 5000: 4000;
        }
        else
        {
            time_ssi = 2000;
        }
    }
    else 
    {
        if (PSDDVMR == psd_board_type)
        {
            if ((hoecc_flag == PSD_OFF) && (mux_flag == PSD_OFF))
            {
                if (etl <= 192) 
                {
                    time_ssi = 1200;
                }
                else 
                {
                    time_ssi = 2000;
                }
            }
            else
            {
                if (etl <= 128) 
                {
                    time_ssi = 1700;
                }
                else if (etl <= 192)
                {
                    time_ssi = 2500;
                }
                else 
                {
					time_ssi = muse_flag? 5000:3300;
                }
            }
        }
        else
        {
            time_ssi = 1000;
        }
    }

    te_time = exist(opte);
    gkdelay = RUP_GRD(gkdelay);

    /* BJM MRIge57693 - need to calculate it first */
    pos_start = RUP_GRD((int)tlead + GRAD_UPDATE_TIME);
    if ((pos_start + pw_gzrf1a) < -rfupa) {
        pos_start = RUP_GRD((int)(-rfupa - pw_gzrf1a + GRAD_UPDATE_TIME));
    }

    non_tetime = pos_start + cs_sattime + sp_sattime + pw_gzrf1a + t_exa + tdaqhxb +
        gktime + gkdelay + time_ssi + GRAD_UPDATE_TIME + delt*(intleaves-1) +
        psd_rf_wait + pw_sspshift;

@inline Inversion_new.e InversionEval /* calculate ir time */

    non_tetime = non_tetime + ir_time + satdelay;

    pos_start_rf0 = RUP_GRD(GRAD_UPDATE_TIME + (int)tlead + pw_gzrf0a);

    /****Changing the beg_nontetime calculation to use pos_start instead of */
    /* pos_start_rf0 - MRIge42119 - RJF/JAP ********/ 
    beg_nontetime = hrf1a + pw_gzrf1a + pos_start;
    
    /***SVBranch: HCSDM00259122 - FOCUS walk sat ***/
    if ((walk_sat_flag) && (rfov_flag))
    {
        non_tetime = non_tetime + pw_wksat_tot;
        beg_nontetime = beg_nontetime + pw_wksat_tot;
    }
    /****************************/    

    /* Removed pw_gzrf0a from beg_nontitime calculation - pos_start_rf0 
       is the time at which the flat portion of the slice select trapezoid starts.*/

    beg_nontitime = pw_rf0/2 + pos_start_rf0;
    full_irtime = exist(opti) - sp_sattime - cs_sattime - satdelay - beg_nontetime + beg_nontitime;

    tmin = te_time + non_tetime;

    /* Imgtimutil calculates actual tr for 
       normal scans, available portion of R-R
       interval for imaging for cardiac scans.
       First parameter is only used if the scan
       is cardiac gated. */

    premid_rf90 = optdel1 - psd_card_hdwr_delay  - td0;
    if (imgtimutil(premid_rf90, seq_type, gating, 
                   &avail_image_time)==FAILURE)
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "imgtimutil" );
    else
        act_tr = avail_image_time;

    /* Image time util returns the time available for slices.
       If cardiac, imgtimutil subtracts off the cardiac trigger delay.
    */

    if (existcv(opcgate) && (opcgate == PSD_ON)) {
        /* act_tr is used in powermon routines */
        act_tr = RUP_GRD((int)((float)(exist(ophrep))
                               * (60.0/exist(ophrate))* 1e6));
        cvoverride(optr, act_tr, _optr.fixedflag, PSD_EXIST_ON);
    }

    /* RTG */
    if ((existcv(oprtcgate) && (oprtcgate == PSD_ON)) || (navtrig_flag == PSD_ON))
    {
        /* act_tr is used in powermon routines */
        act_tr = RUP_GRD((int)((float)(exist(oprtrep))
                               * (60.0/exist(oprtrate))* 1e6));
        cvoverride(optr, act_tr, _optr.fixedflag, PSD_EXIST_ON);
    }

    act_tr = RUP_HRD(act_tr);
    avail_image_time = RUP_HRD(avail_image_time);

    rhptsize = exist(opptsize);

    /* BJM: MRIge60610 */
    if(num_overscan > 0) {
        rhnframes = (short)(ceilf((float)exist(opyres)*asset_factor/rup_factor)*rup_factor*fn*nop - ky_offset);
    } else {
        rhnframes = (short)(ceilf((float)exist(opyres)*asset_factor/rup_factor)*rup_factor*fn*nop);
    }

    /* internref: iref_frames */
    iref_frames = iref_etl * intleaves;

    if (rawdata) {
        slice_size = (1+baseline+rhnframes+rhhnover+iref_frames)*
            2*rhptsize*rhfrsize*nex*exist(opnecho);
    } else {
        slice_size = (1+rhnframes+rhhnover+iref_frames)*2*rhptsize*rhfrsize
            *exist(opnecho);
    }

    rhdayres = rhnframes + rhhnover + iref_frames + 1;
    if (exist(opxres) > 256 && exist(opxres) <= 512)
        rhimsize = 512;
    else
        rhimsize = 256;

    /* internref: rhcv calculations */
    if(iref_etl > 0)
    {
        if( ky_dir == PSD_BOTTOM_UP ){
            rhextra_frames_top = 0;
            rhextra_frames_bot = iref_frames;
            rhpc_ref_start = rhdayres - 1;
            rhpc_ref_stop = rhdayres - iref_frames;
        }else if( ky_dir == PSD_TOP_DOWN ){
            rhextra_frames_top = iref_frames;
            rhextra_frames_bot = 0;
            rhpc_ref_start = 1;
            rhpc_ref_stop = iref_frames;
        }
    }
    else
    {
        rhextra_frames_top = 0;
        rhextra_frames_bot = 0;
    }

    /* prepare for maxslquanttps calculation */
    opslquant_old = opslquant;
    if ( PSD_ON == mph_flag ) {
        if (acqmode == 0)
            opslquant = opslquant_old;
        else if (acqmode == 1)
            opslquant = dwi_fphases;
    }

    if (maxslquanttps(&max_bamslice, (int)rhimsize, slice_size, 1, NULL) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslquanttps" );
        return FAILURE;
    }

    /* return opslquant to its original value */
    opslquant = opslquant_old;

    ta_gxwn = (-1.0)*a_gxw;
    gradx[GXWP_SLOT].num = etl/2+(iref_etl/2+iref_etl%2);
    gradx[GXWN_SLOT].num = (etl+1)/2+iref_etl/2;
    gradx[GXWN_SLOT].amp = &ta_gxwn;
    grady[GY1_SLOT].num = 1;
    grady[GY_BLIP_SLOT].num = etl - 1;

    if (eoskillers == PSD_ON) {
        gradx[GXK_SLOT].num = ((eosxkiller==1) ? 1 : 0);
        grady[GYK_SLOT].num = ((eosykiller==1) ? 1 : 0);
        gradz[GZK_SLOT].num = ((eoszkiller==1) ? 1 : 0);
    } else {
        gradx[GXK_SLOT].num = 0;
        grady[GYK_SLOT].num = 0;
        gradz[GZK_SLOT].num = 0;
    }

    grady[GY1_SLOT].ptype = G_TRAP;
    grady[GY1_SLOT].attack = &pw_gy1a;
    grady[GY1_SLOT].decay = &pw_gy1d;
    grady[GY1_SLOT].pw = &pw_gy1;

    /* MRIge51455 - initalize invthick before Inversion_new. */
    if ( floatsAlmostEqualEpsilons(invthick, 0.0, 2) )
    {
        invthick = 1.0;
    }

    /* Fix up grad structure for number of Z blips */
    if ((use_slice_fov_shift_blips) && (mux_flag) && (mux_slices_rf1 > 1)) {
      gradz[GZ_BLIP_SLOT].num = etl - 1;
    } else {
      gradz[GZ_BLIP_SLOT].num = 0;
    }

    /* To avoid error from prescan signal being too small */
    if (rfov_flag)
    {
        temp_slthick = opslthick;
        cvoverride(opslthick, FMax(2, psminslthick, opslthick), PSD_FIX_ON, PSD_EXIST_ON);
        cvoverride(cfh_fov, FMax(2, psminfov/10.0, opfov/10.0), PSD_FIX_ON, PSD_EXIST_ON);
    }
    else
    {
        cvunlock(cfh_fov);
    }

@inline Prescan.e PScveval

    if (rfov_flag)
    {
        cvoverride(opslthick, temp_slthick, PSD_FIX_ON, PSD_EXIST_ON);
    }

    /* Gradient driver and coil heating calculations */
    if (exist(opplane) != PSD_OBL) {
        gradx[GX1_SLOT].powscale = 1.0;
        gradx[GXDPC1_SLOT].powscale = 1.0;
        gradx[GXDPCR_SLOT].powscale = 1.0;
        gradx[GXWP_SLOT].powscale = 1.0;
        gradx[GXWN_SLOT].powscale = 1.0;
        gradx[GXK_SLOT].powscale = 1.0;
        gradx[GXDR_SLOT].powscale = 1.0;
        gradx[GXDL_SLOT].powscale = 1.0; 
        grady[GY1_SLOT].powscale = 1.0;
        grady[GY_BLIP_SLOT].powscale = 1.0;
        grady[GYK_SLOT].powscale = 1.0;
        grady[GYKCS_SLOT].powscale = 1.0;
        grady[GYRF2IV_SLOT].powscale = 1.0;
        grady[GYK0_SLOT].powscale = 1.0;
        grady[GYDR_SLOT].powscale = 1.0;
        grady[GYDL_SLOT].powscale = 1.0;
        gradz[GZRF1_SLOT].powscale = 1.0;
        gradz[GZRF2L1_SLOT].powscale = 1.0;
        gradz[GZRF2R1_SLOT].powscale = 1.0;
        gradz[GZRF2_SLOT].powscale = 1.0;
        gradz[GZRF0_SLOT].powscale = 1.0;
        gradz[GZK_SLOT].powscale = 1.0;
        gradz[GZ1_SLOT].powscale = 1.0;
        gradz[GZMN_SLOT].powscale = 1.0;
        gradz[GZDL_SLOT].powscale = 1.0;
        gradz[GZDR_SLOT].powscale = 1.0;
        gradz[GZ_BLIP_SLOT].powscale = 1.0;
    } else {
        gradx[GX1_SLOT].powscale     = loggrd.xfs/loggrd.tx_xyz;
        gradx[GXDPC1_SLOT].powscale  = loggrd.xfs/loggrd.tx_xz;
        gradx[GXDPCR_SLOT].powscale  = loggrd.xfs/loggrd.tx;
        gradx[GXWP_SLOT].powscale    = loggrd.xfs/loggrd.tx_xy;
        gradx[GXWN_SLOT].powscale    = loggrd.xfs/loggrd.tx_xy;
        gradx[GXK_SLOT].powscale     = loggrd.xfs/loggrd.tx_xyz;
        gradx[GXDL_SLOT].powscale     = loggrd.xfs/loggrd.tx_xyz;
        gradx[GXDR_SLOT].powscale     = loggrd.xfs/loggrd.tx_xyz;

        grady[GY1_SLOT].powscale     = loggrd.yfs/loggrd.ty_xyz;
        grady[GY_BLIP_SLOT].powscale = loggrd.yfs/loggrd.ty_xy;
        grady[GYK_SLOT].powscale     = loggrd.yfs/loggrd.ty_xyz;
        grady[GYK0_SLOT].powscale    = loggrd.yfs/loggrd.ty_xyz;
        grady[GYKCS_SLOT].powscale   = loggrd.yfs/loggrd.ty_xyz;
        grady[GYRF2IV_SLOT].powscale = loggrd.yfs/loggrd.ty_xyz;
        grady[GYDL_SLOT].powscale = loggrd.yfs/loggrd.ty_xyz;
        grady[GYDR_SLOT].powscale = loggrd.yfs/loggrd.ty_xyz;

        if (rfov_flag)
        {
            gradz[GZRF1_SLOT].powscale   = loggrd.zfs/loggrd.tz_yz;
        }
        else
        {
            gradz[GZRF1_SLOT].powscale   = loggrd.zfs/loggrd.tz;
        }

        gradz[GZRF2L1_SLOT].powscale = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZRF2R1_SLOT].powscale = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZRF2_SLOT].powscale   = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZRF0_SLOT].powscale   = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZK_SLOT].powscale     = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZ1_SLOT].powscale     = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZMN_SLOT].powscale    = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZDL_SLOT].powscale    = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZDR_SLOT].powscale    = loggrd.zfs/loggrd.tz_xyz;
        gradz[GZ_BLIP_SLOT].powscale = loggrd.zfs/loggrd.tz_xyz;
    }

    if(iref_etl > 0)
    {
        gradx[GXDPC1_SLOT].num = 1;
        gradx[GXDPCR_SLOT].num = 1;
    }
    else
    {
        gradx[GXDPC1_SLOT].num = 0;
        gradx[GXDPCR_SLOT].num = 0;
    }

    /* RF Pulse Scaling (to peak B1)  ************************/
    /* First, find the peak B1 for the whole sequence. */

    if (findMaxB1Seq(&maxB1Seq, maxB1, MAX_ENTRY_POINTS, rfpulse, RF_FREE) == FAILURE)
    {
        epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,EE_ARGS(1),STRING_ARG,"findMaxB1Seq");
        return FAILURE;
    }

    /* Throw in an extra scale factor to account for xmtadd. */
    if (setScale(L_SCAN, RF_FREE, rfpulse, maxB1[L_SCAN],
                 maxB1[L_SCAN]/maxB1Seq) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "setScale" );
        return FAILURE;
    }

    /* if FLAIR, available imaging time updated */
    if (epi_flair==PSD_ON)
    {
        maxslq_titime=exist(opti) - sp_sattime - cs_sattime - satdelay - beg_nontetime 
            - (pw_rf0 + 2*pw_gzrf0a + pos_start_rf0);
        maxslq_ilir = maxslq_titime/(tmin + pw_rf0 + 2*pw_gzrf0a + pos_start_rf0);
        avail_se_time = maxslq_titime;
    }
    else
    {
        avail_se_time = avail_image_time;
    }

    minseqcoil_esp = esp;     /* MRIhc16090 */

    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e PulsegenonhostSwitch

    if( opdiffuse == PSD_ON &&
        ((old_weighted_avg_grad != weighted_avg_grad) ||
         (!floatsAlmostEqualEpsilons(old_avg_bval, avg_bval, 2) && weighted_avg_grad == PSD_ON)) )
    {
        old_weighted_avg_grad = weighted_avg_grad;
        old_avg_bval = avg_bval;
        /* set_cvs_changed_flag(TRUE); */
        enforce_minseqseg = PSD_ON;
    }

    if( PSD_ON == weighted_avg_grad &&
        ((opdiffuse == PSD_ON && tensor_flag == PSD_OFF) ||
         (tensor_flag == PSD_ON && num_tensor >= MIN_DTI_DIRECTIONS && 
          ((num_tensor <= act_numdir_clinical) || 
          ((PSD_ON == exist(opresearch)) && (rhtensor_file_number > 0) && (num_tensor <= MAX_DIRECTIONS))))))
    {
        if( FAILURE == set_tensor_orientations() )
        {
            return FAILURE;
        }
    }

    /* Rio diffusion cyclcing, need to check # of dirs, #of T2s, ... to recalculate timing*/
    /* It's necessary to trigger minseq() when switching to 3in1*/
    if( ((opdiffuse == PSD_ON) && (isRioSystem())) &&
        ((old_num_dirs != opdifnumdirs) || (old_opdifnumt2!=opdifnumt2) || (old_dualspinecho_flag !=dualspinecho_flag)
            || (old_diff_order_flag != diff_order_flag) || (old_opdfax3in1 != opdfax3in1)) )
    {
        old_num_dirs = opdifnumdirs;
        old_opdifnumt2 = opdifnumt2;
        old_dualspinecho_flag = dualspinecho_flag;
        old_diff_order_flag = diff_order_flag;
        old_opdfax3in1 = opdfax3in1;

        enforce_minseqseg = PSD_ON;
    }

    INT seq_entry_index = 0;  /* core sequence = 0 */

    /* Perform gradient safety checks for main sequence */  

    if(PSD_OFF == oploadprotocol)
    {
        time_profiler_start_timer("EPI2:minseq()");

        if ( FAILURE == minseq( &min_seqgrad,
                                gradx, GX_FREE,
                                grady, GY_FREE,
                                gradz, GZ_FREE,
                                &loggrd, seq_entry_index, tsamp,
                                avail_image_time,
                                use_ermes, seg_debug ) )
        {
            epic_error( use_ermes, supfailfmt,
                        EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                        STRING_ARG, "minseq" );
            return FAILURE;
        }

        time_profiler_stop_timer("EPI2:minseq()");
    }

    if (diff_order_debug == PSD_ON)
    {
        FILE *fp= NULL;
#ifdef PSD_HW
        const char *dir_log = "/usr/g/service/log";
#else
        const char *dir_log = ".";
#endif
        char fname_tensor_host[255];
        int ii, kk;

        sprintf(fname_tensor_host, "%s/diff_order_tensor_host.txt", dir_log);

        if (NULL != (fp = fopen(fname_tensor_host, "w")))
        {
            if(optensor >= PSD_ON)
            {
                fprintf(fp,"%d\n",opdifnumdirs+opdifnumt2);
                for( kk=0; kk< (opdifnumdirs + opdifnumt2); kk++)
                {
                    fprintf(fp,"%f %f %f\n", TENSOR_HOST[0][kk],TENSOR_HOST[1][kk],TENSOR_HOST[2][kk]);
                }
            }
            else
            {
                fprintf(fp,"%d\n",opdifnumt2 + opdifnumdirs * opnumbvals);

                for( kk=0; kk<opdifnumt2; kk++)
                {
                    fprintf(fp,"%f %f %f\n", TENSOR_HOST[0][kk],TENSOR_HOST[1][kk],TENSOR_HOST[2][kk]);
                }
                for( kk=0; kk<opnumbvals; kk++)
                {
                    for(ii = 0; ii<opdifnumdirs; ii++)
                    {
                        fprintf(fp,"%f %f %f\n",
                                TENSOR_HOST[0][ii+opdifnumt2]* sqrt(diff_bv_weight[kk]),
                                TENSOR_HOST[1][ii+opdifnumt2]* sqrt(diff_bv_weight[kk]),
                                TENSOR_HOST[2][ii+opdifnumt2]* sqrt(diff_bv_weight[kk]) );
                    }
                }
            }

            fprintf(fp, "%d,%d\n", opnumbvals, opdifnumt2);
            for (kk=0; kk<opnumbvals; kk++)
            {
                fprintf(fp, "%d ", (int)difnextab[kk]);
            }

            fclose(fp);
        }
    }


    /* Set the amps back that are scaled within calcPulseParams function */
    if((PSD_ON == gradHeatMethod) && (PSD_ON == derate_amp)) 
    {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            ia_gxdl = (int)(a_gxdl * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr = (int)(a_gxdr * (float)max_pg_iamp / loggrd.tx);
            
            ia_gydl = (int)(a_gydl * (float)max_pg_iamp / loggrd.ty);
            ia_gydr = (int)(a_gydr * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl = (int)(a_gzdl * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr = (int)(a_gzdr * (float)max_pg_iamp / loggrd.tz);
	    if(ftde_flag == PSD_ON){/* granty maybe */
            	ia_gxde = (int)(a_gxde * (float)max_pg_iamp / loggrd.tx);

            	ia_gyde = (int)(a_gyde * (float)max_pg_iamp / loggrd.ty);

            	ia_gzde = (int)(a_gzde * (float)max_pg_iamp / loggrd.tz);
	    }/* granty maybe end */
        } 
        else 
        {
            ia_gxdl1 = (int)(a_gxdl1 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr1 = (int)(a_gxdr1 * (float)max_pg_iamp / loggrd.tx);
        
            ia_gxdl2 = (int)(a_gxdl2 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr2 = (int)(a_gxdr2 * (float)max_pg_iamp / loggrd.tx);

            ia_gydl1 = (int)(a_gydl1 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr1 = (int)(a_gydr1 * (float)max_pg_iamp / loggrd.ty);
            
            ia_gydl2 = (int)(a_gydl2 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr2 = (int)(a_gydr2 * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl1 = (int)(a_gzdl1 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr1 = (int)(a_gzdr1 * (float)max_pg_iamp / loggrd.tz);
            
            ia_gzdl2 = (int)(a_gzdl2 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr2 = (int)(a_gzdr2 * (float)max_pg_iamp / loggrd.tz);  
        }
    }

    if (debug_mux_rf)
    {
        printf("MB: before minseqrfamp opaccel_mb_stride = %d, mux_slices_rf2 =%d\n", opaccel_mb_stride, mux_slices_rf2);
    }

    /* RF amp, SAR, and system limitations on seq time */
    if (minseqrfamp(&min_seqrfamp,(int)RF_FREE,rfpulse, 
                    L_SCAN) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "minseqrfamp" );
        return FAILURE;
    }

    if (maxseqsar(&max_seqsar, (int)RF_FREE, rfpulse, L_SCAN) == FAILURE)
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxseqsar" );
        return FAILURE;
    }

    /* Note: this routine still uses the old coefficients */
    if (maxslicesar(&max_slicesar, (int)RF_FREE,rfpulse, 
                    L_SCAN) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslicesar" );
        return FAILURE;
    }

    /* calculate maximum number of slices to fit in interleaved total IR time */
    if(epi_flair==PSD_ON)
    {
        other_slice_limit = IMin(3, max_slicesar, max_bamslice,maxslq_ilir);
    }
    else
    {
        if(opdiffuse == PSD_OFF)
        {
            other_slice_limit = IMin(2, max_slicesar, max_bamslice);
        }
        else
        {
            other_slice_limit = IMin(3, max_slicesar, max_bamslice, (int)(MAX_SLICES_DTI/dwi_fphases));
            if(mux_flag){
                other_slice_limit = IMin(3, max_slicesar*mux_slices_rf1, max_bamslice, (int)(MAX_SLICES_DTI/dwi_fphases));
            }
        }
    }

    if (rfov_flag)
    {
        if ((rfov_maxnslices >= DEFAULT_MAXNSLICES_RFOV) && (exist(optr) >= FOCUS_ONE_ACQ_MIN_TR))   /* HCSDM00397660 */
        {
            rfov_maxnslices = other_slice_limit;
        }
        else
        {
            rfov_maxnslices = DEFAULT_MAXNSLICES_RFOV;
        }
        other_slice_limit = IMin(2, other_slice_limit, rfov_maxnslices);
    }

    /* Here, calculate #acqs, Auto TI value, avmaxslquant for ASPIR,
       because adaptive Auto TI value depends on slice/acqs.
       This ASPIR rutine is not needed for fixed TI model. */
    if ((PSD_ON == aspir_flag) && (ASPIR_AUTO_TI_ADAPTIVE == aspir_auto_ti_model))
    {
        int null_ti_temp = 0;
            
        if(mux_flag)
        {
            int tmin_temp = 0;
            int tmin_total_temp = 0;

            null_ti_temp = calc_ASPIR_TI(mux_slquant);
            focus_eval_oscil = 0;
            tmin_temp = tmin + (null_ti_temp - exist(opti));
            tmin_total_temp = IMax(4, min_seqgrad, min_seqrfamp, tmin_temp, max_seqsar);

            if ((PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype))
            {
                if ((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF )|| ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                {
                    tmin_total_temp += edwi_extra_time;
                }
            }

            /* MRIge52734 - increase tmin_total for long etl scan to prevent EOS error. PH */
            if (( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON))
            {
                if ((opyres == 256) && (tmin_total_temp < 500ms))
                {
                    tmin_total_temp = 500ms;
                }
            }

            /* Calculate avmaxslquant */
            if (maxslquant(&av_temp_int, avail_se_time, other_slice_limit,
                           seq_type, tmin_total_temp) == FAILURE)
            {
                epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslquant");
                return FAILURE;
            }

            avmaxslquant = ( (av_temp_int%2)?av_temp_int:(av_temp_int-1) ) * mux_slices_rf1;
            if (avmaxslquant > other_slice_limit)
            {
                int temp_count = other_slice_limit / mux_slices_rf1;
                avmaxslquant = ( (temp_count%2)?temp_count:(temp_count-1) ) * mux_slices_rf1;
            }

        }
        else
        {
            /* HCSDM00361682 */
            if(focus_eval_oscil)
            {
                int slicein1_temp = 0;
                acqs = force_acqs;
                avmaxslquant = force_avmaxslquant;
                slicein1(&slicein1_temp, acqs, seq_type);
                null_ti_temp = calc_ASPIR_TI(slicein1_temp);
                if(!keep_focus_eval_oscil)
                {
                    focus_eval_oscil = 0;
                }
            }
            else
            {
                int acqs_index = 1;

                while (acqs_index <= exist(opslquant))
                {
                    int slicein1_temp = 0;
                    int tmin_temp = 0;
                    int tmin_total_temp = 0;
                    int acqs_temp = 0;

                    slicein1(&slicein1_temp, acqs_index, seq_type);
                    null_ti_temp = calc_ASPIR_TI(slicein1_temp);
                    tmin_temp = tmin + (null_ti_temp - exist(opti));
                    tmin_total_temp = IMax(4, min_seqgrad, min_seqrfamp, tmin_temp, max_seqsar);

                    if ((PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype))
                    {
                        if ((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF )|| ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                        {
                            tmin_total_temp += edwi_extra_time;
                        }
                    }

                    /* MRIge52734 - increase tmin_total for long etl scan to prevent EOS error. PH */
                    if (( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON))
                    {
                        if ((opyres == 256) && (tmin_total_temp < 500ms))
                        {
                            tmin_total_temp = 500ms;
                        }
                    }

                    /* Calculate avmaxslquant */
                    if (maxslquant(&av_temp_int, avail_se_time, other_slice_limit,
                                seq_type, tmin_total_temp) == FAILURE)
                    {
                        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslquant");
                        return FAILURE;
                    }


                    /* Calculate # of acqs with new avmaxslquant */
                    if (maxpass(&acqs_temp, seq_type, (int)exist(opslquant), avmaxslquant) == FAILURE)
                    {
                        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxpass");
                        return FAILURE;
                    }

                    if ((acqs_index < acqs_temp) && (PSD_OFF == mux_flag))
                    {
                        acqs_index++;
                    }
                    else
                    {
                        int start_max_slquant = 0;
                        int loop_counter = 0;
                        int MAX_LOOP_COUNT = 20;

                        /* To reduce # of iterations for slice looping, */
                        /* set avmaxslaunt if acqs_index == acqs_temp.  */
                        if (acqs_index > acqs_temp)
                        {
                            slicein1(&slicein1_temp, acqs_temp, seq_type);
                            null_ti_temp = calc_ASPIR_TI(slicein1_temp);
                            start_max_slquant = slicein1_temp;
                        }
                        else
                        {
                            start_max_slquant = avmaxslquant;
                        }

                        /* Find maxslquant for this acqs */
                        /* This calculation is only applied for Auto TI cases.   */
                        /* For Manual TI, avmaxslquant will be calculated lator. */
                        if (PSD_ON == exist(opautoti))
                        {
                            while (loop_counter < MAX_LOOP_COUNT)
                            {
                                int new_auto_ti = 0;
                                int new_tmin = 0;

                                new_auto_ti = calc_ASPIR_TI(start_max_slquant);
                                new_tmin = tmin + (new_auto_ti - exist(opti));
                                tmin_total_temp = IMax(4, min_seqgrad, min_seqrfamp, new_tmin, max_seqsar);

                                if ((PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype))
                                {
                                    if ((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF )|| ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                                    {
                                        tmin_total_temp += edwi_extra_time;
                                    }
                                }

                                /* MRIge52734 - increase tmin_total for long etl scan to prevent EOS error. PH */
                                if (( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON))
                                {
                                    if ((opyres == 256) && (tmin_total_temp < 500ms))
                                    {
                                        tmin_total_temp = 500ms;
                                    }
                                }

                                /* Calculate avmaxslquant by maxslquant() */
                                if (maxslquant(&av_temp_int, avail_se_time, other_slice_limit,
                                            seq_type, tmin_total_temp) == FAILURE)
                                {
                                    epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslquant");
                                    return FAILURE;
                                }

                                /*multiband max number of slices*/
                                if (mux_flag)
                                {
                                    avmaxslquant = ( (av_temp_int%2)?av_temp_int:(av_temp_int-1) ) * mux_slices_rf1;
                                    if (avmaxslquant > other_slice_limit)
                                    {
                                        int temp_count = other_slice_limit / mux_slices_rf1;
                                        avmaxslquant = ( (temp_count%2)?temp_count:(temp_count-1) ) * mux_slices_rf1;
                                    }
                                }

                                if (start_max_slquant < avmaxslquant)
                                {
                                    start_max_slquant = avmaxslquant;
                                    loop_counter++;
                                }
                                else
                                {
                                    break;
                                }

                            } /* End of while loop */
                        }
                        break;
                    }
                } /* acqs_index loop */
            }
        }

        set_ASPIR_TI(null_ti_temp);

        /* Calculate cs_sattime, non_tetime and tmin with new opti */
        if (ChemSatEval(&cs_sattime) == FAILURE)
        {
            epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "ChemSatEval");
            return FAILURE;
        }

        /* HCSDM00361682  pos_start is changed in calcPulseParams() */
        pos_start_init = RUP_GRD((int)tlead + GRAD_UPDATE_TIME);
        if ((pos_start_init + pw_gzrf1a) < -rfupa) {
            pos_start_init = RUP_GRD((int)(-rfupa - pw_gzrf1a + GRAD_UPDATE_TIME));
        }
 
        non_tetime = pos_start_init + cs_sattime + sp_sattime + pw_gzrf1a + t_exa + tdaqhxb +
            gktime + gkdelay + time_ssi + GRAD_UPDATE_TIME + delt*(intleaves-1) +
            psd_rf_wait + pw_sspshift;

        non_tetime = non_tetime + ir_time + satdelay;

        tmin = te_time + non_tetime;
    }

    /* BJM PGEN_HOST */
    /* Calculate minimum sequence time based on coil, gradient driver,
       pulse width modulation, RF amplifier, and playout */
    tmin_total = IMax( 4, min_seqgrad, min_seqrfamp, tmin, max_seqsar );

    if ((PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype))
    {
        if ((opdfaxtetra > PSD_OFF)  || (opdfax3in1 > PSD_OFF )|| ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
        {
            tmin_total += edwi_extra_time;
        }
    }

    if (navtrig_flag)
    {
        /* In Navigator Triggering, imaging scan interval can be reduced
           by adjusting navtrig_waittime after imaging scan. */
        if (isKizunaSystem())
        {
            nav_image_interval = IMax(3, tmin, minseqgrddrv_t, minseqgpm_maxpow_t);

            if ((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF) || ((opdfaxall > PSD_OFF) && (gradopt_diffall == PSD_ON)))
            {
                nav_image_interval += edwi_extra_time;
            }
        }
        else
        {
            nav_image_interval = tmin_total;
        }

        navtrig_waittime = IMax(2, 500ms, (tmin_total - nav_image_interval) * slquant_per_trig - navtrig_wait_before_imaging);
    }

    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqcoil_t = %d\n", minseqcoil_t );
    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqgrddrv_t = %d\n", minseqgrddrv_t );
    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqgpm_t = %d\n", minseqgpm_t );
    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "min_seqrfamp = %d\n", min_seqrfamp );
    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "tmin = %d\n", tmin );
    printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "tmin_total = %d\n", tmin_total );

    /* MRIge52734 - increase tmin_total for long etl scan to prevent EOS error. PH */
    if ( ( ( (cfsrmode == PSD_SR50) && !(isStarterSystem()) ) || cfsrmode == PSD_SR77) && (vrgfsamp == PSD_ON)) 
    {
        if ( (opyres >= 256) && (tmin_total < 500ms) )
            tmin_total = 500ms;
    }

    /* t1flair_stir */
    if (PSD_ON == t1flair_flag)
    {
        tmin_total_ir = ir_time;
        tmin_total_acq_seq = tmin_total - ir_time;
    }

    /* Used for cardiac intersequence time.  Round up to integer number of ms
     * but report to scan in us. */
    avmintseq = tmin_total;
    advroundup(&avmintseq);
    if ((exist(opcgate) == PSD_ON) && existcv(opcgate)) {
        advroundup(&tmin_total); /* this is the min seq time cardiac
                                    can run at.
                                    Needed for adv. panel validity until all 
                                    cardiac buttons exist. */
        if (existcv(opcardseq)) {
            switch (exist(opcardseq)) {
            case PSD_CARD_INTER_MIN:
                psd_tseq = avmintseq;
                tmin_total = avmintseq;
                break;
            case PSD_CARD_INTER_OTHER:
                psd_tseq = optseq;
                if (optseq > tmin_total)
                    tmin_total = optseq;
                break;
            case PSD_CARD_INTER_EVEN:
                /* Roundup tmin_total for the routines ahead. */
                advroundup(&tmin_total);
                break;
            }
        }	else {
            psd_tseq = avmintseq;
        }
    }

    /* RTG */
    avminrttseq = tmin_total;
    advroundup(&avminrttseq);

    if (((exist(oprtcgate) == PSD_ON) && existcv(oprtcgate)) ||
        (navtrig_flag == PSD_ON))
    {
        advroundup(&tmin_total);

        if (existcv(oprtcardseq)) {
            switch (exist(oprtcardseq)) {
            case PSD_CARD_INTER_MIN:
                psd_tseq = avminrttseq;
                tmin_total = avminrttseq;
                break;
            case PSD_CARD_INTER_OTHER:
                psd_tseq = oprttseq;
                if (oprttseq > tmin_total) {
                    tmin_total = oprttseq;
                }
                break;
            case PSD_CARD_INTER_EVEN:
                /* Roundup tmin_total for the routines ahead. */
                advroundup(&tmin_total);
                break;
            }
        }
        else {
            psd_tseq = avminrttseq;
        }
    } /* end RTG */  

    if (maxphases(&av_temp_int, tmin_total, seq_type,
                  other_slice_limit) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxphases" );
        return FAILURE;
    }

    /* For epi_flair, avmaxslquant calculation will performed later. */
    /* For other cases, calculate avmaxlquant here. */
    if (epi_flair==PSD_OFF)
    {
        /* HCSDM00361682 */
        if (!((PSD_ON == aspir_flag) && (ASPIR_AUTO_TI_ADAPTIVE == aspir_auto_ti_model) && (PSD_ON == exist(opautoti))))
        {
            if(focus_eval_oscil)
            {
                acqs = force_acqs;
                avmaxslquant = force_avmaxslquant;
            }
            else if (maxslquant(&av_temp_int, avail_se_time, other_slice_limit,
                           seq_type, tmin_total) == FAILURE) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxslquant" );
                return FAILURE;
            }

            /*multiband max number of slices*/
            if (mux_flag)
            {
                avmaxslquant = ( (av_temp_int%2)?av_temp_int:(av_temp_int-1) ) * mux_slices_rf1;
                if (avmaxslquant > other_slice_limit)
                {
                    int temp_count = other_slice_limit / mux_slices_rf1;
                    avmaxslquant = ( (temp_count%2)?temp_count:(temp_count-1) ) * mux_slices_rf1;
                }
            }
        }
    }

    /* Max slice per pass = 1 for sequential */
    if (exist(opirmode) == PSD_SEQMODE_ON)
        avmaxslquant = 1;
    else {
        if (opautotr == PSD_ON)
        {
            avmaxslquant = SLTAB_MAX;
        }
    } /* end if(opirmode) */

    /* find maximum number of passes allowed */  
    if ((PSD_OFF==epi_flair) && (PSD_OFF==t1flair_flag)) 
    {
        if (maxpass(&acqs,seq_type,(int)exist(opslquant), avmaxslquant) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxpass" );
            return FAILURE;
        }

        /* Set minimum acqs for non t1flair IR cases */
        if ((PSD_ON == ir_prep_manual_tr_mode) && (acqs < (int)exist(opuser8)))
        {
            acqs = (int)exist(opuser8);
            avmaxacqs = acqs;
        }
    }

    act_acqs = acqs;

    tmp_deadlast=0;

    /* Calculate max slice quant, etc. based on flair params */
    if (epi_flair==PSD_ON) {

        /*  maxslices in one false_acqs  */
        /*  For flair account for the dead time in the IR portion of the scan */

        if((exist(opdiffuse)==PSD_OFF) && (tensor_flag == PSD_OFF))
        {
            tmin_flair=IMax(2,tmin,tmin_total/2);
            if(tmin_total/2 < tmin) tmin_flair=tmin_total;
			
            /* SVBranch: GEHmr04247 */
            if(isSVSystem())
            {
                tmin_flair = tmin_total;
            }			
        }
        if((exist(opdiffuse)==PSD_ON) || (tensor_flag == PSD_ON))
        {
            tmin_flair=tmin_total;
        }

        maxslquant(&max_slice_ti, avail_se_time, other_slice_limit,
                   seq_type, tmin_flair);

        /* ***************************************************************************
           force false_acqs = 2 for flair
           ****************************** */
        false_acqs =2;

        /* acqs = number false_acqs for opslquant    */
        maxpass(&acqs,seq_type,(int)exist(opslquant), max_slice_ti);

        if((acqs % false_acqs) == 0)
            act_acqs = (int)((float)acqs/(float)false_acqs);
        if((acqs % false_acqs) != 0) {
            act_acqs = (int)((float)acqs/(float)false_acqs)+1;
        }

        acqs=act_acqs;

        /* number of slices in each false_acqs      */
        slicein1(&false_slquant1, act_acqs*false_acqs, seq_type);

        avmaxacqs = act_acqs;
        avmaxslquant=max_slice_ti*false_acqs;

        if (rfov_flag)
        {
            avmaxslquant = IMin(2, avmaxslquant, rfov_maxnslices);
        }

        dda_packb = false_acqs-1;
        dda_pack  = false_acqs;

        /*****************************************************************************************
          Fixed deadlast calculation. Use avail_se_time for calculation of 
          sequence times  for all but the last sequence. The dead time for the last sequence,
          deadlast, must be increased so the total sequence time adds up to the TR time  
          Time per sequence is avail_se_time/false_slquant1. 
          - MRIge42119  RJF/ JAP.
        ******************************************************************************************/
        deadlast = RUP_GRD((act_tr/false_acqs) - (full_irtime+avail_se_time)
                           + (avail_se_time/false_slquant1 - tmin - time_ssi));

#ifdef UNDEF
        /** Keeping the old calculation here, for future reference - RJF/JAP, MRIge42119 **/
        deadlast = RUP_GRD((act_tr/false_acqs) - (full_irtime+tmin_flair*false_slquant1));
#endif

        tmp_deadlast=deadlast;
        /*  set at least 1s of dead time between false_acq  */
        if(deadlast < 100ms)deadlast=100ms;
        /* tmp_deadlast is to be added to scan time  */
        if(deadlast > tmp_deadlast)tmp_deadlast=deadlast-tmp_deadlast;
        else tmp_deadlast=0;
    }

    /* t1flair_stir */
    dummyslices = 0;
    act_edge_slice_enh_flag = PSD_OFF;

    if ((PSD_ON == epi_flair) || (PSD_ON == irprep_flag)) /* irprep_support */
    {
        /* check slquant1 is non zero */
        if (0 == avmaxslquant)
        {
            epic_error(use_ermes, "TI is too short, increase TI.", EM_PSD_TI_OUT_OF_RANGE1, EE_ARGS(0));
            return FAILURE;
        }

        if (PSD_ON == epi_flair)
        {
            invseqtime = RUP_GRD(full_irtime - time_ssi);
            invthick = (float)act_acqs * (opslthick + opslspace);
        } 
        else if (PSD_ON == irprep_flag)
        {
            invthick = exist(opslthick);
        }
    }

    if (PSD_ON == t1flair_flag)
    {
        /* display auto TI in pitival2 */
        if (exist(opautoti) == PSD_OFF)
        {
            int keep_opti1;
            int keep_optifixedflag;
            int keep_optiexistflag;

            keep_opti1 = exist(opti);
            keep_optifixedflag = _opti.fixedflag;
            keep_optiexistflag = _opti.existflag;
            cvoverride(opautoti, PSD_ON, PSD_FIX_OFF, PSD_EXIST_ON);

            if (FAILURE == T1flair_analytical_seqtime())
            {
                epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,
                           EE_ARGS(1),STRING_ARG,"T1flair_analytical_seqtime");
                return FAILURE;
            }

            pitival2 = exist(opti);
            cvoverride(opautoti, PSD_OFF, PSD_FIX_OFF, PSD_EXIST_ON);
            cvoverride(opti, keep_opti1, keep_optifixedflag, keep_optiexistflag);
        }

        if (FAILURE == T1flair_analytical_seqtime())
        {
            epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,
                       EE_ARGS(1),STRING_ARG,"T1flair_analytical_seqtime");
            return FAILURE;
        }

        /* display auto TI in pitival2 */
        if (opautoti == PSD_ON) pitival2 = exist(opti);

        if (existcv(optracq) && (exist(optracq) > 0))
        {
            act_acqs = acqs;
        }

        /* BJM - this needed here so false_slquant1 is */
        /* correct for gated scans... */
        if ((seq_type == TYPXRR) || (seq_type == TYPRTG) || (seq_type == TYPNCATRTG) || (seq_type == TYPCATRTG))
        {
            slquant1 = opslquant / act_acqs + ((opslquant % act_acqs) ? 1 : 0);
        }
        else
        {
            slquant1 = slquant_per_trig;
        } 

@inline Inversion_new.e InversionEval1
    }
    else
    {
        /* Now calculate slquant_per_trig */
        slicein1(&slquant_per_trig, act_acqs, seq_type);
        slquant1 = opslquant / act_acqs + ((opslquant % act_acqs) ? 1 : 0);

        if (PSD_ON == ir_prep_manual_tr_mode)
        {
            float currentNullTI = getNullTI(exist(optr),
                                            INT_INPUT_NOT_USED,
                                            act_acqs * (exist(opslthick) + exist(opslspace)),
                                            exist(opslthick) / gscale_rf1,
                                            invthick / gscale_rf0);
            
            /* Display auto TI in pitival2 */
            pitival2 = currentNullTI;
            
            if (PSD_ON == exist(opautoti))
            {
                act_ti = currentNullTI;
                cvoverride(opti, act_ti, PSD_FIX_ON, PSD_EXIST_ON);
            }       
        }
    }

    if ((PSD_ON == epi_flair) || (PSD_ON == irprep_flag))
    {
        ihti = exist(opti);
    }

    /* BJM - this needed here so false_slquant1 is */
    /* correct for gated scans... */
    if ((seq_type == TYPXRR) || (seq_type == TYPRTG) || (seq_type == TYPNCATRTG) || (seq_type == TYPCATRTG))
        slquant1 = opslquant / act_acqs + ((opslquant % act_acqs) ? 1 : 0);
    else
        slquant1 = slquant_per_trig;

    /* YMSmr06515: # of slice locations expansion */
    if ( (act_acqs > MAX_PASSES) && (existcv(opslquant)) )
    {
        epic_error(use_ermes,
                   "Maximum of %d acqs exceeded.  Increase locations/acq or decrease number of slices.",
                   EM_PSD_MAX_ACQS, 1, INT_ARG, MAX_PASSES);
        return FAILURE;
    }

    if ( (slquant1 > MAX_SLICES_PER_PASS) && (existcv(opslquant)) )
    {
        epic_error(use_ermes,
                   "The no. of locations/acquisition cannot exceed the max no. of per acq = %d.",
                   EM_PSD_LOC_PER_ACQS_EXCEEDED_MAX_SL_PER_ACQ, 1, INT_ARG, MAX_SLICES_PER_PASS);
        return FAILURE;
    }

    if (epi_flair == PSD_OFF) {
        false_slquant1 = slquant1;
        false_acqs = 1;
        dda_packb = 0;

        /***Changing dda_pack to 1, to have one disdaq for each slice.
            Note that this should be equal to the disdaq_shots used in the 
            host scantime calculation - RJF, MRIge42119 **/

        dda_pack  = 1;
    }

    if ( (mph_flag==PSD_ON) && (acqmode == 1) ) /* sequential multiphase */
    {
        slquant_per_trig = 1;
        false_slquant1 = 1;
    }

    if (slquant_per_trig == 0) {
        epic_error( use_ermes, "slquant_per_trig is 0", EM_PSD_SLQUANT_ZERO, EE_ARGS(0) );
        return FAILURE;
    }

    if (T1flair_options() == FAILURE)
    {
        return FAILURE;
    }

    /* ****************************
       Calculate extra sat time
       ************************** */
    SatCatRelaxtime(act_acqs,(act_tr/(mux_flag?mux_slquant:slquant1)),seq_type);

    /* Calculate inter-sequence delay time for 
       even spacing. */
    if ((exist(opcardseq) == PSD_CARD_INTER_EVEN) && existcv(opcardseq)) {
        psd_tseq = piait/slquant_per_trig;
        advrounddown(&psd_tseq);
    }
    pitseq = avmintseq; /* Value scan displays in min inter-sequence
                           display button */

    /* RTG */
    if ((exist(oprtcardseq) == PSD_CARD_INTER_EVEN) && existcv(oprtcardseq)) {
        psd_tseq = pirtait/slquant_per_trig;
        advrounddown(&psd_tseq);
    }

    /* Set optseq to inter-seq delay value for adv. panel routines. */
    _optseq.fixedflag = 0;
    optseq = psd_tseq;
    /* Have existence of optseq follow opcardseq. */
    _optseq.existflag = _opcardseq.existflag;

    if (seqtime(&max_seqtime, avail_image_time, mux_flag?mux_slquant:slquant_per_trig, seq_type) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "seqtime" );
        return FAILURE;
    }

    if (maxte1(&av_temp_int,max_seqtime, TYPNVEMP, non_tetime, 0) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "maxte1" );
        return FAILURE;
    }

    avround = 1;
    if (mintr(&av_temp_int, seq_type, tmin_total, mux_flag?mux_slquant:slquant_per_trig,
              gating) == FAILURE) 
    {
        /* for starter product, add error information for gradient safety model power supply peak power over limit */
        if(1000000000 == min_seqgrad && 5551 == cfgradamp)
        {
            epic_error(use_ermes, "", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1), STRING_ARG,
                       "please decrease b-value ");
            return FAILURE;
        }
        else
        {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "mintr" );
        return FAILURE;
    }
    }

    /* hardcode min tr times based on ipg sequence update time measurements */
    if (fract_ky == PSD_FRACT_KY) {
        if ( (exist(opyres) <= 512) && (exist(opyres) > 128) && (avmintr <= 280ms) )
            avmintr = 280ms;
        if ( (exist(opyres) <= 128) && (exist(opyres) > 64) && (avmintr <= 120ms) )
            avmintr = 120ms;
        if ( (exist(opyres) <= 64) && (avmintr <= 60ms) )
            avmintr = 60ms;
    }
    if (fract_ky == PSD_FULL_KY) {
        if ( (exist(opyres) <= 512) && (exist(opyres) > 128) && (avmintr <= 600ms) )
            avmintr = 600ms;
        if ( (exist(opyres) <= 128) && (exist(opyres) > 64) && (avmintr <= 260ms) )
            avmintr = 260ms;
        if ( (exist(opyres) <= 64) && (avmintr <= 100ms) )
            avmintr = 100ms;
    }


    /* MRIge57853 (and HiB Diffusion): set lower limit for optr with flair	*/
    if(epi_flair==PSD_ON) {
        avmintr=FLAIR_MIN_TR;
    } else {
        avmintr = HIB_MIN_TR;
    }

    if( tmin_total > avmintr )
    {
        avmintr = tmin_total;
        advroundup(&avmintr);
    }
    
    /* 2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */

    /* Auto TR mode is determined in T1flair_analytical_seqtime for t1flair */
    if (t1flair_flag == PSD_OFF)
    {
        automintr_compatibility_checks();
    }

    if ((exist(opflair) == PSD_ON) || ((PSD_ON == aspir_flag) && (PSD_ON == exist(opautoti))))
    {
        piautotrmode = PSD_AUTO_TR_MODE_MANUAL_TR;    /* disable autoTR for flair and ASPIR*/  
    }

    if (t1flair_flag == PSD_OFF)
    {
        if (automintr_set_display_acqs() == FAILURE)
        {
            return FAILURE;
        }

        /* HCSDM00398231 */
        if ( (existcv(optracq) && (exist(optracq) > 0)) && rfov_flag && (exist(optr) < FOCUS_ONE_ACQ_MIN_TR) && (sl_acq > DEFAULT_MAXNSLICES_RFOV))
        {
            save_avmintr = avmintr;
            save_pitracqval4 = pitracqval4;
            avmintr = FOCUS_ONE_ACQ_MIN_TR;
            if (automintr_set_display_acqs() == FAILURE)
            {
                return FAILURE;
            }
            avmintr = save_avmintr;
            pitracqval4 = save_pitracqval4;
        }

        /* HCSDM00202538 */
        if (existcv(optracq) && (exist(optracq) > 0))
        {
            act_acqs = acqs;
            /* HCSDM00363791 */
            if(PSD_OFF == epi_flair)
            {
                slicein1(&slquant_per_trig, act_acqs, seq_type);
                slquant1 = slquant_per_trig;
                false_slquant1 = slquant_per_trig;
                avail_se_time = avail_image_time;
            }
        }
    }
    
    /* HCSDM00155514 */
    if (rfov_flag)
    {
        avmaxslquant = IMin(2, avmaxslquant, rfov_maxnslices);
    }

    if ( (mph_flag==PSD_ON) && (acqmode == 1) ) { /* sequential multiphase */
        acqs = exist(opslquant);
        act_acqs=acqs;
        avmaxacqs = acqs;
        avmaxslquant = 1;
    }

@inline RTB0.e RTB0Cveval1
   
    /* t1flair_stir */
    T1flairPredownload();
    avround = 1;

    /* need a more elaborate algorithm here for disdaq determination */
    if ((intleaves != 1) || (PSD_ON == epi_flair) || (PSD_ON == opdiffuse) || (PSD_ON == tensor_flag))
        dda = 1;
    else
        dda = 0;
    
    /* t1flair_stir */
    if (PSD_ON == t1flair_flag)
    {
        dda += dda_t1flair;
    }

    ref_dda = dda;

    /* Refless EPI: keep dda with DW-EPI Flair and acqs > 1 */
    if ((ref_in_scan_flag == PSD_ON) && !((epi_flair == PSD_ON) && (act_acqs > 1)))
    {
        scan_dda = dda - 1;
    }
    else
    {
        scan_dda = dda;
    }

    /*KVA 91_merge */
    /*multiband and MUSE support single acq only*/
     if ( PSD_ON == tensor_flag || PSD_ON == mux_flag || PSD_ON == muse_flag ) {
        acqs = 1;
        act_acqs = 1;
        avmaxacqs = 1;
    }

    /* HCSDM00393185: overwrite seq_type */
    if (act_acqs > 1)
    {
        if ((PSD_ON == exist(oprtcgate)) || (PSD_ON == navtrig_flag))
        {
            seq_type = TYPNCATRTG;
        }
        else if ((PSD_OFF == exist(opcgate)) && !rfov_flag)
        {
            seq_type = TYPNCATFLAIR;
        }
    }

    /* MRIhc05228 */
    if ( PSD_OFF == epi_flair ) {
        dda_pack = dda;
    }

    /* Looping structure in rsp:

    pass_reps
    ---------
    |
    | pass
    | --------
    | |  baseline           |
    | |  ---------          |
    | |  | reps             |
    | |  | ------           | baseline time (first pass only)
    | |  | | slices         |
    | |  | --------         |
    | |  |--------
    | |
    | |  disdaqs:           |
    | |  ileaves            |
    | |  ----------         | disdaq_shots
    | |  | slices           |
    | |  | ----------       |
    | |
    | |  core_reps          |
    | |  -----------        |
    | |  |                  |
    | |  | ileaves          |
    | |  | ----------       |
    | |  | |                |
    | |  | | nex            |
    | |  | | ----------     | core_shots
    | |  | | |              |
    | |  | | | slices       |
    | |  | | | ---------    |
    | |  | | ----------     |
    | |  | ---------        |
    | |  ----------         |
    | |
    | | pass packet
    | --------
    |
    |--------
    burst mode (not supported in MGD)

    */

    passr_shots = pass_reps;
    pass_shots = act_acqs;
    disdaq_shots = scan_dda;
    core_shots = intleaves; /* core_reps */

    /* ******************************************************************
       scan time has to be corrected for lack of disdaqs for diffuse
       data when flair is on. Given disdaqs for T2 images only
       ****************************************************************** */
    if(epi_flair==PSD_ON)
    {
        dda_fact=0.5;
    } else {
        dda_fact=1.0; 
    }

    /* Add more time for the last TR of the baseline scan to fix MRIge29749. */
    if(vrgfsamp == PSD_ON && opyres >= 256) bl_acq_tr2 = 1s;

    if (baseline > 0)
        bline_time = (baseline-1)*bl_acq_tr1 + bl_acq_tr2;
    else
        bline_time = 0;

    pass_time = pass_delay*num_passdelay;


    /* DCZ: For MRIge57701, add bline_time to the clock */
    /* ALP MRIge67616  Disdaqs should only be included once for diffusion
       because they are played only for the T2 images acquisition */
    /*MRIhc09116 - no pass_delay after last acquisition */
    if ( exist(opdiffuse) == PSD_OFF ) {
        if (exist(opcgate) == PSD_ON) {
            scan_time  = bline_time * pass_shots + (float)passr_shots*
                  (float)pass_shots*((float)(act_tr)*
                  ( (float)(disdaq_shots*dda_fact*(1.0/(float)passr_shots)) + nex*(float)core_shots*reps ) +
                  (float)ccs_relaxtime + (float)pass_time ) - (float)pass_time;
        } else {
            scan_time  = bline_time * pass_shots + (float)passr_shots*
                  (float)pass_shots*((float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*
                  ( (float)(disdaq_shots*dda_fact*(1.0/(float)passr_shots)) + nex*(float)core_shots*reps ) +
                  (float)ccs_relaxtime + (float)pass_time) -(float)pass_time;
        }
        nreps = act_acqs*(scan_dda + pass_reps*(nex + dex)*intleaves*reps);

    } else {
        if(tensor_flag == 0)
        {
            /* Refless EPI: in ref-in-scan mode, there is an additional ref scan before the T2 scan, which always uses 1 NEX */
            float sum_difnextab = (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag ? rpg_in_scan_num:0) + opdifnext2;

            int bval_counter;
            for (bval_counter = 0; bval_counter<opnumbvals ; bval_counter++)
            {
                sum_difnextab += difnextab[bval_counter]*num_dif;
            }
            if ((exist(opcgate) == PSD_ON) || (exist(oprtcgate) == PSD_ON) || (navtrig_flag == PSD_ON)) {
                scan_time  = bline_time * pass_shots +
                    (float)(disdaq_shots*dda_fact)*(float)(act_tr)*(float)pass_shots +
                    (float)pass_shots*(float)(act_tr)*sum_difnextab*(float)core_shots*reps +
                                     (float)passr_shots*((float)ccs_relaxtime + (float)pass_time) - (float)pass_time;
            } else {
                if (t1flair_flag) {
                    t1flair_disdaq_time = (float)(dda_t1flair*dda_fact)*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*(float)pass_shots;
                } else {
                    t1flair_disdaq_time = 0;
                }
                scan_time  = bline_time * pass_shots +
                    (float)(disdaq_shots*dda_fact)*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*(float)pass_shots +
                    (float)pass_shots*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*sum_difnextab*(float)core_shots*reps +
                                         (float)passr_shots*((float)ccs_relaxtime + (float)pass_time) - (float)pass_time -
                                         (float)t1flair_disdaq_time;
            }
            nreps = act_acqs*(scan_dda + sum_difnextab*intleaves*reps);
        }
        else
        {
            if ((exist(opcgate) == PSD_ON) || (exist(oprtcgate) == PSD_ON) || (navtrig_flag == PSD_ON)) {
                scan_time  = bline_time * pass_shots +
                    (float)(disdaq_shots*dda_fact)*(float)(act_tr)*(float)pass_shots +
                    (float)passr_shots*( (float)pass_shots*(float)(act_tr)*
                                         nex*(float)core_shots*reps +
                                         (float)ccs_relaxtime + (float)pass_time) - (float)pass_time;

                if (ref_in_scan_flag == PSD_ON)
                {
                    /* Refless EPI: first pass is ref with 1 NEX */
                    scan_time -= ((float)pass_shots*(float)(act_tr)*(nex-1)*(float)core_shots*reps);
                }
                if (rpg_in_scan_flag == PSD_ON)
                {
                    /* Reverse pass is with 1 NEX */
                    scan_time -= ((float)rpg_in_scan_num*(float)pass_shots*(float)(act_tr)*(nex-1)*(float)core_shots*reps);
                }
            } else {
                scan_time  = bline_time * pass_shots +
                    (float)(disdaq_shots*dda_fact)*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*(float)pass_shots +
                    (float)passr_shots*( (float)pass_shots*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*
                                         nex*(float)core_shots*reps +
                                         (float)ccs_relaxtime + (float)pass_time) - (float)pass_time;

                if (ref_in_scan_flag == PSD_ON)
                {
                    /* Refless EPI: first pass is ref with 1 NEX */
                    scan_time -= ((float)pass_shots*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*(nex-1)*(float)core_shots*reps);
                }
                if (rpg_in_scan_flag == PSD_ON)
                {
                    /* Reverse pass is with 1 NEX */
                    scan_time -= ((float)rpg_in_scan_num*(float)pass_shots*(float)(act_tr+((TRIG_LINE==gating)?TR_SLOP:0)+tmp_deadlast*2)*(nex-1)*(float)core_shots*reps);
                }
            }
            nreps = act_acqs*(scan_dda + pass_reps*(nex + dex)*intleaves*reps);
        }

        /* Refless EPI: IR is not played out in REF loop with DW-EPI Flair and acqs > 1 */
        if ((ref_in_scan_flag == PSD_ON) && (epi_flair == PSD_ON) && (act_acqs > 1))
        {
            scan_time -= invseqtime * act_acqs * false_acqs;
        }
    }

    avmintscan = scan_time;

    pitscan = avmintscan; /* This value shown in clock */
    pisctim1 = pitscan; 

    /* APx activation */
    if(PSD_ON == apx_status)
    {
        float temp_tscan = pitscan;
        int anatomy_apx_bh_enable = PSD_OFF;

#ifndef SIM
        anatomy_apx_bh_enable = isApplicationAllowedForAnatomy(opanatomy, ATTRIBUTE_APX_BH);
#else
        anatomy_apx_bh_enable = PSD_ON;
#endif

        if(PSD_ON == exist(opmph))
        {
            temp_tscan = (temp_tscan - passtime) / (float)exist(opfphases);
        }

        if( (1 == exist(opnumgroups)) && (0 != exist(opcoax)) &&
            (PSD_OFF == exist(oprtcgate)) && (PSD_OFF == exist(opnav)) && (PSD_OFF == exist(opcgate)) &&
            (PSD_OFF == epi_flair) && (PSD_OFF == tensor_flag) &&
            (PSD_ON == anatomy_apx_bh_enable) &&
            (APX_T_MIN_BH < temp_tscan + 500ms) && (temp_tscan - 500ms < APX_T_MAX_BH) )
        {
            piapx = PSD_ON;
        }
        else
        {
            piapx = PSD_OFF;
        }

        /* APx preference window setting */
        piapxprfstepnub = 2;
        piapxprfres = PSD_ON;
        piapxprfacc = PSD_OFF; /* don't support auto acceleration in DWI */
    }
    else
    {
        piapx = PSD_OFF;

        piapxprfstepnub = 0;
        piapxprfres = PSD_OFF;
        piapxprfacc = PSD_OFF;
    }

    nreps *= ((rawdata == PSD_ON && rhref == 1) ? 2 : 1);

    /* set effective Ky samp freq in KHz */
    if (esp > 0) {
        if ((fract_ky == PSD_FULL_KY) && (ky_dir==PSD_CENTER_OUT)) {
            frqy = 1000.0*(float)(intleaves/2)/(float)esp;
            eesp = rint((float)esp/(float)(intleaves/2));
        } else {
            frqy = 1000.0*(float)(intleaves)/(float)esp;
            eesp = rint((float)esp/(float)intleaves);
        }
    } else {
        frqy = 0;
        eesp = 0;
    }

    frqx = 1000.0/tsp;

    return SUCCESS;
}   /* end cveval1() */

@inline ss.e ssEval
@inline InversionSeqOpt.e InversionSeqOptEval
@inline DTI.e DTI_Eval
@inline DTI.e  Diffusion_Timing
@inline DTI.e DTI_Orientations

/*2009-Mar-10, Lai, GEHmr01484: In-range autoTR support */
@inline AutoAdjustTR.e AutoAdjustTREval1

STATUS
#ifdef __STDC__ 
avmintecalc( void )
#else /* !__STDC__ */
    avmintecalc()
#endif /* __STDC__ */
{
    int tempxy;

    if (exist(oppseq) == PSD_SE)
        avminssp = pw_rf2/2 + rfupd + 8us + pw_wssp + tdaqhxa;
    else                         /* gradient echo */
        avminssp = rfExIso + rfupd + 8us + pw_wssp + tdaqhxa;

    if(hsdab == 2 )
        avminssp = avminssp + DIFFDAB_length;
    else
        avminssp = avminssp + HSDAB_length;

    if (xtr_offset == 0) {
        avminssp = avminssp + (XTRSETLNG + XTR_length[PSD_XCVR2]);
    } else {
        avminssp = avminssp + xtr_offset;
    }

    if (exist(oppseq) == PSD_SE)
        avminssp *= 2;  

    get_gy1_time();

    get_flowcomp_time();

    if (exist(oppseq) == PSD_SE) {

        int extra_tetime;
        extra_tetime = get_extra_dpc_tetime() + get_extra_rtb0_tetime();

        if (PSD_OFF == dualspinecho_flag)
        {

            if (gx1pos == PSD_POST_180) {
                avminxa = 2*(rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) + xdiff_time1 +
                             pw_gzrf2l1_tot + (pw_rf2/2));
                avminxb = 2*(8us + pw_rf2/2 + pw_gzrf2r1_tot + xdiff_time2 + 
                             pw_wgx + pw_gxwad + tdaqhxa + 
                             IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot));

            } else {
                avminxa = 2*(rfExIso + xdiff_time1 + IMax(2, pw_gx1_tot, pw_gyex1_tot));
                avminxb = 2*(tdaqhxa + xdiff_time2 + pw_wgx + pw_rf2/2);
            }
            avminxa += 2*extra_tetime;

        } else {   
            int left_diff_timing = IMax(3,pw_gxdl1a,pw_gydl1a,pw_gzdl1a) + IMax(3,pw_gxdl1,pw_gydl1,pw_gzdl1) + IMax(3,pw_gxdl1d,pw_gydl1d,pw_gzdl1d) + pw_wgxdl1;
            int right_diff_timing = pw_wgxdr2 + IMax(3,pw_gxdr2a,pw_gydr2a,pw_gzdr2a) + IMax(3,pw_gxdr2,pw_gydr2,pw_gzdr2) + IMax(3,pw_gxdr2d,pw_gydr2d,pw_gzdr2d);

            avminxa = 4*(rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) + left_diff_timing +
                         pw_gzrf2l1_tot_bval + (pw_rf2/2));
            avminxa += 4*extra_tetime;

            if(xygradRightCrusherFlag == PSD_ON)
            {
                tempxy = IMax(2, pw_xgradRightCrusherRa + pw_xgradRightCrusherR + 
                         pw_xgradRightCrusherRd, pw_gzrf2r2_tot_bval);
            }
            else
            {
                tempxy = pw_gzrf2r2_tot_bval;
            }
            avminxb = 4*(8us + pw_rf2/2 + tempxy + right_diff_timing + 
                         pw_wgx + pw_gxwad + tdaqhxa + 
                         IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot));   
        }
        avminx  = (avminxa>avminxb) ? avminxa : avminxb;

        if (PSD_OFF == dualspinecho_flag)
        {
            if (gy1pos == PSD_POST_180) {
                avminya = 2*(rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) + ydiff_time1 +
                             pw_gzrf2l1_tot + (pw_rf2/2));
                avminyb = 2*(8us + pw_rf2/2 + pw_gzrf2r1_tot + ydiff_time2 + 
                             pw_wgy + pw_gxwad +  tdaqhxa + 
                             IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot)); 

            } else {
                avminya = 2*(rfExIso + pw_gyex1_tot + pw_gy1_tot + ydiff_time2 + pw_wgy);
                avminyb = 2*(pw_rf2/2 + ydiff_time2 + pw_gxwad +
                             IMax(2, pw_gx1_tot, pw_gzrf2r1_tot));              
            }
            avminya += 2*extra_tetime;

        } else {
            int left_diff_timing = IMax(3,pw_gxdl1a,pw_gydl1a,pw_gzdl1a) + IMax(3,pw_gxdl1,pw_gydl1,pw_gzdl1) + IMax(3,pw_gxdl1d,pw_gydl1d,pw_gzdl1d) + pw_wgydl1;
            int right_diff_timing = pw_wgydr2 + IMax(3,pw_gxdr2a,pw_gydr2a,pw_gzdr2a) + IMax(3,pw_gxdr2,pw_gydr2,pw_gzdr2) + IMax(3,pw_gxdr2d,pw_gydr2d,pw_gzdr2d);

            avminya = 4*(rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) + left_diff_timing +
                         pw_gzrf2l1_tot_bval + (pw_rf2/2));
            avminya += 4*extra_tetime;

            if(xygradRightCrusherFlag == PSD_ON)
            {
                tempxy = IMax(2, pw_ygradRightCrusherRa + pw_ygradRightCrusherR + 
                         pw_ygradRightCrusherRd, pw_gzrf2r2_tot_bval);
            }
            else
            {
                tempxy = pw_gzrf2r2_tot_bval;
            }
            avminyb = 4*(8us + pw_rf2/2 + tempxy + right_diff_timing + 
                         pw_wgy + pw_gxwad + tdaqhxa + 
                         IMax(2, pw_gx1_tot, pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot));            
        }
        avminy  = (avminya>avminyb) ? avminya : avminyb;

        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            avminza = 2*(rfExIso + pw_gzrf1d + IMax(2, pw_gyex1_tot, pw_gz1_tot) + zdiff_time1 +
                         pw_gzrf2l1_tot + (pw_rf2/2));
            avminzb = 2*(8us + pw_rf2/2 + pw_gzrf2r1_tot + zdiff_time2 + 
                         pw_wgz + pw_gxwad +  tdaqhxa + 
                         IMax(2, pw_gx1_tot,
                              pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot));
            avminza += 2*extra_tetime;

        } else {
            /* OK: we've got four times we need to look at.  a) aminza: 90->180 */
            /*     b) minztemp: 180->opte/2 which = c) opte/2 -> 180 */
            /*     d) avminzb: 180 -> echo. Whichever is the larget will determine the */
            /*     minimum echo time for the sequence */
            int minztemp = 0;
            int left_diff_timing = IMax(3,pw_gxdl1a,pw_gydl1a,pw_gzdl1a) + IMax(3,pw_gxdl1,pw_gydl1,pw_gzdl1) + IMax(3,pw_gxdl1d,pw_gydl1d,pw_gzdl1d) + pw_wgzdl1;
            int right_diff_timing1 = pw_wgzdr1 + IMax(3,pw_gxdr1a,pw_gydr1a,pw_gzdr1a) + IMax(3,pw_gxdr1,pw_gydr1,pw_gzdr1) + IMax(3,pw_gxdr1d,pw_gydr1d,pw_gzdr1d);
            int right_diff_timing2 = pw_wgzdr2 + IMax(3,pw_gxdr2a,pw_gydr2a,pw_gzdr2a) + IMax(3,pw_gxdr2,pw_gydr2,pw_gzdr2) + IMax(3,pw_gxdr2d,pw_gydr2d,pw_gzdr2d);

            /* 90-180 time */
            avminza = 4*(rfExIso + pw_gzrf1d + IMin(2, pw_gyex1_tot, pw_gz1_tot) + left_diff_timing +
                       pw_gzrf2l1_tot_bval + pw_rf2/2); 
            avminza += 4*extra_tetime;

            /* 180 - opte/2 spacing: sep_time will add a gap between diffusion lobes */
            minztemp = 4*(GRAD_UPDATE_TIME + sep_time + right_diff_timing1 + 
                        pw_gzrf2r1_tot_bval + pw_rf2/2 );

            avminza = (avminza>minztemp) ? avminza : minztemp;

            /* 180 - echo center time */
            avminzb = 4*(8us + pw_rf2/2 + pw_gzrf2r2_tot_bval + right_diff_timing2 + 
                       pw_wgz + pw_gxwad +  tdaqhxa + 
                       IMax(2,pw_gx1_tot,pw_gymn1_tot + pw_gymn2_tot + pw_gy1_tot));

            avminzb = (avminzb>minztemp) ? avminzb : minztemp;
        }

        avminz  = (avminza>avminzb) ? avminza : avminzb;

    } else {  /* Gradient echo */
        avminx  = rfExIso + xdiff_time1 + xdiff_time2 + pw_gx1a + pw_gx1 +
            pw_gx1d + tdaqhxa + pw_wgx;
        avminy = rfExIso + pw_gyex1_tot + pw_gy1_tot + pw_gymn1_tot + pw_gymn2_tot +
            ydiff_time2 + pw_wgy + tdaqhxa;
        avminz = rfExIso + pw_gzrf1d + pw_gz1_tot + pw_wgz + zdiff_time2 +
            tdaqhxa;

        /*RTB0 correction*/
        if(rtb0_flag)
        {
            avminx += IMax(2, pw_gz1_tot, rfupd+4us+rtb0_minintervalb4acq) + esp + rtb0_acq_delay;
            avminy += IMax(2, pw_gz1_tot, rfupd+4us+rtb0_minintervalb4acq) + esp + rtb0_acq_delay;
            avminz += IMax(2, pw_gz1_tot, rfupd+4us+rtb0_minintervalb4acq) + esp + rtb0_acq_delay - pw_gz1_tot;
        }
    }

    avmintetemp = ((avminy>avminz) ? avminy : avminz);
    avmintetemp = ((avminx>avmintetemp) ? avminx : avmintetemp);
    avmintetemp = ((avminssp>avmintetemp) ? avminssp : avmintetemp);

    return SUCCESS;
}   /* end avmintecalc() */

/* Get extra TE time for dynamic phase correction */
int get_extra_dpc_tetime(void)
{
    int ext_tetime;

    if(dpc_flag)
    {
        ext_tetime = IMax(3, pw_gz1_tot, rfupd+4us+pw_gxiref1_tot, pw_gyex1_tot) - IMax(2, pw_gyex1_tot, pw_gz1_tot) +
                     pw_gxiref_tot + pw_gxirefr_tot + IMax(2, pw_gzrf1d, psd_rf_wait) - pw_gzrf1d;
    }
    else
    {
        ext_tetime = 0;
    }

    return ext_tetime;
}

/* Get extra TE time for RTB0 */
int get_extra_rtb0_tetime(void)
{
    int ext_tetime;

    if(rtb0_flag)
    {
        ext_tetime = IMax(2, pw_gz1_tot, rfupd+4us+ rtb0_minintervalb4acq) +
                     esp + rtb0_acq_delay - pw_gz1_tot;
    }
    else
    {
        ext_tetime = 0;
    }

    return ext_tetime;
}

STATUS get_flowcomp_time(void)
{
    int pulsecnt;

    if (ygmn_type == CALC_GMN1) {

        /* set time origin at end of bipolar flow comp lobe/beginning of
           gy1f phase encoding pulse */
        invertphase = 0;
        zeromomentsum = 0.0;
        firstmomentsum = 0.0;
        pulsepos = 0;

        /* compute moments for blips */
        pulsepos = pw_gy1_tot + pw_gxwad + esp - pw_gxwad/2 - pw_gyb/2 - pw_gybd;
        for (pulsecnt=0;pulsecnt<blips2cent;pulsecnt++) {
            rampmoments(0.0, a_gyb, pw_gyba, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gyb, a_gyb, pw_gyb, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            rampmoments(a_gyb, 0.0, pw_gybd, invertphase, &pulsepos,
                        &zeromoment, &firstmoment, &zeromomentsum,
                        &firstmomentsum);
            pulsepos += (esp - pw_gyba - pw_gyb/2);
        }
        gyb_tot_0thmoment = zeromomentsum;
        gyb_tot_1stmoment = firstmomentsum;

        /* Here we compute the gradient moment nulling pulse parameters
           for a worst case condition: when the gy1f pulse has zero
           amplitude.  Since the gy1f never really steps to zero amplitude,
           this is hardly an optimal solution.  A future option is to
           compute the minimum amplitude of gy1f across all intleaves
           in this calculation. */

        amppwygmn(gyb_tot_0thmoment, gyb_tot_1stmoment, pw_gy1a, pw_gy1,
                  pw_gy1d, 0.0, 0.0, loggrd.ty_xyz, (float)loggrd.yrt*loggrd.scale_3axis_risetime,
                  0, &pw_gymn2a, &pw_gymn2, &pw_gymn2d, &a_gymn2);

        a_gymn2 = -a_gymn2;
        a_gymn1 = -a_gymn2;
        pw_gymn1a = pw_gymn2a;
        pw_gymn1 = pw_gymn2;
        pw_gymn1d = pw_gymn2d;

        pw_gymn1_tot = pw_gymn1a + pw_gymn1 + pw_gymn1d;
        pw_gymn2_tot = pw_gymn2a + pw_gymn2 + pw_gymn2d;

    } else {    /* if (ygmn_type != CALC_GMN1) */
        pw_gymn1_tot = 0;
        pw_gymn2_tot = 0;
    }

    return SUCCESS;
}

STATUS get_gy1_time(void)
{
    /* All this to find pw_gy1_tot: */
    gy1_offset = ky_offset*fabs(area_gyb)/intleaves;
    area_gy1 = area_gy1 + gy1_offset;
    area_gy1 = fabs(area_gy1);
    endview_iamp = max_pg_wamp;
    endview_scale = (float)max_pg_iamp / (float)endview_iamp;

    /* Find the amplitudes and pulse widths of the trapezoidal
       phase encoding pulse. */

    if (amppwtpe(&a_gy1a,&a_gy1b,&pw_gy1,&pw_gy1a,&pw_gy1d,
                 loggrd.ty_xyz/endview_scale,loggrd.yrt*loggrd.scale_3axis_risetime,
                 area_gy1) == FAILURE)
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "amppwtpe" );
        return FAILURE;
    }

    a_gy1 = loggrd.ty_xyz/endview_scale;
    pw_gy1_tot = pw_gy1a + pw_gy1 + pw_gy1d;

    return SUCCESS;
}

@inline DTI.e DTI_Check_Bval_Func

STATUS
#ifdef __STDC__ 
nexcalc( void )
#else /* !__STDC__ */
    nexcalc()
#endif /* __STDC__ */
{ 
    /* This is a similar set of codes as the Nex bookkeeping section, except
       that all the checks have been removed because they have already been
       done once when this routine is called. */

    if (fract_ky == PSD_ON)
        fn = 0.5;
    else
        fn = 1.0;

    nop = 1;

    if(exist(opdiffuse) == PSD_ON)
        nex = IMax(2,(int) 1,(int)max_nex);
    else
    {
        nex = IMax(2,(int) 1,(int)opnex);
        /* update the Nex fields */
        pinexnub = 62;
        pinexval2 = 1;
        pinexval3 = 2;
        pinexval4 = 4;
        pinexval5 = 8;
        pinexval6 = 16;
    }
    return SUCCESS;
}   /* end nexcalc() */

STATUS
#ifdef __STDC__ 
setb0rotmats( void )
#else /* !__STDC__ */
    setb0rotmats()
#endif /* __STDC__ */
{
    int slice, n;
    for (slice=0; slice<3; slice++) {
        for (n=0; n<9; n++)
            scan_info[slice].oprot[n] = 0.0;
    }

    /* 1st slice (1st in time order) is an axial */
    scan_info[0].oprot[0] = 1.0; /* readout on physical X */
    scan_info[0].oprot[4] = 1.0; /* blips on physical Y */
    scan_info[0].oprot[8] = 1.0; /* slice on physical Z */

    /* 2nd slice (3rd in time order) is a saggital */
    scan_info[1].oprot[3] = 1.0; /* readout on physical Y */
    scan_info[1].oprot[7] = 1.0; /* blips on physical Z */
    scan_info[1].oprot[2] = 1.0; /* slice on physical X */

    /* 3rd slice (2nd in time order) is a coronal */
    scan_info[2].oprot[6] = 1.0; /* readout on physical Z */
    scan_info[2].oprot[1] = 1.0; /* blips on physical X */
    scan_info[2].oprot[5] = 1.0; /* slice on physical Y */

    /* new geometry info! */
    opnewgeo = 1;

    /* set slice_reset */
    slice_reset = 1;

    return SUCCESS;
}   /* end setb0rotmats() */

/* Description:
   For Auto Protocol Optimization, it's necessary to set
   min / max / delta values of optimized parameters.
   Default setting is described in getAPxParamInit() and
   this function can modify those initial values.
*/
void
getAPxParam(optval   *min,
            optval   *max,
            optdelta *delta,
            optfix   *fix,
            float    coverage,
            int      algorithm)
{
    delta->slthick_min = delta->slthick;

    min->yres = IMax(2, avminyres, 96);
    if (cffield <= B0_15000)
    {
        max->yres = IMin(2, avmaxyres, 192);
    }
    else
    {
        max->yres = IMin(2, avmaxyres, 256);
    }

    min->xy_ratio = 0.5;
    max->xy_ratio = 2.0;

    if(algorithm & APX_ALG_AUTO_TR)
    {
        if(PSD_ON == irprep_flag)
        {
            if (cffield <= B0_15000)
            {
                min->tr = 3000ms;
            }
            else
            {
                min->tr = 2500ms;
            }
        }
        else
        {
            min->tr = 2000ms;
        }

        max->tr = min->tr * 2;

        if(PSD_ON == exist(opinrangetr))
        {
            min->tr = IMax(2, exist(opinrangetrmin), min->tr);
            min->tr = IMin(2, min->tr, TR_MAX_EPI2 / 2);
            max->tr = IMax(2, exist(opinrangetrmax), 2 * min->tr);
        }
    }

    int bval_counter = 0;
    for (bval_counter = 0; bval_counter < opnumbvals; bval_counter++)
    {
        if ((bvalstab[bval_counter] >= 500) && (cffield <= B0_15000))
        {
            min->difnex[bval_counter] = 2; 
        }
        else
        {
            min->difnex[bval_counter] = 1;
        }
    }
}

/* Description:
   For Auto Protocol Optimization, it's necessary to set
   flags to show which parameters are optimized and
   which algirithms are applied.
   Default setting is described in getAPxAlgorithmInit() and
   this function can modify those initial values.
*/
int getAPxAlgorithm(optparam *optflag, int *algorithm)
{
    int min_acqs_change_flag = PSD_ON;

    *algorithm &= ~APX_ALG_TSCAN_CHECK;
    *algorithm &= ~APX_ALG_AUTO_ACCINC;
    *algorithm &= ~APX_ALG_AUTO_ACCDEC;

    optflag->xres = 0;
    optflag->slicecnt = 0;
    optflag->accel_ph = 0;
    if((int)exist(opdifnext2) > 0)
    {
        optflag->difnext2 = 1;
    }
    optflag->difnextab = 1;

    if((PSD_ON == min_acqs_change_flag) && (t1flair_flag || ir_prep_manual_tr_mode) && existcv(opuser8))
    {
        optflag->user8 = 1;
    }

    return APX_CORE_BH_DWI;
}

/* HCSDM00398133 HCSDM00419770 */
STATUS setUserCVs()
{
    if (PSD_ON == exist(opdiffuse))
    {
        if (t1flair_flag || ir_prep_manual_tr_mode)
        {
            piuset |= use8;
            /* min acqs for t1flair is 2 */
            opuser8 = 2.0;
            cvmod(opuser8, 1.0, 2.0, 2.0, "STIR Minimum Acqs", 0, " ");

            if (existcv(opuser8) && ((exist(opuser8) > 2) || (exist(opuser8) < 1) || !floatIsInteger(exist(opuser8))))
            {
                epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser8.descr );
                return FAILURE;
            }
        }
        else
        {
            piuset &= ~use8;
            cvmod( opuser8, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 8", 0, "" );
            cvoverride(opuser8, _opuser8.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }

        /* overwrite opfat to ensure fatsat performance */
        if (epic_findputcvnum("opfat") == TRUE)
        {
            opfat_on_UI = opfat;
        }

        if (rfov_flag || mux_flag || (ssgr_flag && !dualspinecho_flag))
        {
            ss_rf1_compatible = PSD_OFF;
        }
        else
        {
            ss_rf1_compatible = PSD_ON;
        }

        if(((rfov_flag && focus_B0_robust_mode) ||
           ((mux_flag || ssgr_flag) && !rfov_flag && !ss_rf1_compatible)) &&
           (!irprep_flag && !exist(opspecir)))
        {
            cvoverride(opfat, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
        }
        else
        {
            cvoverride(opfat, opfat_on_UI, PSD_FIX_ON, PSD_EXIST_ON);
        }
 
        if ((irprep_flag || exist(opspecir) || exist(opfat)) && (ss_rf1_compatible == PSD_ON))
        {
            piuset |= use18;
            opuser18 = 0.0;

            if (B0_30000 == cffield)
            {
                    cvmod(opuser18, 0.0, 2.0, 0.0, "Enhanced Fat Suppression (0=Off, 1=On, 2=Breast)",0," ");
            }
            else
            {
                cvmod(opuser18, 0.0, 1.0, 0.0, "Enhanced Fat Suppression (0=Off, 1=On)",0," ");
            }

            if ((B0_30000 == cffield) && (exist(opuser18) >= 1.72) && (exist(opuser18) <= 1.74))
            {
                /* 3: sqrt(3) New Type II Spectral Spatial RF1 */
                /* Designed for Breast DWI and allow thin slice */
                enhanced_fat_suppression = 3;
            }
            else
            {
                int max_opuser18 = 1.0;

                if (B0_30000 == cffield)
                {
                    max_opuser18 = 2.0;
                }
                else
                {
                    max_opuser18 = 1.0;
                }

                /* only integer value allowed */
                if (existcv(opuser18) && ((exist(opuser18) > max_opuser18) || (exist(opuser18) < 0) ||
                    (!floatIsInteger(exist(opuser18)))))
                {
                    epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser18.descr );
                    return FAILURE;
                }

                /* For non-Multiband */
                /* 0: SINC RF1 */
                /* 1: Product Spectral Spatial RF1 before DV22 software */
                /* 2: New Spectral Spatial RF1 designed for Breast DWI */
                enhanced_fat_suppression = (int)exist(opuser18);
            }
        }
        else
        {
            piuset &= ~use18;
            cvmod( opuser18, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 18", 0, "" );
            cvoverride(opuser18, _opuser18.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            enhanced_fat_suppression = 0;
        }
    }
    else
    {
        piuset &= ~use8;
        piuset &= ~use18;
        cvmod( opuser8, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 8", 0, "" );
        cvoverride(opuser8, _opuser8.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser18, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 18", 0, "" );
        cvoverride(opuser18, _opuser18.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        enhanced_fat_suppression = PSD_OFF;
        ss_rf1_compatible = PSD_ON;
    }

    /* FLAIR CV should not be available for tensor, cardiac gating, respiratory
     * gating, IR prep FOCUS and Multiband */
    /* FLAIR + ASSET is not compatible for NON_VALUE_SYSTEM */
    if ( exist(opdiffuse) == PSD_ON && 
         ((tensor_flag == PSD_OFF) && (exist(opcgate) == PSD_OFF) && 
          (exist(oprtcgate) == PSD_OFF) && (exist(opirprep) == PSD_OFF) &&
          (navtrig_flag == PSD_OFF) && (rfov_flag == PSD_OFF) && (mux_flag == PSD_OFF)) &&
         !((value_system_flag == NON_VALUE_SYSTEM) && (exist(opasset) > PSD_OFF)) )
    {
        piuset |= use6;
    } else {
        piuset &=~use6;
    }

    opuser6 = 0.0;
    cvmod(opuser6, 0, 1, 0, "FLAIR Inversion (1=on, 0=off)",1," ");

    /* MRIge59852: opuser6 range check */
    /* MRIge71092 */
    if( existcv(opuser6) && ((exist(opuser6) > 1) || (exist(opuser6) < 0) || (!floatIsInteger(exist(opuser6))))) 
    {
        epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser6.descr );
        return FAILURE;
    }

    return SUCCESS;
}

@inline DTI.e DTI_Check

/***********************************************************************/
/* CVCHECK                                                             */
/***********************************************************************/
STATUS
#ifdef __STDC__ 
cvcheck( void )
#else /* !__STDC__ */
    cvcheck() 
#endif /* __STDC__ */ 
{
    int temp_int = 0;
    int status_flag = SUCCESS;
    int bval_counter = 0;
    float allowed_max_bval = 0;
    float allowed_min_bval = 0;

    /* Check for existance of EPI flag */
    if (exist(opepi) != PSD_ON) {
        epic_error( use_ermes, "The EPI option must be selected with this psd.", EM_PSD_EPI_EPIOPTION, EE_ARGS(0) );
        return FAILURE;
    }

    /* SVBranch: GEHmr04247 */
    if( (isSVSystem()) &&
        (((exist(opdiffuse) == PSD_ON) &&
          ((float)min_seqgrad * cfxfd_power_limit > XFD_MINSEQ_LIMIT_DWI)) ||
         ((exist(opdiffuse) == PSD_OFF) && (epi_flair == PSD_ON) &&
          ((float)min_seqgrad * cfxfd_power_limit > XFD_MINSEQ_LIMIT_FLAIR))) )
    {
        epic_error( use_ermes, "The FOV needs to be increased to %3.1f cm",
                    EM_PSD_FOV_OUT_OF_RANGE4, EE_ARGS(1), FLOAT_ARG,
                    exist(opfov) / 10.0 + 1.0 );
        return FAILURE;
    }	
	
    /* YMSmr06515, YMSmr06769 May 2005 KK */
    if (exist(opslquant) > MAXSLQUANT_EPI){
        epic_error( use_ermes, "The number of scan locations selected must be reduced to %d for the current prescription.",
                    EM_PSD_SLQUANT_OUT_OF_RANGE, 1, INT_ARG, MAXSLQUANT_EPI);
        return FAILURE; 
    } 

    /* cvcheck for HOEC */
@inline HoecCorr.e HoecCheck
    /* RTB0 correction: cvcheck for RTB0 */
@inline RTB0.e RTB0Cvcheck_epi2 
@inline Muse.e MuseCvcheck

    /* MRIge48250 - lock freq dir to R/L */
    if ( (cfsrmode == PSD_SR20 || cfsrmode == PSD_SR25) && 
         (piswapfc == 1) && existcv(opspf) && (exist(opspf) == 0) ) {
        epic_error( 0, "Frequency direction must be R/L for this sequence.", 0, EE_ARGS(0) );
        return FAILURE;
    }

    /* BJM: MRIge55304 - #ifdef SIM part - permit epi2 in simulaton mode only */
#ifndef SIM
    /* MRIge52197 - lockout epi2.e from being typed in */
    if( (exist(opdiffuse) != PSD_ON) &&
        (exist(opflair) != PSD_ON) && (tensor_flag != PSD_ON) ) {
        epic_error( use_ermes, "This prescription is not allowed", EM_PSD_INVALID_RX, EE_ARGS(0) );
        return FAILURE;
    } 
#endif /* !SIM */

    /* MRIge56891 - lock out EZDWI w/ Flair PSD Option */
    /* MRIge56913 - Lock out EZDWI when FLAIR EPI is selected - TAA */
    if( (EZflag == PSD_ON) && (exist(opflair)== PSD_ON) && floatsAlmostEqualEpsilons(exist(opuser6), 0.0, 2) )
    {
        epic_error( use_ermes, "This prescription is not allowed", EM_PSD_INVALID_RX, EE_ARGS(0) );
        return FAILURE;
    }
   
    /* MRIge59850 - lock out sequential flair 
       MRIge59560 - changed the error message to indicate incompatiblity of FLAIR EPI
       and Sequential Multiphase options - AMR */
    if((exist(opflair) == PSD_ON) && (exist(opacqo) == PSD_ON)) {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "FLAIR EPI", STRING_ARG, "Sequential Multiphase" );

        return FAILURE;
    }
     
    /*MRIhc04522 - FLAIR EPI is not compatible with sequential
     * acquisition*/
    if((exist(opflair) == PSD_ON) && (exist(opirmode) == PSD_ON)) {                 
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_IMGOPT_PSD1, EE_ARGS(2), STRING_ARG, "sequential ", STRING_ARG, "FLAIR EPI" );

        return FAILURE;                                                           
    }                                                                             
    /* irprep_support */
    if( floatsAlmostEqualEpsilons(exist(opuser6), 1.0, 2) && (exist(opirprep) == PSD_ON)) 
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_IMGOPT_PSD1, EE_ARGS(2), STRING_ARG, "IR Prep", STRING_ARG, "FLAIR Inversion" );

        return FAILURE;

    }

    if (((t1flair_flag || ir_prep_manual_tr_mode) && existcv(opuser8) && existcv(opslquant) && (exist(opslquant) < avminslquant))
        || (mux_flag && existcv(opslquant) && (exist(opslquant) < avminslquant)) )
    {
        epic_error( use_ermes, "The number of scan locations selected must be increased to %d for the current prescription",
                    EM_PSD_SLQUANT_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, avminslquant );
        return FAILURE;
    }

    if ((epi_flair== PSD_ON)&&((exist(optr) < avmintr) && existcv(optr))) {
        epic_error( use_ermes, "Minimum TR is %-d ms", EM_PSD_TR_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, (avmintr/1ms) );
        return ADVISORY_FAILURE;
    }

    if ((epi_flair== PSD_ON)&&(exist(opslquant)<4)) {
        epic_error( use_ermes, "Number of slices must be greater than or equal to 4 with Flair.", EM_PSD_EPI_FLAIRSLICES, EE_ARGS(0) );
        return FAILURE;
    }

    if ((exist(opti) > (exist(optr)/(false_acqs*2))) && (epi_flair==PSD_ON)) {
        epic_error( use_ermes, "TR must be at least 4 times longer than TI.", EM_PSD_EPI_TRTI, EE_ARGS(0) );
        return ADVISORY_FAILURE;

    }

    /* MRIhc40140 */
    if ( (scan_deadtime > MAX_INST_PERIOD) && existcv(optr) && existcv(opslquant) )
    {
        epic_error(use_ermes,"Maximum TR is %-d ms",
                   EM_PSD_TR_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, (int)((MAX_INST_PERIOD+tmin-time_ssi)/1ms));
        return ADVISORY_FAILURE;
    }

    /* MRIhc40140 */
    if ( (act_tr > MAX_INST_PERIOD) && existcv(opslquant) &&
         (((exist(opcgate) == PSD_ON) && existcv(ophrep)) || ((exist(oprtcgate) == PSD_ON) && existcv(oprtrep))) )
    {
        /* Calculate ctlend_last */
        if ( FAILURE == calcPulseParams(AVERAGE_POWER) )
        {
            return FAILURE;
        }

        int acq_cnt = 0;
        int max_ctlend_last = 0;
        for (acq_cnt = 0; acq_cnt < act_acqs; acq_cnt++)
        {
            if (max_ctlend_last < ctlend_last[acq_cnt])
            {
               max_ctlend_last = ctlend_last[acq_cnt];
            }
        }

        if ( max_ctlend_last > MAX_INST_PERIOD )
        {
            int temp_reps = (exist(oprtcgate) == PSD_ON) ? exist(oprtrep) : exist(ophrep);
            int temp_rate = (exist(oprtcgate) == PSD_ON) ? exist(oprtrate) : exist(ophrate); 
            int suggested_step = (ceil) ((max_ctlend_last - MAX_INST_PERIOD)/60*temp_rate*1e-6);
            epic_error(use_ermes,"The number of RR intervals must be decreased to %d for the current prescription.", EM_PSD_SPEC_DECREASE_RRI, EE_ARGS(1), INT_ARG, temp_reps-suggested_step);
            return FAILURE;
        }
    }

    if( (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON) ) {
        /*
         * BJM: MRIge57366 - calculate the maximum b-value for the system
         *                   config.
         */

        if ( PSD_OFF == optimizedTEFlag )
        {
            allowed_max_bval = bmax_fixed;
        }
        else 
        {
             /* b-value limits based on coil type and slew rate */
            switch ( cfgcoiltype )
            {
            case PSD_CRM_COIL:
                allowed_max_bval = MAXB_10000;
                break;

            case PSD_XRMB_COIL:
                allowed_max_bval = MAXB_10000;
                if ((exist(opdfaxtetra) > PSD_OFF)  || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                {
                    allowed_max_bval = MAXB_1500;
                }
                break;

            case PSD_60_CM_COIL:
            case PSD_BRM2_COIL:
                switch ( cfsrmode )
                {
                case PSD_SR100:
                case PSD_SR120:
                    allowed_max_bval = MAXB_7000;
                    if ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                    {
                         allowed_max_bval = MAXB_1500;
                    }
                    /*** SVBranch: 
                    HCSDM00097735:
                    Increase max b-value for 16Beat system 
                    under certain cases;
                    This feature can only be activated if
                    both of the following two conditions
                    are met:
                    1. slice thickness is set and is set
                       to not less than 20mm;
                    2. the TE value is set;
                    ***/
                    if((isSVSystem()) && (exist(opslthick) >= 20))
                    {
                        allowed_max_bval = MAXB_10000;
                    }
                    /*********************************/                    
                    break;
                case PSD_SR77:
                    allowed_max_bval = MAXB_4000;
                    break;
                case PSD_SR50:
                    allowed_max_bval = MAXB_2500;
                    if (isStarterSystem())
                    {
                        allowed_max_bval = MAXB_7000;
                        if ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                        {
                             allowed_max_bval = MAXB_1500;
                        }
                        if((exist(opslthick)) >= 20)
                        {
                            allowed_max_bval = MAXB_10000;
                        }
                    }
                    break;
                default:
                    allowed_max_bval = MAXB_1000;
                    break;
                }
                break;

            case PSD_TRM_COIL:
                if ( cfsrmode == PSD_SR77 || ( exist( opgradmode ) == TRM_BODY_COIL && existcv( opgradmode ) ) )
                {
                    allowed_max_bval = MAXB_4000;
                    if ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                    {
                        allowed_max_bval = MAXB_1500;
                    }
                }
                else if ( cfsrmode == PSD_SR150 || ( exist( opgradmode ) == TRM_ZOOM_COIL && existcv( opgradmode ) ) )
                {
                    allowed_max_bval = MAXB_10000;
                    if ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                    {
                        allowed_max_bval = MAXB_1500;
                    }
                }
                break;

            case PSD_XRMW_COIL:
            case PSD_VRMW_COIL:
                allowed_max_bval = MAXB_10000;
                if ((exist(opdfaxtetra) > PSD_OFF) || (exist(opdfax3in1) > PSD_OFF )|| ((exist(opdfaxall) > PSD_OFF) && (gradopt_diffall == PSD_ON)))
                {
                    allowed_max_bval = MAXB_1500;
                }
                break;

            case PSD_HRMW_COIL:
                allowed_max_bval = MAXB_10000;
                break;
            default:
                allowed_max_bval = MAXB_1000;
                break;
            }
        }

        if (tensor_flag == PSD_ON)
        {
            if ((PSD_XRMB_COIL == cfgcoiltype) || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_VRMW_COIL == cfgcoiltype) || (isRioSystem()))
            {
                allowed_max_bval = FMin(2, allowed_max_bval, (float)MAXB_10000);
            }
            else
            {
                allowed_max_bval = FMin(2, allowed_max_bval, (float)MAXB_4000);
            }
        }

        allowed_min_bval = MINB_VALUE;
        avminbvalstab = allowed_min_bval;
        avmaxbvalstab = allowed_max_bval;

        /* error massages for DWI */
        for (bval_counter = 0; bval_counter < opnumbvals; bval_counter++)
        {
            if (bvalstab[bval_counter] > avmaxbvalstab) 
            {
                epic_error( use_ermes, "The max b-value = %d for this prescription", EM_PSD_MAX_BVALUE, 
                            EE_ARGS(1), INT_ARG, (int)allowed_max_bval );
                return FAILURE; 
             }
	   if (bvalstab[bval_counter] < avminbvalstab)
            {
                epic_error( use_ermes, "The min b-value = %d for this prescription", EM_PSD_MIN_BVALUE, 
                            EE_ARGS(1), INT_ARG, (int)allowed_min_bval );
                return FAILURE; 
             }
        }

        /* Synthetic DWI */
        if ((PSD_OFF == syndwi_status) && (PSD_ON == syndwi_flag))
        {
            epic_error( use_ermes, "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1), STRING_ARG, "Synthetic DWI" );
            return FAILURE;
        }
        if(syndwi_flag)
        {
            /* synthetic b-value range is restricted by several limits.    */
            /* 1: syn bvalue is always >= LOWER_SYNB_LIMIT_IVIM            */
            /*    due to IVIM effect mainly in liver                       */
            /* 2: syn bvalue is always <= UPPER_SYNB_LIMIT_RESTRICT_DIFF   */
            /*    due to restricted diffusion mainly in brain              */
            /* 3: available range is limited by user's b-value description */
            /*    (need to disallow if user set an agressive prescription  */
            /*     e.g syn-b=1500 with acq-b=200,220)                      */
            avminsynbvalstab = prescribed_min_bval - prescribed_bval_range * SYNBVAL_EXPAND_FACTOR;
            if (avminsynbvalstab < LOWER_SYNB_LIMIT_IVIM)
            {
                avminsynbvalstab = LOWER_SYNB_LIMIT_IVIM;
            }
            avmaxsynbvalstab = prescribed_max_bval + prescribed_bval_range * SYNBVAL_EXPAND_FACTOR;
            if (avmaxsynbvalstab > UPPER_SYNB_LIMIT_RESTRICT_DIFF)
            {
                avmaxsynbvalstab = UPPER_SYNB_LIMIT_RESTRICT_DIFF;
            }

            if (PSD_ON == exist(opresearch))
            {
                avmaxsynbvalstab = UPPER_SYNB_LIMIT_RESEARCH_MODE;
            }

            /* update the background default synbvals if it gets out of range. */
            /* this is needed to avoid error condition when user increase the number of synbvals */
            for (bval_counter = opnumsynbvals; bval_counter < MAX_NUM_SYNBVALS; bval_counter++)
            {
                if (synbvalstab[bval_counter] > avmaxsynbvalstab)
                {
                    synbvalstab[bval_counter] = avmaxsynbvalstab;
                }
                else if (synbvalstab[bval_counter] < avminsynbvalstab)
                {
                    synbvalstab[bval_counter] = avminsynbvalstab;
                }
            }

            /* error massages for synDWI */
            for (bval_counter = 0; bval_counter < opnumsynbvals; bval_counter++)
            {
                if (synbvalstab[bval_counter] > avmaxsynbvalstab || synbvalstab[bval_counter] < avminsynbvalstab)
                {
                    epic_error( use_ermes, 
                                "Available synthetic b-value range is %d to %d for the entered b-value range %d to %d.",
                                EM_PSD_SYNBVALUE_OUT_OF_RANGE, EE_ARGS(4), 
                                INT_ARG, (int)avminsynbvalstab,  INT_ARG, (int)avmaxsynbvalstab,
                                INT_ARG, (int)prescribed_min_bval , INT_ARG, (int)prescribed_max_bval);
                    return FAILURE;
                }
            }
        }

        /* MRIge71092 */
        if((!floatIsInteger(opuser6)) || (opuser6<0.0) || (opuser6>1.0))
        {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, _opuser6.descr );
            return FAILURE;
        }

        /* BJM: DTI Error Messages */
        if(FAILURE == DTI_Check()) 
        {
            return FAILURE;
        }  

        /* YMSmr06650: limit # slices to max_slice_dfaxall with MPG ALL */
        if ((exist(opslquant) > max_slice_dfaxall) && existcv(opslquant)
           && (exist(opdfaxall) > PSD_OFF) && (exist(opdiffuse) == PSD_ON))
        {
            epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, max_slice_dfaxall );
            avmaxslquant = max_slice_dfaxall;
            return ADVISORY_FAILURE;
        }

        if (tensor_flag == PSD_ON) {
            if ((exist(opslquant) > avmaxslquant) && existcv(opslquant))
            {
                epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxslquant );
                return ADVISORY_FAILURE;
            }

            if ( (act_acqs > 1) ) {
                epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "TENSOR", STRING_ARG, "Multiple acquisitions" );
                return FAILURE;
            }

        } /* end tensor_flag check */      
        /*multiband suppoprts single acq only*/
        if (mux_flag == PSD_ON) {
            if ((exist(opslquant) > avmaxslquant) && existcv(opslquant))
            {
                epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxslquant );
                return ADVISORY_FAILURE;
            }

            if ( (act_acqs > 1) ) {
                epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "HyperBand", STRING_ARG, "Multiple acquisitions" );
                return FAILURE;
            }

        } /* end mux_flag check */

        /* MUSE supports single acq only*/
        if (muse_flag == PSD_ON) {
            if ((exist(opslquant) > avmaxslquant) && existcv(opslquant))
            {
                epic_error( use_ermes, "Maximum slice quantity is %-d ", EM_PSD_SLQUANT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxslquant );
                return ADVISORY_FAILURE;
            }

            if ( (act_acqs > 1) ) {
                epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "Multiple acquisitions" );
                return FAILURE;
            }
        } /* end muse_flag check */
   
   } /* end opdiffuse check */

@inline MK_GradSpec.e GspecCheck

    /* HCSDM00337293 */
    if(mkgspec_flag)
    {
        if( (PSD_OFF == exist(opdiffuse)) && (MK_SPEC_MODE_GMAX == mkgspec_flag) )
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "The gradient spec PSD", STRING_ARG, "EPI FLAIR" );
            return FAILURE;
        }
        if( (PSD_OFF == exist(opdfax3in1)) && existcv(opdfax3in1) && (PSD_ON == different_mpg_amp_flag) )
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "The gradient spec PSD", STRING_ARG, "other diffusion direction than 3 in 1" );
            return FAILURE;
        }
        if( (PSD_ON == dualspinecho_flag) && (PSD_ON == different_mpg_amp_flag) )
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "The gradient spec PSD", STRING_ARG, "Dual Spin Echo" );
            return FAILURE;
        }
        if( (exist(opnumbvals) > 1) && (PSD_ON == different_mpg_amp_flag) )
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "The gradient spec PSD", STRING_ARG, "Multiple b-value" );
            return FAILURE;
        }
    }

    /* Check if the number of opshots are greater than opyres. */
    if ( exist(opnshots) > exist(opyres) ) { 
        epic_error( use_ermes, "Number of shots must be less than or equal to phase encode lines.", EM_PSD_EPI_NSHOTS_YRES_INCOMPATIBLE1, EE_ARGS(0) );
        avminnshots = exist(opyres);
        avmaxnshots = exist(opyres);
        return ADVISORY_FAILURE;
    }

    /* Check if the selected yres is compatible with the chosen opnshots and te */
    if ( ((rhnframes + rhhnover) % exist(opnshots)) != 0 ) { 
        temp_int = exist(opyres)/exist(opnshots);
        if ( (temp_int % 2) == 1) 
            temp_int +=1;
        newyres = temp_int*exist(opnshots);

        {
            int temp_yres, temp_frames, calc_sign, icount, max_count;

            max_count = IMax(2, (newyres - avminyres)/2, (avmaxyres - newyres)/2);

            for (icount=0; (icount<=max_count*2); icount++){

                calc_sign = 1 - 2*(icount%2);
                temp_yres = newyres + 2*calc_sign*(icount/2);

                if ((temp_yres >= avminyres) && (temp_yres <= avmaxyres)){
                    if(num_overscan > 0) {
                         temp_frames = (short)(ceilf((float)temp_yres*asset_factor/rup_factor)*rup_factor*fn*nop - ky_offset);
                    } else {
                         temp_frames = (short)(ceilf((float)temp_yres*asset_factor/rup_factor)*rup_factor*fn*nop);
                    }
                    if (((temp_frames + rhhnover) % 2 == 0) &&
                        ((temp_frames + rhhnover) % exist(opnshots) == 0)){
                        newyres = temp_yres;
                        break;
                    }
                }
            }
        }

        epic_error( use_ermes, "The nearest valid phase encoding value is %d.", EM_PSD_YRES_ROUNDING, EE_ARGS(1), INT_ARG, newyres );
        avminyres = newyres;
        avmaxyres = newyres;
        return ADVISORY_FAILURE;
    }

    /*MRIge42072*/
    if (existcv(opphasefov) && ((exist(opphasefov) < min_phasefov) || (exist(opphasefov) > 1.00)))
    {
        epic_error( use_ermes, "Phase FOV less than %0.2f and greater than %0.2f are not supported.",
                    EM_PSD_PHASEFOV_OUT_OF_RANGE2, EE_ARGS(2), FLOAT_ARG, min_phasefov, FLOAT_ARG, 1.00);
        return FAILURE;
    }

    if ( (rhnframes + rhhnover)%2 != 0 ) {
        epic_error( use_ermes, "Illegal combination of phase encode lines, shots, and fract/full TE.", EM_PSD_EPI_ILLEGAL_NFRAMES, EE_ARGS(0) );
        return FAILURE;
    }


    if ((exist(opte) < (float)avminte) && existcv(opte)) {
        epic_error( use_ermes, "The selected TE must be increased to %d ms for the current prescription.", EM_PSD_TE_OUT_OF_RANGE3, EE_ARGS(1), INT_ARG, (int)ceil((double)avminte/1000.0) );
        return ADVISORY_FAILURE;
    }

    /* Limit min FOV based on asset scan Calibration */
@inline Asset.e AssetMinFOV  

    if ((exist(opfov) < avminfov) && existcv(opfov)) {
        epic_error( use_ermes, "The FOV needs to be increased to %3.1f cm for the current prescription, or receive bandwidth can be decreased.", EM_PSD_FOV_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avminfov/10.0 );
        return ADVISORY_FAILURE;
    }  

    if (existcv(oprbw) && (exist(oprbw) < avminrbw)) {
        epic_error( use_ermes, "With the current Scan Timimg prescription, the minimum first echo bandwidth is %4.2f KHz.", EM_PSD_MIN_RBW1, EE_ARGS(1), FLOAT_ARG, avminrbw );
        return ADVISORY_FAILURE;
    }

    if ((exist(opfov) > avmaxfov) && existcv(opfov)) {
        epic_error( use_ermes, "The FOV needs to be decreased to %3.1f cm for the current prescription.", EM_PSD_FOV_OUT_OF_RANGE2, EE_ARGS(1), FLOAT_ARG, avmaxfov/10.0 );
        return ADVISORY_FAILURE;
    }

    if (existcv(opyres) && (exist(opyres) % 2) != 0) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "yres must be an even number" );
        return FAILURE; 
    }

    if (existcv(opxres) && (exist(opxres) <= 32 || exist(opxres) > 512)) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "X resolution out of range." );
        return FAILURE; 
    }

    /* Ensure that xres is a even number. ufi2_ypd */
    if (existcv(opxres) && (exist(opxres) % 2) != 0) {
        epic_error( use_ermes, "The xres must be an even number.", EM_PSD_EPI_XRES_INVALID, EE_ARGS(0) );
        return FAILURE;
    }

    /* MRIhc56388: rhfrsize limit for dynamic phasce correction */
    if( iref_etl>0 && existcv(opxres) && rhfrsize > MAXFRAMESIZE_DPC) {
        epic_error(use_ermes, "XRES is out of range",
                   EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "XRES");
        return FAILURE;
    }

    /* MRIge57061 - lock out greater than 16 NEX */
    if(exist(opdiffuse) == PSD_ON)
    {
        for (bval_counter = 0; bval_counter < exist(opnumbvals); bval_counter++)
        {
            if (difnextab[bval_counter] > max_difnex_limit || difnextab[bval_counter] < 1) 
            {
                epic_error( use_ermes, "The selected number of excitations is not valid for the current prescription."
                                        , EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
                return FAILURE; 
             }
        }

        for (bval_counter = 0; bval_counter < exist(opnumbvals); bval_counter++)
        {
            if( !floatsAlmostEqualRelative(floor(difnextab[bval_counter]), difnextab[bval_counter], 0.0001) )
            {
                epic_error(use_ermes, "Fractional NEX is not allowed with this scan.", EM_PSD_FNEX_INCOMPATIBLE, EE_ARGS(0));
                return FAILURE;
            }
        }
    }
    else
    {
        if ( !floatIsInteger(exist(opnex)) || floatsAlmostEqualEpsilons(exist(opnex), 0.0, 2)) 
        {
            epic_error(use_ermes, "Fractional NEX is not allowed with this scan.", EM_PSD_FNEX_INCOMPATIBLE, EE_ARGS(0));
            avminnex = 1.0;
            avmaxnex = FMax(2, 1.0, floor(exist(opnex)));
            return ADVISORY_FAILURE; 
        }
    }

    if (vrgfsamp == 0 && rampsamp == PSD_ON) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "vrgfsamp must be 1 when rampsamp is 1" );
        return FAILURE; 
    }

    if ( (exist(opcgate)==PSD_ON) && (opmph==PSD_ON) && (opacqo==1) ) {
        epic_error( use_ermes, "The sequential multiphase and cardiac gating options are not\ncompatible for epi.", EM_PSD_EPI_SEQMPH_CGATE_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    if (ygmn_type == CALC_GMN1 && gy1pos == PSD_PRE_180) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "gy1 pulse pos for fcomp." );
        return FAILURE;
    }

    if (SpSatCheck() == FAILURE) return FAILURE;

    if( existcv(opslthick) && (exist(opslthick) < avminslthick) ) {
        epic_error( use_ermes, "The Slice thickness must be increased to %.2f mm for the current prescription.", EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avminslthick );
        return ADVISORY_FAILURE;
    }        

    if (a_gzrf1 > loggrd.tz) {
        epic_error( use_ermes, "The Slice thickness must be increased to %.2f mm for the current prescription.", EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avminslthick );
        return ADVISORY_FAILURE;
    }

    if (a_gzrf2 > loggrd.tz) {
        epic_error( use_ermes, "The Slice thickness must be increased to %.2f mm for the current prescription.", EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avminslthick );
        return ADVISORY_FAILURE;

    }

    /*
     *  MRIge70693 - Due to the way multiple NEX is implemented DW-EPI not
     *  compatible with extended dynamic range. If operator choses EDR,
     *  display error message
     */
    if (exist(opptsize) == 4 && exist(opdiffuse) == PSD_ON && (edr_support == PSD_OFF)) {
        epic_error( use_ermes, "Extended Dynamic Range is not supported for DW-EPI.", EM_PSD_DWEPI_EDR_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    /* dB/dt error checks */
    /************************************/
    if (pidbdtts > cfdbdtts && cfdbdtts > 0.0 && existcv(opfov)) {
        epic_error( use_ermes, "Stimulation threshold exceeded (T/s).", EM_PSD_EPI_DBDTTS, EE_ARGS(0) );
        printf("\ndB/dt value of %f T/s exceeds limit of %f T/s\n",
               pidbdtts, cfdbdtts);
        return FAILURE;
    }

    if (pidbdtper > cfdbdtper && cfdbdtper > 0.0 && existcv(opfov)) {
        epic_error( use_ermes, "Stimulation threshold exceeded (%%).", EM_PSD_EPI_DBDTPER, EE_ARGS(0) );
        printf("\ndB/dt value of %f percent exceeds limit of %f percent\n",
               100.0*pidbdtper, 100.0*cfdbdtper);
        return FAILURE;  
    }

    /* multi-phase error messages */
    /* DTI change check from avmaxpasses */
    if( mph_flag == PSD_ON ) {
        if ( existcv(opslquant) && ((dwi_fphases*exist(opdiffuse)) > 
                                    avmaxpasses ) ) {
/* TOMOD: need to add errmsgs */
            epic_error( 0, "Maximum number of phases exceeded, reduce # of phases or b-values", EM_PSD_MAXPHASE_EXCEEDED, EE_ARGS(0) );
            return FAILURE;
        }

        /*No of images check 1024 im/ser*/
        if ( existcv(opslquant) && (opslquant * (dwi_fphases*exist(opdiffuse)) > 
                    max_slice_limit) ) {
/* TOMOD: need to add errmsgs */
            epic_error( 0, "Maximum number of images exceeded, reduce # of slices, phases or b-values", EM_PSD_MAXPHASE_EXCEEDED, EE_ARGS(0) );
            return FAILURE;
        }

        /* YMSmr06649 */
        if ( existcv(opslquant) && existcv(opfphases) &&
                ((opfphases * opslquant * opphases) > max_slice_limit) ) {
            epic_error(use_ermes, "The number of locations * phases has exceeded %d.",
                    EM_PSD_SLCPHA_OUT_OF_RANGE ,EE_ARGS(1),INT_ARG,max_slice_limit);
            return FAILURE;
        }

        /* MRIhc00610 */
        /* rhnpasses check*/ /* YMSmr06515: # of slice locations expansion */
        if ( existcv(opfphases) && (exist(opacqo) == 0) && ( (pass_reps * act_acqs) > avmaxpasses ) ) { 
            epic_error (use_ermes, "The maximum number of phases is %-d", 
                        EM_PSD_NUM_PASS_OUT_OF_RANGE, 1, INT_ARG, avmaxpasses);
            return FAILURE;
        }
        if ( existcv(opfphases) && (exist(opacqo) == PSD_ON) && (opfphases > avmaxpasses) ) {
            epic_error (use_ermes, "The maximum number of phases is %-d", 
                    EM_PSD_NUM_PASS_OUT_OF_RANGE, 1, INT_ARG, avmaxpasses);
            return FAILURE;
        }
    }


    if ( (exist(opnshots) == exist(opyres)) && (exist(opautote) == 2) ) {
        epic_error( use_ermes, "Number of Phases should exceed Number of shots if Minimum TE is selected.", EM_PSD_EPI_NPHASESNSHOTS, EE_ARGS(0) );
        return FAILURE;
    }

    /* YMSmr07177 */
    if ((opsldelay < (float)avminsldelay) && existcv(opsldelay)) { 
        epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "Delay After Acq" );
	return FAILURE;
    }

    /* YMSmr06685, YMSmr07177 */
    if ((opsldelay > (float)avmaxsldelay) && existcv(opsldelay)) {
        epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "Delay After Acq" );
        return FAILURE;
    } 

    /* PH MRIge49595 - opnshots have to be 1 with diffusion. */
    if  ((exist(opnshots) != min_nshots) && (exist(opdiffuse) == PSD_ON) && (muse_flag == PSD_OFF) )  {

        epic_error( use_ermes, "Max. Number of Shots for DW-EPI is %d.", EM_DWEPI_MAX_SHOT_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, 1 );

        return ADVISORY_FAILURE; 
    }

    if ( (exist(opxres) > 256) && (rampsamp == PSD_ON)  && (muse_flag == PSD_OFF) ) {
        epic_error( use_ermes, "xres greater than 256 and ramp sampling are not compatible.", EM_PSD_EPI_RAMPSAMP_XRES, EE_ARGS(0) );
        return FAILURE; 
    }

    if ( (cffield == B0_5000) && (exist(opfat) !=  PSD_ON) ) {
        epic_error( use_ermes, "Fat suppression must be selected with 0.5T epi.", EM_PSD_EPI_HALFT_NOFATSAT, EE_ARGS(0) );
        return FAILURE; 
    }

    if (FAILURE == Monitor_Cvcheck())
    {
        return FAILURE;
    }

    /* Check imaging options */
    status_flag = checkEpi2ImageOptions();
    if(status_flag != SUCCESS) return status_flag;

    /* Throw warning if cal files are missing */
    if(epiCalFileCVCheck() != SUCCESS) return FAILURE;

    if(aspir_flag)
    {
        if( PSD_ON == exist(opirprep) )
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "IRPREP", STRING_ARG, "ASPIR" ); 
            return FAILURE; 
        } 
        if( PSD_ON == epi_flair ) 
        { 
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "FLAIR", STRING_ARG, "ASPIR" ); 
            return FAILURE; 
        } 
    }

    if ((t1flair_flag) && exist(opcgate))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Interleaved STIR", STRING_ARG, "Cardiac Gating" );
        return FAILURE;
    }

    if ((t1flair_flag) && exist(oprtcgate))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Interleaved STIR", STRING_ARG, "Respiratory Gating" );
        return FAILURE;
    }

    if ((t1flair_flag) && (PSD_ON == navtrig_flag))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Interleaved STIR", STRING_ARG, "Navigator" );
        return FAILURE;
    }

    if ((t1flair_flag) && (exist(opirmode) == PSD_ON))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Interleaved STIR", STRING_ARG, "Sequential" );
        return FAILURE;
    }

    if ((PSD_OFF == bodynav_status) && (PSD_ON == navtrig_flag))
    {
        epic_error( use_ermes, "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1), STRING_ARG, "Body Navigator" );
        return FAILURE;
    }
    
    if ((PSD_OFF == focus_status) && (PSD_ON == rfov_flag))
    {
        epic_error( use_ermes, "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1), STRING_ARG, "Focus" );
        return FAILURE;
    }

    if ((PSD_OFF == multiband_status) && (PSD_ON == mux_flag))
    {
        epic_error( use_ermes, "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1), STRING_ARG, "HyperBand" );
        return FAILURE;
    }

    if ((PSD_OFF == muse_status) && (PSD_ON == muse_flag))
    {
        epic_error( use_ermes, "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1), STRING_ARG, "MUSE" );
        return FAILURE;
    }

    if ( ( cfrecvend-cfrecvst+1<8 ) && (PSD_ON == muse_flag) )
    {
        /* MUSE does not support coils with less than 8 channels */
        epic_error(use_ermes, "%s is incompatible with %s", EM_PSD_INCOMPATIBLE,
                   EE_ARGS(2), STRING_ARG, "Coil with less than 8 channels",STRING_ARG, "MUSE");
        return FAILURE;
    }

    if ( (1.0/asset_factor>avmaxaccel_ph_stride/(float)exist(opnshots)) && (PSD_ON == muse_flag) && (PSD_ON != exist(opresearch)) && existcv(opnshots) ) {
		epic_error( use_ermes, "The phase acceleration must be reduced to %0.2f for this prescription.",
					EM_PSD_GEM_INVALID_ACCEL, EE_ARGS(1),
					FLOAT_ARG, (avmaxaccel_ph_stride/(float)exist(opnshots))  );
		return FAILURE;
    }

    if ( ( cfrecvend-cfrecvst+1<9 ) && (PSD_ON == mux_flag) && (exist(opaccel_mb_stride)>1))
    {
        /* Multiband does not support coils with less than 9 channels */
        epic_error(use_ermes, "%s is incompatible with %s", EM_PSD_INCOMPATIBLE,
                   EE_ARGS(2), STRING_ARG, "Coil with less than 9 channels",STRING_ARG, "HyperBand");
        return FAILURE;
    }


#ifndef SIM
    char attribute_codeMeaning[ATTRIBUTE_RESULT_SIZE] = "";
    getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CODE_MEANING, attribute_codeMeaning);

    if ( (!isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_HEAD) && opanatomy) 
         && !(isCategoryMatchForAnatomy(exist(opanatomy), ATTRIBUTE_CATEGORY_CHEST)
             && strstr(attribute_codeMeaning, "Breast"))
         && (PSD_ON == mux_flag) && (exist(opaccel_mb_stride)>1) )
    {
        epic_error(use_ermes, "%s is incompatible with %s", EM_PSD_INCOMPATIBLE,
                   EE_ARGS(2), STRING_ARG, "Non-Head or Non-Breast Scan in Clinical Mode",STRING_ARG, "HyperBand");
        return FAILURE;
    }
#endif
    /* Refless EPI */
    if (ref_in_scan_flag == PSD_ON)
    {
        if (exist(opdiffuse) == PSD_OFF)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Integrated Reference Scan", STRING_ARG, "Non-Diffusion" );
            return FAILURE;
        }

        if (dda == 0)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Integrated Reference Scan", STRING_ARG, "dda 0" );
            return FAILURE;
        }

        if ((intleaves > 1) && (muse_flag == PSD_OFF))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Integrated Reference Scan", STRING_ARG, "intleaves > 1" );
            return FAILURE;
        }

        if (ref_volrecvcoil_flag == PSD_ON)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG,
                        "Switching Coil for Reference Scan", STRING_ARG, "Integrated Reference Scan" );
            return FAILURE;
        }
    }
    if(ssgr_flag)
    {
        if(PSD_OFF == exist(opdiffuse))
        {
            epic_error( use_ermes, "The Classic option is not supported in this scan.", EM_PSD_CLASSIC_INCOMPATIBLE, EE_ARGS(0) );
            return FAILURE;
        }
        else if(((ss_rf1 && existcv(opfat) && existcv(opspecir)) || rfov_flag) && (!dualspinecho_flag))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), 
                        STRING_ARG, "Classic", STRING_ARG, "Single Spin Echo with SpSp or FOCUS pulse" );
            return FAILURE;
        }
    }

        /*RTB0 correction: add 1 TR for RTB0*/ /*this will be ok for both triggered scan or non-triggered scan*/
    if (rtb0_flag == PSD_ON)
    {
        scan_time += act_tr+rtb0fittingwaittime+rtb0dummy_time;
        avmintscan = scan_time;
        pitscan = avmintscan; /* This value shown in clock */
        pisctim1 = pitscan;
    }

@inline Asset.e AssetCheck     /* Asset */
    if(mux_flag)
    {
@inline ARC.e ARCCheck
    }

    /* diff cycling will is incompatible with the legacy hyerdab*/
    if ((diff_order_flag >0) && (hsdab !=2 ))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG,
                    "Diffusion gradient cycling", STRING_ARG, "non-diffusion hyper dab packet" );
        return FAILURE;
    }
    
    if (rpg_flag > 0)
    {
        if (PSD_OFF == distcorr_status)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "this system" );
            return FAILURE;
        }

        if (diff_order_flag == 2)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "T2+Diffusion Cycling" );
            return FAILURE;
        }
        
        if (PSD_OFF == exist(opdiffuse))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Non-Diffusion scan" );
            return FAILURE;
        }
        
        if (PSD_ON == rfov_flag)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Focus" );
            return FAILURE;
        }
        
        if (0 == dda)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "dda 0" );
            return FAILURE; 
        }

        if (PSD_ON == exist(opcgate))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Cardiac Gating" );
            return FAILURE; 
        }

        if (PSD_ON == exist(oprtcgate))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Respiratory Triggering" );
            return FAILURE; 
        }

        if (PSD_ON == exist(opnav))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Navigators" );
            return FAILURE; 
        }

        if (PSD_ON == exist(opmph))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Multi-Phase" );
            return FAILURE; 
        }

        if (PSD_ON == exist(opfcomp))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "Flow Compensation" );
            return FAILURE; 
        }

        if ((asset_factor/(float)(opnshots))>0.5)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction", STRING_ARG, "<2.0 ASSET" );
            return FAILURE;
        }
    }
    else
    {
        if (rhdistcorr_ctrl > 0)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Distortion Correction Off", STRING_ARG, "rhdistcorr_ctrl>0");
            return FAILURE;
        }
    }

    if(dpc_flag)
    {
        if(iref_etl == 0)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                STRING_ARG, "Dynamic Phase Correction", STRING_ARG, "iref_etl = 0" );
            return FAILURE;
        }

        if (exist(opdiffuse) == PSD_OFF)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                STRING_ARG, "Dynamic Phase Correction", STRING_ARG, "Non-Diffusion scan" );
            return FAILURE;
        }

        if( ky_dir == PSD_CENTER_OUT) {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                STRING_ARG, "Dynamic Phase Correction", STRING_ARG, "CENTER_OUT" );
            return FAILURE;
        }

        if(rtb0_flag)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Dynamic Phase Correction", STRING_ARG, "Real Time Center Frequency");
            return FAILURE;
        }

    }

    if((hopc_flag == PSD_ON) && (pc_enh == PSD_OFF))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "High-Order Phase Correction", STRING_ARG, "Magnitude-Weighted");
        return FAILURE;
    }

    return SUCCESS;
} /* end CVCHECK */

@inline ss.e ssCheck

/*RTB0 correction*/
@inline RTB0.e RTB0init

/* DTI b-value calcs using pulsegen are inlined here */
@inline DTI.e DTI_Predownload
@inline T1flair.e T1flairPredownload

/***********************************************************************/
/* PREDOWNLOAD                                                         */
/***********************************************************************/
STATUS
predownload( void )
{
    int off_index;   /* loop index */
    int i,j;       /* counters */
    int sloff;
    int acq_off;
    int pislice[SLTAB_MAX];

    /* HCSDM00361682 */
    if(focus_eval_oscil_hist)
    {
        int status;
        isPredownload = 1;
        set_cvs_changed_flag(TRUE);
        for(i=0; i<NUM_EVAL_IN_PREDOWNLOAD; i++)
        {
            status = cveval();
            if(status != SUCCESS)
            {
                isPredownload = 0;
                set_cvs_changed_flag(FALSE);
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "cveval" );
                return status;
            }
        }
        set_cvs_changed_flag(FALSE);
        oscil_eval_count = 0;
        isPredownload = 0;
        focus_eval_oscil_hist = 0;
    }

@inline vmx.e PreDownLoad 

    /* to avoid side effects, set pitfeextra before loadrheader */
    pitfeextra = 0;

    /* t1flair_stir */
    if (PSD_ON == t1flair_flag)
    {
        slquant1 -= dummyslices + 2*act_edge_slice_enh_flag;
    }

    /* PURE Mix */
    model_parameters.epi.dualspinecho_flag = dualspinecho_flag;
    model_parameters.epi.rfov_flag = rfov_flag;

    /* recon variables */
@inline loadrheader.e rheaderinit
    
    /* t1flair_stir */
    if (PSD_ON == t1flair_flag)
    {
        slquant1 += dummyslices + 2*act_edge_slice_enh_flag;
    }

    /* Asset */
@inline Asset.e AssetSetRhVars
    /* MUSE This must be done after AssetSetRhVars such that rhasset_torso is set to 1 for Muse regardless of coils*/
@inline Muse.e MuseSetRhVars

    if(mux_flag)
    {
@inline ARC.e ARCrh
    }
    /* > 1024 im/ser -Venkat
     * rhformat(14th bit) : 0=Normal 1=Multiphase scan
     * rhmphasetype       : 0=Int MPh 1=Seq Mph
     * rhnphases          : No of phases in a multiphase scan
     */
 
    cvmax(rhnphases, avmaxpasses); 

    if ( enable_1024 )
    {
        rhformat |= RHF_SINGLE_PHASE_INFO;

        if (exist(opacqo) == PSD_OFF) 
        {
            rhmphasetype = 0; /* Interleaved multiphase*/
        }
        else
        {
            rhmphasetype = 1; /* Sequential multiphase*/
        }

        rhnphases = dwi_fphases; /* No of phases in a multiphase scan*/
    }
    else
    {
        rhformat &= ~RHF_SINGLE_PHASE_INFO;
        rhnphases = exist(opfphases);
    }


    /* now set it for fract ky annotation */
    pitfeextra = fract_ky;

    /* *****************************
       Slice Ordering
       *************************** */

    if (use_myscan==1) myscan();

    if (exist(opslquant) == 3 && b0calmode == 1)
        setb0rotmats();

    if (slice_reset == 1) {
        for (off_index=0;off_index<opslquant;off_index++)
            scan_info[off_index].optloc = slice_loc;
    }

    if (scan_offset != 0 )
        for (off_index=0;off_index<opslquant;off_index++)
            scan_info[off_index].optloc += (float)scan_offset;

    if (debug_scan)
        psd_dump_scan_info();

    order_routine = seq_type;

    /* t1flair_stir */
    if (PSD_ON == t1flair_flag)
    {
        int s;
        if (orderslice(order_routine,opslquant+(dummyslices+ 2*act_edge_slice_enh_flag)*acqs,
                       slquant1, gating) == FAILURE)
        {
            epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,EE_ARGS(1),STRING_ARG,"orderslice");
            return FAILURE;
        }

        t1flair_slice_info_enh[0] = slquant1;
        for (s = 0; s <slquant1; s++)
        {
            t1flair_slice_info_enh[s+1] = data_acq_order[s*acqs].sltime;
        }

        if (orderslice(order_routine,opslquant,
                       (slquant1 - dummyslices- 2*act_edge_slice_enh_flag), 
                       gating) == FAILURE)
        {
            epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,EE_ARGS(1),STRING_ARG,"orderslice");
            return FAILURE;
        }

        t1flair_slice_info_reg[0] = slquant1-dummyslices - 2*act_edge_slice_enh_flag;
        for (s = 0; s <slquant1-dummyslices - 2*act_edge_slice_enh_flag; s++)
        {
            t1flair_slice_info_reg[s+1] = data_acq_order[s*acqs].sltime;
        }

    }
    else if (mux_flag)
    {
        if (orderslice(TYPMULTIBAND, opslquant, slquant1, gating) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "orderslice" );
            return FAILURE;
        }
    }
    else
    {
        if (orderslice(order_routine, opslquant, slquant1, gating) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "orderslice" );
            return FAILURE;
        }
    }

    /* MRIhc27254, MRIhc27361 slice ordering is interleaved to prevent slice
     * intensity variation */
    if ( exist(opcgate) == PSD_ON )
    {
        int ii, jj, numReps;
        int iRR = 0;         /* index for RR 0,1,2,...*/
        int rr_start = 0;    /* index for the starting slice in each RR 0,1,2,...*/

        if (act_acqs > 1)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG,
                        "Multi Acquisition", STRING_ARG, "Cardiac Triggering" );
            return FAILURE;
        }

        /* n.b. for TYPXRR numAcqs is always 1 */
        numReps = ((0 == (opslquant % slquant1)) ?  opslquant / slquant1 : opslquant / slquant1 + 1);
        typncat(data_acq_order, pislice, opslquant, numReps, opimode, oppseq, exist(opflaxall));

        for (ii = 0; ii <= opslquant -1; ii++)
        {
            rsp_info[pislice[ii]].rsptloc    = scan_info[ii].optloc    + scan_info[ii].optloc_shift;
            rsp_info[pislice[ii]].rsprloc    = scan_info[ii].oprloc    + scan_info[ii].oprloc_shift;
            rsp_info[pislice[ii]].rspphasoff = scan_info[ii].opphasoff + scan_info[ii].opphasoff_shift;

            for (jj = 0; jj <= 8; jj++) 
            {
                rsprot[pislice[ii]][jj] = hostToRspRotMat(scan_info[ii].oprot[jj]);
            }

            rsptrigger[ii] = TRIG_INTERN; /* initialize the trigger as internal */

            if (opslquant <= ophrep) 
            {
                rsptrigger[ii] = gating;
            }
            else 
            {
                if (ii == rr_start)
                {
                    iRR += 1;
                    if (iRR <= (opslquant % ophrep))
                    {
                        rsptrigger[ii] = gating;
                        rr_start += (int)(opslquant/ophrep) + 1;
                    }
                    if (iRR > (opslquant % ophrep))
                    {
                        rsptrigger[ii] = gating;
                        rr_start += (int)(opslquant/ophrep);
                    }
                }
            }
        }
    }

    if(mux_flag)
    {
        if(scan_info[2].optloc - scan_info[1].optloc > 0)
        {
            rhmb_slice_order_sign = 1;
        }
        else
        {
            rhmb_slice_order_sign = -1;
        }
    }

    /* Value1.5T May 2005 KK */
    if(ghost_check&&gck_offset_fov)
       rsp_info[0].rspphasoff = get_act_phase_fov() / 4.0;

    /* set slice order for multi phase (seq,intl)	*/
    if ( order_routine == TYPNCAT && opfphases > 1 && opdiffuse == PSD_OFF && tensor_flag == PSD_OFF) {


        acq_off = reps*slquant1;

        if (acqmode == 0)  /* interleaved */
        {
            
            /*Venkat > 1024 im/ser */
            /* do nothing ! */
        } /* end if interleaved */

        else if (acqmode == 1)  /* sequential */
        {
            for (i=0; i<acqs; i++)  /* slices loop */
            {
                /*Venkat > 1024 im/ser */
                for (j=0; j<1; j++)
                {
                    sloff = i*reps + j;
                    data_acq_order[sloff].slloc = i;

                    /*MRIge59759 -- actual data order is 0,acq/2,1,acq/2+1...
                      i/2 is integer 0,0,1,1,2,2,... i%2 marks the odd acqs
                      and ceil(acqs/2) adds the offset.*/

                    data_acq_order[sloff].slpass = i/2 + ((i%2)*ceil((float)acqs/2.0));
                    data_acq_order[sloff].sltime = j;
                }
            }
        } /* end if sequential */
    }

    /* Load data_acq_order for diffusion acquisition */
    if ( pass_reps > 1) {
        /* dw-epi, tensor and multiphase(with fphases > 1) interleaved epi-flair enter here*/
        /* Should not enter "if" for Tensor and multiphase epi-(flair)-Venkat*/
        if( (! enable_1024) )
        {
            for (j = 1; j < pass_reps; j++) {
                for (i = 0; i < opslquant*opphases; i++) {
                    sloff = i + j*opslquant*opphases;
                    data_acq_order[sloff].slloc = data_acq_order[i].slloc;
                    data_acq_order[sloff].slpass = data_acq_order[i].slpass + j*act_acqs;
                    data_acq_order[sloff].sltime = data_acq_order[i].sltime;
                }
            }
        }
    } /* if order_routine==TYPMPMP && pass_reps>1 */

    if (debug_order) {
        int max_ims = 0;

        /*
            1024 im/ser -Venkat
         */
        if( enable_1024 )
            max_ims = opslquant*opphases*reps;
        else
            max_ims = opslquant*dwi_fphases*opphases*reps;

        printf("\nslloc\tslpass\tsltime\t\n");
        for (i = 0; i < max_ims; i++) {
            printf("%d\t%d\t%d\n",data_acq_order[i].slloc,
                   data_acq_order[i].slpass,
                   data_acq_order[i].sltime);
        }
    }

    /* t1flair_stir */
    /* Predownload section for t1flair */
    if (T1flairPredownload() == FAILURE)
    {
        return FAILURE;
    }

    trig_scan = gating; 

    if (debug_scan)
        psd_dump_rsp_info();

    /* rsprot code */
    for (i=0; i<opslquant*opphases; i++){
        if (obl_debug == 1)
            printf("Slice %d\n",i);
        for (j=0; j<9; j++){
            rsprot_unscaled[i][j] = rsprot[i][j];
            if (obl_debug == 1)
                printf("rsprot_unscaled[%d] = %ld\n",j,rsprot_unscaled[i][j]);
        }
    }

    if (scalerotmats(rsprot, &loggrd, &phygrd, (int)(opslquant*opphases), obl_debug) == FAILURE)
    {
        epic_error(use_ermes,"System configuration data integrity violation detected in PSD. \nPlease try again or restart the system.",
                   EM_PSD_PSDCRUCIAL_CONFIG_FAILURE,EE_ARGS(0));
        return FAILURE;
    }

    /* **************************************
       Image Header CVs
       ************************************** */

    /* The routine imgtimutil() rounds down optr to full integer line cycles and
     * subtracts TR_SLOP in the calculation of act_tr. Therefore, act_tr is
     * never greater than optr, except in epi. In epi, act_tr is rounded up
     * to hrdwr_period (=64us) at the call of imgtimutil(). Because of this,
     * act_tr + TR_SLOP could be greater than optr. When this happens (ie, ihtr>optr),
     * we get download failure. In order to avoid this download failure, it is fixed 
     * by replacing:
     ihtr = act_tr + ((gating==TRIG_LINE) ? TR_SLOP :0);
     * with:
     ihtr = act_tr + ((gating==TRIG_LINE) ? TR_SLOP :0);
     if(gating==TRIG_LINE) ihtr = ihtr - hrdwr_period;

     * MRIge34441, ypd */

    if (opcgate == PSD_OFF && oprtcgate == PSD_OFF && mph_flag == PSD_OFF)
    {
        ihtr = act_tr + ((gating==TRIG_LINE) ? TR_SLOP :0);
        if(gating==TRIG_LINE) ihtr = ihtr - hrdwr_period;
        ihtdel1 = MIN_TDEL1;
    }
    else if (mph_flag == PSD_ON && opcgate == PSD_OFF)
    {
        ihtr = act_tr + ((gating==TRIG_LINE) ? TR_SLOP :0);
        if(gating==TRIG_LINE) ihtr = ihtr - hrdwr_period;
        free(ihtdeltab);

        if( enable_1024 )
        {
            ihtdeltab = (int *)malloc(opslquant*sizeof(int));
            exportaddr(ihtdeltab, (int)(opslquant*sizeof(int)));
            for (i=0; i<opslquant; i++)
            {
                /* YMSmr06832 */
                if (acqmode == 0) { /* interleaved */
                    if(epi_flair == PSD_ON){
                        ihtdeltab[i] =
                            (data_acq_order[i].slpass) *
                            (disdaq_shots*dda_fact/(float)passr_shots + nex*reps*core_shots) * act_tr +
                            (disdaq_shots*dda_fact/(float)passr_shots + nex*reps*core_shots-1) * act_tr +
                            ((int)(data_acq_order[i].sltime/false_slquant1))*(act_tr/(float)false_acqs) + exist(opti) +
                            RUP_GRD(avail_se_time/false_slquant1 - time_ssi) *
                            (data_acq_order[i].sltime % false_slquant1 + 1) +
                            (data_acq_order[i].slpass) * pass_delay*num_passdelay;
                    } else {
                        ihtdeltab[i] =
                            (data_acq_order[i].slpass) *
                            (disdaq_shots*dda_fact + nex*reps*core_shots) * act_tr +
                            (disdaq_shots*dda_fact + nex*reps*core_shots-1) * act_tr +
                            (data_acq_order[i].sltime + 1)*(act_tr/(float)slquant1) +
                            (data_acq_order[i].slpass) * pass_delay*num_passdelay;
                    }
                }
                else if (acqmode == 1) { /* sequential */
                    ihtdeltab[i] = 
                        (data_acq_order[i].slpass + 1) * 
                        (disdaq_shots*dda_fact/(float)reps + nex*core_shots) * act_tr +
                        (data_acq_order[i].sltime)*(act_tr/(float)slquant1) +
                        (data_acq_order[i].slpass) * pass_delay*num_passdelay;
                }
            }
        }
        else
        {
            ihtdeltab = (int *)malloc(dwi_fphases*opslquant*sizeof(int));
            exportaddr(ihtdeltab, (int)(dwi_fphases*opslquant*sizeof(int)));
            for (i=0; i<dwi_fphases*opslquant; i++)
            {
                ihtdeltab[i] = data_acq_order[i].slpass*
                    (disdaq_shots + nex*reps*(core_shots)) * act_tr +
                    (disdaq_shots + nex*reps*(core_shots-1)) * act_tr +
                    (data_acq_order[i].sltime+1)*(act_tr/(float)slquant1) +
                    data_acq_order[i].slpass*pass_delay*num_passdelay;
            }
        }

    }    
    else {
        free(ihtdeltab);
        free(ihtrtab);

        if( enable_1024 )
        {
            ihtdeltab = (int *)malloc(opphases*opslquant*sizeof(int));
            exportaddr(ihtdeltab, (int)(opphases*opslquant*sizeof(int)));
            ihtrtab = (int *)malloc(opphases*opslquant*sizeof(int));
            exportaddr(ihtrtab, (int)(opphases*opslquant*sizeof(int)));

            if (opphases > 1) {
                for (i = 0; i < opphases*opslquant; i++) {
                    if (data_acq_order[i].sltime < opslquant) {
                        ihtrtab[i] = act_tr - ((opphases/opslquant) - 1)
                            *opslquant*psd_tseq;
                    } else {
                        ihtrtab[i] = opslquant*psd_tseq;
                    }
                }
                for (i = 0; i < opphases*opslquant; i++) {
                    ihtdeltab[i] = optdel1 + psd_tseq*data_acq_order[i].sltime;
                }
            } else {
                /* Cross R-R */
                int n_per_RR = 0;
                int n_fill = opslquant % ophrep; /* # of filled R-R intervals */
                int ii, iii;
                int tmpslorder[opslquant]; /* temporal slice order */

                /* Calculate array mapping temporal slice order to
                 * spatial slice order */
                for (i = 0; i < opslquant; i++)
                {
                    tmpslorder[pislice[i]]=i;
                }

                iii = 0;
                for (i = 0; i < ophrep; i++)
                {
                    n_per_RR = opslquant / ophrep;
                    if (n_fill > 0)
                    {
                        /* Number of slices not evenly divisible by number
                         * of R-R intervals.  Increase number per R-R by 1
                         * and pack 1 extra slice into first n_fill R-R's */
                        n_per_RR += 1;
                        n_fill -= 1;
                    }

                    for (ii = 0; ii < n_per_RR; ii++)
                    {
                        /* If there are more R-R's than slices, we do
                         * not acquire data on the extra R-R's at the end */
                        if (iii < opslquant)
                        {
                            ihtdeltab[tmpslorder[iii]] = optdel1 + psd_tseq*ii;
                            ihtrtab[tmpslorder[iii]] = act_tr;
                            iii++;
                        }
                    }
                }

            }
        }
        else
        {
            ihtdeltab = (int *)malloc(opphases*opslquant*dwi_fphases*sizeof(int));
            exportaddr(ihtdeltab, (int)(opphases*opslquant*dwi_fphases*sizeof(int)));
            ihtrtab = (int *)malloc(opphases*opslquant*dwi_fphases*sizeof(int));
            exportaddr(ihtrtab, (int)(opphases*opslquant*dwi_fphases*sizeof(int)));

            if (opphases > 1) {
                for (i = 0; i < opphases*opslquant*dwi_fphases; i++) {
                    if (data_acq_order[i].sltime < opslquant) {
                        ihtrtab[i] = act_tr - ((opphases/opslquant) - 1)
                            *opslquant*psd_tseq;
                    } else {
                        ihtrtab[i] = opslquant*psd_tseq;
                    }
                }
                for (i = 0; i < opphases*opslquant*dwi_fphases; i++) {
                    ihtdeltab[i] = optdel1 + psd_tseq*data_acq_order[i].sltime;
                }
            } else {
                /* Cross R-R */
                int n_per_RR = 0;
                int n_fill = opslquant % ophrep; /* # of filled R-R intervals */
                int ii, iii;
                int tmpslorder[opslquant]; /* temporal slice order */

                /* Calculate array mapping temporal slice order to
                 * spatial slice order */
                for (i = 0; i < opslquant; i++)
                {
                    tmpslorder[pislice[i]]=i;
                }

                iii = 0;
                for (i = 0; i < ophrep; i++)
                {
                    n_per_RR = opslquant / ophrep;
                    if (n_fill > 0)
                    {
                        /* Number of slices not evenly divisible by number
                         * of R-R intervals.  Increase number per R-R by 1
                         * and pack 1 extra slice into first n_fill R-R's */
                        n_per_RR += 1;
                        n_fill -= 1;
                    }

                    for (ii = 0; ii < n_per_RR; ii++)
                    {
                        /* If there are more R-R's than slices, we do
                         * not acquire data on the extra R-R's at the end */
                        if (iii < opslquant)
                        {
                            ihtdeltab[tmpslorder[iii]] = optdel1 + psd_tseq*ii;
                            ihtrtab[tmpslorder[iii]] = act_tr;
                            iii++;
                        }
                    }
                }
            } 
        }

        if(debug_tdel)
        {
            for(i=0;i< opphases*opslquant; i++)
            {
                printf("ihtrtab[%d] = %d\n",i,ihtrtab[i]);
            }
        }
        fflush(stdout);
    } /* if (opcgate == PSD_OFF) */

    /* RTG or Nav */
    if ((exist(oprtcgate) == PSD_ON) || (navtrig_flag == PSD_ON))
    {
        int ikount, jkount = 0;

        ihtr = act_tr;
        free(ihtrtab);
        if(exist(oprtcgate) == PSD_ON)
        {
            free(ihtdeltab);
            ihtdeltab = (int *)malloc(opphases*exist(opslquant)*sizeof(int));
            exportaddr(ihtdeltab, (int)(opphases*exist(opslquant)*sizeof(int)));
        }
        ihtrtab = (int *)malloc(opphases*exist(opslquant)*sizeof(int));
        exportaddr(ihtrtab, (int)(opphases*exist(opslquant)*sizeof(int)));

        jkount= 0;
        for (ikount = 0; ikount < exist(opslquant); ikount++) {
            jkount = ikount/oprtrep;
            if(exist(oprtcgate) == PSD_ON)
            {
                ihtdeltab[ikount] = 60s/oprtrate*oprtpoint + psd_tseq*jkount;
            }
            ihtrtab[ikount] = act_tr;
        }
    } /* end RTG */

    if(debug_tdel && ( mph_flag == PSD_ON ) )
    {
        int max_ims = 0;

        /*
         * 1024 im/ser Venkat
         */
        if( enable_1024 )
            max_ims = opphases*opslquant;
        else
            max_ims = opphases*opslquant*dwi_fphases;
        
        for(i=0;i< max_ims; i++)
        {
            printf("ihtdeltab[%d] = %d\n",i,ihtdeltab[i]);
        }
    }
    fflush(stdout);

    /* set ihmaxtdelphase
     * This is the tdel value for the last acquired slice for the first phase
     * Used in ifcc to calculate the tdel values for the rest of the phases
     * -Venkat
     */ 
    if( enable_1024 )
    {
        /* YMSmr06832 */
        if( epi_flair == PSD_ON ){
            ihmaxtdelphase = acqs * ((disdaq_shots*dda_fact/(float)passr_shots + nex*reps*core_shots) * act_tr + pass_delay*num_passdelay);
        } else {
            ihmaxtdelphase = 0;

            for(i=0;i<opslquant*opphases;i++) 
            { 
                if((ihmaxtdelphase < ihtdeltab[i]) && 
                   (data_acq_order[i].slpass == 0 )){ 
                    ihmaxtdelphase = ihtdeltab[i];
                }
            }

            ihmaxtdelphase = ihmaxtdelphase + opsldelay;
            ihmaxtdelphase = ihmaxtdelphase * acqs;
        }
    }

    if(debug_tdel)
    {
        printf("ihmaxtdelphase = %10d\n",ihmaxtdelphase);
        fflush(stdout);
    }



    ihte1 = opte;

    /* nex annotation requirements changed at a late date per MRIge24292 */
    ihnex = nex;

    ihflip = flip_rf1;
    ihvbw1 = (FLOAT)(rint(oprbw));
    iheesp = eesp;

    /* *********************
       SAT Positioning
    *********************/
    if(SatPlacement(act_acqs) == FAILURE)
    {
        epic_error(use_ermes,"%s failed",EM_PSD_SUPPORT_FAILURE,
                   EE_ARGS(1),STRING_ARG,"SatPlacement");
        return FAILURE;
    }
 
    rhnpasses = act_acqs*pass_reps;
    eepf = 0;

    /* If phase enc grad is flipped, inform recon */
    if (PSD_ON == pepolar)
    {
        oepf = 1;
    }
    else
    {
        oepf = 0;
    }
    set_echo_flip(&rhdacqctrl, &chksum_rhdacqctrl, eepf, oepf, eeff, oeff); /* clear bit 1 - flips image in phase dir */

    rhdaxres = rhfrsize;

    rhpcctrl = 0;
    if ((exist(opdiffuse) == PSD_ON) && (ref_in_scan_flag == PSD_ON))
    {
        rhref = 5;
        rhpcctrl |= RHPCCTRL_INTEGRATED_REF;
    }
    else
    {
        /* Turn on new epi phase correction algorithm */
        /* BJM: 2 = Nearest Neighbor processing */
        rhref = 2; /* 0=old algorithm, 1 = new algorithm */
    }

    if(iref_etl > 0)
    {
        if(sndpc_flag == PSD_OFF)
            rhref = 3; /* Legacy dynamic phase correction */
        else
            rhref = 4; /* Self-navigated dynamic phase correction */
        rhpcctrl |= RHPCCTRL_DYNAMICPC_B0ONLY;
    }

    if(rf_chop == PSD_ON)
    {
        rhpcctrl |= RHPCCTRL_DWI_NEXS_RFCHOPPED;
    }

    /*MRIge93538 Turn off the advanced filter for DWI or DTI with PURE
      so that the ADC and EADC calculation will not be affected*/
    rhpurefilter = 0;

    if(vrgf_reorder == PSD_ON) {
        rhtype1 |= VRGF_AFTER_PCOR_ALT;
    } else {
        rhtype1 &= ~VRGF_AFTER_PCOR_ALT;
    }

    rhtype1 |= RHTYP1BAM0FILL; /* zero fill for smart NEX */
    if(opdiffuse == PSD_ON)
    {
        rhtype1 |= RHTYP1DIFFUSIONEPI;
    }
    else
    {
        rhtype1 &= ~RHTYP1DIFFUSIONEPI;
    }

    rhileaves = intleaves;
    rhkydir = ky_dir;
    rhalt = ep_alt;

    cvmax(rhreps, avmaxpasses); 

    /*MRIhc09116, YMSmr07202*/
    /* Needed for recon fixes. MRIge35288, MRIge36731. */
    if (exist(opmph)!=PSD_OFF)
        rhreps = exist(opfphases);
    else if (rhpcspacial == 0 && opdiffuse == PSD_ON) /*MRIge41682*/
    {
        rhreps = (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag ? rpg_in_scan_num:0) + opdifnumt2 + opdifnumdirs * opnumbvals;  /* Refless EPI */
    }
    else
    {
        rhreps = reps;
    }

    /* BJM: need to set rhreps to the total number of */
    /* phases (reps) for a tensor scan when rhpcpspacial is */
    /* used */
    if( (rhpcspacial == 0) && (tensor_flag == PSD_ON)) {
        rhreps = (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag ? rpg_in_scan_num:0) + num_tensor + num_B0;  /* Refless EPI */
    }

    /* determine region to be used for phase correction: */
    if (get_act_freq_fov() <= 300.0)
        pckeeppct = 100.0;
    else
        pckeeppct = (300.0 / get_act_freq_fov()) * 100.0;


    /* MRIge51452 - enable 256zip and annotation. */
    /* MRIge53876 - 256zip for matrix less than 256x256 */
    if ( !strncmp("epi2is",get_psd_name(),6) )
    {
        rhmethod = 1;  /* enable reduced image size */
    }
    else if ( (opxres<256) && (opyres<256) )
    {
        rhmethod = 0;  /* Always zip to 256 for sr20. HOUP */
    }
    else
    {
        rhmethod = 1;  /* enable reduced image size */
    }

    {
        int power;
        float temp;

        if (rhmethod == 1) {

            if (vrgfsamp == 1) {

                temp = (float)opxres;
                power = 0;

                while (temp > 1) {
                    temp /= 2.0;
                    ++power;
                }

                fft_xsize = (int)pow(2.0,(double)power);

                temp = (float)opyres;
                power = 0;

                while (temp > 1) {
                    temp /= 2.0;
                    ++power;
                }

                fft_ysize = (int)pow(2.0,(double)power);

                image_size = IMax(2, fft_xsize, fft_ysize);
                fft_xsize = image_size;
                fft_ysize = image_size;

                rhrcxres = fft_xsize;
                rhrcyres = fft_ysize;
                rhimsize = image_size;

            } else {   /* non-VRGF */

                temp = (float)rhdaxres;
                power = 0;

                while (temp > 1) {
                    temp /= 2.0;
                    ++power;
                }

                fft_xsize = (int)pow(2.0,(double)power);

                temp = (float)opyres;
                power = 0;

                while (temp > 1) {
                    temp /= 2.0;
                    ++power;
                }

                fft_ysize = (int)pow(2.0,(double)power);

                image_size = IMax(2, fft_xsize, fft_ysize);
                fft_xsize = image_size;
                fft_ysize = image_size;

                rhrcxres = fft_xsize;
                rhrcyres = fft_ysize;
                rhimsize = image_size;
            }	

        } else {   /* rhmethod == 0 Image = 256x256  or 512x512 */

            if(opxres<=256)fft_xsize=256;
            if(opxres>256)fft_xsize=512;

            if(eg_phaseres<=256)fft_ysize=256;
            if(eg_phaseres>256)fft_ysize=512;

            image_size  = IMax(2,fft_xsize,fft_ysize);
            fft_xsize = image_size;
            fft_ysize = image_size;

            rhrcxres = image_size;
            rhrcyres = image_size;
            rhimsize = image_size;
        }

    	/* granty edit turns of default interpolation */
    	rhimsize = opxres;
    	rhrcxres = opxres;
    	rhrcyres = opyres;

        /* number of points to exclude, beginning and end, for phase correction */
        rhpcdiscbeg = (fft_xsize*(100.0 - pckeeppct)/100.0)/2.0;
        rhpcdiscbeg = IMax(2, rhpcdiscbeg, 2);
        rhpcdiscend = rhpcdiscbeg;

        /* BJM: set discard pts = 0 */
        if(rhref == 2 || rhref == 5)
        {
            rhpcdiscbeg = 0;
            rhpcdiscend = 0;
        }
    }

    rhpcdiscmid = 0;

    /* number of interleaves to acquire for phase correction (ref) */
    if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY)
        rhpcileave = 0;   /* collect them all */
    else
        rhpcileave = 0;   /* collect 1 only and interpolate */

    if (fract_ky == PSD_FRACT_KY)
        cvmax(rhpcbestky, rhnframes+rhhnover+1);
    else
        cvmax(rhpcbestky, rhnframes+1);

    if (exist(oppseq) == PSD_SE) {   /* spin echo - best line coincident
                                        w/ Hahn echo */
        if (fract_ky == PSD_FULL_KY && ky_dir == PSD_TOP_DOWN) {
            rhpcbestky = (float)(rhnframes+1)/2.0 + ky_offset;
        } else if (fract_ky == PSD_FULL_KY && ky_dir == PSD_BOTTOM_UP) {
            rhpcbestky = (float)(rhnframes+1)/2.0 - ky_offset;
        } else if (fract_ky == PSD_FRACT_KY || ky_dir == PSD_BOTTOM_UP) {
            rhpcbestky = (float)(2*rhnframes+1)/2.0 - ky_offset;
        } else if (fract_ky == PSD_FULL_KY || ky_dir == PSD_CENTER_OUT) {
            rhpcbestky = (float)(rhnframes+1)/2.0;
        }
    } else {                  /* gradient echo - best line is 1st in time */
        if (fract_ky == PSD_FULL_KY && ky_dir == PSD_TOP_DOWN) {
            rhpcbestky = ( 1.0  + (float)(rhnframes + 1)/2.0 )/2.0;          
        } else if (fract_ky == PSD_FULL_KY && ky_dir == PSD_BOTTOM_UP) {
            rhpcbestky = ( (float)rhnframes  + (float)(rhnframes + 1)/2.0 )/2.0;
        } else if (fract_ky == PSD_FRACT_KY || ky_dir == PSD_BOTTOM_UP) {
            rhpcbestky = rhnframes;
        } else if (fract_ky == PSD_FULL_KY || ky_dir == PSD_CENTER_OUT) {
            rhpcbestky = (float)(rhnframes+1)/2.0;
        }
    }

    if (fract_ky == PSD_FRACT_KY) {
        switch (ky_dir) {
        case PSD_TOP_DOWN:
            rhhdbestky = opyres/2 + ky_offset;
            break;
        case PSD_BOTTOM_UP:
            rhhdbestky = opyres/2 - ky_offset;
            break;
        case PSD_CENTER_OUT:
        default:
            rhhdbestky = 0;
            break;
        }
    }

    cvrefindex1 = opnshots;

    /* Value1.5T May 2005 KK */
    if(ghost_check == 1) {
      rhpccon = 0;
      rhpclin = 0;
    }
    else if(ghost_check == 2){
      rhpccon = 1;
      rhpclin = 1;
    }

    /* Coil Selection */
    cvmax(rhpccoil, (INT)((cfrecvend - cfrecvst)+1));
    cvmin(rhpccoil, (INT)(-1));

    {
        INT numcoils = ((cfrecvend - cfrecvst)+1);

        /* BJM: use coil #4 for phase correcion with 8 channel */
        /* head coil */
        /* 11.0 update - use all coils, rhpccoil = 0 */

        if(numcoils > 1)
            rhpccoil = 0; /* (INT)(numcoils)/2.0; */
        else
            rhpccoil = 1;

        /* MRIge91081 - disable ref scan per coil for Asset */
        /* asset = 2 for scans, 1 for calibration */
        if(exist(opasset) == 2) { 

            char attribute_codeMeaning[ATTRIBUTE_RESULT_SIZE] = "";
            getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CODE_MEANING, attribute_codeMeaning);

            if ((cffield == B0_30000) &&
                (isCategoryMatchForAnatomy(exist(opanatomy), ATTRIBUTE_CATEGORY_CHEST)
                 && strstr(attribute_codeMeaning, "Breast")))
            {
                rhpccoil = 0;
            }
            else
            {
                rhpccoil = (INT)(-1);
            }
        }
    }

    if (pc_enh == PSD_ON)
    {
        char * coil_name = coilInfo[0].coilName;
        char attribute_codeMeaning[ATTRIBUTE_RESULT_SIZE] = "";
        getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CODE_MEANING, attribute_codeMeaning);

        rhpccoil = 0;
        if (1 == intleaves)
        {
            rhpcctrl |= (RHPCCTRL_NN_WEIGHT | RHPCCTRL_CON_ALIGN);
        }
        else
        {
			/* Enable phase alignment feature for MUSE */
			if (muse_flag) 
			{
				rhpcctrl |= (RHPCCTRL_NN_WEIGHT | RHPCCTRL_CON_ALIGN);	
			}
			else 
            {
                /*The phase alignment feature, RHPCCTRL_CON_ALIGN, does not work with multi-shot EPI*/
                rhpcctrl |= RHPCCTRL_NN_WEIGHT;
            }
        }

        /* Enable PC estimation after view projection for Breast and Neck coils */
        if (isCategoryMatchForAnatomy(exist(opanatomy), ATTRIBUTE_CATEGORY_CHEST)
             && strstr(attribute_codeMeaning, "Breast"))
        {
            rhpcctrl |= RHPCCTRL_NN_PROJ;
        }
        else if ((PSD_VRMW_COIL == cfgcoiltype) &&
                 ((strstr(coil_name, "Spine 18 1") != NULL) ||
                  (strstr(coil_name, "Neck Spine 32") != NULL) ||
                  (strstr(coil_name, "Neck Chest 32 AA") != NULL)))
        {
            rhpcctrl |= RHPCCTRL_NN_PROJ;
        }

        if(hopc_flag == PSD_ON)
        {
            rhpcctrl |= RHPCCTRL_NN_POLYFITTING;
        }
    }

    if (ref_volrecvcoil_flag == PSD_ON)
    {
        rhpccoil = 1;
    }

    /* Turn on constant and linear phase correction */
    rhpccon = PSD_ON;
    rhpclin = PSD_ON;

    /* for single-shot ref scan, minimum fit orders are 1 */
    if ( rhpcileave > 0 ) {
        cvmod(rhpcconorder, 1, 4, 2, "Constant fit order: 0=vu spcfc;1=Kybest;2=line;3,4=poly",0," ");
        cvmod(rhpclinorder, 1, 4, 2, "Constant fit order: 0=vu spcfc;1=Kybest;2=line;3,4=poly",0," ");
    }
    else {
        cvmod(rhpcconorder, 0, 4, 2, "Linear fit order: 0=vu spcfc;1=Kybest;2=line;3,4=poly",0," ");
        cvmod(rhpclinorder, 0, 4, 2, "Linear fit order: 0=vu spcfc;1=Kybest;2=line;3,4=poly",0," ");
    }

    cvmax(rhpcshotfirst, intleaves-1);
    rhpcshotfirst = 0;
    cvmin(rhpcshotlast, rhpcshotfirst);
    cvmax(rhpcshotlast, intleaves - 1);
    rhpcshotlast = intleaves - 1;

    /* set con and lin orders: 0=vu spcfc, 1=kybest, 2=line, 3,4=poly */
    rhpcconorder = 2;
    rhpclinorder = 0;

    /* set con and lin #pts */
    cvmax(rhpcconnpts, 4);
    cvmax(rhpclinnpts, 4);
    rhpcconnpts = 4;
    if (etl > 3) {
        while (rhpcconnpts > etl/2) {
            rhpcconnpts = rhpcconnpts - 1;
        }
        cvmax(rhpcconnpts, etl/2);
    } 
    else {
        rhpcconorder = 1;
    }

    if (etl>3) {
        rhpclinnpts = IMin(2, 4, etl/2);
        cvmax(rhpclinnpts, etl/2);
    }
    else {
        rhpclinnpts = 3; /* value does not matter */
        rhpclinorder = 0;
    }

    if ( (etl == 1) ) {
        rhpccon = 0;
        rhpclin = 0;
        rhpcconorder = 1;
        rhpclinorder = 0;
    }

    /* HCSDM00153103, HCSDM00159442 */
    if (PSD_ON == calc_rate)
    {
        rhpccon = 0;
        rhpclin = 0;
    }

    /* Refless EPI */
    if ((exist(opdiffuse) == PSD_ON) && (ref_in_scan_flag == PSD_ON))
    {
        rhpclin = 0;
        rhpccon = 0;
    }

    if ((TX_COIL_BODY == getTxCoilType()) && (RX_COIL_LOCAL == getRxCoilType()))
    {
        rhpclinnorm = 1;
        rhpcconnorm = 1;
    }
    else
    {
        rhpclinnorm = 0;
        rhpcconnorm = 0;
    }

    rhpclinfitwt = 0;
    cvmax(rhpclinfitwt, 0);
    rhpclinavg = 0;

    cvmax(rhpcthrespts, 32);

    rhpcconfitwt = 0;
    cvmax(rhpcconfitwt, 0);

    final_xres = exist(opxres);
    rhvrgfxres = final_xres;
    rhvrgf = vrgfsamp;

    rhdab0s = cfrecvst;
    rhdab0e = cfrecvend;

    if (rawdata == PSD_ON)
        rhrawsize = 2*slquant1*(1+rhbline+rhnframes+rhhnover+iref_frames)*2
            *rhptsize*nex*rhfrsize;
    else
        rhrawsize = (n64)slquant1 * (n64)rhfrsize * (n64)(2*rhptsize)
            * (n64)ceil((float)(1 + rhnframes + rhhnover+iref_frames));

    /* update size variables for DW-EPI */
    rhrawsize *= reps*exist(opphases);
    rhnslices = exist(opslquant)*exist(opphases)*dwi_fphases;

    /* BJM - for multi-nex DW-EPI */
    if(opdiffuse == PSD_ON)
    {
       if(nex > 1 && tensor_flag == PSD_OFF)
       {
           rhnecho = nex;
           pinecho = 1;
           rhrawsize *= nex;
       }
       else if(tensor_flag == PSD_ON)
       {
           rhnecho = nex;
           pinecho = 1;
           rhrawsize *= nex;
       }
    }

    if ((rhdab0e - rhdab0s) == 0) {
        rhtype1 = rhtype1 & ~RHTYP1AUTOPASS;  /* clear automatic scan/pass detection bit */
    }

    /* Tell TARDIS there is a hyperscan dab packet and to use HRECON. */
    if (hsdab > 0)
        rhformat = rhformat | 64;

    /* Turn on row-flipping */
    rhformat = rhformat | 2048;

    /* Turn off image compression */
    rhrcctrl = RHRCMAG + rawmode*RHRCRAW;
    
    if(rpg_flag > 0)
    {
        /* Other Distortion Correction  options include:  RH_DIST_CORR_RIGID, RH_DIST_OUTPUT_REVERSET2 */
        rhdistcorr_ctrl = RH_DIST_CORR_B0 + (rpg_in_scan_flag?RH_DIST_CORR_RPG:0) + RH_DIST_CORR_AFFINE; 
	/* granty edit force save of reverse polarity B0 images 7/2/2018 */
	rhdistcorr_ctrl = 29;
    }
    else
    {
        rhdistcorr_ctrl = 0;
    }
    /* Fill in Image/DICOM Header for Distortion Correction */
    ihdistcorr = rhdistcorr_ctrl;   /* Add to DICOM tag (0043,10B3) */
    ihpepolar = pepolar;            /* Updates DICOM tag (0018,9034) */

    /* use zero-filling if CV5 is zero */
    if ( (PSD_OFF == (int)opuser5 ) && (PSD_ON == exist(opdiffuse)) )
    {
        rhtype &= ~RHTYPFRACTNEX;
    }

    dc_chop = (muse_flag) ? 0 : 1; 

    if (dc_chop == 1) {
        rhtype = rhtype & ~RHTYPCHP;  /* clear chopper bit */
        rhblank = blank;
    } else {
        rhtype = rhtype | RHTYPCHP;   /* set chopper bit */
        rhblank = 0;
    }

    /* number of points to blank on display */
    if (image_size < 256)
        rhblank = (4*image_size)/256;

    /* fermi filter control - different for epi due to vrgf */
    rhfermr = exist(opxres)/2;

    if (!strncmp("epi2wwwl",get_psd_name(),8))
    {
        cvoverride(rhnew_wnd_level_flag, 1, PSD_FIX_ON, PSD_EXIST_ON);
    }

    /* split predownlaod into two modules so gcc assembler can process */
    if (predownload1()==FAILURE) {
        return FAILURE;
    }
    /* BJM call exact b-value calcs and scaling */
    if ( FAILURE == DTI_Predownload() ) {
        return FAILURE;
    } 

    /* Focus RFOV HCSDM00150820 */
    if ((PSD_ON == opdiffuse) && rfov_flag && rfov_cmplx_avg_flag && (nex > 1))
    {
        rhtype1 = rhtype1 & ~RHTYP1IMGNEX;      /* Turn off usual mag image nex */
        rhtype1 = rhtype1 | RHTYP1CMPLXIMGNEX;  /* Bit mask for Complex Averaging */
    }
    else
    {
        rhtype1 = rhtype1 & ~RHTYP1CMPLXIMGNEX; /* Make sure Complex Averaging is off */
    }

    if((rhtype1 & RHTYP1CMPLXIMGNEX) && (1 == oepf))
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG,
                    "Complex Averaging", STRING_ARG, "Phase Encoding Flip" );
        return FAILURE;
    }

    /* Set pulse parameters */
    if ( FAILURE == calcPulseParams(AVERAGE_POWER) )
    {
        return FAILURE;
    }

    /* Set the amps back that are scaled within calcPulseParams function */
    if((PSD_ON == gradHeatMethod) && (PSD_ON == derate_amp)) 
    {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            ia_gxdl = (int)(a_gxdl * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr = (int)(a_gxdr * (float)max_pg_iamp / loggrd.tx);
            
            ia_gydl = (int)(a_gydl * (float)max_pg_iamp / loggrd.ty);
            ia_gydr = (int)(a_gydr * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl = (int)(a_gzdl * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr = (int)(a_gzdr * (float)max_pg_iamp / loggrd.tz);
	    if(ftde_flag == PSD_ON){ /*granty edit for full time diffusion encoding option */
            	ia_gxde = (int)(a_gxde * (float)max_pg_iamp / loggrd.tx);

            	ia_gyde = (int)(a_gyde * (float)max_pg_iamp / loggrd.ty);

            	ia_gzde = (int)(a_gzde * (float)max_pg_iamp / loggrd.tz);
	    }
        } 
        else 
        {
            ia_gxdl1 = (int)(a_gxdl1 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr1 = (int)(a_gxdr1 * (float)max_pg_iamp / loggrd.tx);
        
            ia_gxdl2 = (int)(a_gxdl2 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr2 = (int)(a_gxdr2 * (float)max_pg_iamp / loggrd.tx);

            ia_gydl1 = (int)(a_gydl1 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr1 = (int)(a_gydr1 * (float)max_pg_iamp / loggrd.ty);
            
            ia_gydl2 = (int)(a_gydl2 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr2 = (int)(a_gydr2 * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl1 = (int)(a_gzdl1 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr1 = (int)(a_gzdr1 * (float)max_pg_iamp / loggrd.tz);
            
            ia_gzdl2 = (int)(a_gzdl2 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr2 = (int)(a_gzdr2 * (float)max_pg_iamp / loggrd.tz);  
        }
    }

    /* set up tensor orientations */
    if ( FAILURE == set_tensor_orientations() ){
        return FAILURE;
    }  

    if (ss_fa_scaling_flag)
    {
        override_fatsat_high_weight = PSD_ON;
    }
    else
    {
        override_fatsat_high_weight = PSD_OFF;
    }

    if (PSD_OFF == override_fatsat_high_weight)
    {
        if ((opweight > BIG_PATIENT_WEIGHT) && (ss_rf1 == PSD_ON))
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_IMGOPT_PSD1, EE_ARGS(2), STRING_ARG, "SPSP RF (Chem Sat=None/water)", STRING_ARG, "high pat. weight (>160kg) for EPI" ); 
            return FAILURE;
        }
    }

#ifndef SIM
    if(exist(opdiffuse) == PSD_ON && opdifnumt2 == 0 && ADC_warning_flag == PSD_ON)
    {
        int bval_different = PSD_OFF;
        for(i=1; i<opnumbvals; i++)
        {
            if(!floatsAlmostEqualEpsilons(bvalstab[i], bvalstab[0], 2))
            {
                bval_different = PSD_ON;
                break;
            }
        }
        if(bval_different == PSD_OFF)
        {
            epic_warning( "At least two distinctive b-values are needed to create an ADC map");
            ADC_warning_flag = PSD_OFF;
        }
    }

    if (bigpat_warning_flag == PSD_ON)
    {
        if (((flip_rf1 < opflip) && (ss_rf1 == PSD_ON)) || 
            ((ir_fa_scaling_flag == PSD_ON) && (ir_on == PSD_ON) && (flip_rf0 < 180.0)))
        {
            epic_warning( "Image quality may be degraded due to reduced flip angles at high patient weights" );
            bigpat_warning_flag = PSD_OFF;
        }
    }

    /*multiband band gap warning*/
    if (mux_band_gap_warning_flag == PSD_ON)
    {
        if(mux_flag && (mux_slice_shift_mm_rf1<30)){
            epic_warning( "Image quality may be degraded if HyperBand spacing less than 30mm for certain coils. Please consider to increase slice thickness, spacing or number of slices." );
        }
        mux_band_gap_warning_flag = PSD_OFF;
    }

#endif

    for (i=0; i<opnumbvals; i++)
    {
        difnextab_rsp[i] = (int)difnextab[i];
    }

    if (opdfax3in1 > PSD_OFF || opdfaxtetra > PSD_OFF || (opdfaxall > PSD_OFF && gradopt_diffall == PSD_ON))
    {
         invertCrusherXY = PSD_ON; 
         invertSliceSelectZ2 = PSD_OFF;
    }
    else
    {
         invertCrusherXY = PSD_OFF; 
         invertSliceSelectZ2 = PSD_ON;
    }

    if ((1 == global_shim_method) && oppscvquant)
    {
        pidoshim = PSD_CONTROL_PSC_SPECIAL;
    }

    /*RTB0 correction*/
    if(rtb0_flag)
    {
        rtb0Init();
    }

    if (PSD_ON == t1flair_flag)
    {
        act_slquant1 = slquant1 - dummyslices - 2*act_edge_slice_enh_flag;

    }
    else
    {
        act_slquant1 = slquant1;
    }

    for(i=0;i<opslquant; i++)
    {
        int slmod_acqs = opslquant%acqs;
        if((data_acq_order[i].slpass < slmod_acqs) || (slmod_acqs == 0))
        {
            slloc2sltime[data_acq_order[i].slloc] = 
                data_acq_order[i].slpass*act_slquant1+data_acq_order[i].sltime;
            sltime2slloc[data_acq_order[i].slpass*act_slquant1+data_acq_order[i].sltime] = 
                data_acq_order[i].slloc;
        }
        else
        {
            slloc2sltime[data_acq_order[i].slloc] = 
                data_acq_order[i].slpass*(act_slquant1-1)+slmod_acqs+data_acq_order[i].sltime;
            sltime2slloc[data_acq_order[i].slpass*(act_slquant1-1)+slmod_acqs+data_acq_order[i].sltime] = 
                data_acq_order[i].slloc;
        }
    }


    /*RTB0 Correction: convert sltime2slloc to float, such that weighted_polyfit function can take it*/
    if (rtb0_flag){
        intarr2float(f_sltime2slloc, sltime2slloc, opslquant); /*convert from int array to float array*/
    }

    /* scale Flip Angles for non-Multiband here */
    /* PURE Mix */
    if ((PURE2 == exist(oppure)) && pure_mix.enable && (PSD_OFF == mux_flag))
    {
        if (90.0*pure_mix_tx_scale < flip_rf1)
        {
            ia_rf1 = (int)(pure_mix_tx_scale*ia_rf1*90.0/flip_rf1);
        }
        if (PSD_SE == oppseq)
        {
            ia_rf2 = (int)(pure_mix_tx_scale*ia_rf2);
        }
    }
    /* HCSDM00129469: Shading has been observed at the center of brain due to overtipping.
       The software mitigation is to reduce the flip angles of rf1 and rf2 equivalent to TG
       reduced by #counts of TGenh (default as 5.5, HCSDM00168896) */
    else if (TGenh < 0)
    {
        ia_rf1 = (int)(ia_rf1*pow(10.0, (double)(TGenh/200.0)));
        if(PSD_SE == oppseq)
        {
            ia_rf2 = (int)(ia_rf2*pow(10.0, (double)(TGenh/200.0)));
        }
    }

    /* Multiband */
    if(mux_flag)
    {
        rhmb_factor = exist(opaccel_mb_stride);
        if (use_slice_fov_shift_blips)
        {
            if ( ((INT)exist(opaccel_mb_stride) * (INT)exist(opaccel_ph_stride)%slice_fov_shift) && (PSD_ON == mux_flag))
            {
                epic_error(use_ermes, "%s is incompatible with %s", EM_PSD_INCOMPATIBLE,
                           EE_ARGS(2), STRING_ARG, "Slice FOV Shift Factor",STRING_ARG, "HyperBand Factor");
                return FAILURE;
            }
            rhmb_slice_fov_shift_factor = slice_fov_shift;
        }
        else{
            rhmb_slice_fov_shift_factor = 1;
        }
    }
    else
    {
        rhmb_factor = 1;
        rhmb_slice_fov_shift_factor = 1;
    }

@inline loadrheader.e rheaderpredownload

    /* Call acoustic model */
    enable_acoustic_model = isAcousticDataAvailable();
    if( enable_acoustic_model && (PSD_OFF == oploadprotocol) )
    {
        int min_acoustic; // Temporary variable, not used in any calculation
        enforce_minseqseg = 1;
        seqEntryIndex = idx_seqcore;
        acoustic_seq_repeat_time = (int)(act_tr/((mux_flag)?mux_slquant:slquant1));

        if( FAILURE == minseq(&min_acoustic, gradx, GX_FREE, grady, GY_FREE, gradz, GZ_FREE, &loggrd, seqEntryIndex,
                    tsamp,act_tr, use_ermes, seg_debug) )
        {
            epic_error(use_ermes, "%s failed.",
                    EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "minseq for acoustic");
            enforce_minseqseg = 0;
            enable_acoustic_model = 0;
            return FAILURE;
        }
        enforce_minseqseg = 0;
        enable_acoustic_model = 0;
    }

    return SUCCESS;
}   /* end predownload() */

STATUS
predownload1( void )
{
    int i;
    float t_array[7];                     /* timing parametrers for DW-EPI sequence */
    int xfull,yfull,zfull;

    xfull=max_pg_iamp;
    yfull=max_pg_iamp;
    zfull=max_pg_iamp;

    /* Prescan Slice Calc **********************/

    if (prescanslice(&pre_pass, &pre_slice, opslquant) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "prescanslice" );
        return FAILURE;
    }

    aps2_rspslqb = 0;
    aps2_rspslq =  mux_flag?mux_slquant:slquant1;

    /* Find the corresponding spacial slice/pass for the prescan/center slice location */
    {
        int savei = 0;

        for (i = 0; i < opphases*opslquant; i++) {
            if (data_acq_order[i].sltime == pre_slice) {
                savei = i;
                i = opphases*opslquant;
            }
        }

        if ( (mph_flag==PSD_ON) && (acqmode==1) ) {  /* multi-phase sequential */
            for (i = 0; i < reps*opphases*opslquant; i++) {
                if (data_acq_order[i].slpass == pre_pass) {
                    savei = i;
                    i = reps*opphases*opslquant;
                }
            }
        }

        slice_num = savei + 1;
    }

    rhpctemporal = 1;         /* use first temporal position */

    if (opdiffuse == PSD_ON && floatsAlmostEqualEpsilons(opuser14, 1.0, 2)) 
    {
        /* Use rhpctemporal = 0 - one ref for each temporal position  - for Diffusion */
        /* Use center slice only for ref scan to cut down on reference scan time */
        rhpctemporal = 0;
        ref_mode = 1;
    }
    else 
    {
        rhpctemporal = 1;         /* use first temporal position */
        ref_mode = 1;   /* loop to center slice */
    }

    rhpclinorder = 2; /* lin fit */ 

    /* mph, seq, play 1 rep */
    if ( (mph_flag==PSD_ON) && (acqmode==1) && (rhpctemporal==1) )
        slice_num = data_acq_order[slice_num-1].slpass + 1;

    /* Figure out rhpcpspacial given opuser value.           
     * Spacial phase correction (rhpcspacial) is only 
     * compatible with constant in-plane shift on each slice */
    if (((vol_shift_type & VOL_SHIFT_FREQ_DIR_ALLOWED) || 
         (vol_shift_type & VOL_SHIFT_PHASE_DIR_ALLOWED)) &&
         (vol_shift_constraint_type == VOL_SHIFT_CONSTRAINT_NONE))
    {
        rhpcspacial = 0;
    }
    else if(exist(refSliceNum) != -1 && exist(refSliceNum) > 0) {

        /* Is ref slice in a valid prescription range */
        if(existcv(opslquant) && exist(opslquant) >= exist(refSliceNum)) {
            /* Figure out temporal position of desired ref slice (interleaved order) */
            /* the slice prescribed is in terms of the spatial order.  This converts */
            /* the spatial index to the temporal position in the pass.               */
            /* Note: the must subtract 1 since slice index starts @ 0!               */

            rhpcspacial = (INT)(data_acq_order[(INT)(exist(refSliceNum)-1)].sltime + 1);
            pre_slice =  rhpcspacial - 1;
        } else {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "predownload: Error!: Ref Scan Slice Index > number of slices" );
            return FAILURE;
        }

        if( exist(refSliceNum) != -1 && acqs > 1) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "predownload: Error!: refSliceNum != -1 & acqs > 1 not compatible" );
            return FAILURE;
        }

    } else {
        /* MRIhc19933 */
        /* One ref for all, using prescan slice */
        rhpcspacial = 0;            /* use all slices */

        if ( (mph_flag==PSD_ON) && (acqmode==1) ) /* multi-phase sequential */
        {
            rhpcspacial = 1;
        }    
    }

    rhpcspacial_dynamic = rhpcspacial;

    /* set rhscnframe and rhpasframe */
    if(exist(opdiffuse) != PSD_ON)
    {
        if (acqmode == 0) {   /* interleaved */
            rhscnframe = rhnslices*(opnex*(rhnframes+rhhnover) + baseline);
            rhpasframe = slquant1*(opnex*(rhnframes+rhhnover) + baseline);
        } else if (acqmode == 1) {  /* sequential */
            rhscnframe = rhnslices*(opnex*(rhnframes+rhhnover) + baseline);
            rhpasframe = reps*(opnex*(rhnframes+rhhnover) + baseline);
        }
    }
    else
    {
        if (acqmode == 0) {   /* interleaved */
            rhscnframe = rhnslices*(max_nex*(rhnframes+rhhnover) + baseline);
            rhpasframe = slquant1*(max_nex*(rhnframes+rhhnover) + baseline);
        } else if (acqmode == 1) {  /* sequential */
            rhscnframe = rhnslices*(max_nex*(rhnframes+rhhnover) + baseline);
            rhpasframe = reps*(max_nex*(rhnframes+rhhnover) + baseline);
        }
    }
    

    if ( rhpcspacial == 0 ) 
        ref_mode = 0;
    else
        ref_mode = 1; /* loop to the center slice */

    /* Refless EPI */
    if (ref_in_scan_flag == PSD_ON)
    {
        if (ref_mode != 0)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Integrated Reference Scan", STRING_ARG, "ref_mode != 0" );
            return FAILURE;
        }

        if (rhpctemporal != 1)
        {
            epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "Integrated Reference Scan", STRING_ARG, "rhpctemporal != 1" );
            return FAILURE;
        }
    }
    else
    {
        if (rhref == 5)
        {
            epic_error( use_ermes, "%s is out of range.", EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "rhref" );
            return FAILURE;
        }
    }

    if (rhpcileave == 0)
        refnframes = rhnframes;
    else
        refnframes = rhnframes/intleaves;

    /* set rhrefframes and rhrefframep */
    if (ref_mode == 0) {  /* excite all slices in ref scan */
        if (acqmode == 0) {   /* interleaved */
            if (rhpctemporal == 0)
                rhrefframes = rhnslices*(refnframes+rhhnover+baseline);
            else
                rhrefframes = (rhnslices/reps)*(refnframes+rhhnover+baseline);
            rhrefframep = slquant1*((refnframes+rhhnover) + baseline);
        } else if (acqmode == 1) {  /* sequential */
            if (rhpctemporal == 0)
                rhrefframes = rhnslices*((refnframes+rhhnover) + baseline);
            else
                rhrefframes = (rhnslices/reps)*((refnframes+rhhnover) + baseline);
            rhrefframep = reps*((refnframes+rhhnover) + baseline);
        }
    }
    else if (ref_mode == 1) {  /* loop to center slice in ref scan */
        if (acqmode == 0) {   /* interleaved */
            rhrefframes = (pre_slice+1)*((refnframes+rhhnover) + baseline);
            rhrefframep = (pre_slice+1)*((refnframes+rhhnover) + baseline);
        } else if (acqmode == 1) {  /* sequential */
            rhrefframes = (pre_pass+1)*((refnframes+rhhnover) + baseline);
            rhrefframep = reps*((refnframes+rhhnover) + baseline);
        }
    }
    else if (ref_mode == 2) {  /* excite center slice only in ref scan */
        if (acqmode == 0) {   /* interleaved */
            rhrefframes = reps*((refnframes+rhhnover) + baseline);
            rhrefframep = reps*((refnframes+rhhnover) + baseline);
        } else if (acqmode == 1) {  /* sequential */
            rhrefframes = ((refnframes+rhhnover) + baseline);
            rhrefframep =((refnframes+rhhnover) + baseline);
        }
    }
    else {
        epic_error( use_ermes, "invalid ref_mode value, use 0, 1, or 2.", EM_PSD_REF_MODE_ERROR, EE_ARGS(0) );
        return FAILURE;
    }

    /* *******************************
       Entry Point Table Evaluation
       ******************************* */

    if (entrytabinit(entry_point_table, (int)ENTRY_POINT_MAX) == FAILURE)
        return FAILURE;

    /* Scan entry point */
    strcpy(entry_point_table[L_SCAN].epname, "scan");

    /* Set xmtadd according to maximum B1 and rescale for powermon,
       adding additional (audio) scaling if xmtadd is too big. 
       Add in coilatten, too. */
    xmtaddScan = -200*log10(maxB1[L_SCAN]/maxB1Seq) + getCoilAtten(); 
    
    if (xmtaddScan > cfdbmax) {
        extraScale = (float) pow(10.0, (cfdbmax - xmtaddScan)/200.0);
        xmtaddScan = cfdbmax;
    } else {
        extraScale = 1.0;
    }

    if (setScale(L_SCAN, RF_FREE, rfpulse, maxB1[L_SCAN], 
                 extraScale) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "setScale" );
        return FAILURE;
    }

    entry_point_table[L_SCAN].epxmtadd = (short) rint((double)xmtaddScan);

    if (cs_sat == PSD_ON)
        rfpulse[RFCSSAT_SLOT].num = 1;

    /* MRIge75651 */
    if (powermon(&entry_point_table[L_SCAN], L_SCAN, (int)RF_FREE,
                         rfpulse, (int)(act_tr/((mux_flag)?mux_slquant:slquant1))) == FAILURE)
        return FAILURE;

    /*multiband*/
    if (FAILURE == Monitor_Predownload( rfpulse, entry_point_table, (int)RF_FREE, (int)(act_tr/((mux_flag)?mux_slquant:slquant1)),
                                        &monave_sar, &moncave_sar, &monpeak_sar ))
    {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                   STRING_ARG, "Monitor_Predownload");
        return FAILURE;
    }

    entry_point_table[L_SCAN].epfilter = (unsigned char)echo1_filt.fslot;
    entry_point_table[L_SCAN].epprexres = rhfrsize;
    entry_point_table[L_SCAN].epstartrec = rhdab0s;
    entry_point_table[L_SCAN].ependrec = rhdab0e;
    entry_point_table[L_SCAN].epfastrec = fast_rec;

    /* Now copy into APS2, MPS2, REF */
    entry_point_table[L_APS2] = entry_point_table[L_MPS2] =
        entry_point_table[L_REF] = entry_point_table[L_SCAN];

    strcpy(entry_point_table[L_MPS2].epname, "mps2");
    strcpy(entry_point_table[L_APS2].epname, "aps2");
    strcpy(entry_point_table[L_REF].epname, "ref");


    /* Calculate per unit (1 G/cm), per axis contribution to delta gradient and frequency
       and set HOEC rh- and ih- CVs */
@inline HoecCorr.e HoecCalcCorrectionPredownload

    /* Compute offsets due to linear EC */
    if((opdiffuse==PSD_ON) && (dwicntrl==1) && (hoecc_flag==PSD_OFF))  /* do not use linear correction if HOECC is on */
    {
        dwicorrcal(dwigcor, dwibcor, dwikcor, dwicntrl, dwidebug, rsprot_unscaled, xfull, yfull, zfull, t_array);  /* Note: t_array is set in HoecCalcCorrectionPredownload */
    }

    /* Prescan echos.  Collect 2 frames for MPS2.  Frames 1 & 2 are */
    /* subtracted and added together and each result is displayed in */
    /* the prescan windows */
    etot = 2;  

    if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FRACT_KY) {
        emid = num_overscan/intleaves - 1;
        emid += ky_offset/intleaves;
    } else if (ky_dir == PSD_CENTER_OUT && fract_ky == PSD_FULL_KY) {
        emid = 0;
    } else if ((ky_dir==PSD_TOP_DOWN || ky_dir==PSD_BOTTOM_UP) &&
               fract_ky == PSD_FULL_KY) {
        emid = (etl-1)/2;
        emid += ky_offset/intleaves;
    }
    else if ((ky_dir==PSD_TOP_DOWN || ky_dir==PSD_BOTTOM_UP) &&
             fract_ky == PSD_FRACT_KY) {
        emid = num_overscan/intleaves - 1;
        emid += ky_offset/intleaves;
    }
    else{
        emid = 0;
    }

    /* First echo in train to send to MPS2 */
    if (exist(oppseq) == PSD_SE) {
        /* spin echo epi */
        e1st = emid - etot / 2;
    } else if (exist(oppseq) == PSD_GE) {
        /* gradient echo epi */
        e1st = 0;
    } else {
        /* default */
        e1st = 0;
    }

    /* check for negative values */
    emid = ((emid < 0) ? 0 : emid);
    e1st = ((e1st < 0) ? 0 : e1st);

    entry_point_table[L_MPS2].epprexres = rhfrsize;
    entry_point_table[L_APS2].epprexres = rhfrsize;

    if (debug_scan) {
        psd_dump_scan_info();
        psd_dump_rsp_info();
    } 

    /* *****************************
       Auto Prescan Init

       Inform Auto Prescan about
       prescan parameters.
       *************************** */

    pitr = prescan1_tr; /* first pass prescan TR */
    pichop = 0; /* no chop for APS */
    picalmode = 0;
    pislquant = etot*slquant1;  /*Number of slices in 2nd pass prescan*/ 

    /* Must be called before first setfilter() call in predownload */
    initfilter();

    if (setfilter( &echo1_filt, SCAN) == FAILURE) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "setfilter" );
        return FAILURE;
    } 

@inline Monitor.e MonitorFilter

    /* set CV for EP_TRAIN macro */
    scanslot = echo1_filt.fslot;

    /*RTB0 correction*/
@inline RTB0.e RTB0Filter

@inline Prescan.e PSfilter
  
    rhfast_rec = 0;
    frtime = (float)((rhfrsize-1)*tsp);
    
    /* Open /usr/g/bin/vrgf.param and write out the VRGF parameters
       If auto mode, request that scan call the vrgf program */

    piforkvrgf = 0;
    if (vrgfsamp == PSD_ON) {
        if (genVRGF(&gradout,
                    (int)exist(opxres),
                    tsp,
                    a_gxw,
                    (float)(pw_gxwl + pw_gxw/2)/1.0e6,
                    (float)(pw_gxwad)/1.0e6,
                    2.0/(epiloggrd.xbeta + 1.0),
                    epiloggrd.xbeta) == FAILURE)
            return FAILURE;

        if (autovrgf == PSD_ON)
            piforkvrgf = 1;
    }
    
    /* Turn on/off bandpass asymmetry correction */
    if(PSDDVMR != psd_board_type) 
    { 
	if(((rhdab0e - rhdab0s + 1) > number_of_bc_files) || (value_system_flag)) 
	{
	   rhbp_corr = 0;  /* turn it off if the number of BC files */
        /* does not match the number of active receivers */
    	} 
	else 
    	{    
           rhbp_corr = 1;   /* else turn it on */
    	}
    }
    else
    {
	rhbp_corr = 0; /* MRIhc24730 : Bandpass asymmetry correction will */
                     /* not be applied for DVMR receive chain hardware*/
    } 

    /* Local Scope */
    {
        float delta_freq;  /* delta frequency (Hz) */
        float full_bw;     /* full bandwidth  (Hz) */
        float read_offset; /* readout offset (Hz) */

        full_bw = 1.0/(tsp*1.0e-6);
        delta_freq = full_bw/(float)rhfrsize;

        /*	read_offset = a_gxw * GAM * scan_info[0].oprloc / 10.0; */
        read_offset = 0.0;
        rhrecv_freq_s = -((float)rhfrsize*delta_freq/2.0 + read_offset) + 0.5;
        rhrecv_freq_e = (float)((rhfrsize-1)/2)*delta_freq + read_offset;
    }

    if (vrgfsamp == PSD_ON) {
        dacq_adjust = (float)pw_gxw/2.0 + (float)(pw_gxwad) -
            (float)(pw_gyba + pw_gyb + pw_gybd)/2.0 - tsp*((float)rhfrsize - 1.0)/2.0;
    } else {
        dacq_adjust = (float)pw_gxw/2.0 - tsp*((float)rhfrsize - 1.0)/2.0;
    }

    /* protect against negative adjustment */
    dacq_adjust = ((dacq_adjust < 0) ? 0 : dacq_adjust);

    /* Check for spacial spectral pulse offset error at end of
       predownload, so that the scan_info file will be properly set */
    if (ssCheck() ==FAILURE) return FAILURE;

#ifndef SIM
    /* compute interpolated time delays for phase-encode blip correction method */
    if ( FAILURE == blipcorrdel(&bc_delx, &bc_dely, &bc_delz, esp,
                                getTxCoilType(), debug_oblcorr) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1), STRING_ARG, "blipcorrdel" );
        return FAILURE;
    }
#endif

    /* Use volRec coil for Reference Scan */
    if ((ref_in_scan_flag == PSD_OFF) && (ref_volrecvcoil_flag == PSD_ON))
    {
        UpdateEntryTabRecCoil(&entry_point_table[L_REF], 0);
    }

    return SUCCESS;
}    /* end predownload1() */

/*
 *  calcPulseParams
 *  
 *  Type: Public Function
 *  
 *  Description:
 *    This function sets pulse widths and instruction amplitudes needed
 *    for pulse generation.
 */
STATUS
#ifdef __STDC__ 
calcPulseParams( int encode_mode )
#else /* !__STDC__ */
    calcPulseParams() 
#endif /* __STDC__ */
{
    /* Obl 3in1 opt */
    float log_incdifx_scaled = 0;
    float log_incdify_scaled = 0;
    float log_incdifz_scaled = 0;

    /* Include EPIC-generated code */
#include "predownload.in"

    /* MRIge59113 */
@inline Inversion_new.e InversionPredownload
@inline Prescan.e PSpredownload

     FILE *fp_grad = NULL;

    /*****************************
      Timing for SCAN entrypoint
    ****************************/
  
    /*************************************************************************
      pos_start marks the position of the start of the attack ramp of
      the gradient for the excitation pulse.  If Sat or other prep pulses
      are played before excitation, then the pos_start marker is incremented
      accordingly to account for the prep time.
      
      Because the rf unblank must be played at least -rfupa us prior to
      the excitation pulse, pos_start must allow enough space for this
      unblank if the attack of the ramp is not long enough.  Rather than
      arbitrarily making the attack pulse longer, the start position is
      adjusted and the attack ramp is optimized.
      
      Note also that rfupa is a negative number, so it is negated in
      the following calculation to make it a positive number.
    ************************************************************************/
    pos_start = RUP_GRD((int)tlead + GRAD_UPDATE_TIME);
    if ((pos_start + pw_gzrf1a) < -rfupa) {
        pos_start = RUP_GRD((int)(-rfupa - pw_gzrf1a + GRAD_UPDATE_TIME));
    }

    /*
      Ordering of pulse is for non cardiac:
      spatial sat, chemsat, 90 (180) readout and killer.

      For cardiac:
      90 (180) readout, spatial sat, chemsat, and killer
    */
    sp_satcard_loc = 0;

    if ( (existcv(opcgate)) && (exist(opcgate)==PSD_ON) )
    {
        /* Set some values for the scan clock */
        pidmode = PSD_CLOCK_CARDIAC; /* Display views  and clock */
        /*
           piclckcnt 
           piclckcnt is used is estimating the scan time remaining in
           a cardiac scan.  It is the number of cardiac triggers within
           an effective TR interval used by the PSD to initiate a 
           sequence after the initial  cardiac trigger 

           piviews
           piviews is used by the Tgt in cardiac scans to display the
           number of heart beat triggers the PSD will use 
           to complete a scan 

           trigger_time
           Amount of time to leave for the cardiac trigger.
         */

        ctlend = IMax( 2, (int)GRAD_UPDATE_TIME, RDN_GRD(psd_tseq - tmin - time_ssi) );
        if (opphases  > 1) 
        {
            piviews = nreps; /* used by the Tgt in cardiac scans to display the
                                number of heart beat triggers the PSD will use 
                                to complete a scan */
            piclckcnt = 0;
            trigger_time =  RDN_GRD((int)( 0.01 * oparr * (60.0/ophrate) *
                        1e6 * ophrep));
            ctlend_last[0] = RDN_GRD(act_tr - trigger_time - td0 -
                    (opphases -1) * psd_tseq - tmin - time_ssi);
        } 
        else 
        {
            ctlend_fill[0] = RDN_GRD(piait - (((int)(opslquant/ophrep) +
                            (opslquant%ophrep ? 1:0) -1) *
                        psd_tseq) - tmin - time_ssi);
            ctlend_unfill[0] = RDN_GRD(ctlend_fill[0] +
                    (opslquant%ophrep ? psd_tseq:0));
            /* Cross R-R */
            if (opslquant >= ophrep) 
            {
                piclckcnt = ophrep - 1;
                piviews = (nreps+rtb0_dda) * ophrep; /*RTB0 correction*/
                trigger_time =  .01 * oparr * (60.0/ophrate)*1e6;
                ctlend_last[0] = ctlend_unfill[0];
            } 
            else 
            {
                piclckcnt = opslquant - 1;
                piviews = (nreps+rtb0_dda) * opslquant; /*RTB0 correction*/
                trigger_time = (0.01 * oparr * (60.0/ophrate) * 1e6 * (ophrep + 1 - opslquant));
                ctlend_last[0] = RDN_GRD(ctlend_fill[0] + (ophrep - opslquant) *
                        ((1 -.01*oparr) * (60.0/ophrate) * 1e6));
            }
        }

        ps2_dda = dda;
        if (optdel1 < pitdel1) 
        { /* Calculate time from middle of last echo to when 
             spatial sat, chemsat or killer can begin */
            post_echo_time = tdaqhxb + pw_gxwad - rfupa + 1us + gkdelay + gktime;
            postsat = opsat;

            if( irprep_flag == PSD_ON )
            {
                sp_satstart = pos_ir_start + ir_time;
            } 
            else 
            {
                sp_satstart = td0 + tlead;
            }

            sp_satstart = sp_satstart + pw_gzrf1a + t_exa + psd_rf_wait + te_time + post_echo_time;
            cs_satstart = sp_satstart + sp_sattime - rfupa + CHEM_SSP_FREQ_TIME;
            post_echo_time = post_echo_time + sp_sattime + cs_sattime;

            if( irprep_flag == PSD_ON ){
                pos_start = pos_start + ir_time + pos_ir_start; 
            }

            sp_satcard_loc = 1;
        } 
        else 
        {
            postsat = PSD_OFF;

            if( irprep_flag == PSD_ON ){
                sp_satstart = pos_ir_start + ir_time;
            } else {
                sp_satstart = GRAD_UPDATE_TIME + tlead + ir_time;
            }

            cs_satstart = sp_satstart + sp_sattime - rfupa + CHEM_SSP_FREQ_TIME;
            pos_start = pos_start + sp_sattime + cs_sattime + ir_time + satdelay ;

            if( irprep_flag == PSD_ON ){
                pos_start = pos_start + pos_ir_start;
            }

            sp_satcard_loc = 0;
        }
    } 
    else if ( ((existcv(oprtcgate)) && (exist(oprtcgate)==PSD_ON)) || /* RTG */
              (PSD_ON == navtrig_flag) ) 
    {
        /* Set some values for the scan clock */
        pidmode = PSD_CLOCK_CARDIAC; /* Display views  and clock */
        /* piclckcnt 
           piclckcnt is used in estimating the scan time remaining in
           a cardiac scan.  It is the number of cardiac triggers within
           an effective TR interval used by the PSD to initiate a
           sequence after the initial  cardiac trigger

           piviews
           piviews is used by the Tgt in cardiac scans to display the
           number of heart beat triggers the PSD will use
           to complete a scan

           trigger_time  
           Amount of time to leave for the cardiac trigger.  */

        int acq_cnt = 0;  /* counter */
        int tmp_slquant_acq = 0;
        ctlend = IMax(2,(int)GRAD_UPDATE_TIME, RDN_GRD(psd_tseq-tmin-time_ssi));        

        for (acq_cnt = 0; acq_cnt < act_acqs; acq_cnt++)
        { 
            tmp_slquant_acq = opslquant / act_acqs + ((opslquant % act_acqs > acq_cnt) ? 1 : 0);

            ctlend_fill[acq_cnt] = RDN_GRD(pirtait - (((int)(tmp_slquant_acq / oprtrep) +
                            (tmp_slquant_acq  % oprtrep ? 1 : 0) - 1) * psd_tseq) - tmin);
            ctlend_unfill[acq_cnt] = RDN_GRD(ctlend_fill[acq_cnt] + (tmp_slquant_acq % oprtrep?psd_tseq : 0));
        }

        /* Cross R-R  */
        /* HCSDM00432487: Support cross R-R with multi acq case */ 
        if (opslquant >= oprtrep * act_acqs) 
        {   /* No cross R-R case */
            piclckcnt = oprtrep - 1;
            piviews = (nreps+rtb0_dda) * oprtrep;
            trigger_time =  .01 * oprtarr * (60.0 / oprtrate)*1e6;

            /* Need filling more than 0 to ctlend_last in each acq to avoid prep fail */
            for (acq_cnt = 0; acq_cnt < act_acqs; acq_cnt++)
            {
                ctlend_last[acq_cnt] = ctlend_unfill[acq_cnt];
            }  
        }
        else 
        {   /* Cross R-R case */
            piclckcnt = exist(opslquant) - 1;
            piviews = ((nreps/act_acqs) * exist(opslquant)) + 
                (rtb0_dda * (exist(opslquant) / act_acqs + (opslquant%act_acqs ? 1 : 0)));
            trigger_time =  .01 * oprtarr * (60.0 / oprtrate)*1e6 * (oprtrep + 1 - (exist(opslquant) / act_acqs));
            /* In cross R-R with multi acq case, ctlend_last[] will be used each acq */
            for (acq_cnt = 0; acq_cnt < act_acqs; acq_cnt++)
            {
                if (oprtrep > opslquant / act_acqs + (opslquant%act_acqs > acq_cnt? 1 : 0))
                { /* Cross R-R case in current acq */
                    ctlend_last[acq_cnt] = RDN_GRD(ctlend_fill[acq_cnt] + 
                            (oprtrep - (exist(opslquant) / act_acqs)) * (60.0 / oprtrate) * 1e6);
                }
                else
                { /* Non cross R-R case in current acq */
                    ctlend_last[acq_cnt] = ctlend_fill[acq_cnt];
                }
            }
        }

        ps2_dda = dda;

        if( irprep_flag == PSD_ON ){
            sp_satstart = pos_ir_start + ir_time;
        } else {
            sp_satstart = pos_start + ir_time;
        }

        cs_satstart = sp_satstart + sp_sattime - rfupa + CHEM_SSP_FREQ_TIME;
        pos_start = pos_start + ir_time + sp_sattime + cs_sattime + satdelay;

        if( irprep_flag == PSD_ON ){
            pos_start = pos_start + pos_ir_start;
        }

    } 
    else 
    {
        pidmode = PSD_CLOCK_NORM; /* Display scan clock in seconds */
        ps2_dda = dda;

        if( irprep_flag == PSD_ON ){
            sp_satstart = pos_ir_start + ir_time;
        } else {
            sp_satstart = pos_start + ir_time;
        }

        cs_satstart = sp_satstart + sp_sattime - rfupa + CHEM_SSP_FREQ_TIME;
        pos_start = pos_start + ir_time + sp_sattime + cs_sattime + satdelay;

        if( irprep_flag == PSD_ON ){
            pos_start = pos_start + pos_ir_start;
        }

    }
    
    /* YMSmr07671 */
    sp_satcard_loc = sp_satcard_loc || irprep_flag || epi_flair;
  
    if (ss_rf1 != PSD_ON) {
        pos_moment_start = pos_start + t_exa + pw_gzrf1a;
        
        /* SVBranch: HCSDM00259122  - walk sat case for Type I 2D RF */
        if (rfov_flag && walk_sat_flag)
        {
            pos_moment_start = pos_moment_start + pw_wksat_tot;
        }            
    }
    cs_satstart = RUP_GRD(cs_satstart);
    sp_satstart = RUP_GRD(sp_satstart); 
    
    /***SVBranch: HCSDM00259122  -  FOCUS walk sat calc ***/
    /* update the walk-sat module start time
       based on the new pos_start; */
    if (rfov_flag && walk_sat_flag)
    {
        if ( FAILURE == walk_sat_timing() ) return FAILURE;
    }
    /*********************************/
  
    /*
     * Initialize the waits for the cardiac instruction.
     * Pulse widths of wait will be set to td0 for first slice
     * of an R-R in RSP.  All other slices will be set to 
     * the GRAD_UPDATE_TIME.
     */
    pw_x_td0 = GRAD_UPDATE_TIME;
    pw_y_td0 = GRAD_UPDATE_TIME;
    pw_z_td0 = GRAD_UPDATE_TIME;
    pw_rho_td0 = GRAD_UPDATE_TIME;
    pw_ssp_td0 = GRAD_UPDATE_TIME;
    pw_theta_td0 = GRAD_UPDATE_TIME;
    pw_omega_td0 = GRAD_UPDATE_TIME;

    freq_dwi=0.0;   /* B0 frequency offset */
    phase_dwi=0.0;  /* B0 phase offset */
 
    a_gz_dwi=0.0;
    a_gy_dwi=0.0;
    a_gx_dwi=0.0;

    ia_gx1 = (int)(a_gx1 * (float)max_pg_iamp / loggrd.tx);

    /* BJM: pulsegen on the host does not utilize the grad[].scale fields */
    /*      The actual amplitudes are used instead.  For the diffusion lobes, */
    /*      we can account for the frequency of occurance by scaling the amp */

    if((PSD_ON == gradHeatMethod)  && (PSD_ON == derate_amp)) 
    {    
        /*MRIhc05854: 1*/
        if( weighted_avg_grad == PSD_ON && pgen_calc_bval_flag == PSD_OFF && AVERAGE_POWER == encode_mode ) 
        {
            int kk;

            cur_num_iters = 0; /*single-TR average power mode in generating cp files*/

            scale_difx = 0.0;
            scale_dify = 0.0;
            scale_difz = 0.0;

            if ( weighted_avg_debug == PSD_ON ) 
            {
                fp_grad = fopen("/tmp/dwi_grad_debug","a");
            }
            if(tensor_flag == PSD_ON)
            {
                for( kk=0; kk< (opdifnumdirs + opdifnumt2); kk++) 
                {
                    scale_difx += TENSOR_HOST[0][kk] * TENSOR_HOST[0][kk];
                    scale_dify += TENSOR_HOST[1][kk] * TENSOR_HOST[1][kk];
                    scale_difz += TENSOR_HOST[2][kk] * TENSOR_HOST[2][kk];
                    if ( weighted_avg_debug == PSD_ON ) 
                    {
                        fprintf(fp_grad,"TENSOR_HOST[0][%d]=%f, TENSOR_HOST[1][%d]=%f, TENSOR_HOST[2][%d]=%f\n",
                                kk,TENSOR_HOST[0][kk],kk,TENSOR_HOST[1][kk],kk,
                                TENSOR_HOST[2][kk]);
                        fprintf(fp_grad,"scale_difx=%f,scale_dify=%f,scale_difz=%f\n",
                                scale_difx,scale_dify,scale_difz);
                    }
                }
                scale_difx /= (opdifnumdirs + opdifnumt2 + (rpg_in_scan_flag?rpg_in_scan_num:0));
                scale_difx = sqrt(scale_difx);
                scale_dify /= (opdifnumdirs + opdifnumt2 + (rpg_in_scan_flag?rpg_in_scan_num:0));
                scale_dify = sqrt(scale_dify);
                scale_difz /= (opdifnumdirs + opdifnumt2 + (rpg_in_scan_flag?rpg_in_scan_num:0));
                scale_difz = sqrt(scale_difz);
            }
            else
            {
                int counter = 0;
                /* Account for Distortion Correction hidden t2 passes first */
                for( kk=0; kk<(rpg_in_scan_flag?rpg_in_scan_num:0); kk++)
                {
                    /* No diff grads */
                    if ( weighted_avg_debug == PSD_ON ) 
                    {
                        fprintf(fp_grad,"Adding zero amplitude gradients for RPG pass %d\n", kk);
                        fprintf(fp_grad,"scale_difx=%f,scale_dify=%f,scale_difz=%f\n",
                                scale_difx,scale_dify,scale_difz);
                    }
                    counter += (int)1; /* 1NEX*/
                }
                for( kk=0; kk<opdifnumt2; kk++)
                {
                    scale_difx += TENSOR_HOST[0][kk] * TENSOR_HOST[0][kk] * opdifnext2;
                    scale_dify += TENSOR_HOST[1][kk] * TENSOR_HOST[1][kk] * opdifnext2;
                    scale_difz += TENSOR_HOST[2][kk] * TENSOR_HOST[2][kk] * opdifnext2;
                    if ( weighted_avg_debug == PSD_ON ) 
                    {
                        fprintf(fp_grad,"TENSOR_HOST[0][%d]=%f, TENSOR_HOST[1][%d]=%f, TENSOR_HOST[2][%d]=%f\n",
                                kk,TENSOR_HOST[0][kk],kk,TENSOR_HOST[1][kk],kk,
                                TENSOR_HOST[2][kk]);
                        fprintf(fp_grad,"scale_difx=%f,scale_dify=%f,scale_difz=%f\n",
                                scale_difx,scale_dify,scale_difz);
                    }
                    counter += (int)opdifnext2;
                }
                for( kk=0; kk<opnumbvals; kk++)
                {
                    int ii;
                    for(ii = 0; ii<opdifnumdirs; ii++)
                    {
                        scale_difx += TENSOR_HOST[0][ii+opdifnumt2] * TENSOR_HOST[0][ii+opdifnumt2] *
                                      diff_bv_weight[kk] * difnextab[kk];
                        scale_dify += TENSOR_HOST[1][ii+opdifnumt2] * TENSOR_HOST[1][ii+opdifnumt2] *
                                      diff_bv_weight[kk] * difnextab[kk];
                        scale_difz += TENSOR_HOST[2][ii+opdifnumt2] * TENSOR_HOST[2][ii+opdifnumt2] *
                                      diff_bv_weight[kk] * difnextab[kk];
                        if ( weighted_avg_debug == PSD_ON ) 
                        {
                            fprintf(fp_grad,"TENSOR_HOST[0][%d]=%f, TENSOR_HOST[1][%d]=%f, TENSOR_HOST[2][%d]=%f\n",
                                    kk,TENSOR_HOST[0][kk],kk,TENSOR_HOST[1][kk],kk,TENSOR_HOST[2][kk]);
                            fprintf(fp_grad,"diff_bv_weight[%d]=%f\n", kk,diff_bv_weight[kk]);
                            fprintf(fp_grad,"scale_difx=%f,scale_dify=%f,scale_difz=%f\n",
                                    scale_difx,scale_dify,scale_difz);
                        }
                        counter += (int)difnextab[kk];
                    }
                }
                scale_difx /= IMax(2, counter, 1);
                scale_difx = sqrt(scale_difx);
                scale_dify /= IMax(2, counter, 1);
                scale_dify = sqrt(scale_dify);
                scale_difz /= IMax(2, counter, 1);
                scale_difz = sqrt(scale_difz);
            }
            
            if ( weighted_avg_debug == PSD_ON ) 
            {
                    fprintf(fp_grad,"opdifnumdirs=%d, opdifnumt2=%d, opnumbvals=%d\n",
                            opdifnumdirs,opdifnumt2,opnumbvals);
                    fprintf(fp_grad,"scale_difx=%f, scale_dify=%f, scale_difz=%f\n\n\n",
                            scale_difx,scale_dify,scale_difz);
                    fclose(fp_grad);
            }
        } 
        else if (pgen_calc_bval_flag == PSD_OFF)
        {  /* weighted_avg_debug == PSD_OFF */                
            if (tensor_flag == PSD_OFF) 
            {
                if(opdfaxall >PSD_OFF)
                {
                    scale_difx = 1.0;
                    scale_dify = 0.0;
                    scale_difz = 0.0;
                    if(gradopt_diffall == PSD_ON)
                    {
                        scale_difx = 1.0;
                        scale_dify = 1.0;
                        scale_difz = 0.0;
                    }
                }
                else if (opdfaxx > PSD_OFF) 
                {
                    scale_difx = 1.0;
                    scale_dify = 0.0;
                    scale_difz = 0.0;
                }
                else if (opdfaxy > PSD_OFF) 
                {
                    scale_difx = 0.0;
                    scale_dify = 1.0;
                    scale_difz = 0.0;
                }
                else if (opdfaxz > PSD_OFF) 
                {
                    scale_difx = 0.0;
                    scale_dify = 0.0;
                    scale_difz = 1.0;
                }
                else if((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
                {
                    scale_difx = 1.0;
                    scale_dify = 1.0;
                    scale_difz = 1.0;
                }
            }
            else 
            {
                scale_difx = 1.0;
                scale_dify = 0.0;
                scale_difz = 0.0;
            }
        }
        else  /* pgen_calc_bval ON */
        {
            if (tensor_flag == PSD_OFF)
            {
                if(opdfaxall >PSD_OFF)
                {
                    scale_difx = 1.0;
                    scale_dify = 1.0;
                    scale_difz = 1.0;
                }
                else if (opdfaxx > PSD_OFF)
                {
                    scale_difx = 1.0;
                    scale_dify = 0.0;
                    scale_difz = 0.0;
                }
                else if (opdfaxy > PSD_OFF)
                {
                    scale_difx = 0.0;
                    scale_dify = 1.0;
                    scale_difz = 0.0;
                }
                else if (opdfaxz > PSD_OFF)
                {
                    scale_difx = 0.0;
                    scale_dify = 0.0;
                    scale_difz = 1.0;
                }
                else if((opdfaxtetra > PSD_OFF) || (opdfax3in1 > PSD_OFF))
                {
                    scale_difx = 1.0;
                    scale_dify = 1.0;
                    scale_difz = 1.0;
                }
            }
            else
            {
                scale_difx = 1.0;
                scale_dify = 1.0;
                scale_difz = 1.0;
            }
        }

        /* Obl 3in1 opt */
        if (obl_3in1_opt)
        {
            int i;

            if (obl_3in1_opt_debug)
            {
                printf("Obl3in1:  \n");
                printf("Obl3in1: weighted_avg_grad=%d pgen_calc_bval_flag=%d\n", weighted_avg_grad, pgen_calc_bval_flag);
                printf("Obl3in1: scale_difx=%f scale_dify=%f scale_difz=%f\n", scale_difx, scale_dify, scale_difz);
                printf("Obl3in1:  \n");
                printf("Obl3in1: Input logical MPG amplitude in each axis in G/cm.\n");
                printf("Obl3in1: norot_incdifx= %f norot_incdify= %f norot_incdifz= %f\n", norot_incdifx, norot_incdify, norot_incdifz);
            }

            gx_phys = norot_incdifx*scale_difx;
            gy_phys = norot_incdify*scale_dify;
            gz_phys = norot_incdifz*scale_difz;

            log_incdifx_scaled = inversRR[0]*gx_phys + inversRR[1]*gy_phys + inversRR[2]*gz_phys;
            log_incdify_scaled = inversRR[3]*gx_phys + inversRR[4]*gy_phys + inversRR[5]*gz_phys;
            log_incdifz_scaled = inversRR[6]*gx_phys + inversRR[7]*gy_phys + inversRR[8]*gz_phys;

            if (obl_3in1_opt_debug)
            {
                printf("Obl3in1: Calculated scaled logical MPG amplitude\n");
                printf("Obl3in1: log_incdifx_scaled= %f log_incdify_scaled= %f log_incdifz_scaled= %f\n", log_incdifx_scaled, log_incdify_scaled, log_incdifz_scaled);
            }

            for (i=0; i<num_dif; i++)
            {
                gx_log = norot_incdifx;
                gy_log = norot_incdify;
                gz_log = norot_incdifz;

                rotateToLogical(&gx_log, &gy_log, &gz_log, i);

                log_incdifx[i]=gx_log;
                log_incdify[i]=gy_log;
                log_incdifz[i]=gz_log;

                if (obl_3in1_opt_debug)
                {
                    printf("Obl3in1: Dir= %d\n",i);
                    printf("Obl3in1: Calculated logical MPG amplitude\n");
                    printf("Obl3in1: log_incdifx= %f  log_incdify= %f log_incdifz= %f\n",log_incdifx[i],log_incdify[i],log_incdifz[i]);
                }
            }

            agxdif_tmp = log_incdifx[0];
            agydif_tmp = log_incdify[0];
            agzdif_tmp = log_incdifz[0];
        }
        else
        {
            /* BJM: pulsegen on the host does not utilize the grad[].scale fields */
            /*      The actual amplitudes are used instead.  For the diffusion lobes, */
            /*      we can account for the frequency of occurance by scaling the amp */

            /* DTI */
            if (PSD_OFF == dualspinecho_flag)
            {
                agxdif_tmp = a_gxdl;
                agydif_tmp = a_gydl;
                agzdif_tmp = a_gzdl;
            }
            else 
            {
                agxdif_tmp = a_gxdl1;
                agydif_tmp = a_gydl1;
                agzdif_tmp = a_gzdl1;
            }
        }

        /* MRIge57853: Dont scale X for ultra Hi-B to protect against */
        /* power supply droop... */
        /* MRIge58521 - removed fix for 57853 since this is taken */
        /* into account with this fix */
        /* DTI */
        
        if (PSD_OFF == dualspinecho_flag)
        {
            /* x axis scaled - scale_difx = 1 (worst case)*/
            a_gxdl = gradx[GXDL_SLOT].num*a_gxdl*scale_difx;
            a_gxdr = a_gxdl;
            
            /* y axis scaled - scale_dify = 0*/
            a_gydl = grady[GYDL_SLOT].num*a_gydl*scale_dify;
            a_gydr = a_gydl;

            /* z axis scaled - scale_difz = 0*/
            a_gzdl = gradz[GZDL_SLOT].num*a_gzdl*scale_difz;
            a_gzdr = a_gzdl; 
	    
	    /* granty edit for full time diffusion encoding */
	    if(ftde_flag == PSD_ON){
		a_gxde = -a_gxdr;
		a_gyde = -a_gydr;
		a_gzde = -a_gzdr;
	    }

            /* Obl 3in1 opt */
            if (obl_3in1_opt)
            {
                if (pgen_calc_bval_flag)
                {
                    a_gxdl = amp_difx_bverify;
                    a_gydl = amp_dify_bverify;
                    a_gzdl = amp_difz_bverify;
                    a_gxdr = amp_difx_bverify;
                    a_gydr = amp_dify_bverify;
                    a_gzdr = amp_difz_bverify;
                }
                else
                {
                    a_gxdl = log_incdifx_scaled;
                    a_gydl = log_incdify_scaled;
                    a_gzdl = log_incdifz_scaled;
                    a_gxdr = log_incdifx_scaled;
                    a_gydr = log_incdify_scaled;
                    a_gzdr = log_incdifz_scaled;
                }
            }

            ia_gxdl = (int)(a_gxdl * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr = (int)(a_gxdr * (float)max_pg_iamp / loggrd.tx);
            
            ia_gydl = (int)(a_gydl * (float)max_pg_iamp / loggrd.ty);
            ia_gydr = (int)(a_gydr * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl = (int)(a_gzdl * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr = (int)(a_gzdr * (float)max_pg_iamp / loggrd.tz);

	    if(ftde_flag == PSD_ON){/* granty maybe */
            	ia_gxde = (int)(a_gxde * (float)max_pg_iamp / loggrd.tx);

            	ia_gyde = (int)(a_gyde * (float)max_pg_iamp / loggrd.ty);

            	ia_gzde = (int)(a_gzde * (float)max_pg_iamp / loggrd.tz);
	    }

        }
        else 
        {
            a_gxdl1 = gradx[GXDL_SLOT].num*a_gxdl1*scale_difx;
            a_gxdr1 = -a_gxdl1;
            
            a_gxdl2 = gradx[GXDL_SLOT].num*a_gxdl2*scale_difx;
            a_gxdr2 = -a_gxdl2;

            /* y axis scaled */
            a_gydl1 = grady[GYDL_SLOT].num*a_gydl1*scale_dify;
            a_gydr1 = -a_gydl1;
            
            a_gydl2 = grady[GYDL_SLOT].num*a_gydl2*scale_dify;
            a_gydr2 = -a_gydl2;
            
            /* z axis scaled */
            a_gzdl1 = gradz[GZDL_SLOT].num*a_gzdl1*scale_difz;
            a_gzdr1 = -a_gzdl1; 
            
            a_gzdl2 = gradz[GZDL_SLOT].num*a_gzdl2*scale_difz;
            a_gzdr2 = -a_gzdl2; 
            
            /* Obl 3in1 opt */
            if (obl_3in1_opt)
            {
                if (pgen_calc_bval_flag)
                {
                    a_gxdl1 = amp_difx_bverify;
                    a_gydl1 = amp_dify_bverify;
                    a_gzdl1 = amp_difz_bverify;
                    a_gxdr1 = -amp_difx_bverify;
                    a_gydr1 = -amp_dify_bverify;
                    a_gzdr1 = -amp_difz_bverify;
                    a_gxdl2 = amp_difx_bverify;
                    a_gydl2 = amp_dify_bverify;
                    a_gzdl2 = amp_difz_bverify;
                    a_gxdr2 = -amp_difx_bverify;
                    a_gydr2 = -amp_dify_bverify;
                    a_gzdr2 = -amp_difz_bverify;
                }
                else
                {
                    a_gxdl1 = log_incdifx_scaled;
                    a_gydl1 = log_incdify_scaled;
                    a_gzdl1 = log_incdifz_scaled;
                    a_gxdr1 = -log_incdifx_scaled;
                    a_gydr1 = -log_incdify_scaled;
                    a_gzdr1 = -log_incdifz_scaled;
                    a_gxdl2 = log_incdifx_scaled;
                    a_gydl2 = log_incdify_scaled;
                    a_gzdl2 = log_incdifz_scaled;
                    a_gxdr2 = -log_incdifx_scaled;
                    a_gydr2 = -log_incdify_scaled;
                    a_gzdr2 = -log_incdifz_scaled;
                }
            }

            ia_gxdl1 = (int)(a_gxdl1 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr1 = (int)(a_gxdr1 * (float)max_pg_iamp / loggrd.tx);
        
            ia_gxdl2 = (int)(a_gxdl2 * (float)max_pg_iamp / loggrd.tx);
            ia_gxdr2 = (int)(a_gxdr2 * (float)max_pg_iamp / loggrd.tx);

            ia_gydl1 = (int)(a_gydl1 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr1 = (int)(a_gydr1 * (float)max_pg_iamp / loggrd.ty);
            
            ia_gydl2 = (int)(a_gydl2 * (float)max_pg_iamp / loggrd.ty);
            ia_gydr2 = (int)(a_gydr2 * (float)max_pg_iamp / loggrd.ty);

            ia_gzdl1 = (int)(a_gzdl1 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr1 = (int)(a_gzdr1 * (float)max_pg_iamp / loggrd.tz);
            
            ia_gzdl2 = (int)(a_gzdl2 * (float)max_pg_iamp / loggrd.tz);
            ia_gzdr2 = (int)(a_gzdr2 * (float)max_pg_iamp / loggrd.tz);  
        }

        /* Set the amps back that are scaled */
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            /* x-axis scaled */
            a_gxdl = agxdif_tmp;
            a_gxdr = a_gxdl;

            /* y axis scaled */
            a_gydl = agydif_tmp;
            a_gydr = a_gydl;

            /* z axis scaled */
            a_gzdl = agzdif_tmp;
            a_gzdr = a_gzdl;

	    if(ftde_flag == PSD_ON){/* granty maybe */
		a_gzde = -a_gzdr;
		a_gyde = -a_gydr;
		a_gxde = -a_gxdr;
	    }
        } 
        else 
        {
            a_gxdl1 = agxdif_tmp;
            a_gxdr1 = -a_gxdl1;

            a_gydl1 = agydif_tmp;
            a_gydr1 = -a_gydl1;

            a_gzdl1 = agzdif_tmp;
            a_gzdr1 = -a_gzdl1;

            a_gxdl2 = agxdif_tmp;
            a_gxdr2 = -a_gxdl2;

            a_gydl2 = agydif_tmp;
            a_gydr2 = -a_gydl2;

            a_gzdl2 = agzdif_tmp;
            a_gzdr2 = -a_gzdl2;
        }
    }

    ia_incdifx = (int)(incdifx * (float)max_pg_iamp / loggrd.tx);
    ia_incdify = (int)(incdify * (float)max_pg_iamp / loggrd.ty);
    ia_incdifz = (int)(incdifz * (float)max_pg_iamp / loggrd.tz);

    /*
     * Rio diffusion will generate multi-TR cornerPoints in the MAXIMUM_POWER mode
     */
    if ((pgen_calc_bval_flag == PSD_OFF) && (MAXIMUM_POWER == encode_mode) &&
        (isRioSystem()) && (opdiffuse == PSD_ON))
    {
        int ia_incdifx_tmp, ia_incdify_tmp, ia_incdifz_tmp, sindex, ii;

    ia_incdifx_tmp = (int)(agxdif_tmp * (float)max_pg_iamp / loggrd.tx);
    ia_incdify_tmp = (int)(agydif_tmp * (float)max_pg_iamp / loggrd.ty);
    ia_incdifz_tmp = (int)(agzdif_tmp * (float)max_pg_iamp / loggrd.tz);

        if (diff_order_flag == 1)
    {
            if (opdfaxtetra >= PSD_ON || optensor >= PSD_ON || opdfaxall >= PSD_ON)
        {
                for(ii = 0; ii<num_iters; ii++)
                {
                    if (PSD_ON == tensor_host_sort_flag)
                    {
                        sindex = sort_index[ii];
                    }
                    else
                    {
                        sindex = ii+opdifnumt2;
                    }
                    xamp_iters[ii] = (int) (ia_incdifx_tmp * TENSOR_HOST[0][sindex]);
                    yamp_iters[ii] = (int) (ia_incdify_tmp * TENSOR_HOST[1][sindex]);
                    zamp_iters[ii] = (int) (ia_incdifz_tmp * TENSOR_HOST[2][sindex]);
                }
            }
        }
        else /*diff_order_flag == 2*/
        {
            if (opdfaxtetra >= PSD_ON || optensor >= PSD_ON || opdfaxall >= PSD_ON)
            {
                int index_t2;
                if (opdifnumt2 > 0)
                {
                    index_t2 = opdifnumt2-1;
                }else{
                    index_t2 = 0;
                }

                for(ii = 0; ii<num_iters; ii++)
                {
                    if (PSD_ON == tensor_host_sort_flag)
                    {
                        sindex = sort_index[ii];
                    }
                    else
                    {
                        sindex = ii + index_t2;
                    }
                    xamp_iters[ii] = (int) (ia_incdifx_tmp * TENSOR_HOST[0][sindex]);
                    yamp_iters[ii] = (int) (ia_incdify_tmp * TENSOR_HOST[1][sindex]);
                    zamp_iters[ii] = (int) (ia_incdifz_tmp * TENSOR_HOST[2][sindex]);
                }
            }
        }
        cur_num_iters = num_iters; /*multi-TR for maximum power mode in generating cp file*/
    }
    
    if (diff_order_debug == PSD_ON)
    {
        FILE *fp= NULL;
#ifdef PSD_HW
        const char *dir_log = "/usr/g/service/log";
#else
        const char *dir_log = ".";
#endif
        char fname[255];

        sprintf(fname, "%s/diff_order_xyzamp_iters.txt", dir_log);

        if (num_iters>0)
        {
            if ( NULL != (fp = fopen(fname, "w")) )
            {
                int ii;
                fprintf(fp, "num_iters: %d\n", num_iters);
                for(ii = 0; ii<num_iters; ii++)
                {
                    fprintf(fp, "xamp_iters[%d]=%d\t",ii,xamp_iters[ii]);
                    fprintf(fp, "yamp_iters[%d]=%d\t",ii,yamp_iters[ii]);
                    fprintf(fp, "zamp_iters[%d]=%d\n",ii,zamp_iters[ii]);
                }
                fclose(fp);
            }
        }
    }

    ia_gy1 = endview_iamp; /* GEHmr01804 */

    if (eoskillers == PSD_ON) {
	ia_gxk = (int)(a_gxk * (float)max_pg_iamp / loggrd.tx);
	ia_gyk = (int)(a_gyk * (float)max_pg_iamp / loggrd.ty);
	ia_gzk = (int)(a_gzk * (float)max_pg_iamp / loggrd.tz);
    }
    ia_rf1 = max_pg_iamp * (*rfpulse[RF1_SLOT].amp);
    ia_rf2 = max_pg_iamp * (*rfpulse[RF2_SLOT].amp);
  
    /* SVBranch: HCSDM00259122  - FOCUS walk sat */
    if (walk_sat_flag && rfov_flag) walk_sat_scaleRF();   

    SpSatIAmp();

    if (cs_sat == PSD_ON) {
	ia_rfcssat = max_pg_iamp * (*rfpulse[RFCSSAT_SLOT].amp);
    }
  
    /* BJM: Omega Freq Mod Pulses */
    a_omega = 1;
    ia_omega = (a_omega*max_pg_iamp)/loggrd.tz;

    return SUCCESS;
}   /* end calcPulseParams() */

/* t1flair_stir */
@inline T1flair.e T1flairEval

@inline ChemSat.e ChemSatEval
@inline ChemSat.e ChemSatCheck
@inline SpSat.e SpSatEval
@inline SpSat.e SatPlacement
@inline Prescan.e PShost
@inline Dwicorrcal.e Predownload

/* Functions that calculate per unit, per axis contribution to delta grad and freq */
@inline HoecCorr.e HoecDeltaGradFreqCalFunctionsPredownload

@inline Inversion_new.e InversionEvalFunc

/**************************************************************************/
/**************************************************************************/
@rspvar
@inline Prescan.e PSrspvar

@inline Monitor.e MonitorRspVar

float rdx, rdy, rdz;     /* B0 phase dither in degrees, physical axes */
float dlyx, dlyy, dlyz;  /* gldelay acq/grad alignment real time variables */

int ref_switch;   /* If 1 use prescribed y FOV offset in exciter phase calc
                     If 0, don't used phase offset (for reference scan) */

int acq_data;  /* data acquisiton on/off flag */

int shot_delay;    /* trigger delay value for progressive gating */
int end_delay;     /* end of sequence wait time for conserved TR with
                      progressive gating */
int gyb_amp;       /* amplitude of gyb pulse */
int dro = 0;         /* delta readout offset in mm */
int dpo = 0;         /* delta phase encoding offset in mm */

float xtr;         /* xtr tuning value */
float frt;         /* frt tuning value */

float timedelta;
int deltaomega,scaleomega;
int newramp1,newramp1a;

int   sliceindex, pass,view,core_rep,ileave,excitation,slice,echo,pass_rep, pass_index, sliceindex1,slice1;
int   false_pass, false_slice, slice_tmp;
int   slq_to_shift; /* MRIge44963 - slice to be shifted in flair to get correct number of */
                    /* slices in each pack (false_pass) so that there is no cross talk */
int   slicerep;
int   use_sl;
int   sl_rcvcf;        /*  center freq receive offset */
int   dabecho, dabecho_multi, dabop, dabview; /* vars for loaddab */
short debugstate;      /* if trace is on */
int   acq_sl;
int   rsp_card_intern; /* deadtime when next slice is internally gated in a cardiac scan */
int   rsp_card_last[DATA_ACQ_MAX];   /* dead time for last temporal slice of a cardiac scan */
int   rsp_card_fill[DATA_ACQ_MAX];   /* dead time for last slice in a filled R-R interval */
int   rsp_card_unfill[DATA_ACQ_MAX]; /* dead time for last slice in a unfilled R-R interval */
short rsp_hrate;       /* cardiac heart rate */

short rsp_preview; /* amplitude of phase encode for prescan entrypoints */

int pre_slnum;  /* Prescan slice number */

/* int dshot; */  /* Diffusion shot counter */

int echoOffset;
int dabmask, hsdabmask, diffdabmask;

int sync1_pos;                  /* time of sync for rf1 */
int rf1_pos;                    /* time of rf1 */
int sync_to_rf1;                /* time from sync to start of rf1 */
int t_rf1_phase;                /* time from sync to middle of rf1 */

int sync2_pos;                  /* time of sync for rf2 */
int rf2_pos;                    /* time of rf2 */
int sync_to_rf2;                /* time from sync to start of rf2 */
int t_rf2_phase;                /* time from sync to middle of rf2 */

@inline SpSat.e SpSatRspVar
@inline ChemSat.e ChemSatRspVar 

/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptRspVar

int   rspent, rspgyc, rspgzc;

short rspdda, rspbas, rspvus, rspilv, rsprep, rspnex, rspnex_temp, rspchp, rspgy1,
    rspesl, rspasl, rspech, rspsct, rspdex, rspslq, rspslq1,
    rspacq, rspacqb, rspslqb, rspilvb, rspbasb, rspprp, rsppepolar, rspfskillercycling; 

short false_rspacqb, false_rspacq;

short rspe1st, rspetot;

/* ocfov fix MRIge26428 */
int refindex1,refindex2;
float refdattime[SLTAB_MAX];
int blankomega;
/* blip correction array */
int rspia_gyboc[DATA_ACQ_MAX];

/*RTB0 correction*/
@inline RTB0.e RTB0rspvar_epi2

@pg
/*********************************************************************
 *                       EPI2.E PULSEGEN SECTION                     *
 *                                                                   *
 * Write here the functional code that loads hardware sequencer      *
 * memory with data that will allow it to play out the sequence.     *
 * These functions call pulse generation macros previously defined   *
 * with @pulsedef, and must return SUCCESS or FAILURE.               *
 *********************************************************************/
/* MRIge55206 - change memory allocation if in SIM for multi-dim array support */
#ifdef SIM
#include <stdlib.h>
#define AllocMem malloc
#else
#define AllocMem AllocNode
#endif

#include <math.h>

long rsprot_orig[DATA_ACQ_MAX][9]; /* rotation matrix for SAT */
extern PSD_EXIT_ARG psdexitarg;
short *acq_ptr;               /* first slice in a pass */
int   *ctlend_tab;            /* table of cardiac deadtimes */
short *slc_in_acq;            /* number of slices in each pass */
/* Frequency/Phase offsets */
int   *rf1_freq;
int   *theta_freq;
int   *rf2_freq;
int   *thetarf2_freq;
int   ***recv_freq;
int   ***recv_phase;
double ***recv_phase_ang_nom;   /* nominal receiver phase angle - XJZ */
double ***recv_phase_angle;
int *rf1_pha;
int *rf2_pha;
int *rf2left_pha;
int *rf2right_pha;
WF_PULSE tmppulse,*tmppulseptr;
WF_INSTR_HDR *tmpinstr;
int **diff_order;
int *diff_order_pass;
int *diff_order_nex;
int *diff_order_dif;


/* declare delta grad and freq arrays */
@inline HoecCorr.e HoecArrayDefPG

int   **rf_phase_spgr;
WF_PULSE **echotrainxtr;
WF_PULSE **echotrainrba;
int *echotrainramp1;
int *echotrainramp2;

/*RTB0 correction*/
WF_PULSE_ADDR rtb0echoxtr;

/* invertGy1 = 1 or -1, for rpg_flag.
   We need this for setting gy1f because this is init in PG by ileaveinit and 
   depends on pepolar. For the RPG volume, gy1 needs to be inverted because
   it is not initialized properly. */
int invertGy1 = 1;

/* The following arrays are indexed by intleave: */
int *gy1f;      /* amplitude of gy1f pulse */
int *gymn;      /* amplitude of y gradient moment nulling pulses */
int *view1st;   /* 1st view to acquire */
int *viewskip;  /* number of views to skip */
int *tf;        /* time factor shift */
int *rfpol;     /* rf polarity */
int *blippol;   /* blip gradient polarity */
int *gradpol;   /* readout gradient polarity */
float *b0ditherval;/* B0 dither value, per slice basis */
float *delayval;   /* delay values, per slice basis */
int *gldelaycval;  /* per slice gldelayc valuse */
float *gldelayfval; /* per slice gldelayf values */
int defaultdelay = 0; /* default delay */
int mintf;         /* most negative tfon value, for echo train positioning */
int sp_satindex, cs_satindex;  /* index for multiple calls to spsat
                                  and chemsat routines */
int rcvrunblankpos;
WF_PULSE gx1a = INITPULSE;
WF_PULSE gx1 = INITPULSE;
WF_PULSE gx1d = INITPULSE;

WF_PULSE rs_omega_attack = INITPULSE;
WF_PULSE rs_omega_decay = INITPULSE;
WF_PULSE omega_flat = INITPULSE;

WF_PULSE rho_killer = INITPULSE;

long scan_deadtime_inv;      /* deadtime in ir prep loop */
long scan_deadlast;          /* deadtime in last seqcore loop in 
                                Interleaved IR EPI*/
long prescan_trigger;        /* save the prescan slice's trigger */
long rsptrigger_temp[1];     /* temp trigger array for pass packets 
                                sequences and other misc */
/* Original scan info */
RSP_INFO orig_rsp_info[DATA_ACQ_MAX];
long origrot[DATA_ACQ_MAX][9];
WF_INSTR_HDR *instrtemp;

char psddbgstr[256] = "";

/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptPG

/*RTB0 correction*/
short sspwm_dynr1[4]={SSPDS,SSPOC,SSPD,SSPDS};

@inline Inversion_new.e InversionPGinit
@inline RfovFuncs.e RfovPG
@inline MultibandFuncs.e MultibandPG

#ifdef __STDC__ 
void dummyssi( void )
#else /* !__STDC__ */
    void dummyssi() 
#endif /* __STDC__ */
{
    return;
}

/* Added for Inversion.e */
#ifdef __STDC__
STATUS setupphases ( INT *phase, INT *freq, INT slice, FLOAT rel_phase, INT time_delay, INT sign_flag)
#else /* !__STDC__ */
    STATUS setupphases (phase, freq, slice, rel_phase, time_delay)
    INT *phase;                /* output phase offsets */
    INT *freq;                 /* precomputed frequency offsets */
    INT slice;                 /* slice number */
    FLOAT rel_phase;           /* in cycles */
    INT time_delay;            /* in micro seconds */
#endif /* __STDC__ */
{
    double ftime_delay;           /* floating point time delay in seconds */
    double temp_freq;             /* frequency offset */
    float tmpphase;
    int   intphase;
    int   sign;

    ftime_delay = ((double)time_delay)/((double)(1s));

    /* Convert tardis int to frequency */
    temp_freq = sign_flag*((double)(freq[slice]))*TARDIS_FREQ_RES;

    /* determine phase change in radians */
    tmpphase = (rel_phase - ( temp_freq * ftime_delay ))*2.0*PI;

    tmpphase /= (float)PI;    /* unwrap this phase bits */
    if (tmpphase < 0) {
        sign = -1;
        tmpphase *= -1;
    }
    else
        sign = 1;

    if ( ((int)floor((double)tmpphase) % 2) == 1) {
        sign *= -1;
        intphase = sign * (long)
            ( (1.0-(tmpphase - (float)floor((double)tmpphase)) ) * ((double)FSI));
    }
    else
        intphase = sign * (long)
            ( (tmpphase - (float)floor((double)tmpphase)) * ((double)FSI));

    phase[slice] = intphase;

    return SUCCESS;
}

void
#ifdef __STDC__ 
ssisat( void )
#else /* !__STDC__ */
    ssisat()
#endif /* __STDC__ */
{
#ifdef IPG
    int next_slice;

    next_slice = sp_sat_index;
    sp_update_rot_matrix( &rsprot_orig[next_slice][0], sat_rot_matrices,
                          sat_rot_ex_num, sat_rot_df_num );
#endif /* IPG */
    return;
}

/***************************** setreadpolarity *************************/
#ifdef __STDC__ 
STATUS setreadpolarity( void )
#else /* !__STDC__ */
    STATUS setreadpolarity()
#endif /* __STDC__ */
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

    if(iref_etl > 0)
    {
        setiamp(tia_gxw, &gxw, 0); /* gx_dwi cross term correction */
    }
    else
    {
        setiamp(tia_gxw-ia_gx_dwi, &gxw, 0); /* gx_dwi cross term correction */
    }

    /* Ramps are handled with opposite sign because of the way they
       are defined in the EP_TRAIN macro.  Please refer to epic.h
       for more details. */

    for (echo=1; echo < tot_etl; echo++) {
        if(echo < iref_etl)
        {
            if ((echo % 2) == 1) {  /* Even echo within interleave */
                setiamp(-tia_gxw, &gxwa, echo-1); /* waveforms go neg to pos in ep_train */
                setiamp(-tia_gxw, &gxwd, echo-1);
                setiamp(-tia_gxw, &gxw, echo);    /* const   */
            } else {                    /* Odd echo within interleave */
                setiamp(tia_gxw, &gxwa, echo-1); /* waveforms go neg to pos in ep_train */
                setiamp(tia_gxw, &gxwd, echo-1);
                setiamp(tia_gxw, &gxw, echo);     /* flattop   */
            }
        }
        else
        {
            if ((echo % 2) == 1) {  /* Even echo within interleave */ 
                setiamp(-tia_gxw-ia_gx_dwi, &gxwa, echo-1); /* waveforms go neg to pos in ep_train */
                setiamp(-tia_gxw-ia_gx_dwi, &gxwd, echo-1);
                setiamp(-tia_gxw-ia_gx_dwi, &gxw, echo);    /* const   */
            } else {                    /* Odd echo within interleave */
                setiamp(tia_gxw-ia_gx_dwi, &gxwa, echo-1); /* waveforms go neg to pos in ep_train */
                setiamp(tia_gxw-ia_gx_dwi, &gxwd, echo-1);
                setiamp(tia_gxw-ia_gx_dwi, &gxw, echo);     /* flattop   */
            }
        }
    }

    if ((tot_etl % 2) == 1) {
        setiamp(-tia_gxw-ia_gx_dwi,&gxwde, 0);  /* decay,end */
        if (eosxkiller == 1) {
            setiamp(-tia_gxk,&gxka, 0);   /* killer attack */
            setiamp(-tia_gxk,&gxk, 0);    /* killer flattop */
            setiamp(-tia_gxk,&gxkd, 0);   /* killer decay  */
        }
    } else {
        setiamp(tia_gxw-ia_gx_dwi,&gxwde, 0);   /* decay,end */
        if (eosxkiller == 1) {
            setiamp(tia_gxk,&gxka, 0);    /* killer attack */
            setiamp(tia_gxk,&gxk, 0);     /* killer flattop */
            setiamp(tia_gxk,&gxkd, 0);    /* killer decay  */
        }
    }

    return SUCCESS;
} /* end setreadpolarity */

#ifdef __STDC__ 
STATUS pulsegen( void )
#else /* !__STDC__ */
    STATUS pulsegen() 
#endif /* __STDC__ */ 
{
    EXTERN_FILENAME ext_filename; /* filename holder for externals */
    int Rf2Location[NECHO_MAX]; /* time locations of Rf2 */
    short slmod_acqs;           /* slices%acqs */
    int tempx, tempy, tempz, temps, tempiref = 0;
    int temp1, temp2 = 0;
    int echoloop;
    int psd_icnt,psd_jcnt;
    int psd_seqtime;      /* sequence time */
    short *wave_space;
    short *temp_wave_space = NULL; /* temporary waveform space for rf scaling */
    short temp_res;         /* temporary resolution */
    int wave_ptr;           /* hardware wave pointer */
    float temp_gmnamp;  /* temporary amplitudes for y gmn calc */
    float tempa, tempb;
    LONG pulsePos;
    int lpfval = -1;
    float betax;

    tot_etl = etl + iref_etl; /* internref */

    /* Added for Inversion.e InversionPG1 */
    int i;

    /* Set HPC timer set to 10 seconds (5 sec. per count) */
    setwatchdogrsp(watchdogcount); /* First give pulsegen a little extra time */
#ifdef MGD_TGT		/* if this is MGD */
    SetHWMem();		/* reset MGD instruction and waveform mem */
#endif	
 
    /*MRIhc18005*/
    sspinit(psd_board_type);

    /* Initialize TGlimit */
    TGlimit = MAX_SYS_TG;

#ifdef IPG 
    /*
     * Execute this code only on the Tgt side
     */
#ifdef SIM
    /* 7/17/96 RJL: Initialization for Simulators. Only required for simulation builds.
       This is not compiled in during HW builds. This is taken care of in Makefile */
    simulationInit( rsprot[0] );
    /* rsprot code */
    {
        int j;

        for (i=0; i<opslquant*opphases; i++) {
            for (j=0; j<9; j++) {
                rsprot_unscaled[i][j] = rsprot[i][j];
            }
        }
    }

#endif /* SIM */
#endif /* IPG */

@inline vmx.e VMXpg  

    debugstate = debugipg;

    /* Allocate memory for various arrays.
     * An extra 2 locations are saved in case the user wants to do
     * some tricks. */
    acq_ptr = (short *)AllocNode((act_acqs*pass_reps + 2)*sizeof(short));
    ctlend_tab = (int *)AllocNode((opphases*opslquant + 2)*sizeof(int));
    slc_in_acq = (short *)AllocNode((act_acqs*pass_reps + 2)*sizeof(short));
    rf1_freq = (int *)AllocNode((opslquant + 2)*sizeof(int));
    theta_freq = (int *)AllocNode((opslquant + 2)*sizeof(int));
    rf2_freq = (int *)AllocNode((opslquant + 2)*sizeof(int));
    thetarf2_freq = (int *)AllocNode((mux_slquant + 2)*sizeof(int));
    rf1_pha = (int *)AllocNode((opslquant + 2)*sizeof(int));
    rf2_pha = (int *)AllocNode((opslquant + 2)*sizeof(int));
    rf2left_pha = (int *)AllocNode((opslquant + 2)*sizeof(int));
    rf2right_pha = (int *)AllocNode((opslquant + 2)*sizeof(int));

    recv_freq = (int ***)AllocMem(opslquant*sizeof(int **));
    for (psd_icnt = 0; psd_icnt < opslquant; psd_icnt++) {
        recv_freq[psd_icnt] = (int **)AllocMem(intleaves*sizeof(int *));
        for (psd_jcnt = 0; psd_jcnt < intleaves; psd_jcnt++)
        {
            recv_freq[psd_icnt][psd_jcnt] = (int *)AllocMem(tot_etl*sizeof(int));
        }
    }

    recv_phase = (int ***)AllocMem(opslquant*sizeof(int **));
    for (psd_icnt = 0; psd_icnt < opslquant; psd_icnt++) {
        recv_phase[psd_icnt] = (int **)AllocMem(intleaves*sizeof(int *));
        for (psd_jcnt = 0; psd_jcnt < intleaves; psd_jcnt++)
        {
            recv_phase[psd_icnt][psd_jcnt] = (int *)AllocMem(tot_etl*sizeof(int));
        }
    }

    recv_phase_angle = (double ***)AllocMem(opslquant*sizeof(double **));
    recv_phase_ang_nom = (double ***)AllocMem(opslquant*sizeof(double **));
    for (psd_icnt = 0; psd_icnt < opslquant; psd_icnt++) {
        recv_phase_angle[psd_icnt] = (double **)AllocMem(intleaves* sizeof(double *));
        recv_phase_ang_nom[psd_icnt] = (double **)AllocMem(intleaves*sizeof(double *)); 
        for (psd_jcnt = 0; psd_jcnt < intleaves; psd_jcnt++)
        {
            recv_phase_angle[psd_icnt][psd_jcnt] = (double *)AllocMem(tot_etl*sizeof(double));
            recv_phase_ang_nom[psd_icnt][psd_jcnt] = (double *)AllocMem(tot_etl*sizeof(double));
        }
    }

    rf_phase_spgr = (int **)AllocMem(opslquant*sizeof(int *));
    for (psd_icnt = 0; psd_icnt < opslquant; psd_icnt++) {
	rf_phase_spgr[psd_icnt] = (int *)AllocMem(intleaves*sizeof(int));
    }

@inline HoecCorr.e HoecAllocateMemPG

    echotrainxtr = (WF_PULSE **)AllocNode(tot_etl*sizeof(WF_PULSE *));
    echotrainrba = (WF_PULSE **)AllocNode(tot_etl*sizeof(WF_PULSE *));
    echotrainramp1 = (int *)AllocNode(tot_etl*sizeof(int));
    echotrainramp2 = (int *)AllocNode(tot_etl*sizeof(int));

    gy1f = (int *)AllocNode((intleaves+1)*sizeof(int));
    gymn = (int *)AllocNode((intleaves+1)*sizeof(int));
    view1st = (int *)AllocNode((intleaves+1)*sizeof(int));
    viewskip = (int *)AllocNode((intleaves+1)*sizeof(int));
    tf = (int *)AllocNode((intleaves+1)*sizeof(int));
    rfpol = (int *)AllocNode((intleaves+1)*sizeof(int));
    gradpol = (int *)AllocNode((intleaves+1)*sizeof(int));
    blippol = (int *)AllocNode((intleaves+1)*sizeof(int));
    b0ditherval = (float *)AllocNode((opslquant+1)*sizeof(float));
    delayval = (float *)AllocNode((opslquant+1)*sizeof(float));
    gldelaycval = (int *)AllocNode((opslquant+1)*sizeof(int));
    gldelayfval = (float *)AllocNode((opslquant+1)*sizeof(float));

    /* t1flair_stir */
    if (t1flair_flag == PSD_ON)
    {
        physical_slice_acq_seq_reg = (int *)AllocNode((slquant1 + 2)*sizeof(int));
        physical_slice_acq_seq_enh = (int *)AllocNode((slquant1 + 2)*sizeof(int));
        real_slice_acq_seq = (int **)AllocNode((acqs + 2)*sizeof(int*));

        T1flair_slice_flag = (int **)AllocNode((acqs + 2)*sizeof(int*));
        for (i = 0; i < acqs + 2; i++)
        {
            real_slice_acq_seq[i] = (int *)AllocNode((slquant1 + 1)*sizeof(int));
            T1flair_slice_flag[i] = (int *)AllocNode((slquant1 + 1)*sizeof(int));
        }
    }

    if (opdiffuse == PSD_ON && diff_order_flag)
    {
        if (flair_flag == PSD_OFF)
        {
            diff_order_nslices = (mux_flag?mux_slquant:slquant1) * acqs;
        }
        else
        {
            diff_order_nslices = false_slquant1 * false_acqs * acqs;
        }

        if ((diff_order_flag == 1) || (diff_order_flag == 2 && tensor_flag == PSD_ON))
        {
            diff_order_size = pass_reps;
        }
        else if (diff_order_flag == 2)
        {
            diff_order_size = (int)(opdifnext2 * opdifnumt2 + num_dif * total_difnex + (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag?rpg_in_scan_num:0));
            diff_order_pass = (int *)AllocNode(diff_order_size*sizeof(int));
            diff_order_nex = (int *)AllocNode(diff_order_size*sizeof(int));
            diff_order_dif = (int *)AllocNode(diff_order_size*sizeof(int));
        }

        /* diff_order[pass][slice] */
        diff_order = (int **)AllocNode(diff_order_size*sizeof(int *));

        for (psd_icnt = 0; psd_icnt < diff_order_size; psd_icnt++)
        {
            diff_order[psd_icnt] = (int *)AllocNode(diff_order_nslices*sizeof(int));
        }

        if ( FAILURE == set_diff_order() )
        {
            return FAILURE;
        }
    }

#ifdef ERMES_DEBUG
    debugileave = 1;
#else
    debugileave = 0;
#endif
  
    switch (ky_dir) {
    case PSD_TOP_DOWN:
	readpolar = 1;
	break;
    case PSD_BOTTOM_UP:
    case PSD_CENTER_OUT:
    default:
	if (etl % 2 == 1)  /* odd */
            readpolar = 1;
	else               /* even */
            readpolar = -1;  
	break;
    }

    /* BJM: MRIge60610 - added num_overscan */ 
    /* MRIge89403: added one more argument for EPI internal ref
       scan but set to 0 */
    if (FAILURE == ileaveinit( fullk_nframes, ky_dir,
                               intleaves, ep_alt, readpolar, blippolar, debugileave, ia_rf1,
                               ia_gyb, pepolar, etl, seq_data, delt, tfon, fract_ky,
                               ky_offset, num_overscan, endview_iamp, esp, tsp, rhfrsize,
                               a_gxw, rhrcxres, slquant1, lpfval, iref_etl, gy1f, view1st,
                               viewskip, tf, rfpol, gradpol, blippol, &mintf ))
    {
        return FAILURE;
    }

    for (ileave = 0; ileave < intleaves; ileave++){
        if (ygmn_type == CALC_GMN1) {
            tempa = a_gy1a * (float)gy1f[ileave]/(float)endview_iamp;
            tempb = a_gy1b * (float)gy1f[ileave]/(float)endview_iamp;
	  
            amppwygmn(gyb_tot_0thmoment, gyb_tot_1stmoment, pw_gy1a, pw_gy1,
                      pw_gy1d, tempa, tempb, loggrd.ty_xyz, (float)loggrd.yrt*loggrd.scale_3axis_risetime,
                      1, &pw_gymn1a, &pw_gymn1, &pw_gymn1d, &temp_gmnamp);
	  
            gymn[ileave] = (int)((float)ia_gymn1 * a_gymn1/ temp_gmnamp);
          
            if (debugileave == 1)
                printf("gymn[%d] = %d, temp_gmnamp = %f\n",
                       ileave,gymn[ileave],temp_gmnamp);
        } else
            gymn[ileave] = 0;
    }


#ifdef IPG
    /*
     * Execute this code only on the Tgt side
     */
    rdx = dx;
    rdy = dy;
    rdz = dz;

    dlyx = gldelayx;
    dlyy = gldelayy;
    dlyz = gldelayz;

    b0Dither_ifile(b0ditherval, ditheron, rdx, rdy, rdz, a_gxw, esp, opslquant,
                   debugdither, rsprot_unscaled, ccinx, cciny, ccinz, esp_in, 
                   fesp_in, &g0, &num_elements, &file_exist);

    calcdelay(delayval, delayon, dlyx, dlyy, dlyz,
              &defaultdelay, opslquant, opgradmode,debugdelay, rsprot_unscaled);

    for (slice = 0; slice < opslquant; slice++)
        delayval[slice] += dacq_adjust;

    if (oppseq == PSD_SPGR)
	spgr_flag = 1;
    else
	spgr_flag = 0;

    for (slice = 0; slice < opslquant; slice++) {
        for (ileave = 0; ileave < intleaves; ileave++)
            rf_phase_spgr[slice][ileave] = 0;  /* call spgr function in future */
    }
#endif /* IPG */

    /*RTB0 correction*/
    if(rtb0_flag)
    {
        SSPPACKET(dynr1,tlead-pw_dynr1-GRAD_UPDATE_TIME,pw_dynr1,sspwm_dynr1,);
    }

    WAIT(XGRAD, x_td0, tlead, pw_x_td0);
    WAIT(YGRAD, y_td0, tlead, pw_y_td0);
    WAIT(ZGRAD, z_td0, tlead, pw_z_td0);
    WAIT(RHO, rho_td0, tlead, pw_rho_td0);
    WAIT(THETA, theta_td0, tlead, pw_theta_td0); /* YMSmr07445 */
    WAIT(OMEGA, omega_td0, tlead, pw_omega_td0);
    WAIT(SSP, ssp_td0, tlead, pw_ssp_td0);
  
#ifdef IPG
    for (slice = 0; slice < opslquant; slice++) 
    {
        if (delayval[slice] < 0.0)
	    gldelaycval[slice] = (int)(delayval[slice] - 0.5);
        else
	    gldelaycval[slice] = (int)(delayval[slice] + 0.5);
    }
#endif /* IPG */  

    /* Spatial Sat *******************************************************/
    sp_satindex = 0;
    SpSatPG(vrgsat,sp_satstart, &sp_satindex, sp_satcard_loc);
  
    /* Chem Sat **********************************************************/
    cs_satindex = 0;
    if (cs_sat)
	ChemSatPG(cs_satstart, &cs_satindex);

    if (rfov_flag)
    {
        if(FAILURE == rfov_pulsegen())
        {
            return FAILURE;
        }
    }
    else if (mux_flag)
    {
        if(FAILURE == Multiband_pulsegen_rf1())
        {
            return FAILURE;
        }
    }
    else
    {
        /* spsp 90 RF slice select pulse *******************************************/
        if(rftype && (!ss_rf1))
        {
            temp_wave_space = (short *)AllocNode(res_rf1*sizeof(short));
            uextwave(temp_wave_space, res_rf1, ssrffile);
        }

        temp_res = res_rf1;
        if (rfpulseInfo[RF1_SLOT].change == PSD_ON)  /* set to new resolution */
            res_rf1 = rfpulseInfo[RF1_SLOT].newres;

        /* set rfunblank_bits[2] so that addrfbits in sliceselz does not
           unblank the receiver - see EpicConf.c for defaults. Will unblank
           the receiver later - MRIge28778 */ /*CLARIFY*/

        leaveReceiverBlanked();

        EFFSLICESELZ_SPSP(rf1, pos_start+pw_gzrf1a, pw_rf1, opslthick,
                          flip_rf1, cyc_rf1, gztype, res_rf1,
                          ssgzfile, (rftype && ss_rf1), res_rf1,
                          ssrffile, thetatype, 0, loggrd, ss_rf_wait);

        /* reset the bit */
        initializeReceiverUnblankPacket();

        if(rftype && (!ss_rf1))
        {
             /* Stretch rf pw if needed */
            if (rfpulseInfo[RF1_SLOT].change==PSD_ON) 
            {
                wave_space = (short *)AllocNode(rfpulseInfo[RF1_SLOT].newres*sizeof(short));
                stretchpulse((int)temp_res, (int)rfpulseInfo[RF1_SLOT].newres,temp_wave_space,wave_space);
                FreeNode(temp_wave_space);
            } 
            else
            {
                wave_space = temp_wave_space;
            }

            /* move immediately into permanent memory */
            movewaveimm(wave_space, &rf1, (int)0, res_rf1, TOHARDWARE);
            FreeNode(wave_space);
        }

        if (rfpulseInfo[RF1_SLOT].change == PSD_ON)  /* change back for ext. file */
            res_rf1 = temp_res;
    }

    /* 180 RF refocusing pulse ********************************************/
    if (oppseq == PSD_SE) {
        Rf2Location[0] = RUP_GRD((int)(pend(&rf1,"rf1",0) - rfExIso  + opte/2
                                       - pw_rf2/2) - psd_rf_wait);  /* Find start loc of 180s */
 
        /* DTI */
        if (PSD_ON == dualspinecho_flag)
        {
            /* BJM: place the 180's at t & 3t with echo center at 4t... */
            /*      Note: this increases the TE slightly since minTE = 4* azminb  */
            Rf2Location[1] = RUP_GRD((int)(pend(&rf1,"rf1",0) - rfExIso + opte/4 - pw_rf2/2) - psd_rf_wait);
            Rf2Location[2] = RUP_GRD((int)(pend(&rf1,"rf1",0) - rfExIso + 3*opte/4 - pw_rf2/2) - psd_rf_wait);
        }

        /* MRIge58235: moved uextwave to here so the file read from disk is always read with orig. res_rf2 */
        if (PSD_OFF == mux_flag)
        {
            strcpy(ext_filename, "rfse1b4.rho");
        }
        else
        {
            sprintf(ext_filename, "verse_sb%d_rf2.rho",mux_slices_rf2);
        }

        /* Create some RHO waveform space, read in the
       se1b4 spin echo 180 to local memory, and then move
       the local memory to the reserved RHO memory.
        */
        temp_wave_space = (short *)AllocNode(res_rf2*sizeof(short));
        uextwave(temp_wave_space, res_rf2, ext_filename);

        /* MRIge58235: save orig. res_rf2 for scaling */
        short orig_res;

        orig_res = res_rf2;
        if (rfpulseInfo[RF2_SLOT].change==PSD_ON)
            res_rf2 = rfpulseInfo[RF2_SLOT].newres;     /* Set to new resolution */

        /* set rfunblank_bits[2] so that addrfbits in sliceselz does not
               unblank the receiver - see EpicConf.c for defaults. Will unblank
               the receiver later - MRIge28778 */
        leaveReceiverBlanked();

        /*  180 slice sel pulse  */
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            SLICESELZ(rf2, Rf2Location[0], pw_rf2,
                      opslthick, flip_rf2, cyc_rf2, TYPNDEF, loggrd);

        } else {
            /* If pw_rf2 is scaled...DTI BJM (dsp) */
            if (PSD_ON == dualspinecho_flag)
            {
                res_rf2left = res_rf2;
                res_rf2right = res_rf2left;
            }

            SLICESELZ(rf2left, Rf2Location[1], pw_rf2left,
                      opslthick, flip_rf2left, cyc_rf2, TYPNDEF, loggrd);


            SLICESELZ(rf2right, Rf2Location[2], pw_rf2right,
                      opslthick, flip_rf2right, cyc_rf2, TYPNDEF, loggrd);
        }

        if(mux_flag)
        {
            if(FAILURE == Multiband_pulsegen_rf2(Rf2Location, temp_wave_space))
            {
                return FAILURE;
            }
            FreeNode(temp_wave_space);
        }
        else
        {
            /* reset the bit */
            initializeReceiverUnblankPacket();

            /* Stretch rf pw if needed */
            if (rfpulseInfo[RF2_SLOT].change==PSD_ON) {
                wave_space = (short *)AllocNode(rfpulseInfo[RF2_SLOT].newres*
                                                sizeof(short));
                stretchpulse((int)orig_res, (int)rfpulseInfo[RF2_SLOT].newres,
                             temp_wave_space,wave_space);
                FreeNode(temp_wave_space);
            } else
                wave_space = temp_wave_space;

            /* Assign temporary board memory and move immediately into permanent
               memory */
            res_rf2se1b4 = res_rf2;
            SPACESAVER(RHO, rf2se1b4, res_rf2);
            movewaveimm(wave_space, &rf2se1b4, (int)0, res_rf2, TOHARDWARE);
            FreeNode(wave_space);
        }

        /* MRIge58235: reset res_rf2 after scaling */
        res_rf2 = orig_res;

        /* DTI BJM (dsp) */
        if (PSD_ON == dualspinecho_flag)
        {
            res_rf2left = res_rf2;
            res_rf2right = res_rf2left;
        }

        if (innerVol == PSD_ON)
        {
            TRAPEZOID(YGRAD, gyrf2iv, Rf2Location[0], 0.0, TYPNDEF, loggrd);
            ia_gzrf2 = 0;
        }

        /* DTI BJM (dsp) */
        if (PSD_OFF == dualspinecho_flag)
        {
            setphase((float)(PI/-2.0), &rf2, 0);       /* Apply 90 phase shift to  180 */
        } else {
            setphase((float)(PI/-2.0), &rf2right, 0);  /* Apply 90 phase shift to  180 */
            setphase((float)(PI/-2.0), &rf2left, 0);   /* Apply 90 phase shift to  180 */
        }

        attenflagon(&rf1, 0);                 /* Assert ESSP flag on rf1 pulse */

        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            attenflagon(&rf2, 0);                 /* Assert ESSP flag on 1st rf2 */
        } else {
            attenflagon(&rf2right, 0);            /* Assert ESSP flag on rigth rf2 */
        }

        /* Z crushers (echo 1) ***********************************************/
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            TRAPEZOID(ZGRADB, gzrf2l1,
                      pbeg(&gzrf2,"gzrf2", 0)-(pw_gzrf2l1+pw_gzrf2l1d), 0, TYPNDEF,
                      loggrd);

            TRAPEZOID(ZGRADB, gzrf2r1, pend(&gzrf2,"gzrf2d",0), 0, TYPNDEF, loggrd);
            if( PSD_ON == xygradCrusherFlag ) {
                TRAPEZOID(XGRAD, xgradCrusherL,
                          pbeg(&gzrf2,"gzrf2",0) -
                          (pw_xgradCrusherL+pw_xgradCrusherLd),
                          0,TYPNDEF,loggrd);

                TRAPEZOID(XGRAD, xgradCrusherR,
                          pend(&gzrf2,"gzrf2",0) +
                          pw_xgradCrusherRa,0,TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradCrusherL,
                          pbeg(&gzrf2,"gzrf2",0) -
                          (pw_ygradCrusherL+pw_ygradCrusherLd),
                          0,TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradCrusherR,
                          pend(&gzrf2,"gzrf2",0) +
                          pw_ygradCrusherRa,0,TYPNDEF,loggrd);
            }
        } else {
            TRAPEZOID(ZGRADB, gzrf2leftl1,
                      pbeg(&gzrf2left,"gzrf2left", 0) - 
                      (pw_gzrf2leftl1+pw_gzrf2leftl1d), 0, TYPNDEF, loggrd);

            TRAPEZOID(ZGRADB, gzrf2leftr1, 
                      pend(&gzrf2left,"gzrf2leftd",0), 0, TYPNDEF, loggrd);

            TRAPEZOID(ZGRADB, gzrf2rightl1,
                      pbeg(&gzrf2right,"gzrf2right", 0) -
                      (pw_gzrf2rightl1+pw_gzrf2rightl1d), 0, TYPNDEF, loggrd);

            TRAPEZOID(ZGRADB, gzrf2rightr1, 
                      pend(&gzrf2right,"gzrf2rightd",0), 0, TYPNDEF, loggrd);

            /* MRIhc05227 */
            /* Create Crushers on Left and Right 180s for X & Y axes */ 
            if( PSD_ON == xygradRightCrusherFlag ) { 
                TRAPEZOID(XGRAD, xgradRightCrusherL, 
                          pbeg(&gzrf2right,"gzrf2right",0) - 
                          (pw_xgradRightCrusherL+pw_xgradRightCrusherLd),
                          0,TYPNDEF,loggrd);

                TRAPEZOID(XGRAD, xgradRightCrusherR, 
                          pend(&gzrf2right,"gzrf2right",0) +
                          pw_xgradRightCrusherRa,0,TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradRightCrusherL,
                          pbeg(&gzrf2right,"gzrf2right",0) -
                          (pw_ygradRightCrusherL+pw_ygradRightCrusherLd),
                          0,TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradRightCrusherR,
                          pend(&gzrf2right,"gzrf2right",0) +
                          pw_ygradRightCrusherRa,0,TYPNDEF,loggrd);
            }
            if( PSD_ON == xygradLeftCrusherFlag ) {
                TRAPEZOID(XGRAD, xgradLeftCrusherL,
                          pbeg(&gzrf2left,"gzrf2left",0) -
                          (pw_xgradLeftCrusherL+pw_xgradLeftCrusherLd),0,
                          TYPNDEF,loggrd);

                TRAPEZOID(XGRAD, xgradLeftCrusherR,
                          pend(&gzrf2left,"gzrf2left",0) +
                          pw_xgradLeftCrusherRa,0,TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradLeftCrusherL,
                          pbeg(&gzrf2left,"gzrf2left",0) -
                          (pw_ygradLeftCrusherL+pw_ygradLeftCrusherLd),0,
                          TYPNDEF,loggrd);

                TRAPEZOID(YGRAD, ygradLeftCrusherR,
                          pend(&gzrf2left,"gzrf2left",0) +
                          pw_ygradLeftCrusherRa,0,TYPNDEF,loggrd);
            }
        }   
    } /* end PSD_SE check */

    /***********************************************************************/
    /* X EPI readout train                                                 */
    /***********************************************************************/
  
    /* For now assume a simple retiling. */
    if (fract_ky == PSD_FRACT_KY) {
	echoOffset  = num_overscan/intleaves;
    } else {
	if (ky_dir == PSD_TOP_DOWN || ky_dir == PSD_BOTTOM_UP)
            echoOffset  = fullk_nframes/intleaves/2;
	else
            echoOffset  = 0;
    }
  
    if (rampsamp == PSD_ON) {  /* Ramp sampling on CERD, HOUP */
        if ( mux_flag == PSD_ON && use_slice_fov_shift_blips == PSD_ON ) {
            dacq_offset = pkt_delay + pw_gxwad - (int)IMax(2, (int)(fbhw*((float)pw_gyb/2.0 + (float)pw_gybd) + 0.5),
                                                 (int)(fbhw*((float)pw_gzb/2.0 + (float)pw_gzbd) + 0.5));
        } else {
            dacq_offset = pkt_delay + pw_gxwad - (int)(fbhw*((float)pw_gyb/2.0 +
                                                             (float)pw_gybd) + 0.5);
        }
    } else {
        dacq_offset = pkt_delay;
    }

    /* MRIge58023 & 58033 need to RUP_GRD entire expression */
    if (intleaves == fullk_nframes)
    {
        tempx = RUP_GRD((int)(pend(&rf1,"rf1",0) - rfExIso + opte -
                              pw_gxw/2 - pw_gxwl - ky_offset*esp/intleaves));
    }
    else
    {
        tempx = RUP_GRD((int)(pend(&rf1,"rf1",0) - rfExIso + opte -
                              echoOffset * esp - ky_offset*esp/intleaves));
    }

    tempy = tempx + gydelay;
    tempz = tempx;
    tempx += gxdelay;
  
    if(iref_etl > 0)
    {
        if(rtb0_flag && dpc_flag)
        {   
            tempiref = pendall(&rf1, 0) + IMax(2, pw_gz1_tot, rfupd + 4us + rtb0_minintervalb4acq)+
                       rtb0_acq_delay+esp+pw_gxiref1_tot;
        }
        else
        {
            tempiref = pendall(&rf1, 0) + IMax(3, pw_gz1_tot, rfupd+4us+pw_gxiref1_tot, pw_gyex1_tot);
        }
        tempiref = RUP_GRD(tempiref);
    }

    /* MRIge89403: added one more argument for EPI internal ref
     * but set it to 0 */
    /* EP_TRAIN */
    /* internref: use tot_etl instead of etl; added iref_etl */
    EP_TRAIN((LONG)tempx + pw_gxwad,
             tot_etl,
             0,
             tot_etl,
             fast_rec,
             scanslot,
             hsdab > 0 ? 0:1,
             psd_grd_wait - dacq_offset,
             pg_tsp,
             dab_offset,
             xtr_offset,
             iref_etl,
             epiloggrd,
             1,
             (iref_etl > 0 ? tempiref + pw_gxwad : DEFAULTPOS));

    /* unblank receiver rcvr_ub_off us prior to first xtr/dab/rba packet */
    /*  rec_unblank_pack[2] = SSPD+RUBL;*/
    getssppulse(&(echotrainxtr[0]), &(echotrain[0]), "xtr", 0);
    rcvrunblankpos = echotrainxtr[0]->inst_hdr_tail->start;
    rcvrunblankpos += rcvr_ub_off;
    RCVRUNBLANK(rec_unblank, rcvrunblankpos,);
    if(iref_etl>0)
    {
        getssppulse(&(echotrainxtr[iref_etl]), &(echotrain[iref_etl]), "xtr", 0);
        rcvrunblankpos = echotrainxtr[iref_etl]->inst_hdr_tail->start;
        rcvrunblankpos += rcvr_ub_off;
        RCVRUNBLANK(rec_unblank3, rcvrunblankpos,);
    }

    if (tot_etl % 2 == 1) {
        getbeta(&betax, XGRAD, &epiloggrd);
        pulsePos = pend(&gxw, "gxw", tot_etl-1);
        createramp(&gxwde, XGRAD, pw_gxwad, -max_pg_wamp, 0,
                   (short)(maxGradRes*(pw_gxwad)/GRAD_UPDATE_TIME), betax);
        createinstr(&gxwde, (LONG)pulsePos, pw_gxwad, -ia_gxw-ia_gx_dwi);
        pulsePos += pw_gxwad;
    }

    /***********************************************************************/
    /* X dephaser                                                          */
    /***********************************************************************/
  
    if (gx1pos == PSD_POST_180)
        temp1 = RUP_GRD((int)(pbeg(&gxw,"gxw",iref_etl) - (pw_gxwad + pw_gx1a +
            pw_gx1 + pw_gx1d)));
    else
        temp1 = RUP_GRD((int)(pend(&gzrf1,"gzrf1",0) + pw_gx1a + pw_wgx + rfupd));

    pg_beta = loggrd.xbeta;

    pulsename(&gx1a,"gx1a");
    createramp(&gx1a,XGRAD,pw_gx1a,(short)0,
               max_pg_wamp,(short)(maxGradRes*(pw_gx1a/
                                               GRAD_UPDATE_TIME)),
               pg_beta);
    createinstr(&gx1a, (LONG)temp1, pw_gx1a, ia_gx1);

    if (pw_gx1 >= GRAD_UPDATE_TIME) {
        pulsename(&gx1,"gx1");
        createconst(&gx1,XGRAD,pw_gx1,max_pg_wamp);
        createinstr( &gx1,(LONG)(LONG)temp1+pw_gx1a,
                     pw_gx1,ia_gx1);
    }

    pulsename(&gx1d, "gx1d");
    if (single_ramp_gx1d == PSD_ON) {   /* Single ramp for gx1 decay into gxw
                                           attack */
        createramp(&gx1d, XGRAD, pw_gxwad, max_pg_wamp, -max_pg_wamp,
                   (short)(maxGradRes*(2*pw_gxwad/GRAD_UPDATE_TIME)), pg_beta);
        createinstr(&gx1d, (LONG)(temp1+pw_gx1a+pw_gx1), 2*pw_gxwad, ia_gx1);
    } else {                     /* decay ramp for gx1 */
        createramp(&gx1d,XGRAD,pw_gx1d,max_pg_wamp,
                   (short)0,(short)(maxGradRes*(pw_gx1d/GRAD_UPDATE_TIME)),
                   pg_beta);
        createinstr( &gx1d,(LONG)((LONG)temp1+pw_gx1a+pw_gx1),
                     pw_gx1d,ia_gx1);

        pulsename(&gxwa, "gxwa");  /* attack ramp for epi train */
        createramp(&gxwa, XGRAD, pw_gxwad, (short)0, max_pg_wamp,
                   (short)(maxGradRes*(pw_gxwad/GRAD_UPDATE_TIME)), pg_beta);
        if(iref_etl > 0)
        {
            tempx = tempiref;
        }
        if ( tot_etl%2 == 0 )
            createinstr(&gxwa, (LONG)tempx, pw_gxwad, -ia_gxw-ia_gx_dwi);
        else
            createinstr(&gxwa, (LONG)tempx, pw_gxwad, ia_gxw-ia_gx_dwi);
    }

    /*RTB0 correction*/
    if(rtb0_flag)
    {
        temp2 = pendall(&rf1, 0) + IMax(2, pw_gz1_tot, rfupd + 4us + rtb0_minintervalb4acq)+rtb0_acq_delay;
        ACQUIREDATA(rtb0echo, temp2, DEFAULTPOS, DEFAULTPOS, DABNORM);
        attenflagon( &(rtb0echo), 0 );

        getssppulse(&(rtb0echoxtr), &(rtb0echo), "xtr", 0);
        rcvrunblankpos = rtb0echoxtr->inst_hdr_tail->start;
        rcvrunblankpos += rcvr_ub_off;
        RCVRUNBLANK(rec_unblank2, rcvrunblankpos,);

        temp2 += esp;
    }

    /* Hyperscan and diff DAB packet */
    if (hsdab > 0) {
        if (rtb0_flag == PSD_OFF)
        {
            temp2 = pendall(&rf1, 0) + rfupd + 4us;  /* 4us for unblank receiver */
        }

        if(hsdab == 1)
	        HSDAB(hyperdab, temp2);
        else
            DIFFDAB(diffdab, temp2);
    }  

    if(iref_etl > 0)
    {
        TRAPEZOID(XGRAD, gxiref1, tempiref-pw_gxiref1_tot+pw_gxiref1a, 0, TYPNDEF, loggrd);    
        TRAPEZOID(XGRAD, gxirefr, tempiref+pw_gxiref_tot+pw_gxirefra, 0, TYPNDEF, loggrd);
    }

    /* Set readout polarity to gradpol[ileave] value */
    ileave = 0;
    setreadpolarity();

    /* If we don't reset frequency and phase on each view, then it is best
       to use a single packet at the beginning of the frame - one that doesn't
       shift with interleave.  This is because we want the constant part of Ahn
       correction to see continuous phase evolution across the views. */
 
    if (oppseq == PSD_SE) {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            temp2 = pendall(&rf2, 0) + rfupd + 4us;  /* 4us for unblank receiver */
        } else {
            temp2 = pendall(&rf2right, 0) + rfupd + 4us;  /* 4us for unblank receiver */
        }
    } else {
        temp2 = pendall(&rf1, 0) + rfupd + 4us;  /* 4us for unblank receiver */
    }

    /* Y prephaser ************************************************************/
    if (gy1pos == PSD_POST_180) {
	temp1 = pbeg(&gxw, "gxw", iref_etl) - pw_gxwad - pw_gy1_tot;
	temp1 = RDN_GRD(temp1);
    } else {
	temp1 = RDN_GRD(pend(&rf1,"rf1",0) + rfupd);
    }

    TRAPEZOID2(YGRAD, gy1, temp1, TRAP_ALL_SLOPED,,,endview_scale, loggrd);

    if (ygmn_type == CALC_GMN1) {
        temp1 = pbeg(&gy1a, "gy1a", 0) - pw_gymn2 - pw_gymn2d;
        TRAPEZOID(YGRAD, gymn2, temp1, 0, TYPNDEF, loggrd);
        temp1 = pbeg(&gy1a, "gy1a", 0) - pw_gymn2_tot - pw_gymn1 - pw_gymn1d;
        TRAPEZOID(YGRAD, gymn1, temp1, 0, TYPNDEF, loggrd);
    }

    /* Z prephaser ************************************************************/
    if (oppseq != PSD_SE || zgmn_type == CALC_GMN1 || rtb0_flag || dpc_flag || ((oppseq == PSD_SE) && mux_flag && (use_slice_fov_shift_blips) && (mux_slices_rf1>1)) ) {
        if(ss_rf1 == PSD_ON)
        {
#if defined(IPG_TGT) || defined(MGD_TGT)
            temp1 = RDN_GRD(pend(&gzrf1, "gzrf1", gzrf1.ninsts-1) + pw_gz1a);
#elif defined(HOST_TGT)
            temp1 = RDN_GRD(pend(&gzrf1d, "gzrf1d", gzrf1.ninsts-1) + pw_gz1a);
#endif
        }
        else
        {
            temp1 = RDN_GRD(pendall(&gzrf1, gzrf1.ninsts-1) + pw_gz1a);
        }
	TRAPEZOID( ZGRAD, gz1, temp1, 0, TYPNDEF, loggrd);
	if (zgmn_type == CALC_GMN1) {
            temp1 += (pw_gz1 + pw_gz1d + pw_gzmna);
            TRAPEZOID( ZGRAD, gzmn, temp1, 0, TYPNDEF, loggrd); 
	}
    }

    /* Added for Inversion.e */
    SPACESAVER(RHO, rf2se1, PSD_FSE_RF2_R);

    /* X diffusion pulses *****************************************************/
    /* DTI */
    if ((oppseq == PSD_SE && opdiffuse == PSD_ON) || tensor_flag == PSD_ON) {
      
        if (PSD_OFF == dualspinecho_flag)
        {
	    if(ftde_flag == PSD_OFF){ /* granty edit to add full time diffusion encoding option */
            	if(xygradCrusherFlag == PSD_ON ) {
                	tempx = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&xgradCrusherL,"xgradCrusherLa",0)) - pw_gxdl - pw_gxdld - pw_wgxdl);
            	} else {
                	tempx = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gxdl - pw_gxdld - pw_wgxdl);
            	}
            }else{
            	if(xygradCrusherFlag == PSD_ON ) {
                	tempx = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&xgradCrusherL,"xgradCrusherLa",0)) - pw_gxdl - pw_gxdld - pw_wgxdl - pw_gxde - pw_gxded - pw_gxdea);
            	} else {
                	tempx = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gxdl - pw_gxdld - pw_wgxdl - pw_gxde - pw_gxded - pw_gxdea);
            	}
		TRAPEZOID(XGRAD, gxde, tempx + pw_gxdla + pw_gxdl + pw_gxdld, 0, TYPNDEF, loggrd);
#if defined(HOST_TGT)
            	setiamptiter(xamp_iters, cur_num_iters, &gxde, 0, 1);
#endif
	   }
            	TRAPEZOID(XGRAD, gxdl, tempx, 0, TYPNDEF, loggrd);


#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdl, 0, 1);
#endif
            if(xygradCrusherFlag == PSD_ON ) {
                tempx = RUP_GRD(IMax(2,pend(&gzrf2r1,"gzrf2r1d",0),pend(&xgradCrusherR,"xgradCrusherRd",0)) + pw_gxdra + pw_wgxdr);
            } else {
                tempx = RUP_GRD(pend(&gzrf2r1,"gzrf2r1d",0) + pw_gxdra + pw_wgxdr);
            }
            TRAPEZOID(XGRAD, gxdr, tempx, 0, TYPNDEF, loggrd);
 
#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdr, 0, 1);
#endif

        } else {
            /*MRIhc05259*/
            if(xygradLeftCrusherFlag == PSD_ON ) {
                tempx = RUP_GRD(IMin(2,pbeg(&gzrf2leftl1,"gzrf2leftl1a",0),
                                pbeg(&xgradLeftCrusherL,"xgradLeftCrusherLa",0))
                                - pw_gxdl1 - pw_gxdl1d - pw_wgxdl1);
            } else {
                tempx = RUP_GRD(pbeg(&gzrf2leftl1,"gzrf2leftl1a",0) -
                                pw_gxdl1 - pw_gxdl1d - pw_wgxdl1);
            }
/* SVBranch:HCSDM00259119  -  dse enh */        
@inline eco_mpg.e left_xdiff_dse            
            TRAPEZOID(XGRAD, gxdl1, tempx, 0, TYPNDEF, loggrd);
         
#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdl1, 0, 1);
#endif

            if(xygradLeftCrusherFlag == PSD_ON ) {
                tempx = RUP_GRD(IMax(2,pend(&gzrf2leftr1,"gzrf2leftr1d",0),
                                pend(&xgradLeftCrusherR,"xgradLeftCrusherRd",0))
                                + pw_gxdr1a + pw_wgxdr1);
            } else {
                tempx = RUP_GRD(pend(&gzrf2leftr1,"gzrf2leftr1d",0) +
                                pw_gxdr1a + pw_wgxdr1);
            }
            TRAPEZOID(XGRAD, gxdr1, tempx, 0, TYPNDEF, loggrd);
         
#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdr1, 0, -1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) { 
                tempx = RUP_GRD(IMin(2,pbeg(&gzrf2rightl1,"gzrf2rightl1a",0),
                            pbeg(&xgradRightCrusherL,"xgradRightCrusherLa",0))
                            - pw_gxdl2 - pw_gxdl2d - pw_wgxdl2);
            } else {
                tempx = RUP_GRD(pbeg(&gzrf2rightl1,"gzrf2rightl1a",0) 
                                - pw_gxdl2 - pw_gxdl2d - pw_wgxdl2);
            }
            TRAPEZOID(XGRAD, gxdl2, tempx, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdl2, 0, 1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) {
                tempx = RUP_GRD(IMax(2,pend(&gzrf2rightr1,"gzrf2rightr1d",0),
                            pend(&xgradRightCrusherR,"xgradRightCrusherRd",0))
                            + pw_gxdr2a + pw_wgxdr2);
            } else {
                tempx = RUP_GRD(pend(&gzrf2rightr1,"gzrf2rightr1d",0) 
                                + pw_gxdr2a + pw_wgxdr2);
            }
            TRAPEZOID(XGRAD, gxdr2, tempx, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(xamp_iters, cur_num_iters, &gxdr2, 0, -1);
#endif

        }
    }

    /* X killer pulse *********************************************************/
    if (eosxkiller == PSD_ON) {
	tempx = RUP_GRD(pend(&gxwde,"gxwde",0) + gkdelay + pw_gxka);
	TRAPEZOID(XGRAD, gxk, tempx, 0, TYPNDEF, loggrd);
    }
  
    /* Y diffusion pulses *****************************************************/
    /* DTI */
    if ((oppseq == PSD_SE && opdiffuse == PSD_ON) || tensor_flag == PSD_ON) {
        if (PSD_OFF == dualspinecho_flag)
        {/* granty maybe */
	    if(ftde_flag == PSD_OFF){
            	if(xygradCrusherFlag == PSD_ON ) {
                	tempy = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&ygradCrusherL,"ygradCrusherLa",0)) - pw_gydl - pw_gydld - pw_wgydl);
            	} else {
                	tempy = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gydl - pw_gydld - pw_wgydl);
            	}
	    }else{
            	if(xygradCrusherFlag == PSD_ON ) {
                	tempy = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&ygradCrusherL,"ygradCrusherLa",0)) - pw_gydl - pw_gydld - pw_wgydl - pw_gyde - pw_gyded - pw_gydea);
            	} else {
                	tempy = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gydl - pw_gydld - pw_wgydl - pw_gyde - pw_gyded - pw_gydea);
            	}
            	TRAPEZOID(YGRAD, gyde, tempy + pw_gydla + pw_gydl + pw_gydld, 0, TYPNDEF, loggrd);
         
#if defined(HOST_TGT)
            	setiamptiter(yamp_iters, cur_num_iters, &gydl, 0, 1);
#endif
	    }
            TRAPEZOID(YGRAD, gydl, tempy, 0, TYPNDEF, loggrd);
         
#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydl, 0, 1);
#endif

            if(xygradCrusherFlag == PSD_ON ) {
                tempy = RUP_GRD(IMax(2,pend(&gzrf2r1,"gzrf2r1d",0),pend(&ygradCrusherR,"ygradCrusherRd",0)) + pw_gydra + pw_wgydr);
            } else {
                tempy = RUP_GRD(pend(&gzrf2r1,"gzrf2r1d",0) + pw_gydra + pw_wgydr);
            }
            TRAPEZOID(YGRAD, gydr, tempy, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydr, 0, 1);
#endif

        } else {
            /*MRIhc05259*/
            if(xygradLeftCrusherFlag == PSD_ON ) {
                tempy = RUP_GRD(IMin(2,pbeg(&gzrf2leftl1,"gzrf2leftl1a",0),
                                pbeg(&xgradLeftCrusherL,"xgradLeftCrusherLa",0))
                                - pw_gydl1 - pw_gydl1d - pw_wgydl1);
            } else {
                tempy = RUP_GRD(pbeg(&gzrf2leftl1,"gzrf2leftl1a",0) -
                                pw_gydl1 - pw_gydl1d - pw_wgydl1);
            }
/* SVBranch:HCSDM00259119  -  dse enh */        
@inline eco_mpg.e left_ydiff_dse            
            TRAPEZOID(YGRAD, gydl1, tempy, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydl1, 0, 1);
#endif

            if(xygradLeftCrusherFlag == PSD_ON ) {
                tempy = RUP_GRD(IMax(2,pend(&gzrf2leftr1,"gzrf2leftr1d",0),
                                pend(&xgradLeftCrusherR,"xgradLeftCrusherRd",0))
                                + pw_gydr1a + pw_wgydr1);
            } else {
                tempy = RUP_GRD(pend(&gzrf2leftr1,"gzrf2leftr1d",0) +
                                pw_gydr1a + pw_wgydr1);
            }
            TRAPEZOID(YGRAD, gydr1, tempy, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydr1, 0, -1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) {
                tempy = RUP_GRD(IMin(2,pbeg(&gzrf2rightl1,"gzrf2rightl1a",0),
                            pbeg(&xgradRightCrusherL,"xgradRightCrusherLa",0))
                            - pw_gydl2 - pw_gydl2d - pw_wgydl2);
            } else {
                tempy = RUP_GRD(pbeg(&gzrf2rightl1,"gzrf2rightl1a",0) 
                                - pw_gydl2 - pw_gydl2d - pw_wgydl2);
            }
            TRAPEZOID(YGRAD, gydl2, tempy, 0, TYPNDEF, loggrd);
       
#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydl2, 0, 1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) {
                tempy = RUP_GRD(IMax(2,pend(&gzrf2rightr1,"gzrf2rightr1d",0),
                            pend(&xgradRightCrusherR,"xgradRightCrusherRd",0))
                            + pw_gydr2a + pw_wgydr2);
            } else {
                tempy = RUP_GRD(pend(&gzrf2rightr1,"gzrf2rightr1d",0) 
                                + pw_gydr2a + pw_wgydr2);
            }
            TRAPEZOID(YGRAD, gydr2, tempy, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(yamp_iters, cur_num_iters, &gydr2, 0, -1);
#endif
        }
    }

    /* Y killer pulse *****************************************************/
    if (eosykiller == PSD_ON) {
	tempy = RUP_GRD(pend(&gxwde,"gxwde",0) + gkdelay + pw_gyka);
	TRAPEZOID(YGRAD, gyk, tempy, 0, TYPNDEF, loggrd);
    }
  
    /* Z diffusion pulses *****************************************************/
    /* DTI */
    if ((oppseq == PSD_SE && opdiffuse == PSD_ON) || tensor_flag == PSD_ON) {
        if (PSD_OFF == dualspinecho_flag)
        {
		if(ftde_flag == PSD_OFF){ /* granty maybe This is th original parts */
            if(xygradCrusherFlag == PSD_ON) {
                tempz = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&xgradCrusherL,"xgradCrusherLa",0)) - pw_gzdl - pw_gzdld - pw_wgzdl);
            } else {
                tempz = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gzdl - pw_gzdld - pw_wgzdl);
            }
	    }else{ /* granty maybe */
            	if(xygradCrusherFlag == PSD_ON) {
            	    tempz = RUP_GRD(IMin(2,pbeg(&gzrf2l1,"gzrf2l1a",0),pbeg(&xgradCrusherL,"xgradCrusherLa",0)) - pw_gzdl - pw_gzdld - pw_wgzdl - pw_gzde - pw_gzded - pw_gzdea);
            	} else {
            	    tempz = RUP_GRD(pbeg(&gzrf2l1,"gzrf2l1a",0) - pw_gzdl - pw_gzdld - pw_wgzdl - pw_gzde - pw_gzded - pw_gzdea);
            	}
            	TRAPEZOID(ZGRAD, gzde, tempz + pw_gzdla + pw_gzdl + pw_gzdld, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
           	 setiamptiter(zamp_iters, cur_num_iters, &gzde, 0, 1);
#endif
	    } /* granty maybe end */
            TRAPEZOID(ZGRAD, gzdl, tempz, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdl, 0, 1);
#endif

            if(xygradCrusherFlag == PSD_ON) {
                tempz = RUP_GRD(IMax(2,pend(&gzrf2r1,"gzrf2r1d",0),pend(&xgradCrusherR,"xgradCrusherRd",0)) + pw_gzdra + pw_wgzdr);
            } else {
                tempz = RUP_GRD(pend(&gzrf2r1,"gzrf2r1d",0) + pw_gzdra + pw_wgzdr);
            }
            TRAPEZOID(ZGRAD, gzdr, tempz, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdr, 0, 1);
#endif

        } else {
            /*MRIhc05259*/
            if(xygradLeftCrusherFlag == PSD_ON) {
                tempz = RUP_GRD(IMin(2,pbeg(&gzrf2leftl1,"gzrf2leftl1a",0),
                                pbeg(&xgradLeftCrusherL,"xgradLeftCrusherLa",0))
                                - pw_gzdl1 - pw_gzdl1d - pw_wgzdl1);
            }
            else {
                tempz=RUP_GRD(pbeg(&gzrf2leftl1,"gzrf2leftl1a",0) -
                              pw_gzdl1 - pw_gzdl1d - pw_wgzdl1);
            }
/* SVBranch:HCSDM00259119  -  dse enh */        
@inline eco_mpg.e left_zdiff_dse            
            TRAPEZOID(ZGRAD, gzdl1, tempz, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdl1, 0, 1);
#endif

            if(xygradLeftCrusherFlag == PSD_ON ) {
                tempz = RUP_GRD(IMax(2,pend(&gzrf2leftr1,"gzrf2leftr1d",0),
                                pend(&xgradLeftCrusherR,"xgradLeftCrusherRd",0))
                                + pw_gzdr1a + pw_wgzdr1);
            }
            else {
                tempz=RUP_GRD(pend(&gzrf2leftr1,"gzrf2leftr1d",0) +
                              pw_gzdr1a + pw_wgzdr1);
            }
            TRAPEZOID(ZGRAD, gzdr1, tempz, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdr1, 0, -1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) {
                tempz = RUP_GRD(IMin(2,pbeg(&gzrf2rightl1,"gzrf2rightl1a",0),
                            pbeg(&xgradRightCrusherL,"xgradRightCrusherLa",0))
                            - pw_gzdl2 - pw_gzdl2d - pw_wgzdl2);
            } else {
                tempz = RUP_GRD(pbeg(&gzrf2rightl1,"gzrf2rightl1a",0) 
                                - pw_gzdl2 - pw_gzdl2d - pw_wgzdl2);
            }
            TRAPEZOID(ZGRAD, gzdl2, tempz, 0, TYPNDEF, loggrd);
       
#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdl2, 0, 1);
#endif

            if(xygradRightCrusherFlag == PSD_ON ) {
                tempz = RUP_GRD(IMax(2,pend(&gzrf2rightr1,"gzrf2rightr1d",0),
                            pend(&xgradRightCrusherR,"xgradRightCrusherRd",0))
                            + pw_gzdr2a + pw_wgzdr2);
            } else {
                tempz = RUP_GRD(pend(&gzrf2rightr1,"gzrf2rightr1d",0) 
                                + pw_gzdr2a + pw_wgzdr2);
            }
            TRAPEZOID(ZGRAD, gzdr2, tempz, 0, TYPNDEF, loggrd);

#if defined(HOST_TGT)
            setiamptiter(zamp_iters, cur_num_iters, &gzdr2, 0, -1);
#endif
        }

    }

    /* Z killer pulse *****************************************************/
    if (eoszkiller == PSD_ON) {
        tempz = RUP_GRD(pend(&gxwde,"gxwde",0) + gkdelay + pw_gzka);
        TRAPEZOID(ZGRAD, gzk, tempz, 0, TYPNDEF, loggrd);
    }

    /* RHO killer? pulse ***********************************************/
    /* This pulse is specific to MGD.  It forces the RHO sequencer to  */
    /* EOS after all other RF sequencers (omega & theta) as a temp fix */
    /* for a seqeuncer issue.                                          */
    if (eosrhokiller == PSD_ON) {
        int pw_rho_killer = 2;
        int ia_rho_killer = 0;

        tempz = RUP_GRD(pend(&gxwde,"gxwde",0) + gkdelay + pw_gzka);
        pulsename(&rho_killer,"rho_killer");
        createconst(&rho_killer,RHO,pw_rho_killer,MAX_PG_WAMP);
        createinstr( &rho_killer,(long)(tempz),
                     pw_rho_killer,ia_rho_killer);
    }

    /* Major "Wait" Pulses ************************************************/
    /* DTI */
    if (opdiffuse == PSD_ON || tensor_flag == PSD_ON) {
        if (PSD_OFF == dualspinecho_flag)
        {
            tempx = pendall(&gxdr,0);
            tempy = pendall(&gydr,0);
        } else {
            tempx = pendall(&gxdr2,0);
            tempy = pendall(&gydr2,0);
        }	
    } else {
        if (gy1pos == PSD_POST_180)
            tempy = pbeg(&gy1a, "gy1a", 0) - pw_wgy;
        else
            tempy = pbeg(&gyba, "gyba", 0) - pw_wgy;

        if (ygmn_type == CALC_GMN1)
            tempy = pbeg(&gymn1a, "gymn1a", 0) - pw_wgy;

        if (gx1pos == PSD_POST_180)
            tempx = pbeg(&gx1a, "gx1a", 0) - pw_wgx;
        else
            tempx = pbeg(&gxwa, "gxwa", 0) - pw_wgx;
    }

    /* TFON sliding data acq. window wait intervals */
    WAIT(XGRAD, wgx, tempx, pw_wgx );
    WAIT(YGRAD, wgy, tempy, pw_wgy );

    if (oppseq == PSD_SE) {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            tempz = pendall(&gzrf2r1, 0);
        } else {
            tempz = pendall(&gzrf2rightr1, 0);
        }	
    } else {
        if (zgmn_type == CALC_GMN1)
            tempz = pendall(&gzmnd, 0);
        else
            tempz = pendall(&gz1d, 0);
    }

    /* DTI */
    if (opdiffuse == PSD_ON || tensor_flag == PSD_ON) {
        if (PSD_OFF == dualspinecho_flag)
        {
            tempz = pendall(&gzdr,0);
        }
        else {
            tempz = pendall(&gzdr2,0);
        }
    }

    WAIT(ZGRAD, wgz, tempz, pw_wgz);

    if (oppseq == PSD_SE)
    {
        if (PSD_OFF == dualspinecho_flag)
        {
            temps = pendall(&rf2, 0) + rfupd + 4us;
        }
        else
        {
            temps = pendall(&rf2right, 0) + rfupd + 4us;
        }
    }
    else
    {
        if (hsdab == 2)
            temps = pendall(&rf1, 0) + rfupd + 4us + (int)DIFFDAB_length;
        else
        temps = pendall(&rf1, 0) + rfupd + 4us + (int)HSDAB_length;
    }

    if (mux_flag && verse_rf2)
    {
        temps = temps + 40us;
    }

    WAIT(SSP, wssp, temps, pw_wssp);
    pw_sspdelay = defaultdelay + 1us;
    WAIT(SSP, sspdelay, temps + pw_wssp, pw_sspdelay);
    pw_omegadelay = RUP_RF(defaultdelay+2us);
    WAIT(OMEGA, omegadelay, RUP_GRD(temps), pw_omegadelay );
    WAIT(OMEGA, womega, RUP_GRD(temps)+pw_omegadelay, pw_womega); /* ufi2_ypd */

    /* pulse names for Omega Freq Mod pulses */ 
    pulsename(&rs_omega_attack, "rs_omega_attack");
    pulsename(&rs_omega_decay, "rs_omega_decay");
    pulsename(&omega_flat, "omega_flat");
  
    /* These thress pulses are for receive */
    setrxflag(&rs_omega_attack, 1);
    setrxflag(&rs_omega_decay, 1);
    setrxflag(&omega_flat, 1);
  
    /* internref: use tot_etl instead of etl */
    for (echoloop = 0; echoloop < tot_etl; echoloop++ ) {
        getssppulse(&(echotrainrba[echoloop]), &(echotrain[echoloop]), "rba", 0);
      
        {   /* local scope */
          
            int time_offset = 0;
            pulsepos = pendallssp(echotrainrba[echoloop], 0); 
            time_offset = pw_gxwad - dacq_offset;  
          
            /* TURN TNS ON at the first etl and OFF at the last etl so that */
            /* the xtr and TNS do not overlap. */
            if ( echoloop == 0) TNSON(e1entns,pulsepos);
            if ( echoloop == tot_etl-1) TNSOFF(e1distns,pulsepos + (int)(tsp*(float)rhfrsize));
          
            if (vrgfsamp) {
                trapezoid( OMEGA,"omega", &omega_flat, 
                           &rs_omega_attack, &rs_omega_decay,
                           pw_gxwl+pw_gxw+pw_gxwr,  pw_gxwad, pw_gxwad, 
                           ia_omega,ia_omega,ia_omega, 0, 0, 
                           RUP_RF(pulsepos-time_offset+rba_act_start), TRAP_ALL, &loggrd);    
            } else {
              
                /* BJM: to offset frequency, play constant on omega */
                createconst(&omega_flat, OMEGA, pw_gxwl+pw_gxw+pw_gxwr, 
                            max_pg_wamp);
                createinstr(&omega_flat, RUP_RF(pulsepos+rba_act_start),
                            pw_gxwl+pw_gxw+pw_gxwr, ia_omega);            
            }
          
        }
    }
  
    /* 4us for the e1distns pack */
    temps = pendallssp(&echotrain[tot_etl-1], 0) + (int)(tsp*(float)rhfrsize)+ 4; 

    ATTENUATOR(atten, temps);

    /* spring for sspdelay */
    WAIT(SSP, sspshift, temps + 7us, pw_sspshift);

    temps = pendallssp(&sspshift, 0);

    for (i=0; i<num_passdelay; i++) { 
        WAIT(SSP, ssp_pass_delay, temps, 1us);
        temps = pendallssp(&ssp_pass_delay, i);
    }

    PASSPACK(pass_pulse, temps);

    /* Actual deadtimes for cardiac scans will be rewritten later */
    if((opcgate==PSD_ON) || (oprtcgate==PSD_ON))
    {
        psd_seqtime = RUP_GRD(tmin);
    }
    else if(navtrig_flag == PSD_ON)
    {
        psd_seqtime = RUP_GRD(nav_image_interval - time_ssi);
    }
    else
    {
        psd_seqtime = RUP_GRD(avail_se_time/(mux_flag?mux_slquant:false_slquant1) - time_ssi);

        if (t1flair_flag == PSD_ON)
        {
            psd_seqtime = RUP_GRD(act_tr/false_slquant1 - time_ssi);
        }
    }

    /*  Code to estimate the phase error accumulation for the 90-180-180
        SE sequence so as to maintain the CPMG condotion...this code based
        off the correction in fse-xl.e and fixes the slice-to-slice signal 
        variation issue with dualspinecho ALP */
    getssppulse(&tmppulseptr, &rf1,"frq", 0); /* Get beginning of rf1 */
    tmpinstr = (WF_INSTR_HDR *)GetPulseInstrNode(tmppulseptr,0);
    sync1_pos = (tmpinstr->start);
    rf1_pos = pbeg(&rf1,"rf1",0);
    sync_to_rf1 = rf1_pos - ( sync1_pos + frq2sync_dly ); 
    t_rf1_phase = sync_to_rf1 + hrf1a;

    if (PSD_OFF == dualspinecho_flag)
    {
        getssppulse(&tmppulseptr, &rf2,"frq", 0); /* Get beginning of rf2 */
        tmpinstr = (WF_INSTR_HDR *)GetPulseInstrNode(tmppulseptr,0);
        sync2_pos = (tmpinstr->start);
        rf2_pos = pbeg(&rf2,"rf2",0);
        sync_to_rf2 = rf2_pos - ( sync2_pos + frq2sync_dly ); 
        t_rf2_phase = sync_to_rf2 + pw_rf2/2;
    }
    else {
        getssppulse(&tmppulseptr, &rf2left,"frq", 0); /* Get beginning of rf2 */
        tmpinstr = (WF_INSTR_HDR *)GetPulseInstrNode(tmppulseptr,0);
        sync2_pos = (tmpinstr->start);
        rf2_pos = pbeg(&rf2left,"rf2left",0);
        sync_to_rf2 = rf2_pos - ( sync2_pos + frq2sync_dly ); 
        t_rf2_phase = sync_to_rf2 + pw_rf2left/2;
    }

    if(!irprep_flag) 
    {
        SEQLENGTH(seqcore,psd_seqtime,seqcore);

        getperiod((long*)&scan_deadtime, &seqcore, 0);
        scan_deadlast = deadlast;
    }

    if(ir_on)
    {
@inline Inversion_new.e InversionPG
        if(irprep_flag)
        {
            pulsename(&seqcore,"seqcore");
            createseq(&seqcore,psd_seqtime, off_seqcore);
#if defined(HOST_TGT)
            /* Update sequence counter and get current sequence entry index */
            updateIndex( &idx_seqcore );
            printDebug( DBLEVEL1, (dbLevel_t)seg_debug, "SEQLENGTH",
                        "idx_seqcore = %d\n", idx_seqcore );
#endif
            getperiod((long*)&scan_deadtime, &seqcore, 0);
            scan_deadlast = deadlast;
        }
        else
        {
            SEQLENGTH(seqinv, invseqtime, seqinv);
            buildinstr();
            getperiod(&scan_deadtime_inv, &seqinv, 0);
            /* Assert the ESSP flag on the sync packet byte seq length */
            attenflagon(&seqinv, 0);
        }
    }

    /* PS **************************************************************/
@inline Prescan.e PSpulsegen
  
    if (SatRelaxers) /* Create Null sequence for Relaxers */
        SpSatCatRelaxPG(time_ssi);

    /* Baseline Acquisition *********************************************/
    RCVRUNBLANK(bline_unblank, (LONG)(3ms),);
    FASTACQUIREDATA(blineacq1,
                    (LONG)(5ms), 
                    (LONG)fast_rec,
                    (LONG)(hsdab > 0 ? 0:1),
                    (LONG)0,
                    (LONG)0,
                    (TYPDAB_PACKETS)DABNORM);
				 


    if (hsdab == 1)
        HSDAB(hyperdabbl, 1ms);
    else if (hsdab == 2)
        DIFFDAB(diffdabbl, 1ms);
  
    SEQLENGTH(seqblineacq, bl_acq_tr2, seqblineacq);

/*RTB0 correction*/
@inline RTB0.e RTB0pg

#ifdef IPG
    if (FAILURE == Monitor_pulsegen())
    {
        return FAILURE;
    }
#endif

#ifdef NOT_MGD

    /* Move the instruction memory around a bit */
    /* There are essentially two memory banks: (1) XGRAD, YGRAD, ZGRAD, and SSP
       and      (2) RHO1, RHO2, THETA, OMEGA, AUX
       (Originally there were 4096 instructions assigned to each of x, z and ssp,
       and 4032 instructions to y.) */

    ipg_alloc_instr[0] = 4608;  /* XGRAD */
    ipg_alloc_instr[1] = 4544;  /* YGRAD */
    ipg_alloc_instr[2] = 2560;  /* ZGRAD */
    ipg_alloc_instr[3] = 4096;  /* RHO1  */
    ipg_alloc_instr[4] = 4096;  /* RHO2  */
    ipg_alloc_instr[5] = 4096;  /* THETA */
    ipg_alloc_instr[6] = 4096;  /* OMEGA */
    ipg_alloc_instr[7] = 4608;  /* SSP   */
    ipg_alloc_instr[8]  = 64;   /* AUX   */

#endif

    buildinstr();              /* load the sequencer memory */

    if (SatRelaxers) /* Use X and Z Grad offsets from off seqcore */
        SpSatCatRelaxOffsets(off_seqcore);

@inline Inversion_new.e InversionPG1


    /*  ***********************************************************
        Initialization
        ********************************************************** */

    if (oppseq == PSD_SE) {   /* point to proper waveform */

        if (mux_flag && verse_rf2) {
            getwave(&wave_ptr, &index_rf2[0]);                /* VERSEd envelope */
            getwave(&grad_wave_ptr, &rf2_gradient_waveform);  /* VERSEd gradient waveform */
        } else {
            getwave(&wave_ptr, &rf2se1b4);          /* use this for non-VERSEd RF pulses */
        }
        /* DTI */
        if( opdualspinecho == PSD_OFF) {
            setwave(wave_ptr,   &rf2, 0);
            if (mux_flag && verse_rf2) {
                setwave(grad_wave_ptr, &gzrf2, 0);
                setperiod(GRAD_UPDATE_TIME, &gzrf2, 0);
            }
        } else {
            setwave(wave_ptr,   &rf2left, 0);
            setwave(wave_ptr,   &rf2right, 0);
            if (mux_flag && verse_rf2) {
                setwave(grad_wave_ptr, &gzrf2left, 0);
                setperiod(GRAD_UPDATE_TIME, &gzrf2left, 0);
                setwave(grad_wave_ptr, &gzrf2right, 0);
                setperiod(GRAD_UPDATE_TIME, &gzrf2right, 0);
            }
        }
    }

    rspdex = dex;
    rspech = 0;
    rspchp = CHOP_ALL;
    rsp_preview = 0;
  
#ifdef IPG
    /*
     * Execute this code only on the Tgt side
     */
    if (rfov_flag)
    {
        /* Slice shift controlled though theta */
        for (temps = 0; temps < opslquant; ++temps)
        {
            rf1_freq[temps] = 0;
        }

        /* TG limit calc based on Tx freq offset */
        calcTGLimitAtOffset((int)rfov_max_freq_shift, &TGlimit, psddebugcode2);
    }
    else if (mux_flag)
    {
        setupslices(rf1_freq, rsp_info, mux_slquant, a_gzrf1,
                    (float)1, (opfov*freq_scale), TYPTRANSMIT);
        setupslices(theta_freq, rsp_info, mux_slquant, a_gzrf1/omega_scale,
                    (float)1, (opfov*freq_scale), TYPTRANSMIT);

    }
    else
    {
        /* Find frequency offsets */
        setupslices(rf1_freq, rsp_info, opslquant, a_gzrf1,
                    (float)1, (opfov*freq_scale), TYPTRANSMIT);
        setupslices(theta_freq, rsp_info, opslquant, a_gzrf1/omega_scale,
                    (float)1, (opfov*freq_scale), TYPTRANSMIT);
    }

    if (oppseq == PSD_SE)
    {
        if (mux_flag)
        {
            setupslices(rf2_freq, rsp_info, mux_slquant, a_gzrf2,
                        (float)1, (opfov*freq_scale), TYPTRANSMIT);
            setupslices(thetarf2_freq, rsp_info, mux_slquant, a_gzrf2/omega_scale,
                        (float)1, (opfov*freq_scale), TYPTRANSMIT);

        }
        else
        {
            setupslices(rf2_freq, rsp_info, opslquant, a_gzrf2,
                        (float)1, (opfov*freq_scale), TYPTRANSMIT);
        }
    }

    /* BJM: dualspinecho */
    for (i=0; i<opslquant; i++) {
        if (ss_rf1 == PSD_ON) {
            setupphases(rf1_pha, rf1_freq, i, rf1_phase, 0, freqSign);
        } else {
            setupphases(rf1_pha, rf1_freq, i, rf1_phase, t_rf1_phase, freqSign);
        }

        if(PSD_OFF == dualspinecho_flag)
        {
            setupphases(rf2_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2);
        }
        else
        {
            setupphases(rf2left_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2left);
            setupphases(rf2right_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2right);
        }
    }
  
    settriggerarray((short)(opslquant*opphases),rsptrigger);
  
    if (FAILURE == Monitor_Download())
    {
        return FAILURE;
    }

    /* Inform the Tgt of the rotation matrix array to be used.
       For everything but CFH and CFL the sat pulses are played
       out so load the sat rotation matrix. Otherwise
       the original slice rotation matrix is used. */
    SpSat_set_sat1_matrix(rsprot_orig, rsprot, opslquant*opphases,
                          sat_rot_matrices, sat_rot_ex_num, sat_rot_df_num,
                          sp_satcard_loc, 0);

    /* Inform the Tgt of the rotation matrix array to be used */
    setrotatearray((short)(opslquant*opphases),rsprot[0]);

    /* update RSP maxTG with min TGlimit value */
    maxTGAtOffset = updateTGLimitAtOffset(TGlimit, sat_TGlimit);

#endif /* IPG */
    sl_rcvcf = (int)((float)cfreceiveroffsetfreq / TARDIS_FREQ_RES);

    /* Set up SlcInAcq and AcqPtr tables for multipass scans and
     * multi-repetition scans, including cardiac gating, interleaved,
     * and sequential multi-rep modes.
     * SlcInAcq array gives number of slices per array.
     * AcqPtr array gives index to the first slice in the 
     * multislice tables for each pass. */
  
    /* cardiac gated multi-slice, multi-phase, multi-rep */
    if (opcgate==PSD_ON) 
    {
        rspcardiacinit((short)ophrep, (short)piclckcnt);
        sliceindex = acqs - 1; /* with cardiac gating, acqs is the no. of slices */
        for (pass = 0; pass < acqs; pass++) 
	{
            slc_in_acq[pass] = slquant1*opphases;
            if (pass == 0)
                acq_ptr[pass] = 0;
            else 
	    {
                acq_ptr[pass] = sliceindex;
                sliceindex = sliceindex - 1;
	    }
  	} /* repeat the table for multi-reps */
        for (pass_rep = 1; pass_rep < pass_reps; pass_rep++) 
	{
            for (pass = 0; pass < acqs; pass++) 
	    {
                slc_in_acq[pass + pass_rep*acqs] = slc_in_acq[pass];
                acq_ptr[pass + pass_rep*acqs] = acq_ptr[pass];
	    }
	}
    }
    /* RTG */
    else if ((oprtcgate == PSD_ON) || (navtrig_flag == PSD_ON))
    {
        rspcardiacinit((short)oprtrep, (short)piclckcnt);

        slmod_acqs = (opslquant * reps) % act_acqs;

        for (pass = 0; pass < act_acqs; pass++)
        {
            slc_in_acq[pass] = (opslquant * reps) / act_acqs;
            acq_ptr[pass] = 0;

            if (slmod_acqs > pass)
            {
                slc_in_acq[pass] = slc_in_acq[pass] + 1;
            }

            acq_ptr[pass] = (int)(opslquant / act_acqs) * pass;

            if (slmod_acqs <= pass)
            {
                acq_ptr[pass] = acq_ptr[pass] + slmod_acqs;
            }
            else
            {
                acq_ptr[pass] = acq_ptr[pass] + pass;
            }
        }

        /* repeat the table for multi-reps */
        for (pass_rep = 1; pass_rep < pass_reps; pass_rep++) {
            for (pass = 0; pass < acqs; pass++) {
                slc_in_acq[pass + pass_rep*acqs] = slc_in_acq[pass];
                acq_ptr[pass + pass_rep*acqs] = acq_ptr[pass];
            }
        }
    }
    else 
    {
        if ( mph_flag==PSD_OFF ) 
	{  /* single-rep interleaved multi-slice */
            slmod_acqs = (opslquant*reps)%act_acqs;
            for (pass = 0; pass < act_acqs; pass++) 
	    {
                slc_in_acq[pass] = (opslquant*reps)/act_acqs;
                if (slmod_acqs > pass)
                    slc_in_acq[pass] = slc_in_acq[pass] + 1;
                acq_ptr[pass] = (int)(opslquant/act_acqs) *pass;
                if (slmod_acqs <= pass)
                    acq_ptr[pass] = acq_ptr[pass] + slmod_acqs;
                else
                    acq_ptr[pass] = acq_ptr[pass] + pass;
	    }
	}
        if ( (mph_flag==PSD_ON) && (acqmode==1)) 
	{  /* mph, sequential */
            for (pass=0; pass<act_acqs; pass++) 
	    {  /* for sequential, acqs=opslquant */
                slc_in_acq[pass] = reps;
                acq_ptr[pass] = pass;
	    }
	}
        if ( (mph_flag==PSD_ON) && (acqmode==0) ) 
	{  /* mph, interleaved, single pass */
            for (pass = 0; pass < act_acqs; pass++) 
	    {
                slc_in_acq[pass] = slquant1;
                acq_ptr[pass] = 0;
                slmod_acqs = (opslquant*reps)%act_acqs;
                for (pass = 0; pass < act_acqs; pass++) 
		{
                    slc_in_acq[pass] = (opslquant*reps)/act_acqs;
                    if (slmod_acqs > pass)
                        slc_in_acq[pass] = slc_in_acq[pass] + 1;
                    acq_ptr[pass] = (int)(opslquant/act_acqs) *pass;
                    if (slmod_acqs <= pass)
                        acq_ptr[pass] = acq_ptr[pass] + slmod_acqs;
                    else
                        acq_ptr[pass] = acq_ptr[pass] + pass;
		}
	    }
            for (pass_rep = 1; pass_rep < pass_reps; pass_rep++) 
	    { /* repeat the table for multi-reps */
                for (pass = 0; pass < act_acqs; pass++) 
		{
                    slc_in_acq[pass + pass_rep*act_acqs] = slc_in_acq[pass];
                    acq_ptr[pass + pass_rep*act_acqs] = acq_ptr[pass];
		}
	    }
	}
    }
    
    /* t1flair_stir */
    if (t1flair_flag == PSD_ON)
    {
        if (FAILURE == T1flair_sliceordering())
        {
            return FAILURE;
        }
    }
  
    /* Save the trigger for the prescan slice. */
    prescan_trigger = rsptrigger[acq_ptr[pre_pass] + pre_slice];

    rsptrigger_temp[0] = TRIG_INTERN;
    
    /* Save copy of scan_info table */ 
    for(temp1=0; temp1<opslquant; temp1++) {
        orig_rsp_info[temp1].rsptloc = rsp_info[temp1].rsptloc;
        orig_rsp_info[temp1].rsprloc = rsp_info[temp1].rsprloc;
        orig_rsp_info[temp1].rspphasoff = rsp_info[temp1].rspphasoff;
        for (temp2=0; temp2<9; temp2++)
            origrot[temp1][temp2] = rsprot[temp1][temp2];
    }

    for (echoloop = 0; echoloop < tot_etl; echoloop++ ) {
        getssppulse(&(echotrainxtr[echoloop]), &(echotrain[echoloop]), "xtr", 0);
        getssppulse(&(echotrainrba[echoloop]), &(echotrain[echoloop]), "rba", 0);
    }

    hsdabmask = PSD_LOAD_HSDAB_ALL;
    diffdabmask = PSD_LOAD_DIFFDAB_ALL;
    dabmask = PSD_LOAD_DAB_ALL;
    scaleomega = 0;

    return SUCCESS;

} /* end pulsegen */

@inline ChemSat.e ChemSatPG
@inline SpSat.e SpSatPG
@inline Prescan.e PSipg

@inline Monitor.e MonitorPGDecl
@inline Monitor.e MonitorPG

@rsp
#include "pgen_tmpl.h"
#include "epic_loadcvs.h"
#include <math.h>

#include <stdlib.h> /*RTB0 correction*/ 
#include <stdio.h> /*RTB0 correction*/
#include <string.h> /*RTB0 correction*/

int * rpgUnitTestPtr = NULL; /* Distortion Correction Unit Test */
int rpgUnitTestPtrSize = -1;

const CHAR *entry_name_list[ENTRY_POINT_MAX] = { "scan",
					   "mps2",
					   "aps2",
					   "ref",
@inline Prescan.e PSeplist
};

@inline DTI.e rspDTI
@inline RfovFuncs.e RfovRSP

@inline SlabTracking.e SlabTrackVariables

long deadtime;               /* amount of deadtime */
short viewtable[1025];        /* view table */
int xrr_trig_time;             /* trigger time for filled or unfilled
		                  R-R interval which is not last R-R */

short tempamp;

@inline DTI.e rspPrototypes
@inline DTI.e readTensorOrientationsFunc
@inline epiMaxwellCorrection.e epiMaxwellCorrection 

/*RTB0 correction*/
@inline RTB0.e RTB0Core
@inline RTB0.e RTB0Core_epi2


/* t1flair_stir */
@inline InversionSeqOpt.e InversionSeqOptRsp

/*Diffusion hyper DAB*/
typedef enum FRAME_TYPE {
    REF_FRAME,
    T2_FRAME,
    DIFF_FRAME
} E_FRAME_TYPE;
E_FRAME_TYPE frame_type;

int diff_index = 0;
int nex_index = 0;
int instance_index =0;
int b_index = 0;
int dir_index = 0;
int vol_index =0;
int gradpol_dab = 0;
/*******************************   PS   ***************************/
@inline Prescan.e PScore

/*****************************  PSDINIT  **************************/
STATUS
#ifdef __STDC__ 
psdinit( void )
#else /* !__STDC__ */
    psdinit() 
#endif /* __STDC__ */
{
    strcpy(psdexitarg.text_arg, "psdinit");  /* reset global error variable */
    diff_index = 0;
    nex_index = 0;
    frame_type = REF_FRAME;
    instance_index = 0;
    b_index = 0;
    dir_index = 0;
    vol_index = 0;
    skip_ir = 0;
    blankomega=0;
    deltaomega = 0;
    timedelta = 0;  
    dda_packe = dda_pack;

    /* BJM: initialize sign of freq offset to be positive */
    /*      variable declared in ss.e */
    freqSign = 1;
    freqSign_ex = 1;
    freqSign_rf2right = 1;
    freqSign_rf2left = 1;
    freqSign_rf2 = 1;

    setrfconfig((short)rfconf);

    /* Clear the SSI routine. */
    if (opsat == PSD_ON)
        ssivector(ssisat, (short) FALSE);
    else 
        ssivector(dummyssi, (short) FALSE);

    /* turn off dithering */
    setditherrsp(dither_control,dither_value);

    /* Set ssi time.  This is time from eos to start of sequence interrupt
       in internal triggering.  The minimum time is 50us plus 2us*(number of
       waveform and instruction words modified in the update queue).
       Needs to be done per entry point. */
    setssitime((LONG)time_ssi/GRAD_UPDATE_TIME);

    scopeon(&seqcore);    /* reset all scope triggers */

    if (epi_flair == PSD_ON)		/* IR scope triggers */
        scopeon(&seqinv);

    scopeoff(&seqblineacq);

    syncon(&seqcore);  /* reset all synchronizations, not needed in pass */

    /* Set trigger for cf and 1st pass prescan.
       Reset trigger the prescan slice to its scan trigger for 
       scan and second pass prescan entry points. */
    if ((rspent == L_CFL) || (rspent == L_CFH) || (rspent == L_MPS1)
        || (rspent == L_APS1)) {
        rsptrigger[acq_ptr[pre_pass] + pre_slice] = trig_prescan;

        if (ipg_trigtest == 0) 
            /* Remove next line when line gating supported */
            rsptrigger[acq_ptr[pre_pass] + pre_slice] = TRIG_INTERN;
        else 
            rsptrigger[acq_ptr[pre_pass] + pre_slice] = prescan_trigger;
    }
    /* Allow for manual trigger override for testing. */      
    if (((psd_mantrig == PSD_ON) || (opcgate == PSD_ON) || (oprtcgate == PSD_ON))
        && ((rspent == L_APS2) || (rspent == L_MPS2) || (rspent == L_SCAN) || (rspent == L_REF) ))
    {
        for (slice=0; slice < opslquant*opphases; slice++)
        {
            if (rsptrigger[slice] != TRIG_INTERN)
            {
                switch(rspent)
                {
                case L_MPS2:
                    rsptrigger[slice] = trig_mps2;
                    break;
                case L_APS2:
                    rsptrigger[slice] = trig_aps2;
                    break;
                case L_SCAN:
                case L_REF:
                    rsptrigger[slice] = trig_scan;
                    break;
                default:
                    break;
                }
            }
        }
    }

    /* Inform the Tgt of the location of the trigger arrays. */
    settriggerarray((SHORT)(opslquant*opphases), rsptrigger);

    /* Inform the Tgt of the rotation matrix array to be used */
    setrotatearray((SHORT)(opslquant*opphases), rsprot[0]);

    pass = 0;
    pass_index = 0;
    rspacqb = 0;
    rspacq = act_acqs;
    false_rspacqb = 0;
    false_rspacq = false_acqs;
    rspprp = pass_reps;

    /* DAB initialization */
    dabop = 0; /* Store data */
    dabview = 0; 
    dabecho = 0; /* first dab packet is for echo 0 */
    /* use the autoincrement echo feature for subsequent echos */
    dabecho_multi = -1;


    CsSatMod(cs_satindex);
    SpSatInitRsp((INT)1, sp_satcard_loc,0);

    if ( gyctrl == PSD_ON )
        gyb_amp = blippol[0];
    else
        gyb_amp = 0;

    rspgyc = gyctrl;
    rspgzc = rspgyc;
    /*multiband slice looping upto mux'ed number of slices*/
    rspslqb = 0;
    rspslq = mux_flag?mux_slquant:false_slquant1;

    rspilvb = 0;
    rspilv = intleaves;
    rspbasb = 1;

    if (gxctrl == PSD_OFF)                /* turn off the readout axis */
        setieos((SHORT)EOS_DEAD, &x_td0,0);
    else                                  /* turn it on */
        setieos((SHORT)EOS_PLAY, &x_td0, 0);

    if (gzctrl == PSD_OFF)                /* turn off slice select axis */
        setieos((SHORT)EOS_DEAD, &z_td0,0);
    else                                  /* turn it on */
        setieos((SHORT)EOS_PLAY, &z_td0, 0);

    /* Update the exciter freq/phase tables */
    if (rspent == L_REF)
        ref_switch = 1;
    else
        ref_switch = 0;

    xtr = 0.0;    /* This used to be the time between the XTR and RBA packet */
    /* but we are now using the Omega board to offset the freq. */
    /* instead of the offset freq register so this is now 0 */
    frt = frtime;
 
    /* BJM: refdattime is no longer used to prephase the echoes */
    /* keep it until the epiRecvFrqPhs() interface is modified. */
    {
        int slc;
        
        /* No need to calculate refdattime */
        for( slc = 0; slc < opslquant; slc++ ) {
            refdattime[slc] = 0.0;
        }
    }

    rsppepolar = pepolar; /* used in recv_phase_freq_init */

    recv_phase_freq_init();

    /** end of XJZ's addition  **/

    ref_switch = 0;

    if ((intleaves > 1) && (ep_alt > 0)) 
    {
        ileave = 0;
        setreadpolarity();  /* make sure readout gradient polarity is set
                               properly */
    }

    rspe1st = 0;
    rspetot = tot_etl;

    /* phase-encoding blip correction for oblique scan planes */
    blipcorr(rspia_gyboc,da_gyboc,debug_oblcorr,rsprot_unscaled,oc_fact,cvxfull,
             cvyfull,cvzfull,bc_delx,bc_dely,bc_delz,oblcorr_on,opslquant,
             &epiloggrd,pw_gyb,pw_gyba,a_gxw);

    /* set up tensor orientations from the AGP side */ 
    if ( FAILURE == set_tensor_orientationsAGP() ){
        return FAILURE;
    } 

#ifdef PSD_HW
    if (PSD_ON == navtrig_flag)
    {
        if (L_REF == rspent)
        {
            skip_navigator_prescan = 0;
            if (PSD_OFF == calc_rate)
            {
                NavigatorRspInit();
            }
        }
        if (L_SCAN == rspent)
        {
            NavigatorRspInit();
        }
    }
#endif /* PSD_HW */

    return SUCCESS;  
} /* End psdinit */	    

@inline Monitor.e MonitorCore

/* *******************************************************************
   CardInit
   RSP Subroutine

   Purpose:
   To create an array of deadtimes for each slice/phase of the first
   pass in a cardiac scan.  For multi-phase scans, this same array can be
   used as the slices are shuffled in each pass to obtain new phases.

   Description: The logic for creating the deadtime array for
   multiphase scans is rather simple.  All of the slices except the last
   slice have the same deadtime.  This deadtime will assure that the
   repetition time between slices equals the inter-sequence delay time.
   The last slice has a deadtime that will run the logic board until the
   beginning of the cardiac trigger window.

   The logic for creating the deadtime for single phase, or cross R-R
   scans, is much more complicated.  In these scans, the operator
   prescribes over how many R-R intervals (1-4) the slices should be
   interleaved over.  The deadtimes for the last slice in each R-R
   interval will be different depending on whether the R-R interval is
   filled, unfilled, or the last R-R interval. For example, lets say 14
   slices are to be interleaved among 4 R-R intervals.  4 slices will be
   placed in the first R-R, 4 in the second, 3 in the third, and 3 in the
   fourth.  This prescription has 2 filled R-R intervals, 1 unfilled R-R
   interval, and a final R-R interval.  The deadtimes for slices which
   are not the last slice in a R-R interval is the same deadtime that
   assures that the inter-sequence delay time is met.

   Parameters:
   (O) int ctlend_tab[]  table of deadtimes
   (I) int ctlend_intern deadtime needed to maintain intersequence delay time.
   Delay when next slice will be internally gated.
   (I) int ctlend_last   Delay time for last slice in ophrep beats.  Deadtime needed
   to get proper trigger delay for next heart beat. 
   (I) int ctlend_fill   Dead time for filled R-R interval.  Not used in multi-phase
   scans. 
   (I) int ctlend_unfill Deadtime of last slice in an unfilled R-R interval.  Not used in
   multi-phase scans.
   *********************************************************************** */


/**************************  CardInit  *********************************/

#ifdef __STDC__
STATUS CardInit( INT ctlend_tab[], INT ctlend_intern, INT ctlend_last[], INT ctlend_fill[], INT ctlend_unfill[], INT subhacq,  INT subhrep, INT subphases)
#else /* !__STDC__ */
    STATUS CardInit(ctlend_tab, ctlend_intern, ctlend_last, ctlend_fill, ctlend_unfill)
    INT ctlend_tab[];   /* output table of deadtimes */
    INT ctlend_intern;  /* dead time for a slice when next slice will be
                           internally gated */
    INT ctlend_last[];    /* dead time of last temporal cardiac slice */
    INT ctlend_fill[];    /* dead time of last slice in a filled R-R interval */
    INT ctlend_unfill[];  /* dead time of a last slice in an unfilled R-R interval */
    INT subhrep;
    INT subhacq;
    INT subphases;

#endif /* __STDC__ */
{
    int rr = 0;  /* index for current R-R interval - 1 */
    int rr_end = 0; /* index for last slice in a R-R interval */
    int acq_cnt = 0; /* counter */
    int slice_cnt = 0; /* counter */
    int slice_quant = 0; /* number of slices */
    int prev_sum_slices_acq = 0; /* sum of slices till previous acq */
    int current_sum_slices_acq = 0; /* sum of slices till current acq */
    int current_acq = 0; /* index for current pass */
    int current_slices_acq = 0; /* current slices in current acq */
    int current_slices_rep = 0; /* current slices in current RR */
    int slices_rep_offset = 0; /* offset slices for current slice in current RR */

    /* Check for negative deadtimes and deadtimes that don't fall
       on GRAD_UPDATE_TIME boundaries */
    for (acq_cnt = 0; acq_cnt < subhacq; acq_cnt++)
    {
        if ((ctlend_intern < 0) || (ctlend_last[acq_cnt] < 0) || (ctlend_fill[acq_cnt] < 0) || (ctlend_unfill[acq_cnt] < 0)) 
        {
            psdexit( EM_PSD_SUPPORT_FAILURE, 0, "", "CardInit", 0 );
        }
    }

    ctlend_intern = RUP_GRD(ctlend_intern);

    for (acq_cnt = 0; acq_cnt < subhacq; acq_cnt++) 
    {
        ctlend_fill[acq_cnt] = RUP_GRD(ctlend_fill[acq_cnt]);
        ctlend_unfill[acq_cnt] = RUP_GRD(ctlend_unfill[acq_cnt]);
        ctlend_last[acq_cnt] = RUP_GRD(ctlend_last[acq_cnt]);
    }

    if (subphases > 1)
    {
        slice_quant = subphases;
    }
    else
    {
        slice_quant = opslquant;
    }

    for (slice_cnt=0; slice_cnt < slice_quant; slice_cnt++) 
    {
        if (subphases > 1) 
        { /* Multiphase */
            current_acq = 1; /* NOT support multi acq */
            if (slice_cnt == (slice_quant - 1))
            { /* next slice will be cardiac gated */
                ctlend_tab[slice_cnt] = ctlend_last[current_acq - 1];
            } 
            else
            { /* next slice will be internally gated */
                ctlend_tab[slice_cnt] = ctlend_intern;
            }
        } 
        else 
        {   /* Single phase, cross R-R */
            /* Initialize as if slice is NOT the last in a R-R */
            ctlend_tab[slice_cnt] = ctlend_intern; 

            if (slice_cnt  == current_sum_slices_acq)
            {
                current_acq += 1;
                /* Calculate # of slices in current acq */
                prev_sum_slices_acq = current_sum_slices_acq;
                if (current_acq <= slice_quant % subhacq)
                {
                    current_slices_acq = slice_quant / subhacq + 1;
                }
                else
                {
                    current_slices_acq = slice_quant / subhacq;
                }
                current_sum_slices_acq = prev_sum_slices_acq + current_slices_acq;

                slices_rep_offset = (current_slices_acq / subhrep) * 
                    (current_slices_acq % subhrep) +
                    (current_slices_acq % subhrep);

                /* Calculate # of slices in current rep */
                if ( (current_slices_acq % subhrep != 0) && (0 < slices_rep_offset) )
                {
                    current_slices_rep = current_slices_acq / subhrep + 1;
                }
                else
                {
                    current_slices_rep = current_slices_acq / subhrep;
                }

                rr_end = current_slices_rep - 1;
            }

            if (slice_cnt == (slice_quant - 1)) 
            { /* last slice */
                ctlend_tab[slice_cnt] = ctlend_last[current_acq - 1];
            }
            else if ((current_slices_acq <= subhrep) && (slice_quant >= subhacq * subhrep))
            {  /* At most 1 slice in each R-R. Each
                  slice is the first and last in an R-R in single acq case*/
                ctlend_tab[slice_cnt] = ctlend_fill[current_acq - 1];
            }
            else 
            {
                if ((slice_cnt - prev_sum_slices_acq) == rr_end) 
                { /* This is the last slice in an R-R */
                    rr += 1; /* up the rr counter */
                    if ((rr > subhrep) ||
                            ((current_slices_acq < subhrep) && (rr > current_slices_acq)))
                    {
                        rr = 1;
                    } 

                    /* Decide whether to use filled deadtime or
                       unfilled deadtime. Also recalculate rr_end,
                       the index of last slice of the next R-R interval */
                    if (rr < current_slices_acq % subhrep) 
                    { /* This is a filled R-R interval and the next
                         will be filled also. */
                        ctlend_tab[slice_cnt] = ctlend_fill[current_acq - 1];
                        rr_end += (int)(current_slices_acq / subhrep) + 1;
                    }
                    else if (rr == current_slices_acq % subhrep) 
                    { /* This R-R is filled but the next is not */
                        if ((current_slices_acq <= subhrep) && (slice_quant < subhacq * subhrep))
                        { /* Cross R-R with multi acq case. This is last slice in current acq */
                            ctlend_tab[slice_cnt] = ctlend_last[current_acq - 1];
                        }
                        else
                        {
                            ctlend_tab[slice_cnt] = ctlend_fill[current_acq - 1];
                            rr_end += (int)(current_slices_acq / subhrep);
                        }
                    }
                    else
                    { /* rr > current_slices_acq % subhrep, 
                         This is an unfilled R-R interval */
                        ctlend_tab[slice_cnt] = ctlend_unfill[current_acq - 1];
                        rr_end += (int)(current_slices_acq / subhrep);
                    }
                } 
            } 
        } 
    } 
    return SUCCESS;
}

/*******************************  MPS2  ***************************/
#ifdef __STDC__ 
STATUS mps2( void)
#else /* !__STDC__ */
    STATUS mps2() 
#endif /* __STDC__ */
{
    printdbg("Greetings from MPS2", debugstate);
    boffset(off_seqcore);
    rspent = L_MPS2;  
    rspdda = ps2_dda;

    if (cs_sat ==1)	/* Turn on Chemsat Y crusher */
        cstun=1;
    psdinit();
    strcpy(psdexitarg.text_arg, "mps2");
  
    rspent = L_MPS2;
    rspbas = 0;
    rspvus = 1;
    rspasl = pre_slice;
    rsprep = 30000;
    rspilv = 1;
    rspgy1 = 0;
    rspnex = 2;
    rspsct = 0;
    rspesl = -1;
    rspslqb = 0;
    rspslq = mux_flag?mux_slquant:false_slquant1;
    rspe1st = e1st;
    rspetot = etot;
    pass = pre_pass;

    rspfskillercycling = 1;

    if (ir_on == PSD_ON)  /* IR..MHN */
        setiamp(ia_rf0, &rf0, 0);


    rspgyc = 0;
    rspgzc = rspgyc;
    gyb_amp = 0;
    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    scanloop();
    printdbg("Normal End of MPS2", debugstate);
    rspexit();

    return SUCCESS;
} /* End MPS2 */

/*******************************  APS2  **************************/
#ifdef __STDC__ 
STATUS aps2( void )
#else /* !__STDC__ */
    STATUS aps2() 
#endif /* __STDC__ */
{
    printdbg("Greetings from APS2", debugstate);
    boffset(off_seqcore);
  
    rspent = L_APS2;
    rspdda = ps2_dda;
    if (cs_sat ==1)	/* Turn on ChemSat Y crusher */
	cstun = 1;
    psdinit();
 
    strcpy(psdexitarg.text_arg, "aps2");
  
    rspent = L_APS2;
    rspbas = 0;
    rspvus = 1;
    rspasl = -1;
    rsprep = 30000;
    rspilv = 1;
    rspgy1 = 0;
    rspnex = 2;
    rspsct = 0;
    rspesl = -1;
    rspslqb = aps2_rspslqb;
    rspslq = aps2_rspslq;
    rspe1st = e1st;
    rspetot = etot;
  
    rspacqb = pre_pass;
    rspacq  = pre_pass + 1;
    false_rspacqb = 0;
    false_rspacq = 1;
    rspprp = 1;

    rspfskillercycling = 1;

  
    if (ir_on == PSD_ON)
        setiamp(ia_rf0, &rf0, 0);

    rspgyc = 0;
    rspgzc = rspgyc;
    gyb_amp = 0;
    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    scanloop();
    printdbg("Normal End of APS2", debugstate);
    rspexit();
    return SUCCESS;
  
} /* End APS2 */

/***************************  SCAN  *******************************/
#ifdef __STDC__ 
STATUS scan( void )
#else /* !__STDC__ */
    STATUS scan() 
#endif /* __STDC__ */
{
    printdbg("Greetings from SCAN", debugstate);
    rspent = L_SCAN;
    rspdda = scan_dda;
    if (cs_sat == 1)	/* Turn on ChemSat Y crusher */
	cstun =1;
    psdinit();

    /*RTB0 correction*/
    rtb0_initialized =0;

    rspbas = rhbline;   /* used on blineacq only */
    rspvus = rhnframes + rhhnover + rhoscans;
    rspasl = -1;
    rsprep = reps;
    rspgy1 = 1;
    rspnex = nex;
    rspsct = 0;
    rspesl = -1;
    rspslqb = 0;
    rspslq = rspslqb + (mux_flag?mux_slquant:false_slquant1);
    rspilv = intleaves;
    rspgyc = 0;
    rspgzc = rspgyc;

    rspfskillercycling = 1;

    if (ir_on == PSD_ON)
        setiamp(ia_rf0, &rf0, 0);


    if (rawdata == PSD_ON && baseline > 0) {  /* collect reference scan for rawdata */
	ygradctrl(rspgyc, gyb_amp, etl);
	scanloop();
    }
    if (gyctrl == PSD_ON)
	rspgyc = 1;
    else
	rspgyc = 0;
    rspgzc = rspgyc;
    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    if (PSD_ON == navtrig_flag)
    {
        if(!skip_navigator_prescan)
        {
            nav_rrmeas_end_flag = 0;
            navigator_baseline_prescan(&nav_rrmeas_end_flag);

            if(nav_rrmeas_end_flag)
            {
                int i;
                boffset(off_seqcore);
                setwamp(SSPDS + DABDC, &pass_pulse, 0);
                setwamp(SSPD + DABPASS + DABSCAN, &pass_pulse, 2);
                setwamp(SSPDS + DABDC, &pass_pulse, 4);
                for (i=0; i<num_passdelay; i++) {
                    setperiod(1, &ssp_pass_delay, i);
                }
                startseq((short)0, (SHORT)MAY_PAUSE);
                rspexit();
            }
        }

        skip_navigator_prescan = 0;

#ifndef SIM
        setscantimestop();
        setscantimeimm(PSD_CLOCK_CARDIAC, pitscan, nreps*oprtrep, pitslice, opslicecnt);
        setscantimestart();
#endif

        num_slice_rr = (int)ceil((float)(rspslq)/oprtrep);

#ifndef SIM
        hbs_total = nreps*oprtrep;
        hbs_left = hbs_total;

        view_accepted = 0;
        view_rejected = 0;
#endif

        /* reset trigger status */
        nav_active = 0;
    }

    scanloop();

#ifdef PSD_HW
    if (PSD_ON == navtrig_flag || rtb0_flag) { /*RTB0 correction*/
        RtpEnd();
        isrtplaunched = 0;
        rtb0_initialized =0;
    }
#endif

    rspexit();
    return SUCCESS;
}

/***************************  REF  *******************************/
#ifdef __STDC__ 
STATUS ref( void )
#else /* !__STDC__ */
    STATUS ref() 
#endif /* __STDC__ */
{
    printdbg("Greetings from REF", debugstate);
    rspent = L_REF;
    rspdda = ref_dda; /* Refless EPI */
    if (cs_sat ==1)	/* Turn on ChemSat Y crusher */
	cstun=1;

    psdinit();

    rspbas = rhbline;   /* used on blineacq only */
    rspvus = rhnframes + rhhnover + rhoscans;
    rspasl = -1;
    rspgy1 = 1;
    rspnex = 1;
    rspsct = 0;
    rspesl = -1;
    rspgyc = 0;
    rspgzc = rspgyc;
    rspacqb = pre_pass;
    rspacq = pre_pass + 1;
    false_rspacqb = 0;
    false_rspacq = 1;
    rspslqb = pre_slice;
    rspslq = pre_slice + 1;
    rspprp = 1;
    rsprep = 1;

    rspfskillercycling = 1;

    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    if (ref_mode == 0 && rhpctemporal == 0) {
        rspacqb = 0;
        rspacq = act_acqs;
        false_rspacqb = 0;
        false_rspacq = false_acqs;
        rspslqb = 0;
        rspslq =  rspslqb + (mux_flag?mux_slquant:false_slquant1);
        if ( (mph_flag==1) && (acqmode==0) )
            rspprp = pass_reps;
        if ( (mph_flag==1) && (acqmode==1) )
            rsprep =  reps;
        rsprep = reps;
    } else if (ref_mode == 1 && rhpctemporal == 0) {
        rspacqb = pre_pass;
        rspacq = pre_pass + 1;
        false_rspacqb = 0;
        false_rspacq = 1;
        rspslqb = 0;
        rspslq = pre_slice+1;
        if ( (mph_flag==1) && (acqmode==0) )
            rspprp = pass_reps;
        if ( (mph_flag==1) && (acqmode==1) )
            rsprep =  reps;
        rsprep = reps;
    } else if (ref_mode == 2 && rhpctemporal == 0) {
        rspacqb = pre_pass;
        rspacq = pre_pass + 1;
        false_rspacqb = 0;
        false_rspacq = 1;
        rspslqb = pre_slice;
        rspslq = pre_slice+1;
        if ( (mph_flag==1) && (acqmode==0) )
            rspprp = pass_reps;
        if ( (mph_flag==1) && (acqmode==1) )
            rsprep =  reps;
        rsprep = reps;
    } else if (ref_mode == 0 && rhpctemporal != 0) {
        rspacqb = 0;
        rspacq = act_acqs;
        false_rspacqb = 0;
        false_rspacq = false_acqs;
        rspslqb =  0;
        rspslq = rspslqb + (mux_flag?mux_slquant:false_slquant1);
        rsprep = rhpctemporal;
    } else if (ref_mode == 1 && rhpctemporal != 0) {
	rsprep = rhpctemporal;
        rspacqb = pre_pass;
        rspacq = pre_pass + 1;
        false_rspacqb = 0;
        false_rspacq = 1;
        rspslqb = 0;
        rspslq = pre_slice+1;
    } else if (ref_mode == 2 && rhpctemporal != 0) {
        rspacqb = pre_pass;
        rspacq = pre_pass + 1;
        false_rspacqb = 0;
        false_rspacq = 1;
        rspslqb = pre_slice;
        rspslq = pre_slice+1;
    } else {
        return FAILURE;
    }

    if (rhpcileave == 0)
  	rspilv = intleaves;
    else
	rspilv = 1;

    if (PSD_ON == navtrig_flag)
    {
        if((!skip_navigator_prescan) && (PSD_OFF == calc_rate))
        {
            navigator_baseline_prescan(&nav_rrmeas_end_flag);
        }
        num_slice_rr = (int)ceil((float)(rspslq)/oprtrep);
    }

    /* HCSDM00153103 */
    if (PSD_OFF == calc_rate)
    {
        scanloop();
    }

    /* load current nav threshold and nav window in the next scan, when navigator prescan is skipped */
    /* HCSDM00176499 */
    if ((PSD_ON == navtrig_flag) && (PSD_OFF == calc_rate))
    {
        if(3 == nav_alg)
        {
            skip_navigator_prescan = 1;
            nav_prev_thresh = nav_currthresh;
            nav_prev_window = nav_currwindow;
        }

#ifdef PSD_HW
        RtpEnd();
        isrtplaunched = 0;
#endif
    }

    rspexit();
    return SUCCESS;
}

/* recv_phase_freq_init: Set receiver frequence and phase, including Maxwell correction */
STATUS recv_phase_freq_init(void)
{
    int ii, jj, kk;
    
    /* MRIge89403: added one more argument for EPI internal ref scan but set to 0 */
    /* RTB0 correction add 2 argument. slice_cfoffset_filtered[] is initialized to 0 at beginning of scanloop and updated when RTB0 is performed*/
    /* Distortion correction changes pepolar to rsp variable rsppepolar */
    epiRecvFrqPhs( opslquant, intleaves, etl, xtr-timedelta, refdattime, frt,
                   opfov, fullk_nframes,
                   opphasefov, b0ditherval, rf_phase_spgr, dro, dpo, rsp_info,
                   view1st, viewskip, gradpol, ref_switch, ky_dir, dc_chop,
                   rsppepolar, recv_freq, recv_phase_angle, recv_phase,
                   gldelayfval, a_gxw, debugepc, ref_with_xoffset,
                   asset_factor, iref_etl,
				   slice_cfoffset_filtered,eesp); /* MUSE use eesp instead of esp*/

    /* Call MaxwellCorrection Function (see epiMaxwellCorrection.e) */
    if (epiMaxwellCorrection() == FAILURE) return FAILURE;  /* this Maxwell correction only takes care of the      
                                                               parabolic shift due to maxwell related z2 B0 offset 
                                                               for axial plane */                                  
    
    /** save the nominal receiver phase angles to avoid the accumulative
        addition effect in the DWI B0-correction. The nominal phase is
        also used in HOEC Correction. **/
    for (ii=0; ii<opslquant; ii++)
    {
        for (jj=0; jj<intleaves; jj++)
        {
            for (kk=0; kk<tot_etl; kk++)
            {
                recv_phase_ang_nom[ii][jj][kk] = recv_phase_angle[ii][jj][kk];
            }
        }
    }

    return SUCCESS;
}

/* Refless EPI: scan_init() called in scan_loop() to switch back to scan with PE */
STATUS scan_init(void)
{
    rspent = L_SCAN;
    ref_switch = 0;

    recv_phase_freq_init();

    rspnex = nex;

    if (ir_on == PSD_ON) setiamp(ia_rf0, &rf0, 0);

    if (gyctrl == PSD_ON)
    {
        rspgyc = 1;
    }
    else
    {
        rspgyc = 0;
    }
    rspgzc = rspgyc;

    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    if (epi_flair == PSD_OFF)
    {
        dda_packe = dda_pack - 1;
    }

    return SUCCESS;
}

/* Refless EPI: ref_init() called in scan_loop() to switch the first pass of scan to ref without PE */
STATUS ref_init(void)
{
    rspent = L_REF;
    ref_switch = 1;

    recv_phase_freq_init();

    ref_switch = 0;

    rspnex = 1;
    
    rspgyc = 0;
    rspgzc = rspgyc;

    ygradctrl(rspgyc, gyb_amp, etl);

    if ( use_slice_fov_shift_blips && (PSD_ON == mux_flag) && (mux_slices_rf1 > 1) )
    {
        zgradctrl(0, 0, 0, etl, 0);
    }

    if (epi_flair == PSD_OFF)
    {
        dda_packe = dda_pack - 1;
    }

    return SUCCESS;
}

/*************************** SCANLOOP *******************************/
#ifdef __STDC__ 
STATUS scanloop( void )
#else /* !__STDC__ */
    STATUS scanloop() 
#endif /* __STDC__ */
{
    int pause; /* pause attribute storage loc */
    int i;
    char fname_coreinfo[255];
    char fname_diff_order[255];
#ifdef PSD_HW
    const char *dir_coreinfo = "/usr/g/service/log";
#else
    const char *dir_coreinfo = "./";
#endif

#ifdef DEBUG_CORE
    if (debug_core == PSD_ON)
    {
        sprintf(fname_coreinfo, "%s/EPI_coreinfo.log", dir_coreinfo);
        fp_coreinfo = fopen(fname_coreinfo, "w");
        if (fp_coreinfo == NULL)
        {
            return FAILURE;
        }
    }
#endif

    if (diff_order_debug == PSD_ON)
    {
        if(rspent == L_REF)
        {
            sprintf(fname_diff_order, "%s/EPI2_diff_order_ref.log", dir_coreinfo);
        }
        else if(rspent == L_SCAN)
        {
            sprintf(fname_diff_order, "%s/EPI2_diff_order_scan.log", dir_coreinfo);
        }
        else
        {
            sprintf(fname_diff_order, "%s/EPI2_diff_order_other.log", dir_coreinfo);
        }
        fp_diff_order = fopen(fname_diff_order,"w");
        if(fp_diff_order == NULL)
        {
            return FAILURE;
        }
    }

    /*RTB0 correction*/
    if (debug_unitTest == PSD_ON)
    {
        sprintf(fname_coreinfo, "%s/EPI2_LoopOrderUnitTest.log", dir_coreinfo);
        fp_utloopinfo = fopen(fname_coreinfo, "w");
        if (fp_utloopinfo == NULL)
        {
            return FAILURE;
        }
        else
        {
            fprintf(fp_utloopinfo,"Loop\t pass_rep\t pass\t dda_ind\t dda_fl_sl\t dda_sl\t core_rep\t ileave\t nex\t false_pass\t fl_sl\t sl\t \n");
        }
    }

    /*RTB0 correction*/
    if(rtb0_flag && rspent == L_SCAN && rtb0_debug)
    {
        time_t now_epoch = time(NULL);
        struct tm now; 
        int uid;
    
        localtime_r(&now_epoch, &now);
        uid = now.tm_sec +
              now.tm_min  * 100 +
              now.tm_hour * 10000 +
              now.tm_mday * 1000000 +
              (now.tm_mon +1) * 100000000;
        sprintf(fname_coreinfo, "%s/EPI2_sliceCF_data.%d", dir_coreinfo, uid);
        fp_cfdata = fopen(fname_coreinfo, "w");
        if (fp_cfdata == NULL)
        {
            return FAILURE;
        }

        fprintf(fp_cfdata, "slloc -> sltime\n");
        for(i=0; i<opslquant; i++)
            fprintf(fp_cfdata, "%d %d\n", i, slloc2sltime[i]);
        fprintf(fp_cfdata, "sltime -> slloc\n");
        for(i=0; i<opslquant; i++)
            fprintf(fp_cfdata, "%d %d\n", i, sltime2slloc[i]);
    }

    printdbg("Greetings from scanloop", debugstate);
    
    /*RTB0 correction*/
    for(i=0; i<DATA_ACQ_MAX; i++)
    {
        slice_cfoffset_TARDIS[i] = 0;
        slice_cfoffset[i] = 0.0;
        slice_cfoffset_filtered[i] = 0.0;
    }
    
    if (cs_sat == PSD_ON) 
	cstun = 1;
    
    setiamp(ia_rf1, &rf1, 0);   /* Reset amplitudes */
    if (oppseq == PSD_SE) {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            setiamp(ia_rf2, &rf2, 0);
        } else {
            setiamp(ia_rf2, &rf2right, 0);
            setiamp(ia_rf2, &rf2left, 0);
        }
    }
    
    /* turning spatial & chem SAT on */ 
    SpSat_Saton(0);
    
    if (cs_sat > 0)  
	setiamp(ia_rfcssat, &rfcssat, 0);
    
    strcpy(psdexitarg.text_arg, "scan");
    
    if (opcgate==PSD_ON) {
#ifndef PSD_HW
	/* Don't check ecg rate in simulator mode. */
#else /* PSD_HW */
	if (test_getecg == PSD_ON) {
            getecgrate(&rsp_hrate);
            if (rsp_hrate == 0)
		psdexit(EM_PSD_NO_HRATE,0,"","psd scan entry point",0);
	}
#endif /* !PSD_HW */
	rsp_card_intern = ctlend + scan_deadtime;
    int acq_cnt = 0;
    for (acq_cnt = 0; acq_cnt < acqs; acq_cnt++)
    {
        rsp_card_last[acq_cnt]   = ctlend_last[acq_cnt] + scan_deadtime;
        rsp_card_fill[acq_cnt]   = ctlend_fill[acq_cnt] + scan_deadtime;
        rsp_card_unfill[acq_cnt] = ctlend_unfill[acq_cnt] + scan_deadtime;
    }

	CardInit(ctlend_tab, rsp_card_intern, rsp_card_last,
                 rsp_card_fill, rsp_card_unfill, act_acqs, ophrep, opphases);
    } else if (oprtcgate==PSD_ON){
#ifndef PSD_HW
	    /* Don't check ecg rate in simulator mode. */
#else /* PSD_HW */
        if (test_getecg == PSD_ON) {
            getresprate(&rsp_hrate);
            if (rsp_hrate == 0) {
                psdexit(EM_PSD_NO_RESP_RATE,0,"","psd scan entry point",0);
            }
        }
#endif /* !PSD_HW */
        rsp_card_intern = ctlend + scan_deadtime;
        int acq_cnt = 0;
        for (acq_cnt = 0; acq_cnt < acqs; acq_cnt++)
        {
            rsp_card_last[acq_cnt]   = ctlend_last[acq_cnt] + scan_deadtime;
            rsp_card_fill[acq_cnt]   = ctlend_fill[acq_cnt] + scan_deadtime;
            rsp_card_unfill[acq_cnt] = ctlend_unfill[acq_cnt] + scan_deadtime;
        }

        CardInit(ctlend_tab, rsp_card_intern, rsp_card_last,
                 rsp_card_fill, rsp_card_unfill, act_acqs, oprtrep, rt_opphases);
 
    } else
	setperiod(scan_deadtime, &seqcore, 0);
 
    inversRspRot(inversRR, rsprot_unscaled[0]); 

    /* DTI */    
    if (opdiffuse == PSD_ON || tensor_flag == PSD_ON) {

        /* DTI BJM: (dsp) set the instruction amplitude */
        if (PSD_OFF == dualspinecho_flag)
        {
            setiampt(0, &gxdl, 0);
            setiampt(0, &gxdr, 0);
            setiampt(0, &gydl, 0);
            setiampt(0, &gydr, 0);
            setiampt(0, &gzdl, 0);
            setiampt(0, &gzdr, 0);
	    if(ftde_flag == PSD_ON){/* granty edit for full time diffusion encoding */
		setiampt(0, &gxde, 0);
	        setiampt(0, &gyde, 0);
	        setiampt(0, &gzde, 0);
	    }
        } else {
            setiampt(0, &gxdl1, 0);
            setiampt(0, &gxdr1, 0);
            setiampt(0, &gxdl2, 0);
            setiampt(0, &gxdr2, 0);
            
            setiampt(0, &gydl1, 0);
            setiampt(0, &gydr1, 0);
            setiampt(0, &gydl2, 0);
            setiampt(0, &gydr2, 0);

            setiampt(0, &gzdl1, 0);
            setiampt(0, &gzdr1, 0); 
            setiampt(0, &gzdl2, 0);
            setiampt(0, &gzdr2, 0);
        }
    }
    diff_pass_counter = 0;
    diff_pass_counter_save = 0;

    /* BJM: passreps control diffusion gradients */
    for (pass_rep = 0; pass_rep < rspprp; pass_rep++) 
    {
#ifdef DEBUG_CORE
        if (debug_core == PSD_ON)
        {
            fprintf(fp_coreinfo,"scanloop:pass_rep %d/%d\n", pass_rep, rspprp-1);
        }
#endif
        
        /* Refless EPI: make the first pass of scan as ref */
        if ((opdiffuse==PSD_ON || tensor_flag==PSD_ON) && (rspent != L_MPS2 && rspent != L_APS2))
        {
            /* for no ref 2 and 1 cases, first pass is initialized as ref scan without PE */
            if (ref_in_scan_flag)
            {
                if (pass_rep == 0)
                {
                    ref_init();
                }
                else if (pass_rep == 1)
                {
                    /* scan_init() only needs to be done once after the ref scan
                       because all remaining passes are scan passes */
                    scan_init();
                }
            }
	    
            /* RTB0 Correction*/
            /* Initialize RTB0 RTP communication*/
            /* dummy seq is played to avoid timeout error because sometimes */
            /* it takes time to load RTP variables for the first time*/ 
            /* RTP Init should happen after ref_init() or scan_init() depending*/
            /* on whether refless is ON & rtb0 mode*/
            if (rtb0_flag && !rtb0_initialized)
            {
                if ((ref_in_scan_flag && rtb0_flag && pass_rep == 0) ||
                   (!ref_in_scan_flag && pass_rep == 0))
                {	
                    play_rtb0dummyseq(1);
                    reset_to_epi2scan();

                    rtB0ComRspInit();
#ifdef PSD_HW
                    routeDataFrameDab(&rtb0echo, ROUTE_TO_RTP, cfcoilswitchmethod);
#endif
                    rtb0_initialized = 1;
                 }
            }
	
        }
        
        /* Distortion Correction. Note that ref scan or pass is defined rspent==L_REF.
           Therefore, invertGy1=-1 state will only happen for expected RPG pass.
           All other passes will have invertGy1=1. */
        if ((rpg_flag > 0) && (L_SCAN == rspent))
        {
            if (pass_rep > (ref_in_scan_flag?1:0)) 
            {   /* Not the first volume nor REF entry point */
                rsppepolar = (rpg_flag == RPG_FWD_THEN_REV) ? 1 : 0;
                invertGy1 = 1;
            }
            else 
            {   /* First volume. Do RPG here. */
                rsppepolar = (rpg_flag == RPG_FWD_THEN_REV) ? 0 : 1;
                invertGy1 = -1;
            }
            recv_phase_freq_init();
        }
        else
        {
            rsppepolar = pepolar;
            invertGy1 = 1;
        }

        /* Distortion Correction Unit Test */
        if ( (rpgUnitTestPtrSize > -1) && (pass_rep < rpgUnitTestPtrSize) && (NULL != rpgUnitTestPtr) )
        {
            rpgUnitTestPtr[pass_rep] = rsppepolar;
        }

        if ((opdiffuse == 1 && incr == 1) || (tensor_flag == PSD_ON)) 
        {
            /* BJM: increment diffusion gradients */ 
            /* RPG change setting dshot here */
            diffstep(pass_rep - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
        }

        diff_pass_counter_save = diff_pass_counter;

        for (pass = rspacqb; pass < rspacq; pass++) 
        {
#ifdef DEBUG_CORE
            if (debug_core == PSD_ON)
            {
                fprintf(fp_coreinfo,"scanloop:acq %d/%d\n", pass, rspacq-1);
            }
#endif
 
            pass_index = pass + pass_rep*rspacq;
            
            if (pass_index < rspacq)  {   /* MRIge57446: acquire baselines for the 1st rep of first pass */
                if (baseline > 0) {                     /* acquire the baseline */
                    if (baseline > 1)  /* play first n-1 baselines at fast rate */
                        setperiod(bl_acq_tr1, &seqblineacq, 0);
                    else
                        setperiod(bl_acq_tr2, &seqblineacq, 0);
                    blineacq();
                }
            }

            if (PSD_ON == oprtcgate)
            {
                rspslq = slc_in_acq[pass];
            }
            else if (PSD_ON == navtrig_flag)
            {
                rspslq = slc_in_acq[pass];
                num_slice_rr = (int)ceil((float)(rspslq)/oprtrep);
            }
            
            boffset(off_seqcore);
            
            setperiod(scan_deadtime, &seqcore, 0);
            
            /* initialize wait time and pass packet for disdacqs, etc. */
            setwamp(SSPDS, &pass_pulse, 0);
            setwamp(SSPD, &pass_pulse, 2);
            setwamp(SSPDS, &pass_pulse, 4);
            for (i=0; i<num_passdelay; i++) 
                setperiod(1, &ssp_pass_delay, i);
            pause = MAY_PAUSE;
            printdbg("Null ssp pass packet", debugstate);
            diff_pass_counter = diff_pass_counter_save;
            core();                                 /* acquire the data */
            
            settriggerarray((SHORT)1, rsptrigger_temp);
            
            /* Return to standard trigger array and core offset */
            settriggerarray((SHORT)(opslquant*opphases), rsptrigger);
            
            /* If this isn't the last pass and we are */
            /* doing relaxers  */
            if ((SatRelaxers)&&( (pass!=(rspacq-1)) && (pass_rep!=(rspprp-1)) ) )
                SpSatPlayRelaxers();
            
        } /* End pass loop */    
    } /* End pass rep loop */
    
#ifdef DEBUG_CORE
    if (debug_core == PSD_ON)
    {
        fclose(fp_coreinfo);
    }
#endif
    if (debug_unitTest == PSD_ON)
    {
        fclose(fp_utloopinfo);
    }
    /*RTB0 correction*/
    if(rtb0_flag && rspent == L_SCAN && rtb0_debug)
    {
        fclose(fp_cfdata);
    }

    if (diff_order_debug == PSD_ON)
    {
        fclose(fp_diff_order);
    }
    printdbg("Normal End of SCAN", debugstate);
    return SUCCESS;
    
} /* End SCANLOOP */

/*****************************  CORE  *************************/
#ifdef __STDC__ 
STATUS core( void )
#else /* !__STDC__ */
    STATUS core() 
#endif /* __STDC__ */
{
    int pause = MAY_PAUSE;
    int InterPassDoneFlag = 0;
    int disdaq_index;
    int i; 
    int tmpi;

    /* t1flair_stir */
    int real_slice_IR;
    int slice_flag;

    /*RTB0 correction*/
    int first_rtb0_sliceindex;
    int last_rtb0_sliceindex;
    int cf_counter;
    int num_wait;

@inline RTB0.e RTB0_clock_decl

    /*RTB0 correction*/
    int dda_in_pass_rep; /*indicate which pass_rep should play the disdaq block if rspdda > 0*/
    int dda_rtb0 = 0; /*additional TR for RTB0*/
 
#ifdef PRINTRSP
    printdbg("Starting Core", debugstate);
#endif  

    /* t1flair_stir */ 
    if ( (PSD_ON == t1flair_flag) && (PSD_ON == act_edge_slice_enh_flag) )
    {
        T1flair_calc_edgeslice_freq_pha();
    }

    /* MRIge44963 - Check if there is two more slices in the first pack, Hou */
    /* MRIge48302 - because the number of slices in L_REF is not the same as */
    /* L_SCAN, so that the slq_to_shift could be 1 even there is no need to */
    /* shift a slice.  Exclude this case by adding L_SCAN to the if. */  
    
    slq_to_shift = 0;
    if ( (epi_flair) &&
         ((rspent == L_SCAN) || ((rspent == L_REF) && (ref_in_scan_flag == PSD_ON))) )
    {
        if ( (2*rspslq - slc_in_acq[pass_index]) == false_acqs )
            slq_to_shift = 1;
        else
            slq_to_shift = 0;
    }
    
    /******* disdaq block ***********************************/
    /* Refless EPI: Play dda in T2 loop (pass_rep = 1) for DW-EPI Flair */
    /*RTB0 correction: Clean up the code. Basically, if ref_in_scan_flag is ON, */
    /*then in L_REF, if rtb0 is ON, then go into dda loop so the first dda (-1) can be used for rtb0. */
    /*In L_SCAN, don't play dda except when epi_flair is ON*/
    /*and the dda (if played) should be played in pass_rep = 1 (L_SCAN). */
    /*If ref_in_scan_flag is OFF, then play dda as usual (ie. in pass_rep = 0). */
    /*-1 means don't play dda*/    
    if (ref_in_scan_flag == PSD_ON)
    {
        if (rspent == L_SCAN)
            dda_in_pass_rep = (epi_flair == PSD_ON)? 1:-1; 
        if (rspent == L_REF) 
            dda_in_pass_rep = (epi_flair == PSD_OFF || rtb0_flag == PSD_ON)? 0:-1; 
    } 
    else 
    {
        dda_in_pass_rep = 0;
    }

    if ((rspdda > 0 || rtb0_flag) && (pass_rep == dda_in_pass_rep)){

        acq_data = (int)DABOFF;
        dabrbaload(0, 0, 0, tot_etl, 0);

        setperiod((int)tf[0], &wgx, 0);
        setperiod((int)tf[0], &wgy, 0);
        setperiod((int)tf[0], &wgz, 0);
        setperiod((int)tf[0], &wssp, 0);
        setperiod((int)tf[0], &womega, 0);      /* ufi2_ypd */

        if (rspent == L_REF)
        {
            zgradctrl(0, 0, 0, etl, 0);
        }

        if (gyctrl == PSD_ON && rspent != L_REF &&
            rspent != L_MPS2 && rspent != L_APS2) {
            setiampt(invertGy1*gy1f[0], &gy1, 0);
            if (ygmn_type == CALC_GMN1) {
                setiampt(gymn[0], &gymn1, 0);
                setiampt(-gymn[0], &gymn2, 0);
            }
        }

        acq_sl = 0;
        attenlockon(&atten);

        use_sl = 0;


        cf_counter = 0; /*RTB0 correction*//*move this here for STIR cases, otherwise, the cf_counter would be reset to 0 after the first dda (1 slice only), and that will mess up the indexing relationship between cf_counter & processedIndex*/
        dda_rtb0 =0;
       
        /*RTB0 correction: add an extra dda for RTB0 data collection. This dda will be indexed as -1*/
        if (rtb0_flag && pass ==0)
        {
            if ((ref_in_scan_flag == PSD_ON && rspent == L_REF) ||
               (ref_in_scan_flag == PSD_OFF && rspent == L_SCAN))
            {
                dda_rtb0 = 1;
            }
        }
 
        for (disdaq_index = dda_packb-dda_rtb0; disdaq_index < dda_packe; disdaq_index++)
        {
#ifdef DEBUG_CORE
            if (debug_core == PSD_ON)
            {
                fprintf(fp_coreinfo,"core:dda:%d/%d\n", disdaq_index, dda_packe-1);
            }
#endif

	    /*RTB0 correction: determine whether to play rtb0 related things*/
	    if (dda_rtb0 != 0 && disdaq_index==(dda_packb-dda_rtb0))
	    {
                in_rtb0_loop = 1;
	    }
	    else
	    {
                in_rtb0_loop = 0;
	    }
	
	    /*RTB0 correction*/
	    if (rtb0_flag)
	    {
                if(in_rtb0_loop ==1)
                {	
                    attenlockoff(&atten);
                    if(pscR1-rtb0_r1_delta > 0)
                    {
                        set_dynr1(pscR1-rtb0_r1_delta); 
        	        /* this only works on DV. need to change on HD */
                    }
                    setiampt(freqSign*ia_gz1, &gz1, 0);
                }	
                else
                {
                    attenlockon(&atten);
                    setiampt(0, &gz1, 0);
                }	
            }	

            if (epi_flair && rspent == L_SCAN) 
            {
                /* MRIge81039  NU */
                setrotatearray((SHORT)(opslquant*opphases),rsprot_orig[0]);

                /* MRIge44963 - need to subtract slq_to_shift from rspslq, HOU */
                for (false_slice = rspslqb; false_slice < rspslq-slq_to_shift; false_slice++) 
                {
#ifdef DEBUG_CORE
                    if (debug_core == PSD_ON)
                    {
                        fprintf(fp_coreinfo,"core:dda_inv:slice:%d/%d\n", false_slice, rspslq-slq_to_shift-1);
                    }
#endif
                    printdbg("Starting Interleaved Inversion", debugstate);
                    boffset(off_seqinv);
                    
                    slice_tmp = false_slice + (rspslq-slq_to_shift);
                    if (slice_tmp<slc_in_acq[pass_index]) {
                        slice = slice_tmp;
                        setiamp(ia_rf0, &rf0, false_slice);
                    }
                    else    
                    {
                        slice = 0;
                        setiamp(0, &rf0, false_slice);
                    } 

                    if (rspesl == -1)
                    {    
                        if (acqmode==0) /* interleaved */
                            sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                        if (acqmode==1) /* sequential */
                            sliceindex = acq_ptr[pass_index];
                    }
                    else
                        sliceindex = acq_ptr[pass_index] + rspesl;
                    
                    /* Load Transmit Frequencies */
                    setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, false_slice);
                    /* setfrequency(rf0_freq[sliceindex], &rf0, 0); */
                    /*	setiphase(rf0_pha[sliceindex], &rf0, 0); */
                      
                    /* MRIge81039  NU */
                    if ((rspent== L_CFH) || (rspent == L_CFL))
                        setrotatearray((SHORT)(opslquant*opphases),rsprot_orig[0]);
                    else
                        setrotatearray((SHORT)(opslquant*opphases),rsprot[0]);

                } /*IR prep */
                
                startseq((short)sliceindex, (SHORT)MAY_PAUSE);
                
                if (debug_unitTest)
                    fprintf(fp_utloopinfo,"%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t \n", "dda_flair:", pass_rep, pass, disdaq_index, false_slice, -1, -1,-1, -1,-1,-1,-1);
            } /*epi_flair*/
            
            boffset(off_seqcore); /* switch back to core seq */

            /* t1flair_stir */
            if (PSD_ON == t1flair_flag)
            {
                if ((disdaq_index == dda_packb) && dda_t1flair)
                {
                    rspslq = slquant_in_ti;
                }
                else
                {
                    rspslq = false_slquant1;
                }
            }
            
            /* MRIge44963 - need to subtract slq_to_shift from rspslq, HOU */
            for (false_slice = rspslqb; false_slice < rspslq-slq_to_shift; false_slice++) 
            { 
#ifdef DEBUG_CORE
                if (debug_core == PSD_ON)
                {
                    fprintf(fp_coreinfo,"core:dda_img:slice:%d/%d\n", false_slice, rspslq-slq_to_shift-1);
                }
#endif               

                if ((PSD_ON == navtrig_flag) && (PSD_OFF == calc_rate) && ((L_REF == rspent) || (L_SCAN == rspent)) &&
                    (false_slice % num_slice_rr == 0))
                {
                    NavigatorPlayTrig();
#ifndef SIM
                    if ((rspent == L_REF) && (ref_in_scan_flag == PSD_ON))
                    {
                        scantime = (60s / (float)oprtrate) * (float)hbs_left;
                        setscantimestop();
                        setscantimeimm(PSD_CLOCK_CARDIAC, scantime, hbs_left,pitslice,opslicecnt);
                        setscantimestart();
                    }
#endif
                }

                if(epi_flair)
                {  
                    slice_tmp = false_slice + (rspslq-slq_to_shift);
                }
                else
                {
                    slice_tmp = false_slice;
                }
                if (slice_tmp<slc_in_acq[pass_index]) 
                    slice = slice_tmp;
                else
                    slice = 0;   


                slice1 = slice;

                if (rspesl == -1)
                {
                    if (acqmode==0) /* interleaved */
                        sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                    if (acqmode==1) /* sequential */
                        sliceindex = acq_ptr[pass_index];
                }
                else
                    sliceindex = acq_ptr[pass_index] + rspesl;

                /* Set cardiac delays and end times */
                if (opcgate || oprtcgate) {

                    /* Build the trigger for multi-slice, multi-phase cardiac */
                    msmpTrig();

                    if ((rspent == L_SCAN)||(rspent == L_MPS2) 
                        ||(rspent == L_APS2)||(rspent == L_REF))
                        setperiod(ctlend_tab[sliceindex],&seqcore ,0);

                    /*  first slice in RR */
                    if (rsptrigger[sliceindex] != TRIG_INTERN) {	
                        if ((rspent == L_SCAN)||(rspent == L_MPS2)
                            ||(rspent == L_APS2)) {
                            /* Use cardiac trigger delay */
                            setperiod(td0, &x_td0, 0);
                            setperiod(td0, &y_td0, 0);
                            setperiod(td0, &z_td0, 0);
                            setperiod(td0, &rho_td0, 0);
                            setperiod(td0, &theta_td0, 0);
                            setperiod(td0, &omega_td0, 0);
                            setperiod(td0, &ssp_td0, 0);
                        }
                    } else {
                        /* Bypass cardiac trigger delay */
                        setperiod((int)GRAD_UPDATE_TIME, &x_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &y_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &z_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &rho_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &theta_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &omega_td0, 0);
                        setperiod((int)GRAD_UPDATE_TIME, &ssp_td0, 0);
                    }
                } /* if opcgate */

                /* t1flair_stir */
                if (PSD_ON == t1flair_flag)
                {
                    real_slice_IR = 0;
                    slice_flag = IMGSLICE;
                    sliceindex = (false_slice + slquant_in_ti)%rspslq + acq_ptr[pass_index];
                    if ( (dummyslices >= 0) || (act_edge_slice_enh_flag == PSD_ON) )
                    {
                        real_slice_IR =  real_slice_acq_seq[pass][(false_slice + slquant_in_ti)%rspslq];
                        sliceindex = acq_ptr[pass_index] + real_slice_IR;
                        slice_flag = T1flair_slice_flag[pass][(false_slice + slquant_in_ti)%rspslq];
                    }
                    sliceindex %= opslquant; 

                    if (slice_flag == EDGESLICE)
                    {
                        if (real_slice_IR == edgeslice1)
                        {
                            setfrequency(freqSign*edgeslice1freq+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                            setiphase(edgeslice1pha, &rf0, 0);
                        }
                        else
                        {
                            setfrequency(freqSign*edgeslice2freq+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                            setiphase(edgeslice2pha, &rf0, 0);
                        }
                        setiamp(ia_rf0, &rf0, 0);
                    }
                    else if (slice_flag == IMGSLICE)
                    {
                        setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                        setiphase(rf0_pha[sliceindex], &rf0, 0);
                        setiamp(ia_rf0,&rf0,0);
                    }
                    else
                    {
                        setiamp(0,&rf0,0);
                    }

                    /* t1flair_stir: the imaging sequence's sliceindex,
                     * slice_flag, etc.
                     */
                    slice = real_slice_acq_seq[pass][false_slice];
                    sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                    sliceindex1 = sliceindex; 
                    slice_flag = T1flair_slice_flag[pass][false_slice];

                    /*RTB0 correction*/
                    if(rtb0_flag && dda_t1flair)
                    {
                        if (in_rtb0_loop == 1 && false_slice < rspslq)  
                        {
                            if (ss_rf1 == PSD_ON)
                            {
                                /* need to turn off rf0 to have enough signal for CF offset measurement */
                                setiamp(0,&rf0,0);
                                if (rtb0_gzrf0_off)
                                {
                                    setiampt(0, &gzrf0, INSTRALL); 
                                }
                            }
                        }
                    }
                }
                else if (slice_tmp<slc_in_acq[pass_index])
                {   /* live slice */
                    if (!aspir_flag)
                    {
                        /* turn on RHO BOARD */
                        setieos((SHORT)EOS_PLAY, &rho_td0, 0);
                    }
                    else
                    {
                        /* turn on RHO BOARD */
                        setieos((SHORT)EOS_PLAY, &rf1, 0);
                    }
                    use_sl = 1;
                }
                else {
                    /* Dummy slice */
                    /* turn off RHO BOARD */
                    if (!aspir_flag)
                    {
                        setieos((SHORT)EOS_DEAD, &rho_td0,0);
                    }
                    else
                    {
                        /* play ASPIR rf only */
                        setieos((SHORT)EOS_DEAD, &rf1,0);
                    }
                    use_sl = 0;
                    if (rspesl == -1) {
                        sliceindex = (acq_ptr[0])%opslquant;
                        sliceindex1 = (acq_ptr[0])%opslquant;
                    }
                }

                if (epi_flair) {
                    /* MRIge44963 - need to subtract slq_to_shift so that the last slice in a pack */
                    /* can have longer deadtime (scan_deadlast) to prevent cross talk from IR pulse, HOU */
                    if (false_slice == rspslq-1-slq_to_shift)
                        setperiod(scan_deadlast,&seqcore,0); 
                    else
                        setperiod(scan_deadtime,&seqcore,0);
                }

                SpSatUpdateRsp(1, pass_index, opccsat);

                if( (PSD_ON == irprep_flag) && (t1flair_flag != PSD_ON) )
                {
@inline Inversion_new.e InversionRSPcore 
                }    

                /* t1flair_stir */
                /* Play the IR rf pulses for the 1st excitation if T1FLAIR is on,
                   and turn off the rf1 and rf2 rf pulses. The data acquisition has
                   been  turn off. */
                if( (PSD_ON == t1flair_flag) &&
                    ( (slice_flag != IMGSLICE) ||
                      ( (disdaq_index == dda_packb) && (dda_t1flair) )
                    )
                  )
                {
                    setiamp(0, &rf1, 0);
                    if (oppseq == PSD_SE) /* DTI */
                    {
                        if (PSD_OFF == dualspinecho_flag)
                        {
                            setiamp(0, &rf2, 0);
                        }
                        else
                        {
                            setiamp(0, &rf2right, 0);
                            setiamp(0, &rf2left, 0);
                        }
                    }
                }
                else
                {
                    if (ssRsp() == FAILURE) return FAILURE;

                    setiamp(ia_rf1, &rf1, 0);

                    if (rfov_flag)
                    {
                        /* SVBranch: HCSDM00259122  - FOCUS walk sat */
                        if (walk_sat_flag) setrfwk();
                        
                        setfrequency(0, &rf1, 0);
                        setthetarf1(sliceindex); /* control frequency through theta wave */
                    }
                    else
                    {
                        setfrequency(freqSign*rf1_freq[sliceindex] + d_cf+slice_cfoffset_TARDIS[sliceindex], &rf1, 0);
                    }

                    if (sliceindex == 0) {
#ifdef DEBUG_CORE
                        if (debug_core == PSD_ON)
                        {
                            fprintf(fp_coreinfo,"DDA: Phase cycle number %d\n",(core_rep+reps*pass_rep));
                        }
#endif
                        if (mux_flag && mux_slices_rf1 > 1) {
                            if (phase_cycle_rf2) {
                                setwave( ptr_rf1[0], &rf1, 0);
                                if( opdualspinecho == PSD_OFF) {
                                    setwave( ptr_rf2[0], &rf2, 0);
                                } else {
                                    setwave( ptr_rf2[0], &rf2left,  0);
                                    setwave( ptr_rf2[0], &rf2right, 0);
                                }
                            }
                        }
                    }

                    if (oppseq == PSD_SE) /* DTI */
                    {
                        if (PSD_OFF == dualspinecho_flag)
                        {
                            if (mux_flag && verse_rf2) {
                                if (use_omegatheta) {
                                    setfrequency(0, &rf2, 0);
                                    setiamp(freqSign*max_pg_iamp, &th_omthrf2, 0);
                                    setiamp(freqSign*om_iamp_omthrf2[sliceindex], &om_omthrf2, 0);
                                    setwave(om_wave_omthrf2[sliceindex], &om_omthrf2, 0);
                                    setwave(th_wave_omthrf2[sliceindex], &th_omthrf2, 0);
                                } else if (thetarf2_flag == PSD_OFF) {
                                    setfrequency(freqSign*rf2_freq[sliceindex], &rf2, 0);
                                    setiamp(0, &thetarf2, 0);
                                } else {
                                    setiamp(freqSign*thetarf2_freq[sliceindex],&thetarf2,0);
                                    setfrequency(0, &rf2, 0);
#ifdef DEBUG_CORE
                                    if (debug_core == PSD_ON)
                                    {
                                        fprintf(fp_coreinfo,"FM: thetarf2_freq[%d]=%d\n",sliceindex,freqSign*thetarf2_freq[sliceindex]);
                                    }
#endif
                                }
                            } else {
                                setfrequency(freqSign_rf2*rf2_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf2, 0);
                            }
                            setiphase(rf2_pha[sliceindex], &rf2, 0);
                            setiamp(ia_rf2, &rf2, 0);
                        } else {
                            if (mux_flag && verse_rf2) {
                                if (use_omegatheta) {
                                    setfrequency(0, &rf2left, 0);
                                    setfrequency(0, &rf2right, 0);
                                    setiamp(freqSign_rf2left*max_pg_iamp, &th_omthrf2left, 0);
                                    setiamp(freqSign_rf2right*max_pg_iamp, &th_omthrf2right, 0);
                                    setiamp(freqSign_rf2left*om_iamp_omthrf2left[sliceindex], &om_omthrf2left, 0);
                                    setiamp(freqSign_rf2right*om_iamp_omthrf2right[sliceindex], &om_omthrf2right, 0);
                                    setwave(om_wave_omthrf2left[sliceindex], &om_omthrf2left, 0);
                                    setwave(om_wave_omthrf2right[sliceindex], &om_omthrf2right, 0);
                                    setwave(th_wave_omthrf2left[sliceindex], &th_omthrf2left, 0);
                                    setwave(th_wave_omthrf2right[sliceindex], &th_omthrf2right, 0);
                                } else if (thetarf2_flag == PSD_OFF) {
                                    setfrequency(freqSign_rf2left*rf2_freq[sliceindex], &rf2left, 0);
                                    setiamp(0, &thetarf2left, 0);
                                    setfrequency(freqSign_rf2right*rf2_freq[sliceindex], &rf2right, 0);
                                    setiamp(0, &thetarf2right, 0);
                                } else {
                                    setiamp(freqSign_rf2right*thetarf2_freq[sliceindex],&thetarf2right,0);
                                    setiamp(freqSign_rf2left*thetarf2_freq[sliceindex],&thetarf2left,0);
                                    setfrequency(0, &rf2right, 0);
                                    setfrequency(0, &rf2left, 0);
                                }
                            } else {
                                setfrequency(freqSign_rf2right*rf2_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf2right, 0);
                                setfrequency(freqSign_rf2left*rf2_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf2left, 0);
                            }
                            setiphase(rf2right_pha[sliceindex1], &rf2right , 0);
                            setiphase(rf2left_pha[sliceindex1],&rf2left , 0);
                            setiamp(ia_rf2, &rf2right, 0);
                            setiamp(ia_rf2, &rf2left, 0);
                        }
                    }
                } 

                /*RTB0 correction*/
                if (rtb0_flag)
                {
                    if (in_rtb0_loop == 1 && slice_tmp < slc_in_acq[pass_index])
                    {
                        loaddab(&(rtb0echo), 0, 0, DABSTORE, 1, DABOFF, PSD_LOAD_DAB_ACQON);
                        loaddab(&(rtb0echo), 0, 0, DABSTORE, 1, DABON, PSD_LOAD_DAB_ACQON_RBA);
                    }
                    else
                    {
                        loaddab(&(rtb0echo), 0, 0, DABSTORE, 1, DABOFF, PSD_LOAD_DAB_ALL);
                    }
                }

                printdbg("D", debugstate);
                sp_sat_index = sliceindex;

                if(opfat && fskillercycling)
                {
                    setiampt(ia_gykcs*rspfskillercycling, &gykcs, 0);
                    rspfskillercycling *= -1;
                }

		        startseq((short)sliceindex, (SHORT)MAY_PAUSE);
		
                if (debug_unitTest)
                    fprintf(fp_utloopinfo,"%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t \n", "dda:", pass_rep, pass, disdaq_index, -1, false_slice, -1,-1, -1,-1,-1,-1);

                /*RTB0 correction*/
                /*Acquired FID and RTP will return cfoffset & fidmean*/
                if (in_rtb0_loop == 1 && (slice_tmp < slc_in_acq[pass_index] || (t1flair_flag == PSD_OFF && use_sl == 1)))
                {
                    if (rtb0_debug)
                    { 
                        fprintf(fp_cfdata, "core: cf_counter%d, rtb0_processed_index %d\n", cf_counter, rtb0_processed_index);
                    }

                    num_wait =1;

@inline RTB0.e RTB0starttimer
                    play_rtb0resultwaitseq(1);


#if defined(MGD_TGT) && defined(PSD_HW)
                    while(cf_counter == rtb0_processed_index)	
                    {							
                        if (0==getRTB0Feedback(&rtb0_processed_index, &rtb0_cfoffset, &rtb0_fidmean, &rtb0_cfstddev, &rtb0_cfresidual))
                        {
                            /* No feedback available.  Play dummy pulse to 
                            prevent EOS errors while waiting for result */
                            num_wait++;
                            startseq((SHORT)0, (SHORT)MAY_PAUSE);
                        }/*end if*/

                        if( (PSD_OFF == rtb0_debug) && (0 == rtb0DebugFlag) && (0 == rtb0SaveRaw) && (1500 < num_wait * rtb0resultwaittime) ) 
                        {
                            printdbg("Warning: Could not receive Feedback from RTP within 1.5ms in getRTB0Feedback", 1);
                            rtb0_cfoffset = 0;
                            rtb0_fidmean = 0;
                            rtb0_cfstddev = rtb0_cfstddev_threshold*2; /*ensure this data point is not used*/
                            rtb0_cfresidual = rtb0_cfresidual_threshold*2; /*ensure this data point is not used*/
                            printf("getRTB0Feedback Timeout, rtb0_cfoffset %f\n", rtb0_cfoffset);
                            break; /*If timeout, break from the while loop*/
                        }
                    }                					

                    /*Forcing CF offset to be a user defined value*/
                    /*for debugging/formal verification purpose*/
                    if (rtb0_debug && !floatsAlmostEqualEpsilons(rtb0_cfoffset_debug, 0.0, 2))
                    {
                        rtb0_cfoffset = rtb0_cfoffset_debug;
                    }

#else

                    rtb0_cfoffset = 10;
                    rtb0_fidmean = 100;
                    rtb0_cfstddev = 50;
                    rtb0_cfresidual = 10;
#endif

@inline RTB0.e RTB0readtimer

                    slice_cfoffset[sliceindex] = rtb0_cfoffset;
                    slice_fidmean[sliceindex] = rtb0_fidmean;
                    slice_cfstddev[sliceindex] = rtb0_cfstddev;
                    slice_cfresidual[sliceindex] = rtb0_cfresidual;
			 
                    if (rtb0_debug)
                    {
                        fprintf(fp_cfdata,"core: While loop: pass_rep=%d,pass=%d,dda=%d/%d, false_slice=%d, num_wait=%d\n",pass_rep, pass, disdaq_index, dda_packe-1, false_slice, num_wait);
                        fprintf(fp_cfdata,"core: While loop: slice_cfoffset[%d]=%7.2f, slice_fidmean = %f, slice_cfstddev=%f, slice_cfresidual=%f\n", sliceindex, slice_cfoffset[sliceindex], slice_fidmean[sliceindex], slice_cfstddev[sliceindex], slice_cfresidual[sliceindex]);
                    }

                    reset_to_epi2scan();

                    /*RTB0 correction*/
                    /*Reject noise if CF offset is greater than pre-defined threshold*//*Remove this or move to RTB0.e and activate only when polyfit is used*/
                    switch (rtb0_rejectnoise)
                    {
                        case 1: /*set Mag to 0 if cfoffset> rtb0_max_range*/
                            slice_fidmean[sliceindex] = (fabs(rtb0_cfoffset) > rtb0_max_range)? 0:rtb0_fidmean;
                            break;
                        case 2: /*set cfoffset to rtb0_max_range if cfoffset > rtb0_max_range*/
                            if (rtb0_cfoffset > rtb0_max_range)
                                slice_cfoffset[sliceindex] = rtb0_max_range;
                            if (rtb0_cfoffset < rtb0_max_range*-1)
                                slice_cfoffset[sliceindex] = -1*rtb0_max_range;
                            break;
                        default: /*original: do nothing*/
                            break;
                    }

                    if(cf_counter == 0)
                    {
                        first_rtb0_sliceindex = sliceindex;
                    }
                    last_rtb0_sliceindex = sliceindex;
                    cf_counter++;
                }
            } /* false_slice= 0 */

            /*RTB0 correction: reset things & do interslice fitting before going into actual disdacqs*/
            /*do fitting & comp only after RTB0 loop is completed*/
            if (rtb0_flag && in_rtb0_loop)
            {	
                set_dynr1(pscR1); /*reset R1*/

                if (rtb0_gzrf0_off && t1flair_flag==PSD_ON) /*reset gzrf0*/
                {
                    setiampt(freqSign*ia_gzrf0, &gzrf0, INSTRALL);
                }

                /*Play dummy sequence to avoid EOS timing error*/
                play_rtb0fitwaitseq(rtb0fittingwaittimeLoop);
                reset_to_epi2scan();

@inline RTB0.e RTB0startfittingtimer
@inline RTB0.e RTB0intersliceFitting
@inline RTB0.e RTB0applyComp
@inline RTB0.e RTB0readfittingtimer
@inline RTB0.e RTB0computeTimingStats

                loaddab(&(rtb0echo), 0, 0, DABSTORE, 1, DABOFF, PSD_LOAD_DAB_ALL);
                in_rtb0_loop = 0;
            }

        }  /* disdaq */
	
    }	/* if rspdda > 0 */
    
    /******* end disdaq block ***********************************/
    /*RTB0 correction*/
    if(rtb0_flag)
    {
        setiampt(0, &gz1, 0);
    }

    /* Refless EPI: when T1 Flair is on, the original logic is that first dda sets rspslq to slquant_in_ti and second dda sets it back
       to false_slquant1. In refless EPI, we skip the 2nd dda, so here we need to manually set rspslq back after the dda loop */
    if (t1flair_flag && ref_in_scan_flag)
    {
        rspslq = false_slquant1;
    }

    if (rspent != L_SCAN)
	attenlockoff(&atten);
    else
	attenlockon(&atten);

    for (core_rep = 0; core_rep <= rsprep-1; core_rep++) 
    {
        /* baselines are done seperately in blineacq routine */
        for (ileave = rspilvb; ileave < rspilv; ileave++) 
        {
            if (ileave>0) 
            {
                if ( (ep_alt > 0) && (gradpol[ileave] != gradpol[ileave-1] ))
                    setreadpolarity();
            }

            if ((cs_sat == PSD_ON) && (rspent == L_MPS2))
                CsSatMod(cs_satindex);

            /* set sliding ssp/readout/phase/slice */

            setperiod((int)tf[ileave], &wgx, 0);
            setperiod((int)tf[ileave], &wgy, 0);
            setperiod((int)tf[ileave], &wgz, 0);
            setperiod((int)tf[ileave], &wssp, 0);
            setperiod((int)tf[ileave], &womega, 0);       /* ufi2_ypd */


            /* Set blip and gy1 pulse amplitudes */
            ygradctrl(rspgyc, blippol[ileave], etl);
            if (gyctrl == PSD_ON && rspent != L_REF &&
                rspent != L_MPS2 && rspent != L_APS2) {
                setiampt(invertGy1*gy1f[ileave], &gy1, 0);
                if (ygmn_type == CALC_GMN1) {
                    setiampt(gymn[ileave], &gymn1, 0);
                    setiampt(-gymn[ileave], &gymn2, 0);
                }
            }

            /* SWL pick the right nex for current pass rep */
            /* Refless EPI: for ref-in-scan mode, first pass is labeled as L_REF where rspnex is preset to 1 */
            /* rspnex_temp of the ref pass for DWI and DTI is set here */
            if((rspent==L_MPS2)||(rspent==L_APS2)||(rspent==L_REF))
            {
                rspnex_temp = rspnex;
            }
            else if( (PSD_ON == rpg_in_scan_flag) && ((pass_rep-(ref_in_scan_flag?1:0)) < rpg_in_scan_num) )
            {   
                /* Distortion Correction: Set 1NEX for rpg_in_scan_flag and rpg_in_scan_num passes */
                rspnex_temp = 1;
            }
            else if(tensor_flag == PSD_ON)
            {
                rspnex_temp = difnextab_rsp[0];
            }
            else if(opdiffuse == PSD_ON)
            {
                int pass_rep_tmp = pass_rep-(ref_in_scan_flag ? 1:0)-(rpg_in_scan_flag ? rpg_in_scan_num:0);
                if (pass_rep_tmp < 0) /* Only with RPG on */
                {
                    rspnex_temp = 1;
                }
                else if (opdifnumt2 == 0)
                {
                    rspnex_temp = difnextab_rsp[(pass_rep_tmp)/opdifnumdirs];
                }
                else
                {
                    if(pass_rep_tmp == 0)
                    {
                        rspnex_temp = (short)opdifnext2;
                    }
                    else
                    {
                        rspnex_temp = difnextab_rsp[(pass_rep_tmp-1)/opdifnumdirs];
                    }
                }
            }
            else
            {
                rspnex_temp = rspnex;
            }

            for (excitation=1-rspdex; excitation <= rspnex_temp; excitation++) 
            {
                if (rf_chop == PSD_ON && excitation % 2 == 0)
                {
                    setiamp(-rfpol[ileave], &rf1, 0);  /* even excitation */
                }
                else
                {
                    setiamp(rfpol[ileave], &rf1, 0);   /* odd excitation */
                }
	               
#ifdef UNDEF
		if (debugstate==PSD_ON)
                    sprintf(psddbgstr,"  Excitation=%6d",excitation);
		printdbg(psddbgstr, debugstate);
#endif		
                
		if (epi_flair) {
                    setiamp(ia_rf0, &rf0, 0);
                    setiamp(freqSign*ia_gzrf0, &gzrf0, 0);
                    setiamp(freqSign*ia_gzrf0, &gzrf0a, 0);
                    setiamp(freqSign*ia_gzrf0, &gzrf0d, 0);
                    setiamp(ia_gyk0, &gyk0, 0);
                    setiamp(ia_gyk0, &gyk0a, 0);
                    setiamp(ia_gyk0, &gyk0d, 0);
		}
                
                for (false_pass = false_rspacqb; false_pass < false_rspacq; false_pass++) 
                {
                    /* Refless EPI: Play IR in REF for DW-EPI Flair with 1 acq */
                    if (epi_flair && flair_flag &&
                        ((rspent == L_SCAN) ||
                         ((rspent == L_REF) && (ref_in_scan_flag == PSD_ON) && (rspacq == 1))))
                    {

                        /* MRIge81039  NU */
                        setrotatearray((SHORT)(opslquant*opphases),rsprot_orig[0]);

                        /* MRIge44963 - need to subtract slq_to_shift from rspslq, HOU */
                        for (false_slice = rspslqb; false_slice < rspslq-slq_to_shift; false_slice++) 
                        { 
                            printdbg("Starting Interleaved Inversion", debugstate);
#ifdef DEBUG_CORE
                            if (debug_core == PSD_ON)
                            {
                                fprintf(fp_coreinfo,"core:inv:core_rep%d/%d:int%d/%d:nex%d/%d:false_acq%d/%d:slice%d/%d\n", 
                                        core_rep,rsprep-1,ileave, rspilv-1,excitation,rspnex_temp-1,false_pass,false_rspacq-1,
                                        false_slice,rspslq-slq_to_shift-1); 
                            }
#endif
                            boffset(off_seqinv);   
                            slice_tmp = false_slice + false_pass*(rspslq-slq_to_shift);
                            if (slice_tmp<slc_in_acq[pass_index]) {
                                slice = slice_tmp;
                                setiamp(ia_rf0, &rf0, false_slice);
                                /* setiamp(ia_rf0, &rf0, 0); */

                            }
                            else    {
                                slice = 0;
                                setiamp(0, &rf0, false_slice);
                                /* setiamp(0, &rf0, 0); */
                            } 

                            /* Determine which slice(s) to excite (find spot in
                               rspinfo table) */
                            /* Remember slices & passes start at 0 */
                            if (rspesl == -1)
                            {
                                if (acqmode==0) /* interleaved */
                                    sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                                if (acqmode==1)  /* sequential */
                                    sliceindex = acq_ptr[pass_index];
                            }
                            else 
                                sliceindex = acq_ptr[pass_index] + rspesl;

                            /* SW: Setup Diff Gradient Dir */
                            if (diff_order_flag && (rspent == L_SCAN))
                            {
                                int pass_index;

                                if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                                {
                                    pass_index = pass_rep;
                                }
                                else
                                {
                                    pass_index = diff_pass_counter;
                                }

                                tmpi = get_diff_order(pass_index, false_slice + false_pass * rspslq + slquant1 * pass);

                                if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                                {
                                    diff_index = tmpi;
                                }
                                else
                                {
                                    diff_index = diff_order_pass[tmpi-ref_in_scan_flag-(rpg_in_scan_flag?rpg_in_scan_num:0)];
                                }

                                if ((opdiffuse == 1 && incr == 1) || tensor_flag)
                                {
                                    /* BJM: increment diffusion gradients */
                                    skip_ir = PSD_ON;
                                    diffstep(diff_index - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
                                    if(rtb0_flag)
                                    {
                                        setiampt(0, &gz1, 0);
                                    }
                                    skip_ir = PSD_OFF;
                                }

                                /* Load Transmit Frequencies */
                                setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, false_slice);
                                setiamp(freqSign*ia_gzrf0, &gzrf0, false_slice);
                                setiamp(freqSign*ia_gzrf0, &gzrf0a, false_slice);
                                setiamp(freqSign*ia_gzrf0, &gzrf0d, false_slice);
                            }
                            else
                            {
                                /* Load Transmit Frequencies */
                                setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, false_slice);
                                /* setfrequency(rf0_freq[sliceindex], &rf0, 0); */
                                /* setiphase(rf0_pha[sliceindex], &rf0, 0); */
                            }
                        } /*IR prep */

                        startseq((short)sliceindex, (SHORT)MAY_PAUSE);

			if (debug_unitTest)
				fprintf(fp_utloopinfo,"%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t \n", "core_flair:", pass_rep, pass, -1, -1, -1, core_rep, ileave, excitation, false_pass, false_slice, -1);

                        /* MRIge81039  NU */
                        if ((rspent== L_CFH) || (rspent == L_CFL))
                            setrotatearray((SHORT)(opslquant*opphases),rsprot_orig[0]);
                        else
                            setrotatearray((SHORT)(opslquant*opphases),rsprot[0]);

                    } /*epi_flair*/

                    boffset(off_seqcore); /* switch back to core seq */
                    
                    /* MRIge44963 - need to subtract slq_to_shift from rspslq, HOU */
                    for (false_slice = rspslqb; false_slice < rspslq-slq_to_shift; false_slice++) 
                    { 
#ifdef DEBUG_CORE
                        if (debug_core == PSD_ON)
                        {
                            fprintf(fp_coreinfo,"core:img:core_rep%d/%d:int%d/%d:nex%d/%d:false_acq%d/%d:slice%d/%d\n",
                                    core_rep,rsprep-1,ileave,rspilv-1, excitation,rspnex_temp-1,false_pass,false_rspacq-1,
                                    false_slice,rspslq-slq_to_shift-1);
                        }
#endif                            

                        if ((PSD_ON == navtrig_flag) && (PSD_OFF == calc_rate) && ((L_REF == rspent) || (L_SCAN == rspent)) &&
                            (false_slice % num_slice_rr == 0))
                        {
                            NavigatorPlayTrig();

#ifndef SIM
                            if ((rspent == L_REF) && (ref_in_scan_flag == PSD_ON))
                            {
                                scantime = (60s / (float)oprtrate) * (float)hbs_left;
                                setscantimestop();
                                setscantimeimm(PSD_CLOCK_CARDIAC, scantime, hbs_left,pitslice,opslicecnt);
                                setscantimestart();
                            }
#endif
                        }

                        slice_tmp = false_slice + false_pass*(rspslq-slq_to_shift);

                        if (slice_tmp<slc_in_acq[pass_index]) { 
                            slice = slice_tmp;
                        } else {
                            slice = 0;   
                        }
                        slice1 = slice; 
                        
#ifdef UNDEF
                        sprintf(psddbgstr,"    slice=%6d",slice);
                        printdbg(psddbgstr,debugstate);
#endif
                        
                        if ((slice == rspasl) || (rspasl == -1)) {
                            acq_sl = 1;
                        } else { 
                            acq_sl = 0;
                        }

                        /* Determine which slice(s) to excite (find spot in 
                           rspinfo table) */
                        /* Remember slices & passes start at 0 */
                        if (rspesl == -1)
                        {
                            if (acqmode==0) {/* interleaved */
                                sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                                sliceindex1 = (acq_ptr[pass_index] + slice1)%opslquant;

                                /* t1flair_stir */
                                if (PSD_ON == t1flair_flag )
                                {
                                    slice = real_slice_acq_seq[pass][false_slice];
                                    slice1 = slice;
                                    sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                                    sliceindex1 = (acq_ptr[pass_index] + slice1)%opslquant;
                                }
                            }
                            if (acqmode==1) { /* sequential */
                                sliceindex = acq_ptr[pass_index];
                                sliceindex1 = acq_ptr[pass_index];
                            }
                        }
                        else 
                        {
                            sliceindex = acq_ptr[pass_index] + rspesl;
                            sliceindex1 = acq_ptr[pass_index] + rspesl;
                        }

                        if ((rspent == L_MPS1) || (rspent == L_MPS2)) {
                            if ((excitation == rspnex_temp) && (acq_sl == 1))
                                attenlockoff(&atten);
                            else
                                attenlockon(&atten);
                        }

                        /* Set cardiac delays and end times */
                        if (opcgate || oprtcgate) {

                            /* Build the trigger for multi-slice, multi-phase cardiac */
                            msmpTrig();

                            if ((rspent == L_SCAN)||(rspent == L_MPS2) 
                                ||(rspent == L_APS2) ||(rspent == L_REF))
                                setperiod(ctlend_tab[sliceindex],&seqcore ,0);

                            /*  first slice in RR */
                            if (rsptrigger[sliceindex] != TRIG_INTERN) {	
                                if ((rspent == L_SCAN)||(rspent == L_MPS2)||(rspent == L_APS2)) {
                                    /* Use cardiac trigger delay */
                                    setperiod(td0, &x_td0, 0);
                                    setperiod(td0, &y_td0, 0);
                                    setperiod(td0, &z_td0, 0);
                                    setperiod(td0, &rho_td0, 0);
                                    setperiod(td0, &theta_td0, 0);
                                    setperiod(td0, &omega_td0, 0);
                                    setperiod(td0, &ssp_td0, 0);
                                }
                            } else {
                                /* Bypass cardiac trigger delay */
                                setperiod((int)GRAD_UPDATE_TIME, &x_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &y_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &z_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &rho_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &theta_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &omega_td0, 0);
                                setperiod((int)GRAD_UPDATE_TIME, &ssp_td0, 0);
                            }
                        }
                         
                        /* t1flair_stir */
                        if (PSD_ON != t1flair_flag)
                        {
                            if (slice_tmp<slc_in_acq[pass_index]) { /* live slice */
                                if (!aspir_flag)
                                {
                                    /* turn on RHO BOARD */
                                    setieos((SHORT)EOS_PLAY, &rho_td0, 0);
                                }
                                else
                                {
                                    /* turn on RHO BOARD */
                                    setieos((SHORT)EOS_PLAY, &rf1, 0);
                                }

                                use_sl = 1;
                                if ((acq_sl == PSD_ON)&&(excitation > 0)) {
                                    acq_data = (int)DABON;
                                } else { 
                                    acq_data = (int)DABOFF;
                                }
                            }
                            else 
                            {
                                /* Dummy slice */
                                acq_data = (int)DABOFF;
                                if (!aspir_flag)
                                {
                                    /* turn off RHO BOARD */
                                    setieos((SHORT)EOS_DEAD, &rho_td0, 0);
                                }
                                else
                                {
                                    /* turn off RHO BOARD */
                                    setieos((SHORT)EOS_DEAD, &rf1, 0);
                                }
                                use_sl = 0;
                                if (rspesl == -1) {
                                    sliceindex = (acq_ptr[0])%opslquant;
                                    sliceindex1 = (acq_ptr[0])%opslquant;
                                }
                            }
                        }
                        
                        /* update Sat Move CATSAT Pulse */
                        SpSatUpdateRsp(1, pass_index, opccsat);
                        
                        /* SW: Setup Diff Gradient Dir */
                        if (diff_order_flag && (rspent == L_SCAN))
                        {
                            int pass_index;

                            if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                            {
                                pass_index = pass_rep;
                            }
                            else
                            {
                                pass_index = diff_pass_counter;
                            }

                            tmpi = get_diff_order(pass_index, false_slice + false_pass * rspslq + slquant1 * pass);

                            if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                            {
                                diff_index = tmpi;
                            }
                            else
                            {
                                diff_index = diff_order_pass[tmpi-ref_in_scan_flag-(rpg_in_scan_flag?rpg_in_scan_num:0)];
                                nex_index = diff_order_nex[tmpi-ref_in_scan_flag-(rpg_in_scan_flag?rpg_in_scan_num:0)];
                            }

                            if ((opdiffuse == 1 && incr == 1) || tensor_flag)
                            {
                                /* BJM: increment diffusion gradients */
                                diffstep(diff_index - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
                                if(rtb0_flag)
                                {
                                    setiampt(0, &gz1, 0);
                                }
                            }
                        }
                        else
                        {
                            diff_index = pass_rep;
                        }

                        if( (PSD_ON == irprep_flag) && (t1flair_flag != PSD_ON) )
                        {
@inline Inversion_new.e InversionRSPcore 
                        }    

#ifdef UNDEF
@inline Inversion.e InversionRSPcore 
#endif
                        /* t1flair_stir */
                        if( PSD_ON == t1flair_flag )
                        {
                            int temp_pass_index = pass_index;
                            int freqSign_org = freqSign;

                            /* Play IR Prep for next pass at the end of pass.
                               1st pass_rep is excluded as IR is applied during disdaq. */
                            if ((slquant_in_ti > 0) && !((pass_rep == 0) && (pass < rspacq -1)) &&
                                (false_slice > rspslq-1-slq_to_shift-slquant_in_ti) &&
                                (false_pass == false_rspacq-1) && (excitation == rspnex_temp) &&
                                (ileave == rspilv-1) && (core_rep == rsprep-1))
                            {
                                temp_pass_index++;

                                if ((pass == rspacq - 1) && (diff_order_flag == PSD_OFF) &&
                                    !((rspent==L_MPS2)||(rspent==L_APS2)))
                                {
                                    /* set freqSign of IR prep for next pass */
                                    if (pass_rep < rspprp - 1)
                                    {
                                        diffamp(pass_rep + 1 - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
                                    }

                                    freqSign = 1;

                                    if (PSD_OFF == dualspinecho_flag)
                                    {
                                        if(invertSliceSelectZ == PSD_ON || invertSliceSelectZ2 == PSD_ON)
                                        {
                                            if((invertSliceSelectZ==PSD_ON && ((ia_incdifz<0 && ia_gzrf2r1>0) || (ia_incdifz>0 && ia_gzrf2r1<0))) ||
                                               (invertSliceSelectZ2==PSD_ON && ia_gzrf2r1<0))
                                            {
                                                freqSign = -1;
                                            }
                                            else
                                            {
                                                freqSign = 1;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if(PSD_ON == invertSliceSelectZ || PSD_ON == invertSliceSelectZ2)
                                        {
                                            if((invertSliceSelectZ==PSD_ON && ((ia_incdifz>0 && ia_gzrf2leftr1>0) || (ia_incdifz<0 && ia_gzrf2leftr1<0))) ||
                                               (invertSliceSelectZ2==PSD_ON && ia_gzrf2leftr1>0))
                                            {
                                                freqSign = -1;
                                            }
                                            else
                                            {
                                                freqSign = 1;
                                            }
                                        }
                                    }
                                    if(ssgr_flag)
                                    {
                                        freqSign *= -1;
                                    }

                                    if(ir_on) setiampt(freqSign*ia_gzrf0, &gzrf0, INSTRALL);

                                    diffamp(pass_rep - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0)); /* restore */
                                }
                            }

                            if ((diff_order_flag) &&
                                !((rspent==L_MPS2)||(rspent==L_APS2)))
                            {
                                /* SW: Setup Diff Gradient Dir */
                                if (rspent == L_SCAN)
                                {
                                    int pass_index;
                                    int diff_index_orig = diff_index;
                                    int slice_index = 0;

                                    if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                                    {
                                        pass_index = temp_pass_index/rspacq; /* pass_rep; */

                                        if (pass_index > rspprp - 1)
                                        {
                                            pass_index = 0;
                                        }
                                    }
                                    else
                                    {
                                        pass_index = diff_pass_counter;
                                    }

                                    if (excitation == rspnex_temp)
                                    {
                                        slice_index = (slquant_in_ti + false_slice + false_pass * rspslq + slquant1 * pass) % (slquant1*rspacq);

                                        if ((diff_order_flag == 2) &&
                                            ((int)((slquant_in_ti + false_slice + false_pass * rspslq + slquant1 * pass) / (slquant1*rspacq))) > 0)
                                        {
                                            pass_index++;
                                            if (pass_index > rspprp - 1)
                                            {
                                                pass_index = 0;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        slice_index = (slquant_in_ti + false_slice + false_pass * rspslq + slquant1 * pass) % slquant1 + slquant1 * pass;

                                        if ((diff_order_flag == 2) &&
                                            ((int)((slquant_in_ti + false_slice + false_pass * rspslq) / (slquant1))) > 0)
                                        {
                                            pass_index++;
                                            if (pass_index > rspprp - 1)
                                            {
                                                pass_index = 0;
                                            }
                                        }
                                    }

                                    tmpi = get_diff_order(pass_index, slice_index);

                                    if (diff_order_flag == 1 || (diff_order_flag == 2 && tensor_flag == PSD_ON))
                                    {
                                        diff_index = tmpi;
                                    }
                                    else
                                    {
                                        diff_index = diff_order_pass[tmpi-1];
                                    }

                                    if ((opdiffuse == 1 && incr == 1) || tensor_flag)
                                    {
                                        /* BJM: increment diffusion gradients */
                                        diffamp(diff_index - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0));
                                    }

                                    freqSign = 1;

                                    if (PSD_OFF == dualspinecho_flag)
                                    {
                                        if(invertSliceSelectZ == PSD_ON || invertSliceSelectZ2 == PSD_ON)
                                        {
                                            if((invertSliceSelectZ==PSD_ON && ((ia_incdifz<0 && ia_gzrf2r1>0) || (ia_incdifz>0 && ia_gzrf2r1<0))) ||
                                               (invertSliceSelectZ2==PSD_ON && ia_gzrf2r1<0))
                                            {
                                                freqSign = -1;
                                            }
                                            else
                                            {
                                                freqSign = 1;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if(PSD_ON == invertSliceSelectZ || PSD_ON == invertSliceSelectZ2)
                                        {
                                            if((invertSliceSelectZ==PSD_ON && ((ia_incdifz>0 && ia_gzrf2leftr1>0) || (ia_incdifz<0 && ia_gzrf2leftr1<0))) ||
                                               (invertSliceSelectZ2==PSD_ON && ia_gzrf2leftr1>0))
                                            {
                                                freqSign = -1;
                                            }
                                            else
                                            {
                                                freqSign = 1;
                                            }
                                        }
                                    }

                                    if(ssgr_flag)
                                    {
                                        freqSign *= -1;
                                    }

                                    if(ir_on) setiampt(freqSign*ia_gzrf0, &gzrf0, INSTRALL);

                                    diff_index = diff_index_orig;
                                    diffamp(diff_index - (ref_in_scan_flag?1:0) - (rpg_in_scan_flag?rpg_in_scan_num:0)); /* restore */
                                }
                            }

                            real_slice_IR = 0;
                            slice_flag = IMGSLICE;
                            sliceindex = (false_slice + slquant_in_ti)%rspslq + acq_ptr[temp_pass_index];

                            if (dummyslices >= 0 || PSD_ON == act_edge_slice_enh_flag)
                            {
                                real_slice_IR =  real_slice_acq_seq[pass][(false_slice + slquant_in_ti)%rspslq];
                                sliceindex = acq_ptr[temp_pass_index] + real_slice_IR;
                                slice_flag = T1flair_slice_flag[pass][(false_slice + slquant_in_ti)%rspslq];
                            }

                            sliceindex = sliceindex % opslquant;

                            if (slice_flag == EDGESLICE)
                            {
                                if (real_slice_IR == edgeslice1)
                                {
                                    /* RTB0 correction*/
                                    setfrequency(freqSign*edgeslice1freq+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                                    setiphase(edgeslice1pha, &rf0, 0);
                                }
                                else
                                {
                                    /* RTB0 correction*/
                                    setfrequency(freqSign*edgeslice2freq+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                                    setiphase(edgeslice2pha, &rf0, 0);
                                }
                                setiamp(ia_rf0, &rf0, 0);
                            }
                            else if (slice_flag == IMGSLICE)
                            {
                                /* RTB0 correction*/
                                setfrequency(freqSign*rf0_freq[sliceindex]+slice_cfoffset_TARDIS[sliceindex], &rf0, 0);
                                setiphase(rf0_pha[sliceindex], &rf0, 0);
                                setiamp(ia_rf0,&rf0,0);

                                /* Not play IR Prep at the end of 1st pass_rep,
                                   as IR is applied during disdaq in next pass */
                                if ((slquant_in_ti > 0) && (pass_rep == 0) && (pass < rspacq -1) &&
                                    (false_slice > rspslq-1-slq_to_shift-slquant_in_ti) && (false_pass == false_rspacq-1) &&
                                    (excitation == rspnex_temp) && (ileave == rspilv-1) && (core_rep == rsprep-1))
                                {
                                    setiamp(0,&rf0,0);
                                }
                            }
                            else
                            {
                                setiamp(0,&rf0,0);
                            }

                            /* t1flair_stir: the imaging sequence's sliceindex,
                             * slice_flag, etc.
                             */
                            slice = real_slice_acq_seq[pass][false_slice];
                            sliceindex = (acq_ptr[pass_index] + slice)%opslquant;
                            sliceindex1 = sliceindex;
                            slice_flag = T1flair_slice_flag[pass][false_slice];

                            if ((slice_flag == IMGSLICE) && (acq_sl == PSD_ON) && (excitation > 0))
                            {
                                acq_data = (int)DABON;
                            }
                            else
                            {
                                acq_data = (int)DABOFF;
                            }

                            freqSign = freqSign_org;
                        }

                    /* t1flair_stir */
                    /* Play the IR rf pulses for the 1st excitation if T1FLAIR is on, 
                       and turn off the rf1 and rf2 rf pulses. The data acquisition has 
                       been  turn off. */
                    if ((PSD_ON == t1flair_flag) && (slice_flag != IMGSLICE))
                    {
                        setiamp(0, &rf1, 0);
                        if (oppseq == PSD_SE) /* DTI */
                        {
                            if (PSD_OFF == dualspinecho_flag)
                            {
                                setiamp(0, &rf2, 0);
                            }
                            else
                            {
                                setiamp(0, &rf2right, 0);
                                setiamp(0, &rf2left, 0);
                            }
                        }
                    }
                    else
                    {
                        /* Set the rf pulse transmit frequencies */
                        if (ssRsp() == FAILURE) return FAILURE;
                        if (slice1 < 0) {
                            
                            setiamp(0, &rf1, 0);   /* zero amplitudes */
                            
                            if (oppseq == PSD_SE)
                            {
                                if (PSD_OFF == dualspinecho_flag)
                                {
                                    setiamp(0, &rf2, 0);
                                }
                                else
                                {
                                    setiamp(0, &rf2right, 0);
                                    setiamp(0, &rf2left, 0);
                                }
                            }

                        } else {

                            if (rf_chop == PSD_ON && excitation % 2 == 0)
                            {
                                setiamp(-rfpol[ileave], &rf1, 0);  /* even excitation */
                            }
                            else
                            {
                                setiamp(rfpol[ileave], &rf1, 0);   /* odd excitation */
                            }

                            if (rfov_flag)
                            {
                                /* SVBranch: HCSDM00259122  - FOCUS walk sat */
                                if (walk_sat_flag) setrfwk();                            
                            
                                setfrequency(0, &rf1, 0);
                                setthetarf1(sliceindex1); /* control frequency through theta wave */
                            }
                            else /* RTB0 correction*/
                            {
                                setfrequency(freqSign*rf1_freq[sliceindex1] + d_cf + slice_cfoffset_TARDIS[sliceindex1], &rf1, 0);
                            }

                            if (sliceindex1 == 0) {
#ifdef DEBUG_CORE
                                if (debug_core == PSD_ON)
                                {
                                    fprintf(fp_coreinfo,"Phase cycle number %d\n",(core_rep+reps*pass_rep));
                                }
#endif
                                if (mux_flag && mux_slices_rf1 >1) {
                                    setwave( ptr_rf1[0], &rf1, 0);
                                    if (phase_cycle_rf2) {
                                        if( opdualspinecho == PSD_OFF) {
                                            setwave( ptr_rf2[0], &rf2, 0);
                                        } else {
                                            setwave( ptr_rf2[0], &rf2left,  0);
                                            setwave( ptr_rf2[0], &rf2right, 0);
                                        }
                                    }
                                    if (use_slice_fov_shift_blips && mux_flag && (mux_slices_rf1 > 1)) { /* Use Gz blips */
                                        zgradctrl(rspgzc, slice_fov_shift_blip_start, slice_fov_shift_blip_inc, etl, slice_fov_shift);
                                    } else { /* No Gz blips */
                                        zgradctrl(0, 0, 0, etl, 0);
                                    }
                                } else {
                                    zgradctrl(0, 0, 0, etl, 0);
                                } /* mux_slices_rf1 > 1 */
                            } /* sliceindex == 1 */

                            if (oppseq == PSD_SE)
                            {
                                if (PSD_OFF == dualspinecho_flag)
                                {
                                    if (mux_flag && verse_rf2) {
                                        if (use_omegatheta) {
                                            setfrequency(0, &rf2, 0);
                                            setiamp(freqSign*max_pg_iamp, &th_omthrf2, 0);
                                            setiamp(freqSign*om_iamp_omthrf2[sliceindex], &om_omthrf2, 0);
                                            setwave(om_wave_omthrf2[sliceindex], &om_omthrf2, 0);
                                            setwave(th_wave_omthrf2[sliceindex], &th_omthrf2, 0);
                                        } else if (thetarf2_flag == PSD_OFF) {
                                            setfrequency(freqSign*rf2_freq[sliceindex], &rf2, 0);
                                            setiamp(0, &thetarf2, 0);
                                        } else {
                                            setiamp(freqSign*thetarf2_freq[sliceindex1],&thetarf2,0);
                                            setfrequency(0, &rf2, 0);
#ifdef DEBUG_CORE
                                            if (debug_core == PSD_ON)
                                            {
                                                fprintf(fp_coreinfo,"FM: thetarf2_freq[%d]=%d\n",sliceindex1,freqSign*thetarf2_freq[sliceindex1]);
                                            }
#endif
                                        }
                                    } else {
                                        setfrequency(freqSign_rf2*rf2_freq[sliceindex1]+slice_cfoffset_TARDIS[sliceindex1], &rf2, 0);
                                    }
                                    setiphase(rf2_pha[sliceindex1], &rf2, 0);
#ifdef DEBUG_CORE
                                    if (debug_core == PSD_ON)
                                    {
                                         fprintf(fp_coreinfo,"rf2_pha[%d] = %d\n",sliceindex1, rf2_pha[sliceindex1]);
                                    }
#endif
                                    setiamp(ia_rf2, &rf2, 0);
                                } else {
                                    if (mux_flag && verse_rf2) {
                                        if (use_omegatheta) {
                                            setfrequency(0, &rf2left, 0);
                                            setfrequency(0, &rf2right, 0);
                                            setiamp(freqSign_rf2left*max_pg_iamp, &th_omthrf2left, 0);
                                            setiamp(freqSign_rf2right*max_pg_iamp, &th_omthrf2right, 0);
                                            setiamp(freqSign_rf2left*om_iamp_omthrf2left[sliceindex], &om_omthrf2left, 0);
                                            setiamp(freqSign_rf2right*om_iamp_omthrf2right[sliceindex], &om_omthrf2right, 0);
                                            setwave(om_wave_omthrf2left[sliceindex], &om_omthrf2left, 0);
                                            setwave(om_wave_omthrf2right[sliceindex], &om_omthrf2right, 0);
                                            setwave(th_wave_omthrf2left[sliceindex], &th_omthrf2left, 0);
                                            setwave(th_wave_omthrf2right[sliceindex], &th_omthrf2right, 0);
                                        }	else if (thetarf2_flag == PSD_OFF) {
                                            setfrequency(freqSign_rf2left*rf2_freq[sliceindex], &rf2left, 0);
                                            setiamp(0, &thetarf2left, 0);
                                            setfrequency(freqSign_rf2right*rf2_freq[sliceindex], &rf2right, 0);
                                            setiamp(0, &thetarf2right, 0);
                                        } else {
                                            setiamp(freqSign_rf2right*thetarf2_freq[sliceindex1], &thetarf2right, 0);
                                            setiamp(freqSign_rf2left*thetarf2_freq[sliceindex1], &thetarf2left, 0);
                                            setfrequency(0, &rf2right, 0);
                                            setfrequency(0, &rf2left,  0);
                                        }
                                    } else {
                                        setfrequency(freqSign_rf2right*rf2_freq[sliceindex1]+slice_cfoffset_TARDIS[sliceindex1], &rf2right, 0);
                                        setfrequency(freqSign_rf2left*rf2_freq[sliceindex1]+slice_cfoffset_TARDIS[sliceindex1], &rf2left, 0);
                                    }
                                    setiphase(rf2right_pha[sliceindex1], &rf2right , 0);
                                    setiphase(rf2left_pha[sliceindex1], &rf2left  , 0);
                                    setiamp(ia_rf2, &rf2right, 0);
                                    setiamp(ia_rf2, &rf2left,  0);

                                }
                            }
                        }
                    }
                    dabview = ileave;

                    /* BJM: always store (dabop = 0) for multi-nex DW-EPI */
                    if ((excitation == 1) || (opdiffuse == PSD_ON) || (tensor_flag == PSD_ON))
                    {
                        dabop = 0;
                    }
                    else if (rf_chop == PSD_OFF)
                    {
                        dabop = 1;
                    }
                    else
                    {
                        dabop = 3 - 2*(excitation % 2);
                    }

                    if (slice1 >= 0) {
                        slicerep = slice1 + core_rep*rspslq;
                    } else {
                        slicerep = 0 + core_rep*rspslq;
                    }

                    if (PSD_ON == t1flair_flag)
                    {
                        slicerep = slice + core_rep*(rspslq - dummyslices);
                    }

                    if (slice1 >= 0 &&  setDataAcqDelays == PSD_ON ) {
                        /* Set the delay for the proper dacq/gradient alignment */

                        /* Coorected group delay. ufi2_ypd */

                        setperiod((int)((float)gldelaycval[sliceindex] + pw_sspdelay),
                                  &sspdelay, 0);
                        setperiod(RUP_RF((int)((float)gldelaycval[sliceindex] +
                            pw_omegadelay + deltaomega)), &omegadelay, 0);

                        setperiod((int)((float)(pw_sspshift - gldelaycval[sliceindex])),
                                  &sspshift, 0);

                    } /*slice1 >0 */

                    if (use_slice_fov_shift_blips && mux_flag && (mux_slices_rf1 > 1)) {
                        dabrbaload(rspgzc, slice_fov_shift_blip_start, slice_fov_shift_blip_inc, tot_etl, slice_fov_shift);
                    } else {
                        dabrbaload(0, 0, 0, tot_etl, 0);
                    }

                    /* Note in diffstep(), recv_phase is adjusted for HOEC B0 compensation,
                                         but the actual phase is set in dabrbaload here */

                    /* play out pass delay and send proper pass packet within seqcore.  We do
                           this to avoid having to play out a seperate pass sequence as is usually
                           done */
                    if ( (pass == (rspacq - 1)) && (pass_rep == (rspprp - 1)) &&
                        (false_pass == false_rspacq-1) && (false_slice == rspslq-1-slq_to_shift) &&
                        (excitation == rspnex_temp) && (ileave == rspilv-1) &&
                        (core_rep == rsprep-1) ) {
                        /* Set DAB pass packet to end of scan */
                        setwamp(SSPDS + DABDC, &pass_pulse, 0);
                        setwamp(SSPD + DABPASS + DABSCAN, &pass_pulse, 2);
                        setwamp(SSPDS + DABDC, &pass_pulse, 4);
                        /*MRIhc09116 end of scan, no opsldelay is
                         * needed*/
                        for (i=0; i<num_passdelay; i++) {
                            setperiod(1, &ssp_pass_delay, i);
                        }
                        pause = MAY_PAUSE;
                        printdbg("End of Scan and Pass", debugstate);
                        InterPassDoneFlag = 0;
                    } else if ( (false_slice == rspslq-1-slq_to_shift) && (false_pass == false_rspacq-1) &&
                        (excitation == rspnex_temp) && (ileave == rspilv-1) && (core_rep == rsprep-1) ) {
                        /* Set DAB pass packet to end of pass */
                        setwamp(SSPDS + DABDC, &pass_pulse, 0);
                        setwamp(SSPD + DABPASS, &pass_pulse, 2);
                        setwamp(SSPDS + DABDC, &pass_pulse, 4);
                        for (i=0; i<num_passdelay; i++) {
                            if ((rspent == L_REF) &&
                                !((mph_flag == PSD_ON) && (avminsldelay > 0)))
                            {
                                setperiod(1, &ssp_pass_delay, i);
                            }
                            else
                            {
                                setperiod(pass_delay, &ssp_pass_delay, i);
                            }
                        }
                        pause = AUTO_PAUSE;
                        printdbg("End of Pass", debugstate);
                        InterPassDoneFlag = 1;
                    } else if (slice1 >= 0) {
                        /* send null pass packet and use the minimum delay for pass_delay */
                        setwamp(SSPDS, &pass_pulse, 0);
                        setwamp(SSPD, &pass_pulse, 2);
                        setwamp(SSPDS, &pass_pulse, 4);
                        for (i=0; i<num_passdelay; i++) {
                            setperiod(1, &ssp_pass_delay, i);
                        }
                        pause = MAY_PAUSE;
                        printdbg("Null ssp pass packet", debugstate);
                        InterPassDoneFlag = 0;
                    }

                    /* MRIge44963 - need to subtract slq_to_shift so that the last slice in a pack */
                    /* can have longer deadtime (scan_deadlast) to prevent cross talk from IR pulse, HOU */
                    if (epi_flair) {
                        if (false_slice == rspslq-1-slq_to_shift)
                            setperiod(scan_deadlast,&seqcore,0);
                        else
                            setperiod(scan_deadtime,&seqcore,0);
                    }

                    sp_sat_index = sliceindex1;

                    /* Update per slice instruction amplitude of echo train readout and phase blips */
@inline HoecCorr.e HoecUpdateReadoutBlipAmpRsp

                    if(opfat && fskillercycling)
                    {
                        setiampt(ia_gykcs*rspfskillercycling, &gykcs, 0);
                        rspfskillercycling *= -1;
                    }
                        
                    startseq((short)sliceindex1, (SHORT)pause);

                    if (debug_unitTest)
                        fprintf(fp_utloopinfo,"%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t \n", "core:", pass_rep, pass, -1, -1, -1, core_rep, ileave, excitation, false_pass, -1, false_slice);
                    

#ifdef PSD_HW       /* Auto Voice  08/08/2005 KK */
                    if (mph_flag && InterPassDoneFlag) {
                        broadcast_autovoice_timing((int)(act_tr/slquant1)/1ms, pass_delay*num_passdelay/1ms, TRUE, TRUE);
                    }   
#endif        
                        
                        syncoff(&seqcore);

#ifdef UNDEF                        
     
                        /* Load Transmit and Receive Frequencies */
                        printf("Tf1= %d, Tf2 = %d, ->rsp_info[%d].rsploc= %f,pass_index =%d,slc_in_acq=%d\n",rf1_freq[sliceindex1],rf2_freq[sliceindex1],sliceindex1,rsp_info[sliceindex1].rsprloc,pass_index, slc_in_acq[pass_index]);
                        
                        printf("excitation = %d out of %d NEX\n", excitation,rspnex_temp);
                        printf("Slice = %d && Slice1 = %d\n",slice,slice1);
                        printf("Slice Index = %d && Slice Index 1 = %d\n",sliceindex, sliceindex1);
                        printf("false_slice = %d && rspslqb = %d\n",false_slice,rspslqb);
                        printf("rspslq = %d && slq_to_shift = %d\n",rspslq,slq_to_shift);
                        fflush(stdout);
#endif 
                    }  /* slice */                    
                   
                }  /* false_pass */
                
                if (rspchp == CHOP_NONE) SpSatChop();
		
#ifdef UNDEF
		if (debugstate==1)
                    sprintf(psddbgstr,"Ileave=%6d",ileave);
		printdbg(psddbgstr,debugstate);
#endif
        if ((diff_order_flag == 2) &&
            (ileave == rspilv-1) &&
                (core_rep == rsprep-1))
        {
            diff_pass_counter++;
        }
		
            } /* excitation */

	} /* ileave */
    } /* core_rep */	

    printdbg("Returning from CORE", debugstate);
    return SUCCESS;
    
} /* End Core */


STATUS reset_for_scan(void)
{
    int i;

    /* RF1, echo1 and trigger array are already set */
    boffset(off_seqcore);

    if ((rspent == L_SCAN) || (rspent == L_REF) || (rspent == L_APS2) || (rspent == L_MPS2))
    {
        for (i=0;i<etl;i++)
            setrfltrs((int)scanslot, &(echotrain[i]));
    }

    setrotatearray((SHORT)(opslquant*opphases),rsprot[0]);

    return SUCCESS;
}

/* RTB0 correction*/
void reset_to_epi2scan(void){
    boffset(off_seqcore);
    settriggerarray((SHORT)(opslquant*opphases), rsptrigger); /*reset trigger to original*/
}

/***************************** blineacq  *************************/
#ifdef __STDC__ 
STATUS blineacq( void )
#else /* !__STDC__ */
    STATUS blineacq()
#endif /* __STDC__ */
{
    int bcnt, nslice, rcnt, slindex;
    int bl_slice_end;

    if (rspent == L_REF) /* for ref entry point, play baselines for all slices */
        bl_slice_end = rspslq;
    else /* otherwise, play baselines for first slice only */
        bl_slice_end = rspslqb + 1;
  
    printdbg("Entering blineacq", (SHORT)debugstate);
    boffset(off_seqblineacq);
  
    settriggerarray((SHORT)1, rsptrigger_temp);
    if (baseline > 0 && rawdata == PSD_ON) {    /* collect single frame */
        sp_sat_index = 0;
	startseq((short)0, (SHORT)MAY_PAUSE);
	printdbg("B", (SHORT)debugstate);
    } else {
	dabop = 0; /* Store data */
	for (bcnt = rspbasb; bcnt <= rspbas; bcnt++) {
            for (rcnt = 0;rcnt < rsprep; rcnt++) {
                for (nslice = rspslqb;nslice < bl_slice_end; nslice++) {

                    /* play last baseline at longer TR */
                    if ( (rspbas > 1) && (bcnt == rspbas) && (nslice == bl_slice_end - 1) && (rcnt == rsprep - 1)  )
                        setperiod(bl_acq_tr2, &seqblineacq, 0);

                    if (nslice < slc_in_acq[pass_index]) {
			slindex = nslice + rcnt*rspslq;
                        /* Load the HSDAB or DIFFDAB packet. */

                        if(hsdab == 2)
                        {
                            loaddiffdab( &diffdabbl,
                                         (LONG) 0,
                                         (LONG) dabop,
                                         (LONG) 1,
                                         (LONG) 0,
                                         (LONG) slindex,
                                         (LONG) 1,
                                         (LONG) 1,
                                         (LONG) 1,
                                         (LONG) 0,
                                         (LONG) 0,
                                         (LONG) 0,
                                         (LONG) 0,
                                         (TYPDAB_PACKETS) DABON,
                                         (LONG) diffdabmask );
                        }
                        else
                        {
		  	    loadhsdab(&hyperdabbl,
                                      (LONG)slindex,
                                      (LONG)0,
                                      (LONG)dabop,
                                      (LONG)0,
                                      (LONG)1,
                                      (LONG)1,
                                      (LONG)1,
                                      (LONG)1,
                                      (TYPDAB_PACKETS)DABON,
                                      (LONG)hsdabmask);
                        }

                        sp_sat_index = 0;
                        startseq((short)0, (SHORT)MAY_PAUSE);
                        printdbg("B", (SHORT)debugstate);
                    }		  
		
                } /* for (nslice = rspslqb;nslice <= rspslq; nslice++) */
            } /* reps loop */
            dabop = 1;       /* add baseviews */
        } /* for (bcnt = 1; bcnt <= rspbas; bcnt++) */
    } /* if (baseline > 0 && rawdata == PSD_ON) */
  
    /* Return to standard trigger array and core offset */
    settriggerarray((SHORT)(opslquant*opphases), rsptrigger);

    return SUCCESS;
  
} /* end blineacq */


/***************************** dabrbaload *************************/
#ifdef __STDC__

STATUS dabrbaload(INT blipsw,
                  INT blipstart,
                  INT blipinc,
                  INT etl,
                  INT fovshift)

#else /* !__STDC__ */
    STATUS dabrbaload(blipsw, blipstart, blipinc, etl, fovshift)
    INT blipsw;
    INT blipstart;
    INT blipinc;
    INT etl;
    INT fovshift;
#endif /* __STDC__ */
{
    TYPDAB_PACKETS dabacqctrl;
    int echo;                 /* loop counter */
    int echo_nex;
    int freq_ctrl = 0;
    int phase_ctrl = 0;

    int kz_idx;
    float kz_off, kz_to_phase;
    float slice_fov_shift_phase;
    float slice_fov_shift_area_to_use;

    /* BJM: pass nex to echo slot for mag. avg'd multi-nex diffusion */
    if((opdiffuse == PSD_ON || tensor_flag == PSD_ON) && (rspent == L_SCAN)) {
        echo_nex = excitation-1;
    } else {
        echo_nex = 0;
    }

    dabacqctrl = (TYPDAB_PACKETS)acq_data;
    if (hsdab == 1)
    {
	loadhsdab(&hyperdab,        /* load hyperdab */
		  (LONG)slicerep,
	          (LONG)echo_nex,        /* note, this is the echonum slot */
		  (LONG)dabop,
		  (LONG)view1st[ileave],
		  (LONG)viewskip[ileave],
		  (LONG)etl,
                  (LONG)1, /* card_rpt */
                  (LONG)1, /* k_read */
	          dabacqctrl,
	          (LONG)hsdabmask);
    }
    else if (hsdab == 2)
    {
        int ioffset = ref_in_scan_flag + (rpg_in_scan_flag?rpg_in_scan_num:0);

        /* Note: For diffusion hyper DAB, indices below can be determined with diff_index */
        instance_index = 0;
        dir_index = 0;
        b_index = 0;
        vol_index = pass;
        frame_type = REF_FRAME;

        if ( (ref_in_scan_flag && (diff_index == 0)) || (rspent == L_REF) )
        { /*ref*/
            frame_type = REF_FRAME;
        }
        else if ( rpg_flag && rpg_in_scan_flag && (diff_index < ioffset))
        {   /* RPG TODO */
            frame_type = T2_FRAME;
            instance_index = diff_index - ref_in_scan_flag;
        }
        else if ( ((diff_index > (ioffset-1) ) && (diff_index < opdifnumt2 + ioffset)) && (rspent == L_SCAN))
        {  /*T2, if ref_in_scan_flag is off, it starts from 0, otherwise, starts from 1*/
            frame_type = T2_FRAME;
            instance_index = diff_index - ref_in_scan_flag; /*T2 instance index starting from 0*/
        }
        else if (rspent == L_SCAN)
        {
            frame_type = DIFF_FRAME;
            dir_index = (diff_index - opdifnumt2 - ioffset) % opdifnumdirs; /*diff dir_index starts from 0 */
            b_index = (diff_index - opdifnumt2 - ioffset) / opdifnumdirs;
        }

        if(diff_order_debug == PSD_ON)
        {
            sprintf(psddbgstr,"pass: %d, diff_index:%d, echo_nex:%d, dabop:%d, frame_type:%d, instance_index:%d, slicerep:%d, b_index:%d, dir_index:%d, vol_index:%d \n",
                    pass, diff_index, echo_nex, dabop, (int)frame_type, instance_index, slicerep,  b_index, dir_index, vol_index);
            printdbg(psddbgstr, diff_order_debug);

            fprintf(fp_diff_order, "%s", psddbgstr);
        }

        loaddiffdab( &diffdab,
                     (LONG) echo_nex,
                     (LONG) dabop,
                     (LONG) frame_type,
                     (LONG) instance_index,
                     (LONG) slicerep,
                     (LONG) view1st[ileave],
                     (LONG) viewskip[ileave],
                     (LONG) etl,
                     (LONG) b_index,
                     (LONG) dir_index,
                     (LONG) vol_index,
                     (LONG) gradpol_dab,
                     dabacqctrl,
                     (LONG) diffdabmask );
    }

    if (mux_flag)
    {
        if (fovshift == 0) {
            fovshift = slice_fov_shift;
        }
        slice_fov_shift_area_to_use = slice_fov_shift_area;

        kz_idx = blipstart;
        kz_to_phase = 2.0 * PI * GAM * (slice_fov_shift_area_to_use/1e6) / (fovshift-1);    /* phase/cm / kz_offset */
    }
    else
    {
        fovshift = 0;
        slice_fov_shift_area_to_use = 0.0;
        kz_idx = 0;
        kz_to_phase = 0.0;
    }

    /* Load the receive frequency/phase and dab packets */
    for (echo=0; echo<etl; echo++) {
      
        /* MRIge56894 - only set this stuff during real data acq */
        if(acq_data != DABOFF) { 
            /* BJM: we set the demod freq (sl_rcvcf) in the freq offset */
            /* register and then use omega to offset the slice along */
            /* the read axis.  For non-ramp sampled cases, the offset */
            /* waveform is a constant pulse.  For ramp sampled waveforms */
            /* the offset freq wavefrom is a trapezoid (freq mod on ramps */
            /* This simplifies the phase accumulation across the echo since */
            /* we no longer have to worry about the time it takes to latch */
            /* a freq. offset which leads to an uncertainty in how long we */
            /* accumulate phase across each echo in the train */
          
            freq_ctrl = sl_rcvcf;

            if ((blipsw == 0) || (PSD_OFF== mux_flag) || (echo < iref_etl)) {
                phase_ctrl = recv_phase[sliceindex][ileave][echo];
            } else {
                /* Calculate phase correction for center slice to remove effect of Kz encoding */
                kz_off = -1 * (kz_idx - (fovshift-1)/2.0);
                if (mux_flag && ((mux_slices_rf1 & 1) == 1))
                    slice_fov_shift_phase =  (rsp_info[sliceindex].rsptloc/10.0) * kz_off * kz_to_phase;
                else
                    slice_fov_shift_phase =  ((rsp_info[sliceindex].rsptloc + mux_slice_shift_mm_rf1/2.0)/10.0) * kz_off * kz_to_phase;
                phase_ctrl = calciphase(recv_phase_angle[sliceindex][ileave][echo] + slice_fov_shift_phase);

                kz_idx = (kz_idx + blipinc) % (fovshift);
            }
            
            setfreqphase(freq_ctrl,
                         phase_ctrl,
                         echotrainxtr[echo]);
          
            /* frequency offset */ 
            tempamp=(short)((recv_freq[sliceindex][ileave][echo]-sl_rcvcf)/omega_scale);
          
            if (vrgfsamp){
              
                setiampt(tempamp, &omega_flat, echo);
              
            } else {
              
                setiamp(tempamp, &omega_flat, echo);
              
            }

        } /* end acq_data condition */
      
        if ((echo >= rspe1st) && (echo < rspe1st + rspetot))
            dabacqctrl = (TYPDAB_PACKETS)acq_data;
        else
            dabacqctrl = DABOFF;
      
        acqctrl(dabacqctrl, fast_rec, echotrainrba[echo]);
      
    } /* end echo loop for setting op xtr packets */ 

    return SUCCESS;

} /* End dabrbaload */

/***************************** diffamp *************************/
STATUS diffamp( INT dshot )
{
    if((dshot < 0)||(rspent == L_MPS2)||(rspent == L_APS2)||(rspent == L_REF))
    {
        ia_incdifx = 0;
        ia_incdify = 0;
        ia_incdifz = 0;
    }
    else
    {
        /* DWI */
        if(opdiffuse == PSD_ON && tensor_flag == PSD_OFF)
        {
            getDiffGradAmp(&incdifx, &incdify, &incdifz, dshot);
            ia_incdifx = (int)(incdifx*(float)max_pg_iamp/loggrd.tx);
            ia_incdify = (int)(incdify*(float)max_pg_iamp/loggrd.ty);
            ia_incdifz = (int)(incdifz*(float)max_pg_iamp/loggrd.tz);
        }
        /* DTI BJM: do the tensor acq. */
        else if(tensor_flag == PSD_ON)
        {
            ia_incdifx = (int)(incdifx*TENSOR_AGP[0][dshot]*(float)max_pg_iamp/loggrd.tx);
            ia_incdify = (int)(incdify*TENSOR_AGP[1][dshot]*(float)max_pg_iamp/loggrd.ty);
            ia_incdifz = (int)(incdifz*TENSOR_AGP[2][dshot]*(float)max_pg_iamp/loggrd.tz);

            if (debugTensor == PSD_ON)
            {
                printf("Shot # = %d\n", dshot);
                printf("TENSOR_AGP[0] = %f\n", TENSOR_AGP[0][dshot]);
                printf("TENSOR_AGP[1] = %f\n", TENSOR_AGP[1][dshot]);
                printf("TENSOR_AGP[2] = %f\n\n",TENSOR_AGP[2][dshot]);
                printf("incdifx=%d,incdify=%d,incdifz=%d,dshot=%d\n",ia_incdifx,ia_incdify,ia_incdifz,dshot);
                fflush(stdout);
            }
        }
    }
        
    return SUCCESS;
}

/***************************** diffstep *************************/
STATUS diffstep( INT dshot )
{
    int i;

    diffamp(dshot);

#ifdef UNDEF

    if (hoecc_flag == PSD_OFF)  /* only turn on linear correction if HOECC is off */
    {
        /*************************************************************/
        /* compute cross term correction values                      */
        /*************************************************************/
        
        /* B0 calculation */
        
        freq_dwi = (float)ia_incdifx/(float)max_pg_iamp*loggrd.tx*dwibcor[0];
        freq_dwi += (float)ia_incdify/(float)max_pg_iamp*loggrd.ty*dwibcor[1];
        freq_dwi += (float)ia_incdifz/(float)max_pg_iamp*loggrd.tz*dwibcor[2];
        
        freq_dwi = freq_dwi*GAM; /* convert frequency from Gauss to Herz */
        phase_dwi = freq_dwi*TWO_PI*(float)esp/(1.0e6);  /* convert freq to phase */
        
        
        /* gradient calculation */
        
        ia_gx_dwi=ia_incdifx*dwigcor[0];
        ia_gx_dwi=ia_gx_dwi+ia_incdify*dwigcor[3];
        ia_gx_dwi=ia_gx_dwi+ia_incdifz*dwigcor[6];
        
        ia_gy_dwi=ia_incdifx*dwigcor[1];
        ia_gy_dwi=ia_gy_dwi+ia_incdify*dwigcor[4];
        ia_gy_dwi=ia_gy_dwi+ia_incdifz*dwigcor[7];
        
        /*  now convert the phase-encoding correctin values to the
            blip correction amplitudes  */
        
        ia_gy_dwi = ia_gy_dwi*esp/(pw_gyb + pw_gyba);
        
        /* the conversion is based on area conservation */
        /* This calculation does not account for the    */
        /* change in the slew rate of gyba as a result  */
        /* of adding ia_gy_dwi to gyb                   */
        
        
        /******************************************************************************/
        /*      ia_gz_dwi not used at this time                                       */
        /******************************************************************************/
        ia_gz_dwi=ia_incdifx*dwigcor[2];
        ia_gz_dwi=ia_gz_dwi+ia_incdify*dwigcor[5];
        ia_gz_dwi=ia_gz_dwi+ia_incdifz*dwigcor[8];
        
        tmp_ileave=ileave;
        ileave=0;
        setreadpolarity();
        ileave=tmp_ileave;
        
        tmp_ygrad_sw=1;
        ygradctrl(tmp_ygrad_sw,gyb_amp,etl);
       
        /** added by XJZ for B0-eddy current DWI correction  **/
        
        if (dwicntrl==1)
            for (ii=0; ii<opslquant; ii++)
                for(jj=0; jj<intleaves; jj++)
                    for(kk=0; kk<tot_etl; kk++)
                    {
                        recv_phase_angle[ii][jj][kk] = recv_phase_ang_nom[ii][jj][kk];
                        recv_phase_angle[ii][jj][kk] += (phase_dwi/2.0+phase_dwi*(float)kk);
                        recv_phase[ii][jj][kk] = calciphase(recv_phase_angle[ii][jj][kk]);
                    }
        
        /* end cross term correction  and B0 computation */
    }
#endif  /* UNDEF */

    /* Calculate read, blip grad and receiver freq compensation; update receiver phase in diffstep() */
@inline HoecCorr.e HoecCalcAmpUpdateReceiverPhaseRsp

    /*	turn off diffusion during prescan	*/

    if((rspent==L_MPS2)||(rspent==L_APS2)||(rspent==L_REF)) 
    {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            setiampt(0, &gxdl, 0);
            setiampt(0, &gxdr, 0);
            setiampt(0, &gydl, 0);
            setiampt(0, &gydr, 0);
            setiampt(0, &gzdl, 0);
            setiampt(0, &gzdr, 0);
	    if(ftde_flag == PSD_ON){/* granty edit for full time diffusion encoding */
		setiampt(0, &gxde, 0);
	        setiampt(0, &gyde, 0);
	        setiampt(0, &gzde, 0);
	    }
        } else {
            setiampt(0, &gxdl1, 0);
            setiampt(0, &gxdr1, 0);
            setiampt(0, &gxdl2, 0);
            setiampt(0, &gxdr2, 0);
          
            setiampt(0, &gydl1, 0);
            setiampt(0, &gydr1, 0);
            setiampt(0, &gydl2, 0);
            setiampt(0, &gydr2, 0);
          
            setiampt(0, &gzdl1, 0);
            setiampt(0, &gzdr1, 0); 
            setiampt(0, &gzdl2, 0);
            setiampt(0, &gzdr2, 0);
        }
  
    }
    else
    {
        /* DTI */
        if (PSD_OFF == dualspinecho_flag)
        {
            setiampt(ia_incdifx, &gxdl, 0);
            setiampt(ia_incdifx, &gxdr, 0);
            setiampt(ia_incdify, &gydl, 0);
            setiampt(ia_incdify, &gydr, 0);
            setiampt(ia_incdifz, &gzdl, 0);
            setiampt(ia_incdifz, &gzdr, 0);
	    if(ftde_flag == PSD_ON){/* granty edit for full time diffusion encoding */
		setiampt(-ia_incdifx, &gxde, 0);
	        setiampt(-ia_incdify, &gyde, 0);
	        setiampt(-ia_incdifz, &gzde, 0);
	    }
        } 
        else 
        {
            setiampt(ia_incdifx, &gxdl1, 0);
            setiampt(-ia_incdifx, &gxdr1, 0);
            setiampt(ia_incdifx, &gxdl2, 0);
            setiampt(-ia_incdifx, &gxdr2, 0);

            setiampt(ia_incdify, &gydl1, 0);
            setiampt(-ia_incdify, &gydr1, 0);
            setiampt(ia_incdify, &gydl2, 0);
            setiampt(-ia_incdify, &gydr2, 0);

            setiampt(ia_incdifz, &gzdl1, 0);
            setiampt(-ia_incdifz, &gzdr1, 0); 
            setiampt(ia_incdifz, &gzdl2, 0);
            setiampt(-ia_incdifz, &gzdr2, 0);
        }
    }       

    freqSign = 1;
    freqSign_ex = 1;
    freqSign_rf2 = 1;
    freqSign_rf2right = 1;
    freqSign_rf2left = 1;

    if (PSD_OFF == dualspinecho_flag)
    {
            /* Keep the polarity of rf1 and rf2 slice select grad and crusher same as diff grad */
            if(invertSliceSelectZ == PSD_ON || invertSliceSelectZ2 == PSD_ON)
            {
                if((invertSliceSelectZ==PSD_ON && ((ia_incdifz<0 && ia_gzrf2r1>0) || (ia_incdifz>0 && ia_gzrf2r1<0))) ||
                    (invertSliceSelectZ2==PSD_ON && ia_gzrf2r1<0))
            {
                freqSign = -1;
                freqSign_ex = -1;
                freqSign_rf2 = -1;
            }
            else
            {
                freqSign = 1;
                freqSign_ex = 1;
                freqSign_rf2 = 1;
            }
        }
        if(ssgr_flag)
        {
            freqSign *= -1;
            freqSign_ex *= -1;
        }

        /* 90 */
        if (ss_rf1 || rfov_flag) setiamp(freqSign*ia_gzrf1, &gzrf1, 0);
        else 
        {
            setiamp(freqSign*ia_gzrf1, &gzrf1a, 0);
            setiamp(freqSign*ia_gzrf1, &gzrf1, 0);
            setiamp(freqSign*ia_gzrf1, &gzrf1d, 0);
        }   
        /* RTB0 correction*/
        if(rtb0_flag || (dpc_flag && (!mux_flag)))
        {
            setiampt(freqSign*ia_gz1, &gz1, 0);
        }

        if (rfov_flag)
        {
            setiamp(freqSign*ia_gyrf1, &gyrf1, 0);
            if (ia_gyex1 != 0)
            {
                setiamp(freqSign*ia_gyex1, &gyex1a, 0);
                setiamp(freqSign*ia_gyex1, &gyex1, 0);
                setiamp(freqSign*ia_gyex1, &gyex1d, 0);
            }
        }

        /* 180 + crushers */
        setiamp(freqSign_rf2*ia_gzrf2l1, &gzrf2l1a, 0);
        setiamp(freqSign_rf2*ia_gzrf2l1, &gzrf2l1, 0);
        setiamp(freqSign_rf2*max_pg_iamp, &gzrf2l1d, 0);
        setiamp(freqSign_rf2*ia_gzrf2, &gzrf2, 0);
        setiamp(freqSign_rf2*max_pg_iamp, &gzrf2r1a, 0);
        setiamp(freqSign_rf2*ia_gzrf2r1, &gzrf2r1, 0);
        setiamp(freqSign_rf2*ia_gzrf2r1, &gzrf2r1d, 0);

        /* Inversion pulse */
        if(ir_on && (skip_ir == PSD_OFF)) setiampt(freqSign*ia_gzrf0, &gzrf0, INSTRALL);

            /* Keep the polarity of XY crusher same as diff grad */
            if(invertCrusherXY == PSD_ON)
            {
                if((ia_incdifx < 0 && ia_xgradCrusherR >0) || (ia_incdifx > 0 && ia_xgradCrusherR <0)) {
                    if(xygradCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_xgradCrusherL, &xgradCrusherL, 0);
                        setiampt(-ia_xgradCrusherR, &xgradCrusherR, 0);
                    }
                } else {
                    if(xygradCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_xgradCrusherL, &xgradCrusherL, 0);
                        setiampt(ia_xgradCrusherR, &xgradCrusherR, 0);
                    }
                } 
                if((ia_incdify < 0 && ia_ygradCrusherR >0) || (ia_incdify > 0 && ia_ygradCrusherR <0)) {
                    if(xygradCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_ygradCrusherL, &ygradCrusherL, 0);
                        setiampt(-ia_ygradCrusherR, &ygradCrusherR, 0);
                    }
                } else {
                    if(xygradCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_ygradCrusherL, &ygradCrusherL, 0);
                        setiampt(ia_ygradCrusherR, &ygradCrusherR, 0);
                    }
                } 
            }
    }
    else 
    {
            /* Need to flip sign of SlicSel gradients to */
            /* prevent STE formation due to balancing    */
            /* of diffusion lobes on Z and slice select  */
            /* crushers....                             */
            /* keep the polarity of slice select grad and crusher same as the last diff grad lobe */
            if(PSD_ON == invertSliceSelectZ || PSD_ON == invertSliceSelectZ2) {

                if((invertSliceSelectZ==PSD_ON && ((ia_incdifz>0 && ia_gzrf2leftr1>0) || (ia_incdifz<0 && ia_gzrf2leftr1<0))) || 
                   (invertSliceSelectZ2==PSD_ON && ia_gzrf2leftr1>0)) {
                freqSign = -1;
                freqSign_ex = -1;
                    freqSign_rf2left = -1;
                freqSign_rf2right = -1;
            } 
            else
            {
                freqSign = 1;
                freqSign_ex = 1;
                freqSign_rf2left = 1;
                freqSign_rf2right = 1;
            }
        }
        if(ssgr_flag)
        {
            freqSign *= -1;
            freqSign_ex *= -1;
            freqSign_rf2left *= -1;
        }

        /* 90 */
        if (ss_rf1 || rfov_flag) setiamp(freqSign*ia_gzrf1, &gzrf1, 0);
        else 
        {
            setiamp(freqSign*ia_gzrf1, &gzrf1a, 0);
            setiamp(freqSign*ia_gzrf1, &gzrf1, 0);
            setiamp(freqSign*ia_gzrf1, &gzrf1d, 0);
        }
        /* RTB0 correction*/
        if(rtb0_flag || (dpc_flag && (!mux_flag)))
        {
            setiampt(freqSign*ia_gz1, &gz1, 0);
        }

        if (rfov_flag)
        {
            setiamp(freqSign*ia_gyrf1, &gyrf1, 0);
            if (ia_gyex1 != 0)
            {
                setiamp(freqSign*ia_gyex1, &gyex1a, 0);
                setiamp(freqSign*ia_gyex1, &gyex1, 0);
                setiamp(freqSign*ia_gyex1, &gyex1d, 0);
            }
        }

        /* left 180 + crushers */
        setiamp(freqSign_rf2left*ia_gzrf2leftl1, &gzrf2leftl1a, 0);
        setiamp(freqSign_rf2left*ia_gzrf2leftl1, &gzrf2leftl1, 0);
        setiamp(freqSign_rf2left*max_pg_iamp, &gzrf2leftl1d, 0);
        setiamp(freqSign_rf2left*ia_gzrf2left, &gzrf2left, 0);
        setiamp(freqSign_rf2left*max_pg_iamp, &gzrf2leftr1a, 0);
        setiamp(freqSign_rf2left*ia_gzrf2leftr1, &gzrf2leftr1, 0);
        setiamp(freqSign_rf2left*ia_gzrf2leftr1, &gzrf2leftr1d, 0);

        /* right 180 + crushers */
        setiamp(freqSign_rf2right*ia_gzrf2rightl1, &gzrf2rightl1a, 0);
        setiamp(freqSign_rf2right*ia_gzrf2rightl1, &gzrf2rightl1, 0);
        setiamp(freqSign_rf2right*max_pg_iamp, &gzrf2rightl1d, 0);
        setiamp(freqSign_rf2right*ia_gzrf2right, &gzrf2right, 0);
        setiamp(freqSign_rf2right*max_pg_iamp, &gzrf2rightr1a, 0);
        setiamp(freqSign_rf2right*ia_gzrf2rightr1, &gzrf2rightr1, 0);
        setiamp(freqSign_rf2right*ia_gzrf2rightr1, &gzrf2rightr1d, 0);

        /* Inversion pulse */
        if(ir_on && (skip_ir == PSD_OFF)) setiampt(freqSign*ia_gzrf0, &gzrf0, INSTRALL);

            /* Keep the polarity of left XY crusher same as 1st diff grad lobe,
               and right XY crusher as the last diff grad lobe */
            if(invertCrusherXY == PSD_ON)
            {
                if((ia_incdifx < 0 && ia_xgradLeftCrusherR >0) || (ia_incdifx > 0 && ia_xgradLeftCrusherR <0)) {
                    if(xygradLeftCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_xgradLeftCrusherL, &xgradLeftCrusherL, 0);
                        setiampt(-ia_xgradLeftCrusherR, &xgradLeftCrusherR, 0);
                    }
                    if(xygradRightCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_xgradRightCrusherL, &xgradRightCrusherL, 0);
                        setiampt(ia_xgradRightCrusherR, &xgradRightCrusherR, 0);
                    }
                } else {
                    if(xygradLeftCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_xgradLeftCrusherL, &xgradLeftCrusherL, 0);
                        setiampt(ia_xgradLeftCrusherR, &xgradLeftCrusherR, 0);
                    }
                    if(xygradRightCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_xgradRightCrusherL, &xgradRightCrusherL, 0);
                        setiampt(-ia_xgradRightCrusherR, &xgradRightCrusherR, 0);
                    }
                } 
                if((ia_incdify < 0 && ia_ygradLeftCrusherR >0) || (ia_incdify > 0 && ia_ygradLeftCrusherR <0)) {
                    if(xygradLeftCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_ygradLeftCrusherL, &ygradLeftCrusherL, 0);
                        setiampt(-ia_ygradLeftCrusherR, &ygradLeftCrusherR, 0);
                    }
                    if(xygradRightCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_ygradRightCrusherL, &ygradRightCrusherL, 0);
                        setiampt(ia_ygradRightCrusherR, &ygradRightCrusherR, 0);
                    }
                } else {
                    if(xygradLeftCrusherFlag == PSD_ON)
                    {
                        setiampt(ia_ygradLeftCrusherL, &ygradLeftCrusherL, 0);
                        setiampt(ia_ygradLeftCrusherR, &ygradLeftCrusherR, 0);
                    }
                    if(xygradRightCrusherFlag == PSD_ON)
                    {
                        setiampt(-ia_ygradRightCrusherL, &ygradRightCrusherL, 0);
                        setiampt(-ia_ygradRightCrusherR, &ygradRightCrusherR, 0);
                    }
                } 
            }
    }

    for (i=0; i<opslquant; i++) 
    {
        if (ss_rf1 == PSD_ON) 
        {
            setupphases(rf1_pha, rf1_freq, i, rf1_phase, 0, freqSign);
        } 
        else 
        {
            setupphases(rf1_pha, rf1_freq, i, rf1_phase, t_rf1_phase, freqSign);
        }

        if(ir_on)
        {
            setupphases(rf0_pha, rf0_freq, i, rf0_phase, 0, freqSign);
        }

        if(PSD_OFF == dualspinecho_flag)
        {
            setupphases(rf2_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2);
        }
        else
        {
            setupphases(rf2left_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2left);
            setupphases(rf2right_pha, rf2_freq, i, rf2_phase, t_rf2_phase, freqSign_rf2right);
        }
    }		

    return SUCCESS;

}

/***************************** msmpTrig *************************/
/* Build the trigger for multi-slice, multi-phase cardiac */
#ifdef __STDC__ 
STATUS msmpTrig(void )
#else /* !__STDC__ */
    STATUS msmpTrig()
#endif /* __STDC__ */
{
    if ((opcgate == PSD_ON) && (opphases > 1) &&
        ((rspent == L_MPS2)||(rspent == L_APS2)||
         (rspent == L_SCAN)||(rspent == L_REF))) 
    {
        if (slice == 0) {
            switch(rspent) {
            case L_MPS2:
                settrigger((short)trig_mps2, (short)sliceindex);
                break;
            case L_APS2:
                settrigger((short)trig_aps2, (short)sliceindex);
                break;
            case L_SCAN:
            case L_REF:
                settrigger((short)trig_scan, (short)sliceindex);
                break;
            default:
                break;
            }
        }
        else
            settrigger((short)TRIG_INTERN, (short)sliceindex);
    }
    return SUCCESS;
}

/***************************** phaseReset*************************/
STATUS
#ifdef __STDC__
phaseReset( WF_PULSE_ADDR pulse,
            INT control )
#else /* !__STDC__ */
    phaseReset(pulse, control)
    WF_PULSE_ADDR pulse;
    INT control;
#endif /* __STDC__ */
{
    SHORT loadbits;

    if (control == 0)
        loadbits = 0;
    else
        loadbits = EDC;

    sspload((SHORT *)&loadbits,
            (WF_PULSE_ADDR)pulse,
            (LONG)0,
            (SHORT)1,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);

    return SUCCESS;
}

/***************************** ygradctrl  *************************/
#ifdef __STDC__
STATUS ygradctrl( INT blipsw,
                  INT blipwamp,
                  INT numblips )
#else /* !__STDC__ */
    int ygradctrl(blipsw, blipwamp, numblips)
    INT blipsw;
    INT blipwamp;
    INT numblips;
#endif /* __STDC__ */
{
    int bcnt;
    int dephaser_amp;
    int gmn_amp;
    int parity;

    parity = gradpol[ileave];

    if (blipsw == 0) {
        dephaser_amp = 0;
        gmn_amp = 0;
        for (bcnt=0;bcnt<numblips-1;bcnt++)
            setiampt((short)0, &gyb, bcnt);
    } else {
        gmn_amp = ia_gymn2;
        if (rsppepolar == PSD_OFF)
        {
            dephaser_amp = -gy1f[0];
            for (bcnt=0;bcnt<numblips-1;bcnt++) {
                if (oblcorr_perslice == 1)
                    setiampt((short)(-blipwamp + parity*rspia_gyboc[slice]-ia_gy_dwi), &gyb, bcnt);
                else
                    setiampt((short)(-blipwamp + parity*rspia_gyboc[0]-ia_gy_dwi), &gyb, bcnt);
                parity *= -1;
            }
        } 
        else 
        {
            dephaser_amp = gy1f[0];
            for (bcnt=0;bcnt<numblips-1;bcnt++) {
                if (oblcorr_perslice == 1)
                    setiampt((short)(blipwamp + parity*rspia_gyboc[slice]-ia_gy_dwi), &gyb, bcnt);
                else
                    setiampt((short)(blipwamp + parity*rspia_gyboc[0]-ia_gy_dwi), &gyb, bcnt);
                parity *= -1;
            }
        }
    }	 

    setiampt((short)dephaser_amp, &gy1, 0);
    if (ygmn_type == CALC_GMN1) {
        setiampt((short)-gmn_amp, &gymn1, 0);
        setiampt((short)gmn_amp, &gymn2, 0);
    }

    return SUCCESS;

} /* End ygradctrl */
/* functions that set blip amplitude and receiver phase */
STATUS zgradctrl( INT blipsw,
                  INT blipstart,
                  INT blipinc,
                  INT etl,
                  INT fovshift)
{
    int bcnt;
    int kz_last, kz_new;
    float kz_off;
    float gz1_single_blip_scale;
    float gz1_scale;
    float gzb_scale;
    float slice_fov_shift_cycles_to_use;
    float factor_gz1_to_use;

    if (blipsw == 0) {
        /* Set all blips to 0 amplitude */
        if (oppseq == PSD_GE)
            setiampt((short)(a_gz1 / loggrd.tz * MAX_PG_IAMP), &gz1, 0);
        if (oppseq == PSD_SE && use_slice_fov_shift_blips)
        {
            if(dpc_flag)
            {
                gz1_scale = area_gz1/(fabs(slice_fov_shift_area/2) + fabs(area_gz1));
                setiampt((short)(gz1_scale*a_gz1 / loggrd.tz * MAX_PG_IAMP), &gz1, 0);
            }
            else
            {
                setiampt((short)0, &gz1, 0);
            }
        }
        if ( use_slice_fov_shift_blips > 0 ) {
            for (bcnt=0;bcnt<etl-1;bcnt++) {
                setiampt((short)0, &gzb, bcnt);
            }
        }
    } else {
        /* Normal blipped slice_fov_shift */
        if (fovshift == 0) {
            fovshift = slice_fov_shift;
        }

        /* Find gz1 scaling so that we are acquiring Kz = blipstart, with Kz going from [0..fovshift-1] */
        slice_fov_shift_cycles_to_use = slice_fov_shift_cycles;
        factor_gz1_to_use = factor_gz1;

        kz_off = -1 * (blipstart - ((fovshift-1)/2.0));
        if (oppseq == PSD_GE) {
            gz1_single_blip_scale = 2*(factor_gz1_to_use-1.0) / (slice_fov_shift_cycles_to_use * fovshift); /* gz1 multiple equivalent to single Kz blip */
            gz1_scale = 1.0 - gz1_single_blip_scale * kz_off;
            setiampt((short)(a_gz1 * gz1_scale / loggrd.tz * MAX_PG_IAMP), &gz1, 0);
        }
        if (oppseq == PSD_SE && use_slice_fov_shift_blips) {
            gz1_single_blip_scale = 2 * factor_gz1_to_use / (slice_fov_shift_cycles_to_use * fovshift);
            if(dpc_flag)
            {
                gz1_scale = ((kz_off * gz1_single_blip_scale)*slice_fov_shift_area/2+area_gz1)/(fabs(slice_fov_shift_area/2) + fabs(area_gz1));  
            }    
            else
            {   
                gz1_scale = kz_off * gz1_single_blip_scale;
            }
            setiampt((short)(a_gz1 * gz1_scale / loggrd.tz * MAX_PG_IAMP), &gz1, 0);
        }

        kz_last = blipstart;
        for (bcnt=0; bcnt<etl-1; bcnt++) {
            kz_new = (kz_last + blipinc) % (fovshift);
            kz_off = -1 * (kz_new - kz_last);
            kz_last = kz_new;

            gzb_scale = kz_off / (slice_fov_shift_cycles * fovshift); /* Always use max blip area in accelerated time points to set up gzb amplitude and width, because calibration time points never use gzb */
            setiampt((short)(gzb_amp * gzb_scale / epiloggrd.tz * MAX_PG_IAMP), &gzb, bcnt);
        }
    }

    return SUCCESS;
} /* End zgradctrl */

@inline HoecCorr.e HoecRspFunctionsInRsp

void dummylinks( void )
{
    epic_loadcvs("thefile");            /* for downloading CVs */
}



@inline SpSat.e SpSatChop
@inline ChemSat.e CsSatMod
@inline SpSat.e SpSatInitRsp 
@inline SpSat.e SpSatUpdateRsp
@inline SpSat.e SpSatON
@inline ss.e ssRsp

@inline Navigator.e

@pg
void getDiffGradAmp(float * difx, float * dify, float * difz, int dshot)
{
    int bindex, dirindex;

    if (opdifnumt2 > 0)
    {
        if (dshot <= 0 )  /* ref and T2 */
        {
            *difx = 0;
            *dify = 0;
            *difz = 0;
        }
        else
        {
            *difx = diff_ampx[(int)((dshot-1)/opdifnumdirs)];
            *dify = diff_ampy[(int)((dshot-1)/opdifnumdirs)];
            *difz = diff_ampz[(int)((dshot-1)/opdifnumdirs)];

            if(opdfaxtetra > PSD_OFF || opdfax3in1 > PSD_OFF || (opdfaxall > PSD_OFF && gradopt_diffall == PSD_ON))
            {
                if (obl_3in1_opt) /* Obl 3in1 opt */
                {
                    bindex = (int)((dshot-1)/opdifnumdirs);
                    dirindex = (dshot-1)%opdifnumdirs;

                    *difx = diff_ampx2[bindex][dirindex];
                    *dify = diff_ampy2[bindex][dirindex];
                    *difz = diff_ampz2[bindex][dirindex];

                    if (obl_3in1_opt_debug)
                    {
                        printf(" \n");
                        printf("bindex= %d dirindex= %d\n", bindex, dirindex);
                        printf("MPG amplitude in each axis in G/cm.\n");
                        printf("*difx= %f *dify= %f *difz= %f\n", *difx, *dify, *difz);
                    }
                }
                else if (PSD_OFF == different_mpg_amp_flag)
                {
                    rotateToLogical(difx, dify, difz, (dshot-1)%opdifnumdirs);
                }
            }
            else
            {
                *difx *= D[(dshot-1)%opdifnumdirs][AXIS_X];
                *dify *= D[(dshot-1)%opdifnumdirs][AXIS_Y];
                *difz *= D[(dshot-1)%opdifnumdirs][AXIS_Z];
            }
        }
    }
    else
    {
        if (dshot<0)  /* ref */
        {
            *difx = 0;
            *dify = 0;
            *difz = 0;
        }
        else
        {
            *difx = diff_ampx[(int)(dshot/opdifnumdirs)];
            *dify = diff_ampy[(int)(dshot/opdifnumdirs)];
            *difz = diff_ampz[(int)(dshot/opdifnumdirs)];

            if(opdfaxtetra > PSD_OFF || opdfax3in1 > PSD_OFF || (opdfaxall > PSD_OFF && gradopt_diffall == PSD_ON))
            {
                if (obl_3in1_opt) /* Obl 3in1 opt */
                {
                    bindex = (int)(dshot/opdifnumdirs);
                    dirindex = dshot%opdifnumdirs;

                    *difx = diff_ampx2[bindex][dirindex];
                    *dify = diff_ampy2[bindex][dirindex];
                    *difz = diff_ampz2[bindex][dirindex];

                    if (obl_3in1_opt_debug)
                    {
                        printf(" \n");
                        printf("bindex= %d dirindex= %d\n", bindex, dirindex);
                        printf("MPG amplitude in each axis in G/cm.\n");
                        printf("*difx= %f *dify= %f *difz= %f\n", *difx, *dify, *difz);
                    }
                }
                else if (PSD_OFF == different_mpg_amp_flag)
                {
                    rotateToLogical(difx, dify, difz, dshot%opdifnumdirs);
                }
            }
            else
            {
                *difx *= D[dshot%opdifnumdirs][AXIS_X];
                *dify *= D[dshot%opdifnumdirs][AXIS_Y];
                *difz *= D[dshot%opdifnumdirs][AXIS_Z];
            }
        }
    }
}

void loadDiffVecMatrix(void)
{
    /* SWL: set the diffusion lobe amp scale for DWI
     * D[][] are 4by3 matrix. First dimension
     * indicates the axis to play the gradient lobe, the second
     * dimension indicates the TRs to be played. (Index 0 is the
     * T2 scan) */

    if (opdfaxall == PSD_ON)
    {
        if(gradopt_diffall == PSD_OFF)
        {
            D[DIR1][AXIS_X] = 0.0;
            D[DIR1][AXIS_Y] = 0.0;
            D[DIR1][AXIS_Z] = 1.0;

            D[DIR2][AXIS_X] = 1.0;
            D[DIR2][AXIS_Y] = 0.0;
            D[DIR2][AXIS_Z] = 0.0;

            D[DIR3][AXIS_X] = 0.0;
            D[DIR3][AXIS_Y] = 1.0;
            D[DIR3][AXIS_Z] = 0.0;
        }
        else
        {
            D[DIR1][AXIS_X] = 1.0;
            D[DIR1][AXIS_Y] = 1.0;
            D[DIR1][AXIS_Z] = 0.0;

            D[DIR2][AXIS_X] = 1.0/sqrt(2.0);
            D[DIR2][AXIS_Y] = -1.0/sqrt(2.0);
            D[DIR2][AXIS_Z] = 1.0;

            D[DIR3][AXIS_X] = -1.0/sqrt(2.0);
            D[DIR3][AXIS_Y] = 1.0/sqrt(2.0);
            D[DIR3][AXIS_Z] = 1.0;
        }
    }
    else if(opdfaxx > 0)
    {
        D[DIR1][AXIS_X] = 1.0;
        D[DIR1][AXIS_Y] = 0.0;
        D[DIR1][AXIS_Z] = 0.0;
    }
    else if(opdfaxy > 0)
    {
        D[DIR1][AXIS_X] = 0.0;
        D[DIR1][AXIS_Y] = 1.0;
        D[DIR1][AXIS_Z] = 0.0;
    }
    else if(opdfaxz > 0)
    {
        D[DIR1][AXIS_X] = 0.0;
        D[DIR1][AXIS_Y] = 0.0;
        D[DIR1][AXIS_Z] = 1.0;
    }
    else if (opdfax3in1 > PSD_OFF || opdfaxtetra > PSD_OFF)
    {
        D[DIR1][AXIS_X] = 1.0;
        D[DIR1][AXIS_Y] = 1.0;
        D[DIR1][AXIS_Z] = 1.0;

        D[DIR2][AXIS_X] = 1.0;
        D[DIR2][AXIS_Y] = -1.0;
        D[DIR2][AXIS_Z] = -1.0;

        D[DIR3][AXIS_X] = -1.0;
        D[DIR3][AXIS_Y] = -1.0;
        D[DIR3][AXIS_Z] = 1.0;

        D[DIR4][AXIS_X] = -1.0;
        D[DIR4][AXIS_Y] = 1.0;
        D[DIR4][AXIS_Z] = -1.0;
    }
}

STATUS rotateToLogical(float * idifx, float * idify, float * idifz, int dir)
{
    float ax, ay, az;

    ax = (*idifx)*D[dir][AXIS_X];
    ay = (*idify)*D[dir][AXIS_Y];
    az = (*idifz)*D[dir][AXIS_Z];

    *idifx = inversRR[0]*ax+inversRR[1]*ay+inversRR[2]*az;
    *idify = inversRR[3]*ax+inversRR[4]*ay+inversRR[5]*az;
    *idifz = inversRR[6]*ax+inversRR[7]*ay+inversRR[8]*az;

    return SUCCESS;
}

STATUS inversRspRot( float inversRot[9], long  origRot[9])
{
    /* given that the rotation matrix would always be real and
     * orthogonal, then the inverse of the rotation matrix would
     * be the same as its tranpose matrix ZL */
    float a[9];
    int i, j;

    for (i = 0; i<9; i++)
    {
        a[i] = (float)origRot[i]/(float)max_pg_iamp;
    }

    for (i=0; i<3 ; i++)
    {
        for (j=0; j<3; j++)
        {
            inversRot[i*3+j] = a[3*j+i];
        }
    }

    if (debugTensor == PSD_ON)
    {
        printf("orig rot is\n");
        for (i=0; i<3; i++)
        {
            for (j=0; j<3; j++)
            {
                printf( "%f        ",a[i*3+j]);
            }
            printf("\n");
        }
        printf("invers rot is\n");
        for (i=0; i<3; i++)
        {
            for (j=0; j<3; j++)
            {
                printf( "%f        ",inversRot[i*3+j]);
            }
            printf("\n");
        }
        fflush( stdout );
    }
    return SUCCESS;
}

STATUS set_diff_order( void )
{
    /* This function calculates the diffusion gradient cycling orders for each pass and
     * save the scheme into diff_order.txt
     * */
    int npass;
    int nslice;
    int ndirs = 0;
    int LCD;
    int thedir = 0;
    int count = 0;
    int noffset=0;
    int n = 0, nrep = 0;
    int var;
    int kk, ll, mm;
    int maxnex;

#ifndef IPG
    int sum_dir;
    FILE *fp_diff_order = NULL;

#ifdef PSD_HW
    const char *dir_difforder = "/usr/g/service/log";
#else
    const char *dir_difforder = "./";
#endif

    char fname_difforder[255];
    sprintf(fname_difforder, "%s/diff_order.txt", dir_difforder);
#endif

    int pass_offset = (ref_in_scan_flag ? 1:0) + (rpg_in_scan_flag?rpg_in_scan_num:0);

    if (tensor_flag == PSD_OFF)
    {
        if(diff_order_flag == 1)
        {
            ndirs = num_dif;
            nrep = opnumbvals;
        }
        else if (diff_order_flag == 2)
        {
            ndirs = (int)(opdifnext2 * opdifnumt2 + num_dif * total_difnex);
            nrep = 1;
        }
    }
    else
    {
        if(diff_order_flag == 1)
        {
#ifndef IPG
            ndirs = exist(opdifnumdirs);
#else
            ndirs = opdifnumdirs;
#endif
        }
        else if (diff_order_flag == 2)
        {
            ndirs = pass_reps - pass_offset; /* Don't cycle integrated ref nor RPG volume */
        }
        nrep = 1;
    }

    int counter = 0;
    if (diff_order_flag == 2 && tensor_flag == PSD_OFF)
    {
        for(kk=0; kk<opdifnumt2; kk++)
        {
            for (ll=0; ll<opdifnext2; ll++)
            {
                diff_order_pass[counter] = kk+pass_offset;
                diff_order_nex[counter]  = ll;
                diff_order_dif[counter]  = 0;
                counter++;
            }
        }

        for(kk=0; kk<opnumbvals; kk++)
        {
#ifdef IPG
            maxnex = difnextab_rsp[kk];
#else
            maxnex = (int)difnextab[kk];
#endif
            for (ll=0; ll< maxnex; ll++)
            {
                for (mm=0; mm<num_dif; mm++)
                {
                    diff_order_pass[counter] = (int)(opdifnext2 * opdifnumt2 + mm + num_dif * kk + pass_offset);
                    diff_order_nex[counter] = ll;
                    diff_order_dif[counter] = kk;
                    counter++;
                }
            }
        }
    }

    if (ndirs == 0)
    {
        return SKIP;
    }

    /* No change in order */
    for (npass = 0; npass < opdifnumt2 + pass_offset; npass++)
    {
        for (nslice = 0; nslice < diff_order_nslices; nslice++)
        {
            diff_order[npass][nslice] = npass;
        }
    }

    /* Assign diffusion direction */
    if (diff_order_flag == 1)
    {
        noffset = opdifnumt2 + pass_offset;
    }
    else if (diff_order_flag == 2)
    {
        noffset = pass_offset;
    }

    LCD = getLCD(diff_order_nslices, ndirs);

    if(LCD == 0)
    {
        return FAILURE;
    }

    var = 0;

    for (npass = 0; npass < ndirs; npass++)
    {
        if (diff_order_nslices > ndirs)
        {
            var = npass;
        }

        for (nslice = 0; nslice < diff_order_nslices; nslice++)
        {
            if ((diff_order_flag == 1) || (diff_order_flag == 2))
            {
                thedir = thedir%ndirs;
                diff_order[noffset + npass][nslice] = noffset + thedir;
                count++;
                thedir++;
            }
        }

        if ((diff_order_flag == 1) || (diff_order_flag == 2))
        {
            thedir = thedir%ndirs;
            if(count%LCD == 0)
            {
                thedir++;
            }
            thedir = thedir%ndirs;
        }
    }

    /* repeat for multi-b */
    if (nrep > 1)
    {
        for (n = 1; n < nrep; n++)
        {
            for (npass = 0; npass < ndirs; npass++)
            {
                for (nslice = 0; nslice < diff_order_nslices; nslice++)
                {
                    diff_order[noffset + n * ndirs + npass][nslice] = diff_order[noffset + npass + (n-1) * ndirs][nslice] + ndirs;
                }
            }
        }
    }

#ifndef IPG
    /* Debug info in diff_order.txt*/
    if(diff_order_debug)
    {
        if (NULL != (fp_diff_order = fopen(fname_difforder, "w")))
        {
            fprintf(fp_diff_order, "# ndirs, Slices\n");
            fprintf(fp_diff_order, "%d, %d\n", ndirs, diff_order_nslices);
            fprintf(fp_diff_order, "# opdfaxall, opdfax3in1, opdfaxtetra, optensor\n");
            fprintf(fp_diff_order, "%d, %d, %d, %d\n", opdfaxall, opdfax3in1, opdfaxtetra, optensor);

            for (npass = 0; npass < diff_order_size; npass++)
            {
                fprintf(fp_diff_order, "# Pass %d: \n", npass);
                for (nslice = 0; nslice < diff_order_nslices; nslice++)
                {
                    fprintf(fp_diff_order, "%d ", diff_order[npass][nslice]);
                }
                fprintf(fp_diff_order, "\n");

            }

            if (diff_order_flag == 2 && tensor_flag == PSD_OFF)
            {
                fprintf(fp_diff_order, "\n");
                fprintf(fp_diff_order, "diff_pass: ");

                for (npass = 0; npass < ndirs; npass++)
                {
                    fprintf(fp_diff_order, "%02d ", diff_order_pass[npass]);
                }

                fprintf(fp_diff_order, "\n");
                fprintf(fp_diff_order, "diff_nex:  ");

                for (npass = 0; npass < ndirs; npass++)
                {
                    fprintf(fp_diff_order, "%02d ", diff_order_nex[npass]);
                }

                fprintf(fp_diff_order, "\n");
                fprintf(fp_diff_order, "diff_dif:  ");

                for (npass = 0; npass < ndirs; npass++)
                {
                    fprintf(fp_diff_order, "%02d ", diff_order_dif[npass]);
                }
            }
            fclose(fp_diff_order);
        }
    }

    /* verify order */
    if (diff_order_verify == 1)
    {
        int *verify_diff = NULL;
        if((verify_diff = (int *) malloc(sizeof(int) * pass_reps)) == NULL)
        {
            return FAILURE;
        }

        for (nslice = 0; nslice < diff_order_nslices; nslice++)
        {
            memset(verify_diff, 0, sizeof(int) * pass_reps);

            sum_dir = 0;

            for (npass = 0; npass < pass_reps; npass++)
            {
                if(verify_diff[diff_order[npass][nslice]] == 1)
                {
                    return FAILURE;
                }
                else
                {
                    verify_diff[diff_order[npass][nslice]] = 1;
                }

                sum_dir += diff_order[npass][nslice];
            }

            if (sum_dir != pass_reps*(pass_reps - 1)/2)
            {
                return FAILURE;
            }
        }

        free(verify_diff);
    }

#endif
    return SUCCESS;
}

int getLCD(int a, int b)
{
    int x, y, r;

    x = a;
    y = b;
    r = a % b;

    while (r > 0)
    {
        x = y;
        y = r;
        r = x % y;
    }

    return a*b/y;
}

int get_diff_order(int pass, int slice)
{
    return diff_order[pass][slice];
}
