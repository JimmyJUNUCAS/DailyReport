%
% compute dense color feature for an image
%

function [color_arr, grid_x, grid_y] = sp_dense_color(I, params)
% dense color MATLAB script
%

grid_spacing = params.gridSpacing;
patch_size = params.patchSize;
num_bins = params.nbins;

[hgt, wid, dimcolor] = size(I);

% grid
grid_x = params.patchSize/2:params.gridSpacing:wid-params.patchSize/2+1;
grid_y = params.patchSize/2:params.gridSpacing:hgt-params.patchSize/2+1;
[grid_x,grid_y] = meshgrid(grid_x, grid_y);
grid = [grid_x(:), grid_y(:)];

Nx = length(grid_x);
Ny = length(grid_y);

color_arr = zeros(Nx*Ny, num_bins*dimcolor);
% extract dense color histogram
for i = 1:Nx*Ny
    hist = colorHist(l(I, ...
        [grid(i, :)-patch_size/2+1, patch_size-1, patch_size-1]), num_bins);
    %             % L2-clamp norm
    %             norm_tmp = hist/sqrt(sum(hist.^2)+epsi^2);
    %             norm_tmp(norm_tmp >= clamp) = clamp;
    %             norm_tmp = norm_tmp/sqrt(sum(norm_tmp.^2)+epsi^2);
    color_arr(i, :) = hist;
end
end


function h = colorHist(cvt, K)
%compute the color histogram of the image patch
ratio = 256/K;
data_r = uint8(cvt(:,:,1)/ratio+1);
data_g = uint8(cvt(:,:,2)/ratio+1);
data_b = uint8(cvt(:,:,3)/ratio+1);
h = [hist(data_r(:), 1:K),hist(data_g(:), 1:K), hist(data_b(:), 1:K)];
h = h';
end
