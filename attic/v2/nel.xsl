<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:skos="http://www.w3.org/2004/02/skos/core#"
               xmlns:sru="http://docs.oasis-open.org/ns/search-ws/sruResponse"
               exclude-result-prefixes="xsl pica rdf skos sru"
               >

  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <xsl:key name="notation"
           match="pica:record[string-length(pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a']) = 2]"
           use="pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a']"/>

  <xsl:variable name="unapi-template" select="'http://katalog.hab.de/service/unapi?format=picaxml&amp;id=opac-de-23:ppn:'"/>
  <xsl:variable name="fachgruppen" select="document('fachgruppen.rdf')"/>

  <xsl:include href="picaconv/pica/title.xsl"/>
  <xsl:include href="picaconv/pica/person.xsl"/>
  <xsl:include href="picaconv/pica/publication.xsl"/>

  <xsl:template match="sru:records">
    <html>
      <head>
        <title>Sammlung Deutscher Drucke 1601-1700 – Neuerwerbungsliste</title>
        <style type="text/css">
          html { background-color: #ccc; }
          body { font-family: Verdana, sans-serif; margin: 0 auto; width: 60em; background-color: white; }
          a, a:visited { color: #900129; }
          ul { list-style: outside none none; }
          ul ul { list-style: outside disc none; }
          ul ul li { margin: 1em 0; }
          h1 { font-size: 1.5em; }
          h2 { font-size: 1.25em; }
          dl { font-size: 0.9em; }
          dd, dt { margin: 0 1em; display: inline; }
          dt:after { content: ":"; }
          dt { font-weight: bold; color: #888; }
          div { padding: 1em; }
          #page { font-size: 11px; }
          #header { background-image: url('banner.jpg'); margin: 0; padding: 0; text-align: right; }
          #table-of-contents {  }
        </style>
        <link rel="unapi-server" type="application/xml" title="unAPI" href="http://katalog.hab.de/service/unapi" />
      </head>
      <body>
        <div id="header">
          <img src="logo.png"/>
        </div>
        <div id="page">
          <h1>Sammlung Deutscher Drucke 1601-1700</h1>
          <h2>Neuerwerbungsliste Januar - April 2015</h2>
          <div id="table-of-contents">
            <xsl:call-template name="process-records">
              <xsl:with-param name="mode" select="'toc'"/>
            </xsl:call-template>
          </div>
          <div>
            <xsl:call-template name="process-records"/>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="process-records">
    <xsl:param name="mode"/>
    <ul>
      <xsl:apply-templates select="sru:record/sru:recordData/pica:record">
        <xsl:sort select="pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a']"/>
        <xsl:with-param name="mode" select="$mode"/>
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <xsl:template match="pica:record[generate-id() = generate-id(key('notation', pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a'])[1])]">
    <xsl:param name="mode"/>
    <xsl:variable name="notation" select="pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a']"/>

    <xsl:if test="$fachgruppen/rdf:RDF/skos:Concept[skos:notation = $notation]">
      <xsl:variable name="label" select="$fachgruppen/rdf:RDF/skos:Concept[skos:notation = $notation]/skos:prefLabel[@xml:lang = 'de']"/>
      <xsl:variable name="count" select="count(key('notation', $notation))"/>
      <li>
        <xsl:choose>
          <xsl:when test="$mode = 'toc'">
            <a href="#sdd.{$notation}">
              <xsl:value-of select="$label"/>
            </a>
            <xsl:value-of select="concat(' (', $count, ')')"/>
          </xsl:when>
          <xsl:otherwise>
            <h3 id="sdd.{$notation}"><xsl:value-of select="concat($label, ' (', $count, ')')"/></h3>
            <ul>
              <xsl:for-each select="key('notation', $notation)">
                <xsl:variable name="ppn" select="pica:datafield[@tag = '003@']/pica:subfield[@code = '0']"/>
                <li>
                  <xsl:apply-templates mode="person"/>
                  <xsl:apply-templates mode="title"/>
                  <xsl:apply-templates mode="publication"/>
                  <xsl:text> [</xsl:text>
                  <a href="https://opac.lbs-braunschweig.gbv.de/DB=2/LNG=DU/PPN?PPN={$ppn}" target="_blank">
                    <xsl:value-of select="translate((pica:datafield[@tag = '209A']/pica:subfield[@code = 'a'])[1], ' ', ' ')"/>
                  </a>
                  <xsl:text>]</xsl:text>
                  <abbr class="unapi-id" title="opac-de-23:ppn:{$ppn}"/>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="title"/>
    <xsl:param name="subtitle"/>
    <xsl:param name="author-statement"/>
    <xsl:param name="type"/>

    <xsl:if test="string-length($type) = 0">
      <xsl:value-of select="translate($title, '@', '')"/>
      <xsl:if test="string-length($subtitle) &gt; 0">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="$subtitle"/>
      </xsl:if>
      <xsl:if test="string-length($author-statement) &gt; 0">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="$author-statement"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="person">
    <xsl:param name="person-name-display"/>
    <xsl:param name="person-role"/>
    <xsl:if test="$person-role = 'aut'">
      <xsl:value-of select="$person-name-display"/>
      <xsl:choose>
        <xsl:when test="following-sibling::pica:datafield[@tag = '028B']">
          <xsl:text>; </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>:</xsl:text>
          <br/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="publication">
    <xsl:param name="publication-date"/>
    <xsl:param name="publication-date-type"/>
    <xsl:param name="publication-place"/>
    <xsl:param name="publication-publisher"/>

    <xsl:text>. - </xsl:text>
    
    <xsl:value-of select="$publication-place"/>
    <xsl:if test="string-length($publication-place) &gt; 0 and string-length($publication-publisher) &gt; 0">
      <xsl:text> : </xsl:text>
    </xsl:if>
    <xsl:value-of select="$publication-publisher"/>

    <xsl:if test="string-length($publication-place) &gt; 0 or string-length($publication-publisher) &gt; 0">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="$publication-date"/>

  </xsl:template>

  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="title"/>
  <xsl:template match="text()" mode="person"/>
  <xsl:template match="text()" mode="publication"/>

</xsl:transform>
