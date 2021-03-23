clc,clear;

file1 = fopen('image.coe','w');
file2= fopen('int_values.txt','w');
formatSpec0 = 'memory_initialization_radix=2;\n';
formatSpec1 = 'memory_initialization_vector=\n';
formatSpec2 = '%c';
formatSpec3 = ' ,\n';
I = imread('hw_test_img.bmp');

fprintf(file1,formatSpec0);
fprintf(file1,formatSpec1);

h=1;
for r = 1 : 120 
    for c = 1 : 160 
        temp = fi( I(r,c),0,8,0);
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



