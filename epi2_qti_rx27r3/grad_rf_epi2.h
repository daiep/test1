/* *************************************
 * grad_rf_data.h
 * This structure is used to track the 
 * rf heating, SAR heating, Grad coil heating,
 * grad amplifier heating.
 * ********************************** */

#include "sar_pm.h"

/* Global #defines are in grad_rf_memp.globals.h in @globals section */

RF_PULSE rfpulse[MAX_RFPULSE] = {
  /* RFPULSE 0 - Default SATX 1 Pulse */
  {(int *)&pw_rfsx1,
     (float *)&a_rfsx1, 
     SAR_ABS_SINC1,
     SAR_PSINC1,
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsx1,
     3200.0,
     1000.0,  /* Saturation, not excitation, bw */
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsx1,
     0,
     (int *)&wg_rfsx1,
     1},
  /* RFPULSE 1 - Default SATX 2 Pulse */
  {(int *)&pw_rfsx2,
     (float *)&a_rfsx2, 
     SAR_ABS_SINC1,
     SAR_PSINC1,
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsx2,
     3200.0,
     1000.0,  /* Saturation, not excitation, bw */
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsx2,
     0,
     (int *)&wg_rfsx2,
     1},
  /* RFPULSE 2 - Default SATY 1 Pulse */
  {(int *)&pw_rfsy1,
     (float *)&a_rfsy1, 
     SAR_ABS_SINC1,
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsy1,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsy1,
     0,
     (int *)&wg_rfsy1,
     1},
  /* RFPULSE 3 - Default SATY 2 Pulse */
  {(int *)&pw_rfsy2,
     (float *)&a_rfsy2, 
     SAR_ABS_SINC1,
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsy2,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsy2,
     0,
     (int *)&wg_rfsy2,
     1},
  /* RFPULSE 4 - Default SATZ 1 Pulse */
  {(int *)&pw_rfsz1, 
     (FLOAT *)&a_rfsz1, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsz1,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsz1,
     0,
     (int *)&wg_rfsz1,
     1},
  /* RFPULSE 5 - Default SATZ 2 Pulse */
  {(int *)&pw_rfsz2, 
     (FLOAT *)&a_rfsz2, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfsz2,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfsz2,
     0,
     (int *)&wg_rfsz2,
     1},
  /* RFPULSE 6 - Explicit SAT1 Pulse */
  {(int *)&pw_rfse1, 
     (FLOAT *)&a_rfse1, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse1,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse1,
     0,
     (int *)&wg_rfse1,
     1},
  /* RFPULSE 7 - Explicit SAT2 Pulse */
  {(int *)&pw_rfse2, 
     (FLOAT *)&a_rfse2, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse2,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse2,
     0,
     (int *)&wg_rfse2,
     1},
  /* RFPULSE 8 - Explicit SAT3 Pulse */
  {(int *)&pw_rfse3, 
     (FLOAT *)&a_rfse3, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse3,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse3,
     0,
     (int *)&wg_rfse3,
     1},
  /* RFPULSE 9 - Explicit SAT4 Pulse */
  {(int *)&pw_rfse4, 
     (FLOAT *)&a_rfse4, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse4,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse4,
     0,
     (int *)&wg_rfse4,
     1},
  /* RFPULSE 10 - Explicit SAT5 Pulse */
  {(int *)&pw_rfse5, 
     (FLOAT *)&a_rfse5, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse5,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse5,
     0,
     (int *)&wg_rfse5,
     1},
  /* RFPULSE 11 -Explicit SAT6 Pulse */
  {(int *)&pw_rfse6, 
     (FLOAT *)&a_rfse6, 
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfse6,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfse6,
     0,
     (int *)&wg_rfse6,
     1},
  /* RFPULSE 12 - ChemSat Pulse */
  {(int *)&pw_rfcssat,
     (FLOAT *)&a_rfcssat,
     SAR_ABS_SINC1, 
     SAR_PSINC1, 
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     0,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rfcssat,
     3200.0,
     1000.0,
     PSD_PULSE_OFF,
     0,
     0,
     1.0,
     (int *)&res_rfcssat,
     0,
     (int *)&wg_rfcssat,
     1},
  /* RFPULSE 13 - RF1 Pulse */
  {(int *)&pw_rf1,
     (FLOAT *)&a_rf1, 
     SAR_ABS_SINC1,
     SAR_PSINC1,
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     1,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rf1,
     3200.0,
     1250.0,
     PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON,
     0,
     0,
     1.0,
     (int *)&res_rf1,
     0,
     (int *)&wg_rf1,
     1},
  /* RFPULSE 14 - RF2 Pulse */
  {(int *)&pw_rf2,
     (FLOAT *)&a_rf2, 
     SAR_ABS_SINC1,
     SAR_PSINC1,
     SAR_ASINC1,
     SAR_DTYCYC_SINC1,
     SAR_MAXPW_SINC1,
     1,
     MAX_B1_SINC1_90,
     MAX_INT_B1_SQ_SINC1_90,
     MAX_RMS_B1_SINC1_90,
     90.0,
     &flip_rf2,
     3200.0,
     1250.0,
     PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON,
     1,
     0,
     1.0,
     (int *)&res_rf2,
     0,
     (int *)&wg_rf2,
     1},
  /* RFPULSE 15 - RF0 Pulse */
  {(int *)&pw_rf0,
     (FLOAT *)&a_rf0,
     SAR_ABS_INVI0,
     SAR_PINVI0,
     SAR_AINVI0,
     SAR_DTYCYC_INVI0,
     SAR_MAXPW_INVI0,
     0,
     MAX_B1_INVI0_180,
     MAX_INT_B1_SQ_INVI0_180,
     MAX_RMS_B1_INVI0_180,
     178.0,
     &flip_rf0,
     5000.0,
     NOM_BW_INVI0,
     PSD_PULSE_OFF,
     0, 
     0, 
     0,
     (int *)&res_rf0,
     0,
     (int *)&wg_rf0,
     1},
     
  /* RFPULSE 16 - rfwk for FOCUS walking sat  */
  {(int *)&pw_rfwk,
     (FLOAT *)&a_rfwk,
     SAR_ABSWIDTH_RFWK,
     SAR_EFFWIDTH_RFWK,
     SAR_AREA_RFWK,
     SAR_DTYCYC_RFWK,
     SAR_MAXPW_RFWK,
     1,
     SAR_MAX_B1_RFWK,
     SAR_MAX_INT_B1_SQ_RFWK,
     SAR_MAX_RMS_B1_RFWK,
     SAR_NOM_FA_RFWK,
     &flip_rfwk,
     SAR_NOM_PW_RFWK,
     SAR_NOM_BW_RFWK,
     PSD_PULSE_OFF,
     0, 
     0, 
     1,
     (int *)&res_rfwk,
     0,
     (int *)&wg_rfwk,
     1},     

#include "rf_navmonitor.h"
#include "rf_Prescan.h"
};


GRAD_PULSE gradx[MAX_GRADX] = { 
  /* GRADX 0 - Default X SAT 1 slice select */
  {G_TRAP,                /* pulse type */
     (int *)&pw_gxrfsx1a, /* attack */
     (int *)&pw_gxrfsx1d, /* decay */
     (int *)&pw_gxrfsx1,  /* pw */
     (FLOAT *)NULL,       /* amps */
     (FLOAT *)&a_gxrfsx1, /* amp */
     (FLOAT *)NULL,       /* ampd */
     (FLOAT *)NULL,       /* ampe */
     (char *)NULL,        /* gradfile */
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */ 
  /* GRADX 1 - Default X SAT 2 slice select */
  {G_TRAP, 
     (int *)&pw_gxrfsx2a, 
     (int *)&pw_gxrfsx2d, 
     (int *)&pw_gxrfsx2,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gxrfsx2,
     (FLOAT *)NULL,
     (FLOAT *)NULL, 
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 2 - GX1 dephaser */
  {G_TRAP,
     (int *)&pw_gx1a, 
     (int *)&pw_gx1d,
     (int *)&pw_gx1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gx1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 3 - Positive Polarity Readout */
  {G_TRAP,                  /* Really a ramp-const-ramp, not trap */
     (int *)&pw_gxwad, 
     (int *)&pw_gxwad,
     (int *)&pw_gxw_total,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxw,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 4 - Negative Polarity Readout */
  {G_TRAP,                  /* Really a ramp-const-ramp, not trap */
     (int *)&pw_gxwad, 
     (int *)&pw_gxwad,
     (int *)&pw_gxw_total,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxw,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 5 - Killer Pulse */
  {G_TRAP,
     (int *)&pw_gxka, 
     (int *)&pw_gxkd,
     (int *)&pw_gxk,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxk,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 6 - Left Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gxdla, 
     (int *)&pw_gxdld,
     (int *)&pw_gxdl,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxdl,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADX 7 - Right Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gxdra, 
     (int *)&pw_gxdrd,
     (int *)&pw_gxdr,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxdr,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
     
  /* GRADX 8 - Walk sat X spoiler */
  {G_TRAP,
     (int *)&pw_gxwkspa,
     (int *)&pw_gxwkspd,
     (int *)&pw_gxwksp,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxwksp, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */

  /* GRADX 9 - dynamicn PC pre-phaser */
  {G_TRAP,
     (int *)&pw_gxiref1a,
     (int *)&pw_gxiref1d,
     (int *)&pw_gxiref1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxiref1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */

  /* GRADX 10 - dynamicn PC re-winder */
  {G_TRAP,
     (int *)&pw_gxirefra,
     (int *)&pw_gxirefrd,
     (int *)&pw_gxirefr,
     (FLOAT *)NULL,
     (FLOAT *)&a_gxirefr,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0}                 /* SGD */
};
 
GRAD_PULSE grady[MAX_GRADY] = { 
  /* GRADY 0 - Default Slice Select for Y Sat 1 */
  {G_TRAP,
     (int *)&pw_gyrfsy1a, 
     (int *)&pw_gyrfsy1d, 
     (int *)&pw_gyrfsy1,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gyrfsy1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 1 - Default Slice Select for Y Sat 2 */
  {G_TRAP,
     (int *)&pw_gyrfsy2a, 
     (int *)&pw_gyrfsy2d, 
     (int *)&pw_gyrfsy2,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gyrfsy2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 2 -Killer for explicit Sat 1 */
  {G_TRAP,
     (int *)&pw_gykse1a,
     (int *)&pw_gykse1d,
     (int *)&pw_gykse1,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gykse1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 3 - Killer for explicit Sat 2 */
  {G_TRAP,
     (int *)&pw_gykse2a,
     (int *)&pw_gykse2d, 
     (int *)&pw_gykse2,
     (FLOAT *)NULL,
     (FLOAT *)&a_gykse2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 4 - Killer for explicit Sat 3 */
  {G_TRAP,
     (int *)&pw_gykse3a,
     (int *)&pw_gykse3d,
     (int *)&pw_gykse3, 
     (FLOAT *)NULL,
     (FLOAT *)&a_gykse3,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 5 - Killer for explicit Sat 4 */
  {G_TRAP,
     (int *)&pw_gykse4a,
     (int *)&pw_gykse4d,
     (int *)&pw_gykse4,
     (FLOAT *)NULL,
     (FLOAT *)&a_gykse4,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                  /* bridge */
     0.0},                /* SGD */
  /* GRADY 6 - Killer for explicit Sat 5 */
  {G_TRAP,
     (int *)&pw_gykse5a,
     (int *)&pw_gykse5d,
     (int *)&pw_gykse5,
     (FLOAT *)NULL,
     (FLOAT *)&a_gykse5,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 7 - Killer for explicit Sat 6 */
  {G_TRAP,
     (int *)&pw_gykse6a,
     (int *)&pw_gykse6d,
     (int *)&pw_gykse6,
     (FLOAT *)NULL,
     (FLOAT *)&a_gykse6,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 8 -Killer for X Sat 1 */
  {G_TRAP,
     (int *)&pw_gyksx1a,
     (int *)&pw_gyksx1d,
     (int *)&pw_gyksx1,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gyksx1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 9 -Killer for X Sat 2 */
  {G_TRAP,
     (int *)&pw_gyksx2a,
     (int *)&pw_gyksx2d,
     (int *)&pw_gyksx2,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gyksx2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 10 - Killer for Y Sat 1 */
  {G_TRAP,
     (int *)&pw_gyksy1a,
     (int *)&pw_gyksy1d, 
     (int *)&pw_gyksy1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyksy1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                  /* bridge */
     0.0},                /* SGD */
  /* GRADY 11 - Killer for Y Sat 2 */
  {G_TRAP,
     (int *)&pw_gyksy2a,
     (int *)&pw_gyksy2d, 
     (int *)&pw_gyksy2,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyksy2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 12 - Killer for Z Sat 1 */
  {G_TRAP,
     (int *)&pw_gyksz1a,
     (int *)&pw_gyksz1d,
     (int *)&pw_gyksz1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyksz1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 13 - Killer for Z Sat 2 */
  {G_TRAP,
     (int *)&pw_gyksz2a,
     (int *)&pw_gyksz2d,
     (int *)&pw_gyksz2,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyksz2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 14 - Phase Encodes and Rewinder */
  {G_TRAP,
     (int *)&pw_gy1a,
     (int *)&pw_gy1, 
     (int *)&pw_gy1d,
     (FLOAT *)NULL,
     (FLOAT *)&a_gy1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */ 
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 15 - Phase Encoding Blips */
  {G_TRAP,
     (int *)&pw_gyba, 
     (int *)&pw_gybd,
     (int *)&pw_gyb,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyb,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 16 - Killer Pulse */
  {G_TRAP,
     (int *)&pw_gyka, 
     (int *)&pw_gykd,
     (int *)&pw_gyk,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyk,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 17 - Chem Sat Killer */
  {G_TRAP, 
     (int *)&pw_gykcsa, 
     (int *)&pw_gykcsd,
     (int *)&pw_gykcs,
     (FLOAT *)NULL,
     (FLOAT *)&a_gykcs,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 18 - 180 slice select for inner volume*/
  {G_TRAP,
     (int *)&pw_gyrf2iva,
     (int *)&pw_gyrf2ivd,
     (int *)&pw_gyrf2iv,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyrf2iv,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 19 - Killer for IR */
  {G_TRAP,
     (int *)&pw_gyk0a,
     (int *)&pw_gyk0d,
     (int *)&pw_gyk0,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyk0,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,
     1.0,
     (int *)NULL,
     0,
     0.0,
     0.0,
     0.0,
     0.0,
     0.0,
     0.0,
     0,
     0,
     0.0},                /* SGD */
  /* GRADY 20 - Left Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gydla, 
     (int *)&pw_gydld,
     (int *)&pw_gydl,
     (FLOAT *)NULL,
     (FLOAT *)&a_gydl,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 21 - Right Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gydra, 
     (int *)&pw_gydrd,
     (int *)&pw_gydr,
     (FLOAT *)NULL,
     (FLOAT *)&a_gydr,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 22 - RFOV excitation */
  {G_TRAP,
     (int *)&pw_gyrf1a,
     (int *)&pw_gyrf1d,
     (int *)&pw_gyrf1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyrf1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 23 - RFOV y refocusing gradient */
  {G_TRAP,
     (int *)&pw_gyex1a,
     (int *)&pw_gyex1d,
     (int *)&pw_gyex1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyex1, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
     
  /* GRADY 24 - Walk sat slice select grad */
  {G_TRAP,
     (int *)&pw_gyrfwka,
     (int *)&pw_gyrfwkd,
     (int *)&pw_gyrfwk,
     (FLOAT *)NULL,
     (FLOAT *)&a_gyrfwk, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 25 - Walk sat Y spoiler */
  {G_TRAP,
     (int *)&pw_gywkspa,
     (int *)&pw_gywkspd,
     (int *)&pw_gywksp,
     (FLOAT *)NULL,
     (FLOAT *)&a_gywksp, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0}                 /* SGD */     
     
  };

GRAD_PULSE gradz[MAX_GRADZ] = { 
  /* GRADZ 0 - Default Slice Select for Z Sat 1 */
  {G_TRAP, (int *)&pw_gzrfsz1a, 
     (int *)&pw_gzrfsz1d,
     (int *)&pw_gzrfsz1, 
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrfsz1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 1 - Default Slice Select for Z Sat 2 */
  {G_TRAP, (int *)&pw_gzrfsz2a, 
     (int *)&pw_gzrfsz2d,
     (int *)&pw_gzrfsz2,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gzrfsz2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 2 - Slice Select for Explicit Sat 1 */
  {G_TRAP, (int *)&pw_gzrfse1a, 
     (int *)&pw_gzrfse1d,
     (int *)&pw_gzrfse1,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gzrfse1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 3 - Slice Select for Explicit Sat 2 */
  {G_TRAP, (int *)&pw_gzrfse2a, 
     (int *)&pw_gzrfse2d,
     (int *)&pw_gzrfse2,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gzrfse2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 4 - Slice Select for Explicit Sat 3 */
  {G_TRAP, (int *)&pw_gzrfse3a, 
     (int *)&pw_gzrfse3d,
     (int *)&pw_gzrfse3, 
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrfse3,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 5 - Slice Select for Explicit Sat 4 */
  {G_TRAP, (int *)&pw_gzrfse4a, 
     (int *)&pw_gzrfse4d,
     (int *)&pw_gzrfse4,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gzrfse4,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 6 - Slice Select for Explicit Sat 5 */
  {G_TRAP, (int *)&pw_gzrfse5a, 
     (int *)&pw_gzrfse5d,
     (int *)&pw_gzrfse5,
     (FLOAT *)NULL, 
     (FLOAT *)&a_gzrfse5,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 7 - Slice Select for Explicit Sat 6 */
  {G_TRAP, (int *)&pw_gzrfse6a, 
     (int *)&pw_gzrfse6d,
     (int *)&pw_gzrfse6, 
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrfse6,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL, 
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 8 - 90 Slice Select  */
  {G_TRAP, 
     (int *)&pw_gzrf1a, 
     (int *)&pw_gzrf1d, 
     (int *)&pw_gzrf1, 
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrf1, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 9 - Left Crusher for Echo 1 */
  {G_TRAP,                /* pulse type */
     (int *)&pw_gzrf2l1a, /* attack */
     (int *)&pw_gzrf2l1d, /* decay */
     (int *)&pw_gzrf2l1,  /* pw */
     (FLOAT *)&psd_zero,  /* amps */
     (FLOAT *)&a_gzrf2l1, /* amp */
     (FLOAT *)&a_gzrf2l1, /* ampd */
     (FLOAT *)&a_gzrf2,   /* ampe */
     (char *)NULL,        /* gradfile */
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     1,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 10 - Right Crusher for Echo 1 */
  {G_TRAP,                /* pulse type */
     (int *)&pw_gzrf2r1a, /* attack */
     (int *)&pw_gzrf2r1d, /* decay */
     (int *)&pw_gzrf2r1,  /* pw */
     (FLOAT *)&a_gzrf2,   /* amps */
     (FLOAT *)&a_gzrf2r1, /* amp */
     (FLOAT *)&a_gzrf2r1, /* ampd */
     (FLOAT *)&psd_zero,  /* ampe */
     (char *)NULL,        /* gradfile */
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     1,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 11 - 180 slice select */
  {G_TRAP,
     (int *)&pw_gzrf2a,
     (int *)&pw_gzrf2d,
     (int *)&pw_gzrf2,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrf2,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     2,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 12 - Killer Pulse */
  {G_TRAP,
     (int *)&pw_gzka, 
     (int *)&pw_gzkd,
     (int *)&pw_gzk,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzk,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 13 - 180 slice select for IR */
  {G_TRAP,
     (int *)&pw_gzrf0a,
     (int *)&pw_gzrf0d,
     (int *)&pw_gzrf0,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzrf0,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,
     1.0,
     (int *)NULL,
     0,
     0.0,
     0.0,
     0.0,
     0.0,
     0.0,
     0.0,
     0,
     0,
     0.0},                /* SGD */
  /* GRADZ 14 - refocusing gradient lobe */
  {G_TRAP,
     (int *)&pw_gz1a,
     (int *)&pw_gz1d,
     (int *)&pw_gz1,
     (FLOAT *)NULL,
     (FLOAT *)&a_gz1,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADZ 15 - gradient lobe for flow compensation */
  {G_TRAP,
     (int *)&pw_gzmna,
     (int *)&pw_gzmnd,
     (int *)&pw_gzmn,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzmn,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0},                /* SGD */
  /* GRADY 16 - Left Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gzdla, 
     (int *)&pw_gzdld,
     (int *)&pw_gzdl,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzdl,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                  /* bridge */
     0.0},                /* SGD */
  /* GRADY 17 - Right Diffusion Pulse */
  {G_TRAP,
     (int *)&pw_gzdra, 
     (int *)&pw_gzdrd,
     (int *)&pw_gzdr,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzdr,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */   
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */ 
     0.0},                /* SGD */
  /* GRADZ 18 - gradient blips for slice fov shift */
 {G_TRAP,
     (int *)&pw_gzba,
     (int *)&pw_gzbd,
     (int *)&pw_gzb,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzb,
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     1,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
         0.0,                 /* tdelta */
         1.0,                 /* powscale */
         0.0,                 /* power */
         0.0,                 /* powpos */
         0.0,                 /* powneg */
         0.0,                 /* powabs */
         0.0,                 /* amptran */
         0,                   /* pwm time */
         0,                   /* bridge */
         0.0},                  /* SGD */
     
  /* GRADZ 19 - Walk sat Z spoiler */
  {G_TRAP,
     (int *)&pw_gzwkspa,
     (int *)&pw_gzwkspd,
     (int *)&pw_gzwksp,
     (FLOAT *)NULL,
     (FLOAT *)&a_gzwksp, 
     (FLOAT *)NULL,
     (FLOAT *)NULL,
     (char *)NULL,
     0,                   /* num */
     1.0,                 /* scale */
     (int *)NULL,         /* time */
     0.0,                 /* tdelta */
     1.0,                 /* powscale */
     0.0,                 /* power */
     0.0,                 /* powpos */
     0.0,                 /* powneg */
     0.0,                 /* powabs */
     0.0,                 /* amptran */
     0,                   /* pwm time */
     0,                   /* bridge */
     0.0}                 /* SGD */     
 };


    


