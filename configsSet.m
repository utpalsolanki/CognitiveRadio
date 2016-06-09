
%% Power threshold
detect.threshold = 1000;
detect.min = detect.threshold;
detect.max = detect.threshold;
%% CHANGE PARAMETERS AS NEEDED
% Radio Setings
% USRP Configuration stuff
thisRadio = 'C'; % use 'S' to configure it as Server, use 'C' to configure as client
r.Platform = 'N200/N210/USRP2';
r.IPaddress = '192.168.25.2';
rfFreq = 2.52e9;                % RF transmit center frequency (set identically between Tx and Rx USRPs)

%% Do not change any parameters below
MasterClockRate = 100e6;        %Hz
Fs = 200e3;                     % NEEDS TO MATCH THE CFO SAMPLING FREQUENCY IN initObjects.m

frameRxLength = 100000;

Tx.USRPTxCenterFrequency   = rfFreq;                        % Hz
Tx.USRPGain                = 0;                             % dB
Tx.USRPInterpolationFactor = MasterClockRate/Fs;

tx = comm.SDRuTransmitter( ...
    'Platform',             r.Platform, ...
    'IPAddress',            r.IPaddress, ...
    'CenterFrequency',      Tx.USRPTxCenterFrequency, ...
    'Gain',                 Tx.USRPGain,...
    'InterpolationFactor',  Tx.USRPInterpolationFactor, ...
    'UnderrunOutputPort',    1);
%tx.LocalOscillatorOffset = 1e6;
rx = comm.SDRuReceiver('Platform','N200/N210/USRP2',...
                       'CenterFrequency', rfFreq,...
                       'IPAddress', r.IPaddress,...
                       'Gain', 10,...
                       'FrameLength', frameRxLength,...
                       'DecimationFactor', 500,...
                       'OutputDataType', 'double');

rx.FrameLength = 100000;
spacing = 21;
sampleRate = 200000;

radioConfigs.radio = rx;
radioConfigs.detect = detect;
radioConfigs.spacing = spacing;
radioConfigs.sampleRate = sampleRate;
radioConfigs.maxBits = 1600;
radioConfigs.timeOut = 4;
radioConfigs.handShakeFreq = 2.6e9;
radioConfigs.txPower = 25; % We start with 25 dB, decrease it as needed from DSA sensing.

% Discard first few frames
len = 0;
while len == 0
    [rx_data len] = step(rx);
end;
len = 0;
while len == 0
    [rx_data len] = step(rx);
end;

% Let init Tx object by sending a frame with all zeros
sampleZero = zeros(length(spacing*radioConfigs.maxBits),1);
% We have to step twice to send frame to USRP
%step(tx,sampleZero);
%step(tx,sampleZero);