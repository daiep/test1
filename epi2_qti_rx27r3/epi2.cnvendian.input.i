typedef int ptrdiff_t;
typedef unsigned int size_t;
typedef int wchar_t;
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;
__extension__
typedef long long int int64_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
__extension__
typedef unsigned long long int uint64_t;
typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef int int_least32_t;
__extension__
typedef long long int int_least64_t;
typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;
__extension__
typedef unsigned long long int uint_least64_t;
typedef signed char int_fast8_t;
typedef int int_fast16_t;
typedef int int_fast32_t;
__extension__
typedef long long int int_fast64_t;
typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
__extension__
typedef unsigned long long int uint_fast64_t;
typedef int intptr_t;
typedef unsigned int uintptr_t;
__extension__
typedef long long int intmax_t;
__extension__
typedef unsigned long long int uintmax_t;
typedef char s8;
typedef unsigned char n8;
typedef int16_t s16;
typedef uint16_t n16;
typedef long s32;
typedef unsigned long n32;
typedef int64_t s64;
typedef uint64_t n64;
typedef float f32;
typedef double f64;
struct EXT_CERD_PARAMS
{
  s32 alg;
  s32 demod;
} ;
typedef struct {
  f64 filfrq;
  struct EXT_CERD_PARAMS cerd;
  s32 taps;
  s32 outputs;
  s32 prefills;
  s32 filter_slot;
} PSD_FILTER_GEN;
enum
{
    COIL_CONNECTOR_A,
    COIL_CONNECTOR_P1,
    COIL_CONNECTOR_P2,
    COIL_CONNECTOR_P3,
    COIL_CONNECTOR_P4,
    COIL_CONNECTOR_P5,
    NUM_COIL_CONNECTORS,
    NUM_COIL_CONNECTORS_PADDED = 8,
    COIL_CONNECTOR_PORT0 = COIL_CONNECTOR_A,
    COIL_CONNECTOR_PORT1 = COIL_CONNECTOR_P1,
    COIL_CONNECTOR_PORT2 = COIL_CONNECTOR_P2,
    COIL_CONNECTOR_PORT3 = COIL_CONNECTOR_P3,
    COIL_CONNECTOR_PORT4 = COIL_CONNECTOR_P4,
    COIL_CONNECTOR_PORT5 = COIL_CONNECTOR_P5,
    COIL_CONNECTOR_MCRV = NUM_COIL_CONNECTORS,
    NUM_COIL_CONNECTORS_INC_MCRV = NUM_COIL_CONNECTORS + 1
};
enum
{
    COIL_CONNECTOR_MNS_LEGACY_TOP,
    COIL_CONNECTOR_C_LEGACY_BOTTOM,
    COIL_CONNECTOR_PORT_A,
    COIL_CONNECTOR_PORT_B,
    NUM_COIL_CONNECTORS_PRE_HDV
};
enum
{
    COIL_STATE_UNKNOWN,
    COIL_STATE_DISCONNECTED,
    COIL_STATE_CONNECTED,
    COIL_STATE_ID,
    COIL_STATE_COMPLETE,
    NUM_COIL_STATES
};
enum
{
    COIL_INVALID,
    COIL_VALID,
    NUM_COIL_VALID_VALUES
};
enum
{
    COIL_TYPE_TRANSMIT,
    COIL_TYPE_RECEIVE,
    NUM_COIL_TYPE_VALUES
};
enum
{
    BODY_TRANSMIT_DISABLE,
    BODY_TRANSMIT_ENABLE,
    NUM_BODY_TRANSMIT_ENABLE_VALUES
};
enum
{
    TRANSMIT_SELECT_NONE,
    TRANSMIT_SELECT_A,
    TRANSMIT_SELECT_P1,
    TRANSMIT_SELECT_LEGACY_HEAD,
    TRANSMIT_SELECT_LEGACY_MC,
    TRANSMIT_SELECT_1MNS,
    NUM_TRANSMIT_SELECTS
};
enum
{
    MNS_CONVERTER_SELECT_NONE = 0x00000000,
    MNS_CONVERTER_SELECT_A = 0x00000001,
    MNS_CONVERTER_SELECT_MASK = 0x00000001,
};
enum
{
    COIL_ID_TYPE_REQUIRED = 0,
    COIL_ID_TYPE_PRESENCE_ONLY = 1,
    COIL_ID_TYPE_NOT_REQUIRED = 2,
    NUM_COIL_ID_TYPES
};
enum
{
    COIL_INT_FAULT_CHECK_UNSUPPORTED,
    COIL_INT_FAULT_CHECK_SUPPORTED,
    NUM_COIL_INT_FAULT_CHECK_TYPES
};
typedef struct
{
    n32 receiverID;
    n32 connectorStartCh;
    n32 receiverStartCh;
    n32 numChannels;
} CPRM_ENTRY_TYPE;
typedef struct
{
    n32 numCprmEntries;
    n32 pad;
    CPRM_ENTRY_TYPE coilPortReceiverMap[2];
} CPRM_TYPE;
typedef struct
{
    CPRM_TYPE cprm[NUM_COIL_CONNECTORS];
} COIL_PORTS_RX_MAPS_TYPE;
enum {
    TX_POS_BODY,
    TX_POS_HEAD,
    TX_POS_EXTREMITY,
    TX_POS_XIPHOID,
    TX_POS_STERN,
    TX_POS_BREAST,
    TX_POS_HEAD_XIPHOID,
    TX_POS_HEAD_BODY,
    TX_POS_NECK,
    NUM_TX_POSITIONS
};
typedef struct CTMEntry
{
   n8 receiverID;
   n8 receiverChannel;
   n16 entryMask;
} CTMEntryType;
typedef struct QuadVolWeight
{
    n8 receiverID;
    n8 receiverChannel;
    n8 pad[2];
    f32 recWeight;
    f32 recPhaseDeg;
} QuadVolWeightType;
typedef struct CTTEntry
{
    s8 logicalCoilName[128];




    s8 clinicalCoilName[32];




    n32 configUID;




    n32 coilTypeMask;




    n32 isActiveScanConfig;




    CTMEntryType channelTranslationMap[256];




    QuadVolWeightType quadVolReceiveWeights[16];




    n32 numChannels;

} ChannelTransTableEntryType;
enum
{
    NORMAL_COIL,
    F000_COIL,
    FG00_COIL,
    P000_COIL,
    PG00_COIL,
    R000_COIL,
    SERV_COIL
};
typedef struct _INSTALL_COIL_INFO_
{
    char coilCode[(32 + 8)];
    int isInCoilDatabase;
}INSTALL_COIL_INFO;
typedef struct _INSTALL_COIL_CONNECTOR_INFO_
{
    int connector;
    int needsInstall;
    INSTALL_COIL_INFO installCoilInfo[4];
}INSTALL_COIL_CONNECTOR_INFO;
typedef struct coil_config_params
{
    char coilName[16];
    char GEcoilName[24];
    short pureCorrection;
    int maxNumOfReceivers;
    int coilType;
    int txCoilType;
    int fastTGmode;
    int fastTGstartTA;
    int fastTGstartRG;
    int nuclide;
    int tRPAvolumeRecEnable;
    int pureCompatible;
    int aps1StartTA;
    int cflStartTA;
    int cfhSensitiveAnatomy;
    float pureLambda;
    float pureTuningFactorSurface;
    float pureTuningFactorBody;
    float cableLoss;
    float coilLoss;
    float reconScale;
    float autoshimFOV;
    float coilWeights[4][256];
    ChannelTransTableEntryType cttEntry[4];
} COIL_CONFIG_PARAM_TYPE;
typedef struct application_config_param_type
{
    int aps1StartTA;
    int cflStartTA;
    int AScfPatLocChangeRL;
    int AScfPatLocChangeAP;
    int AScfPatLocChangeSI;
    int TGpatLocChangeRL;
    int TGpatLocChangeAP;
    int TGpatLocChangeSI;
    int autoshimFOV;
    int fastTGstartTA;
    int fastTGstartRG;
    int fastTGmode;
    int cfhSensitiveAnatomy;
    int aps1Mod;
    int aps1Plane;
    int pureCompatible;
    int maxFOV;
    int assetThresh;
    int scic_a_used;
    int scic_s_used;
    int scic_c_used;
    float aps1ModFOV;
    float aps1ModPStloc;
    float aps1ModPSrloc;
    float opthickPSMod;
    float pureScale;
    float pureCorrectionThreshold;
    float pureLambda;
    float pureTuningFactorSurface;
    float pureTuningFactorBody;
    float scic_a[7];
    float scic_s[7];
    float scic_c[7];
    int assetSupported;
    float assetValues[3];
    int arcSupported;
    float arcValues[3];
    int sagCalEnabled;
    int scenicEnabled;
    float slice_down_sample_rate;
    float inplane_down_sample_rate;
    int num_levels_max;
    int num_iterations_max;
    float convergence_threshold;
    int gain_clamp_mode;
    float gain_clamp_value;
} APPLICATION_CONFIG_PARAM_TYPE;
typedef struct application_config_hdr
{
    int error;
    char clinicalName[32];
    APPLICATION_CONFIG_PARAM_TYPE appConfig;
} APPLICATION_CONFIG_HDR;
typedef struct {
    s8 coilName[32];
    s32 txIndexPri;
    s32 txIndexSec;
    n32 rxCoilType;
    n32 hubIndex;
    n32 rxNucleus;
    n32 aps1Mod;
    n32 aps1ModPlane;
    n32 coilSepDir;
    s32 assetCalThreshold;
    f32 aps1ModFov;
    f32 aps1ModSlThick;
    f32 aps1ModPsTloc;
    f32 aps1ModPsRloc;
    f32 autoshimFov;
    f32 assetCalMaxFov;
    f32 maxB1Rms;
    n32 pureCompatible;
    f32 pureLambda;
    f32 pureTuningFactorSurface;
    f32 pureTuningFactorBody;
    n32 numChannels;
    f32 switchingSpeed;
} COIL_INFO;
typedef struct {
    s32 coilAtten;
    n32 txCoilType;
    n32 txPosition;
    n32 txNucleus;
    n32 txAmp;
    f32 maxB1Peak;
    f32 maxB1Squared;
    f32 cableLoss;
    f32 coilLoss;
    f32 reflCoeffSquared[10];
    f32 reflCoeffMassOffset;
    f32 reflCoeffCurveType;
    f32 exposedMass[8];
    f32 lowSarExposedMass[8];
    f32 jstd[12];
    f32 meanJstd[12];
    f32 separationStdev;
} TX_COIL_INFO;
typedef struct _psd_coil_info_
{
    COIL_INFO imgRcvCoilInfo[10];
    COIL_INFO volRcvCoilInfo[10];
    COIL_INFO fullRcvCoilInfo[10];
    TX_COIL_INFO txCoilInfo[5];
    int numCoils;
} PSD_COIL_INFO;
enum
{
    CFG_VAL_APS_NOT_PRESENT = 0,
    CFG_VAL_APS_PRESENT = 1
};
enum
{
    CFG_VAL_CFB_NOT_PRESENT = 0,
    CFG_VAL_CFB_PRESENT = 1
};
enum
{
    CFG_VAL_RCV_SWITCH_16_CH_SWITCH = 0,
    CFG_VAL_RCV_SWITCH_8_CH_SWITCH = 1,
    CFG_VAL_RCV_SWITCH_MEGASWITCH = 2,
    CFG_VAL_RCV_SWITCH_RF_HUB = 3,
    CFG_VAL_RCV_SWITCH_NONE = 4
};
enum
{
    CFG_VAL_RECEIVER_DCERD = 0,
    CFG_VAL_RECEIVER_RRF = 1,
    CFG_VAL_RECEIVER_RRX = 2,
    CFG_VAL_RECEIVER_DPP = 3
};
enum
{
    CFG_VAL_SRI_SERIAL = 0,
    CFG_VAL_SRI_CAN = 1
};
enum
{
    CFG_VAL_TNS_UTNS = 0,
    CFG_VAL_TNS_TDM = 1
};
enum
{
    CFG_VAL_DACQ_DRF = 0,
    CFG_VAL_DACQ_VRF = 1,
    CFG_VAL_DACQ_IVRF = 2
};
enum
{
    CFG_VAL_HEC_NOT_PRESENT = 0
};
enum
{
    CFG_VAL_DV_CABINET = 0,
    CFG_VAL_ISC_CABINET = 1,
    CFG_VAL_HD_CABINET = 2,
    CFG_VAL_CABINET_TYPE_MAX_NUM,
};
enum
{
    CFG_VAL_ONEWIRE_NET_ENV_MON_ONLY = 0,
    CFG_VAL_ONEWIRE_NET_PHPS = 1
};
enum
{
    CFG_VAL_SSC_TYPE_MGD = 0,
    CFG_VAL_SSC_TYPE_ICE = 1,
    CFG_VAL_SSC_TYPE_MAX_NUM = 2
};
enum
{
    CFG_VAL_ICE_CAN_FIBER_DISABLED = 0,
    CFG_VAL_ICE_CAN_FIBER_ENABLED = 1
};
enum
{
    CFG_VAL_TERMSERVER_NOT_PRESENT = 0,
    CFG_VAL_TERMSERVER_PRESENT = 1
};
enum
{
    CFG_VAL_FIELDSTRENGTH_0_0T = 0,
    CFG_VAL_FIELDSTRENGTH_0_35T = 3500,
    CFG_VAL_FIELDSTRENGTH_0_70T = 7000,
    CFG_VAL_FIELDSTRENGTH_1_0T = 10000,
    CFG_VAL_FIELDSTRENGTH_1_5T = 15000,
    CFG_VAL_FIELDSTRENGTH_3_0T = 30000,
    CFG_VAL_FIELDSTRENGTH_7_0T = 70000
};
enum
{
    CFG_VAL_SRPS_NOT_PRESENT = 0,
    CFG_VAL_SRPS_OR_ESRPS = 1
};
enum
{
    CFG_ESTOP_TYPE_SMC = 0,
    CFG_ESTOP_TYPE_EXT = 1,
    CFG_ESTOP_TYPE_MAX_NUM = 2
};
enum
{
    CFG_VAL_PTX_NOT_CAPABLE = 0,
    CFG_VAL_PTX_CAPABLE = 1,
};
enum
{
    CFG_VAL_DPP_TYPE_GEN1 = 0,
    CFG_VAL_DPP_TYPE_GEN2 = 1,
    CFG_VAL_DPP_TYPE_NUM_TYPES
};
enum
{
    CFG_VAL_BODYCOIL_TYPE_0 = 0,
    CFG_VAL_BODYCOIL_TYPE_1 = 1,
    CFG_VAL_BODYCOIL_TYPE_2 = 2,
    CFG_VAL_BODYCOIL_TYPE_3 = 3,
    CFG_VAL_BODYCOIL_TYPE_4 = 4,
    CFG_VAL_BODYCOIL_TYPE_5 = 5,
    CFG_VAL_BODYCOIL_TYPE_6 = 6,
    CFG_VAL_BODYCOIL_TYPE_7 = 7,
    CFG_VAL_BODYCOIL_TYPE_8 = 8,
    CFG_VAL_BODYCOIL_TYPE_9 = 9,
    CFG_VAL_BODYCOIL_TYPE_10 = 10,
    CFG_VAL_BODYCOIL_TYPE_11 = 11,
    CFG_VAL_BODYCOIL_TYPE_12 = 12,
    CFG_VAL_BODYCOIL_TYPE_13 = 13
};
enum
{
    CFG_VAL_BODYCOIL_POLARITY_UNFLIPPED = 0,
    CFG_VAL_BODYCOIL_POLARITY_FLIPPED = 1
};
enum
{
    CFG_WIRED_PAC = 3,
    CFG_WIRELESS_PAC = 4,
    CFG_UNKNOWN_PAC_TYPE = 10
};
enum
{
    CFG_VAL_MCBIAS_VOLTAGE = 0,
    CFG_VAL_MCBIAS_CURRENT = 1
};
enum
{
    CFG_VAL_CABMON1_TYPE = 1,
    CFG_VAL_CABMON2_TYPE = 2,
    CFG_VAL_CABMON3_TYPE = 3
};
enum
{
    CFG_VAL_RECEIVE_FREQ_BANDS_DISABLED = 0,
    CFG_VAL_RECEIVE_FREQ_BANDS_ENABLED = 1
};
typedef struct {
    s16 pmPredictSAR;
    s16 pmContinuousUpdate;
} power_monitor_table_t;
typedef struct {
    char epname[16];
    n32 epamph;
    n32 epampb;
    n32 epamps;
    n32 epampc;
    n32 epwidthh;
    n32 epwidthb;
    n32 epwidths;
    n32 epwidthc;
    n32 epdcycleh;
    n32 epdcycleb;
    n32 epdcycles;
    n32 epdcyclec;
    n8 epsmode;
    n8 epfilter;
    n8 eprcvrband;
    n8 eprcvrinput;
    n8 eprcvrbias;
    n8 eptrdriver;
    n8 epfastrec;
    s16 epxmtadd;
    s16 epprexres;
    s16 epshldctrl;
    s16 epgradcoil;
    n32 eppkpower;
    n32 epseqtime;
    s16 epstartrec;
    s16 ependrec;
    power_monitor_table_t eppmtable;
    n8 epGeneralBankIndex;
    n8 epGeneralBankIndex2;
    n8 epR1BankIndex;
    n8 epNbTransmitSelect;
    n8 epBbTransmitSelect;
    n32 epMnsConverterSelect;
    n32 epRxCoilType;
    f32 epxgd_cableirmsmax;
    f32 epcoilAC_powersum;
    n8 enableReceiveFreqBands;
    s32 offsetReceiveFreqLower;
    s32 offsetReceiveFreqHigher;
} entry_point_table_t;
typedef entry_point_table_t ENTRY_POINT_TABLE;
typedef entry_point_table_t ENTRY_PNT_TABLE;
typedef enum ANATOMY_ATTRIBUTE {
    ATTRIBUTE_CODE_MEANING,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE_APX_BH,
    ATTRIBUTE_MAGIC,
    ATTRIBUTE_SAG_CAL,
    ATTRIBUTE_3DGW_BSPLINE_INTERP,
    ATTRIBUTE_2DFSE_ANNEFACT_REDUCTION,
    ATTRIBUTE_ENABLE_PURE_BLUR,
    ATTRIBUTE_PURE_BLUR,
    ATTRIBUTE_NEAR_HEAD,
    ATTRIBUTE_CALIB_TABLE_MOVE_THRESH,
    ATTRIBUTE_VIRTUAL_CHANNEL_RECON,
    ATTRIBUTE_OPTIMAL_SNR_RECON,
    ATTRIBUTE_SELF_SENSITIVITY_UNIFORM_CORRECTION
} ANATOMY_ATTRIBUTE_E;
typedef enum ANATOMY_ATTRIBUTE_CATEGORY {
    ATTRIBUTE_CATEGORY_HEAD,
    ATTRIBUTE_CATEGORY_NECK,
    ATTRIBUTE_CATEGORY_UPPEREXTREMITIES,
    ATTRIBUTE_CATEGORY_CHEST,
    ATTRIBUTE_CATEGORY_ABDOMEN,
    ATTRIBUTE_CATEGORY_SPINE,
    ATTRIBUTE_CATEGORY_PELVIS,
    ATTRIBUTE_CATEGORY_LOWEREXTREMITIES
} ANATOMY_ATTRIBUTE_CATEGORY_E;
size_t getAnatomyAttribute(const int id, const char* attribute, char* result, size_t len);
int getAnatomyAttributeCached(const int key_id, const int attribute, char* attribute_result);
int isApplicationAllowedForAnatomy(int key_id, int application);
int isCategoryMatchForAnatomy(int key_id, int category);
int getIntAnatomyAttribute(const int key_id, const int attribute, int* attribute_result_int);
int getFloatAnatomyAttribute(const int key_id, const int attribute, float* attribute_result_float);
typedef struct
{
    float oprloc;
    float opphasoff;
    float optloc;
    float oprloc_shift;
    float opphasoff_shift;
    float optloc_shift;
    float opfov_freq_scale;
    float opfov_phase_scale;
    float opslthick_scale;
    float oprot[9];
} SCAN_INFO;
typedef struct
{
    float oppsctloc;
    float oppscrloc;
    float oppscphasoff;
    float oppscrot[9];
    int oppsclenx;
    int oppscleny;
    int oppsclenz;
} PSC_INFO;
typedef struct {
    float opgirthick;
    float opgirtloc;
    float opgirrot[9];
} GIR_INFO;
typedef struct
{
    short slloc;
    short slpass;
    short sltime;
} DATA_ACQ_ORDER;
typedef struct {
    float rsptloc;
    float rsprloc;
    float rspphasoff;
    int slloc;
 } RSP_INFO;
typedef struct {
    int ysign;
    int yoffs;
} PHASE_OFF;
typedef struct {
  float rsppsctloc;
  float rsppscrloc;
  float rsppscphasoff;
  long rsppscrot[10];
  int rsppsclenx;
  int rsppscleny;
  int rsppsclenz;
 } RSP_PSC_INFO;
typedef enum {
    TYPXGRAD = 0,
    TYPYGRAD = 1,
    TYPZGRAD = 2,
    TYPRHO1 = 3,
    TYPRHO2 = 4,
    TYPTHETA = 5,
    TYPOMEGA = 6,
    TYPSSP = 7,
    TYPAUX = 8,
    TYPBXGRAD,
    TYPBYGRAD,
    TYPBZGRAD,
    TYPBRHO1,
    TYPBRHO2,
    TYPBTHETA,
    TYPBOMEGA,
    TYPBSSP,
    TYPBAUX
} WF_PROCESSOR;
typedef enum {
    TYPINSTRMEM = 0,
    TYPWAVEMEM = 1
} WF_HARDWARE_TYPE;
typedef enum {
    TOHARDWARE = 0,
    FROMHARDWARE = 1
} HW_DIRECTION;
typedef enum {
    SSPS1 = 0,
    SSPS2 = 1,
    SSPS3 = 2,
    SSPS4 = 3
} SSP_S_ATTRIB;
typedef struct {
  s32 abcode;
  char text_string[256];
  char text_arg[16];
  s32 *longarg[4];
} PSD_EXIT_ARG;
typedef enum GRADIENT_COILS
{
    PSD_55_CM_COIL = 1,
    PSD_60_CM_COIL = 2,
    PSD_TRM_COIL = 3,
    PSD_4_COIL = 4,
    PSD_5_COIL = 5,
    PSD_CRM_COIL = 6,
    PSD_HFO_COIL = 7,
    PSD_XRMB_COIL = 8,
    PSD_OVATION_COIL = 9,
    PSD_10_COIL = 10,
    PSD_XRMW_COIL = 11,
    PSD_VRMW_COIL = 12,
    PSD_HRMW_COIL = 13,
    PSD_BRM2_COIL = 14
} GRADIENT_COIL_E;
typedef enum BODY_COIL_TYPES
{
    PSD_15_BRM_BODY_COIL = 0,
    PSD_15_TRM_BODY_COIL = 0,
    PSD_15_HDE_BODY_COIL = 0,
    PSD_15_CRM_BODY_COIL = 1,
    PSD_30_CRM_BODY_COIL = 2,
    PSD_30_TRM_BODY_COIL = 3,
    PSD_30_XRM_BODY_COIL = 4,
    PSD_15_XRM_BODY_COIL = 5,
    PSD_15_XRMW_BODY_COIL = 6,
    PSD_30_XRMW_BODY_COIL = 7,
    PSD_30_NEONATAL_BODY_COIL = 8,
    PSD_30_XRMW_PET_BODY_COIL = 9,
    PSD_30_VRMW_BODY_COIL = 10,
    PSD_30_HRMW_BODY_COIL = 11,
    PSD_30_VRMW_VCP_BODY_COIL = 12,
    PSD_15_VRMW_BODY_COIL = 13
} BODY_COIL_TYPE_E;
typedef enum PSD_BOARD_TYPE
{
    PSDCERD = 0,
    PSDDVMR,
    NUM_PSD_BOARD_TYPES
} PSD_BOARD_TYPE_E;
typedef enum SSC_TYPE
{
    SSC_TYPE_MGD = 0,
    SSC_TYPE_ICE = 1
} SSC_TYPE_E;
typedef enum GRADIENT_COIL_METHOD
{
    GRADIENT_COIL_METHOD_AUTO = -1,
    GRADIENT_COIL_METHOD_DC = 0,
    GRADIENT_COIL_METHOD_AC = 1,
    GRADIENT_COIL_METHOD_QAC = 2
} GRADIENT_COIL_METHOD_E;
typedef enum POWER_IN_HEAT_CALC
{
    AVERAGE_POWER = 0,
    MAXIMUM_POWER = 1
} POWER_IN_HEAT_CALC_E;
typedef enum GRADIENT_PULSE_TYPE
{
    G_RAMP = 1,
    G_TRAP = 2,
    G_SIN = 3,
    G_CONSTANT = 4,
    G_ARBTRAP = 5,
    G_USER = 6,
    G_EMPTY = -1,
} GRADIENT_PULSE_TYPE_E;
typedef struct {
  int ptype;
  int *attack;
  int *decay;
  int *pw;
  float *amps;
  float *amp;
  float *ampd;
  float *ampe;
  char *gradfile;
  int num;
  float scale;
  int *time;
  int tdelta;
  float powscale;
  float power;
  float powpos;
  float powneg;
  float powabs;
  float amptran;
  int pwm;
  int bridge;
  float intabspwmcurr;
} GRAD_PULSE;
typedef struct {
  int *pw;
  float *amp;
  float abswidth;
  float effwidth;
  float area;
  float dtycyc;
  float maxpw;
  int num;
  float max_b1;
  float max_int_b1_sq;
  float max_rms_b1;
  float nom_fa;
  float *act_fa;
  float nom_pw;
  float nom_bw;
  unsigned int activity;
  unsigned char reference;
  int isodelay;
  float scale;
  int *res;
  int extgradfile;
  int *exciter;
  int apply_as_hadamard_factor;
} RF_PULSE;
typedef struct {
  int change;
  int newres;
} RF_PULSE_INFO;
typedef enum {
    NORMAL_CONTROL_MODE = 0,
    FIRST_CONTROL_MODE = 1,
    SECOND_CONTROL_MODE = 2,
    LOWSAR_CONTROL_MODE = 3
} regulatory_control_mode_e;
typedef enum epic_slice_order_type_e
{
    TYPNCAT =0,
    TYPCAT =1,
    TYPXRR =2,
    TYPMPMP =3,
    TYPSSMP =4,
    TYP3D =5,
    TYPNORMORDER =6,
    TYPFASTMPH =7,
    TYPF3D =8,
    TYP3DMSNCAT =9,
    TYP3DMSCAT =10,
    TYP3DFSENCAT =11,
    TYP3DFSECAT =12,
    TYPRTG =13,
    TYPF3DMPH =14,
    TYPSSFSEINT =15,
    TYPSSFSESEQ =16,
    TYPSSFSEXRR =17,
    TYPSSFSERTG =18,
    TYPSEQSLIC =19,
    TYPF3DMSMPH =20,
    TYPSSFSEFLAIR=21,
    TYPMAVRIC =22,
    TYPNCATFLAIR =23,
    TYPMDMENORM =24,
    TYPMULTIBAND =25,
    TYPSSFSEMPH =26,
    TYPF3DCINE =27,
    TYPF3DMSCINE =28,
    TYPNCATRTG =29,
    TYPCATRTG =30,
    TYPMULTIBAND2=31,
    TYPMULTIBANDNORMORDER =32
} epic_slice_order_type;
typedef enum exciter_type {
    NO_EXCITER = 0,
    MASTER_EXCITER,
    SLAVE_EXCITER,
    ALL_EXCITERS
} exciterSelection;
typedef enum receiver_type {
    NO_RECEIVER = 0,
    MASTER_RECEIVER,
    SLAVE_RECEIVER,
    ALL_RECEIVERS
} receiverSelection;
typedef enum oscillator_source {
    LO_MASTER_RCVALL = 0,
    LO_SLAVE_RCVB1,
    LO_SLAVE_RCVB2,
    LO_SLAVE_RCVB3,
    LO_SLAVE_RCVB4,
    LO_SLAVE_RCVB1B2,
    LO_SLAVE_RCVB1B3,
    LO_SLAVE_RCVB1B4,
    LO_SLAVE_RCVB1B2B3,
    LO_SLAVE_RCVB1B2B4,
    LO_SLAVE_RCVB1B3B4,
    LO_SLAVE_RCVB2B3,
    LO_SLAVE_RCVB2B4,
    LO_SLAVE_RCVB2B3B4,
    LO_SLAVE_RCVB3B4,
    LO_SLAVE_RCVALL,
    NO_LO_CHANGE
} demodSelection;
typedef enum nav_type {
    NAV_OFF = 0,
    NAV_ON,
    NAV_MASTER,
    NAV_SLAVE,
    NO_NAV_CHANGE
} navSelection;
typedef enum VALUE_SYSTEM_TYPE
{
  NON_VALUE_SYSTEM = 0,
  VALUE_SYSTEM_HDE,
  VALUE_SYSTEM_SVEM,
  VALUE_SYSTEM_SVDM,
  VALUE_SYSTEM_SVDMP
} VALUE_SYSTEM_TYPE_E;
typedef enum PSD_PATIENT_ENTRY {
    PSD_PATIENT_ENTRY_HEAD_FIRST = 1,
    PSD_PATIENT_ENTRY_FEET_FIRST = 2,
    PSD_PATIENT_ENTRY_AXIAL = 3,
    PSD_PATIENT_ENTRY_SIDE = 4,
    PSD_PATIENT_ENTRY_VERTICAL = 5,
    PSD_PATIENT_ENTRY_RESERVED = 6,
    PSD_PATIENT_ENTRY_HEAD_FIRST_PLUS_25DEG = 7,
    PSD_PATIENT_ENTRY_HEAD_FIRST_MINUS_25DEG = 8,
    PSD_PATIENT_ENTRY_FEET_FIRST_PLUS_25DEG = 9,
    PSD_PATIENT_ENTRY_FEET_FIRST_MINUS_25DEG = 10
} PSD_PATIENT_ENTRY_E;
typedef enum CAL_MODE
{
    CAL_MODE_MIN = 0,
    CAL_MODE_STANDARD = 0,
    CAL_MODE_BREATHHOLD_FREEBREATHING = 1,
    CAL_MODE_FREEBREATHING = 2,
    CAL_MODE_MAX = 2
} CAL_MODE_E;
typedef enum RG_CAL_MODE {
    RG_CAL_MODE_MIN = 0,
    RG_CAL_MODE_MEASURED = 0,
    RG_CAL_MODE_HIGH_FIXED = 1,
    RG_CAL_MODE_LOW_FIXED = 2,
    RG_CAL_MODE_AUTO = 3,
    RG_CAL_MODE_MAX = 3
} RG_CAL_MODE_E;
typedef enum ADD_SCAN_TYPE {
    ADD_SCAN_TYPE_NONE = 0,
    ADD_SCAN_HEADLOC_SCOUT = 1
} ADD_SCAN_TYPE_E;
typedef enum PSD_SLTHICK_LABEL
{
    PSD_SLTHICK_LABEL_SLTHICK = 0,
    PSD_SLTHICK_LABEL_RESOLUTION = 1
} PSD_SLTHICK_LABEL_E;
typedef enum PSD_NAV_TYPE {
  PSD_NAV_TYPE_90_180 = 0,
  PSD_NAV_TYPE_CYL
} PSD_NAV_TYPE_E;
typedef enum PSD_FLIP_ANGLE_MODE_LABEL {
    PSD_FLIP_ANGLE_MODE_EXCITE = 0,
    PSD_FLIP_ANGLE_MODE_REFOCUS = 1
} PSD_FLIP_ANGLE_LABEL_E;
typedef enum PSD_AUTO_TR_MODE_LABEL {
    PSD_AUTO_TR_MODE_MANUAL_TR = 0,
    PSD_AUTO_TR_MODE_IN_RANGE_TR = 1,
    PSD_AUTO_TR_MODE_ADVANCED_IN_RANGE_TR = 2
} PSD_AUTO_TR_MODE_LABEL_E;
typedef enum CARDIAC_GATE_TYPE
{
    CARDIAC_GATE_TYPE_MIN = 0,
    CARDIAC_GATE_TYPE_NONE = 0,
    CARDIAC_GATE_TYPE_ECG = 1,
    CARDIAC_GATE_TYPE_PG = 2,
    CARDIAC_GATE_TYPE_MAX = 2
} CARDIAC_GATE_TYPE_E;
typedef char CHAR;
typedef s16 SHORT;
typedef int INT;
typedef INT LONG;
typedef f32 FLOAT;
typedef f64 DOUBLE;
typedef n8 UCHAR;
typedef n16 USHORT;
typedef unsigned int UINT;
typedef UINT ULONG;
typedef int STATUS;
typedef void * ADDRESS;
typedef enum e_axis {
    X = 0,
    Y,
    Z
} t_axis;

typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;
typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;
__extension__ typedef signed long long int __int64_t;
__extension__ typedef unsigned long long int __uint64_t;
__extension__ typedef long long int __quad_t;
__extension__ typedef unsigned long long int __u_quad_t;
__extension__ typedef __u_quad_t __dev_t;
__extension__ typedef unsigned int __uid_t;
__extension__ typedef unsigned int __gid_t;
__extension__ typedef unsigned long int __ino_t;
__extension__ typedef __u_quad_t __ino64_t;
__extension__ typedef unsigned int __mode_t;
__extension__ typedef unsigned int __nlink_t;
__extension__ typedef long int __off_t;
__extension__ typedef __quad_t __off64_t;
__extension__ typedef int __pid_t;
__extension__ typedef struct { int __val[2]; } __fsid_t;
__extension__ typedef long int __clock_t;
__extension__ typedef unsigned long int __rlim_t;
__extension__ typedef __u_quad_t __rlim64_t;
__extension__ typedef unsigned int __id_t;
__extension__ typedef long int __time_t;
__extension__ typedef unsigned int __useconds_t;
__extension__ typedef long int __suseconds_t;
__extension__ typedef int __daddr_t;
__extension__ typedef long int __swblk_t;
__extension__ typedef int __key_t;
__extension__ typedef int __clockid_t;
__extension__ typedef void * __timer_t;
__extension__ typedef long int __blksize_t;
__extension__ typedef long int __blkcnt_t;
__extension__ typedef __quad_t __blkcnt64_t;
__extension__ typedef unsigned long int __fsblkcnt_t;
__extension__ typedef __u_quad_t __fsblkcnt64_t;
__extension__ typedef unsigned long int __fsfilcnt_t;
__extension__ typedef __u_quad_t __fsfilcnt64_t;
__extension__ typedef int __ssize_t;
typedef __off64_t __loff_t;
typedef __quad_t *__qaddr_t;
typedef char *__caddr_t;
__extension__ typedef int __intptr_t;
__extension__ typedef unsigned int __socklen_t;
struct _IO_FILE;

typedef struct _IO_FILE FILE;


typedef struct _IO_FILE __FILE;
typedef struct
{
  int __count;
  union
  {
    unsigned int __wch;
    char __wchb[4];
  } __value;
} __mbstate_t;
typedef struct
{
  __off_t __pos;
  __mbstate_t __state;
} _G_fpos_t;
typedef struct
{
  __off64_t __pos;
  __mbstate_t __state;
} _G_fpos64_t;
typedef int _G_int16_t __attribute__ ((__mode__ (__HI__)));
typedef int _G_int32_t __attribute__ ((__mode__ (__SI__)));
typedef unsigned int _G_uint16_t __attribute__ ((__mode__ (__HI__)));
typedef unsigned int _G_uint32_t __attribute__ ((__mode__ (__SI__)));
typedef __builtin_va_list __gnuc_va_list;
struct _IO_jump_t; struct _IO_FILE;
typedef void _IO_lock_t;
struct _IO_marker {
  struct _IO_marker *_next;
  struct _IO_FILE *_sbuf;
  int _pos;
};
enum __codecvt_result
{
  __codecvt_ok,
  __codecvt_partial,
  __codecvt_error,
  __codecvt_noconv
};
struct _IO_FILE {
  int _flags;
  char* _IO_read_ptr;
  char* _IO_read_end;
  char* _IO_read_base;
  char* _IO_write_base;
  char* _IO_write_ptr;
  char* _IO_write_end;
  char* _IO_buf_base;
  char* _IO_buf_end;
  char *_IO_save_base;
  char *_IO_backup_base;
  char *_IO_save_end;
  struct _IO_marker *_markers;
  struct _IO_FILE *_chain;
  int _fileno;
  int _flags2;
  __off_t _old_offset;
  unsigned short _cur_column;
  signed char _vtable_offset;
  char _shortbuf[1];
  _IO_lock_t *_lock;
  __off64_t _offset;
  void *__pad1;
  void *__pad2;
  void *__pad3;
  void *__pad4;
  size_t __pad5;
  int _mode;
  char _unused2[15 * sizeof (int) - 4 * sizeof (void *) - sizeof (size_t)];
};
typedef struct _IO_FILE _IO_FILE;
struct _IO_FILE_plus;
extern struct _IO_FILE_plus _IO_2_1_stdin_;
extern struct _IO_FILE_plus _IO_2_1_stdout_;
extern struct _IO_FILE_plus _IO_2_1_stderr_;
typedef __ssize_t __io_read_fn (void *__cookie, char *__buf, size_t __nbytes);
typedef __ssize_t __io_write_fn (void *__cookie, __const char *__buf,
     size_t __n);
typedef int __io_seek_fn (void *__cookie, __off64_t *__pos, int __w);
typedef int __io_close_fn (void *__cookie);
extern int __underflow (_IO_FILE *);
extern int __uflow (_IO_FILE *);
extern int __overflow (_IO_FILE *, int);
extern int _IO_getc (_IO_FILE *__fp);
extern int _IO_putc (int __c, _IO_FILE *__fp);
extern int _IO_feof (_IO_FILE *__fp) __attribute__ ((__nothrow__));
extern int _IO_ferror (_IO_FILE *__fp) __attribute__ ((__nothrow__));
extern int _IO_peekc_locked (_IO_FILE *__fp);
extern void _IO_flockfile (_IO_FILE *) __attribute__ ((__nothrow__));
extern void _IO_funlockfile (_IO_FILE *) __attribute__ ((__nothrow__));
extern int _IO_ftrylockfile (_IO_FILE *) __attribute__ ((__nothrow__));
extern int _IO_vfscanf (_IO_FILE * __restrict, const char * __restrict,
   __gnuc_va_list, int *__restrict);
extern int _IO_vfprintf (_IO_FILE *__restrict, const char *__restrict,
    __gnuc_va_list);
extern __ssize_t _IO_padn (_IO_FILE *, int, __ssize_t);
extern size_t _IO_sgetn (_IO_FILE *, void *, size_t);
extern __off64_t _IO_seekoff (_IO_FILE *, __off64_t, int, int);
extern __off64_t _IO_seekpos (_IO_FILE *, __off64_t, int);
extern void _IO_free_backup_area (_IO_FILE *) __attribute__ ((__nothrow__));
typedef __gnuc_va_list va_list;
typedef __off_t off_t;
typedef __ssize_t ssize_t;

typedef _G_fpos_t fpos_t;

extern struct _IO_FILE *stdin;
extern struct _IO_FILE *stdout;
extern struct _IO_FILE *stderr;

extern int remove (__const char *__filename) __attribute__ ((__nothrow__));
extern int rename (__const char *__old, __const char *__new) __attribute__ ((__nothrow__));

extern int renameat (int __oldfd, __const char *__old, int __newfd,
       __const char *__new) __attribute__ ((__nothrow__));

extern FILE *tmpfile (void) ;
extern char *tmpnam (char *__s) __attribute__ ((__nothrow__)) ;

extern char *tmpnam_r (char *__s) __attribute__ ((__nothrow__)) ;
extern char *tempnam (__const char *__dir, __const char *__pfx)
     __attribute__ ((__nothrow__)) __attribute__ ((__malloc__)) ;

extern int fclose (FILE *__stream);
extern int fflush (FILE *__stream);

extern int fflush_unlocked (FILE *__stream);

extern FILE *fopen (__const char *__restrict __filename,
      __const char *__restrict __modes) ;
extern FILE *freopen (__const char *__restrict __filename,
        __const char *__restrict __modes,
        FILE *__restrict __stream) ;

extern FILE *fdopen (int __fd, __const char *__modes) __attribute__ ((__nothrow__)) ;
extern FILE *fmemopen (void *__s, size_t __len, __const char *__modes)
  __attribute__ ((__nothrow__)) ;
extern FILE *open_memstream (char **__bufloc, size_t *__sizeloc) __attribute__ ((__nothrow__)) ;

extern void setbuf (FILE *__restrict __stream, char *__restrict __buf) __attribute__ ((__nothrow__));
extern int setvbuf (FILE *__restrict __stream, char *__restrict __buf,
      int __modes, size_t __n) __attribute__ ((__nothrow__));

extern void setbuffer (FILE *__restrict __stream, char *__restrict __buf,
         size_t __size) __attribute__ ((__nothrow__));
extern void setlinebuf (FILE *__stream) __attribute__ ((__nothrow__));

extern int fprintf (FILE *__restrict __stream,
      __const char *__restrict __format, ...);
extern int printf (__const char *__restrict __format, ...);
extern int sprintf (char *__restrict __s,
      __const char *__restrict __format, ...) __attribute__ ((__nothrow__));
extern int vfprintf (FILE *__restrict __s, __const char *__restrict __format,
       __gnuc_va_list __arg);
extern int vprintf (__const char *__restrict __format, __gnuc_va_list __arg);
extern int vsprintf (char *__restrict __s, __const char *__restrict __format,
       __gnuc_va_list __arg) __attribute__ ((__nothrow__));


extern int snprintf (char *__restrict __s, size_t __maxlen,
       __const char *__restrict __format, ...)
     __attribute__ ((__nothrow__)) __attribute__ ((__format__ (__printf__, 3, 4)));
extern int vsnprintf (char *__restrict __s, size_t __maxlen,
        __const char *__restrict __format, __gnuc_va_list __arg)
     __attribute__ ((__nothrow__)) __attribute__ ((__format__ (__printf__, 3, 0)));

extern int vdprintf (int __fd, __const char *__restrict __fmt,
       __gnuc_va_list __arg)
     __attribute__ ((__format__ (__printf__, 2, 0)));
extern int dprintf (int __fd, __const char *__restrict __fmt, ...)
     __attribute__ ((__format__ (__printf__, 2, 3)));

extern int fscanf (FILE *__restrict __stream,
     __const char *__restrict __format, ...) ;
extern int scanf (__const char *__restrict __format, ...) ;
extern int sscanf (__const char *__restrict __s,
     __const char *__restrict __format, ...) __attribute__ ((__nothrow__));
extern int fscanf (FILE *__restrict __stream, __const char *__restrict __format, ...) __asm__ ("" "__isoc99_fscanf") ;
extern int scanf (__const char *__restrict __format, ...) __asm__ ("" "__isoc99_scanf") ;
extern int sscanf (__const char *__restrict __s, __const char *__restrict __format, ...) __asm__ ("" "__isoc99_sscanf") __attribute__ ((__nothrow__));


extern int vfscanf (FILE *__restrict __s, __const char *__restrict __format,
      __gnuc_va_list __arg)
     __attribute__ ((__format__ (__scanf__, 2, 0))) ;
extern int vscanf (__const char *__restrict __format, __gnuc_va_list __arg)
     __attribute__ ((__format__ (__scanf__, 1, 0))) ;
extern int vsscanf (__const char *__restrict __s,
      __const char *__restrict __format, __gnuc_va_list __arg)
     __attribute__ ((__nothrow__)) __attribute__ ((__format__ (__scanf__, 2, 0)));
extern int vfscanf (FILE *__restrict __s, __const char *__restrict __format, __gnuc_va_list __arg) __asm__ ("" "__isoc99_vfscanf")
     __attribute__ ((__format__ (__scanf__, 2, 0))) ;
extern int vscanf (__const char *__restrict __format, __gnuc_va_list __arg) __asm__ ("" "__isoc99_vscanf")
     __attribute__ ((__format__ (__scanf__, 1, 0))) ;
extern int vsscanf (__const char *__restrict __s, __const char *__restrict __format, __gnuc_va_list __arg) __asm__ ("" "__isoc99_vsscanf")
     __attribute__ ((__nothrow__)) __attribute__ ((__format__ (__scanf__, 2, 0)));


extern int fgetc (FILE *__stream);
extern int getc (FILE *__stream);
extern int getchar (void);

extern int getc_unlocked (FILE *__stream);
extern int getchar_unlocked (void);
extern int fgetc_unlocked (FILE *__stream);

extern int fputc (int __c, FILE *__stream);
extern int putc (int __c, FILE *__stream);
extern int putchar (int __c);

extern int fputc_unlocked (int __c, FILE *__stream);
extern int putc_unlocked (int __c, FILE *__stream);
extern int putchar_unlocked (int __c);
extern int getw (FILE *__stream);
extern int putw (int __w, FILE *__stream);

extern char *fgets (char *__restrict __s, int __n, FILE *__restrict __stream)
     ;
extern char *gets (char *__s) ;

extern __ssize_t __getdelim (char **__restrict __lineptr,
          size_t *__restrict __n, int __delimiter,
          FILE *__restrict __stream) ;
extern __ssize_t getdelim (char **__restrict __lineptr,
        size_t *__restrict __n, int __delimiter,
        FILE *__restrict __stream) ;
extern __ssize_t getline (char **__restrict __lineptr,
       size_t *__restrict __n,
       FILE *__restrict __stream) ;

extern int fputs (__const char *__restrict __s, FILE *__restrict __stream);
extern int puts (__const char *__s);
extern int ungetc (int __c, FILE *__stream);
extern size_t fread (void *__restrict __ptr, size_t __size,
       size_t __n, FILE *__restrict __stream) ;
extern size_t fwrite (__const void *__restrict __ptr, size_t __size,
        size_t __n, FILE *__restrict __s) ;

extern size_t fread_unlocked (void *__restrict __ptr, size_t __size,
         size_t __n, FILE *__restrict __stream) ;
extern size_t fwrite_unlocked (__const void *__restrict __ptr, size_t __size,
          size_t __n, FILE *__restrict __stream) ;

extern int fseek (FILE *__stream, long int __off, int __whence);
extern long int ftell (FILE *__stream) ;
extern void rewind (FILE *__stream);

extern int fseeko (FILE *__stream, __off_t __off, int __whence);
extern __off_t ftello (FILE *__stream) ;

extern int fgetpos (FILE *__restrict __stream, fpos_t *__restrict __pos);
extern int fsetpos (FILE *__stream, __const fpos_t *__pos);


extern void clearerr (FILE *__stream) __attribute__ ((__nothrow__));
extern int feof (FILE *__stream) __attribute__ ((__nothrow__)) ;
extern int ferror (FILE *__stream) __attribute__ ((__nothrow__)) ;

extern void clearerr_unlocked (FILE *__stream) __attribute__ ((__nothrow__));
extern int feof_unlocked (FILE *__stream) __attribute__ ((__nothrow__)) ;
extern int ferror_unlocked (FILE *__stream) __attribute__ ((__nothrow__)) ;

extern void perror (__const char *__s);

extern int sys_nerr;
extern __const char *__const sys_errlist[];
extern int fileno (FILE *__stream) __attribute__ ((__nothrow__)) ;
extern int fileno_unlocked (FILE *__stream) __attribute__ ((__nothrow__)) ;
extern FILE *popen (__const char *__command, __const char *__modes) ;
extern int pclose (FILE *__stream);
extern char *ctermid (char *__s) __attribute__ ((__nothrow__));
extern void flockfile (FILE *__stream) __attribute__ ((__nothrow__));
extern int ftrylockfile (FILE *__stream) __attribute__ ((__nothrow__)) ;
extern void funlockfile (FILE *__stream) __attribute__ ((__nothrow__));

typedef enum e_fopen_mode {
   READ_MODE = 0,
   WRITE_MODE
} t_fopen_mode;
STATUS DefOpenUsrFile( const CHAR *filename, const CHAR *marker );
STATUS DefOpenFile( const CHAR *markername );
STATUS DefFindKey( const CHAR *key, const INT mark );
STATUS DefReadData( const CHAR *format_str, ADDRESS data_addr );
STATUS DefCloseFile( void );
INT ExtractNameTo( CHAR *orig_name, CHAR *key, CHAR *new_name );
double FMax( int info, ... );
double FMin( int info, ... );
int IMax( int info, ... );
int IMin( int info, ... );
short floatsAlmostEqualAbsolute( const float a,
                                 const float b,
                                 const float tol );
short floatsAlmostEqualRelative( const float a,
                                 const float b,
                                 const float fract );
short floatsAlmostEqualEpsilons( const float a,
                                 const float b,
                                 const unsigned int neps );
short floatsAlmostEqualEpsilon( const float a,
                                const float b );
short floatAlmostZeroAbsolute( const float a,
                               const float tol );
short floatIdenticallyZero( const float a );
short floatsAlmostEqualNulps( const float a,
                              const float b,
                              const n32 nulps );
float floatUlp( const float a );
short floatIsInteger( const float a );
short floatIsNormal( const float a );
short floatIsInfinite( const float a );
short floatIsPositiveInfinity( const float a );
short floatIsNegativeInfinity( const float a );
short floatIsNan( const float a );
short doublesAlmostEqualAbsolute( const double a,
                                  const double b,
                                  const double tol );
short doublesAlmostEqualRelative( const double a,
                                  const double b,
                                  const double fract );
short doublesAlmostEqualEpsilons( const double a,
                                  const double b,
                                  const unsigned int neps );
short doublesAlmostEqualEpsilon( const double a,
                                 const double b );
short doubleAlmostZeroAbsolute( const double a,
                                const double tol );
short doubleIdenticallyZero( const double a );
short doublesAlmostEqualNulps( const double a,
                               const double b,
                               const n64 nulps );
double doubleUlp( const double a );
short doubleIsInteger( const double a );
short doubleIsNormal( const double a );
short doubleIsInfinite( const double a );
short doubleIsPositiveInfinity( const double a );
short doubleIsNegativeInfinity( const double a );
short doubleIsNan( const double a );
typedef float datavalue;
datavalue median(const datavalue * p, const int kernel_size);
void smooth(float *data, int numpts, int kernel_size, int skip);
void intarr2float(float * f_a, const int * a, const int numpt);
void generate_polycurve(float * result, const float * xdata, const float * coeff, const int order, const int numpt);
STATUS weighted_polyfit( float * fittedResult,
               float * coeff,
               const float * ydata ,
               const float * xdata,
               const float * weight,
               const int order,
               const int numpt );
FILE *OpenFile( const CHAR *filename, const t_fopen_mode mode );
STATUS CloseFile( FILE *plotdata_fptr );
STATUS RewindFile( FILE *plotdata_fptr );
STATUS RemoveFile( const CHAR *filename );
STATUS FileExists( const CHAR *filename );
LONG FileDate( CHAR *path );
void WriteError( const CHAR *string );
STATUS FileExecs( const CHAR *filename );
STATUS IsaWDir( const CHAR *filename );
STATUS IsSunview( void );
const char *Resides( const char *env_varname );
const char *SetBase( const char *filename );
const char *ExtractBase( const char *filename );
int RNEAREST_RF( int n, int fact );
ADDRESS WTAlloc( size_t size );
void WTFree( ADDRESS address );
STATUS
activate_usercv( const int usercv );
STATUS
deactivate_usercv( const int usercv );
STATUS
deactivate_all_usercvs( void );
STATUS
activate_reserved_usercv( const int usercv );
STATUS
deactivate_reserved_usercv( const int usercv );
STATUS
deactivate_all_reserved_usercvs( void );
enum
{
    SEQ_CFG_SEQ_ID_GRAD_X = 0,
    SEQ_CFG_SEQ_ID_GRAD_Y = 1,
    SEQ_CFG_SEQ_ID_GRAD_Z = 2,
};
enum
{
    SEQ_CFG_TYPE_NONE = 0x00000000,
    SEQ_CFG_TYPE_SSP = 0x00000001,
    SEQ_CFG_TYPE_GRAD_X = 0x00000002,
    SEQ_CFG_TYPE_GRAD_Y = 0x00000004,
    SEQ_CFG_TYPE_GRAD_Z = 0x00000008,
    SEQ_CFG_TYPE_RHO = 0x00000010,
    SEQ_CFG_TYPE_THETA = 0x00000020,
    SEQ_CFG_TYPE_OMEGA = 0x00000040,
    SEQ_CFG_TYPE_RF_TX = 0x00000080,
    SEQ_CFG_TYPE_RF_RX = 0x00000100,
};
enum
{
    SEQ_CFG_RF_GROUP_MODE_NONE = 0x00000000,
    SEQ_CFG_RF_GROUP_MODE_DUAL_SEQUENCE = 0x00000001,
};
enum
{
    SEQ_CFG_MAX_RF_GROUPS = 3,
    SEQ_CFG_CORE_RF_CHANNEL_1 = 0,
    SEQ_CFG_CORE_RF_CHANNEL_2 = 1,
    SEQ_CFG_NUM_CORE_RF_CHANNELS = 2,
    SEQ_CFG_CORE_TYPE_NONE = 0x0000,
    SEQ_CFG_CORE_TYPE_PRIMARY = 0x0001,
    SEQ_CFG_CORE_TYPE_SECONDARY = 0x0002,
    SEQ_CFG_CORE_TYPE_4RF_MODE = 0x0004,
    SEQ_CFG_CORE_TYPE_6RF_MODE = 0x0008,
    SEQ_CFG_MAX_CORES = 5,
    SEQ_CFG_MAX_CORE_SEQS = 8,
    SEQ_CFG_MAX_SECONDARY_CORE_SEQS = 7,
    SEQ_CFG_MAX_SEQ_IDS = (SEQ_CFG_MAX_CORE_SEQS +
                                       ((SEQ_CFG_MAX_CORES - 1) *
                                        SEQ_CFG_MAX_SECONDARY_CORE_SEQS)),
    SEQ_CFG_DEBUG_OPTION_DEFAULT = 0,
};
typedef struct
{
    n32 sscType;
    n32 ptxCapable;
    n32 fieldStrength;
    n32 rfAmpType;
    n32 receiverType;
} SeqCfgSysCfgInfo;
typedef struct
{
    s32 seqId;
    n32 seqType;
    s32 duplicateSeqId;
    s32 sspSeqId;
    s32 rfGroupId;
    s32 rfGroupTxChannel;
    n32 coreId;
    s32 coreRfChannel;
} SeqCfgSeqInfo;
typedef struct
{
    s32 coreId;
    n32 coreType;
    s32 requiredPhysicalTxId[SEQ_CFG_MAX_RF_GROUPS];
    n32 numSeqs;
    n32 seqs[SEQ_CFG_MAX_CORE_SEQS];
} SeqCfgCoreInfo;
typedef struct
{
    n32 txAmp;
    n32 txCoilType;
    n32 txNucleus;
    n32 txChannels;
} SeqCfgRfTxInfo;
typedef struct
{
    n32 rfGroupId;
    n32 numAppTxChannels;
    n32 txSeqTypes;
    n32 rxFlag;
    n32 rxSeqTypes;
    n32 mode;
    SeqCfgRfTxInfo txInfo;
} SeqCfgRfGroupInfo;
typedef struct
{
    s32 valid;
    n32 debugOptions;
    n32 numRfGroups;
    n32 numCores;
    n32 numAppSeqs;
    n32 numSeqs;
    SeqCfgSysCfgInfo sysCfg;
    SeqCfgRfGroupInfo rfGroups[SEQ_CFG_MAX_RF_GROUPS];
    SeqCfgCoreInfo cores[SEQ_CFG_MAX_CORES];
    SeqCfgSeqInfo seqs[SEQ_CFG_MAX_SEQ_IDS];
} SeqCfgInfo;
typedef struct SeqType
{
    n32 seqID;
    n32 seqOpt;
    char *pName;
} SeqType;
typedef enum {
    DABNORM,
    DABCINE,
    DABON,
    DABOFF
} TYPDAB_PACKETS;
typedef enum {
    NOPASS,
    PASSTHROUGH
} TYPACQ_PASS;
typedef SeqType SeqData;
typedef long WF_HW_WAVEFORM_PTR;
typedef long WF_HW_INSTR_PTR;
typedef ADDRESS WF_PULSE_FORWARD_ADDR;
typedef ADDRESS WF_INSTR_PTR;
typedef struct INST_NODE {
    struct INST_NODE *next;
    WF_HW_INSTR_PTR wf_instr_ptr;
    long amplitude;
    long period;
    long start;
    long end;
    long entry_group;
    WF_PULSE_FORWARD_ADDR pulse_hdr;
    WF_HW_INSTR_PTR wf_instr_ptr_secssp[SEQ_CFG_MAX_CORES];
    int num_iters;
    long* ampl_iters;
} WF_INSTR_HDR;
typedef struct {
    short amplitude;
} CONST_EXT;
typedef struct {
    short amplitude;
    float separation;
    float nsinc_cycles;
    float alpha;
} HADAMARD_EXT;
typedef struct {
    short start_amplitude;
    short end_amplitude;
} RAMP_EXT;
typedef struct {
    short amplitude;
    float nsinc_cycles;
    float alpha;
} SINC_EXT;
typedef struct {
    short amplitude;
    float start_phase;
    float phase_length;
    short offset;
} SINUSOID_EXT;
typedef union {
    CONST_EXT constext;
    HADAMARD_EXT hadamard;
    RAMP_EXT ramp;
    SINC_EXT sinc;
    SINUSOID_EXT sinusoid;
} WF_PULSE_EXT;
typedef enum {
    TYPBITS,
    TYPBRIDGED_CONST,
    TYPBRIDGED_RAMP,
    TYPCONSTANT,
    TYPEXTERNAL,
    TYPHADAMARD,
    TYPRAMP,
    TYPRESERVE,
    TYPSINC,
    TYPSINUSOID
} WF_PULSE_TYPES;
typedef enum {
    SSPUNKN,
    SSPDAB,
    SSPRBA,
    SSPXTR,
    SSPSYNC,
    SSPFREQ,
    SSPUBR,
    SSPPA,
    SSPPD,
    SSPPM,
    SSPPMD,
    SSPPEA,
    SSPPED,
    SSPPEM,
    SSPRFBITS,
    SSPSEQ,
    SSPSCP,
    SSPPASS,
    SSPATTEN,
    SSP3DIM,
    SSPTREG
} WF_PGMTAG;
typedef enum {
    PSDREUSEP,
    PSDNEWP
} WF_PGMREUSE;
typedef struct PULSE {
    const char *pulsename;
    long ninsts;
    WF_HW_WAVEFORM_PTR wave_addr;
    int board_type;
    WF_PGMREUSE reusep;
    WF_PGMTAG tag;
    long addtag;
    int id;
    long ctrlfield;
    WF_INSTR_HDR *inst_hdr_tail;
    WF_INSTR_HDR *inst_hdr_head;
    WF_PROCESSOR wavegen_type;
    WF_PULSE_TYPES type;
    short resolution;
    struct PULSE *assoc_pulse;
    WF_PULSE_EXT *ext;
    int rfgroup;
    int ptx_flag;
    int seq_id;
    int rx_flag;
    WF_HW_WAVEFORM_PTR wave_addr_secssp[SEQ_CFG_MAX_CORES];
} WF_PULSE;
typedef WF_PULSE * WF_PULSE_ADDR;
typedef struct INST_QUEUE_NODE {
    WF_INSTR_HDR *instr;
    struct INST_QUEUE_NODE *next;
    struct INST_QUEUE_NODE *new_queue;
    struct INST_QUEUE_NODE *last_queue;
} WF_INSTR_QUEUE;
typedef long SEQUENCE_ENTRIES[SEQ_CFG_MAX_SEQ_IDS];
typedef struct ENTRY_PT_NODE{
    WF_PULSE_ADDR ssp_pulse;
    long *entry_addresses;
    long time;
    struct ENTRY_PT_NODE *next;
} SEQUENCE_LIST;
typedef enum rbw_update_type {OVERWRITE_NONE, OVERWRITE_OPRBW, OVERWRITE_OPRBW2} RBW_UPDATE_TYPE;
typedef enum filter_block_type {SCAN, PRESCAN} FILTER_BLOCK_TYPE;
typedef struct {
  float decimation;
  int tdaq;
  float bw;
  float tsp;
  int fslot;
  int outputs;
  int prefills;
  int taps;
  } FILTER_INFO;
typedef struct
{
    int fit_order;
    int total_bases_per_axis;
    int num_terms[3][56];
    float alpha[3][56][6];
    float tau[3][56][6];
    int termIndex2xyzOrderMapping[3][56];
    int xyzOrder2termIndexMapping[6][6][6];
} HOEC_CAL_INFO;
typedef struct
{
    float hoec_coef[56][3];
    int hoec_xorder[56];
    int hoec_yorder[56];
    int hoec_zorder[56];
} RDB_HOEC_BASES_TYPE;
typedef struct {
    int xfull;
    int yfull;
    int zfull;
    float xfs;
    float yfs;
    float zfs;
    int xrt;
    int yrt;
    int zrt;
    int xft;
    int yft;
    int zft;
    float xcc;
    float ycc;
    float zcc;
    float xbeta;
    float ybeta;
    float zbeta;
    float xirms;
    float yirms;
    float zirms;
    float xipeak;
    float yipeak;
    float zipeak;
    float xamptran;
    float yamptran;
    float zamptran;
    float xiavrgabs;
    float yiavrgabs;
    float ziavrgabs;
    float xirmspos;
    float yirmspos;
    float zirmspos;
    float xirmsneg;
    float yirmsneg;
    float zirmsneg;
    float xpwmdc;
    float ypwmdc;
    float zpwmdc;
} PHYS_GRAD;
typedef struct {
    int x;
    int xy;
    int xz;
    int xyz;
} t_xact;
typedef struct {
    int y;
    int xy;
    int yz;
    int xyz;
} t_yact;
typedef struct {
    int z;
    int xz;
    int yz;
    int xyz;
} t_zact;
typedef struct {
    int xrt;
    int yrt;
    int zrt;
    int xft;
    int yft;
    int zft;
} ramp_t;
typedef struct {
    int xrt;
    int yrt;
    int zrt;
    int xft;
    int yft;
    int zft;
    ramp_t opt;
    t_xact xrta;
    t_yact yrta;
    t_zact zrta;
    t_xact xfta;
    t_yact yfta;
    t_zact zfta;
    float xbeta;
    float ybeta;
    float zbeta;
    float tx_xyz;
    float ty_xyz;
    float tz_xyz;
    float tx_xy;
    float tx_xz;
    float ty_xy;
    float ty_yz;
    float tz_xz;
    float tz_yz;
    float tx;
    float ty;
    float tz;
    float xfs;
    float yfs;
    float zfs;
    float xirms;
    float yirms;
    float zirms;
    float xipeak;
    float yipeak;
    float zipeak;
    float xamptran;
    float yamptran;
    float zamptran;
    float xiavrgabs;
    float yiavrgabs;
    float ziavrgabs;
    float xirmspos;
    float yirmspos;
    float zirmspos;
    float xirmsneg;
    float yirmsneg;
    float zirmsneg;
    float xpwmdc;
    float ypwmdc;
    float zpwmdc;
    float scale_1axis_risetime;
    float scale_2axis_risetime;
    float scale_3axis_risetime;
} LOG_GRAD;
typedef struct {
    float xfs;
    float yfs;
    float zfs;
    int xrt;
    int yrt;
    int zrt;
    float xbeta;
    float ybeta;
    float zbeta;
    float xfov;
    float yfov;
    int xres;
    int yres;
    int ileaves;
    float xdis;
    float ydis;
    float zdis;
    float tsp;
    int osamps;
    float fbhw;
    int vvp;
    float pnsf;
    float taratio;
    float zarea;
} OPT_GRAD_INPUT;
typedef struct {
    float *agxw;
    int *pwgxw;
    int *pwgxwa;
    float *agyb;
    int *pwgyb;
    int *pwgyba;
    float *agzb;
    int *pwgzb;
    int *pwgzba;
    int *frsize;
    int *pwsamp;
    int *pwxgap;
} OPT_GRAD_PARAMS;


typedef __clock_t clock_t;



typedef __time_t time_t;


typedef __clockid_t clockid_t;
typedef __timer_t timer_t;
struct timespec
  {
    __time_t tv_sec;
    long int tv_nsec;
  };

struct tm
{
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;
  long int tm_gmtoff;
  __const char *tm_zone;
};


struct itimerspec
  {
    struct timespec it_interval;
    struct timespec it_value;
  };
struct sigevent;
typedef __pid_t pid_t;

extern clock_t clock (void) __attribute__ ((__nothrow__));
extern time_t time (time_t *__timer) __attribute__ ((__nothrow__));
extern double difftime (time_t __time1, time_t __time0)
     __attribute__ ((__nothrow__)) __attribute__ ((__const__));
extern time_t mktime (struct tm *__tp) __attribute__ ((__nothrow__));
extern size_t strftime (char *__restrict __s, size_t __maxsize,
   __const char *__restrict __format,
   __const struct tm *__restrict __tp) __attribute__ ((__nothrow__));

typedef struct __locale_struct
{
  struct __locale_data *__locales[13];
  const unsigned short int *__ctype_b;
  const int *__ctype_tolower;
  const int *__ctype_toupper;
  const char *__names[13];
} *__locale_t;
typedef __locale_t locale_t;
extern size_t strftime_l (char *__restrict __s, size_t __maxsize,
     __const char *__restrict __format,
     __const struct tm *__restrict __tp,
     __locale_t __loc) __attribute__ ((__nothrow__));

extern struct tm *gmtime (__const time_t *__timer) __attribute__ ((__nothrow__));
extern struct tm *localtime (__const time_t *__timer) __attribute__ ((__nothrow__));

extern struct tm *gmtime_r (__const time_t *__restrict __timer,
       struct tm *__restrict __tp) __attribute__ ((__nothrow__));
extern struct tm *localtime_r (__const time_t *__restrict __timer,
          struct tm *__restrict __tp) __attribute__ ((__nothrow__));

extern char *asctime (__const struct tm *__tp) __attribute__ ((__nothrow__));
extern char *ctime (__const time_t *__timer) __attribute__ ((__nothrow__));

extern char *asctime_r (__const struct tm *__restrict __tp,
   char *__restrict __buf) __attribute__ ((__nothrow__));
extern char *ctime_r (__const time_t *__restrict __timer,
        char *__restrict __buf) __attribute__ ((__nothrow__));
extern char *__tzname[2];
extern int __daylight;
extern long int __timezone;
extern char *tzname[2];
extern void tzset (void) __attribute__ ((__nothrow__));
extern int daylight;
extern long int timezone;
extern int stime (__const time_t *__when) __attribute__ ((__nothrow__));
extern time_t timegm (struct tm *__tp) __attribute__ ((__nothrow__));
extern time_t timelocal (struct tm *__tp) __attribute__ ((__nothrow__));
extern int dysize (int __year) __attribute__ ((__nothrow__)) __attribute__ ((__const__));
extern int nanosleep (__const struct timespec *__requested_time,
        struct timespec *__remaining);
extern int clock_getres (clockid_t __clock_id, struct timespec *__res) __attribute__ ((__nothrow__));
extern int clock_gettime (clockid_t __clock_id, struct timespec *__tp) __attribute__ ((__nothrow__));
extern int clock_settime (clockid_t __clock_id, __const struct timespec *__tp)
     __attribute__ ((__nothrow__));
extern int clock_nanosleep (clockid_t __clock_id, int __flags,
       __const struct timespec *__req,
       struct timespec *__rem);
extern int clock_getcpuclockid (pid_t __pid, clockid_t *__clock_id) __attribute__ ((__nothrow__));
extern int timer_create (clockid_t __clock_id,
    struct sigevent *__restrict __evp,
    timer_t *__restrict __timerid) __attribute__ ((__nothrow__));
extern int timer_delete (timer_t __timerid) __attribute__ ((__nothrow__));
extern int timer_settime (timer_t __timerid, int __flags,
     __const struct itimerspec *__restrict __value,
     struct itimerspec *__restrict __ovalue) __attribute__ ((__nothrow__));
extern int timer_gettime (timer_t __timerid, struct itimerspec *__value)
     __attribute__ ((__nothrow__));
extern int timer_getoverrun (timer_t __timerid) __attribute__ ((__nothrow__));

typedef struct timespec GEtimespec;
typedef unsigned short int dbkey_exam_type;
typedef short int dbkey_magic_type;
typedef short int dbkey_series_type;
typedef int dbkey_image_type;
typedef struct {
   char su_id[4];
   dbkey_magic_type mg_no;
   dbkey_exam_type ex_no;
   dbkey_series_type se_no;
   dbkey_image_type im_no;
} DbKey;
typedef char OP_NMRID_TYPE[12];
typedef struct {
 n16 rev;
 n16 length;
 OP_NMRID_TYPE req_nmrid;
 OP_NMRID_TYPE resp_nmrid;
 n16 opcode;
 n16 packet_type;
 n16 seq_num;
 n32 status;
 } OP_HDR1_TYPE;
typedef struct _OP_HDR_TYPE {
 s8 rev;
 s8 endian;
 n16 length;
 OP_NMRID_TYPE req_nmrid;
 OP_NMRID_TYPE resp_nmrid;
 n16 opcode;
 n16 packet_type;
 n16 seq_num;
 n16 pad;
 n32 status;
 } OP_HDR_TYPE;
typedef struct _OP_RECN_READY_TYPE
{
    DbKey dbkey;
    s32 seq_number;
    GEtimespec time_stamp;
    s32 run_no;
    s32 prep_flag;
    n32 patient_checksum;
    char clinicalCoilName[32];
} OP_RECN_READY_TYPE;
typedef struct _OP_RECN_READY_PACK_TYPE
{
    OP_HDR_TYPE hdr;
    OP_RECN_READY_TYPE req;
} OP_RECN_READY_PACK_TYPE;
typedef struct
{
    s32 somes32bitint;
    n16 somen16bitint;
    char somechar;
    unsigned long someulong;
    float somefloat;
} OP_RECN_FOO_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_RECN_FOO_TYPE req;
} OP_RECN_FOO_PACK_TYPE;
typedef struct _OP_RECN_START_TYPE
{
    s32 seq_number;
    GEtimespec time_stamp;
} OP_RECN_START_TYPE;
typedef struct _OP_RECN_START_PACK_TYPE
{
    OP_HDR_TYPE hdr;
    OP_RECN_START_TYPE req;
} OP_RECN_START_PACK_TYPE;
typedef struct
{
    s32 seq_number;
    s32 status;
    s32 aborted_pass_num;
} OP_RECN_SCAN_STOPPED_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_RECN_SCAN_STOPPED_TYPE req;
} OP_RECN_SCAN_STOPPED_PACK_TYPE;
typedef struct
{
    DbKey dbkey;
    s32 seq_number;
    char scan_initiator[12];
} OP_RECN_STOP_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_RECN_STOP_TYPE req;
} OP_RECN_STOP_PACK_TYPE;
typedef struct
{
    s32 seq_number;
} OP_RECN_IM_ALLOC_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_RECN_IM_ALLOC_TYPE req;
} OP_RECN_IM_ALLOC_PACK_TYPE;
typedef struct
{
    s32 seq_number;
} OP_RECN_SCAN_STARTED_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_RECN_SCAN_STARTED_TYPE req;
} OP_RECN_SCAN_STARTED_PACK_TYPE;
extern int fastcard_viewtable[2048];
typedef struct
{
    s32 table_size;
    s32 block_size;
    s32 first_entry_index;
    s32 table[256];
} OP_VIEWTABLE_UPDATE_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    OP_VIEWTABLE_UPDATE_TYPE pkt;
} OP_VIEWTABLE_UPDATE_PACK_TYPE;
typedef struct
{
    n64 mrhdr;
    n64 pixelhdr;
    n64 pixeldata;
    n64 raw_offset;
    n64 raw_receivers;
    n64 pixeldata3;
} MROR_ADDR_BLOCK;
typedef struct
{
    OP_HDR_TYPE hdr;
    MROR_ADDR_BLOCK mrab;
} MROR_ADDR_BLOCK_PKT;
typedef struct
{
    n32 recon_ts;
} MROR_RETRIEVAL_DONE_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    MROR_RETRIEVAL_DONE_TYPE retrieve_done;
} __attribute__((__may_alias__)) MROR_ADDR_BLOCK_PACK_TYPE;
typedef struct
{
    s32 exam_number;
    s32 calib_flag;
} SCAN_CALIB_INFO_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    SCAN_CALIB_INFO_TYPE info;
} SCAN_CALIB_INFO_PACK_TYPE;
typedef struct _OP_RECN_SIZE_CHECK_TYPE
{
    n64 total_bam_size;
    n64 total_disk_size;
} OP_RECN_SIZE_CHECK_TYPE;
typedef struct _OP_RECN_SIZE_CHECK_PACK_TYPE
{
    OP_HDR_TYPE hdr;
    OP_RECN_SIZE_CHECK_TYPE req;
} OP_RECN_SIZE_CHECK_PACK_TYPE;
typedef struct
{
    s32 exam_number;
} EXAM_SCAN_DONE_TYPE;
typedef struct
{
    OP_HDR_TYPE hdr;
    EXAM_SCAN_DONE_TYPE info;
} EXAM_SCAN_DONE_PACK_TYPE;
typedef struct _POSITION_DETECTION_DONE_TYPE
{
    n32 object_detected;
    f32 object_si_position_mm;
    f32 right_most_voxel_mm;
    f32 anterior_most_voxel_mm;
    f32 superior_most_voxel_mm;
    n32 checksum;
} POSITION_DETECTION_DONE_TYPE;
typedef struct _POSITION_DETECTION_DONE_PACK_TYPE
{
    OP_HDR_TYPE hdr;
    POSITION_DETECTION_DONE_TYPE info;
} POSITION_DETECTION_DONE_PACK_TYPE;
typedef struct _OP_CTT_UPDATE_TYPE
{
    s64 calUniqueNo;
    ChannelTransTableEntryType cttentry[4];
    n32 errorCode;
} OP_CTT_UPDATE_TYPE;
typedef struct _OP_CTT_UPDATE_PACK_TYPE
{
    OP_HDR_TYPE hdr;
    OP_CTT_UPDATE_TYPE req;
} OP_CTT_UPDATE_PACK_TYPE;
typedef enum PSD_PSC_CONTROL
{
    PSD_CONTROL_PSC_SKIP = -1,
    APS_CONTROL_PSC = 0,
    PSD_CONTROL_PSC_RUN = 1,
    PSD_CONTROL_PSC_SPECIAL = 2
} PSD_PSC_CONTROL_E;
typedef enum GRADSHIM_SELECTION
{
    GRADSHIM_OFF = 0,
    GRADSHIM_ON = 1,
    GRADSHIM_AUTO = 2
} GRADSHIM_SELECTION_E;
typedef enum PRESSCFH_EXCITATION_TYPE {
    PRESSCFH_SLICE = 1,
    PRESSCFH_SLAB = 2,
    PRESSCFH_SHIMVOL = 3,
    PRESSCFH_SHIMVOL_SLICE = 4,
    PRESSCFH_NONE = 5
} PRESSCFH_EXCITATION_TYPE_E;
typedef struct zy_index {
    n16 view;
    n16 slice;
    n16 flags;
} ZY_INDEX;
typedef struct zy_dist1 {
    float distance;
    n16 view;
    n16 slice;
    n16 flags;
} ZY_DIST1;
typedef struct _RDB_SLICE_INFO_ENTRY
{
    short pass_number;
    short slice_in_pass;
    float gw_point1[3];
    float gw_point2[3];
    float gw_point3[3];
    short transpose;
    short rotate;
    unsigned int coilConfigUID;
    float fov_freq_scale;
    float fov_phase_scale;
    float slthick_scale;
    float freq_loc_shift;
    float phase_loc_shift;
    float slice_loc_shift;
    short sliceGroupId;
    short sliceIndexInGroup;
} RDB_SLICE_INFO_ENTRY;
s32 seqCfgInit(SeqCfgInfo *pSeqCfg,
               const SeqCfgSysCfgInfo *pSysCfg,
               n32 debugOptions);
s32 seqCfgSetRfTxInfo(SeqCfgInfo *pSeqCfg,
                      n32 rfGroupId,
                      n32 txAmp,
                      n32 txCoilType,
                      n32 txNucleus,
                      n32 txChannels);
s32 seqCfgSetAppRfSeqUsage(SeqCfgInfo *pSeqCfg,
                           n32 rfGroupId,
                           n32 txSeqTypes,
                           n32 rxFlag,
                           n32 rxSeqTypes);
s32 seqCfgGetTxConfigs(const SeqCfgInfo *pSeqCfg,
                       n32 rfGroupId,
                       n32 *pTxConfigs,
                       n32 *pNumTxConfigs);
s32 seqCfgSetAppTxUsage(SeqCfgInfo *pSeqCfg,
                        n32 rfGroupId,
                        n32 numAppTxChannels);
s32 seqCfgValidate(SeqCfgInfo *pSeqCfg);
s32 seqCfgGetNumAppSeqs(const SeqCfgInfo *pSeqCfg,
                        n32 *pNumAppSeqs);
s32 seqCfgGetNumSeqs(const SeqCfgInfo *pSeqCfg,
                     n32 *pNumSeqs);
s32 seqCfgLookupSeqId(const SeqCfgInfo *pSeqCfg,
                      n32 rfGroupId,
                      n32 rfGroupTxChannel,
                      n32 rfTxRxType,
                      n32 seqType,
                      n32 *pSeqId);
s32 seqCfgLookupSeqIds(const SeqCfgInfo *pSeqCfg,
                       n32 rfGroupId,
                       n32 rfTxRxType,
                       n32 seqType,
                       n32 *pSeqIds,
                       n32 *pNumSeqIds);
const SeqCfgSeqInfo * seqCfgGetSeqInfo(const SeqCfgInfo *pSeqCfg,
                                       n32 seqId);
extern int cfswgut;
extern int cfswrfut;
extern int cfswssput;
extern int cfhwgut;
extern int cfhwrfut;
extern int cfhwssput;
typedef char EXTERN_FILENAME[80];
typedef char *EXTERN_FILENAME2;
extern INT EDC;
extern INT RDC;
extern INT ECF;
extern INT EMISC;
extern INT ESSL;
extern INT ESYNC;
extern INT ETHETA;
extern INT EUBL;
extern INT EXTATTEN;
extern INT EXTATTEN_Q;
extern INT PHASELAG_Q;
extern INT DDIQSWOC;
extern INT DB_I;
extern INT DB_Q;
extern INT SRI_C;
extern INT RFHUBSEL;
extern INT HUBIND;
extern INT R1IND;
extern INT ERFREQ;
extern INT ERPHASE;
extern INT RFLTRS;
extern INT RFLTRC;
extern INT RFUBL;
extern INT RSYNC;
extern INT RATTEN;
extern INT RRFSEL;
extern INT ESEL0;
extern INT ESEL1;
extern INT ESEL_ALL;
extern INT RSEL0;
extern INT RSEL1;
extern INT RSEL_ALL;
extern INT RATTEN_ALL;
extern INT RATTEN_1;
extern INT RATTEN_2;
extern INT RATTEN_3;
extern INT RATTEN_4;
extern INT RLOOP;
extern INT RHEADI;
extern INT RFAUX;
extern INT RFBODYI;
extern INT ECCF;
extern INT EDSYNC;
extern INT EMRST;
extern INT EMSSS1;
extern INT EMSSS2;
extern INT EMSSS3;
extern INT ESSP;
extern INT EXUBL;
extern INT EDDSP;
extern INT EATTEN_TEST;
extern INT ETHETA_L;
extern INT EOMEGA_L;
extern INT RBA;
extern INT RBL;
extern INT RFF;
extern INT RDSYNC;
extern INT RSAD;
extern INT RSUF;
extern INT RUBL;
extern INT RUBL_1;
extern INT RUBL_2;
extern INT RUBL_3;
extern INT RUBL_4;
extern INT RATTEN_FSEL;
extern INT RATTEN_3DB;
extern INT RATTEN_6DB;
extern INT RATTEN_12DB;
extern INT RATTEN_23DB;
extern INT FAST_EDC;
extern INT FAST_RDC;
extern INT FAST_RFLTRS;
extern INT RRFMISC;
extern INT LOSOURCE;
extern INT cfrfupa;
extern INT cfrfupd;
extern INT cfrfminunblk;
extern INT cfrfminblank;
extern INT cfrfminblanktorcv;
extern float cfrfampftconst;
extern float cfrfampftlinear;
extern float cfrfampftquadratic;
extern INT SEDC;
extern const INT opcode_xcvr[NUM_PSD_BOARD_TYPES][66];
extern int psd_board_type;
extern int psd_id_count;
extern int bd_index;
typedef struct
{
    n32 opcode;
    n32 source;
    n32 driverType;
    struct timespec
        timestamp;
    n32 txBufLength;
} HC_COMMAND_HDR_TYPE;
typedef struct
{
    n32 key;
    n32 value;
} HC_SET_VALUE_TYPE;
typedef struct
{
    HC_COMMAND_HDR_TYPE hdr;
    HC_SET_VALUE_TYPE req;
} HC_SET_VALUE_PACK_TYPE;
typedef struct
{
    n32 coil;
}RSP_COIL_COMMAND_TYPE;
typedef struct
{
    HC_COMMAND_HDR_TYPE hdr;
    RSP_COIL_COMMAND_TYPE req;
}RSP_COIL_COMMAND_PACK_TYPE;
typedef struct
{
    n32 select[2];
} RSP_SWITCH_SELECT_TYPE;
typedef struct
{
    HC_COMMAND_HDR_TYPE hdr;
    RSP_SWITCH_SELECT_TYPE req;
} RSP_SWITCH_SELECT_PACK_TYPE;
typedef struct
{
    n32 biasEnable0[3];
    n32 biasEnable1[3];
} RSP_BIAS_ENABLE_TYPE;
typedef struct
{
    HC_COMMAND_HDR_TYPE hdr;
    RSP_BIAS_ENABLE_TYPE req;
} RSP_BIAS_ENABLE_PACK_TYPE;
typedef struct
{
    n32 hubIndex;
} RSP_HUB_INDEX_TYPE;
typedef struct
{
    HC_COMMAND_HDR_TYPE hdr;
    RSP_HUB_INDEX_TYPE req;
} RSP_HUB_INDEX_PACK_TYPE;
typedef struct
{
    n32 command;
    n32 override;
    n32 mdsAddress;
    n32 registerAddress;
    n32 writeValue;
    n32 response;
    n32 responseData;
    n32 coil;
} RSP_STATE_TYPE;
typedef struct {
    s32 c_numviews;
    s32 c_curpass;
    s32 c_tr;
    s16 c_slq;
    s16 c_acq;
} CINE_PASS;
typedef struct {
    s16 c_arr;
    s16 c_op;
    s32 c_nview;
    s32 c_pview;
    s16 c_frame1;
    s16 c_frame2;
    s16 c_frame3;
    s16 c_frame4;
    s32 c_delay;
    s32 c_f1slice;
    s16 c_check;
    s16 c_collect;
    s16 c_send;
    s16 c_group;
} CINE_SEQ;
typedef struct
{
    n16 txAttenI;
    n16 txAttenQ;
    n16 txAttenDbI;
    n16 txAttenDbQ;
    n16 phaseLagQ;
} TX_SSP_SETTINGS;
s32 getTime( void );
STATUS rsp_add_psd_parameters( s16 first_arg );
STATUS rsp_error_abort( void );
void rsp_psd_err_log( );
STATUS rsp_psd_err_clear( s32 first_arg );
STATUS rsp_parameter_check_failure( char *function_name,
                                    char *parameter_name,
                                    s32 parameter_value,
                                    s32 parameter_lower_bound,
                                    s32 parameter_upper_bound );
STATUS rsp_fparameter_check_failure( char *function_name,
                                     char *parameter_name,
                                     f64 parameter_value,
                                     f64 parameter_lower_bound,
                                     f64 parameter_upper_bound );
STATUS rsp_resource_exceeded( char *function_name,
                              s16 resource_type,
                              s16 resource_index );
STATUS rsp_file_access_failure( char *function_name,
                                char *file_name_part_0,
                                char *file_name_part_1,
                                char *file_name_part_2,
                                char *file_name_part_3,
                                s16 file_failure_type );
STATUS rsp_hardware_access_failure( char *function_name,
                                    s32 parameter_1,
                                    s32 parameter_2,
                                    s32 parameter_3 );
STATUS getamprsp( SeqType seqType,
                  s16 *amplitude,
                  s16 hardware_type,
                  s32 index );
STATUS getcmonphase( s16 *cmonphase );
STATUS getcmonrate( s16 *cmonrate );
STATUS getctrlrsp( SeqType seqType,
                   s32 *ctrl_mask,
                   s32 index );
STATUS getecgrate( s16 *ecgrate );
STATUS geteosrsp( SeqType seqType,
                  s16 *eos_value,
                  s16 hardware_type,
                  s32 index );
STATUS geteoswupderr( s32 *update_errors );
STATUS getisiwupderr( s32 *update_errors );
STATUS getperiodrsp( SeqType seqType,
                     s32 *period,
                     s32 index );
STATUS getrespphase( s16 *respphase );
STATUS getresprate( s16 *resprate );
STATUS getrespcurrposition( s16 *respcurrpos );
STATUS getrespthreshold( s16 *respthreshold );
STATUS getrotate( s32 *rotation_matrix,
                  s16 slice_index );
STATUS getseqtime( s32 *seqtime );
STATUS getsspoutputs( s32 *sspoutputs );
STATUS gettrigger( s16 *trigger,
                   s16 slice_index );
s32 gettrigoccur( void );
STATUS getwaversp( SeqType seqType,
                   s32 *waveform_reference,
                   s32 index );
STATUS rspgettxatten( n16 *txAttenI,
                      n16 *txAttenQ,
                      f32 *phaseQ,
                      n16 exciter );
STATUS rspgettxattencal( TX_SSP_SETTINGS* pTxSspVals,
                         n16 exciter,
                         n16 txAttenDbI,
                         n16 txAttenDbQ,
                         f32 phaseQ );
STATUS rsphwoverride( s16 hardware_bitmask );
STATUS rsphwreadpoll( s16 *status,
                      s16 *data );
STATUS rsphwreadreq( s16 device,
                     s16 address );
STATUS rsphwwrite( s16 device,
                   s16 address,
                   s16 data );
STATUS rsptimedelay( s16 delay_time );
STATUS printdbg( const char *text_block, s16 debug_state );
STATUS rspcardiacinit( s16 trigs_to_skip,
                       s16 effective_tr );
STATUS rspexit( void );
STATUS rspinit( void );
STATUS rspsignalinit( s32 signal_number );
STATUS rspsignalreceive( s32 signal_number,
                         s32 *signal_status );
STATUS rspsignalsend( s32 signal_number,
                      s32 *signal_status );
STATUS rspsignalwait( s32 signal_number,
                      s32 *signal_status,
                      s32 timeout );
STATUS startseq( s16 slice_index,
                 s16 pause_attribute );
STATUS boffset( s32 *offsets );
STATUS isivector( s16 interrupt_number,
                  void (*interrupt_routine )( void ),
                  s16 fpflag );
STATUS ssivector( void (*interrupt_routine )(void),
                  s16 fpflag );
STATUS eosvector( void (*interrupt_routine )( ) );
STATUS forceupdate( void );
void simssifunction( void );
void rspstarttimer( void );
s32 rspreadtimer( void );
void rsptimerstart( void );
void rsptimersample( void );
s32 rsptimergetms( void );
s32 rsptimergetus( void );
s32 rsptimergetsec( void );
s32 rsptimergetnano( void );
STATUS rspresetqueues( void );
STATUS rspqueueinit( s16 queuesize );
STATUS rspresetinst( s32 *maxinst );
void rspfreepulsemem( void );
STATUS setamprsp( SeqType seqType,
                  s16 amplitude,
                  s16 hardware_type,
                  s32 index );
STATUS setampimmrsp( SeqType seqType,
                     s16 amplitude,
                     s16 hardware_type,
                     s32 index );
STATUS setsspamprsp( SeqType seqType,
                     s32 amplitude,
                     s16 hardware_type,
                     s32 index );
STATUS setperiodrsp( SeqType seqType,
                     s32 period,
                     s32 index );
STATUS setwaversp( SeqType seqType,
                   s32 waveform_reference,
                   s32 index );
STATUS iwait( s32 *index,
              SeqType seqType,
              s32 period,
              s16 eos_value );
STATUS iwave( s32 *index,
              SeqType seqType,
              s32 waveform_reference,
              s32 period,
              s32 amplitude,
              s16 eos_value );
STATUS setctrlrsp( SeqType seqType,
                   s32 ctrl_mask,
                   s32 index );
STATUS seteosrsp( SeqType seqType,
                  s16 eos_value,
                  s16 hardware_type,
                  s32 index );
STATUS sspextloadrsp( SeqType seqType,
                      s32 *ssp_block,
                      s32 index,
                      s16 resolution,
                      s16 direction,
                      s16 s_attribute );
STATUS ssploadrsp( SeqType seqType,
                   s16 *ssp_block,
                   s32 index,
                   s16 resolution,
                   s16 direction,
                   s16 s_attribute );
STATUS movewaveimmrsp( SeqType seqType,
                       s16 *wave_block,
                       s32 index,
                       s16 resolution,
                       s16 direction );
STATUS setcmonmode( s16 periods_averaged,
                    s16 offset_factor );
STATUS setditherrsp( s16 enable_flag,
                     s16 max_dither_value );
void setfastcardtrig( void );
void setfastcardecgtrig( void );
STATUS setresphistmode( s16 hist_mode,
                        s16 roll_time );
STATUS setresphistparam( s16 hist_mode,
                         s16 roll_time,
                         s16 update_period );
STATUS setrfconfig( s16 rfconfig );
STATUS setseqcfg( SeqCfgInfo *seqcfginfo );
STATUS setrotate( s32 *rotation_matrix,
                  s16 slice_index );
STATUS setrotatearray( s16 number_of_rotates,
                       s32 *rotation_matrix_array );
STATUS setrotateimm( s32 *rotation_matrix,
                     s16 update_type );
STATUS setscantimeauto( void );
STATUS setscantimeimm( s32 pidmode,
                       f32 pitscan,
                       s32 piviews,
                       f32 pitslice,
                       s32 opslicecnt );
STATUS setscantimemanual( void );
STATUS setscantimestart( void );
STATUS setscantimestop( void );
STATUS setshimimm( s16 *shim_array,
                   s16 update_type );
STATUS setssitime( s32 ssi_time );
STATUS settrigger( s16 trigger,
                   s16 slice_index );
STATUS settriggerarray( s16 number_of_triggers,
                        s32 *trigger_array );
STATUS setwatchdogrsp( s32 time_count );
STATUS setgstsuspend( void );
STATUS setgstresume( void );
void setrcvportimm( s16 port );
void setmcswitchselectimm( n32 select, n32 selectSof );
void setmcbiasenableimm( RSP_BIAS_ENABLE_TYPE *bias_enable );
void sethubindeximm( n32 hub_index );
STATUS cineinit( CINE_PASS *cn_cine_pass_info );
STATUS getcineinfo( CINE_SEQ *cn_cine_info );
STATUS getexorindex( s16 *respindex,
                     s16 group_number,
                     s16 unscaled_phase );
STATUS getrespindex( s16 *respindex,
                     s16 group_number );
STATUS updaterespindex( s16 *respindex,
                        s16 group_number );
STATUS respcompinit( s16 number_of_groups,
                     s16 number_of_frames,
                     s16 threshold_error,
                     s16 number_of_overscans );
void rsp_exor_error( s32 error_code,
                     s32 abcode,
                     s32 arg1,
                     s32 arg2,
                     char *procedure );
void resetcinescantype( void );
void find_phase_limits( s16 group_number,
                        s16 desired_phase,
                        s16 *low_limit,
                        s16 *high_limit );
void replace_phase( s16 low_bound,
                    s16 high_bound,
                    s8 direction_flag,
                    s16 group_number );
void rsp_exor_save( s16 group_number );
void setup_phase_table( void );
void update_phase_table( s16 group_number,
                         s16 low_limit,
                         s16 high_limit );
STATUS rspexorreverse( void );
STATUS rsp_os_histogram( void );
STATUS rsp_os_error( s16 start_group,
                     s16 end_group );
STATUS rsp_os_init( s16 start_group,
                    s16 end_group );
void rsp_os_candidate( s32 upper_bound,
                       s32 lower_bound,
                       s32 group );
void rsp_os_update( s32 lower_bound,
                    s32 upper_bound,
                    s32 group );
STATUS rsp_os_profile( s16 start_group,
                       s16 end_group );
void rsp_os_replace( s16 group,
                     s16 os_view,
                     s16 replacement_os_view );
s32 wextwave( SeqType seqType,
              s16 resolution,
              const char *pwave_path );
s32 uextwave( s16 *pextwave,
              s16 resolution,
              const char *pwave_path );
s32 wreserve( SeqType seqType,
              s16 resolution );
STATUS ureserve( s16 *preserve,
                 s16 resolution );
s32 wbits( SeqType seqType,
           s16 resolution,
           s16 *pbits );
STATUS ubits( s16 *pwave,
              s16 resolution,
              s16 *pbits );
s32 wconstant( SeqType seqType,
               s16 resolution,
               s16 amplitude );
s32 wconstantssp( SeqType seqType,
                  s16 resolution,
                  s16 amplitude );
STATUS uconstant( s16 *pconstant,
                  s16 resolution,
                  s16 amplitude );
s32 wramp( SeqType seqType,
           s16 resolution,
           s16 start_amp,
           s16 end_amp,
           f64 beta );
STATUS uramp( s16 *pramp,
              s16 resolution,
              s16 start_amp,
              s16 end_amp,
              f64 beta );
s32 wsinusoid( SeqType seqType,
               s16 resolution,
               s16 amplitude,
               f64 start_phase,
               f64 phase_length,
               s16 offset );
s32 usinusoid( s16 *psinusoid,
               s16 resolution,
               s16 amplitude,
               f64 start_phase,
               f64 phase_length,
               s16 offset );
s32 wsinc( SeqType seqType,
           s16 resolution,
           s16 amplitude,
           f64 sinc_cycles,
           f64 alpha );
s32 usinc( s16 *psinc,
           s16 resolution,
           s16 amplitude,
           f64 sinc_cycles,
           f64 alpha );
s32 whadamard( SeqType seqType,
               s16 resolution,
               s16 amplitude,
               f64 separation,
               f64 sinc_cycles,
               f64 alpha );
s32 uhadamard( s16 *phadamard,
               s16 resolution,
               s16 amplitude,
               f64 separation,
               f64 sinc_cycles,
               f64 alpha );
extern CHAR *pgen_error_hdrs[];
extern CHAR *pgen_error_message[];


extern void *memcpy (void *__restrict __dest,
       __const void *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern void *memmove (void *__dest, __const void *__src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));

extern void *memccpy (void *__restrict __dest, __const void *__restrict __src,
        int __c, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));

extern void *memset (void *__s, int __c, size_t __n) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));
extern int memcmp (__const void *__s1, __const void *__s2, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern void *memchr (__const void *__s, int __c, size_t __n)
      __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));


extern char *strcpy (char *__restrict __dest, __const char *__restrict __src)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strncpy (char *__restrict __dest,
        __const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strcat (char *__restrict __dest, __const char *__restrict __src)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strncat (char *__restrict __dest, __const char *__restrict __src,
        size_t __n) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strcmp (__const char *__s1, __const char *__s2)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strncmp (__const char *__s1, __const char *__s2, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strcoll (__const char *__s1, __const char *__s2)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern size_t strxfrm (char *__restrict __dest,
         __const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2)));

extern int strcoll_l (__const char *__s1, __const char *__s2, __locale_t __l)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2, 3)));
extern size_t strxfrm_l (char *__dest, __const char *__src, size_t __n,
    __locale_t __l) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2, 4)));
extern char *strdup (__const char *__s)
     __attribute__ ((__nothrow__)) __attribute__ ((__malloc__)) __attribute__ ((__nonnull__ (1)));
extern char *strndup (__const char *__string, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__malloc__)) __attribute__ ((__nonnull__ (1)));

extern char *strchr (__const char *__s, int __c)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern char *strrchr (__const char *__s, int __c)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));


extern size_t strcspn (__const char *__s, __const char *__reject)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern size_t strspn (__const char *__s, __const char *__accept)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strpbrk (__const char *__s, __const char *__accept)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strstr (__const char *__haystack, __const char *__needle)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strtok (char *__restrict __s, __const char *__restrict __delim)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2)));

extern char *__strtok_r (char *__restrict __s,
    __const char *__restrict __delim,
    char **__restrict __save_ptr)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2, 3)));
extern char *strtok_r (char *__restrict __s, __const char *__restrict __delim,
         char **__restrict __save_ptr)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2, 3)));

extern size_t strlen (__const char *__s)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));

extern size_t strnlen (__const char *__string, size_t __maxlen)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));

extern char *strerror (int __errnum) __attribute__ ((__nothrow__));

extern int strerror_r (int __errnum, char *__buf, size_t __buflen) __asm__ ("" "__xpg_strerror_r") __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (2)));
extern char *strerror_l (int __errnum, __locale_t __l) __attribute__ ((__nothrow__));
extern void __bzero (void *__s, size_t __n) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));
extern void bcopy (__const void *__src, void *__dest, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern void bzero (void *__s, size_t __n) __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1)));
extern int bcmp (__const void *__s1, __const void *__s2, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *index (__const char *__s, int __c)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern char *rindex (__const char *__s, int __c)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1)));
extern int ffs (int __i) __attribute__ ((__nothrow__)) __attribute__ ((__const__));
extern int strcasecmp (__const char *__s1, __const char *__s2)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern int strncasecmp (__const char *__s1, __const char *__s2, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__pure__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strsep (char **__restrict __stringp,
       __const char *__restrict __delim)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *strsignal (int __sig) __attribute__ ((__nothrow__));
extern char *__stpcpy (char *__restrict __dest, __const char *__restrict __src)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *stpcpy (char *__restrict __dest, __const char *__restrict __src)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *__stpncpy (char *__restrict __dest,
   __const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));
extern char *stpncpy (char *__restrict __dest,
        __const char *__restrict __src, size_t __n)
     __attribute__ ((__nothrow__)) __attribute__ ((__nonnull__ (1, 2)));

STATUS EpicConf(void);
extern SHORT DAB_length[2];
extern SHORT DAB_bits[2][16];
extern LONG DAB_start;
extern SHORT PROPDAB_length[2];
extern SHORT PROPDAB_bits[2][23];
extern LONG PROPDAB_start;
extern SHORT XTR_length[2];
extern SHORT XTR_bits[2][18];
extern LONG XTR_start;
extern SHORT RBA_length[2];
extern SHORT RBA_bits[2][12];
extern LONG RBA_start;
extern SHORT FAST_RBA_length;
extern SHORT FAST_RBA_bits[];
extern LONG FAST_RBA_start;
extern SHORT FAST_PROG_length;
extern SHORT FAST_PROG_bits[];
extern LONG FAST_PROG_start;
extern SHORT FAST_DIAG_length;
extern SHORT FAST_DIAG_bits[];
extern LONG FAST_DIAG_start;
extern SHORT SUF_length;
extern SHORT SUF_bits[];
extern LONG SUF_start;
extern SHORT HSDAB_length;
extern SHORT HSDAB_bits[];
extern SHORT HSDAB_start;
extern SHORT DIFFDAB_length;
extern SHORT DIFFDAB_bits[];
extern SHORT DIFFDAB_start;
extern SHORT COPY_DAB_length;
extern SHORT COPY_DAB_bits[];
extern SHORT COPY_DAB_start;
extern SHORT txatten_bits[17];
extern SHORT DIM_length;
extern SHORT DIM_bits[];
extern LONG DIM_start;
extern SHORT DIM2_length;
extern SHORT DIM2_bits[];
extern LONG DIM2_start;
extern SHORT sq_sync_length[2];
extern SHORT sq_sync_bits[2][13];
extern SHORT sq_lockout_length;
extern SHORT sq_lockout_bits[];
extern SHORT pass_length;
extern SHORT pass_bits[];
extern LONG pass_start;
extern SHORT ATTEN_unlock_length[2];
extern SHORT ATTEN_unlock_bits[2][6];
extern LONG ATTEN_start;
extern INT psd_gxwcnt;
extern INT psd_pulsepos;
extern INT psd_eparity;
extern FLOAT psd_etbetax, psd_etbetay;
extern CHAR psd_epstring[];
extern LONG rfupa;
extern LONG rfupd;
extern LONG rfublwait;
extern INT EDC;
extern INT RDC;
extern INT ECF;
extern INT EMISC;
extern INT ESSL;
extern INT ESYNC;
extern INT ETHETA;
extern INT EUBL;
extern INT EXTATTEN;
extern INT ERFREQ;
extern INT ERPHASE;
extern INT RFLTRS;
extern INT RFLTRC;
extern INT RFUBL;
extern INT RSYNC;
extern INT RATTEN;
extern INT RRFSEL;
extern INT ESEL0;
extern INT ESEL1;
extern INT ESEL_ALL;
extern INT RSEL0;
extern INT RSEL1;
extern INT RSEL_ALL;
extern INT RATTEN_ALL;
extern INT RATTEN_1;
extern INT RATTEN_2;
extern INT RATTEN_3;
extern INT RATTEN_4;
extern INT RLOOP;
extern INT RHEADI;
extern INT RFAUX;
extern INT RFBODYI;
extern INT ECCF;
extern INT EDSYNC;
extern INT EMRST;
extern INT EMSSS1;
extern INT EMSSS2;
extern INT EMSSS3;
extern INT ESSP;
extern INT EXUBL;
extern INT EDDSP;
extern INT EATTEN_TEST;
extern INT ETHETA_L;
extern INT EOMEGA_L;
extern INT RBA;
extern INT RBL;
extern INT RFF;
extern INT RDSYNC;
extern INT RSAD;
extern INT RSUF;
extern INT RUBL;
extern INT RUBL_1;
extern INT RUBL_2;
extern INT RUBL_3;
extern INT RUBL_4;
extern INT RATTEN_FSEL;
extern INT RATTEN_3DB;
extern INT RATTEN_6DB;
extern INT RATTEN_12DB;
extern INT RATTEN_23DB;
extern INT FAST_EDC;
extern INT FAST_RDC;
extern INT FAST_RFLTRS;
extern INT RFHUBSEL;
extern INT HUBIND;
extern INT R1IND;
extern INT EXTATTEN_Q;
extern INT DB_I;
extern INT DB_Q;
extern INT PHASELAG_Q;
extern INT SRI_C;
typedef enum aptype_e
{
    UNKNOWN = 0,
    REFLEX100,
    REFLEX200,
    REFLEX400,
    REFLEX800
} aptype_t;
aptype_t check_apconfig( const int e_flag );
STATUS init_apconfig( const int n_proc,
                      const float memsize,
                      const int proc_type,
                      const int e_flag );
typedef enum dbLevel_e
{
    NODEBUG = 0,
    DBLEVEL1,
    DBLEVEL2,
    DBLEVEL3,
    DBLEVEL4,
    DBLEVEL5,
    DBLEVEL6,
    DBLEVEL7,
    DBLEVEL8,
    DBLEVEL9,
    DBLEVEL10
} dbLevel_t;
    int appendGradientModelOrganizationDirectory( char* directory,
                                                  const size_t dirLenMax );
    void
    appendUniquePsdIdSeconds( char* fileName,
                              const size_t fileNameSize );
    void printDebug( const dbLevel_t level,
                     const dbLevel_t dbLevel,
                     const char *functionName,
                     const char *format,
                     ... );
    void setDebugFileExt( char * fileName,
                          const size_t fileNameSize,
                          const int fileFlag );
    void getDebugFile( char * debugFileName,
                       const size_t debugFileNameSize,
                       const char * baseFileName,
                       const int fileFlag,
                       const int checkMxPath );
    FILE * openGradientModelDebugFile( const int fileFlag,
                                       const int checkMxPath,
                                       const int appendFlag );
typedef struct {
   float real;
   float imag;
} COMPLEX;
typedef struct
{
    void* fftwPlan;
    int N;
    int dir;
} PLAN_info;
typedef struct
{
    int nelems;
    int logb2_nelems;
    int numPowOf2Plans;
    COMPLEX* setupTmpv;
    void** FFTW_fplansBA;
    void** FFTW_fplansBU;
    void** FFTW_fplansFA;
    void** FFTW_fplansFU;
    PLAN_info FFTW_fplanBA_fft1_cin;
    PLAN_info FFTW_fplanBU_fft1_cin;
    PLAN_info FFTW_fplanFA_fft1_cin;
    PLAN_info FFTW_fplanFU_fft1_cin;
} FFT_setup;
int CFFT( COMPLEX*,
           const int,
           const int );
void CFFT_version();
typedef struct
{
        long I;
        long Q;
} lcomplex;
typedef struct
{
        double I;
        double Q;
} dcomplex;
extern COMPLEX FCadd( const COMPLEX a,
                       const COMPLEX b );
extern COMPLEX FCsub( const COMPLEX a,
                       const COMPLEX b );
extern COMPLEX FCneg( const COMPLEX a );
extern COMPLEX FCmul( const COMPLEX a,
                       const COMPLEX b );
extern COMPLEX FCipow( const COMPLEX a,
                        const int z );
extern COMPLEX FCdiv( const COMPLEX a,
                       const COMPLEX b );
extern COMPLEX FComplex( const float real,
                          const float imaginary );
extern float FCabs( const COMPLEX z );
extern float FCang( const COMPLEX z );
extern COMPLEX FConjg( const COMPLEX z );
extern COMPLEX FCsqrt( const COMPLEX z );
extern COMPLEX FRCmul( const COMPLEX a,
                        const float x );
extern COMPLEX FRCdiv( const COMPLEX a,
                        const float x );
extern COMPLEX FCexp( const COMPLEX a );
extern void hprintComplex( const COMPLEX a,
                           const char n );
extern float FCdot( const COMPLEX a,
                    const COMPLEX b );
extern float FCang1( const COMPLEX a,
                     const COMPLEX b );
extern float FCang2( const COMPLEX a,
                     const COMPLEX b );
extern void FCswap2( COMPLEX * const a,
                     COMPLEX * const b );
extern void FCfft_shift( COMPLEX * a,
                         int const length );
extern void FCfft_1d( COMPLEX * const a,
                      const int complex_element_cnt,
                      const int iopt );
typedef struct mss_result_s
{
    INT minseqgrad;
    INT minseqcoil;
    INT minseqcoilx;
    INT minseqcoily;
    INT minseqcoilz;
    INT minseqcoilburst;
    INT minseqcoilvrms;
    INT minseqgrddrv;
    INT minseqgrddrv_case;
    INT minseqgpm;
    INT minseqgpm_maxpow;
    INT minseqpdu;
    INT minseqps;
    INT minseqpdubreaker;
    INT minseqxfmr;
    INT minseqcoilcool;
    INT minseqsyscool;
    INT minseqccucool;
    INT minseqcable;
    INT minseqcable_maxpow;
    INT minseqcableburst;
    INT minseqchoke;
    INT minseqbusbar;
    FLOAT vol_ratio_est_req;
    FLOAT burstcooltime;
    FLOAT xa2s;
    FLOAT ya2s;
    FLOAT za2s;
    FLOAT ACxpower;
    FLOAT ACypower;
    FLOAT ACzpower;
    FLOAT ACpowerSum_Watts;
    FLOAT cableCurrentRMSmax_Amps;
    FLOAT peakSPL;
    FLOAT avgSPL;
    FLOAT avgSPL_non_wt;
    FLOAT SGAlosslow[3];
    FLOAT SGAlosshigh[3];
    FLOAT XPSpowerhigh[3];
    FLOAT XPSpowerlow[3];
    INT minseqcoil_3axis;
    INT minseqcoil_each[3];
    INT minseqcable_each[3];
    INT minseqcable_maxpow_each[3];
    INT minseqgrddrv_case_each[3];
    INT minseqgrddrv_each[3];
    INT minseqgpm_PDU;
    INT minseqgpm_each[3];
    INT minseqgpm_LV_each[3];
    INT minseqgpm_HV_each[3];
    INT minseqgpm_Itank;
    INT minseqgpm_maxpow_3axis;
    INT minseqgpm_maxpow_each[3];
    INT minseqps_each[3];
    INT minseqchoke_each[3];
    INT minseqbusbar_each[3];
} mss_result_t;
typedef struct mss_hw_s
{
    double amp2Gauss[3];
    double maxCurrent[3];
    double gcontirms;
    double irmsPerAxis[3][3];
    int gradamp;
    int gcoiltype;
    int gradmode;
    int srmode;
    int updateTime;
    float coilDC_gain;
    float coilDC_Rx;
    float coilDC_Ry;
    float coilDC_Rz;
    float coilDC_Lx;
    float coilDC_Ly;
    float coilDC_Lz;
    float coilAC_gain;
    float coilAC_xgain;
    float coilAC_ygain;
    float coilAC_zgain;
    float coilAC_power;
    float coilAC_power_1axis;
    float coilAC_powerburst;
    float coilAC_temp_base_burst;
    float coilAC_temp_limit_burst;
    float coilAC_timeconstant_burst;
    float coilAC_RxA;
    float coilAC_RyA;
    float coilAC_RzA;
    float coilAC_RxB;
    float coilAC_RyB;
    float coilAC_RzB;
    float coilAC_RxC;
    float coilAC_RyC;
    float coilAC_RzC;
    float coilAC_lumpR1x;
    float coilAC_lumpR1y;
    float coilAC_lumpR1z;
    float coilAC_lumpR2x;
    float coilAC_lumpR2y;
    float coilAC_lumpR2z;
    float coilAC_lumpL1x;
    float coilAC_lumpL1y;
    float coilAC_lumpL1z;
    float coilAC_lumpL2x;
    float coilAC_lumpL2y;
    float coilAC_lumpL2z;
    float coilAC_lumpL3x;
    float coilAC_lumpL3y;
    float coilAC_lumpL3z;
    float coilAC_lumpR3x;
    float coilAC_lumpR3y;
    float coilAC_lumpR3z;
    float coilAC_lumpL4x;
    float coilAC_lumpL4y;
    float coilAC_lumpL4z;
    float coilAC_lumpR4x;
    float coilAC_lumpR4y;
    float coilAC_lumpR4z;
    float coilAC_lumpR5x;
    float coilAC_lumpR5y;
    float coilAC_lumpR5z;
    float coilAC_lumpCx;
    float coilAC_lumpCy;
    float coilAC_lumpCz;
    float coilAC_lumpRcable;
    float coilAC_lumpRoutputFilter;
    float coilAC_lumpLoutputFilter;
    float coilAC_timeres;
    int coilAC_fftpoints;
    float coilQAC_A[7];
    float coilQAC_B[3];
    float coilQAC_maxtime;
    float coilQAC_const;
    float coilQAC_heat_maxtime;
    float coilQAC_heat_slope;
    float coilQAC_heat_const;
    float coil_irmslimit_total;
    float xgd_timeres;
    float xgd_cableirmslimit;
    float xgd_cableirmslimit_burst;
    float xgd_cabletimeconstant_burst;
    float xgd_chokepowerlimit;
    float xgd_busbartemplimit;
    float xps_avglvpwrlimit;
    float xps_avghvpwrlimit;
    float xps_avgpdulimit;
    float xgd_IGBTtemplimit;
    float xfd_power_limit;
    float xfd_temp_limit;
    int ecc_modeling;
    float ecc_xtau1;
    float ecc_xtau2;
    float ecc_xtau3;
    float ecc_ytau1;
    float ecc_ytau2;
    float ecc_ytau3;
    float ecc_ztau1;
    float ecc_ztau2;
    float ecc_ztau3;
    float ecc_xalpha1;
    float ecc_xalpha2;
    float ecc_xalpha3;
    float ecc_yalpha1;
    float ecc_yalpha2;
    float ecc_yalpha3;
    float ecc_zalpha1;
    float ecc_zalpha2;
    float ecc_zalpha3;
    float ps_avgpwrLimit;
    float ps_avgpwrLimit_total;
    float ps_pkpwrLimit;
    float ps_pkpwrLimit_total;
    float pdu_avgpwrLimit;
    float pdu_pkpwrLimit;
    float pdu_breakercurrentLimit;
    float cooling_coilLimit;
    float cooling_ccuLimit;
    float cooling_sysLimit;
    float coilACpower_axisPer;
    int cooling_model;
    float xfmr_rmsLimit;
    float coil_vrmsLimit;
    float resist_wattLimit;
    int seq_repeat_rate;
} mss_hw_t;
typedef struct mss_wave_s
{
    FLOAT *time;
    FLOAT *ampl[3];
    FLOAT *pul_type[3];
    INT num_points;
    INT num_iters;
    INT encode_mode;
    INT burstreps;
    FLOAT *resampledTime;
    FLOAT *resampledCurrent[3];
    COMPLEX *resampledCurrentFFT[3];
    FLOAT *resampledVoltage[3];
    FLOAT *resampledPower[3];
    INT resampledTotalPoints;
    FLOAT *amplifierLoss[3];
    FLOAT resampledTimeStep;
    COMPLEX *netLoad[3];
    float *Pcoil_ladder[3];
    float *Pcoil_ladderWorst[3];
} mss_wave_t;
typedef struct mss_waveforms_s
{
    mss_wave_t *average;
    mss_wave_t *maximum;
} mss_waveforms_t;
typedef struct mss_geo_s
{
    SCAN_INFO *lscninfo;
    INT n_slices;
} mss_geo_t;
typedef struct mss_flags_s
{
    int hiFreqMode;
    int coilCompositeRMSMethod;
    int psCompositeIntegralMethod;
    int sgaGradDriverMethod;
    int gradHeatFile;
    int gradCoilMethod;
    int burstMode;
    int stopwatchFlag;
    int cveval_counter;
    int value_system_flag;
    int e_flag;
    dbLevel_t debug;
    int xgd_optimization;
    int eccupdatetime;
    int checkMxPath;
    int runCapBankModel;
    int acoustic_flag;
    int enable_grad_model_logging;
} mss_flags_t;
INT isCoilDBEnabled( void );
void getTxAndExciter( INT *txIndex,
                      INT *exciterIndex,
                      INT *exciterUsed,
                      INT *numTxIndexUsed,
                      const COIL_INFO coilinfo[],
                      const INT ncoils );
INT getTxIndex( const COIL_INFO coilinfo );
void getCoilIndex( INT *coilIndex,
                   INT *indexFilled,
                   const COIL_INFO coilinfo[],
                   const INT ncoils,
                   const INT txIndex );
s32 getCoilAtten( void );
INT getNumTxCoils( const COIL_INFO coilinfo[],
                   const INT ncoils );
f32 getTxCoilMaxB1Peak( void );
n32 getTxCoilType( void );
n32 getTxAmp( void );
n32 getTxNucleus( void );
n32 getTxChannels( void );
n32 getRxCoilType( void );
n32 getRxNumChannels( void );
n32 getVolRxNumChannels( void );
n32 getTxPosition( void );
n32 getAps1Mod( void );
n32 getAps1ModPlane( void );
f32 getAps1ModFov( void );
f32 getAps1ModSlThick( void );
f32 getAps1ModPsRloc( void );
f32 getAps1ModPsTloc( void );
void getSilentSpec( const INT silent,
                    INT * const Gctrl,
                    FLOAT * const Glimit,
                    FLOAT * const Srate );
void getRioGradSpec( const INT rio_gradspec_flag,
                    INT * const Gctrl,
                    FLOAT * const Glimit,
                    FLOAT * const Srate );
void getRioExtremeGradSpec(const INT rio_40170_gradspec_flag,
                          INT * const Gctrl,
                          FLOAT * const Glimit,
                          FLOAT * const Srate);
PHYS_GRAD getOrigphygrd( void );
int is3TeslaWideSystem( void );
int isDVWideSystem( void );
int isIceHardware( void );
int isHeadNeckTxPosition( void );
int isDVSystem( void );
int isSVSystem( void );
int isKizunaSystem( void );
int isRioSystem( void);
int isK15TSystem( void );
int isValueSystem( void);
int isStarterSystem( void);
STATUS configSystem( void );
STATUS entrytabinit( ENTRY_POINT_TABLE *entryPoint,
                     const INT numEntries );
STATUS setsysparms( void );
STATUS setupConfig( void );
STATUS set_grad_spec( const INT spec_ctrl,
                      FLOAT g_max,
                      FLOAT s_rate,
                      const INT duty_limit,
                      const INT debug );
STATUS UpdateEntryTabRecCoil( ENTRY_POINT_TABLE * const entryTab,
                              const INT index );
void copyCoilInfo(void);
typedef struct s_list {
    INT time;
    FLOAT ampl;
    INT ptype;
} t_list;
    STATUS calcChecksumScanInfo(
        n32 *chksum_val, const SCAN_INFO *si, const int numslices, int psdcrucial_debug
    );
    void dump_vol_shift_scale(
        const int num_slice
    );
    STATUS endview(
        INT resolution,
        INT *last_phase_iamp
    );
    long hostToRspRotMat(
        const float fval
    );
    STATUS orderslice(
        const INT acqType, const INT numLocs, const INT locsPerPass,
        const INT gating
    );
    STATUS orderslice2(
        const INT acqType, const INT numLocs, const INT numAcqs, INT *sl_pass,
        INT *prescan_pass, const INT gating
    );
    STATUS scalerotmatscrc(
        long (*rsprot)[9], const LOG_GRAD *lgrad, const PHYS_GRAD *pgrad,
        const INT slquant, const INT debug, const INT rampdir, const n32 chksum_rampdir
    );
    STATUS setupphasetable(
        SHORT *phaseTab, INT respCompType, INT phaseRes
    );
    STATUS set_echo_flip(
        int *rhdacqctrl, n32 * chksum_rhdacqctrl, const int eepf, const int oepf,
        const int eeff, const int oeff
    );
    extern STATUS (*typ3dmscat)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislab, INT numLocs, INT numSlabs, INT numAcqs
    );
    extern STATUS (*typ3dmsncat)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislab, INT numLocs, INT numSlabs, INT numAcqs
    );
    extern STATUS (*typcard)(
        DATA_ACQ_ORDER data_acq_order[], INT *indexrot, INT numLocs, INT maxphase
    );
    extern STATUS (*typcat)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs,
        INT numAcqs, INT opimode, INT oppseq, INT opflaxall,
        INT oppomp, INT rhnpomp
    );
    extern STATUS (*typcatxrr)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs,
        INT numReps
    );
    extern STATUS (*typfsa)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT *locsPass, INT numAcqs
    );
    extern STATUS (*typncat)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs,
        INT opimode, INT oppseq, INT opflaxall
    );
    extern STATUS (*typncatxrr)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs,
        INT numReps
    );
    extern STATUS (*typncatPomp)(
        DATA_ACQ_ORDER *tempAcqTab, INT *pislice, INT numLocs, INT numAcqs
    );
    extern STATUS (*typssfse)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT *locsPerPass, INT numAcqs, INT orderType
    );
    extern STATUS (*typssfseint)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs
    );
    extern STATUS (*typssfseseq)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs
    );
    extern STATUS (*typxrr)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs
    );
    extern STATUS (*typxrrPomp)(
        DATA_ACQ_ORDER *tempAcqTab, INT *pislice, INT numLocs, INT numAcqs
    );
    extern STATUS (*typncatoptflair)(
        DATA_ACQ_ORDER data_acq_order[], INT *pislice, INT numLocs, INT numAcqs
    );
typedef enum logging_apptype
{
    L_PSD_APPS = 0,
    L_OTHER_APPS
} logging_apptype_e;
typedef enum log_level
{
    LOG_LEVEL_ERROR,
    LOG_LEVEL_INFO
} log_level_e;
typedef enum trace_level
{
    TRACE_LEVEL_DEBUG,
    TRACE_LEVEL_INFO,
    TRACE_LEVEL_WARNING,
    TRACE_LEVEL_ERROR,
    TRACE_LEVEL_FATAL,
    TRACE_LEVEL_NONE
} trace_level_e;
typedef enum trace_file_name_style
{
    TRACE_FULL_FILE_PATH,
    TRACE_BASE_FILE_NAME
} trace_file_name_style_e;
typedef enum
{
    LOG_TRACE_FAILED = -1,
    LOG_TRACE_OK
} log_trace_return_e;
typedef const void* trace_module;
log_trace_return_e log_trace_service_register( const char *app_name,
                                               const trace_level_e app_trace_level,
                                               const logging_apptype_e app_type,
                                               const char *output_dir );
log_trace_return_e log_trace_service_log_message( const log_level_e msg_log_level,
                                                  const char *calling_file_name,
                                                  const int calling_line_no,
                                                  const char *module,
                                                  const char *format,
                                                  ... );
trace_module log_trace_service_get_trace_module( const char *module_name );
log_trace_return_e log_trace_service_set_module_buffer_size( trace_module t_module,
                                                             const size_t size );
log_trace_return_e log_trace_service_trace_message( const trace_level_e msg_trace_level,
                                                    const char *calling_file_name,
                                                    const int calling_line_no,
                                                    trace_module t_module,
                                                    const char *format,
                                                    ... );
log_trace_return_e log_trace_service_flush_trace_module_buffer( trace_module t_module );
log_trace_return_e log_trace_service_remove_trace_module( trace_module t_module );
log_trace_return_e log_trace_service_update_trace_level( void );
log_trace_return_e log_trace_service_is_trace_active( const trace_level_e msg_trace_level,
                                                      trace_module t_module );
log_trace_return_e log_trace_service_deregister( void );
log_trace_return_e log_trace_service_close_connection( void );
typedef struct maxslquanttps_option
{
        FLOAT arcRxToAcqSlicesSlope;
        FLOAT arcRxToAcqSlicesIntercept;
        INT discoTotalAcqPoints;
} MAXSLQUANTTPS_OPTION;
STATUS b0Dither_ifile( FLOAT * const dither_val,
                       const INT control,
                       const DOUBLE dx,
                       const DOUBLE dy,
                       const DOUBLE dz,
                       const DOUBLE agxw,
                       const INT esp,
                       const INT nslices,
                       const INT debug,
                       long (*const rsprot)[9],
                       const FLOAT * const ccinx,
                       const FLOAT * const cciny,
                       const FLOAT * const ccinz,
                       const INT * const esp_in,
                       const FLOAT * const fesp_in,
                       const FLOAT * const g0,
                       const INT * const num_elements,
                       const INT * const exist );
STATUS b0DitherFile( FLOAT *dither_val,
                     INT control,
                     DOUBLE dx,
                     DOUBLE dy,
                     DOUBLE dz,
                     DOUBLE agxw,
                     INT esp,
                     INT nslices,
                     INT debug,
                     long (*rsprot)[9],
                     FLOAT *buffer );
STATUS epiRecvFrqPhs( const INT nslices,
                      const INT nileaves,
                      const INT etl,
                      const DOUBLE xtr_rba_time,
                      FLOAT *const reftime,
                      const DOUBLE frtime,
                      const DOUBLE opfov,
                      const INT opyres,
                      const DOUBLE fovar,
                      FLOAT *const b0_dither_val,
                      INT **const rf_phase_spgr,
                      const INT dro,
                      const INT dpo,
                      RSP_INFO *const rspinfo,
                      INT *const view1st,
                      INT *const viewskip,
                      INT *const gradpol,
                      const INT ref_mode,
                      const INT kydir,
                      const INT dc_chop_flag,
                      const INT pepolar_flag,
                      INT ***const recv_freq,
                      DOUBLE ***const recv_phase_angle,
                      INT ***const recv_phase_ctrl,
                      FLOAT *const gldelayfval,
                      const DOUBLE ampgxw,
                      const INT debug,
                      const INT refxoff,
                      const FLOAT asset_factor,
                      const INT iref_etl,
                      FLOAT *const sl_cfoffset,
                      INT esp );
STATUS OpenDelayFile( FLOAT *buffer );
STATUS OpenDitherFile( const INT coiltype,
                       FLOAT * const buffer );
STATUS OpenDitherInterpoFile( INT coiltype,
                              FLOAT * const ccinx,
                              FLOAT * const cciny,
                              FLOAT * const ccinz,
                              INT * const esp_in,
                              FLOAT * const fesp_in,
                              FLOAT * const g0,
                              INT * const num_elements,
                              INT * const exist );
STATUS optdda( INT *dda,
               const INT T1_dda );
INT phase_order_fgre3d( SHORT * const view_tab,
                        const INT phase_order,
                        const INT rspviews,
                        const INT viewoffset,
                        const INT nframes,
                        const INT noverscans,
                        const FLOAT fractnex );
STATUS prescanslice( INT * const slpass,
                     INT * const sltime,
                     const LONG numLocs );
STATUS prescanslice1( INT * const preslorder,
                      const INT pre_slquant,
                      const LONG numLocs );
STATUS pcflowtarget( const INT flaxx,
                     const INT flaxy,
                     const INT flaxz,
                     const DOUBLE derate_factor,
                     FLOAT * const xtarget,
                     FLOAT * const ytarget,
                     FLOAT * const ztarget,
                     const LOG_GRAD * const Loggrdp,
                     const INT derate_flag );
STATUS genVRGF( const OPT_GRAD_PARAMS * const gradout,
                const INT xres,
                const DOUBLE period,
                const DOUBLE tamp,
                const DOUBLE tfthw,
                const DOUBLE tadw,
                const DOUBLE alpha,
                const DOUBLE beta );
void psd_init_iopts( void );
STATUS cvsetfeatures( void );
STATUS cvfeatureiopts( void );
STATUS cvevaliopts( void );
STATUS calcqmapshift( INT * const qmap_shift,
                      const INT slquant,
                      const INT nshifts,
                      const INT shift_ind );
STATUS info_fields_display( INT *pi_inplaneres,
                         INT *pi_rbwperpix,
                         INT *pi_esp,
                         FLOAT *inplanexres,
                         FLOAT *inplaneyres,
                         FLOAT *rbwperpix,
                         FLOAT *esp,
                         INT pibitmask,
                         INT act_esp,
                         INT method_for_ypixsize );
void copyCoilInfo(void);
void rfB1optplus( void );
void rfB1opt( void );
STATUS setScale( const INT entryPoint,
                 const INT numPulseEntries,
                 const RF_PULSE *rfpulse,
                 const FLOAT maxB1,
                 const FLOAT extraScale );
STATUS rfsafetyopt( FLOAT * const opt_deratingfactor,
                    const INT rfscale_flag,
                    FLOAT * const orig_rfscale,
                    FLOAT * const limit_scale_seed,
                    const INT rf1slot,
                    RF_PULSE * const rfpulse,
                    RF_PULSE_INFO * const rfpulseInfo );
typedef enum slicesort_acq_type
{
    PSD_FRONT_LOADED_SLICE_SORT = 0,
    PSD_DISTRIBUTED_SLICE_SORT = 1
} slicesort_acq_type_e;
STATUS setAccelPulldown( const float arc_ph_maxaccel,
                         const float arc_sl_maxaccel,
                         float* piaccel_phval2,
                         float* piaccel_phval3,
                         float* piaccel_phval4,
                         float* piaccel_phval5,
                         float* piaccel_phval6,
                         int* piaccel_phnub,
                         int* piaccel_phedit,
                         float* piaccel_slval2,
                         float* piaccel_slval3,
                         float* piaccel_slval4,
                         float* piaccel_slval5,
                         float* piaccel_slval6,
                         int* piaccel_slnub,
                         int* piaccel_sledit,
                         float *ph_stepsize,
                         float *sl_stepsize );
STATUS fseminti( INT * const mintitime,
                 const INT hrf0,
                 const INT pw_gzrf0d,
                 const INT cs_sattime,
                 const INT sp_sattime,
                 const INT satdelay,
                 const INT t_exa );
STATUS imgtimutil( LONG const premidRF1_time,
                   LONG const acqType,
                   LONG const gating,
                   LONG * const availimagetime );
STATUS optspecir( FLOAT *opttheta,
                  INT *maxti,
                  INT soltype );
STATUS seqtime( LONG * const Seqtime,
                const LONG availimagetime,
                const INT Slquant1,
                const INT acqType );
STATUS seqtype( LONG *Seqtype );
STATUS slicein1( INT * const Slquant1,
                 const INT numAcqs,
                 const INT acqType );
STATUS slicesort( INT * const Slquant1,
                  INT * const sl_pass,
                  INT * const sl_angle,
                  const INT maxlocsPerPass,
                  INT * const numAcqs,
                  INT * const numAngles,
                  const INT MaxAcq,
                  const INT acqType );
STATUS setnexctrl( INT * const Nex,
                   FLOAT * const Fn,
                   FLOAT * const Truenex,
                   INT * const Oddnex,
                   INT * const Halfnex);
STATUS amppwcrush( GRAD_PULSE * const rightgradcrush,
                   GRAD_PULSE * const leftgradcrush,
                   const INT echonum,
                   const DOUBLE crushscale,
                   const DOUBLE targetamp,
                   DOUBLE ampslicesel,
                   const DOUBLE stdarea,
                   const INT minconstpw,
                   const INT rmpfullscale );
STATUS amppwlcrsh( GRAD_PULSE * const gradleftcrush,
                   GRAD_PULSE * const gradrightcrush,
                   const DOUBLE area_rephase,
                   const DOUBLE amp_180slicesel,
                   const DOUBLE target_amp,
                   const INT minconstpw,
                   const INT rmpfullscale,
                   INT *attackpw_180slicesel );
STATUS crusherutil( FLOAT * const crusher_scale,
                    const INT psd_type );
STATUS dbdtderate( LOG_GRAD * const lgrad,
                   const INT debug );
short isdbdtper( void );
short isdbdtts( void );
STATUS amp_rt_dbdtopt( FLOAT * target_ampmax, INT * target_rtmin, INT slewrate, FLOAT ampscaling, FLOAT ampmaxlimit );
STATUS amppwfcse1( GRAD_PULSE * const gxf11,
                   GRAD_PULSE * const gxf21,
                   GRAD_PULSE * const gzf11,
                   GRAD_PULSE * const gzf21,
                   const GRAD_PULSE * const gxw,
                   const GRAD_PULSE * const gzrf1,
                   const GRAD_PULSE * const gzrf2,
                   const GRAD_PULSE * const gzrf2l1,
                   const GRAD_PULSE * const gzrf2r1,
                   const DOUBLE pw_read,
                   const DOUBLE fnecho,
                   const DOUBLE pcor90,
                   const DOUBLE pcor180,
                   const DOUBLE xtarget,
                   const INT pw_rampx,
                   const DOUBLE ztarget,
                   const INT pw_rampz,
                   const INT te,
                   const INT isodelay );
STATUS amppwfcse1opt( GRAD_PULSE * const gxf11,
                      GRAD_PULSE * const gxf21,
                      GRAD_PULSE * const gzf11,
                      GRAD_PULSE * const gzf21,
                      const GRAD_PULSE * const gxw,
                      const GRAD_PULSE * const gzrf1,
                      const GRAD_PULSE * const gzrf2,
                      const GRAD_PULSE * const gzrf2l1,
                      const GRAD_PULSE * const gzrf2r1,
                      const DOUBLE pw_read,
                      const DOUBLE fnecho,
                      const DOUBLE pcor90,
                      const DOUBLE pcor180,
                      const DOUBLE xtarget,
                      const INT pw_rampx,
                      const DOUBLE ztarget,
                      const INT pw_rampz,
                      const INT te,
                      const INT isodelay,
                      const INT xflow_gap,
                      INT *minte_temp );
STATUS amppwfcse2( GRAD_PULSE * const gxf12,
                   GRAD_PULSE * const gxf22,
                   GRAD_PULSE * const gzf12,
                   GRAD_PULSE * const gzf22,
                   const GRAD_PULSE * const gxw,
                   const GRAD_PULSE * const gxw2,
                   const GRAD_PULSE * const gzrf1,
                   const GRAD_PULSE * const gzrf2,
                   const GRAD_PULSE * const gzrf2l2,
                   const GRAD_PULSE * const gzrf2r2,
                   const DOUBLE pw_read,
                   const DOUBLE te2_te1,
                   const DOUBLE pcor180,
                   const DOUBLE xtarget,
                   const INT pw_rampx,
                   const DOUBLE ztarget,
                   const INT pw_rampz );
STATUS amppwfcse2opt( GRAD_PULSE * const gxf12,
                      GRAD_PULSE * const gxf22,
                      GRAD_PULSE * const gzf12,
                      GRAD_PULSE * const gzf22,
                      const GRAD_PULSE * const gxw,
                      const GRAD_PULSE * const gxw2,
                      const GRAD_PULSE * const gzrf1,
                      const GRAD_PULSE * const gzrf2,
                      const GRAD_PULSE * const gzrf2l2,
                      const GRAD_PULSE * const gzrf2r2,
                      const DOUBLE pw_read,
                      const INT te1,
                      const INT te2,
                      const DOUBLE pcor180,
                      const DOUBLE xtarget,
                      const INT pw_rampx,
                      const DOUBLE ztarget,
                      const INT pw_rampz,
                      const INT xflow_gap,
                      INT * const minte2_temp );
STATUS amppwgxfc2( const DOUBLE a_gxw,
                   const INT pw_gxw,
                   const INT pw_gxwd,
                   const INT pw_gxw2a,
                   const INT pw_gxw2,
                   const INT pw_ramp,
                   const INT avail_time,
                   const DOUBLE loggrd_target,
                   const INT te1_te2,
                   FLOAT * const a_gxfc2,
                   INT * const pw_gxfc2a,
                   INT * const pw_gxfc2,
                   INT * const pw_gxfc2d,
                   FLOAT * const a_gxfc3,
                   INT * const pw_gxfc3a,
                   INT * const pw_gxfc3,
                   INT * const pw_gxfc3d );
STATUS amppwgxfcmin( const DOUBLE a_gxw,
                     const INT pw_gxwa,
                     const INT pw_gxw,
                     const INT pw_gxwd,
                     const INT avail_time,
                     const DOUBLE frac_echo,
                     const DOUBLE amp_target,
                     const INT pw_rampx,
                     const DOUBLE xbeta,
                     FLOAT * const a_gx1,
                     INT * const pw_gx1a,
                     INT * const pw_gx1,
                     INT * const pw_gx1d,
                     FLOAT * const a_gxfc,
                     INT * const pw_gxfca,
                     INT * const pw_gxfc,
                     INT * const pw_gxfcd );
STATUS amppwgzfc( const DOUBLE a_gzrf1,
                  const INT pw_gzrf1a,
                  const INT pw_gzrf1,
                  const INT pw_gzrf1d,
                  const INT pw_ramp,
                  const INT avail_time,
                  FLOAT *a_gz1,
                  INT *pw_gz1a,
                  INT *pw_gz1,
                  INT *pw_gz1d,
                  FLOAT *a_gzfc,
                  INT *pw_gzfca,
                  INT *pw_gzfc,
                  INT *pw_gzfcd );
STATUS amppwgzfcmin( const DOUBLE a_gzrf1,
                     const INT pw_gzrf1a,
                     const INT fulltexb,
                     const INT pw_gzrf1d,
                     const INT avail_time,
                     const INT off_90,
                     const DOUBLE amp_target,
                     const INT pw_rampz,
                     const DOUBLE zbeta,
                     FLOAT * const a_gz1,
                     INT * const pw_gz1a,
                     INT * const pw_gz1,
                     INT * const pw_gz1d,
                     FLOAT * const a_gzfc,
                     INT * const pw_gzfca,
                     INT * const pw_gzfc,
                     INT * const pw_gzfcd );
STATUS amppwgx1( FLOAT *ampgx1,
                 INT *c_pwgx1,
                 INT *a_pwgx1,
                 INT *d_pwgx1,
                 INT seq_type,
                 DOUBLE area,
                 const DOUBLE area_ramp,
                 const INT avai_ptime,
                 const DOUBLE fract_echo,
                 const INT minconstpw,
                 const INT rmpfullscale,
                 const DOUBLE target );
STATUS calcfilter( FILTER_INFO * const echortf,
                   const DOUBLE des_bandwidth,
                   const INT outputs,
                   const RBW_UPDATE_TYPE update_rbw );
STATUS calcfilter_half_integer_decimation( FILTER_INFO * const echortf,
                                           const DOUBLE des_bandwidth,
                                           const INT outputs,
                                           const RBW_UPDATE_TYPE update_rbw );
void dump_filter_info( const FILTER_INFO * const filtinfo );
STATUS epigradopt( const OPT_GRAD_INPUT *const gradin,
                   OPT_GRAD_PARAMS *const gradout,
                   FLOAT *const pidbdtts,
                   FLOAT *const pidbdtper,
                   const DOUBLE cfdbdtts,
                   const DOUBLE cfdbdtper,
                   const DOUBLE cfdbdtdx,
                   const DOUBLE cfdbdtdy,
                   const INT reqesp,
                   const INT autogap,
                   const INT rampsamp,
                   const INT vrgsamp,
                   const INT debug );
STATUS epigradopt_zblips( const OPT_GRAD_INPUT *const gradin,
                   OPT_GRAD_PARAMS *const gradout,
                   FLOAT *const pidbdtts,
                   FLOAT *const pidbdtper,
                   FLOAT *const dbdtperx,
                   FLOAT *const dbdtpery,
                   FLOAT *const dbdtperz,
                   const DOUBLE cfdbdtts,
                   const DOUBLE cfdbdtper,
                   const DOUBLE cfdbdtdx,
                   const DOUBLE cfdbdtdy,
                   const DOUBLE cfdbdtdz,
                   const INT reqesp,
                   const INT autogap,
                   const INT rampsamp,
                   const INT vrgsamp,
                   const INT debug );
STATUS filterutilv6( FILTER_INFO * const echo1rtf,
                     FILTER_INFO * const echo2rtf,
                     const INT outputs,
                     const DOUBLE fnecholim,
                     const INT pwramp,
                     const INT read_timel,
                     const INT read_timer,
                     const INT read_wingl,
                     const INT read_wingr,
                     const INT read_wing2l,
                     const INT read_wing2r,
                     const INT treadvbw,
                     const INT maxseqtime );
STATUS fractecho( INT * const tfe_extra,
                  const DOUBLE fnecho_lim,
                  const INT seq_type,
                  const INT min_tenfe,
                  const INT read_pw,
                  const INT max_gx1time,
                  const DOUBLE amp_targetx,
                  const INT target_xrt,
                  const INT xres,
                  const DOUBLE fov );
STATUS maxwell_pc_calc( const INT max_flag,
                        const INT num_points,
                        const INT debug,
                        const INT pwgx1a,
                        const INT pwgx1,
                        const INT pwgx1d,
                        const INT pwgxfca,
                        const INT pwgxfc,
                        const INT pwgxfcd,
                        const INT pwgz1a,
                        const INT pwgz1,
                        const INT pwgz1d,
                        const INT pwgzfca,
                        const INT pwgzfc,
                        const INT pwgzfcd,
                        const INT pwgyfe1a,
                        const INT pwgyfe1,
                        const INT pwgyfe1d,
                        const INT pwgxwa,
                        const INT pwgy1a,
                        const INT pwgy1,
                        const INT pwgy1d,
                        const INT pwgzrf1d,
                        const DOUBLE flow_wdth_x,
                        const DOUBLE flow_wdth_z,
                        const INT iagx1fen,
                        const INT iagx1feu,
                        const INT iagx1fed,
                        const INT iagx2fen,
                        const INT iagx2feu,
                        const INT iagx2fed,
                        const INT iagz1fen,
                        const INT iagz1feu,
                        const INT iagz1fed,
                        const INT iagz2fen,
                        const INT iagz2feu,
                        const INT iagz2fed,
                        const INT iagy1feu,
                        const INT iagy1fed,
                        const INT iagy2feu,
                        const INT iagy2fed,
                        const DOUBLE agxw,
                        const DOUBLE agzrf1,
                        const long * const rotmat,
                        FLOAT * const maxcoef1a,
                        FLOAT * const maxcoef1b,
                        FLOAT * const maxcoef1c,
                        FLOAT * const maxcoef1d,
                        FLOAT * const maxcoef2a,
                        FLOAT * const maxcoef2b,
                        FLOAT * const maxcoef2c,
                        FLOAT * const maxcoef2d,
                        FLOAT * const maxcoef3a,
                        FLOAT * const maxcoef3b,
                        FLOAT * const maxcoef3c,
                        FLOAT * const maxcoef3d );
STATUS maxwellcomp( FLOAT * const a_mid,
                    INT * const pw_attack,
                    INT * const pw_mid,
                    INT * const pw_decay,
                    const DOUBLE maxterm,
                    const DOUBLE a_start,
                    const DOUBLE targetAmp,
                    const INT riseTime,
                    FLOAT * const r1,
                    FLOAT * const r2,
                    FLOAT * const r3 );
STATUS trapmaxwell( const DOUBLE a_start,
                    const INT pw_attack,
                    const DOUBLE a_mid,
                    const INT pw_mid,
                    const DOUBLE a_end,
                    const INT pw_decay,
                    FLOAT * const maxterm );
STATUS amppwgmn( const DOUBLE ref_area,
                 const DOUBLE ref_moment,
                 const DOUBLE encode_area,
                 const DOUBLE moment_area,
                 const INT max_allowable_time,
                 const DOUBLE beta,
                 DOUBLE targetamp,
                 const INT ramp2target,
                 const INT minconstpw,
                 FLOAT *a_gmn1,
                 INT *pw_gmn1a,
                 INT *pw_gmn1,
                 INT *pw_gmn1d,
                 FLOAT *a_gmn2,
                 INT *pw_gmn2a,
                 INT *pw_gmn2,
                 INT *pw_gmn2d );
STATUS calctrap1stmom( FLOAT *moment,
                       DOUBLE ampl,
                       INT attack,
                       INT plateau,
                       INT decay,
                       DOUBLE timeref );
STATUS optgmn( const DOUBLE a_left,
               const INT pw_lefta,
               const INT pw_left,
               const INT pw_leftd,
               const DOUBLE a_right,
               const INT pw_righta,
               const INT pw_right,
               const INT pw_rightd,
               FLOAT *a_mid,
               INT *pw_mida,
               INT *pw_mid,
               INT *pw_midd,
               const DOUBLE rate,
               INT *pos_mid,
               INT *pos_right );
STATUS rampmoments( const DOUBLE ampinitial,
                    const DOUBLE ampfinal,
                    const INT duration,
                    const INT invertphaseflag,
                    INT * const pulsepos,
                    FLOAT * const zerothmoment,
                    FLOAT * const firstmoment,
                    FLOAT * const zeromomentsum,
                    FLOAT * const firstmomentsum );
STATUS minseqbusbar( INT * const minseqtime,
                     const INT minseqcable,
                     const INT tmin_minseq );
STATUS minseqcable( INT * const minseqtime,
                    FLOAT * const xa2s,
                    FLOAT * const ya2s,
                    FLOAT * const za2s,
                    const INT srmode,
                    const GRAD_PULSE * const gradx,
                    const GRAD_PULSE * const grady,
                    const GRAD_PULSE * const gradz,
                    const INT numXpulse,
                    const INT numYpulse,
                    const INT numZpulse,
                    const DOUBLE gcontirms,
                    const INT tmin_minseq );
STATUS power_peraxis_cable( FLOAT * const power,
                            const INT numPulses,
                            const GRAD_PULSE * const grad );
STATUS power_peraxis( FLOAT *const power,
                      const INT numPulses,
                      GRAD_PULSE *const grad );
STATUS minseqcoil( INT *const minseqtime,
                   FLOAT *const xa2s,
                   FLOAT *const ya2s,
                   FLOAT *const za2s,
                   const INT srmode,
                   GRAD_PULSE *const gradx,
                   GRAD_PULSE *const grady,
                   GRAD_PULSE *const gradz,
                   const INT numXpulse,
                   const INT numYpulse,
                   const INT numZpulse,
                   const DOUBLE gcontirms );
STATUS minseqgrad( INT *const minseqgrddrv,
                   INT *const minseqgrddrvx,
                   INT *const minseqgrddrvy,
                   INT *const minseqgrddrvz,
                   INT *const ro_time,
                   INT *const pe_time,
                   INT *const ss_time,
                   INT *const px_time,
                   INT *const py_time,
                   INT *const pz_time,
                   GRAD_PULSE *const gradx,
                   GRAD_PULSE *const grady,
                   GRAD_PULSE *const gradz,
                   const INT numx,
                   const INT numy,
                   const INT numz,
                   const LOG_GRAD *const lgrad,
                   const PHYS_GRAD *const pgrad,
                   SCAN_INFO *const scaninfotab,
                   INT slquant,
                   const INT plane_type,
                   const INT coaxial,
                   const INT _sigrammode,
                   const INT debug,
                   FLOAT *const amptrans_px,
                   FLOAT *const amptrans_py,
                   FLOAT *const amptrans_pz,
                   FLOAT *const amptrans_lx,
                   FLOAT *const amptrans_ly,
                   FLOAT *const amptrans_lz,
                   FLOAT *const abspower_px,
                   FLOAT *const abspower_py,
                   FLOAT *const abspower_pz,
                   FLOAT *const abspower_lx,
                   FLOAT *const abspower_ly,
                   FLOAT *const abspower_lz,
                   FLOAT *const power_lx,
                   FLOAT *const pospower_lx,
                   FLOAT *const negpower_lx,
                   FLOAT *const power_ly,
                   FLOAT *const pospower_ly,
                   FLOAT *const negpower_ly,
                   FLOAT *const power_lz,
                   FLOAT *const pospower_lz,
                   FLOAT *const negpower_lz,
                   INT *const minseqgpm );
STATUS minseqgram( INT *minseqtime,
                   INT *ro_time,
                   INT *pe_time,
                   INT *ss_time,
                   INT *px_time,
                   INT *py_time,
                   INT *pz_time,
                   GRAD_PULSE *gradx,
                   GRAD_PULSE *grady,
                   GRAD_PULSE *gradz,
                   INT numx,
                   INT numy,
                   INT numz,
                   PHYS_GRAD *pgrad,
                   SCAN_INFO *scaninfotab,
                   INT slquant,
                   INT plane_type,
                   INT coaxial,
                   INT _sigrammode,
                   INT debug,
                   FLOAT *amptrans_px,
                   FLOAT *amptrans_py,
                   FLOAT *amptrans_pz,
                   FLOAT *amptrans_lx,
                   FLOAT *amptrans_ly,
                   FLOAT *amptrans_lz,
                   FLOAT *abspower_px,
                   FLOAT *abspower_py,
                   FLOAT *abspower_pz,
                   FLOAT *abspower_lx,
                   FLOAT *abspower_ly,
                   FLOAT *abspower_lz );
STATUS minseqgrddrv( LONG *const minseqtime,
                     FLOAT *const power,
                     FLOAT *const pospower,
                     FLOAT *const negpower,
                     const INT numPulses,
                     GRAD_PULSE *const grad,
                     const INT gramtype,
                     const DOUBLE irmspos,
                     const DOUBLE irmsneg,
                     const DOUBLE irms,
                     const DOUBLE ampgcmfs,
                     const DOUBLE gcmfs );
STATUS minseqsys( INT * const Minseqsys );
STATUS obloptimize( LOG_GRAD * const lgrad,
                    PHYS_GRAD * const pgrad,
                    SCAN_INFO * const scaninfotab,
                    INT slquant,
                    const INT plane_type,
                    const INT coaxial,
                    const INT method,
                    const INT debug,
                    INT * const newgeo,
                    const INT srmode );
STATUS obloptimize_epi( LOG_GRAD * const lgrad,
                        PHYS_GRAD * const pgrad,
                        SCAN_INFO * const scaninfotab,
                        INT slquant,
                        const INT plane_type,
                        const INT coaxial,
                        const INT method,
                        const INT debug,
                        INT * const newgeo,
                        const INT srmode );
STATUS obloptimizecalc( LOG_GRAD * const lgrad,
                        PHYS_GRAD * const pgrad,
                        SCAN_INFO * const scaninfotab,
                        INT slquant,
                        const INT plane_type,
                        const INT coaxial,
                        const INT method,
                        const INT debug,
                        INT * const newgeo,
                        const INT srmode,
                        const INT epimode );
STATUS l_p_transver( FLOAT * const phy,
                     const FLOAT a,
                     const FLOAT b,
                     const FLOAT c,
                     const DOUBLE logx,
                     const DOUBLE logy,
                     const DOUBLE logz );
STATUS ampfov( FLOAT *Ampfov,
               const DOUBLE readout_filter,
               const DOUBLE fov );
STATUS amppwgrad( const DOUBLE targetArea,
                  const DOUBLE targetAmp,
                  const DOUBLE startAmp,
                  const DOUBLE endAmp,
                  const INT riseTime,
                  const INT minConst,
                  FLOAT *Amp,
                  INT *Attack,
                  INT *Pw,
                  INT *Decay );
STATUS amppwgradmethod( const GRAD_PULSE * const gradpulse,
                        const DOUBLE targetArea,
                        const DOUBLE targetAmp,
                        const DOUBLE startAmp,
                        const DOUBLE endAmp,
                        const INT riseTime,
                        const INT minConst );
STATUS fitresol( SHORT * const resolution,
                 INT * const pulsewidth,
                 INT maxlimit,
                 const INT minlimit,
                 const INT cycle );
STATUS generatespiral_1( const float fov,
                         const int matrix,
                         const int nPoints,
                         const int nInterleaves,
                         const float deltaT,
                         const float slewMax,
                         const float gradMax,
                         int * const Gx,
                         int * const Gy,
                         float * const Kx,
                         float * const Ky,
                         float * const W,
                         float * const f,
                         float * const dbdtper_t );
STATUS generatespiral_2( const float fov,
                         const int matrix,
                         const int nPoints,
                         const int nInterleaves,
                         const float deltaT,
                         const float slewMax,
                         const float gradMax,
                         const float alpha,
                         int * const Gx,
                         int * const Gy,
                         float * const f );
STATUS getbeta( FLOAT *beta,
                WF_PROCESSOR wgname,
                LOG_GRAD *lgrad );
STATUS getramptime( INT * const risetime,
                    INT * const falltime,
                    const WF_PROCESSOR wgname,
                    const LOG_GRAD * const lgrad );
STATUS gettarget( FLOAT * const target,
                  const WF_PROCESSOR wgname,
                  const LOG_GRAD * const lgrad );
STATUS ileaveinit( const INT nframes,
                   const INT kydir,
                   const INT intleaves,
                   const INT alt_fact,
                   const INT gpolarity,
                   const INT bpolarity,
                   const INT debug,
                   const INT rfamp,
                   const INT blipamp,
                   const INT pepolarity,
                   const INT etl,
                   const INT seqdata,
                   const DOUBLE tshift,
                   const INT tfon,
                   const INT fract_ky,
                   const DOUBLE ky_off,
                   const INT num_overscan,
                   const INT pe_end_iamp,
                   const INT esp,
                   const DOUBLE tsp,
                   const INT samples,
                   const DOUBLE ro_amp,
                   const INT xft_size,
                   const INT slquant,
                   const INT lpf,
                   const INT iref_etl,
                   INT * const gy1f,
                   INT * const view1st,
                   INT * const viewskip,
                   INT * const tf,
                   INT * const rfpol,
                   INT * const gradpol,
                   INT * const blippol,
                   INT * const mintf );
STATUS inittargets( LOG_GRAD *const lgrad,
                    PHYS_GRAD *const pgrad );
STATUS initpgradtargets( PHYS_GRAD *const phys_grad );
STATUS setuppgrad( PHYS_GRAD *const phys_grad );
STATUS initlgradtargets( LOG_GRAD *const log_grad );
STATUS optramp( LONG *pulsewidth,
                const DOUBLE ampdelta,
                const DOUBLE maxamp,
                const INT rmp2fullscale,
                const INT defineType );
INT psd_getgradmode( void );
STATUS scalerotmats( long (*rsprot)[9],
                     const LOG_GRAD *lgrad,
                     const PHYS_GRAD *pgrad,
                     const INT slquant,
                     const INT debug );
STATUS maxfov( FLOAT *Maxfov );
STATUS maxnecho( INT *Maxnecho,
                 LONG nonTEtime,
                 LONG maxSeqTime,
                 INT echoType );
STATUS maxpass( INT * const Maxpass,
                const INT acqType,
                const INT numLocs,
                const INT locsPerPass );
STATUS maxphases( INT * const Maxphases,
                  const LONG seqTimPresc,
                  const INT acqType,
                  const LONG otherslicelimit );
STATUS maxslquant( INT * const Maxslquant,
                   const INT repetitionTime,
                   const INT otherslicelimit,
                   const INT acqType,
                   const INT seqTimPresc );
STATUS maxslquant1( const INT Maxslquant,
                    INT * const repetitionTime,
                    const INT acqType,
                    const INT seqTimPresc,
                    const INT gating );
STATUS maxslquanttps( INT * const Maxslquanttps,
                      const INT imageSize,
                      const INT siSize,
                      const INT numTemporalPhases,
                      const MAXSLQUANTTPS_OPTION *option );
INT maxslquantBasedOnEnergyLimit(const FLOAT sar,
                                 const FLOAT sarLimit,
                                 const INT slicesInOnePass);
STATUS maxte1( LONG *Maxte1,
               LONG maxSeqTime,
               INT echoType,
               LONG nonTEtime,
               INT min_fullte );
STATUS maxte2( LONG * const Maxte2,
               const LONG maxSeqTime,
               const LONG nonTEtime );
STATUS maxti( INT * const maxtitime,
              const INT gating,
              const INT te_time,
              const INT nonteti,
              const INT slquant_one,
              const INT tmin,
              const INT left_rf0_time,
              const INT left_rf1_time );
STATUS maxti_rep( INT * const maxtitime,
                  const INT gating,
                  const INT te_time,
                  const INT nonteti,
                  const INT slquant_one,
                  const INT tmin,
                  const INT left_rf0_time,
                  const INT left_rf1_time,
                  const INT num_reps );
STATUS maxtr( INT * const Maxtr );
STATUS maxyres( INT * const Maxyres,
                const DOUBLE targetAmp,
                const INT ramp_time,
                const INT avaiPhaseTime,
                const DOUBLE fov,
                const GRAD_PULSE * const gradstruct_y,
                const INT stepsize );
STATUS minfov( FLOAT * const Minfov,
               const GRAD_PULSE * const gradstruct,
               const DOUBLE foview,
               const INT seq_type,
               const INT phase_time,
               const INT freq_time,
               const DOUBLE readout_BW,
               const INT phase_encode_resolution,
               const INT existyres,
               const INT phasestep,
               const DOUBLE yaspect_ratio,
               const INT flow_comp_type,
               const INT readout_pw,
               const DOUBLE fractecho_fact,
               const DOUBLE gxwtargetamp,
               const DOUBLE gx1targetamp,
               const INT ramp2xtarget,
               const DOUBLE gy1targetamp,
               const INT ramp2ytarget );
STATUS minpulsesep( INT * const Minpulsesep,
                    const INT pwgzrf1d,
                    const INT pwgzrf2l1a,
                    const INT pwgzrf2l1,
                    const INT pwgzrf2l1d );
STATUS minte1_enh( INT * const Minte1,
                   const INT yresolution,
                   const DOUBLE foview,
                   const INT min_seq1,
                   const INT min_seq2,
                   const INT min_seq3,
                   const INT seq_type,
                   const INT echo_type,
                   const INT read_pw,
                   const DOUBLE left_wing_area,
                   const INT iso_delay,
                   const INT rf_180_pw,
                   const INT flow_comp_type,
                   const DOUBLE fnecho_lim,
                   const GRAD_PULSE *gradstruct_y,
                   const DOUBLE gxw_target,
                   const DOUBLE gx1_target,
                   const INT pw_rampx );
STATUS minte1( INT * const Minte1,
               const INT yresolution,
               const DOUBLE foview,
               const INT min_seq1,
               const INT min_seq2,
               const INT min_seq3,
               const INT seq_type,
               const INT echo_type,
               const INT read_pw,
               const INT iso_delay,
               const INT rf_180_pw,
               const INT flow_comp_type,
               const DOUBLE fnecho_lim,
               const GRAD_PULSE *gradstruct_y,
               const DOUBLE gxw_target,
               const DOUBLE gx1_target,
               const INT pw_rampx );
STATUS minte2( INT * const Minte2,
               const INT tfe_extra,
               const INT min_seq1,
               const INT min_seq2,
               const INT seq_type,
               const INT echo_type,
               const INT read_pw1,
               const DOUBLE amp_read1,
               const INT read_pw2,
               const DOUBLE amp_read2,
               const INT flow_comp_type,
               const DOUBLE target_ampx,
               const INT target_xrt );
STATUS minti( INT * const Minti,
              const INT slquant1,
              const INT tmin,
              const INT tileftovers,
              const INT sat2flag );
STATUS mintr( LONG * const Mintr,
              const INT acqType,
              const LONG minseqTime,
              const INT Slquant1,
              const INT gating );
STATUS zoom_limit( INT *index_limit,
                   FLOAT *off_cent_dist,
                   const INT app_grad_type,
                   const INT grad_mode,
                   const INT zoom_coil_index,
                   const FLOAT zoom_fov_xy,
                   const FLOAT zoom_fov_z,
                   const FLOAT zoom_dist_ax,
                   const FLOAT zoom_dist_cor,
                   const FLOAT zoom_dist_sag,
                   const DOUBLE foview,
                   const DOUBLE fov_phase_frac,
                   const INT imag_plane,
                   const INT slquant,
                   SCAN_INFO *scaninfotab );
void advroundup( INT * const adv_panel_value );
void advrounddown( INT * const adv_panel_value );
STATUS highlow( INT * const low,
                INT * const high,
                const INT resolution,
                const SHORT * const waveform );
STATUS scale( FLOAT (*inrotmat)[9],
              long (*outrotmat)[9],
              const INT slquant,
              const LOG_GRAD * const lgrad,
              const PHYS_GRAD * const pgrad,
              const INT contdebug );
STATUS unscale( long (*inrotmat)[9],
                FLOAT (*outrotmat)[9],
                const INT slquant,
                const LOG_GRAD * const lgrad,
                const PHYS_GRAD * const pgrad,
                const INT contdebug );
STATUS newrotatearray( long (*inrot)[9],
                       long (*outrot)[9],
                       const DOUBLE alpha,
                       const DOUBLE beta,
                       const DOUBLE gamma,
                       const INT slquant,
                       const LOG_GRAD * const lgrad,
                       const PHYS_GRAD * const pgrad,
                       const INT contdebug );
STATUS xyztofpn( long (*rotmit)[9],
                 const INT slquant,
                 FLOAT (*xyz)[3],
                 RSP_INFO * const fpn,
                 const LOG_GRAD * const lgrad,
                 const PHYS_GRAD * const pgrad,
                 const INT contdebug );
STATUS fpntoxyz( long (*rotmit)[9],
                 const INT slquant,
                 FLOAT (*xyz)[3],
                 const RSP_INFO * const tpn,
                 const LOG_GRAD * const lgrad,
                 const PHYS_GRAD * const pgrad,
                 const INT contdebug );
STATUS matrixcheck( const INT maxx,
                    const INT maxy );
STATUS matrixcheck_ext( const INT max_x,
                        INT max_y,
                        const INT min_yres );
STATUS modrotmats( long (*inrot)[9],
                   long (*outrot)[9],
                   const INT alpha,
                   const INT beta,
                   const INT gamma,
                   const INT slquant,
                   const INT debug );
STATUS orderphases( SHORT * const phase2view,
                    const INT respCompType,
                    const INT phaseRes );
STATUS vrghighlow( INT * const low,
                   INT * const high,
                   const INT resolution,
                   const SHORT * const waveform );
STATUS amppwencode( const GRAD_PULSE* const gradpulse,
                    INT *total_pw,
                    const DOUBLE target_amp,
                    const INT rise_time,
                    const DOUBLE fov,
                    const INT num_encodes,
                    const DOUBLE area_offset );
STATUS
amppwencode_slice( const GRAD_PULSE *gradpulse,
                   INT *total_pw,
                   const DOUBLE target_amp,
                   const INT rise_time,
                   const DOUBLE slabthick,
                   const INT num_encodes,
                   const DOUBLE area_offset );
STATUS
amppwencodecalc( const GRAD_PULSE *gradpulse,
                 INT *total_pw,
                 const DOUBLE target_amp,
                 const INT rise_time,
                 const DOUBLE fov,
                 const INT num_encodes,
                 const DOUBLE area_offset );
STATUS amppwencode2( const GRAD_PULSE* const gradpulse,
                     INT *total_pw,
                     const DOUBLE target_amp,
                     const INT rise_time,
                     const DOUBLE fov,
                     const INT num_encodes,
                     const DOUBLE area_offset,
                     DOUBLE area_offset_scale );
STATUS amppwencodefse( FLOAT *ampencode,
                       INT *pw_encode,
                       const DOUBLE fov,
                       const INT encodes,
                       const INT logaxis,
                       const INT xflag,
                       const INT yflag,
                       const INT zflag );
STATUS amppwencodet( FLOAT *a_attack,
                     FLOAT *a_decay,
                     INT *pw_middle,
                     INT *pw_attack,
                     INT *pw_decay,
                     const DOUBLE target_amp,
                     const INT rise_time,
                     const DOUBLE fov,
                     const INT size );
STATUS amppwtpe( FLOAT *a_attack,
                 FLOAT *a_decay,
                 INT *pw_middle,
                 INT *pw_attack,
                 INT *pw_decay,
                 const DOUBLE target_amp,
                 const INT rise_time,
                 const DOUBLE target_area );
STATUS amppwtpe2( FLOAT *a_attack,
                  FLOAT *a_decay,
                  INT *pw_middle,
                  INT *pw_attack,
                  INT *pw_decay,
                  const DOUBLE target_amp,
                  const INT rise_time,
                  const DOUBLE target_area,
                  const DOUBLE target_area_largest );
void amppwygmn( const DOUBLE zeromoment,
                const DOUBLE firstmoment,
                const INT pw_gy1fa,
                const INT pw_gy1f,
                const INT pw_gy1fd,
                const DOUBLE a_gy1fa,
                const DOUBLE a_gy1fb,
                const DOUBLE targetamp,
                const DOUBLE ramp2target,
                const INT method,
                INT *pw_gymna,
                INT *pw_gymn,
                INT *pw_gymnd,
                FLOAT *a_gymn );
STATUS avepepowscale( FLOAT *scale_fact,
                      INT num_encodes,
                      INT overscans );
STATUS
avepepowscale_slice( FLOAT *scale_fact,
                     INT num_encodes,
                     INT overscans );
STATUS
avepepowscalecalc( FLOAT *scale_fact,
                   INT num_encodes,
                   INT overscans,
                   FLOAT fov );
STATUS blipcorr( INT * const ia_gyb_corr,
                 const DOUBLE da_gyb_corr,
                 const INT debug,
                 long (*rsprot)[9],
                 const DOUBLE mult_fact,
                 const INT xfs,
                 const INT yfs,
                 const INT zfs,
                 const DOUBLE itx,
                 const DOUBLE ity,
                 const DOUBLE itz,
                 const INT control,
                 const INT nslices,
                 const LOG_GRAD * const lgrad,
                 const INT pw_gyb,
                 const INT pw_gyba,
                 const DOUBLE a_gxw );
STATUS blipcorrdel( FLOAT * const bc_delx,
                    FLOAT * const bc_dely,
                    FLOAT * const bc_delz,
                    const INT esp,
                    const INT coiltype,
                    const INT debug );
STATUS avecrushpepowscale( FLOAT *const scale_fact,
                           const INT num_encodes,
                           const INT overscans,
                           const int even_sym,
                           const float crush_area,
                           const float fov );
STATUS
calcrecphase( int *rec_phase,
              const float phase_offset,
              const float fov,
              const float phase_fov,
              const float nop_factor,
              const float asset_factor);
INT get_tsp_mgd( void );
FLOAT get_max_rbw_hw( void );
STATUS calcvalidrbw( const DOUBLE des_bandwidth,
                     FLOAT * const rbw,
                     FLOAT * const max_bw,
                     FLOAT *decimation,
                     const RBW_UPDATE_TYPE override_rbw,
                     const int vrgf_samp );
STATUS initfilter( void );
STATUS setfilter( FILTER_INFO * const echofilt,
                  const FILTER_BLOCK_TYPE type );
void dump_runtime_filter_info( const PSD_FILTER_GEN *filtgen );
STATUS specparamset( FLOAT * const gamma,
                     INT * const bbandfilt,
                     INT * const xmtband,
                     const INT nucleus );
STATUS getGamma( FLOAT * const gamma,
                 const INT nucleus );
STATUS minseqrfamp_coil( INT *Minseqrfamp,
                         const INT numPulses,
                         const RF_PULSE *rfpulse,
                         const INT entry,
                         const INT activeExciter,
                         const TX_COIL_INFO txCoil );
STATUS minseqrfamp_exciter( INT *Minseqrfamp_exciter,
                            const INT numPulses,
                            const RF_PULSE *rfpulse,
                            const INT entry,
                            INT *exciterUsedFlag );
STATUS minseqrfamp_b1scale( INT *Minseqrfamp,
                            const INT numPulses,
                            const RF_PULSE *rfpulse,
                            const INT entry );
STATUS minseqrfamp( INT *Minseqrfamp,
                    const INT numPulses,
                    const RF_PULSE *rfpulse,
                    const INT entry );
STATUS rfamppowlimit( double *rfamplimit,
                      const TX_COIL_INFO* txCoil );
STATUS pulseEnergyB1LimitForCoil( double* coil_b1_limit,
                                  const RF_PULSE* const pulse,
                                  const TX_COIL_INFO* const txCoil );
STATUS pulseEnergyB1Limit( double* b1limit,
                           const RF_PULSE* const pulse );
void setuprfpulse( const INT slot,
                   INT *pw,
                   FLOAT *amp,
                   const DOUBLE abswidth,
                   const DOUBLE effwidth,
                   const DOUBLE area,
                   const DOUBLE dtycyc,
                   const DOUBLE maxpw,
                   const INT num,
                   const DOUBLE max_b1,
                   const DOUBLE max_int_b1_sq,
                   const DOUBLE max_rms_b1,
                   const DOUBLE nom_fa,
                   FLOAT *act_fa,
                   const DOUBLE nom_pw,
                   const DOUBLE nom_bw,
                   const UINT activity,
                   const UCHAR reference,
                   const INT isodelay,
                   const DOUBLE scale,
                   INT *res,
                   const INT extgradfile,
                   INT *exciter,
                   const INT hadamardfactor,
                   RF_PULSE *rfpulse );
void updaterfpulse( const INT slot,
                    const DOUBLE abswidth,
                    const DOUBLE effwidth,
                    const DOUBLE area,
                    const DOUBLE dtycyc,
                    const DOUBLE maxpw,
                    const INT num,
                    const DOUBLE max_b1,
                    const DOUBLE max_int_b1_sq,
                    const DOUBLE max_rms_b1,
                    const DOUBLE nom_fa,
                    const DOUBLE nom_pw,
                    const DOUBLE nom_bw,
                    const UINT activity,
                    const UCHAR reference,
                    const INT isodelay,
                    const DOUBLE scale,
                    const INT extgradfile,
                    const INT hadamardfactor,
                    RF_PULSE *rfpulse );
void setrfpulsepointers( const INT slot,
                         INT *pw,
                         FLOAT *amp,
                         FLOAT *act_fa,
                         INT *res,
                         INT *exciter,
                         RF_PULSE *rfpulse );
void setupslices( INT *sliceTab,
                  const RSP_INFO *rspInfoTab,
                  const INT numLocs,
                  const DOUBLE gradStrength,
                  const DOUBLE receiveBW,
                  const DOUBLE fov,
                  const INT transmitFlag );
void receivefreqcheck( const SCAN_INFO * scan_info,
                       const INT numlocs,
                       const float receiveBW,
                       float * newRBW,
                       const float fov,
                       const float act_field_strength,
                       const float noisefreefreqlow,
                       const float noisefreefreqhigh,
                       const float minrbw,
                       const float cerdmaxbw);
void receivefreqcheckprop( const float cfreqtemplow,
                           const float cfreqtemphigh,
                           const float receiveBW,
                           float * newRBW,
                           const float fov,
                           float oversampling_factor,
                           float act_field_strength,
                           const float orig_noisefreefreqlow,
                           const float orig_noisefreefreqhigh,
                           float minrbw,
                           float maxcerdbw);
void receivefreqcalc( const float cfreqtemplow,
                      const float cfreqtemphigh,
                      const float receiveBW,
                      float * newRBW,
                      const float act_field_strength,
                      const float noisefreefreqlow,
                      const float noisefreefreqhigh,
                      const float cerdmaxbw);
void receivefreqoffsetcalc( const SCAN_INFO * scan_info,
                            const INT numLocs,
                            const float receiveBW,
                            const float fov,
                            int * offsetfreqlow,
                            int * offsetfreqhigh);
void calcvalidreceivebw( float *newRBW,
                         float oversampling_factor,
                         float maxcerdbw);
STATUS altrfgen( const INT gentypflag,
                 const INT resolution,
                 const SHORT *kernel,
                 const DOUBLE cycles,
                 const DOUBLE slice_offset,
                 const DOUBLE slice_mod_fact,
                 const SHORT *phase_kernel,
                 const DOUBLE start_phase,
                 SHORT *result_wave,
                 const DOUBLE freq_step );
STATUS altcomplexrfgen( const INT gentypflag,
                        const INT resolution,
                        const SHORT *kernel_rho,
                        const SHORT *kernel_theta,
                        const DOUBLE cycles,
                        const DOUBLE slice_offset,
                        const DOUBLE slice_mod_fact,
                        const SHORT *phase_kernel,
                        const DOUBLE start_phase,
                        SHORT *result_wave_rho,
                        SHORT *result_wave_theta,
                        const DOUBLE freq_step );
static const double FAILSAFE_JSTD = 1.0e4;
static const double JSTD_RX_SI_CHANGE_THRESHOLD = 5.0;
typedef enum jstdPositionErr_e {
    JSTDPOS_ASSIGNMENT_ERROR = 0,
    JSTDPOS_NO_ERROR = 1,
    JSTDPOS_CALCULATION_ERROR,
    JSTDPOS_DATA_ERROR,
    JSTDPOS_CONDITION_ERROR
} jstdPositionErr_e;
typedef struct jstdConditions_s {
        int activate;
        double mass;
        n32 tx_coil_type;
} jstdConditions_t;
typedef POSITION_DETECTION_DONE_TYPE jstdReferencePosition_t;
typedef struct jstdPositionResult_s {
        double wholeBodyJstd;
        double headJstdFraction;
        double headJstd;
        double headMass;
        double partialBodyMassFraction;
        double partialBodyJstdFraction;
        double offset;
        jstdPositionErr_e errcode;
} jstdPositionResult_t;
typedef struct jstdResults_s {
        double coilJstd;
        double coilMeanJstd;
        jstdPositionResult_t rxPosition;
} jstdResults_t;
     jstdReferencePosition_t jstdReferencePosition();
    short usablePositionDependentConfig( void );
    short usablePositionDependentConfigAtMass( const double mass );
    short usePositionDependentEnergy( jstdConditions_t* conditions );
    jstdPositionResult_t positionDependentJstdCalculation( const double mass, const double position );
typedef enum scalerfpulses_b1_derate_type
{
    DERATE_B1_BY_COIL = 1,
    DERATE_B1_MIN_SAR_COIL = 2
} scalerfpulses_b1_derate_type_e;
double calcCoilWeight( const TX_COIL_INFO* txCoil,
                       const double mass );
double calcExtremityLimit( const TX_COIL_INFO* txCoil,
                           const double mass,
                           const double maxExtremity,
                           const double maxBody );
double calcHeadWeight( const double mass );
double calcStdRF( const RF_PULSE * const rfpulse,
                  const DOUBLE b1Val,
                  const double gamma_factor );
STATUS maxsar( INT * const Maxseqsar,
                   INT * const Maxslicesar,
                   DOUBLE * const Avesar,
                   DOUBLE * const Cavesar,
                   DOUBLE * const Pksar,
                   DOUBLE * const B1rms,
                   const INT numPulses,
                   const RF_PULSE * const rfpulse,
                   const INT entry,
                   const INT tr_val );
STATUS maxsar_coil( INT * const Maxseqsar,
                    INT * const Maxslicesar,
                    DOUBLE * const Avesar,
                    DOUBLE * const Cavesar,
                    DOUBLE * const Pksar,
                    const INT numPulses,
                    const RF_PULSE * const rfpulse,
                    const INT entry,
                    const TX_COIL_INFO txCoil,
                    const INT activeExciter,
                    const int TR_val );
STATUS maxsar_exciter( INT *Maxseqsar_exciter,
                       INT *Maxslicesar_exciter,
                       DOUBLE *Avesar_exciter,
                       DOUBLE *Cavesar_exciter,
                       DOUBLE *Pksar_exciter,
                       DOUBLE *B1rms_exciter,
                       const INT numPulses,
                       const RF_PULSE * const rfpulse,
                       const INT entry,
                       const int TR_val,
                       INT *exciterUsedFlag );
STATUS maxseqsar( INT * const Maxseqsar,
                  const INT numPulses,
                  const RF_PULSE * const rfpulse,
                  const INT entry );
STATUS maxseqsar_b1scale( INT * const Maxseqsar,
                          const INT numPulses,
                          const RF_PULSE *rfpulse,
                          const INT entry );
STATUS maxseqslicesar( INT * const Maxseqsar,
                       INT * const Maxslicesar,
                       const INT numPulses,
                       const RF_PULSE * const rfpulse,
                       const INT entry );
STATUS maxslicesar( INT * const Maxslicesar,
                    const INT numPulses,
                    const RF_PULSE * const rfpulse,
                    const INT entry );
STATUS maxslicesar_b1scale( INT * const Maxslicesar,
                            const INT numPulses,
                            const RF_PULSE *rfpulse,
                            const INT entry );
STATUS maxslicesar_modified( LONG * const Maxslicesar,
                             const INT numPulses,
                             const RF_PULSE * const rfpulse,
                             const INT entry,
                             const INT tr_val );
STATUS peakAveSars( double * const Avesar,
                    double * const Cavesar,
                    double * const Pksar,
                    double * const B1rms,
                    const int numPulses,
                    const RF_PULSE * const rfpulse,
                    const int entry,
                    const int tr_val );
STATUS publishImagingSar( const int numPulses,
                          const RF_PULSE *rfpulse,
                          const int tr_val );
STATUS sarEstimates( double *Avesar,
                     double *Cavesar,
                     double *Pksar,
                     double *B1rms,
                     const int numPulses,
                     const RF_PULSE *rfpulse,
                     const int entry,
                     const int tr_val );
STATUS powermon( ENTRY_POINT_TABLE * const entryPoint,
                 const INT entry,
                 const INT numPulses,
                 const RF_PULSE *rfpulse,
                 const INT sarTseq );
s16 scalePowermonWatts( const float wattsperkg );
STATUS setupPowerMonitor( ENTRY_POINT_TABLE * const entryPoint,
                          const double avg_sar );
STATUS scalerfpulses_coil( const DOUBLE weight,
                           const INT gcoiltype,
                           const INT numPulses,
                           const RF_PULSE * const rfpulse,
                           const INT entry,
                           RF_PULSE_INFO * const rfpulseInfo,
                           const int derate_type,
                           const TX_COIL_INFO txCoil,
                           const INT activeExciter );
STATUS scalerfpulses( const DOUBLE weight,
                      const INT gcoiltype,
                      const INT numPulses,
                      const RF_PULSE * const rfpulse,
                      const INT entry,
                      RF_PULSE_INFO * const rfpulseInfo );
STATUS scalerfpulses_derate( const DOUBLE weight,
                             const INT gcoiltype,
                             const INT numPulses,
                             const RF_PULSE * const rfpulse,
                             const INT entry,
                             RF_PULSE_INFO * const rfpulseInfo,
                             const INT b1_derate_type );
STATUS scalerfpulses2ut( const DOUBLE derateb1,
                         const INT updatetime,
                         const RF_PULSE * const rfpulse,
                         const INT entry,
                         const INT pulse,
                         RF_PULSE_INFO * const rfpulseInfo,
                         const INT activeExciter );
STATUS scalerfpulsescalc( const INT oldpwrf,
                          INT newpwrf,
                          const INT updatetime,
                          const RF_PULSE * const rfpulse,
                          const INT entry,
                          const INT pulse,
                          RF_PULSE_INFO * const rfpulseInfo,
                          const INT activeExciter );
STATUS findMaxB1Seq( float *maxB1Seq,
                     float *maxB1,
                     const INT numEntries,
                     const RF_PULSE * const rfpulse,
                     const INT numPulseEntries );
STATUS peakB1( FLOAT *maxB1Val,
               const INT entryPoint,
               const INT numPulseEntries,
               const RF_PULSE * const rfpulse );
STATUS peakB1_exciter( FLOAT *maxB1Val,
                       const INT entryPoint,
                       const INT numPulseEntries,
                       const RF_PULSE * const rfpulse,
                       const INT activeExciter );
STATUS calcB1Val( DOUBLE *b1Val,
                  DOUBLE *scale,
                  const RF_PULSE * const rfpulse,
                  const INT pulse,
                  const UCHAR active,
                  const INT e_flag );
STATUS calcPulseB1Rms( DOUBLE *b1RMSVal,
                       DOUBLE *scale,
                       const RF_PULSE * const rfpulse,
                       const INT pulse,
                       const UCHAR active,
                       const INT e_flag );
STATUS calcIntegratedB1Squared( DOUBLE *b1Sqr,
                                DOUBLE *scale,
                                const RF_PULSE * const rfpulse,
                                const INT pulse,
                                const UCHAR active,
                                const INT e_flag );
STATUS peakHardrfB1( FLOAT *maxB1Val,
                     const INT entryPoint,
                     const INT numPulseEntries,
                     const RF_PULSE * const rfpulse );
STATUS peakHardrfB1_exciter( FLOAT *maxB1Val,
                             const INT entryPoint,
                             const INT numPulseEntries,
                             const RF_PULSE * const rfpulse,
                             const INT activeExciter );
STATUS calcRFPower( double * const power_factor,
                    double * const coil_jstd,
                    const TX_COIL_INFO txCoil );
STATUS calcMeanRFPower( double * const mean_power_factor,
                        double * const mean_coil_jstd,
                        const TX_COIL_INFO txCoil );
STATUS calcRFPowerDual( double * const power_factor,
                        double * const mean_power_factor,
                        double * const coil_jstd,
                        double * const mean_coil_jstd,
                        const TX_COIL_INFO txCoil );
STATUS peakrf( DOUBLE * const peak_output,
               DOUBLE * const est_jstd,
               const INT numPulses,
               const RF_PULSE *rfpulse,
               const INT entry );
STATUS peakrf_exciter( DOUBLE * const peak_output_exciter,
                       DOUBLE * const est_jstd_exciter,
                       const INT numPulses,
                       const RF_PULSE * const rfpulse,
                       const INT entry,
                       INT *exciterUsedFlag );
STATUS peakrf_coil( DOUBLE * const peak_output,
                    DOUBLE * const est_jstd,
                    const INT numPulses,
                    const RF_PULSE *rfpulse,
                    const INT entry,
                    const INT activeExciter,
                    const TX_COIL_INFO txCoil );
STATUS mean_peakrf_coil( DOUBLE * const mean_peak_output,
                         DOUBLE * const mean_est_jstd,
                         const INT numPulses,
                         const RF_PULSE *rfpulse,
                         const INT entry,
                         const INT activeExciter,
                         const TX_COIL_INFO txCoil );
STATUS dual_peakrf_coil( DOUBLE * const peak_output,
                         DOUBLE * const mean_peak_output,
                         DOUBLE * const est_jstd,
                         DOUBLE * const mean_est_jstd,
                         const INT numPulses,
                         const RF_PULSE *rfpulse,
                         const INT entry,
                         const INT activeExciter,
                         const TX_COIL_INFO txCoil );
STATUS calcJstd( double * const jstd,
                 const double weight,
                 const TX_COIL_INFO txCoil,
                 const int gradcoil,
                 const int field );
STATUS calcMeanJstd( double * const meanJstd,
                     const double weight,
                     const TX_COIL_INFO txCoil,
                     const int gradcoil,
                     const int field );
STATUS calcDualJstd( double * const jstd,
                     double * const meanJstd,
                     const double weight,
                     const TX_COIL_INFO txCoil,
                     const int gradcoil,
                     const int field );
STATUS calcJstdSet( jstdResults_t* results,
                    const double weight,
                    const TX_COIL_INFO* txCoil,
                    const int gradcoil,
                    const int field );
STATUS calcRfForward( double * const rfforward,
                      const double weight,
                      const TX_COIL_INFO txCoil,
                      const int gradcoil,
                      const int field );
void applyDiscretionaryB1Limit( double * const b1limit );
STATUS amplifierB1Limit( double * const B1_limit,
                         const TX_COIL_INFO txCoil );
STATUS coilB1Limit( double * const B1_limit,
                    const TX_COIL_INFO txCoil );
void calcTGLimit( int * const tgcap_output,
                  int * const tgwindow_output,
                  const float maxB1Seq,
                  const TX_COIL_INFO txCoil );
void requestRTSarForApplication( int rtsar_application_flag );
STATUS amppwcombpe( const DOUBLE a_start,
                    const DOUBLE area_const,
                    const DOUBLE area_pe,
                    const DOUBLE max_amp,
                    const DOUBLE slew_rate,
                    const INT nencodes,
                    INT *pw_attack,
                    INT *pw_plat,
                    INT *pw_decay,
                    FLOAT *a_base,
                    FLOAT *a_ramp );
STATUS amppwgz1( FLOAT *ampgz1,
                 INT *c_pwgz1,
                 INT *a_pwgz1,
                 INT *d_pwgz1,
                 const DOUBLE area,
                 const INT avai_ptime,
                 const INT minconstpw,
                 const INT rmpfullscale,
                 const DOUBLE target );
STATUS ampslice( FLOAT *amp_slice_select,
                 const LONG trans_bwd,
                 const DOUBLE slice_thk,
                 const DOUBLE factor,
                 const INT def_type );
STATUS minslicethick( FLOAT *amp_slice_select,
                      const LONG trans_bwd,
                      const DOUBLE slice_thk,
                      const DOUBLE factor,
                      const INT def_type );
void dump_Data_Acquisition_Order_Table( const INT numAcqs,
                                        const INT sl_in_pass[] );
void printPHYSGRAD( trace_module t_module,
                    const PHYS_GRAD *pulse );
void printLOGGRAD( trace_module t_module,
                   const LOG_GRAD *pulse );
void printCVARG( trace_module t_module,
                 const int opcv_type,
                 const void *cv_arg,
                 const char *cv_name );
void printEntrypointLabel( const trace_level_e level,
                           const trace_module t_module ,
                           const int entry );
void psd_dump_scan_info( void );
void psd_dump_rsp_info( void );
void psd_dump_psc_info( void );
void psd_dump_rsp_psc_info( void );
void psd_dump_coil_info( void );
void
set_vol_shift_cvs( void );
void
set_vol_scale_cvs( const int gradCoilType,
                   const int scaleDirBit,
                   const int scaleConstraintFlag,
                   int* volScaleType,
                   int* volScaleConstraintType);
FLOAT
get_act_freq_fov( void );
FLOAT
get_act_phase_fov( void );
STATUS
calcOptimizedPulses( LOG_GRAD *p_loggrd,
                     FLOAT *Pidbdtper,
                     FLOAT *derate_factor,
                     const FLOAT cf_dbdt_per,
                     const INT core_index,
                     const INT debug_level,
                     const INT e_flag,
                     const INT higher_dbdt_mode );
void
calcTGLimitAtOffset( int off_freq,
                     int *tg_limit,
                     int debug );
int
getCornerPointFileGenerationFlag( void );
STATUS
getCornerPoints( FLOAT **p_time,
                 FLOAT *ampl[3],
                 FLOAT *pul_type[3],
                 INT *num_totpoints,
                 INT *num_iters,
                 const LOG_GRAD *log_grad,
                 const INT seq_entry_index,
                 const INT samp_rate,
                 const INT min_tr,
                 const FLOAT dbdtinf,
                 const FLOAT dbdtfactor,
                 const FLOAT efflength,
                 const INT max_encode_mode,
                 const mss_flags_t* flags );
int
getPulsegenOnHostStopwatchFlag( void );
STATUS
minseq( INT *p_minseqgrad,
        GRAD_PULSE *gradx,
        const INT gx_free,
        GRAD_PULSE *grady,
        const INT gy_free,
        GRAD_PULSE *gradz,
        const INT gz_free,
        const LOG_GRAD *loggrd,
        const INT seq_entry_index,
        const INT samp_rate,
        const INT min_tr,
        const INT e_flag,
        const INT debug_flag );
void setLinearModel1(void);
void setLinearModel2(void);
int calcLinearModel(const int model_etl,
                    const int real_etl);
STATUS
updateIndex( int *index );
INT
updateTGLimitAtOffset( int tglimit,
                       int tglimit2 );
STATUS
set_app_grad_modeling( const INT debug );
STATUS
set_igbt_spec( const INT debug );
STATUS
set_Rio_40170_spec( const INT debug);
void
setupdBdtFlags( mss_flags_t* flags );
STATUS
shimvol_slice_intersect( PSC_INFO *shimvol_info,
                         SCAN_INFO *slice_info,
                         FLOAT margin,
                         INT debug );
STATUS getbeta( FLOAT *beta, WF_PROCESSOR wgname, LOG_GRAD *lgrad );
STATUS getramptime( INT *const risetime, INT *const falltime, const WF_PROCESSOR wgname, const LOG_GRAD *const lgrad );
STATUS gettarget( FLOAT *const target, const WF_PROCESSOR wgname, const LOG_GRAD *const lgrad );
STATUS setxdcntrl( WF_PULSE *pulse_ptr, INT state, INT rcvr);
FLOAT get_act_freq_fov( void );
FLOAT get_act_phase_fov( void );
void epic_error( const int ermes, const char *plain_fmt, const int ermes_num,
                 const int num_args, ... );
int log_error(const char* pathname, const char* filename, const int headerinfo,
              const char* format, ...);
typedef enum DABOUTHUBINDEX
{
    DABOUTHUBINDEX_NOSWITCH = 0,
    DABOUTHUBINDEX_PRIMARY,
    DABOUTHUBINDEX_SECONDARY
} DABOUTHUBINDEX_E;
typedef enum DATA_FRAME_DESTINATION
{
    ROUTE_TO_RECON = 0,
    ROUTE_TO_RTP
} DATA_FRAME_DESTINATION_E;
STATUS
attenlockon( WF_PULSE_ADDR pulse );
STATUS
attenlockoff( WF_PULSE_ADDR pulse );
STATUS
BoreOverTemp( INT monitor_temp,
              INT debug );
STATUS
buildinstr( void );
STATUS
calcdelay( FLOAT *delay_val,
           INT control,
           DOUBLE gldelayx,
           DOUBLE gldelayy,
           DOUBLE gldelayz,
           INT *defaultdelay,
           INT nslices,
           INT gradmode,
           INT debug,
           long(*rsprot)[9] );
STATUS
calcdelayfile( FLOAT *delay_val,
               INT control,
               DOUBLE gldelayx,
               DOUBLE gldelayy,
               DOUBLE gldelayz,
               INT *defaultdelay,
               INT nslices,
               INT debug,
               long(*rsprot)[9],
               FLOAT *buffer );
LONG
calciphase( DOUBLE phase );
STATUS
copyframe( WF_PULSE_ADDR pulse,
           LONG frame_control,
           LONG pass_src,
           LONG slice_src,
           LONG echo_src,
           LONG view_src,
           LONG pass_des,
           LONG slice_des,
           LONG echo_des,
           LONG view_des,
           LONG nframes,
           TYPDAB_PACKETS acqon_flag );
STATUS
create3dim( WF_PULSE_ADDR pulse,
            LONG pos_readout,
            LONG pos_ref );
STATUS
create3dim2( WF_PULSE_ADDR pulse,
             LONG pos_readout,
             LONG pos_ref );
STATUS
rfon( WF_PULSE_ADDR pulse,
      LONG index );
STATUS
rfoff( WF_PULSE_ADDR pulse,
       LONG index );
STATUS
scopeoff( WF_PULSE_ADDR pulse );
STATUS
scopeon( WF_PULSE_ADDR pulse );
STATUS
setPSDtags( WF_PULSE_ADDR pulse,
            WF_PGMREUSE reuse,
            WF_PGMTAG tag,
            LONG addtag,
            INT id,
            INT board_type,
            STATUS force );
STATUS
getctrl( long *ctrl,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
getiwave( long *waveform_ix,
          WF_PULSE_ADDR pulse,
          LONG index );
STATUS
getiphase( INT *phase,
           WF_PULSE_ADDR pulse,
           LONG index );
STATUS
getphase( FLOAT *phase,
          WF_PULSE_ADDR pulse,
          LONG index );
STATUS
getieos( SHORT *eos,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
getpulse( WF_PULSE_ADDR *ret_pulse,
          WF_PULSE_ADDR pulse,
          WF_PGMTAG tagfield,
          INT id,
          LONG index );
STATUS
getssppulse( WF_PULSE_ADDR *ssppulse,
             WF_PULSE_ADDR pulse,
             const CHAR *pulsesuff,
             LONG index );
STATUS
getssppulse_modal( WF_PULSE_ADDR *ssppulse,
                   WF_PULSE_ADDR pulse,
                   const CHAR *pulsesuff,
                   LONG index,
                   LONG exit_mode );
STATUS
getiamp( SHORT *amplitude,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
getperiod( long *period,
           WF_PULSE_ADDR pulse,
           LONG index );
STATUS
getwamp( SHORT *amplitude,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
getweos( SHORT *eos,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
getwave( LONG *waveform_ix,
         WF_PULSE_ADDR pulse );
void
init_wf_queue(void);
STATUS
initfastrec( WF_PULSE_ADDR pulse,
             LONG pos_ref,
             LONG xres,
             LONG tsptics,
             LONG deltics,
             LONG lpf );
int
isRFEnvelopeWaveformGenerator( const WF_PROCESSOR waveform_gen_rf );
int
isRFWaveformGenerator( const WF_PROCESSOR waveform_gen_rf );
STATUS
movewave( SHORT *pulse_mem,
          WF_PULSE_ADDR pulse,
          LONG index,
          INT resolution,
          HW_DIRECTION direction );
void
requestTransceiver( int bd_type,
                    exciterSelection e,
                    receiverSelection r );
void
requestTransceiverDemod( int bd_type,
                         exciterSelection e,
                         receiverSelection r,
                         demodSelection o,
                         navSelection n );
void
RFEnvelopeWaveformGeneratorCheck( const CHAR *pulse_name,
                                  const WF_PROCESSOR waveform_gen );
void
RFWaveformGeneratorCheck( const CHAR *pulse_name,
                          const WF_PROCESSOR waveform_gen );
STATUS
setattenlock( STATUS restore_flag,
              WF_PULSE_ADDR pulse );
STATUS
setctrl( LONG ctrl_mask,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
setfastdly( WF_PULSE_ADDR pulse,
            LONG deltics );
STATUS
setfreqphase( LONG frequency,
              LONG phase,
              WF_PULSE_ADDR pulse );
STATUS
setfrequency( LONG frequency,
              WF_PULSE_ADDR pulse,
              LONG index );
STATUS
setfreqarray( INT* frequency,
              WF_PULSE_ADDR pulse,
              LONG arraySize );
STATUS
setmrtouchdriver( const float freq,
                  const int cycles,
                  const int amp );
void
SetHWMem( void );
STATUS
setiamp( INT amplitude,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
setiampssp( LONG amplitude,
            WF_PULSE_ADDR pulse,
            LONG index );
STATUS
setiampall( INT amplitude,
            WF_PULSE_ADDR pulse,
            LONG index );
STATUS
setiamparray(SHORT* amplitude,
             WF_PULSE_ADDR pulse,
             LONG arraySize);
STATUS
setiampimm( INT amplitude,
            WF_PULSE_ADDR pulse,
            LONG index );
STATUS
setiamptimm( INT amplitude,
             WF_PULSE_ADDR pulse,
             LONG index );
STATUS
setiphase( LONG phase,
           WF_PULSE_ADDR pulse,
           LONG index );
STATUS
setphase( DOUBLE phase,
          WF_PULSE_ADDR pulse,
          LONG index );
STATUS
setphasearray( INT* phase,
               WF_PULSE_ADDR pulse,
               LONG arraySize );
STATUS
setiampt( INT amplitude,
          WF_PULSE_ADDR pulse,
          LONG index );
STATUS
setieos( INT eos_flag,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
setperiod( LONG period,
           WF_PULSE_ADDR pulse,
           LONG index );
STATUS
setrf( STATUS restore_flag,
       WF_PULSE_ADDR pulse,
       LONG index );
STATUS
setrfltrs( LONG filter_no,
           WF_PULSE_ADDR pulse );
STATUS
setEpifilter( LONG filter_no,
              WF_PULSE_ADDR pulse );
STATUS
settransceiver( INT board );
STATUS
setwampimm( INT amplitude,
            WF_PULSE_ADDR pulse,
            LONG index );
STATUS
setwamp( INT amplitude,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
setwave( WF_HW_WAVEFORM_PTR waveform_ix,
         WF_PULSE_ADDR pulse,
         LONG index );
void
simulationInit( long *rot_ptr );
STATUS
setweos( INT eos_flag,
         WF_PULSE_ADDR pulse,
         LONG index );
STATUS
sspextload( LONG *loc_addr,
            WF_PULSE_ADDR pulse,
            LONG index,
            INT resolution,
            HW_DIRECTION direction,
            SSP_S_ATTRIB s_attr );
STATUS
sspinit( INT psd_board_type );
STATUS
sspload( SHORT *loc_addr,
         WF_PULSE_ADDR pulse,
         LONG index,
         INT resolution,
         HW_DIRECTION direction,
         SSP_S_ATTRIB s_attr );
STATUS
syncon( WF_PULSE_ADDR pulse );
STATUS
syncoff( WF_PULSE_ADDR pulse );
STATUS
movewaversp( void );
STATUS
stretchpulse( INT oldres,
              INT newres,
              SHORT *opulse,
              SHORT *newpulse );
STATUS
AddToInstrQueue( WF_INSTR_QUEUE *queue,
                 WF_INSTR_HDR *instr_ptr );
ADDRESS
AllocNode( LONG size );
STATUS
FreeNode( ADDRESS address );
STATUS
FreePSDHeap( void );
ADDRESS
TempAllocNode( LONG size );
STATUS
BridgeTrap( WF_PULSE_ADDR *pulses,
            LONG n_pulses,
            STATUS bridge_first,
            WF_INSTR_QUEUE *queue );
STATUS
BuildBridgesIn( WF_INSTR_QUEUE *queue );
STATUS
CreatePulse( WF_PULSE_ADDR pulse,
             SeqData seqdata,
             WF_PROCESSOR waveform_gen,
             WF_PULSE_TYPES waveform_type,
             INT resol,
             WF_PULSE_EXT *extension,
             WF_HW_WAVEFORM_PTR wave_addr );
STATUS
FreePsdsQ( void );
STATUS
AddToPsdQ( WF_PULSE_ADDR pulse );
LONG
GetMinPeriod( WF_PROCESSOR waveform_gen,
              LONG pulse_width,
              const INT sworhw_flag );
INT
SetResol( LONG pulse_width,
          LONG min_period );
STATUS
TimeHist( const CHAR *ipgname );
STATUS
acqctrl( TYPDAB_PACKETS acqon_flag,
         INT recvr,
         WF_PULSE_ADDR pulse );
void
MsgHndlr( const CHAR *routine,
          ... );
STATUS
acqq( WF_PULSE_ADDR pulse,
      LONG pos_ref,
      LONG dab_ref,
      LONG xtr_ref,
      LONG fslot_value,
      TYPDAB_PACKETS cine_flag );
STATUS
propAcqq( WF_PULSE_ADDR pulse,
      LONG pos_ref,
      LONG dab_ref,
      LONG xtr_ref,
      LONG fslot_value);
STATUS
acqq2( WF_PULSE_ADDR dabpulse,
       WF_PULSE_ADDR rcvpulse,
       LONG pos_ref,
       LONG fslot_value,
       LONG dabstart,
       TYPDAB_PACKETS cine_flag,
       TYPACQ_PASS passthrough_flag );
STATUS
addrfbits( WF_PULSE_ADDR pulse,
           LONG offset,
           LONG refstart,
           LONG refduration );
STATUS
fastAddrfbits( WF_PULSE_ADDR pulse,
               LONG offset,
               LONG refstart,
               LONG refduration,
               LONG init_ublnk_time );
STATUS
setrfcontrol( SHORT selectamp,
              int mod_number,
              WF_PULSE_ADDR pulse,
              LONG index );
STATUS
attenflagon( WF_PULSE_ADDR pulse,
             LONG index );
STATUS
attenflagoff( WF_PULSE_ADDR pulse,
              LONG index );
STATUS
createatten( WF_PULSE_ADDR pulse,
             LONG start );
STATUS
createbits( WF_PULSE_ADDR pulse,
            WF_PROCESSOR waveform_gen,
            INT resol,
            SHORT *bits_array );
STATUS
createcine( WF_PULSE *pulse,
            const CHAR *name );
STATUS
createconst( WF_PULSE_ADDR pulse,
             WF_PROCESSOR waveform_gen,
             LONG pulse_width,
             INT amplitude );
STATUS
createextwave( WF_PULSE_ADDR pulse,
               WF_PROCESSOR waveform_gen,
               INT resol,
               CHAR *ext_wave_pathname );
void
destroyExtWave( void );
void
printExtWave( void );
STATUS
createhadamard( WF_PULSE_ADDR pulse,
                WF_PROCESSOR waveform_gen,
                INT resol,
                INT amplitude,
                DOUBLE sep,
                DOUBLE ncycles,
                DOUBLE alpha );
void
CleanUp( void );
STATUS
creatediffdab( WF_PULSE_ADDR pulse,
             LONG pos_ref );
STATUS
createhsdab( WF_PULSE_ADDR pulse,
             LONG pos_ref );
STATUS
createhscdab( WF_PULSE_ADDR pulse,
              LONG pos_ref,
              TYPDAB_PACKETS cine_flag );
STATUS
createinstr( WF_PULSE_ADDR pulse,
             LONG start,
             LONG pulse_width,
             LONG ampl );
STATUS
createpass( WF_PULSE_ADDR pulse,
            LONG start );
STATUS
createramp( WF_PULSE_ADDR pulse,
            WF_PROCESSOR waveform_gen,
            LONG pulse_width,
            INT start_amp,
            INT end_amp,
            INT resol,
            DOUBLE ramp_beta );
STATUS
createreserve( WF_PULSE_ADDR pulse,
               WF_PROCESSOR waveform_gen,
               INT resol );
STATUS
createsinc( WF_PULSE_ADDR pulse,
            WF_PROCESSOR waveform_gen,
            INT resol,
            INT amplitude,
            DOUBLE ncycles,
            DOUBLE alpha );
STATUS
createsinusoid( WF_PULSE_ADDR pulse,
                WF_PROCESSOR waveform_gen,
                INT resol,
                INT amplitude,
                DOUBLE start_phase,
                DOUBLE phase_length,
                INT offset );
STATUS
createseq( WF_PULSE_ADDR ssp_pulse,
           LONG length,
           long int *entry_array );
STATUS
createtraps( WF_PROCESSOR wgname,
             WF_PULSE *traparray,
             WF_PULSE *traparraya,
             WF_PULSE *traparrayd,
             INT ia_start,
             INT ia_end,
             DOUBLE a_base,
             DOUBLE a_delta,
             INT nsteps,
             INT pw_plateau,
             INT pw_attack,
             INT pw_decay,
             INT slope_direction,
             DOUBLE target_amp,
             DOUBLE beta );
STATUS
addubr( WF_PULSE_ADDR pulse,
        LONG pos_ref );
STATUS
createubr( WF_PULSE_ADDR pulse,
           LONG pos_ref,
           const INT index );
STATUS
dabrecorder( int record_mask );
STATUS
epiacqq( WF_PULSE_ADDR pulse,
         LONG pos_ref,
         LONG dab_ref,
         LONG xtr_ref,
         LONG fslot_value,
         TYPDAB_PACKETS cine_flag,
         LONG receiver_type,
         LONG dab_on );
STATUS
loaddab( WF_PULSE_ADDR pulse,
         LONG slice,
         LONG echo,
         LONG oper,
         LONG view,
         TYPDAB_PACKETS acqon_flag,
         LONG ctrlmask );
STATUS
loaddab_hub_r1( WF_PULSE_ADDR pulse,
                LONG slice,
                LONG echo,
                LONG oper,
                LONG view,
                LONG hubIndex,
                LONG r1Index,
                TYPDAB_PACKETS acqon_flag,
                LONG ctrlmask );
STATUS
loadpropdab( WF_PULSE_ADDR pulse,
         LONG oper,
         LONG frameType,
         LONG instanceIndex,
         LONG sliceIndex,
         LONG echotrainIndex,
         LONG bladeIndex,
         LONG bladeViewIndex,
         INT bladeAngle,
         LONG bValIndex,
         LONG diffDirIndex,
         LONG volIndex,
         TYPDAB_PACKETS acqon_flag,
         LONG ctrlmask );
STATUS
loaddabwithnex( WF_PULSE_ADDR pulse,
                LONG nex,
                LONG slice,
                LONG echo,
                LONG oper,
                LONG view,
                TYPDAB_PACKETS acqon_flag,
                LONG ctrlmask );
STATUS
loaddabwithangle( WF_PULSE_ADDR pulse,
                INT angle,
                LONG slice,
                LONG echo,
                LONG oper,
                LONG view,
                TYPDAB_PACKETS acqon_flag,
                LONG ctrlmask );
STATUS
loaddab2( WF_PULSE_ADDR pulse,
          WF_PULSE_ADDR rbapulse,
          LONG slice,
          LONG echo,
          LONG oper,
          LONG view,
          TYPDAB_PACKETS acqon_flag );
STATUS
load3d( WF_PULSE_ADDR pulse,
        LONG view,
        TYPDAB_PACKETS acqon_flag );
STATUS
loaddabecho( WF_PULSE_ADDR pulse,
             LONG echo );
STATUS
loaddaboper( WF_PULSE_ADDR pulse,
             LONG oper );
STATUS
loaddabset( WF_PULSE_ADDR pulse,
            TYPDAB_PACKETS dab_acq,
            TYPDAB_PACKETS rba_acq );
STATUS
loaddabslice( WF_PULSE_ADDR pulse,
              LONG slice );
STATUS
loaddabview( WF_PULSE_ADDR pulse,
             LONG view );
STATUS
load3decho( WF_PULSE_ADDR pulse,
            LONG view,
            LONG echo,
            TYPDAB_PACKETS acqon_flag );
STATUS
loadcine( WF_PULSE_ADDR pulse,
          INT arr,
          INT op,
          LONG pview,
          INT frame1,
          INT frame2,
          INT frame3,
          INT frame4,
          LONG delay,
          LONG fslice,
          TYPDAB_PACKETS acqon_flag );
STATUS
loaddiffdab( WF_PULSE_ADDR pulse,
           LONG ecno,
           LONG dab_op,
           LONG frame,
           LONG instance,
           LONG slnum,
           LONG vstart,
           LONG vskip,
           LONG numv,
           LONG bindex,
           LONG dirindex,
           LONG vol,
           LONG gradpol,
           TYPDAB_PACKETS acqon_flag,
           LONG ctrlmask );
STATUS
loadhsdab( WF_PULSE_ADDR pulse,
           LONG slnum,
           LONG ecno,
           LONG dab_op,
           LONG vstart,
           LONG vskip,
           LONG vnum,
           LONG card_rpt,
           LONG k_read,
           TYPDAB_PACKETS acqon_flag,
           LONG ctrlmask );
STATUS
movestretchedwave( const char* fileloc,
                   const int old_res,
                   WF_PULSE_ADDR pulse,
                   const int pulse_index,
                   const int new_res );
STATUS
movewave( SHORT *pulse_mem,
          WF_PULSE_ADDR pulse,
          LONG index,
          INT resolution,
          HW_DIRECTION direction );
STATUS
movewaveimm( SHORT *pulse_mem,
             WF_PULSE_ADDR pulse,
             LONG index,
             INT resolution,
             HW_DIRECTION direction );
STATUS
linkpulses( INT l_arg,
            ... );
STATUS
pulsename( WF_PULSE_ADDR pulse,
           const CHAR *pulse_name );
LONG
pbeg( WF_PULSE_ADDR pulse,
      const CHAR *pulse_name,
      LONG index );
LONG
pbegall( WF_PULSE_ADDR pulse,
         LONG index );
LONG
pbegallssp( WF_PULSE_ADDR pulse,
            LONG index );
LONG
pend( WF_PULSE_ADDR pulse,
      const CHAR *pulse_name,
      LONG index );
LONG
pendall( WF_PULSE_ADDR pulse,
         LONG index );
LONG
pendallssp( WF_PULSE_ADDR pulse,
            LONG index );
WF_INSTR_HDR
*GetFreqInstrNode( WF_PULSE *this_pulse,
                   LONG index,
                   const CHAR *name );
void
init_pgen_times( void );
void
print_pgen_times( void );
void
start_timer( long *start_time );
void
end_timer( long start_time,
           INT function_index,
           const CHAR *name );
LONG
pmid( WF_PULSE_ADDR pulse,
      const CHAR *pulse_name,
      LONG index );
LONG
pmidall( WF_PULSE_ADDR pulse,
         LONG index );
void
psdexit( INT ermes_no,
         INT abcode,
         const CHAR *txt_str,
         const CHAR *routine,
         ... );
STATUS
routeDataFrameDab( WF_PULSE_ADDR dab_pulse,
                   const DATA_FRAME_DESTINATION_E destination,
                   const INT coilswitchmethod );
STATUS
routeDataFrameXtr( WF_PULSE_ADDR xtr_pulse,
                   const DATA_FRAME_DESTINATION_E destination,
                   const INT coilswitchmethod );
STATUS
setnullpulsename( WF_PULSE_ADDR pulse);
STATUS
trapezoid( WF_PROCESSOR wgname,
           const CHAR *name,
           WF_PULSE_ADDR pulseptr,
           WF_PULSE_ADDR pulseptra,
           WF_PULSE_ADDR pulseptrd,
           LONG pw_pulse,
           LONG pw_pulsea,
           LONG pw_pulsed,
           LONG ia_pulse,
           LONG ia_pulsewa,
           LONG ia_pulsewb,
           LONG ia_start,
           LONG ia_end,
           LONG position,
           LONG trp_parts,
           LOG_GRAD *loggrd );
WF_INSTR_HDR
*GetPulseInstrNode( WF_PULSE_ADDR pulse,
                    LONG position );
STATUS
psd_update_spu_hrate( LONG hrate );
STATUS
psd_update_spu_trigger_window( LONG trigger_window );
STATUS
setdaboutcoilswitchhubindex( WF_PULSE_ADDR dab_pulse,
                             const DABOUTHUBINDEX_E index,
                             const INT coilswitchmethod );
int
get_disable_exciter_unblank( void );
STATUS
setiampiter( INT * amplitude,
          INT num_iters,
          WF_PULSE_ADDR pulse,
          LONG index,
          INT sign_flag);
STATUS
setiamptiter( INT * amplitude,
          INT num_iters,
          WF_PULSE_ADDR pulse,
          LONG index,
          INT sign_flag);
STATUS
settxattenabs( WF_PULSE_ADDR pulse,
               int wavegen_type,
               int txAttenI,
               int txAttenQ,
               float phaseQoffset );
STATUS
settxattendelta( WF_PULSE_ADDR pulse,
                 int wavegen_type,
                 int deltaTxAttenI,
                 int deltaTxAttenQ,
                 float deltaPhaseQoffset );
STATUS
initSeqCfg(void);
STATUS
setupSeqCfg(int rfgroup,
            int numapptxchannels,
            int rxflag,
            int rxtheta,
            int rxomega);
STATUS
getNumSeqIDs(int * numIDs);
STATUS
sortOutSeqs(int rfgroup);
STATUS
setPgenSeqFlag(int seqtype,
          int seqid,
          int * pgenflag);
STATUS
setTxSeqFlag(int seqtype,
        int * txflag);
STATUS
setSeqLegacyName(int seqtype,
                  int * legacyname);
int
getTxRxType(int seqname,
            int rxflag);
STATUS
getSeqID(int * seqid,
         int rfgroup,
         int seqname,
         int txchannel,
         int rxflag);
const SeqCfgSeqInfo *
getSeqInfo(int seqID);
void *
getSeqCfgData(void);
int
getNumAppTxChannels(int rfgroup);
STATUS
mapWavegen2SeqName(int * seqname,
                   WF_PROCESSOR waveform_gen);
STATUS
getWaveSeqOpt(int * seqopt,
              int rfgroup,
              int seqname,
              int ptxflag,
              int rxflag,
              int opmode);
STATUS
getWaveSeqDataWavegen(SeqData * seqdata,
                      WF_PROCESSOR wgen,
                      int rfgroup,
                      int ptxflag,
                      int rxflag, int opmode);
STATUS
getWaveSeqDataPulse(SeqData * seqdata,
                    WF_PULSE_ADDR pulse, int opmode);
STATUS
getWaveSeqDataPulsePtx(SeqData * seqdata,
                       WF_PULSE_ADDR pulse, int channel_index);
STATUS
getInstrSeqOpt(int * seqopt,
               int seqid,
               int opmode);
STATUS
getInstrSeqDataSeqID(SeqData * seqdata,
                     int seqid,
                     int opmode);
STATUS
getInstrSeqDataPulse(SeqData * seqdata,
                     WF_PULSE_ADDR pulse,
                     int opmode);
STATUS
getInstrSeqDataPulsePtx(SeqData * seqdata,
                        WF_PULSE_ADDR pulse,
                        int channel_index);
STATUS
setrxflag(WF_PULSE_ADDR pulse,
          int rxflag);
STATUS
setptxflag(WF_PULSE_ADDR pulse,
           int ptxflag);
STATUS
setrfgroup(WF_PULSE_ADDR pulse,
           int rfgroup);
STATUS
setiphasePtx(LONG phase,
             WF_PULSE_ADDR pulse,
             LONG index,
             INT channel_index);
STATUS
setiphasePtxall(LONG * phase,
                INT arraysize,
                WF_PULSE_ADDR pulse,
                LONG index);
STATUS
setiphasePtxallplus(LONG phase0,
                    LONG * phase,
                    INT arraysize,
                    WF_PULSE_ADDR pulse,
                    LONG index);
STATUS
setphasePtx(DOUBLE phase,
            WF_PULSE_ADDR pulse,
            LONG index,
            INT channel_index);
STATUS
setphasePtxall(DOUBLE * phase,
               INT arraysize,
               WF_PULSE_ADDR pulse,
               LONG index);
STATUS
setphasePtxallplus(DOUBLE phase0,
                   DOUBLE * phase,
                   INT arraysize,
                   WF_PULSE_ADDR pulse,
                   LONG index);
STATUS
setiampPtx(INT amplitude,
           WF_PULSE_ADDR pulse,
           LONG index,
           INT channel_index);
STATUS
setiampPtxall(INT * amplitude,
              INT arrarsize,
              WF_PULSE_ADDR pulse,
              LONG index);
STATUS
setiampPtxallsign(INT * amplitude,
                  INT sign_flag,
                  INT arrarsize,
                  WF_PULSE_ADDR pulse,
                  LONG index);
STATUS
movewaveimmPtx(SHORT *pulse_mem,
               WF_PULSE_ADDR pulse,
               LONG index,
               INT resolution,
               HW_DIRECTION direction,
               INT channel_index);
STATUS
movewaveimmPtxall(SHORT **pulse_mem,
                  INT arraysize,
                  WF_PULSE_ADDR pulse,
                  LONG index,
                  INT resolution,
                  HW_DIRECTION direction);
STATUS
sspextloadPtx(LONG *loc_addr1,
              WF_PULSE_ADDR pulse,
              LONG index, INT resolution,
              HW_DIRECTION direction,
              SSP_S_ATTRIB s_attr,
              INT channel_index);
STATUS
movewavememimm(WF_PULSE_ADDR pulse,
             WF_PROCESSOR waveform_gen,
             SHORT * pulse_mem,
             WF_HW_WAVEFORM_PTR moveto_mem,
             INT resolution,
             HW_DIRECTION direction );
INT
createwreserve( WF_PULSE_ADDR pulse,
               WF_PROCESSOR waveform_gen,
               INT resol );
INT
createwramp( WF_PULSE_ADDR pulse,
            WF_PROCESSOR waveform_gen,
            INT resol,
            INT start_amp,
            INT end_amp,
            DOUBLE ramp_beta );
int
getAppTxChannels( void );
int
getNumSeqs(void);
int
isPgenSeq(int seqid);
int
isTxSeq(int seqid);
int
getSeqLegacyName(int seqid);
int
getNumSecSsps(void);
int
getSecSspId(int seqid);
    int applyAcousticResponse( COMPLEX** cornerPoints, COMPLEX* nonWeightedAcousicResponse, COMPLEX* aWeightedAcousticResponse, int numFFTpoints) ;
    int isAcousticDataAvailable();
    const int NUM_POINTS_IN_TRANSFER_FUNC = 32768;
    void calculateSPL(COMPLEX* t_predSound,
            COMPLEX* t_predSoundA,
            int t_numPoints,
            float *t_maxdB,
            float *t_avgSPdb,
            float *t_avgSPdbA);
int limitByAcousticResonanceBands(int TR);
void resetAcousticParams();
int isEspLockoutRequired(int inputEsp, int &espIndex);
void getEspBounds(int &esp_lower, int &esp_upper, int esp_index);
n32 getCRCValueForAcousticLockout(int numesprange_x,int esprange_x[][2], float *espamp_x, int numesprange_y, int esprange_y[][2],
                       float *espamp_y,int numesprange_z, int esprange_z[][2], float *espamp_z);
int broadcast_autovoice_init(void);
int broadcast_autovoice_timing(int delayStartOffsetMS, int acqDelayMS, int playPostMessage, int playPreMessage);
int broadcast_scan_end_for_autovoice(void);
int set_autovoice_playing_state(int playingState);
STATUS HoecSetEchoTrainAmp(void);
STATUS HoecSetBlipAmp(int blipsw);
STATUS HoecCalcReceiverPhase(void);
STATUS ReadHoecCorrTerms(void);
STATUS
CalcPsdReconHoecCorr(int control_psd,
                     int control_recon,
                     int per_echo_corr,
                     int numSlices,
                     long rsprot[(2048)][9],
                     float t_array[7],
                     int echoSpacing,
                     int nechoBeforeTE,
                     int echoTrainLength,
                     int interleaves);
float g_error_kcenter(float R,
                      float amp,
                      float tau,
                      float t1,
                      float t2,
                      float t5,
                      float t10);
float g_error_kcenter2(float R1,
                       float R2,
                       float R3,
                       float R4,
                       float amp,
                       float tau,
                       float t1, float t2,
                       float t3, float t5,
                       float t6, float t7,
                       float t8, float t10);
void SaveHoecDebugInfo(int control_psd, int control_recon, int numSlices, float t_array[7], float r[3][3]);
void convertPhy2Log(float * output, int logTermIndex, int orderIndex, float rotm[3][3]);
void expandTrinomial(float output[21],
                     int index[3][21],
                     int num,
                     float rotm[3]);
int fractorial(int n);
STATUS failureClose(FILE * fp);
int isCommentOrBlankLine(char * str);
STATUS ChemSatEval( INT *time_cssat );
STATUS setupFatComponentT1( float *T1 );
STATUS ChemSatFlip( INT delay_time,
      INT tetime,
      INT rc_time,
      INT slquant,
      INT tr_time );
STATUS DBFlip( INT delay_time,
               INT tetime,
               INT rc_time,
               INT slquant,
               INT tr_time,
               INT sattime);
STATUS ChemSatFlip_T2flair( INT delay_time,
                            INT tetime,
                            INT rc_time,
                            INT slquant1,
                            INT tr_time,
                            INT packs,
                            INT ti_time,
                            INT seq_time,
                            INT ignore_ir );
INT Calc_Aspir_Null_TI_2DFSE(INT tr,
        INT slicesperacq,
        INT TESL,
        float Qfactor,
        float aspir_null_level);
STATUS ChemSatFlip_duo( INT delay_time,
                        INT tetime,
                        INT rc_time,
                        INT slquant,
                        INT tr_time,
                        INT sattime );
float
ChemSatFlip_duo_sub( INT delay_time,
       INT tetime,
       INT rc_time,
       INT slquant,
       INT tr_time,
       INT cs_sattime,
       INT alpha,
       float delta_signal,
       INT *remnant_signal_flags,
       double* spec_prof);
float
Signal_fat_duo( INT delay_time,
                INT tetime,
                INT rc_time,
                INT slquant,
                INT tr_time,
                INT cs_sattime,
                INT alpha,
                INT beta,
                double* spec_prof);
STATUS ChemSatCheck( void );
STATUS SelectSpSpFatSatPulse(void);
STATUS ChemSatPG( INT chemsat_start, INT *cssat_index );
STATUS CsSatMod( INT num_chemsats );
STATUS CsSatMod_duo( INT num_chemsats );
STATUS CsSatPrep( INT num_chemsats );
STATUS CsSatChopKiller( INT num_chemsats );
STATUS SpSpFatSatRsp(void);
STATUS aps1( void );
STATUS aps2( void );
STATUS autoshim( void );
STATUS calcPulseParams( int max_encode_mode );
STATUS cfh( void );
STATUS cfl( void );
STATUS cvcheck( void );
STATUS cveval( void );
STATUS cvevaliopts( void );
STATUS cvfeatureiopts( void );
STATUS cvinit( void );
STATUS cvsetfeatures( void );
STATUS fasttg( void );
STATUS expresstg( void );
STATUS mps1( void );
STATUS mps2( void );
STATUS mapTg( void );
STATUS predownload( void );
n32 psdcleanup(n32 abort);
STATUS psdinit( void );
void psd_init_iopts( void );
STATUS pulsegen( void );
STATUS scan( void );
STATUS scanloop( void );
STATUS syscheck( INT *syscheck_safety_limit, int *status_flag );
float parab( float amp, float time, float offset);
void myscan(void);
STATUS cveval1(void);
STATUS getminesp( FILTER_INFO epi_filt,
               INT xtr_pkt_off,
               INT ileaves,
               INT hrd_per,
               INT vrgf_on,
               INT *minesp );
STATUS avmintecalc(void);
STATUS setburstmode(void);
STATUS setb0rotmats(void);
STATUS nexcalc(void);
STATUS predownload1(void);
STATUS setUserCVs(void);
void ssisat(void);
void dummyssi(void);
STATUS setupphases(int *phase,int *freq,int slice,float rel_phase,int time_delay, int sign_flag);
STATUS makephaseencode(int pos);
STATUS makephaserewinder(int pos);
STATUS CardInit(
    int ctlend_tab[], int ctlend_intern,int ctlend_last[],
    int ctlend_fill[],int ctlend_unfill[], int subhacq, int subhrep, int subphases);
STATUS ref(void);
STATUS ref_init(void);
STATUS fstune(void);
STATUS rtd(void);
STATUS scan_init(void);
STATUS recv_phase_freq_init(void);
STATUS scanloop(void);
STATUS core(void);
STATUS blineacq(void);
STATUS dabrbaload(int blipsw, int blipstart, int blipinc, int numblips, int fovshift);
STATUS diffamp( int dshot );
STATUS diffstep( int dshot );
STATUS ddpgatetrig(void);
STATUS msmpTrig(void);
STATUS phaseReset(WF_PULSE_ADDR pulse, int control);
STATUS pgatetrig(void);
STATUS pgatedelay(void);
STATUS setreadpolarity(void);
STATUS ygradctrl(int blipsw,int blipwamp,int numblips);
STATUS zgradctrl(int blipsw, int blipstart, int blipinc, int numblips, int fovshift);
STATUS getfiltdelay(float *delay_val,int fastrec,int vrgfflag);
STATUS rotateToLogical(float * idifx, float * idify, float * idifz, int dir);
STATUS inversRspRot(float inversRot[9], long origRot[9]);
STATUS reset_for_scan( void );
void getDiffGradAmp(float * difx, float * dify, float * difz, int dshot);
void loadDiffVecMatrix(void);
STATUS set_diff_order();
int get_diff_order(int pass, int slice);
int getLCD(int a, int b);
STATUS get_gy1_time(void);
STATUS get_flowcomp_time(void);
int get_extra_dpc_tetime(void);
int get_extra_rtb0_tetime(void);
STATUS dwicorrcal( float dwigcorr[9], float dwibcorr[3], float dwikcorr[9],
                   int control, int debug, long rsprot[(2048)][9],
                   int xfs, int yfs, int zfs, float t_array[7] );
float k_error( float R, float amp, float tau, float t1, float t2,
               float t3, float t4, float t9, float d4, float delta);
float g_error( float R, float amp, float tau, float t1, float t2,
               float t5, float t10 );
float get_fa_scaling_factor_ir(float act_fa, float nom_fa, float nom_max_b1);
STATUS
psd_init_iopt_activity( void );
int
ioptlist_cvnum( void );
STATUS
activate_ioption( const int iopt );
STATUS
activate_iopt_list( const int numopts,
                    const int *ioptarr );
STATUS
display_all_iopts( void );
STATUS
deactivate_ioption( const int iopt );
STATUS
deactivate_iopt_list( const int numopts,
                      const int *ioptarr );
STATUS
deactivate_all_iopts( void );
STATUS
enable_ioption( const int iopt );
STATUS
enable_iopt_list( const int numopts,
                  const int *ioptarr );
STATUS
disable_ioption( const int iopt );
STATUS
disable_iopt_list( const int numopts,
                   const int *ioptarr );
void
set_base_iopt_compatibilities( void );
STATUS
set_compatibility( const int iopt1,
                   const int iopt2,
                   const short compatibility );
STATUS
set_compatible( const int iopt1,
                const int iopt2 );
STATUS
set_incompatible( const int iopt1,
                  const int iopt2 );
STATUS
set_list_compatible( const int iopt1,
                     const int *ioptarr,
                     const int numopts );
STATUS
set_list_incompatible( const int iopt1,
                       const int *ioptarr,
                       const int numopts );
STATUS
set_forcing( const int iopt1,
             const int iopt2 );
STATUS
set_required_disabled_option( const int iopt1 );
STATUS
set_disallowed_option( const int iopt1 );
int
return_iopt_activity( const int iopt );
int
return_iopt_compatibility( const int iopt1,
                           const int iopt2 );
int
iopt_key( const int the_iopt );
int
valid_iopt_key( const int the_key );
STATUS
set_iopt_key( const int the_iopt,
              const int the_key );
STATUS
iopt_cvcheck( void );
int
is_iopt_selected( const int the_iopt );
int
return_iopt_cv_num( const int the_iopt );
int
return_iopt_cv_on_val( const int the_iopt );
int
return_iopt_cv_off_val( const int the_iopt );
STATUS
return_iopt_cv_name( const int the_iopt,
                     char *iopt_cv );
void
return_iopt_name(int iopt_num,char *iopt_name);
int
find_iopt_by_cv_name( char *iopt_cv );
void sp_init_rf( INT *pw_ptr,FLOAT *amp_ptr, FLOAT *flip_ptr,INT type,
                 RF_PULSE *rfstruct );
STATUS SpSatInit( INT sat_type);
void sp_set_num_pulses( RF_PULSE *rf_struct, GRAD_PULSE *grad_struct);
void sp_set_rfpulse( INT pulse_type, RF_PULSE *rf_struct, INT *resoln,
                     INT *pw_rf,INT *bw_rf, INT sat_band_type );
STATUS sp_set_slice_select( INT *pw_slice_select, INT *pw_slice_select_a,
                            INT *pw_slice_select_d, INT pw_rf,
                            FLOAT *amp_slice_select, INT *bw_rf,
                            DOUBLE thickness, DOUBLE targetamp,
                            INT target_rt, INT pulse_type );
STATUS sp_initrfpulseInfo( RF_PULSE_INFO rfPulseInfo[], INT pulse );
STATUS sp_scalerfpulses( DOUBLE weight, GRADIENT_COIL_E gcoiltype,
                         RF_PULSE rfpulse[], INT numentry,
                         RF_PULSE_INFO rfPulseInfo[], INT pulse );
void sp_get_rot_matrix( float *source, long *dest );
void sp_get_scaninfo_matrix(float *source, SCAN_INFO * dest);
STATUS sp_init_satloggrd( LOG_GRAD *sloggrd );
STATUS SpSatEval( INT *time_spsat );
STATUS SpSatCheck( void );
void SatGetZOffset( DOUBLE locpos, DOUBLE locneg,
                    INT *offset1, INT *offset2 );
int SatCatRelaxtime( INT acqs,INT seq_time,INT seq_type );
STATUS SatPlacement( INT numPasses );
STATUS SpSatIAmp( void );
STATUS SpSatPG( INT sat_type, INT start_time,
                INT *sat_index, INT cardiacsat_pos );
STATUS SpSatPG_fgre( INT sat_type, INT start_time,
                     INT *sat_index, INT cardiacsat_pos,
                     INT seq_time );
STATUS SpSatCatRelaxPG( INT ssi_time );
STATUS SpSatCatRelaxOffsets( SEQUENCE_ENTRIES sequence_offsets );
void dump_sat_input( void );
void sp_dump_rsp_rot( INT ir_mode );
void sp_dump_sat_rot( void );
void sp_set_rot_matrix( void );
void sp_set_rot_matrix_card( void );
void sp_set_rot_matrix_seqir123( void );
void sp_set_rot_matrix_seqir12( void );
void sp_set_rot_matrix_seqir13( void );
STATUS sp_update_rot_matrix( long *slice_rot_matrix, long (*sat_rot_array)[9],
                             const INT num_explicit_sats,
                             const INT num_default_sats );
void SpSat_set_sat1_matrix( long (*orig_rot_matrix)[9],
                            long (*new_rot_matrix)[9],
                            int entries, long (*sat_array)[9],
                            int num_explicit_sats, int num_default_sats,
                            int cardiacsat_pos, int sequence_flag );
STATUS SpSatInitRsp( INT num_sat_grps, INT cardiacsat_pos, INT ir_sattype );
STATUS SpSatUpdateRsp( INT num_sat_grps, INT pass, INT cat_seq_type );
STATUS SpSatPlayRelaxers( void );
STATUS SpSatChop( void );
STATUS SpSatChopKiller( void );
void SpSatSPGR( INT phase );
void SpSat_Satoff(INT sat_index );
void SpSat_Saton( INT sat_index);
void SpSat_Satrfoff( INT sat_index );
void SpSat_Satrfon( INT sat_index );
STATUS PScvinit(void);
STATUS PS1cvinit(void);
STATUS CFLcvinit(void);
STATUS CFHcvinit(void);
STATUS FTGcvinit(void);
STATUS XTGcvinit(void);
STATUS RGcvinit(void);
STATUS AScvinit(void);
STATUS RCVNcvinit(void);
STATUS DTGcvinit(void);
STATUS RScvinit(void);
STATUS ExtCalcvinit(void);
STATUS AutoCoilcvinit(void);
STATUS PScveval(void);
STATUS PScveval1(int local_ps_te);
STATUS PS1cveval(FLOAT *opthickPS);
STATUS CFLcveval(FLOAT opthickPS);
STATUS CFHfilter(int xres);
STATUS CFHcveval(FLOAT opthickPS);
STATUS FTGcveval(void);
STATUS XTGcveval(void);
STATUS RGcveval(void);
STATUS AScveval(void);
STATUS RCVNcveval(void);
STATUS DTGcveval(void);
STATUS RScveval(void);
STATUS ExtCalcveval(void);
STATUS AutoCoilcveval(void);
STATUS PSfilter(void);
STATUS PSpredownload(void);
STATUS PS1predownload(void);
STATUS CFLpredownload(void);
STATUS CFHpredownload(void);
STATUS FTGpredownload(void);
STATUS XTGpredownload(void);
STATUS ASpredownload(void);
STATUS DTGpredownload(void);
STATUS RSpredownload(void);
STATUS ExtCalpredownload(void);
STATUS AutoCoilpredownload(void);
STATUS RCVNpredownload(void);
STATUS
generateZyIndex(ZY_INDEX * zy_index,
                const int zy_views,
                const int zy_slices,
                const float yFov,
                const float zFov,
                const int psc_pfkr_flag,
                const float psc_pfkr_fraction,
                int *zy_sampledPoints);
int psc_dist_compare(const void *dist1, const void *dist2);
STATUS mps1(void);
STATUS aps1(void);
STATUS cfl(void);
STATUS cfh(void);
STATUS fasttg(void);
STATUS expresstg(void);
STATUS RFshim(void);
STATUS DynTG(void);
STATUS mapTg(void);
STATUS Autocoil(void);
STATUS extcal(void);
STATUS autoshim(void);
STATUS rcvn(void);
STATUS avg(void);
STATUS single1(void);
STATUS aws(void);
STATUS PSpulsegen(void);
STATUS PS1pulsegen(INT posstart);
STATUS CFLpulsegen(INT posstart);
STATUS CFHpulsegen(INT posstart);
STATUS FTGpulsegen(void);
STATUS XTGpulsegen(void);
STATUS ASpulsegen(void);
STATUS RCVNpulsegen(INT posstart);
STATUS DTGpulsegen(void);
STATUS ExtCalpulsegen(void);
STATUS AutoCoilpulsegen(void);
STATUS SliceAcqOrder(int *sl_acq_order, int rx_sls);
STATUS RSpulsegen(void);
STATUS PSmps1(INT mps1nex);
STATUS PScfl(void);
STATUS PScfh(void);
STATUS PSrcvn(void);
STATUS NoiseCalrcvn(void);
void StIRMod(void);
STATUS PSinit(long (*PSrotmat)[9]);
STATUS PSfasttg(INT pre_slice, INT debugstate);
STATUS PSexpresstg(INT pre_slice, INT debugstate);
STATUS PSrfshim(void);
STATUS PSdyntg(void);
STATUS PSextcal(void);
STATUS PSautocoil(void);
STATUS FastTGCore( DOUBLE slice_loc, INT ftg_disdaqs, INT ftg_views,
                   INT ftg_nex, INT ftg_debug );
STATUS eXpressTGCore( DOUBLE slice_loc, INT xtg_disdaqs, INT xtg_views,
                   INT xtg_nex, INT xtg_debug );
INT ASautoshim(INT rspsct);
STATUS CoilSwitchSetCoil( const COIL_INFO coil,
                          const INT setRcvPortFlag);
int CoilSwitchGetTR(const int setRcvPortFlag);
int doTG(int psd_psc_control);
int doAS(int psd_psc_control);
STATUS phase_ordering(SHORT *view_tab, const INT phase_order, const INT yviews, const INT yetl);
void SDL_PrintFStrengthWarning( const int psdCode,
                                const int fieldStrength,
                                const char * const fileName,
                                const int lineNo );
void SDL_Print0_7Debug( const int psdCode,
                        const char *const fileName,
                        const int lineNo);
void SDL_Print3_0Debug( const int psdCode,
                        const char *const fileName,
                        const int lineNo);
void SDL_Print4_0Debug( const int psdCode,
                        const char *const fileName,
                        const int lineNo);
void SDL_FStrengthPanic( const int psdCode,
                         const int fieldStrength,
                         const char *const fileName,
                         const int lineNo);
STATUS SDL_CheckValidFieldStrength( const int psdCode,
                                    const int fieldStrength,
                                    const int use_ermes );
void SDL_SetLimTE( const int psdCode,
                   const int fStrength,
                   const int opautote,
                   int * const llimte1,
                   int * const llimte2,
                   int * const llimte3,
                   int * const ulimte1,
                   int * const ulimte2,
                   int * const ulimte3 );
void SDL_CalcRF1RF2Scale( const int psdCode,
                          const int fStrength,
                          const int coilType,
                          const float slThickness,
                          float * const gscale_rf1,
                          float * const gscale_rf2,
                          float * const gscale_rf1se1,
                          float * const gscale_rf1se2 );
void SDL_SetFOV( const int psdCode,
                 const int fStrength );
void SDL_SetSLTHICK( const int psdCode,
                     const int fStrength );
void SDL_SetCS( const int psdCode,
                const int fStrength );
    float SDL_GetChemicalShift( const int fStrength );
    STATUS SDL_RFDerating( double * const deRateB1,
                           const int fStrength,
                           const double weight,
                           const TX_COIL_INFO txCoil,
                           const GRADIENT_COIL_E gcoiltype );
    STATUS SDL_RFDerating_calc( double * const deRateB1,
                                const int fStrength,
                                const double weight,
                                const TX_COIL_INFO txCoil,
                                const GRADIENT_COIL_E gcoiltype,
                                const int prescan_entry,
                                double safety_factor );
    STATUS SDL_RFDerating_entry( double * const deRateB1,
                                 const int fStrength,
                                 const double weight,
                                 const TX_COIL_INFO txCoil,
                                 const GRADIENT_COIL_E gcoiltype,
                                 const int entry );
    STATUS SDL_RFDerating_entry_sat( double * const deRateB1,
                                     const int fStrength,
                                     const double weight,
                                     const TX_COIL_INFO txCoil,
                                     const GRADIENT_COIL_E gcoiltype,
                                     const int entry,
                                     const double safetyfactor );
    void SDL_InitSPSATRFPulseInfo( const int fStrength,
                                   const int rfSlot,
                                   int * const pw_rfse1,
                                   RF_PULSE_INFO rfPulseInfo[] );
int dynTG_sliceloc(float *dynTG_sliceloc, const int dynTG_nslices, const int imaging_nslices, const int debug_flag);
STATUS ssInit(void);
STATUS ssEval1(void);
STATUS ssEval2(void);
float get_fa_scaling_factor_ss(float * max_fa, float act_fa, float nom_fa, float nom_max_b1);
STATUS ssCheck(void);
STATUS ssRsp(void);
STATUS ssRsp3D(void);
STATUS DTI_Init(void);
STATUS DTI_Eval(void);
STATUS DTI_Predownload(void);
STATUS DTI_Check(void);
STATUS verify_bvalue(FLOAT *curr_bvalue,
                     const FLOAT rf_excite_location,
                     const FLOAT *rf_180_location,
                     const INT num180s,
                     const INT seq_entry_index,
                     const INT bmat_flag,
                     const INT debug);
STATUS calc_b_matrix( FLOAT * curr_bvalue,
                      const FLOAT rf_excite_location,
                      const FLOAT * rf_180_location,
                      const INT num180s,
                      const INT seq_entry_index,
                      const INT bmat_flag,
                      const INT seg_debug);
STATUS pgen_calcbvalue(FLOAT *bvalue,
                       const FLOAT rf_excite_location,
                       const FLOAT *rf_180_location,
                       const INT num_180s,
                       const FLOAT te,
                       const FLOAT gam,
                       const LOG_GRAD *log_grad,
                       const INT seq_entry_index,
                       const INT samp_rate,
                       const INT pgen_tr,
                       const INT e_flag,
                       const INT debug_flag,
                       const INT bmat_flag);
void calcpwabc(double b_target, int wait_time, int rf2_time, double gmax, int ramp, int *pwa, int *pwb, int *pwc);
int gCoilType = PSD_XRMW_COIL;
STATUS init_arc_variables(void);
STATUS reset_accel_variables(void);
STATUS print_arc_params(void);
void print_asset_params(void);
STATUS initialize_arc_asset_variables(void);
STATUS read_rfpulse_info(void);
STATUS rfov_cveval(void);
STATUS type1_control(void);
void value_system_grad_scale(void);
STATUS walk_sat_RFinit(void);
STATUS walk_sat_cveval(void);
STATUS walk_sat_timing(void);
int set_psd_rf_wait_delta(void);
float calcdbdtper_rfov(void);
float calcdbdtper_rfov2(void);
float intercept_rfov(float y1, float y2, int xl, int x);
void print_corner_point_rfov(int nump, int * tcon, float * aconx, float * acony);
void print_dbdtper_rfov(float the_dbdtper, int nump, int * tcon, float * dbdtper_x, float * dbdtper_y, float * dbdtper_t);
float get_fa_scaling_factor_rfov(float * max_fa, float act_fa, float nom_fa, float nom_max_b1);
void walk_sat_scaleRF(void);
void integrate2_add_phase(short *thwaveout, float phaseinit, short *omegawave1, float ia_omegawave1,
                          short *omegawave2, float ia_omegawave2, int npoints);
STATUS walk_sat_pulsegen(void);
STATUS rfov_pulsegen(void);
void setrfwk(void);
void setthetarf1(int num);
STATUS Multiband_cvinit(void);
STATUS Multiband_cveval(int);
void winsinc(int *rtrf, int points, float tbp, int wtype, float gwidth,
                          int mux_slices, float mux_slice_shift_mm, float thk, int mux_index, int mux_mode);
void setuprfpulse_mux(int *rtwave, int *wfres, float *wfflip, int *wfpw, float wfbw, float iso,
                        float gam, int rfslotnum,unsigned int wfactivity, float *ampl);
float get_fa_scaling_factor_multiband(float * max_fa, float act_fa, float nom_fa, float nom_max_b1, int mux_factor);
STATUS Multiband_pulsegen_rf1(void);
STATUS Multiband_pulsegen_rf2(int *RF2Location, short *temp_wave_space);
WF_PULSE thetarf2 = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2a = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2d = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2left = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2lefta = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2leftd = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2right = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2righta = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE thetarf2rightd = {"<uninitialized>",0,-1, PSDCERD, PSDREUSEP, SSPUNKN, 0, 0, 0, (WF_INSTR_HDR*)((void *)0), (WF_INSTR_HDR*)((void *)0), TYPXGRAD, TYPBITS, 0, (struct PULSE*)((void *)0), (WF_PULSE_EXT*)((void *)0), 0, 0, 0, 0, {0}};
WF_PULSE index_rf2[10]; ;
WF_HW_WAVEFORM_PTR ptr_rf2[10];
float calc_cross_tr(int n1,
                    int n2,
                    float t1min,
                    float t2min,
                    float start_tr,
                    float tolerance,
                    int numAcqs,
                    float minimum_tr,
                    int boundary_type);
float calcEffT1CSF(float slice_interval,
                   float eff_slthick,
                   float eff_invthick);
float get_invthick(int numAcqs);
float getNullTI(int repetitionTime,
                int relaxationTime,
                float slice_interval,
                float eff_slthick,
                float eff_invthick);
float getNullTR(int inversionTime,
                int null_period,
                float slice_interval,
                float eff_slthick,
                float eff_invthick);
STATUS
T1flair_analytical_ManualTR(void);
STATUS
T1flair_analytical_AutoTR (int tmpnumAcqs);
STATUS
T1flair_analytical_seqtime(void);
STATUS
maxslquant1_T2flair(INT Maxslquant,
                    INT *requestedTR,
                    INT null_period,
                    INT Packs,
                    INT acqType,
                    INT seqTimPresc,
                    INT gating);
STATUS
T2flair_automintr_set_display_acqs( int null_period, int Packs );
int automintr_compatibility_checks(void);
STATUS automintr_set_display_acqs(void) ;
STATUS automintr_set_display_acqs_enh(int dummyslice_type);
STATUS eco_mpg_cvinit(void);
STATUS eco_mpg_cveval(void);
STATUS mpg_opt_gen(int avail_time,
                   int time_180,
                   int t1,
                   int tv1,
                   int t2,
                   int tv2,
                   int t3,
                   float maxG,
                   float SR,
                   float b_target,
                   int axis_flag);
STATUS mpg_opt_timing(int tmp_axis_flag,
                      int tmp_Delta_time,
                      float tmp_MaxAmp,
                      float tmp_bvaltemp);
STATUS dse_opt_timing(float b_target,
                      int pw_d1_guess,
                      int pw_ramp,
                      int pw_delta,
                      float gmax);
float eco_mpg_calcbval(float *g, float *t, int n);
FILE *fp_coreinfo;
FILE *fp_diff_order;
FILE *fp_cfdata;
FILE *fp_utloopinfo;
STATUS Monitor_Cvinit( RF_PULSE Rfpulse[] );
STATUS Monitor_CvevalInit( RF_PULSE Rfpulse[] );
STATUS Monitor_Eval( RF_PULSE Rfpulse[], INT numPulses,
                     FLOAT *average_sar, FLOAT *avecoil_sar, FLOAT *peak_sar_mon );
STATUS Calc_Monitor_Acq_Delay(INT Act_tr);
STATUS Monitor_setpulsenumoff( RF_PULSE Rfpulse[] );
STATUS Monitor_setpulsenumon( RF_PULSE Rfpulse[] );
STATUS monitor_cveval( RF_PULSE Rfpulse[], INT numPulses,
                       FLOAT *average_sar, FLOAT *avecoil_sar, FLOAT *peak_sar_mon);
STATUS dump_rot( long rotation_matrix[] );
STATUS Monitor_Predownload( RF_PULSE Rfpulse[], ENTRY_POINT_TABLE entryPoint[], INT numPulses,
                            INT actTR, FLOAT *average_sar, FLOAT *avecoil_sar, FLOAT *peak_sar_mon );
STATUS monitorCalcSar( RF_PULSE Rfpulse[], const INT numPulses,
                       FLOAT *average_sar, FLOAT *avecoil_sar, FLOAT *peak_sar_mon1 );
void resetPulseNumActivity( RF_PULSE Rfpulse[] );
STATUS Monitor_Cvcheck(void);
STATUS monitor_PG(void);
STATUS Monitor_pulsegen(void);
STATUS Monitor_Download(void);
void Monitor_load_SmartPrep_RTPtask(void);
STATUS monitor_write_data_file(void);
STATUS monitor_core( INT acquire_data,INT sliceindex,
                  INT standalone);
STATUS monitor_signal(void);
int getSmartPrepFeedback(int * detected, float * signal);
typedef enum CYLR_RF_TYPE
{
    CYLR_CONSTANT_DENSITY = 0,
    CYLR_VARIABLE_DENSITY_SR48,
    CYLR_VARIABLE_DENSITY_SR75,
    CYLR_VARIABLE_DENSITY_SR107,
    CYLR_VARIABLE_DENSITY_SR118,
    CYLR_VARIABLE_DENSITY_SR145,
    CYLR_VARIABLE_DENSITY_SR190,
    NUM_CYLR_RF_TYPE
} CYLR_RF_TYPE_E;
typedef struct
{
    n32 queueDepth;
    n32 queueOverflowOption;
} RTP_OPCODE_OPTIONS;
enum
{
    RTP_STOP_THE_SCAN,
    RTP_REMOVE_OLDEST_MSG
};
void rtp_register_callback( void (*func_ptr)(void*) );
void rtp_unregister_callback( );
int rtp_register_opcode(n32 opcode, n32 msgSize, RTP_OPCODE_OPTIONS* options);
int rtp_get_feedback_data(void* data, n32 size_in_bytes, n32* packed, n32 opcode, n32 reqType);
extern void rtp_feedback_task(void);
enum {
    RTP_QUEUE_OLDEST = 1,
    RTP_QUEUE_NEWEST
};
typedef struct _RtpBufferHeader {
    short frameSize;
    short pointSize;
    short numRtpReceivers;
    long acquiredIndex;
    long processedIndex;
} RtpBufferHeader;
typedef struct _RtpDataTransportStruct {
    char path[50];
    char func[50];
    short frameSize;
    short dacqType;
    short numRtpReceivers;
    short bodyCoilCombine;
    short hubIndex;
    long acquiredIndex;
    long processedIndex;
    char charArrayVar_1[50];
    char charArrayVar_2[50];
    char charArrayVar_3[50];
    float floatVar_1;
    float floatVar_2;
    float floatVar_3;
    float floatVar_4;
    float floatVar_5;
    float floatVar_6;
    float floatVar_7;
    float floatVar_8;
    float floatVar_9;
    float floatVar_10;
    float floatVar_11;
    float floatVar_12;
    float floatVar_13;
    float floatVar_14;
    float floatVar_15;
    int intVar_1;
    int intVar_2;
    int intVar_3;
    int intVar_4;
    int intVar_5;
    int intVar_6;
    int intVar_7;
    int intVar_8;
    int intVar_9;
    int intVar_10;
    int intVar_11;
    int intVar_12;
    int intVar_13;
    int intVar_14;
    int intVar_15;
    long longVar_1;
    long longVar_2;
    long longVar_3;
    long longVar_4;
    long longVar_5;
    long longVar_6;
    long longVar_7;
    long longVar_8;
    long longVar_9;
    long longVar_10;
    long longVar_11;
    long longVar_12;
    long longVar_13;
    long longVar_14;
    long longVar_15;
    short writeRawData;
    short vreDebug;
} RtpDataTransportStruct;
typedef struct _RtpUnpackedResult
{
    n32 opcode;
    n8 data[((2048) - sizeof(OP_HDR_TYPE) - 4 * sizeof(n32))];
} RtpUnpackedResult;
typedef struct _RtpResultStruct {
    n32 packedResult;
    n32 packedResultValid;
    n32 unpackedResultSize;
    RtpUnpackedResult unpackedResult;
} RtpResultStruct;
typedef struct _RtpSimpleData
{
    long l;
    float f;
    void* p;
    short s;
    char c;
} RtpSimpleData;
typedef struct _RtpSimplePkt
{
    OP_HDR_TYPE hdr;
    RtpSimpleData rtpData;
} RtpSimplePkt;
typedef struct _RtpDataValuesPkt
{
    OP_HDR_TYPE hdr;
    RtpDataTransportStruct rtpDataVal;
} RtpDataValuesPkt;
typedef struct _RtpProcessedResultsPkt
{
    OP_HDR_TYPE hdr;
    RtpResultStruct rtpResults;
} RtpProcessedResultsPkt;
typedef struct _RtpTaskData
{
    unsigned long subOpcode;
    float currVal;
} RtpTaskData;
typedef struct _RtpTaskPkt
{
    OP_HDR_TYPE hdr;
    RtpTaskData data;
} RtpTaskPkt;
typedef struct _RtpDataToPsdTask
{
    n32 subOpcode;
    n32 n32vals[16];
    s32 s32vals[16];
    f32 f32vals[16];
    f64 f64vals[16];
} RtpDataToPsdTask;
typedef struct _RtpDataToPsdTaskPkt
{
    OP_HDR_TYPE hdr;
    RtpDataToPsdTask data;
} RtpDataToPsdTaskPkt;
STATUS NavigatorCvevalInit(void);
STATUS NavigatorEval(void);
STATUS NavigatorPlayContRf( INT NumDisdaqs, INT StartIndex );
STATUS NavigatorPlaySPGR( INT NumDisdaqs, INT navg_calc );
STATUS NavigatorPlayAlone(INT NumNavs, INT navTR, INT *nav_rrmeas_end);
STATUS NavigatorRspInit( void );
STATUS get_navigator_histogram(FLOAT *trigger_point);
STATUS get_navigator_phase(INT slice_index, INT nav_tr, FLOAT *nav_phase);
STATUS navigator_set_deltapixel(FLOAT trig_phase);
STATUS navigator_reset_iter(SHORT iter);
STATUS navigator_set_accwindow (FLOAT auto_accwin);
STATUS write_navigator_data_file( void );
STATUS NavigatorSat(void);
STATUS NavigatorTipUp(void);
STATUS navigator_baseline_prescan(INT *nav_rrmeas_end);
STATUS NavigatorPlayTrig(void);
STATUS NavigatorPlayGate(void);
int getNavigatorFeedback(int * processedIndex, float * phase);
typedef enum NAV_ALG {
    NAV_ALG_LSQ = 0,
    NAV_ALG_ED_DERIV = 1,
    NAV_ALG_AHN_PHASE = 2,
    NAV_ALG_ED_THRESH = 3
} _NAV_ALG;
typedef enum NAV_SAVE {
    NAV_SAVE_NONE = 0,
    NAV_SAVE_PHASE = 1,
    NAV_SAVE_RAWDATA = 2
} _NAV_SAVE;
typedef struct _DataPacket
{
   long state;
   float phase;
   float refphase;
   short detected;
   short curiter;
   short sequence;
   short frameSize;
   short pointSize;
   short baselines;
   float fov_factor;
   float navwindow;
   float acqmonfov;
   float hrate;
   float hist_time;
   long start_coil;
   long end_coil;
   int trig_mode;
   float datamagn[256];
   int mon_mode;
   int respRate;
   short scantime;
   int hrate_ctrl_mode;
   long messageNo;
} DataPacket;
typedef struct _NavigatorEventPkt
{
   OP_HDR_TYPE hdr;
   DataPacket data;
} NavigatorEventPkt;
typedef struct _NavigatorResult
{
    s32 processedIndex;
    f32 phase;
} NavigatorResult;
long nav_channel_bit[4] = {0x0, 0x0, 0x0, 0x0};
long navscm_channel_bit[4] = {0x0, 0x0, 0x0, 0x0};
long _firstcv = 0;
int psd_annefact_level = 0
;
int rhpsd_annefact_level = 0
;
float psd_relative_excited_volume_freq = -1.0
;
float psd_relative_excited_volume_phase = -1.0
;
float psd_relative_excited_volume_slice = 1.0
;
float psd_relative_encoded_volume_freq = -1.0
;
float psd_relative_encoded_volume_phase = 1.0
;
float psd_relative_encoded_volume_slice = 1.0
;
int opresearch = 0
;
float opweight = 50
;
int oplandmark = 0
;
int optabent = 0
;
int opentry = 1
;
int oppos = 1
;
int opplane = 1
;
int opphysplane = 1
;
int opobplane = 1
;
int opimode = 1
;
int oppseq = 1
;
int opgradmode = 0
;
int opanatomy = 0
;
int piimgoptlist = 0
;
int opcgate = 0
;
int opexor = 0
;
int opcmon = 0
;
int opfcomp = 0
;
int opgrx = 0
;
int opgrxroi = 0
;
int opnopwrap = 0
;
int opptsize = 2
;
int oppomp = 0
;
int opscic = 0
;
int oprect = 0
;
int opsquare = 0
;
int opvbw = 0
;
int opblim = 0
;
int opfast = 0
;
int opcs = 0
;
int opdeprep = 0
;
int opirprep = 0
;
int opsrprep = 0
;
int opmph = 0
;
int opdynaplan = 0
;
int opdynaplan_mask_phase = 0
;
int opbsp = 0
;
int oprealtime = 0
;
int opfluorotrigger = 0
;
int opET = 0
;
int opmultistation = 0
;
int opepi = 0
;
int opflair = 0
;
int opt1flair = 0
;
int opt2flair = 0
;
int opdoubleir = 0
;
int optissuet1 = 0
;
int opautotissuet1 = 0
;
int optlrdrf = 0
;
int opfulltrain = 0
;
int opirmode = 1
;
int opmt = 0
;
int opzip512 = 0
;
int opzip1024 = 0
;
int opslzip2 = 0
;
int opslzip4 = 0
;
int opsmartprep = 0
;
int opssrf = 0
;
int opt2prep = 0
;
int opspiral = 0
;
int opnav = 0
;
int opfmri = 0
;
int opectricks = 0
;
int optricksdel = 1000000
;
int optrickspause = 1
;
int opfr = 0
;
int opcube = 0
;
int ophydro = 0
;
int opphasecycle = 0
;
int oplava = 0
;
int op3dcine_fiesta = 0
;
int op3dcine_spgr = 0
;
int op4dflow = 0
;
int opbrava = 0
;
int opcosmic = 0
;
int opvibrant = 0
;
int opbravo = 0
;
int opdisco = 0
;
int opmprage = 0
;
int oppromo = 0
;
int opprop = 0
;
int opdwprop = 0
;
int opdwpropduo = 0
;
int opmuse = 0
;
int opallowedrescantime = 0
;
int opbreastmrs = 0
;
int opjrmode = 0
;
int opssfse = 0
;
int t1flair_flag = 0
;
int opphsen = 0
;
int opbc = 0
;
int opfatwater = 0
;
int oprtbc = 0
;
int opnseg = 1
;
int opnnex = 0
;
int opsilent = 0
;
int opsilentlevel = 1
;
int opmerge = 0
;
int opswan = 0
;
int opphaseimage = 0
;
int opdixon = 0
;
int opdixproc = 0
;
int opmedal = 0
;
int opquickstep = 0
;
int opidealiq = 0
;
int opsilentmr = 0
;
int opmagic = 0
;
float opzoom_fov_xy = 440.0
;
float opzoom_fov_z = 350.0
;
float opzoom_dist_ax = 120.0
;
float opzoom_dist_cor = 120.0
;
float opzoom_dist_sag = 150.0
;
int app_grad_type = 0
;
int opzoom_coil_ind = 0
;
int pizoom_index = 0
;
int opsat = 0
;
int opsatx = 0
;
int opsaty = 0
;
int opsatz = 0
;
float opsatxloc1 = 9999
;
float opsatxloc2 = 9999
;
float opsatyloc1 = 9999
;
float opsatyloc2 = 9999
;
float opsatzloc1 = 9999
;
float opsatzloc2 = 9999
;
float opsatxthick = 40.0
;
float opsatythick = 40.0
;
float opsatzthick = 40.0
;
int opsatmask = 0
;
int opfat = 0
;
int opwater = 0
;
int opccsat = 0
;
int opfatcl = 0
;
int opspecir = 0
;
int opexsatmask = 0
;
float opexsathick1 = 40.0
;
float opexsathick2 = 40.0
;
float opexsathick3 = 40.0
;
float opexsathick4 = 40.0
;
float opexsathick5 = 40.0
;
float opexsathick6 = 40.0
;
float opexsatloc1 = 9999
;
float opexsatloc2 = 9999
;
float opexsatloc3 = 9999
;
float opexsatloc4 = 9999
;
float opexsatloc5 = 9999
;
float opexsatloc6 = 9999
;
int opexsatparal = 0
;
int opexsatoff1 = 0
;
int opexsatoff2 = 0
;
int opexsatoff3 = 0
;
int opexsatoff4 = 0
;
int opexsatoff5 = 0
;
int opexsatoff6 = 0
;
int opexsatlen1 = 480
;
int opexsatlen2 = 480
;
int opexsatlen3 = 480
;
int opexsatlen4 = 480
;
int opexsatlen5 = 480
;
int opexsatlen6 = 480
;
float opdfsathick1 = 40.0
;
float opdfsathick2 = 40.0
;
float opdfsathick3 = 40.0
;
float opdfsathick4 = 40.0
;
float opdfsathick5 = 40.0
;
float opdfsathick6 = 40.0
;
float exsat1_normth_R = 0;
float exsat1_normth_A = 0;
float exsat1_normth_S = 0;
float exsat2_normth_R = 0;
float exsat2_normth_A = 0;
float exsat2_normth_S = 0;
float exsat3_normth_R = 0;
float exsat3_normth_A = 0;
float exsat3_normth_S = 0;
float exsat4_normth_R = 0;
float exsat4_normth_A = 0;
float exsat4_normth_S = 0;
float exsat5_normth_R = 0;
float exsat5_normth_A = 0;
float exsat5_normth_S = 0;
float exsat6_normth_R = 0;
float exsat6_normth_A = 0;
float exsat6_normth_S = 0;
float exsat1_dist = 0;
float exsat2_dist = 0;
float exsat3_dist = 0;
float exsat4_dist = 0;
float exsat5_dist = 0;
float exsat6_dist = 0;
int pigirscrn = 0;
int piautoirbands = 0;
float pigirdefthick = 200.0;
int pinumgir = 2
;
int opnumgir = 0
;
int pigirmode = 3
;
int opgirmode = 0
;
int optagging = 0
;
int optagspc = 7
;
float optagangle = 45.0
;
float opvenc = 50.0
;
int opflaxx = 0
;
int opflaxy = 0
;
int opflaxz = 0
;
int opflaxall = 0
;
int opproject = 0
;
int opcollapse = 1
;
int oprlflow = 0
;
int opapflow = 0
;
int opsiflow = 0
;
int opmagc = 1
;
int opflrecon = 0
;
int oprampdir = 0
;
int project = 0
;
int vas_ovrhd = 0
;
int slice_col = 1
;
int phase_col = 0
;
int read_col = 0
;
int mag_mask = 1
;
int phase_cor = 1
;
int extras = 0
;
int mag_create = 1
;
int rl_flow = 0
;
int ap_flow = 0
;
int si_flow = 0
;
int imagenum = 1
;
int motsa_ovrhd = 0
;
int opslinky = 0
;
int opinhance = 0
;
int opmavric = 0
;
int opinhsflow = 0
;
int opmsde = 0
;
float opvest = 50.0
;
int opmsdeaxx = 0
;
int opmsdeaxy = 0
;
int opmsdeaxz = 0
;
int opbreathhold= 0
;
int opautosubtract = 0
;
int opsepseries = 0
;
int pititle = 0 ;
float opuser0 = 0 ;
float opuser1 = 0 ;
float opuser2 = 0 ;
float opuser3 = 0 ;
float opuser4 = 0 ;
float opuser5 = 0 ;
float opuser6 = 0 ;
float opuser7 = 0 ;
float opuser8 = 0 ;
float opuser9 = 0 ;
float opuser10 = 0 ;
float opuser11 = 0 ;
float opuser12 = 0 ;
float opuser13 = 0 ;
float opuser14 = 0 ;
float opuser15 = 0 ;
float opuser16 = 0 ;
float opuser17 = 0 ;
float opuser18 = 0 ;
float opuser19 = 0 ;
float opuser20 = 0 ;
float opuser21 = 0 ;
float opuser22 = 0 ;
float opuser23 = 0 ;
float opuser24 = 0 ;
float opuser25 = 0 ;
float opuser26 = 0 ;
float opuser27 = 0 ;
float opuser28 = 0 ;
float opuser29 = 0 ;
float opuser30 = 0 ;
float opuser31 = 0 ;
float opuser32 = 0 ;
float opuser33 = 0 ;
float opuser34 = 0 ;
float opuser35 = 0 ;
float opuser36 = 0 ;
float opuser37 = 0 ;
float opuser38 = 0 ;
float opuser39 = 0 ;
float opuser40 = 0 ;
float opuser41 = 0 ;
float opuser42 = 0 ;
float opuser43 = 0 ;
float opuser44 = 0 ;
float opuser45 = 0 ;
float opuser46 = 0 ;
float opuser47 = 0 ;
float opuser48 = 0 ;
int opnostations = 1
;
int opstation = 1
;
int oploadprotocol = 0
;
int opmask = 0
;
int opvenous = 0
;
int opprotRxMode = 0
;
int opacqo = 1
;
int opfphases = 1
;
int opsldelay = 50000
;
int avminsldelay = 50000
;
int optphases = 1
;
int opdynaplan_nphases = 1
;
int opvsphases = 1
;
int opdiffuse = 0
;
int opsavedf = 0
;
int opmintedif = 1
;
int opseparatesynb = 1
;
int opdfaxx = 0;
int opdfaxy = 0;
int opdfaxz = 0;
int opdfaxall = 0;
int opdfaxtetra = 0;
int opdfax3in1 = 0;
int opbval = 0
;
int opnumbvals = 1
;
int opautonumbvals = 0
;
int opnumsynbvals = 0
;
float opdifnext2 = 1
;
int opautodifnext2 = 0
;
int optensor = 0
;
int opdifnumdirs = 1
;
int opdifnumt2 = 1
;
int opautodifnumt2 = 0
;
int opdualspinecho = 0
;
int opdifproctype = 0
;
int opdifnumbvalues = 1
;
int dti_plus_flag = 0
;
int optouch = 0
;
int optouchfreq = 60
;
int optouchmegfreq = 60
;
int optouchamp = 30
;
int optouchtphases = 4
;
int optouchcyc = 3
;
int optouchax = 4
;
int opaslprep = 0
;
int opasl = 0
;
float oppostlabeldelay = 1525.0
;
int rhchannel_combine_method = 0
;
int rhasl_perf_weighted_scale = 32
;
float cfslew_artmedium = 2.0
;
float cfgmax_artmedium = 3.3
;
float cfslew_arthigh = 2.0
;
float cfgmax_arthigh = 3.3
;
int cfnumartlevels = 0
;
int pinumartlevels = 0
;
float cfslew_artmediumopt = 5.0
;
float cfgmax_artmediumopt = 2.2
;
int oprep_active = 1
;
int oprep_rest = 1
;
int opdda = 0
;
int opinit_state = 0
;
int opfMRIPDTYPE = 0
;
int opview_order = 1
;
int opslice_order = 0
;
int oppsd_trig = 0
;
int oppdgm_str = -1
;
int opbwrt = 0
;
int cont_flag = 0
;
int opautonecho = 1
;
int opnecho = 1
;
int opnshots = 1
;
int opautote = 0
;
int opte = 25000
;
int opte2 = 50000
;
int optefw = 0
;
int opti = 50000
;
int opbspti = 50000
;
int opautoti = 0
;
int opautobti = 0
;
int optrecovery = 0
;
int optlabel = 2000000
;
int opt2prepte = 25000
;
int opautotr = 0
;
int opnspokes = 128
;
float opoversamplingfactor = 1.0
;
int opacs = 4
;
int opharmonize = 0
;
int pieffbladewidth = 1
;
int opinrangetr = 0
;
int opinrangetrmin = 160000
;
int opinrangetrmax = 10000000
;
int optr = 400000
;
float opflip = 90
;
int opautoflip = 0
;
int opautoetl = 0
;
int opetl = 8
;
int opautorbw = 0
;
float oprbw = 16.0
;
float oprbw2 = 16.0
;
float opfov = 500
;
float opphasefov = 1
;
float opnpwfactor = 1.0
;
float opfreqfov = 1
;
int opautoslquant = 0
;
int opslquant = 1
;
int opsllocs = 1
;
float opslthick = 5
;
float opslspace = 10
;
int opileave = 0
;
int opcoax = 1
;
float opvthick = 320
;
int opvquant = 1
;
int opovl = 0
;
float oplenrl = 0
;
float oplenap = 0
;
float oplensi = 0
;
float oplocrl = 0
;
float oplocap = 0
;
float oplocsi = 0
;
float oprlcsiis = 1
;
float opapcsiis = 2
;
float opsicsiis = 3
;
float opmonfov = 200
;
float opmonthick = 20
;
float opinittrigdelay = 1000000
;
int opxres = 256
;
int opyres = 128
;
int opautonex = 0
;
float opnex = 1
;
int opslicecnt = 0
;
int opnbh = 0
;
int opspf = 0
;
int opcfsel = 2
;
int opfcaxis = 0
;
int opphcor = 0
;
float opdose = 0
;
int opcontrast = 0
;
int opchrate = 100
;
int opcphases = 1
;
int opaphases = 1
;
int opclocs = 1
;
int ophrate = 60
;
int oparr = 10
;
int ophrep = 1
;
int opautotdel1 = 0
;
int optdel1 = 20000
;
int optseq = 1
;
int opphases = 1
;
int opcardseq = 0
;
int opmphases = 0
;
int oparrmon = 1
;
int opvps = 8
;
int opautovps = 0
;
int opcgatetype = CARDIAC_GATE_TYPE_NONE
;
int opadvgate = 0
;
int opfcine = 0
;
int opcineir = 0
;
int opstress = 0
;
int opnrr = 0
;
int opnrr_dda = 8
;
int oprtcgate = 0
;
int oprtrate = 12
;
int oprtrep = 1
;
int oprttdel1 = 20000
;
int oprttseq = 1
;
int oprtcardseq = 0
;
int oprtarr = 10
;
int oprtpoint= 10
;
int opnavrrmeas = 0
;
int opnavrrmeastime = 20
;
int opnavrrmeasrr = 12
;
int opnavsltrack = 0
;
int opnavautoaccwin = 0
;
float opnavaccwin = 2.0
;
int opnavautotrigtime = 10
;
int opnavpsctime = 10
;
int opnavmaxinterval = 200
;
int opnavtype = PSD_NAV_TYPE_90_180
;
int opnavpscpause = 0
;
int opnavsigenhance = 0
;
int opasset = 0
;
int opassetcal = 0
;
int opassetscan = 0
;
int rhcoilno = 0
;
int rhcal_options = 0
;
int rhasset = 0
;
int rhasset_calthresh = 10000
;
float rhasset_R = 0.5
;
int rhasset_phases = 1
;
float rhscancent = 0.0
;
int rhasset_alt_cal = 0
;
int rhasset_torso = 0
;
int rhasset_localTx = 0
;
float rhasset_TuningFactor = 15.0
;
float rhasset_SnrMin = 15.0
;
float rhasset_SnrMax = 75.0
;
float rhasset_SnrScalar = 1.0
;
int oppure = 0
;
int rhpure = 0
;
int oppurecal = 0
;
int rhpurechannel = 0
;
int rhpurefilter= 0
;
float rhpure_scale_factor = 1.0
;
int cfpure_filtering_mode = 1
;
int rhpure_filtering_mode = 1
;
float rhpure_lambda = 10.0
;
float rhpure_tuning_factor_surface = 0.0
;
float rhpure_tuning_factor_body = 1.0
;
float rhpure_derived_cal_fraction = 0.0
;
float rhpure_cal_reapodization = 12.0
;
int opcalrequired = 0
;
int rhpure_blur_enable = 0
;
float rhpure_blur = 0.0
;
float rhpure_mix_lambda = 10.0
;
float rhpure_mix_tuning_factor_surface = 0.0
;
float rhpure_mix_tuning_factor_body = 1.0
;
int rhpure_mix_blur_enable = 0
;
float rhpure_mix_blur = 0.0
;
float rhpure_mix_alpha = 0.0
;
int rhpure_mix_otsu_class_qty = 2
;
float rhpure_mix_exp_wt = 0.0
;
int rhpure_mix_erode_dist = 0
;
int rhpure_mix_dilate_dist = 0
;
int rhpure_mix_aniso_blur = 0
;
int rhpure_mix_aniso_erode_dist = 0
;
int rhpure_mix_aniso_dilate_dist = 0
;
int opcalmode = CAL_MODE_STANDARD
;
int rhcalmode = 0
;
int opcaldelay = 5000000
;
int rhcal_pass_set_vector = 12
;
int rhcal_nex_vector = 101
;
int rhcal_weight_vector = 101
;
int sifsetwokey = 0
;
int opautosldelay = 0
;
int specnuc = 1
;
int specpts = 256
;
int specwidth = 2000
;
int specnavs = 1
;
int specnex = 2
;
int specdwells = 1
;
int acquire_type = 0
;
int pixmtband = 1
;
int pibbandfilt = 0
;
int opwarmup = 0
;
int pscahead = 0
;
int opprescanopt = 0
;
int autoadvtoscn = 0
;
int opapa = 0
;
int oppscapa = 0
;
int PSslice_ind = 0
;
int oppscshimtg = 0
;
int opdyntg = 0
;
float dynTG_fov = 500
;
int dynTG_slquant = 1
;
float dynTG_flipangle = 60.0
;
float dynTG_slthick = 10.0
;
int dynTG_xres = 64
;
int dynTG_yres = 64
;
int dynTG_baseline = 0
;
int dynTG_ptsize = 4
;
float dynTG_b1factor = 1.0
;
float rfshim_fov = 500
;
int rfshim_slquant = 1
;
float rfshim_flipangle = 60.0
;
float rfshim_slthick = 10.0
;
int rfshim_xres = 64
;
int rfshim_yres = 64
;
int rfshim_baseline = 0
;
int rfshim_ptsize = 4
;
float rfshim_b1factor = 1.0
;
int cal_xres = 32
;
int cal_yres = 32
;
int cal_slq = 36
;
int cal_nex = 2
;
int cal_interleave = 0
;
float cal_fov = 500
;
float cal_slthick = 15
;
int cal_pass = 2
;
int coil_xres = 32
;
int coil_yres = 32
;
int coil_slq = 36
;
int coil_nex = 2
;
float coil_fov = 500
;
float coil_slthick = 15
;
int coil_pass = 1
;
int coil_interleave = 0
;
float asfov = 500
;
int asslquant = 1
;
float asflip = 20
;
float asslthick = 10
;
int asxres = 256
;
int asyres = 128
;
int asbaseline = 8
;
int asrhblank = 4
;
int asptsize = 4
;
int opascalcfov = 0
;
float tgfov = 500
;
int tgcap = 200
;
int tgwindow = 200
;
int oppscvquant = 0
;
int opdrivemode = 1
;
int pidrivemodenub = 7
;
int opexcitemode = 0
;
float lp_stretch = 2.0
;
int lp_mode = 0
;
float derateb1_body_factor = 1.0
;
float SAR_bodyNV_weight_lim = 110.0
;
float derateb1_NV_factor = 1.0
;
float jstd_multiplier_body = 0.145
;
float jstd_multiplier_NV = 0.0137
;
float jstd_exponent_body = 0.763
;
float jstd_exponent_NV = 1.154
;
int pidiffmode = 0;
int pifmriscrn = 0;
int piresol = 0
;
int pioverlap = 0
;
int piforkvrgf = 0;
int pinofreqoffset = 0;
int pirepactivenub = 0;
int pireprestnub = 0;
int piddanub = 0;
int piinitstatnub = 0;
int piviewordernub = 0;
int pisliceordnub = 0;
int pipsdtrignub = 0;
int pispssupnub = 1;
int pi_neg_sp = 0
;
float piisvaldef = 2.0
;
int pi2dmde = 0
;
int pidmode = 0
;
int piviews = 0
;
int piclckcnt = 1
;
float avmintscan = 0.0
;
float pitslice = 0.0
;
float pitscan = 0.0
;
float pimscan = 0.0
;
float pivsscan = 0.0
;
float pireconlag = -3.0
;
float pitres = 0.0
;
float pitres2 = 0.0
;
int pisaveinter = 0
;
int pivextras = 0
;
int pinecho = 0
;
float piscancenter = 0.0
;
float pilandmark = 0.0
;
float pitableposition = 0.0
;
int pismode = 0
;
int pishldctrl = 0
;
int pinolr = 1
;
int pinoadc = 0
;
int pimixtime = 0
;
int pishim2 = 0
;
int pi1stshimb = 0
;
float pifractecho = 1.0
;
int nope = 0
;
int opuser_usage_tag = 0x00000000
;
int rhuser_usage_tag = 0x00000000
;
int rhFillMapMSW = 0x00000000
;
int rhFillMapLSW = 0x00000000
;
int rhbline = 0
;
int rhblank = 4
;
int rhnex = 1
;
int rhnavs = 1
;
int rhnslices = 1
;
int rhnrefslices = 0
;
int rhnframes = 256
;
int rhfrsize = 256
;
int rhnecho = 1
;
int rhnphases = 1
;
int rhmphasetype = 0
;
int rhtrickstype = 0
;
int rhtype = 0
;
int rhtype1 = 0
;
int rhformat = 0
;
int rhptsize = 2
;
int rhnpomp = 1
;
int rhrcctrl = 1
;
int rhdacqctrl = 2
;
int rhexecctrl = (0x0001 | 0x0008)
;
int rhfdctrl = 0
;
float rhxoff = 0.0
;
float rhyoff = 0.0
;
int rhrecon = 0
;
int rhdatacq = 0
;
int rhvquant = 0
;
int rhslblank = 2
;
int rhhnover = 0
;
int rhfeextra = 0
;
int rhheover = 0
;
int rhoscans = 0
;
int rhddaover = 0
;
float rhzeroph = 128.5
;
float rhalpha = 0.46
;
float rhnwin = 0.0
;
float rhntran = 2.0
;
int rhherawflt = 0
;
float rhherawflt_befnwin = 1.0
;
float rhherawflt_befntran = 2.0
;
float rhherawflt_befamp = 1.0
;
float rhherawflt_hpfamp = 1.0
;
float rhfermw = 10.0
;
float rhfermr = 128.0
;
float rhferme = 1.0
;
float rhclipmin = 0.0
;
float rhclipmax = 16383.0
;
float rhdoffset = 0.0
;
int rhudasave = 0
;
int rhsspsave = 0
;
float rh2dscale = 1.0
;
float rh3dscale = 1.0
;
int rhnpasses = 1
;
int rhincrpass = 1
;
int rhinitpass = 1
;
int rhmethod = 0
;
int rhdaxres = 256
;
int rhdayres = 256
;
int rhrcxres = 256
;
int rhrcyres = 256
;
int rhimsize = 256
;
int rhnoncart_dual_traj = 0
;
int rhnoncart_traj_kmax_ratio = 8
;
int rhnspokes_lowres = 8192
;
int rhnspokes_highres = 8192
;
int rhnoncart_traj_merge_start = 3
;
int rhnoncart_traj_merge_end = 5
;
float rhoversamplingfactor = 1.0
;
float rhnoncart_grid_factor = 2.0
;
int rhnoncart_traj_mode = 0x00
;
int rhviewSharing3D = 0
;
int rhdaviewsPerBlade = 24
;
float rhrotationThreshold = 2.0
;
float rhshiftThreshold = 0.01
;
float rhcorrelationThreshold = 0.50
;
float rhphaseCorrFiltFreqRadius = 1.0
;
float rhphaseCorrFiltPhaseRadius = 1.0
;
float rhnpwfactor = 1.0
;
float rhuser0 = 0 ;
float rhuser1 = 0 ;
float rhuser2 = 0 ;
float rhuser3 = 0 ;
float rhuser4 = 0 ;
float rhuser5 = 0 ;
float rhuser6 = 0 ;
float rhuser7 = 0 ;
float rhuser8 = 0 ;
float rhuser9 = 0 ;
float rhuser10 = 0 ;
float rhuser11 = 0 ;
float rhuser12 = 0 ;
float rhuser13 = 0 ;
float rhuser14 = 0 ;
float rhuser15 = 0 ;
float rhuser16 = 0 ;
float rhuser17 = 0 ;
float rhuser18 = 0 ;
float rhuser19 = 0 ;
float rhuser20 = 0 ;
float rhuser21 = 0 ;
float rhuser22 = 0 ;
float rhuser23 = 0 ;
float rhuser24 = 0 ;
float rhuser25 = 0 ;
float rhuser26 = 0 ;
float rhuser27 = 0 ;
float rhuser28 = 0 ;
float rhuser29 = 0 ;
float rhuser30 = 0 ;
float rhuser31 = 0 ;
float rhuser32 = 0 ;
float rhuser33 = 0 ;
float rhuser34 = 0 ;
float rhuser35 = 0 ;
float rhuser36 = 0 ;
float rhuser37 = 0 ;
float rhuser38 = 0 ;
float rhuser39 = 0 ;
float rhuser40 = 0 ;
float rhuser41 = 0 ;
float rhuser42 = 0 ;
float rhuser43 = 0 ;
float rhuser44 = 0 ;
float rhuser45 = 0 ;
float rhuser46 = 0 ;
float rhuser47 = 0 ;
float rhuser48 = 0 ;
int rhdab0s = 0
;
int rhdab0e = 0
;
float rhctr = 1.0
;
float rhcrrtime = 1.0
;
int rhcphases = 1
;
int rhaphases = 1
;
int rhovl = 0
;
int rhvtype = 0
;
float rhvenc = 0.0
;
float rhvcoefxa = 0.0
;
float rhvcoefxb = 0.0
;
float rhvcoefxc = 0.0
;
float rhvcoefxd = 0.0
;
float rhvcoefya = 0.0
;
float rhvcoefyb = 0.0
;
float rhvcoefyc = 0.0
;
float rhvcoefyd = 0.0
;
float rhvcoefza = 0.0
;
float rhvcoefzb = 0.0
;
float rhvcoefzc = 0.0
;
float rhvcoefzd = 0.0
;
float rhvmcoef1 = 0.0
;
float rhvmcoef2 = 0.0
;
float rhvmcoef3 = 0.0
;
float rhvmcoef4 = 0.0
;
float rhphasescale = 1.0
;
float rhfreqscale = 1.0
;
int rawmode = 0
;
int rhileaves = 1
;
int rhkydir = 0
;
int rhalt = 0
;
int rhreps = 1
;
int rhref = 1
;
int rhpcthrespts = 2
;
int rhpcthrespct = 15
;
int rhpcdiscbeg = 0
;
int rhpcdiscmid = 0
;
int rhpcdiscend = 0
;
int rhpcileave = 0
;
int rhpcextcorr = 0
;
int rhrefframes = 0
;
int rhpcsnore = 0
;
int rhpcspacial = 0
;
int rhpctemporal = 0
;
float rhpcbestky = 64.0
;
int rhhdbestky = 0
;
int rhpcinvft = 0
;
int rhpcctrl = 0
;
int rhpctest = 0
;
int rhpcgraph = 0
;
int rhpclin = 0
;
int rhpclinnorm = 0
;
int rhpclinnpts = 0
;
int rhpclinorder = 2
;
int rhpclinfitwt = 0
;
int rhpclinavg = 0
;
int rhpccon = 0
;
int rhpcconnorm = 0
;
int rhpcconnpts = 2
;
int rhpcconorder = 2
;
int rhpcconfitwt = 0
;
int rhvrgfxres = 128
;
int rhvrgf = 0
;
int rhbp_corr = 0
;
float rhrecv_freq_s = 0.0
;
float rhrecv_freq_e = 0.0
;
int rhhniter = 0
;
int rhfast_rec = 0
;
int rhgridcontrol = 0
;
int rhb0map = 0
;
int rhtediff = 0
;
float rhradiusa = 0
;
float rhradiusb = 0
;
float rhmaxgrad = 0.0
;
float rhslewmax = 0.0
;
float rhscanfov = 0.0
;
float rhtsamp = 0.0
;
float rhdensityfactor = 0.0
;
float rhdispfov = 0.0
;
int rhmotioncomp = 0
;
int grid_fov_factor = 2
;
int rhte = 25000
;
int rhte2 = 50000
;
int rhdfm = 0
;
int rhdfmnavsperpass = 1
;
int rhdfmnavsperview = 1
;
float rhdfmrbw = 4.0
;
int rhdfmptsize = 2
;
int rhdfmxres = 32
;
int rhdfmdebug = 0
;
float rhdfmthreshold = 0.0
;
int rh_rc_enhance_enable = 0
;
int rh_ime_scic_enable = 0
;
float rh_ime_scic_edge = 0.0
;
float rh_ime_scic_smooth = 0.0
;
float rh_ime_scic_focus = 0.0
;
int rh_ime_clariview_type = 0
;
float rh_ime_clariview_edge = 0.0
;
float rh_ime_clariview_smooth = 0.0
;
float rh_ime_clariview_focus = 0.0
;
int rh_ime_definefilter_nr = 0
;
int rh_ime_definefilter_sh = 0
;
float rh_ime_scic_reduction = 0.0
;
float rh_ime_scic_gauss = 0.0
;
float rh_ime_scic_threshold = 0.0
;
float rh_ime_scic_contrast = 0.0
;
int cfscic_allowed = 1
;
float cfscic_edge = 0.0
;
float cfscic_smooth = 0.0
;
float cfscic_focus = 0.0
;
float cfscic_reduction = 0.0
;
float cfscic_gauss = 0.0
;
float cfscic_threshold = 0.0
;
float cfscic_contrast = 0.0
;
int piscic = 0
;
int cfscenic = 0
;
int piscenic = 0
;
int opscenic = 0
;
int rhscenic_type = 0
;
int cfn4_allowed = 1
;
float cfn4_slice_down_sample_rate = 1.0
;
float cfn4_inplane_down_sample_rate = 0.15
;
int cfn4_num_levels_max = 4
;
int cfn4_num_iterations_max = 50
;
float cfn4_convergence_threshold = 0.001
;
int cfn4_gain_clamp_mode = 0
;
float cfn4_gain_clamp_value = 5.0
;
float rhn4_slice_down_sample_rate = 1.0
;
float rhn4_inplane_down_sample_rate = 0.15
;
int rhn4_num_levels_max = 4
;
int rhn4_num_iterations_max = 50
;
float rhn4_convergence_threshold = 0.002
;
int rhn4_gain_clamp_mode = 0
;
float rhn4_gain_clamp_value = 5.0
;
int rhpure_gain_clamp_mode = 0
;
float rhpure_gain_clamp_value = 5.0
;
int rhphsen_pixel_offset = 0
;
int rhapp = 0
;
int rhapp_option = 0
;
int rhncoilsel = 0
;
int rhncoillimit = 45
;
int rhrefframep = 0
;
int rhscnframe = 0
;
int rhpasframe = 0
;
int rhpcfitorig = 1
;
int rhpcshotfirst = 0
;
int rhpcshotlast = 0
;
int rhpcmultegrp = 0
;
int rhpclinfix = 1
;
float rhpclinslope = 0.0
;
int rhpcconfix = 1
;
float rhpcconslope = 0.0
;
int rhpccoil = 1
;
float rhmaxcoef1a = 0
;
float rhmaxcoef1b = 0
;
float rhmaxcoef1c = 0
;
float rhmaxcoef1d = 0
;
float rhmaxcoef2a = 0
;
float rhmaxcoef2b = 0
;
float rhmaxcoef2c = 0
;
float rhmaxcoef2d = 0
;
float rhmaxcoef3a = 0
;
float rhmaxcoef3b = 0
;
float rhmaxcoef3c = 0
;
float rhmaxcoef3d = 0
;
int rhdptype = 0
;
int rhnumbvals = 1
;
int rhdifnext2 = 1
;
int rhnumdifdirs = 1
;
int rhutctrl = 0
;
float rhzipfact = 0
;
int rhfcinemode = 0
;
int rhfcinearw = 10
;
int rhvps = 8
;
int rhvvsaimgs = 1
;
int rhvvstr = 0
;
int rhvvsgender = 0
;
int rhgradmode = 0;
int rhfatwater = 0
;
int rhfiesta = 0
;
int rhlcfiesta = 0
;
float rhlcfiesta_phase = 0.0
;
int rhdwnavview = 0
;
int rhdwnavcorecho = 2
;
int rhdwnavsview = 1
;
int rhdwnaveview = 1
;
int rhdwnavsshot = 1
;
int rhdwnaveshot = 2
;
float rhdwnavcoeff = 0.5
;
int rhdwnavcor = 0
;
float rhassetsl_R = 1.0
;
float rhasset_slwrap = 0.0
;
int rh3dwintype = 0
;
float rh3dwina = 0.1
;
float rh3dwinq = 0.0
;
int rhectricks_num_regions = 0;
int rhectricks_input_regions = 0;
int rhretro_control = 0
;
int rhetl = 0
;
int rhleft_blank = 0
;
int rhright_blank = 0
;
float rhspecwidth = 0.0
;
int rhspeccsidims = 0
;
int rhspecrescsix = 0
;
int rhspecrescsiy = 0
;
int rhspecrescsiz = 0
;
float rhspecroilenx = 0.0
;
float rhspecroileny = 0.0
;
float rhspecroilenz = 0.0
;
float rhspecroilocx = 0.0
;
float rhspecroilocy = 0.0
;
float rhspecroilocz = 0.0
;
int rhexciterusage = 1
;
int rhexciterfreqs = 1
;
int rhwiener = 0
;
float rhwienera = 0.0
;
float rhwienerb = 0.0
;
float rhwienert2 = 0.0
;
float rhwieneresp = 0.0
;
int rhflipfilter = 0
;
int rhdbgrecon = 0
;
int rhech2skip = 0
;
int rhrcideal = 0
;
int rhrcdixproc = 0
;
int rhrcidealctrl = 0
;
int rhdf = 210
;
int rhmedal_mode = 0
;
int rhmedal_nstack_size = 54
;
int rhmedal_echo_order = 0
;
int rhmedal_up_kernel_size = 15
;
int rhmedal_down_kernel_size = 8
;
int rhmedal_smooth_kernel_size = 8
;
int rhmedal_starting_slice = 0
;
int rhmedal_ending_slice = 10
;
float rhmedal_param = 3.0
;
int rhvibrant = 0
;
int rhkacq_uid = 0
;
int rhnex_unacquired = 1
;
int rhdiskacqctrl = 0
;
int rhechopc_extra_bot = 0
;
int rhechopc_ylines = 0
;
int rhechopc_primary_yfirst = 0
;
int rhechopc_reverse_yfirst = 0
;
int rhechopc_zlines = 0
;
int rhechopc_yxfitorder = 1
;
int rhechopc_ctrl = 0
;
int rhchannel_combine_filter_type = 0
;
float rhchannel_combine_filter_width = 0.3
;
float rhchannel_combine_filter_beta = 2
;
float rh_low_pass_nex_filter_width = 8.0
;
int rh3dgw_interptype = 0
;
int rhrc3dcinectrl = 0
;
int rhncycles_cine = 0
;
int rhnvircchannel = 0
;
int rhrc_cardt1map_ctrl = 0
;
int rhrc_moco_ctrl = 0
;
int rhrc_algorithm_ctrl = 0
;
int ihtr = 100
;
int ihti = 0
;
int ihtdel1 = 10
;
float ihnex = 1
;
float ihflip = 90
;
int ihte1 = 0
;
int ihte2 = 0
;
int ihte3 = 0
;
int ihte4 = 0
;
int ihte5 = 0
;
int ihte6 = 0
;
int ihte7 = 0
;
int ihte8 = 0
;
int ihte9 = 0
;
int ihte10 = 0
;
int ihte11 = 0
;
int ihte12 = 0
;
int ihte13 = 0
;
int ihte14 = 0
;
int ihte15 = 0
;
int ihte16 = 0
;
int ihdixonte = 0
;
int ihdixonipte = 0
;
int ihdixonoopte = 0
;
float ihvbw1 = 16.0
;
float ihvbw2 = 16.0
;
float ihvbw3 = 16.0
;
float ihvbw4 = 16.0
;
float ihvbw5 = 16.0
;
float ihvbw6 = 16.0
;
float ihvbw7 = 16.0
;
float ihvbw8 = 16.0
;
float ihvbw9 = 16.0
;
float ihvbw10 = 16.0
;
float ihvbw11 = 16.0
;
float ihvbw12 = 16.0
;
float ihvbw13 = 16.0
;
float ihvbw14 = 16.0
;
float ihvbw15 = 16.0
;
float ihvbw16 = 16.0
;
int ihnegscanspacing = 0
;
int ihoffsetfreq = 1200
;
int ihbsoffsetfreq = 4000
;
int iheesp = 0
;
int ihfcineim = 0
;
int ihfcinent = 0
;
int ihbspti = 50000
;
float ihtagfa = 180.0
;
float ihtagor = 45.0
;
float ih_idealdbg_cv1 = 0 ;
float ih_idealdbg_cv2 = 0 ;
float ih_idealdbg_cv3 = 0 ;
float ih_idealdbg_cv4 = 0 ;
float ih_idealdbg_cv5 = 0 ;
float ih_idealdbg_cv6 = 0 ;
float ih_idealdbg_cv7 = 0 ;
float ih_idealdbg_cv8 = 0 ;
float ih_idealdbg_cv9 = 0 ;
float ih_idealdbg_cv10 = 0 ;
float ih_idealdbg_cv11 = 0 ;
float ih_idealdbg_cv12 = 0 ;
float ih_idealdbg_cv13 = 0 ;
float ih_idealdbg_cv14 = 0 ;
float ih_idealdbg_cv15 = 0 ;
float ih_idealdbg_cv16 = 0 ;
float ih_idealdbg_cv17 = 0 ;
float ih_idealdbg_cv18 = 0 ;
float ih_idealdbg_cv19 = 0 ;
float ih_idealdbg_cv20 = 0 ;
float ih_idealdbg_cv21 = 0 ;
float ih_idealdbg_cv22 = 0 ;
float ih_idealdbg_cv23 = 0 ;
float ih_idealdbg_cv24 = 0 ;
float ih_idealdbg_cv25 = 0 ;
float ih_idealdbg_cv26 = 0 ;
float ih_idealdbg_cv27 = 0 ;
float ih_idealdbg_cv28 = 0 ;
float ih_idealdbg_cv29 = 0 ;
float ih_idealdbg_cv30 = 0 ;
float ih_idealdbg_cv31 = 0 ;
float ih_idealdbg_cv32 = 0 ;
int ihlabeltime = 0
;
int ihpostlabeldelay = 0
;
int ihnew_series = 0
;
int ihcardt1map_hb_pattern = 0
;
int dbdt_option_key_status = 0
;
int dbdt_mode = 0
;
int opsarmode = 0
;
int cfdbdttype = 0
;
float cfrinf = 23.4
;
int cfrfact = 334
;
float cfdbdtper_norm = 80.0
;
float cfdbdtper_cont = 100.0
;
float cfdbdtper_max = 200.0
;
int cfnumicn = 1
;
int cfdppericn = 4
;
int cfgradcoil = 2;
int cfswgut = 4;
int cfswrfut = 2;
int cfswssput = 1;
int cfhwgut = 4;
int cfhwrfut = 2;
int cfhwssput = 1;
int cfoption = -1
;
int cfrfboardtype = 0
;
int psd_board_type = PSDDVMR
;
int opdfm = 0
;
int opdfmprescan = 0
;
int cfdfm = 0
;
int cfdfmTG = 70
;
int cfdfmR1 = 13
;
int cfdfmDX = 0
;
int derate_ACGD = 0
;
int rhextra_frames_top = 0
;
int rhextra_frames_bot = 0
;
int rhpc_ref_start = 0
;
int rhpc_ref_stop = 0
;
int rhpc_ref_skip = 0
;
int opaxial_slice=0
;
int opsagittal_slice =0
;
int opcoronal_slice=0
;
int opvrg = 0
;
int opmart = 0
;
int piassetscrn = 0
;
int opseriessave = 0
;
int opt1map = 0
;
int opt2map = 0
;
int opmer2 = 0
;
int rhnew_wnd_level_flag = 1
;
int rhwnd_image_hist_area = 60
;
float rhwnd_high_hist = 1.0
;
float rhwnd_lower_hist = 1.0
;
int rhrcmavric_control = 0
;
int rhrcmavric_image = 0
;
int rhrcmavric_bin_separation = 1000
;
int cfrfupa = -50
;
int cfrfupd = 50
;
int cfrfminblank = 200
;
int cfrfminunblk = 200
;
int cfrfminblanktorcv = 50
;
float cfrfampftconst = 0.784
;
float cfrfampftlinear = 0.0
;
float cfrfampftquadratic = 15.125
;
int opradialrx = 0
;
int cfsupportreceivefreqbands = 0
;
float cfcntfreefreqlow = 0.0
;
float cfcntfreefreqhigh = 10000.0
;
int optracq = 0
;
int opswift = 0
;
int rhswiftenable = 0
;
int rhnumCoilConfigs = 0
;
int rhnumslabs = 1
;
int opncoils = 1
;
int rtsar_first_series_flag = 0
;
int rtsar_enable_flag = 0
;
int measured_TG = -1
;
int predicted_TG = -1
;
float sar_correction_factor = 1.0
;
int gradHeatMethod = 0
;
int gradHeatFile = 0
;
int gradCoilMethod = GRADIENT_COIL_METHOD_AUTO
;
int gradHeatFlag = 0
;
int xgd_optimization = 1
;
int gradChokeFlag = 0
;
int piburstmode = 0
;
int opburstmode = 0
;
int burstreps = 1






;

float piburstcooltime = 0.0






;


float opaccel_ph_stride = 1.0






;

float opaccel_sl_stride = 1.0






;

float opaccel_t_stride = 1.0






;

int opaccel_mb_stride = 2






;


int opmb = 0






;


int rhmb_factor = 1






;



int rhmb_slice_fov_shift_factor = 1






;


int rhmb_slice_order_sign = 1






;


int rhmuse = 0






;


int rhmuse_nav = 0






;


int rhmuse_nav_accel = 1






;


int rhmuse_nav_hnover = 16






;


int rhmuse_nav_yres = 96






;

float opaccel_cs_stride = 1.0






;


int opcompressedsensing = 0






;


float rhcs_factor = 1.0






;


int rhcs_flag = 0






;


int rhcs_maxiter = 3






;


float rhcs_consistency = 0






;


int rhcs_ph_stride = 1






;


int rhcs_sl_stride = 1






;

int oparc = 0






;

int opaccel_kt_stride = 8






;

int rhkt_factor = 1






;


int rhkt_cal_factor = 1






;


int rhkt_calwidth_ph = 0






;


int rhkt_calwidth_sl = 0






;





int opab1 = 0






;

int op3dgradwarp = 0






;

int opauto3dgradwarp = 1






;

int cfmaxtransmitoffsetfreq = 650000






;


int cfreceiveroffsetfreq = 0






;


int cfcoilswitchmethod = 0x0004






;

int TG_record = 0





;





int ab1_enable = 0





;

int cfreceivertype = CFG_VAL_RECEIVER_RRX






;

int cfreceiverswitchtype = CFG_VAL_RCV_SWITCH_RF_HUB






;

int cfEllipticDriveEnable = 0






;

int pi3dgradwarpnub = 1






;

int cfDualDriveCapable = 0






;


int optrip = 0






;


int oprtb0 = 0






;

int pirtb0vis = 0






;

int pirtb0nub = 0






;



int ophoecc = 0






;


int rhhoecc = 0






;


int rhhoec_fit_order = 3






;


int opdistcorr = 0






;



int pidistcorrnub = 0






;



int pidistcorrdefval = 0






;


int rhdistcorr_ctrl = 0






;


int rhdistcorr_B0_filter_size = 5






;


float rhdistcorr_B0_filter_std_dev = 1.5






;



int ihdistcorr = 0






;


int rhtensor_file_number = 0






;


int ihpepolar = 0






;


int rhesp = 500






;


int viewshd_num = 0






;


float grad_intensity_thres = 3.0






;

int anne_mask_dilation_length = 2






;

float anne_intensity_thres = 0.0






;

float anne_channel_percentage = 0.4






;

int ec3_iterations = 1






;

float combined_coil_map_thres = 0.15






;

float coil_map_smooth_factor = 0.02






;

float coil_map_2_filter_width = 0.02






;

int ec3_iteration_method = 0






;


int edr_support = 0






;

float recon_bandwidth_factor = 1.0






;



int dacq_data_type = 0






;

int rawmode_scaling = 0






;

float rawmode_scaling_factor = 1.0






;


int oprgcalmode = RG_CAL_MODE_MEASURED






;


int opnumgroups = 0






;


int opsarburst = 0






;

int opheadscout = 0






;

int rhposition_detection = 0






;


int opfus = 0






;

int opexamnum = 0






;

int opseriesnum = 0






;



int vol_shift_type = 0






;

int vol_shift_constraint_type = 0






;


int vol_scale_type = 0






;

int vol_scale_constraint_type = 0






;


int rhsnrnoise = 0






;

int rhvircpolicy = 0






;

int rhvirsenstype = 1






;

int rhvircoiltype = 1






;

int rhvircoilunif = 0






;

int rhvircoilchannels = 1






;

int cffield = 15000






;

float act_field_strength = 30000.0






;

int enableReceiveFreqBands = 0






;

int offsetReceiveFreqLower = 0






;

int offsetReceiveFreqHigher = 0






;

int cfrfamptyp = 0






;

int cfssctype = 0






;

int cfbodycoiltype = PSD_15_XRM_BODY_COIL






;

int cfptxcapable = 0






;


int cfbdcabletglimit = 1






;


int cfcablefreq = 226






;


int cfcabletg = 175






;


int cfcablebw = 500






;

int opgradshim = 2






;

int track_flag = 0






;



int prevent_scan_under_emul = 0






;


int acqs = 1






;

int avround = 1






;

int baseline = 0






;


int nex = 1






;

float trunex = 1.0






;

int isOddNexGreaterThanOne = 0






;

int isNonIntNexGreaterThanOne = 0






;






float fn = 1.0






;

int enablfracdec = 1






;

int npw_flag = 0






;

float nop = 1.0






;

int acq_type = 0






;

int seq_type = TYPNCAT






;

int num_images = 1






;


int recon_mag_image = 1






;

int recon_pha_image = 0






;

int recon_imag_image = 0






;

int recon_qmag_image = 0






;


int slquant1 = 1






;

int psd_grd_wait = 56






;

int psd_rf_wait = 0






;




int pos_moment_start = 0






;






int mps1rf1_inst = 0






;

int scanrf1_inst = 0






;


int cfcarddelay = 10






;


int psd_card_hdwr_delay = 0






;


float GAM = 4257.59






;

int off90 = 80






;

int TR_SLOP = 2000






;

int TR_PASS = 50000






;

int TR_PASS3D = 550000






;

int csweight= 100






;



int exnex = 1






;

float truenex = 0.0






;

int eg_phaseres = 128






;

int sp_satcard_loc = 0






;

int min_rfdycc = 0;

int min_rfavgpow = 0;

int min_rfrmsb1 = 0;

int coll_prefls = 1






;


int maxGradRes = 1






;

float dfg = 2






;

float pg_beta = 1.0






;

int split_dab = 0






;

float freq_scale = 1.0






;

int numrecv = 1






;


int pe_on = 1






;

float psd_targetscale = 1.0;

float psd_zero = 0.0






;


int lx_pwmtime = 0;
int ly_pwmtime = 0;
int lz_pwmtime = 0;


int px_pwmtime = 0;
int py_pwmtime = 0;
int pz_pwmtime = 0;

int min_seqgrad = 0;
int min_seqrfamp = 0;


float xa2s = 0;
float ya2s = 0;
float za2s = 0;

int minseqcoil_t = 0;
int minseqcoilx_t = 0;
int minseqcoily_t = 0;
int minseqcoilz_t = 0;
int minseqcoilburst_t = 0;
int minseqcoilvrms_t = 0;
int minseqgram_t = 0;
int minseqchoke_t = 0;
int minseqcable_t = 0;
int minseqcable_maxpow_t = 0;
int minseqcableburst_t = 0;
int minseqbusbar_t = 0;
int minseqps_t = 0;
int minseqpdu_t = 0;
int minseqpdubreaker_t = 0;
int minseqcoilcool_t = 0;
int minseqsyscool_t = 0;
int minseqccucool_t = 0;
int minseqxfmr_t = 0;
int minseqresist_t = 0;


int minseqgrddrv_t = 0;
int minseqgrddrv_case_t = 0;
int minseqgrddrvx_t = 0;
int minseqgrddrvy_t = 0;
int minseqgrddrvz_t = 0;
float powerx = 0;
float powery = 0;
float powerz = 0;
float pospowerx = 0;
float pospowery = 0;
float pospowerz = 0;
float negpowerx = 0;
float negpowery = 0;
float negpowerz = 0;
float amptrans_lx = 0;
float amptrans_ly = 0;
float amptrans_lz = 0;
float amptrans_px = 0;
float amptrans_py = 0;
float amptrans_pz = 0;
float abspower_lx = 0;
float abspower_ly = 0;
float abspower_lz = 0;
float abspower_px = 0;
float abspower_py = 0;
float abspower_pz = 0;


int minseqpwm_x = 0;
int minseqpwm_y = 0;
int minseqpwm_z = 0;
int minseqgpm_t = 0;
int minseqgpm_maxpow_t = 0;


float vol_ratio_est_req = 2.0;


int skip_waveform_rotmat_check = 0;


int set_realtime_rotmat = 0;


int skip_rotmat_search = 0;


int enforce_minseqseg = 0;


int enforce_dbdtopt = 0;


int skip_minseqseg = 0;


int skip_initialize_dbdtopt = 0;

int time_pgen = 0;

int cont_debug = 0






;


int maxpc_cor = 0






;

int maxpc_debug = 0






;

int maxpc_points = 500






;


int pass_thru_mode = 0






;


int tmin = 0






;

int tmin_total = 0






;

int psd_tol_value = 0






;


int bd_index = 1






;


int use_ermes = 0






;


float fieldstrength = 15000;

int asymmatrix = 0






;

int psddebugcode = 0






;

int psddebugcode2 = 0






;

int serviceMode = 0






;


int upmxdisable = 16






;






int tsamp = 4






;

int seg_debug = 0






;

int CompositeRMS_method = 0






;

int gradDriverMethod = 0






;



int gradDCsafeMethod = 1






;


int stopwatchFlag = 0






;

int seqEntryIndex = 0






;


int dbdt_debug = 0






;

int reilly_mode = 0






;



int dbdt_disable = 0






;




int use_dbdt_opt = 1






;

float srderate = 1.0






;

int config_update_mode = 0






;

int phys_record_flag = 0






;

int phys_rec_resolution = 25






;
int phys_record_channelsel = 15
;
int rotateflag = 0
;
int rhpcspacial_dynamic = 0
;
int rhpc_rationalscale = 0
;
int rhpcmag = 0
;
int mild_note_support = 0
;
int save_grad_spec_flag = 0
;
int grad_spec_change_flag = 0
;
int value_system_flag = 0
;
int rectfov_npw_support = 0
;
int pigeosrot = 0
;
int minseqrf_cal = 1
;
int min_rfampcpblty = 0
;
int b1derate_flag = 0
;
int oblmethod_dbdt_flag = 0
;
int minseqcoil_esp = 1000
;
int aspir_flag = 0
;
int rhrawsizeview = 0
;
int chksum_scaninfo_view = 0
;
int chksum_rhdacqctrl_view = 0
;
float fnecho_lim = 1.0
;
int psdcrucial_debug = 0
;
float b1max_scale = 1.0
;
int disable_exciter_unblank = 0
;
int TGlimit = 200;
int sat_TGlimit = 200;
int autoparams_debug = 0
;
int num_autotr_cveval_iter = 1
;
int apx_cveval_counter = 0
;
int enforce_inrangetr = 0
;
int passtime = 0
;
int retropc_extra = 0
;
int esp = 10000
;
int echoint = 1
;
int arc_flag = 0
;
int arc_ph_calwidth = 24
;
int arc_sl_calwidth = 24
;
int vrgfsamp = 0
;
float srate_x = 15.0
;
float glimit_x = 3.6
;
float srate_y = 15.0
;
float glimit_y = 3.6
;
float srate_z = 15.0
;
float glimit_z = 3.6
;
float act_srate_x = 10.0
;
float act_srate_y = 10.0
;
float act_srate_z = 10.0
;
int mkgspec_x_sr_flag = 0
;
int mkgspec_x_gmax_flag = 0
;
int mkgspec_y_sr_flag = 0
;
int mkgspec_y_gmax_flag = 0
;
int mkgspec_z_sr_flag = 0
;
int mkgspec_z_gmax_flag = 0
;
int mkgspec_flag = 0
;
int mkgspec_epi2_flag = 0
;
int pfkz_total = 32
;
float fov_freq_scale = 1.0
;
float fov_phase_scale = 1.0
;
float slthick_scale = 1.0
;
int silent_mode = 0
;
float silent_slew_rate = 3.0
;
int rhpropellerCtrl = 0
;
float prop_act_npwfactor = 1.0
;
float prop_act_oversamplingfactor = 1.0
;
int navtrig_wait_before_imaging = 200000
;
int xtg_volRecCoil = 0
;
int minseqseg_max_full = 0
;
int sphericalGradient = 0
;
int minseqcoil_option = 0
;
int minseqgrad_option = 0
;
int rtp_bodyCoilCombine = 1
;
int ntxchannels = 1
;
int napptxchannels = 1
;
int seqcfgdebug = 0
;
int enable_acoustic_model = 0
;
int acoustic_seq_repeat_time = 4
;
float avgSPL_non_weighted = -1
;
int noisecal_in_scan_flag = 1
;
int cs_sat = 0;
int cs_satstart = 0, cs_sattime = 0;
float a_rfcssatcfh = 0, flip_rfcssatcfh = 0;
int pw_rfcssatcfh = 0, ia_rfcssatcfh = 0;
int ChemSatPulse=1;
float area_gxkcs = 0;
float area_gykcs = 0;
float area_gyakcs = 0;
float area_gzkcs = 0;
int csk_derate_factor = 1 ;
int pw_rfcssat = 0, pw_omega_hs_rfcssat = 0;
int off_rfcssat = 0;
int ia_rfcssat = 0, ia_omega_hs_rfcssat = 0;
float cyc_rfcssat = 0;
float a_rfcssat = 0, a_omega_hs_rfcssat = 0;
float alpha_rfcssat = 0;
float gscale_rfcssat = 0;
float flip_rfcssat = 0;
float a_gzrfcssat = 0;
int ia_gzrfcssat = 0;
int pw_gzrfcssat = 0;
int res_gzrfcssat = 0;
float a_gzrfcssat_wrf = 0;
float a_thetarfcssat = 0;
int ia_thetarfcssat = 0;
int pw_thetarfcssat = 0;
int res_thetarfcssat = 0;
int off_thetarfcssat = 0;
int bw_rfcssat = 0;
int selectiveChemsat = 0 ;
float selectiveChemsatBWscaler = 1.0 ;
int offset_rfchemsat = 0;
int num_gzrfcssat_lobe = 0;
int pw_gzrfcssat_lobe = 0;
int pw_gzrfcssat_constant = 0;
int pw_gzrfcssat_rampz = 0;
int num_gzrfcssat_lobe_norf = 0;
int pw_gzrfcssat_lobe_norf = 0;
int pw_gzrfcssat_constant_norf = 0;
int pw_gzrfcssat_rampz_norf = 0;
int ext_pw_rfcssat = 0;
int ext_res_rfcssat = 0;
int ext_isodelay = 0;
int ext_water_freq_flag = 0;
int ext_pw_grad_sub_lobe = 0;
int ext_pw_grad_sub_lobe_ramp = 0;
int ext_num_grad_sub_lobe = 0;
int ext_pw_grad_sub_lobe_norf = 0;
int ext_pw_grad_sub_lobe_ramp_norf = 0;
int ext_num_grad_sub_lobe_norf = 0;
float ext_abswidth = 0;
float ext_effwidth = 0;
float ext_area = 0;
float ext_dtycyc = 0;
float ext_maxpw = 0;
float ext_max_b1 = 0;
float ext_max_int_b1_sq = 0;
float ext_max_rms_b1 = 0;
float ext_nom_fa = 0;
float ext_nom_pw = 0;
float ext_nom_bw = 0;
float ext_gzrfcssat_scale_fac = 0;
float ext_fatsat_min_slthick = 0;
int duo_cs_flag = 0;
int w_debug_flag = 0;
int n_cspulses = 0;
int flip_final_1 = 0;
int flip_final_2 = 0;
float killer_scale = 1.0;
int delay_time_bkp = -1;
int tetime_bkp = -1;
int rc_time_bkp = -1;
int slquant_bkp = -1;
int tr_time_bkp = -1;
int sattime_bkp = -1;
int flip_final_1_bkp = -1;
int flip_final_2_bkp = -1;
float fatsat_factor_bkp = -1;
int phantom_test_flag = 0 ;
float phantom_fat_T1 = 300.0 ;
int DB_flag = 0 ;
float DB_shift_ratio = 0 ;
float DB_ChemShift = 0.75 ;
int DBgrad_flag = 0 ;
float DB_Buffer_X = 0.0;
float DB_Buffer_Y = 0.0;
float DB_Chemical_Shift = 0;
float dbcenterlocx1 = 0,
      dbcenterlocx2 = 0,
      dbcenterlocy1 = 0,
      dbcenterlocy2 = 0,
      dbcenterlocz1 = 0,
      dbcenterlocz2 = 0;
float dbsatthickx = 0,
      dbsatthicky = 0,
      dbsatthickz = 0;
float dbbandlocx1 = 0,
      dbbandlocx2 = 0,
      dbbandlocy1 = 0,
      dbbandlocy2 = 0,
      dbbandlocz1 = 0,
      dbbandlocz2 = 0;
float off_rfcssat1 = 0,
      off_rfcssat2 = 0;
float bw_rfcssat_nom = 0;
float bw_rfcssat_ramp = 0;
float bw_ramp = 0;
float fatsat_factor = 1.0 ;
 int csat_rfupa = -600 ;
 int csat_sys_type = 0 ;
int aspir_delay = 0;
int aspir_cfoffset = 0;
int aspir_minti = 0;
float aspir_T1 = 0;
float aspir_TI = 0;
float aspir_TI_null = 0;
float aspir_TI_extra = 0;
float aspir_TI_min = 0;
float aspir_eff = 0;
int fatFlag = 0;
int cs_isodelay = 0;
int cs_delay = 0;
int recovery_time = 0;
float flip_sat = 0;
float flip_satcfh = 0;
int fStrength = 0;
int use_spsp_fatsat = 0 ;
int debug_spsp_fatsat = 0;
float spsp_fatsat_slthick = 30.0 ;
int spsp_fatsat_pulse_extra_time = 0 ;
int spsp_fatsat_spatial_mode = 0 ;
float spsp_fatsat_spatial_offset = 0.0 ;
int spsp_fatsat_pulse_override = 0 ;
float spsp_fatsat_omega_scale= 256.0 ;
float max_aspir_fa = 0;
int fa_scale_debug = 0;
int cs_tr = 0 ;
int cs_slquant =0 ;
int cs_dda_per_trig_flag = 0 ;
int psd_chemsat_seq_flag = 0 ;
int cs_dda_flip = 90 ;
float ccs_dead = 3000000 ;
int ccs_relaxers = 0;
int ccs_relaxtime = 0;
int ccs_relaxseqtime = 0;
int SatRelaxers = 0;
float gsat_scale = 0;
float cyc_rfs = 0;
int pw_rfs = 0;
int pw_satrampx = 0, pw_satrampy = 0, pw_satrampz = 0;
int sat_rot_ex_num = 0;
int sat_rot_df_num = 0;
int sat_rot_index = 0;
int pw_isisat= 200 ;
int pw_rotupdate = 12 ;
int isi_satdelay = 100 ;
int rot_delay = 12 ;
int isi_extra = 32 ;
int sat_debug = 0;
int spsat_host_debug = 0 ;
int sp_first_scan = 0;
int sat_obl_debug = 0;
int sat_newgeo = 1;
 int spsat_rfupa = -600 ;
 int spsat_sys_type = 0 ;
int xkiller_set = 0;
int maxkiller_time = 0;
float satgapxpos= 0
;
float satgapxneg= 0
;
float satgapypos= 0
;
float satgapyneg= 0
;
float satgapzpos= 0
;
float satgapzneg= 0
;
float satspacex1 = 0,
        satspacex2 = 0,
        satspacey1 = 0,
        satspacey2 = 0,
        satspacez1 = 0,
        satspacez2 = 0,
        satspace1 = 0,
        satspace2 = 0,
        satspace3 = 0,
        satspace4 = 0,
        satspace5 = 0,
        satspace6 = 0;
float satthickx1 = 0,
        satthickx2 = 0,
        satthickdfx = 0,
        satthicky1 = 0,
        satthicky2 = 0,
        satthickdfy = 0,
        satthickz1 = 0,
        satthickz2 = 0,
        satthickdfz = 0,
        exsatthick1 = 0,
        exsatthick2 = 0,
        exsatthick3 = 0,
        exsatthick4 = 0,
        exsatthick5 = 0,
        exsatthick6 = 0;
float satxlocpos = 0,
        satxlocneg = 0,
        satylocpos = 0,
        satylocneg = 0,
        satzlocpos = 0,
        satzlocneg = 0,
        satzloca = 0,
        satzlocb = 0,
        satloce1 = 0,
        satloce2 = 0,
        satloce3 = 0,
        satloce4 = 0,
        satloce5 = 0,
        satloce6 = 0;
float area_rfsx1 = 0 ;
float area_rfsx2 = 0 ;
float area_rfsy1 = 0 ;
float area_rfsy2 = 0 ;
float area_rfsz1 = 0 ;
float area_rfsz2 = 0 ;
float area_rfse1 = 0 ;
float area_rfse2 = 0 ;
float area_rfse3 = 0 ;
float area_rfse4 = 0 ;
float area_rfse5 = 0 ;
float area_rfse6 = 0 ;
float area_gyksx1 = 0,area_gyksx2 = 0,area_gyksy1 = 0,area_gyksy2 = 0,area_gyksz1 = 0,
          area_gyksz2 = 0,area_gykse1 = 0,area_gykse2 = 0,area_gykse3 = 0,area_gykse4 = 0,
          area_gykse5 = 0,area_gykse6 = 0;
float area_gxksx1 = 0,area_gxksx2 = 0,area_gxksy1 = 0,area_gxksy2 = 0,area_gxksz1 = 0,
          area_gxksz2 = 0,area_gxkse1 = 0,area_gxkse2 = 0,area_gxkse3 = 0,area_gxkse4 = 0,
          area_gxkse5 = 0,area_gxkse6 = 0;
int sp_sattime = 0 ;
int sp_satstart = 0 ;
int vrgsat = 2 ;
int numsatramp = 0 ;
int had_sat = 0 ;
float rtia3d_sat_flip = 70
;
float rtia3d_sat_pos = 100.0
;
int sat_pulse_type = 0 ;
int satgap_opt_flag = 0 ;
int autolock = 0
;
int blank = 4
;
int nograd = 0
;
int nofermi = 0
;
int rawdata = 0
;
int saveinter = 0
;
int zchop = 1
;
int eepf = 0
;
int oepf = 0
;
int eeff = 0
;
int oeff = 0
;
int cine_choplet = 0
;
float fermi_rc = 0.5
;
float fermi_wc = 1.0
;
int apodize_level_flag = 0
;
float fermi_r_factor = 1.0
;
float fermi_w_factor = 1.0
;
float pure_mix_tx_scale = 1.0
;
int channel_compression = 0
;
int optimal_channel_combine = 0
;
int enforce_cal_for_channel_combine = 0
;
int override_opcalrequired = 0
;
int dump_channel_comp_optimal_recon = 0
;
int dump_scenic_parameters = 0
;
float PSsr_derate_factor = 1.0 ;
float PSamp_derate_factor = 1.0 ;
float PSassr_derate_factor = 1.0 ;
float PSasamp_derate_factor = 1.0 ;
int PSTR_PASS = 20000;
float mpsfov = 100 ;
int fastprescan = 0 ;
int pre_slice = 0 ;
int PSslice_num = 0;
float xmtaddAPS1 = 0, xmtaddCFL = 0, xmtaddCFH = 0, xmtaddFTG = 0, xmtadd = 0, xmtaddRCVN = 0;
float ps1scale = 0, cflscale = 0, cfhscale = 0, ftgscale = 0;
float extraScale = 0;
int PSdebugstate = 0 ;
int PSfield_strength = 5000 ;
int PScs_sat = 1 ;
int PSir = 1 ;
int PSmt = 1 ;
int ps1_rxcoil = 0 ;
int ps_seed = 21001;
int tg_1_2_pw = 1 ;
int tg_axial = 1 ;
float coeff_pw_tg = 1.0;
float fov_lim_mps = 350.0 ;
int TGspf = 0 ;
float flip_rf2cfh = 0;
float flip_rf3cfh = 0;
float flip_rf4cfh = 0;
int ps1_tr=2000000;
int cfl_tr=398000;
int cfh_tr=398000;
int rcvn_tr=398000;
float cfh_ec_position = (16.0/256.0) ;
int cfl_dda = 4 ;
int cfl_nex = 2 ;
int cfh_dda = 4 ;
int cfh_nex = 2 ;
int rcvn_dda = 0 ;
int rcvn_nex = 1 ;
int local_tg = 0 ;
float fov_scaling = 0.8 ;
float flip_rf1xtg = 90.0;
float gscale_rf1xtg = 1.0;
int init_xtg_deadtime = 0;
float flip_rf1mps1 = 90.0;
float gscale_rf1mps1 = 1.0;
int presscfh_override = 0 ;
int presscfh = PRESSCFH_NONE ;
int presscfh_ctrl = PRESSCFH_NONE ;
int presscfh_outrange = 0;
int presscfh_cgate = 0;
int presscfh_debug = 0 ;
int presscfh_wait_rf12 = 0;
int presscfh_wait_rf23 = 0;
int presscfh_wait_rf34 = 0;
int presscfh_minte = 20000;
float presscfh_fov = 0.0;
float presscfh_fov_ratio = 1.0;
float presscfh_pfov_ratio = 1.0;
float presscfh_slab_ratio = 1.0;
float presscfh_pfov = 0.0;
float presscfh_slthick = 10.0;
float presscfh_slice = 10.0;
float presscfh_ir_slthick = 10.0;
int presscfh_ir_noselect = 1;
float presscfh_minfov_ratio = 0.3;
int cfh_steam_flag = 0;
int steam_pg_gap = 8;
float area_gykcfl = 0;
float area_gykcfh = 0;
float area_xtgzkiller = 0;
float area_xtgykiller = 0;
int PSoff90=80 ;
int dummy_pw = 0;
int min180te = 0;
float PStloc = 0;
float PSrloc = 0;
float PSphasoff = 0;
int PStrigger = 0;
float PStloc_mod = 0;
float PSrloc_mod = 0;
float PSphasoff_mod = 0;
float thickPS_mod = 0;
float asx_killer_area = 840.0;
float asz_killer_area = 840.0;
float cfhir_killer_area = 4086.0;
float ps_crusher_area = 714.0;
float cfh_crusher_area = 4000.0;
float target_cfh_crusher = 0;
float target_cfh_crusher2 = 0;
int cfh_newmode = 1;
float cfh_rf1freq = 0 ;
float cfh_rf2freq = 0 ;
float cfh_rf3freq = 0 ;
float cfh_rf4freq = 0 ;
float cfh_fov = 0 ;
int cfh_ti = 120000;
int eff_cfh_te = 50000;
int PScfh_shimvol_debug = 0 ;
int debug_shimvol_slice = 0;
int wg_cfh_rf3 = 0;
int wg_cfh_rf4 = 0;
float FTGslthk = 20 ;
float FTGopslthickz1=80 ;
float FTGopslthickz2=80 ;
float FTGopslthickz3=20 ;
int ftgtr = 2000000 ;
float FTGfov = 480.0 ;
float FTGau = 4 ;
float FTGtecho = 4 ;
int FTGtau1 = 8192 ;
int FTGtau2 = 32768 ;
int FTGacq1 = 0 ;
int FTGacq2 = 1 ;
int epi_ir_on = 0 ;
int ssfse_ir_on = 0 ;
int ftg_dda = 0 ;
float FTGecho1bw = 3.90625 ;
int FTGtestpulse = 0 ;
int FTGxres = 256 ;
float FTGxmtadd = 0;
int pw_gxw2ftgleft = 4096;
int xtgtr = 200000 ;
int XTGtau1 = 8192 ;
float XTGfov = 480.0 ;
int pw_bsrf = 4000;
int xtg_offres_freq = 2000;
float XTGecho1bw = 15.625 ;
int XTGxres = 256 ;
float xmtaddXTG = 0, xtgscale = 0;
int xtg_dda = 0 ;
int XTGacq1 = 0 ;
float TGopslthick = 10.0 ;
float TGopslthickx = 30.0 ;
float TGopslthicky = 30.0 ;
int XTG_minimizeYKillerGap = 0 ;
int dynTG_etl = 2 ;
int dtg_iso_delay = 1280 ;
int dtg_off90 = 80;
int dtg_dda = 4 ;
int rf1dtg_type = 1 ;
float echo1bwdtg = 15.625 ;
int dtgt_exa = 0, dtgt_exb = 0, tleaddtg = 0, td0dtg = 0;
int dtgphorder = 1;
int dtgspgr_flag = 0 ;
int pw_rf1dtg = 0;
float a_rf1dtg = 0;
int min_dtgte = 0, dtg_esp = 0;
int tr_dtg = 20000;
int time_ssidtg = 400;
int rsaxial_flag = 1 ;
int rsspgr_flag = 1 ;
int multi_channel = 1 ;
int minph_iso_delay = 1280 ;
int rs_off90 = 80;
int rs_iso_delay = 1280 ;
float echo1bwrs = 15.625 ;
int rsphorder = 1;
int rs_dda = 4 ;
int rst_exa = 0, rst_exb = 0, tleadrs = 0, td0rs = 0;
int pw_rf1rs = 0;
int ia_rf1rs = 0;
float a_rf1rs = 0;
int rf1rs_type = 1 ;
float gscale_rf1rs = 0;
float flip_rf1rs = 0, flip_rfbrs = 0, cyc_rf1rs = 0;
float flip_rf1dtg = 0, flip_rfbdtg = 0, cyc_rf1dtg = 0, gscale_rf1dtg = 0;
int ia_rf1dtg = 0;
float rf1rs_scale = 0, rf1dtg_scale = 0;
float xmtaddrs = 0, xmtadddtg = 0;
int pw_acqrs1 = 0, pw_acqdtg1 = 0;
int min_rste = 0, rs_esp = 0;
int tr_rs = 0, tr_prep_rs = 0;
int rd_ext_rs = 0, rd_ext_dtg = 0;
int fast_xtr = 50;
int attenlen = 6;
int tns_len = 4;
int e2_delay_rs = 4;
int e2_delay_dtg = 4;
int time_ssirs = 400;
int rfshim_etl = 2;
int B1Cal_mode = 0 ;
int DD_delay = 2000 ;
int DD_channels = 2 ;
int DD_nCh = 1;
int DD_debug = 0 ;
int endview_iamprs = 0, endview_iampdtg = 0;
float endview_scalers = 0, endview_scaledtg = 0;
float echo1bwcal = 62.5 ;
int cal_dda = 128 ;
int cal_delay = 4000000 ;
int cal_delay_dda = 0;
int calspgr_flag = 1 ;
int cal_tr_interleave = 0;
int cal_nex_interleave = 0;
float cal_xfov = 100.0;
float cal_yfov = 100.0;
float cal_vthick = 10.0;
int cal_btw_rf_rba_ssp = 0;
int cal_grd_rf_delays = 0;
int tleadcal = 0;
int td0cal = 0;
int calt_exa = 4;
int calt_exb = 4;
int tacq_cal = 4;
int te_cal = 4;
int tr_cal = 4;
float flip_rf1cal = 0.0;
int cal_iso_delay = 0;
int endview_iampcal = 0;
int endviewz_iampcal = 0;
float endview_scalecal = 1.0;
float endviewz_scalecal = 1.0;
float a_combcal = 1.0;
float a_endcal = 1.0;
float a_combcal2 = 1.0;
float a_endcal2 = 1.0;
int time_ssical = 160;
float xmtaddcal = 0.0;
float cal_amplimit = 0.0;
float cal_slewrate = 100.0;
float cal_freq_scale = 1.0;
float cal_phase_scale = 1.0;
float area_gzkcal = 300.0;
float cal_ampscale = 1.05;
int cal_pfkr_flag = 1;
float cal_pfkr_fraction = 1.0;
int cal_sampledPts = 0;
float echo1bwcoil = 62.5 ;
int coil_dda = 4 ;
int coilspgr_flag = 1 ;
int coil_nex_interleave = 0;
float coil_xfov = 100.0;
float coil_yfov = 100.0;
float coil_vthick = 10.0;
int tleadcoil = 0;
int td0coil = 0;
int coilt_exa = 4;
int coilt_exb = 4;
int tacq_coil = 4;
int te_coil = 4;
int tr_coil = 4;
float flip_rf1coil = 0.0;
int coil_iso_delay = 0;
int endview_iampcoil = 0;
int endviewz_iampcoil = 0;
float endview_scalecoil = 1.0;
float endviewz_scalecoil = 1.0;
float a_combcoil = 1.0;
float a_endcoil = 1.0;
float a_combcoil2 = 1.0;
float a_endcoil2 = 1.0;
int time_ssicoil = 160;
float xmtaddcoil = 0.0;
float coil_amplimit = 0.0;
float coil_slewrate = 100.0;
float coil_freq_scale = 1.0;
float coil_phase_scale = 1.0;
int coil_pfkr_flag = 1;
float coil_pfkr_fraction = 1.0;
int coil_sampledPts = 0;
int CFLxres = 256 ;
int CFHxres = 256 ;
float echo1bwcfl = 2.016129 ;
float echo1bwcfh = 0.50 ;
float echo1bwrcvn = 15.625 ;
int rcvn_xres = 4096 ;
int rcvn_loops = 10;
int pw_grdtrig= 8 ;
int wait_time_before_cfh = 1000000 ;
float echo1bwas = 15.625 ;
int off90as = 80 ;
int td0as = 4 ;
int t_exaas = 0 ;
int time_ssias = 400 ;
int tleadas = 25 ;
int te_as = 0;
int tr_as = 0;
int as_dda = 4 ;
int pw_isislice= 200 ;
int pw_rotslice= 12 ;
int isi_sliceextra = 32 ;
int rgfeature_enable = 0 ;
int enableMapTg = 0 ;
float aslenap = 200 ;
float aslenrl = 200 ;
float aslensi = 200 ;
float aslocap = 0 ;
float aslocrl = 0 ;
float aslocsi = 0 ;
float area_gxwas = 0;
float area_gz1as = 0;
float area_readrampas = 0;
int avail_pwgx1as = 0;
int avail_pwgz1as = 0;
int bw_rf1as = 0;
float flip_pctas=1.0;
int dix_timeas = 0;
float xmtaddas = 0,xmtlogas = 0;
int ps1obl_debug = 0
;
int asobl_debug = 0
;
int ps1_newgeo = 1;
int as_newgeo = 1;
int pw_gy1as_tot = 0;
int endview_iampas = 0;
float endview_scaleas = 0;
int cfh_newgeo = 1;
int cfhobl_debug = 0
;
float deltf = 1.0 ;
int IRinCFH = 0 ;
int cfh_each = 0 ;
int cfh_slquant = 0 ;
int noswitch_slab_psc = 0 ;
int noswitch_coil_psc = 0 ;
int PStest_slab = 1 ;
int pimrsapsflg = 0 ;
int pimrsaps1 = 1
;
int pimrsaps2 = 104
;
int pimrsaps3 = 103
;
int pimrsaps4 = 4
;
int pimrsaps5 = 12
;
int pimrsaps6 = 3
;
int pimrsaps7 = 0
;
int pimrsaps8 = 0
;
int pimrsaps9 = 0
;
int pimrsaps10 = 0
;
int pimrsaps11 = 0
;
int pimrsaps12 = 0
;
int pimrsaps13 = 0
;
int pimrsaps14 = 0
;
int pimrsaps15 = 0
;
int pw_contrfhubsel = 4 ;
int delay_rfhubsel = 20;
int pw_contrfsel = 4 ;
int csw_tr = 0 ;
int csw_wait_sethubindeximm = 250000
;
int csw_wait_setrcvportimm = 100000
;
int csw_wait_before = 10000 ;
int csw_time_ssi = 50
;
float area_gxkrcvn = 10000;
float area_gykrcvn = 10000;
float area_gzkrcvn = 10000;
int pre_rcvn_tr = 20000 ;
int rcvn_flag = 1 ;
int psd_startta_override = 0 ;
int psd_psctg = APS_CONTROL_PSC
;
int psd_pscshim = APS_CONTROL_PSC
;
int psd_pscall = APS_CONTROL_PSC
;
int bw_rf1cal = 0, bw_rf1coil = 0;
float yk0_killer_area = 4140.0;
int ir_on = 0 ;
int ir_start = 0 ;
int irk_start = 0 ;
int ir_grad_time = 0 ;
int ir_time = 0 ;
int ir_time_total= 0 ;
int ext_ir_pulse = 1 ;
float rf0_phase = 0 ;
int irslquant = 0;
int pos_ir_start = 0;
int bw_rf0 = 0 ;
int hrf0 = 0 ;
int ir_index = 0;
float csf_fact=0.5;
int ir_fa_scaling_flag = 0 ;
int inner_spacing = 0;
int post_spacing = 0;
int invseqlen = 0;
 int ir_rfupa = -600 ;
 int ir_sys_type = 0 ;
int invThickOpt = 0 ;
int invThickOpt_seqtime = 0 ;
int t2flair_extra_ir_flag = 0 ;
int packs = 0 ;
int ir_fa_scale_debug = 0 ;
int ss_rf1 = 0 ;
int fat_flag = 0 ;
float fat_delta = -230.0
;
int fat_offset = -386 ;
int sszchop = 0
;
int pw_gzrf1lobe = 0;
int pw_constant = 0;
int num_rf1lobe = 0;
int gradient_mode = 1 ;
int ss_rf_wait = 0
;
int pw_ss_rampz = 0;
int ss_override = 0 ;
int whichss = 0;
float nbw_ssrf = 0;
float ss_min_slthk = 0, ss_maxoff = 0, ss_minslthk1 = 0;
int ss_convolution_flag = 0 ;
int breast_spsp_flag = 0 ;
int ss_fa_scaling_flag = 0 ;
int ss_fa_scale_debug = 0 ;
float max_ss_fa = 0;
int ss_maxoffex = 0;
int off90minor = 0;
float omega_amp = 0;
float gz1_zero_moment = 0;
float gz1_first_moment = 0;
float a_gzrf1_ss_max = 0;
int freqSign = 1;
 int cv_rfupa = -600 ;
 int system_type = 0 ;
 int cvlock = 1 ;
 int psd_taps = -1
;
 int fix_fermi = 0
;
 int grad_spec_ctrl = 0
  ;
 float srate = 1.651 ;
 float glimit = 1.0 ;
 float save_gmax = 1.0;
 float save_srate = 2.551;
 int save_cfxfull = 32752;
 int save_cfyfull = 32752;
 int save_cfzfull = 32752;
 float save_cfxipeak = 194.0;
 float save_cfyipeak = 194.0;
 float save_cfzipeak = 194.0;
 int save_ramptime = 600;
 int debug_grad_spec = 0 ;
 float act_srate=1.651;
 int val15_lock = 0
  ;
 int avecrushpepowscale_for_SBM_XFD = 0;
int dbdt_model = 0 ;
float dbdtper_new = 0;
int esprange_check = 0 ;
int espamp_check = 0 ;
int espopt = 1 ;
int espincway = 0 ;
int epigradopt_debug = 0;
int epigradopt_output = 0;
int disable_crc_check_for_esp = 0 ;
float dbdtperx = 0;
float dbdtpery = 0;
float dbdtperz = 0;
int max_dbdtper_hb_zblips = 1
;
float scale_ramp = 1.0 ;
int debugTensor = 0 ;
int tensor_flag = 0 ;
int ftde_flag = 0 ;
int num_tensor = 6 ;
int validTensorFile = 0;
int validTensorFileAndEntry = 0;
int num_B0 = 1 ;
int sep_time = 0 ;
int min180_echo_tim = 2000 ;
int min180_echo_tim2 = 2000 ;
int calc_bmatrix_flag = 0 ;
int bmax_fixed = 0;
int pgen_calc_bval_flag = 0 ;
int tensor_host_sort_flag = 0 ;
int tensor_host_sort_debug = 0;
int sse_manualte_derating = 1 ;
int sse_manualte_derating_debug = 0;
float spherical_derating_limit = 5.0 ;
int collect_six_sigma = 0;
float per_err_orig_x = 0.0;
float per_err_orig_y = 0.0;
float per_err_orig_z = 0.0;
float per_err_corr_x = 0.0;
float per_err_corr_y = 0.0;
float per_err_corr_z = 0.0;
int sse_enh = 1 ;
int optimizedTEFlag = 0 ;
int act_numdir_clinical = 150 ;
int maxwell_flag = 1;
int maxwell_blip = 1;
float B0_field = 0;
float pw_gxw_MAX_l = 0;
float pw_gxw_MAX_r = 0;
float pw_gyb_MAX_l = 0;
float pw_gyb_MAX_r = 0;
int max_debug=0;
int nodelay=0;
int nodelayesp=0;
int b0dither_new = 1 ;
int nob0dither=0;
int nob0dither_interpo=0;
int nobcfile=0;
int number_of_bc_files = 0;
int activeReceivers=-1;
int flagWarning = (1);
int rfov_flag = 0 ;
int rfov_type = 0 ;
int rfov_override = 0 ;
int rfov_cmplx_avg_flag = 1 ;
int debug_rfov = 0 ;
float psminfov = 120 ;
float psminslthick = 10.0 ;
float temp_slthick = 10.0 ;
int rfov_maxnslices = 16;
int rfov_fa_scaling_flag = 1;
float max_rfov_fa = 0;
float rfov_dbdtper = 0.0 ;
int rfov_dbdt_debug = 0 ;
int start_rf1 = 0;
float thky_rf1 = 0;
float a_gyrf1 = 0;
int ia_gyrf1 = 0;
int pw_gyrf1 = 0;
int pw_gyrf1a = 0;
int pw_gyrf1d = 0;
int res_gyrf1 = 0;
int ia_thrf1 = 0;
int addrfdel = 0;
float area_gyex1 = 0.0;
int pw_gyex1_tot = 0;
int ex_res = 0;
int ex_pw = 0;
int ex_ttipdown = 0;
float ex_nom_flip = 0;
float ex_abswidth = 0;
float ex_effwidth = 0;
float ex_area = 0;
float ex_dtycyc = 0;
float ex_maxpw = 0;
float ex_max_b1 = 0;
float ex_max_int_b1_sqr = 0;
float ex_max_rms_b1 = 0;
float ex_a_gzs = 0;
float ex_nom_thkz = 0;
float ex_a_gys = 0;
float ex_nom_thky = 0;
float ex_maxnslices = 0;
int ex_num_gylobe = 0;
int ex_num_gzlobe = 0;
int ex_pw_gyrf1lobe = 0;
int ex_pw_rampy = 0;
int ex_pw_rampz = 0;
int ex_pw_constanty = 0;
int ex_pw_constantz = 0;
float ex_refocus_ratioy = 0;
float ex_refocus_ratioz = 0;
float ex_tbwy = 0;
float ex_tbwz = 0;
int freqSign_ex = 1;
float shift_to_freq = 0.0;
float y_shift = 0.0;
float y_to_freq = 0.0;
float z_shift = 0.0;
float z_to_freq = 0.0;
int type1_support = 0 ;
int type1_flag = 0;
int homogeneity_flag = 0 ;
float ex_a_gys_pos = 0.0;
float a_gys_pos = 0.0;
int ia_gys_pos = 0;
int ex_pw_rampy_pos = 0;
int ex_pw_constanty_pos = 0;
float excite_ratio = 1.0;
int walk_sat_flag = 0;
int pw_wksat_tot = 0;
float a_gyrfwk = 0.0;
int ia_gyrfwk = 0;
int pw_gyrfwk = 0;
int pw_gyrfwka = 0;
int pw_gyrfwkd = 0;
int pw_gwksp = 0;
int pw_gwkspa = 0;
int pw_gwkspd = 0;
float a_gwksp = 0.0;
int pos_sp_wk = 0;
int walk_sat_cycle = 16 ;
int wg_rfwk = 0;
int res_rfwk_orig = 0;
int res_rfwk = 0;
int pw_rfwk = 0;
int hrfwka = 0;
int hrfwkb = 0;
float flip_rfwk = 90.0;
int bw_rfwk = 0;
float cyc_rfwk = 3.0;
float a_rfwk = 0.0;
int ia_rfwk = 0;
int ia_thrfwk = 0;
int pos_rfwk = 0;
int off_rfwk = 0;
int off_thrfwk = 0;
float loc_satcen_cm = 0.0;
float loc_satcen_Hz = 0.0;
float sat_thk_factor = 0.4 ;
float sep_sat_ratio = 0.0;
float rfov_max_freq_shift = 0.0 ;
int mux_flag = 0 ;
float mux_phase_step = 0;
int thetarf2_flag = 0 ;
int use_omegatheta = 1 ;
int omegatheta_pol = -1 ;
int rf2_isodelay= 0 ;
int mux_slquant = 1;
int res_thetarf2 = 0, res_gzrf2 = 0, pw_thetarf2 = 0, ia_thetarf2 = 0;
int ia_thetarf2left=32767;
int ia_thetarf2right=32767;
int pw_thetarf2a = 0;
int pw_thetarf2d = 0;
int pw_thetarf2left = 0;
int pw_thetarf2lefta = 0;
int pw_thetarf2leftd = 0;
int pw_thetarf2right = 0;
int pw_thetarf2righta = 0;
int pw_thetarf2rightd = 0;
int verse_rf2 = 1 ;
int sltune_rf2 = 0;
int mux_slices_rf2 = 2 ;
int phase_cycle_rf2 = 1 ;
int mux_band_gap_warning_flag = 1;
float tbwp_rf1 = 1.0 ;
int window_type_rf1 = 1 ;
float gauss_width_rf1 = 1.0 ;
int mux_slices_rf1 = 2 ;
float mux_slice_shift_mm_rf1 = 30.0 ;
int save_res_rf1 = 0;
float save_tbwp_rf1 = 0.0;
int save_window_type_rf1 = 0;
float save_gauss_width_rf1 = 0.0;
int save_mux_slices_rf1 = 0;
float save_mux_slice_shift_mm_rf1 = 0.0;
float save_thk_rf1 = 0.0;
int save_mux_mode_rf1 = 0;
int dwell_rf_rf1 = 2;
int debug_mux_rf = 0 ;
int multiband_fa_scaling_flag = 1 ;
float max_multiband_rf1_fa = 0.0;
float max_multiband_rf2_fa = 0.0;
float mux_rf1_scale = 1.0 ;
float mux_rf2_scale = 1.0 ;
int slice_fov_shift = 0 ;
int use_slice_fov_shift_blips = 1 ;
float slice_fov_shift_area = 0.0 ;
float slice_fov_shift_cycles = 0.0 ;
int slice_fov_shift_blip_start = 0 ;
int slice_fov_shift_blip_inc = 1 ;
float factor_gz1 = 1.0 ;
float gzb_amp = 0.0 ;
int slice_fov_shift_extra_gap = 0 ;
int slice_fov_shift_calc_new_esp = 0 ;
int slice_fov_shift_extra_gap_flag = 0 ;
float mux_min_verserf2_slthk = 1.0 ;
int seqtime_t1flair = 0;
int act_ti = 0;
int dda_t1flair = 0;
int dummyslices = 0 ;
int autoti_model = 1 ;
int t1flair_autotr_flag = 1;
int t2flair_autotr_flag = 1;
int t1flair_seqtime_method = 0 ;
int tmin_total_acq_seq = 0, tmin_total_ir = 0;
float dtr1_tolerance = 0;
float dtr2_tolerance = 0;
int max_slice_num_reduction = -1;
float t1flair_mint1 = 0, t1flair_mint2 = 0;
int avminti_t1flair = 0, avmaxti_t1flair = 0;
int debug_t1flairenh = 0;
int t1flair_chop_flag = 0 ;
int req_edge_slice_enh_flag = 0 ;
int act_edge_slice_enh_flag = 0 ;
int t1flair_slice_uniformity_flag = 1 ;
int force_odd_even_slquant= 1 ;
int enht2flairacqs = 0;
int enht2flair_highsort = 0 ;
int avmintr_autotr_t1flair =1500000;
int incinv = 1;
int slquant_in_ti = 0;
int act_esp = 4000;
int autotr_flair_debug = 0;
int T1FLAIR_MIN_TI = 50000;
int T1FLAIR_MAX_TI = 2000000;
int ir_prep_manual_tr_mode = 0 ;
float asset_factor = 0.5 ;
float assetsl_factor = 1.0 ;
int assetph_flag = 0 ;
int assetsl_flag = 0 ;
int asset_supported_direction = 0
;
int fov_advisory_ignore_mslices = 0 ;
int arc_research_flag = 0 ;
int arc_split_method = 0 ;
int arc_fullbam_flag = 1 ;
int arc_extCal = 0 ;
int arc_ph_flag = 0 ;
float arc_ph_factor = 1.0 ;
float arc_ph_maxstride = 1.0 ;
float arc_ph_recstride = 1.0 ;
float arc_ph_userstride = 1.0 ;
int arc_ph_stride = 1 ;
float arc_ph_maxnetaccel = 1.0 ;
float arc_ph_recnetaccel = 1.0 ;
int arc_ph_acs = 12 ;
int arc_ph_acs_min = 12 ;
int arc_ph_fullencode = 256 ;
int arc_ph_spanned = 256 ;
int arc_ph_acquired = 128 ;
int arc_ph_intaccel = 1 ;
int arc_ph_halfnex = 0 ;
int arc_ph_hnover = 0 ;
int arc_ph_minover = 8 ;
int arc_sl_flag = 0 ;
float arc_sl_factor = 1.0 ;
float arc_sl_maxstride = 1.0 ;
float arc_sl_recstride = 1.0 ;
float arc_sl_userstride = 1.0 ;
int arc_sl_stride = 1 ;
float arc_sl_maxnetaccel = 1.0 ;
float arc_sl_recnetaccel = 1.0 ;
int arc_sl_acs = 12 ;
int arc_sl_acs_min = 12 ;
int arc_sl_fullencode = 128 ;
int arc_sl_spanned = 128 ;
int arc_sl_acquired = 64 ;
int arc_sl_intaccel = 1 ;
int arc_sl_halfnex = 0 ;
int arc_sl_hnover = 0 ;
int arc_sl_minover = 8 ;
float arc_sl_fn = 1.0 ;
int arc_kx_peak_pos = 0 ;
int arc_ky_peak_pos = -1 ;
int arc_syn_pts = 0 ;
int ARCKey = 0;
int readmonloc = 0;
int loopdelay = 1000000 ;
int loopdelay2 = 100000 ;
int navgs = 20 ;
float sigma1 = 5.0 ;
float sigma2 = 1.0 ;
int savedata = 1 ;
int max_avg_time = 40000000 ;
float monloc_shift = 0.0 ;
int tracker_quant = 0 ;
int acq_data_only = 0 ;
int mon_tr = 20000 ;
int smartprep_flag = 0 ;
int min_delay_time = 0 ;
int num_audibles = 2 ;
int audible_loop = 16;
int data_type = 1 ;
int save_fft = 0;
int swap_monplane = 0 ;
int swap_mon_zy = 0 ;
int detector_mode = 0 ;
float fov_factor = 1.0 ;
int nav_angle_adj = 0 ;
float mon_angle = 0.0 ;
float nav_tipup_ratio = 2.0 ;
int cylr_rf_type = 0 ;
int pw_rfcylr = 0,ia_rfcylr = 0;
float a_rfcylr = 0;
int pw_thcylr = 0,ia_thcylr = 0;
float a_thcylr = 0;
int pw_gycylr = 0,ia_gycylr = 0;
float a_gycylr = 0;
int pw_gzcylr = 0,ia_gzcylr = 0;
float a_gzcylr = 0;
int pw_rfcylrtipup = 0,ia_rfcylrtipup = 0;
float a_rfcylrtipup = 0;
int pw_thcylrtipup = 0,ia_thcylrtipup = 0;
float a_thcylrtipup = 0;
int pw_gycylrtipup = 0,ia_gycylrtipup = 0;
float a_gycylrtipup = 0;
int pw_gzcylrtipup = 0,ia_gzcylrtipup = 0;
float a_gzcylrtipup = 0;
float min_delay_sec = 0;
int delay_dda = 0;
int delay_quiet_dda = 0;
int total_quiet_dda = 0;
int rtpend_quiet_dda = 0 ;
int delay_quiet_time = 0;
int debug_monrot=0;
int debug_monrotphi=0;
int debug_monloc=0;
int transpose_monloc = 0;
int write_spinfo = 0;
int oblique_monplane=0;
int monitor_axis = 0;
float theta = 0;
int ta_180sp = 0, tb_180sp = 0,te_180sp = 0;
int min_montr = 0,tlead_monitor = 0,tlead_montipup = 0,mon_ssi_time = 0;
int non_tetime_mon = 0, tmin_mon = 0, tmin_montipup = 0;
int rda_mon = 0;
int minseqcoilmon_t = 0;
int minseqgrddrvmon_t = 0;
int minseqgrddrvxmon_t = 0;
int minseqgrddrvymon_t = 0;
int minseqgrddrvzmon_t = 0;
int minseqcablemon_t = 0;
int minseqbusbarmon_t = 0;
int max_seqsarmon = 0;
int min_seqrfampmon = 0;
int monnewgeo = 1;
int monobl_debug = 0
;
int monobl_method = 1
;
int monitor_page = 1 ;
float monave_sar = 0, monpeak_sar = 0;
float moncave_sar = 0;
int mon_xres = 128 ;
float rf1mon_shift = 0.0 ;
float rf2mon_shift = 0.0 ;
int bw_rf1mon = 0, bw_rf2mon = 0, bw_rfmontipup = 0;
float mon_fov = 200.0 ;
float mon_acqfov = 200.0 ;
float echo1monbw = 0;
float mon_vthickz = 40.0 ;
float mon_vthicky = 40.0 ;
float mon_vthick = 40.0 ;
float area_gzkmon = 2500.0 ;
float area_gzkmontipup = 2500.0 ;
int mon_fcomp = 1 ;
float fnecho_frac = 0.6 ;
int monitor_test = 0;
int get_fullecho = 0;
int numpts2pass = 0;
int reverse_views = 0 ;
int mon_trigger_delay = 0;
int smartprep_was_on=0;
float scanclocktime = 0;
int mon_dabdelay = 1000;
int xres2use = 128;
int num_avg_bline = 40;
int num_throwaways = 5;
int num_baseline_pts = (40 + 5);
float tmpbw1 = 0;
int debug_sp_rtp = 0;
int debug_sp_agp = 0;
int cerdtype = 002 ;
int mon_run_setrcvportimm = 1 ;
int sprep_save_raw_data = 0 ;
int sprep_debug_flag = 0 ;
int sprep_timing_flag = 1 ;
int rtpresultwait = 1000;
int navend_time = 20000 ;
int nav_dual_mode = 1 ;
int nav_irprep_flag = 0 ;
int nav_tseq_irprep = 0 ;
int nav_min_tseq_irprep = 0 ;
int pw_nomcyl = 5500 ;
float a_nomcyl = 1.44 ;
int smartPrepEdrFlag = 1 ;
int slabtracking_flag = 0 ;
int corr_mode = 2
;
float corr_factor_z = 1.0
;
float corr_factor_y = 1.0
;
float corr_factor_x = 1.0
;
int corr_x = 1
;
int corr_y = 1
;
int corr_z = 1
;
int fixed_acqs_debug = 0 ;
int sl_acq = 1 ;
int sl_acq_val2 = 1 ;
int sl_acq_val3 = 1 ;
int sl_acq_val4 = 1 ;
int tr_acq = 10000 ;
int tr_acq_val2 = 10000 ;
int tr_acq_val3 = 10000 ;
int tr_acq_val4 = 10000 ;
int tr_limit = 30 ;
int temp_trval =10000 ;
int temp_tmin_total = 1000 ;
int keep_opti = 0;
int rtb0_flag = 0 ;
int rtb0_enable = 0 ;
int rtb0_support = 0 ;
int rtb0_first_skip = 20 ;
int rtb0_last_skip = 20 ;
int rtb0_movAvg = 5 ;
int rtb0_min_points = 10 ;
int rtb0DebugFlag = 0;
int rtb0SaveRaw = 0;
int rtb0_phase_method = 1 ;
int rtb0_coil_combine = 1 ;
int rtb0_timing_flag = 0 ;
int rtb0dummy_time = 1200000;
int rtb0fittingwaittime = 1000000;
int rtb0resultwaittime = 1000;
int rtb0fittingwaittimeLoop = 1;
int rtb0dummyseq = 1 ;
int rtb0_comp_flag = 0 ;
int rtb0_acq_delay = 0 ;
int rtb0_minintervalb4acq = 0;
int rtb0_r1_delta = 2 ;
int pw_dynr1=4;
int rtb0_filter_cf_flag = 1 ;
int rtb0_recvphase_comp_flag = 0 ;
int rtb0_comp_debug_flag = 0 ;
float rtb0_cfoffset_debug = 0.0;
int rtb0_slice_shift = 0 ;
int cf_interpolation = 4 ;
float rtb0_max_range = 300.0 ;
int rtb0_rejectnoise = 1 ;
int rtb0_smooth_kernel_size = 9 ;
int rtb0_smooth_cf_flag = 0 ;
int rtb0_median_kernel_size = 3 ;
int rtb0_min_kernel_keep_edge = 1 ;
float rtb0_max_kernel_percent = 50.0 ;
int rtb0_max_kernel_keep_edge = 1 ;
int rtb0_confidence_method = 1 ;
float rtb0_cfstddev_threshold = 100.0 ;
float rtb0_cfresidual_threshold = 100.0 ;
float rtb0_confidence_thresh_val = 100.0 ;
int rtb0_gzrf0_off = 1 ;
int rtb0_spsp_flag = 0 ;
int rtb0_dda = 0 ;
int rtb0_debug = 0 ;
int rtb0_midsliceindex = -1 ;
float rtb0_outlier_threshold = 10.0 ;
float rtb0_outlier_duration = 30.0 ;
int rtb0_outlier_nTRs = 0;
int focus_eval_oscil = 0 ;
int focus_eval_oscil_hist = 0 ;
int isPredownload = 0 ;
int keep_focus_eval_oscil = 0 ;
int reset_oscil_in_eval = 0 ;
int force_acqs = 0 ;
int force_avmaxslquant = 0 ;
int oscil_eval_count = 0;
int optr_save = 0 ;
int opslquant_save = 0 ;
int save_avmintr = 0;
int save_pitracqval4 = 0;
int num_passdelay = 1 ;
int use_maxloggrad = 0 ;
int max_grad = 0;
float scale_dif = 0.0;
int debug_core = 0 ;
int debug_unitTest = 0 ;
float taratio = 0.0 ;
int rampopt = 1 ;
float totarea = 0;
float actratio = 0;
int dpc_flag = 0 ;
int sndpc_flag = 1 ;
int iref_etl = 0 ;
int iref_frames = 0;
int tot_etl = 1 ;
int pw_gxiref1_tot = 0;
int pw_gxiref_tot = 0;
int pw_gxirefr_tot = 0;
int MinFram2FramTime = 30 ;
int maxslice_per_ti = 0 ;
int invseqtime = 0;
int false_acqs = 0;
int false_slquant1 = 1 ;
int max_slice_ti = 0;
int flair_min_tr = 10000000;
int dda_packb = 0, dda_pack = 0, dda_packe = 0;
int dda_passb = 0, dda_pass = 0;
int deadlast = 0;
int tmp_deadlast = 0;
float phase_dither = 0.0 ;
int spgr_flag = 0 ;
int rhhnover_max = 0;
int rhhnover_min = 16;
int rhhnover_min_per_ilv = 16;
int newyres= 0;
int num_overscan = 8;
int smart_numoverscan = 1 ;
int avmintefull = 0 ;
int cvrefindex1 = 0;
float gx1_area = 0;
int avmintetemp = 0;
int fast_rec = 0
;
int bl_acq_tr1 = 1000 ;
int bl_acq_tr2 = 300000 ;
float fecho_factor = 0;
float tsp = 2.0 ;
int intleaves = 1 ;
int ky_dir = 2 ;
int kx_dir = 0 ;
int dc_chop = 1 ;
int etot = 0 ;
int emid = 0 ;
int e1st = 0 ;
int seq_data = 0 ;
float msamp = 0.0 ;
float dsamp = 0.0 ;
float delpw = 0;
int num_dif=0 ;
int incr = 0 ;
int df_encode = 0 ;
int i_bval = 0 ;
int df_refscn = 0 ;
int dwi_fphases = 0;
int max_slice_dfaxall = 256;
int dualspinecho_flag = 0 ;
int derate_amp = 1 ;
float scale_difx = 1.0 ;
float scale_dify = 1.0 ;
float scale_difz = 1.0 ;
int unbalanceCrusher = 1 ;
float crusherFactorLeft = 1.0 ;
float crusherFactorRight = 2.0 ;
int invertSliceSelectZ = 0 ;
int invertSliceSelectZ2 = 0 ;
int xygradRightCrusherFlag = 0 ;
int xygradLeftCrusherFlag = 0 ;
int xygradCrusherFlag = 0 ;
int invertCrusherXY = 0 ;
int ssgr_mux = 0 ;
int ssgr_flag = 0 ;
int ssgr_bw_update = 0 ;
int freqSign_rf2right = 1;
int freqSign_rf2left = 1;
int freqSign_rf2 = 1;
float fat_cs = 220.0;
float rf1_bw_ratio = 2.0;
float rf2_bw_ratio = 2.0;
float b0_offset = 100.0;
int RightCrusherLSlop = 0 ;
int RightCrusherRSlop = 0 ;
int LeftCrusherLSlop = 0 ;
int LeftCrusherRSlop = 0 ;
int CrusherRSlop = 0 ;
int CrusherLSlop = 0 ;
int epi2spec_mode = 0 ;
int weighted_avg_grad = 1 ;
int weighted_avg_debug = 0 ;
float DELTAx = 0;
float DELTAy = 0;
float DELTAz = 0;
float deltax = 0;
float deltay = 0;
float deltaz = 0;
float a_gx_dwi=0.0000;
float a_gy_dwi = 0.0000 ;
float a_gz_dwi = 0.0000 ;
float freq_dwi = 0.0 ;
float phase_dwi = 0.0 ;
int ia_gx_dwi = 0;
int ia_gy_dwi = 0;
int ia_gz_dwi = 0;
int dwicntrl=0;
int dwidebug=0;
int tmp_ileave = 0;
int tmp_ygrad_sw = 0;
float t4_tmp = 0;
float incdifx = 1.0 ;
float incdify = 1.0 ;
float incdifz = 1.0 ;
int ia_incdifx = 0, ia_incdify = 0, ia_incdifz = 0;
float bincr = 0;
float invthick = 1.0;
float xerror = 0, yerror = 0, zerror = 0;
int obl_3in1_opt_debug
  = 0 ;
int obl_3in1_opt
  = 0 ;
float norot_incdifx = 0;
float norot_incdify = 0;
float norot_incdifz = 0;
float target_mpg_inv = 0;
float target_mpg = 0;
float amp_difx_bverify = 0,amp_dify_bverify = 0,amp_difz_bverify = 0;
int different_mpg_amp_flag = 0;
int act_acqs = 1;
int min_acqs = 0;
int maxslq_titime = 0;
int maxslq_ilir = 0;
int epi_flair = 0 ;
int flair_flag = 0;
float dda_fact = 0;
int reps = 1 ;
int pass_reps = 1 ;
int max_dsht = 7 ;
int avg_at_loc = 0 ;
int filtfix = 0 ;
int rf_chop = 1 ;
int rftype = 1 ;
int thetatype = 0 ;
int gztype = 1 ;
int hsdab = 1 ;
int slice_num = 1 ;
int rep_num = 1 ;
int endview_iamp = 0;
int endview_scale = 0;
int gx1pos = 1 ;
int gy1pos = 1 ;
int eosxkiller = 0 ;
int eosykiller = 1 ;
int eoszkiller = 1 ;
int eoskillers = 1 ;
int eosrhokiller = 1 ;
int gyctrl = 1 ;
int gxctrl = 1 ;
int gzctrl = 1 ;
int ygmn_type = 0;
int zgmn_type = 0;
int rampsamp = 0 ;
int final_xres = 0 ;
int autovrgf = 1 ;
float vrgf_targ = 2.0 ;
int vrgf_reorder = 1 ;
float fbhw = 1.0 ;
int osamp = 0 ;
int etl = 1 ;
int eesp = 0 ;
int nblips = 0, blips2cent = 0;
int ep_alt = 0 ;
int tia_gx1 = 0, tia_gxw = 0, tia_gxk = 0;
int tia_gxiref1 = 0, tia_gxirefr = 0;
float ta_gxwn = 0;
float rbw = 0;
int avminxa = 0, avminxb = 0, avminx = 0, avminya = 0, avminyb = 0, avminy = 0;
int avminza = 0, avminzb = 0, avminz = 0, avminssp = 0;
float avminfovx = 0, avminfovy = 0;
int hrdwr_period = 4 ;
int samp_period = 8 ;
int pwmin_gap = 2*4;
float frqx = 200.0 ;
float frqy = 2.0 ;
int dacq_offset = 14 ;
int pepolar = 0 ;
int rpg_flag = 0 ;
int rpg_in_scan_flag = 0 ;
int rpg_in_scan_num = 1 ;
int tdaqhxa = 0, tdaqhxb = 0;
int xdiff_time1 = 0, xdiff_time2 = 0;
int ydiff_time1 = 0, ydiff_time2 = 0;
int zdiff_time1 = 0, zdiff_time2 = 0;
float delt = 0;
int T1eff = 0;
float bcoeff = 0;
int aspir_auto_ti_model = 0;
int tfon = 1 ;
int fract_ky = 0 ;
float ky_offset = 0.0 ;
float gy1_offset = 0.0 ;
int satdelay = 0000 ;
int sp_sattype = 0 ;
int td0 = 4 ;
int t_exa = 0 ;
int te_time = 0 ;
int pos_start = 0 ;
int pos_start_init = 0 ;
int post_echo_time = 0 ;
int psd_tseq = 0 ;
int time_ssi = 1000 ;
float dacq_adjust = 0.0 ;
int watchdogcount = 10 ;
int dabdelay = 0 ;
int tlead = 25 ;
int act_tr = 0 ;
int rfconf = 1 + 4 + 8 + 128;
int ctlend = 0 ;
int dda = 0 ;
int debug = 0 ;
int debug_dbdt = 0 ;
int debugipg = 0 ;
int debugepc = 0 ;
int debugdither = 0 ;
int debugdelay = 0 ;
int dex = 0 ;
int gating = 0 ;
int ipg_trigtest = 1 ;
int gxktime = 0 ;
int gyktime = 0 ;
int gzktime = 0 ;
int gktime = 0 ;
int gkdelay = 100 ;
float scanbw = 62.5 ;
int scanslot = 0 ;
float a_lcrush_cfh = 0;
float area_gxw = 0;
float area_gx1 = 0;
float area_readramp = 0;
float area_r1 = 0, area_gz1 = 0, area_gzrf2l1 = 0, area_r1_cfh = 0;
float area_std = 0, area_stde = 0;
int avail_pwgz1 = 0;
int prescan1_tr = 2000000 ;
int ps2_dda = 0 ;
int avail_pwgx1 = 0;
int avail_image_time = 0;
int beg_nontetime = 0;
int pos_start_rf0 = 0;
int beg_nontitime = 0;
int avail_se_time = 0;
int avail_tdaqhxa = 0;
int full_irtime = 0;
int avail_yflow_time=0;
int avail_zflow_time = 0;
int nviews = 0;
int test_getecg = 1;
int premid_rf90 = 0 ;
float c1_scale = 0, c2_scale = 0;
float crusher_cycles = 4.0;
int sar_amp = 0;
int sar_cycle = 0;
int sar_width = 0;
int max_seqtime = 0;
int max_slicesar = 0;
int max_seqsar = 0;
float myrloc = 0 ;
int other_slice_limit = 0;
float target_area = 0;
float start_amp = 0;
float end_amp = 0;
int pre_pass = 0 ;
int nreps = 0 ;
float xmtaddScan = 0;
float rfscale = 1.0 ;
int rfExIso = 0;
int frq2sync_dly = 9 ;
float rf1_phase = 0 ;
float rf2_phase = 0 ;
int hrf1a = 0, hrf1b = 0;
int hrf2a = 0, hrf2b = 0;
int innerVol = 0 ;
float ivslthick = 5 ;
int psd_mantrig = 0 ;
int trig_mps2 = 0x01 ;
int trig_aps2 = 0x01 ;
int trig_scan = 0x01 ;
int trig_prescan = 0x01 ;
int read_truncate = 1 ;
int tmin_flair = 0;
int trigger_time = 0 ;
int use_myscan = 0 ;
int t_postreadout = 0;
int initnewgeo = 1;
int obl_debug = 0 ;
int obl_method = 1 ;
int debug_order = 0 ;
int debug_tdel = 0 ;
int debug_scan = 0 ;
int postsat = 0;
int order_routine = 0 ;
int scan_offset = 0;
int dither_control = 0;
int dither_value = 0 ;
int slquant_per_trig = 0 ;
int non_tetime = 0;
int slice_size = 0;
int max_bamslice = 0;
int rf2PulseType = 0;
int bw_rf1 = 0, bw_rf2 = 0;
float a_gx1 = 0;
int ia_gx1 = 0;
int pw_gx1a = 0;
int pw_gx1d = 0;
int pw_gx1 = 0;
int single_ramp_gx1d = 0;
float area_gy1 = 0;
float area_gyb = 0;
float a_omega = 0;
int ia_omega = 0;
float bline_time = 0;
float scan_time = 0;
float t1flair_disdaq_time = 0.0;
int pw_gx1_tot = 0;
int pw_gy1_tot = 0;
int pw_gymn1_tot = 0, pw_gymn2_tot = 0;
float gyb_tot_0thmoment = 0;
float gyb_tot_1stmoment = 0;
int pw_gz1_tot = 0;
int pw_gzrf2l1_tot = 0;
int pw_gzrf2r1_tot = 0;
int pw_gzrf2l1_tot_bval = 0;
int pw_gzrf2l2_tot_bval = 0;
int pw_gzrf2r1_tot_bval = 0;
int pw_gzrf2r2_tot_bval = 0;
int dab_offset = 0;
int xtr_offset = -56;
int rcvr_ub_off = -100;
int temprhfrsize = 0;
int pw_wgxdl = 0;
int pw_wgxdr = 0;
int pw_wgydl = 0;
int pw_wgydr = 0;
int pw_wgzdl = 0;
int pw_wgzdr = 0;
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
float zeromoment = 0;
float firstmoment = 0;
float zeromomentsum = 0;
float firstmomentsum = 0;
int pulsepos = 0;
int invertphase = 0;
float xtarg = 1.0 ;
float ytarg = 1.0 ;
float ztarg = 1.0 ;
int ditheron = 1 ;
float dx = 0.0 ;
float dy = 0.0 ;
float dz = 0.0 ;
int b0calmode = 0 ;
int slice_reset = 0 ;
float slice_loc = 0.0 ;
int delayon = 1 ;
int gxdelay = 0 ;
int gydelay = 0 ;
float gldelayx = 0 ;
float gldelayy = 0 ;
float gldelayz = 0 ;
float pckeeppct = 100.0 ;
int pkt_delay = 0 ;
int mph_flag = 1 ;
int acqmode = 0 ;
int max_phases = 0;
int opslquant_old = 1 ;
int piphases = 0;
int reqesp = 0 ;
int autogap = 0 ;
int minesp = 0;
int fft_xsize = 0 ;
int fft_ysize = 0 ;
int image_size = 0 ;
float xtr_rba_time = 130 + 5 ;
float frtime = 0.0 ;
int readpolar = 1 ;
int blippolar = 1 ;
int ref_mode = 1 ;
int refnframes = 256 ;
int ref_with_xoffset = 1 ;
int noRefPrePhase = 0 ;
int setDataAcqDelays = 1 ;
int refSliceNum = -1 ;
int core_shots = 0;
int disdaq_shots = 0;
int pass_shots = 0;
int passr_shots = 0;
int pass_time = 0;
int scan_deadtime = 0;
int pw_gxwl1 = 0;
int pw_gxwl2 = 0;
int pw_gxwr1 = 0;
int pw_gxwr2 = 0;
int pw_gxw_total = 0 ;
int pass_delay = 1 ;
int nshots_locks = 0 ;
int min_nshots = 1 ;
int max_nshots = 1 ;
float da_gyboc = 0.0 ;
float oc_fact = 2.0 ;
int oblcorr_on = 0 ;
int oblcorr_perslice = 0 ;
int debug_oblcorr = 0 ;
float bc_delx = 0.0 ;
float bc_dely = 0.0 ;
float bc_delz = 0.0 ;
int cvxfull = 32767;
int cvyfull = 32767;
int cvzfull = 32767;
float bw_flattop = 0;
float area_usedramp = 0;
float pw_usedramp = 0;
float area_usedtotal = 0;
int EZflag = 0 ;
float omega_scale= 256.0 ;
int rba_act_start = 0;
int aps2_rspslq = 0;
int aps2_rspslqb = 0;
int ghost_check = 0 ;
int gck_offset_fov = 1 ;
int irprep_flag = 0 ;
int irprep_support = 0 ;
int enhanced_fat_suppression = 0 ;
int global_shim_method = 0 ;
int d_cf = 0;
int rt_opphases = 1
;
int debugileave = 0;
float rup_factor = 2.0;
float min_phasefov = 0.5 ;
float core_time = 0 ;
int override_fatsat_high_weight = 0 ;
float scale_all = 1.0 ;
float default_bvalue = 1000;
int default_difnex = 1;
int use_phygrad=1;
int total_difnex = 0;
int max_difnex = 0;
int max_nex = 0;
float max_bval = 0;
int gradopt_diffall = 0;
int ADC_warning_flag = 1;
int edwi_extra_time = 40000;
int bigpat_warning_flag = 1;
float avg_bval = 0.0;
int max_difnex_limit = 16;
int syndwi_flag = 0 ;
float prescribed_max_bval=0;
float prescribed_min_bval=1000000;
float prescribed_bval_range=0.0;
int fullk_nframes = 1;
float xfd_power_limit = 8.5 ;
float xfd_temp_limit = 8.5 ;
float TGenh = 0.0 ;
int vrgf_bwctrl = 0 ;
int ref_in_scan_flag = 0 ;
int refless_option = 1 ;
int ref_dda = 0 ;
int scan_dda = 0 ;
int pc_enh = 0 ;
int ref_volrecvcoil_flag = 0 ;
int hopc_flag = 0 ;
int diff_order_flag = 0 ;
int diff_order_debug = 0;
int diff_order_verify = 0;
int diff_order_nslices = 0;
int diff_order_size = 0;
int diff_pass_counter = 0;
int diff_pass_counter_save = 0;
int skip_ir = 0;
int num_iters = 0 ;
float dti_dse_ecoon_scaling_factor = 1.07;
float dti_sse_ecoon_scaling_factor = 1.03;
float dti_sse_ecooff_scaling_factor = 1.0175;
float dwi_single_all_dse_ecoon_scaling_factor = 1.04;
float dwi_single_all_sse_ecoon_scaling_factor = 1.01;
float dwi_3in1_dse_ecoon_scaling_factor = 1.03;
int k15_system_flag = 0 ;
int hoecc_flag = 0 ;
int hoecc_psd_flag = 0 ;
int hoecc_recon_flag = 0 ;
int hoecc_debug = 0 ;
int hoecc_support = 0 ;
int hoecc_enable = 0 ;
int necho_before_te = 0 ;
int psd_per_echo_corr = 1 ;
int read_corr_option = 1 ;
int psd_debug_echo_index = -1 ;
int psd_echo_for_debug = 0;
int psd_ileave_for_debug = 0;
int psd_slice_for_debug = 0;
float hoec_cal_data_sign = 1.0 ;
int hoecc_manual_mode_warning_flag = 0 ;
int hoecc_manual_mode_psd_override_flag = 0 ;
int muse_flag = 0 ;
int muse_support = 0 ;
float epi_srderate_factor = 1.0;
int epi_loggrd_glim_flag = 0;
float epi_loggrd_glim = 0.0;
int adaptive_mpg_glim_flag = 0;
float adaptive_mpg_glim = 0.0;
int avmaxpasses = 150 +10 ;
int nav_image_interval = 0;
int focus_B0_robust_mode = 0 ;
float focus_unwanted_delta_f = 440 ;
int eco_mpg_support = 0 ;
int eco_mpg_flag = 0 ;
int mpg_opt_flag = 0 ;
int dse_enh_flag = 0 ;
int dse_opt_flag = 0 ;
int bval_arbitrary_flag = 0 ;
float pw_d1 = 0.0 ;
float pw_d2 = 0.0 ;
float b_tol = 0.015 ;
int mpg_opt_margin = 200 ;
float mpg_opt_derate = 1.0 ;
float mpg_opt_glimit_orig = 2.8 ;
int fskillercycling = 0 ;
int nav_type = 0 ;
int nav_sr = 10 ;
float nav_window = 2.0 ;
int navigator_flag = 0 ;
int nav_ss = 3 ;
int nav_dda = 48 ;
int nav_pause_after_prescan = 0 ;
int enhanced_nav_flag = 1 ;
int skip_navigator_prescan = 0 ;
int nav_test = 0 ;
int nav_alg = 3 ;
int nav_dir = 1 ;
int nav_channel = -3 ;
int nav_coilsel_index = 2 ;
int nav_normalization = 1 ;
int mon_navgs = 1;
int hist_wait_time = 1000000 ;
int nav_dump_time = 1000000 ;
float curr_eff = 0.3 ;
float monrot_phi = -45.0 ;
int navtrig_flag = 0 ;
int navgate_flag = 0 ;
int calc_rate = 0 ;
int num_slice_rr = 1 ;
int nav_prescan_tr = 200000 ;
int nav_coilsel_tr = 200000 ;
int mon_tr_nav = 20000 ;
int mon_tr_wait = 100000 ;
int navtrig_target_tr = 200000 ;
int navgate_target_tr = 20000 ;
int wait_pts = 3 ;
int navtrig_waittime = 500000 ;
float navtrig_factor = 0.5 ;
int nav_scantime_refresh = 1000000 ;
int nav_scantime_refresh_pts = 5 ;
int nav_save_raw_data = 0 ;
int nav_debug_flag = 0 ;
int nav_timing_flag = 0 ;
int navigatorCYL_flag = 0 ;
int tlead_cylnav = 200 ;
int navsat_flag = 0 ;
float flip_rfcylr_navsat = 90.0 ;
float flip_rfmon_navsat = 90.0 ;
float navscale = 1.0 ;
float flip_rfcylr = 30.0 ;
float flip_rfcylrtipup = 120.0 ;
float cylr_xoff = 0.0 ;
float cylr_yoff = 0.0 ;
int cylr_manoff = 0 ;
float cylr_skew = 1.0 ;
float cylr_dtheta = 0.0 ;
int act_te_cylr = 0;
int t_exa_cylr = 0 ;
int t_exb_cylr = 0 ;
int t_rdb_cylr = 0 ;
int rtp_mode_for_nav_dynaplan = 1 ;
  float a_gxwksp = 0;
  int ia_gxwksp = 0;
  int pw_gxwkspa = 0;
  int pw_gxwkspd = 0;
  int pw_gxwksp = 0;
  int wg_gxwksp = 0;
  float a_gywksp = 0;
  int ia_gywksp = 0;
  int pw_gywkspa = 0;
  int pw_gywkspd = 0;
  int pw_gywksp = 0;
  int wg_gywksp = 0;
  float a_gzwksp = 0;
  int ia_gzwksp = 0;
  int pw_gzwkspa = 0;
  int pw_gzwkspd = 0;
  int pw_gzwksp = 0;
  int wg_gzwksp = 0;
  float a_gyex1 = 0;
  int ia_gyex1 = 0;
  int pw_gyex1a = 0;
  int pw_gyex1d = 0;
  int pw_gyex1 = 0;
  int wg_gyex1 = 0;
    int res_omthrf2 = 0 ;
    int res_omthrf2left = 0 ;
    int res_omthrf2right = 0 ;
  int res_rf2_gradient_waveform = 0;
  int wg_rf2_gradient_waveform = 0;
  int ia_dynr1 = 0;
  int pw_x_td0 = 0;
  int wg_x_td0 = 0;
  int pw_y_td0 = 0;
  int wg_y_td0 = 0;
  int pw_z_td0 = 0;
  int wg_z_td0 = 0;
  int pw_rho_td0 = 0;
  int wg_rho_td0 = 0;
  int pw_theta_td0 = 0;
  int wg_theta_td0 = 0;
  int pw_omega_td0 = 0;
  int wg_omega_td0 = 0;
  int pw_ssp_td0 = 0;
  int wg_ssp_td0 = 0;
    float a_gzrf1 = 0;
    int ia_gzrf1 = 0;
    int pw_gzrf1a = 0;
    int pw_gzrf1d = 0;
    int pw_gzrf1 = 0;
    int res_gzrf1 = 0;
    float a_rf1 = 0;
    int ia_rf1 = 0;
    int pw_rf1 = 0;
    int res_rf1 = 0;
    float cyc_rf1 = 0;
    int off_rf1 = 0;
    float alpha_rf1 = 0.46;
    float thk_rf1 = 0;
    float gscale_rf1 = 1.0;
    float flip_rf1 = 0;
    float a_thetarf1 = 0;
    int ia_thetarf1 = 0;
    int pw_thetarf1 = 0;
    int res_thetarf1 = 0;
    int off_thetarf1 = 0;
    int wg_rf1 = TYPRHO1
;
  float a_gzrf2 = 0;
  int ia_gzrf2 = 0;
  int pw_gzrf2a = 0;
  int pw_gzrf2d = 0;
  int pw_gzrf2 = 0;
  float a_rf2 = 0;
  int ia_rf2 = 0;
  int pw_rf2 = 0;
  int res_rf2 = 0;
  float cyc_rf2 = 0;
  int off_rf2 = 0;
  float alpha_rf2 = 0.46;
  float thk_rf2 = 0;
  float gscale_rf2 = 1.0;
  float flip_rf2 = 0;
  int wg_rf2 = TYPRHO1
;
  float a_gzrf2left = 0;
  int ia_gzrf2left = 0;
  int pw_gzrf2lefta = 0;
  int pw_gzrf2leftd = 0;
  int pw_gzrf2left = 0;
  float a_rf2left = 0;
  int ia_rf2left = 0;
  int pw_rf2left = 0;
  int res_rf2left = 0;
  float cyc_rf2left = 0;
  int off_rf2left = 0;
  float alpha_rf2left = 0.46;
  float thk_rf2left = 0;
  float gscale_rf2left = 1.0;
  float flip_rf2left = 0;
  int wg_rf2left = TYPRHO1
;
  float a_gzrf2right = 0;
  int ia_gzrf2right = 0;
  int pw_gzrf2righta = 0;
  int pw_gzrf2rightd = 0;
  int pw_gzrf2right = 0;
  float a_rf2right = 0;
  int ia_rf2right = 0;
  int pw_rf2right = 0;
  int res_rf2right = 0;
  float cyc_rf2right = 0;
  int off_rf2right = 0;
  float alpha_rf2right = 0.46;
  float thk_rf2right = 0;
  float gscale_rf2right = 1.0;
  float flip_rf2right = 0;
  int wg_rf2right = TYPRHO1
;
  int res_rf2se1b4 = 0;
  int wg_rf2se1b4 = 0;
  float a_gyrf2iv = 0;
  int ia_gyrf2iv = 0;
  int pw_gyrf2iva = 0;
  int pw_gyrf2ivd = 0;
  int pw_gyrf2iv = 0;
  int wg_gyrf2iv = 0;
  float a_gzrf2l1 = 0;
  int ia_gzrf2l1 = 0;
  int pw_gzrf2l1a = 0;
  int pw_gzrf2l1d = 0;
  int pw_gzrf2l1 = 0;
  int wg_gzrf2l1 = 0;
  float a_gzrf2r1 = 0;
  int ia_gzrf2r1 = 0;
  int pw_gzrf2r1a = 0;
  int pw_gzrf2r1d = 0;
  int pw_gzrf2r1 = 0;
  int wg_gzrf2r1 = 0;
  float a_xgradCrusherL = 0;
  int ia_xgradCrusherL = 0;
  int pw_xgradCrusherLa = 0;
  int pw_xgradCrusherLd = 0;
  int pw_xgradCrusherL = 0;
  int wg_xgradCrusherL = 0;
  float a_xgradCrusherR = 0;
  int ia_xgradCrusherR = 0;
  int pw_xgradCrusherRa = 0;
  int pw_xgradCrusherRd = 0;
  int pw_xgradCrusherR = 0;
  int wg_xgradCrusherR = 0;
  float a_ygradCrusherL = 0;
  int ia_ygradCrusherL = 0;
  int pw_ygradCrusherLa = 0;
  int pw_ygradCrusherLd = 0;
  int pw_ygradCrusherL = 0;
  int wg_ygradCrusherL = 0;
  float a_ygradCrusherR = 0;
  int ia_ygradCrusherR = 0;
  int pw_ygradCrusherRa = 0;
  int pw_ygradCrusherRd = 0;
  int pw_ygradCrusherR = 0;
  int wg_ygradCrusherR = 0;
  float a_gzrf2leftl1 = 0;
  int ia_gzrf2leftl1 = 0;
  int pw_gzrf2leftl1a = 0;
  int pw_gzrf2leftl1d = 0;
  int pw_gzrf2leftl1 = 0;
  int wg_gzrf2leftl1 = 0;
  float a_gzrf2leftr1 = 0;
  int ia_gzrf2leftr1 = 0;
  int pw_gzrf2leftr1a = 0;
  int pw_gzrf2leftr1d = 0;
  int pw_gzrf2leftr1 = 0;
  int wg_gzrf2leftr1 = 0;
  float a_gzrf2rightl1 = 0;
  int ia_gzrf2rightl1 = 0;
  int pw_gzrf2rightl1a = 0;
  int pw_gzrf2rightl1d = 0;
  int pw_gzrf2rightl1 = 0;
  int wg_gzrf2rightl1 = 0;
  float a_gzrf2rightr1 = 0;
  int ia_gzrf2rightr1 = 0;
  int pw_gzrf2rightr1a = 0;
  int pw_gzrf2rightr1d = 0;
  int pw_gzrf2rightr1 = 0;
  int wg_gzrf2rightr1 = 0;
  float a_xgradRightCrusherL = 0;
  int ia_xgradRightCrusherL = 0;
  int pw_xgradRightCrusherLa = 0;
  int pw_xgradRightCrusherLd = 0;
  int pw_xgradRightCrusherL = 0;
  int wg_xgradRightCrusherL = 0;
  float a_xgradRightCrusherR = 0;
  int ia_xgradRightCrusherR = 0;
  int pw_xgradRightCrusherRa = 0;
  int pw_xgradRightCrusherRd = 0;
  int pw_xgradRightCrusherR = 0;
  int wg_xgradRightCrusherR = 0;
  float a_ygradRightCrusherL = 0;
  int ia_ygradRightCrusherL = 0;
  int pw_ygradRightCrusherLa = 0;
  int pw_ygradRightCrusherLd = 0;
  int pw_ygradRightCrusherL = 0;
  int wg_ygradRightCrusherL = 0;
  float a_ygradRightCrusherR = 0;
  int ia_ygradRightCrusherR = 0;
  int pw_ygradRightCrusherRa = 0;
  int pw_ygradRightCrusherRd = 0;
  int pw_ygradRightCrusherR = 0;
  int wg_ygradRightCrusherR = 0;
  float a_xgradLeftCrusherL = 0;
  int ia_xgradLeftCrusherL = 0;
  int pw_xgradLeftCrusherLa = 0;
  int pw_xgradLeftCrusherLd = 0;
  int pw_xgradLeftCrusherL = 0;
  int wg_xgradLeftCrusherL = 0;
  float a_xgradLeftCrusherR = 0;
  int ia_xgradLeftCrusherR = 0;
  int pw_xgradLeftCrusherRa = 0;
  int pw_xgradLeftCrusherRd = 0;
  int pw_xgradLeftCrusherR = 0;
  int wg_xgradLeftCrusherR = 0;
  float a_ygradLeftCrusherL = 0;
  int ia_ygradLeftCrusherL = 0;
  int pw_ygradLeftCrusherLa = 0;
  int pw_ygradLeftCrusherLd = 0;
  int pw_ygradLeftCrusherL = 0;
  int wg_ygradLeftCrusherL = 0;
  float a_ygradLeftCrusherR = 0;
  int ia_ygradLeftCrusherR = 0;
  int pw_ygradLeftCrusherRa = 0;
  int pw_ygradLeftCrusherRd = 0;
  int pw_ygradLeftCrusherR = 0;
  int wg_ygradLeftCrusherR = 0;
    float a_gxcl = 0;
    float a_gxw = 0;
    float a_gxcr = 0;
    float a_gyb = 0;
    float a_gzb = 0;
    int ia_gxcl = 0;
    int ia_gxw = 0;
    int ia_gxcr = 0;
    int ia_gyb = 0;
    int ia_gzb = 0;
    int pw_gxcla = 0;
    int pw_gxcl = 0;
    int pw_gxcld = 0;
    int pw_gxwl = 0;
    int pw_gxw = 0;
    int pw_gxwr = 0;
    int pw_gxwad = 0;
    int pw_gxgap = 0;
    int pw_gxcra = 0;
    int pw_gxcr = 0;
    int pw_gxcrd = 0;
    int pw_gyba = 0;
    int pw_gyb = 0;
    int pw_gybd = 0;
    int pw_gzba = 0;
    int pw_gzb = 0;
    int pw_gzbd = 0;
    int pw_iref_gxwait = 0;
  int ia_rec_unblank = 0;
  int ia_rec_unblank3 = 0;
  int filter_rtb0echo = 0;
  int ia_rec_unblank2 = 0;
  float a_gxiref1 = 0;
  int ia_gxiref1 = 0;
  int pw_gxiref1a = 0;
  int pw_gxiref1d = 0;
  int pw_gxiref1 = 0;
  int wg_gxiref1 = 0;
  float a_gxirefr = 0;
  int ia_gxirefr = 0;
  int pw_gxirefra = 0;
  int pw_gxirefrd = 0;
  int pw_gxirefr = 0;
  int wg_gxirefr = 0;
  float a_gy1 = 0;
  float a_gy1a = 0;
  float a_gy1b = 0;
  int ia_gy1 = 0;
  int ia_gy1wa = 0;
  int ia_gy1wb = 0;
  int pw_gy1a = 0;
  int pw_gy1d = 0;
  int pw_gy1 = 0;
  int wg_gy1 = 0;
  float a_gymn2 = 0;
  int ia_gymn2 = 0;
  int pw_gymn2a = 0;
  int pw_gymn2d = 0;
  int pw_gymn2 = 0;
  int wg_gymn2 = 0;
  float a_gymn1 = 0;
  int ia_gymn1 = 0;
  int pw_gymn1a = 0;
  int pw_gymn1d = 0;
  int pw_gymn1 = 0;
  int wg_gymn1 = 0;
  float a_gz1 = 0;
  int ia_gz1 = 0;
  int pw_gz1a = 0;
  int pw_gz1d = 0;
  int pw_gz1 = 0;
  int wg_gz1 = 0;
  float a_gzmn = 0;
  int ia_gzmn = 0;
  int pw_gzmna = 0;
  int pw_gzmnd = 0;
  int pw_gzmn = 0;
  int wg_gzmn = 0;
  int res_rf2se1 = 0;
  int wg_rf2se1 = 0;
  float a_gxde = 0;
  int ia_gxde = 0;
  int pw_gxdea = 0;
  int pw_gxded = 0;
  int pw_gxde = 0;
  int wg_gxde = 0;
  float a_gxdl = 0;
  int ia_gxdl = 0;
  int pw_gxdla = 0;
  int pw_gxdld = 0;
  int pw_gxdl = 0;
  int wg_gxdl = 0;
  float a_gxdr = 0;
  int ia_gxdr = 0;
  int pw_gxdra = 0;
  int pw_gxdrd = 0;
  int pw_gxdr = 0;
  int wg_gxdr = 0;
  float a_gxdl1 = 0;
  int ia_gxdl1 = 0;
  int pw_gxdl1a = 0;
  int pw_gxdl1d = 0;
  int pw_gxdl1 = 0;
  int wg_gxdl1 = 0;
  float a_gxdr1 = 0;
  int ia_gxdr1 = 0;
  int pw_gxdr1a = 0;
  int pw_gxdr1d = 0;
  int pw_gxdr1 = 0;
  int wg_gxdr1 = 0;
  float a_gxdl2 = 0;
  int ia_gxdl2 = 0;
  int pw_gxdl2a = 0;
  int pw_gxdl2d = 0;
  int pw_gxdl2 = 0;
  int wg_gxdl2 = 0;
  float a_gxdr2 = 0;
  int ia_gxdr2 = 0;
  int pw_gxdr2a = 0;
  int pw_gxdr2d = 0;
  int pw_gxdr2 = 0;
  int wg_gxdr2 = 0;
  float a_gxk = 0;
  int ia_gxk = 0;
  int pw_gxka = 0;
  int pw_gxkd = 0;
  int pw_gxk = 0;
  int wg_gxk = 0;
  float a_gyde = 0;
  int ia_gyde = 0;
  int pw_gydea = 0;
  int pw_gyded = 0;
  int pw_gyde = 0;
  int wg_gyde = 0;
  float a_gydl = 0;
  int ia_gydl = 0;
  int pw_gydla = 0;
  int pw_gydld = 0;
  int pw_gydl = 0;
  int wg_gydl = 0;
  float a_gydr = 0;
  int ia_gydr = 0;
  int pw_gydra = 0;
  int pw_gydrd = 0;
  int pw_gydr = 0;
  int wg_gydr = 0;
  float a_gydl1 = 0;
  int ia_gydl1 = 0;
  int pw_gydl1a = 0;
  int pw_gydl1d = 0;
  int pw_gydl1 = 0;
  int wg_gydl1 = 0;
  float a_gydr1 = 0;
  int ia_gydr1 = 0;
  int pw_gydr1a = 0;
  int pw_gydr1d = 0;
  int pw_gydr1 = 0;
  int wg_gydr1 = 0;
  float a_gydl2 = 0;
  int ia_gydl2 = 0;
  int pw_gydl2a = 0;
  int pw_gydl2d = 0;
  int pw_gydl2 = 0;
  int wg_gydl2 = 0;
  float a_gydr2 = 0;
  int ia_gydr2 = 0;
  int pw_gydr2a = 0;
  int pw_gydr2d = 0;
  int pw_gydr2 = 0;
  int wg_gydr2 = 0;
  float a_gyk = 0;
  int ia_gyk = 0;
  int pw_gyka = 0;
  int pw_gykd = 0;
  int pw_gyk = 0;
  int wg_gyk = 0;
  float a_gzde = 0;
  int ia_gzde = 0;
  int pw_gzdea = 0;
  int pw_gzded = 0;
  int pw_gzde = 0;
  int wg_gzde = 0;
  float a_gzdl = 0;
  int ia_gzdl = 0;
  int pw_gzdla = 0;
  int pw_gzdld = 0;
  int pw_gzdl = 0;
  int wg_gzdl = 0;
  float a_gzdr = 0;
  int ia_gzdr = 0;
  int pw_gzdra = 0;
  int pw_gzdrd = 0;
  int pw_gzdr = 0;
  int wg_gzdr = 0;
  float a_gzdl1 = 0;
  int ia_gzdl1 = 0;
  int pw_gzdl1a = 0;
  int pw_gzdl1d = 0;
  int pw_gzdl1 = 0;
  int wg_gzdl1 = 0;
  float a_gzdr1 = 0;
  int ia_gzdr1 = 0;
  int pw_gzdr1a = 0;
  int pw_gzdr1d = 0;
  int pw_gzdr1 = 0;
  int wg_gzdr1 = 0;
  float a_gzdl2 = 0;
  int ia_gzdl2 = 0;
  int pw_gzdl2a = 0;
  int pw_gzdl2d = 0;
  int pw_gzdl2 = 0;
  int wg_gzdl2 = 0;
  float a_gzdr2 = 0;
  int ia_gzdr2 = 0;
  int pw_gzdr2a = 0;
  int pw_gzdr2d = 0;
  int pw_gzdr2 = 0;
  int wg_gzdr2 = 0;
  float a_gzk = 0;
  int ia_gzk = 0;
  int pw_gzka = 0;
  int pw_gzkd = 0;
  int pw_gzk = 0;
  int wg_gzk = 0;
  int pw_wgx = 0;
  int wg_wgx = 0;
  int pw_wgy = 0;
  int wg_wgy = 0;
  int pw_wgz = 0;
  int wg_wgz = 0;
  int pw_wssp = 0;
  int wg_wssp = 0;
  int pw_sspdelay = 0;
  int wg_sspdelay = 0;
  int pw_omegadelay = 0;
  int wg_omegadelay = 0;
  int pw_womega = 0;
  int wg_womega = 0;
  int pw_sspshift = 0;
  int wg_sspshift = 0;
  int pw_ssp_pass_delay = 0;
  int wg_ssp_pass_delay = 0;
  float a_gzrf0 = 0;
  int ia_gzrf0 = 0;
  int pw_gzrf0a = 0;
  int pw_gzrf0d = 0;
  int pw_gzrf0 = 0;
  int res_gzrf0 = 0;
  float a_rf0 = 0;
  int ia_rf0 = 0;
  int pw_rf0 = 0;
  int res_rf0 = 0;
  float cyc_rf0 = 0;
  int off_rf0 = 0;
  float alpha_rf0 = 0.46;
  float thk_rf0 = 0;
  float gscale_rf0 = 1.0;
  float flip_rf0 = 0;
  int wg_rf0 = TYPRHO1
;
  float a_omegarf0 = 0;
  int ia_omegarf0 = 0;
  int pw_omegarf0 = 0;
  int res_omegarf0 = 0;
  int off_omegarf0 = 0;
  int rfslot_omegarf0 = 0;
  float gscale_omegarf0 = 1.0;
  int n_omegarf0 = 0;
  int wg_omegarf0 = 0;
  float a_gyk0 = 0;
  int ia_gyk0 = 0;
  int pw_gyk0a = 0;
  int pw_gyk0d = 0;
  int pw_gyk0 = 0;
  int wg_gyk0 = 0;
  int ia_bline_unblank = 0;
  int filter_blineacq1 = 0;
  int res_rfcssat = 0;
  int wg_rfcssat = 0;
  float a_dbgxrfcssat = 0;
  int ia_dbgxrfcssat = 0;
  int pw_dbgxrfcssata = 0;
  int pw_dbgxrfcssatd = 0;
  int pw_dbgxrfcssat = 0;
  int wg_dbgxrfcssat = 0;
  float a_dbgyrfcssat = 0;
  int ia_dbgyrfcssat = 0;
  int pw_dbgyrfcssata = 0;
  int pw_dbgyrfcssatd = 0;
  int pw_dbgyrfcssat = 0;
  int wg_dbgyrfcssat = 0;
  float a_dbgzrfcssat = 0;
  int ia_dbgzrfcssat = 0;
  int pw_dbgzrfcssata = 0;
  int pw_dbgzrfcssatd = 0;
  int pw_dbgzrfcssat = 0;
  int wg_dbgzrfcssat = 0;
  int res_omega_hs_rfcssat = 0;
  int wg_omega_hs_rfcssat = 0;
  float a_gzrfcs = 0;
  int ia_gzrfcs = 0;
  int pw_gzrfcsa = 0;
  int pw_gzrfcsd = 0;
  int pw_gzrfcs = 0;
  int wg_gzrfcs = 0;
  float a_gykcs = 0;
  int ia_gykcs = 0;
  int pw_gykcsa = 0;
  int pw_gykcsd = 0;
  int pw_gykcs = 0;
  int wg_gykcs = 0;
  float a_gxkcs = 0;
  int ia_gxkcs = 0;
  int pw_gxkcsa = 0;
  int pw_gxkcsd = 0;
  int pw_gxkcs = 0;
  int wg_gxkcs = 0;
  float a_gzkcs = 0;
  int ia_gzkcs = 0;
  int pw_gzkcsa = 0;
  int pw_gzkcsd = 0;
  int pw_gzkcs = 0;
  int wg_gzkcs = 0;
  int pw_isi_cardiacsat = 0;
  int wg_isi_cardiacsat = 0;
  int pw_rot_update_cardiacsat = 0;
  int wg_rot_update_cardiacsat = 0;
  float a_gzrfse1 = 0;
  int ia_gzrfse1 = 0;
  int pw_gzrfse1a = 0;
  int pw_gzrfse1d = 0;
  int pw_gzrfse1 = 0;
  float a_rfse1 = 0;
  int ia_rfse1 = 0;
  int pw_rfse1 = 0;
  int res_rfse1 = 0;
  int temp_res_rfse1 = 0;
  float cyc_rfse1 = 0;
  int off_rfse1 = 0;
  float alpha_rfse1 = 0.46;
  float thk_rfse1 = 0;
  float gscale_rfse1 = 1.0;
  float flip_rfse1 = 0;
  int wg_rfse1 = TYPRHO1
;
  int pw_isi_sate1 = 0;
  int wg_isi_sate1 = 0;
  int pw_rot_update_e1 = 0;
  int wg_rot_update_e1 = 0;
  float a_gykse1 = 0;
  int ia_gykse1 = 0;
  int pw_gykse1a = 0;
  int pw_gykse1d = 0;
  int pw_gykse1 = 0;
  int wg_gykse1 = 0;
  float a_gxkse1 = 0;
  int ia_gxkse1 = 0;
  int pw_gxkse1a = 0;
  int pw_gxkse1d = 0;
  int pw_gxkse1 = 0;
  int wg_gxkse1 = 0;
  int pw_isi_satek1 = 0;
  int wg_isi_satek1 = 0;
  int pw_rot_update_ek1 = 0;
  int wg_rot_update_ek1 = 0;
  float a_gzrfse2 = 0;
  int ia_gzrfse2 = 0;
  int pw_gzrfse2a = 0;
  int pw_gzrfse2d = 0;
  int pw_gzrfse2 = 0;
  float a_rfse2 = 0;
  int ia_rfse2 = 0;
  int pw_rfse2 = 0;
  int res_rfse2 = 0;
  int temp_res_rfse2 = 0;
  float cyc_rfse2 = 0;
  int off_rfse2 = 0;
  float alpha_rfse2 = 0.46;
  float thk_rfse2 = 0;
  float gscale_rfse2 = 1.0;
  float flip_rfse2 = 0;
  int wg_rfse2 = TYPRHO1
;
  int pw_isi_sate2 = 0;
  int wg_isi_sate2 = 0;
  int pw_rot_update_e2 = 0;
  int wg_rot_update_e2 = 0;
  float a_gykse2 = 0;
  int ia_gykse2 = 0;
  int pw_gykse2a = 0;
  int pw_gykse2d = 0;
  int pw_gykse2 = 0;
  int wg_gykse2 = 0;
  float a_gxkse2 = 0;
  int ia_gxkse2 = 0;
  int pw_gxkse2a = 0;
  int pw_gxkse2d = 0;
  int pw_gxkse2 = 0;
  int wg_gxkse2 = 0;
  int pw_isi_satek2 = 0;
  int wg_isi_satek2 = 0;
  int pw_rot_update_ek2 = 0;
  int wg_rot_update_ek2 = 0;
  float a_gzrfse3 = 0;
  int ia_gzrfse3 = 0;
  int pw_gzrfse3a = 0;
  int pw_gzrfse3d = 0;
  int pw_gzrfse3 = 0;
  float a_rfse3 = 0;
  int ia_rfse3 = 0;
  int pw_rfse3 = 0;
  int res_rfse3 = 0;
  int temp_res_rfse3 = 0;
  float cyc_rfse3 = 0;
  int off_rfse3 = 0;
  float alpha_rfse3 = 0.46;
  float thk_rfse3 = 0;
  float gscale_rfse3 = 1.0;
  float flip_rfse3 = 0;
  int wg_rfse3 = TYPRHO1
;
  int pw_isi_sate3 = 0;
  int wg_isi_sate3 = 0;
  int pw_rot_update_e3 = 0;
  int wg_rot_update_e3 = 0;
  float a_gykse3 = 0;
  int ia_gykse3 = 0;
  int pw_gykse3a = 0;
  int pw_gykse3d = 0;
  int pw_gykse3 = 0;
  int wg_gykse3 = 0;
  float a_gxkse3 = 0;
  int ia_gxkse3 = 0;
  int pw_gxkse3a = 0;
  int pw_gxkse3d = 0;
  int pw_gxkse3 = 0;
  int wg_gxkse3 = 0;
  int pw_isi_satek3 = 0;
  int wg_isi_satek3 = 0;
  int pw_rot_update_ek3 = 0;
  int wg_rot_update_ek3 = 0;
  float a_gzrfse4 = 0;
  int ia_gzrfse4 = 0;
  int pw_gzrfse4a = 0;
  int pw_gzrfse4d = 0;
  int pw_gzrfse4 = 0;
  float a_rfse4 = 0;
  int ia_rfse4 = 0;
  int pw_rfse4 = 0;
  int res_rfse4 = 0;
  int temp_res_rfse4 = 0;
  float cyc_rfse4 = 0;
  int off_rfse4 = 0;
  float alpha_rfse4 = 0.46;
  float thk_rfse4 = 0;
  float gscale_rfse4 = 1.0;
  float flip_rfse4 = 0;
  int wg_rfse4 = TYPRHO1
;
  int pw_isi_sate4 = 0;
  int wg_isi_sate4 = 0;
  int pw_rot_update_e4 = 0;
  int wg_rot_update_e4 = 0;
  float a_gykse4 = 0;
  int ia_gykse4 = 0;
  int pw_gykse4a = 0;
  int pw_gykse4d = 0;
  int pw_gykse4 = 0;
  int wg_gykse4 = 0;
  float a_gxkse4 = 0;
  int ia_gxkse4 = 0;
  int pw_gxkse4a = 0;
  int pw_gxkse4d = 0;
  int pw_gxkse4 = 0;
  int wg_gxkse4 = 0;
  int pw_isi_satek4 = 0;
  int wg_isi_satek4 = 0;
  int pw_rot_update_ek4 = 0;
  int wg_rot_update_ek4 = 0;
  float a_gzrfse5 = 0;
  int ia_gzrfse5 = 0;
  int pw_gzrfse5a = 0;
  int pw_gzrfse5d = 0;
  int pw_gzrfse5 = 0;
  float a_rfse5 = 0;
  int ia_rfse5 = 0;
  int pw_rfse5 = 0;
  int res_rfse5 = 0;
  int temp_res_rfse5 = 0;
  float cyc_rfse5 = 0;
  int off_rfse5 = 0;
  float alpha_rfse5 = 0.46;
  float thk_rfse5 = 0;
  float gscale_rfse5 = 1.0;
  float flip_rfse5 = 0;
  int wg_rfse5 = TYPRHO1
;
  int pw_isi_sate5 = 0;
  int wg_isi_sate5 = 0;
  int pw_rot_update_e5 = 0;
  int wg_rot_update_e5 = 0;
  float a_gykse5 = 0;
  int ia_gykse5 = 0;
  int pw_gykse5a = 0;
  int pw_gykse5d = 0;
  int pw_gykse5 = 0;
  int wg_gykse5 = 0;
  float a_gxkse5 = 0;
  int ia_gxkse5 = 0;
  int pw_gxkse5a = 0;
  int pw_gxkse5d = 0;
  int pw_gxkse5 = 0;
  int wg_gxkse5 = 0;
  int pw_isi_satek5 = 0;
  int wg_isi_satek5 = 0;
  int pw_rot_update_ek5 = 0;
  int wg_rot_update_ek5 = 0;
  float a_gzrfse6 = 0;
  int ia_gzrfse6 = 0;
  int pw_gzrfse6a = 0;
  int pw_gzrfse6d = 0;
  int pw_gzrfse6 = 0;
  float a_rfse6 = 0;
  int ia_rfse6 = 0;
  int pw_rfse6 = 0;
  int res_rfse6 = 0;
  int temp_res_rfse6 = 0;
  float cyc_rfse6 = 0;
  int off_rfse6 = 0;
  float alpha_rfse6 = 0.46;
  float thk_rfse6 = 0;
  float gscale_rfse6 = 1.0;
  float flip_rfse6 = 0;
  int wg_rfse6 = TYPRHO1
;
  int pw_isi_sate6 = 0;
  int wg_isi_sate6 = 0;
  int pw_rot_update_e6 = 0;
  int wg_rot_update_e6 = 0;
  float a_gykse6 = 0;
  int ia_gykse6 = 0;
  int pw_gykse6a = 0;
  int pw_gykse6d = 0;
  int pw_gykse6 = 0;
  int wg_gykse6 = 0;
  float a_gxkse6 = 0;
  int ia_gxkse6 = 0;
  int pw_gxkse6a = 0;
  int pw_gxkse6d = 0;
  int pw_gxkse6 = 0;
  int wg_gxkse6 = 0;
  int pw_isi_satek6 = 0;
  int wg_isi_satek6 = 0;
  int pw_rot_update_ek6 = 0;
  int wg_rot_update_ek6 = 0;
  float a_gxrfsx1 = 0;
  int ia_gxrfsx1 = 0;
  int pw_gxrfsx1a = 0;
  int pw_gxrfsx1d = 0;
  int pw_gxrfsx1 = 0;
  float a_rfsx1 = 0;
  int ia_rfsx1 = 0;
  int pw_rfsx1 = 0;
  int res_rfsx1 = 0;
  int temp_res_rfsx1 = 0;
  float cyc_rfsx1 = 0;
  int off_rfsx1 = 0;
  float alpha_rfsx1 = 0.46;
  float gscale_rfsx1 = 1.0;
  float thk_rfsx1 = 0;
  float flip_rfsx1 = 0;
  int wg_rfsx1 = TYPRHO1
;
  int pw_isi_satx1 = 0;
  int wg_isi_satx1 = 0;
  int pw_rot_update_x1 = 0;
  int wg_rot_update_x1 = 0;
  float a_gyksx1 = 0;
  int ia_gyksx1 = 0;
  int pw_gyksx1a = 0;
  int pw_gyksx1d = 0;
  int pw_gyksx1 = 0;
  int wg_gyksx1 = 0;
  float a_gxksx1 = 0;
  int ia_gxksx1 = 0;
  int pw_gxksx1a = 0;
  int pw_gxksx1d = 0;
  int pw_gxksx1 = 0;
  int wg_gxksx1 = 0;
  int pw_isi_satxk1 = 0;
  int wg_isi_satxk1 = 0;
  int pw_rot_update_xk1 = 0;
  int wg_rot_update_xk1 = 0;
  float a_gxrfsx2 = 0;
  int ia_gxrfsx2 = 0;
  int pw_gxrfsx2a = 0;
  int pw_gxrfsx2d = 0;
  int pw_gxrfsx2 = 0;
  float a_rfsx2 = 0;
  int ia_rfsx2 = 0;
  int pw_rfsx2 = 0;
  int res_rfsx2 = 0;
  int temp_res_rfsx2 = 0;
  float cyc_rfsx2 = 0;
  int off_rfsx2 = 0;
  float alpha_rfsx2 = 0.46;
  float gscale_rfsx2 = 1.0;
  float thk_rfsx2 = 0;
  float flip_rfsx2 = 0;
  int wg_rfsx2 = TYPRHO1
;
  int pw_isi_satx2 = 0;
  int wg_isi_satx2 = 0;
  int pw_rot_update_x2 = 0;
  int wg_rot_update_x2 = 0;
  float a_gyksx2 = 0;
  int ia_gyksx2 = 0;
  int pw_gyksx2a = 0;
  int pw_gyksx2d = 0;
  int pw_gyksx2 = 0;
  int wg_gyksx2 = 0;
  float a_gxksx2 = 0;
  int ia_gxksx2 = 0;
  int pw_gxksx2a = 0;
  int pw_gxksx2d = 0;
  int pw_gxksx2 = 0;
  int wg_gxksx2 = 0;
  int pw_isi_satxk2 = 0;
  int wg_isi_satxk2 = 0;
  int pw_rot_update_xk2 = 0;
  int wg_rot_update_xk2 = 0;
  float a_gyrfsy1 = 0;
  int ia_gyrfsy1 = 0;
  int pw_gyrfsy1a = 0;
  int pw_gyrfsy1d = 0;
  int pw_gyrfsy1 = 0;
  float a_rfsy1 = 0;
  int ia_rfsy1 = 0;
  int pw_rfsy1 = 0;
  int res_rfsy1 = 0;
  int temp_res_rfsy1 = 0;
  float cyc_rfsy1 = 0;
  int off_rfsy1 = 0;
  float alpha_rfsy1 = 0.46;
  float thk_rfsy1 = 0;
  float gscale_rfsy1 = 1.0;
  float flip_rfsy1 = 0;
  int wg_rfsy1 = TYPRHO1
;
  int pw_isi_saty1 = 0;
  int wg_isi_saty1 = 0;
  int pw_rot_update_y1 = 0;
  int wg_rot_update_y1 = 0;
  float a_gyksy1 = 0;
  int ia_gyksy1 = 0;
  int pw_gyksy1a = 0;
  int pw_gyksy1d = 0;
  int pw_gyksy1 = 0;
  int wg_gyksy1 = 0;
  float a_gxksy1 = 0;
  int ia_gxksy1 = 0;
  int pw_gxksy1a = 0;
  int pw_gxksy1d = 0;
  int pw_gxksy1 = 0;
  int wg_gxksy1 = 0;
  int pw_isi_satyk1 = 0;
  int wg_isi_satyk1 = 0;
  int pw_rot_update_yk1 = 0;
  int wg_rot_update_yk1 = 0;
  float a_gyrfsy2 = 0;
  int ia_gyrfsy2 = 0;
  int pw_gyrfsy2a = 0;
  int pw_gyrfsy2d = 0;
  int pw_gyrfsy2 = 0;
  float a_rfsy2 = 0;
  int ia_rfsy2 = 0;
  int pw_rfsy2 = 0;
  int res_rfsy2 = 0;
  int temp_res_rfsy2 = 0;
  float cyc_rfsy2 = 0;
  int off_rfsy2 = 0;
  float alpha_rfsy2 = 0.46;
  float thk_rfsy2 = 0;
  float gscale_rfsy2 = 1.0;
  float flip_rfsy2 = 0;
  int wg_rfsy2 = TYPRHO1
;
  int pw_isi_saty2 = 0;
  int wg_isi_saty2 = 0;
  int pw_rot_update_y2 = 0;
  int wg_rot_update_y2 = 0;
  float a_gyksy2 = 0;
  int ia_gyksy2 = 0;
  int pw_gyksy2a = 0;
  int pw_gyksy2d = 0;
  int pw_gyksy2 = 0;
  int wg_gyksy2 = 0;
  float a_gxksy2 = 0;
  int ia_gxksy2 = 0;
  int pw_gxksy2a = 0;
  int pw_gxksy2d = 0;
  int pw_gxksy2 = 0;
  int wg_gxksy2 = 0;
  int pw_isi_satyk2 = 0;
  int wg_isi_satyk2 = 0;
  int pw_rot_update_yk2 = 0;
  int wg_rot_update_yk2 = 0;
  float a_gzrfsz1 = 0;
  int ia_gzrfsz1 = 0;
  int pw_gzrfsz1a = 0;
  int pw_gzrfsz1d = 0;
  int pw_gzrfsz1 = 0;
  float a_rfsz1 = 0;
  int ia_rfsz1 = 0;
  int pw_rfsz1 = 0;
  int res_rfsz1 = 0;
  int temp_res_rfsz1 = 0;
  float cyc_rfsz1 = 0;
  int off_rfsz1 = 0;
  float alpha_rfsz1 = 0.46;
  float thk_rfsz1 = 0;
  float gscale_rfsz1 = 1.0;
  float flip_rfsz1 = 0;
  int wg_rfsz1 = TYPRHO1
;
  int pw_isi_satz1 = 0;
  int wg_isi_satz1 = 0;
  int pw_rot_update_z1 = 0;
  int wg_rot_update_z1 = 0;
  float a_gyksz1 = 0;
  int ia_gyksz1 = 0;
  int pw_gyksz1a = 0;
  int pw_gyksz1d = 0;
  int pw_gyksz1 = 0;
  int wg_gyksz1 = 0;
  float a_gxksz1 = 0;
  int ia_gxksz1 = 0;
  int pw_gxksz1a = 0;
  int pw_gxksz1d = 0;
  int pw_gxksz1 = 0;
  int wg_gxksz1 = 0;
  int pw_isi_satzk1 = 0;
  int wg_isi_satzk1 = 0;
  int pw_rot_update_zk1 = 0;
  int wg_rot_update_zk1 = 0;
  float a_gzrfsz2 = 0;
  int ia_gzrfsz2 = 0;
  int pw_gzrfsz2a = 0;
  int pw_gzrfsz2d = 0;
  int pw_gzrfsz2 = 0;
  float a_rfsz2 = 0;
  int ia_rfsz2 = 0;
  int pw_rfsz2 = 0;
  int res_rfsz2 = 0;
  int temp_res_rfsz2 = 0;
  float cyc_rfsz2 = 0;
  int off_rfsz2 = 0;
  float alpha_rfsz2 = 0.46;
  float thk_rfsz2 = 0;
  float gscale_rfsz2 = 1.0;
  float flip_rfsz2 = 0;
  int wg_rfsz2 = TYPRHO1
;
  int pw_isi_satz2 = 0;
  int wg_isi_satz2 = 0;
  int pw_rot_update_z2 = 0;
  int wg_rot_update_z2 = 0;
  float a_gyksz2 = 0;
  int ia_gyksz2 = 0;
  int pw_gyksz2a = 0;
  int pw_gyksz2d = 0;
  int pw_gyksz2 = 0;
  int wg_gyksz2 = 0;
  float a_gxksz2 = 0;
  int ia_gxksz2 = 0;
  int pw_gxksz2a = 0;
  int pw_gxksz2d = 0;
  int pw_gxksz2 = 0;
  int wg_gxksz2 = 0;
  int pw_isi_satzk2 = 0;
  int wg_isi_satzk2 = 0;
  int pw_rot_update_zk2 = 0;
  int wg_rot_update_zk2 = 0;
  int pw_y_ccs_null = 0;
  int wg_y_ccs_null = 0;
  float a_rf1mps1 = 0;
  int ia_rf1mps1 = 0;
  int pw_rf1mps1 = 0;
  int res_rf1mps1 = 0;
  float cyc_rf1mps1 = 0;
  int off_rf1mps1 = 0;
  float alpha_rf1mps1 = 0;
  int wg_rf1mps1 = 0;
  float a_gyrf1mps1 = 0;
  int ia_gyrf1mps1 = 0;
  int pw_gyrf1mps1a = 0;
  int pw_gyrf1mps1d = 0;
  int pw_gyrf1mps1 = 0;
  int wg_gyrf1mps1 = 0;
  float a_gy1mps1 = 0;
  int ia_gy1mps1 = 0;
  int pw_gy1mps1a = 0;
  int pw_gy1mps1d = 0;
  int pw_gy1mps1 = 0;
  int wg_gy1mps1 = 0;
  float a_gzrf1mps1 = 0;
  int ia_gzrf1mps1 = 0;
  int pw_gzrf1mps1a = 0;
  int pw_gzrf1mps1d = 0;
  int pw_gzrf1mps1 = 0;
  int wg_gzrf1mps1 = 0;
  float a_gz1mps1 = 0;
  int ia_gz1mps1 = 0;
  int pw_gz1mps1a = 0;
  int pw_gz1mps1d = 0;
  int pw_gz1mps1 = 0;
  int wg_gz1mps1 = 0;
  float a_gx1mps1 = 0;
  int ia_gx1mps1 = 0;
  int pw_gx1mps1a = 0;
  int pw_gx1mps1d = 0;
  int pw_gx1mps1 = 0;
  int wg_gx1mps1 = 0;
  float a_gzrf2mps1 = 0;
  int ia_gzrf2mps1 = 0;
  int pw_gzrf2mps1a = 0;
  int pw_gzrf2mps1d = 0;
  int pw_gzrf2mps1 = 0;
  float a_rf2mps1 = 0;
  int ia_rf2mps1 = 0;
  int pw_rf2mps1 = 0;
  int res_rf2mps1 = 0;
  int temp_res_rf2mps1 = 0;
  float cyc_rf2mps1 = 0;
  int off_rf2mps1 = 0;
  float alpha_rf2mps1 = 0.46;
  float thk_rf2mps1 = 0;
  float gscale_rf2mps1 = 1.0;
  float flip_rf2mps1 = 0;
  int wg_rf2mps1 = TYPRHO1
;
  float a_gzrf2lmps1 = 0;
  int ia_gzrf2lmps1 = 0;
  int pw_gzrf2lmps1a = 0;
  int pw_gzrf2lmps1d = 0;
  int pw_gzrf2lmps1 = 0;
  int wg_gzrf2lmps1 = 0;
  float a_gzrf2rmps1 = 0;
  int ia_gzrf2rmps1 = 0;
  int pw_gzrf2rmps1a = 0;
  int pw_gzrf2rmps1d = 0;
  int pw_gzrf2rmps1 = 0;
  int wg_gzrf2rmps1 = 0;
  float a_gxwmps1 = 0;
  int ia_gxwmps1 = 0;
  int pw_gxwmps1a = 0;
  int pw_gxwmps1d = 0;
  int pw_gxwmps1 = 0;
  int wg_gxwmps1 = 0;
  int filter_echo1mps1 = 0;
  float a_gzrf1cfl = 0;
  int ia_gzrf1cfl = 0;
  int pw_gzrf1cfla = 0;
  int pw_gzrf1cfld = 0;
  int pw_gzrf1cfl = 0;
  float a_rf1cfl = 0;
  int ia_rf1cfl = 0;
  int pw_rf1cfl = 0;
  int res_rf1cfl = 0;
  int temp_res_rf1cfl = 0;
  float cyc_rf1cfl = 0;
  int off_rf1cfl = 0;
  float alpha_rf1cfl = 0.46;
  float thk_rf1cfl = 0;
  float gscale_rf1cfl = 1.0;
  float flip_rf1cfl = 0;
  int wg_rf1cfl = TYPRHO1
;
  float a_gz1cfl = 0;
  int ia_gz1cfl = 0;
  int pw_gz1cfla = 0;
  int pw_gz1cfld = 0;
  int pw_gz1cfl = 0;
  int wg_gz1cfl = 0;
  int filter_cfl_fid = 0;
  float a_gykcfl = 0;
  int ia_gykcfl = 0;
  int pw_gykcfla = 0;
  int pw_gykcfld = 0;
  int pw_gykcfl = 0;
  int wg_gykcfl = 0;
  float a_gxkrcvn = 0;
  int ia_gxkrcvn = 0;
  int pw_gxkrcvna = 0;
  int pw_gxkrcvnd = 0;
  int pw_gxkrcvn = 0;
  int wg_gxkrcvn = 0;
  float a_gykrcvn = 0;
  int ia_gykrcvn = 0;
  int pw_gykrcvna = 0;
  int pw_gykrcvnd = 0;
  int pw_gykrcvn = 0;
  int wg_gykrcvn = 0;
  float a_gzkrcvn = 0;
  int ia_gzkrcvn = 0;
  int pw_gzkrcvna = 0;
  int pw_gzkrcvnd = 0;
  int pw_gzkrcvn = 0;
  int wg_gzkrcvn = 0;
  int pw_grd_trig = 0;
  int wg_grd_trig = 0;
  float a_gxk2rcvn = 0;
  int ia_gxk2rcvn = 0;
  int pw_gxk2rcvna = 0;
  int pw_gxk2rcvnd = 0;
  int pw_gxk2rcvn = 0;
  int wg_gxk2rcvn = 0;
  float a_gyk2rcvn = 0;
  int ia_gyk2rcvn = 0;
  int pw_gyk2rcvna = 0;
  int pw_gyk2rcvnd = 0;
  int pw_gyk2rcvn = 0;
  int wg_gyk2rcvn = 0;
  float a_gzk2rcvn = 0;
  int ia_gzk2rcvn = 0;
  int pw_gzk2rcvna = 0;
  int pw_gzk2rcvnd = 0;
  int pw_gzk2rcvn = 0;
  int wg_gzk2rcvn = 0;
  int pw_rcvn_wait = 0;
  int wg_rcvn_wait = 0;
  int ia_rcvrbl = 0;
  int filter_rcvn_fid = 0;
  int ia_rcvrbl2 = 0;
  float a_gzrf0cfh = 0;
  int ia_gzrf0cfh = 0;
  int pw_gzrf0cfha = 0;
  int pw_gzrf0cfhd = 0;
  int pw_gzrf0cfh = 0;
  int res_gzrf0cfh = 0;
  float a_rf0cfh = 0;
  int ia_rf0cfh = 0;
  int pw_rf0cfh = 0;
  int res_rf0cfh = 0;
  float cyc_rf0cfh = 0;
  int off_rf0cfh = 0;
  float alpha_rf0cfh = 0.46;
  float thk_rf0cfh = 0;
  float gscale_rf0cfh = 1.0;
  float flip_rf0cfh = 0;
  int wg_rf0cfh = TYPRHO1
;
  float a_omegarf0cfh = 0;
  int ia_omegarf0cfh = 0;
  int pw_omegarf0cfh = 0;
  int res_omegarf0cfh = 0;
  int off_omegarf0cfh = 0;
  int rfslot_omegarf0cfh = 0;
  float gscale_omegarf0cfh = 1.0;
  int n_omegarf0cfh = 0;
  int wg_omegarf0cfh = 0;
  float a_gyrf0kcfh = 0;
  int ia_gyrf0kcfh = 0;
  int pw_gyrf0kcfha = 0;
  int pw_gyrf0kcfhd = 0;
  int pw_gyrf0kcfh = 0;
  int wg_gyrf0kcfh = 0;
  int pw_zticfh = 0;
  int wg_zticfh = 0;
  int pw_rticfh = 0;
  int wg_rticfh = 0;
  int pw_xticfh = 0;
  int wg_xticfh = 0;
  int pw_yticfh = 0;
  int wg_yticfh = 0;
  int pw_sticfh = 0;
  int wg_sticfh = 0;
  float a_gzrf1cfh = 0;
  int ia_gzrf1cfh = 0;
  int pw_gzrf1cfha = 0;
  int pw_gzrf1cfhd = 0;
  int pw_gzrf1cfh = 0;
  float a_rf1cfh = 0;
  int ia_rf1cfh = 0;
  int pw_rf1cfh = 0;
  int res_rf1cfh = 0;
  int temp_res_rf1cfh = 0;
  float cyc_rf1cfh = 0;
  int off_rf1cfh = 0;
  float alpha_rf1cfh = 0.46;
  float thk_rf1cfh = 0;
  float gscale_rf1cfh = 1.0;
  float flip_rf1cfh = 0;
  int wg_rf1cfh = TYPRHO1
;
  float a_rf2cfh = 0;
  int ia_rf2cfh = 0;
  int pw_rf2cfh = 0;
  int res_rf2cfh = 0;
  float cyc_rf2cfh = 0;
  int off_rf2cfh = 0;
  float alpha_rf2cfh = 0;
  int wg_rf2cfh = 0;
  float a_rf3cfh = 0;
  int ia_rf3cfh = 0;
  int pw_rf3cfh = 0;
  int res_rf3cfh = 0;
  float cyc_rf3cfh = 0;
  int off_rf3cfh = 0;
  float alpha_rf3cfh = 0;
  int wg_rf3cfh = 0;
  float a_rf4cfh = 0;
  int ia_rf4cfh = 0;
  int pw_rf4cfh = 0;
  int res_rf4cfh = 0;
  float cyc_rf4cfh = 0;
  int off_rf4cfh = 0;
  float alpha_rf4cfh = 0;
  int wg_rf4cfh = 0;
  float a_gxrf2cfh = 0;
  int ia_gxrf2cfh = 0;
  int pw_gxrf2cfha = 0;
  int pw_gxrf2cfhd = 0;
  int pw_gxrf2cfh = 0;
  int wg_gxrf2cfh = 0;
  float a_gyrf2cfh = 0;
  int ia_gyrf2cfh = 0;
  int pw_gyrf2cfha = 0;
  int pw_gyrf2cfhd = 0;
  int pw_gyrf2cfh = 0;
  int wg_gyrf2cfh = 0;
  float a_gzrf2lcfh = 0;
  int ia_gzrf2lcfh = 0;
  int pw_gzrf2lcfha = 0;
  int pw_gzrf2lcfhd = 0;
  int pw_gzrf2lcfh = 0;
  int wg_gzrf2lcfh = 0;
  float a_gzrf2rcfh = 0;
  int ia_gzrf2rcfh = 0;
  int pw_gzrf2rcfha = 0;
  int pw_gzrf2rcfhd = 0;
  int pw_gzrf2rcfh = 0;
  int wg_gzrf2rcfh = 0;
  float a_gyrf3cfh = 0;
  int ia_gyrf3cfh = 0;
  int pw_gyrf3cfha = 0;
  int pw_gyrf3cfhd = 0;
  int pw_gyrf3cfh = 0;
  int wg_gyrf3cfh = 0;
  float a_gzrf3lcfh = 0;
  int ia_gzrf3lcfh = 0;
  int pw_gzrf3lcfha = 0;
  int pw_gzrf3lcfhd = 0;
  int pw_gzrf3lcfh = 0;
  int wg_gzrf3lcfh = 0;
  float a_gzrf3rcfh = 0;
  int ia_gzrf3rcfh = 0;
  int pw_gzrf3rcfha = 0;
  int pw_gzrf3rcfhd = 0;
  int pw_gzrf3rcfh = 0;
  int wg_gzrf3rcfh = 0;
  float a_gy1cfh = 0;
  int ia_gy1cfh = 0;
  int pw_gy1cfha = 0;
  int pw_gy1cfhd = 0;
  int pw_gy1cfh = 0;
  int wg_gy1cfh = 0;
  float a_gx1cfh = 0;
  int ia_gx1cfh = 0;
  int pw_gx1cfha = 0;
  int pw_gx1cfhd = 0;
  int pw_gx1cfh = 0;
  int wg_gx1cfh = 0;
  float a_gzrf4cfh = 0;
  int ia_gzrf4cfh = 0;
  int pw_gzrf4cfha = 0;
  int pw_gzrf4cfhd = 0;
  int pw_gzrf4cfh = 0;
  int wg_gzrf4cfh = 0;
  int pw_isi_slice1 = 0;
  int wg_isi_slice1 = 0;
  int pw_rot_slice1 = 0;
  int wg_rot_slice1 = 0;
  int pw_isi_slice2 = 0;
  int wg_isi_slice2 = 0;
  int pw_rot_slice2 = 0;
  int wg_rot_slice2 = 0;
  float a_gzrf4lcfh = 0;
  int ia_gzrf4lcfh = 0;
  int pw_gzrf4lcfha = 0;
  int pw_gzrf4lcfhd = 0;
  int pw_gzrf4lcfh = 0;
  int wg_gzrf4lcfh = 0;
  float a_gzrf4rcfh = 0;
  int ia_gzrf4rcfh = 0;
  int pw_gzrf4rcfha = 0;
  int pw_gzrf4rcfhd = 0;
  int pw_gzrf4rcfh = 0;
  int wg_gzrf4rcfh = 0;
  int filter_cfh_fid = 0;
  float a_gykcfh = 0;
  int ia_gykcfh = 0;
  int pw_gykcfha = 0;
  int pw_gykcfhd = 0;
  int pw_gykcfh = 0;
  int wg_gykcfh = 0;
  int ia_contrfhubsel = 0;
  int ia_contrfsel = 0;
  int pw_csw_wait = 0;
  int wg_csw_wait = 0;
  float a_gzrf1ftg = 0;
  int ia_gzrf1ftg = 0;
  int pw_gzrf1ftga = 0;
  int pw_gzrf1ftgd = 0;
  int pw_gzrf1ftg = 0;
  float a_rf1ftg = 0;
  int ia_rf1ftg = 0;
  int pw_rf1ftg = 0;
  int res_rf1ftg = 0;
  int temp_res_rf1ftg = 0;
  float cyc_rf1ftg = 0;
  int off_rf1ftg = 0;
  float alpha_rf1ftg = 0.46;
  float thk_rf1ftg = 0;
  float gscale_rf1ftg = 1.0;
  float flip_rf1ftg = 0;
  int wg_rf1ftg = TYPRHO1
;
  float a_gz1ftg = 0;
  int ia_gz1ftg = 0;
  int pw_gz1ftga = 0;
  int pw_gz1ftgd = 0;
  int pw_gz1ftg = 0;
  int wg_gz1ftg = 0;
  float a_gzrf2ftg = 0;
  int ia_gzrf2ftg = 0;
  int pw_gzrf2ftga = 0;
  int pw_gzrf2ftgd = 0;
  int pw_gzrf2ftg = 0;
  float a_rf2ftg = 0;
  int ia_rf2ftg = 0;
  int pw_rf2ftg = 0;
  int res_rf2ftg = 0;
  int temp_res_rf2ftg = 0;
  float cyc_rf2ftg = 0;
  int off_rf2ftg = 0;
  float alpha_rf2ftg = 0.46;
  float thk_rf2ftg = 0;
  float gscale_rf2ftg = 1.0;
  float flip_rf2ftg = 0;
  int wg_rf2ftg = TYPRHO1
;
  float a_gz2ftg = 0;
  int ia_gz2ftg = 0;
  int pw_gz2ftga = 0;
  int pw_gz2ftgd = 0;
  int pw_gz2ftg = 0;
  int wg_gz2ftg = 0;
  float a_gzrf3ftg = 0;
  int ia_gzrf3ftg = 0;
  int pw_gzrf3ftga = 0;
  int pw_gzrf3ftgd = 0;
  int pw_gzrf3ftg = 0;
  float a_rf3ftg = 0;
  int ia_rf3ftg = 0;
  int pw_rf3ftg = 0;
  int res_rf3ftg = 0;
  int temp_res_rf3ftg = 0;
  float cyc_rf3ftg = 0;
  int off_rf3ftg = 0;
  float alpha_rf3ftg = 0.46;
  float thk_rf3ftg = 0;
  float gscale_rf3ftg = 1.0;
  float flip_rf3ftg = 0;
  int wg_rf3ftg = TYPRHO1
;
  float a_gz3ftg = 0;
  int ia_gz3ftg = 0;
  int pw_gz3ftga = 0;
  int pw_gz3ftgd = 0;
  int pw_gz3ftg = 0;
  int wg_gz3ftg = 0;
  float a_gx1ftg = 0;
  int ia_gx1ftg = 0;
  int pw_gx1ftga = 0;
  int pw_gx1ftgd = 0;
  int pw_gx1ftg = 0;
  int wg_gx1ftg = 0;
  float a_gx1bftg = 0;
  int ia_gx1bftg = 0;
  int pw_gx1bftga = 0;
  int pw_gx1bftgd = 0;
  int pw_gx1bftg = 0;
  int wg_gx1bftg = 0;
  float a_gxw1ftg = 0;
  int ia_gxw1ftg = 0;
  int pw_gxw1ftga = 0;
  int pw_gxw1ftgd = 0;
  int pw_gxw1ftg = 0;
  int wg_gxw1ftg = 0;
  float a_postgxw1ftg = 0;
  int ia_postgxw1ftg = 0;
  int pw_postgxw1ftga = 0;
  int pw_postgxw1ftgd = 0;
  int pw_postgxw1ftg = 0;
  int wg_postgxw1ftg = 0;
  int filter_echo1ftg = 0;
  float a_gz2bftg = 0;
  int ia_gz2bftg = 0;
  int pw_gz2bftga = 0;
  int pw_gz2bftgd = 0;
  int pw_gz2bftg = 0;
  int wg_gz2bftg = 0;
  float a_gx2ftg = 0;
  int ia_gx2ftg = 0;
  int pw_gx2ftga = 0;
  int pw_gx2ftgd = 0;
  int pw_gx2ftg = 0;
  int wg_gx2ftg = 0;
  float a_gxw2ftg = 0;
  int ia_gxw2ftg = 0;
  int pw_gxw2ftga = 0;
  int pw_gxw2ftgd = 0;
  int pw_gxw2ftg = 0;
  int wg_gxw2ftg = 0;
  float a_gx2test = 0;
  int ia_gx2test = 0;
  int pw_gx2testa = 0;
  int pw_gx2testd = 0;
  int pw_gx2test = 0;
  int wg_gx2test = 0;
  int filter_echo2ftg = 0;
  float a_rf1xtg = 0;
  int ia_rf1xtg = 0;
  int pw_rf1xtg = 0;
  int res_rf1xtg = 0;
  float cyc_rf1xtg = 0;
  int off_rf1xtg = 0;
  float alpha_rf1xtg = 0;
  int wg_rf1xtg = 0;
  float a_gyrf1xtg = 0;
  int ia_gyrf1xtg = 0;
  int pw_gyrf1xtga = 0;
  int pw_gyrf1xtgd = 0;
  int pw_gyrf1xtg = 0;
  int wg_gyrf1xtg = 0;
  float a_gzrf1xtg = 0;
  int ia_gzrf1xtg = 0;
  int pw_gzrf1xtga = 0;
  int pw_gzrf1xtgd = 0;
  int pw_gzrf1xtg = 0;
  int wg_gzrf1xtg = 0;
  float a_gykxtgl = 0;
  int ia_gykxtgl = 0;
  int pw_gykxtgla = 0;
  int pw_gykxtgld = 0;
  int pw_gykxtgl = 0;
  int wg_gykxtgl = 0;
       float a_rf3xtg = 0;
       int ia_rf3xtg = 0;
       int pw_rf3xtg = 0;
       int res_rf3xtg = 0;
       int off_rf3xtg = 0;
       float alpha_rf3xtg = 0.46;
       float gscale_rf3xtg = 1.0;
       float flip_rf3xtg = 0;
       int ia_phs_rf3xtg = 0;
       int wg_rf3xtg = TYPRHO1
;
  float a_gz1xtg = 0;
  int ia_gz1xtg = 0;
  int pw_gz1xtga = 0;
  int pw_gz1xtgd = 0;
  int pw_gz1xtg = 0;
  int wg_gz1xtg = 0;
  float a_gzrf2xtg = 0;
  int ia_gzrf2xtg = 0;
  int pw_gzrf2xtga = 0;
  int pw_gzrf2xtgd = 0;
  int pw_gzrf2xtg = 0;
  float a_rf2xtg = 0;
  int ia_rf2xtg = 0;
  int pw_rf2xtg = 0;
  int res_rf2xtg = 0;
  int temp_res_rf2xtg = 0;
  float cyc_rf2xtg = 0;
  int off_rf2xtg = 0;
  float alpha_rf2xtg = 0.46;
  float thk_rf2xtg = 0;
  float gscale_rf2xtg = 1.0;
  float flip_rf2xtg = 0;
  int wg_rf2xtg = TYPRHO1
;
  float a_gz2xtg = 0;
  int ia_gz2xtg = 0;
  int pw_gz2xtga = 0;
  int pw_gz2xtgd = 0;
  int pw_gz2xtg = 0;
  int wg_gz2xtg = 0;
       float a_rf4xtg = 0;
       int ia_rf4xtg = 0;
       int pw_rf4xtg = 0;
       int res_rf4xtg = 0;
       int off_rf4xtg = 0;
       float alpha_rf4xtg = 0.46;
       float gscale_rf4xtg = 1.0;
       float flip_rf4xtg = 0;
       int ia_phs_rf4xtg = 0;
       int wg_rf4xtg = TYPRHO1
;
  float a_gykxtgr = 0;
  int ia_gykxtgr = 0;
  int pw_gykxtgra = 0;
  int pw_gykxtgrd = 0;
  int pw_gykxtgr = 0;
  int wg_gykxtgr = 0;
  float a_gx1bxtg = 0;
  int ia_gx1bxtg = 0;
  int pw_gx1bxtga = 0;
  int pw_gx1bxtgd = 0;
  int pw_gx1bxtg = 0;
  int wg_gx1bxtg = 0;
  float a_gxw1xtg = 0;
  int ia_gxw1xtg = 0;
  int pw_gxw1xtga = 0;
  int pw_gxw1xtgd = 0;
  int pw_gxw1xtg = 0;
  int wg_gxw1xtg = 0;
  int filter_echo1xtg = 0;
  float a_gzrf1as = 0;
  int ia_gzrf1as = 0;
  int pw_gzrf1asa = 0;
  int pw_gzrf1asd = 0;
  int pw_gzrf1as = 0;
  float a_rf1as = 0;
  int ia_rf1as = 0;
  int pw_rf1as = 0;
  int res_rf1as = 0;
  int temp_res_rf1as = 0;
  float cyc_rf1as = 0;
  int off_rf1as = 0;
  float alpha_rf1as = 0.46;
  float thk_rf1as = 0;
  float gscale_rf1as = 1.0;
  float flip_rf1as = 0;
  int wg_rf1as = TYPRHO1
;
  float a_gz1as = 0;
  int ia_gz1as = 0;
  int pw_gz1asa = 0;
  int pw_gz1asd = 0;
  int pw_gz1as = 0;
  int wg_gz1as = 0;
  float a_gxwas = 0;
  int ia_gxwas = 0;
  int pw_gxwasa = 0;
  int pw_gxwasd = 0;
  int pw_gxwas = 0;
  int wg_gxwas = 0;
  int filter_echo1as = 0;
  float a_gx1as = 0;
  int ia_gx1as = 0;
  int pw_gx1asa = 0;
  int pw_gx1asd = 0;
  int pw_gx1as = 0;
  int wg_gx1as = 0;
  float a_gy1as = 0;
  float a_gy1asa = 0;
  float a_gy1asb = 0;
  int ia_gy1as = 0;
  int ia_gy1aswa = 0;
  int ia_gy1aswb = 0;
  int pw_gy1asa = 0;
  int pw_gy1asd = 0;
  int pw_gy1as = 0;
  int wg_gy1as = 0;
  float a_gy1ras = 0;
  float a_gy1rasa = 0;
  float a_gy1rasb = 0;
  int ia_gy1ras = 0;
  int ia_gy1raswa = 0;
  int ia_gy1raswb = 0;
  int pw_gy1rasa = 0;
  int pw_gy1rasd = 0;
  int pw_gy1ras = 0;
  int wg_gy1ras = 0;
  float a_gxkas = 0;
  int ia_gxkas = 0;
  int pw_gxkasa = 0;
  int pw_gxkasd = 0;
  int pw_gxkas = 0;
  int wg_gxkas = 0;
  float a_gzkas = 0;
  int ia_gzkas = 0;
  int pw_gzkasa = 0;
  int pw_gzkasd = 0;
  int pw_gzkas = 0;
  int wg_gzkas = 0;
  float a_xdixon = 0;
  int ia_xdixon = 0;
  int pw_xdixon = 0;
  int wg_xdixon = 0;
  float a_ydixon = 0;
  int ia_ydixon = 0;
  int pw_ydixon = 0;
  int wg_ydixon = 0;
  float a_zdixon = 0;
  int ia_zdixon = 0;
  int pw_zdixon = 0;
  int wg_zdixon = 0;
  float a_sdixon = 0;
  int ia_sdixon = 0;
  int pw_sdixon = 0;
  int wg_sdixon = 0;
  float a_sdixon2 = 0;
  int ia_sdixon2 = 0;
  int pw_sdixon2 = 0;
  int wg_sdixon2 = 0;
  int ia_dDDIQ = 0;
  int res_rf1rs = 0;
  int wg_rf1rs = 0;
  float a_gzrf1rs = 0;
  int ia_gzrf1rs = 0;
  int pw_gzrf1rsa = 0;
  int pw_gzrf1rsd = 0;
  int pw_gzrf1rs = 0;
  int wg_gzrf1rs = 0;
  float a_gxkbsrs = 0;
  int ia_gxkbsrs = 0;
  int pw_gxkbsrsa = 0;
  int pw_gxkbsrsd = 0;
  int pw_gxkbsrs = 0;
  int wg_gxkbsrs = 0;
  float a_gz1rs = 0;
  int ia_gz1rs = 0;
  int pw_gz1rsa = 0;
  int pw_gz1rsd = 0;
  int pw_gz1rs = 0;
  int wg_gz1rs = 0;
  float a_rfbrs = 0;
  int ia_rfbrs = 0;
  int pw_rfbrs = 0;
  int res_rfbrs = 0;
  int off_rfbrs = 0;
  int rfslot_rfbrs = 0;
  float gscale_rfbrs = 1.0;
  int n_rfbrs = 0;
  int wg_rfbrs = 0;
  float a_thetarfbrs = 0;
  int ia_thetarfbrs = 0;
  int pw_thetarfbrs = 0;
  int res_thetarfbrs = 0;
  int off_thetarfbrs = 0;
  int rfslot_thetarfbrs = 0;
  float gscale_thetarfbrs = 1.0;
  int n_thetarfbrs = 0;
  int wg_thetarfbrs = 0;
  float a_gzkbsrs = 0;
  int ia_gzkbsrs = 0;
  int pw_gzkbsrsa = 0;
  int pw_gzkbsrsd = 0;
  int pw_gzkbsrs = 0;
  int wg_gzkbsrs = 0;
  float a_gxwrs = 0;
  int ia_gxwrs = 0;
  int pw_gxwrsa = 0;
  int pw_gxwrsd = 0;
  int pw_gxwrs = 0;
  int wg_gxwrs = 0;
  int filter_echo1rs = 0;
  float a_gx2rs = 0;
  int ia_gx2rs = 0;
  int pw_gx2rsa = 0;
  int pw_gx2rsd = 0;
  int pw_gx2rs = 0;
  int wg_gx2rs = 0;
  float a_gy2rs = 0;
  float a_gy2rsa = 0;
  float a_gy2rsb = 0;
  int ia_gy2rs = 0;
  int ia_gy2rswa = 0;
  int ia_gy2rswb = 0;
  int pw_gy2rsa = 0;
  int pw_gy2rsd = 0;
  int pw_gy2rs = 0;
  int wg_gy2rs = 0;
  float a_gxw2rs = 0;
  int ia_gxw2rs = 0;
  int pw_gxw2rsa = 0;
  int pw_gxw2rsd = 0;
  int pw_gxw2rs = 0;
  int wg_gxw2rs = 0;
  float a_gx1rs = 0;
  int ia_gx1rs = 0;
  int pw_gx1rsa = 0;
  int pw_gx1rsd = 0;
  int pw_gx1rs = 0;
  int wg_gx1rs = 0;
  float a_gy1rrs = 0;
  float a_gy1rrsa = 0;
  float a_gy1rrsb = 0;
  int ia_gy1rrs = 0;
  int ia_gy1rrswa = 0;
  int ia_gy1rrswb = 0;
  int pw_gy1rrsa = 0;
  int pw_gy1rrsd = 0;
  int pw_gy1rrs = 0;
  int wg_gy1rrs = 0;
  float a_gy1rs = 0;
  float a_gy1rsa = 0;
  float a_gy1rsb = 0;
  int ia_gy1rs = 0;
  int ia_gy1rswa = 0;
  int ia_gy1rswb = 0;
  int pw_gy1rsa = 0;
  int pw_gy1rsd = 0;
  int pw_gy1rs = 0;
  int wg_gy1rs = 0;
  float a_gzkrs = 0;
  int ia_gzkrs = 0;
  int pw_gzkrsa = 0;
  int pw_gzkrsd = 0;
  int pw_gzkrs = 0;
  int wg_gzkrs = 0;
  float a_gxkrs = 0;
  int ia_gxkrs = 0;
  int pw_gxkrsa = 0;
  int pw_gxkrsd = 0;
  int pw_gxkrs = 0;
  int wg_gxkrs = 0;
  int res_rf1dtg = 0;
  int wg_rf1dtg = 0;
  float a_gzrf1dtg = 0;
  int ia_gzrf1dtg = 0;
  int pw_gzrf1dtga = 0;
  int pw_gzrf1dtgd = 0;
  int pw_gzrf1dtg = 0;
  int wg_gzrf1dtg = 0;
  float a_gxkbsdtg = 0;
  int ia_gxkbsdtg = 0;
  int pw_gxkbsdtga = 0;
  int pw_gxkbsdtgd = 0;
  int pw_gxkbsdtg = 0;
  int wg_gxkbsdtg = 0;
  float a_gz1dtg = 0;
  int ia_gz1dtg = 0;
  int pw_gz1dtga = 0;
  int pw_gz1dtgd = 0;
  int pw_gz1dtg = 0;
  int wg_gz1dtg = 0;
  float a_rfbdtg = 0;
  int ia_rfbdtg = 0;
  int pw_rfbdtg = 0;
  int res_rfbdtg = 0;
  int off_rfbdtg = 0;
  int rfslot_rfbdtg = 0;
  float gscale_rfbdtg = 1.0;
  int n_rfbdtg = 0;
  int wg_rfbdtg = 0;
  float a_thetarfbdtg = 0;
  int ia_thetarfbdtg = 0;
  int pw_thetarfbdtg = 0;
  int res_thetarfbdtg = 0;
  int off_thetarfbdtg = 0;
  int rfslot_thetarfbdtg = 0;
  float gscale_thetarfbdtg = 1.0;
  int n_thetarfbdtg = 0;
  int wg_thetarfbdtg = 0;
  float a_gzkbsdtg = 0;
  int ia_gzkbsdtg = 0;
  int pw_gzkbsdtga = 0;
  int pw_gzkbsdtgd = 0;
  int pw_gzkbsdtg = 0;
  int wg_gzkbsdtg = 0;
  float a_gxwdtg = 0;
  int ia_gxwdtg = 0;
  int pw_gxwdtga = 0;
  int pw_gxwdtgd = 0;
  int pw_gxwdtg = 0;
  int wg_gxwdtg = 0;
  int filter_echo1dtg = 0;
  float a_gx2dtg = 0;
  int ia_gx2dtg = 0;
  int pw_gx2dtga = 0;
  int pw_gx2dtgd = 0;
  int pw_gx2dtg = 0;
  int wg_gx2dtg = 0;
  float a_gy2dtg = 0;
  float a_gy2dtga = 0;
  float a_gy2dtgb = 0;
  int ia_gy2dtg = 0;
  int ia_gy2dtgwa = 0;
  int ia_gy2dtgwb = 0;
  int pw_gy2dtga = 0;
  int pw_gy2dtgd = 0;
  int pw_gy2dtg = 0;
  int wg_gy2dtg = 0;
  float a_gxw2dtg = 0;
  int ia_gxw2dtg = 0;
  int pw_gxw2dtga = 0;
  int pw_gxw2dtgd = 0;
  int pw_gxw2dtg = 0;
  int wg_gxw2dtg = 0;
  float a_gx1dtg = 0;
  int ia_gx1dtg = 0;
  int pw_gx1dtga = 0;
  int pw_gx1dtgd = 0;
  int pw_gx1dtg = 0;
  int wg_gx1dtg = 0;
  float a_gy1rdtg = 0;
  float a_gy1rdtga = 0;
  float a_gy1rdtgb = 0;
  int ia_gy1rdtg = 0;
  int ia_gy1rdtgwa = 0;
  int ia_gy1rdtgwb = 0;
  int pw_gy1rdtga = 0;
  int pw_gy1rdtgd = 0;
  int pw_gy1rdtg = 0;
  int wg_gy1rdtg = 0;
  float a_gy1dtg = 0;
  float a_gy1dtga = 0;
  float a_gy1dtgb = 0;
  int ia_gy1dtg = 0;
  int ia_gy1dtgwa = 0;
  int ia_gy1dtgwb = 0;
  int pw_gy1dtga = 0;
  int pw_gy1dtgd = 0;
  int pw_gy1dtg = 0;
  int wg_gy1dtg = 0;
  float a_gzkdtg = 0;
  int ia_gzkdtg = 0;
  int pw_gzkdtga = 0;
  int pw_gzkdtgd = 0;
  int pw_gzkdtg = 0;
  int wg_gzkdtg = 0;
  float a_gxkdtg = 0;
  int ia_gxkdtg = 0;
  int pw_gxkdtga = 0;
  int pw_gxkdtgd = 0;
  int pw_gxkdtg = 0;
  int wg_gxkdtg = 0;
  float a_rf1cal = 0;
  int ia_rf1cal = 0;
  int pw_rf1cal = 0;
  int res_rf1cal = 0;
  int off_rf1cal = 0;
  int rfslot_rf1cal = 0;
  float gscale_rf1cal = 1.0;
  int n_rf1cal = 0;
  int wg_rf1cal = 0;
  float a_gzrf1cal = 0;
  int ia_gzrf1cal = 0;
  int pw_gzrf1cala = 0;
  int pw_gzrf1cald = 0;
  int pw_gzrf1cal = 0;
  int wg_gzrf1cal = 0;
  float a_gzcombcal = 0;
  float a_gzcombcala = 0;
  float a_gzcombcalb = 0;
  int ia_gzcombcal = 0;
  int ia_gzcombcalwa = 0;
  int ia_gzcombcalwb = 0;
  int pw_gzcombcala = 0;
  int pw_gzcombcald = 0;
  int pw_gzcombcalf = 0;
  int pw_gzcombcal = 0;
  int res_gzcombcal = 0;
  int per_gzcombcal = 0;
  int wg_gzcombcal = 0;
  float a_gzprcal = 0;
  float a_gzprcala = 0;
  float a_gzprcalb = 0;
  int ia_gzprcal = 0;
  int ia_gzprcalwa = 0;
  int ia_gzprcalwb = 0;
  int pw_gzprcala = 0;
  int pw_gzprcald = 0;
  int pw_gzprcalf = 0;
  int pw_gzprcal = 0;
  int res_gzprcal = 0;
  int per_gzprcal = 0;
  int wg_gzprcal = 0;
  float a_gxwcal = 0;
  int ia_gxwcal = 0;
  int pw_gxwcala = 0;
  int pw_gxwcald = 0;
  int pw_gxwcal = 0;
  int wg_gxwcal = 0;
  int filter_echo1cal = 0;
  float a_gx1cal = 0;
  float a_gx1cala = 0;
  float a_gx1calb = 0;
  int ia_gx1cal = 0;
  int ia_gx1calwa = 0;
  int ia_gx1calwb = 0;
  int pw_gx1cala = 0;
  int pw_gx1cald = 0;
  int pw_gx1calf = 0;
  int pw_gx1cal = 0;
  int res_gx1cal = 0;
  int per_gx1cal = 0;
  int wg_gx1cal = 0;
  float a_gy1cal = 0;
  float a_gy1cala = 0;
  float a_gy1calb = 0;
  int ia_gy1cal = 0;
  int ia_gy1calwa = 0;
  int ia_gy1calwb = 0;
  int pw_gy1cala = 0;
  int pw_gy1cald = 0;
  int pw_gy1calf = 0;
  int pw_gy1cal = 0;
  int res_gy1cal = 0;
  int per_gy1cal = 0;
  int wg_gy1cal = 0;
  float a_gy1rcal = 0;
  float a_gy1rcala = 0;
  float a_gy1rcalb = 0;
  int ia_gy1rcal = 0;
  int ia_gy1rcalwa = 0;
  int ia_gy1rcalwb = 0;
  int pw_gy1rcala = 0;
  int pw_gy1rcald = 0;
  int pw_gy1rcalf = 0;
  int pw_gy1rcal = 0;
  int res_gy1rcal = 0;
  int per_gy1rcal = 0;
  int wg_gy1rcal = 0;
  float a_rf1coil = 0;
  int ia_rf1coil = 0;
  int pw_rf1coil = 0;
  int res_rf1coil = 0;
  int off_rf1coil = 0;
  int rfslot_rf1coil = 0;
  float gscale_rf1coil = 1.0;
  int n_rf1coil = 0;
  int wg_rf1coil = 0;
  float a_gzrf1coil = 0;
  int ia_gzrf1coil = 0;
  int pw_gzrf1coila = 0;
  int pw_gzrf1coild = 0;
  int pw_gzrf1coil = 0;
  int wg_gzrf1coil = 0;
  float a_gzcombcoil = 0;
  float a_gzcombcoila = 0;
  float a_gzcombcoilb = 0;
  int ia_gzcombcoil = 0;
  int ia_gzcombcoilwa = 0;
  int ia_gzcombcoilwb = 0;
  int pw_gzcombcoila = 0;
  int pw_gzcombcoild = 0;
  int pw_gzcombcoilf = 0;
  int pw_gzcombcoil = 0;
  int res_gzcombcoil = 0;
  int per_gzcombcoil = 0;
  int wg_gzcombcoil = 0;
  float a_gzprcoil = 0;
  float a_gzprcoila = 0;
  float a_gzprcoilb = 0;
  int ia_gzprcoil = 0;
  int ia_gzprcoilwa = 0;
  int ia_gzprcoilwb = 0;
  int pw_gzprcoila = 0;
  int pw_gzprcoild = 0;
  int pw_gzprcoilf = 0;
  int pw_gzprcoil = 0;
  int res_gzprcoil = 0;
  int per_gzprcoil = 0;
  int wg_gzprcoil = 0;
  float a_gxwcoil = 0;
  int ia_gxwcoil = 0;
  int pw_gxwcoila = 0;
  int pw_gxwcoild = 0;
  int pw_gxwcoil = 0;
  int wg_gxwcoil = 0;
  int filter_echo1coil = 0;
  float a_gx1coil = 0;
  float a_gx1coila = 0;
  float a_gx1coilb = 0;
  int ia_gx1coil = 0;
  int ia_gx1coilwa = 0;
  int ia_gx1coilwb = 0;
  int pw_gx1coila = 0;
  int pw_gx1coild = 0;
  int pw_gx1coilf = 0;
  int pw_gx1coil = 0;
  int res_gx1coil = 0;
  int per_gx1coil = 0;
  int wg_gx1coil = 0;
  float a_gy1coil = 0;
  float a_gy1coila = 0;
  float a_gy1coilb = 0;
  int ia_gy1coil = 0;
  int ia_gy1coilwa = 0;
  int ia_gy1coilwb = 0;
  int pw_gy1coila = 0;
  int pw_gy1coild = 0;
  int pw_gy1coilf = 0;
  int pw_gy1coil = 0;
  int res_gy1coil = 0;
  int per_gy1coil = 0;
  int wg_gy1coil = 0;
  float a_gy1rcoil = 0;
  float a_gy1rcoila = 0;
  float a_gy1rcoilb = 0;
  int ia_gy1rcoil = 0;
  int ia_gy1rcoilwa = 0;
  int ia_gy1rcoilwb = 0;
  int pw_gy1rcoila = 0;
  int pw_gy1rcoild = 0;
  int pw_gy1rcoilf = 0;
  int pw_gy1rcoil = 0;
  int res_gy1rcoil = 0;
  int per_gy1rcoil = 0;
  int wg_gy1rcoil = 0;
  float start_gycylra = 0;
  float end_gycylra = 0;
  int ia_stgycylra = 0;
  int ia_endgycylra = 0;
  int pw_gycylra = 0;
  int res_gycylra = 0;
  int wg_gycylra = 0;
  float start_gzcylra = 0;
  float end_gzcylra = 0;
  int ia_stgzcylra = 0;
  int ia_endgzcylra = 0;
  int pw_gzcylra = 0;
  int res_gzcylra = 0;
  int wg_gzcylra = 0;
  int res_rfcylr = 0;
  int wg_rfcylr = 0;
  int res_thcylr = 0;
  int wg_thcylr = 0;
  int res_gycylr = 0;
  int wg_gycylr = 0;
  int res_gzcylr = 0;
  int wg_gzcylr = 0;
  float a_gzrf1mon = 0;
  int ia_gzrf1mon = 0;
  int pw_gzrf1mona = 0;
  int pw_gzrf1mond = 0;
  int pw_gzrf1mon = 0;
  float a_rf1mon = 0;
  int ia_rf1mon = 0;
  int pw_rf1mon = 0;
  int res_rf1mon = 0;
  int temp_res_rf1mon = 0;
  float cyc_rf1mon = 0;
  int off_rf1mon = 0;
  float alpha_rf1mon = 0.46;
  float thk_rf1mon = 0;
  float gscale_rf1mon = 1.0;
  float flip_rf1mon = 0;
  int wg_rf1mon = TYPRHO1
;
  float a_gyrf1mon = 0;
  int ia_gyrf1mon = 0;
  int pw_gyrf1mona = 0;
  int pw_gyrf1mond = 0;
  int pw_gyrf1mon = 0;
  int wg_gyrf1mon = 0;
  float a_gz1mon = 0;
  int ia_gz1mon = 0;
  int pw_gz1mona = 0;
  int pw_gz1mond = 0;
  int pw_gz1mon = 0;
  int wg_gz1mon = 0;
  float a_gy1mon = 0;
  int ia_gy1mon = 0;
  int pw_gy1mona = 0;
  int pw_gy1mond = 0;
  int pw_gy1mon = 0;
  int wg_gy1mon = 0;
  float a_gyrf2mon = 0;
  int ia_gyrf2mon = 0;
  int pw_gyrf2mona = 0;
  int pw_gyrf2mond = 0;
  int pw_gyrf2mon = 0;
  float a_rf2mon = 0;
  int ia_rf2mon = 0;
  int pw_rf2mon = 0;
  int res_rf2mon = 0;
  int temp_res_rf2mon = 0;
  float cyc_rf2mon = 0;
  int off_rf2mon = 0;
  float alpha_rf2mon = 0.46;
  float thk_rf2mon = 0;
  float gscale_rf2mon = 1.0;
  float flip_rf2mon = 0;
  int wg_rf2mon = TYPRHO1
;
  float a_gyrf2lmon = 0;
  int ia_gyrf2lmon = 0;
  int pw_gyrf2lmona = 0;
  int pw_gyrf2lmond = 0;
  int pw_gyrf2lmon = 0;
  int wg_gyrf2lmon = 0;
  float a_gyrf2rmon = 0;
  int ia_gyrf2rmon = 0;
  int pw_gyrf2rmona = 0;
  int pw_gyrf2rmond = 0;
  int pw_gyrf2rmon = 0;
  int wg_gyrf2rmon = 0;
  float a_gxwmon = 0;
  int ia_gxwmon = 0;
  int pw_gxwmona = 0;
  int pw_gxwmond = 0;
  int pw_gxwmon = 0;
  int wg_gxwmon = 0;
  float a_gx1mon = 0;
  int ia_gx1mon = 0;
  int pw_gx1mona = 0;
  int pw_gx1mond = 0;
  int pw_gx1mon = 0;
  int wg_gx1mon = 0;
  float a_gxfcmon = 0;
  int ia_gxfcmon = 0;
  int pw_gxfcmona = 0;
  int pw_gxfcmond = 0;
  int pw_gxfcmon = 0;
  int wg_gxfcmon = 0;
  int filter_echo1mon = 0;
  float a_gzkmon = 0;
  int ia_gzkmon = 0;
  int pw_gzkmona = 0;
  int pw_gzkmond = 0;
  int pw_gzkmon = 0;
  int wg_gzkmon = 0;
  float start_gycylratipup = 0;
  float end_gycylratipup = 0;
  int ia_stgycylratipup = 0;
  int ia_endgycylratipup = 0;
  int pw_gycylratipup = 0;
  int res_gycylratipup = 0;
  int wg_gycylratipup = 0;
  float start_gzcylratipup = 0;
  float end_gzcylratipup = 0;
  int ia_stgzcylratipup = 0;
  int ia_endgzcylratipup = 0;
  int pw_gzcylratipup = 0;
  int res_gzcylratipup = 0;
  int wg_gzcylratipup = 0;
  int res_rfcylrtipup = 0;
  int wg_rfcylrtipup = 0;
  int res_thcylrtipup = 0;
  int wg_thcylrtipup = 0;
  int res_gycylrtipup = 0;
  int wg_gycylrtipup = 0;
  int res_gzcylrtipup = 0;
  int wg_gzcylrtipup = 0;
  float a_gyrfmontipup = 0;
  int ia_gyrfmontipup = 0;
  int pw_gyrfmontipupa = 0;
  int pw_gyrfmontipupd = 0;
  int pw_gyrfmontipup = 0;
  float a_rfmontipup = 0;
  int ia_rfmontipup = 0;
  int pw_rfmontipup = 0;
  int res_rfmontipup = 0;
  int temp_res_rfmontipup = 0;
  float cyc_rfmontipup = 0;
  int off_rfmontipup = 0;
  float alpha_rfmontipup = 0.46;
  float thk_rfmontipup = 0;
  float gscale_rfmontipup = 1.0;
  float flip_rfmontipup = 0;
  int wg_rfmontipup = TYPRHO1
;
  float a_gzkmontipup = 0;
  int ia_gzkmontipup = 0;
  int pw_gzkmontipupa = 0;
  int pw_gzkmontipupd = 0;
  int pw_gzkmontipup = 0;
  int wg_gzkmontipup = 0;
long _lastcv = 0;
RSP_INFO rsp_info[(2048)] = { {0,0,0,0} };
long rsprot[2*(2048)][9]= {{0}};
long rsptrigger[2*(2048)]= {0};
long ipg_alloc_instr[9] = {
4096,
4096,
4096,
4096,
4096,
4096,
4096,
8192,
64};
RSP_INFO asrsp_info[3] = { {0,0,0,0} };
long sat_rot_matrices[14][9]= {{0}};
int sat_rot_ex_indices[7]= {0};
PHYS_GRAD phygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
LOG_GRAD loggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD satloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD asloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
SCAN_INFO asscan_info[3] = { {0,0,0,0,0,0,0,0,0,{0}} };
long PSrot[1][9]= {{0}};
long PSrot_mod[1][9]= {{0}};
PHASE_OFF phase_off[(2048)] = { {0,0} };
int yres_phase= {0};
int yoffs1= {0};
int off_rfcsz_base[(2048)]= {0};
SCAN_INFO scan_info_base[1] = { {0,0,0,0,0,0,0,0,0,{0}} };
float xyz_base[(2048)][3]= {{0}};
long rsprot_base[2*(2048)][9]= {{0}};
int rtia_first_scan_flag = 1 ;
RSP_PSC_INFO rsp_psc_info[5] = { {0,0,0,{0},0,0,0} };
COIL_INFO coilInfo_tgt[10] = { { {0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } };
COIL_INFO volRecCoilInfo_tgt[10] = { { {0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } };
COIL_INFO fullRecCoilInfo_tgt[10] = { { {0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } };
TX_COIL_INFO txCoilInfo_tgt[5] = { { 0,0,0,0,0,0,0,0,0,{0},0,0,{0},{0},{0},{0},0 } };
int cframpdir_tgt = 1;
int chksum_rampdir_tgt = 1447292810UL;
SeqCfgInfo seqcfginfo = {0,0,0,0,0,0,{0,0,0,0,0},{{0,0,0,0,0,0,{0,0,0,0}}},{{0,0,{0},0,{0}}},{{0,0,0,0,0,0,0,0}}};
int PSfreq_offset[20]= {0};
int cfl_tdaq= {0};
int cfh_tdaq= {0};
int rcvn_tdaq= {0};
long rsp_PSrot[5] [9]= {{0}};
long rsp_rcvnrot[1][9]= {{0}};
long rsrsprot[1][9] = {{0}};
long dtgrsprot[5][9] = {{0}};
long calrsprot[64 + 1][9] = {{0}};
long coilrsprot[64 + 1][9] = {{0}};
int min_ssp= {0};
RSP_INFO rsrsp_info[1] = { {0,0,0,0} };
RSP_INFO dtgrsp_info[5] = { {0,0,0,0} };
RSP_INFO calrsp_info[64] = { {0,0,0,0} };
RSP_INFO coilrsp_info[64] = { {0,0,0,0} };
ZY_INDEX cal_zyindex[64*64] = { {0,0,0} };
ZY_INDEX coil_zyindex[64*64] = { {0,0,0} };
PSC_INFO presscfh_info[5]={ {0,0,0,{0},0,0,0} };
LOG_GRAD cflloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD ps1loggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD cfhloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD rcvnloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD rsloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD dtgloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD calloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD coilloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
LOG_GRAD maptgloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
PHYS_GRAD original_pgrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
WF_PROCESSOR read_axis = TYPXGRAD;
WF_PROCESSOR killer_axis = TYPYGRAD;
WF_PROCESSOR tg_killer_axis = TYPYGRAD;
WF_PROCESSOR tg_read_axis = TYPXGRAD;
float z_to_omscale[(2048)]= {0};
float y_to_omscale[(2048)]= {0};
float shift_to_omscale[(2048)]= {0};
int runtime_rf_waveform_rf1[32768]= {0};
int runtime_rf_waveform_rf1a[32768]= {0};
int runtime_rf_waveform_rf1b[32768]= {0};
int runtime_rf_waveform_rf1c[32768]= {0};
int runtime_rf_waveform_rf1d[32768]= {0};
int runtime_rf_waveform_rf1e[32768]= {0};
int runtime_rf_waveform_rf1f[32768]= {0};
int runtime_rf_waveform_rf1g[32768]= {0};
int runtime_rf_waveform_rf1h[32768]= {0};
int runtime_rf_waveform_rf1i[32768]= {0};
int slloc2sltime[1*(2048)]= {0};
int sltime2slloc[1*(2048)]= {0};
float f_sltime2slloc[1*(2048)]= {0};
int act_slquant1= {0};
long rsprot_unscaled[(2048)][9]= {{0}};
float inversRR[9]= {0};
float D[4][3]= {{0}};
float log_incdifx[4]= {0};
float log_incdify[4]= {0};
float log_incdifz[4]= {0};
float diff_ampx2[40][4]= {{0}};
float diff_ampy2[40][4]= {{0}};
float diff_ampz2[40][4]= {{0}};
int off_rfcsz[(2048)]= {0};
float dwigcor[9] = {0,0,0,0,0,0,0,0,0};
float dwibcor[3] = {0,0,0};
float dwikcor[9] = {0,0,0,0,0,0,0,0,0};
float dwi_hoec_gcor_XonX[8][150][256]={{{0}}};
float dwi_hoec_gcor_YonX[8][150][256]={{{0}}};
float dwi_hoec_gcor_ZonX[8][150][256]={{{0}}};
float dwi_hoec_gcor_XonY[8][150][256]={{{0}}};
float dwi_hoec_gcor_YonY[8][150][256]={{{0}}};
float dwi_hoec_gcor_ZonY[8][150][256]={{{0}}};
float dwi_hoec_bcor_XonB0[8][150][256]={{{0}}};
float dwi_hoec_bcor_YonB0[8][150][256]={{{0}}};
float dwi_hoec_bcor_ZonB0[8][150][256]={{{0}}};
float diff_ampx[40]= {0};
float diff_ampy[40]= {0};
float diff_ampz[40]= {0};
float diff_bv_weight[40]= {0};
PHYS_GRAD epiphygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
LOG_GRAD epiloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
PHYS_GRAD orthphygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
LOG_GRAD orthloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0, 0, 0 };
RF_PULSE_INFO rfpulseInfo[((17 +5)+24)] = { {0,0} };
float delay_buffer[10]= {0};
float dither_buffer[12]= {0};
float ccinx[50]= {0};
float cciny[50]= {0};
float ccinz[50]= {0};
float fesp_in[50]= {0};
int esp_in[50]= {0};
float g0= {0};
int num_elements= {0};
int file_exist= {0};
float taratio_arr[3]= {0};
float totarea_arr[3]= {0};
float agxdif_tmp= {0}, agydif_tmp= {0}, agzdif_tmp= {0};
int difnextab_rsp[100]= {0};
int ctlend_last[(2048)]= {0};
int ctlend_fill[(2048)]= {0};
int ctlend_unfill[(2048)]= {0};
int t1flair_slice_info_enh[(2048)]= {0};
int t1flair_slice_info_reg[(2048)]= {0};
char ssrffile[40]= {0};
char ssgzfile[40]= {0};
char hgzssfn[40]= {0};
float ss_psd_slthick = 10;
RSP_INFO mon_rsp_info[1] = { {0,0,0,0} };
RSP_INFO mon_rsp_info2[1] = { {0,0,0,0} };
LOG_GRAD monloggrd = {0,0,0,0,0,0,{0,0,0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 , 0, 0, 0};
PHYS_GRAD monphygrd = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
long rsprot_monitor[1][9]= {{0}};
n32 mcbias_info[3] = {0};
int arcPhIndex[2048 +1]= {0};
int arcSlIndex[256 +1]= {0};
long _lasttgtex = 0;
