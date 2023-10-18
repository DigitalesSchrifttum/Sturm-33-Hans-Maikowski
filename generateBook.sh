#!/bin/bash

convertHtmlToPdf() {
	sourceName=$1
	targetName=$2
	echo "Start converting of $sourceName."
	params="--headless=new --print-to-pdf=${targetName} ./${sourceName}"
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
	param="$(echo ${@} book.pdf)"
	pdfunite $param
}

main() {

	echo "This script will convert each html file to pdf by chromium with the following line for each html."
	echo "'chromium --headless=new --disable-gpu --print-to-pdf=<name>.pdf ./<name>.html'"

	allPDFsArr=()

	for file in `find . -type f -regex '\.\/[0-9]*.html' | sort -n`; do
		fnameHtml=$(basename "$file")
		fnamePdf=${fnameHtml%.*}.pdf
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