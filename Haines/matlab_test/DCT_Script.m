
I_gs = fi(imread('hw_test_img.bmp'), 0, 8, 0); %image is 160x120 resolution (120 rows 160 columns)

[M,N] = size(I_gs);
DCT_I = zeros([M,N]);
%DCT_I = fi(zeros([M,N]), 1, 18, 0);

block_size = 8;
b = block_size;

% create a cos LUT
cosLUT = fi(zeros(8,8),1,9,8); % signed fixed-point binary point scaling
for k = 0 : 7
    for m = 0 : 7
        cosval = cos( (pi/8)*k*(m+0.5) );
        cosLUT(k+1,m+1) = fi(cosval, 1, 9, 8);
        %fprintf('actual %12.9f, fixed point: %12.9f\n', cosval,double(cosLUT(k+1,m+1)));
    end
end

%  for r = 0:0
%      for c = 0:0
for r = 0:(M/block_size)-1
    for c = 0:(N/block_size)-1
        disp(r)

        data = I_gs( (r*b+1:r*b+b) , (c*b+1:c*b+b) );
        DCT_I( (r*b+1:r*b+b) , (c*b+1:c*b+b) ) = DCT_block( data, cosLUT );
        
    end
 end


%%

I_restored = uint8(zeros([M,N]));

for r = 0:(M/block_size)-1
    disp(r)
    for c = 0:(N/block_size)-1
        
        data = DCT_I( (r*b+1:r*b+b) , (c*b+1:c*b+b) );
        I_restored( (r*b+1:r*b+b) , (c*b+1:c*b+b) ) = DCTI_block(data, cosLUT);
        %I_restored( (r*b+1:r*b+b) , (c*b+1:c*b+b) ) = idct2(data);
        
    end
end

%imshow(I_restored)
imshowpair(uint8(I_gs),I_restored,'montage')

%imshow(DCT_I)

%%
I_gs = fi(imread('hw_test_img.bmp'), 0, 8, 0); %image is 160x120 resolution (120 rows 160 columns)
[M,N] = size(I_gs);
block_size = 8;
b = block_size;

load('DCT_GoldenReference.mat')

file = fopen('DCT_GoldenReference.txt','w');
fprintf(file, 'DCT Value, DCT Ram Address\n');

for r = 0:(M/block_size)-1
    for c = 0:(N/block_size)-1

        data = DCT_I( (r*b+1:r*b+b) , (c*b+1:c*b+b) );
        
        for m = 0:7
            for n = 0:7
                m_DCT = (r*8) + m;
                n_DCT = (c*8) + n;
                DCT_Ram_addr = (m_DCT*160) + n_DCT;
                
                fprintf(file, '%5.0f, %5.0f\n', data(m+1,n+1), DCT_Ram_addr);
            end
        end
        
    end
end

fclose(file);




