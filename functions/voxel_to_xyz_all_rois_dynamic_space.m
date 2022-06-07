function [] = voxel_to_xyz_all_rois_dynamics_space(SUBJECT)  
%nina fultz may 2021

%usage:
%1) loading your putamen and cerebellum masks
%2) finding anything thats nonzero
%3) subtracting 1 to get to matlab coordinates
%4) writing out to jip-km directory

%%% run in terminal before opening matlab:
% module load spm
% module load matlab
% module load freesurfer
% matlab

%% defining variables
rois = {'cerebellum' 'putamen' 'caudate' 'thalamus' 'cerebral_cortex' 'amygdala' 'occipital_cortex' 'raphe_nuclei'}
%% setting parent directory

projectdir = '//data1/ninafultz/az_vig/'
%% 
addpath('//data1/ninafultz/scripts/az_vig/pet_analysis') %adding current path and subfolders

%% defining ts components for fmri

for i = 1:length(rois)
    roi=rois{i}
    labels_dir = [projectdir, SUBJECT, '/labels']
    addpath(labels_dir)
    cd(labels_dir)

    file = niftiread([roi '_mask_in_dynamic_space.nii']);
    idx = find(file); % find nonzero values in M
    [x,y,z] = ind2sub(size(file), idx);
    p = [x-1 y-1 z-1] ;

jip_dir = [projectdir, SUBJECT, '/pet/fastmap/']
addpath(jip_dir)
cd(jip_dir)
dlmwrite([roi '_mask_in_dynamic_space.txt'],p,'delimiter',' ')
end
end
