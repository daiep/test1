@host AllSupportedIopts
#include <psdiopt.h>
int sequence_iopts[] = {
    PSD_IOPT_ARC,
    PSD_IOPT_CARD_GATE,
    PSD_IOPT_FLOW_COMP,
    PSD_IOPT_SEQUENTIAL,
    PSD_IOPT_MPH,
    PSD_IOPT_SQR_PIX,
    PSD_IOPT_ASSET,
    PSD_IOPT_DYNPL,
    PSD_IOPT_MILDNOTE,
    PSD_IOPT_IR_PREP,
    PSD_IOPT_RESP_TRIG,
    PSD_IOPT_NAV,
    PSD_IOPT_EDR,
    PSD_IOPT_MULTIBAND,
    PSD_IOPT_CLASSIC
};

typedef enum feature_bits {
    DWI_E,
    FLAIR_E
} feature_bit_e;

#define DWI (long)(1 << DWI_E)
#define FLAIR (long)(1 << FLAIR_E)

long feature_flag = 0;

@host ImagingOptionFunctions
void
psd_init_iopts( void )
{
    int numopts = sizeof(sequence_iopts) / sizeof(int);

    psd_init_iopt_activity();

    activate_iopt_list( numopts, sequence_iopts );
    enable_iopt_list( numopts, sequence_iopts );

    set_incompatible( PSD_IOPT_CARD_GATE, PSD_IOPT_MPH );
    set_incompatible( PSD_IOPT_CARD_GATE, PSD_IOPT_DYNPL );
    set_incompatible( PSD_IOPT_MPH, PSD_IOPT_DYNPL );
    set_incompatible( PSD_IOPT_CARD_GATE, PSD_IOPT_RESP_TRIG );
    set_incompatible( PSD_IOPT_SEQUENTIAL, PSD_IOPT_RESP_TRIG );
    set_incompatible( PSD_IOPT_DYNPL, PSD_IOPT_RESP_TRIG );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_CARD_GATE );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_DYNPL );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_MPH );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_RESP_TRIG );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_SEQUENTIAL );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_MILDNOTE );
    set_incompatible( PSD_IOPT_ASSET, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_IR_PREP, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_CARD_GATE, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_RESP_TRIG, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_NAV, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_FLOW_COMP, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_SQR_PIX, PSD_IOPT_MULTIBAND );
    set_incompatible( PSD_IOPT_SEQUENTIAL, PSD_IOPT_MULTIBAND );
    return;
}

STATUS
cvsetfeatures( void )
{
    feature_flag = 0;

    if( (exist(opdiffuse) == PSD_ON) && existcv(opdiffuse) )
    {
        feature_flag |= DWI;
    }

    if( (exist(opflair) == PSD_ON) && existcv(opflair) )
    {
        feature_flag |= FLAIR;
    }

    return SUCCESS;
}

STATUS
cvfeatureiopts( void )
{
    psd_init_iopts();

    if( feature_flag & DWI )
    {
        set_disallowed_option( PSD_IOPT_FLOW_COMP );

        if(tensor_flag == PSD_ON)
        {
            set_disallowed_option( PSD_IOPT_DYNPL );
            set_disallowed_option( PSD_IOPT_RESP_TRIG );
            set_disallowed_option( PSD_IOPT_IR_PREP );
            set_disallowed_option( PSD_IOPT_NAV );
        }

        /* HCSDM00150820 */
        if(rfov_flag)
        {
            set_disallowed_option( PSD_IOPT_ASSET );
            set_disallowed_option( PSD_IOPT_MULTIBAND );
        }

        /* HCSDM00445759 */
        if(opmuse)
        {
            set_required_disabled_option( PSD_IOPT_ASSET );
            set_disallowed_option( PSD_IOPT_MULTIBAND );
            set_disallowed_option( PSD_IOPT_IR_PREP);
        }

        if(exist(opmb))
        {
            set_required_disabled_option( PSD_IOPT_ARC );
            set_required_disabled_option( PSD_IOPT_CLASSIC ); /* always use this to help on FatSat for Multiband*/
        }
        else
        {
            set_disallowed_option( PSD_IOPT_ARC );
            enable_ioption( PSD_IOPT_CLASSIC );
        }

        if(rfov_flag && (!dualspinecho_flag) && (!is_iopt_selected(PSD_IOPT_MULTIBAND)))
        {
            set_disallowed_option( PSD_IOPT_CLASSIC );
        }

        deactivate_ioption( PSD_IOPT_MPH );
        if(!value_system_flag){
            deactivate_ioption( PSD_IOPT_DYNPL );
        }

        if(aspir_flag)
        {
            set_disallowed_option( PSD_IOPT_IR_PREP );
        }
    }

    if( feature_flag & FLAIR )
    {
        set_disallowed_option( PSD_IOPT_SEQUENTIAL );
        if(!value_system_flag){
            set_disallowed_option( PSD_IOPT_ASSET );
        }
        /* MRIhc07638 / MRIhc07639 */
        set_disallowed_option( PSD_IOPT_CARD_GATE );
        set_disallowed_option( PSD_IOPT_IR_PREP );
        set_disallowed_option( PSD_IOPT_RESP_TRIG );
        set_disallowed_option( PSD_IOPT_NAV );
        deactivate_ioption( PSD_IOPT_ARC );
        deactivate_ioption( PSD_IOPT_MULTIBAND );
        deactivate_ioption( PSD_IOPT_CLASSIC );
    }

    if(checkOptionKey( SOK_MPHVAR )){
        deactivate_ioption( PSD_IOPT_DYNPL );
    }

    if(checkOptionKey( SOK_BODYNAV )){
        deactivate_ioption( PSD_IOPT_NAV );
    }

    if(!mild_note_support){
        deactivate_ioption( PSD_IOPT_MILDNOTE );
    }

    if((irprep_support == PSD_OFF) || !(feature_flag & DWI))
    {
        deactivate_ioption( PSD_IOPT_IR_PREP );
    }

    if(!(feature_flag & DWI))
    {
        deactivate_ioption( PSD_IOPT_RESP_TRIG ); 
        deactivate_ioption( PSD_IOPT_NAV );
    }

    if( (val15_lock == PSD_ON) &&  
        (!strcmp( coilInfo[0].coilName, "GE_HDx 8NVARRAY_A") ||
         !strcmp( coilInfo[0].coilName, "GE_HDx 8NVANGIO_A"))) 
    {
        disable_ioption( PSD_IOPT_ASSET );
    }

    if(edr_support == PSD_OFF)
    {
        deactivate_ioption( PSD_IOPT_EDR );
    }

    if(checkOptionKey( SOK_HYPERBAND ))
    {
        deactivate_ioption( PSD_IOPT_MULTIBAND );
    }

    if(B0_15000 >= cffield)
    {
        deactivate_ioption( PSD_IOPT_CLASSIC );
    }

    return SUCCESS;
}

STATUS
cvevaliopts( void )
{
    return SUCCESS;
}
