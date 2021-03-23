clear all
close all
clc

%% Variable Space Init
img = double(imread('hw_test_img.bmp'));
[m, n] = size(img);
result = zeros(m,n);
ref_result = zeros(m,n);

%% Signals
res = zeros(8);
res1 = zeros(8);
res2 = zeros(8);

%% LUT
table1 = zeros(8);
for i = 1:8
    for j = 1:8
        table1(i,j) = sqrt(1/8) * cos((pi*(2*(j-1)+1).*(i-1))/(2*8));
    end
end
table2 = zeros(8);
for i = 1:8
    for j = 1:8
        table2(i,j) = 0.5 * cos((pi*(2*(j-1)+1).*(i-1))/(2*8));
    end
end

%% Blocking Image
% Since 2D DCT can be seen as a combination of two 1D DCT operated both on the horizontal and
% the vertical direction, the code following below is just computing 1D DCT twice 
for i = 1:8:m
    for j = 1:8:n
        %% Stage P1 - Row-wise DCT
        res = img(i:i+7,j:j+7);
        res1 = zeros(8);
        for p = 1:8
            for q = 1:8
                if q==1
                    for k = 1:8
                        res1(p,q) = res1(p,q) + res(p,k) * table1(q,k);
                    end
                else
                    for k = 1:8
                        res1(p,q) = res1(p,q) + res(p,k) * table2(q,k);
                    end
                end

            end
        end
        %% Stage P2 - Column-wise DCT
        res2 = zeros(8);
        for p = 1:8
            for q = 1:8
               if q==1
                    for k = 1:8
                        res2(q,p) = res2(q,p) + res1(k,p) * table1(q,k);
                    end
               else
                    for k = 1:8
                        res2(q,p) = res2(q,p) + res1(k,p) * table2(q,k);
                    end
               end
            end
        end
        
        res_ref = dct2(res); %For Comparison
        ref_result(i:i+7,j:j+7) = res_ref; %For Comparison
        
        %% Stage P3 - Saving Data to Memory Storage
        result(i:i+7,j:j+7) = res2;
        
    end
end


%% Evaluation and Plotting
idct_image = zeros(m,n);
idct_ref = zeros(m,n);
for i = 1:8:m
    for j = 1:8:n
       idct_image(i:i+7,j:j+7) = idct2(result(i:i+7,j:j+7));
       idct_ref(i:i+7,j:j+7) = idct2(ref_result(i:i+7,j:j+7));
    end
end

diff_coeff = sum(sum(result - ref_result))
diff_img = sum(sum(idct_image - idct_ref))
subplot(2,2,1);
imagesc(result);
title('DCT coeffs');
subplot(2,2,2);
imagesc(ref_result);
title('Reference DCT coeffs');
subplot(2,2,3);
imagesc(idct_image);
colormap(gray);
title('IDCT from DCT coeffs');
subplot(2,2,4);
imagesc(idct_ref);
colormap(gray);
title('IDCT from Reference DCT coeffs');

