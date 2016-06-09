function [returnStruct isPacketOK] = MAC_validatePacket(packetBits)
returnStruct.length = 0;
packetBits = packetBits';
%% Packet Header Structure
% First 12 bits for length in Byte
% 4 bits for packet type DATA, DATA_ACK, CTRL, CTRL_ACL 
% 8 bits sequence number
% 8 Bits = First bit for EOP, 7 bits reserved
% 32 bits data CRC
% 8 CRC for Packet
packetHeaderSize = 12 + 4 + 8 + 8 + 32 + 8;
%% Validate Packet header CRC
crcPoly = 'z^8 + z^7 + z^6 + z^4 + z^2 + 1';
hCRCRemHeader = comm.CRCDetector('Polynomial', crcPoly);

if (length(packetBits) < packetHeaderSize)
    returnStruct = 0;
    isPacketOK = 0;
    return;
end;
tempPacketHeader = packetBits(1:packetHeaderSize);

[tempPacketHeaderValidated isHeaderOK] = step(hCRCRemHeader, tempPacketHeader);

if isHeaderOK ~= 0
    returnStruct = 0;
    isPacketOK = 0;
    return;
end;

returnStruct.length = (packetBits(1)*2048 + ...
                      packetBits(2)*1024 + ...
                      packetBits(3)*512  + ...
                      packetBits(4)*256  + ...
                      packetBits(5)*128  + ...
                      packetBits(6)*64   + ...
                      packetBits(7)*32   + ...
                      packetBits(8)*16   + ...
                      packetBits(9)*8    + ...
                      packetBits(10)*4   + ...
                      packetBits(11)*2   + ...
                      packetBits(12));

if (returnStruct.length < 0)
    returnStruct = 0;
    isPacketOK = 0;
    return;
end;

% Packet type 
if (packetBits(13) == 1)
    returnStruct.type = 'D';
elseif (packetBits(14) == 1)
    returnStruct.type = 'A';
elseif (packetBits(15) == 1)
    returnStruct.type = 'C';
elseif (packetBits(16) == 1)
    returnStruct.type = 'a';
else
    returnStruct = 0;
    isPacketOK = 0;
    return;
end;

% Packet seq number
returnStruct.seqNo = ( packetBits(17)*128  + ...
                      packetBits(18)*64   + ...
                      packetBits(19)*32   + ...
                      packetBits(20)*16   + ...
                      packetBits(21)*8    + ...
                      packetBits(22)*4   + ...
                      packetBits(23)*2   + ...
                      packetBits(24));

% End Of Packet Validation                  
if (packetBits(25) == 1)
    returnStruct.eop = 'Y';
else
    returnStruct.eop = 'N';
end;

% Validate data in packet with 32 CRC

if ((returnStruct.type == 'D' || returnStruct.type == 'C') && returnStruct.length > 0)
    
    dataBitsInPacket = packetBits(packetHeaderSize + 1:end);
    if (length(dataBitsInPacket) < returnStruct.length*8)
        returnStruct = 0;
        isPacketOK = 0;
        return;
    end;

    dataBitsInPacket = dataBitsInPacket(1:returnStruct.length*8);
    
    crcPoly = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
    hCRCRemPacket = comm.CRCDetector('Polynomial', crcPoly);
    
    dataBitsInPacket = [dataBitsInPacket; packetBits(33:64);];
    
    [dataBitsInPacket isPacketCrcOK] = step(hCRCRemPacket,dataBitsInPacket);
    
    if isPacketCrcOK == 0
        returnStruct.data = dataBitsInPacket;
        isPacketOK = 1;
        return;
    else
        returnStruct = 0;
        isPacketOK = 0;
        return;
    end;
elseif (returnStruct.type == 'A' || returnStruct.type == 'a')    
    isPacketOK = 1;
    return;
else
    returnStruct = 0;
    isPacketOK = 0;
    return;
end;

isPacketOK = 1;
return;
