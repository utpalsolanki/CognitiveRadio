fileID = fopen('recv1.txt','a');
expectedSeqNo = 1;

%fclose(fileID);

while 1
   [packetStructure isPacketOK] = MAC_receivePacket(radioConfigs);
  
   if (isPacketOK == 1)
       packetStructure
       if (packetStructure.type == 'D')
           MAC_sendPacket(tx, 'A', 0, packetStructure.seqNo, packetStructure.eop, radioConfigs.maxBits);
           % String Convert
           if expectedSeqNo ~= packetStructure.seqNo
               continue;
           end;
           
           storeCharCounter = 1;
           for ind3=1:8:length(packetStructure.data)
               tempChar = packetStructure.data(ind3:ind3+8-1);
               tempChar = tempChar';
               tempChar = bi2de(tempChar,2,'left-msb');
               
               tempChar = char(tempChar);
               storeLine(:,storeCharCounter) = tempChar;
               storeCharCounter = storeCharCounter + 1;               
           end
           storeLine = storeLine(1:storeCharCounter-1);
           fprintf(fileID,'%s',storeLine);
           fprintf('%s\n',storeLine);
           expectedSeqNo = expectedSeqNo + 1;
           if packetStructure.eop == 'Y'
              expectedSeqNo = 1;
              fprintf('File finished.\n');
           end;
       end;    
   end;
end;