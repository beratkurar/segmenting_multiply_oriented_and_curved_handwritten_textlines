function [charsRange] = estimateCharsHeight(I,bin,options)
% Estimating line heights.

% Binary Image.
if (islogical(I))
    fprintf('image is logical')
    % Assuming ICDAR's file format
    [lower,upper] = estimateBinaryHeight(bin,options.thsLow,options.thsHigh,options.Margins);    
    
    %Gray Scale or Color image.
else 
    fprintf('image is not logical \n');
    if (options.EMEstimation)
        if (options.EMEstimation)
            EvolutionMapDirectory = 'EvolutionMap';
            EMResult = ['EvolutionMap\estimateCharacterDimensions.exe',' ','"',options.srcPath,...
                '/',options.fileName,'"'];
            [~,cmdout] = system(EMResult);
            res = sscanf(cmdout,'(%f,%f)\n(%f,%f)');
        end
    end
    
    % Evolution map is turned off or failed to execute.
    if (~options.EMEstimation || isempty(res) || res(3) == 0)
        fprintf('EME did not work \n')
        [lower,upper] = estimateBinaryHeight(bin,options.thsLow,options.thsHigh,options.Margins);
    else
        % Success.
        fprintf('EM has been used \n')
        lower = res(3)/2;
        upper = res(4)/2;
    end
end

charsRange = [lower,upper];
end
