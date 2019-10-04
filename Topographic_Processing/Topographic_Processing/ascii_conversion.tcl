
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

foreach name [list "GreatLake_basin.Str3_basins" "GreatLake_basin.Str3_dem" "GreatLake_basin.Str3_mask" "GreatLake_basin.Str3_RivMask" "GreatLake_basin.Str3_step"] {
  set fin "$name.sa"
  set fout "$name.pfb"
  set       file         [pfload -sa $fin]
  pfsetgrid {128 128 1} {0.0 0.0 0.0} {1000.0 1000.0 1.0} $file
  pfsave $file -pfb $fout
}


foreach name [list "segments" "direction" "Ep1.riv100.mn5.secNA_slopex" "Ep1.riv100.mn5.secNA_slopey" "Ep1.riv100.mn5.secNA_SmoothDEM"] {
  set fin "$name.sa"
  set fout "$name.pfb"
  set       file         [pfload -sa $fin]
  pfsetgrid {128 128 1} {0.0 0.0 0.0} {1000.0 1000.0 1.0} $file
  pfsave $file -pfb $fout
}
