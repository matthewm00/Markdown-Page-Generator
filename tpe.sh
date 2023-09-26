#!/bin/bash
# arg1 year, arg2 type

Year="$1"
Type="$2"

if [ "$#" -ne 2 ]; then
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <nascar_data> <error>Invalid number of arguments</error> </nascar_data>" > nascar_data.xml
    java net.sf.saxon.Transform -s:nascar_data.xml -xsl:generate_markdown.xsl -o:nascar_page.md
    exit
fi

#Genera los XML
echo "Loading data..."
curl http://api.sportradar.us/nascar-ot3/$Type/$Year/drivers/list.xml?api_key=${SPORTRADAR_API} > temp_drivers_list.xml 
curl http://api.sportradar.us/nascar-ot3/$Type/$Year/standings/drivers.xml?api_key=${SPORTRADAR_API} > temp_drivers_standings.xml

#Elimina los namespaces 
sed 's/xmlns=\"http:\/\/feed.elasticstats.com\/schema\/nascar\/series-v2.0.xsd\"//g' temp_drivers_list.xml > drivers_list.xml
sed 's/xmlns=\"http:\/\/feed.elasticstats.com\/schema\/nascar\/standings-v2.0.xsd\"//g' temp_drivers_standings.xml > drivers_standings.xml
rm temp_drivers_list.xml
rm temp_drivers_standings.xml


echo "Creating XML..."
java net.sf.saxon.Query -q:extract_nascar_data.xq Year=$Year Type=$Type > nascar_data.xml
java dom.Writer -v -n -s -f nascar_data.xml

echo "Creating Markdown..."
java net.sf.saxon.Transform -s:nascar_data.xml -xsl:generate_markdown.xsl -o:nascar_page.md

echo "Markdown created. Process complete"

