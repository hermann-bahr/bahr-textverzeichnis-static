<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:mam="whatever"
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
    <xsl:param name="relevant-uris" select="document('./utils/list-of-relevant-uris.xml')"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:variable name="prev">
        <xsl:choose>
            <xsl:when test="ends-with(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml')">
                <xsl:value-of
                    select="concat(replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', ''), '.html')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(data(tei:TEI/@prev), '.html')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:choose>
            <xsl:when test="ends-with(tokenize(data(tei:TEI/@next), '/')[last()], '.xml')">
                <xsl:value-of
                    select="concat(replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', ''), '.html')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(data(tei:TEI/@next), '.html')"/>
            </xsl:otherwise>
        </xsl:choose>
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
                            <xsl:if test="descendant::tei:back/tei:listPerson/tei:person[@xml:id][1]">
                                
                            <div class="card-footer">
                                <h3>Erwähnte Personen</h3>
                                <ul>
                                    <xsl:for-each select=".//tei:back/tei:listPerson/tei:person[@xml:id]">
                                        <xsl:sort select="child::tei:persName[1]/tei:surname[1]"/>
                                        <li>
                                            <xsl:call-template name="mam:personenAnzeige">
                                                <xsl:with-param name="current" select="."/>
                                            </xsl:call-template>                                      
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </div>
                            </xsl:if>
                        </div>
                    </div>
                    
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
        <table class="table table-striped">
            <tbody>
                <xsl:if test="tei:analytic">
                    <xsl:apply-templates select="tei:analytic" mode="table"/>
                </xsl:if>
                <xsl:if test="tei:monogr">
                    <xsl:apply-templates select="tei:monogr" mode="table"/>
                </xsl:if>
                <xsl:if test="tei:series">
                    <xsl:apply-templates select="tei:series" mode="table"/>
                </xsl:if>
                <xsl:apply-templates select="tei:note[@type = 'toc']"/>
                <xsl:apply-templates
                    select="child::tei:note[not(@type = 'bibliographical-statement') and not(@type = 'toc')]"/>
                <xsl:apply-templates select="child::tei:ref[@type = 'URL']"/>
                <xsl:apply-templates select="child::tei:ref[@type = 'abdrucke']"/>
                <xsl:apply-templates select="child::tei:noteGrp[@type = 'keywords']"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:note[not(child::tei:bibl) and not(@type = 'toc')]">
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
    <xsl:template match="tei:biblStruct/tei:note[@type = 'toc']">
        <tr>
            <th>Inhaltsverzeichnis</th>
        </tr>
        <xsl:for-each select="tei:desc">
            <xsl:variable name="corresp" select="replace(@corresp, '#', '')"/>
            <tr>
                <td>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($corresp, '.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="@ana"/>
                    </xsl:element>
                </td>
                <td>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($corresp, '.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:note[child::tei:bibl[not(@type='obsolete')]]">
        <tr>
            <th>
                <xsl:choose>
                    <xsl:when test="@type = 'periodica'">
                        <xsl:text>Weitere Drucke (Periodika)</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'monographies'">
                        <xsl:text>Weitere Drucke (Bücher)</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'translations'">
                        <xsl:text>Übersetzungen</xsl:text>
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
                <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                <xsl:apply-templates select="child::tei:bibl[not(@type='obsolete')]"/>
                </ul>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:biblStruct/tei:noteGrp">
        <tr>
            <th>Schlagwörter</th>
            <td>
                <xsl:for-each select="tei:note">
                    <xsl:value-of select="."/>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:note/tei:bibl[not(@type='obsolete')]">
        <xsl:choose>
            <xsl:when test=".[normalize-space()]">
                <li>
                    <xsl:choose>
                        <xsl:when test="child::tei:title[@level = 'a'] and child::tei:author">
                            <xsl:value-of select="tei:author" separator=", "/>
                            <xsl:text>: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="child::tei:title[@level = 'a']/@ref">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of
                                                select="concat(child::tei:title[@level = 'a']/@ref, '.html')"
                                            />
                                        </xsl:attribute>
                                        <xsl:apply-templates select="child::tei:title[@level = 'a']"
                                        />
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>. In: </xsl:text>
                        </xsl:when>
                        <xsl:when test="child::tei:title[@level = 'a']">
                            <xsl:text>Als »</xsl:text>
                            <xsl:choose>
                                <xsl:when test="child::tei:title[@level = 'a']/@ref">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of
                                                select="concat(child::tei:title[@level = 'a']/@ref, '.html')"
                                            />
                                        </xsl:attribute>
                                        <xsl:apply-templates select="child::tei:title[@level = 'a']"
                                        />
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="child::tei:title[@level = 'a']"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>« in: </xsl:text>
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
                                        <xsl:value-of
                                            select="concat(child::tei:title[@level = 'm']/@ref, '.html')"
                                        />
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
                                        <xsl:value-of
                                            select="concat('toc_', child::tei:title[@level = 'j']/@ref, '.html')"
                                        />
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
                                <xsl:when test="position() = last() - 1">
                                    <xsl:text> und </xsl:text>
                                </xsl:when>
                                <xsl:when test="not(position() = last())">
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
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates mode="nochNichtFormatiert"/>
                </li>
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
    <xsl:template match="tei:ref[@type = 'abdrucke']">
        <xsl:for-each
            select="distinct-values(descendant::tei:ptr[@type = 'textref' and @target != ancestor::tei:TEI/@xml:id]/@target)">
            <tr>
                <th>
                    <xsl:if test="position() = 1">
                        <xsl:text>Alternative Drucke</xsl:text>
                    </xsl:if>
                </th>
                <td>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat(., '.html')"/>
                        </xsl:attribute>
                        <xsl:value-of
                            select="document(concat('https://raw.githubusercontent.com/hermann-bahr/bahr-textverzeichnis-data/main/data/editions/', ., '.xml'))/tei:TEI/tei:text[1]/tei:body[1]/tei:div[1]/tei:biblStruct[1]/tei:note[@type = 'bibliographical-statement']"
                        />
                    </xsl:element>
                </td>
            </tr>
        </xsl:for-each>
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
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="tei:analytic" mode="table">
        <xsl:if test="tei:author">
            <tr>
                <th>Verfasser:in</th>
                <td>
                    <xsl:choose>
                        <xsl:when test="tei:author[2]">
                            <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                                <xsl:for-each select="tei:author">
                                    <li>
                                    <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:author"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
        <tr>
            <th>Titel</th>
            <td>
                <xsl:value-of select="tei:title[@level = 'a']"/>
            </td>
        </tr>
        <xsl:if test="tei:editor">
            <tr>
                <th>Herausgeber:in</th>
                <td>
                    <xsl:for-each select="tei:editor">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position() = last())">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:monogr" mode="table">
        <xsl:if test="tei:author and preceding-sibling::tei:analytic">
            <tr>
                <th>Gesamtverfasser:in</th>
                <td>
                    <xsl:choose>
                        <xsl:when test="tei:author[2]">
                            <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                                <xsl:for-each select="tei:author">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:author"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="tei:author and not(preceding-sibling::tei:analytic)">
            <tr>
                <th>Verfasser:in</th>
                <td>
                    <xsl:choose>
                        <xsl:when test="tei:author[2]">
                            <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                                <xsl:for-each select="tei:author">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:author"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
        <tr>
            <th>
                <xsl:choose>
                    <xsl:when test="tei:title[@level = 'm'] and preceding-sibling::tei:analytic">
                        <xsl:text>Gesamttitel</xsl:text>
                    </xsl:when>
                    <xsl:when test="tei:title[@level = 'm']">
                        <xsl:text>Titel</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Periodikum</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </th>
            <td>
                <xsl:choose>
                    <xsl:when test="tei:title[@level = 'j' and @ref]">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('toc_', tei:title[@level = 'j' and @ref]/@ref, '.html')"
                                />
                            </xsl:attribute>
                            <xsl:value-of select="tei:title[@level = 'j' and @ref]"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="tei:title[@level = 'm' and @ref]">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat(tei:title[@level = 'm' and @ref]/@ref, '.html')"
                                />
                            </xsl:attribute>
                            <xsl:value-of select="tei:title[@level = 'm' and @ref]"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
            </td>
        </tr>
        <xsl:if test="tei:editor">
            <tr>
                <th>Gesamtherausgeber:in</th>
                <td>
                    <xsl:choose>
                        <xsl:when test="tei:editor[2]">
                            <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                                <xsl:for-each select="tei:editor">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:editor"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="tei:imprint">
            <tr>
                <th>Erschienen</th>
                <td>
                    <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                    <xsl:if test="tei:imprint/tei:pubPlace">
                        <li><xsl:value-of select="tei:imprint/tei:pubPlace" separator=", "/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:publisher">
                        <li><xsl:value-of select="tei:imprint/tei:publisher" separator=", "/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:date">
                        <li><xsl:value-of select="tei:imprint/tei:date"/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:biblScope[@unit = 'jg']">
                        <li><xsl:value-of
                            select="concat('Jahrgang ', tei:imprint/tei:biblScope[@unit = 'jg'])"/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:biblScope[@unit = 'volume']">
                        <li><xsl:value-of
                            select="concat('Band ', tei:imprint/tei:biblScope[@unit = 'volume'])"/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:biblScope[@unit = 'issue']">
                        <li><xsl:value-of
                            select="concat('Nummer ', tei:imprint/tei:biblScope[@unit = 'issue'])"/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:biblScope[@unit = 'page']">
                        <li><xsl:value-of
                            select="concat('Seite ', tei:imprint/tei:biblScope[@unit = 'page'])"/></li>
                    </xsl:if>
                    <xsl:if test="tei:imprint/tei:extent">
                        <li><xsl:value-of select="tei:imprint/tei:extent"/></li>
                    </xsl:if>
                    </ul>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:series" mode="table">
        <xsl:if test="tei:editor">
            <tr>
                <th>Reihenherausgeber:in</th>
                <td>
                    <xsl:choose>
                        <xsl:when test="tei:editor[2]">
                            <ul style="list-style-type: none; padding-left: 0; margin-left: 0;">
                                <xsl:for-each select="tei:editor">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:editor"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
        <tr>
            <th>Reihe</th>
            <td>
                <xsl:value-of select="tei:title[@level = 's']"/>
                <xsl:if test="tei:biblScope[@unit = 'volume']">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="tei:biblScope[@unit = 'volume']"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template name="mam:personenAnzeige">
        <xsl:param name="current" as="node()"></xsl:param>
        <xsl:variable name="lemma-name" select="$current/tei:persName[(position() = 1)]" as="node()"/>
        <xsl:variable name="namensformen" as="node()">
            <xsl:element name="listPerson">
                <xsl:for-each select="$current/descendant::tei:persName[not(position() = 1) and not(@type='legacy-name-merge')]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <b><a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($current/@xml:id, '.html')"/>
            </xsl:attribute>
            <xsl:choose>
            <xsl:when test="$lemma-name/tei:forename and $lemma-name/tei:surname">
                <xsl:value-of select="concat($lemma-name/tei:forename[1], ' ', $lemma-name/tei:surname[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lemma-name/tei:forename"/>   
                <xsl:value-of select="$lemma-name/tei:surname"/>
            </xsl:otherwise>
        </xsl:choose></a></b>
        <xsl:choose>
            <xsl:when test="$namensformen/descendant::tei:persName[1]">
                <xsl:text>, </xsl:text>
                <xsl:for-each select="$namensformen/descendant::tei:persName">
                    <xsl:choose>
                        <xsl:when test="descendant::*">
                        <xsl:text> </xsl:text>
                            <!-- den Fall dürfte es eh nicht geben, aber löschen braucht man auch nicht -->
                            <xsl:choose>
                                <xsl:when test="./tei:forename/text() and ./tei:surname/text()">
                                    <xsl:value-of
                                        select="concat(./tei:forename/text(), ' ', ./tei:surname/text())"
                                    />
                                </xsl:when>
                                <xsl:when test="./tei:forename/text()">
                                    <xsl:value-of select="./tei:forename/text()"/>
                                </xsl:when>
                                <xsl:when test="./tei:surname/text()">
                                    <xsl:value-of select="./tei:surname/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                        <xsl:text> </xsl:text>
                            <xsl:choose>
                                <xsl:when
                                    test="@type = 'person_geburtsname_vorname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                    <xsl:text>geboren </xsl:text>
                                    <xsl:value-of
                                        select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'][1])"
                                    />
                                </xsl:when>
                                <xsl:when
                                    test="@type = 'person_geburtsname_nachname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname'][1]"/>
                                <xsl:when test="@type = 'person_geburtsname_nachname'">
                                    <xsl:text>geboren </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_geburtsname_vorname'">
                                    <xsl:text>geboren </xsl:text>
                                    <xsl:value-of select="concat(., ' ', $lemma-name//tei:surname)"/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_adoptierter-nachname'">
                                    <xsl:text>Nachname durch Adoption </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_variante-nachname_vorname'">
                                    <xsl:text>Namensvariante </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_namensvariante'">
                                    <xsl:text>Namensvariante </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_rufname'">
                                    <xsl:text>Rufname </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_pseudonym'">
                                    <xsl:text>Pseudonym </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_ehename'">
                                    <xsl:text>Ehename </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_geschieden'">
                                    <xsl:text>geschieden </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_verwitwet'">
                                    <xsl:text>verwitwet </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:if test="$current/tei:birth or $current/tei:death">
            <xsl:value-of select="concat('(', mam:lebensdaten($current[1]), ')')"/>
        </xsl:if>
        
        <xsl:if test="$current//tei:occupation">
            <xsl:variable name="entity" select="$current"/>
            <xsl:text>, </xsl:text>
                <xsl:if test="$entity/descendant::tei:occupation">
                    <i>
                        <xsl:for-each select="$entity/descendant::tei:occupation">
                            <xsl:variable name="beruf" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="contains(., '&gt;&gt;')">
                                        <xsl:value-of select="tokenize(., '&gt;&gt;')[last()]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$entity/tei:sex/@value = 'male'">
                                    <xsl:value-of select="tokenize($beruf, '/')[1]"/>
                                </xsl:when>
                                <xsl:when test="$entity/tei:sex/@value = 'female'">
                                    <xsl:value-of select="tokenize($beruf, '/')[2]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$beruf"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="not(position() = last())">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </i>
                </xsl:if>
        </xsl:if>
        <div id="mentions">
            <xsl:if test="key('only-relevant-uris', $current/tei:idno/@subtype, $relevant-uris)[1]">
                <p class="buttonreihe">
                    <xsl:variable name="idnos-of-current" as="node()">
                        <xsl:element name="nodeset_person">
                            <xsl:for-each select="$current/tei:idno">
                                <xsl:copy-of select="."/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="mam:idnosToLinks">
                        <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                    </xsl:call-template>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:function name="mam:lebensdaten">
        <xsl:param name="entity" as="node()"/>
        <xsl:variable name="geburtsort" as="xs:string?" select="$entity/tei:birth[1]/tei:settlement[1]/tei:placeName[1]"/>
        <xsl:variable name="geburtsdatum" as="xs:string?" select="mam:normalize-date($entity/tei:birth[1]/tei:date[1]/text())[1]"/>
        <xsl:variable name="todessort" as="xs:string?" select="$entity/tei:death[1]/tei:settlement[1]/tei:placeName[1]"/>
        <xsl:variable name="todesdatum" as="xs:string?" select="mam:normalize-date($entity/tei:death[1]/tei:date[1]/text())[1]"/>
        <xsl:variable name="geburtsstring" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$geburtsort != ''">
                    <xsl:value-of select="concat($geburtsdatum, ' ', $geburtsort)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$geburtsdatum"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="todesstring" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$todessort != ''">
                    <xsl:value-of select="concat($todesdatum, ' ', $todessort)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$todesdatum"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($geburtsstring) != '' and normalize-space($todesstring) != ''">
                <xsl:value-of select="concat($geburtsstring, ' – ', $todesstring)"/>
            </xsl:when>
            <xsl:when test="normalize-space($geburtsstring) != ''">
                <xsl:value-of select="concat('* ', $geburtsstring)"/>
            </xsl:when>
            <xsl:when test="normalize-space($todesstring) !=''">
                <xsl:value-of select="concat('† ', $todesstring)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:normalize-date">
        <xsl:param name="date-string-mit-spitze" as="xs:string?"/>
        <xsl:variable name="date-string" as="xs:string">
            <xsl:choose>
                <xsl:when test="contains($date-string-mit-spitze, '&lt;')">
                    <xsl:value-of select="substring-before($date-string-mit-spitze, '&lt;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date-string-mit-spitze"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:analyze-string select="$date-string" regex="^(\d{{4}})-(\d{{2}})-(\d{{2}})$">
            <xsl:matching-substring>
                <xsl:variable name="year" select="xs:integer(regex-group(1))"/>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(2), '0')">
                            <xsl:value-of select="substring(regex-group(2), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(3), '0')">
                            <xsl:value-of select="substring(regex-group(3), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($day, '. ', $month, '. ', $year)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="^(\d{{2}}).(\d{{2}}).(\d{{4}})$">
                    <xsl:matching-substring>
                        <xsl:variable name="year" select="xs:integer(regex-group(3))"/>
                        <xsl:variable name="month">
                            <xsl:choose>
                                <xsl:when test="starts-with(regex-group(2), '0')">
                                    <xsl:value-of select="substring(regex-group(2), 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="regex-group(2)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="day">
                            <xsl:choose>
                                <xsl:when test="starts-with(regex-group(1), '0')">
                                    <xsl:value-of select="substring(regex-group(1), 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="concat($day, '. ', $month, '. ', $year)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    
    <xsl:template name="mam:idnosToLinks">
        <xsl:param name="idnos-of-current" as="node()"/>
        <xsl:for-each select="$relevant-uris/descendant::item[not(@type)]">
            <xsl:variable name="abbr" select="child::abbr"/>
            <xsl:variable name="uri-color" select="child::color" as="xs:string?"/>
            <xsl:if test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]">
                <xsl:variable name="current-idno" as="node()"
                    select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]"/>
                <xsl:element name="a">
                    <xsl:choose>
                        <xsl:when test="$abbr = 'wikidata'">
                            <xsl:variable name="wikipediaVSdata"
                                select="mam:wikidata2wikipedia($current-idno)" as="xs:string"/>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$wikipediaVSdata"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$abbr = 'pmb'">
                            <xsl:variable name="pmb-entitytype" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="tokenize($idnos-of-current/name(), '_')[2] = 'org'">
                                        <xsl:text>institution</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize($idnos-of-current/name(), '_')[2]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="pmb-number" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="ends-with($current-idno, '/')">
                                        <xsl:value-of
                                            select="tokenize($current-idno, '/')[last() - 1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize($current-idno, '/')[last()]"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/', $pmb-entitytype, '/', $pmb-number, '/detail')"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$current-idno"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="span">
                        <xsl:attribute name="class">
                            <xsl:text>badge rounded-pill</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>background-color: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$uri-color">
                                    <xsl:value-of select="$uri-color"/>
                                    <xsl:text>;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>black; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> color: white; margin-top: 4px;</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$abbr = 'wikidata'">
                                <xsl:variable name="wikipediaVSdata"
                                    select="mam:wikidata2wikipedia($current-idno)" as="xs:string"/>
                                <xsl:variable name="lang-code"
                                    select="substring(substring-after($wikipediaVSdata, 'https://'), 1, 2)"/>
                                <xsl:choose>
                                    <xsl:when test="contains($wikipediaVSdata, 'wikipedia')">
                                        <xsl:choose>
                                            <xsl:when test="$lang-code = 'de'"/>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$lang-code"/>
                                                <xsl:text>:</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>Wikipedia</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Wikidata</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./caption"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$relevant-uris/descendant::item[@type = 'print-online']">
            <xsl:variable name="abbr" select="child::abbr"/>
            <xsl:if test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]">
                <xsl:variable name="current-idno" as="node()"
                    select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]"/>
                <xsl:variable name="uri-color" select="child::color" as="xs:string?"/>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="child::url"/>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="span">
                        <xsl:attribute name="class">
                            <xsl:text>badge rounded-pill</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>background-color: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$uri-color">
                                    <xsl:value-of select="$uri-color"/>
                                    <xsl:text>; </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>black; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> color: white</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="./caption"/>
                    </xsl:element>
                </xsl:element>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:function name="mam:wikidata2wikipedia">
        <xsl:param name="wikidata-entry" as="xs:string"/>
        <xsl:variable name="wikidata-entity">
            <xsl:choose>
                <xsl:when test="starts-with($wikidata-entry, 'Q')">
                    <xsl:value-of select="normalize-space($wikidata-entry)"/>
                </xsl:when>
                <xsl:when test="starts-with($wikidata-entry, 'https://www.wikidata.org/entity/')">
                    <xsl:value-of
                        select="normalize-space(substring-after($wikidata-entry, 'https://www.wikidata.org/entity/'))"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="normalize-space(concat('Q', tokenize($wikidata-entry, 'Q')[last()]))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="get-string" as="xs:string"> 
            <xsl:value-of
                select="concat('https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;props=sitelinks&amp;ids=', $wikidata-entity,'')"
            />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="document($get-string)/api[descendant::sitelink]/@success = '1'">
                <xsl:variable name="sitelinks"
                    select="document($get-string)/descendant::sitelinks[1]" as="node()"/>
                <xsl:choose>
                    <xsl:when test="$sitelinks/sitelink[@site = 'dewiki']">
                        <xsl:value-of
                            select="concat('https://de.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'dewiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'enwiki']">
                        <xsl:value-of
                            select="concat('https://en.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'enwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'frwiki']">
                        <xsl:value-of
                            select="concat('https://fr.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'frwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'itwiki']">
                        <xsl:value-of
                            select="concat('https://it.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'frwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'eswiki']">
                        <xsl:value-of
                            select="concat('https://es.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'eswiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="lang-code"
                            select="substring($sitelinks/sitelink[not(@site='commonswiki')][1]/@site, 1, 2)"/>
                        <xsl:value-of
                            select="concat('https://', $lang-code, '.wikipedia.org/wiki/', $sitelinks/sitelink[1]/@title)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$wikidata-entry"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
