lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*
pfset FileVersion 4
#--------------------------------------------------------------------------------------
#
# Super Slab domain example - multiple solid files with simple patches
#
# Nick Engdahl (nick.engdahl@wsu.edu)
#
# This example uses a 2-D domain based on the "Super Slab" problem described in Kollet et al. (2017) 
# Start by modifying a copy of the included Solid_Box.pfsol to create the geometry described in that paper.
#
# The "slabs" variable allows you to turn on and off the internal slabs, but start without them and add them later as you get your code working.
#
#--------------------------------------------------------------------------------------

set runname super_slab_og

file mkdir super_slabby
cd super_slabby

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

# Here you can only subdivide in x and z since ny=1
pfset Process.Topology.P        2
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

# Load in the slabs (1) too, or just load the domain boundary (0)
set slabs 1

# Option to coarsen the grid to speed things up...
# Make sure these scale factors (>=1) lead to EVEN values of NX and NZ
set nx_fac 2
set nz_fac 2
# When these are 1 they recover the Kollet et al. [2017] discretization

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                	0.0
pfset ComputationalGrid.Lower.Y                	0.0
pfset ComputationalGrid.Lower.Z                	0.0

pfset ComputationalGrid.DX	                    [expr 1.0*$nx_fac]
pfset ComputationalGrid.NZ                      [expr 300/int($nz_fac)]

pfset ComputationalGrid.DZ	               		[expr 0.05*$nz_fac]
pfset ComputationalGrid.NX                      [expr 100/int($nx_fac)]

# This is a 2-D domain so Y gets one cell of unit thickness
pfset ComputationalGrid.DY                 		1.0
pfset ComputationalGrid.NY                      1

#-----------------------------------------------------------------------------
# The Names of the GeomInputs
#-----------------------------------------------------------------------------
if ($slabs==1) {
pfset GeomInput.Names "domain_input slab1_input slab2_input"
} else {
pfset GeomInput.Names "domain_input"
}

pfset GeomInput.domain_input.InputType  SolidFile
pfset GeomInput.domain_input.GeomNames  domain
pfset GeomInput.domain_input.FileName   ../SuperSlab_Domain.pfsol
pfset Geom.domain.Patches "bottom_d top_d left_d right_d front_d back_d"

pfset GeomInput.slab1_input.InputType  SolidFile
pfset GeomInput.slab1_input.GeomNames  slab1
pfset GeomInput.slab1_input.FileName   ../SuperSlab_Slab1.pfsol
pfset Geom.slab1.Patches "bottom_s1 top_s1 left_s1 right_s1 front_s1 back_s1"

pfset GeomInput.slab2_input.InputType  SolidFile
pfset GeomInput.slab2_input.GeomNames  slab2
pfset GeomInput.slab2_input.FileName   ../SuperSlab_Slab2.pfsol
pfset Geom.slab2.Patches "bottom_s2 top_s2 left_s2 right_s2 front_s2 back_s2"

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName                domain

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------
if ($slabs==1) {
pfset Geom.Perm.Names              "domain slab1 slab2"
} else {
pfset Geom.Perm.Names              "domain"
}

pfset Geom.domain.Perm.Type           	Constant
pfset Geom.domain.Perm.Value          	10.0

pfset Geom.slab1.Perm.Type              Constant
pfset Geom.slab1.Perm.Value             0.025

pfset Geom.slab2.Perm.Type              Constant
pfset Geom.slab2.Perm.Value             0.001

pfset Perm.TensorType               TensorByGeom
pfset Geom.Perm.TensorByGeom.Names  "domain"
pfset Geom.domain.Perm.TensorValX  1.0
pfset Geom.domain.Perm.TensorValY  1.0
pfset Geom.domain.Perm.TensorValZ  1.0

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
pfset Phase.RelPerm.Type            VanGenuchten
if ($slabs==1) {
pfset Phase.RelPerm.GeomNames       	 "domain slab1 slab2"
pfset Phase.Saturation.GeomNames         "domain slab1 slab2"
} else {
pfset Phase.Saturation.GeomNames         "domain"
pfset Phase.RelPerm.GeomNames       	 "domain"
}

pfset Geom.domain.Saturation.Alpha           6.0
pfset Geom.domain.Saturation.N               2.0
pfset Geom.domain.Saturation.SRes            0.2
pfset Geom.domain.Saturation.SSat            1.0

pfset Geom.slab1.Saturation.N                3.0
pfset Geom.slab1.Saturation.Alpha            1.0
pfset Geom.slab1.Saturation.SRes             0.3
pfset Geom.slab1.Saturation.SSat             1.0

pfset Geom.slab2.Saturation.N                3.0
pfset Geom.slab2.Saturation.Alpha            1.0
pfset Geom.slab2.Saturation.SRes             0.3
pfset Geom.slab2.Saturation.SSat             1.0

pfset Geom.domain.RelPerm.Alpha        6.0
pfset Geom.domain.RelPerm.N            2.0

pfset Geom.slab1.RelPerm.Alpha         1.0
pfset Geom.slab1.RelPerm.N             3.0

pfset Geom.slab2.RelPerm.Alpha         1.0
pfset Geom.slab2.RelPerm.N             3.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                   ""

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------
# Permeability units are hours and we want to run 12 of them, but
#  at higher temporal resolution so we'll decrease our BaseUnit

# Original 0.05, 12.0, 2.0
set base_unit 0.1
set stop_time 12.0
set dump_int   [expr 1/$base_unit]

# set base_unit 0.1
# set stop_time 12.0
# set dump_int   1.0
pfset TimingInfo.BaseUnit               $base_unit
pfset TimingInfo.StartCount             0.0
pfset TimingInfo.StartTime              0.0
pfset TimingInfo.StopTime               $stop_time
pfset TimingInfo.DumpInterval           [expr $base_unit*$dump_int]
pfset TimeStep.Type                     Constant
pfset TimeStep.Value                    $base_unit

set nt [expr int($stop_time/($base_unit*$dump_int))]
puts [format "Step count = %d" $nt]

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------

pfset Cycle.Names                       "rainrec"
# rainfall and recession time periods are defined here
# rain for 3 hour, recession for 9 hours
pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           [expr int(3/$base_unit)]
pfset Cycle.rainrec.rec.Length            [expr int(9/$base_unit)]
pfset Cycle.rainrec.Repeat                1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
# All the other boundaries are zero flux so only the top needs to be defined
pfset BCPressure.PatchNames                     "top_d"
pfset Patch.top_d.BCPressure.Type               OverlandFlow
pfset Patch.top_d.BCPressure.Cycle				"rainrec"
# pfset Patch.top_d.BCPressure.rain.Value			-0.055
# I'm using a lower rain rate just to speed up the example run for you
pfset Patch.top_d.BCPressure.rain.Value			-0.025
pfset Patch.top_d.BCPressure.rec.Value			0.0

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------
pfset TopoSlopesX.Type                 "Constant"
pfset TopoSlopesX.GeomNames            "domain"
pfset TopoSlopesX.Geom.domain.Value    0.1

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------
pfset TopoSlopesY.Type                 "Constant"
pfset TopoSlopesY.GeomNames            "domain"
pfset TopoSlopesY.Geom.domain.Value    0.0

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
pfset Geom.domain.ICPressure.Value                      0.0
pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   bottom_d

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

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfrun $runname
pfundist $runname

puts " --> Run complete <--"
#-----------------------------------------------------------------------
#          Generate some files for visualization
#-----------------------------------------------------------------------
if (1==1) {
set perm_infile [format "%s.out.perm_x.pfb" $runname]
set Perm [pfload -pfb $perm_infile]
pfvtksave $Perm -vtk [format "%s.out.perm_x.vtk" $runname] -var "Perm" -flt


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
        pfvtksave $pdat -vtk $outfile -var "Press" -flt
        pfvtksave $sdat -vtk $outfiles -var "Satur" -flt
        } else {
        puts "End of file list"
        return
        }
}
}

# Mark out the "return" on the next line to generate the time series table
return
#-----------------------------------------------------------------------
#              Calculate storage and runoff
#-----------------------------------------------------------------------

set slopex       0.1
set slopey       0.0
set dx	1.0

set mannings  1e-6
set specific_storage [pfload [format "%s.out.specific_storage.pfb" $runname]]
set porosity [pfload [format "%s.out.porosity.pfb" $runname]]
set mask [pfload -pfb [format "%s.out.mask.pfb" $runname]]
set top [pfcomputetop $mask]
set t_cell [expr int([pfgetelt $top 0 0 0])]
    
puts "Time(hrs)  SurfaceStorage   SubsurfaceStorage    OutletDischarge"
for {set i 0} {$i < $nt} {incr i} {

    set pdat [pfload -pfb [format "%s.out.press.%05d.pfb" $runname $i]]
    set sdat [pfload -pfb [format "%s.out.satur.%05d.pfb" $runname $i]]

    set surface_storage [pfsurfacestorage $top $pdat]
    set total_surface_storage [pfsum $surface_storage]
    
	set outP [pfgetelt $pdat 0 0 $t_cell]
	if {$outP <= 0} {set qout 0} else { 
	set qout [expr ($dx/$mannings)*($slopex**0.5)*($outP**(5.0/3.0))]
    }
    
    set subsurface_storage [pfgwstorage $mask $porosity $pdat $sdat $specific_storage]
    set total_subsurface_storage [pfsum $subsurface_storage]

set out_time [expr $dump_int*$base_unit*$i]

puts [format "%f %f %f %f" $out_time $total_surface_storage $total_subsurface_storage $qout]
}

