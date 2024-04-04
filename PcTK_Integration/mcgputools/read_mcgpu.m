%clear all
Nx = Nrow ;
Nz = Nch  ;
NE = Nbin ;

cd (MCGPU_output_folder)
numProjections = Nview;
tic
for ii = 0:numProjections-1
    if read_binary(1) == 1
        if numProjections == 1
            filename = strcat (output_filename, sprintf('.dat.raw'));
        else
            filename = strcat (output_filename, sprintf('.dat_%04d.raw',ii));
        end
        cd (home_folder)
        readRaw
        if numel(M) == Nx * Nz * NE
           Proj_MCGPU(ii+1,:,:,:) = reshape(M,Nx,Nz,NE);
        else
            disp('Error: Total number of elements must remain the same after reshaping.');
        end
        ii
    else
        if numProjections == 1
            filename = strcat (output_filename, sprintf('.dat'));
        else
            filename = strcat (output_filename, sprintf('.dat_%04d',ii));
        end
        read_here
        if numel(M) == Nx * Nz * NE
           Proj_MCGPU(ii+1,:,:,:) = reshape(M,Nx,Nz,NE);

        else
            disp('Error: Total number of elements must remain the same after reshaping.');
        end
        ii
    end
end
toc

cd (home_folder)


