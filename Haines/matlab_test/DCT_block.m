%calculate all DCT coeficients for the square matrix passed in
%matrix returned will have the same dimension as the input matrix
function dct_data = DCT_block(data, cosLUT)

[M,N] = size(data);
dct_data = fi(zeros([M,N]), 1, 32, 16);
%dct_data = zeros([M,N]);

%iterate over all elements of the output matrix
for k = 0:M-1
    for el = 0:N-1

        %iterate over all elements of the input matrix
        for m = 0:M-1
            for n = 0:N-1
                %disp(m)
                %disp(n)
                
%                 cos1 = cos( (pi/8)*k *(m+0.5) );
%                 cos2 = cos( (pi/8)*el *(n+0.5) );
                
                cos_vals = cosLUT(k+1,m+1) * cosLUT(el+1,n+1);

                dct_data(k+1,el+1) = dct_data(k+1,el+1) + (data(m+1,n+1) * cos_vals);
            end
        end
 
    end
end

dct_data = floor(double( (fi(4,1,32,16) * dct_data) ) );

%dct_data = fi(dct_data, 1, 18, 2);
%dct_data = fi(4,1,18,2) * dct_data;





end