
#
#
# The build, release and restart targets are defined in the app, and are run at different stages of the build.
# The build and release are done on the build-server (pubhub), whereas the restart are run on each webnode
#
# Notice that the pco.json conf file is not present during the build phase, but it present during release
#

build: composer createDirectoryStructure

release: createSettings migrate publishResources

restart: flushCache warmupCache


#
# These are the general targets used for most Neos/Flow deployments
#


composer:
	composer install --no-dev


createDirectoryStructure:
	mkdir fileadmin fileadmin/_temp_ fileadmin/user_upload
	mkdir typo3conf/l10n typo3conf/ext
	mkdir typo3temp typo3temp/Cache typo3temp/compressor typo3temp/cs typo3temp/GB typo3temp/InstallToolSessions typo3temp/llxml typo3temp/locks typo3temp/pics typo3temp/_processed_ typo3temp/sprites typo3temp/temp
	mkdir uploads uploads/media uploads/pics uploads/tx_felogin


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
