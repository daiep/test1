/*
 *  Copyright (C) 2017 The General Electric Company
 *
 *  Muse.e - Code to support Muse implementation
 *
 *  Language : EPIC
 *  Author   : Arnaud Guidon
 *  Date     : 27-Sept-16
 */
/* do not edit anything above this line */

/*
  Date         Author   Comments
  --------------------------------------------------------------------------
  27-Sep-16    AG       Original implementation
  15-Feb-17    AG       Rio Muse feature
  27-Jun-17    AG       HCSDM00466566 Address ringing issues in Muse images
  13-Mar-18    AG       HCSDM00453768 Open MUSE for all anatomies
*/


@global MuseGlobal
/* MuseGlobal  inlined from Muse.e */
#define MUSE_MIN_NSHOTS 2
#define MUSE_MAX_NSHOTS 8

@cv MuseCV
/* MuseCV  inlined from Muse.e */
int muse_flag = 0 with {0, 1, 0, VIS, "MUSE Multishot DWI, 0:OFF 1:ON",};
int muse_support = 0 with {0,1,0,VIS,"MUSE support flag: 0=not support, 1=support",};


@host MuseSetRhVars
/* MuseSetRhVars  inlined from Muse.e */
{
	if (muse_flag)
	{
		rhmuse = muse_flag;
		rhasset_torso =0; /*force this to 0 for MUSE in phase 1 promote*/
		rhferme = rhferme * exist(opnshots); /* HCSDM00466566 */
	}
	else
	{
		rhmuse = 0;
		/*don't force rhasset_torso if muse is off. let Asset.e set it*/
	}
}

@host MuseCVInit
/* MuseCVInit  inlined from Muse.e */
/* Determine if Muse feature is supported. Currently it is supported in Rio and DV systems*/
{
    if (isRioSystem() || isDVSystem() || (isKizunaSystem() && (B0_30000 == cffield)))
    {
        muse_support = PSD_ON;
    }
    else
    {
        muse_support = PSD_OFF;
    }

    if (PSD_ON == muse_support && PSD_ON == exist(opdiffuse))
    {
        cvmax(opmuse, PSD_ON);
    }

    if(PSD_ON == muse_support && PSD_ON == exist(opmuse))
    {
        muse_flag = PSD_ON;
    }
    else
    {
        muse_flag = PSD_OFF;
    }

    if (muse_flag==PSD_ON)
    {		
        piaccel_ph_stride = 1;
    }
}

@host MuseCVInitNumberOfShots
/* MuseCVInitNumberOfShots inlined from Muse.e */
{
	int i;

	/*set this to maximum number in cvinit & update it with coil related values in cveval(). 
	This is essential such that the parameters in the saved protocol will not be overwritten*/
    max_nshots = MUSE_MAX_NSHOTS;  
    min_nshots = MUSE_MIN_NSHOTS;

    cvdef(opnshots, min_nshots);
    cvmin(opnshots, min_nshots);
    cvmax(opnshots, max_nshots);

    opnshots = min_nshots;

	pishotnub = 1;
	for (i = 1; i < max_nshots; i++)
	{
		pishotnub += 1<<i;
	}

	if ( pishotnub >=63 )
		pishotnub = 63; /* maximum is 6 values */

	pishotval2 = 2;
	pishotval3 = 3;
	pishotval4 = 4;
	pishotval5 = 5;
	pishotval6 = max_nshots;
}   

@host MuseCVInitXYResUIOptions
/* MuseCVInitXYResUIOptions inlined from Muse.e */
{
    cvmax(opxres, 512);
    cvdef(opxres, 256);
    opxres = 192;

    cvmax(opyres,512);
    cvdef(opyres, 256);
    opyres = 192;

    pixresnub = 63; /* bitmask */
    pixresval2 = 128;
    pixresval3 = 192;
    pixresval4 = 256;
    pixresval5 = 384;
    pixresval6 = 512;

    piyresnub = 63;
    piyresval2 = 128;
    piyresval3 = 192;
    piyresval4 = 256;
    piyresval5 = 384;
    piyresval6 = 512;
}

@host MuseCvcheck
{

    if(rfov_flag == PSD_ON && muse_flag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "FOCUS" );
        return FAILURE;
    }

    if(mux_flag == PSD_ON && muse_flag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "Hyperband" );
        return FAILURE;
    }

    if(dualspinecho_flag == PSD_ON && muse_flag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "Dual Spin Echo" );
        return FAILURE;
    }

    if((opnumgroups > 1) && muse_flag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "multigroup prescription" );
        return FAILURE;
    }

    if((exist(opnshots) <= 1) && muse_flag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "MUSE", STRING_ARG, "single shot" );
        return FAILURE;
    }

}

@host MuseEval
/* Set default phase acceleration value for MUSE */
{
	int i;

	if ( muse_flag == PSD_ON)
	{
		if ( existcv(opaccel_ph_stride) )
		{
			 /* If user specified value, display it */
			 piaccel_ph_stride = opaccel_ph_stride;
		}
		else
		{
			/* Otherwise default to 1.0 */   
			piaccel_ph_stride = 1.0; 
		}

		max_nshots = (exist(opresearch) == PSD_ON)? MUSE_MAX_NSHOTS: (int)(ceil(avmaxaccel_ph_stride));

		cvmax(opnshots, max_nshots);

		pishotnub = 1;
		for (i = 1; i < max_nshots; i++)
		{
			pishotnub += 1<<i;
		}

		if ( pishotnub >=63 )
			pishotnub = 63; /* maximum is 6 values */

		pishotval2 = 2;
		pishotval3 = 3;
		pishotval4 = 4;
		pishotval5 = 5;
		pishotval6 = max_nshots;

	}
}
