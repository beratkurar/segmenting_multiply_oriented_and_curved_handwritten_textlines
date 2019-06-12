function [max_orientation, scale_res, max_response] = MS_filterDocument(im,scales, theta)

    sz = size(im);
    if (length(sz) == 3)
        im = rgb2gray(im);
    end
    
    if (islogical(im))
        im = uint8(im)*255;
    end
    
    in = double(im);
    sz = size(im);
    
    orientation_map = -Inf(1,sz(1)*sz(2));
    response_map = -Inf(2,sz(1)*sz(2));
    scale_res = -Inf(1,sz(1)*sz(2));
    
    for sc=1:length(scales)
        scale = scales(sc);
        eta = 3;
        [orientation, response] = applyFilters(in, sz,theta,scale,eta);
        gamma = 2;
        response_map(2,:) = (scale*scale*eta)^(gamma/2)*response(:);            
        [val, loc] = max(response_map);
        response_map(1,:) = val;
        orientation_map(loc == 2) = orientation(loc == 2);
        scale_res(loc == 2) = scale;
    end

    max_orientation = reshape(orientation_map,[sz(1),sz(2)]);
    scale_res = reshape(scale_res,[sz(1),sz(2)]);
    max_response = reshape(response_map(1,:),[sz(1),sz(2)]);
end
