
%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%lContrast
%
% Input: image - grayscale or color image
%               w - window size for local averaging
%
%
% Output: res - normalized contrast image

function res=lContrast(image,w)

cMax=colfilt(image,[w w],'sliding',@max);
cMin=colfilt(image,[w w],'sliding',@min);

res=(cMax-cMin)./(cMax+cMin+eps);
