%% Takes a column header row from an excel spreadsheet and returns the
%% column index for the the FIRST INSTANCE of the string value we are looking for
% Search uses 'strcmpi' so is case insenstitive

function [colValue] = getColFromHead(header,srchString)
colValue = [];
for col = 1:length(header)
    if strcmpi(header{col},srchString) > 0
        colValue = col;
        return
    end
end 
end
