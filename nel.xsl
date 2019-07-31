<xsl:transform version="2.0"
               exclude-result-prefixes="#all"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:sru="http://docs.oasis-open.org/ns/search-ws/sruResponse"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="label" as="xs:string" required="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>Neuerwerbungsliste der Sammlung Deutscher Drucke an der Herzog August Bibliothek</title>
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
        <xsl:comment>Executed query: <xsl:value-of select="sru:searchRetrieveResponse/sru:echoedSearchRetrieveRequest/sru:query"/> </xsl:comment>
      </head>
      <body vocab="http://schema.org/">
        <div id="header">
          <img src="logo.png"/>
        </div>
        <div id="page">
          <h1>Sammlung Deutscher Drucke 1601-1700</h1>
          <h2>
            Neuerwerbungsliste <xsl:value-of select="$label"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="count(//sru:record)"/>
            <xsl:text> Erwerbungen)</xsl:text>
          </h2>
          <p>
            <a href="sddlist.pdf" target="_blank">Download als PDF</a>
          </p>
          <div id="table-of-contents">
            <xsl:apply-templates mode="table-of-contents"/>
          </div>
          <xsl:apply-templates/>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="sru:records" mode="table-of-contents">
    <ul>
      <xsl:for-each-group select="sru:record/sru:recordData/mods:mods" group-by="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']">
        <xsl:sort select="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']/@valueURI"/>
        <li>
          <a href="#{generate-id()}">
            <xsl:value-of select="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']"/>
            <xsl:value-of select="concat(' (', count(current-group()), ')')"/>
          </a>
        </li>
      </xsl:for-each-group>
    </ul>
  </xsl:template>

  <xsl:template match="sru:records">
    <ul>
      <xsl:for-each-group select="sru:record/sru:recordData/mods:mods" group-by="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']">
        <xsl:sort select="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']/@valueURI"/>
        <li>
          <h3 id="{generate-id()}">
            <xsl:value-of select="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']"/>
            <xsl:value-of select="concat(' (', count(current-group()), ')')"/>
          </h3>
          <ul>
            <xsl:for-each select="current-group()">
              <li typeof="Book">
                <xsl:if test="mods:name[mods:role/mods:roleTerm = 'aut']">
                  <xsl:for-each select="mods:name[mods:role/mods:roleTerm = 'aut']">
                    <xsl:if test="position() > 1"><xsl:text>; </xsl:text></xsl:if>
                    <span property="creator"><xsl:value-of select="mods:displayForm"/></span>
                  </xsl:for-each>
                  <xsl:text>: </xsl:text>
                  <br/>
                </xsl:if>
                <span property="name">
                  <xsl:value-of select="(mods:titleInfo[1]/mods:title, mods:titleInfo[1]/mods:subTitle)" separator=" : "/>
                </span>
                <xsl:text> </xsl:text>
                <span property="publisher">
                  <xsl:value-of select="mods:originInfo[mods:dateIssued]/mods:place" separator="; "/>
                  <xsl:if test="mods:originInfo[mods:dateIssued]/mods:place and mods:originInfo[mods:dateIssued]/mods:publisher">
                    <xsl:text> : </xsl:text>
                  </xsl:if>
                  <xsl:value-of select="mods:originInfo[mods:dateIssued]/mods:publisher" separator="; "/>
                </span>
                <xsl:if test="mods:originInfo[mods:dateIssued]/mods:place or mods:originInfo[mods:dateIssued]/mods:publisher">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <span property="datePublished">
                  <xsl:value-of select="mods:originInfo/mods:dateIssued"/>
                </span>
                <xsl:if test="mods:location/mods:shelfLocator">
                  <xsl:text> </xsl:text>
                  <a property="offers" typeOf="Offer" href="http://opac.lbs-braunschweig.gbv.de/DB=2/PPN?PPN={mods:recordInfo/mods:recordIdentifier}" target="_blank">
                    <span>
                      <xsl:value-of select="mods:location/mods:shelfLocator"/>
                    </span>
                  </a>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ul>
        </li>
      </xsl:for-each-group>
    </ul>
  </xsl:template>

  <xsl:template match="text()" mode="#all"/>

</xsl:transform>
