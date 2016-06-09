function [packetBits timed] = PHY_receiveBits(radio, detect, noBits, samplesPerSymbol, sampleRate, timeOut)
    
    [rx_frame_sync timedOut] = PHY_receiveFrame(radio, noBits*samplesPerSymbol + (8*samplesPerSymbol), detect, timeOut);
    
    timed = 0;
    
    if(timedOut == 1)
        timed = 1;
        packetBits = 0;
        return;
    end;
    
    start = 1;
    dataIndex = 1;
    dataBinFinal = zeros(length(rx_frame_sync),1);
    
    % Processing, demodulating
    parfor ind1=1:(length(rx_frame_sync)-samplesPerSymbol)
        timeDomainSamples = rx_frame_sync(ind1:ind1+samplesPerSymbol);
        
        N = length(timeDomainSamples);
        transform = fft(timeDomainSamples,N)/N;

        magTransform = abs(transform);
        magTransform = 20*log10(magTransform);

        faxis = linspace(-sampleRate/2,sampleRate/2,N);
        magOrig = fftshift(magTransform);

        % Only consider real frequency
        if (mod((length(magOrig)),2) ~= 0)
            magOrig(end+1) = min(magOrig);
        end;

        for ind2=1:(length(magOrig)/2)
            magOrig(ind2) = magOrig(ind2) + magOrig(end-ind2+1);
        end;

        %% Bin Conversion
        [binDataTemp indMax] = max(magOrig);
        %% Actual Symbol freq detection here.
        detectBin = max(magOrig(17),magOrig(18)) + 120;
        dataBinFinal(ind1) = detectBin;
        %dataIndex = dataIndex + 1;
    
        %start = start+1;
    end;
    dataBinFinal = dataBinFinal';
    % Processing done
    bitPatternWide = (dataBinFinal >= (max(dataBinFinal)-6));
    bitPatternDownSample = downsample(bitPatternWide,samplesPerSymbol);
    
    packetBits = bitPatternDownSample;