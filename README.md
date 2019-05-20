# BLIZ
Masking and ESMF regridding instructions for climate data provided by LfU
By Alex Resovsky

This document describes step-by-step how to interpolate and prepare the climate data provided by LfU for Bavaria-wide simulations with LPJ-GUESS. The raw data are not compatible with the LPJ-GUESS crop/management version and require some post-processing before running a simulation.  The following procedure can be used to produce consistent, LPJ-GUESS-compatible driver data from the raw data files. 

To date, LfU has provided us with two downscaled EURO-CORDEX datasets for Bavaria, each using the hydbav-EUR-11_ICHEC-EC-EARTH_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014 climate projections. The various acronyms used in the nametags have different meanings; EUR-11 means that the data are at 11-km resolution, ICHEC-EC-EARTH is the GCM used to drive the simulation, r1i1p1 refers to the initial conditions used, KNMI is the institute that ran the simulations, and RACMO22E is the regional climate model used for Europe. hydbav indicates that the data are downscaled for Bavaria, and DT-TRANS-KliRef2014 refers to the reference dataset used by the LfU team, which differs from the EURO-CORDEX reference data mainly in precipitation in the south of Bavaria (per discussions with Frank Bäse).

The data files must be downloaded separately from the LfU cloud server. I downloaded precipitation, insolation and surface temperature data files in netcdf format for two scenarios, rcp4.5 and rcp8.5. These data were at the daily timestep and split into decadal files for 1971-2100.



Step 1. Make time the record dimension
	
There are a few things you’ll need to do first, because the data provided by LfU have some issues. Firstly, they do not have the “time” variable identified as the record dimension, which is necessary for working with .nc files. If you try to concatenate the data into 130-year files without first making time the record dimension, you may encounter problems.

Run the folowing nco command:

ncks -mk_rec_dmn Time in.nc out.nc



Step 2. Unpack the data

It’s possible that this step can be skipped because although the data are packed, scale_factor is set to 1.0 and add_offset is set to 0.0, meaning the packing shouldn’t actually have any effect on the data. Unpacked data is a bit easier to work with, but the unpacking procedure may take some time.

ncpdq -O -P upk in.nc out.nc



Step 3. Concatenate the data files

Now you’re ready to concatenate. This can be done with the following linux nco command:

ncrcat -r <infile1.nc> <infile2.nc> <outfile.nc>

The entire process will take several hours so best to do all three variables at the same time (run the commands in three different windows, for example).  You might also try extracting the monthly mean values from the decadal daily files first (step 4), and then concatenating the monthly files. This might save you some time.



Step 4. Extract monthly data from the daily files.

You can do this with cdo commands. First, create a monthly total precipitation file:

cdo monsum <pr_1971-2100_daily.nc> <pr_1971-2100_monsum.nc>

Next, create a monthly average surface temperature file:

cdo monmean <tas_1971-2100_daily.nc> <tas_1971-2100_mon.nc>

Finally, create a monthly average rsds file:

cdo monmean <rsds_1971-2100_daily.nc> <rsds_1971-2100_mon.nc>

Now you have three 130-year monthly files, one for each of the three meteorologic variables (pr_1971-2100_monsum.nc, tas_1971-2100_mon.nc, and rsds_1971-2100_mon.nc, or whatever you choose to call them).





