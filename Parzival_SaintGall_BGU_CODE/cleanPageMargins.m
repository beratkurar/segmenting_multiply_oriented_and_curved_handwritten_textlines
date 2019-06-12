function [mask, cleanIndices, marginIndices] = cleanPageMargins(L,varargin)
    if (nargin == 3)
        row_percentage = varargin{1};
        col_percentage = varargin{2};
    else
        row_percentage = 0.1;
        col_percentage = 0.1;
    end
    % features = Width, Height, Area
    features = getCCfeatures(L,max(max(L)),true);
    [row, col] = size(L);
    centralRow=floor(row*row_percentage);
    centralCol=floor(col*col_percentage);
    not_margins_mask = false(row,col);
    not_margins_mask(centralRow:end-centralRow,centralCol:end-centralCol) = true;
    marginIndices = unique(L(~not_margins_mask));
    not_marginsIndices = unique(L(not_margins_mask));
    marginIndices = setdiff(marginIndices,not_marginsIndices);
    marginIndicator = ((features(marginIndices,1) > 0.25*col) | (features(marginIndices,2) > 0.25*row));
    marginIndices = marginIndices(marginIndicator);
    mask = (L &~ ismember(L,marginIndices));
    cleanIndices = not_marginsIndices(2:end);
end
