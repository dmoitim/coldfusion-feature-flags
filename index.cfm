<cffunction name="loadfeatureFlags" access="public" returntype="void">
    <cfset var featureFlags = {} />

    <!--- Cria uma query fictícia com dados, alterar para buscar do banco de dados --->
    <cfset featureFlagsTable = QueryNew("featureName,isActive", "varchar,boolean") />
    <cfset QueryAddRow(featureFlagsTable, 2) />
    <cfset QuerySetCell(featureFlagsTable, "featureName", "newButton", 1) />
    <cfset QuerySetCell(featureFlagsTable, "isActive", true, 1) />
    <cfset QuerySetCell(featureFlagsTable, "featureName", "anotherFeature", 2) />
    <cfset QuerySetCell(featureFlagsTable, "isActive", false, 2) />

    <cfquery name="flagQuery" dbtype="query">
        SELECT featureName,
               isActive
          FROM featureFlagsTable
    </cfquery>

    <cfloop query="flagQuery">
        <cfset featureFlags[flagQuery.featureName] = flagQuery.isActive />
    </cfloop>

    <!-- Armazena no cache -->
    <cfset application.featureFlags = featureFlags />

    <!-- Atualiza o timestamp de quando o cache foi carregado -->
    <cfset application.featureFlagsLastLoaded = now() />
</cffunction>

<cffunction name="isFeatureActive" access="public" returntype="boolean">
    <cfargument name="featureName" type="string" required="true" />

    <!-- Define o intervalo de atualização do cache em minutos -->
    <cfset cacheInterval = 1 />

    <!-- Verifica se o cache está carregado e se precisa ser atualizado -->
    <cfif (NOT structKeyExists(application, "featureFlags") OR
        dateDiff("n", application.featureFlagsLastLoaded, now()) GTE cacheInterval)>
        <cfset loadfeatureFlags() />
    </cfif>

    <!-- Retorna o estado da Feature Flag do cache -->
    <cfreturn structKeyExists(application.featureFlags, arguments.featureName) ?
        application.featureFlags[arguments.featureName] :
        false />
</cffunction>

<cfoutput>
    <h1>Minha Aplicação</h1>

    <!-- Verifica a Feature Flag para o novo botão -->
    <cfif isFeatureActive("newButton")>
        <button>New Button</button>
    </cfif>

    <br />

    <!-- Verifica a Feature Flag para outra funcionalidade -->
    <cfif isFeatureActive("anotherFeature")>
        <button>Another Feature</button>
    </cfif>

    <br /><br />
    <cfdump var="#application#" />
    <br />
    <cfdump var="#now()#" />
</cfoutput>