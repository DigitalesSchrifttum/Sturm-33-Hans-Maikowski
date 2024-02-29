#!/bin/bash

# check Chromuim exists
if ! command -v chromium &> /dev/null; then
	echo "Please install chromium!"
	exit 1
fi

if [ -z "$1" ]; then
	echo "Please add the path dir to your GERMAN chromium profile as parameter. It is used for hyphens!"
	exit 1
fi

chromiumDataDir="$1"
outputDir="./output"

convertHtmlToPdf() {
	sourceName=$1
	targetName=$2
	echo "Start converting of $sourceName."
	params="--headless=new  --user-data-dir=${chromiumDataDir} --print-to-pdf=${targetName} ./${sourceName}"
	echo $params
	chromium $params &
	BACK_PID=$!
	echo $BACK_PID

	showMessage=true
	while kill -0 $BACK_PID; do
		if [ "$showMessage" = true ]; then
			echo "Wait until process ${BACK_PID} is finished..."
			showMessage=false
		fi
		sleep 1
	done
}

mergeAllPDFs() {
	echo "Merge all PDF pages."
	param="$(echo ${@} ${outputDir}/book.pdf)"
	pdfunite $param
}

main() {

	echo "This script will convert each html file to pdf by chromium with the following line for each html."
	echo "'chromium --headless=new --user-data-dir=<chromium-data-dir> --print-to-pdf=<name>.pdf ./<name>.html'"

	if [ ! -d $outputDir ]; then
		mkdir $outputDir
	fi

	allPDFsArr=()

	for file in `find . -type f -regex '\.\/[0-9]*.html' | sort -n`; do
		fnameHtml=$(basename "$file")
		fnamePdf=${outputDir}/${fnameHtml%.*}.pdf
		allPDFsArr+="${fnamePdf} "
		if [ -e $fnamePdf ]; then
			echo "$fnamePdf existiert bereit und wird ignoriert."
		else
			convertHtmlToPdf $fnameHtml $fnamePdf
		fi
	done

	mergeAllPDFs ${allPDFsArr[@]}
}

main