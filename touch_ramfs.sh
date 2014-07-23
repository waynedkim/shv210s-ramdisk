#!/bin/bash

###
# Ramdisk automation tool
#
# author: Wayne (Dojung) Kim (dojung.kim@live.com)
# last edited by: wdk, 24/JUL/2014
###

CMD=$1
IMG_PATH=$2
FILE_NAME=${IMG_PATH##*/}
WORK_DIR="ramfs_factory"

if [ -z ${CMD} ]; then
	echo "No command specified."
	echo "* Usage: $0 [pack/unpack] [ramdisk.img]"
	exit
fi

if [ -z ${IMG_PATH} ]; then
	echo "No target ramdisk specified."
	echo "* Usage: $0 [pack/unpack] [ramdisk.img]"
	exit
fi

case ${CMD} in
	unpack)
		if [ ! -f ${IMG_PATH} ]; then
			echo "Image file is not exist."
			exit
		fi

		IS_TEMPDIR=`pwd | grep ${WORK_DIR} | wc -l`

		# Check temporary directory
		if [ ${IS_TEMPDIR} == "0" ]; then
			if [ ! -d ${WORK_DIR} ]; then
				mkdir ${WORK_DIR}
			fi
			echo "Working directory is at ${WORK_DIR}"
			cd ${WORK_DIR}
			rm -rf *
			IMG_PATH="../${IMG_PATH}"
		fi

		# Check if it is gzip file or not
		MAGIC_NUMBER=`cat ${IMG_PATH} | head -c2 | hexdump -e '"%02x"'`
		if [ ${MAGIC_NUMBER} == "8b1f" ]; then
			echo "Extracting gzip'd image file"
			cp ${IMG_PATH} ./${FILE_NAME}.gz
			gzip -d ./${FILE_NAME}.gz
		else
			cp ${IMG_PATH} ./${FILE_NAME}
		fi

		# Unpack cpio
		echo "Unpacking cpio..."
		cpio -i --no-absolute-filenames < ./${FILE_NAME}
		rm ./${FILE_NAME}
		echo "Done."
		;;

	pack)
		if [ -f ${IMG_PATH} ]; then
			echo "Image file is already exist."
			echo "Overwrite it? [y/n]"
			read OVERWRITE
			if [ "${OVERWRITE}" == "N" -o "${OVERWRITE}" == "n" ]; then
				exit
			fi
		fi

		echo "Packing cpio..."
		cd ${WORK_DIR}
		find . | cpio -o -H newc > ${IMG_PATH}
		cd ..
		echo "Packing with gzip."
		gzip -c ${IMG_PATH} > ${IMG_PATH}.gz
		mv ${IMG_PATH}.gz ${IMG_PATH}
		echo "${IMG_PATH} is created."
	;;
esac
