<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="yes" indent="yes"/>
<!-- Separamos los casos de error y no error en los parametros pasados por consola
    mediante el uso del elemento choose, aplicando las condiciones when y otherwise -->
<xsl:template match="./nascar_data"><xsl:choose><xsl:when test="count(error) &lt;1">
# Drivers for <xsl:value-of select="./serie_type"/> for <xsl:value-of select="./year"/> season
 ---
 ---
<xsl:for-each select="./drivers/driver"><xsl:sort select="full_name"/> ### <xsl:value-of select="./full_name"/>
1. Country: <xsl:value-of select="./country"/>
2. Birth date: <xsl:value-of select="./birth_date"/>
3. Birthplace: <xsl:value-of select="./birth_place"/>
<xsl:choose><xsl:when test="not(./car)">
4. Car manufacturer: - </xsl:when>
<xsl:otherwise>
4. Car manufacturer: <xsl:value-of select="./car"/>
</xsl:otherwise>
</xsl:choose>
5. Rank: <xsl:value-of select="./rank"/>
<!-- Consultamos la siguiente condicion de rank para poder desplegar la informacion del nodo Statistics  -->
<xsl:if test="./rank != '-' ">
    ##### Statistics
    - Season points: <xsl:value-of select="./statistics/season_points"/>
    - Wins: <xsl:value-of select="./statistics/wins"/>
    - Poles: <xsl:value-of select="./statistics/poles"/>
    - Races not finished: <xsl:value-of select="./statistics/races_not_finished"/>
    - Laps completed: <xsl:value-of select="./statistics/laps_completed"/>
</xsl:if>
---
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<xsl:for-each select="./error">
Error: <xsl:value-of select="."/>
</xsl:for-each>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>