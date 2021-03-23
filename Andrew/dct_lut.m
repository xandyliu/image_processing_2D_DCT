clear,clc;

M = 8;
m = 0:7;
n = 0:7;
k = 0:7;
h = 1;
x = 1;
y = 1;
lut_values = 0:63;

%This block initilizes the lut values for the cosine function within the DCT
for i = 1:8
    for j = 1:8        
        lut_values(h) = cos((pi/M)*k(i)*(m(j)+1/2));
        h = h + 1;        
    end
end 

lut_values_fixed_p = fi(lut_values, 1, 9, 8);

bin(lut_values_fixed_p);

I = imread("hw_test_img.bmp");

block = zeros([8,8]);
block = uint8(block);
freq_comp_block =zeros([8,8]);

x_slides = 120/8;
y_slides = 160/8;


h=1;
for r = 0 : x_slides-1 
    for c = 0 : y_slides -1
    block = I((r*8+1:r*8+8), (c*8+1:c*8+8));
    %subplot(x_slides,y_slides,h);
    %imshow(block);
    freq_comp = my_dct(block,lut_values);
    subplot(x_slides,y_slides,h);
    imshow(freq_comp);
    h = h+1;
    end
end   







fprintf('Image has been tiled \n')

       
        



