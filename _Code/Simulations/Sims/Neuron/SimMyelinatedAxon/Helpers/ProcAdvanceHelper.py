
from OtherInterModularUtils import codeContractViolation


# Our appendix to NEURON RxD that does three things on each iteration:
#   * applies the Dirichlet boundary condition "conc = ko0" for the outermost shells of axon sections except "axonUnderSchwann"
#   * crops the concentration below "self._veryMinOuterConc" to prevent negative values (which tend to bring NaN-s into simulation)
#   * copies the concentration from the outermost shells of "axonUnderSchwann" to "schwann.ko"

class ProcAdvanceHelper:
    
    # Data members added in the ctor:
    #   _axonNotUnderSchwannOuterNodesList
    #   _ko0
    #   _schwannSecsList
    #   _axonUnderSchwannOuterNodesList
    #   _allNodes
    #   _veryMinOuterConc
    
    def __init__(self, axonNotUnderSchwannOuterNodesList, ko0, schwannSecsList, axonUnderSchwannOuterNodesList, allNodes, veryMinOuterConc):
        
        self._axonNotUnderSchwannOuterNodesList = axonNotUnderSchwannOuterNodesList
        self._ko0 = ko0
        
        # Sanity check
        numSegms = sum(sec_sch.nseg for sec_sch in schwannSecsList)
        numNodes = len(axonUnderSchwannOuterNodesList)
        if numSegms != numNodes:
            codeContractViolation()
            
        self._schwannSecsList = schwannSecsList
        self._axonUnderSchwannOuterNodesList = axonUnderSchwannOuterNodesList
        
        self._allNodes = allNodes
        self._veryMinOuterConc = veryMinOuterConc
        
    # !! think about improving performance for this method, especially for the cycle by self._allNodes:
    #    we can do it in parallel (with @njit and prange) or
    #    maybe we can loop just by the boundary shells (which include the flux) 
    def onAdvance(self):
        
        # Applying the Dirichlet boundary condition "conc = ko0" for the outermost shells of axon sections except "axonUnderSchwann"
        # !! it's a workaround that we do this explicitly on each iteration
        #    (NEURON RxD doesn't support "ecs_boundary_conditions" arg in "rxd.Species" ctor for radial diffusion)
        for node_ax in self._axonNotUnderSchwannOuterNodesList:
            node_ax.concentration = self._ko0
            
        # Cropping the concentration below "veryMinOuterConc" to prevent negative values (which tend to bring NaN-s into simulation)
        for node in self._allNodes:
            if node.concentration < self._veryMinOuterConc:
                node.concentration = self._veryMinOuterConc
                
        # Copying the concentration from the outermost shells of "axonUnderSchwann" to "schwann.ko"
        nodeIdx_ax = 0
        for sec_sch in self._schwannSecsList:
            for segm_sch in sec_sch:
                segm_sch.ko = self._axonUnderSchwannOuterNodesList[nodeIdx_ax].concentration
                nodeIdx_ax += 1
                
    def cleanup(self):
        
        self._axonNotUnderSchwannOuterNodesList = None
        self._axonUnderSchwannOuterNodesList = None
        self._allNodes = None
        