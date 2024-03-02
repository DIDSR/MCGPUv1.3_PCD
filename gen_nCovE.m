%function    gen_nCovE
addpath( './3_src' );
%==========================================================================
%
%   funciton gen_nCovE
%
%   This program generates spectral response as normalized energy-dependent 
%   covariance matrix for 3x3 neighboring pixels (1 primary pixel C, 
%   4 edge pixel Xs, and 4 corner pixel Ds). 
%   
%   Apr 14, 2017.   ver 3.0     K. Taguchi (JHU)
%               Using a numerical approach as
%               (1) Charge density of cloud defined as 3D Gaussian
%               (2) Charge size independent of energy
%               (3) PDF of relative locations of the secondary charge
%               (fluoro) indepdent of energy (effect of K-escape ignored)
%               (4) Able to model triple- and quadruple-counting
%               (5) Thus, covariance of X-D and X-X non-zeros
%               (6) No energy-degradation function lambda(E)
%               (7) Slow to process, large file sizes
% 
%   Apr 21, 2017.   ver 3.1     K. Taguchi (JHU)
%               (1) Simultaneous processing of q={0,1,2}
%               (2) The use of quadrant and symmetry for x4 effiicency
%   Jun 12, 2017.   ver 3.2     K. Taguchi (JHU)
%               (1) quadrant_symmetry ver 1.1 called from calc_nCovE_3x3pix
%               (always use upper triangle, with transpose)
%               (2) resample_quadrant ver 1.0 (r=3,q=2) sampling for
%               comparable mean and std of r_K
%   Feb 9, 2018.    ver 3.21    K. Taguchi (JHU)
%               (1) Comments and notes added. 
%   Mar 15, 2018.   ver 3.21a   K. Taguchi (JHU)
%               (1) Official site address, "About us" added
%
%   The official site of PcTK is pctk.jhu.edu
%
%   We are CT research group at Division of Medical Imaging Physics, 
%   Department of Radiology, Johns Hopkins University. PcTK has been 
%   developed in collaboration with Siemens Healthineers (Forchheim,
%   Germany). We wish to help the community by making PcTK available to
%   academic researchers. Please respect our goodwill and community spirit, 
%   and follow the guidelines and rules in place. For example, 
%       - Each user should submit the signed software license agreement. 
%       - No commercial use, either directly or indirectly, is permitted. 
%
%==========================================================================

%%   Below are the history as gen_SRE_E_PIECE2.m 
%
%   Aug 16, 2015. ver 1.0   K. Taguchi (JHU).
%   Sep 08, 2015. ver 1.1   K. Taguchi (JHU). pr of re(E) and pr of dk used
%   Oct 14, 2015. ver 1.2   K. Taguchi (JHU).
%               Ek at both K_Cd (26.7 keV) and K_Te (31.8 keV) with K_eff (29.35 keV)
%               Pr_p2(p=2,E)=0 if E<E_Cd, =val/2 if E_Cd<E<E_Te, =val if E_Te<E
%               Ek(E) = E_Cd if E_Cd<E<E_Te, E_eff if E_Te<E
%   Oct 14, 2015. ver 1.3   K. Taguchi (JHU). multiply Pr(p>0|E). 
%   Nov 18, 2015. ver 1.4   K. Taguchi (JHU).
%               Ekedge at both K_Cd (26.7 keV) and K_Te (31.8 keV) -> Kedge_eff (28.23 keV)
%               Ekbind at both K_Cd (Ka=26.1 keV, Kb=23.2 keV) and K_Te (Ka=31.0 keV, Kb=27.5 keV) with (0.7,0.3) ratio -> K_eff (25.00 keV)
%               Elbind at both L_Cd (3.3 keV) and L_Te (4.0 keV) with (0.7,0.3) ratio -> L_eff (3.51 keV)
%               fluorescence x-ray (K-peak) energy at Ek-El = K_eff - L_eff = 25.00 - 3.51 = 21.49 keV 
%   Dec 18, 2015. ver 1.5   K. Taguchi (JHU).
%               When q=2, EX+EC=Ekbind + (Ek-El) = EA+EB, not Ein. 
%               Thus, 0->(EA+EB) for X and (EA+EB)->0 for C are correlated. 
%   Dec 28, 2015. ver 1.6   K. Taguchi (JHU)
%               Measurement-based energy calibration method applied from
%               E3 to E_{MC}
%   Feb 3, 2016. ver 1.7    K. Taguchi (JHU)
%               Measurement-based energy calibration method changed to linear extrapolation below x(1)=40 keV 
%   Feb 11, 2016. ver 1.8   K. Taguchi (JHU) 
%               wq2, scaling parameter for p=1,q=2 (which mainly affects fluorescence peak)
%   Feb 15, 2016. ver 1.9  K. Taguchi (JHU) 
%               (1) saving SRF data after multiplied with conditional
%               probabilities, (1-Pr_p0)*(Pr_p), (1-Pr_p0)*(1-Pr_p)*(Pr_q1), (1-Pr_p0)*(1-Pr_p)*(1-Pr_q1)
%               (2) saving 3 SRFs, EC, EX, and ED, for 3 types of pixels
%               (3) a parameter "rate_D" for diagonal pixel read from the file and added to global parameters
%   Mar 23, 2016. ver 2.0  K. Taguchi (JHU)
%               (1) K-escape peak at E1-EK, not E1-Efluoro, fluoro peak at Efluoro. 
%               This was found incorrect (see K. Stierstorfer's emails and figure on 3/23-24/2016)
%   Mar 29, 2016. ver 2.1  K. Taguchi (JHU) 
%               (1) fluorescence x-ray (K-peak) energy at Efluoro, calculated from Ka/Kb and its yields. 
%               (2) energy degradation factor applies to fluoro inside q2
%               (3) option flag_plot(17)=3 to create/save a movie with various e_sig and wq2 parameters  
%   Apr 9, 2016. ver 2.2  K. Taguchi (JHU) 
%               (1) energy degradation factor linear function of energy,
%               lambda(E)=E/E_ref*lambda0. 
%   Dec 19, 2016. ver 2.3  K. Taguchi (JHU)
%               Relatively minor mods
%   Mar 23-Apr 2, 2017. ver 2.4  K. Taguchi (JHU)
%               (1) clean up codes, add comments
%               (2) mods to do steps Step 3. Generate SRE for released software package
%               (3) charge cloud size function has an offset and power parameter
%               (4) with q=2 (fluoro emission), the size of the primary and secondary clouds 
%                   is a function of input energy (E1), not E1-Eflu nor Eflu
%   Apr 4, 2017. ver 2.5  K. Taguchi (JHU)
%               A gaussian noise added to model charge induction: sCI and sigCI 


%%%%%%%%%%%%%%%%%%% clear all; 
%%%%%%%%%%%%%%%%%%% close all; 

%% User-defined parameters and file names

    % Input data foldername for the parameter file and 
    dirname_inputdata  = './1_inputdata/' ; 
    
    % parameter file name
    %filename_params  = [dirname_inputdata,'SRF_param_v32_20170622.csv']; 
    filename_params  = [dirname_inputdata,'SRF_param.csv'];
    
    % nCov3x3E and nCov3x3w data will go to the output data folder. 
    % The folder name is the same as the input folder in this example, 
    % because these data will be the input to the workflow script 
    % (script_wrapper_PXtalk32) and be read from this folder. 
    dirname_outputdata = './2_outputdata/' ; 
%    dirname_outputdata = '/Users/ken/Dropbox/Misc/3_Ken_PIECE-1/1_sw_release/ver3.2/1_inputdata/' ; 

%% Fixed parameters
    model_version = 3.2; 
    PCD_type  = 1;      % =1 CdTe, which is the only detector for now
    eps = 0.001;        % tiny value used with floor( ) function 
    fprintf('\n\n *** PcTK version %.2f. Generating nCovE and nCovW *** \n\n', model_version);

%% Set clock
    tts = clock;
    fprintf('\n');
    fprintf('gen_nCovE: start time = %02d:%02d:%02.0f (hour:min:sec)\n\n', tts(4),tts(5),tts(6));

%% Read parameters from the file, a chance to override parameters 
% (0) Initialization
% read parameter set
    fprintf('Reading parameters \n');
    [r0,e_sig,dpix,dz,rho_PCD,Nl,v_Eth] = func_read_params(filename_params, model_version); 

% Decide a sampling pitch of photon incident locations (um)
    if dpix < 551
        dx = 0.2; 
    else
        dx = 0.4; % needs to make dx bigger to decrease matrix size necessary for large dpix
    end

% Create filenames for nCov3x3E and nCov3x3w using parameters
    if ~exist(dirname_outputdata,'dir')
        mkdir(dirname_outputdata);
    end
    % nCov3x3w
    filname_nCov3x3w = ...
        sprintf('dat_nCovw_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f_Eth',...
        model_version, dpix, dz, r0, e_sig);
    %%%% Bahaa 11/28/2023  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for iEth=1:Nl
    %     filname_nCov3x3w = sprintf('%s_%.1f', filname_nCov3x3w, v_Eth(iEth));
    % end
    % filname_nCov3x3w = sprintf('%s_keV.mat',filname_nCov3x3w);
    filname_nCov3x3w = sprintf('%s.mat',filname_nCov3x3w);
    %%%% Bahaa 11/28/2023  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filename_nCov3x3w = [dirname_outputdata,filname_nCov3x3w];  % for nCov3x3w file
    
    % nCov3x3E
    filname_nCov3x3E = ...
        sprintf('dat_nCovE_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f.mat',...
        model_version, dpix, dz, r0, e_sig);
    filename_nCov3x3E = [dirname_outputdata,filname_nCov3x3E];  % for nCov3x3E file
    
%% (1) Read and calculate PCD properties mu (1/um)
% mu(v_E0) of PCD and v_E0=(1:1:200)'
    fprintf('Calculating PCD-related data \n');
    if PCD_type == 1
        [ v_E, v_mu_PCD, v_Ekedge, v_Efluoro, muK, Pr_q0 ] = calc_CdTe( dirname_inputdata, rho_PCD ); 
    else
        fprintf('\nError! PCD_type = %d\n', PCD_type);
        fprintf('PCD_type must be 1 (=CdTe).\n');
        fprintf('Other options will be implemented later.\n');
        return;
    end
    
% lin atten coeff for fluoro x-rays (1/um)
    muK = muK.*10^-4;   % (1/cm) to (1/um)

%% (2) Calculate probabilities Pr( p,q | E )
    fprintf('Calculating probabilities Pr( p,q | E ) \n');
    [v_Pr_p, v_Pr_pq] = calc_pr_p0_q2(v_E, v_mu_PCD, dz, Pr_q0, v_Ekedge(100), muK); 

%% (3) Generate pmf of secondary cloud sites, v_pmf, and its quadrant samples, v_qpmf
    fprintf('Calculating PMF of secondary cloud locations \n');
    [v_pdf_fx, ds, v_sk, v_sk_edge]          = calc_pdf_fx(muK);
    [v_pmf, v_tx, v_ty, v_qx, v_qy, v_qpmf] = resample_quadrant(v_sk, v_pdf_fx); 
    i_skx = floor(v_qx./dx +eps);
    i_sky = floor(v_qy./dx +eps);
    n4sk2 = length(i_sky);

%% (4) Generate 2-D electronic charge cloud density map, rho_e(x,y)
    fprintf('Generating electornic charge cloud density data, rho_e \n');
    [ m2_rho_e, nx, cx ] = calc_pdf_rhoe2D( r0, dx ); 

%% (5) Generate nCovE data for 3x3 pixels
    t1 = clock;
    %%%%%% Bahaa 11/28/2023
    v_E = Ep;%(1:1:170)'; 
    %v_E = (1:1:60)'; 
    fprintf('\n');
    fprintf('nCov3x3pix: start time = %02d:%02d:%02.0f (hour:min:sec)\n', t1(4),t1(5),t1(6));

% Generate and write m3_nCov3x3E and m3_nCov3x3w files
    [v_Eo, m3_nCov3x3E, m3_nCov3x3w, m2_SRE_q0, m2_SRE_q1, m2_SRE_q2, m2_nvol] ...
    = calc_nCovE_3x3pix(v_E, dpix, e_sig, v_Pr_pq, dx, m2_rho_e, v_Efluoro, ...
        v_qpmf, i_skx, i_sky, n4sk2, filname_nCov3x3E, filname_nCov3x3w, v_Eth);

    t2 = clock;
    fprintf('\n');
    fprintf('nCov3x3pix: start time = %02d:%02d:%02.0f (hour:min:sec)\n', t1(4),t1(5),t1(6));
    fprintf('          : end   time = %02d:%02d:%02.0f (hour:min:sec)\n', t2(4),t2(5),t2(6));
    fprintf('          : proc  time = %02d:%02d:%02.0f (hour:min:sec)\n', (t2(4)-t1(4)),(t2(5)-t1(5)),(t2(6)-t1(6)));

%%
    tte = clock;
    fprintf('\n');
    fprintf('gen_nCovE: start time = %02d:%02d:%02.0f (hour:min:sec)\n', tts(4),tts(5),tts(6));
    fprintf('         : end   time = %02d:%02d:%02.0f (hour:min:sec)\n', tte(4),tte(5),tte(6));
    fprintf('         : proc  time = %02d:%02d:%02.0f (hour:min:sec)\n', (tte(4)-tts(4)),(tte(5)-tts(5)),(tte(6)-tts(6)));

    %%
    [m2_nSRF] = calc_SRF_from_Cov3x3( m3_nCov3x3E );
    
    %%
    save('data_100um_r024_sigmae2','m2_nSRF','v_E','v_Eo')
