function freq_comp = my_dct(block, lut)
%my_dct  Performs discrete cosing transform

temp = 0;

    for k = 1: 8
        for l = 1:8
            for r = 1:8
                for c = 1 :8
                    temp = temp + 4 * block(r,c)*lut(r,k)*lut(c,l);
                end
                freq_comp(k,l) = temp;
            end
        end
    end
end

