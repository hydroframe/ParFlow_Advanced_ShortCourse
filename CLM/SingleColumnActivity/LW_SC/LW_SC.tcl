# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

set runname [format "LW_SC"]
puts $runname

set stopt 2184.0
puts $stopt

file copy -force "../narr_1hr.txt" .
file copy -force "../LW_Loam_SU.out.press.00006.pfb" .
file copy -force "../stomataSA.rst.00000.0" .

#-----------------------------------------------------------------------------
# File input version number
#-----------------------------------------------------------------------------
pfset FileVersion 4

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

#pfset Process.Topology.P        [lindex $argv 0]
#pfset Process.Topology.Q        [lindex $argv 1]
#pfset Process.Topology.R        [lindex $argv 2]

pfset Process.Topology.P        1
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                0.0
pfset ComputationalGrid.Lower.Y                0.0
pfset ComputationalGrid.Lower.Z                0.0

pfset ComputationalGrid.DX	                 2.0
pfset ComputationalGrid.DY                     2.0 
pfset ComputationalGrid.DZ	                 0.1

pfset ComputationalGrid.NX                     1
pfset ComputationalGrid.NY                     1
pfset ComputationalGrid.NZ                     100 

set nx [pfget ComputationalGrid.NX]
set dx [pfget ComputationalGrid.DX]
set ny [pfget ComputationalGrid.NY]
set dy [pfget ComputationalGrid.DY]
set nz [pfget ComputationalGrid.NZ]
set dz [pfget ComputationalGrid.DZ]

#-----------------------------------------------------------------------------
# The Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names "domain_input"

#-----------------------------------------------------------------------------
# Domain Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.domain_input.InputType            Box
pfset GeomInput.domain_input.GeomName             domain

#-----------------------------------------------------------------------------
# Domain Geometry
#-----------------------------------------------------------------------------
pfset Geom.domain.Lower.X                        0.0 
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0

pfset Geom.domain.Upper.X                         [expr ($nx * $dx)]
pfset Geom.domain.Upper.Y                         [expr ($ny * $dy)]
pfset Geom.domain.Upper.Z                         [expr ($nz * $dz)]

pfset Geom.domain.Patches  "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names "domain"

pfset Geom.domain.Perm.Type            Constant
pfset Geom.domain.Perm.Value           0.04465

pfset Perm.TensorType               TensorByGeom

pfset Geom.Perm.TensorByGeom.Names  "domain"

pfset Geom.domain.Perm.TensorValX  1.0
pfset Geom.domain.Perm.TensorValY  1.0
pfset Geom.domain.Perm.TensorValZ  1.0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
# specific storage does not figure into the impes (fully sat) case but we still
# need a key for it

pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "domain"
pfset Geom.domain.SpecificStorage.Value 1.0e-4

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	        Constant
pfset Phase.water.Density.Value	1.0

pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names			""


#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				1.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------
 
pfset TimingInfo.BaseUnit        1.0
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        $stopt
pfset TimingInfo.DumpInterval    1.0
pfset TimeStep.Type              Constant
pfset TimeStep.Value             1.0
 

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames      domain

pfset Geom.domain.Porosity.Type    Constant
pfset Geom.domain.Porosity.Value   0.512

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------
pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Mobility
#-----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
 
pfset Phase.RelPerm.Type               VanGenuchten
pfset Phase.RelPerm.GeomNames          "domain"
 
pfset Geom.domain.RelPerm.Alpha         4.0738
pfset Geom.domain.RelPerm.N             2.19

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type              VanGenuchten 
pfset Phase.Saturation.GeomNames         "domain"
 
pfset Geom.domain.Saturation.Alpha        4.0738
pfset Geom.domain.Saturation.N            2.19
pfset Geom.domain.Saturation.SRes         0.11
pfset Geom.domain.Saturation.SSat         1.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names ""


#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names constant
pfset Cycle.constant.Names		"alltime"
pfset Cycle.constant.alltime.Length	 1
pfset Cycle.constant.Repeat		-1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]
 
pfset Patch.x-lower.BCPressure.Type                   FluxConst
pfset Patch.x-lower.BCPressure.Cycle                  "constant"
pfset Patch.x-lower.BCPressure.alltime.Value          0.0
 
pfset Patch.y-lower.BCPressure.Type                   FluxConst
pfset Patch.y-lower.BCPressure.Cycle                  "constant"
pfset Patch.y-lower.BCPressure.alltime.Value          0.0
 
pfset Patch.z-lower.BCPressure.Type                   FluxConst
pfset Patch.z-lower.BCPressure.Cycle                  "constant"
pfset Patch.z-lower.BCPressure.alltime.Value          0.0
 
pfset Patch.x-upper.BCPressure.Type                   FluxConst
pfset Patch.x-upper.BCPressure.Cycle                  "constant"
pfset Patch.x-upper.BCPressure.alltime.Value          0.0
 
pfset Patch.y-upper.BCPressure.Type                   FluxConst
pfset Patch.y-upper.BCPressure.Cycle                  "constant"
pfset Patch.y-upper.BCPressure.alltime.Value          0.0
 
pfset Patch.z-upper.BCPressure.Type                   OverlandFlow
#pfset Patch.z-upper.BCPressure.Type                FluxConst 
pfset Patch.z-upper.BCPressure.Cycle                  "constant"
pfset Patch.z-upper.BCPressure.alltime.Value          0.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
 
pfset TopoSlopesX.Type "Constant"
pfset TopoSlopesX.GeomNames "domain"
pfset TopoSlopesX.Geom.domain.Value 0.005
 
#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------
 
pfset TopoSlopesY.Type "Constant"
pfset TopoSlopesY.GeomNames "domain"
pfset TopoSlopesY.Geom.domain.Value 0.00
 
#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------
 
pfset Mannings.Type "Constant"
pfset Mannings.GeomNames "domain"
pfset Mannings.Geom.domain.Value 1e-6

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value        0.0
 
#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
 
pfset KnownSolution                                      NoKnownSolution

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------
 
pfset Solver                                             Richards
pfset Solver.MaxIter                                     55000
 
pfset Solver.Nonlinear.MaxIter                           100
pfset Solver.Nonlinear.ResidualTol                       1e-9
pfset Solver.Nonlinear.EtaChoice                         Walker1
pfset Solver.Nonlinear.EtaValue                          0.01
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-12
pfset Solver.Nonlinear.StepTol                           1e-20
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      100
pfset Solver.Linear.MaxRestarts                          5

pfset Solver.Linear.Preconditioner.PCMatrixType          FullJacobian
 
pfset Solver.Linear.Preconditioner                       PFMG
#pfset Solver.Linear.Preconditioner.MGSemi.MaxIter        1
#pfset Solver.Linear.Preconditioner.MGSemi.MaxLevels      10
pfset Solver.PrintSubsurf                                False
pfset Solver.Drop                                        1E-20
pfset Solver.AbsTol                                      1E-9
 
pfset Solver.LSM                                         CLM
pfset Solver.WriteSiloCLM                                True
pfset Solver.CLM.MetForcing                              1D
pfset Solver.CLM.MetFileName                             narr_1hr.txt
pfset Solver.CLM.MetFilePath                             ./

#pfset Solver.TerrainFollowingGrid                       True
pfset Solver.CLM.EvapBeta                             Linear

#Writing output: PFB only no SILO
pfset Solver.PrintSubsurfData                         True 
pfset Solver.PrintPressure                            False
pfset Solver.PrintSaturation                          False
pfset Solver.PrintCLM                                 True
pfset Solver.PrintMask                                True 
pfset Solver.PrintSpecificStorage                      True 

#pfset Solver.WriteSiloSpecificStorage                 True
pfset Solver.WriteSiloMannings                        False
pfset Solver.WriteSiloMask                            False
pfset Solver.WriteSiloSlopes                          False
#pfset Solver.WriteSiloSubsurfData                     True
#pfset Solver.WriteSiloPressure                        True
pfset Solver.WriteSiloSaturation                      False
#pfset Solver.WriteSiloEvapTrans                       True
#pfset Solver.WriteSiloEvapTransSum                    True
#pfset Solver.WriteSiloOverlandSum                     True 
#pfset Solver.WriteSiloCLM                             True
#pfset Solver.WriteSiloOverlandBCFlux                  True

pfset Solver.PrintLSMSink                               False
pfset Solver.CLM.CLMDumpInterval                        1
pfset Solver.CLM.CLMFileDir                             "output/"
pfset Solver.CLM.BinaryOutDir                           False
pfset Solver.CLM.IstepStart                             1
pfset Solver.WriteCLMBinary                             False
pfset Solver.WriteSiloCLM                               False

pfset Solver.CLM.WriteLogs				False
pfset Solver.CLM.WriteLastRST				True
pfset Solver.CLM.DailyRST				False
pfset Solver.CLM.SingleFile				True

# Initial conditions: water pressure
#---------------------------------------------------------
 
#pfset ICPressure.Type                                   HydroStaticPatch
#pfset ICPressure.GeomNames                              domain
#pfset Geom.domain.ICPressure.Value                      -1.0
 
#pfset Geom.domain.ICPressure.RefGeom                    domain
#pfset Geom.domain.ICPressure.RefPatch                   z-upper

pfset ICPressure.Type                                   PFBFile
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.FileName                   "LW_Loam_SU.out.press.00006.pfb"
pfdist "LW_Loam_SU.out.press.00006.pfb"

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfrun $runname
pfundist $runname

for {set k 1} {$k <=$stopt} {incr k} {
   set outfile1 [format "%s.out.clm_output.%05d.C.pfb" $runname $k]
   pfundist $outfile1
}