clear;
configsSet;

if (thisRadio == 'C')
    fprintf('This system is now running as client.\nIt will receive file from server.\n');
    client;
elseif (thisRadio == 'S')
    fprintf('This system is now running as server.\nIt will send file/s to client.\n');
    server;
else
    fprintf('Did not understand what to do with this code\n');
end;