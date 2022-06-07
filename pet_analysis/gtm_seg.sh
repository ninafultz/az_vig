for SUBJECT in $SUBJECT_LISR; do export SUBJECTS_DIR=$PROJ_DIR/${SUBJECT};  gtmseg --s fs/ --xcerseg;  done 
