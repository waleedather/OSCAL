<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

<xsl:output indent="yes"/>
    
<xsl:strip-space _elements="*"/>
 
    <xsl:key name="category-by-function" match="record[exists(Category)][empty(Subcategory)]"  use="substring-before(Category,'.')"/>
    <xsl:key name="control-by-family" match="record[exists(Category)][exists(Subcategory)]" use="string(Category)"/>
    
    <xsl:variable name="class-regex" as="xs:string">(AC|AT|AU|CA|CM|CP|IA|IR|MA|MP|PE|PL|PS|RA|SA|SC|SI)</xsl:variable>
    <xsl:variable name="controlorenhancement-regex" as="xs:string" expand-text="true">^{$class-regex}</xsl:variable>
    <xsl:variable name="control-regex"              as="xs:string" expand-text="true">^{$class-regex}\-\d+$</xsl:variable>
    <xsl:variable name="enhancement-regex"          as="xs:string" expand-text="true">^{$class-regex}\-\d+\s+\(\d+\)$</xsl:variable>
    
    <xsl:template match="/*" expand-text="yes">
        <framework>
            <xsl:for-each-group select="row" group-starting-with="row[matches(ID,'[a-z]')]">
                
                <!-- exploiting the order; remember . is the leader of the group -->
                <group>
                    <xsl:variable name="group-id" select="tokenize(ID,'\s+')[last()] => translate('()','')"/>
                    <title>{replace(.,'\s*\(.*$','')}</title>
                    <prop class="name">{$group-id}</prop>
                    <xsl:for-each-group select="current-group() except ."
                        group-starting-with="row[matches(ID,$control-regex)]">
                        <component>
                            <xsl:apply-templates select="Title, * except Title"/>
                         <!--the first row represents the control, subsequent ones are subcontrols-->
                            
                            <xsl:for-each select="current-group() except .">
                                <component>
                                    <xsl:apply-templates select="Title, * except Title"/>
                                </component>
                            </xsl:for-each>
                                
                        </component>
                    </xsl:for-each-group>
                </group>
                
            </xsl:for-each-group>
        </framework>
    </xsl:template>
    
    <xsl:template match="row/*" priority="-0.4">
        <p class="{lower-case(name())}"><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="row/*[not(matches(.,'\S'))]" priority="-0.3"/>
    
    <xsl:template match="Title">
        <title>
            <xsl:value-of select="tokenize(.,' \| ')[last()]"/>
        </title>
        
    </xsl:template>
    
    <xsl:template match="ID">
        <prop class="name">
            <xsl:apply-templates/>
        </prop>
    </xsl:template>
    
    <xsl:template match="Baseline_LOW[.='X']">
        <prop class="baseline-impact">LOW</prop>
    </xsl:template>
    
    <xsl:template match="Baseline_MOD[.='X']">
        <prop class="baseline-impact">MODERATE</prop>
    </xsl:template>
    
    
    <!-- First time through we drop rows that describe controls and subcontrols
         this leaves only the header rows. --> 


    <xsl:template match="row[matches(ID,$controlorenhancement-regex)]"/>
        
    
    
</xsl:stylesheet>