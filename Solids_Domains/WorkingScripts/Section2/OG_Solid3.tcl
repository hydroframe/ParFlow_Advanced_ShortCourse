lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*
pfset FileVersion 4
#--------------------------------------------------------------------------------------
#
# Boxy solid example for an orthogonal, changes solid geometry to be a wedge
#
# Nick Engdahl (nick.engdahl@wsu.edu)
#
#--------------------------------------------------------------------------------------

set runname wedgy_patch

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

pfset Process.Topology.P        2
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                	0.0
pfset ComputationalGrid.Lower.Y                	0.0
pfset ComputationalGrid.Lower.Z                	0.0

pfset ComputationalGrid.DX	                    1.0
pfset ComputationalGrid.DY                 		1.0
pfset ComputationalGrid.DZ	               		1.0

pfset ComputationalGrid.NX                      20
pfset ComputationalGrid.NY                      10
pfset ComputationalGrid.NZ                      8

#-----------------------------------------------------------------------------
# The Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names "box1_input"

pfset GeomInput.box1_input.InputType  SolidFile
pfset GeomInput.box1_input.GeomNames  box1

pfset GeomInput.box1_input.FileName   "YOUR_FILE_NAME_HERE"
pfset GeomInput.box1_input.FileName   Wedge.pfsol
pfset Geom.box1.Patches "bottom_d top_d left_d right_d front_d back_d"

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName                box1

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names              "box1"

pfset Geom.box1.Perm.Type              Constant
pfset Geom.box1.Perm.Value             1.0

pfset Perm.TensorType               TensorByGeom
pfset Geom.Perm.TensorByGeom.Names  "box1"
pfset Geom.box1.Perm.TensorValX  1.0
pfset Geom.box1.Perm.TensorValY  1.0
pfset Geom.box1.Perm.TensorValZ  1.0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "box1"
pfset Geom.box1.SpecificStorage.Value 1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------
pfset Phase.Names                       "water"
pfset Phase.water.Density.Type	        Constant
pfset Phase.water.Density.Value	        1.0
pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names			""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------
pfset Gravity			       1.0

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
pfset Geom.Porosity.GeomNames         "box1"
pfset Geom.box1.Porosity.Type       Constant
pfset Geom.box1.Porosity.Value      0.1

#-----------------------------------------------------------------------------
# Mobility
#-----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#---------------------------------------------------------
# Saturation and Relative Permeability
#---------------------------------------------------------
pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames		"box1"
pfset Phase.RelPerm.Type            VanGenuchten
pfset Phase.RelPerm.GeomNames       	 "box1"


pfset Geom.box1.Saturation.Alpha           6.0
pfset Geom.box1.Saturation.N               2.0
pfset Geom.box1.Saturation.SRes            0.2
pfset Geom.box1.Saturation.SSat            1.0

pfset Geom.box1.RelPerm.Alpha        6.0
pfset Geom.box1.RelPerm.N            2.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                   ""

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------
pfset TimingInfo.BaseUnit               1
pfset TimingInfo.StartCount             0.0
pfset TimingInfo.StartTime              0.0
pfset TimingInfo.StopTime               12.0
pfset TimingInfo.DumpInterval           1
pfset TimeStep.Type                     Constant
pfset TimeStep.Value                    1.0

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------

pfset Cycle.Names                       "constant rainrec"
pfset Cycle.constant.Names                 "alltime"
pfset Cycle.constant.alltime.Length         1
pfset Cycle.constant.Repeat                -1

# rainfall and recession time periods are defined here
# rain for 3 hour, recession for 9 hours
pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           3
pfset Cycle.rainrec.rec.Length            9
pfset Cycle.rainrec.Repeat                1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
# All the other boundaries are zero flux so only the top needs to be defined
pfset BCPressure.PatchNames                     "top_d"
pfset BCPressure.PatchNames         "bottom_d top_d left_d right_d front_d back_d"

pfset Patch.top_d.BCPressure.Type               OverlandFlow
pfset Patch.top_d.BCPressure.Type               FluxConst
pfset Patch.top_d.BCPressure.Cycle				"rainrec"
# pfset Patch.top_d.BCPressure.rain.Value			-0.055
pfset Patch.top_d.BCPressure.rain.Value			0.0
pfset Patch.top_d.BCPressure.rec.Value			0.0

pfset Patch.bottom_d.BCPressure.Type                FluxConst
pfset Patch.bottom_d.BCPressure.Cycle				"constant"
pfset Patch.bottom_d.BCPressure.alltime.Value		0.0

pfset Patch.front_d.BCPressure.Type                FluxConst
pfset Patch.front_d.BCPressure.Cycle				"constant"
pfset Patch.front_d.BCPressure.alltime.Value		0.0

pfset Patch.back_d.BCPressure.Type                FluxConst
pfset Patch.back_d.BCPressure.Cycle				"constant"
pfset Patch.back_d.BCPressure.alltime.Value		0.0

pfset Patch.left_d.BCPressure.Type                FluxConst
pfset Patch.left_d.BCPressure.Cycle				"constant"
pfset Patch.left_d.BCPressure.alltime.Value		0.0

pfset Patch.left_d.BCPressure.Type                FluxConst
pfset Patch.left_d.BCPressure.Cycle				"constant"
pfset Patch.left_d.BCPressure.alltime.Value		0.0

pfset Patch.right_d.BCPressure.Type		      DirEquilRefPatch
pfset Patch.right_d.BCPressure.Cycle		      "constant"
pfset Patch.right_d.BCPressure.RefGeom    	box1
pfset Patch.right_d.BCPressure.RefPatch    	bottom_d
pfset Patch.right_d.BCPressure.alltime.Value  2.0

# pfset Patch.left_d.BCPressure.Type		      DirEquilRefPatch
# pfset Patch.left_d.BCPressure.Cycle		      "constant"
# pfset Patch.left_d.BCPressure.RefGeom    		box1
# pfset Patch.left_d.BCPressure.RefPatch    	bottom_d
# pfset Patch.left_d.BCPressure.alltime.Value  2.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
pfset TopoSlopesX.Type                 "Constant"
pfset TopoSlopesX.GeomNames            "box1"
pfset TopoSlopesX.Geom.box1.Value    0.15

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------
pfset TopoSlopesY.Type                 "Constant"
pfset TopoSlopesY.GeomNames            "box1"
pfset TopoSlopesY.Geom.box1.Value    0.0

#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------
pfset Mannings.Type                    "Constant"
pfset Mannings.GeomNames               "box1"
pfset Mannings.Geom.box1.Value       1e-6

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    box1
pfset PhaseSources.water.Geom.box1.Value            0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
pfset KnownSolution                                    NoKnownSolution

#-----------------------------------------------------------------------------
# Initial conditions: water pressure
#-----------------------------------------------------------------------------
# start this with a totally dry domain
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              box1
pfset Geom.box1.ICPressure.Value                      4.0
pfset Geom.box1.ICPressure.RefGeom                    box1
pfset Geom.box1.ICPressure.RefPatch                   bottom_d

#-----------------------------------------------------------------------------
#  Solver Richards 
#-----------------------------------------------------------------------------
pfset Solver                                             Richards
pfset Solver.MaxIter                                     250000

pfset Solver.Nonlinear.MaxIter                           120
pfset Solver.Nonlinear.ResidualTol                       1e-8
pfset Solver.Nonlinear.EtaChoice                         Walker1
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.StepTol                           1e-16
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      200
pfset Solver.Linear.MaxRestart                           6

pfset Solver.PrintSubsurf                                True
pfset Solver.Drop                                        1E-20
pfset Solver.AbsTol                                      1E-8

pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType          FullJacobian

# pfset Solver.OverlandKinematic.Epsilon                  1E-5
# pfset Patch.top_d.BCPressure.Type		      			OverlandKinematic

# pfset Solver.OverlandDiffusive.Epsilon                  1E-5
# pfset Patch.top_d.BCPressure.Type		      			OverlandDiffusive

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfrun $runname
pfundist $runname

puts [format " --> Run complete: %s <--" $runname]