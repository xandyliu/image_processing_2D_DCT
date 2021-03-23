im_block = ...
     [162  160  163  160  158  158  157  155 ...
      160  159  160  159  155  156  155  153 ...
      157  156  157  157  156  156  156  154 ...
      157  156  156  156  157  157  156  154 ...
      156  156  156  157  158  158  156  155 ...
      155  154  158  158  158  158  156  155 ...
      156  157  158  160  158  159  158  158 ...
      158  158  158  160  160  160  161  164];
  
im_block_fi =  fi(im_block, 0, 8, 0);

% create a cos LUT
cosLUT = fi(zeros(8,8),1,9,8); % signed fixed-point binary point scaling
for k = 0 : 7
    for m = 0 : 7
        cosval = cos( (pi/8)*k*(m+0.5) );
        cosLUT(k+1,m+1) = fi(cosval, 1, 9, 8);
        %fprintf('actual %12.9f, fixed point: %12.9f\n', cosval,double(cosLUT(k+1,m+1)));
    end
end

dct_val = fi(0, 1, 32, 16);
k = 0;
el = 0;

k_2 = 0;
el_2 = 1;

 for m = 0:7
    for n = 0:7
        if ((m == 0) && (n==0))
            cos_vals = cosLUT(k+1,m+1) * cosLUT(el+1,n+1);
            val_to_add = fi(162, 0, 8, 0) * cos_vals;
            dct_val = dct_val + val_to_add;
        elseif ((m == 7) && (n==7))
            cos_vals = cosLUT(k_2+1,m+1) * cosLUT(el_2+1,n+1);
            val_to_add = fi(164, 0, 8, 0) * cos_vals;
            %disp(val_to_add)
            dct_val = dct_val + val_to_add;
        else
            cos_vals = cosLUT(k+1,m+1) * cosLUT(el+1,n+1);
            val_to_add = im_block_fi((m*8 + n)+1) * cos_vals;
            dct_val = dct_val + val_to_add;
        end
        
%         cos_vals = cosLUT(k+1,m+1) * cosLUT(el+1,n+1);
%         val_to_add = im_block_fi((m*8 + n)+1) * cos_vals;
%         dct_val = dct_val + val_to_add;
        
    end
 end
 
 %temp = 39985 - cos(pi/8)*1*(
 %correct value 9996
 dct_val = floor(double( dct_val ) );
 error = dct_val - 9996
 %dct_val = floor(double( (fi(4,1,32,16) * dct_val) ) );
 disp(dct_val)
 
 