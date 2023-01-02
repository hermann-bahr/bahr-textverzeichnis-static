<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output media-type="text" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/params.xsl"/>
    <xsl:template match="/">#FORMAT: BEACON<xsl:text>&#xa;</xsl:text>#NAME:<xsl:value-of select="$project_title"/><xsl:for-each select=".//tei:person[.//tei:idno[@type='GND']/text()]"><xsl:text>&#xa;</xsl:text><xsl:value-of select=".//tei:idno[@type='GND']/text()"/>|<xsl:value-of select=".//tei:persName/text()"/>|<xsl:value-of select="$base_url"/>/<xsl:value-of select="data(@xml:id)"/>.html</xsl:for-each>
    </xsl:template>
</xsl:stylesheet>