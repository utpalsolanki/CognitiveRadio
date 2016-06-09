function  [rx_frame_return timedOut] = PHY_receiveFrame(radio, expectedFrameLength, detect, timeOut)
% expectedFrameLength in terms of sample
flushUSRPRxBuffer(radio,0);    
timedOut = 0;
tic;
% Receive one frame
len = 0;
while len == 0
    [rx_data, len] = step(radio);
end;

% Keep searching for frame
while 1
    if (toc > timeOut)
        timedOut = 1;
        rx_frame_return = 0;
        return;
    end;
    rx_last = rx_data;
    [rx_data len] = step(radio);
    
    if len > 0
        plot(real(rx_data));
        drawnow;

        %Fpower = fft(rx_data);
        %pow = Fpower.*conj(Fpower);
        %total_pow = sum(pow);

        %detect.min = min(detect.min, total_pow);
        %detect.threshold = max(detect.min*2,(detect.min + detect.max)/100);
        answer = detectSignal(rx_data);
        if answer == 1
        
            %detect.max = max(detect.max, total_pow);
        
            start = 1;
            dataIndex = 1;
            
            rx_container = [rx_last; rx_data;];
            % Receive until expected frame length is arrived
            while length(rx_container) < (expectedFrameLength + (radio.FrameLength*2))
                len = 0;
                while len == 0
                    [rx_data, len] = step(radio);
                end;
                rx_container = [rx_container; rx_data;];
            end;
             
            % Sync to start of frame
            rx_container_abs = abs(rx_container);
            rx_max  = max(rx_container_abs);
            rx_mean = mean(rx_container_abs);

            rx_p = rx_max/3; % double it

            rx_find_start_ind = find(rx_container_abs > rx_p);
            
            if(length(rx_find_start_ind) <= 1)
                continue;
            end;

            rx_frame_sync = rx_container(rx_find_start_ind(1):end);
            
            if length(rx_frame_sync) < expectedFrameLength
                fprintf('frame sync went wrong\n');
            else
                rx_frame_sync = rx_frame_sync(1:expectedFrameLength);
                rx_frame_return = rx_frame_sync;
                break;
            end;
        end;
    end;
end;

