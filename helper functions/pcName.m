function [machineName] = pcName
    [idum,machineName]= system('hostname');
end