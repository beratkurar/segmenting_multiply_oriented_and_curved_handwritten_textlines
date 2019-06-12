%
% Author: Itay Bar-Yosef
%
% Date:  30/5/2010
%sw_Length
%
% Input: image - binary image
%
%
% Output: h - runlength histogram of horizontal strokes
%                    h1 - runlength vertical of horizontal strokes
%                   horSW - horizontal stroke width for each boundary pixel
%                   verSW - vertical stroke width for each boundary pixel

function [h,h1,horSW,verSW]=sw_Length(image)
%maximal stroke width
h=zeros(1,500);
h1=zeros(1,500);

[row col]=size(image);
horSW=zeros(row,col);
verSW=zeros(row,col);

r=1;
c=1;
index=0;
while( r<row)
    
   while(image(r,c)==0 & c<col)
       c=c+1;
   end
   %count number of pixels
   while(image(r,c)==1 & c<col)
         index=index+1;
         c=c+1;
   end
   
   index=min(index,499);
   horSW(r,c-1)=index;
   horSW(r,c-index)=index;
   
   %sum
   if (index>0)
       h(index)=   h(index)+1;
   end
   index=0;
   if (c==col)
       r=r+1;
       c=1;
   end
end
       
  r=1;
  c=1;
  index=0;
while( c<col)
    
   while(image(r,c)==0 & r<row)
       r=r+1;
   end
   %count number of pixels
   while(image(r,c)==1 & r<row)
         index=index+1;
         r=r+1;
   end
   index=min(index,499);
   verSW(r-1,c)=index;
   verSW(r-index,c)=index;
   
   %sum
   if (index>0)
       h1(index)=   h1(index)+1;
   end
   index=0;
   if (r==row)
       c=c+1;
       r=1;
   end
end
       
       
            