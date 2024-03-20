close all
clear all
addpath( '../bin' );
addpath( './3_src' );
addpath( './mcgputools' );
read_data                 = 1  ;
get_detector_response     = 0  ;

%% define your detector geometry: 
close all
% From MC_GPU input file:
home_folder = pwd
MCGPU_output_folder = '../Sample_Pencil_Beam/output/PCD/allPhotons'
output_filename = 'pencil_beam_simulation'

read_binary   =  [0, 1] % 1 for the 1st value in arr indicates we read binary 
                       % the second value is required if binary is enabled
                             % 1 - all_scattter data; 2 - non_scatter data;
                             % 3 - compton data; 4- rayleigh data;
                             % 5 - multiscatter data
pixel_size    =  0.1; % mm
Nch           =  3   ; %<--- number of pixles x axis, Nch = geo.nDetector(2);
Nrow          =  3  ; %<--- number of pixles y axis, Nrow = geo.nDetector(1); geo.nDetector=[240; 1];	
Nview         =  1  ; %<--- nb of projections
Estart        =  5   ; %<---  Estart in MCGPU
Eend          =  120  ; %<---  Eend in MCGPU
Nbin          =  115  ; %<--- Number of Energy bins


% For PctK
Eth           = [30 40 60 80]; %<-- detector threshold in KeV
r0            =  8     ; %<---  r_0(um) charge cloud size
sigma_e       = 1.6    ; %<---  keV electronic noise
dz            = 500    ; %<---  um detector thickness
Ep            = 1:120  ; %<---  energy range

%% Read the images --> projections;
if(read_data)
    read_mcgpu
    save('data_MCGPU','Proj_MCGPU')
else
    load('data_MCGPU','Proj_MCGPU')
end
%% The generate the detector covariance response matrix
if (get_detector_response)
    prepare_detector
end
%% Prepare data for 1 keV spacing: 
% step 1:  we start by oversampling:---------------------------------------
E_MCGPU         = linspace(30,120,Nbin)   ;
Ebin            = E_MCGPU(2) - E_MCGPU(1) ;
Eo              = Ep(1):Ebin/100:Ep(end)       ;
Proj_MCGPU_over = zeros(Nview,Nrow,Nch,length(Eo));
for ii = 1:length(E_MCGPU)
    % Find indices of E that are within the current Ep bin
    idx = find( (Eo >= (E_MCGPU(ii)-Ebin/2)) & (Eo < (E_MCGPU(ii)+Ebin/2))  );
    for ix = idx(1):idx(end)
        Proj_MCGPU_over(:,:,:,ix) = Proj_MCGPU(:,:,:,ii)/length(idx);
    end
end
%--------------------------------------------------------------------------
% step 2:  now we do rebining according to Ep:-----------------------------
%Ep = 1:120;
for ii = 1:length(Ep)
    % Find indices of E that are within the current Ep bin
    idx                        = find(Eo >= Ep(ii)-0.5 & Eo < Ep(ii)+0.5);
    Proj_MCGPU_ready(:,:,:,ii) = sum(Proj_MCGPU_over(:,:,:,idx),4);
end
%--------------------------------------------------------------------------




%% run detector response%% get the response of an ideal detector:
%--------------------------------------------------------------------------
% step 1:  Get the ideal PCD response        :-----------------------------
m2_nSRFTrue = zeros(length(Eth),Ep(end));
for ie = 1:length(Eth)
    if ie == length(Eth)
        m2_nSRFTrue(ie,Eth(ie):end)         = 1;
    else
        m2_nSRFTrue(ie,Eth(ie):Eth(ie+1)-1) = 1;
    end
end
%--------------------------------------------------------------------------
% step 2: Run the Pctk functions             :-----------------------------
script_workflow_PcTK_MCGPU
%--------------------------------------------------------------------------

%% save the data
save('data_MCGPU_Pctk','m4_sino_pcd_true', 'm4_sino_pcd_mean','Nl','Nch','Nrow','Nview','-v7.3');
%--------------------------------------------------------------------------
 
%%
% Energy 1
clear a;
a(:,:) = m4_sino_pcd_mean(1,:,:);
figure
subplot(1,2,1)
imagesc(a); axis equal; axis tight 
a(:,:) = m4_sino_pcd_true(1,:,:);
subplot(1,2,2)
imagesc(a); axis equal; axis tight
saveas(gcf, 'data_MCGPU.png');
