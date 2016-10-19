function [ features ] = LocalFeature( img, featurename, params )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
switch featurename
    case 'sift'
        if(~exist('params','var'))
            params.maxImageSize = 600;
            params.gridSpacing = 4;
            params.patchSize = 16;
        end
        if(~isfield(params,'maxImageSize'))
            params.maxImageSize = 600;
        end
        if(~isfield(params,'gridSpacing'))
            params.gridSpacing = 4;
        end
        if(~isfield(params,'patchSize'))
            params.patchSize = 16;
        end
        img_gray = rgb2gray(img);
        [hgt wid] = size(img_gray);
        if min(hgt,wid) > params.maxImageSize
            img_gray = imresize(img_gray, params.maxImageSize/min(hgt,wid), 'bicubic');
            fprintf('original size %d x %d, resizing to %d x %d\n', ...
                wid, hgt, size(img_gray,2), size(img_gray,1));
            [hgt wid] = size(img_gray);
        end
        [siftArr gridX gridY] = sp_dense_sift(img_gray, params.gridSpacing, params.patchSize);
        siftArr = reshape(siftArr,[size(siftArr,1)*size(siftArr,2) size(siftArr,3)]);
        features.data = single(siftArr);
        features.x = gridX(:);
        features.y = gridY(:);
        features.x_grid_num = sqrt(size(features.x,1));
        features.y_grid_num = sqrt(size(features.y,1));
        features.spacing = params.gridSpacing;
        features.hgt = hgt;
        features.wid = wid;
        
    case 'lbp256'
        if(~exist('params','var'))
            params.maxImageSize = 600;
            params.gridSpacing = 4;
            params.patchSize = 16;
        end
        if(~isfield(params,'maxImageSize'))
            params.maxImageSize = 600;
        end
        if(~isfield(params,'gridSpacing'))
            params.gridSpacing = 4;
        end
        if(~isfield(params,'patchSize'))
            params.patchSize = 16;
        end
        img_gray = rgb2gray(img);
        [hgt wid] = size(img_gray);
        if min(hgt,wid) > params.maxImageSize
            img_gray = imresize(img_gray, params.maxImageSize/min(hgt,wid), 'bicubic');
            fprintf('original size %d x %d, resizing to %d x %d\n', ...
                wid, hgt, size(img_gray,2), size(img_gray,1));
            [hgt wid] = size(img_gray);
        end
        SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
        %         mapping=getmapping(8,'u2');
        I=lbp(img_gray, SP, 0, 'i');
        % add boundary:
        I = [I(1,:,:); I; I(end,:,:)];
        I = [I(:,1,:) I I(:,end,:)];
        I = I + 1;
        
        lbp_hist = zeros(hgt, wid, 256);
        for i = 1: 256
            lbp_hist(:, :, i) = int16(I == ones(hgt, wid) * i);
        end
        grid_x = params.patchSize/2:params.gridSpacing:wid-params.patchSize/2+1;
        grid_y = params.patchSize/2:params.gridSpacing:hgt-params.patchSize/2+1;
        
        lbp_arr = zeros(length(grid_y), length(grid_x), 256);
        for ix = 0:(params.patchSize-1)
            for iy = 0:(params.patchSize-1)
                lbp_arr = lbp_arr + lbp_hist(ix + (1:params.gridSpacing:(hgt-params.patchSize+1)), iy + (1:params.gridSpacing:(wid-params.patchSize+1)), :);
            end
        end
        [rows, cols, pages] = size(lbp_arr);
        lbp_arr = reshape(lbp_arr, [rows*cols pages])/(params.patchSize.^2);
        
        [grid_x,grid_y] = meshgrid(grid_x, grid_y);
        
        features.data = single(lbp_arr);
        features.x = grid_x(:);
        features.y = grid_y(:);
        features.x_grid_num = sqrt(size(features.x,1));
        features.y_grid_num = sqrt(size(features.y,1));
        features.spacing = params.gridSpacing;
        features.hgt = hgt;
        features.wid = wid;
        
    case 'ch'
        if(~exist('params','var'))
            params.maxImageSize = 600;
            params.gridSpacing = 4;
            params.patchSize = 16;
            params.nbins = 32;
            
        end
        if(~isfield(params,'maxImageSize'))
            params.maxImageSize = 600;
        end
        if(~isfield(params,'gridSpacing'))
            params.gridSpacing = 4;
        end
        if(~isfield(params,'patchSize'))
            params.patchSize = 16;
        end
        if(~isfield(params,'nbins'))
            params.nbins = 32;
        end
        
        [hgt wid col] = size(img);
        if min(hgt,wid) > params.maxImageSize
            img = imresize(img, params.maxImageSize/min(hgt,wid), 'bicubic');
            fprintf('original size %d x %d, resizing to %d x %d\n', ...
                wid, hgt, size(img,2), size(img,1));
            [hgt wid col] = size(img);
        end
        [chArr gridX gridY] = sp_dense_color(img, params);
        
        features.data = single(chArr/(params.patchSize.^2));
        features.x = gridX(:);
        features.y = gridY(:);
        features.x_grid_num = sqrt(size(features.x,1));
        features.y_grid_num = sqrt(size(features.y,1));
        features.spacing = params.gridSpacing;
        features.hgt = hgt;
        features.wid = wid;
   
end
end

