import boto

exec("createPipeLineInfra.py")

if (cloudprovidername.firstChild.data=='AWS'):
    AWSaccesskey=DOMTree.getElementsByTagName("AWSaccessKey")[0]
    AWSsecretkey=DOMTree.getElementsByTagName("AWSsecretKey")[0]
#    print AWSsecretkey.firstChild.data
#    print AWSaccesskey.firstChild.data
    conn=boto.connect_ec2(AWSaccesskey.firstChild.data ,AWSsecretkey.firstChild.data)
    reservations= conn.get_all_instances()
    
