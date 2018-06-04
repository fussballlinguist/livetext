<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />
   
    <xsl:template match="corpus">
        <corpus>
            <xsl:apply-templates/>
        </corpus>
    </xsl:template>
    
    <xsl:template match="text">
    	<text>
    		<xsl:attribute name="title">
    			<xsl:value-of select="title"/>
    		</xsl:attribute>
    		<xsl:attribute name="url">
    			<xsl:value-of select="url"/>
    		</xsl:attribute>
    		<xsl:attribute name="date">
    			<xsl:value-of select="date"/>
    		</xsl:attribute>
    		<xsl:attribute name="kickoff">
    			<xsl:value-of select="kickoff"/>
    		</xsl:attribute>
    		<xsl:attribute name="team1">
    			<xsl:value-of select="team1"/>
    		</xsl:attribute>
    		<xsl:attribute name="team2">
    			<xsl:value-of select="team2"/>
    		</xsl:attribute>
    		<xsl:attribute name="result">
    			<xsl:value-of select="result"/>
    		</xsl:attribute>

    		<xsl:apply-templates/>
    	</text>
    </xsl:template>

    <xsl:template match="*|text()">
		<xsl:apply-templates/>
	</xsl:template>
	    
	<xsl:template match="topline">
	<topline>
		<xsl:value-of select="normalize-space(.)"/>
	</topline>
	</xsl:template>

	<xsl:template match="head">
	<head>
		<xsl:value-of select="normalize-space(.)"/>
	</head>
	</xsl:template>

	<xsl:template match="teaser">
	<teaser>
		<xsl:value-of select="normalize-space(.)"/>
	</teaser>
	</xsl:template>

	<xsl:template match="p">
	<p>
		<xsl:value-of select="normalize-space(.)"/>
	</p>
	</xsl:template>

</xsl:stylesheet>