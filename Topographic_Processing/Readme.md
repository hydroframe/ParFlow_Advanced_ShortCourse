# Overland Flow Formulations and Topographic Processing
*ParFlow Advanced Short Course, *
*by Laura Condon*
*(lecondon@email.arizona.edu)*

## Overview
These exercises are designed to help you understand the different overland flow boundary conditions available in ParFlow and approaches for processing topography consistent with these boundaries. This is divided into two exercises:

- Exercise 1: Overland flow test cases
- Exercise 2: Topographic processing workflow

## Exercise 1: Overland Flow Test Cases
For this exercise we will run two very simple domains from the ParFlow test suite to demonstrate the behavior of the three overland flow keys *OverlandFlow*, *OverlandKinematic, and *OverlandDiffusive*.  The test cases used here are modified from the main ParFlow test directory. You can see these in their original form in the test directory along with some additional overland flow test cases for a sloping slab test (look for all the test cases named overland_*.tcl).


### 1. Ponded water on a flat domain (*overland_FlatICIP.tcl*)
The first exercise is a flat domain with a small amount of water ponded in the center.  

**Activity:**
- Read the *overland_FlagICP.tcl* to understand the test cases. Try to answer the following:
  1. What overland flow formulation is being used?
  2. Where is this ponding occurring in the domain?
  3. Is any addition water being added?
  4. What do you expect to happen to this ponded water over the course of the simulation?
- Run the test in its original configuration (don't forget to specify your processor configuration when you do your tclsh call)
- Look at the outputs in ParaView and see if they match your intuition
- Modify the test script to use the other two overland flow boundary conditions. I recommend changing the run name for your subsequent tests so that your first results don't get overwritten.
  1. How do you expect things to change between these three cases?


### 2. Raining on a Tilted V (*overland_tiltedV.tcl*)
The second exercise is a very simple catchment represented by two sloping slabs (i.e. a 'Tilted V'). For this exercise the domain will start dry and we will rain on it.

**Activity:**
- Read the *overland_tiltedV.tcl* to understand the test cases. Try to answer the following:
  1. How is the tilted V formed for the original *OverlandFlow* simulation?
  2. How does this change for the *OverlandKinematic*? And why is this necessary?
  3. How much are we raining on the domain and for how long?
  4. What do you expect to happen over the course of this simulation?
  5. Should the two tests (i.e. *OverlandFlow* and *OverlandKinematic*) get the same result?
- Run the test in its original configuration (don't forget to specify your processor configuration when you do your tclsh call)
- Look at the outputs in ParaView and see if they match your intuition
- Modify the script to swap and use *OverlandKinematic* for the first configuration and *OverlandFlow* for the second and rerun.
  1. How do you expect things to change when you do this swap?
  2. What is the difference between these and the original simulations?
- Add an *OverlandDiffusive* test case to this script.
  1. Which Tilted V configuration should you use?
  2. How do the results differ between this test and the other two?


**Extra Activities:**
If you have extra time:
1. Go to the test directory of ParFlow and compare the tests you just did here to the series of overland tests available there.
2. Change up the script we used to explore different solver options similar to the ones in the test directory. Look at the kinsol logs to see how the different solver options change performance.
3. Change the intensity of rainfall and/or slope of the V and see what happens.
4. Turn the flat case into a sloping slab and change where you start the initial ponded water.

## Exercise 2: Topographic Processing
