<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Selbstständig erschienene Werke'"/>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>

            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>

                    <div class="container-fluid">
                        <div class="card">
                            <div class="card-header">
                                <h1>Selbstständig erschienene Werke</h1>
                            </div>
                            <div class="card-body">
                                <div class="w-100 text-center">
                                    <div class="spinner-grow table-loader" role="status">
                                        <span class="sr-only">Wird geladen…</span>
                                    </div>
                                </div>
                                <table class="table table-striped display" id="tocTable"
                                    style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Jahr</th>
                                            <th scope="col">Titel</th>
                                            <th scope="col">Klassifikation</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each
                                            select="document('../data/indices/listBibliografie.xml')/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:list[1]/tei:item">
                                            <xsl:sort select="tei:date/@when"/>
                                            <xsl:variable name="corresp"
                                                select="@corresp"/>
                                            <tr>
                                                <td>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat($corresp, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="tei:date"/>
                                                  </a>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of
                                                                select="concat($corresp, '.html')"
                                                            />
                                                        </xsl:attribute>
                                                        <xsl:value-of
                                                            select="tei:title"/>
                                                    </a>
                                                </td>
                                                <td>
                                                        <xsl:choose>
                                                            <xsl:when test="tei:label/@type='kritische-schrift'">
                                                                <xsl:text>Kritische Schriften</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="tei:label/@type='prosa'">
                                                                <xsl:text>Literarische Prosa</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="tei:label/@type='theater-schrift'">
                                                                <xsl:text>Schriften zum Theater</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="tei:label/@type='theaterstueck'">
                                                                <xsl:text>Theaterstücke</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="tei:label/@type='tagebuch'">
                                                                <xsl:text>Tagebuch</xsl:text>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:text>XXXX</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    
                                                        
                                                    
                                                </td>

                                            </tr>

                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <xsl:call-template name="html_footer"/>
                    <script type="text/javascript" src="https://cdn.datatables.net/v/bs4/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.js"/>
                    <script type="text/javascript" src="js/dt.js"/>
                    <script>
                        $(document).ready(function () {
                        createDataTable('tocTable')
                        });
                    </script>
                    
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="tei:p">
        <p id="{generate-id()}"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="tei:list">
        <ul id="{generate-id()}">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="tei:item">
        <li id="{generate-id()}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="starts-with(data(@target), 'http')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
