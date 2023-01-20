Functions and scripts for testing ATOMIX data files and contentions steps.

Prepare downloaded data for comparisons:
1. Download data from Dropbox. Put netcdf and .mat file on external drive and 
     put yml files in metadata folder under "Originals" subdirectory for the 
     dataset
2. Run convert_netcdfIn_to_mat (optional): Only necessary if .mat file is not 
     provided by the PI, or there are issues with .mat file
3. Create a III## (I=initials,##=processID) subdirectory in the 
     metadata/dataset folder. Copy the appropriate metadata for the test. The 
     provided files may need to be modified to include the relevant processing
     information. Also create a *info.yml file to describe this processing method
     and/or parameters.
4. Run convert_matIn_to_JMM_format: Generates files that can be easily read
     in and used for comparisons to other methods. This will need to be run 
     separately for each analysis method included in the provided file. Note:
     If the provided file only has L1 data, then this script does not need to 
     be run.


Process a file using my methods:
1. Create a JMM## subdirectory in the metadata/dataset folder. Copy and/or 
     create the appropriate metadata for the test. Also create a *info.yml 
     file to describe this processing method and/or parameters.
  - Note: initially set parameters using best guess and then modify as necessary.
     In particular calc_spectra_beam_vel.m and plots_singlefile.m can be used to 
     help identify the limits of the intertial subrange.
2. Run calc_ATOMIX_levels: Reads in level 1 data and calculates epsilon based on 
     the processing options specified in the metadata under the JMM## subdirectory
3. Run convert_matOut_to_netcdf (optional): Create an output netcdf file in ATOMIX
     format of the test results.

Look at the results:
* plots_singlefile: Create plots for one data file
* plots_comparison: Compares two (or more) methods



