<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.arkivverket.no/standarder/addml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="1.0">

<!--
        Denne transformering skjer fra en NoarkIH.xml og gjør denne om til en addml.xml.
        
        Foreløpig er det en feil ved at flere av elementene får med attributtet xlmns="".
-->
    <xsl:output method="xml" version="1.0"
        encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="NOARK.IH">
        <addml xmlns="http://www.arkivverket.no/standarder/addml"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.arkivverket.no/standarder/addml addml.xsd">
            <dataset>
                <reference>
                        <xsl:apply-templates select="EKSPORTINFO"/>
                </reference>
                <flatFiles>
                    <xsl:apply-templates select="TABELLINFO"/>
                    <flatFileDefinitions>
                        <xsl:for-each select="TABELLINFO">
                            <xsl:apply-templates select="ATTRIBUTTER"/>
                        </xsl:for-each>
                    </flatFileDefinitions>
                    <structureTypes>
                        <flatFileTypes>
                            <flatFileType name="filref">
                                <charset>ISO-8859-1</charset>
                                <fixedFileFormat/>
                            </flatFileType>
                        </flatFileTypes>
                        <recordTypes>
                            <recordType name="recref"/>
                        </recordTypes>
                        <fieldTypes>
                            <fieldType name="string">
                                <dataType>string</dataType>
                            </fieldType>
                            <fieldType name="integer">
                                <dataType>integer</dataType>
                            </fieldType>
                            <fieldType name="date8">
                                <dataType>date</dataType>
                                <fieldFormat>ddmmyyyy</fieldFormat>
                            </fieldType>
                        </fieldTypes>
                    </structureTypes>
                    <flatFileProcesses flatFileReference="NOARKSAK">
                        <processes>
                            <process name="Analyse_CountRecords"/>
                            <process name="Control_NumberOfRecords"/>
                        </processes>
                        <recordProcesses definitionReference="NOARKSAK">
                            <processes>
                                <process name="Analyse_CountRecordDefinitionOccurences"/>
                            </processes>
                            <fieldProcesses definitionReference="SA.DATO">
                                <processes>
                                    <process name="Control_DataFormat"/>
                                </processes>
                            </fieldProcesses>
                        </recordProcesses>
                    </flatFileProcesses>
                </flatFiles>
            </dataset>
        </addml>
    </xsl:template>
    
    <xsl:template match="EKSPORTINFO">
        <context>
            <xsl:choose>
            <xsl:when test="EI.ARKSKAPER">
                <additionalElements>
                    <additionalElement name="agents">
                        <additionalElements>
                            <additionalElement name="agent">
                                <additionalElements>
                                    <additionalElement name="role">
                                        <value>recordCreator</value>
                                    </additionalElement>
                                    <additionalElement name="type">
                                        <value>institution</value>
                                    </additionalElement>
                                    <additionalElement name="name">
                                        <value><xsl:value-of select="EI.ARKSKAPER"/></value>
                                    </additionalElement>
                                </additionalElements>
                            </additionalElement>
                        </additionalElements>
                    </additionalElement>
                </additionalElements>
            </xsl:when>
            <xsl:when test="EI.SYSTEMNAVN">
                <additionalElements>
                    <additionalElement name="system">
                        <additionalElements>
                            <additionalElement name="systemType">
                                <value>Noark 4</value>
                            </additionalElement>
                            <additionalElement name="systemNavn">
                                <value><xsl:value-of select="EI.SYSTEMNAVN"/></value>
                            </additionalElement>
                        </additionalElements>
                    </additionalElement>
                </additionalElements>
            </xsl:when>
        </xsl:choose>
        </context>
        <content>
            <xsl:choose>
            <xsl:when test="EI.FRADATO">
                <additionalElements>
                    <additionalElement name="archivalPeriod">
                        <additionalElements>
                            <additionalElement name="startDate">
                                <value><xsl:value-of select="EI.FRADATO"/></value>
                            </additionalElement>
                            <additionalElement name="date">
                                <value><xsl:value-of select="EI.TILDATO"/></value>
                            </additionalElement>
                            <additionalElement name="type">
                                <value>Noark 4</value>
                            </additionalElement>
                        </additionalElements>
                    </additionalElement>
                </additionalElements>
            </xsl:when>
            <xsl:when test="EI.PRODDATO">
                <additionalElements>
                    <additionalElement name="archivalDataset">
                        <additionalElements>
                            <additionalElement name="date">
                                <value><xsl:value-of select="EI.PRODDATO"/></value>
                            </additionalElement>
                            <additionalElement name="type">
                                <value>Noark 4</value>
                            </additionalElement>
                        </additionalElements>
                    </additionalElement>
                </additionalElements>
            </xsl:when>
            <xsl:otherwise>
                <comment>Hva har skjedd nå?</comment>
            </xsl:otherwise>
        </xsl:choose>
        </content>
    </xsl:template>
    
    <xsl:template match="TABELLINFO">
        <xsl:variable name="filnavn" select="TI.TABELL"/>
        <flatFile definitionReference="{$filnavn}" name="{$filnavn}">
            <!--<value><xsl:value-of select="TI.TABELL"/></value>-->
            <properties>
                <property name="fileName">
                    <value>DATA\<xsl:value-of select="FIL/TI.FILNAVN"/></value>
                </property>
                <property name="numberOfRecords">
                    <value><xsl:value-of select="FIL/TI.ANTPOSTER"/></value>
                </property>
            </properties>
        </flatFile>
    </xsl:template>
    
    <xsl:template match="ATTRIBUTTER">
        <xsl:variable name="filnavn" select="../TI.TABELL"/>
        <!--<flatFileDefinitions>-->
            <flatFileDefinition name="{$filnavn}" typeReference="filref">
                <recordDefinitions>
                    <recordDefinition name="{$filnavn}">
                        <fieldDefinitions>
                            <xsl:for-each select="TI.ATTR">
                                <xsl:variable name="feltnavn" select="."/>
                                <xsl:choose>
                                    <xsl:when test="$feltnavn='SA.ID'">
                                        <fieldDefinition name="{$feltnavn}" typeReference="integer"/>
                                    </xsl:when>
                                    <xsl:when test="$feltnavn='SA.DATO'">
                                        <fieldDefinition name="{$feltnavn}" typeReference="date8"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <fieldDefinition name="{$feltnavn}" typeReference="string"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </fieldDefinitions>
                    </recordDefinition>
                </recordDefinitions>
            </flatFileDefinition>
<!--        </flatFileDefinitions>
        <structureTypes>
            <flatFileTypes>
                <flatFileType name="filref"/>
            </flatFileTypes>
            <recordTypes>
                <recordType name="recref"/>
            </recordTypes>
            <fieldTypes>
                <fieldType name="string">
                    <dataType>String</dataType>
                </fieldType>
            </fieldTypes>
        </structureTypes>-->
    </xsl:template>

    <xsl:template match="TI.ATTR">0
        <fieldDefinitions>
            <xsl:variable name="feltnavn">
                <value><xsl:value-of select="TI.ATTR"/></value>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$feltnavn='SA.ID'">
                    <fieldDefinition name="{$feltnavn}" typeReference="integer"/>
                </xsl:when>
                <xsl:when test="$feltnavn='SA.DATO'">
                    <fieldDefinition name="{$feltnavn}" typeReference="date8"/>
                </xsl:when>
                <xsl:otherwise>
                    <fieldDefinition name="{$feltnavn}" typeReference="string"/>
                </xsl:otherwise>
            </xsl:choose>
        </fieldDefinitions>
    </xsl:template>
</xsl:stylesheet>