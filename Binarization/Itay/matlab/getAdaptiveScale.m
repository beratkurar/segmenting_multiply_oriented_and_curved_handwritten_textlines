%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
% getAdaptiveScale
%
% Input: r - binary  image

% Output: radius - for each pixel, indicates of the local radius, or scale
%                                        (approximated stroke width)

function    radius=getAdaptiveScale(r)
    e=r-imerode(r,ones(3,3));
    b=bwmorph(r,'Thin','Inf');
    d=bwdist(e);
    dT=bwdist(b);
    radius=(dT-d)*2;
    radiusIn=(d+dT)*2;
    mask=dT==d&r==0;
    radius(mask)=2*dT(mask);
    radius(r==1)=radiusIn(r==1);
    radiusMax=max(radius,5);
    radius(r==1)=radiusMax(r==1);
    radius=ceil(radius);
    radius=min(radius,40);