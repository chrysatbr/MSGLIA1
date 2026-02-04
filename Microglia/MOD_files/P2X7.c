/* Created by Language version: 7.7.0 */
/* NOT VECTORIZED */
#define NRN_VECTORIZED 0
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mech_api.h"
#undef PI
#define nil 0
#include "md1redef.h"
#include "section.h"
#include "nrniv_mf.h"
#include "md2redef.h"
 
#if METHOD3
extern int _method3;
#endif

#if !NRNGPU
#undef exp
#define exp hoc_Exp
extern double hoc_Exp(double);
#endif
 
#define nrn_init _nrn_init__P2X7
#define _nrn_initial _nrn_initial__P2X7
#define nrn_cur _nrn_cur__P2X7
#define _nrn_current _nrn_current__P2X7
#define nrn_jacob _nrn_jacob__P2X7
#define nrn_state _nrn_state__P2X7
#define _net_receive _net_receive__P2X7 
#define states states__P2X7 
 
#define _threadargscomma_ /**/
#define _threadargsprotocomma_ /**/
#define _threadargs_ /**/
#define _threadargsproto_ /**/
 	/*SUPPRESS 761*/
	/*SUPPRESS 762*/
	/*SUPPRESS 763*/
	/*SUPPRESS 765*/
	 extern double *getarg();
 static double *_p; static Datum *_ppvar;
 
#define t nrn_threads->_t
#define dt nrn_threads->_dt
#define gmax _p[0]
#define gmax_columnindex 0
#define EC50 _p[1]
#define EC50_columnindex 1
#define nHill _p[2]
#define nHill_columnindex 2
#define tau_open _p[3]
#define tau_open_columnindex 3
#define tau_close _p[4]
#define tau_close_columnindex 4
#define tau_dilate _p[5]
#define tau_dilate_columnindex 5
#define i _p[6]
#define i_columnindex 6
#define g _p[7]
#define g_columnindex 7
#define ATPo _p[8]
#define ATPo_columnindex 8
#define pore_dilated _p[9]
#define pore_dilated_columnindex 9
#define dilation_factor _p[10]
#define dilation_factor_columnindex 10
#define o _p[11]
#define o_columnindex 11
#define d _p[12]
#define d_columnindex 12
#define ica _p[13]
#define ica_columnindex 13
#define ina _p[14]
#define ina_columnindex 14
#define ik _p[15]
#define ik_columnindex 15
#define popen _p[16]
#define popen_columnindex 16
#define Do _p[17]
#define Do_columnindex 17
#define Dd _p[18]
#define Dd_columnindex 18
#define _g _p[19]
#define _g_columnindex 19
#define _ion_ica	*_ppvar[0]._pval
#define _ion_dicadv	*_ppvar[1]._pval
#define _ion_ina	*_ppvar[2]._pval
#define _ion_dinadv	*_ppvar[3]._pval
#define _ion_ik	*_ppvar[4]._pval
#define _ion_dikdv	*_ppvar[5]._pval
#define atp	*_ppvar[6]._pval
#define _p_atp	_ppvar[6]._pval
 
#if MAC
#if !defined(v)
#define v _mlhv
#endif
#if !defined(h)
#define h _mlhh
#endif
#endif
 
#if defined(__cplusplus)
extern "C" {
#endif
 static int hoc_nrnpointerindex =  6;
 /* external NEURON variables */
 /* declaration of user functions */
 static int _mechtype;
extern void _nrn_cacheloop_reg(int, int);
extern void hoc_register_prop_size(int, int, int);
extern void hoc_register_limits(int, HocParmLimits*);
extern void hoc_register_units(int, HocParmUnits*);
extern void nrn_promote(Prop*, int, int);
extern Memb_func* memb_func;
 
#define NMODL_TEXT 1
#if NMODL_TEXT
static const char* nmodl_file_text;
static const char* nmodl_filename;
extern void hoc_reg_nmodl_text(int, const char*);
extern void hoc_reg_nmodl_filename(int, const char*);
#endif

 extern void _nrn_setdata_reg(int, void(*)(Prop*));
 static void _setdata(Prop* _prop) {
 _p = _prop->param; _ppvar = _prop->dparam;
 }
 static void _hoc_setdata() {
 Prop *_prop, *hoc_getdata_range(int);
 _prop = hoc_getdata_range(_mechtype);
   _setdata(_prop);
 hoc_retpushx(1.);
}
 /* connect user functions to hoc names */
 static VoidFunc hoc_intfunc[] = {
 "setdata_P2X7", _hoc_setdata,
 0, 0
};
 /* declare global and static user variables */
#define dilation_max dilation_max_P2X7
 double dilation_max = 3;
#define dilation_threshold dilation_threshold_P2X7
 double dilation_threshold = 0.5;
#define ek ek_P2X7
 double ek = -85;
#define ena ena_P2X7
 double ena = 50;
#define eca eca_P2X7
 double eca = 120;
#define pK pK_P2X7
 double pK = 1;
#define pNa pNa_P2X7
 double pNa = 1;
#define pCa pCa_P2X7
 double pCa = 4;
 /* some parameters have upper and lower limits */
 static HocParmLimits _hoc_parm_limits[] = {
 0,0,0
};
 static HocParmUnits _hoc_parm_units[] = {
 "eca_P2X7", "mV",
 "ena_P2X7", "mV",
 "ek_P2X7", "mV",
 "gmax_P2X7", "S/cm2",
 "EC50_P2X7", "mM",
 "tau_open_P2X7", "ms",
 "tau_close_P2X7", "ms",
 "tau_dilate_P2X7", "ms",
 "i_P2X7", "mA/cm2",
 "g_P2X7", "S/cm2",
 "ATPo_P2X7", "mM",
 "atp_P2X7", "mM",
 0,0
};
 static double delta_t = 0.01;
 static double d0 = 0;
 static double o0 = 0;
 static double v = 0;
 /* connect global user variables to hoc */
 static DoubScal hoc_scdoub[] = {
 "pCa_P2X7", &pCa_P2X7,
 "pNa_P2X7", &pNa_P2X7,
 "pK_P2X7", &pK_P2X7,
 "eca_P2X7", &eca_P2X7,
 "ena_P2X7", &ena_P2X7,
 "ek_P2X7", &ek_P2X7,
 "dilation_threshold_P2X7", &dilation_threshold_P2X7,
 "dilation_max_P2X7", &dilation_max_P2X7,
 0,0
};
 static DoubVec hoc_vdoub[] = {
 0,0,0
};
 static double _sav_indep;
 static void nrn_alloc(Prop*);
static void  nrn_init(NrnThread*, _Memb_list*, int);
static void nrn_state(NrnThread*, _Memb_list*, int);
 static void nrn_cur(NrnThread*, _Memb_list*, int);
static void  nrn_jacob(NrnThread*, _Memb_list*, int);
 
static int _ode_count(int);
static void _ode_map(int, double**, double**, double*, Datum*, double*, int);
static void _ode_spec(NrnThread*, _Memb_list*, int);
static void _ode_matsol(NrnThread*, _Memb_list*, int);
 
#define _cvode_ieq _ppvar[7]._i
 static void _ode_matsol_instance1(_threadargsproto_);
 /* connect range variables in _p that hoc is supposed to know about */
 static const char *_mechanism[] = {
 "7.7.0",
"P2X7",
 "gmax_P2X7",
 "EC50_P2X7",
 "nHill_P2X7",
 "tau_open_P2X7",
 "tau_close_P2X7",
 "tau_dilate_P2X7",
 0,
 "i_P2X7",
 "g_P2X7",
 "ATPo_P2X7",
 "pore_dilated_P2X7",
 "dilation_factor_P2X7",
 0,
 "o_P2X7",
 "d_P2X7",
 0,
 "atp_P2X7",
 0};
 static Symbol* _ca_sym;
 static Symbol* _na_sym;
 static Symbol* _k_sym;
 
extern Prop* need_memb(Symbol*);

static void nrn_alloc(Prop* _prop) {
	Prop *prop_ion;
	double *_p; Datum *_ppvar;
 	_p = nrn_prop_data_alloc(_mechtype, 20, _prop);
 	/*initialize range parameters*/
 	gmax = 0.0001;
 	EC50 = 0.3;
 	nHill = 2.5;
 	tau_open = 50;
 	tau_close = 200;
 	tau_dilate = 30000;
 	_prop->param = _p;
 	_prop->param_size = 20;
 	_ppvar = nrn_prop_datum_alloc(_mechtype, 8, _prop);
 	_prop->dparam = _ppvar;
 	/*connect ionic variables to this model*/
 prop_ion = need_memb(_ca_sym);
 	_ppvar[0]._pval = &prop_ion->param[3]; /* ica */
 	_ppvar[1]._pval = &prop_ion->param[4]; /* _ion_dicadv */
 prop_ion = need_memb(_na_sym);
 	_ppvar[2]._pval = &prop_ion->param[3]; /* ina */
 	_ppvar[3]._pval = &prop_ion->param[4]; /* _ion_dinadv */
 prop_ion = need_memb(_k_sym);
 	_ppvar[4]._pval = &prop_ion->param[3]; /* ik */
 	_ppvar[5]._pval = &prop_ion->param[4]; /* _ion_dikdv */
 
}
 static void _initlists();
  /* some states have an absolute tolerance */
 static Symbol** _atollist;
 static HocStateTolerance _hoc_state_tol[] = {
 0,0
};
 static void _update_ion_pointer(Datum*);
 extern Symbol* hoc_lookup(const char*);
extern void _nrn_thread_reg(int, int, void(*)(Datum*));
extern void _nrn_thread_table_reg(int, void(*)(double*, Datum*, Datum*, NrnThread*, int));
extern void hoc_register_tolerance(int, HocStateTolerance*, Symbol***);
extern void _cvode_abstol( Symbol**, double*, int);

 void _P2X7_reg() {
	int _vectorized = 0;
  _initlists();
 	ion_reg("ca", -10000.);
 	ion_reg("na", -10000.);
 	ion_reg("k", -10000.);
 	_ca_sym = hoc_lookup("ca_ion");
 	_na_sym = hoc_lookup("na_ion");
 	_k_sym = hoc_lookup("k_ion");
 	register_mech(_mechanism, nrn_alloc,nrn_cur, nrn_jacob, nrn_state, nrn_init, hoc_nrnpointerindex, 0);
 _mechtype = nrn_get_mechtype(_mechanism[1]);
     _nrn_setdata_reg(_mechtype, _setdata);
     _nrn_thread_reg(_mechtype, 2, _update_ion_pointer);
 #if NMODL_TEXT
  hoc_reg_nmodl_text(_mechtype, nmodl_file_text);
  hoc_reg_nmodl_filename(_mechtype, nmodl_filename);
#endif
  hoc_register_prop_size(_mechtype, 20, 8);
  hoc_register_dparam_semantics(_mechtype, 0, "ca_ion");
  hoc_register_dparam_semantics(_mechtype, 1, "ca_ion");
  hoc_register_dparam_semantics(_mechtype, 2, "na_ion");
  hoc_register_dparam_semantics(_mechtype, 3, "na_ion");
  hoc_register_dparam_semantics(_mechtype, 4, "k_ion");
  hoc_register_dparam_semantics(_mechtype, 5, "k_ion");
  hoc_register_dparam_semantics(_mechtype, 6, "pointer");
  hoc_register_dparam_semantics(_mechtype, 7, "cvodeieq");
 	hoc_register_cvode(_mechtype, _ode_count, _ode_map, _ode_spec, _ode_matsol);
 	hoc_register_tolerance(_mechtype, _hoc_state_tol, &_atollist);
 	hoc_register_var(hoc_scdoub, hoc_vdoub, hoc_intfunc);
 	ivoc_help("help ?1 P2X7 P2X7.mod\n");
 hoc_register_limits(_mechtype, _hoc_parm_limits);
 hoc_register_units(_mechtype, _hoc_parm_units);
 }
static int _reset;
static char *modelname = "P2X7 Purinergic Receptor for Microglia (Improved)";

static int error;
static int _ninits = 0;
static int _match_recurse=1;
static void _modl_cleanup(){ _match_recurse=1;}
 
static int _ode_spec1(_threadargsproto_);
/*static int _ode_matsol1(_threadargsproto_);*/
 static int _slist1[2], _dlist1[2];
 static int states(_threadargsproto_);
 
/*CVODE*/
 static int _ode_spec1 () {_reset=0;
 {
   double _ltarget_o , _ltarget_d , _ltau_o ;
 if ( ATPo > 1e-6 ) {
     _ltarget_o = pow( ATPo , nHill ) / ( pow( ATPo , nHill ) + pow( EC50 , nHill ) ) ;
     }
   else {
     _ltarget_o = 0.0 ;
     }
   if ( _ltarget_o > o ) {
     _ltau_o = tau_open ;
     }
   else {
     _ltau_o = tau_close ;
     }
   Do = ( _ltarget_o - o ) / _ltau_o ;
   if ( o > dilation_threshold ) {
     _ltarget_d = 1.0 ;
     }
   else {
     _ltarget_d = 0.0 ;
     }
   Dd = ( _ltarget_d - d ) / tau_dilate ;
   }
 return _reset;
}
 static int _ode_matsol1 () {
 double _ltarget_o , _ltarget_d , _ltau_o ;
 if ( ATPo > 1e-6 ) {
   _ltarget_o = pow( ATPo , nHill ) / ( pow( ATPo , nHill ) + pow( EC50 , nHill ) ) ;
   }
 else {
   _ltarget_o = 0.0 ;
   }
 if ( _ltarget_o > o ) {
   _ltau_o = tau_open ;
   }
 else {
   _ltau_o = tau_close ;
   }
 Do = Do  / (1. - dt*( ( ( ( - 1.0 ) ) ) / _ltau_o )) ;
 if ( o > dilation_threshold ) {
   _ltarget_d = 1.0 ;
   }
 else {
   _ltarget_d = 0.0 ;
   }
 Dd = Dd  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau_dilate )) ;
  return 0;
}
 /*END CVODE*/
 static int states () {_reset=0;
 {
   double _ltarget_o , _ltarget_d , _ltau_o ;
 if ( ATPo > 1e-6 ) {
     _ltarget_o = pow( ATPo , nHill ) / ( pow( ATPo , nHill ) + pow( EC50 , nHill ) ) ;
     }
   else {
     _ltarget_o = 0.0 ;
     }
   if ( _ltarget_o > o ) {
     _ltau_o = tau_open ;
     }
   else {
     _ltau_o = tau_close ;
     }
    o = o + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / _ltau_o)))*(- ( ( ( _ltarget_o ) ) / _ltau_o ) / ( ( ( ( - 1.0 ) ) ) / _ltau_o ) - o) ;
   if ( o > dilation_threshold ) {
     _ltarget_d = 1.0 ;
     }
   else {
     _ltarget_d = 0.0 ;
     }
    d = d + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau_dilate)))*(- ( ( ( _ltarget_d ) ) / tau_dilate ) / ( ( ( ( - 1.0 ) ) ) / tau_dilate ) - d) ;
   }
  return 0;
}
 
static int _ode_count(int _type){ return 2;}
 
static void _ode_spec(NrnThread* _nt, _Memb_list* _ml, int _type) {
   Datum* _thread;
   Node* _nd; double _v; int _iml, _cntml;
  _cntml = _ml->_nodecount;
  _thread = _ml->_thread;
  for (_iml = 0; _iml < _cntml; ++_iml) {
    _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
    _nd = _ml->_nodelist[_iml];
    v = NODEV(_nd);
     _ode_spec1 ();
    }}
 
static void _ode_map(int _ieq, double** _pv, double** _pvdot, double* _pp, Datum* _ppd, double* _atol, int _type) { 
 	int _i; _p = _pp; _ppvar = _ppd;
	_cvode_ieq = _ieq;
	for (_i=0; _i < 2; ++_i) {
		_pv[_i] = _pp + _slist1[_i];  _pvdot[_i] = _pp + _dlist1[_i];
		_cvode_abstol(_atollist, _atol, _i);
	}
 }
 
static void _ode_matsol_instance1(_threadargsproto_) {
 _ode_matsol1 ();
 }
 
static void _ode_matsol(NrnThread* _nt, _Memb_list* _ml, int _type) {
   Datum* _thread;
   Node* _nd; double _v; int _iml, _cntml;
  _cntml = _ml->_nodecount;
  _thread = _ml->_thread;
  for (_iml = 0; _iml < _cntml; ++_iml) {
    _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
    _nd = _ml->_nodelist[_iml];
    v = NODEV(_nd);
 _ode_matsol_instance1(_threadargs_);
 }}
 extern void nrn_update_ion_pointer(Symbol*, Datum*, int, int);
 static void _update_ion_pointer(Datum* _ppvar) {
   nrn_update_ion_pointer(_ca_sym, _ppvar, 0, 3);
   nrn_update_ion_pointer(_ca_sym, _ppvar, 1, 4);
   nrn_update_ion_pointer(_na_sym, _ppvar, 2, 3);
   nrn_update_ion_pointer(_na_sym, _ppvar, 3, 4);
   nrn_update_ion_pointer(_k_sym, _ppvar, 4, 3);
   nrn_update_ion_pointer(_k_sym, _ppvar, 5, 4);
 }

static void initmodel() {
  int _i; double _save;_ninits++;
 _save = t;
 t = 0.0;
{
  d = d0;
  o = o0;
 {
   o = 0.0 ;
   d = 0.0 ;
   }
  _sav_indep = t; t = _save;

}
}

static void nrn_init(NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; double _v; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 v = _v;
 initmodel();
   }}

static double _nrn_current(double _v){double _current=0.;v=_v;{ {
   if ( atp > 0.0 ) {
     ATPo = atp ;
     }
   else {
     ATPo = 0.0 ;
     }
   dilation_factor = 1.0 + ( dilation_max - 1.0 ) * d ;
   pore_dilated = d ;
   g = gmax * o * dilation_factor ;
   ica = g * pCa / ( pCa + pNa + pK ) * ( v - eca ) ;
   ina = g * pNa / ( pCa + pNa + pK ) * ( v - ena ) ;
   ik = g * pK / ( pCa + pNa + pK ) * ( v - ek ) ;
   i = ica + ina + ik ;
   }
 _current += ica;
 _current += ina;
 _current += ik;

} return _current;
}

static void nrn_cur(NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; double _rhs, _v; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 _g = _nrn_current(_v + .001);
 	{ double _dik;
 double _dina;
 double _dica;
  _dica = ica;
  _dina = ina;
  _dik = ik;
 _rhs = _nrn_current(_v);
  _ion_dicadv += (_dica - ica)/.001 ;
  _ion_dinadv += (_dina - ina)/.001 ;
  _ion_dikdv += (_dik - ik)/.001 ;
 	}
 _g = (_g - _rhs)/.001;
  _ion_ica += ica ;
  _ion_ina += ina ;
  _ion_ik += ik ;
#if CACHEVEC
  if (use_cachevec) {
	VEC_RHS(_ni[_iml]) -= _rhs;
  }else
#endif
  {
	NODERHS(_nd) -= _rhs;
  }
 
}}

static void nrn_jacob(NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml];
#if CACHEVEC
  if (use_cachevec) {
	VEC_D(_ni[_iml]) += _g;
  }else
#endif
  {
     _nd = _ml->_nodelist[_iml];
	NODED(_nd) += _g;
  }
 
}}

static void nrn_state(NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; double _v = 0.0; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
 _nd = _ml->_nodelist[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 v=_v;
{
 { error =  states();
 if(error){fprintf(stderr,"at line 73 in file P2X7.mod:\n    : Get ATP concentration\n"); nrn_complain(_p); abort_run(error);}
 }   }}

}

static void terminal(){}

static void _initlists() {
 int _i; static int _first = 1;
  if (!_first) return;
 _slist1[0] = o_columnindex;  _dlist1[0] = Do_columnindex;
 _slist1[1] = d_columnindex;  _dlist1[1] = Dd_columnindex;
_first = 0;
}

#if NMODL_TEXT
static const char* nmodl_filename = "P2X7.mod";
static const char* nmodl_file_text = 
  "TITLE P2X7 Purinergic Receptor for Microglia (Improved)\n"
  ": ATP-gated cation channel P2X7\n"
  ": Includes pore dilation phenomenon\n"
  ": Critical for NLRP3 inflammasome activation and IL-1beta release\n"
  ": Based on Bhattacharjee et al. 2023, Bhattacharjee & Bhattacharjee 2024\n"
  "\n"
  "NEURON {\n"
  "    SUFFIX P2X7\n"
  "    USEION ca WRITE ica\n"
  "    USEION na WRITE ina  \n"
  "    USEION k WRITE ik\n"
  "    RANGE gmax, g, i\n"
  "    RANGE ATPo, EC50, nHill\n"
  "    RANGE pore_dilated, dilation_factor\n"
  "    RANGE tau_open, tau_close, tau_dilate\n"
  "    POINTER atp\n"
  "}\n"
  "\n"
  "UNITS {\n"
  "    (mA) = (milliamp)\n"
  "    (mV) = (millivolt)\n"
  "    (S)  = (siemens)\n"
  "    (mM) = (milli/liter)\n"
  "}\n"
  "\n"
  "PARAMETER {\n"
  "    gmax = 0.0001 (S/cm2)     : Maximum conductance (small pore)\n"
  "    EC50 = 0.3 (mM)           : ATP EC50 (~300 uM)\n"
  "    nHill = 2.5               : Hill coefficient\n"
  "    \n"
  "    : Permeability ratios (small pore state)\n"
  "    pCa = 4                   : Relative Ca permeability\n"
  "    pNa = 1                   : Relative Na permeability  \n"
  "    pK = 1                    : Relative K permeability\n"
  "    \n"
  "    : Reversal potentials\n"
  "    eca = 120 (mV)\n"
  "    ena = 50 (mV)\n"
  "    ek = -85 (mV)\n"
  "    \n"
  "    : Kinetics\n"
  "    tau_open = 50 (ms)        : Opening time constant\n"
  "    tau_close = 200 (ms)      : Closing time constant\n"
  "    tau_dilate = 30000 (ms)   : Pore dilation time constant (~30 sec)\n"
  "    \n"
  "    : Pore dilation parameters\n"
  "    dilation_threshold = 0.5  : Sustained activation needed for dilation\n"
  "    dilation_max = 3          : Max conductance increase from dilation\n"
  "}\n"
  "\n"
  "ASSIGNED {\n"
  "    v (mV)\n"
  "    atp (mM)\n"
  "    i (mA/cm2)\n"
  "    ica (mA/cm2)\n"
  "    ina (mA/cm2)\n"
  "    ik (mA/cm2)\n"
  "    g (S/cm2)\n"
  "    ATPo (mM)\n"
  "    popen\n"
  "    pore_dilated\n"
  "    dilation_factor\n"
  "}\n"
  "\n"
  "STATE {\n"
  "    o           : Channel open state\n"
  "    d           : Pore dilation state\n"
  "}\n"
  "\n"
  "BREAKPOINT {\n"
  "    SOLVE states METHOD cnexp\n"
  "    \n"
  "    : Get ATP concentration\n"
  "    if (atp > 0) {\n"
  "        ATPo = atp\n"
  "    } else {\n"
  "        ATPo = 0\n"
  "    }\n"
  "    \n"
  "    : Pore dilation increases conductance\n"
  "    dilation_factor = 1 + (dilation_max - 1) * d\n"
  "    pore_dilated = d\n"
  "    \n"
  "    g = gmax * o * dilation_factor\n"
  "    \n"
  "    : Distribute current among ions\n"
  "    : In dilated state, permeability to large molecules increases\n"
  "    : Here we simplify by just increasing total conductance\n"
  "    ica = g * pCa / (pCa + pNa + pK) * (v - eca)\n"
  "    ina = g * pNa / (pCa + pNa + pK) * (v - ena)\n"
  "    ik = g * pK / (pCa + pNa + pK) * (v - ek)\n"
  "    i = ica + ina + ik\n"
  "}\n"
  "\n"
  "INITIAL {\n"
  "    o = 0\n"
  "    d = 0\n"
  "}\n"
  "\n"
  "DERIVATIVE states {\n"
  "    LOCAL target_o, target_d, tau_o\n"
  "    \n"
  "    : Hill equation for ATP activation\n"
  "    if (ATPo > 1e-6) {\n"
  "        target_o = ATPo^nHill / (ATPo^nHill + EC50^nHill)\n"
  "    } else {\n"
  "        target_o = 0\n"
  "    }\n"
  "    \n"
  "    : Asymmetric kinetics for opening/closing\n"
  "    if (target_o > o) {\n"
  "        tau_o = tau_open\n"
  "    } else {\n"
  "        tau_o = tau_close\n"
  "    }\n"
  "    \n"
  "    o' = (target_o - o) / tau_o\n"
  "    \n"
  "    : Pore dilation occurs with sustained high activation\n"
  "    if (o > dilation_threshold) {\n"
  "        target_d = 1\n"
  "    } else {\n"
  "        target_d = 0\n"
  "    }\n"
  "    \n"
  "    : Dilation is slow and somewhat irreversible\n"
  "    d' = (target_d - d) / tau_dilate\n"
  "}\n"
  ;
#endif
