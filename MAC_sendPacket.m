function MAC_sendPacket(radio, txType, txData, txSeqNo, txEop, maxCapacity)

%% Packet Header Structure
% First 12 bits for length in Byte
% 4 bits for packet type DATA, DATA_ACK, CTRL, CTRL_ACL 
% 8 bits sequence number
% 8 Bits = First bit for EOP, 7 bits reserved
% 32 bits data CRC
% 8 CRC for Packet
packetHeaderSize = 12 + 4 + 8 + 8 + 32 + 8;

%%
packetHeaderBits = zeros(packetHeaderSize, 1);

%%
if txType == 'A' || txType == 'a'
    if(txType == 'A')
        packetHeaderBits(14) = 1;
    else
        packetHeaderBits(16) = 1;
    end;
    
    tempString = dec2bin(uint16(txSeqNo),10);
    tempString = str2num(tempString(:))';
    tempString = tempString';
    tempString = tempString(end-8+1:end);
    tempString = [zeros(8-length(tempString),1);tempString;];
    packetHeaderBits(17:24) = tempString;
    
    if(txEop == 'Y')
        packetHeaderBits(25) = 1;
    else
        packetHeaderBits(25) = 0;
    end;
    
    packetHeaderBits = packetHeaderBits(1:end -8);  
    
    %% Add header CRC
    crcPoly = 'z^8 + z^7 + z^6 + z^4 + z^2 + 1';
    hCRCAddHeader = comm.CRCGenerator('Polynomial', crcPoly);
    
    packetHeaderBits = step(hCRCAddHeader,packetHeaderBits);
    
    packetBits = [packetHeaderBits;];
end;

%%
if txType == 'D' || txType == 'C'
    if mod(length(txData),8) ~= 0
        fprintf('Data bits must be in byte\n');
        return;
    end;
    
    tempString = dec2bin(uint16(length(txData)/8),10);
    tempString = str2num(tempString(:))';
    tempString = tempString';
    tempString = [zeros(12-length(tempString),1);tempString;];
    packetHeaderBits(1:12) = tempString;
    
    if(txType == 'D')
        packetHeaderBits(13) = 1;
    else
        packetHeaderBits(15) = 1;
    end;
    
    tempString = dec2bin(uint16(txSeqNo),10);
    tempString = str2num(tempString(:))';
    tempString = tempString';
    tempString = tempString(end-8+1:end);
    tempString = [zeros(8-length(tempString),1);tempString;];
    packetHeaderBits(17:24) = tempString;
    
    if(txEop == 'Y')
        packetHeaderBits(25) = 1;
    else
        packetHeaderBits(25) = 0;
    end;
    
    %% Add data CRC in header
    crcPoly = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
    hCRCAddPacket = comm.CRCGenerator('Polynomial', crcPoly);
    
    txData = step(hCRCAddPacket, txData);
    packetHeaderBits(33:64) = txData(end-32+1:end);
    txData = txData(1:end-32);
    
    packetHeaderBits = packetHeaderBits(1:end -8);
    
    %% Add header CRC
    crcPoly = 'z^8 + z^7 + z^6 + z^4 + z^2 + 1';
    hCRCAddHeader = comm.CRCGenerator('Polynomial', crcPoly);
    
    packetHeaderBits = step(hCRCAddHeader,packetHeaderBits);
    
    packetBits = [packetHeaderBits; txData;];
end;

if (length(packetBits) > 0)
    preambleBits = [1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;];
    packetFinalBits = [preambleBits; packetBits;];
end;

if (length(packetFinalBits) > 0)
    packetFinalBits = [packetFinalBits; zeros(maxCapacity - length(packetFinalBits),1);];
    PHY_sendBits(radio, packetFinalBits);
end;