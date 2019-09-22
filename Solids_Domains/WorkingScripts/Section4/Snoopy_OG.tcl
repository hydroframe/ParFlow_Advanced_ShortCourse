lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*
# 
# Example of the Snoopy domain with an Orthogonal Grid
#
# Nick Engdahl (nick.engdahl@wsu.edu)
#
pfset FileVersion 4

set runname snoopy_og

set Top [pfload -pfb "Snoopy_Top.pfb"]
set Bot [pfload -pfb "Snoopy_Bot.pfb"]

set e_mask 1

# Uncomment this section if you need to re-generate the solids or VTKs but
#  pay attention to the patch write list to avoid surprises
# Comment it out if you don't want to keep regenerating every time...
if {$e_mask==1} {
set EMsk [pfload -pfb "Snoopy_Enhanced_Mask.pfb"]
pfpatchysolid -top $Top -bot $Bot -pfsol "solid_snoopy_enhanced.pfsol" -msk $EMsk -vtk "solid_snoopy_enhanced.vtk" 
# pfpatchysolid -top $Top -bot $Bot -pfsol "solid_snoopy_enhanced.pfsol" -msk $EMsk -vtk "solid_snoopy_enhanced.vtk" -sub
} else {
set Msk [pfload -pfb "Snoopy_Mask.pfb"]
pfpatchysolid -top $Top -bot $Bot -pfsol "solid_snoopy.pfsol" -msk $Msk -vtk "solid_snoopy.vtk" 
}

set NP  [lindex $argv 0]
set NQ  [lindex $argv 1]

pfset Process.Topology.P        $NP
pfset Process.Topology.Q        $NQ
pfset Process.Topology.R        1

set dx 0.5
set dy $dx
set dz 0.2

set nx 60
set ny 40
set nz 18
        
set x0 0.0
set y0 0.0
set z0 0.0

set xmax [expr $x0 + ($nx * $dx)]
set ymax [expr $y0 + ($ny * $dy)]
set zmax [expr $z0 + ($nz * $dz)]
#
#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
pfset ComputationalGrid.Lower.X                 $x0
pfset ComputationalGrid.Lower.Y                 $y0
pfset ComputationalGrid.Lower.Z                 $z0

pfset ComputationalGrid.DX	                    $dx
pfset ComputationalGrid.DY                      $dy
pfset ComputationalGrid.DZ	                    $dz

pfset ComputationalGrid.NX                      $nx
pfset ComputationalGrid.NY                      $ny
pfset ComputationalGrid.NZ                      $nz

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------

pfset GeomInput.Names        "domainbox solidinput"
pfset GeomInput.Names        "solidinput"


pfset GeomInput.domainbox.GeomName   background
pfset GeomInput.domainbox.InputType   Box

pfset GeomInput.solidinput.GeomNames   domain
pfset GeomInput.solidinput.InputType   SolidFile

if {$e_mask==1} {
pfset GeomInput.solidinput.FileName    solid_snoopy_enhanced.pfsol
pfset Geom.domain.Patches              "Bottom  Top  Left  Back  User_2  User_3  User_4  User_8  User_11" 
} else {
pfset GeomInput.solidinput.FileName    solid_snoopy.pfsol
pfset Geom.domain.Patches              "Bottom Top Left Back" 
}

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName domain

#---------------------------------------------------------
# Domain Geometry 
#---------------------------------------------------------
pfset Geom.background.Lower.X                        $x0
pfset Geom.background.Lower.Y                        $y0
pfset Geom.background.Lower.Z                        $z0

pfset Geom.background.Upper.X                        $xmax
pfset Geom.background.Upper.Y                        $ymax
pfset Geom.background.Upper.Z                        $zmax

pfset Geom.background.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

if (1==1) {

pfset Geom.Perm.Names                 "domain"

pfset Geom.domain.Perm.Type            Constant
pfset Geom.domain.Perm.Value           0.2

} else {

pfset Geom.Perm.Names                 "domain"

pfset Geom.domain.Perm.Type "TurnBands"
pfset Geom.domain.Perm.LambdaX  8.0
pfset Geom.domain.Perm.LambdaY  4.0
pfset Geom.domain.Perm.LambdaZ  1.0
pfset Geom.domain.Perm.GeomMean  0.2
pfset Geom.domain.Perm.Sigma   2.0
pfset Geom.domain.Perm.NumLines 40
pfset Geom.domain.Perm.RZeta  5.0
pfset Geom.domain.Perm.KMax  100.0
pfset Geom.domain.Perm.DelK  0.2
pfset Geom.domain.Perm.Seed  23333
pfset Geom.domain.Perm.LogNormal Log
pfset Geom.domain.Perm.StratType Bottom
}


pfset Perm.TensorType               TensorByGeom
pfset Geom.Perm.TensorByGeom.Names  "domain"
pfset Geom.domain.Perm.TensorValX  1.0
pfset Geom.domain.Perm.TensorValY  1.0
pfset Geom.domain.Perm.TensorValZ  0.1


#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------

pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "domain "
pfset Geom.domain.SpecificStorage.Value 1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	        Constant
pfset Phase.water.Density.Value	        1.0
pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------

pfset Contaminants.Names			""

#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------

pfset Geom.Retardation.GeomNames           ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				1.0

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
pfset Geom.Porosity.GeomNames           "domain "

pfset Geom.domain.Porosity.Type         Constant
pfset Geom.domain.Porosity.Value        0.3

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
pfset Phase.RelPerm.Type           VanGenuchten
pfset Phase.RelPerm.GeomNames      "domain"

pfset Geom.domain.RelPerm.Alpha    3.548
pfset Geom.domain.RelPerm.N        4.162 

#-----------------------------------------------------------------------------
# Saturation
#-----------------------------------------------------------------------------
pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames         "domain"

pfset Geom.domain.Saturation.Alpha        3.548
pfset Geom.domain.Saturation.N            4.162
pfset Geom.domain.Saturation.SRes         0.01
pfset Geom.domain.Saturation.SSat         1.0

#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames "domain"
pfset Mannings.Geom.domain.Value 1e-5
#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                           ""

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------

# 
# The UNITS on this simulation are HOURS
pfset TimingInfo.BaseUnit        1
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        10.0
pfset TimingInfo.DumpInterval    1.0
pfset TimeStep.Type              Constant
pfset TimeStep.Value             1.0

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
#pfset Cycle.Names "constant rainrec"
pfset Cycle.Names "constant"
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat             -1
 
#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
if {$e_mask==1} {
pfset BCPressure.PatchNames "Bottom Top Left Back User_2  User_3  User_4  User_8  User_11"
} else {
pfset BCPressure.PatchNames "Bottom Top Left Back"
}

pfset Patch.Bottom.BCPressure.Type		      FluxConst
pfset Patch.Bottom.BCPressure.Cycle		      "constant"
pfset Patch.Bottom.BCPressure.alltime.Value	      0.0

pfset Patch.Left.BCPressure.Type		      FluxConst
pfset Patch.Left.BCPressure.Cycle		      "constant"
pfset Patch.Left.BCPressure.alltime.Value	      0.00

pfset Patch.Back.BCPressure.Type		      FluxConst
pfset Patch.Back.BCPressure.Cycle		      "constant"
pfset Patch.Back.BCPressure.alltime.Value	      -0.2

# pfset Patch.Back.BCPressure.Type		      DirEquilRefPatch
# pfset Patch.Back.BCPressure.Cycle		      "constant"
# pfset Patch.Back.BCPressure.RefGeom    	domain
# pfset Patch.Back.BCPressure.RefPatch    	Bottom
# pfset Patch.Back.BCPressure.alltime.Value  1.0

pfset Patch.User_8.BCPressure.Type		      DirEquilRefPatch
pfset Patch.User_8.BCPressure.Cycle		      "constant"
pfset Patch.User_8.BCPressure.RefGeom    	domain
pfset Patch.User_8.BCPressure.RefPatch    	Bottom
pfset Patch.User_8.BCPressure.alltime.Value  1.5

pfset Patch.User_4.BCPressure.Type		      FluxConst
pfset Patch.User_4.BCPressure.Cycle		      "constant"
pfset Patch.User_4.BCPressure.alltime.Value	      0.00

pfset Patch.User_11.BCPressure.Type		      FluxConst
pfset Patch.User_11.BCPressure.Cycle		      "constant"
pfset Patch.User_11.BCPressure.alltime.Value	      0.00

pfset Patch.User_2.BCPressure.Type		      FluxConst
pfset Patch.User_2.BCPressure.Cycle		      "constant"
pfset Patch.User_2.BCPressure.alltime.Value	      0.00

pfset Patch.User_3.BCPressure.Type		      FluxConst
pfset Patch.User_3.BCPressure.Cycle		      "constant"
pfset Patch.User_3.BCPressure.alltime.Value	      0.00

# pfset Patch.TOP.BCPressure.Type		      			OverlandKinematic
# pfset Patch.Top.BCPressure.Type		              OverlandFlow
pfset Patch.Top.BCPressure.Type		              FluxConst
pfset Patch.Top.BCPressure.Cycle		      "constant"
# pfset Patch.Top.BCPressure.alltime.Value	      -0.003
# pfset Patch.Top.BCPressure.alltime.Value	      -0.001
pfset Patch.Top.BCPressure.alltime.Value	      0.0


#---------------------------------------------------------
# Topo slopes
#---------------------------------------------------------
file copy -force "Snoopy_SlopeX.pfb" slope_x.pfb 
file copy -force "Snoopy_SlopeY.pfb" slope_y.pfb 

pfset TopoSlopesX.Type                 "PFBFile"
pfset TopoSlopesX.GeomNames            "domain"
pfset TopoSlopesX.FileName              slope_x.pfb
pfdist -nz 1 slope_x.pfb

pfset TopoSlopesY.Type                 "PFBFile"
pfset TopoSlopesY.GeomNames            "domain"
pfset TopoSlopesY.FileName              slope_y.pfb
pfdist -nz 1 slope_y.pfb

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value        0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------

pfset KnownSolution                                    NoKnownSolution

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------

pfset Solver                                             Richards
pfset Solver.MaxIter                                     2000000


pfset Solver.Nonlinear.EtaChoice                         Walker1
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.MaxRestart                           4
pfset Solver.MaxConvergenceFailures                      4

pfset Solver.Nonlinear.ResidualTol                       1.0e-8
pfset Solver.Nonlinear.StepTol                           1e-12
pfset Solver.Nonlinear.MaxIter                           150
pfset Solver.Linear.KrylovDimension                      100


# pfset Solver.Linear.Preconditioner                       PFMGOctree
pfset Solver.Linear.Preconditioner                      PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian
pfset Solver.Nonlinear.PrintFlag	            	LowVerbosity

pfset Solver.PrintSubsurf					True
#pfset Solver.PrintSaturation                            False
pfset Solver.Drop                                       1E-15

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      0.0
pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   Bottom

#-----------------------------------------------------------------------------
# Write the ParFlow database and run that puppy
#-----------------------------------------------------------------------------

puts "Starting run"

pfrun $runname
# pfwritedb $runname

pfundist $runname

puts [format " --> Run complete: %s <--" $runname]

# if (1==0) {
# set perm_infile [format "%s.out.perm_x.pfb" $runname]
# set Perm [pfload -pfb $perm_infile]
# pfvtksave $Perm -vtk [format "%s.out.perm_x.vtk" $runname] -var "Perm" -flt
# 
# set nt 1000
# for { set i 0} { $i <= $nt } { incr i} {
# # format lets us specify string writing more explicitly
# #  %s stands for string and %05d writes 00000an integer with 5 places, padded with zeros
#         set infile [format "%s.out.press.%05d.pfb" $runname $i]
#         set outfile [format "%s.out.press.%05d.vtk" $runname $i]
#         set infiles [format "%s.out.satur.%05d.pfb" $runname $i]
#         set outfiles [format "%s.out.satur.%05d.vtk" $runname $i]
#         set next [file exists $infile]
#         if ($next==1) {
#         set pdat [pfload -pfb $infile]
#         set sdat [pfload -pfb $infiles]
#         pfvtksave $pdat -vtk $outfile -var "Press" -flt
#         pfvtksave $sdat -vtk $outfiles -var "Satur" -flt
#         } else {
#         puts "End of file list"
#         return
#         }
# }
# }
