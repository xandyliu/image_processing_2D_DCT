%% test 1
clear all;

height = 120;
width = 160;
% Initialization
%img_RGB = imread('PepperRGB.png');
%img_grey_120x160 = img_preprocess(img_RGB, height, width);
img_grey_120x160 = imread('hw_test_img.bmp');

% create a cos LUT
cosLUT = fi(zeros(8,8),1,9,8); % signed fixed-point binary point scaling
for m = 1 : 8
    for k = 1 : 8
        cosval = cos( (pi/(2*8)) * (2*(m-1) + 1) * (k-1) );
        cosLUT(m,k) = fi(cosval, 1, 9, 8);
    end
end

% Computation: DCT2D and IDCT2D
DCT_120x160_double = zeros(height,width);
recoveredImg_120x160 = uint8(zeros(height,width));

for x = 1:height/8
    for y = 1:width/8
        % img_8x8: img block to be DCT2D
        img_8x8 = img_grey_120x160(8*x-7:8*x,8*y-7:8*y);
        % DCT_8x8_cosLUT: 8x8 DCT kernel
        DCT_8x8 = myfunc_DCT2_8x8kernel_cosLUT(img_8x8, cosLUT);
        % store into DCT_240x320_double
        DCT_8x8_double = double(DCT_8x8);
        DCT_120x160_double(8*x-7:8*x,8*y-7:8*y) = DCT_8x8_double;
        % recover img block with inverse DCT2D
        recoveredImg_8x8 = uint8(DCTI_block(DCT_8x8_double));
        % store into recoveredImg_240x320
        recoveredImg_120x160(8*x-7:8*x,8*y-7:8*y) = recoveredImg_8x8;
    end
    fprintf("block row %d is finished \n", x);
end
%% show imgs
% test: only keep integer part of DCT_240x320
%DCT_240x320_int = int_16(DCT_240x320_double);
figure(1)
subplot(2,2,1),
    imshow(img_grey_120x160)
    title('Original image');
subplot(2,2,2),
    imshow(recoveredImg_120x160)
    title('Recovered image');
subplot(2,2,3),
    imshow(log(abs(DCT_120x160_double)),[])
    colormap(gca,jet(64))
    colorbar
    title('DCT(block processing)');
%% print cosLUT to txt file filecosLUT.txt in VHDL syntax
filecosLUT = fopen('filecosLUT.txt','w');
fprintf(filecosLUT, 'type vector8x9bit is array (0 to 7) of signed(8 downto 0);\n');
fprintf(filecosLUT, 'type array8x8x9bit is array (0 to 7) of vector8x9bit;\n');
fprintf(filecosLUT, 'constant cosLUT : array8x8x9bit := (\n');
for m = 1 : 8
    fprintf(filecosLUT, '\t(');
    for k = 1 : 8
        fprintf(filecosLUT,'"%s"',bin(cosLUT(m, k)));
        if k < 8
            fprintf(filecosLUT,', ');
        end
    end
    fprintf(filecosLUT, '\t)');
    if m < 8
        fprintf(filecosLUT,',\n');
    end
end
fprintf(filecosLUT, '\n);\n');
fclose(filecosLUT);
%% print DCT table to DCToutput.txt
fileDCToutput = fopen('DCToutput.txt','w');
for x = 1:height/8
    for y = 1:width/8
        % print one 8x8 kernel
        DCT_8x8_double = DCT_120x160_double(8*x-7:8*x,8*y-7:8*y);
        for i = 1:8
            for j = 1:8
                fprintf(fileDCToutput, "%f, ", DCT_8x8_double(i,j));
            end
        end
        fprintf(fileDCToutput, "\n");
    end
end
fclose(fileDCToutput);
%% golden_ref: DCT + IDCT
%DCT_8x8 = dct2(img_grey_8x8);
%imgRecovered = uint8(idct2(DCT_8x8));
%% DCT2D with cos LUT
function DCT_8x8 = myfunc_DCT2_8x8kernel_cosLUT(img_8x8, cosLUT)
    % compute 8x8 DCT kernel, same size as the img kernel
    DCT_8x8 = fi(zeros(8,8),1,32,14);
    for k = 1 : 8
        for l = 1 : 8
            sum = fi(0,1,32,16);
            for m = 1 : 8
                for n = 1 : 8
                    % comp: 8+9+9 = 26 bit word length, 16 bit fractional length
                    comp = img_8x8(m,n) * cosLUT(m,k) * cosLUT(n,l); 
                    % comp is summed up 64 times. sum: 26+6 = 32 bit word length, 16 bit fractional length
                    sum = sum + comp; 
                end
            end
            DCT_8x8(k,l) = fi(4*sum,1,32,14); % binary point right shift 2 bits
        end
    end
end
%% From Haines's code. inverse DCT2D
%calculate all DCT coeficients for the square matrix passed in
%matrix returned will have the same dimension as the input matrix
function dct_data = DCTI_block(data)

[M,N] = size(data);
dct_data = zeros([M,N]);

%iterate over all elements of the output matrix
for m = 0:M-1
    for n = 0:N-1

        %iterate over all elements of the input matrix
        for k = 0:M-1
            for el = 0:N-1
                %disp(m)
                %disp(n)
                cos1 = cos( (pi/M)*k *(m+0.5) );
                cos2 = cos( (pi/N)*el*(n+0.5) );
                val = data(k+1,el+1) * cos1 * cos2;
                
                %scaling of dct_data
                if (k == 0)
                    val = 0.5 * val;
                end 

                if (el == 0)
                    val = 0.5 * val;
                end 
                
                
                dct_data(m+1,n+1) = dct_data(m+1,n+1) + val;
                
            end
        end
        
    end
end

dct_data = (1/(M*N)) * dct_data;


end