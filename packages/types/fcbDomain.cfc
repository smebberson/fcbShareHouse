<cfcomponent displayname="Domain Manager" extends="farcry.plugins.fcblib.packages.types.fcbType" hint="Domain Manager">

<!--- object properties --->
<cfproperty ftSeq="1" name="domainName" ftLabel="Domain Name" ftfieldset="Domain Details" type="string" hint="" required="no" default="" ftHint="Comma seperated list of domain names to associate to this alias." />
<cfproperty ftSeq="2" name="homeAlias" ftLabel="Home Alias" ftfieldset="Domain Details" type="string" hint="" required="no" default="" />
<cfproperty ftSeq="3" name="footerAlias" ftLabel="Footer Alias" ftfieldset="Domain Details" type="string" hint="" required="no" default="" />
<cfproperty ftSeq="4" name="siteId" ftLabel="Site ID" ftfieldset="Domain Details" type="string" hint="" required="no" default="" blabel="1" />
<cfproperty ftSeq="5" name="primaryDomain" ftLabel="Primary Domain?" ftfieldset="Domain Details" type="boolean" hint="" required="no" default="0" ftRenderType="checkbox" />

<!--- site description --->
<cfproperty ftSeq="10" ftFieldset="Site Description" name="siteTitlePrefix" type="string" default="" hint="???" ftLabel="Site title prefix" ftType="string" />
<cfproperty ftSeq="11" ftFieldset="Site Description" name="siteTitle" type="string" default="" hint="???" ftLabel="Site title" ftType="string" />
<cfproperty ftSeq="12" ftFieldset="Site Description" name="siteTitleSuffix" type="string" default="" hint="???" ftLabel="Site title suffix" ftType="string" />
<cfproperty ftSeq="13" ftFieldset="Site Description" name="siteTagline" type="string" default="" hint="???" ftLabel="Site tag line" ftType="string" />

<cfproperty ftSeq="20" ftFieldset="Site Description" name="metaKeywords" type="string" default="" hint="???" ftLabel="Meta keywrods" ftType="string" />
<cfproperty ftSeq="21" ftFieldset="Site Description" name="metaDescription" type="string" default="" hint="???" ftLabel="Meta description" ftType="string" />
<cfproperty ftSeq="22" ftFieldset="Site Description" name="searchBoxDefaultText" type="string" default="Enter keywords..." hint="???" ftLabel="Search box text" ftType="string" />
<cfproperty ftSeq="23" ftFieldset="Site Description" name="footerText" type="string" default="&copy; Website name" hint="???" ftLabel="Footer Text" ftType="string" />

<cfproperty ftSeq="30" ftFieldset="Site Logo" name="logoTitle" type="string" default="" hint="???" ftLabel="Logo title" ftType="string" />
<cfproperty ftSeq="31" ftFieldset="Site Logo" name="logoPath" type="string" default="/logo.png" hint="???" ftLabel="Logo path" ftType="string" />
<cfproperty ftSeq="32" ftFieldset="Site Logo" name="logoAlt" type="string" default="" hint="???" ftLabel="Logo alt text" ftType="string" />

<cfproperty ftSeq="40" ftFieldset="Google Analytics" name="analyticsKeyid" type="string" default="" hint="???" ftLabel="Key ID" ftType="string" />
<cfproperty ftSeq="41" ftFieldSet="Google Analytics" name="bAnalyticsActive" type="boolean" fttype="boolean" ftrendertype="checkbox" hint="" ftLabel="Active?" default="0">

<cfproperty ftSeq="60" ftFieldset="Secure Login" name="bEnableLogin" type="boolean" default="0" hint="" ftLabel="Enable Secure login?" />

<cffunction name="init" hint="Domain Manager edit handler" returntype="void">
	
	<cfset var stNavIdMap = structNew()>			
	<cfset var stDomainManager = structNew()>
	
	<cfset application.domainManager = structNew()>

	<!--- loop through all registered primary domains and build the struct --->
	<cfquery name="q" datasource="#application.dsn#">
		SELECT objectid, domainName, homeAlias, footerAlias, siteId, primaryDomain,  
		siteTitlePrefix, siteTitle, siteTitleSuffix, siteTagline, 
		metaKeywords, metaDescription, searchBoxDefaultText, footerText, 
		logoTitle, logoPath, logoAlt, analyticsKeyid, bAnalyticsActive, bEnableLogin
		FROM fcbDomain
	</cfquery>
	
	<cfif q.recordCount>
		<cfloop query="q">		
	
			<cfloop index="listElement" list="#q.domainName#"> 
			    <cfscript>
					stDomainManager['#listElement#'] = structNew();
					stDomainManager['#listElement#'].objectid = trim(q.objectid);
					stDomainManager['#listElement#'].homeAlias = trim(q.homeAlias);
					stDomainManager['#listElement#'].footerAlias = trim(q.footerAlias);
					stDomainManager['#listElement#'].siteId = trim(q.siteId);
					stDomainManager['#listElement#'].primaryDomain = trim(q.primaryDomain);
					
					stDomainManager['#listElement#'].siteTitlePrefix = trim(q.siteTitlePrefix);
					stDomainManager['#listElement#'].siteTitle = trim(q.siteTitle);
					stDomainManager['#listElement#'].siteTitleSuffix = trim(q.siteTitleSuffix);
					stDomainManager['#listElement#'].siteTagline = trim(q.siteTagline);
				
					stDomainManager['#listElement#'].metaKeywords = trim(q.metaKeywords);
					stDomainManager['#listElement#'].metaDescription = trim(q.metaDescription);
					stDomainManager['#listElement#'].searchBoxDefaultText = trim(q.searchBoxDefaultText);
					stDomainManager['#listElement#'].footerText = trim(q.footerText);
					
					stDomainManager['#listElement#'].logoTitle = trim(q.logoTitle);
					stDomainManager['#listElement#'].logoPath = trim(q.logoPath);
					stDomainManager['#listElement#'].logoAlt = trim(q.logoAlt);
					
					stDomainManager['#listElement#'].analyticsKeyid = trim(q.analyticsKeyid);
					stDomainManager['#listElement#'].bAnalyticsActive = trim(q.bAnalyticsActive);


					stDomainManager['#listElement#'].bEnableLogin = trim(q.bEnableLogin);					
				</cfscript>
			</cfloop>
			
		</cfloop>	
	</cfif>
	
	<cfset application.domainManager.stDomains = stDomainManager />
		
</cffunction>

<cffunction name="setCurrentDomainData" hint="Domain Data" returntype="void">
	
	<!--- If current URL doesn't have any parameter and current domain name is not the primary domain, redirect to the correct URL for the sub domain --->
	<cfif len(CGI.QUERY_STRING) LTE 0>
		<cfloop collection="#application.domainManager.stDomains#" item="i">
			
			<cfset alias = application.domainManager.stDomains['#i#'].homeAlias />
			<cfset homeRootId = application.navid[alias] />
			
			<cfif i EQ CGI.HTTP_HOST AND NOT application.domainManager.stDomains['#i#'].primaryDomain>
				<cflocation url="http://#i#/index.cfm?objectid=#homeRootId#" addtoken="false">
			</cfif>	
		</cfloop>		
	</cfif>
	
	<cfset request.currentDomainData = getCurrentDomainData() />
	
</cffunction>

<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
	<cfargument name="stProperties" required="true" type="struct">
	<cfargument name="stFields" required="true" type="struct">
	<cfargument name="stFormPost" required="false" type="struct">		
	
	<cfset arguments.stProperties.domainName = trim(replaceNoCase(arguments.stProperties.domainName,'http://','','all')) />
	
	<cfreturn super.BeforeSave(argumentCollection="#arguments#") />
</cffunction>

 <cffunction name="addRow">
    <cfargument name="query" />

    <cfset QueryAddRow(arguments.query, 1) />
    <cfset lFields = StructKeyList(arguments) />
    <cfloop index="field" list="#lFields#">
        <cfif field neq 'query'>
            <cfset QuerySetCell(arguments.query, field, arguments[field]) />
        </cfif>
    </cfloop>

    <cfreturn arguments />
</cffunction>

<cffunction name="getDefaultDomainData" hint="" returntype="query">
	<cfset var q = queryNew('homeAlias,footerAlias,siteId,primaryDomain') />
	
	<cfquery name="q" datasource="#application.dsn#">
		SELECT objectid, domainName, homeAlias, footerAlias, siteId, primaryDomain,  
		siteTitlePrefix, siteTitle, siteTitleSuffix, siteTagline, 
		metaKeywords, metaDescription, searchBoxDefaultText, footerText, 
		logoTitle, logoPath, logoAlt, analyticsKeyid, bAnalyticsActive,bEnableLogin
		FROM fcbDomain
		WHERE primaryDomain = 1
		LIMIT 0,1
	</cfquery>
	
	<cfreturn q />
</cffunction>

<cffunction name="getCurrentDomainData" hint="" returntype="struct">
	<cfset var stReturn = StructNew() />
	
	<!--- Set up domain details --->
	<cfif isDefined('application.domainManager.stDomains') AND structKeyExists(application.domainManager.stDomains,cgi.http_host)>
		<cfscript>
			stReturn.domainName = cgi.http_host;
			stReturn.objectid = application.domainManager.stDomains['#cgi.http_host#'].objectid;
			stReturn.homeAlias = application.domainManager.stDomains['#cgi.http_host#'].homeAlias;
			stReturn.footerAlias = application.domainManager.stDomains['#cgi.http_host#'].footerAlias;
			stReturn.siteId = application.domainManager.stDomains['#cgi.http_host#'].siteId;
			stReturn.primaryDomain = application.domainManager.stDomains['#cgi.http_host#'].primaryDomain;
		
			stReturn.siteTitlePrefix = application.domainManager.stDomains['#cgi.http_host#'].siteTitlePrefix;
			stReturn.siteTitle = application.domainManager.stDomains['#cgi.http_host#'].siteTitle;
			stReturn.siteTitleSuffix = application.domainManager.stDomains['#cgi.http_host#'].siteTitleSuffix;
			stReturn.siteTagline = application.domainManager.stDomains['#cgi.http_host#'].siteTagline;
		
			stReturn.metaKeywords = application.domainManager.stDomains['#cgi.http_host#'].metaKeywords;
			stReturn.metaDescription = application.domainManager.stDomains['#cgi.http_host#'].metaDescription;
			stReturn.searchBoxDefaultText = application.domainManager.stDomains['#cgi.http_host#'].searchBoxDefaultText;
			stReturn.footerText = application.domainManager.stDomains['#cgi.http_host#'].footerText;
			
			stReturn.logoTitle = application.domainManager.stDomains['#cgi.http_host#'].logoTitle;
			stReturn.logoPath = application.domainManager.stDomains['#cgi.http_host#'].logoPath;
			stReturn.logoAlt = application.domainManager.stDomains['#cgi.http_host#'].logoAlt;
			
			stReturn.analyticsKeyid = application.domainManager.stDomains['#cgi.http_host#'].analyticsKeyid;
			stReturn.bAnalyticsActive = application.domainManager.stDomains['#cgi.http_host#'].bAnalyticsActive;

			stReturn.bEnableLogin = application.domainManager.stDomains['#cgi.http_host#'].bEnableLogin;		
		</cfscript>
	<cfelse>
		<!--- grab the defult domain data --->
		<cfscript>
			qDefaultDomainData = getDefaultDomainData();
			
			stReturn = structNew();
			
			stReturn.domainName = listGetAt(qDefaultDomainData.domainName,1);
			stReturn.objectid = qDefaultDomainData.objectid;
			stReturn.homeAlias = qDefaultDomainData.homeAlias;
			stReturn.footerAlias = qDefaultDomainData.footerAlias;
			stReturn.siteId = qDefaultDomainData.siteId;
			stReturn.primaryDomain = qDefaultDomainData.primaryDomain;
		
			stReturn.siteTitlePrefix = qDefaultDomainData.siteTitlePrefix;
			stReturn.siteTitle = qDefaultDomainData.siteTitle;
			stReturn.siteTitleSuffix = qDefaultDomainData.siteTitleSuffix;
			stReturn.siteTagline = qDefaultDomainData.siteTagline;
		
			stReturn.metaKeywords = qDefaultDomainData.metaKeywords;
			stReturn.metaDescription = qDefaultDomainData.metaDescription;
			stReturn.searchBoxDefaultText = qDefaultDomainData.searchBoxDefaultText;
			stReturn.footerText = qDefaultDomainData.footerText;
			
			stReturn.logoTitle = qDefaultDomainData.logoTitle;
			stReturn.logoPath = qDefaultDomainData.logoPath;
			stReturn.logoAlt = qDefaultDomainData.logoAlt;
			
			stReturn.analyticsKeyid = qDefaultDomainData.analyticsKeyid;
			stReturn.bAnalyticsActive = qDefaultDomainData.bAnalyticsActive;
			
			stReturn.bEnableLogin = qDefaultDomainData.bEnableLogin;			
		</cfscript>
	</cfif>
	
	<cfreturn stReturn />
</cffunction>

<cffunction name="getDomainList" hint="" returntype="string">
	<cfset var lValues = '' />
	<cfset var q = queryNew('name,value') />
	
	<cfquery name="q" datasource="#application.dsn#">
		SELECT label AS name, homeAlias
		FROM fcbDomain
	</cfquery>
	
	<cfif q.recordCount GT 0>
		<cfloop query="q">
			<cfset domainName = replaceNoCase(q.name,'http://','','all') />
			
			<cfset lValues = listAppend(lValues, '#q.homeAlias#:#domainName#') />
		</cfloop>		
	</cfif>
	
	<cfreturn lValues />
</cffunction>

<cffunction name="ArrayUnique" access="public" returntype="array" output="false">
	<cfargument name="array" type="array" required="yes" hint="The original array" />
	<cfset var result = ArrayNew(1)>

	<!--- Create a linked hashset java object as it has: 1) unique key and 2) order --->
	<cfset var lhs = createObject("java", "java.util.LinkedHashSet").init(arguments.array)>
	<cfset result = lhs.toArray()>
	
	<cfreturn result>

</cffunction>

<cffunction name="ListUnique" access="public" returntype="string" output="false">
	<cfargument name="list" type="string" required="yes" hint="The original list" />
	<cfargument name="delimiter" type="string" required="no" default="," hint="The list delimiter" />

	<!--- Convert it to array to use the arrayUnique function --->
	<cfset var result = arrayToList(this.ArrayUnique(listToArray(arguments.list, arguments.delimiter)), arguments.delimiter)>
	
	<cfreturn result>

</cffunction>

<cffunction name="filterByDomain" returntype="query">
    <cfargument name="query" />
	<cfset var qReturn = arguments.query />
	<cfset var lInvalidObjectids = '' />
	<cfset var lValidObjectids = '' />
	<cfset var lDomainTypes = '' />
	
	<cfif arguments.query.recordCount>
		<cfloop query="arguments.query">
			
			<!--- check to see if the typename has 'aDomains' --->
			<cfif StructKeyExists(application.fapi.getContentType(qReturn.typename).getPropsAsStruct(), 'aDomains')>
			
				<cfset lDomainTypes = ListAppend(lDomainTypes, qReturn.typename) />
			
			</cfif>
			
		</cfloop>
		<cfif listLen(lDomainTypes)>
		
			<!--- get objectids that belong to a domain type --->
			<cfquery name="qDomainObjectids" dbtype="query">
				SELECT objectid, typename
				FROM arguments.query
				WHERE typename IN (<cfqueryparam list="true" value="#lDomainTypes#">)
			</cfquery>
			
			<cfquery name="qUniqueTypes" dbtype="query">
				SELECT DISTINCT typename
				FROM arguments.query
			</cfquery>
		
			<!--- loop through each unique type and filter out invalid objects --->
			<cfloop query="qUniqueTypes">
			
				<cfquery name="qUniqueTypeObjectids" dbtype="query">
					SELECT *
					FROM arguments.query
					WHERE typename = <cfqueryparam value="#qUniqueTypes.typename#">
				</cfquery>
				
				<cfquery name="qTemp" datasource="#application.dsn#">				
					SELECT parentid, data, fcbDomain.label
					FROM #qUniqueTypeObjectids.typename#_aDomains 
					JOIN fcbDomain ON fcbDomain.objectid = #qUniqueTypeObjectids.typename#_aDomains.data
					WHERE #qUniqueTypeObjectids.typename#_aDomains.data != <cfqueryparam cfsqltype="string" value="#getCurrentDomainData().objectid#">
					AND parentid IN (<cfqueryparam list="true" value="#valueList(qUniqueTypeObjectids.objectid)#">)
				</cfquery>
		
				<cfset lInvalidObjectids = ListAppend(lInvalidObjectids, ValueList(qTemp.parentid)) />
				
				<!--- make a valid list from those that were left over --->
				<cfquery name="qTemp" datasource="#application.dsn#">				
					SELECT parentid, data, fcbDomain.label
					FROM #qUniqueTypeObjectids.typename#_aDomains 
					JOIN fcbDomain ON fcbDomain.objectid = #qUniqueTypeObjectids.typename#_aDomains.data
					WHERE #qUniqueTypeObjectids.typename#_aDomains.data = <cfqueryparam cfsqltype="string" value="#getCurrentDomainData().objectid#">
					AND parentid IN (<cfqueryparam list="true" value="#valueList(qUniqueTypeObjectids.objectid)#">)
				</cfquery>
				
				<cfset lValidObjectids = ListAppend(lValidObjectids, ValueList(qTemp.parentid)) />
				
			</cfloop>
			
			<!--- remove duplicate invalid ids --->
			<cfset lInvalidObjectids = ListUnique(lInvalidObjectids) />
			
			<!--- remove all valid objects from the invalid objects list --->
			<cfloop list="#lValidObjectids#" index="i">
				<cfset listIndex = ListFind(lInvalidObjectids, i) />
				<cfif listIndex GT 0><cfset lInvalidObjectids = ListDeleteAt(lInvalidObjectids, listIndex) /></cfif>
			</cfloop>
			
			<cfif listLen(lInvalidObjectids)>
				
				<!--- filter on current domain --->
				<cfquery name="qReturn" dbtype="query">
					SELECT *
					FROM qReturn
					WHERE objectid NOT IN (<cfqueryparam list="true" value="#lInvalidObjectids#">)
				</cfquery>
				
			</cfif>
		
		</cfif>
		

	
	</cfif>
	
	<cfreturn qReturn />
</cffunction>

</cfcomponent>