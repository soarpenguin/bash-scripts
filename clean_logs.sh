#!/bin/bash
#
# Purpose:  check disk space, and clean log
#

# Global Settings
#
SAVETIME=${1}
CLEAN_PATH=${2}
CLEAN_FILE=${3}
THRESHOLD=${4:-80}
ISCLEAND_DIR=${5:-"N"}
YESTERDAY=`date +%Y-%m-%d -d "-1 day"`
YESTERDAY_A=`date +%Y%m%d -d "-1 day"`


echo "${SAVETIME}"
echo "${CLEAN_PATH}"
echo "${CLEAN_FILE}"
echo "${THRESHOLD}"

if [ $# -lt 3 ];then
   echo 'the params nums illegality'
   exit 1
fi

check_params(){
    echo "${SAVETIME}" | egrep -i -q "^[0-9]{1,}(h|m)?$"
    if [ $? -ne 0 ];then
        echo 'the $1 param illegality'
        exit 1
    fi
    echo "${CLEAN_PATH}" | egrep -q "^\/(home|Users)\/.{0,}"
    if [ $? -ne 0 ];then
        echo 'the $2 param illegality'
        exit 1
    fi
    echo "${CLEAN_FILE}" | egrep -i -q "^.{0,}(log|access).{0,}$"
    if [ $? -ne 0 ];then
        echo 'the $3 param illegality'
        exit 1
    fi
}

#check disk
check_disk()
{
    for space in `df -lh | sed '1d' | awk '{print $5$6}'`
    do
        p=`echo $space | awk -F% '{print $1}'`
        d=`echo $space | awk -F% '{print $2}'`
        if [ $p -ge $THRESHOLD ];then
           return 0;
        fi
    done
    return 1
}

#clean file
free_space()
{
    echo "$SAVETIME" | grep -i -q "h"
    if [ $? -eq 0 ]; then
        SAVETIMETMP=$(echo   $SAVETIME  |   tr   [a-z]   [A-Z])
        SAVETIME=`expr  ${SAVETIMETMP%H} \* 60`
        echo 'match file number:'
        find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
        #find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print0 |xargs -0 rm -f

        for filename in `find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}"`
        do
            echo $filename
            echo "" | sudo tee $filename
            rm -f $filename
        done
        echo 'after cleaning match file number:'
        find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
    else
        echo "$SAVETIME" | grep -i  -q "m"
        if [ $? -eq 0 ]; then
            SAVETIMETMP=$(echo   $SAVETIME  |   tr   [a-z]   [A-Z])
            SAVETIME=${SAVETIMETMP%M}
            echo 'match file number:'
            find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
            #find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print0 |xargs -0 rm -f
            for filename in `find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}"`
            do
                echo $filename
                echo "" | sudo tee $filename
                rm -f $filename
            done

            echo 'after cleaning match file number:'
            find $CLEAN_PATH -maxdepth 5 -type f -mmin +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
        else
            echo 'match file number:'
            if [ $SAVETIME != 0 ];then
                find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
                #find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print0 |xargs -0 rm -f
                for filename in `find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}"`
                do
                    echo $filename
                    echo "" | sudo tee $filename
                    rm -f $filename
                done
                echo 'after cleaning match file number:'
                find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l

                if [ "$ISCLEAND_DIR" == "Y" ];then
                    free_dir
                fi

            else
                find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l
                #find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print0 |xargs -0 rm -f
                for filename in `find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}"`
                do
                    echo $filename
                    echo "" | sudo tee $filename
                    rm -f $filename
                done
                find $CLEAN_PATH -maxdepth 5 -type f -mtime +"${SAVETIME}" -name "${CLEAN_FILE}" -print|wc -l

                find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY*" -print|wc -l
                #find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY*" -print0 |xargs -0 rm -f
                for filename in `find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY*"`
                do
                    echo $filename
                    echo "" | sudo tee $filename
                    rm -f $filename
                done
                find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY*" -print|wc -l

                find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY_A*" -print|wc -l
                #find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY_A*" -print0 |xargs -0 rm -f
                for filename in `find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY_A*"`
                do
                    echo $filename
                    echo "" | sudo tee $filename
                    rm -f $filename
                done
                find $CLEAN_PATH -maxdepth 5 -type f -name "*$YESTERDAY_A*" -print|wc -l

                if [ "$ISCLEAND_DIR" == "Y" ];then
                   free_dir
                fi
            fi
        fi
    fi
}

#clean date format directory
free_dir(){
    #清理日期命名的空目录
    echo 'match YYYYMMDD directory number:'
    find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9][0-1][0-9][0-3][0-9]" -print|wc -l
    for dirname in `find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9][0-1][0-9][0-3][0-9]"`
    do
        echo $dirname
        if [ `find $dirname -maxdepth 5 -type f -print | wc -l` -eq 0 ];then
           rm -fr $dirname
        else
           echo "$dirname is not empty directory,files number:"
           find $dirname -maxdepth 5 -type f -print | wc -l
        fi
    done
    echo 'after cleaning match directory number:'
    find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9][0-1][0-9][0-3][0-9]" -print|wc -l

    echo 'match YYYY-MM-DD directory number:'
    find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]" -print|wc -l
    for dirname in `find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]"`
    do
        echo $dirname
        if [ `find $dirname -maxdepth 5 -type f -print | wc -l` -eq 0 ];then
           rm -fr $dirname
        else
           echo "$dirname is not empty directory,files number:"
           find $dirname -maxdepth 5 -type f -print | wc -l
        fi
    done
    echo 'after cleaning match directory number:'
    find $CLEAN_PATH -maxdepth 5 -type d -mtime +"${SAVETIME}" -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]" -print|wc -l
}


check_params
check_disk
#sleep random second
if [ $? -eq 0 ];then
    FLOOR=0
    RANGE=60
    number=0
    while [ "$number" -le $FLOOR ]
        do
            number=$RANDOM
            let "number %= $RANGE"
        done
    sleep $number
    free_space
fi
#echo
df -hl
