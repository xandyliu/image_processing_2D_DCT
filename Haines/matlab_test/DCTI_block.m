%calculate all DCT coeficients for the square matrix passed in
%matrix returned will have the same dimension as the input matrix
function dct_data = DCTI_block(data, cosLUT)

[M,N] = size(data);
dct_data = fi(zeros([M,N]), 1, 32, 16);
one_half = fi(0.5,1,32,16);

%iterate over all elements of the output matrix
for m = 0:M-1
    for n = 0:N-1

        %iterate over all elements of the input matrix
        for k = 0:M-1
            for el = 0:N-1
                %disp(m)
                %disp(n)
                cos1 = cosLUT(k+1,m+1);
                cos2 = cosLUT(el+1,n+1);
                val = data(k+1,el+1) * cos1 * cos2;
                
                %scaling of dct_data
                if (k == 0)
                    val = one_half * val;
                end 

                if (el == 0)
                    val = one_half * val;
                end 
                
                
                dct_data(m+1,n+1) = dct_data(m+1,n+1) + val;
                
            end
        end
        
    end
end

dct_data = (1/(M*N)) * dct_data;
dct_data = uint8(dct_data);


end