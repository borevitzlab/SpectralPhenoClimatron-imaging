function [dataDrive] = getDataDrive
    switch deblank(pcName) %Debalnk strips spaces
        case 'Phenocam'
            dataDrive = 'Y:\';
        case 'TimUltrabook'
            dataDrive = 'C:\';
    end
end