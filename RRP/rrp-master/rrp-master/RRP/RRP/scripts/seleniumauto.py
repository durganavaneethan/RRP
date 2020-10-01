import xml.dom.minidom
import boto
import fileinput
import re
import boto3
import xml.etree.ElementTree as ET
import sys
from termcolor import colored
from pprint import pprint


path="/home/ec2-user/test/demoPetclinic1/testNgMavenExample/src/test/java/com/javacodegeeks/testng/maven/TestNgMavenExample.java"
tomcatUrl=''
tomcatURLnew=''
seleniumURLnew=''
instanceTagname=''
DOMTree=xml.dom.minidom.parse("configuration/userConfig.xml")
cloudprovidername=DOMTree.getElementsByTagName("cloudProviderName")[0]
cloudInstanceCount=DOMTree.getElementsByTagName("cloudInstanceCount")[0]
instanceCount=int(cloudInstanceCount.firstChild.data)
seleniumlocation=''
#print instanceCount


"""FINDING SELENIUM LOCATION"""

tree = ET.parse("configuration/userConfig.xml")
root = tree.getroot()
print root.tag
instType=0
multiapp=0
singleapp=0
for applications in root:
    if applications.tag == 'applications':
        for appblocks in applications:
            print appblocks.tag    
            if appblocks.tag == 'BuildBlock':
                for appgroup in appblocks:
                    appcount = 0
                    for appname in appgroup:
                        appcount += 1                    
                    if appcount > 1:
                        multiapp += 1
                    elif appcount == 1:
                        singleapp += 1
            print multiapp
            print singleapp
            if appblocks.tag == 'TestBlock':
                for appgroup in appblocks:
                    appcount = 0
                    selTrack = 0
    
                    for appname in appgroup:
                        appcount += 1        
                        if appname.text == 'selenium':
                            selTrack += 1
                            print appname.text
                            print "selTrack=",selTrack
                            continue
                        if selTrack == 1:
                            break
                        
                    if appcount > 1 :
                        multiapp += 1
                    elif appcount ==1 :
                        singleapp += 1
                    
                    if selTrack == 1:
                        instType+=1
                        break   
       
print "multiapp =",multiapp
print "singleapp=",singleapp
print "instanceType=",instType
instName=''
if instType == 1:
    instName = 'multirrp-'+str(multiapp)
    print instName
#if instType == 0:
 #   instName = 'singlerrp-'+str(singleapp)
  #  print instName



print 'Initiating connection with AWS'
""" AWS code """

if (cloudprovidername.firstChild.data=='AWS'):
    AWSaccesskey=DOMTree.getElementsByTagName("AWSaccessKey")[0]
    AWSsecretkey=DOMTree.getElementsByTagName("AWSsecretKey")[0]
    print AWSsecretkey.firstChild.data
    print AWSaccesskey.firstChild.data
    conn=boto.connect_ec2(AWSaccesskey.firstChild.data ,AWSsecretkey.firstChild.data)
    reservations= conn.get_all_instances()
#    instanceTagname='multirrp-'+str(seleniumlocation)
#    print instanceTagname
#    print reservations

    instances = [i for r in reservations for i in r.instances]
    for inst in instances:
       # print inst.tags['Name']
        if ((inst.tags['Name'] == instName)and (str(inst.state)=='running')):
             print inst.ip_address
             seleniumURLnew='String selUrl="'+inst.ip_address+'";'
             print seleniumURLnew
        if inst.tags['Name'] == "Selenium-RRP" and str(inst.state) == "running":
              seleniumURLnew='String selUrl="'+inst.ip_address+'";'
              print seleniumURLnew


  #      pprint(i.__dict__)
       # pprint(i._dict_['key-name'])
    #for res in reservations:
      #  for inst in res.instances:
       #     print(inst.instance_id, inst.instance_type)



           # if ((inst.tags['Name'] == instName)and (str(inst.state)=='running')):
            #    print inst.tags['Name']
             #   print inst.ip_address
              #  seleniumURLnew='String selUrl="'+inst.ip_address+'";'
               # print seleniumURLnew
           # if inst.tags['Name'] == "Selenium-RRP" and str(inst.state) == "running":
            #    seleniumURLnew='String selUrl="'+inst.ip_address+'";'
             #   print seleniumURLnew




""" AUTOMATION CODE FOR SELENIUM """

for line in fileinput.input(path, inplace=1):
        if 'String selUrl' in line:
             line = re.sub(r'String selUrl.+',seleniumURLnew, line)
        print line,




""" AUTOMATION CODE FOR TOMCAT """

if len(sys.argv) < 2:
    print colored("---- ERROR! NO ENVORMENT MENTIONED FOR DEPLOYMENT ----","red")
    sys.exit ()
else :
    enviorment = sys.argv[1]
    client = boto3.client('elbv2',aws_access_key_id=AWSaccesskey.firstChild.data, aws_secret_access_key=AWSsecretkey.firstChild.data,region_name='us-east-1')
    try:
        if enviorment.upper() == 'DEV':
            response = client.describe_load_balancers(Names=['rrp-dev-loadbalancer',])
            for list in response['LoadBalancers']:
                tomcatUrl = list['DNSName']
                print tomcatUrl
                tomcatURLnew='String tomUrl="'+tomcatUrl+'";'
                for line in fileinput.input(path, inplace=1):
                    if 'String tomUrl' in line:
                        line = re.sub(r'String tomUrl.+',tomcatURLnew, line)
                    print line,

        if enviorment.upper() == 'QA':
            response = client.describe_load_balancers(Names=['rrp-qa-loadbalancer',])
    
            for  list in response['LoadBalancers']:
                tomcatUrl = list['DNSName']
                print tomcatUrl
                tomcatURLnew='String tomUrl="'+tomcatUrl+'";'
                for line in fileinput.input(path, inplace=1):
                    if 'String tomUrl' in line:
                        line = re.sub(r'String tomUrl.+',tomcatURLnew, line)
                    print line,
        if enviorment.upper() == 'PROD':
            response = client.describe_load_balancers(Names=['rrp-prod-loadbalancer',])
    
            for  list in response['LoadBalancers']:
                tomcatUrl = list['DNSName']
                print tomcatUrl
                tomcatURLnew='String tomUrl="'+tomcatUrl+'";'
                for line in fileinput.input(path, inplace=1):
                    if 'String tomUrl' in line:
                        line = re.sub(r'String tomUrl.+',tomcatURLnew, line)
                    print line,
    except:
        print colored("---- ERROR! LOAD BALANCER FOR "+enviorment+" NOT FOUND ----","red")

