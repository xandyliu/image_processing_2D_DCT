clc,clear;

file1 = fopen('image_4bit.coe','w');
file2= fopen('int_values_4bit.txt','w');
formatSpec0 = 'memory_initialization_radix=2;\n';
formatSpec1 = 'memory_initialization_vector=\n';
formatSpec2 = '%c';
formatSpec3 = ' ,\n';
I = imread('hw_test_img.bmp');
figure(1);
title('8 bit image');
image(I);
colormap(gray(256));
% imshow(I);


I4 = I./16;

figure(2);
title('4 bit image');
image(I4);
colormap(gray(16));

fprintf(file1,formatSpec0);
fprintf(file1,formatSpec1);

h=1;
for r = 1 : 120 
    for c = 1 : 160 
        temp = fi( I4(r,c),0,4,0);
        temp_bin = bin(temp);
        
        fprintf(file1,formatSpec2,temp_bin);
        fprintf(file2,'%d\n',temp);
        if( c*r == 19200)
            fprintf(file1,' ;');
        else
            fprintf(file1,formatSpec3);
        end
    end
end
fclose(file1);
fclose(file2);

