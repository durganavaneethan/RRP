import sys
import boto
import boto3
import xml.dom.minidom

DOMTree = xml.dom.minidom.parse("configuration/userConfig.xml")
AWSaccesskey=DOMTree.getElementsByTagName("AWSaccessKey")[0]
AWSsecretkey=DOMTree.getElementsByTagName("AWSsecretKey")[0]

codepipe = DOMTree.documentElement
Deployapps = codepipe.getElementsByTagName("DeployBlock")
blueids = []
greenids = []

for env in Deployapps:
    envlist=env.getElementsByTagName("Environment")
    print envlist
    for apps in envlist:
        appslist=apps.getElementsByTagName("appgroup")
        for app in appslist:
            if apps.getAttribute('name') == "Prod":
                Prodtomcount = int(app.getAttribute('count'))
                print apps.getAttribute('name')
                print Prodtomcount


ec2 = boto.connect_ec2("AKIAJGS7LXWA6BHYVWIQ","52bIxDM1fhPmkC0MGfXCGOEqV5bAauSR8ROW+HCp")
reservations = ec2.get_all_instances()
for res in reservations:
    for inst in res.instances:
        gprod = 0
        bprod = 0
        while gprod < Prodtomcount:
            if inst.tags['Name'] == "G-ProdAppDeploy"+str(gprod+1)+"-RRP" and str(inst.state) == "running":
                inst.add_tag('Name','Gtemp'+str(gprod+1)+"-RRP")
            gprod+=1
        while bprod < Prodtomcount:
            if inst.tags['Name'] == "B-ProdAppDeploy"+str(bprod+1)+"-RRP" and str(inst.state) == "running":
                inst.add_tag('Name','Btemp'+str(bprod+1)+"-RRP")
            bprod+=1
reservationstemp = ec2.get_all_instances()
for restemp in reservationstemp:
    for inst in restemp.instances:
        gprod = 0
        bprod = 0
        while gprod < Prodtomcount:
            if inst.tags['Name'] == "Gtemp"+str(gprod+1)+"-RRP" and str(inst.state) == "running":
                inst.add_tag('Name','B-ProdAppDeploy'+str(gprod+1)+"-RRP")
            gprod+=1
        while bprod < Prodtomcount:
            if inst.tags['Name'] == "Btemp"+str(bprod+1)+"-RRP" and str(inst.state) == "running":
                inst.add_tag('Name','G-ProdAppDeploy'+str(bprod+1)+"-RRP")
            bprod+=1

idreservations = ec2.get_all_instances()
for ids in idreservations:
    for inst in ids.instances:
        bprod = 0
        while bprod < Prodtomcount:
            if inst.tags['Name'] == "B-ProdAppDeploy"+str(bprod+1)+"-RRP" and str(inst.state) == "running":
                blueids.append(inst.id)
            if inst.tags['Name'] == "G-ProdAppDeploy"+str(bprod+1)+"-RRP" and str(inst.state) == "running":
                greenids.append(inst.id)
            bprod+=1

client = boto3.client('elbv2',aws_access_key_id=AWSaccesskey.firstChild.data, aws_secret_access_key=AWSsecretkey.firstChild.data,region_name='us-east-1')

response = client.describe_target_groups(
    Names=[
        'RRP-Prod-target-group',
    ]
)

for list in  response['TargetGroups']:
    targetGrpArn = list['TargetGroupArn']

for blueid in blueids:
    response = client.register_targets(
        TargetGroupArn=targetGrpArn,
        Targets=[
            {
                'Id': blueid,
                'Port': 8088
            },
        ]
    )
for greenid in greenids:
    response = client.deregister_targets(
        TargetGroupArn=targetGrpArn,
        Targets=[
            {
                'Id': greenid,
                'Port': 8088
            },
        ]
    )

