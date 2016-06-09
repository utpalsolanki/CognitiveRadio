function [data EoF] = loadFile(lineNo,filename)
dataInd = 1;
EoF = 'N';
data = 0;

fid = fopen(filename);

tline = fgets(fid);
while ischar(tline)
    if (lineNo == dataInd)
        % Convert Character array to bit stream
        lineData = tline';
        lineDataAsci = uint8(lineData);
        
        binString = dec2bin(lineDataAsci(1),8);
        m = str2num(binString(:))';
        m = m';
        data = m;
        
        for ind2=2:length(lineDataAsci)
            binString = dec2bin(lineDataAsci(ind2),8);
            m = str2num(binString(:))';
            m = m';
            data = [data; m;];
        end;
        
    end;
    dataInd = dataInd + 1;
    tline = fgets(fid);
end

if dataInd <=(lineNo + 1)
    EoF = 'Y';
end;
fclose(fid);