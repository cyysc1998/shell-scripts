#!/bin/bash
# From https://cloud.tencent.com/edu/learning/course-2387-36765
for FILE in $*
do
    if [ ! -w $FILE ]; then
        echo "Warning: File [$FILE] not exists.Skip this file."
        continue
    fi

    if [ "`dirname "$FILE"`" = '.' ];then
        RECYCLEBINDIR="`pwd`/.RECYCLEBIN"
    elif [ "`dirname "$FILE"`" = '/' ];then
        RECYCLEBINDIR="/.RECYCLEBIN"
    else
        RECYCLEBINDIR="`dirname "$FILE"`/.RECYCLEBIN"
    fi

    mkdir -p $RECYCLEBINDIR 2>/dev/null

    if [ $? -ne 0 ];then
        echo "Permission denied.Can't delete file [$FILE]. Skip this file."
        continue	
    fi

    chmod 777 $RECYCLEBINDIR

    function MoveFileToRecyclebin()
    {
        mv $FILE ""$RECYCLEBINDIR"/`basename $FILE`.`date +%Y-%m-%d-%H-%M-%S`"
        at now+7day <<< "/usr/bin/rm -rf ""$RECYCLEBINDIR"/`basename $FILE`.`date +%Y-%m-%d-%H-%M-%S`"">/dev/null 2>/dev/null
    }

    function RemoveFileForever()
    {
        /usr/bin/rm -rf $FILE
    }

    SIZE=`du -ms $FILE | awk '{print $1}'`
    if [ "$SIZE" -gt "1024" ];then
        echo "Warning: File $FILE is too large("$SIZE"M),delete it forever? y/n"
        while read answer
            do
                if [ "$answer" == "y" ];then
                    RemoveFileForever
                    break
                elif [ "$answer" == "n" ];then
                    MoveFileToRecyclebin
                    break
                else
                    echo "Please input y or n"
                fi
            done
    else
        MoveFileToRecyclebin
    fi

done
