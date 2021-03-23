
I_gs = imread('hw_test_img.bmp'); %image is 160x120 resolution (120 rows 160 columns)

[M,N] = size(I_gs);
DCT_I = fi(zeros([M,N]), 1, 18, 0);

block_size = 8;
b = block_size;

% % create a cos LUT
% cosLUT = fi(zeros(8,8),1,9,8); % signed fixed-point binary point scaling
% for k = 0 : 7
%     for m = 0 : 7
%         cosval = cos( (pi/8)*k*(m+0.5) );
%         cosLUT(k+1,m+1) = fi(cosval, 1, 9, 8);
%         %fprintf('actual %12.9f, fixed point: %12.9f\n', cosval,double(cosLUT(k+1,m+1)));
%     end
% end

file = fopen('Load_Controller_Output_ref.txt','w');
fprintf(file, 'Pixel Value, K index, L index\n');

k_index = 0;
el_index = 0;

for r = 0:(M/block_size)-1
    for c = 0:(N/block_size)-1
        
        for local_k_index = 0:7
            for local_el_index = 0:7
                
                for m = 0:7
                    for n = 0:7
                        k_index  = (r*8) + m;
                        el_index = (c*8) + n;
                        fprintf(file, '%3d, %d, %d\n', I_gs(k_index+1,el_index+1),local_k_index,local_el_index);
                    end
                end
                
            end
        end
        
    end
end

fclose(file);