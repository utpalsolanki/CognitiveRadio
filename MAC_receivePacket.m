function [packetStructure isPacketOK] = MAC_receivePacket(radioConfigs)
isPacketOK = 0;
packetStructure = 0;

% preamble secret
preambleMatch = [1;0;1;0;1;0;1;0;1;0;1;0;1;0;1;0;];

% receive packet
[receivedBits timedOut] = PHY_receiveBits(radioConfigs.radio, radioConfigs.detect, length(preambleMatch)+radioConfigs.maxBits, radioConfigs.spacing ,radioConfigs.sampleRate, radioConfigs.timeOut);

if(timedOut == 1)
    isPacketOK = 0;
    fprintf('receive timedout.\n');
    return;
end;

err1 = comm.ErrorRate;
release(err1);
dataToCompare = receivedBits(1:length(preambleMatch));
dataToCompare = dataToCompare';
errState1 = step(err1,preambleMatch,double(dataToCompare));

if (errState1(1) == 0)
    % Preamble is perfect. Lets check Packet header parameters and CRC
    packetBits = receivedBits(length(preambleMatch)+1:end);
    
    [tempStruc isPacketOK1] = MAC_validatePacket(packetBits);
    isPacketOK = isPacketOK1;
    packetStructure = tempStruc;
    return;
    
else
    isPacketOK = 0;
    packetStructure = 0;
end;
return;