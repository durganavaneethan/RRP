#!/usr/bin/python
 
import logging
import xml.dom.minidom
import glob
import logging.handlers
import sys
import xml.dom.minidom 
import xml.etree.ElementTree as ET
import subprocess
from subprocess import call

#   Function definition for Other
def functionOther():
    logging.debug('Please Enter AZURE or AWS in your config file')
    return

#   Function definition for AWS
def functionAWS():
    cloudInstanceCount = DOMTree.getElementsByTagName("cloudInstanceCount")[0]
    logging.info('Cloud Instance Count is %s' %(cloudInstanceCount.firstChild.data))

    jenkinsUsername = DOMTree.getElementsByTagName("jenkinsUsername")[0]
    logging.debug('Jenkins User name is %s' %(jenkinsUsername.firstChild.data))

    jenkinsPassword = DOMTree.getElementsByTagName("jenkinsPassword")[0]
    logging.debug('Jenkins password is %s' %(jenkinsPassword.firstChild.data))

    jenkinsCLIpath = DOMTree.getElementsByTagName("jenkinsCLIpath")[0]
    logging.debug('Jenkins CLI path is %s' %(jenkinsCLIpath.firstChild.data))

    jenkinsProjectName = DOMTree.getElementsByTagName("jenkinsProjectName")[0]
    logging.debug('Jenkins Project Name is %s' %(jenkinsProjectName.firstChild.data))

    Slaves = DOMTree.getElementsByTagName("Slaves")[0]
    logging.debug('Number of slaves is %s' %(Slaves.getAttribute('number')))

    parsetree = ET.parse("configuration/userConfig.xml")
    root = parsetree.getroot()
    
    parseJenkinsTree = ET.parse("configuration/jenkinsPlugin.xml")
    jenkinsRoot = parseJenkinsTree.getroot()

#   Get a Jenkin Plugins from Jenkins XML
    for jenkinsChild in jenkinsRoot:
        if jenkinsChild.tag == "jenkins":
            for jenkinsStepChild in jenkinsChild:
               if  jenkinsStepChild.tag == "jenkinsPlugin":
                   jenkinsPluginList.append(jenkinsStepChild.text)
    logging.debug('jenkinsPluginList has %s'%jenkinsPluginList)
    return;

#   Function definition for single Instance
def executeSingle(str):
    print "This prints a passed string into this function"
    logging.debug('Executing Application on Instance %s'%(str))
    cloudprovidername = DOMTree.getElementsByTagName("cloudProviderName")[0]
    print cloudprovidername.firstChild.data

    if cloudprovidername.firstChild.data == "AWS":
        AWSprivateKeyName = DOMTree.getElementsByTagName("AWSprivateKeyName")[0]
        AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
        AWSaccessKey = DOMTree.getElementsByTagName("AWSaccessKey")[0]
        AWSsecretKey = DOMTree.getElementsByTagName("AWSsecretKey")[0]
        AWSsecurityGroup = DOMTree.getElementsByTagName("AWSsecurityGroup")[0]
        print AWSaccessKey.firstChild.data
        print AWSprivateKeyPath.firstChild.data
        print AWSprivateKeyName.firstChild.data
        print AWSsecretKey.firstChild.data
        print AWSsecurityGroup.firstChild.data
        f = open("Templates/AWSsingle/clientSingle.tf", "w")
        f.write("#\tTerraform Script For Single Instance\n\n")
        f.close()
        startString = "START"+"AWS"
        endString = "END"+"AWS"
        with open('Templates/MasterTemplates/AWSsingleInstanceTemplate.tf') as infile, open('Templates/AWSsingle/clientSingle.tf', 'a') as outfile:
            copy = False
            for line in infile:
                if line.startswith(startString):
                   copy = True
                elif line.startswith(endString):
                   copy = False
                elif copy:
                   line = line.replace("AWSaccessKey",AWSaccessKey.firstChild.data)
                   line = line.replace("AWSsecretKey",AWSsecretKey.firstChild.data)
                   line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                   line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                   line = line.replace("AWSsecurityGroup",AWSsecurityGroup.firstChild.data)
                   outfile.write(line)
    elif cloudprovidername.firstChild.data == "AZURE":
        AZUREsubscriptionId = DOMTree.getElementsByTagName("AZUREsubscriptionId")[0]
        AZUREclientId = DOMTree.getElementsByTagName("AZUREclientId")[0]
        AZUREclientSecretKey = DOMTree.getElementsByTagName("AZUREclientSecretKey")[0]
        AZUREtenantId = DOMTree.getElementsByTagName("AZUREtenantId")[0]
        AZUREpublicKeyPath = DOMTree.getElementsByTagName("AZUREpublicKeyPath")[0]
        AZUREprivateKeyPath = DOMTree.getElementsByTagName("AZUREprivateKeyPath")[0]
        print AZUREsubscriptionId.firstChild.data
        print AZUREclientId.firstChild.data
        print AZUREclientSecretKey.firstChild.data
        print AZUREtenantId.firstChild.data
        print AZUREpublicKeyPath.firstChild.data
        print AZUREprivateKeyPath.firstChild.data
        print "Entered into azure"
        f = open("Templates/AZUREsingle/clientSingle.tf", "w")
        f.write("#\tTerraform Script For Single Instance\n\n")
        f.close()
        startString = "START"+"AZURE"
        endString = "END"+"AZURE"
        with open('Templates/MasterTemplates/AZUREsingleInstanceTemplate.tf') as infile, open('Templates/AZUREsingle/clientSingle.tf', 'a') as outfile:
            copy = False
            for line in infile:
                if line.startswith(startString):
                   copy = True
                elif line.startswith(endString):
                   copy = False
                elif copy:
                   line = line.replace("AZUREsubscriptionID",AZUREsubscriptionId.firstChild.data)
                   line = line.replace("AZUREclientID",AZUREclientId.firstChild.data)
                   line = line.replace("AZUREsecretID",AZUREclientSecretKey.firstChild.data)
                   line = line.replace("AZUREtenantID",AZUREtenantId.firstChild.data)
                   line = line.replace("AZUREpublicKey",AZUREpublicKeyPath.firstChild.data)
                   line = line.replace("AZUREprivateKey",AZUREprivateKeyPath.firstChild.data)
                   outfile.write(line)
    else:
        print "Provider name is not valid"
    return;
#   Function definition for creating Jenkins slaves
def CreateSlaves():
    Slaves = DOMTree.getElementsByTagName("Slaves")[0]
    cloudprovidername = DOMTree.getElementsByTagName("cloudProviderName")[0]
    credentials = ""
    if instanceCount > 1 and int(Slaves.getAttribute('number')) > 0:
        if cloudprovidername.firstChild.data == "AWS":
            AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
            AWSprivateKeyName = DOMTree.getElementsByTagName("AWSprivateKeyName")[0]
            AWSsecurityGroup = DOMTree.getElementsByTagName("AWSsecurityGroup")[0]
            for lines in open(AWSprivateKeyPath.firstChild.data):
                credentials = credentials + lines
            credentialtree = ET.parse('../files/credentials.xml')
            root = credentialtree.getroot()
            root[0][0][1][0][5][0].text = credentials 
            credentialtree.write('../files/credentials.xml')
            with open('Templates/AWSmultiple/clientMultiple.tf', 'a') as f1:
                i = 0
                while(i < int(Slaves.getAttribute('number'))):
                    for line in open('Templates/MasterTemplates/AWSslaveTemplate.tf'):
#                        slaveName = "RRP-Slave-" + str(i)
                        line = line.replace('jenkins-Slave','RRP-Slave'+str(i+1))
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace("AWSsecurityGroup",AWSsecurityGroup.firstChild.data)
                        f1.write(line)
                    i+=1
        elif cloudprovidername.firstChild.data == "AZURE":
            AZUREpublicKeyPath = DOMTree.getElementsByTagName("AZUREpublicKeyPath")[0]
            AZUREprivateKeyPath = DOMTree.getElementsByTagName("AZUREprivateKeyPath")[0]
            with open('Templates/AZUREmultiple/clientMultiple.tf', 'a') as f1:
                i = 0
                while(i < int(Slaves.getAttribute('number'))):
                    for line in open('Templates/MasterTemplates/AZUREslaveTemplate.tf'):
                        line = line.replace('jenkinsslave','jenkinsslave'+str(i+1))
                        line = line.replace('AZUREpublicKey',AZUREpublicKeyPath.firstChild.data)
                        line = line.replace('AZUREprivateKey',AZUREprivateKeyPath.firstChild.data)
                        f1.write(line)
                    i+=1
        else:
            print "Provider name not valid (Slave())"
            exit()
    elif instanceCount == 1 and int(Slaves.getAttribute('number')) > 0:
        if cloudprovidername.firstChild.data == "AWS":
            AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
            AWSprivateKeyName = DOMTree.getElementsByTagName("AWSprivateKeyName")[0]
            AWSsecurityGroup = DOMTree.getElementsByTagName("AWSsecurityGroup")[0]
            for lines in open(AWSprivateKeyPath.firstChild.data):
                credentials = credentials + lines
            credentialtree = ET.parse('../files/credentials.xml')
            root = credentialtree.getroot()
            root[0][0][1][0][5][0].text = credentials 
            credentialtree.write('../files/credentials.xml')
            with open('Templates/AWSsingle/clientSingle.tf', 'a') as f1:
                i = 0
                while(i < int(Slaves.getAttribute('number'))):
                    for line in open('Templates/MasterTemplates/AWSslaveTemplate.tf'):
                        line = line.replace('jenkins-Slave','RRP-Slave'+str(i+1))
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace("AWSsecurityGroup",AWSsecurityGroup.firstChild.data)
                        f1.write(line)
                    i+=1
        elif cloudprovidername.firstChild.data == "AZURE":
            AZUREpublicKeyPath = DOMTree.getElementsByTagName("AZUREpublicKeyPath")[0]
            AZUREprivateKeyPath = DOMTree.getElementsByTagName("AZUREprivateKeyPath")[0]
            with open('Templates/AZUREsingle/clientSingle.tf', 'a') as f1:
                i = 0
                while(i < int(Slaves.getAttribute('number'))):
                    for line in open('Templates/MasterTemplates/AZUREslaveTemplate.tf'):
                        line = line.replace('jenkinsslave','jenkinsslave'+str(i+1))
                        line = line.replace('AZUREpublicKey',AZUREpublicKeyPath.firstChild.data)
                        line = line.replace('AZUREprivateKey',AZUREprivateKeyPath.firstChild.data)
                        f1.write(line)
                    i+=1
        else:
            print "Provider name not valid (Slave())"
            exit()
    return;

def CreatInstances():
    if instanceCount > 1 and cloudprovidername.firstChild.data == "AWS":
        call(["./terraform","apply","Templates/AWSmultiple"])
    elif instanceCount == 1 and cloudprovidername.firstChild.data == "AWS":
        call(["./terraform","apply","Templates/AWSsingle"])
    elif instanceCount > 1 and cloudprovidername.firstChild.data == "AZURE":
        call(["./terraform","apply","Templates/AZUREmultiple"])
    elif instanceCount == 1 and cloudprovidername.firstChild.data == "AZURE":
        call(["./terraform","apply","Templates/AZUREsingle"])
    else:
        print "Provider name not valid CreateInstance()"
        exit()
    return;
    
def executeMultiInstance():
    print('multiple installtion ....... !!!')
    fm = open("Templates/AWSmultiple/clientMultiple.tf", "w")
    fm.write("#\tTerraform Script For Multiple Instances\n\n")
    fm.close()
    DOMTree = xml.dom.minidom.parse("configuration/userConfig.xml")
    AWSprivateKeyPath = DOMTree.getElementsByTagName("AWSprivateKeyPath")[0]
    AWSprivateKeyName = DOMTree.getElementsByTagName("AWSprivateKeyName")[0]
    AWSaccessKey = DOMTree.getElementsByTagName("AWSaccessKey")[0]
    AWSsecretKey = DOMTree.getElementsByTagName("AWSsecretKey")[0]
    AWSsecurityGroup = DOMTree.getElementsByTagName("AWSsecurityGroup")[0]
    print AWSprivateKeyPath.firstChild.data
    print AWSprivateKeyName.firstChild.data
    print AWSaccessKey.firstChild.data
    print AWSsecretKey.firstChild.data
    print AWSsecurityGroup.firstChild.data
    codepipe = DOMTree.documentElement
    appgroups = []
    DevDeploygroup = []
    QADeploygroup = []
    ProdDeploygroup = []
    BlueDeploy = []
    GreenDeploy = []
    Devtomcount = 0
    QAtomcount = 0
    Prodtomcount = 0
    eipline = ""

    Buildapps= codepipe.getElementsByTagName("BuildBlock")
    Testapps= codepipe.getElementsByTagName("TestBlock")
    Deployapps= codepipe.getElementsByTagName("DeployBlock")

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
                if apps.getAttribute('name') == "Dev":
                    tomcount = 0
                    Devtomcount = int(app.getAttribute('count'))
                    print apps.getAttribute('name')
                    print Devtomcount
                    applist=app.getElementsByTagName("appname")
                    grp = list()
                    for a in applist:
                        while tomcount < Devtomcount:   
                            grp.append(a.childNodes[0].data)
                            tomcount += 1
                        DevDeploygroup.append(grp)
                    print DevDeploygroup
    
                elif apps.getAttribute('name') == "QA":
                    tomcount = 0
                    QAtomcount = int(app.getAttribute('count'))
                    print apps.getAttribute('name')
                    print QAtomcount
                    applist=app.getElementsByTagName("appname")
                    grp = list()
                    for a in applist:
                        while tomcount < QAtomcount:   
                            grp.append(a.childNodes[0].data)
                            tomcount += 1
                        QADeploygroup.append(grp)
                    print QADeploygroup
                elif apps.getAttribute('name') == "Prod":
                    tomcount = 0
                    Prodtomcount = int(app.getAttribute('count'))
                    print apps.getAttribute('name')
                    print Prodtomcount
                    applist=app.getElementsByTagName("appname")
                    grp = list()
                    for a in applist:
                        while tomcount < Prodtomcount:   
                            grp.append(a.childNodes[0].data)
                            tomcount += 1
                        if apps.getAttribute('blue-green').upper() == "ON":
                            BlueDeploy.append(grp)
                            GreenDeploy.append(grp)
                            print GreenDeploy
                            print BlueDeploy
                        else:
                            ProdDeploygroup.append(grp)
                            print ProdDeploygroup
                else:
                    exit()

    copy = False
    with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
        for line in infile:
            startString = "STARTAWS" # + app.upper()
            endString = "ENDAWS" # + app.upper()
            if line.startswith(startString):
                print(startString)
                copy = True
            elif line.startswith(endString):
                copy = False
            elif copy:
                line = line.replace("AWSaccessKey",AWSaccessKey.firstChild.data)
                line = line.replace("AWSsecretKey",AWSsecretKey.firstChild.data)
                line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                outfile.write(line)
    
    endProvision=False
    multicount=0
    devtom=0
    qatom=0
    prodtom=0
    greentom=0
    bluetom=0
    awsResource = "aws_instance"
    print appgroups
    for grp in appgroups:
        # print (b)
        appcount = len(grp)
        if appcount > 1:
            print ('count is > 1 ')
            multi=True
            multicount=multicount+1
        
        
        for app in grp:
            print (app)
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                copy = False
                #print(count)
                print('Application ==> ' + app)
                copy = False
                if appcount > 1:
                    print ('Count is more than 1')
                    if multi:
                        startString = "STARTMULTIRRP" # + app.upper()
                        endString = "ENDMULTIRRP" # + app.upper()
                        multi = False
                        print('String Value is %s'%app)
                        print('startString is %s'%startString)
                        print('endString is %s'%endString)
                    
                        for line in infile:
                            if line.startswith(startString):
                                print(line)
                                copy = True
                            elif line.startswith(endString):
                                copy = False
                            elif copy:
                                print ('Multi ===>  ' + line)
                                if (line.find(awsResource) > 1):
                                    resName = (line[line.find(awsResource)+14:line.find('{')])
                                    tempstr = resName.partition('"')[2]
                                    resName = tempstr[:tempstr.find('"')]
                                    line = 'resource "aws_instance" "' + resName + '_' + str(multicount) + '" {\n'
                                    print ("Match Found ......" + resName)
                                tagname = "multirrp-" + str(multicount)
                                line = line.replace('MultiRRP',tagname)
                                line = line.replace('AWSprivateKeyPath',AWSprivateKeyPath.firstChild.data)
                                line = line.replace('AWSprivateKeyName',AWSprivateKeyName.firstChild.data)
                                line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                                outfile.write(line)
                        outfile.close()
                                    
                    # Provision
                    startString = "STARTMULTI" + app.upper() + "PROVISION"
                    endString = "ENDMULTI" + app.upper() + "PROVISION"
                    print('String Value #2 is %s'%app)
                    print('startString #2 is %s'%startString)
                    print('endString #2 is %s'%endString)
                    with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                        for line in infile:
                            # print(startString)
                            if line.startswith(startString):
                                print(startString)
                                copy = True
                            elif line.startswith(endString):
                                copy = False
                            elif copy:
                                # print ('Provision ===>  ' + line)
                                outfile.write(line)
                    endProvision=True           
                    if app.upper() == "JENKINS":
                        with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                            for line in infile:
                                if line.startswith("STARTEIP_JENKINS"):
                                    copy = True
                                elif line.startswith("ENDEIP_JENKINS"):
                                    copy = False
                                elif copy:
                                    line = line.replace("multirrp","multirrp_"+str(multicount))
                                    eipline = eipline + line;
                        print eipline
                elif appcount<=1:
                    print ('Count is less than 1 ' + app.upper())
                    with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                        copy = False
                        print('String Value is %s'%app)
                        startString = "START" + app.upper()
                        print('startString is %s'%startString)
                        endString = "END" + app.upper()
                        print('endString is %s'%endString)
                        for line in infile:
                            if line.startswith(startString):
                                copy = True
                            elif line.startswith(endString):
                                copy = False
                            elif copy:
                                line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                                line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                                line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                                outfile.write(line)
        # to add end tag for provisioner
        if endProvision:
            of = open('Templates/AWSmultiple/clientMultiple.tf', 'a')
            of.write('      "sleep 10"\n')
            of.write("    ] \n   }\n} \n")
            of.close()
        endProvision=False
    print "########"
    print appgroups
    print "#######"
    eip = open('Templates/AWSmultiple/clientMultiple.tf', 'a')
    eip.write(eipline)
    eip.close()
    
    for devdeploys in DevDeploygroup:
        for devdeploy in devdeploys:
            if devdeploy == "tomcat" or devdeploy == "docker":
                devtom = devtom + 1
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                for line in infile:
                    startString = "START" + devdeploy.upper()
                    endString = "END" + devdeploy.upper()
                    if line.startswith(startString):
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace("tomcat","DevAppDeploy"+str(devtom))
                        line = line.replace("Tomcat-RRP","DevAppDeploy"+str(devtom)+"-RRP")
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                        outfile.write(line)
    for qadeploys in QADeploygroup:
        for qadeploy in qadeploys:
            if qadeploy == "tomcat" or qadeploy == "docker":
                qatom = qatom + 1
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                for line in infile:
                    startString = "START" + qadeploy.upper()
                    endString = "END" + qadeploy.upper()
                    if line.startswith(startString):
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace("tomcat","QAAppDeploy"+str(qatom))
                        line = line.replace("Tomcat-RRP","QAAppDeploy"+str(qatom)+"-RRP")
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                        outfile.write(line)
    for greendeploys in GreenDeploy:
        for greendeploy in greendeploys:
            if greendeploy == "tomcat" or greendeploy == "docker":
                greentom = greentom + 1
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                for line in infile:
                    startString = "START" + greendeploy.upper()
                    endString = "END" + greendeploy.upper()
                    if line.startswith(startString):
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace("tomcat","G-ProdAppDeploy"+str(greentom))
                        line = line.replace("Tomcat-RRP","G-ProdAppDeploy"+str(greentom)+"-RRP")
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                        outfile.write(line)

    for bluedeploys in BlueDeploy:
        for bluedeploy in bluedeploys:
            if bluedeploy == "tomcat" or bluedeploy == "docker":
                bluetom = bluetom + 1
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                for line in infile:
                    startString = "START" + bluedeploy.upper()
                    endString = "END" + bluedeploy.upper()
                    if line.startswith(startString):
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace("tomcat","B-ProdAppDeploy"+str(bluetom))
                        line = line.replace("Tomcat-RRP","B-ProdAppDeploy"+str(bluetom)+"-RRP")
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                        outfile.write(line)

    for proddeploys in ProdDeploygroup:
        for proddeploy in proddeploys:
            if proddeploy == "tomcat" or proddeploy == "docker":
                prodtom = prodtom + 1
            with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
                for line in infile:
                    startString = "START" + proddeploy.upper()
                    endString = "END" + proddeploy.upper()
                    if line.startswith(startString):
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace("tomcat","ProdAppDeploy"+str(prodtom))
                        line = line.replace("Tomcat-RRP","ProdAppDeploy"+str(prodtom)+"-RRP")
                        line = line.replace("AWSprivateKeyPath",AWSprivateKeyPath.firstChild.data)
                        line = line.replace("AWSprivateKeyName",AWSprivateKeyName.firstChild.data)
                        line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                        outfile.write(line)
    if Devtomcount > 1:
        with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
            for line in infile:
                startString = "STARTTARGET"
                endString = "ENDTARGET"
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('RRP-target-group','RRP-Dev-target-group')
                    line = line.replace('RRPtarget','RRPDevTarget')
                    outfile.write(line)
            infile.seek(0)        
            for line in infile:
                startString = "STARTLOAD" # + app.upper()
                endString = "ENDLOAD" # + app.upper()
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                    line = line.replace('rrp-loadbalancer','rrp-dev-loadbalancer')
                    line = line.replace('RRPload','RRPDevLoad')
                    line = line.replace('RRP-front_end','RRPDev-front_end')
                    outfile.write(line)
            line = '    target_group_arn = "${aws_alb_target_group.RRPDevTarget.id}"\n    type             = "forward"\n  }\n}\n'
            outfile.write(line)
            t = 0
            multicount = 0
            devtom =0
            for devdeploys in DevDeploygroup:
                for devdeploy in devdeploys:
                    if devdeploy == "tomcat" or devdeploy == "docker":
                        devtom = devtom + 1
                        line = 'resource "aws_alb_target_group_attachment" "DevAppDeploy' + str(devtom) +'" {\n  target_group_arn = "${aws_alb_target_group.RRPDevTarget.arn}"\n  port             = 8088\n  target_id        = "${aws_instance.DevAppDeploy' + str(devtom) + '.id}"\n}\n'
                        outfile.write(line)
        outfile.close
    if QAtomcount > 1:
        with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
            for line in infile:
                startString = "STARTTARGET"
                endString = "ENDTARGET"
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('RRP-target-group','RRP-QA-target-group')
                    line = line.replace('RRPtarget','RRPQATarget')
                    outfile.write(line)
            infile.seek(0)        
            for line in infile:
                startString = "STARTLOAD" # + app.upper()
                endString = "ENDLOAD" # + app.upper()
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                    line = line.replace('rrp-loadbalancer','rrp-qa-loadbalancer')
                    line = line.replace('RRPload','RRPQALoad')
                    line = line.replace('RRP-front_end','RRPQA-front_end')
                    outfile.write(line)
            line = '    target_group_arn = "${aws_alb_target_group.RRPQATarget.id}"\n    type             = "forward"\n  }\n}\n'
            outfile.write(line)
            qatom =0
            for qadeploys in QADeploygroup:
                for qadeploy in qadeploys:
                    if qadeploy == "tomcat" or qadeploy == "docker":
                        qatom = qatom + 1
                        line = 'resource "aws_alb_target_group_attachment" "QAAppDeploy' + str(qatom) +'" {\n  target_group_arn = "${aws_alb_target_group.RRPQATarget.arn}"\n  port             = 8088\n  target_id        = "${aws_instance.QAAppDeploy' + str(qatom) + '.id}"\n}\n'
                        outfile.write(line)
        outfile.close
    if Prodtomcount > 1:
        with open('Templates/MasterTemplates/AWSmultipleInstanceTemplate.tf') as infile, open('Templates/AWSmultiple/clientMultiple.tf', 'a') as outfile:
            for line in infile:
                startString = "STARTTARGET" # + app.upper()
                endString = "ENDTARGET" # + app.upper()
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('RRP-target-group','RRP-Prod-target-group')
                    line = line.replace('RRPtarget','RRPProdTarget')
                    outfile.write(line)
            infile.seek(0)
            for line in infile:
                startString = "STARTLOAD" # + app.upper()
                endString = "ENDLOAD" # + app.upper()
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    line = line.replace('AWSsecurityGroup',AWSsecurityGroup.firstChild.data)
                    line = line.replace('rrp-loadbalancer','rrp-prod-loadbalancer')
                    line = line.replace('RRPload','RRPProdLoad')
                    line = line.replace('RRP-front_end','RRPProd-front_end')
                    outfile.write(line)
            line = '    target_group_arn = "${aws_alb_target_group.RRPProdTarget.id}"\n    type             = "forward"\n  }\n}\n'
            outfile.write(line)
            prodtom=0
            bluetom=0
            greentom=0
            for proddeploys in ProdDeploygroup:
                for proddeploy in proddeploys:
                    if proddeploy == "tomcat" or proddeploy == "docker":
                        prodtom = prodtom + 1
                        line = 'resource "aws_alb_target_group_attachment" "ProdAppDeploy' + str(prodtom) +'" {\n  target_group_arn = "${aws_alb_target_group.RRPProdTarget.arn}"\n  port             = 8088\n  target_id        = "${aws_instance.ProdAppDeploy' + str(prodtom) + '.id}"\n}\n'
                        outfile.write(line)
            for greendeploys in GreenDeploy:
                for greendeploy in greendeploys:
                    if greendeploy == "tomcat" or greendeploy == "docker":
                        greentom = greentom + 1
                        line = 'resource "aws_alb_target_group_attachment" "G-ProdAppDeploy' + str(greentom) +'" {\n  target_group_arn = "${aws_alb_target_group.RRPProdTarget.arn}"\n  port             = 8088\n  target_id        = "${aws_instance.G-ProdAppDeploy' + str(greentom) + '.id}"\n}\n'
                        outfile.write(line)

        outfile.close

    return;     

def AZUREmultiple():
    print "Multiple instance in azure"
    fm = open("Templates/AZUREmultiple/clientMultiple.tf", "w")
    fm.write("#\tTerraform Script For Multiple Instances\n\n")
    fm.close()
    DOMTree = xml.dom.minidom.parse("configuration/userConfig.xml")
    AZUREsubscriptionId = DOMTree.getElementsByTagName("AZUREsubscriptionId")[0]
    AZUREclientId = DOMTree.getElementsByTagName("AZUREclientId")[0]
    AZUREclientSecretKey = DOMTree.getElementsByTagName("AZUREclientSecretKey")[0]
    AZUREtenantId = DOMTree.getElementsByTagName("AZUREtenantId")[0]
    AZUREpublicKeyPath = DOMTree.getElementsByTagName("AZUREpublicKeyPath")[0]
    AZUREprivateKeyPath = DOMTree.getElementsByTagName("AZUREprivateKeyPath")[0]
    codepipe = DOMTree.documentElement
    appgroups = []
    tomcount = 0
    tom = 0
    apps= codepipe.getElementsByTagName("appgroup")
    appnames = codepipe.getElementsByTagName("appname")
    appName = []
    for appname in appnames:
        appName.append(appname.firstChild.data)
    # Splitting into groups
    for app in apps:
        applist=app.getElementsByTagName("appname")
        grp = list()
        for a in applist:
            if a.firstChild.data == "tomcat":
                tomcount+=1
            grp.append(a.childNodes[0].data)
        appgroups.append(grp)
    print "tomcount"
    print tomcount
    copy = False
    with open('Templates/MasterTemplates/AZUREmultipleInstanceTemplate.tf') as infile, open('Templates/AZUREmultiple/clientMultiple.tf', 'a') as outfile:
        for line in infile:
            startString = "STARTAZURE" # + app.upper()
            endString = "ENDAZURE" # + app.upper()
            if line.startswith(startString):
                copy = True
            elif line.startswith(endString):
                copy = False
            elif copy:
                # print ('Provision ===>  ' + line)
                line = line.replace('AZUREsubscriptionID',AZUREsubscriptionId.firstChild.data)
                line = line.replace('AZUREclientID',AZUREclientId.firstChild.data)
                line = line.replace('AZUREsecretID',AZUREclientSecretKey.firstChild.data)
                line = line.replace('AZUREtenantID',AZUREtenantId.firstChild.data)
                outfile.write(line) 
    outfile.close
    
    if tomcount > 1:
        with open('Templates/MasterTemplates/AZUREmultipleInstanceTemplate.tf') as infile, open('Templates/AZUREmultiple/clientMultiple.tf', 'a') as outfile:
            for line in infile:
                startString = "STARTLOAD" # + app.upper()
                endString = "ENDLOAD" # + app.upper()
                if line.startswith(startString):
                    copy = True
                elif line.startswith(endString):
                    copy = False
                elif copy:
                    outfile.write(line)
    outfile.close

    i=0
    count = 0
    while i < len(appgroups):
        print appgroups[i]
        if len(appgroups[i]) == 1:
            flag = 1
            j = 0
            while j<len(appName):
                if appgroups[i][0] == appName[j] and flag == 1:
                    if appgroups[i][0] == "tomcat":
                        tom = tom + 1
                    copy = False
                    startString = "START" + appName[j].upper()
                    endString = "END" + appName[j].upper()
                    infile = open('Templates/MasterTemplates/AZUREmultipleInstanceTemplate.tf','r')
                    outfile = open('Templates/AZUREmultiple/clientMultiple.tf', 'a')
                    for line in infile:
                        if line.startswith(startString):
                            print "in file"
                            print appName[j]
                            copy = True
                        elif line.startswith(endString):
                            copy = False
                        elif copy:
                            line = line.replace('TomcatRRP','Tomcat'+str(tom)+'RRP')
                            line = line.replace('TomcatVMPublicip','TomcatVM'+str(tom)+'Publicip')
                            line = line.replace('TomcatVMNI','TomcatVM'+str(tom)+'NI')
                            line = line.replace('TomcatVMipconfiguration','TomcatVM'+str(tom)+'ipconfiguration')
                            line = line.replace('TomcatVMRRP','TomcatVM'+str(tom)+'RRP')
                            line = line.replace('TomcatVMOSdisk','TomcatVM'+str(tom)+'OSdisk')
                            line = line.replace('tomcatvmstorageacc','tomcatvm'+str(tom)+'storageacc')
                            line = line.replace('AZUREpublicKey',AZUREpublicKeyPath.firstChild.data)
                            line = line.replace('AZUREprivateKey',AZUREprivateKeyPath.firstChild.data)
                            if tomcount > 1:
                                line = line.replace('#place for tomcat set','availability_set_id     = "${azurerm_availability_set.avset.id}"')
                                line = line.replace('#place for tomcat load','load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]')

                            outfile.write(line)
                    outfile.close()
                    infile.close()
                    flag = 0
                j+=1
        if len(appgroups[i]) > 1:
            print "multi coding"
            count+=1
            print count
            if count >= 1:
                copy = False
                startString = "STARTMULTIRRP"
                endString = "ENDMULTIRRP"
                infile = open('Templates/MasterTemplates/AZUREmultipleInstanceTemplate.tf','r')
                outfile = open('Templates/AZUREmultiple/clientMultiple.tf', 'a')
                instancename = "multirrp" + str(count)
                resourcename = "multiplerrp" + str(count)
                ipname = "multiplerrpip" + str(count)
                print instancename
                flag = 0
                for line in infile:
                    if line.startswith(startString):
                        print "in file"
                        print "MULTIRRP"
                        copy = True
                    elif line.startswith(endString):
                        copy = False
                    elif copy:
                        line = line.replace('AZUREpublicKey',AZUREpublicKeyPath.firstChild.data)
                        line = line.replace('AZUREprivateKey',AZUREprivateKeyPath.firstChild.data)
                        line = line.replace('multirrp',instancename)
                        line = line.replace('multiplerrp',resourcename)
                        line = line.replace('multiplerrpip',ipname)
                        for appgroup in appgroups[i]:
                            if appgroup == "tomcat" and tomcount > 1:
                                line = line.replace('#place for tomcat set','availability_set_id     = "${azurerm_availability_set.avset.id}"')
                                line = line.replace('#place for tomcat load','load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]')
                        outfile.write(line)
                outfile.close()
                infile.close()
                for appgroup in appgroups[i]:
                    print appgroup
                    copy = False
                    startString = "STARTMULTI" + appgroup.upper() + "PROVISION"
                    endString = "ENDMULTI" + appgroup.upper() + "PROVISION"
                    infile = open('Templates/MasterTemplates/AZUREmultipleInstanceTemplate.tf','r')
                    outfile = open('Templates/AZUREmultiple/clientMultiple.tf', 'a')
                    for line in infile:
                        if line.startswith(startString):
                            copy = True
                        elif line.startswith(endString):
                            copy = False
                        elif copy:
                            outfile.write(line)
                outfile.write('                 ]\n}\n\ttags {\n\t\tenvironment = "${var.environment}"\n\t}\n}\n')
                outfile.close()
                infile.close()
        i+=1

LOG_FILENAME = 'pipeline.log'
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

fh = logging.FileHandler(LOG_FILENAME)
fh.setFormatter(formatter)

ch = logging.StreamHandler()
ch.setFormatter(formatter)

#   Below are the log levels and their values used 
#Level      Value
#CRITICAL   50
#ERROR      40
#WARNING    30
#INFO       20
#DEBUG      10
#UNSET       0

logger = logging.getLogger()
LEVELS = { 'debug':logging.DEBUG,
            'info':logging.INFO,
            'warning':logging.WARNING,
            'error':logging.ERROR,
            'critical':logging.CRITICAL,
            }

if len(sys.argv) > 1:
    level_name = sys.argv[1]
    level = LEVELS.get(level_name, logging.NOTSET)
    logger.setLevel(level)
    if level == 10:
       fh.setLevel(logging.DEBUG)
       ch.setLevel(logging.DEBUG)
       logger.setLevel(logging.DEBUG)
    elif level == 20:
       fh.setLevel(logging.INFO)
       ch.setLevel(logging.INFO)
       logger.setLevel(logging.INFO)
    elif level == 30:
       fh.setLevel(logging.WARNING)
       ch.setLevel(logging.WARNING)
       logger.setLevel(logging.WARNING)
    elif level == 40:
       fh.setLevel(logging.ERROR)
       ch.setLevel(logging.ERROR)
       logger.setLevel(logging.ERROR)
    elif level == 50:
       fh.setLevel(logging.CRITICAL)
       ch.setLevel(logging.CRITICAL)
       logger.setLevel(logging.CRITICAL)
    else:
       fh.setLevel(logging.UNSET)
       ch.setLevel(logging.UNSET)
       logger.setLevel(logging.UNSET)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
logger.addHandler(fh)
logger.addHandler(ch)

#   Open XML document using minidom parser
DOMTree = xml.dom.minidom.parse("configuration/userConfig.xml")

#   doc.getElementsByTagName returns NodeList
cloudprovidername = DOMTree.getElementsByTagName("cloudProviderName")[0]
logging.debug('Cloud Provider Name is %s' %cloudprovidername.firstChild.data)

#codeBlockList = []
#buildBlockList = []
#testBlockList = []
#analysisBlockList = []
#deployBlockList = []
jenkinsPluginList = []
jenkinsSlaveList = []

if cloudprovidername.firstChild.data and cloudprovidername.firstChild.data.strip():
    if cloudprovidername.firstChild.data.upper() == "AWS":
         logging.debug('Inside if-function: Cloud Provider Name is %s' %(cloudprovidername.firstChild.data))
         functionAWS()
    elif cloudprovidername.firstChild.data.upper() == "AZURE":
         logging.debug('Inside if-function: Cloud Provider Name is %s' %(cloudprovidername.firstChild.data))
         functionAWS()
    else:
         logging.debug('Inside if-function: Cloud Provider Name is %s' %(cloudprovidername.firstChild.data))
         functionOther()
else:
    logging.debug('Fatal Error Occured...Please provide atleast one Provider name')
    exit()

try:
    cloudInstanceCount = DOMTree.getElementsByTagName("cloudInstanceCount")[0]
    instanceCount=int(cloudInstanceCount.firstChild.data)
    logging.debug('cloudInstanceCount contains Integer Values...Proceeding')
    if instanceCount > 1 and cloudprovidername.firstChild.data.upper() == "AWS":
        print('Multiple Instance for AWS')
        executeMultiInstance()
        logging.debug('Instance count is greater than One.....Install on multiple instances in AWS')
    elif instanceCount > 1 and cloudprovidername.firstChild.data.upper() == "AZURE":
        AZUREmultiple()
    elif instanceCount == 1:
        executeSingle("single")
        logging.debug('Instance count is One...Install all applications on single EC2 Instance')
except:
    logging.debug('cloudInstanceCount doesnt contain Integer Values...Stopping')
    exit()
CreateSlaves()
CreatInstances()

