function PHY_sendBits(radio, txBits)


t = [0:(pi/2):2*pi*5];
a = sin(t);
a = a';
z = zeros(length(a),1);

waveToSend = 0;

for ind1=1:length(txBits)
    if txBits(ind1) == 1
        waveToSend = [waveToSend; a;];
    else
        waveToSend = [waveToSend; z;];
    end;
end;

waveToSend = [waveToSend; z; z; a; a; z; z; a; z;];

% Actual send on radio
step(radio, waveToSend);
step(radio, waveToSend);

% Wait for transmission
pause(min(length(waveToSend),100000)/200000);
pause(min(length(waveToSend),100000)/200000);

% Safe time
pause(0.200);

return;