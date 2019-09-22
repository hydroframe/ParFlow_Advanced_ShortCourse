lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*
pfset FileVersion 4
#--------------------------------------------------------------------------------------
#
# Boxy solid example for a terrain following grid with box and wedge solids
#
# Nick Engdahl (nick.engdahl@wsu.edu)
#
#--------------------------------------------------------------------------------------

set runname boxy_solid_tfg

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

pfset Process.Topology.P        2
pfset Process.Topology.Q        2
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
pfset GeomInput.Names "domain_input box1_input"

pfset GeomInput.domain_input.InputType  		 Box
pfset GeomInput.domain_input.GeomName   		 domain
pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0
pfset Geom.domain.Upper.X                        20.0
pfset Geom.domain.Upper.Y                        10.0
pfset Geom.domain.Upper.Z                        8.0
pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"

pfset GeomInput.box1_input.InputType  SolidFile
pfset GeomInput.box1_input.GeomNames  box1
# pfset GeomInput.box1_input.FileName   "YOUR_FILE_NAME_HERE"
# pfset GeomInput.box1_input.FileName   Box_Real_NoPatch.pfsol
# pfset Geom.box1.Patches ""


pfset GeomInput.box1_input.FileName   Box_Real.pfsol
# pfset GeomInput.box1_input.FileName   Wedge.pfsol
pfset Geom.box1.Patches "bottom_d top_d left_d right_d front_d back_d"

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names              "domain box1"

pfset Geom.domain.Perm.Type           	Constant
pfset Geom.domain.Perm.Value          	5.0

pfset Geom.box1.Perm.Type              Constant
pfset Geom.box1.Perm.Value             0.1

pfset Perm.TensorType               TensorByGeom
pfset Geom.Perm.TensorByGeom.Names  "domain"
pfset Geom.domain.Perm.TensorValX  1.0
pfset Geom.domain.Perm.TensorValY  1.0
pfset Geom.domain.Perm.TensorValZ  0.1

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName                domain

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "domain"
pfset Geom.domain.SpecificStorage.Value 1.0e-5

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
pfset Geom.Porosity.GeomNames         "domain"
pfset Geom.domain.Porosity.Type       Constant
pfset Geom.domain.Porosity.Value      0.1

#-----------------------------------------------------------------------------
# Mobility
#-----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#---------------------------------------------------------
# Saturation and Relative Permeability
#---------------------------------------------------------
pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames		"domain"
pfset Phase.RelPerm.Type            VanGenuchten
pfset Phase.RelPerm.GeomNames       	 "domain"


pfset Geom.domain.Saturation.Alpha           6.0
pfset Geom.domain.Saturation.N               2.0
pfset Geom.domain.Saturation.SRes            0.2
pfset Geom.domain.Saturation.SSat            1.0

pfset Geom.domain.RelPerm.Alpha        6.0
pfset Geom.domain.RelPerm.N            2.0

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
pfset TimingInfo.StopTime               13.0
pfset TimingInfo.DumpInterval           1
pfset TimeStep.Type                     Constant
pfset TimeStep.Value                    1.0

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------

pfset Cycle.Names                       "rainrec"
# rainfall and recession time periods are defined here
# rain for 3 hour, recession for 9 hours
pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           6
pfset Cycle.rainrec.rec.Length            7
pfset Cycle.rainrec.Repeat                1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
# All the other boundaries are zero flux so only the top needs to be defined
pfset BCPressure.PatchNames                     "z-upper"
pfset Patch.z-upper.BCPressure.Type               OverlandFlow
# pfset Patch.z-upper.BCPressure.Type               OverlandKinematic
# pfset Patch.z-upper.BCPressure.Type               OverlandDiffusive
# pfset Patch.z-upper.BCPressure.Type               FluxConst
pfset Patch.z-upper.BCPressure.Cycle				"rainrec"
pfset Patch.z-upper.BCPressure.rain.Value			-0.055
pfset Patch.z-upper.BCPressure.rec.Value			0.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
pfset TopoSlopesX.Type                 "Constant"
pfset TopoSlopesX.GeomNames            "domain"
pfset TopoSlopesX.Geom.domain.Value    0.15

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------
pfset TopoSlopesY.Type                 "Constant"
pfset TopoSlopesY.GeomNames            "domain"
pfset TopoSlopesY.Geom.domain.Value    0.0

pfset TopoSlopes.Elevation.FileName  "TFG_DEM.pfb"
pfdist -nz 1 "TFG_DEM.pfb"
#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------
pfset Mannings.Type                    "Constant"
pfset Mannings.GeomNames               "domain"
pfset Mannings.Geom.domain.Value       1e-6

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value            0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
pfset KnownSolution                                    NoKnownSolution

#-----------------------------------------------------------------------------
# Initial conditions: water pressure
#-----------------------------------------------------------------------------
# start this with a totally dry domain
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      4.0
pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   z-lower

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

pfset Solver.TerrainFollowingGrid 						True
#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfrun $runname
pfundist $runname
pfundist "TFG_DEM.pfb"

puts [format " --> Run complete: %s <--" $runname]

return
#-----------------------------------------------------------------------
#          Reference code for generating portable VTK files
#-----------------------------------------------------------------------

set DEM [pfload -pfb "TFG_DEM.pfb"]

set perm_infile [format "%s.out.perm_x.pfb" $runname]
set Perm [pfload -pfb $perm_infile]
pfvtksave $Perm -vtk [format "%s.out.perm_x.vtk" $runname] -var "Perm" -flt -dem $DEM
 
set nt 1000
for { set i 0} { $i <= $nt } { incr i} {
# format lets us specify string writing more explicitly
#  %s stands for string and %05d writes 00000an integer with 5 places, padded with zeros
        set infile [format "%s.out.press.%05d.pfb" $runname $i]
        set outfile [format "%s.out.press.%05d.vtk" $runname $i]
        set infiles [format "%s.out.satur.%05d.pfb" $runname $i]
        set outfiles [format "%s.out.satur.%05d.vtk" $runname $i]
        set next [file exists $infile]
        if ($next==1) {
        set pdat [pfload -pfb $infile]
        set sdat [pfload -pfb $infiles]
        pfvtksave $pdat -vtk $outfile -var "Press" -flt -dem $DEM
        pfvtksave $sdat -vtk $outfiles -var "Satur" -flt -dem $DEM
		# If it's an orthogonal grid there is no need for the DEM option
#  		  pfvtksave $pdat -vtk $outfile -var "Press" -flt
#         pfvtksave $sdat -vtk $outfiles -var "Satur" -flt
        } else {
        puts "End of file list"
        return
        }
}