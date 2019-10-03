# Problem 7: Strong Scaling with different solvers
# this runs a very simple, homogeneous test problem with
# constant head bc's and no wells. It

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


#-----------------------------------------------------------------------------
# File input version number
#-----------------------------------------------------------------------------
pfset FileVersion 4

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

pfset Process.Topology.P        1
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                0.0
pfset ComputationalGrid.Lower.Y                0.0
pfset ComputationalGrid.Lower.Z                0.0

pfset ComputationalGrid.DX	                   10.
pfset ComputationalGrid.DY                     10.
pfset ComputationalGrid.DZ	                    1.

pfset ComputationalGrid.NX                      100
pfset ComputationalGrid.NY                      100
pfset ComputationalGrid.NZ                      200

## Uncomment below to make problem much smaller
## pfset ComputationalGrid.NX                      10
## pfset ComputationalGrid.NY                      10
## pfset ComputationalGrid.NZ                      20
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

pfset Geom.domain.Upper.X                     1000.0
pfset Geom.domain.Upper.Y                     1000.0
pfset Geom.domain.Upper.Z                      200.0

## Uncomment to make problem much smaller
## pfset Geom.domain.Upper.X                        100.0
## pfset Geom.domain.Upper.Y                        100.0
## pfset Geom.domain.Upper.Z                        20.0
##
pfset Geom.domain.Patches "left right front back bottom top"

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names "domain"

pfset Geom.domain.Perm.Type        Constant
pfset Geom.domain.Perm.Value       1.0

# uncomment to make problem harder with subsurface heterogeneity

## pfset Geom.domain.Perm.Type "TurnBands"
## pfset Geom.domain.Perm.LambdaX  50.0
## pfset Geom.domain.Perm.LambdaY  50.0
## pfset Geom.domain.Perm.LambdaZ  5.0
## pfset Geom.domain.Perm.GeomMean  1.00
## # note this is sigma, not variance (which is sigma^2)
## # this value corresponds to a variance of 0.5
## pfset Geom.domain.Perm.Sigma   0.707
## pfset Geom.domain.Perm.NumLines 250
## pfset Geom.domain.Perm.RZeta  5.0
## pfset Geom.domain.Perm.KMax  100.0000001
## pfset Geom.domain.Perm.DelK  0.2
## pfset Geom.domain.Perm.Seed  33333
## pfset Geom.domain.Perm.LogNormal Log
## pfset Geom.domain.Perm.StratType Bottom

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
pfset SpecificStorage.GeomNames       ""
pfset Geom.domain.SpecificStorage.Value 1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	Constant
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

pfset TimingInfo.BaseUnit		        1.0
pfset TimingInfo.StartCount		     -1
pfset TimingInfo.StartTime		      0.0
pfset TimingInfo.StopTime           0.0
pfset TimingInfo.DumpInterval	     -1

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames          domain

pfset Geom.domain.Porosity.Type    Constant
pfset Geom.domain.Porosity.Value   0.390

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
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names ""


#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names                    constant
pfset Cycle.constant.Names		       "alltime"
pfset Cycle.constant.alltime.Length	  1
pfset Cycle.constant.Repeat		       -1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames "left right front back bottom top"

pfset Patch.left.BCPressure.Type			DirEquilRefPatch
pfset Patch.left.BCPressure.Cycle			"constant"
pfset Patch.left.BCPressure.RefGeom			domain
pfset Patch.left.BCPressure.RefPatch			bottom
pfset Patch.left.BCPressure.alltime.Value		150.0

pfset Patch.right.BCPressure.Type			DirEquilRefPatch
pfset Patch.right.BCPressure.Cycle			"constant"
pfset Patch.right.BCPressure.RefGeom			domain
pfset Patch.right.BCPressure.RefPatch			bottom
pfset Patch.right.BCPressure.alltime.Value		149.0

pfset Patch.front.BCPressure.Type			FluxConst
pfset Patch.front.BCPressure.Cycle			"constant"
pfset Patch.front.BCPressure.alltime.Value		0.0

pfset Patch.back.BCPressure.Type			FluxConst
pfset Patch.back.BCPressure.Cycle			"constant"
pfset Patch.back.BCPressure.alltime.Value		0.0

pfset Patch.bottom.BCPressure.Type			FluxConst
pfset Patch.bottom.BCPressure.Cycle			"constant"
pfset Patch.bottom.BCPressure.alltime.Value		0.0

pfset Patch.top.BCPressure.Type			        FluxConst
pfset Patch.top.BCPressure.Cycle			"constant"
pfset Patch.top.BCPressure.alltime.Value		0.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
# topo slopes do not figure into the impes (fully sat) case but we still
# need keys for them

pfset TopoSlopesX.Type "Constant"
pfset TopoSlopesX.GeomNames ""

pfset TopoSlopesX.Geom.domain.Value 0.0

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------

pfset TopoSlopesY.Type "Constant"
pfset TopoSlopesY.GeomNames ""

pfset TopoSlopesY.Geom.domain.Value 0.0

#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------
# mannings roughnesses do not figure into the impes (fully sat) case but we still
# need a key for them

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames ""
pfset Mannings.Geom.domain.Value 0.

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                   Constant
pfset PhaseSources.water.GeomNames              domain
pfset PhaseSources.water.Geom.domain.Value      0.0

#-----------------------------------------------------------------------------
#  Solver Impes
#-----------------------------------------------------------------------------
pfset Solver  Impes

pfset Solver.Linear.MaxIter 15000
pfset Solver.MaxIter 50
pfset Solver.AbsTol  1E-10
pfset Solver.Drop   1E-15

#----------------------------
#  turn off printing of all PFB output
#-----------------------------
pfset Solver.PrintPressure  False
pfset Solver.PrintSubsurf   False


#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

puts stdout "Running with PCG"
pfset Solver.Linear PCG
pfrun problem7.pcg
pfundist problem7.pcg

puts stdout "Running with MGSemi"
pfset Solver.Linear MGSemi
pfrun problem7.MGSemi
pfundist problem7.MGSemi

puts stdout "Running with PPCG"
pfset Solver.PPCG.MaxIter 15000
pfset Solver.Linear PPCG
pfrun problem7.PPCG
pfundist problem7.PPCG

puts stdout "Running with CGHS"
pfset Solver.CGHS.MaxIter 15000
pfset Solver.Linear CGHS
pfrun problem7.CGHS
pfundist problem7.CGHS

# divide domain across two processors vertically
pfset Process.Topology.R        2
puts stdout "Running with PCG 2p"
pfset Solver.Linear PCG
pfrun problem7.2p.pcg
pfundist problem7.2p.pcg

puts stdout "Running with MGSemi 2p"
pfset Solver.Linear MGSemi
pfrun problem7.2p.MGSemi
pfundist problem7.2p.MGSemi

puts stdout "Running with PPCG 2p"
pfset Solver.PPCG.MaxIter 15000
pfset Solver.Linear PPCG
pfrun problem7.2p.PPCG
pfundist problem7.2p.PPCG

puts stdout "Running with CGHS 2p"
pfset Solver.CGHS.MaxIter 15000
pfset Solver.Linear CGHS
pfrun problem7.2p.CGHS
pfundist problem7.2p.CGHS

# divide domain across two processors in X
pfset Process.Topology.P        2
puts stdout "Running with PCG 4p"
pfset Solver.Linear PCG
pfrun problem7.4p.pcg
pfundist problem7.4p.pcg

puts stdout "Running with MGSemi 4p"
pfset Solver.Linear MGSemi
pfrun problem7.4p.MGSemi
pfundist problem7.4p.MGSemi

puts stdout "Running with PPCG 4p"
pfset Solver.PPCG.MaxIter 15000
pfset Solver.Linear PPCG
pfrun problem7.4p.PPCG
pfundist problem7.4p.PPCG

puts stdout "Running with CGHS 4p"
pfset Solver.CGHS.MaxIter 15000
pfset Solver.Linear CGHS
pfrun problem7.4p.CGHS
pfundist problem7.4p.CGHS

# divide domain across two processors in Y
pfset Process.Topology.Q        2
puts stdout "Running with PCG 8p"
pfset Solver.Linear PCG
pfrun problem7.8p.pcg
pfundist problem7.8p.pcg

puts stdout "Running with MGSemi 8p"
pfset Solver.Linear MGSemi
pfrun problem7.8p.MGSemi
pfundist problem7.8p.MGSemi

puts stdout "Running with PPCG 8p"
pfset Solver.PPCG.MaxIter 15000
pfset Solver.Linear PPCG
pfrun problem7.8p.PPCG
pfundist problem7.8p.PPCG

puts stdout "Running with CGHS 8p"
pfset Solver.CGHS.MaxIter 15000
pfset Solver.Linear CGHS
pfrun problem7.8p.CGHS
pfundist problem7.8p.CGHS
