 model_version = 3.2;
    fprintf('\n\n *** This script uses codes and scriplt from PcTK version %.2f: \n', model_version);
    fprintf('          Generating PCD data with correlation *** \n\n'); 
    % Directory/folder names for input/output data and parameter files
    dirname_inputdata  = './1_inputdata/' ;
    dirname_outputdata = './2_outputdata/';
    if ~exist(dirname_outputdata,'dir')
        mkdir(dirname_outputdata);
    end
 
 

    % Read PCD parameters
    filename_PCDparam = [dirname_inputdata,'SRF_param_v32_20170622.csv'];  % file for PCD parameters
    [r0,e_sig,dpix,dz,rho_PCD,Nl,v_Eth] = func_read_params(filename_PCDparam, model_version);
   
%%   Step 1. Read detector data
    ein = Ep ;
    filnam_nCov3x3w = ...
        sprintf('dat_nCovw_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f_Eth',...
        model_version, dpix, dz, r0, e_sig);
    %%%%%%%%%%%%%%%%%%%%%%%% Bahaa %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filnam_nCov3x3w = sprintf('%s.mat',filnam_nCov3x3w);
    filename_nCov3x3w = ['./',filnam_nCov3x3w];  % for nCov3x3w file
    filnam_nCov3x3E = ...
        sprintf('dat_nCovE_ver%.1f_dpix_%d_dz_%d_r0_%d_esig_%.1f.mat',...
        model_version, dpix, dz, r0, e_sig);
    filename_nCov3x3E = ['./',filnam_nCov3x3E];  % for nCov3x3E file
   
    % read nCov3x3w data generated by PcTK
    if exist(filename_nCov3x3w,'file')
        load(filename_nCov3x3w);
    else
        fprintf('File nCov3x3w does not exist. \n');
        if exist(filename_nCov3x3E,'file')
            fprintf('Attempting to create nCov3x3w from nCov3x3E.\n');
            fprintf('FYI, filename of nCov3x3w is %s\n',filename_nCov3x3w);
            load(filename_nCov3x3E);
            m3_nCov3x3w=zeros(length(v_Eth)*9,length(v_Eth)*9,size(m3_nCov3x3E,3));
            for j=1:size(m3_nCov3x3w,3)
                [ m3_nCov3x3w(:,:,j) ] = func_covE2covBin( squeeze(m3_nCov3x3E(:,:,j)), v_Eo, v_Eth );
            end
            save(filename_nCov3x3w,'v_Eo','v_E1','m3_nCov3x3w','v_Eth','v_Pr_pq','-v7.3');
        else
            fprintf('File nCov3x3E does not exist as well. \n');
            fprintf('Please run gen_nCovE to create nCov3x3E.\n\n');
            fprintf('BTW, filename of nCov3x3E is %s\n',filename_nCov3x3E);
            fprintf('BTW, filename of nCov3x3w is %s\n',filename_nCov3x3w);
            return;
        end
    end
 
%%   Step 2. Calculate a 4-D spectrum sinogram
    n1 = size(m3_nCov3x3w,1);
    n2 = size(m3_nCov3x3w,2);
    n3 = length(Ep);         
    for iv=1:Nview
        t1 = clock;
        fprintf(' on view %d of %d: time = %d:%d:%.0f (hour:min:sec)\n', iv,Nview,t1(4),t1(5),t1(6));
        pause(0.5);
        m3_yt = zeros(Nl, Nch+2, Nrow+2);
        m3_yn = zeros(Nl, Nch+2, Nrow+2);
        for irow=1:Nrow
            disp(irow);
            m2_St = zeros(length(Ep),Nch);
            v_St  = zeros(length(Ep),1)  ;
            for ich=1:Nch
 
                m2_St(:,ich) = Proj_MCGPU_ready(iv,irow,ich,:);
            %   Step 1. 4-D spectrum sinogram from MC-GPU
                v_St(:) = Proj_MCGPU_ready(iv,irow,ich,:);
               
            %   Step 2: The below 3 lines thanks to Scott Hsieh of UCLA (ver 1.03)
                m3_nCov3x3w_abbreviated = m3_nCov3x3w(:,:,1:n3);
                shortForm = reshape(m3_nCov3x3w_abbreviated, [n1*n2, n3]);
                m2_cov3x3j = reshape(shortForm * v_St, [n1, n2]);
 
            %   Step 3: Calculate a noise-free 4-D count sinogram, nR(Nl,ch,row,view)
                % gen pcd data (noise free)
                v_mean = diag( m2_cov3x3j );
                m3_pcd3x3jt = reshape( v_mean, [Nl,3,3] );
            %   Step 4: Generate a 4-D count sinogram, nRm(Nl,ch,row,view)
                if min( eig(m2_cov3x3j) ) < 0 % then not positive-semidefinite
                    m2_cov3x3j = sup_offdiag( m2_cov3x3j );
                end
               
                % add 3x3 data to a global matrix
                m3_yt(:,ich:(ich+2),irow:(irow+2)) ...
                    = m3_yt(:,ich:(ich+2),irow:(irow+2)) + m3_pcd3x3jt;
 
 
            end % ich
             m2_yt_true = m2_nSRFTrue* m2_St; %<---Ideal PCD changed by Bahaa
             m4_sino_pcd_true(:,:,irow,iv) = m2_yt_true;
 
        end % irow
 
        m4_sino_pcd_mean(:,:,:,iv) = m3_yt(:,2:(end-1),2:(end-1));
 
    end %iv