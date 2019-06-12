function [ result,Labels, LabeledLines] = MS_PostProcessByMRF(L,num,LabeledLines, numLines, LabelCost, charRange, options )
    CCsparseNs = computeNsSystem( L,num, options );
    Dc  = computeLinesDC(LabeledLines,numLines,L,num, charRange(2));
    [Labels] = LineExtraction_GC_MRFminimization(numLines, num, CCsparseNs,Dc, LabelCost);
    Labels(Labels == numLines+1) = 0;
    residualLines = ismember(LabeledLines, Labels);
    LabeledLines(~residualLines)=0;
    result = drawLabels(L,Labels);
    RefinedCCs = RefineBinaryOverlappingComponents(L,num, LabeledLines, numLines );
    tempMask = RefinedCCs > 0;
    result(tempMask) = RefinedCCs(tempMask);
end

%TODO: merge these functions into one function.
function result = drawLabels(L,Labels)
    L = uint16(L);
    LUT = zeros(1,65536,'uint16');
    LUT(2:length(Labels)+1) = Labels;
    result = double(intlut(L, LUT));
end