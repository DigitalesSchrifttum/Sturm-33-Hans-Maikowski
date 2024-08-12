#!/bin/bash

# check Chromium exists
if ! command -v chromium &> /dev/null; then
	echo "Please install chromium!"
	exit 1
fi

if [ -z "$1" ]; then
	echo "Please add the path dir to your output directory."
	exit 1
fi

if [ -z "$2" ]; then
	echo "Please add the path dir to your GERMAN chromium profile as parameter. It is used for hyphens!"
	exit 1
fi

outputDir="$1"
chromiumDataDir="$2"
printMode="$3"

convertHtmlToPdf() {
	sourceName=$1
	targetName=$2
	echo "Start converting of $sourceName."
	params="--headless=new --no-pdf-header-footer --user-data-dir=${chromiumDataDir} --print-to-pdf=${targetName} ./${sourceName}"
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

rotateSpecificPDFs() {
	pdfs=("13.pdf" "14.pdf" "61.pdf" "62.pdf" "78.pdf")
	for pdf in "${pdfs[@]}"; do
		inputPdf="${outputDir}/${pdf}"
		outputPdf="${outputDir}/rotated_${pdf}"
		if [[ $pdf =~ ^(13|61|78)\.pdf$ ]]; then
			pdftk "$inputPdf" cat 1-endleft output "$outputPdf"
		else
			pdftk "$inputPdf" cat 1-endright output "$outputPdf"
		fi
		mv "$outputPdf" "$inputPdf"
	done
}

main() {

	echo "This script will convert each html file to pdf by chromium with the following line for each html."
	echo "'chromium --headless=new --no-pdf-header-footer --user-data-dir=<chromium-data-dir> --print-to-pdf=<name>.pdf ./<name>.html'"

	if [ ! -d $outputDir ]; then
		mkdir $outputDir
	fi

	for file in `find . -type f -regex '\.\/[0-9]*.html' | sort -n`; do
		fnameHtml=$(basename "$file")
		if [ "$printMode" == "print" ]; then
			tempHtml="temp_${fnameHtml}"
			cp "$file" "$tempHtml"
			sed -i "s/jpg/png/g" "$tempHtml"
			fnamePdf=${outputDir}/${fnameHtml%.*}.pdf
			allPDFsArr+="${fnamePdf} "
			if [ -e $fnamePdf ]; then
				echo "$fnamePdf existiert bereit und wird ignoriert."
			else
				convertHtmlToPdf $tempHtml $fnamePdf
			fi
			rm "$tempHtml"
		else
			fnamePdf=${outputDir}/${fnameHtml%.*}.pdf
			allPDFsArr+="${fnamePdf} "
			if [ -e $fnamePdf ]; then
				echo "$fnamePdf existiert bereit und wird ignoriert."
			else
				convertHtmlToPdf $fnameHtml $fnamePdf
			fi
		fi
	done

	rotateSpecificPDFs

	mergeAllPDFs ${allPDFsArr[@]}
}

main