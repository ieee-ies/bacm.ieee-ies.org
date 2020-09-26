#!/usr/bin/env bash
# Dominik Meyer (dominik.meyer@ieee.org)
# based on work done by Stamatis Karnouskos (karnouskos@ieee.org)
# Requirements: curl

FILE='chairs'
LANG='C'
LC_ALL='C'


#Local testing. Read local config if available
CONFIGFILE='config.conf'
if [ -f $CONFIGFILE ]
then
    source $CONFIGFILE
fi

#Make sure secret variables are set properly
if [ -z ${CHAIRSURL+x} ]
  then
    echo "Secret variable CHAIRSURL is unset. Exiting"
    exit 1
fi

# A TSV export from google spreadsheet
curl -s -L -R  $CHAIRSURL -o "$FILE.tsv"

if [ -s $FILE".tsv" ]; then

cat "../template_header.html" >$FILE".html"

echo "<div class=\"title\">Structure </div> <div class=\"subcont\"> " >> $FILE".html"
echo "<h2>Current Chairs of the TC</h2>" >> $FILE".html"

tail -n +4 $FILE".tsv" \
| awk 'BEGIN { FS = "\t" } ;
{
  print "<b>"$1"</b>"
  print "<div class=\"member\">"
  print "<div class=\"image\"><img align=\"left\""
  print "\tsrc=\"https://scholar.google.com/citations?view_op=medium_photo&user="$5"\" width=\"60\" height=\"60\" alt=\""$2"\">"
  print "</div>"
  print "<div class=\"member_data\"><p><b><a href=\"https://scholar.google.com/citations?user="$5"\">"$2"</a></b><br>"$3"<br><i>E-mail:</i><a href=\"mailto:"$4"\">"$4"</a></p></div>"
  print "</div>"
  print "<br><br>"
}
' >> $FILE".html"


cat "../template_footer.html" >>$FILE".html"
sed -i.bak -e 's/[[:blank:]]*$//' $FILE".html"
\rm -f $FILE".html.bak"

#cleanup
\rm -f $FILE".tsv"
\mv -f "$FILE.html" "../$FILE.html"

fi
exit 0
