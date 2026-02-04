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
 
#define nrn_init _nrn_init__P2Y12
#define _nrn_initial _nrn_initial__P2Y12
#define nrn_cur _nrn_cur__P2Y12
#define _nrn_current _nrn_current__P2Y12
#define nrn_jacob _nrn_jacob__P2Y12
#define nrn_state _nrn_state__P2Y12
#define _net_receive _net_receive__P2Y12 
#define states states__P2Y12 
 
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
#define EC50 _p[0]
#define EC50_columnindex 0
#define ADPo _p[1]
#define ADPo_columnindex 1
#define chemotaxis_signal _p[2]
#define chemotaxis_signal_columnindex 2
#define activation _p[3]
#define activation_columnindex 3
#define Dactivation _p[4]
#define Dactivation_columnindex 4
#define _g _p[5]
#define _g_columnindex 5
#define adp	*_ppvar[0]._pval
#define _p_adp	_ppvar[0]._pval
 
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
 static int hoc_nrnpointerindex =  0;
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
 "setdata_P2Y12", _hoc_setdata,
 0, 0
};
 /* declare global and static user variables */
#define nHill nHill_P2Y12
 double nHill = 1.5;
#define tau_deact tau_deact_P2Y12
 double tau_deact = 5000;
#define tau_act tau_act_P2Y12
 double tau_act = 1000;
 /* some parameters have upper and lower limits */
 static HocParmLimits _hoc_parm_limits[] = {
 0,0,0
};
 static HocParmUnits _hoc_parm_units[] = {
 "tau_act_P2Y12", "ms",
 "tau_deact_P2Y12", "ms",
 "EC50_P2Y12", "mM",
 "ADPo_P2Y12", "mM",
 "adp_P2Y12", "mM",
 0,0
};
 static double activation0 = 0;
 static double delta_t = 0.01;
 static double v = 0;
 /* connect global user variables to hoc */
 static DoubScal hoc_scdoub[] = {
 "nHill_P2Y12", &nHill_P2Y12,
 "tau_act_P2Y12", &tau_act_P2Y12,
 "tau_deact_P2Y12", &tau_deact_P2Y12,
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
 
#define _cvode_ieq _ppvar[1]._i
 static void _ode_matsol_instance1(_threadargsproto_);
 /* connect range variables in _p that hoc is supposed to know about */
 static const char *_mechanism[] = {
 "7.7.0",
"P2Y12",
 "EC50_P2Y12",
 0,
 "ADPo_P2Y12",
 "chemotaxis_signal_P2Y12",
 0,
 "activation_P2Y12",
 0,
 "adp_P2Y12",
 0};
 
extern Prop* need_memb(Symbol*);

static void nrn_alloc(Prop* _prop) {
	Prop *prop_ion;
	double *_p; Datum *_ppvar;
 	_p = nrn_prop_data_alloc(_mechtype, 6, _prop);
 	/*initialize range parameters*/
 	EC50 = 0.001;
 	_prop->param = _p;
 	_prop->param_size = 6;
 	_ppvar = nrn_prop_datum_alloc(_mechtype, 2, _prop);
 	_prop->dparam = _ppvar;
 	/*connect ionic variables to this model*/
 
}
 static void _initlists();
  /* some states have an absolute tolerance */
 static Symbol** _atollist;
 static HocStateTolerance _hoc_state_tol[] = {
 0,0
};
 extern Symbol* hoc_lookup(const char*);
extern void _nrn_thread_reg(int, int, void(*)(Datum*));
extern void _nrn_thread_table_reg(int, void(*)(double*, Datum*, Datum*, NrnThread*, int));
extern void hoc_register_tolerance(int, HocStateTolerance*, Symbol***);
extern void _cvode_abstol( Symbol**, double*, int);

 void _P2Y12_reg() {
	int _vectorized = 0;
  _initlists();
 	register_mech(_mechanism, nrn_alloc,nrn_cur, nrn_jacob, nrn_state, nrn_init, hoc_nrnpointerindex, 0);
 _mechtype = nrn_get_mechtype(_mechanism[1]);
     _nrn_setdata_reg(_mechtype, _setdata);
 #if NMODL_TEXT
  hoc_reg_nmodl_text(_mechtype, nmodl_file_text);
  hoc_reg_nmodl_filename(_mechtype, nmodl_filename);
#endif
  hoc_register_prop_size(_mechtype, 6, 2);
  hoc_register_dparam_semantics(_mechtype, 0, "pointer");
  hoc_register_dparam_semantics(_mechtype, 1, "cvodeieq");
 	hoc_register_cvode(_mechtype, _ode_count, _ode_map, _ode_spec, _ode_matsol);
 	hoc_register_tolerance(_mechtype, _hoc_state_tol, &_atollist);
 	hoc_register_var(hoc_scdoub, hoc_vdoub, hoc_intfunc);
 	ivoc_help("help ?1 P2Y12 P2Y12.mod\n");
 hoc_register_limits(_mechtype, _hoc_parm_limits);
 hoc_register_units(_mechtype, _hoc_parm_units);
 }
static int _reset;
static char *modelname = "P2Y12 Purinergic Receptor for Microglia";

static int error;
static int _ninits = 0;
static int _match_recurse=1;
static void _modl_cleanup(){ _match_recurse=1;}
 
static int _ode_spec1(_threadargsproto_);
/*static int _ode_matsol1(_threadargsproto_);*/
 static int _slist1[1], _dlist1[1];
 static int states(_threadargsproto_);
 
/*CVODE*/
 static int _ode_spec1 () {_reset=0;
 {
   double _ltarget , _ltau ;
 _ltarget = pow( ADPo , nHill ) / ( pow( ADPo , nHill ) + pow( EC50 , nHill ) ) ;
   if ( _ltarget > activation ) {
     _ltau = tau_act ;
     }
   else {
     _ltau = tau_deact ;
     }
   Dactivation = ( _ltarget - activation ) / _ltau ;
   }
 return _reset;
}
 static int _ode_matsol1 () {
 double _ltarget , _ltau ;
 _ltarget = pow( ADPo , nHill ) / ( pow( ADPo , nHill ) + pow( EC50 , nHill ) ) ;
 if ( _ltarget > activation ) {
   _ltau = tau_act ;
   }
 else {
   _ltau = tau_deact ;
   }
 Dactivation = Dactivation  / (1. - dt*( ( ( ( - 1.0 ) ) ) / _ltau )) ;
  return 0;
}
 /*END CVODE*/
 static int states () {_reset=0;
 {
   double _ltarget , _ltau ;
 _ltarget = pow( ADPo , nHill ) / ( pow( ADPo , nHill ) + pow( EC50 , nHill ) ) ;
   if ( _ltarget > activation ) {
     _ltau = tau_act ;
     }
   else {
     _ltau = tau_deact ;
     }
    activation = activation + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / _ltau)))*(- ( ( ( _ltarget ) ) / _ltau ) / ( ( ( ( - 1.0 ) ) ) / _ltau ) - activation) ;
   }
  return 0;
}
 
static int _ode_count(int _type){ return 1;}
 
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
	for (_i=0; _i < 1; ++_i) {
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

static void initmodel() {
  int _i; double _save;_ninits++;
 _save = t;
 t = 0.0;
{
  activation = activation0;
 {
   activation = 0.0 ;
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

static double _nrn_current(double _v){double _current=0.;v=_v;{
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
 if(error){fprintf(stderr,"at line 37 in file P2Y12.mod:\n    : ADP concentration\n"); nrn_complain(_p); abort_run(error);}
 } {
   if ( adp > 0.0 ) {
     ADPo = adp ;
     }
   else {
     ADPo = 0.0 ;
     }
   chemotaxis_signal = activation ;
   }
}}

}

static void terminal(){}

static void _initlists() {
 int _i; static int _first = 1;
  if (!_first) return;
 _slist1[0] = activation_columnindex;  _dlist1[0] = Dactivation_columnindex;
_first = 0;
}

#if NMODL_TEXT
static const char* nmodl_filename = "P2Y12.mod";
static const char* nmodl_file_text = 
  "TITLE P2Y12 Purinergic Receptor for Microglia\n"
  ": ADP-activated G-protein coupled receptor\n"
  ": Essential for microglial chemotaxis and process extension toward injury\n"
  ": Homeostatic microglia marker\n"
  "\n"
  "NEURON {\n"
  "    SUFFIX P2Y12\n"
  "    RANGE ADPo, EC50, activation\n"
  "    RANGE chemotaxis_signal\n"
  "    POINTER adp  : External ADP concentration\n"
  "}\n"
  "\n"
  "UNITS {\n"
  "    (mM) = (milli/liter)\n"
  "}\n"
  "\n"
  "PARAMETER {\n"
  "    EC50 = 0.001 (mM)      : ADP EC50 (1 uM typical)\n"
  "    nHill = 1.5            : Hill coefficient\n"
  "    tau_act = 1000 (ms)    : Activation time constant\n"
  "    tau_deact = 5000 (ms)  : Deactivation time constant\n"
  "}\n"
  "\n"
  "ASSIGNED {\n"
  "    adp (mM)\n"
  "    ADPo (mM)\n"
  "    chemotaxis_signal      : Output signal for process extension\n"
  "}\n"
  "\n"
  "STATE {\n"
  "    activation             : Receptor activation level (0-1)\n"
  "}\n"
  "\n"
  "BREAKPOINT {\n"
  "    SOLVE states METHOD cnexp\n"
  "    \n"
  "    : ADP concentration\n"
  "    if (adp > 0) {\n"
  "        ADPo = adp\n"
  "    } else {\n"
  "        ADPo = 0\n"
  "    }\n"
  "    \n"
  "    : Chemotaxis signal proportional to activation\n"
  "    chemotaxis_signal = activation\n"
  "}\n"
  "\n"
  "INITIAL {\n"
  "    activation = 0\n"
  "}\n"
  "\n"
  "DERIVATIVE states {\n"
  "    LOCAL target, tau\n"
  "    \n"
  "    : Hill equation for ADP activation\n"
  "    target = ADPo^nHill / (ADPo^nHill + EC50^nHill)\n"
  "    \n"
  "    : Asymmetric kinetics\n"
  "    if (target > activation) {\n"
  "        tau = tau_act\n"
  "    } else {\n"
  "        tau = tau_deact\n"
  "    }\n"
  "    \n"
  "    activation' = (target - activation) / tau\n"
  "}\n"
  ;
#endif
