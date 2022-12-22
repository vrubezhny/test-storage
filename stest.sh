#!/bin/sh
requestReview=false
	
	projectId="tools.wildwebdeveloper"
      	gitlabAPIToken="false-token"

	exitStatus=0
	mkdir -p target/dash
	
        dashLicenseToolJar=$(ls ~/.m2/repository/org/eclipse/dash/org.eclipse.dash.licenses/0.0.1-SNAPSHOT/org.eclipse.dash.licenses-*.jar | tail -n 1)
        echo "Dash License Tool: ${dashLicenseTool}"
        npmCommonArgs=" --no-bin-links --ignore-scripts"
        dashCommonArgs="-excludeSources local -summary target/dash/npm-deps-summary"
        
        mkdir -p target/dash # Make directory for dash-license review summary 

        dashArgs="${dashCommonArgs}"
        if [ $requestReview == true ]; then
#        if [ ${{ env.request-review }} ]; then 
          dashArgs="$dashCommonArgs -review -project $projectId -token $gitlabAPIToken" # Add "-project <Project Name> -token <Token>" here when a review is required
          echo RUNNING WITH REQUEST REVIEW: ${dashArgs}
        else
          echo RUNNING ONLY CHECK: ${dashArgs}         
        fi
  
        for p in $(find */ -print | grep -wv node_modules | grep -wv target | grep package.json)
        do 
          echo "Working $p filename ..."
          projectPath="${p%%/package.json*}"      # remove prefix '/package.json'
	  echo "Project path: ${projectPath}"
          projectName="${projectPath##*/}"        # remove longest prefix `*/`
          echo "Project name: ${projectName}"

          echo "Installing: $projectPath/$rojectName/package-lock.json"
          echo "Processing: npm install $npmCommonArgs $projectName --prefix $projectPath"
          npm install $npmCommonArgs $projectName --prefix $projectPath

          echo "Verifying: ${projectPath}/package-lock.json"
          echo "java -jar ${dashLicenseToolJar} ${dashArgs} ${projectPath}/package-lock.json"
          java -jar ${dashLicenseToolJar} ${dashArgs} ${projectPath}/package-lock.json
         if [[ $? != 0 ]]; then
           exitStatus=$? # Save for future
         fi
      done

      if [ $requestReview == true ]; then
#      if [ ${{ env.request-review }} ]; then 
        if [[ $exitStatus == 0 ]]; then # All licenses are vetted
#          echo "::set-output name=build-succeeded::$(echo 1)"
          echo "All licenses are vetted"
        else
#          echo "::set-output name=build-succeeded::$(echo 0)"
          echo "Some contents requires a review"
        fi
      else
        if [[ $? != 0 ]]; then
          echo "Committers can request a review by commenting '/request-license-review'"
#          exit 1
        fi
      fi

