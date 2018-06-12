<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:import href="includes/linker.xsl" />


<xsl:output method="xml" media-type="application/xslfo+xml" indent="no" encoding="UTF-8"/>

<!-- Global constants -->
<xsl:variable name="pageWidth">15</xsl:variable>
<xsl:variable name="pageHeight">8.5</xsl:variable>
<xsl:variable name="margin">0.25</xsl:variable>
<xsl:variable name="headerHeight">0.25</xsl:variable>
<xsl:variable name="footerHeight">0.55</xsl:variable>
<xsl:variable name="bodyWidth" select="$pageWidth - (2 * $margin)"/>
<xsl:variable name="units">in</xsl:variable>
<xsl:variable name="halfBodyWidth" select="$bodyWidth div 2"/>
<xsl:variable name="gutter" select="0.125"/>
<xsl:variable name="solidRuleWidth">0.75pt</xsl:variable>

<!-- Source gateway -->
<xsl:variable name="sourceGateway" select="/queryResult/metadata/sourceGateway"/>

<xsl:variable name="windchill" select="/queryResult/metadata/sourceSystem"/>
<xsl:variable name="relatedFilesURL" select='concat($windchill,"/netmarkets/images/Allegion_logo_new.png")'/>

<xsl:variable name="fopSpaceAfterTable" select="0.125"/>

<!-- Get locale -->
<xsl:variable name="locale" select='/queryResult/metadata/locale'/>

<!-- Get name of Java resource bundle if provided and then include translation handling template -->
<xsl:variable name="javaResourceBundle" select='/queryResult/auxData/dataItem[@name="jrb"]'/>
<xsl:include href="includes/localizeString.xsl"/>

<!-- Translated Report Name -->
<xsl:variable name="reportName">
  <xsl:call-template name="localizeString">
   <xsl:with-param name="key" select="/queryResult/result/row/NUMBER"/>
  </xsl:call-template>
</xsl:variable>

<!-- Globals derived from input -->
<xsl:variable name="executedBy" select="/queryResult/metadata/executingPrincipal/fullName"/>
<xsl:variable name="executedAt" select="/queryResult/metadata/timeOfExecution"/>
<xsl:variable name="numberOfColumns" select="count(/queryResult/result/heading)"/>
<xsl:variable name="columnWidth" select="$bodyWidth div $numberOfColumns"/>

<!-- Note: due to use relative URL here, this XSL should be in "usual" place -->
<xsl:variable name="rb" select='document(concat("defReportRB_",$locale,".xml"))/rb'/>

<!-- Master XSLT template rule; creates an XSL FO document -->
<xsl:template match="/">
  <fo:root>
    <!-- Page setup (master) info -->
    <fo:layout-master-set>
      <xsl:call-template name="declarePageMasters"/>
    </fo:layout-master-set>
    
    <!-- Actual document content -->
    <fo:page-sequence font-size="15pt" master-reference="pages">
      <!-- Set up the header -->
      <fo:static-content flow-name="xsl-region-before">
        <xsl:call-template name="generateHeader"/>
      </fo:static-content>

      <!-- Set up the footer -->
      <fo:static-content flow-name="xsl-region-after" font-size="10pt" font-style="oblique" >
        <xsl:call-template name="generateFooter"/>
      </fo:static-content>
      
      <!-- Output the main flow (there's only one in this particular format) -->
      <fo:flow flow-name="xsl-region-body">
        <xsl:call-template name="generateBody"/>
      </fo:flow>
    </fo:page-sequence>
  </fo:root>
</xsl:template>

<!-- Generate page master declarations -->
<xsl:template name="declarePageMasters">
  <!-- Simple page master sequence of special first page with rest being identical -->
  <fo:page-sequence-master master-name="pages">
    <fo:repeatable-page-master-alternatives>
      <fo:conditional-page-master-reference page-position="first" master-reference="firstPage"/>
      <fo:conditional-page-master-reference page-position="rest" master-reference="normalPage"/>
    </fo:repeatable-page-master-alternatives>
  </fo:page-sequence-master>

  <!-- first page has no header or footer and is assumed to have title block -->
  <!-- (region after here simply allows leader through, rest is intentionally clipped) -->
  <fo:simple-page-master master-name="firstPage"
      page-height="{$pageHeight}{$units}" page-width="{$pageWidth}{$units}"
      margin-top="{$margin}{$units}" margin-bottom="{$margin}{$units}"
      margin-left="{$margin}{$units}" margin-right="{$margin}{$units}">
    <fo:region-body margin-top="0{$units}"
        margin-bottom="{$footerHeight - $fopSpaceAfterTable}{$units}"
        margin-left="0{$units}" margin-right="0{$units}"/>
    <fo:region-after extent="{$footerHeight}{$units}"/>
  </fo:simple-page-master>

  <!-- all other pages have header and footer -->
  <fo:simple-page-master master-name="normalPage"
      page-height="{$pageHeight}{$units}" page-width="{$pageWidth}{$units}"
      margin-top="{$margin}{$units}" margin-bottom="{$margin}{$units}"
      margin-left="{$margin}{$units}" margin-right="{$margin}{$units}">
    <fo:region-body margin-top="{$headerHeight}{$units}"
        margin-bottom="{$footerHeight - $fopSpaceAfterTable}{$units}"
        margin-left="0{$units}" margin-right="0{$units}"/>
    <fo:region-before extent="{$headerHeight}{$units}"/>
    <fo:region-after extent="{$footerHeight}{$units}"/>
  </fo:simple-page-master>
</xsl:template>

<!-- Generate page header -->
<xsl:template name="generateHeader">

  <!-- Repeat report title in header -->
  <fo:block font-size="9pt" font-style="oblique" text-align="start">
    <xsl:value-of select="$reportName"/>
  </fo:block>
</xsl:template>

<!-- Generate page footer -->
<xsl:template name="generateFooter">



  <!-- Footer leader (divider) -->
  <fo:block>
    <fo:leader leader-pattern="rule" leader-length.optimum="100%" color="blue" rule-thickness="{$solidRuleWidth}"/>
  </fo:block>
  
  <!-- Use table to place chunks of text at right and left margins and at the center of the footer -->
  <fo:table width="{$bodyWidth}{$units}" table-layout="fixed">
    <xsl:variable name="centerColWidth">1.1</xsl:variable>
    <xsl:variable name="sideColWidth" select="($bodyWidth - $centerColWidth) div 2"/>
    
    <!-- Declare columns -->
    <fo:table-column column-width="{$sideColWidth}{$units}"/>
    <fo:table-column column-width="{$centerColWidth}{$units}"/>
    <fo:table-column column-width="{$sideColWidth}{$units}"/>

    <!-- Create table body -->
    <fo:table-body display-align="before">
      <fo:table-row>
        
        <!-- Executing principal -->
        <fo:table-cell text-align="start">
          <fo:block>
            <xsl:value-of select="$executedBy"/>
          </fo:block>
        </fo:table-cell>
        
        <!-- Page number -->
        <fo:table-cell text-align="center">
          <fo:block>
            <fo:page-number/>
          </fo:block>
        </fo:table-cell>
        
        <!-- Executed at -->
        <fo:table-cell text-align="end">
          <fo:block>
            <xsl:value-of select="$executedAt"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-body>
  </fo:table>

  <fo:block>
            .
  </fo:block>

  <!-- Footer Disclaimer -->
  <fo:block font-size="6pt" space-after.optimum="12pt">
	                COPYRIGHT 2015 - ALL RIGHTS RESERVED. THIS DOCUMENT, CONTAINING CONFIDENTIAL AND TRADE SECRET INFORMATION, IS THE PROPERTY OF ALLEGION AND IS GIVEN TO THE RECEIVER IN CONFIDENCE, THE RECEIVER BY RECEPTION AND RETENTION OF THE DOCUMENT ACCEPTS THE DOCUMENT IN CONFIDENCE AND AGREES THAT, EXCEPT AS AUTHORIZED IN WRITING BY ALLEGION, IT WILL (1) NOT USE THE DOCUMENT OR ANY COPY THEREOF OR THE CONFIDENTIAL OR THE TRADE SECRET INFORMATION THEREIN; (2) NOT COPY THE DOCUMENT; (3) NOT DISCLOSE TO OTHERS EITHER THE DOCUMENT OR THE CONFIDENTIAL OR THE TRADE SECRET INFORMATION THEREIN; AND (4) UPON COMPLETION OF THE NEED TO RETAIN THE DOCUMENT, OR UPON DEMAND, RETURN THE DOCUMENT, ALL COPIES THEROF, AND ALL MATERIAL COPIED THEREFROM
  </fo:block>
  
</xsl:template>

<!-- Generate page body -->
<xsl:template name="generateBody">

	<fo:block space-after="12pt">
     <fo:external-graphic src="{$relatedFilesURL}" height="75px" width="100px"/>
	</fo:block>

  <!-- Title block -->
  <fo:block padding-top="3pt" padding-bottom="3pt" background-color="navy" text-align="center" font-weight="bold" font-size="18pt" space-after.optimum="12pt" color="white">
    <xsl:value-of select="$reportName"/>
  </fo:block>

  
  <!-- Generate execution information table -->
  <xsl:call-template name="generateExecutionInfoTable"/>

  <!-- Generate main results table -->
  <xsl:call-template name="generateResultsTable"/>


</xsl:template>

<!-- Generate execution information table -->
<xsl:template name="generateExecutionInfoTable">
  <fo:table font-size="12pt" width="{$bodyWidth}{$units}" table-layout="fixed">

    <!-- Declare columns -->
    <fo:table-column column-width="{($halfBodyWidth - $gutter) div 2}{$units}"/>
    <fo:table-column column-width="{$gutter}{$units}"/>
    <fo:table-column column-width="{$halfBodyWidth * 1.5}{$units}"/>

    <!-- Create table body -->
    <fo:table-body display-align="before">
    

      
      <!-- Executed At -->
      <fo:table-row>
        <fo:table-cell font-weight="bold" text-align="end">
          <fo:block><xsl:value-of select="$rb/timeOfExecutionLabel"/>:</fo:block>
        </fo:table-cell>
        <fo:table-cell>
          <fo:block/>
        </fo:table-cell>
        <fo:table-cell text-align="start">
          <fo:block>
            <xsl:value-of select="$executedAt"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>

    </fo:table-body>
  </fo:table>
</xsl:template>



<!-- Generate main results table -->
<xsl:template name="generateResultsTable">
  <fo:table width="100%" table-layout="fixed" space-before.optimum="12pt"  >

    <!-- Declare columns -->
   <fo:table-column column-width="25%"/>
   <fo:table-column column-width="25%"/> 
   <fo:table-column column-width="25%"/> 
   <fo:table-column column-width="25%"/>

    <!-- Create table header -->
    <fo:table-header display-align="after">
      <fo:table-row>
          <!-- Would really like to move color assignment up to table-row to avoid repetition,
               but this does not produce the same rendering in FOP -->
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Number</fo:block>
          </fo:table-cell>
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Name</fo:block>
          </fo:table-cell>
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Revision</fo:block>
          </fo:table-cell>     
	  <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>State</fo:block>
          </fo:table-cell> 
      </fo:table-row>
    </fo:table-header>
    
        <!-- Create table body -->
        <fo:table-body display-align="before">
    
            <xsl:choose>
                <xsl:when test="/queryResult/result/row">
        
                  <!-- For each result row -->
                    <fo:table-row>
    
                      <!-- Compute background color for row striping -->
                      <!-- NOTE: black used rather than transparent since this gives a different row width in FOP at this point -->
                      <xsl:variable name="backgroundColor">
                        <xsl:choose>
                          <xsl:when test="(position() mod 2)=0">white</xsl:when>
                          <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>        
    
                        <fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                          <fo:block>
                                <xsl:value-of select='/queryResult/result/row/NUMBER'/>
                          </fo:block> 
                        </fo:table-cell>
                        <fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                          <fo:block>
                                <xsl:value-of select='/queryResult/result/row/NAME'/>
                          </fo:block> 
                        </fo:table-cell>
                        <fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                          <fo:block>
                                <xsl:value-of select='/queryResult/result/row/REVISION'/>
                          </fo:block> 
                        </fo:table-cell>
			<fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                          <fo:block>
                                <xsl:value-of select='/queryResult/result/row/STATE'/>
                          </fo:block> 
                        </fo:table-cell>
                    </fo:table-row> 
                    
                </xsl:when>
                <xsl:otherwise>
                    <fo:table-row>  
                        <fo:table-cell>
                           <fo:block>
                           </fo:block>
                       </fo:table-cell>
                    </fo:table-row>  
                </xsl:otherwise>
            </xsl:choose>
          
        </fo:table-body>
  </fo:table>
  <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">

    <!-- Declare columns -->
    <xsl:for-each select="/queryResult/result/heading">
      <fo:table-column column-width="100%"/>
    </xsl:for-each>
    <fo:table-header>    
      <fo:table-row>
          <!-- Would really like to move color assignment up to table-row to avoid repetition,
               but this does not produce the same rendering in FOP -->
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Description</fo:block>
          </fo:table-cell>
        </fo:table-row>
    </fo:table-header>
    
        <!-- Create table body -->
        <fo:table-body display-align="before">
    
            <xsl:choose>
                <xsl:when test="/queryResult/result/row">
        
                  <!-- For each result row -->
                     <fo:table-row>
    
                      <xsl:variable name="backgroundColor">
                        <xsl:choose>
                          <xsl:when test="(position() mod 2)=0">white</xsl:when>
                          <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>        
    
                        <fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                           <fo:block linefeed-treatment="preserve">
                             <xsl:value-of select='/queryResult/result/row/DESCRIPTION'/>
                          </fo:block> 
                        </fo:table-cell>
                                          
                    </fo:table-row>        
                    
                </xsl:when>
                <xsl:otherwise>
                    <fo:table-row>  
                        <fo:table-cell>
                           <fo:block>
                           </fo:block>
                       </fo:table-cell>
                    </fo:table-row>  
                </xsl:otherwise>
            </xsl:choose>
          
        </fo:table-body>
  </fo:table>
  
  
  <fo:block>
  </fo:block>

  <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">

    <!-- Declare columns -->
   <fo:table-column column-width="50%"/>
   <fo:table-column column-width="50%"/>   
    
   
    <fo:table-header>
      <fo:table-row>
          <!-- Would really like to move color assignment up to table-row to avoid repetition,
               but this does not produce the same rendering in FOP -->
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Vendor</fo:block>
          </fo:table-cell>
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Vendor Alternative</fo:block>
          </fo:table-cell>
      </fo:table-row>           
    </fo:table-header> 
    
    <!-- Create table body -->
    <fo:table-body display-align="before">

        <xsl:choose>
            <xsl:when test="/queryResult/result/row">
    
                <fo:table-row>

                  <xsl:variable name="backgroundColor">
                    <xsl:choose>
                      <xsl:when test="(position() mod 2)=0">white</xsl:when>
                      <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>        

                    <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block>
                            <xsl:value-of select='/queryResult/result/row/Vendor'/>
                      </fo:block> 
                    </fo:table-cell>
                    <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block linefeed-treatment="preserve">
                            <xsl:value-of select='/queryResult/result/row/VendorAlternative'/>
                      </fo:block> 
                    </fo:table-cell>                 
                </fo:table-row>        
                
            </xsl:when>
            <xsl:otherwise>
                <fo:table-row>  
                    <fo:table-cell>
                       <fo:block>
                       </fo:block>
                   </fo:table-cell>
                </fo:table-row>  
            </xsl:otherwise>
        </xsl:choose>
      
    </fo:table-body>
  </fo:table>
  
    <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">
  
    <!-- Declare columns -->
   <fo:table-column column-width="50%"/>
   <fo:table-column column-width="50%"/>    
  
  
      <!-- Create table header -->
      <fo:table-header display-align="after">
        <fo:table-row>
            <!-- Would really like to move color assignment up to table-row to avoid repetition,
                 but this does not produce the same rendering in FOP -->
            <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
            	<fo:block>Deviate From</fo:block>
            </fo:table-cell>
            <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
            	<fo:block>Deviate To</fo:block>
            </fo:table-cell>
               
        </fo:table-row>
      </fo:table-header>
      
          <!-- Create table body -->
          <fo:table-body display-align="before">
      
              <xsl:choose>
                  <xsl:when test="/queryResult/result/row">
          
                    <!-- For each result row -->
                      <fo:table-row>
      
                        <!-- Compute background color for row striping -->
                        <!-- NOTE: black used rather than transparent since this gives a different row width in FOP at this point -->
                        <xsl:variable name="backgroundColor">
                          <xsl:choose>
                            <xsl:when test="(position() mod 2)=0">white</xsl:when>
                            <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>        
      
                          <fo:table-cell background-color="{$backgroundColor}">
                            <xsl:if test="position()!=last()">
                              <xsl:attribute name="end-indent">6pt</xsl:attribute>
                            </xsl:if>
                             <fo:block linefeed-treatment="preserve">
                                  <xsl:value-of select='/queryResult/result/row/DeviateFrom'/>
                            </fo:block> 
                          </fo:table-cell>
                          <fo:table-cell background-color="{$backgroundColor}">
                            <xsl:if test="position()!=last()">
                              <xsl:attribute name="end-indent">6pt</xsl:attribute>
                            </xsl:if>
                            <fo:block linefeed-treatment="preserve">
                                  <xsl:value-of select='/queryResult/result/row/DeviateTo'/>
                            </fo:block> 
                          </fo:table-cell>
                                            
                      </fo:table-row> 
                      
                  </xsl:when>
                  <xsl:otherwise>
                      <fo:table-row>  
                          <fo:table-cell>
                             <fo:block>
                             </fo:block>
                         </fo:table-cell>
                      </fo:table-row>  
                  </xsl:otherwise>
              </xsl:choose>
            
          </fo:table-body>
    </fo:table>
    <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">
        
            <!-- Declare columns -->
   <fo:table-column column-width="50%"/>
   <fo:table-column column-width="50%"/>
            
            <fo:table-header>
              <fo:table-row>
                  <!-- Would really like to move color assignment up to table-row to avoid repetition,
                       but this does not produce the same rendering in FOP -->
                  <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
                  	<fo:block>Document(Number, Name, Revision)</fo:block>
                  </fo:table-cell>
                  <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
                  	<fo:block>Approved Quantity</fo:block>
                  </fo:table-cell>              
              </fo:table-row>           
            </fo:table-header> 
    
          <!-- Create table body -->
          <fo:table-body display-align="before">
      
              <xsl:choose>
                  <xsl:when test="/queryResult/result/row">
         		 <xsl:for-each select="/queryResult/result/row[not(Document__Number__Name__Revision= preceding-sibling::row/Document__Number__Name__Revision)]">
                      <fo:table-row>
      
                        <xsl:variable name="backgroundColor">
                          <xsl:choose>
                            <xsl:when test="(position() mod 2)=0">rgb(190,190,190)</xsl:when>
                            <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>        
      
                          <fo:table-cell background-color="{$backgroundColor}">
                            <xsl:if test="position()!=last()">
                              <xsl:attribute name="end-indent">6pt</xsl:attribute>
                            </xsl:if>
                            <fo:block>
                                  <xsl:value-of select='Document_Number__Name__Revision'/>
                            </fo:block> 
                          </fo:table-cell>
                          <fo:table-cell background-color="{$backgroundColor}">
                            <xsl:if test="position()!=last()">
                              <xsl:attribute name="end-indent">6pt</xsl:attribute>
                            </xsl:if>
                            <fo:block>
                                  <xsl:value-of select='ApprovedQuantity'/>
                            </fo:block> 
                          </fo:table-cell>                 
                      </fo:table-row>        
        		</xsl:for-each>
                      
                  </xsl:when>
                  <xsl:otherwise>
                      <fo:table-row>  
                          <fo:table-cell>
                             <fo:block>
                             </fo:block>
                         </fo:table-cell>
                      </fo:table-row>  
                  </xsl:otherwise>
              </xsl:choose>
            
          </fo:table-body>
            
  </fo:table>
    <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">

    <!-- Declare columns -->
    <xsl:for-each select="/queryResult/result/heading">
      <fo:table-column column-width="100%"/>
    </xsl:for-each>
    <fo:table-header>    
      <fo:table-row>
          <!-- Would really like to move color assignment up to table-row to avoid repetition,
               but this does not produce the same rendering in FOP -->
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="1pt">
          	<fo:block>Engineering Analysis</fo:block>
          </fo:table-cell>
        </fo:table-row>
    </fo:table-header>
    
        <!-- Create table body -->
        <fo:table-body display-align="before">
    
            <xsl:choose>
                <xsl:when test="/queryResult/result/row">
        
                  <!-- For each result row -->
                     <fo:table-row>
    
                      <xsl:variable name="backgroundColor">
                        <xsl:choose>
                          <xsl:when test="(position() mod 2)=0">white</xsl:when>
                          <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>        
    
                        <fo:table-cell background-color="{$backgroundColor}">
                          <xsl:if test="position()!=last()">
                            <xsl:attribute name="end-indent">6pt</xsl:attribute>
                          </xsl:if>
                           <fo:block linefeed-treatment="preserve">
                                <xsl:value-of select='/queryResult/result/row/EngineeringAnalysis'/>
                          </fo:block> 
                        </fo:table-cell>
                                          
                    </fo:table-row>        
                    
                </xsl:when>
                <xsl:otherwise>
                    <fo:table-row>  
                        <fo:table-cell>
                           <fo:block>
                           </fo:block>
                       </fo:table-cell>
                    </fo:table-row>  
                </xsl:otherwise>
            </xsl:choose>
          
        </fo:table-body>
  </fo:table>
  
  
    
  <fo:table width="100%" table-layout="auto" space-before.optimum="12pt">

    <!-- Declare columns -->
    <xsl:for-each select="/queryResult/result/heading">
    <fo:table-column column-width="25%"/>
     <fo:table-column column-width="25%"/>
    <fo:table-column column-width="25%"/>
      <fo:table-column column-width="25%"/>
    </xsl:for-each>
    
    <fo:table-header>
      <fo:table-row>
          <!-- Would really like to move color assignment up to table-row to avoid repetition,
               but this does not produce the same rendering in FOP -->
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
          	<fo:block>Initiated By</fo:block>
          </fo:table-cell>
          <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
          	<fo:block>Started On</fo:block>
          </fo:table-cell>
	   <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
          	<fo:block>Expire By</fo:block>
          </fo:table-cell>
	   <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
          	<fo:block>Expiration Date</fo:block>
          </fo:table-cell>
      </fo:table-row>           
    </fo:table-header> 
    
    <!-- Create table body -->
    <fo:table-body display-align="before">

        <xsl:choose>
            <xsl:when test="/queryResult/result/row">
    
                <fo:table-row>

                  <xsl:variable name="backgroundColor">
                    <xsl:choose>
                      <xsl:when test="(position() mod 2)=0">white</xsl:when>
                      <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>        

                    <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block>
                            <xsl:value-of select='/queryResult/result/row/InitiatedBy'/>
                      </fo:block> 
                    </fo:table-cell>
                    <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block>
                            <xsl:value-of select='/queryResult/result/row/StartedOn'/>
                      </fo:block> 
                    </fo:table-cell> 
		     <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block>
                            <xsl:value-of select='/queryResult/result/row/ExpireBy'/>
                      </fo:block> 
                    </fo:table-cell>  
		     <fo:table-cell background-color="{$backgroundColor}">
                      <xsl:if test="position()!=last()">
                        <xsl:attribute name="end-indent">6pt</xsl:attribute>
                      </xsl:if>
                      <fo:block>
                            <xsl:value-of select='/queryResult/result/row/ExpirationDate'/>
                      </fo:block> 
                    </fo:table-cell>  
                </fo:table-row>        
                
            </xsl:when>
            <xsl:otherwise>
                <fo:table-row>  
                    <fo:table-cell>
                       <fo:block>
                       </fo:block>
                   </fo:table-cell>
                </fo:table-row>  
            </xsl:otherwise>
        </xsl:choose>
      
    </fo:table-body>
  </fo:table>
  
    
  
    <!-- creating table and filling values for Plants Impacted and Requestor Plant -->
<fo:table width="100%" table-layout="auto" space-before.optimum="12pt">
  
      <!-- Declare columns -->
      <xsl:for-each select="/queryResult/result/heading">
      <fo:table-column column-width="33%"/>
      <fo:table-column column-width="33%"/>
      <fo:table-column column-width="34%"/>    
      
        </xsl:for-each>
      
      <fo:table-header>
        <fo:table-row>
            <!-- Would really like to move color assignment up to table-row to avoid repetition,
                 but this does not produce the same rendering in FOP -->
            <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
            	<fo:block>Business Unit</fo:block>
            </fo:table-cell>
            <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
            	<fo:block>Primary Location</fo:block>
            </fo:table-cell>
	     <fo:table-cell background-color="blue" color="white" padding-top="1pt" padding-bottom="0.25pt">
            	<fo:block>Location Affected</fo:block>
            </fo:table-cell>
        </fo:table-row>           
      </fo:table-header> 
      
      <!-- Create table body -->
      <fo:table-body display-align="before">
  
          <xsl:choose>
              <xsl:when test="/queryResult/result/row">
		<xsl:for-each select="/queryResult/result/row[not(LocationAffected= preceding-sibling::row/LocationAffected)]">
      
                  <fo:table-row>
  
                    <xsl:variable name="backgroundColor">
                      <xsl:choose>
                        <xsl:when test="(position() mod 2)=0">white</xsl:when>
                        <xsl:otherwise>rgb(204,204,204)</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>        
  
                      <fo:table-cell background-color="{$backgroundColor}">
                        <xsl:if test="position()!=last()">
                          <xsl:attribute name="end-indent">6pt</xsl:attribute>
                        </xsl:if>
                        <fo:block>
                              <xsl:value-of select='/queryResult/result/row/BusinessUnit'/>
                        </fo:block> 
                      </fo:table-cell>
		      <fo:table-cell background-color="{$backgroundColor}">
                        <xsl:if test="position()!=last()">
                          <xsl:attribute name="end-indent">6pt</xsl:attribute>
                        </xsl:if>
                        <fo:block>
                              <xsl:value-of select='/queryResult/result/row/PrimaryLocation'/>
                        </fo:block> 
                      </fo:table-cell>  
                      <fo:table-cell background-color="{$backgroundColor}">
                        <xsl:if test="position()!=last()">
                          <xsl:attribute name="end-indent">6pt</xsl:attribute>
                        </xsl:if>
                        <fo:block>
                              <xsl:value-of select="LocationAffected"/>
                        </fo:block> 
                      </fo:table-cell>                 
                  </fo:table-row>        
                  </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                  <fo:table-row>  
                      <fo:table-cell>
                         <fo:block>
                         </fo:block>
                     </fo:table-cell>
                  </fo:table-row>  
              </xsl:otherwise>
          </xsl:choose>
        
      </fo:table-body>
  </fo:table>
    
    
</xsl:template>


</xsl:stylesheet>
