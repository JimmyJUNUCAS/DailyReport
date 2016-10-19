%% extract low-level features for the dataset

LocalFeatureAll_aid;

clc;
clear;
close all;

localfeaturename = {'sift','lbp256','ch'};
image_dir = '/home/user1/0TODO/AID/';
localfeaturepath = '/home/user1/0TODO/AID/temp_data/localfeature/aid/';
mkdir (localfeaturepath);
savepath = '/home/user1/0TODO/AID/temp_data/feat/aid/';
mkdir (savepath);


%% for ch, lbp and sift
params.gridSpacing = 4;
params.patchSize = 8;
num_img_all = 10000;
fnames = dir(localfeaturepath);
num_files = size(fnames,1);
num_class = num_files-2;
num_img_per_class = zeros(num_class,1);

for lf = 1: length(localfeaturename)
    savename = fullfile(savepath, sprintf('globalfeatureall_lowlevel_%s.mat',localfeaturename{lf}));
    if(exist(savename,'file')~=0)
        fprintf('Already exist %s\n', savename);
        continue;
    end
    globalfeatureall = [];
    for i = 1:num_files
        
        if( (strcmp(fnames(i).name , '.')==1) || (strcmp(fnames(i).name , '..')==1))
            continue;
        end
        subfoldername = fnames(i).name;
        filename_tif = dir(fullfile(strcat(image_dir,subfoldername),'*.jpg'));
        num_img_per_class(i-2) = length(filename_tif);
        
        for j=1:num_img_per_class(i-2)
            localfeaturefile = dir(fullfile(strcat(localfeaturepath,subfoldername,'/',sprintf( '*_%s_*',localfeaturename{lf}))));
            if length(localfeaturefile) == length(filename_tif)
                filename = strcat(localfeaturepath,subfoldername,'/',localfeaturefile(j).name);
                load (filename);
                globalfeatureall = [globalfeatureall; mean(features.data)];
            else
                fprintf('You have not extract the local features for every image\n');
            end
            
        end
        
    end
    save(savename, 'globalfeatureall')
end

%% for gist
num_img_all = 10000;
fnames = dir(image_dir);
num_files = size(fnames,1);
num_class = num_files-2;
num_img_per_class = zeros(num_class,1);

% Parameters:
clear param
param.imageSize = [600 600]; 
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;
featurename = 'gist';

globalfeatureall = [];
globalfeaturename = fullfile(savepath, sprintf('globalfeatureall_lowlevel_%s.mat',featurename));
if(exist(globalfeaturename,'file')~=0)
    fprintf('%s already exists.\n', globalfeaturename);
    load (globalfeaturename);
    return
else
    
    for i = 1:num_files
        
        if( (strcmp(fnames(i).name , '.')==1) || (strcmp(fnames(i).name , '..')==1))
            continue;
        end
        subfoldername = fnames(i).name;
        filename_tif = dir(fullfile(strcat(image_dir,subfoldername),'*.jpg'));
        num_img_per_class(i-2) = length(filename_tif);
        savepath = strcat(localfeaturepath,subfoldername);
        mkdir (savepath);
        for j=1:num_img_per_class(i-2)
            localfeaturefile = fullfile(savepath, sprintf('%s_%s.mat',...
                filename_tif(j).name(1:end-4),featurename));
            if(exist(localfeaturefile,'file')~=0)
                fprintf('Already exist %s\n', localfeaturefile);
                load (localfeaturefile);
                globalfeatureall = [globalfeatureall; features];
                continue;
            end
            img = imread(strcat(image_dir,subfoldername,'/',filename_tif(j).name));
            [features, param] = LMgist(img, '', param);
            save(localfeaturefile, 'features');
            globalfeatureall = [globalfeatureall; features];
            i
            j
        end
    end
    save (globalfeaturename, 'globalfeatureall');
    
end

