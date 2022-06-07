# AZ vigilance analysis
# Nina Fultz May 2022

# # overview
# 1) organize files
# 2) run recon all 
# 3) create segmentation for GTM
# 4) register PET image with anatomical
# 5) motion correction
# 6) jip kinetic modelling

#define
PROJ_PATH=
SUBJECT_LIST=()

# 1) organizing files - moving mr and pet data into common folder
az_moving_files.sh

# 2) unpacking, recon all, brainstem recon, gtmseg

#dicom unpacking
parallel ./get_data.sh -n dicoms -d /users/ninafultz/az_vig/{} -s dcm2niix ::: $SUBJECT_LIST

#recon all 
parallel SUBJECTS_DIR=//data1/ninafultz/az_vig/{} recon-all -all -subj fs -parallel -i $PROJ_PATH/{}/anat/Head_t1_mprage_sag_p2_iso.nii.gz ::: $SUBJECT_LIST
for SUBJECT in *; 
do if [[ -f $SUBJECT/fs/scripts/recon-all.error ]]; 
then echo "$SUBJECT recon-all.error exists on your filesystem."; fi; done

#brainstemstructures
parallel ./recon_brainstem.sh -n {} -d $PROJ_PATH ::: $SUBJECT_LIST

#pet structures
parallel export SUBJECTS_DIR=$PROJ_PATH/{} ./gtmseg --s fs/ ::: $SUBJECT_LIST

for SUBJECT in *; 
do if [[ ! -f $SUBJECT/fs/mri/gtmseg.lta ]]; 
then     echo "$SUBJECT/fs/mri/gtmseg.lta not exist on your filesystem."; 
fi; done 

#3) pet registration, pet motion correction

parallel ./pet_registration.sh -n {} -d $PROJ_PATH -f NP3-kontrol.nii.gz ::: $SUBJECT_LIST
parallel ./pet_motion_correction.sh -n {} -d $PROJ_PATH -f NP3-kontrol.nii.gz ::: $SUBJECT_LIST

#4) making rois: brainstem overlays, cortex, amygdala, etc 
parallel ./extract_rois.sh -n {} -d $PROJ_DIR ::: $SUBJECT_LIST
parallel ./annot_lobes_to_niftis.sh -n {} -d $PROJ_DIR ::: $SUBJECT_LIST


#5) turning labels into xyz txt file

for SUBJECT in $SUBJECT_LIST #automate this more
do
matlab -nodisplay -r "voxel_to_xyz_all_rois_dynamic_space('$SUBJECT')"
done

#6) formatting and moving files into a fastmap folder
parallel ./fastmap_organizing -n {} -d $PROJ_PATH -s $SCRIPTS ::: $SUBJECT_LIST #automate this more

#7) displaying results (in jip_km folder): make sure to have source /usr/pubsw/packages/jip/define-jip.bash added to your .bashrc file --- MAKE SURE TO RESTART WHEN YOU DO THIS. ALSO THIS FILE WILL INTERACT BADLY WITH OTHER THINGS LIKE RSYNC SO HAVE AN ENVIRONMENT YOU RUN THIS IN 

$JIP_PATH NP3-kontrol.nii.gz_mc.nii -o overlay-list.txt 

#8) save out ROI as individual file (press big R in jip-display GUI) #should automate this but idk right now
        #EXTRACTING INFORMATION:
        #right click, can take out all curves , and extract text file

#9) take text files from .roi files
 
parallel ./formatting_fastmap_rois.sh -n {} -s SRTM3_20min -d $PROJ_PATH ::: $SUBJECT_LIST
## make figures !

############################################################################
#ASL data

#unpacking data
parallel ./get_data1.sh -n dicoms -d $PROJ_PATH/{} -s dcm2niix ::: $SUBJECT_LIST

#motion correction
parallel ./motion_correction.sh -n {} -d $PROJ_PATH -s $SCRIPTS ::: $SUBJECT_LIST

#registration using bbregister
parallel ./registration.sh -n {} -d $PROJ_PATH -i Head_ep2d_pcasl_UI_PHC_LT1730PLD1500_p2 ::: $SUBJECT_LIST
#extracting asl rois

parallel ./extract_asl_rois.sh -n {} -d $PROJ_PATH -i Head_ep2d_pcasl_UI_PHC_LT1730PLD1500_p2 ::: $SUBJECT_LIST
