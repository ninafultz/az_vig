!/bin/bash                                                                      
# Script log to get data from scanner
# Nina Fultz January 2022

# how to write it out: ./get_data.sh -n dicoms -d /users/ninafultz -s dcm2niix

#gets displayed when -h or --help is put in
display_usage(){
    echo "***************************************************************************************
Script to retrieve data from scanner, convert to nifti and create minimal meta data files
*************************************************************************************** "
    echo "Usage: ./get_data.sh -n -d -s
           -n: Name of dicom directory - e.g. dicoms
           -d: Subject directory /autofs/cluster/mreg_project
           -s: Pathway to dcm2niix - you can download this from https://github.com/dangom/dcm2niix onto your cluster"
}

if [ $# -le 1 ]
then
    display_usage
    exit 1
fi

unset SubjectOnScanner DIR Subject

while getopts "n:d:s:" opts;
do
    case $opts in
        n) DICOM_DIR=$OPTARG ;;
        d) OUTPUT_DIR=$OPTARG ;;
        s) DCM2NIIX_DIR=$OPTARG ;;
    esac
done

unpacksdcmdir -src "$OUTPUT_DIR"/"$DICOM_DIR"/pet/* -targ "$OUTPUT_DIR" -scanonly unpack.scan
unpacksdcmdir -src "$OUTPUT_DIR"/"$DICOM_DIR"/anat/* -targ "$OUTPUT_DIR" -scanonly unpack.scan
unpacksdcmdir -src "$OUTPUT_DIR"/"$DICOM_DIR"/func/* -targ "$OUTPUT_DIR" -scanonly unpack.scan

# Convert dicoms to nifti and create sidecar JSON file
$DCM2NIIX_DIR -b y -f %p y -z y -o $OUTPUT_DIR $OUTPUT_DIR/$DICOM_DIR #

############################# Start some preparation #################################

mkdir $OUTPUT_DIR/anat $OUTPUT_DIR/func $OUTPUT_DIR/info $OUTPUT_DIR/dynamic

#move stuff accordingly, add to this list
mv $OUTPUT_DIR/*pcasl* $OUTPUT_DIR/func/
mv $OUTPUT_DIR/T1* $OUTPUT_DIR/anat/
mv $OUTPUT_DIR/MEMPRA* $OUTPUT_DIR/anat/
mv $OUTPUT_DIR/MEM* $OUTPUT_DIR/anat/
mv $OUTPUT_DIR/*t1* $OUTPUT_DIR/anat/
mv $OUTPUT_DIR/*NP3* $OUTPUT_DIR/dynamic/
mv $OUTPUT_DIR/DICOM_DIR $OUTPUT_DIR/parse* $OUTPUT_DIR/unpack.scan $OUTPUT_DIR/session $OUTPUT_DIR/unpack.log $OUTPUT_DIR/dicomdir.sumfile $OUTPUT_DIR/info/

INFO=$OUTPUT_DIR/info/unpack.log
echo $INFO
if [ -f $INFO ]; then
  echo "${INFO##*/} DICOM unpacking and parsing is all done! All done, have a lovely day! "
else
  echo "${INFO##*/} DICOM unpacking and parsing failed! "
fi
