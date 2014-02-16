function elements = parseFilename ( filename, re, varnames, sep )
    % filename: it will be stripped from path and extension
    % re: is the regular expression that will sparate the name. It will be
    %     used with the textscan function
    % varnames: the names of the variables for each element. Its an array of
    %           strings.
    % sep: is the separator for the textscan call.

    [p,n,e] = fileparts(filename);

    foundElems = textscan(n, re, 'Delimiter', sep);

    if (size(varnames, 2) ~= size(foundElems, 2) )
        error ( 'Error in parsing step' )
    end

    for ( i = 1:size(varnames, 2) )
        elements.(varnames{i}) = foundElems{i};
    end
end
