
# !! Qs:
#   * why are the Graph-s different from run to run?
#   * would it make sense to split the method "_cacheData" into two stages:
#     caching segm centre coords and "_ref_i_cap" on "show", then caching "factor" on "preRun"?

# !! TODOs:
#   * maybe create some "arrayCache" helper class and object with all arrays, list and "cleanup" method (just for encapsulation)
#   * check if "View = plot" makes the process much slower on late iterations


# LFP equation adaptation:
#   
#   potential[uV] =
#       = I[uA] / (4*pi * sigma[uS/m] * dist[m]) =
#       = 1e3 I[mA] / (4*pi * 1e6 sigma[S/m] * dist[m]) =
#       = 1e-3 I[mA] / (4*pi * sigma[S/m] * dist[m]) =
#       = 1e-3 i_cap[mA/cm2] * area[cm2] / (4*pi * sigma[S/m] * 1e-6 dist[um]) =
#       = 1e3 i_cap[mA/cm2] * area[cm2] / (4*pi * sigma[S/m] * dist[um]) =
#       = 1e3 i_cap[mA/cm2] * 1e-8 * area[um2] / (4*pi * sigma[S/m] * dist[um]) =
#       = 1e-5 i_cap[mA/cm2] * area[um2] / (4*pi * sigma[S/m] * dist[um]) =
#       = 1e-5/(4*pi) i_cap[mA/cm2] * area[um2] / (sigma[S/m] * dist[um]) =
#       = const * i_cap[mA/cm2] * area[um2] / sigma[S/m] / dist[um] =
#       = factor * i_cap[mA/cm2]


from neuron import h

import math
import numpy as np          # This one is installed with Anaconda by default (but without cudatoolkit) ...

try:
    import cupy as cp       # ... and this one is NOT installed by default
except ModuleNotFoundError:
    pass
    
from XpuUtils import xpuUtils

from OtherInterModularUtils import isNanoGeometrySection, codeContractViolation


class LFPCalculator:
    
    _minDist = 1e-6                             # (um) tolerance
    
    _const = 1e-5 / 4 / h.PI                    # (unitless) phys/units const
    
    # Data member added in "setListOfPts":
    #   _listOfPts                              # (list of h.ObservationPoint)
    
    # Data members added in "onPreRun":
    #   _sigma                                  # (S/m)
    #   _isGpuOrCpu                             # (bool)
    #   _isPrinted                              # (bool)
    
    # Data members added in "_cacheData":
    #   _srcPtIdx_to_ptrSegmRefICap             # (list of h.Pointer)
    #   _x_srcPtIdxAndDstPtIdx_to_factor        # (numpy.ndarray OR cupy.ndarray)
    
    # Data members added in "_allocateArrays":
    #   _icap, _pot                             # (numpy.ndarray)
    #   _d_icap, _d_pot                         # (cupy.ndarray)
    
    
    def setListOfPts(self, listOfPts):
        self._listOfPts = listOfPts
        
    def onPreRun(self, sigma, isSkipNanoSects, isGpuOrCpu):
        
        # !! instead of doing this assignment, maybe have them in self._calc only
        self._sigma = sigma
        self._isGpuOrCpu = isGpuOrCpu
        
        mt = h.MechanismType(0)     # 0: "Distributed Membrane Mechanisms"
        mt.select('capacitance')
        
        numSrcPts = 0
        
        # We'll read "i_cap", so need to insert "capacitance" everywhere
        for sec in h.allsec():
            
            if isSkipNanoSects and isNanoGeometrySection(str(sec)):
                continue
                
            # sec.insert(h.capacitance)     # "TypeError: Cannot access capacitance (NEURON type 312) directly." (even though works fine for other mechs)
            # h.capacitance.insert(sec)     # (the same error msg)
            # sec.insert('capacitance')     # "ValueError: argument not a density mechanism name." (looks like NEURON gives a misleading error msg)
            # h.execute(f'{sec} insert capacitance')    # "syntax error ... {<ExtraCell.ExtraCell object at 0x000001F0EF525EB0>.soma[0] insert capacitance}"
            
            mt.make(sec=sec)                            # Works fine
            
            numSrcPts += sec.nseg
            
        if h.mmIcrHelper:   # !! can be nil in tests
            h.mmIcrHelper.scheduleRescan(2)     # !! ideally, schedule rescan of "capacitance" in subset of sects
            
        # Caching "factor" matrix and "_ref_i_cap" list
        self._cacheData(isSkipNanoSects, isGpuOrCpu, numSrcPts, self._listOfPts)
        
        # Creating arrays for "i_cap" and "potential"
        numDstPts = len(self._listOfPts)
        self._allocateArrays(isGpuOrCpu, numSrcPts, numDstPts)
        
        # !! can we avoid the jump at the beginning of each Graph?
        for pt in self._listOfPts:
            # i_cap = 0 => LFP = 0
            pt.theValue = 0
            
        self._isPrinted = False
        
        return False
        
    def onAdvance(self):
        
        numSrcPts = len(self._srcPtIdx_to_ptrSegmRefICap)
        numDstPts = len(self._listOfPts)
        
        if not self._isPrinted:
            xpuUtils.printMsgOnCalcStart('local field potential', numSrcPts, numDstPts, self._isGpuOrCpu)
            self._isPrinted = True
            
        for srcPtIdx in range(numSrcPts):
            self._icap[srcPtIdx] = self._srcPtIdx_to_ptrSegmRefICap[srcPtIdx].val
            
        # Here is the core operation for the entire simulation
        if self._isGpuOrCpu:
            self._d_icap.set(self._icap)
            cp.dot(self._d_icap, self._x_srcPtIdxAndDstPtIdx_to_factor, out=self._d_pot)
            self._d_pot.get(out=self._pot)
        else:
            np.dot(self._icap, self._x_srcPtIdxAndDstPtIdx_to_factor, out=self._pot)
            
        for pt, pot in zip(self._listOfPts, self._pot):
            pt.theValue = pot
            
    def cleanup(self, isDestroyListOfPts):
        
        if isDestroyListOfPts:
            self._listOfPts = None
            
        self._srcPtIdx_to_ptrSegmRefICap = None
        self._x_srcPtIdxAndDstPtIdx_to_factor = None
        self._icap = None
        self._pot = None
        self._d_icap = None
        self._d_pot = None
        
    # All next staff is private
    
    
    # Caching "factor" matrix and "_ref_i_cap" list
    # !! some code dup. with IntGapJuncPtrSeedingHelper.cacheAllSegms3DCoords
    def _cacheData(self, isSkipNanoSects, isGpuOrCpu, numSrcPts, listOfPts):
        
        numDstPts = len(listOfPts)
        
        srcPtIdx_to_ptrSegmRefICap = [None] * numSrcPts
        
        srcPtIdxAndDstPtIdx_to_factor = np.empty((numSrcPts, numDstPts))
        
        xSegm_vec = h.Vector()
        ySegm_vec = h.Vector()
        zSegm_vec = h.Vector()
        
        srcPtIdx = 0
        
        for sec in h.allsec():
            
            if isSkipNanoSects and isNanoGeometrySection(str(sec)):
                continue
                
            h.interpEachSegmCentreCoordsFromSec3DPointCoords_CalledFromPython(h.SectionRef(sec), xSegm_vec, ySegm_vec, zSegm_vec)
            
            for segmLocalIdx in range(sec.nseg):
                
                arc = (0.5 + segmLocalIdx) / sec.nseg
                segm = sec(arc)
                
                srcPtIdx_to_ptrSegmRefICap[srcPtIdx] = h.Pointer(segm._ref_i_cap)
                
                segmArea = segm.area()
                
                for dstPtIdx, pt in enumerate(listOfPts):
                    
                    # !! see also hoc:_getDistBetweenTwo3DPoints
                    dist = math.sqrt(h.math.sumSq(
                        xSegm_vec[segmLocalIdx] - pt.x,
                        ySegm_vec[segmLocalIdx] - pt.y,
                        zSegm_vec[segmLocalIdx] - pt.z))
                        
                    # Avoiding division by zero
                    if dist < self._minDist:
                        dist = self._minDist
                        
                    srcPtIdxAndDstPtIdx_to_factor[srcPtIdx, dstPtIdx] = self._const * segmArea / self._sigma / dist
                    
                srcPtIdx += 1
                
        if srcPtIdx != numSrcPts:
            codeContractViolation()
            
        self._srcPtIdx_to_ptrSegmRefICap = srcPtIdx_to_ptrSegmRefICap
        
        if isGpuOrCpu:
            srcPtIdxAndDstPtIdx_to_factor = cp.array(srcPtIdxAndDstPtIdx_to_factor)
        self._x_srcPtIdxAndDstPtIdx_to_factor = srcPtIdxAndDstPtIdx_to_factor
        
    def _allocateArrays(self, isGpuOrCpu, numSrcPts, numDstPts):
        
        # Creating array(s) for "i_cap"
        size = (numSrcPts)
        self._icap = np.empty(size)
        if isGpuOrCpu:
            self._d_icap = cp.empty(size)
            
        # Creating array(s) for "potential"
        size = (numDstPts)
        self._pot = np.empty(size)
        if isGpuOrCpu:
            self._d_pot = cp.empty(size)
            