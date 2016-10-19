%% LocalFeatureAll
% Example of extract local descriptor of the dataset

clc;
clear;
close all;

image_dir = '/home/user1/0TODO/AID/'; %change for your own path of the dataset
data_dir = '/home/user1/0TODO/temp_data/localfeature/aid/';
mkdir (data_dir);

num_img_all = 10000;
fnames = dir(image_dir);
num_files = size(fnames,1);
filenames = cell(num_img_all,1);
num_class = num_files-2;
num_img_per_class = zeros(num_class,1);

%control all the parameters
params.maxImageSize = 600;
params.gridSpacing = 8;
params.patchSize = 16;
params.nbins = 32; %only for color histogram
featurename = {'ch','sift','lbp256'};
for lf = 1: length(featurename)
    for i = 1:num_files
        
        if( (strcmp(fnames(i).name , '.')==1) || (strcmp(fnames(i).name , '..')==1))
            continue;
        end
        subfoldername = fnames(i).name;
        filename_tif = dir(fullfile(strcat(image_dir,subfoldername),'*.jpg'));
        num_img_per_class(i-2) = length(filename_tif);
        savepath = strcat(data_dir,subfoldername);
        mkdir (savepath);
        for j=1:num_img_per_class(i-2)
            filenames{sum(num_img_per_class(1:i-3))+j,1} = strcat(subfoldername,'/',filename_tif(j).name);
            localfeaturefile = fullfile(savepath, sprintf('%s_%s_%d_%d.mat',...
                filename_tif(j).name(1:end-4),featurename{lf},params.gridSpacing,params.patchSize));
            if(exist(localfeaturefile,'file')~=0)
                fprintf('Already exist %s\n', localfeaturefile);
                continue;
            end
            img = imread(strcat(image_dir,'/',filenames{sum(num_img_per_class(1:i-3))+j,1}));
            features  = LocalFeature( img, featurename{lf}, params );
            save(localfeaturefile, 'features');
        end
        
    end
end
