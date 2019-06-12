%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
% localized_Bin_Adaptive_Rad
%
% Input: image - grayscale  image
%                  mask - initil binary mask
%                  max_its - maximum number of iterations
%                   rad - local radius map. Determines the local window
%                   size for the level set force
%                   display - 1 for evolution display, 0 - no display
% Output: seg - Binary image
%                      its- number ofiterations untill convergance

function [seg,its] = localized_Bin_Adaptive_Rad(image,mask,max_its,rad,display)

image=double(image);
se=ones(3,3);


 %-- Default localization radius is 1/10 of average length
 [dimy dimx] = size(image);
       
 prevMask=mask;
 %--main loop
 for its = 1:max_its   
     
    % check for convergance
            if (mask==prevMask & its>1)
                      seg=mask;
                      return;
             end
        prevMask=mask;
   
    
       %-- get the curve's narrow band

       onLst=mask-imerode(mask,se);
       narLst=getNarrowPixels(onLst);

       idxIn = find(onLst==1);  
       [yIn xIn] = ind2sub(size(mask),idxIn);
   
       idxOut = find(narLst==1);  
       [yOut xOut] = ind2sub(size(mask),idxOut);
      idx = find(narLst==1|onLst==1);  
       [y x] = ind2sub(size(mask),idx);
   
      radAdaptive=rad(idx);
   
       %-- get windows for localized statistics
       xneg = x-radAdaptive; xpos = x+radAdaptive;      %get subscripts for local regions
       yneg = y-radAdaptive; ypos = y+radAdaptive;
       xneg(xneg<1)=1; yneg(yneg<1)=1;  %check bounds
       xpos(xpos>dimx)=dimx; ypos(ypos>dimy)=dimy;

       %-- re-initialize u,v,Ain,Aout
       u=zeros(size(idx)); v=zeros(size(idx));

       Ain=zeros(size(idx)); Aout=zeros(size(idx));
    
      
       
       %-- compute local stats
       for i = 1:numel(idx)  % for every point in the narrow band
         img = image(yneg(i):ypos(i),xneg(i):xpos(i)); %sub image
         P = mask(yneg(i):ypos(i),xneg(i):xpos(i)); %sub phi

         
         upts = find(P==1);            %local interior
         Ain(i) = length(upts);%+eps;
         u(i) = sum(img(upts))/Ain(i);

         
           vpts = find(P==0);             %local exterior
           Aout(i) = length(vpts);%+eps;
           v(i) = sum(img(vpts))/Aout(i);
       end  

   %-- get image-based forces

     F=abs(image(idx)-u)-abs(image(idx)-v);  
   
   
     
        mask(idx)=F<0;%
   %-- intermediate output
   if(display>0)
       e=edge(mask*8);
       tmp=image;
       tmp(e==1)=255;
       figure(1),imshow(tmp,[]);

       title(int2str(its))
       pause(0.0001)
   end
 end
 
 seg=mask;
 
end
function  narLst=getNarrowPixels(onLst)
   
    %straight lines
    l=circshift(onLst,[0 1]);
    r=circshift(onLst,[0 -1]);
    u=circshift(onLst,[1 0]);
    d=circshift(onLst,[-1 0]);
    %diagonals
    lu=circshift(onLst,[1 1]);
    ld=circshift(onLst,[-1 1]);
    ru=circshift(onLst,[1 -1]);
    rd=circshift(onLst,[-1 -1]);
    
    tmp=l+r+u+d+lu+ld+ru+rd;
    narLst=tmp>0;
end