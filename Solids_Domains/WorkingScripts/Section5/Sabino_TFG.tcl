lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*
# 
# Example of the Snoopy domain with a Terrain Following Grid
#
# Nick Engdahl (nick.engdahl@wsu.edu)
#
pfset FileVersion 4

set runname sabino_multi


set NP  [lindex $argv 0]
set NQ  [lindex $argv 1]

pfset Process.Topology.P        $NP
pfset Process.Topology.Q        $NQ
pfset Process.Topology.R        1

set dx 90.0
set dy $dx
set dz 100.0

set nx 246
set ny 178
set nz 5
        
set x0 0.0
set y0 0.0
set z0 0.0

set xmax [expr $x0 + ($nx * $dx)]
set ymax [expr $y0 + ($ny * $dy)]
set zmax [expr $z0 + ($nz * $dz)]

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

pfset GeomInput.Names        "solidinput"
pfset GeomInput.Names        "basininput mbinput solidinput"

# # ----- First we'll build the domain mask -----
set DEM [pfload -pfb "Sabino_DEM.pfb"]
set Mask [pfload -pfb "Sabino_Mask.pfb"]
set DMsk [pfload -pfb "Sabino_Dummy_Mask.pfb"]
set Bot [pfcellsumconst  $DEM -500 $DMsk]
# pfpatchysolid -top $DEM -bot $Bot -pfsol "sabino_mask_og.pfsol" -msk $Mask -vtk "sabino_mask_og.vtk"

# Now transform it to be a TFG solid
set Top [pfcelldiff $DEM $DEM $DMsk] 
set Bot [pfcelldiff $Bot $DEM $DMsk] 
set Top [pfcellsumconst  $Top 500 $DMsk]
set Bot [pfcellsumconst  $Bot 500 $DMsk]
pfpatchysolid -top $Top -bot $Bot -pfsol "sabino_mask_tfg.pfsol" -msk $Mask -vtk "sabino_mask_tfg.vtk"

pfset GeomInput.solidinput.GeomNames   domain
pfset GeomInput.solidinput.InputType   SolidFile
# pfset GeomInput.solidinput.FileName    sabino_solid.pfsol
pfset GeomInput.solidinput.FileName    sabino_mask_tfg.pfsol
pfset Geom.domain.Patches              "Bottom Top" 

# # ----- Now we'll build the Basin fill region -----
set Msk [pfload -pfb "Sabino_Basin_Mask.pfb"]
set Bot [pfload -pfb "Sabino_Basin_Bot.pfb"]
# pfpatchysolid -top $DEM -bot $Bot -pfsol "basin_OG.pfsol" -msk $Msk -vtk "basin_OG.vtk" 

set TFGtop [pfcelldiff $DEM $DEM $DMsk]
set TFGbot [pfcelldiff $Bot $DEM $DMsk]
set TFGtop [pfcellsumconst  $TFGtop 500 $DMsk]
set TFGbot [pfcellsumconst  $TFGbot 500 $DMsk]

pfpatchysolid -top $TFGtop -bot $TFGbot -pfsol "basin_TFG.pfsol" -msk $Msk -vtk "basin_TFG.vtk" 

pfset GeomInput.basininput.GeomNames   basin
pfset GeomInput.basininput.InputType   SolidFile
pfset GeomInput.basininput.FileName    basin_tfg.pfsol
pfset Geom.basin.Patches              "" 
# Note: Even though this file has patches, they aren't used so we'll leave this blank

# # ----- And now the mountain block region -----
set Msk [pfload -pfb "Sabino_MBGeo_Mask.pfb"]
set Bot [pfload -pfb "Sabino_MBGeo_Bot.pfb"]
# pfpatchysolid -top $DEM -bot $Bot -pfsol "mbgeo_OG.pfsol" -msk $Msk -vtk "mbgeo_OG.vtk" 

set TFGtop [pfcelldiff $DEM $DEM $DMsk]
set TFGbot [pfcelldiff $Bot $DEM $DMsk]
set TFGtop [pfcellsumconst  $TFGtop 500 $DMsk]
set TFGbot [pfcellsumconst  $TFGbot 750 $DMsk]

pfpatchysolid -top $TFGtop -bot $TFGbot -pfsol "mbgeo_TFG.pfsol" -msk $Msk -vtk "mbgeo_TFG.vtk" 

pfset GeomInput.mbinput.GeomNames   mbgeo
pfset GeomInput.mbinput.InputType   SolidFile
pfset GeomInput.mbinput.FileName    mbgeo_TFG.pfsol
pfset Geom.mbgeo.Patches              "" 

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------


pfset Geom.Perm.Names                 "domain basin mbgeo"

pfset Geom.domain.Perm.Type            Constant
pfset Geom.domain.Perm.Value           0.1

pfset Geom.basin.Perm.Type            Constant
pfset Geom.basin.Perm.Value           10.0

pfset Geom.mbgeo.Perm.Type            Constant
pfset Geom.mbgeo.Perm.Value           1.0


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
pfset Geom.domain.Saturation.SRes         0.05
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
# The UNITS on this simulation are HOURS

pfset TimingInfo.BaseUnit        1
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        1.0
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
pfset BCPressure.PatchNames "Bottom Top"

pfset Patch.Bottom.BCPressure.Type		      FluxConst
pfset Patch.Bottom.BCPressure.Cycle		      "constant"
pfset Patch.Bottom.BCPressure.alltime.Value	      0.0

pfset Patch.Top.BCPressure.Type		              FluxConst
pfset Patch.Top.BCPressure.Cycle		      "constant"
pfset Patch.Top.BCPressure.alltime.Value	      0.0

#---------------------------------------------------------
# Topo slopes
#---------------------------------------------------------
file copy -force "Sabino_DEM.pfb" "Top_Surf.pfb"
pfset TopoSlopes.Elevation.FileName  "Top_Surf.pfb"
pfdist -nz 1 "Top_Surf.pfb"

# Need to compute slopes so TFG can can work correctly
set DEM [pfload -pfb "Top_Surf.pfb"]
set slpX [pfslopex $DEM]
set slpY [pfslopey $DEM]
pfsave $slpX -pfb "slope_x.pfb"
pfsave $slpY -pfb "slope_y.pfb"

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
# pfset Solver.MaxIter                                     2000000

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

pfset Solver.TerrainFollowingGrid 				True
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

pfundist $runname
pfundist "Top_Surf.pfb"
pfundist "slope_x.pfb"
pfundist "slope_y.pfb"

puts [format " --> Run complete: %s <--" $runname]
