function flushUSRPRxBuffer(radio, debug)
len = 1;
while (len > 0 )
    [ddata, len ] = step(radio);
    if debug
        %fprintf('%d\n', len);
    end
end
%fprintf('Receive Buffer Flushed!\n');