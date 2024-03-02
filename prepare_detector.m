
% Eth   = [30 80]; %<-- detector threshold
% m2_nSRFTrue = ones(length(E),60);
% for ie = 1:length(Eth)
%     m2_nSRFTrue(1:E(ie)-1) = 0
% end

addpath( './3_src' );
addpath('./data')


    tic
    cd 1_inputdata/
    filename = 'SRF_param.csv';
    fid = fopen(filename, 'wt');

    fprintf(fid,'r_0(um),%.1f\n',r0);
    fprintf(fid,'sigma_e(keV),%.1f\n',sigma_e);
    fprintf(fid,'dpix(um),%d\n',pixel_size*1e3);
    fprintf(fid,'dz(um),%d\n',dz);
    fprintf(fid,'ro_PCD(g/cm3),5.85\n');

    s = sprintf('Nl,%d\n',length(Eth))
    fprintf(fid,s);

    for ie = 1:length(Eth)
        s = sprintf('1,%d\n',Eth(ie));
        fprintf(fid,s);
    end
    fclose(fid);
    cd ../
    
    gen_nCovE
    [m2_nSRF] = calc_SRF_from_Cov3x3( m3_nCov3x3E );


