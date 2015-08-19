function GT = mt2gt(MT, grid)
% GT = mt2gt(MT, grid)
% 
%     INPUT
% 
%       MT : 2-column table, 
%           Column1 : Test 
%           Column 2 : Ref
%       
%       grid : a vector or array
%           The desired grid (to be interpolated)
% 
%     OUTPUT
%       
%       GT : Gridded table, a 2-column table like as MT
%           Column1 : Test (New, interpolated) 
%           Column2 : Reference(Given, the same as "grid")
%           
%       -> the column 1 of MT is interpolated to the grid
%
grid = grid(:);
N = length(grid);
LastVal = max([grid(end), grid(end)], MT(end, :))+ grid(2) - grid(1) + 1;
MT1 = [[0, 0]; MT; LastVal]; % Add dummy 1's and the largest sample number (the last value of grid)
U = interp1(MT1(:, 2), MT1(:, 1), grid, 'pchip');
GT = [U, grid];