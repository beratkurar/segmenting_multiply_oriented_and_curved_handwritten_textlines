function [res, response]= applyFilters(in,sz,theta,scale,eta)
% in - a normalized image.
    responses = -Inf(length(theta)+1,sz(1)*sz(2));
    for idx=1:length(theta)
        im1 = anigauss(in, scale, eta*scale, theta(idx), 2, 0);
        responses(idx,:) = (im1(:))';
    end
    [response, loc] =  max(responses);
    res = reshape(loc,sz(1),sz(2));
    response = reshape(response,sz(1),sz(2));
end

