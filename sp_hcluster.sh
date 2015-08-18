#!/bin/bash

usage()
{
cat <<EOF
${txtcyn}

***CREATED BY Chen Tong (chentong_biology@163.com)***

Usage:

$0 options${txtrst}

${bldblu}Function${txtrst}:

This script is used to do hierarchical clustering for columns by using
hcluster(package amap is required).

${txtbld}OPTIONS${txtrst}:
	-f	Data file (with header line, the first column is the
 		colname, tab seperated).${bldred}[NECESSARY]${txtrst}
	-k	If the row and column names start with numeric value,
		this can be set to FALSE to avoid modifying these names to be
		illegal variable names. But duplicates can not be picked out.
		[${bldred}Default TRUE${txtrst}] 
		Accept FALSE.
	-s	Whether scale the data.[${bldred}Default FALSE${txtrst}]
		Accept TRUE.
	-b	whether transpose data.[${bldred}Default TRUE${txtrst}]
		Default cluster by columns. If cluster by rows, FALSE should be given.
	-c	Number of final clusters.[${txtred}Default 1${txtrst}, 
		integer (>=2) is allowed. Red lines will be displayed to label
		each cluster.]
	-t	An overall title for the plot.[${txtred}Default empty${txtrst}]
	-x	A title for the x axis.[${txtred}Default empty${txtrst}]. 
	-y	a title for the y axis.[${txtred}Default empty${txtrst}]. 
	-d	dist method.[${bldred}Default "euclidean"${txtrst}]
		Accept "euclidean", "maximum", "manhattan", "canberra", 
		"binary", "pearson", "correlation", "spearman" or "kendall".
	-h	hclust method.[${txtred}Default "ward"${txtrst}]
		Accept "single", "complete", "average", "mcquitty", "median"
		or "centroid".
	-z	Is there a header[${bldred}Default TRUE${txtrst}]
		Accept FALSE.
	-e	whether execute the R script [${bldred}Default TRUE${txtrst}]
		Accept FALSE.
EOF
}

file=
checkNames='TRUE'
scale='FALSE'
title=''
xlab=''
ylab=''
dm='euclidean'
hm='ward'
header='TRUE'
execute='TRUE'
num=0
transpose='TRUE'

while getopts "hf:k:s:b:c:t:x:y:d:h:z:e:" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		f)
			file=$OPTARG
			;;
		k)
			checkNames=$OPTARG
			;;
		s)
			scale=$OPTARG
			;;
		b)	
			transpose=$OPTARG
			;;
		c)
			num=$OPTARG 
			;;
		t)
			title=$OPTARG
			;;
		x)
			xlab=$OPTARG
			;;
		y)
			ylab=$OPTARG
			;;
		d)
			dm=$OPTARG
			;;
		h)
			hm=$OPTARG
			;;
		z)
			header=$OPTARG
			;;
		e)
			execute=$OPTARG
			;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -z $file ]; then
	usage
	exit 1
fi

mid=".hcluster.${dm}.${hm}"

if [ "$scale" = 'TRUE' ]; then
	mid=${mid}'.scale'
fi

cat <<EOF >$file${mid}.r
library(graphics)
library(amap)

data1 <- read.table("$file", header=$header, sep="\t",row.names=1, check.names=${checkNames})

x <- as.matrix(data1)

if ($transpose){
	x <- t(x)
}

if ($scale){
	x <- scale(x)
}

fit <- hcluster(x, method="$dm", link="$hm")

png(file="${file}${mid}.png", width=600, height=900, res=100)

plot(fit, hang=-1, main="$title", xlab="$xlab", ylab="$ylab")

if ($num){
	rect.hclust(fit, k=$num, border="red")
}

dev.off()
EOF

if [ "${execute}" = 'TRUE' ]; then
	Rscript $file${mid}.r
if [ "$?" == "0" ]; then /bin/rm -f ${file}${mid}.r; fi
fi
