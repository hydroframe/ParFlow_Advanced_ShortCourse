# Creating and working with solid files (.pfsol)
*ParFlow Advanced Short Course*
*by Nick Engdahl*
*(nick.engdahl@wsu.edu)*


## Preliminary: Obtaining the Patchy_Solid branch
The command to retrieve the branch we need for today is:

`git clone https://github.com/nbengdahl/parflow.git --branch pf_patchy_solid --single-branch`

This has soon to be merged set of tools built to help construct complex domains. The rest of the ParFlow installation instructions are exactly as they appear on the blog.


## Overview
The objective of this exercise is to help you understand the basics of solid files so you can build your own using either the built in PFTool utilities or your own code.

Complex geometries in ParFlow are handled using 3-D objects based on a triangular irregular network (TIN). These can be confusing and frustrating, but once you understand them the sky is the limit for the shapes you can create.  

Two handy abbreviations we'll use are **OG** for an Orthogonal Grid and **TFG** for a Terrain Following Grid since solids are handled slightly differently for each. The list below gives an outline of our tasks for today:
0. Creating 3-d objects - general overview and considerations
1. Solid file basics
   - Creating, loading, and verifying a rectangular solid (**OG**)
   - Patch basics (**OG**)
2. Modify our solid into a wedge (**OG** & **TFG**)
3. Making and loading multiple solids (**OG** & **TFG**)
4. Building a solid mask from a raster (**OG** & **TFG**)
5. Building the solid mask for our Sabino Canyon domain (**TFG**)
The kind of grid(s) used in each are identified in parentheses but this *does not* mean that you can't use the other kind of grid; solids are general and can be used with **OG** and **TFG** with a few modifications that we'll highlight in Items 3 & 4 before making the domain you'll use throughout the course.

## 0. General overview
This section is an in-class discussion with lecture.

## 1. Solid file basics
The format for a solid file is provided in the ParFlow manual and they always get the extension `.pfsol`. Find the page in the manual and look over it. Try to get a feel for what is in the file and how it is written based on the provided pseudo-code.

The standard format is an ASCII (or Unicode) text file where individual points are defined, connections between them are defined to build triangles, and then groups of triangles are used to define patches on the surface of the solid. The key concept is that triangle is defined in terms of its points and the outward normal of the "path" must point outside of the solid. Consider three points in d-3 space defined by the coordinates: A=(0,1,0), B=(0,0,0), and C=(1,0,0). If we define vectors AB and AC, connecting those points where A is the tail of the vector and the other point is the head (*i.e.* AB goes from A to B), the normal to these vectors has components [0,0,1]. If instead we had defined CA and CB the normal has components [0,0,-1]. Another way to think about this is it terms of a right handed coordinate system: if your middle finger points from B to A and your index finger points from B to C, your thumb is pointing upward along [0,0,1], which is the outward normal vector. *(Note: We'll sketch this on the board too)*

### Building our first solid
What we're going to do now is *manually* build a rectangular solid that is 20m along x (x1), 10m along y (x2), and 8m along z (x3), and we need eight points to do this. A rectangle has 6 faces so we'll need two triangles per face for 12 total. Consistency is the key to doing this correctly and it will help to DRAW a wirefram 3-D box on a sheet of paper and NUMBER each corner, which I'll also do on the board. When counting, the index starts at ZERO *not one* so be sure to remember that detail. I choose to follow a normal i,j,k numbering (increase along x, then y, then z), but you can use whatever makes the most sense to you.
The first triangle I define will be on the "South" face which is defined from points `4,0,1` and the second triangle is made from `1,5,0` *but always remember that the order matters!!* This convention helps because it "walks a counter-clockwise loop" around the face, repeating the "overlapping" points of the triangles. For the "North" face, our points would be `3,2,6` and ` 6,7,3` to make sure the outward normal points along [0,1,0], whereas the south face norm is [0,-1,0].

Create an empty text file in vim (or whatever you prefer) and call it `Boxy.pfsol` and write the coordinates of each point *in the order you sketched them* and then start to build the rest of the file. We'll skip patches for now, but they'll be added later. A file `Box_Real_NoPatch.pfsol` is provided with one possible way to build the solid, but I encourage you to try to build your own. *I cannot emphasize enough how useful it is to have a sketch when doing this!* Once your solid is built, you can use the `pfsol-to-vtk` utility located in `$PARFLOW_DIR/bin` to convert the pfsol to a viewable object. Note that this is a standalone utility so you'll need to add `$PARFLOW_DIR/bin` to your PATH variable or copy it into your current folder, then its syntax is `pfsol-to-vtk <pfsol filename> <desired vtk filename>`; a pftool called `pfsolidtovtk` is forthcoming so you'll soon be able to call this conversion utility from within the tools infrastructure and this tool will also write the patch ID its average elevation as attributed to the VTK.

Next, we're going to bring your solid into a ParFlow domain and use it to set the permeability. For this task I'm going to ask that you start from "scratch" but that just means find an example or test script that does something similar to what you want then modifying it. Your task is to build a 20m (x) by 10m (y) by 8m (z) domain and define the permeability from the solid. There are several ways to go about this and I encourage you to discuss how with others in the class. The objective is to confirm that the solid was used to set the permeability so you only need to run a single time step and can set all domain boundaries as zero flux for now; however, since we didn't define any patches in our solid you will also need to define a box geometry so you can define the boundaries for the domain. Specific values of permeability, storage coefficients, etc... are not important so just set what you think are reasonable values.
*Each of our brains each has a different level of built-in 3-d visualization capability (which often directly correlated to how much you played with Legos as a child), so please don't hesitate to ask questions if you have any questions about the description of the geometry.*

The script `OG_Solid1.tcl` is provided so you have something that works in case you have any problems. The script builds a rectangular, 3-D domain using the `Box_Real_NoPatch.pfsol` file but there is a place holder for your solid file to define permeability in part of the domain. Search for "YOUR_FILE_NAME_HERE" to find the block to insert yours, then comment out the line where the file was set to `Box_Real_NoPatch.pfsol`. The permeability is defined in the `domain` geometry (a box geometry) and also the `box1` geometry (solid file): both overlap in this case so the order set in the `pfset Geom.Perm.Names` list dictates which overwrites the other. You should only see one value of permeability corresponding to value set for the `box1` geometry. We'll modify this later on so for now, let's move on to discuss patches.

### Patches
Recall that patches are collections of triangles that are used to define "faces" of a solid object. We've already written the triangles (the hard part) so all we need to do in order to define a patch is specify which triangles belong to it. For a given solid, each triangle can only belong to a single patch. Consult the back of ParFlow manual for the details but the basics are that we specify the number of patches, then the number of triangles for that patch, then the IDs of the specific patches.

Using the manual as a guide, define a patch for each of the six faces of our solid box. Remember that the *first patch you write is patch zero* not one. Keep in mind that each face of the box is a rectangle defined by two triangles so every patch will have two triangles in this case. A completed example is provided as `Box_Real.pfsol` if you prefer not to make your own. The order of its patches is given in `OG_Solid1.tcl` as a commented-out line with `_d` after each.  

Now that we have patches defined, we can use this object to define our computational domain instead of the Box we built as "domain_input" and we need to change a few things. First, is the `Domain.GeomName` key, which should now be set `box1`. Next, we need to update our boundaries so that they refer to the solid object. We only have one in this example since the rest are implied zero flux and we need to change "z-upper" to "top_d" in the `BCPressure.PatchNames` and the subsequent lines. You could update the other references (*i.e.* slopes, initial condition, etc...) but it isn't necessary. When you run this example, it should look exactly like the last one but importantly we defined patches this time.

Since we defined six patches in this solid file, you could also define up to six boundaries; if you forget to assign a boundary, ParFlow will assume it is a zero flux but it's good practice to specifically define all boundaries. For example, you could assign Dirichlet boundaries at `left_d` and `right_d` (basically the same as x-lower and x-upper) to drive flow across the domain. Give it a try and see if the results make sense. You can find a reference script in `OG_Solid2.tcl` for all the patches

## 2. Turning the box into a wedge
### Orthogonal Grid:
Part of the reason we wanted to switch to the domain defined by our solid file is it allows us to deactive parts of the computational grid that fall outsize our domain of interest. What we're going to do next is modify the solid so that top has a slope. We won't be needing the `domain_input` geometry anymore so go ahead and remove that from your TCL script. This means that any reference to the `domain` geometry needs to be replaced with a reference to the `box1` geometry and any references to patches need to be updated too (*hint: initial condition*). After making those changes, re-run the script to make sure it works, debug if necessary, then make a copy of your solid file so we don't edit your original.

The revised domain will create a wedge with a positive slope along the x direction. To create the wedge, we need to modify the positions of some points but nothing else in the solid will change. This isn't always the case, but it is today so let's get to it. Find the points with x values of zero, there are four. Two are at the bottom of the domain with z values of zero and two have z values of 8.0 because they're at the top. Change the two at x=0 from 8.0 to 5.0, then find the two points with x=20.0 and z=0.0 and make these z=3.0. Save the solid file, then re-run your tcl script, being sure to update the name of the solid file. The working example of this is `OG_Solid3.tcl` if you get stuck and the reference solid `Wedge.pfsol` has the final geometry.

Look at the permeability (in VisIt or ParaView) and you should see a stairstep going up along the x1 direction on the top, and a similar pattern on the bottom of the domain. The values within our domain should be 1.0 and the values above should be 0.0, which is the uninitialized value. There is one thing we didn't change yet though: this domain now has a non-zero slope on its surface. Change this under `TopoSlopesX.Geom.box1.Value` to be the correct value (3/20=0.15). Now re-run the script but assign a Dirichlet boundary at `right_d` with the value of 2.0m using `bottom_d` as the reference patch, and use zero-flux for the other boundaries. What do you see? There is a block of code commented out in `OG_Solid3.tcl` that sets `left_d` as a Dirichlet too; see what happens.

### Terrain Following Grid:
As we said in class, terrain following grids can be handy in many cases but they also require us to be a bit more careful when defining properties. The thing to remember is that we can use a solid to define properties in a region, an active domain, or both, but the TFG is often assumed to already follow the top (and often the bottom) so many times a solid is just used to define properties. Solid files and terrain following grids are a little tricky because the solid needs to be aligned with the ParFlow grid, which follows the terrain. Basically what this means is subtract the elevation of the top of your model from any solid file you're building then add back in the total domain height and that's it. In other words, a solid file that fully covers a sloping TFG domain is a rectangular box with no slope.

Confused? Let's modify our first example to be a terrain following grid. Make a copy and call it `TFG_temp.tcl`,add the key `pfset Solver.TerrainFollowingGrid    True` to the file, and make sure to set the slope `pfset TopoSlopesX.Geom.box1.Value  0.15`. For the first part of this, revert  to our original boxy solid file and run the problem. Take a look at the permeability field but since this is a **TFG** you'll need to do one of two things to get the land surface in the right place. First, is to add a key like `pfset
 TopoSlopes.Elevation.FileName DEM_file.pfb` where DEM_file.pfb holds the surface elevations of your model: this file MUST be distributed with pfdist and *it is a 2-d file* so you'll want the `pfdist -nz 1 DEM_file.pfb` syntax. This will be written to the metadata so Paraview can correctly deflect your terrain. If you didn't distribute your file correctly, get other odd behavior in Paraview, or just want a more portable graphics format, you can use another option: convert to a VTK using `pfvtksave` and its "-dem" option, an example of this can be found in `TFG_Solid1.tcl`. In either case you can use the included `TFG_DEM.pfb` for the surface elevation. You should see a single value for the permeability, which should seem odd. We just gave this a flat solid file and it defined a sloping domain. This is what is meant when we say solids are relative to the top surface. Now switch to your wedge solid and look at the permeability field, but be sure to switch to the "domain" geometry to defined the active domain (this may require you to move a boundary to avoid an error). You should now see two permeability values and a familiar looking slope. **We'll discuss what you're looking at in more detail together in class because this concept can get confusing.**  

See the included `TFG_Solid1.tcl` for the complete example with several permutations that can be commented/uncommented.


## 3. Making and loading multiple solids
### Terrain Following Grid:
The next task is to create the geometry of "Super Slab" test case from Kollet et al. [2017], but we'll do it as a terrain following grid. We'll discuss the details of the setup and what would change in a **OG** during class so if you've read ahead to this point you'll need to be patient now.

The domain itself is a rectangle and since we're using a **TFG** that is just a box. We have a constant slope and the problem is 2-d, so we don't need a solid to define the active domain, but we do need two solids to define the properties. In this case, each can be defined as a box so it's only a matter of determining the coordinates of the corners and modifying a copy of the original box solid we've already built. The trick here though is to *make sure the coordinates are relative to the top of the domain* so use the sketch we drew to carefully determine what the transformed (TFG) and untransformed (real world) coordinates should be.

We could run this problem but really we're just interested in seeing that the solids are defined in the correct place. Run a single time step and look at the permeability field. Since we haven't defined a DEM you won't be able to deflect the terrain (Paraview) so your domain will look flat on top but you should be able to see if the permeability regions have been defined in the right place.

A set of example files for this problem are provided and these include a DEM that defines the surface (for plotting purposes) `SuperSlab_DEM.pfb`, the two solid files that define the geometries `SuperSlab_TFG_Slab1.pfsol` `SuperSlab_TFG_Slab2.pfsol`, and a working example script of the problem provided in `SuperSlab_TFG.tcl`. Only one of the solids actually needs to be a solid in this case, `SuperSlab_TFG_Slab1.pfsol`, because the other two can be built as box geometries but they are included anyway.

### Orthogonal Grid:
The main difference when building the "Super Slab" as an orthogonal grid is that 1) a solid is needed to define the active domain, and 2) the coordinates of the solids are written in real-world coordinates without any transformation. If you have time, try to build an **OG** version of the super slab. Make sure that your computational grid is tall enough to capture the lowest and highest points of the domain. When built, it should look exactly like the figures in Kollet et al. [2017], albeit a bit more stair-steppy if your grid is coarse.

The example files needed to build this domain are provided and include three solids `SuperSlab_Domain.pfsol`, `SuperSlab_Slab1.pfsol`, and `SuperSlab_Slab2.pfsol`, with a working run script provided in `SuperSlab_OG.tcl`


## 4. Building a solid from an "enhanced mask" raster (**OG** & **TFG**)
### Orthogonal Grid:
One of the branches of ParFlow that can be found in the `nbengdahl/parflow` fork is called "pf_patchy_solid" and it will soon be merged into the master release it hasn't already been. You can get it using `git clone  https://github.com/nbengdahl/parflow.git --branch pf_patchy_solid --single-branch` instead of cloning the master and it will install and function exactly the same as the master version, so go ahead and get that if you haven't already. *You DO NOT need to reinstall anything else (MPI, Hypre, etc...) for this so it goes very fast, and you don't have to change your PARFLOW_DIR variable either.* This branch adds a few new options for solid files, creates a new binary solid file to reduce their size, includes an ascii to binary (or vice versa) conversion utility, and it adds a new pftool for building solids. Before moving on, note that a solid file tool also exists in `/parflow/bin` called `pfmask-to-pfsol` and this also includes a few options for building solids that we'll discuss in class. The big difference is that the new `pfpatchysolid` command in pftools gives you the ability to build complex surfaces (*i.e.* irregular top and bottom surfaces ) instead of just *cookie-cutting* out your domain. One other difference is that `pfmask-to-pfsol` has a mode that allows multiple patches on the top surface, but keep in mind that surface inputs are commonly specified from pfb files so a single top patch is typical. Basically, if you're working with a **TFG** without any complexity in the subsurface or using a pfb to define properties (*i.e.* as indicators) `pfmask-to-pfsol` is probably better for you, and if you have complex 3-d surfaces within your **TFG** domain or are using an **OG** then `pfpatchysolid` is the way to go.

We'll focus on using `pfpatchysolid` and building solid objects with it centers around defining the top surface elevations, the bottom surface elevations, and a mask that identifies active and inactive regions. A typical mask file is a gridded file (pfb) where active cells get a value of 1 and inactive cells are zero but `pfpatchysolid` also lets you write different numbers to the mask to define patches, so I call this an "enhanced mask." In the project folder for this section of the course you'll find a folder called "Snoopy" with two tcl scripts, pfbs for the *top and bottom elevations* and two mask files: `Snoopy_Mask.pfb` and `Snoopy_Enhanced_Mask.pfb`. Go ahead and open both in Paraview and the choice of file name will make a lot of sense. You'll see them as 2-d datasets and the difference is that the enhanced mask has more numbers in it (not just 0 and 1). The tool will create patches at the faces where an active cell (value 1) touches these numbers and will also break these patches up further according to the direction they are facing if you tell it to. Let's look at a comparative example. Create a new PFTCL file and add the "import package" block at the top so we can use pftools; we don't need to run this model yet, we just want to look at the domain being created.

> **_The manual might not show this yet so the entry for pfpatchysolid is:_** 
>
> `pfpatchysolid -top topdata -bot botdata -msk emaskdata [optional args] `
>
> Creates a solid file with complex upper and lower surfaces from a top surface elevation dataset (topdata), a bottom elevation dataset (botdata), and an enhanced mask dataset (emaskdata) all of which must be passed as handles to 2-d datasets that share a common size and origin. The solid is built as the volume between the top and bottom surfaces using the mask to deactivate other regions. The "enhanced mask" used here is a gridded dataset containing integers where all active cells have values of one but inactive cells may be given a positive integer value that identifies a patch along the model edge or the values may be zero. Any mask cell with value 0 is omitted from the active domain and *is not* written to a patch.
> If an active cell is adjacent to a non-zero mask cell, the face between the active and inactive cell is assigned to the patch with the integer value of the adjacent inactive cell. Bottom and Top patches are always written for every active cell and the West, East, South, and North edges are written automatically anytime active cells touch the edges of the input dataset(s). Up to 30 user defined patches can be specified using arbitrary integer values that are *greater than* 1.
> Note that the -msk flag may be omitted and doing so will make every cell active.

> The -top and -bot flags, and -msk if it is used, MUST each be followed by the handle for the relevant dataset. Optional argument flag-name pairs include:
>
> `-pfsol <file name>.pfsol  (or -pfsolb <file name>.pfsolb)`

> `-vtk <file name>.vtk`

> `-sub`
>
> where <file name> is replaced by the desired text string. The -pfsolb option creates a compact binary solid file; pfsolb cannot currently be read directly by ParFlow but it can be converted with `pfsolidfmtconvert` and full support is under development. If -pfsol (or -pfsolb) is not specified the default name "SolidFile.pfsol" will be used. If -vtk is omitted, no vtk file will be created. The vtk attributes will contain mean patch elevations and patch IDs from the enhanced mask. Edge patch IDs are shown as negative values in the vtk.
> The patchysolid tool also outputs the list of the patch names in the order they are written, which can be directly copied into a ParFlow TCL script for the list of patch names.
>
> Assuming Msk, Top, and Bot are valid dataset handles from pfload, two valid examples are:
>
> `pfpatchysolid -msk $Msk -top $Top -bot $Bot -pfsol "MySolid.pfsol" -vtk "MySolid.vtk"`
>   
> `pfpatchysolid -bot $Bot -top $Top -vtk "MySolid.vtk" -sub`
>
> Note that all flag-name pairs may be specified in any order for this tool as long as the required argument immediately follows the flag. To use with a terrain following grid, you will need to subtract the surface elevations from the top and bottom datasets (this makes the top flat) then add back in the total thickness of your grid, which can be done using "pfcelldiff" and "pfcellsumconst".

OK, now back to the task at hand. What we'll do next is create two solid files, one for each kind of mask, and VTKs for each so we can look at them. To do so, you need to load in the `-top`, `-bot`, and `-msk` datasets with `pfload` then  define the file names to be what you'd like. Add both to out new tcl scrip and run the script. Load both of the VTK objects into Paraview and let's compare them (note that the VTK file will look the same whether or not -sub is used, so pay attention to the patch write list). Two variables are written to these VTK files (Elev and Patch) but we want to look at `Patch` so select that for the standard mask. You'll find several values: 0, -1, -2, -4 etc... for the "ignored" region, the bottom, the top, and the "north" edge (see the description above). Every patch on the vertical sides of the solid have value 0 because the "Snoopy_Mask.pfb" has zeros there, except for the one place it intersects the edge of the grid where a North patch (value -4) was written. If you switch to the enhanced mask, "Snoopy_Mask.pfb", you'll see quite a few more patches.

Snoopy's awesome (albeit silly) geometry helps to emphasize a few things. First, solid files can have "holes" in them and this can be a handy way to define things like lakes, but what Snoopy doesn't show is that they can have disconnected parts too. Second, the top and bottom of Snoopy are not even, which can be seen looking at the active domain thickness at -x and +x (threshold the mask in Visit/Paraview to see this). Third, the holes are there in this example to help you see more clearly how the different patch boundaries affect the simulation and that's the purpose of the `Snoopy_OG.tcl` scripts. Open up the `Snoopy_OG.tcl` and start going through each section of the script to understand what is going on, then run the example and play around with it. When you get to the time cycles and boundaries section, there are several options commented out you can manipulate to see how each patch affects the simulation. Try changing some boundary types.

### Terrain Following Grid:
The modification for all of these files for a terrain following grid is similar to what we did for the Super Slab example. For every solid object we create, we'll need to adjust its positions by subtracting out the elevation of the top of the model, then adding back in the total thickness of the grid. You can do this by modifying your input PFBs to `pfpatchysolid` using Python, R, Matlab, whatever, or the existing pftools commands `pfcelldiff` and `pfcellsumconst` (see the manual for more info); those pftools currently require a mask file and the tool gets confused with this domain since it has holes in the domain. A fix to this bug is forthcoming so in the meantime, you can use the `Snoopy_Top_TFG.pfb` and `Snoopy_Bot_TFG.pfb` files and the same mask as before to build the TFG version. It's worth taking a moment to compare the **OG** and **TFG** inputs by plotting them in Paraview. The top of the **TFG** domain should be a constant but the bottom should not be, and neither the top nor the bottom of the **OG** will be constants. However, if you subtract the top from the bottom in either case, you'll find that both have identical thicknesses.

The included `Snoopy_TFG.tcl` script is the reference for the **TFG** and it is an "equivalent" **TFG** construction of the `Snoopy_OG.tcl` domain. However, try to build your own `My_Snoopy_TFG.tcl` from `Snoopy_OG.tcl` instead of just running the **TFG** version.

## 5. Building the solid mask for our Sabino Canyon domain
Our last item of business for this session is to build the solid file for the Sabino Canyon watershed. This example involves a **TFG** and three solid files: one for the active domain and two to delineate the permeability in two regions, with the remainder filled in as a background type. This will be a slightly simplified version of the actual site geology where we'll assume each region fully penetrates the domain, one region goes half way down.

The files you need to build this geometry are `Sabino_Dummy_Mask.pfb`, `Sabino_Mask.pfb`, `Sabino_Basin_Mask.pfb`, `Sabino_MBGeo_Mask.pfb` and `Sabino_DEM.pfb`. The `Sabino_Mask.pfb` file is the mask for the active domain, the "basin" and "mbgeo" masks are for the basin fill and mountain block regions and the `Sabino_Dummy_Mask.pfb` is just a 2d PFB file the same size as the DEM but filled with ones (a file like this can be helpful when usinging pftools).

Go ahead and make a copy of a working **TFG** based tcl and call it `SabinoTFG.tcl`. The dimensions of the computational grid are: dx=90.0, dy=90.0, dz=100.0, nx=246, ny=178, nz=5, and the coordinate origin is x0=y0=z0=0.0. Now let's build our active domain solid.

### Option 1 - A simple mask for a TFG
First, we'll use the `pfmask-to-pfsol` utility to build the solid. You can look at the online documentation on GitHub (within the pftools folder) for the complete syntax but the command we'll use is:

>pfmask-to-pfsol --mask Sabino_Mask.pfb --vtk sabino_masker.vtk --pfsol sabino_masker.pfsol --z-top 500.0 --z-bottom 0.0

We'll explain what each argument does in class. Note that this is entered at the command line, NOT in a tcl script. When that runs you'll see a few outputs print to the screen but what is important to note is that the top patch is written first then the bottom and side patches. If you load the VTK, you'll see where these patches have been written.

This command is very handy for simple terrain following grids where uniform layers are involved because the constant top and bottom elevations are specified. However, it cannot handle irregular surfaces where the thickness changes spatially.

### Option 2 - The longer but more flexible way
Our second option is to use `pfpatchysolid` recognizing that it requires a PFB to define the top and bottom of the solid, but these don't have to be flat. What I typically do is create my solid files as 3d objects with their actual (real world) elevations, then convert those into an equivalent **TFG** solid. The way to do that is to subtract the DEM of the surface from every top and bottom surface, then add back in the total layer thickness. This is a little more work but it gives you a lot more freedom to define complex objects.

First, let's build the "real-world" version of the active domain solid to see what this looks like. We'll load in the top surface and use pftools to subtract out the thickness to make the bottom. Since this is pftools these commands will go into a TCL script and the operations for this go something like:

> `set DEM [pfload -pfb "Sabino_DEM.pfb"]`

> `set Mask [pfload -pfb "Sabino_Mask.pfb"]`

> `set DMsk [pfload -pfb "Sabino_Dummy_Mask.pfb"]`

> 
> `set Bot [pfcellsumconst  $DEM -500 $DMsk]`

> `pfpatchysolid -top $DEM -bot $Bot -pfsol "sabino_mask_og.pfsol" -msk $Mask -vtk "sabino_mask_og.vtk"`

Where I've used the "og" identifier so we remember that this is not setup for a **TFG** just yet. The `pfcellsumconst` command requires a mask (in my experience it gives better results when you use a dummy mask that covers the entire domain) and we simply defined a new surface 500m below the top. To build the **TFG** the approach is similar but we need to transform the top and bottom surfaces. In addition to those commands above, we need the following:

> `set Top [pfcelldiff $DEM $DEM $DMask]`

> `set Bot [pfcelldiff $Bot $DEM $DMask]`

> `set Top [pfcellsumconst  $Top 500 $DMsk]`

> `set Bot [pfcellsumconst  $Bot 500 $DMsk]`

> `pfpatchysolid -top $Top -bot $Bot -pfsol "sabino_mask_tfg.pfsol" -msk $Mask -vtk "sabino_mask_tfg.vtk"`

which will generate the final solid and tell you the patches that were written in the order that they were written. There are a few other ways you could get the same result but I'll leave that to you to explore.

### Comparison
The main difference you'll see between these two options is the patches that are written and the size of the files. Since `pfpatchysolid` is designed for complex terrain, it creates top and bottom triangles for every cell to preserve the resolution of the terrain in the PFB. Since `pfmask-to-pfsol` is designed for flat solids only, it can take advantage of an algorithm that significantly reduces the number of interior points in the solid domain, while preserving the resolution along the edge, because we can make big flat triangles. Open both VTK files in Paraview of Visit and look at the "Wireframe" view and you'll immediately see the difference. If you have flat layers in an **OG** or layers that are uniform thickness in a **TFG** then `pfmask-to-pfsol` is probably your best choice. Otherwise `pfpatchysolid` can be used for any arbitrary solid and grid combination, but the files will be larger. To help reduce this size we are adding support for a *binary* solid file but this is not yet fully implemented.

### The rest of the solids
The two solids left to build are the "basin fill" and "mountain block" units, which use the same top surface (the DEM) but switch off different sides of the domain. Build each but for the mountain block only make it cover the upper 250m. Once you have all the solids built, define permeability in each differently so you can see them, take a single time step forward, and look at the permeability field to make sure everything is in the right place. You'll need to define the slopes but the built in pftool `pfslopex` can be used for that. If you get stuck, a completed example of this is provided in the `Sabino_TFG.tcl` script.
