import logging
import xml.dom.minidom
import logging.handlers
import sys
import xml.etree.ElementTree as ET
import boto
import os
import subprocess
from subprocess import call

DOMTree = xml.dom.minidom.parse("configuration/userConfig.xml")
codepipe = DOMTree.documentElement
appgroups = []
Buildapps = codepipe.getElementsByTagName("BuildBlock")
Testapps = codepipe.getElementsByTagName("TestBlock")
Deployapps = codepipe.getElementsByTagName("DeployBlock")
appnames = codepipe.getElementsByTagName("appname")
tomcount = 0
DeployIn = ""
# Splitting into groups
for apps in Buildapps:
    appslist=apps.getElementsByTagName("appgroup")
    for app in appslist:
        applist=app.getElementsByTagName("appname")
        grp = list()
        for a in applist:
            grp.append(a.childNodes[0].data)
        appgroups.append(grp)
for apps in Testapps:
    appslist=apps.getElementsByTagName("appgroup")
    for app in appslist:
        applist=app.getElementsByTagName("appname")
        grp = list()
        for a in applist:
            grp.append(a.childNodes[0].data)
        appgroups.append(grp)
for env in Deployapps:
    envlist=env.getElementsByTagName("Environment")
    print envlist
    for apps in envlist:
        appslist=apps.getElementsByTagName("appgroup")
        for app in appslist:
            applist=app.getElementsByTagName("appname")
            for a in applist:
                DeployIn = a.firstChild.data
                print DeployIn
            if apps.getAttribute('name') == "Dev":
                Devtomcount = int(app.getAttribute('count'))
                print apps.getAttribute('name')
                print Devtomcount
            elif apps.getAttribute('name') == "QA":
                QAtomcount = int(app.getAttribute('count'))
                print apps.getAttribute('name')
                print QAtomcount
            elif apps.getAttribute('name') == "Prod":
                Prodtomcount = int(app.getAttribute('count'))
                print apps.getAttribute('name')
                print Prodtomcount

print appgroups

print "tomcount"
print tomcount

multiposition = []
DevAppDeployUrlArr = []
QAAppDeployUrlArr = []
ProdAppDeployUrlArr = []
i = 0
while i < len(appgroups):
    if len(appgroups[i]) > 1:
        print appgroups.index(appgroups[i])
        multiposition.append(appgroups.index(appgroups[i]))
    i+=1
print multiposition


gitRepositoryName = DOMTree.getElementsByTagName("gitRepositoryName")[0]
AcceptanceTestFolderName = DOMTree.getElementsByTagName("AcceptanceTestFolderName")[0]
# Fetching the public DNS names of created instances using the instance tag names
cloudprovidername = DOMTree.getElementsByTagName("cloudProviderName")[0]
if cloudprovidername.firstChild.data == "AWS":
    AWSaccessKey = DOMTree.getElementsByTagName("AWSaccessKey")[0]
    AWSsecretKey = DOMTree.getElementsByTagName("AWSsecretKey")[0]
    print AWSsecretKey.firstChild.data
    print AWSaccessKey.firstChild.data
    ec2 = boto.connect_ec2(AWSaccessKey.firstChild.data,AWSsecretKey.firstChild.data)
    reservations = ec2.get_all_instances()
    for res in reservations:
        for inst in res.instances:
            if inst.tags['Name'] == "Jenkins-RRP" and str(inst.state) == "running":
                jenkinsurl = "http://" + inst.public_dns_name + ":8082/"
                jenkinsip = inst.ip_address
                print jenkinsurl
            if inst.tags['Name'] == "Sonarqube-RRP" and str(inst.state) == "running":
                sonarUrl = "http://" + inst.public_dns_name + ":8080/"
                print sonarUrl
            if inst.tags['Name'] == "GitBucket-RRP" and str(inst.state) == "running":
                repositoryUrl = "http://" + inst.ip_address + ":8081/git/root/" + gitRepositoryName.firstChild.data + ".git"
                print repositoryUrl
            dtomc = 0
            qtomc = 0
            ptomc = 0
            if sys.argv[1].upper() == "DEV":
                while dtomc < Devtomcount:
                    if inst.tags['Name'] == "DevAppDeploy" + str(dtomc+1) + "-RRP" and str(inst.state) == "running":
                        AppDeployUrl = inst.public_dns_name 
                        DevAppDeployUrlArr.append(AppDeployUrl)
                    dtomc+=1
            if sys.argv[1].upper() == "QA":
                while qtomc < QAtomcount:
                    if inst.tags['Name'] == "QAAppDeploy" + str(qtomc+1) + "-RRP" and str(inst.state) == "running":
                        AppDeployUrl = inst.public_dns_name 
                        QAAppDeployUrlArr.append(AppDeployUrl)
                    qtomc+=1
            if sys.argv[1].upper() == "PROD":
                while ptomc < Prodtomcount:
                    if inst.tags['Name'] == "ProdAppDeploy" + str(ptomc+1) + "-RRP" and str(inst.state) == "running":
                        AppDeployUrl = inst.public_dns_name 
                        ProdAppDeployUrlArr.append(AppDeployUrl)
                    elif inst.tags['Name'] == "G-ProdAppDeploy" + str(ptomc+1) + "-RRP" and str(inst.state) == "running":
                        AppDeployUrl = inst.public_dns_name 
                        ProdAppDeployUrlArr.append(AppDeployUrl)
                    ptomc+=1
            if inst.tags['Name'] == "SingleInstance-RRP" and str(inst.state) == "running":
                jenkinsurl = "http://" + inst.public_dns_name + ":8082/"
                jenkinsip = inst.ip_address
                repositoryUrl = "http://" + inst.ip_address + ":8081/git/root/" + gitRepositoryName.firstChild.data + ".git"
                sonarUrl = "http://" + inst.public_dns_name + ":8080/"
                tomcatUrl = "http://" + inst.public_dns_name + ":8088/manager/text"
                tomcatUrlArr.append(tomcatUrl)
                print "JenkinsUrl = " + jenkinsurl
                print "RepositoryUrl = " + repositoryUrl
                print "SonarUrl = " + sonarUrl
                print "TomcatUrls = " + str(tomcatUrlArr)
            j = 0

            while j < len(multiposition):
                if inst.tags['Name'] == "multirrp-"+ str(j+1) and str(inst.state) == "running":
                    instanceip = inst.public_dns_name
                    print instanceip
                    for apgrp in appgroups[multiposition[j]]:
                        if apgrp == "sonarqube":
                            sonarUrl = "http://" + inst.public_dns_name + ":8080/"
                        if apgrp == "gitbucket":
                            repositoryUrl = "http://" + inst.ip_address + ":8081/git/root/" + gitRepositoryName.firstChild.data + ".git"
                        if apgrp == "jenkins":
                            jenkinsurl = "http://" + inst.public_dns_name + ":8082/"
                            jenkinsip = inst.ip_address
                        if apgrp == "tomcat":
                            tomcatUrl = "http://" + inst.public_dns_name + ":8088/manager/text"
                            tomcatUrlArr.append(tomcatUrl)
                j+=1

elif cloudprovidername.firstChild.data == "AZURE":
    print cloudprovidername.firstChild.data
    multicount = 0
    tomc = 0
    for appgroup in appgroups:
        if len(appgroup) > 1:
            multicount += 1
            ipcommand = "azure vm show multipleresource multiplerrp" + str(multicount) + " |grep 'Public IP address' | awk -F ':' '{print $3}'"
            for apps in appgroup:
                if apps == "jenkins":
                    jenkinsip = subprocess.check_output(ipcommand,shell=True).rstrip('\n')
                    jenkinsurl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8082/"
                if apps == "gitbucket":
                    repositoryUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8081/git/root/" + gitRepositoryName.firstChild.data + ".git"
                if apps == "sonarqube":
                    sonarUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8080/"
                if apps == "tomcat":
                    tomcatUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8088/manager/text"
                    tomcatUrlArr.append(tomcatUrl)
        if len(appgroup) == 1:
            for apps in appgroup:
                if apps == "jenkins":
                    ipcommand = "azure vm show multipleresource JenkinsVM |grep 'Public IP address' | awk -F ':' '{print $3}'"
                    jenkinsip = subprocess.check_output(ipcommand,shell=True).rstrip('\n')
                    jenkinsurl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8082/"
                if apps == "gitbucket":
                    ipcommand = "azure vm show multipleresource GitBucketVM |grep 'Public IP address' | awk -F ':' '{print $3}'"
                    repositoryUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8081/git/root/" + gitRepositoryName.firstChild.data + ".git"
                if apps == "sonarqube":
                    ipcommand = "azure vm show multipleresource SonarqubeVM |grep 'Public IP address' | awk -F ':' '{print $3}'"
                    sonarUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8080/"
                if apps == "tomcat":
                    tomc += 1
                    ipcommand = "azure vm show multipleresource TomcatVM" + str(tomc) + "RRP |grep 'Public IP address' | awk -F ':' '{print $3}'"
                    tomcatUrl = "http://" + subprocess.check_output(ipcommand,shell=True).rstrip('\n') + ":8088/manager/text"
                    tomcatUrlArr.append(tomcatUrl)

    print "jenkinsurl = " + jenkinsurl
    print "repo url = " + repositoryUrl
    print "sonarurl = " + sonarUrl
    print "tomcaturl = " + str(tomcatUrlArr)
    
else:
    print "Please Provide Providername in userconfig.xml as AWS or AZURE"
    exit()
print "sonar url:"
print sonarUrl
print "Repo url:"
print repositoryUrl
print "jenkins url"
print jenkinsurl
print jenkinsip

# Fetching the jenkins plugins from jenkinsPlugin.xml
jenkinsPluginList = []
parseJenkinsTree = ET.parse("configuration/jenkinsPlugin.xml")
jenkinsRoot = parseJenkinsTree.getroot()
for jenkinsChild in jenkinsRoot:
    if jenkinsChild.tag == "jenkins":
        for jenkinsStepChild in jenkinsChild:
            if  jenkinsStepChild.tag == "jenkinsPlugin":
                jenkinsPluginList.append(jenkinsStepChild.text)

# Creating user and Installing the plugins mentioned in jenkinsPlugin.xml file
jenkinsUser = DOMTree.getElementsByTagName("jenkinsUsername")[0]
jenkinsPswd = DOMTree.getElementsByTagName("jenkinsPassword")[0]
jenkinsClipath = DOMTree.getElementsByTagName("jenkinsCLIpath")[0]
jenkinsProj = DOMTree.getElementsByTagName("jenkinsProjectName")[0]
Slaves = DOMTree.getElementsByTagName("Slaves")[0]

# Changing the sonar url in settings.xml inside jenkins machine
if cloudprovidername.firstChild.data == "AZURE":
    copycmd = "sshpass -p Password1234! scp -o 'StrictHostKeyChecking no' RRP@" + jenkinsip +":/home/RRP/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/conf/settings.xml ."
    copyback = "sshpass -p Password1234! scp settings.xml RRP@" + jenkinsip + ":/home/RRP/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/conf/"
elif cloudprovidername.firstChild.data == "AWS":
    AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
    copycmd = "scp -P 22 -i " + AWSprivateKeyPath.firstChild.data + " -o 'StrictHostKeyChecking no' ec2-user@" + jenkinsip +":/home/ec2-user/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/conf/settings.xml ."
    copyback = "scp -P 22 -i " + AWSprivateKeyPath.firstChild.data + " -o 'StrictHostKeyChecking no' settings.xml ec2-user@" + jenkinsip + ":/home/ec2-user/data/jenkins_data/tools/hudson.tasks.Maven_MavenInstallation/test/conf/"
print copycmd
print copyback

os.system(copycmd)

string = ""
with open('settings.xml') as infile:
    for line in infile:
        line = line.replace('sonar-url',sonarUrl)
        string = string + line
f1 = open('settings.xml','w')
f1.write(string)
f1.close()

os.system(copyback)

def SlaveConfigure():
    if cloudprovidername.firstChild.data == "AWS":
        AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
        for res in reservations:
            for inst in res.instances:
                if str(inst.tags['Name']) == "Docker-RRP" and str(inst.state) == "running":
                    print inst.tags['Name'] 
                    f = open('node/slaveConfig.xml','w')
                    f.write("<?xml version='1.0' encoding='UTF-8'?>\n")
                    f.close()
                    f1 = open('node/slaveConfig.xml','a')
                    for line in open('configuration/AWSslave.xml'):
                        line = line.replace('host-dns-name',inst.public_dns_name)
                        line = line.replace('Slave-label-name','Docker')
                        line = line.replace('Slave-name','Docker')
                        f1.write(line)
                    f1.close()
                    call(["cat","node/slaveConfig.xml"])
                    slavecmd = "java -jar %s -s %s create-node < node/slaveConfig.xml" % (jenkinsClipath.firstChild.data,jenkinsurl)
                    os.system(slavecmd)
                    copyinslave = "scp -P 22 -i " + AWSprivateKeyPath.firstChild.data + " -o 'StrictHostKeyChecking no' settings.xml ec2-user@" + inst.public_dns_name + ":/opt/apache-maven-3.3.9/conf/"
                    os.system(copyinslave)



                i = 0
                while i < int(Slaves.getAttribute('number')):
                    if str(inst.tags['Name']) == "RRP-Slave" + str(i+1) and str(inst.state) == "running":
                        print inst.tags['Name'] 
                        f = open('node/slaveConfig.xml','w')
                        f.write("<?xml version='1.0' encoding='UTF-8'?>\n")
                        f.close()
                        f1 = open('node/slaveConfig.xml','a')
                        for line in open('configuration/AWSslave.xml'):
                            line = line.replace('host-dns-name',inst.public_dns_name)
                            line = line.replace('Slave-label-name','Slave'+str(i+1))
                            line = line.replace('Slave-name','Slave'+str(i+1))
                            f1.write(line)
                        f1.close()
                        call(["cat","node/slaveConfig.xml"])
                        slavecmd = "java -jar %s -s %s create-node < node/slaveConfig.xml" % (jenkinsClipath.firstChild.data,jenkinsurl)
                        os.system(slavecmd)
                        copyinslave = "scp -P 22 -i " + AWSprivateKeyPath.firstChild.data + " -o 'StrictHostKeyChecking no' settings.xml ec2-user@" + inst.public_dns_name + ":/opt/apache-maven-3.3.9/conf/"
                        os.system(copyinslave)
                    i+=1
    if cloudprovidername.firstChild.data == "AZURE":
        for ipname in words:
            i = 0
            while i < int(Slaves.getAttribute('number')):
                if ipname == "jenkinsslave" + str(i+1) + "rrp":
                    print "slave found"
                    f = open('node/slaveConfig.xml','w')
                    f.write("<?xml version='1.0' encoding='UTF-8'?>\n")
                    f.close()
                    f1 = open('node/slaveConfig.xml','a')
                    for line in open('configuration/AZUREslave.xml'):
                        line = line.replace('host-dns-name',words[words.index(ipname) + 6])
                        line = line.replace('SlaveLabelName','Slave'+str(i+1))
                        line = line.replace('SlaveName','Slave'+str(i+1))
                        f1.write(line)
                    f1.close()
                    call(["cat","node/slaveConfig.xml"])
                    slavecmd = "java -jar %s -s %s create-node < node/slaveConfig.xml" % (jenkinsClipath.firstChild.data,jenkinsurl)
                    os.system(slavecmd)
                    copyinslave = "sshpass -p Password1234! scp -o 'StrictHostKeyChecking no' settings.xml RRP@" + words[words.index(ipname) + 6] + ":/usr/share/maven/conf/"
                    os.system(copyinslave)
                i+=1

    return;

userjen = "echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(" + '"' + jenkinsUser.firstChild.data + '","' + jenkinsPswd.firstChild.data + '")' + "'" + ' | java -jar ' + jenkinsClipath.firstChild.data + ' -s ' + jenkinsurl + ' groovy ='
print userjen
os.system(userjen)
j = 0
while j < len(jenkinsPluginList):
    call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"install-plugin",jenkinsPluginList[j],"-deploy"])
    j+=1

call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"restart"])
recheckcmd = 'while [[ $(curl -s -w "%{http_code}" ' + jenkinsurl + ' -o /dev/null) != "200" ]]; do  sleep 5; echo "Checking Connection"; done'
os.system(recheckcmd)
print "Connected"
call(["sleep","10"])


configfile = "<?xml version='1.0' encoding='"+"UTF-"+"8'?>\n"
configfile = configfile + '<flow-definition plugin="workflow-job@2.8">\n'
configfile = configfile + '  <actions/>\n'
configfile = configfile + '  <description></description>\n'
configfile = configfile + '  <keepDependencies>false</keepDependencies>\n'
configfile = configfile + '  <properties>\n'
configfile = configfile + '    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>\n'
configfile = configfile + '      <triggers/>\n'
configfile = configfile + '    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>\n'
configfile = configfile + '  </properties>\n'
configfile = configfile + '  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.23">\n'
configfile = configfile + '    <script>node {\n'
configfile = configfile + '   def mvnHome\n'
configfile = configfile + '   def dockerHome\n'
#Stage for fetching the code
configfile = configfile + '   stage(&apos;Code Checkout&apos;) { // for display purposes\n'
configfile = configfile + '      git &apos;' + repositoryUrl + '&apos;\n'
configfile = configfile + '      mvnHome = tool &apos;test&apos;\n'
configfile = configfile + '      dockerHome = tool &apos;testdocker&apos;\n'
configfile = configfile + '   }\n'
if len(sys.argv) == 2:
    if sys.argv[1].upper() == "DEV":
        #Stage for maven Build
        configfile = configfile + '   stage(&apos;Build&apos;) {\n'
        configfile = configfile + '      if (isUnix()) {\n'
        configfile = configfile + '         sh &quot;&apos;${mvnHome}/bin/mvn&apos; -Dmaven.test.failure.ignore clean package&quot;\n'
        configfile = configfile + '      } else {\n'
        configfile = configfile + '         bat(/&quot;${mvnHome}\mbin\mvn&quot; -Dmaven.test.failure.ignore clean package/)\n'
        configfile = configfile + '      }\n'
        configfile = configfile + '   }\n'
else:
    print "ERROR:\tUsage:\n\t\tpython createPipeline [pass argument for Environment type as Dev/QA/Prod]"
    exit()
#Stage for pushing the docker image to local registry
if DeployIn == "docker":
    configfile = configfile + '   stage(&apos;Pushing Docker image to Registry&apos;) {\n'
    configfile = configfile + '      sh &quot;cp ${JENKINS_HOME}/Dockerfile .&quot;\n'
    configfile = configfile + '      sh &quot;&apos;${dockerHome}/bin/docker&apos; build -t '+jenkinsip+':5000/${JOB_NAME}:${BUILD_NUMBER} .&quot;\n'
    configfile = configfile + '      sh &quot;&apos;${dockerHome}/bin/docker&apos; push '+jenkinsip+':5000/${JOB_NAME}:${BUILD_NUMBER}&quot;\n'
    configfile = configfile + '   }\n'
#Stage for Code analysis
configfile = configfile + '    stage(&apos;SonarQube analysis&apos;) {\n'
configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; sonar:sonar&quot;\n'
configfile = configfile + '  }\n'
#Stage for Unit testing
configfile = configfile + '   stage(&apos;Unit test&apos;) {\n'
configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; clean compile test&quot;\n'
configfile = configfile + '      junit &apos;**/target/surefire-reports/*.xml&apos;\n'
configfile = configfile + '      archive &apos;target/*.jar&apos;\n'
configfile = configfile + '   }\n'
#Stage for report generation
configfile = configfile + '   stage(&apos;Generate Report&apos;){\n'
configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; clean install site&quot;\n'
configfile = configfile + '      publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: &apos;target/site&apos;, reportFiles: &apos;project-reports.html&apos;, reportName: &apos;Generated Reports&apos;])\n'
configfile = configfile + '   }\n'
#Stage for Deployment
if DeployIn == "tomcat":
    if sys.argv[1].upper() == "DEV":
        configfile = configfile + '   stage(&apos;Deployment in Dev&apos;) {\n'
        for tomcatUrls in DevAppDeployUrlArr:
            configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; tomcat7:redeploy -DtomcatUrl=http://' + tomcatUrls + ':8088/manager/text&quot;\n'
        configfile = configfile + '  }\n'
    if sys.argv[1].upper() == "QA":
        configfile = configfile + '   stage(&apos;Deployment in QA&apos;) {\n'
        for tomcatUrls in QAAppDeployUrlArr:
            configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; tomcat7:redeploy -DtomcatUrl=http://' + tomcatUrls + ':8088/manager/text&quot;\n'
        configfile = configfile + '  }\n'
    if sys.argv[1].upper() == "PROD":
        configfile = configfile + '   stage(&apos;Deployment in Production&apos;) {\n'
        for tomcatUrls in ProdAppDeployUrlArr:
            configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; tomcat7:redeploy -DtomcatUrl=http://' + tomcatUrls + ':8088/manager/text&quot;\n'
        configfile = configfile + '  }\n'
elif DeployIn == "docker":
    print "taken as docker"
    if sys.argv[1].upper() == "DEV":
        configfile = configfile + '   stage(&apos;Deployment as docker container in Dev&apos;) {\n'
        for dockerUrls in DevAppDeployUrlArr:
            configfile = configfile + '      sh &quot;ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker rm -f ${JOB_NAME} || true &amp;&amp; ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker run -d --restart=always --name ${JOB_NAME} -p 8088:8080 '+jenkinsip+':5000/${JOB_NAME}:${BUILD_NUMBER} || true&quot;\n'
        configfile = configfile + '  }\n'
    if sys.argv[1].upper() == "QA":
        configfile = configfile + '   stage(&apos;Deployment as docker container in QA&apos;) {\n'
        for dockerUrls in QAAppDeployUrlArr:
            configfile = configfile + '      sh &quot;ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker rm -f ${JOB_NAME} || true &amp;&amp; ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker run -d --restart=always --name ${JOB_NAME} -p 8088:8080 '+jenkinsip+':5000/${JOB_NAME}:${BUILD_NUMBER} || true&quot;\n'
        configfile = configfile + '  }\n'
    if sys.argv[1].upper() == "PROD":
        configfile = configfile + '   stage(&apos;Deployment as docker container in Prod&apos;) {\n'
        for dockerUrls in ProdAppDeployUrlArr:
            configfile = configfile + '      sh &quot;ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker rm -f ${JOB_NAME} || true &amp;&amp; ssh -i ${JENKINS_HOME}/NEWRRP.pem -o &apos;StrictHostKeyChecking no&apos; ec2-user@' + dockerUrls + ' sudo docker run -d --restart=always --name ${JOB_NAME} -p 8088:8080 '+jenkinsip+':5000/${JOB_NAME}:${BUILD_NUMBER} || true&quot;\n'
        configfile = configfile + '  }\n'
#Stage for Acceptance testing
configfile = configfile + '   stage(&apos;Acceptence Testing&apos;) {\n'
configfile = configfile + '      sh &quot;&apos;${mvnHome}/bin/mvn&apos; -f ' + AcceptanceTestFolderName.firstChild.data + ' clean compile test &quot;\n'
configfile = configfile + '      publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: &apos;' + AcceptanceTestFolderName.firstChild.data + '/target/&apos;, reportFiles: &apos;index.html&apos;, reportName: &apos;Acceptence Test Report&apos;])\n'
configfile = configfile + '  }\n'

configfile = configfile + '}</script>\n'
configfile = configfile + '    <sandbox>true</sandbox>\n'
configfile = configfile + '  </definition>\n'
configfile = configfile + '  <triggers/>\n'
configfile = configfile + '</flow-definition>'

f = open("ProjConf.xml", "w")
f.write(configfile)
f.close()
'''
projconf = open('configuration/config.xml','r')
orgprojconf = open('ProjConf.xml','w')
for  in  appgroups:
    for apps in appgroup:
        if apps == "docker":
            for line in projconf:
                line = line.replace('#node','node("Docker"){')
                line = line.replace('repoUrl',repositoryUrl)
                line = line.replace('buildCommand','clean install -PbuildDocker')
                line = line.replace('deploymentCommand','sh &quot;docker-compose up -d&quot;')
                line = line.replace('AcceptFolder',AcceptanceTestFolderName.firstChild.data)
                orgprojconf.write(line)
        elif apps == "tomcat":
            for line in projconf:
                line = line.replace('#node','node(){')
                line = line.replace('repoUrl',repositoryUrl)
                line = line.replace('buildCommand','-Dmaven.test.failure.ignore clean package')
                line = line.replace('AcceptFolder',AcceptanceTestFolderName.firstChild.data)
                print tomcatUrlArr
                tomcatcommand = ""
                for tomcatUrls in tomcatUrlArr:
                    tomcatcommand = tomcatcommand + 'sh &quot;&apos;${mvnHome}/bin/mvn&apos; tomcat7:redeploy -DtomcatUrl=' + tomcatUrls + '&quot;\n      '
                line = line.replace('deploymentCommand',tomcatcommand)
                orgprojconf.write(line)


orgprojconf.close()
'''
print "-----------------LOGGING INTO JENKINS-----------------"
#call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"login","--username",jenkinsUser.firstChild.data,"--password",jenkinsPswd.firstChild.data])

SlaveConfigure()
listjobs = subprocess.check_output(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"list-jobs"])
jobs = listjobs.split("\n")

if any(job == jenkinsProj.firstChild.data for job in jobs):
    response = raw_input("Job exists do you want to continue with Build?(y/n): ")
    if str(response) == "y" or str(response) == "Y":
        updatecmd = "java -jar %s -s %s update-job %s < ProjConf.xml" % (jenkinsClipath.firstChild.data,jenkinsurl,jenkinsProj.firstChild.data)
        os.system(updatecmd)
        call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"build",jenkinsProj.firstChild.data,"-s","-v"])
        exit()
    elif str(response) == "n" or str(response) == "N":
        exit()
    else:
        response2 = raw_input("Please enter y or n... ")
        if str(response2) == "y" or str(response) == "Y":
            updatecmd = "java -jar %s -s %s update-job %s < ProjConf.xml" % (jenkinsClipath.firstChild.data,jenkinsurl,jenkinsProj.firstChild.data)
            os.system(updatecmd)
            call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"build",jenkinsProj.firstChild.data,"-s","-v"])
            exit()
        elif str(response2) == "n" or str(response) == "N":
            exit()
        else:
            exit()
else:
    cmd = "java -jar %s -s %s create-job %s < ProjConf.xml" % (jenkinsClipath.firstChild.data,jenkinsurl,jenkinsProj.firstChild.data)
    os.system(cmd)
    call(["java","-jar",jenkinsClipath.firstChild.data,"-s",jenkinsurl,"build",jenkinsProj.firstChild.data,"-s","-v"])
    exit()

