function [ result,Labels,newLines ] = PostProcessByMRF(L,num,linesMask,charRange,options)

   CCsparseNs = computeNsSystem( L,num,options);

    [ result,Labels,newLines ] = PostProcessByMRFHelper(L,num,linesMask,CCsparseNs,charRange);

    if (options.mergeLines)
        [ joinedMask, joinedFlag] = JoinSegments(newLines);
        if (joinedFlag)
            [ result,Labels,newLines ] = PostProcessByMRFHelper(L,num,joinedMask,CCsparseNs,charRange);
        end
    end

end


function [ result,Labels,Lines ] = PostProcessByMRFHelper(L,num,linesMask,CCsparseNs,charRange)
    [Lines, numLines] = permuteLabels(bwlabel(linesMask));
    Dc  = computeLinesDC(Lines,numLines,L,num, charRange(2));
    [ LabelCost ] = computeLinesLabelCost( L,Lines,numLines );
    [Labels] = LineExtraction_GC_MRFminimization(numLines, num, CCsparseNs,Dc, LabelCost);
    Labels(Labels == numLines+1) = 0;
    residualLines = ismember(Lines, Labels);
    Lines(~residualLines)=0;
    result = drawLabels(L,Labels);
    RefinedCCs = RefineBinaryOverlappingComponents(L,num, Lines,numLines );
    tempMask = RefinedCCs > 0;
    result(tempMask) = RefinedCCs(tempMask);

end

function result = drawLabels(L,Labels)
    L = uint16(L);
    LUT = zeros(1,65536,'uint16');
    LUT(2:length(Labels)+1) = Labels;
    result = double(intlut(L, LUT));
end