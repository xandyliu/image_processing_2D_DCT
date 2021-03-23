
clc,clear;

file1 = fopen('blocked_image.coe','w');
file2= fopen('blocked_int_values.txt','w');
formatSpec0 = 'memory_initialization_radix=2;\n';
formatSpec1 = 'memory_initialization_vector=\n';
formatSpec2 = '%c';
formatSpec3 = ' ,\n';
I = imread('hw_test_img.bmp');

x_slides = 120/8;
y_slides = 160/8;
block = cell(x_slides * y_slides);

fprintf(file1,formatSpec0);
fprintf(file1,formatSpec1);

h=1;
for r = 0 : x_slides-1 
    for c = 0 : y_slides -1
        temp = I((r*8+1:r*8+8), (c*8+1:c*8+8));
    
        for i = 1:8
            temp_vec = temp(i,:)';
            temp_vec_fp = fi(temp_vec,0,8,0);
            temp_vec_bin = bin(temp_vec_fp);
            
            fprintf(file2,'%f\n',temp_vec);
            for j = 1:8
                for k = 1:8
                    fprintf(file1,formatSpec2,temp_vec_bin(j,k));                    
                    if( k == 8)
                        if(h == 19200)
                            fprintf(file1, ' ;');
                        else
                        fprintf(file1,formatSpec3);
                        h = h+1;
                        end
                    end        
                end
            end
        end
    end
end
fclose(file1);
fclose(file2);



