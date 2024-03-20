# Instruction Manual
Authors: Preetham Rudraraju, Yee Lam Elim Thompson, Bahaa Ghammraoui

## What is a Photon Counting Detector
A Photon Counting Detector is a specialized radiation detection device designed to keep track of each photon that hits a pixel within the detector's spatial boundaries. While an Energy Integrated Detector takes the aggregate energy deposited by all photons within a designated area, Photon Counting Detectors register and discern each photon and its energies. This capability facilitates the discrimination of varying energy levels among photons, thereby enabling spectral imaging.

The advantage of tracking individual photons lies in its capability to monitor and categorize each photon based on its specific energy level. This feature allows users to selectively concentrate on distinct energy ranges, facilitating the exclusion of extraneous data falling outside the scope of interest.

Due to their photon-counting capabilities, PCDs (Photon Counting Detectors) can produce high-resolution images with improved image contrast. Smaller detector pixels could enable improved spatial resolution and the elimination of down-weighting of lower energy photons.

#
## Changes to the code

The main modifications to the code from MC-GPU v1.3[1] involve enhancements to the tally_image function. This function now integrates the PCD functionality, in addition to changes in reading the input file and the structure of the output files. Specifically, the tally_image function integrates the PCD functionality by aggregating photon counts per pixel rather than energies. However, the function utilizes the energy of each photon before tallying to assign it to its corresponding Energy Bin.

For instance, with Emin set to 30 keV, Emax to 60 keV, and Nbin to 2, two energy bins are created: [30,45] and [45,60]. If a 50 keV photon is detected, it is categorized under the second Energy Bin [45,60].

In the read_input function, the goal is to extract a new line of parameters from the input file. This line includes three new parameters: Emin (minimum energy level to consider), Emax (maximum energy level of photons to consider), and Nbin (Number of Energy Bins to equally divide the user-defined energy range [Emin to Emax]). It's important to note that if Emin is set to a value less than 1, the simulation will use an Energy-Integrated detector instead of a Photon Counting Detector.

The output structure of the results has also been adjusted to facilitate the categorization of photon counts based on their energy levels. Energy Bins are computed by dividing the Energy Range (defined by Emin and Emax) into N (defined by Nbin) equal groups. Before counting the photon at each pixel in the tally_image function, photons are separated into their respective Energy Bins. To achieve this, the image object, which stores results for every projection simulation, had to adopt a three-dimensional structure.

#
## Input Parameters

Most of the parameters have essentially remained unchanged from the previous versions of MC-GPU except for three new additions. These new additions are highlighted in the image below.

<br>
<p align="center">

  <img width="800" height="300" src="https://github.com/DIDSR/MCGPUv1.3_PCD/assets/input.png">

</p>
<br>

These new parameters provide the simulation key variables to successfully run a Photon Counting Detector on MCGPU. The EMin and EMax define the minimum and maximum for the energy range that the user is interested in examining. As a result, a simulated photon that arrives at the detector consisting of energy outside of this user-defined will not be taken into account and excluded from the simulation results. Nbin stands for the number of energy bins. This variable defines how many equal groups the energy range be split into. 



#
## Output Structure
A New Image Structure was required to accept a simulation that is categorized by Energy Bins. A 3-D matrix configuration was adapted for the image object.

X -> Energy Bin <br>
Y -> Energy Interaction <br>
Z -> Pixel Number in the detector <br>

<p align="center">


The Figure below displays the output structure of results in the new Photon Counting Toolkit version. Unlike previously all the results will be located in an output folder. The location of the output folder can be modified by changing the output image file name parameter in the input file. 

<br>

<p align="center">

  <img width="600" height="800" src="https://github.com/DIDSR/MCGPUv1.3_PCD/assets/structure.png">

</p>

<br>


The output folder consists of two subfolders EID and PCD. EID or Energy Integrated Detector subfolder will only receive results when an EID simulation is run (when Nbin < 1). Likewise, the PCD or Photon Counting detector subfolder will only receive results when a PCD simulation is run (when Nbin >= 1). The output results and binary output results in the EID option have remained unchanged from MCGPU v1.3 except for the fact that they are now located in the /[Image File Output Name]/Output/EID. Meanwhile, for PCD the structure of the output files themselves has changed. The Image below shows one of the projection output data files from the new PCD version.


<br>

![image](assets/output.png)

Although each row still represents a pixel from the detector, the columns no longer represent one of the four types of photon interactions. Instead, each column now represents each energy bin in increasing order. This means the number of columns in thr PCD output files directly corresponds to the Nbin parameter that's defined. 

On the other hand, the columns no longer represent one of the four types of photon interactions. Instead, each column now represents each energy bin in increasing order. This means the number of columns in thr PCD output files directly corresponds to the Nbin parameter that's defined in input file.

Because the representation of the type of photon interaction data was removed from the output data, this was replaced with two subfolders within the PCD subfolder. We now have :

1. NonScatteredPhotons
2. allPhotons

The NonScatteredPhotons subfolder has the the phtoton counts at each pixel grouped in their respective energy bins for photons that did not encounter any sort of scattering interaction between the source and the detector (Non-Scattered). Meanwhile the allPhotons will include all photon counts; those that are Non-Scattered, have had a single Compton interaction, a single Rayleigh interaction, or a multi-scattered photon. For more information on the interactions data refer to the README.

<br>

</p>

#
## Running Sample
Before running the simulation please make sure you have all requirements to the run the MCGPU software. This sample walkthrough will assume you have a good understanding of running MCGPU v1,3. If you have any issues with the base requirements please go over the Installation and Compilation subsection of MCGPU v1.3[1].

<br>

> [!NOTE]
> Please refer to the compilation section of the MCGPU v1.3 README for more information on compiling the code

<br>

In the Sample_Pencil_Beam folder, you will see the pencil_beam_simulation.in file which consists of the parameters along with the paths to phantom voxel file and material files. We will run this sample file from the home MC-GPU folder. First, we need to compile the MCGPU software and generate an executable. We can accomplish this by running 'make' in terminal located at the home MCGPU directory.

<br>

```
cd /MCGPUv1.3_PCD
```

<br>

> [!WARNING]
> Both MCGPU v1.3 and MCGPU v1.3_PCD have only been tested in a Linux environment. If you are trying to run this on another environment you may run into a few issues. For cuda version 12.4+, you may need the ![cuda-samples toolkit](https://github.com/NVIDIA/cuda-samples) and modify the `Makefile` or `make_MC-GPU_v1.3_PCD.sh` to point to the common folder in the cuda-samples toolkit.

<br>

```
make
```

<br>

This will generate an executable file `MC-GPU_v1.3_PCD.x` which we can now use to run the input file with the MC-GPU program. 

<br>

```
./MC-GPUv1.3_PCD.x Sample_Pencil_Beam/pencil_beam_simulation.in | tee MC-GPU_v1.3.out
```

<br>

Now on the terminal, you will see the MCGPU application running the simulation. The current progress will be displayed as it will indicate which projection the program is currently simulating. Once finished the output file will be populated with the results of the simulations. The default path for the output file is set to inside the Sample folder, however, you can change this accordingly by adjusting the output file path parameter in the input file.




#
## Integrating the Photon Counting Toolkit with MCGPU to get Ideal PCD results

This version of MCGPU is capable of simulating a Photon Counting Detetor. However, this simulation is only capable of producing results from that of an ideal Phototon Counting Detector. For those who are interested in getting simulation results to that of a realistic Photon Counting Detector, we included scripts to facilitate the integration to the Johns Hopkins Photon Counting Toolkit (PcTK), developed by Ken Taguchi, on the MCGPU simulation output.

<br>

> [!NOTE]
> To run PcTK-MCGPU scripts you will be required to have the Photon Counting Toolkit software installed. For Installation of PctK, follow the instructions at https://pctk.jhu.edu/. The matlab scripts in PcTK_Integration/ folder are meant to be the plugs-in such that PcTK can read the MCGPU outputs.

<br>

Once you download the PcTK from Ken, copy or move the entire package into the PcTK_Integration/ folder.

<br>

> [!NOTE]
> The scripts we provided are currently only compatible with PcTK version 3.2.4. The scripts will be updated as new versions of PcTK become available if required.

<br>

For the first time you ever run PcTK, you must run `3_src/gen_nCovE.m` to generate spectral response as normalized energy-dependent covariance matrix for 3x3 neighboring pixels. For it to work with MCGPU outputs, we require two modifications to this script before running it. First modification is around L142 with the following code:
```
% Create filenames for nCov3x3E and nCov3x3w using parameters
    if ~exist(dirname_outputdata,'dir')
        mkdir(dirname_outputdata);
    end
    % nCov3x3w
    filname_nCov3x3w = ...
        sprintf('dat_nCovw_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f_Eth',...
        model_version, dpix, dz, r0, e_sig);
    for iEth=1:Nl
        filname_nCov3x3w = sprintf('%s_%.1f', filname_nCov3x3w, v_Eth(iEth));
    end
    filname_nCov3x3w = sprintf('%s_keV.mat',filname_nCov3x3w);
    filename_nCov3x3w = [dirname_outputdata,filname_nCov3x3w];  % for nCov3x3w file
```
This should be modified to ...
```
% Create filenames for nCov3x3E and nCov3x3w using parameters
    if ~exist(dirname_outputdata,'dir')
        mkdir(dirname_outputdata);
    end
    % nCov3x3w
    filname_nCov3x3w = ...
        sprintf('dat_nCovw_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f_Eth',...
        model_version, dpix, dz, r0, e_sig);
    %%%% Changes  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for iEth=1:Nl
    %     filname_nCov3x3w = sprintf('%s_%.1f', filname_nCov3x3w, v_Eth(iEth));
    % end
    % filname_nCov3x3w = sprintf('%s_keV.mat',filname_nCov3x3w);
    filname_nCov3x3w = sprintf('%s.mat',filname_nCov3x3w);
    %%%% Changes  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filename_nCov3x3w = [dirname_outputdata,filname_nCov3x3w];  % for nCov3x3w file
```
Another modification happens in L192:
```
%% (5) Generate nCovE data for 3x3 pixels
    t1 = clock;
    v_E = (1:1:170)'; 
    fprintf('\n');
    fprintf('nCov3x3pix: start time = %02d:%02d:%02.0f (hour:min:sec)\n', t1(4),t1(5),t1(6));
```
It should be changed to ...
```
%% (5) Generate nCovE data for 3x3 pixels
    t1 = clock;
    %%%% Changes  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v_E = Ep;%(1:1:170)'; 
    %%%% Changes  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n');
    fprintf('nCov3x3pix: start time = %02d:%02d:%02.0f (hour:min:sec)\n', t1(4),t1(5),t1(6));
```
Once the changes are applied, run the matlab code in the matlab interactive coding enviornment.
```
>> cd PcTK_Integration/3_src
>> gen_nCovE
```

Next, we can run PcTK with MCGPU outputs. We provided two example matlab scripts for the pencil and fan beam examples. For now, we focus on the pencil beam outputs. User should have already run the `MC-GPUv1.3_PCD.x` to generate a set of outputs under Sample_Pencil_Beam/output/PCD/allPhotons/ with many projections. Here are the steps to run PcTK with these outputs:

1. In generate_MCGPU_PENCILBEAM_SAMPLE.m, modify L16-27 to match the detector settings in Sample_Pencil_Beam/pencil_beam_simulation.in.
2. In the matlab interactive coding enviornment, run the script
```
>> cd PcTK_Integration/
>> generate_MCGPU_PENCILBEAM_SAMPLE
```

When completed, you will see the three files:
* data_MCGPU_Pctk.mat includes the MCGPU outputs with detector response
* data_MCGPU.mat includes the original MCGPU outputs in .mat format
* data_MCGPU.png: MCGPU output from 1 projection with and without detector response

#
## References

1. Pctk https://pctk.jhu.edu/
