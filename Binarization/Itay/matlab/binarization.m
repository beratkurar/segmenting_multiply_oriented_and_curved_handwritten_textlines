%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
% binarization
%
% Input: image - grayscale or color image
%                 windowSize - local averaging window size. Best value
%                 should be 1.5 times   the  average character size.
%
%                type - 0 for faster version without the final level set
%                                  method. 
%                              1 - slower and more accurate method
%                              (including level set method)
%
% Output: seg - Binary image

function seg = binarization(image,windowSize,type)
    %Initila binarization
    
    [row col dim]=size(image);
    if( dim==3)
        image=rgb2gray(image);
    end
 
    image=double(image);

    [R,E]=localMin_Max_Bin(image,windowSize);
    %Post processing
    [r,edgeCount,areaCount]=edgeCountConnectivity(R,E,0.35);
    % Calculate average stroke width and remove small blobs
    r=postProcessing_Stroke(r);    
    
    if (type==0)
        seg=r;
        return;
    end
    
    %Processing information towards adaptive scale level set method
    
    %variable radius denotes for each pixel its local scale
     radius=getAdaptiveScale(r);
    %Local level set segmentation
    numIter=30;%number of iterations for the level set function
    [seg,its] = localized_Bin_Adaptive_Rad(image,r,numIter,radius,0);