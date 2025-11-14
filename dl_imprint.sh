# bin/bash

REDMINE_ID=22527
IMPRINT_XML=./data/imprint.xml

# Ensure data directory exists
mkdir -p ./data

rm -f ${IMPRINT_XML}
echo '<?xml version="1.0" encoding="UTF-8"?>' > ${IMPRINT_XML}
echo "<root>" >> ${IMPRINT_XML}
curl "https://imprint.acdh.oeaw.ac.at/22527/?format=xhtml" >> ${IMPRINT_XML}
echo "</root>" >> ${IMPRINT_XML}