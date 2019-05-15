/*
 *  GE Medical Systems
 *  Copyright (C) 1997 The General Electric Company
 *  
 *  epiMaxwellCorrection.e
 *  
 *  Contains maxwell correction code for axial EPI scans
 *  
 *  Language : ANSI C
 *  Author   : Bryan Mock
 *  Date     : 5/10/01
 */
/* do not edit anything above this line */

@cv epiMaxwellCV

/* BJM - added Maxwell compensation phase encode also */
int maxwell_flag = PSD_ON;    /* user variable for turning on maxwell correction (read) */	
int maxwell_blip = PSD_ON;    /* user variable for turning on maxwell correction (phase) */	
float B0_field;         /* B0 field in Gauss */
float pw_gxw_MAX_l;     /* total Maxwell timing for the left half of trapezoid */
float pw_gxw_MAX_r;     /* total Maxwell timing for the right half of trapezoid */
float pw_gyb_MAX_l;     /* total Maxwell timing for the left half of phase trapezoid */
float pw_gyb_MAX_r;     /* total Maxwell timing for the right half phase trapezoid */
int max_debug=0;        /* print flag  */

@rsp epiMaxwellCorrection

/* MRIge54172 - maxwell correction */
float delta_fre_MAX[SLTAB_MAX]; /* Maxwell frequency offset */ /* YMSmr06515 */
float delta_phase_MAX_l[SLTAB_MAX]; /* Maxwell phase offset for thefirst echo */
float delta_phase_MAX[SLTAB_MAX]; /* Maxwell phase offset for all echoes */

/* Function Declaration */
STATUS epiMaxwellCorrection(void);

/* BJM - correct receiver phase to account for maxwell terms - see Tech Note by Joe Zhou 97-08    */
/*       Most of this code taken from epi2.e.  However, Ive added the phase encode blip term and  */
/*       and removed the g2z2_delta factor which was an empirical test factor for the phase blips */
/*       It was set = 2.0 which was way too large since the phase blip contribution is small      */

STATUS epiMaxwellCorrection(void) {
 
  int ii, jj, kk;  /* Maxwell comp: index to set the receiver frequency array */
  
  if((maxwell_flag==PSD_ON)&&(opplane==PSD_AXIAL)&&((rspent==L_SCAN) || (rspent==L_REF))) {
      
      float Gx2 = 0.0;                    /* readout gradient squared */
      float Gy2 = 0.0;                    /* phase gradient squared */
      float Z2 = 0.0;                     /* z location squared */
      float field_fact = 0.0;             /* constant term that includes B field */
      float mxwtmp1,mxwtmp2;
      float mxwtmp_gxw1,mxwtmp_gxw2;      /* tmp variables for maxwell offset computation */
      float mxwtmp_gyb1,mxwtmp_gyb2;
      
      /* BJM: readout gradient timing */
      pw_gxw_MAX_l = (1.0/3.0*(float)pw_gxwad+0.5*(float)pw_gxw+(float)pw_gxwl)/1.0e6;
      /* timing for the left half of readout trapezoid; unit: sec. */
      pw_gxw_MAX_r = (1.0/3.0*(float)pw_gxwad+0.5*(float)pw_gxw+(float)pw_gxwr)/1.0e6;
      /* timing for the right half of readout trapezoid; unit: sec. */
      
      /* BJM: account for phase blips also */
      pw_gyb_MAX_l = (1.0/3.0*(float)pw_gyba+0.5*(float)pw_gyb)/1.0e6;
      /* timing for the left half of phase trapezoid; unit: sec. */
      pw_gyb_MAX_r = (1.0/3.0*(float)pw_gybd+0.5*(float)pw_gyb)/1.0e6;
      /* timing for the right half of phase trapezoid; unit: sec. */
      
      if(max_debug==1)
          printf("left Maxwell width = %f s\nright Maxwell width = %f s\n", 
                 pw_gxw_MAX_l, pw_gxw_MAX_r);
      
      field_fact = 2.0*PI*GAM/(2.0*B0_field);      /* Field dependance */
      Gx2 =a_gxw*a_gxw/100.0;                      /* Readout Gx^2 term */
      mxwtmp_gxw1 = pw_gxw_MAX_l;
      mxwtmp_gxw2 = (pw_gxw_MAX_l+pw_gxw_MAX_r);
      
      Gy2 = a_gyb*a_gyb/100.0;                   /* Phase encode term */
      mxwtmp_gyb1 = pw_gyb_MAX_l;
      mxwtmp_gyb2 = (pw_gyb_MAX_r+pw_gyb_MAX_l);
      
      for (kk=0; kk<opslquant; kk++) {
          
          Z2 = rsp_info[kk].rsptloc*rsp_info[kk].rsptloc;  
          
          /* BJM: this code accounts for the readout term */       
          delta_fre_MAX[kk] = field_fact*Gx2*Z2;           /* purely for debugging */
          delta_phase_MAX_l[kk] = field_fact*Gx2*Z2*(mxwtmp_gxw1);    /* unit: radians */
          delta_phase_MAX[kk] = field_fact*Gx2*Z2*(mxwtmp_gxw2);      /* unit: radians */
          
          if(max_debug==1) /* readout comp. */
              printf("%d freq offset: %f phase: %f loc: %f  \n",
                     kk,delta_fre_MAX[kk],delta_phase_MAX[kk],rsp_info[kk].rsptloc);
          
          if(maxwell_blip == PSD_ON) {
              /* BJM: now account for the phase encode blips... */

              delta_phase_MAX_l[kk] += field_fact*Gy2*Z2*(mxwtmp_gyb1);    /* unit: radians */
              delta_phase_MAX[kk] += field_fact*Gy2*Z2*(mxwtmp_gyb2);      /* unit: radians */
              
              if(max_debug==1) /* phase comp */ 
                  printf("%d phase w/ blip: %f loc: %f  \n",
                         kk,delta_phase_MAX[kk],rsp_info[kk].rsptloc);
          }
          
      } /* end opslquant loop */ 
      
      /* Now loop over each slice, echo, etc and reset the receiver phase */
      for (ii=0; ii<opslquant; ii++) {

          mxwtmp1=((double)(delta_phase_MAX_l[ii]));   /* The constant phase term -> BJM: not really needed*/
          mxwtmp2=((double)(delta_phase_MAX[ii]));     /* Phase term accumlates with each echo */

          for(jj=0; jj<intleaves; jj++) {
              for(kk=0; kk<etl+iref_etl; kk++) {

                  if(kk < iref_etl) continue; /* interref echo is apart from normal echo train */
                  recv_phase_angle[ii][jj][kk] += (mxwtmp1 + mxwtmp2*(float)(kk-iref_etl));
                  recv_phase[ii][jj][kk] = calciphase(recv_phase_angle[ii][jj][kk]);

                  if(max_debug==1)
                      printf("%d freq offset: %d \n",kk, recv_freq[ii][jj][kk]);             

              } /* echo */

          } /* interleave */

      } /* slice */

  } /* end Maxwell compensation */
  
  return SUCCESS;
} 
