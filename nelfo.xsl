<xsl:transform version="2.0"
	       exclude-result-prefixes="#all"
	       xmlns:fo="http://www.w3.org/1999/XSL/Format"
	       xmlns:mods="http://www.loc.gov/mods/v3"
	       xmlns:sru="http://docs.oasis-open.org/ns/search-ws/sruResponse"
	       xmlns:xs="http://www.w3.org/2001/XMLSchema"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="label" as="xs:string" required="yes"/>
  <xsl:output indent="yes"/>

  <xsl:attribute-set name="heading">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="font-size">x-large</xsl:attribute>
    <xsl:attribute name="page-break-after">avoid</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="subheading" use-attribute-sets="heading">
    <xsl:attribute name="font-size">large</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="record">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="page-break-inside">avoid</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="creator"/>

  <xsl:attribute-set name="title">
    <xsl:attribute name="space-end">.2em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="publisher">
    <xsl:attribute name="space-end">.2em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="shelfmark">
    <xsl:attribute name="space-end">.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="hyperlink">
    <xsl:attribute name="font-size">small</xsl:attribute>
    <xsl:attribute name="space-before">.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:key name="by-creator" match="mods:mods" use="mods:name[mods:role/mods:roleTerm = 'aut']/@valueURI"/>

  <xsl:template match="sru:searchRetrieveResponse">
    <fo:root>
      <fo:layout-master-set>

	<fo:simple-page-master master-name="page" page-height="297mm" page-width="210mm">

	  <fo:region-body margin="20mm 20mm 20mm 25mm"/>
	  <fo:region-before extent="0mm"/>
	  <fo:region-after extent="0mm"/>
	  <fo:region-start extent="0mm"/>
	  <fo:region-end extent="0mm"/>

	</fo:simple-page-master>

      </fo:layout-master-set>

      <fo:bookmark-tree>
	<xsl:apply-templates mode="table-of-contents"/>
      </fo:bookmark-tree>

      <fo:page-sequence master-reference="page">
	<fo:flow flow-name="xsl-region-body">
	  <fo:block font-size="xx-large">
	    <fo:block>
	      Sammlung Deutscher Drucke 1601-1700
	    </fo:block>
	    <fo:block>
	      Neuererwerbungen <xsl:value-of select="$label"/>
	    </fo:block>
	  </fo:block>
	  <xsl:apply-templates/>
	</fo:flow>
      </fo:page-sequence>

    </fo:root>
  </xsl:template>

  <xsl:template match="sru:records" mode="table-of-contents">
    <fo:bookmark internal-destination="subject">
      <fo:bookmark-title>Nach Fachgebiet</fo:bookmark-title>
      <xsl:for-each-group select="sru:record/sru:recordData/mods:mods" group-by="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']">
	<xsl:sort select="current-grouping-key()"/>
	<fo:bookmark internal-destination="{generate-id()}">
	  <fo:bookmark-title><xsl:value-of select="current-grouping-key()"/></fo:bookmark-title>
	</fo:bookmark>
      </xsl:for-each-group>
    </fo:bookmark>
  </xsl:template>

  <xsl:template match="sru:records">
    <fo:block id="subject">
      <fo:block xsl:use-attribute-sets="heading">Nach Fachgebiet</fo:block>
      <xsl:for-each-group select="sru:record/sru:recordData/mods:mods" group-by="mods:classification[@authorityURI = 'http://uri.hab.de/vocab/sdd-fachgruppen']">
	<xsl:sort select="current-grouping-key()"/>
	<fo:block>
	  <fo:block xsl:use-attribute-sets="subheading" id="{generate-id()}">
	    <xsl:value-of select="current-grouping-key()"/>
	  </fo:block>
	  <xsl:for-each select="current-group()">
	    <xsl:call-template name="bibrecord"/>
	  </xsl:for-each>
	</fo:block>
      </xsl:for-each-group>
    </fo:block>
    <fo:block id="creator">
      <fo:block xsl:use-attribute-sets="heading">Nach Verfasser</fo:block>
      <xsl:for-each-group select="sru:record/sru:recordData/mods:mods/mods:name[mods:role/mods:roleTerm = 'aut']"
			  group-by="@valueURI">
	<xsl:sort select="mods:displayForm"/>
	<fo:block xsl:use-attribute-sets="subheading">
	  <xsl:value-of select="mods:displayForm"/>
	</fo:block>
	<xsl:for-each select="key('by-creator', current-grouping-key())">
	  <xsl:call-template name="bibrecord"/>
	</xsl:for-each>
      </xsl:for-each-group>
    </fo:block>
  </xsl:template>

  <xsl:template name="bibrecord">
    <fo:block xsl:use-attribute-sets="record">
      <!-- Verfasser -->
      <fo:block xsl:use-attribute-sets="creator">
	<xsl:variable name="creators">
	  <xsl:value-of select="mods:name[mods:role/mods:roleTerm = 'aut']/mods:displayForm" separator="; "/>
	</xsl:variable>
	<xsl:value-of select="concat(if ($creators eq '') then 'N.N.' else $creators , ':')"/>
      </fo:block>
      <!-- Titel -->
      <fo:inline xsl:use-attribute-sets="title">
	<xsl:value-of select="(mods:titleInfo[1]/mods:title, mods:titleInfo[1]/mods:subTitle)" separator=" : "/>
      </fo:inline>
      <fo:inline>
	<xsl:text> - </xsl:text>
      </fo:inline>
      <!-- Verlagsangaben -->
      <fo:inline xsl:use-attribute-sets="publisher">
	<xsl:value-of select="mods:originInfo[mods:dateIssued]/mods:place" separator="; "/>
	<xsl:if test="mods:originInfo[mods:dateIssued]/mods:place and mods:originInfo[mods:dateIssued]/mods:publisher">
	  <xsl:text> : </xsl:text>
	</xsl:if>
	<xsl:value-of select="mods:originInfo[mods:dateIssued]/mods:publisher" separator="; "/>
	<xsl:if test="mods:originInfo[mods:dateIssued]/mods:place or mods:originInfo[mods:dateIssued]/mods:publisher">
	  <xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:value-of select="mods:originInfo/mods:dateIssued"/>
      </fo:inline>
      <!-- Signatur -->
      <xsl:if test="mods:location/mods:shelfLocator">
	<fo:inline xsl:use-attribute-sets="shelfmark">
	  <fo:inline><xsl:text> - </xsl:text></fo:inline>
	  <xsl:value-of select="mods:location/mods:shelfLocator"/>
	</fo:inline>
	<fo:block xsl:use-attribute-sets="hyperlink">
	  <xsl:text>URL: </xsl:text>
	  <fo:basic-link external-destination="http://opac.lbs-braunschweig.gbv.de/DB=2/PPN?PPN={mods:recordInfo/mods:recordIdentifier}">
	    <xsl:value-of select="concat('http://opac.lbs-braunschweig.gbv.de/DB=2/PPN?PPN=', mods:recordInfo/mods:recordIdentifier)"/>
	  </fo:basic-link>
	</fo:block>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="text()" mode="#all"/>

</xsl:transform>
