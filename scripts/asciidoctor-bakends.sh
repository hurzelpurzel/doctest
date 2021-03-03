#!/bin/bash
# see https://gist.github.com/leif81/fdc55d94fea078ea3572

# Setup the environment
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="$BASE_DIR/output"
command -v ruby >/dev/null && RUBY_Installed=true || RUBY_Installed=false
if [ -z "$BUILD_NUMBER" ] ; then BUILD_NUMBER=0 ; fi

# Comment out the toolchains you don't wish to use.
TOOLCHAINS=$TOOLCHAINS" asciidoctorDocx"
TOOLCHAINS=$TOOLCHAINS" asciidoctorPDF"
TOOLCHAINS=$TOOLCHAINS" asciidoctorFopub"
TOOLCHAINS=$TOOLCHAINS" asciidoctorWkhtmlpdf"


function Get_Clone {
    # Github clone the asciidoctor-pdf project
    cd $BASE_DIR/..
    git clone https://github.com/opendevise/asciidoctor-pdf.git asciidoctor-pdf
    cd asciidoctor-pdf
    bundle install
    cd $BASE_DIR
}

function No_Ruby {
    echo We need ruby installed to proceed
    exit
}

function Help {
    echo -e "Usage is \"$0 *.adoc\" to generate single PDF\nOr no input to generate from all *.adoc"
    exit
}

function asciidoctorPDF {
    cd $3
    ruby $BASE_DIR/../asciidoctor-pdf/bin/asciidoctor-pdf $1
    mv $2.pdf $2-$BUILD_NUMBER.pdf
    rm $2.pdfmarks
    cd $BASE_DIR
}

function asciidoctorFopub {
    asciidoctor $1 -D $3 -b docbook5
    $BASE_DIR/../asciidoctor-fopub/fopub $3/$2.xml
    mv $3/$2.pdf $3/$2-$BUILD_NUMBER.pdf
}

function asciidoctorWkhtmlpdf {
    asciidoctor -a data-uri $1 -D $3
    /c/Program\ Files/wkhtmltopdf/bin/wkhtmltopdf.exe $3/$2.html $3/$2-$BUILD_NUMBER.pdf
}

function asciidoctorDocx {
    asciidoctor $1 -D $3 -b docbook5
    pandoc --from=docbook $3/$2.xml -o $3/$2.docx
    mv $3/$2.docx $3/$2-$BUILD_NUMBER.docx
}

function makePDF {
    echo Generating PDF from $(basename $1)

    # Short filename without file extension
    DOC_NAME=`basename ${1%.*}`

    for toolchain in $TOOLCHAINS; do

        echo $toolchain
        mkdir -p $OUTPUT_DIR/$toolchain
        $toolchain $1 $DOC_NAME $OUTPUT_DIR/$toolchain

    done;
}

#### MAIN START
if [[ "$RUBY_Installed" == false ]] ; then No_Ruby ; fi
if [ ! -d $BASE_DIR/../asciidoctor-pdf ] ; then Get_Clone ; fi

# Update asciidoctor-pdf if available
echo Checking for asciidoctor-pdf updates
cd $BASE_DIR/../asciidoctor-pdf && git pull
cd $BASE_DIR

# Ruby and asciidoctor-pdf are present, lets make a PDF!
echo 
# sed txt and adoc files for BUILD_NUMBER
for input in $(grep -l {documentversion} $(find $BASE_DIR -name "*.txt" -o -name "*.adoc")) ; do
	cp $input "$input.bak"
	sed -i 's/{documentversion}/'$BUILD_NUMBER'/g' $input
done

rm -rf $OUTPUT_DIR

# What are we doing...
case "$1" in
    -*|--*)
        # There are no real arguments, so show the help instead
        Help
        ;;
    *.adoc)
        # Use the input *.adoc to generate single PDF
        makePDF $BASE_DIR/$1
        ;;
    "")
        # Generate PDF from all *.adoc
        for filename in $BASE_DIR/*.adoc ; do
            makePDF $filename
        done
        ;;
    *)
        # Something has completely gone wrong, show the help
        Help
        ;;
esac

echo Done PDF Generation
echo 

# Move bak files
for rename in *.bak ; do mv -f "$rename" "$(basename $rename .bak)" ; done

echo Done
#### END MAIN