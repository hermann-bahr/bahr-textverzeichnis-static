<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    version="3.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/osd-container.xsl"/>
    <xsl:import href="./partials/tei-facsimile.xsl"/>
    <xsl:import href="./partials/person.xsl"/>
    <xsl:import href="./partials/place.xsl"/>
    <xsl:import href="./partials/org.xsl"/>
    <xsl:variable name="prev">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"
        />
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"
        />
    </xsl:variable>
    <xsl:variable name="teiSource">
        <xsl:value-of select="data(tei:TEI/@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select="descendant::tei:titleStmt/tei:title[@level = 'a'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container-fluid">
                        <div class="card" data-index="true">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-2">
                                        <xsl:if test="ends-with($prev, '.html')">
                                            <h1>
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$prev"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-left" title="prev"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                    <div class="col-md-8">
                                        <h1 align="center">
                                            <xsl:value-of select="$doc_title"/>
                                        </h1>
                                        <h3 align="center">
                                            <a href="{$teiSource}">
                                                <i class="fas fa-code" title="zeige TEI"/>
                                            </a>
                                        </h3>
                                    </div>
                                    <div class="col-md-2" style="text-align:right">
                                        <xsl:if test="ends-with($next, '.html')">
                                            <h1>
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$next"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-right" title="next"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <xsl:apply-templates select=".//tei:body"/>
                            </div>
                            <div class="card-footer">
                                <p style="text-align:center;">
                                    <!-- Hier personenindex her -->
                                </p>
                            </div>
                        </div>
                    </div>
                    <xsl:for-each select=".//tei:back//tei:person[@xml:id]">
                        <xsl:variable name="xmlId">
                            <xsl:value-of select="data(./@xml:id)"/>
                        </xsl:variable>
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true"
                            id="{$xmlId}">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of
                                                select="normalize-space(string-join(.//tei:persName[1]//text()))"/>
                                            <xsl:text> </xsl:text>
                                            <a href="{concat($xmlId, '.html')}">
                                                <i class="fas fa-external-link-alt"/>
                                            </a>
                                        </h5>
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="person_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary"
                                            data-dismiss="modal">Schlie??en</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:biblStruct">
        <xsl:element name="h2">
            <xsl:value-of select="tei:note[@type = 'bibliographical-statement']"/>
        </xsl:element>
        <p/>
        <table class="table table-striped">
            <tbody>
                <xsl:apply-templates select="child::tei:note[not(@type = 'bibliographical-statement')]"/>
                <xsl:if test="tei:monogr/tei:title[@level='j' and @ref] or tei:monogr/tei:title[@level='m' and @ref]">
                    <tr>
                    <th/>
                    <td>
                <xsl:choose>
                    <xsl:when test="tei:monogr/tei:title[@level='j' and @ref]">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('toc_', tei:monogr/tei:title[@level='j' and @ref]/@ref, '.html')"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:monogr/tei:title[@level='j' and @ref]"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="tei:monogr/tei:title[@level='m' and @ref]">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat(tei:monogr/tei:title[@level='m' and @ref]/@ref, '.html')"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:monogr/tei:title[@level='m' and @ref]"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                    </td>
                    </tr>
                </xsl:if>
                <xsl:apply-templates select="child::tei:noteGrp[@type = 'keywords']"/> 
                <xsl:apply-templates select="child::tei:ref[@type = 'URL']"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:note[not(child::tei:bibl)]">
        <tr>
            <th>
                <xsl:choose>
                    <xsl:when test="@type = 'incipit' and ends-with(normalize-space(.), '|')">
                        <xsl:text>Volltext</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'incipit'">
                        <xsl:text>Textanfang</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'summary'">
                        <xsl:text>Zusammenfassung</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Allgemein</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </th>
            <td>
                <xsl:choose>
                    <xsl:when test="@type">
                        <i>
                            <xsl:apply-templates/>
                        </i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:note[child::tei:bibl]">
        <tr>
            <th>
                <xsl:choose>
                    <xsl:when test="@type = 'periodica'">
                        <xsl:text>Weitere Drucke (Periodika)</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'monographies'">
                        <xsl:text>Weitere Drucke (B??cher)</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'translations'">
                        <xsl:text>??bersetzungen</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'review-of'">
                        <xsl:text>Rezensiert</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'reviews'">
                        <xsl:text>Besprochen in</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Allgemein</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </th>
            <td>
                <xsl:apply-templates select="child::tei:bibl"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:noteGrp">
        <tr>
            <th>Schlagw??rter</th>
            <td>
            <xsl:for-each select="tei:note">
                <xsl:value-of select="."/>
                <xsl:if test="not(position()=last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:note/tei:bibl">
        <xsl:choose>
            <xsl:when test=".[normalize-space()]">
                <p>
                    <xsl:choose>
                        <xsl:when test="child::tei:title[@level = 'a'] and child::tei:author">
                        <xsl:value-of select="tei:author" separator=", "/>
                        <xsl:text>: </xsl:text>
                        <xsl:choose>
                            <xsl:when test="child::tei:title[@level = 'a']/@ref">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat(child::tei:title[@level = 'a']/@ref, '.html')"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>. In: </xsl:text>
                        </xsl:when>
                        <xsl:when test="child::tei:title[@level = 'a']">
                            <xsl:text>Als ??</xsl:text>
                            <xsl:choose>
                                <xsl:when test="child::tei:title[@level = 'a']/@ref">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat(child::tei:title[@level = 'a']/@ref, '.html')"/>
                                        </xsl:attribute>
                                        <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>?? in: </xsl:text>
                        </xsl:when>
                        <xsl:when test="child::tei:author">
                            <xsl:value-of select="tei:author" separator=", "/>
                            <xsl:text>: </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="child::tei:title[@level = 'm']">
                        <xsl:choose>
                            <xsl:when test="child::tei:title[@level = 'm']/@ref">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat(child::tei:title[@level = 'm']/@ref, '.html')"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="child::tei:title[@level = 'm']"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="child::tei:title[@level = 'm']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="child::tei:title[@level = 'j']">
                        <xsl:choose>
                            <xsl:when test="child::tei:title[@level = 'j']/@ref">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('toc_', child::tei:title[@level = 'j']/@ref, '.html')"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="child::tei:title[@level = 'j']"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="child::tei:title[@level = 'j']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="child::tei:biblScope[@unit = 'jg']">
                        <xsl:text>, Jg. </xsl:text>
                        <xsl:value-of select="child::tei:biblScope[@unit = 'jg']"/>
                    </xsl:if>
                    <xsl:if test="child::tei:biblScope[@unit = 'volume']">
                        <xsl:text>, Band </xsl:text>
                        <xsl:value-of select="child::tei:biblScope[@unit = 'volume']"/>
                    </xsl:if>
                    <xsl:if test="child::tei:date[@type = 'year']">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="child::tei:date[@type = 'year']"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="child::tei:biblScope[@unit = 'issue']">
                        <xsl:text> #</xsl:text>
                        <xsl:value-of select="child::tei:biblScope[@unit = 'issue']"/>
                    </xsl:if>
                    <xsl:if test="child::tei:biblScope[@unit = 'page']">
                        <xsl:text>, S. </xsl:text>
                        <xsl:for-each select="child::tei:biblScope[@unit = 'page']">
                            <xsl:value-of select="."/>
                            <xsl:choose>
                                <xsl:when test="position()=last()-1">
                                    <xsl:text> und </xsl:text>
                                </xsl:when>
                                <xsl:when test="not(position()=last())">
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:apply-templates select="text()"/>
                    <xsl:if test="child::tei:date[@when]">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="child::tei:date[@when]"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="child::tei:note"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates mode="nochNichtFormatiert"/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="nochNichtFormatiert" match="tei:*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="tei:note[not(parent::tei:biblStruct)]">
        <xsl:text> [</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>] </xsl:text>
    </xsl:template>
    <xsl:template match="tei:ref[@type = 'URL']">
        <tr>
            <th>
                <xsl:if test="not(preceding-sibling::tei:ref[@type = 'URL'])">
                    <xsl:text>Link</xsl:text>
                </xsl:if>
            </th>
            <td>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="contains(., '.anno')">
                            <xsl:text>ANNO</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>TEXT</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:title[@level = 'a' or @level = 'm']/text()">
        <span style="text-style:italic">
            <xsl:value-of select="normalize-space(.)"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:title[@level = 'j']/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="tei:supplied">
        <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
    </xsl:template>
</xsl:stylesheet>
