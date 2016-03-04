
#
#
# The build, release and restart targets are defined in the app, and are run at different stages of the build.
# The build and release are done on the build-server (pubhub), whereas the restart are run on each webnode
#
# Notice that the pco.json conf file is not present during the build phase, but it present during release
#

build: moveFilesToVersioned downloadSource createWebdir

release: createSettings migrate publishResources

restart: flushCache warmupCache


#
# These are the general targets used for most Neos/Flow deployments
#



moveFilesToVersioned:
	mkdir versioned
	mv * versioned/ 
	mv .git* versioned/
	mv versioned/Makefile .
	mv versioned/pco.yml .

downloadSource:
	curl -L -o typo3_src.tgz get.typo3.org/6.2.19
	tar -zxf typo3_src.tgz

createWebdir:
	mkdir htdocs
	cd htdocs
	ln -s ../typo3_src-6.2.19 typo3_src
	ln -s typo3_src/typo3
	ln -s typo3_src/index.php
	mkdir fileadmin
	mkdir typo3conf
	mkdir typo3temp
	mkdir uploads


#
# Since the Resource dir is a shared folder, we need to remove it before the ng-deployment can make a shared folder. If
# the folder already exists, the folder wil not be shared.
#
rmResourcesDir:
	rm -rf Web/_Resources

#
# The settings and Cache files are based on the existence of the pco.json file
#
createSettings:
	php Build/WriteSettingsFromEnvironment.php > Configuration/Settings.yaml
	php Build/WriteCacheSettingsFromEnvironment.php > Configuration/Caches.yaml


composer:
	composer install --no-dev

flushCache:
	php flow flow:cache:flush

warmupCache:
	php flow flow:cache:warmup

nodeRepair:
	php flow node:repair

clearResources:
	php flow ng:cleanresources

publishResources:
	php flow resource:publish

migrate:  createSettings
	php flow doctrine:migrate

showSetupPassword:
	cat Data/SetupPassword.txt

pruneSite:
	php flow site:prune

importSite:
	php flow site:import --package-key TYPO3.NeosDemoTypo3Org

listSites:
	php flow site:list

createRevsbechUser:
	php flow user:create "revsbech" "eo0Fiesh3foh" "Jan-Erik" "Revsbech" --roles Administrator

resetRevsbechPassword:
	php flow user:setpassword "revsbech" "eo0Fiesh3foh"

listUsers:
	php flow user:list

showSettingsConfiguration:
	./flow configuration:show --type Settings

showCacheConfiguration:
	./flow configuration:show --type Caches

#
# Various helper targets for debugging
#
listStorageFiles:
	ls -alph files/Resources/

listFiles:
	ls -alph

listSharedFiles:
	ls -alph files

listWebFiles:
	ls -alph Web
