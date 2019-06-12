% features: width 1, height 2,  area 3, max_horSW 4,
 % max_verSW 5,  sw 6, (mode,mean,variance) verSW 7-8-9,
 % (mode,mean,variance) horWS 10-11-12.
function features = getCCfeatures(L,num,basic)
    if (basic)
        features = zeros(num,3);
    else
        features = zeros(num,7);
    end
    
    s=regionprops(L,'Area','BoundingBox');
    bb=[s.BoundingBox];
%    Extent = [s.Extent];
    idx = 1:size(bb,2);
    Area = [s.Area];
    
    % rect = [x y width height]
    Width = bb(mod(idx,4) == 3);   
    Height = bb(mod(idx,4) == 0);
    
     features(:,1) = Width; 
     features(:,2) = Height;
     features(:,3) = Area;
    
     if (basic)
         return;
     end
     
     mask = L > 0;
     border_mask = mask &~ imerode(mask,ones(3));
     [horSW,verSW]=my_sw_Length2(double(mask));
     flat_L=L(:);
     horSW = horSW(:);
     verSW = verSW(:);
     border_mask = border_mask(:);
     for i=1:length(flat_L)
         if (flat_L(i) ~= 0)
             features(flat_L(i),4) = (max(horSW(i), features(L(i),4)));
             features(flat_L(i),5) = (max(verSW(i), features(L(i),5)));
             features(flat_L(i),6) =  features(flat_L(i),6) +  1;
             features(flat_L(i),7) = features(flat_L(i),7)+ border_mask(i);
         end
     end
     features(:,6) =  2* (features(:,6) ./ features(:,7));
     
     [ver_rl_hist, hor_rl_hist] = compute_run_length_histograms(L,num);
     [features(:,7),features(:,8),features(:,9)]=computeHistFeatures(ver_rl_hist);
     [features(:,10),features(:,11),features(:,12)]=computeHistFeatures(hor_rl_hist);
     
    features(:,13) =  sqrt(features(:,1).^2+features(:,2).^2);
end

function [ver_rl_hist, hor_rl_hist] = compute_run_length_histograms(L,num)
    sz = size(L);
    ver_rl_hist = zeros(num,sz(1));
    hor_rl_hist = zeros(num,sz(2));
    
    [horSW,verSW]=my_sw_Length(double(L>0));
    ver_rl_hist = compute_run_length_histogram_helper(L,verSW,ver_rl_hist);
    hor_rl_hist = compute_run_length_histogram_helper(L',horSW',hor_rl_hist);
end

function  [my_mode,my_mean,my_var]=computeHistFeatures(histogram)
    sz = size(histogram);
    indices = 1:sz(2);
    my_mean =sum(bsxfun(@times,histogram,indices),2)./sum(histogram,2);
    my_var =sum(bsxfun(@times,histogram,indices.^2),2)./sum(histogram,2)-my_mean.^2;
    [~,my_mode] = max(histogram,[],2);
end

function [run_length_histogram] = compute_run_length_histogram_helper(L,SW,run_length_histogram)
    flat_SW = SW(:);
    flat_L = L(:);
    
    for i=1:length(flat_SW)
        if (flat_SW(i)~=0)
            if (flat_SW(i)==1)
                addition = 1;
            else
                addition = 0.5;
            end
            run_length_histogram(flat_L(i),flat_SW(i))=run_length_histogram(flat_L(i),flat_SW(i))+addition;
        end
    end
end
