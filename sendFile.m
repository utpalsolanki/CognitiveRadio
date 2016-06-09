function sendFile(fileName, tx, rx, configs)
seqTest = 1;
Done = 0;
EoF = 'N';
while Done ~= 1
    
   % Receive data from file
   [bitData EoF] = loadFile( seqTest, fileName);
   
   fprintf('%s: sending\n',char(datetime('now')));
   
   MAC_sendPacket(tx, 'D', bitData, seqTest, EoF, configs.maxBits);
   [packetStructure isOK] = MAC_receivePacket(configs);
   
   if (isOK == 1)
       if (packetStructure.type == 'A' && packetStructure.seqNo == seqTest)
           fprintf('%s: ACKed\n',char(datetime('now')));
           seqTest = seqTest + 1;
           if (EoF == 'Y')
               Done = 1;
           end;
       end;
   end;
end;
fprintf('File transfer done.\n');