function [result,location] = slmpar(model,parameter,domain)
% slmpar: Compute a given parameter of a slm or pp function (integral, max, min) over a defined domain
% usage: result = slmpar(model,parameter)
% usage: result = slmpar(model,parameter,domain)
%
% Arguments: (input)
%  model - A slm model as produced by slmengine,
%        also any pp form, as produced by spline
%        or pchip, or even by slmengine.
% 
%  parameter - Character string which denotes the
%        parameter to be computed. Allowable options
%        are {'integral', 'maxfun', 'minfun', 'maxslope', 'minslope'}
%
%        'integral' - Computes the definite integral
%           of a spline between two points
%
%        'maxfun' - the maximum value of a spline 
%           between the supplied limits
%
%        'minfun' - the minimum value of a spline 
%           between the supplied limits
%
%        'maxslope' - the maximum value of the first
%           derivative of the spline between the
%           supplied limits
%
%        'minslope' - the minimum value of the first
%           derivative of the spline between the
%           supplied limits
%
%  domain - (OPTIONAL) - denotes the domain over
%        which the specified parameter will be
%        computed. When domain is not supplied, then
%        it is assumed to be the entire support of
%        the supplied spline model (slm or pp form).
%
%        If domain falls outside of the support of
%        the spline, then the min or max will be
%        reported as [], and any integral will be zero.
%
%        Default: [model.breaks(1), model(breaks(end))]
%
% Arguments: (output)
%  result - a scalar value which contains the desired
%        parameter value.
%
%  location - The location where the spline attains
%        the indicated parameter value. No location is
%        returned for the integral, so this argument
%        will be empty for that case.
%
% Example:
% % An interpolating spline, created by spline
%
% x = linspace(-pi,pi);
% y = sin(x);
% pp = spline(x,y);
%
% res = slmpar(pp,'integral')
% % res =
% %    -2.00360561475321e-16
%
% res = slmpar(pp,'integral',[0,pi])
% % res =
% %     1.99999995586484
% 
% [res,loc] = slmpar(pp,'maxfun')
% % res =
% %     0.99999997621329
% % loc =
% %     1.57079432824228
%
% [res,loc] = slmpar(pp,'minfun',[-1,1])
% % res =
% %    -0.841470963664934
% % loc =
% %    -1
%
% See also: slmeval, ppval, slmengine, spline, pchip
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 6/10/09

if (nargin < 2) || (nargin > 3)
  error('SLMPAR:improperarguments','Too many or too few arguments supplied')
end

if ~isstruct(model) || ~isfield(model,'form') || ~ismember(model.form,{'pp' 'slm'})
  error('SLMPAR:improperarguments','model must be a structure, specifically a pp or slm form')
end

% we will do all processing on model as a pp form
if strcmp(model.form,'slm')
  % convert the slm to a pp form
  model = slm2pp(model);
end

% degree of the spline in question?
deg = model.order - 1;

if (nargin < 2) || isempty(parameter) || ~ischar(parameter)
  error('SLMPAR:improperarguments','parameter was not supplied, as a string')
end

% check to see which parameter is requested
valid = {'integral', 'maxfun', 'minfun', 'maxslope', 'minslope'};
ind = strmatch(lower(parameter),valid);
if isempty(ind) 
  error('SLMPAR:improperarguments','Improper parameter supplied')
elseif (numel(ind) > 1)
  error('SLMPAR:improperarguments','Ambiguous parameter supplied')
else
  parameter = valid{ind};
end

% domain must be an interval if supplied
if (nargin < 3) || isempty(domain)
  domain = [model.breaks(1), model.breaks(end)];
elseif ~isnumeric(domain) || (numel(domain)~=2)
  error('SLMPAR:improperarguments','domain must be a vector of length 2 if supplied')
end
domain = double(domain);

if strcmp(parameter,'integral')
  % integrate the pp
  n = model.pieces;
  dx = diff(model.breaks)';
  coef = [model.coefs,zeros(n,1)];
  coef(:,1:(deg+1)) = coef(:,1:(deg+1)) * diag(1./((deg+1):-1:1));
  
  % make the segments accumulate the integral
  if n > 1
    subint = coef(:,1);
    for i = 1:(deg+1)
      subint = subint.*dx + coef(:,i+1);
    end
    subint = cumsum([0;subint(1:(end-1))]);
    
    coef(:,end) = coef(:,end) + subint;
  end
  model.coefs = coef;
  model.order = model.order + 1;
  
  % evaluate at the end points and subtract
  result = diff(ppval(model,domain));
  
  % no location is returned for this parameter
  location = [];
  
  % we are done
  return
end

% if we drop down to here, we must compute a
% function min or max, or a derivative min or max.

% for the integral, domain could have been supplied
% with domain(1) > domain(2). just sort it for any
% other possible parameter.
domain = sort(domain);

% we will find a min in all cases. For a max,
% i.e., {'maxfun' 'maxslope'} these are really the
% same problem. just negate the coefficients to
% turn one into the other.
if ismember(parameter,{'maxfun', 'maxslope'})
  model.coefs = -model.coefs;
end

% We wish to locate a derivative. differentiate
% the model itself.
if ismember(parameter,{'minslope', 'maxslope'})
  if deg == 0
    % a piecewise constant function will have
    % a simpler yet derivative (excluding those
    % nasty singularities at the breaks.)
    result = 0;
    location = model.breaks(1);
    return
  end
  
  ind = 1:deg;
  model.coefs = model.coefs(:,ind).*repmat(deg-ind+1,model.pieces,1);
  
  model.order = model.order - 1;
  deg = deg - 1;
end

% the problem is now reduced to finding the minimum
% value of the pp function represented by model, over
% the specified domain.
location = domain(1);
result = inf;
for i = 1:model.pieces
  xa = model.breaks(i);
  xb = model.breaks(i+1);
  
  if (domain(1) > xb)
    % this interval does not lie in the domain
    % interval, so skip to the next interval
    continue
  elseif (domain(2) < xa)
    % no reason to search over any more intervals
    break
  end
  
  coef = model.coefs(i,:);
  
  if (deg == 0)
    if (coef(end) < result)
      % the function is constant, so the
      % minimum value over this interval
      % is simple to find. If it was less than
      % the previous min, keep it.
      result = coef(end);
      % just in case the domain left hand end point
      % fell inside this interval.
      location = max(xa,domain(1));
    end
    
    % we can drop to the next interval
    continue
  elseif (deg == 1)
    % if deg is 1, then the min value must
    % occur at one of the end points. Be
    % careful not to look outside domain.
    fa = polyval(coef,max(xa,domain(1))-xa);
    fb = polyval(coef,min(xb,domain(2))-xa);
    
    if fa < result
      result = fa;
      location = max(xa,domain(1));
    end
    
    if fb < result
      result = fb;
      location = min(xb,domain(2));
    end
    
    % we can drop to the next interval
    continue
  end
  
  % deg  must be at least 2 to get to this point.
  % The min value MAY occur at one of the end
  % points, or it may lie at an internal location.
  fa = polyval(coef,max(xa,domain(1))-xa);
  fb = polyval(coef,min(xb,domain(2))-xa);
  
  if fa < result
    result = fa;
    location = max(xa,domain(1));
  end
  
  if fb < result
    result = fb;
    location = min(xb,domain(2));
  end
  
  % are there any roots of the derivative in this
  % interval? (Note: if this was a minslope or maxslope
  % problem, then this will be the 2nd derivative
  % computed here.
  dercoef = coef(1:deg).*(deg:-1:1);
  
  derroots = roots(dercoef);
  % we don't need any complex roots
  derroots(imag(derroots) ~= 0) = [];
  % or those which fell outside of the interval
  derroots(derroots <= max(0,domain(1) - xa)) = [];
  derroots(derroots >= min(xb - xa,domain(2) - xa)) = [];
  
  % test any that remain, in case the min
  % was an interior min
  if ~isempty(derroots)
    fr = polyval(coef,derroots);
    [fr,indmin] = min(fr);
    locr = derroots(indmin) + xa;
    
    if fr < result
      result = fr;
      location = locr;
    end
  end
  
end % for i = 1:model.pieces

% did we drop through and never find anything?
if isinf(result)
  result = [];
  location = [];
end

% turn a min back into a max. the location
% stays the same.
if ismember(parameter,{'maxfun', 'maxslope'})
  result = -result;
end






