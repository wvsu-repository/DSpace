<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    <xsl:call-template name="itemSummaryView-DIM-advisers"/>
                    <xsl:call-template name="itemSummaryView-DIM-chair"/>
                    <xsl:call-template name="itemSummaryView-DIM-member"/>
                    <xsl:call-template name="sharethis"/>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                    <xsl:if test='confman:getProperty("dimensions.enabled") and $identifier_doi'>
                        <xsl:call-template name="impact-dimensions"/>
                    </xsl:if>
                    <xsl:if test='confman:getProperty("altmetric.enabled") and $identifier_doi'>
                        <xsl:call-template name="impact-altmetric"/>
                    </xsl:if>
                    <xsl:if test='confman:getProperty("plumx.enabled") and $identifier_doi'>
                        <xsl:call-template name="impact-plumx"/>
                    </xsl:if>
                </div>
                <div class="col-sm-8">
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-DIM-description"/>
                    <xsl:call-template name="relation-associatedcontent"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:choose>
                        <xsl:when test="(dim:field[@element='citation' and @qualifier='journaltitle']) and (dim:field[@element='citation' and @qualifier='firstpage'])">
                            <xsl:variable name="item-type">
                                <xsl:value-of select="dim:field[@element='type' and not(@qualifier)]"/>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$item-type = 'Article' or 'Magazine article'">
                                    <xsl:call-template name="journalCitation"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='identifier' and @qualifier='citation']">
                            <xsl:call-template name="itemSummaryView-DIM-citation"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="itemSummaryView-DIM-DOI"/>
                    <div class="row">
                        <xsl:call-template name="itemSummaryView-DIM-type"/>
                        <xsl:call-template name="itemSummaryView-DIM-ISSN"/>
                        <xsl:call-template name="itemSummaryView-DIM-ISBN"/>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-subject"/>
                    <xsl:call-template name="itemSummaryView-DIM-keyword"/>
                    <xsl:call-template name="itemSummaryView-DIM-discipline"/>
                    <xsl:call-template name="itemSummaryView-DIM-degree"/>
                    <xsl:call-template name="itemSummaryView-DIM-level"/>
                    <div class="row">
                        <xsl:call-template name="itemSummaryView-DIM-DDC"/>
                        <xsl:call-template name="itemSummaryView-DIM-format"/>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-series"/>
                    <xsl:call-template name="itemSummaryView-collections"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                    <xsl:choose>
                        <xsl:when test="contains($src,'isAllowed=n')"/>
                        <xsl:otherwise>
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <img class="img-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="break">
                                    <xsl:with-param name="text" select="./node()"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-description">
        <xsl:if test="dim:field[@element='description' and not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="break">
                                    <xsl:with-param name="text" select="./node()"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                </div>
                <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                    <div class="spacer">&#160;</div>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citation">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='citation']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-citation</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='citation']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='citation']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='citation']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-advisers">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='advisor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-adviser</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='advisor']">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-chair">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='chair' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-chair</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='chair']">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-member">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='committeemember' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-member</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='committeemember']">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-discipline">
        <xsl:if test="dim:field[@element='degree'][@qualifier='discipline' and descendant::text()]">
                <div class="item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-discipline</i18n:text>
                    </h5>
                    <xsl:for-each select="dim:field[@element='degree'][@qualifier='discipline']">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
                </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-degree">
        <xsl:if test="dim:field[@element='degree'][@qualifier='name' and descendant::text()]">
                <div class="item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-degree</i18n:text>
                    </h5>
                    <xsl:for-each select="dim:field[@element='degree'][@qualifier='name']">
                        <xsl:copy-of select="node()"/>
                    </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-level">
        <xsl:if test="dim:field[@element='degree'][@qualifier='level' and descendant::text()]">
            <div class="item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-level</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='degree'][@qualifier='level']">
                    <xsl:copy-of select="node()"/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="@qualifier='author'">
                            <xsl:text>/discover?filtertype=author&amp;filter_relational_operator=equals&amp;sort_by=dc.date.issued_dt&amp;order=desc&amp;filter=</xsl:text>
            <xsl:copy-of select="node()"/>
                        </xsl:when>
                        <xsl:when test="@qualifier='chair'">
                            <xsl:text>/discover?filtertype=chair&amp;filter_relational_operator=equals&amp;sort_by=dc.date.issued_dt&amp;order=desc&amp;filter=</xsl:text>
                            <xsl:copy-of select="node()"/>
                        </xsl:when>
                        <xsl:when test="@qualifier='committeemember'">
                            <xsl:text>/discover?filtertype=member&amp;filter_relational_operator=equals&amp;sort_by=dc.date.issued_dt&amp;order=desc&amp;filter=</xsl:text>
                            <xsl:copy-of select="node()"/>
                        </xsl:when>
                        <xsl:when test="@qualifier='adviser'">
                            <xsl:text>/discover?filtertype=adviser&amp;filter_relational_operator=equals&amp;sort_by=dc.date.issued_dt&amp;order=desc&amp;filter=</xsl:text>
                            <xsl:copy-of select="node()"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:copy-of select="node()"/>
            </a>
            <xsl:if test="@orcid_id">
                <xsl:text> </xsl:text>
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>https://orcid.org/</xsl:text>
                        <xsl:value-of select="@orcid_id"/>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="data-toggle"><xsl:text>tooltip</xsl:text></xsl:attribute>
                    <xsl:attribute name="data-placement"><xsl:text>top</xsl:text></xsl:attribute>
                    <xsl:attribute name="data-original-title">
                        <xsl:value-of select="@orcid_id"/>
                    </xsl:attribute>
                    <img src="{$theme-path}/images/ORCIDiD.svg" alt="ORCID" />
                </a>
                <!--<a href="https://orcid.org/{@orcid_id}" target="_blank"><img src="{$theme-path}/images/ORCIDiD.svg" alt="ORCID" /></a>-->
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-LCSH-entry">
        <xsl:if test="starts-with(@authority,'fst')">
            <xsl:text>&#160;</xsl:text>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>http://id.worldcat.org/fast/</xsl:text>
                    <xsl:value-of select="@authority"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAAXNSR0IB2cksfwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAJNQTFRFAAAAIHm1IHm1IHm1IHm1IHm1IHm1IHm1IHm1IHm1IHm1IHm1IHm1Ppo8Ppo8Ppo8OpZLNpFdPpo8Ppo8Ppo8Ppo8Ppo8IHm1Ppo8e5Iz9YIgg5Ey9YIg9YIg9YIgPpo89YIg9YIg9YIgIHm10oE59YIg9YIg9YIg14E15oQiPpo89YIgoI0t9YIg9YIg9YIg9YIgFSvS3AAAADF0Uk5TABCA3//PYK/vIJ8wQHDf//+vn8+Aj2CP7zBA/+//UECPIJ+/v6/fgN+/EGDvzxAwv/6gdEsAAACoSURBVHicPU5RFoIwDMvGQBBhykARQZkKqIh4/9O5bmo+2jQvTQuAcU8I4Qf4gvnCYcF+c8gjRDwUSytwEcaWxKFYUfdcS1Ip1xtiwqOaSZUXqVQk0OZWJk7OjbAzLC3cRVUCvm+I3FcVrBMIKPRQN019BE5GMBZWNa3W50YjKemzi3ftyN8PSHMbFdxswHDP1MOFtyPV7ll8Z+jpBYy1xh/z9J762dIPwB8J12aqWq4AAAAASUVORK5CYII="
                     alt="OCLC - FAST (Faceted Application of Subject Terminology)" class="vocabulary"
                     title="OCLC - FAST (Faceted Application of Subject Terminology)"/>
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-AGROVOC-entry">
        <xsl:if test="@authority">
            <xsl:text>&#160;</xsl:text>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="@authority"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <img src="{$theme-path}images/AGROVOC-logo.gif" alt="AGROVOC" class="vocabulary" title="AGROVOC"/>
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-MeSH-entry">
        <xsl:if test="@authority">
            <xsl:text>&#160;</xsl:text>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="@authority"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <img src="{$theme-path}images/MeSH-logo.jpg" alt="MeSH" class="vocabulary" title="MeSH"/>
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-TGN-entry">
        <xsl:if test="@authority">
            <xsl:text>&#160;</xsl:text>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="@authority"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:text>_blank</xsl:text>
                </xsl:attribute>
                <img src="{$theme-path}images/TGN-logo.gif" alt="TGN" class="vocabulary" title="Getty Thesaurus of Geographic Names (TGN)®"/>
            </a>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-DOI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='doi' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-doi</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:text>http://doi.org/</xsl:text>
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-subject">
        <xsl:if test="dim:field[@element='subject'][@qualifier='lcsh']">
            <div class="item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-subject</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject'][@qualifier='lcsh']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of
                                        select="concat($context-path,'/discover?filtertype=')"/>
                                <xsl:text>subject&amp;filter_relational_operator=equals&amp;filter=</xsl:text>
                                <xsl:copy-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="text()"/>
                        </a>
                        <xsl:call-template name="itemSummaryView-DIM-LCSH-entry"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='lcsh']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-keyword">
        <xsl:if test="dim:field[@element='subject' and not(@qualifier)]
        or dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']
        or dim:field[@element='subject'][@qualifier='mesh']
or dim:field[@element='coverage'][@qualifier='spatial']">
            <div class="item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-keyword</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject' and not(@qualifier)]">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of
                                        select="concat($context-path,'/discover?filtertype=')"/>
                                <xsl:text>subject&amp;filter_relational_operator=equals&amp;filter=</xsl:text>
                                <xsl:copy-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="text()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject' and not(@qualifier)]) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']">
                        <xsl:if test="count(dim:field[@element='subject' and not(@qualifier)]) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:for-each select="dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="concat($context-path,'/discover?filtertype=')"/>
                                    <xsl:text>subject&amp;filter_relational_operator=equals&amp;filter=</xsl:text>
                                    <xsl:copy-of select="."/>
                                </xsl:attribute>
                                <xsl:value-of select="text()"/>
                            </a>
                            <xsl:call-template name="itemSummaryView-DIM-AGROVOC-entry"/>
                            <xsl:if test="count(following-sibling::dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="dim:field[@element='subject'][@qualifier='mesh']">
                        <xsl:if test="count(dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']) != 0
                        or count(dim:field[@element='subject' and not(@qualifier)]) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:for-each select="dim:field[@element='subject'][@qualifier='mesh']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="concat($context-path,'/discover?filtertype=')"/>
                                    <xsl:text>subject&amp;filter_relational_operator=equals&amp;filter=</xsl:text>
                                    <xsl:copy-of select="."/>
                                </xsl:attribute>
                                <xsl:value-of select="text()"/>
                            </a>
                            <xsl:call-template name="itemSummaryView-DIM-MeSH-entry"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='mesh']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="dim:field[@element='coverage'][@qualifier='spatial']">
                        <xsl:if test="count(dim:field[@mdschema='local'][@element='subject'][@qualifier='scientificname']) != 0
                        or count(dim:field[@element='subject' and not(@qualifier)]) != 0
                        or count(dim:field[@element='subject'][@qualifier='mesh']) !=0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:for-each select="dim:field[@element='coverage'][@qualifier='spatial']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="concat($context-path,'/discover?filtertype=')"/>
                                    <xsl:text>subject&amp;filter_relational_operator=equals&amp;filter=</xsl:text>
                                    <xsl:copy-of select="."/>
                                </xsl:attribute>
                                <xsl:value-of select="text()"/>
                            </a>
                            <xsl:call-template name="itemSummaryView-DIM-TGN-entry"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='coverage'][@qualifier='spatial']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-type">
        <xsl:if test="dim:field[@element='type' and not(@qualifier)]">
            <div class="col-sm-6 col-print-4">
                <div class="simple-item-view-issn item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type</i18n:text>
                    </h5>
                    <span>
                        <xsl:for-each select="dim:field[@element='type' and not(@qualifier)]">
                            <xsl:copy-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='type' and not(@qualifier)]) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-ISSN">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='issn' and descendant::text()] or
         dim:field[@element='identifier' and @qualifier='essn' and descendant::text()]">
            <div class="col-sm-6 col-print-4">
                <div class="simple-item-view-issn item-page-field-wrapper table">
                    <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-issn</i18n:text></h5>
                    <span>
                        <xsl:for-each select="dim:field[@element='identifier' and (@qualifier='issn' or @qualifier='essn') and descendant::text()]">
                            <xsl:copy-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier' and (@qualifier='issn' or @qualifier='essn')]) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-ISBN">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn' and descendant::text()]">
            <div class="col-sm-6 col-print-4">
                <div class="simple-item-view-isbn item-page-field-wrapper table">
                    <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-isbn</i18n:text></h5>
                    <span>
                        <xsl:for-each select="dim:field[@element='identifier' and @qualifier='isbn']">
                            <xsl:copy-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='isbn']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-format">
        <xsl:if test="dim:field[@element='format' and @qualifier='extent' and descendant::text()]">
            <div class="col-sm-6 col-print-4">
                <div class="item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-format</i18n:text>
                    </h5>
                    <div>
                        <xsl:value-of select="dim:field[@element='format'][@qualifier='extent'][1]/node()"/>
                    </div>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-series">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries' and descendant::text()]">
            <div class="item-page-field-wrapper table">
                <h5><i18n:text>xmlui.ArtifactBrowser.AdvancedSearch.type_series</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
                        <xsl:copy-of select="./node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartofseries']) != 0">
                            <xsl:text> | </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-DDC">
        <xsl:if test="dim:field[@element='subject' and @qualifier='ddc' and descendant::text()]">
            <div class="col-sm-6 col-print-4">
                <div class="item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-ddc</i18n:text>
                    </h5>
                    <div>
                        <xsl:value-of select="dim:field[@element='subject'][@qualifier='ddc'][1]/node()"/>
                    </div>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="sharethis">
        <div class="simple-item-view-date word-break item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-share</i18n:text>&#160;
                <i aria-hidden="true" class="glyphicon glyphicon-share-alt"></i>
            </h5>
            <div class="sharethis-inline-share-buttons">&#160;</div>
        </div>
    </xsl:template>

    <!-- This is to render line breaks in abstract and description fields in item simple view -->
    <xsl:template name="break">
        <xsl:param name="text" select="."/>
        <xsl:choose>
            <xsl:when test="contains($text, '&#xa;')">
                <xsl:value-of select="substring-before($text, '&#xa;')" disable-output-escaping="yes"/>
                <p/>
                <xsl:call-template name="break">
                    <xsl:with-param name="text" select="substring-after($text, '&#xa;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" disable-output-escaping="yes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="dim:field[@element='relation' and @qualifier='uri' and descendant::text()]">
                <xsl:call-template name="relation-associatedurl"/>
            </xsl:when>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>
                    <!-- Primary bitstream is always first fptr child of mets:div[@TYPE='DSpace Item'] -->
                    <xsl:variable name="primaryBitstream" select="//mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>

                    <!-- If primary bitstream has text/html MIME type ONLY list that bitstream -->
                    <xsl:choose>
                        <xsl:when test="//mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                            <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[@ID=$primaryBitstream]">
                                <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                                    <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                                    <xsl:with-param name="mimetype" select="@MIMETYPE" />
                                    <xsl:with-param name="label-1" select="$label-1" />
                                    <xsl:with-param name="label-2" select="$label-2" />
                                    <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                                    <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                                    <xsl:with-param name="size" select="@SIZE" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- Otherwise, iterate over and display all of them -->
                        <xsl:otherwise>
                            <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                                <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                                    <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                                    <xsl:with-param name="mimetype" select="@MIMETYPE" />
                                    <xsl:with-param name="label-1" select="$label-1" />
                                    <xsl:with-param name="label-2" select="$label-2" />
                                    <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                                    <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                                    <xsl:with-param name="size" select="@SIZE" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <xsl:template name="relation-associatedcontent">
        <xsl:if test="dim:field[@element='relation' and @qualifier='hasversion' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-version</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='hasversion']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="substring-before(./node(),' ')"/>
                            </xsl:attribute>
                            <xsl:value-of select="substring-after(./node(),' ')"/>
                        </a>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="relation-associatedurl">
        <xsl:if test="dim:field[@element='relation' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-url</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="data-target">
                                <xsl:text>#externalLinkModal</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:text>#</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="data-toggle">
                                <xsl:text>modal</xsl:text>
                            </xsl:attribute>
                            <xsl:variable name="url_ini">
                                <xsl:copy-of select="./node()"/>
                            </xsl:variable>
                            <xsl:variable name="url_minus_http">
                                <xsl:value-of select="substring-after($url_ini,'://')"/>
                            </xsl:variable>
                            <i aria-hidden="true">
                                <xsl:attribute name="class">
                                    <xsl:text>glyphicon glyphicon-download-alt</xsl:text>
                                </xsl:attribute>
                            </i>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="substring-before($url_minus_http,'/')"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name='impact-altmetric'>
        <div id='impact-altmetric' class="table">
            <!-- Altmetric.com -->
            <script type="text/javascript" src="{concat($scheme, 'd1bxh8uas1mnw7.cloudfront.net/assets/embed.js')}">&#xFEFF;
            </script>
            <div id='altmetric'
                 class='altmetric-embed'>
                <xsl:variable name='badge_type' select='confman:getProperty("altmetric.badgeType")'/>
                <xsl:if test='boolean($badge_type)'>
                    <xsl:attribute name='data-badge-type'><xsl:value-of select='$badge_type'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='badge_popover' select='confman:getProperty("altmetric.popover")'/>
                <xsl:if test='$badge_popover'>
                    <xsl:attribute name='data-badge-popover'><xsl:value-of select='$badge_popover'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='badge_details' select='confman:getProperty("altmetric.details")'/>
                <xsl:if test='$badge_details'>
                    <xsl:attribute name='data-badge-details'><xsl:value-of select='$badge_details'/></xsl:attribute>
                </xsl:if>

                <xsl:variable name='no_score' select='confman:getProperty("altmetric.noScore")'/>
                <xsl:if test='$no_score'>
                    <xsl:attribute name='data-no-score'><xsl:value-of select='$no_score'/></xsl:attribute>
                </xsl:if>

                <xsl:if test='confman:getProperty("altmetric.hideNoMentions")'>
                    <xsl:attribute name='data-hide-no-mentions'>true</xsl:attribute>
                </xsl:if>

                <xsl:variable name='link_target' select='confman:getProperty("altmetric.linkTarget")'/>
                <xsl:if test='$link_target'>
                    <xsl:attribute name='data-link-target'><xsl:value-of select='$link_target'/></xsl:attribute>
                </xsl:if>

                <xsl:choose>    <!-- data-doi data-handle data-arxiv-id data-pmid -->
                    <xsl:when test='$identifier_doi'>
                        <xsl:attribute name='data-doi'><xsl:value-of select='$identifier_doi'/></xsl:attribute>
                    </xsl:when>
                    <xsl:when test='$identifier_handle'>
                        <xsl:variable name="handle" select="dim:field[@element='identifier' and @qualifier='uri'][1]"/>
                        <xsl:attribute name='data-handle'><xsl:value-of select='substring-after($handle,"hdl.handle.net/")'/></xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                &#xFEFF;
            </div>
        </div>
    </xsl:template>

    <xsl:template name="impact-plumx">
        <div id="impact-plumx" style="clear:right" class="table">
            <!-- PlumX <http://plu.mx> -->
            <xsl:variable name="plumx_type" select="confman:getProperty('plumx.widget-type')"/>
            <xsl:variable name="plumx-script-url">
                <xsl:choose>
                    <xsl:when test="boolean($plumx_type)">
                        <xsl:value-of select="concat($scheme, 'cdn.plu.mx/widget-', $plumx_type, '.js')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($scheme, 'cdn.plu.mx/widget-popup.js')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <script type="text/javascript" src="{$plumx-script-url}">&#xFEFF;
            </script>

            <xsl:variable name="plumx-class">
                <xsl:choose>
                    <xsl:when test="boolean($plumx_type) and ($plumx_type != 'popup')">
                        <xsl:value-of select="concat('plumx-', $plumx_type)"/>
                    </xsl:when>
                    <xsl:otherwise>plumx-plum-print-popup</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <a>
                <xsl:attribute name="id">plumx</xsl:attribute>
                <xsl:attribute name="class"><xsl:value-of select="$plumx-class"/></xsl:attribute>
                <xsl:attribute name="href">https://plu.mx/pitt/a/?doi=<xsl:value-of select="$identifier_doi"/></xsl:attribute>

                <xsl:variable name="plumx_data-popup" select="confman:getProperty('plumx.data-popup')"/>
                <xsl:if test="$plumx_data-popup">
                    <xsl:attribute name="data-popup"><xsl:value-of select="$plumx_data-popup"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('plumx.data-hide-when-empty')">
                    <xsl:attribute name="data-hide-when-empty">true</xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('plumx.data-hide-print')">
                    <xsl:attribute name="data-hide-print">true</xsl:attribute>
                </xsl:if>

                <xsl:variable name="plumx_data-orientation" select="confman:getProperty('plumx.data-orientation')"/>
                <xsl:if test="$plumx_data-orientation">
                    <xsl:attribute name="data-orientation"><xsl:value-of select="$plumx_data-orientation"/></xsl:attribute>
                </xsl:if>

                <xsl:variable name="plumx_data-width" select="confman:getProperty('plumx.data-width')"/>
                <xsl:if test="$plumx_data-width">
                    <xsl:attribute name="data-width"><xsl:value-of select="$plumx_data-width"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="confman:getProperty('plumx.data-border')">
                    <xsl:attribute name="data-border">true</xsl:attribute>
                </xsl:if>
                &#xFEFF;
            </a>

        </div>
    </xsl:template>

    <xsl:template name='impact-dimensions'>
        <script type="text/javascript" src="https://badge.dimensions.ai/badge.js" charset="utf-8">&#xFEFF;</script>
        <div class="table">
            <span class="__dimensions_badge_embed__">
                <xsl:variable name='badge_type' select='confman:getProperty("dimensions.style")'/>
                <xsl:if test='boolean($badge_type)'>
                    <xsl:attribute name='data-style'>
                        <xsl:value-of select='$badge_type'/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:variable name="legend" select="confman:getProperty('dimensions.legend')"/>
                <xsl:if test="boolean($legend)">
                    <xsl:attribute name="data-legend">
                        <xsl:value-of select="$legend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="data-doi">
                    <xsl:value-of select="$identifier_doi"/>
                </xsl:attribute>
                <xsl:attribute name="data-hide-zero-citations">
                    <xsl:text>true</xsl:text>
                </xsl:attribute>
            </span>
        </div>
    </xsl:template>

    <xsl:variable name="scheme">
        <xsl:choose>
            <xsl:when test="starts-with(confman:getProperty('dspace.baseUrl'), 'https://')">
                <xsl:text>https://</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>http://</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- item metadata reference
    <xsl:variable name='identifier_doi'
                  select='//dri:meta/dri:pageMeta/dri:metadata[@element="citation_doi"]'/>
    <xsl:variable name='identifier_handle'
                  select='substring-after($request-uri,"handle/")'/>
                  -->

    <!-- item metadata reference -->
    <xsl:variable name='identifier_doi'
                  select='document($otherItemMetadataURL)//dim:field[@element="identifier" and @qualifier="doi"]/text()'/>
    <xsl:variable name='identifier_handle'
                  select='document($otherItemMetadataURL)//dim:field[@element="identifier" and @qualifier="handle"]/text()'/>

</xsl:stylesheet>
