#include <stdio.h>
#include "hocdec.h"
#define IMPORT extern __declspec(dllimport)
IMPORT int nrnmpi_myid, nrn_nobanner_;

extern void _CaER_reg();
extern void _KCa31_reg();
extern void _Kir21_reg();
extern void _Kv13_reg();
extern void _L_VDCC_reg();
extern void _MG_activation_reg();
extern void _NCX_reg();
extern void _P2X7_reg();
extern void _P2Y12_reg();
extern void _PMCA_reg();
extern void _SOCE_reg();
extern void _THIK1_reg();

void modl_reg(){
	//nrn_mswindll_stdio(stdin, stdout, stderr);
    if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
	fprintf(stderr, "Additional mechanisms from files\n");

fprintf(stderr," CaER.mod");
fprintf(stderr," KCa31.mod");
fprintf(stderr," Kir21.mod");
fprintf(stderr," Kv13.mod");
fprintf(stderr," L_VDCC.mod");
fprintf(stderr," MG_activation.mod");
fprintf(stderr," NCX.mod");
fprintf(stderr," P2X7.mod");
fprintf(stderr," P2Y12.mod");
fprintf(stderr," PMCA.mod");
fprintf(stderr," SOCE.mod");
fprintf(stderr," THIK1.mod");
fprintf(stderr, "\n");
    }
_CaER_reg();
_KCa31_reg();
_Kir21_reg();
_Kv13_reg();
_L_VDCC_reg();
_MG_activation_reg();
_NCX_reg();
_P2X7_reg();
_P2Y12_reg();
_PMCA_reg();
_SOCE_reg();
_THIK1_reg();
}
