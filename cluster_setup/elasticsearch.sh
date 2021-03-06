#This document is under progress
#!/usr/bin/env bash
sudo update

# ref: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04

# download package
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-amd64.deb

export ELASTIC_VERSION=elasticsearch-7.1.1-amd64.deb

# extract
sudo dpkg -i $ELASTIC_VERSION
#This results in Elasticsearch being installed in /usr/share/elasticsearch/ with its configuration files placed in /etc/elasticsearch and its init script added in /etc/init.d/elasticsearch.



# Note: data will be at - /var/lib/elasticsearch
# create new user - https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
#change ownership from root to elasticsearch
sudo chown -R elasticsearch:elasticsearch elasticsearch-folder


sudo systemctl enable elasticsearch
sudo systemctl restart elasticsearch
sudo systemctl status elasticsearch


	
sudo systemctl restart elasticsearch.service

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-amd64.deb
sudo dpkg -i elasticsearch-7.1.1-amd64.deb
sudo apt-get install -f

curl 10.0.0.0:9200

# ref: https://www.bmc.com/blogs/how-to-setup-elasticsearch-cluster-amazon-ec2/
curl -XGET http://172.31.46.15:9200/_cluster/health?pretty


# Challenges launching - 
error - " max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]"
#https://github.com/docker-library/elasticsearch/issues/111
sudo sysctl -w vm.max_map_count=262144


# set up = 
https://github.com/InsightDataScience/data-engineering-ecosystem/wiki/elasticsearch#setup-elasticsearch


# Setting up python client
pip install elasticsearch urllib3 requests
#https://elasticsearch-py.readthedocs.io/en/master/
#TAR: https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html
# AWS Pluging: https://www.elastic.co/guide/en/elasticsearch/plugins/current/discovery-ec2.html
# AWS Discovery: https://www.elastic.co/guide/en/elasticsearch/reference/7.1/modules-discovery-hosts-providers.html
# Create new user: https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart

# Elastic Resources -  Articles
# https://tryolabs.com/blog/2015/02/17/python-elasticsearch-first-steps/
# https://medium.com/the-andela-way/getting-started-with-elasticsearch-python-part-two-1c0c9d1117ea
# Loading to ES from
#https://www.bmc.com/blogs/write-apache-spark-elasticsearch-python/




from datetime import datetime

from elasticsearch import Elasticsearch
from elasticsearch import helpers

es = Elasticsearch()

actions = [
  {
    "_index": "tickets-index",
    "_type": "tickets",
    "_id": j,
    "_source": {
        "any":"data" + str(j),
        "timestamp": datetime.now()}
  }
  for j in range(0, 10)
]

helpers.bulk(es, actions)
# https://stackoverflow.com/questions/20288770/how-to-use-bulk-api-to-store-the-keywords-in-es-by-using-python

# SETTING UP KIBANA - 

# https://www.elastic.co/guide/en/kibana/current/targz.html#install-darwin64

# get Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.1.1-linux-x86_64.tar.gz

# extract -
sudo tar -xvf kibana-7.1.1-linux-x86_64.tar.gz -C /usr/local



# ELASTIC SEARCH
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-linux-x86_64.tar.gz -P /usr/local
cd /usr/local
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-linux-x86_64.tar.gz.sha512
sudo shasum -a 512 -c elasticsearch-7.1.1-linux-x86_64.tar.gz.sha512 
sudo tar -xzf elasticsearch-7.1.1-linux-x86_64.tar.gz
sudo mv elasticsearch-7.1.1  elasticsearch

# add bashrc profile
export ELASTICSEARCH_HOME=/usr/local/elasticsearch
export PATH=$PATH:$ELASTICSEARCH_HOME/bin

# Install AWS Plugin: https://www.elastic.co/guide/en/elasticsearch/plugins/current/discovery-ec2.html
sudo bin/elasticsearch-plugin install discovery-ec2 -y


# Note: data will be at - /var/lib/elasticsearch
# create new user - https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
sudo adduser elasticsearch

# give sudo access 
usermod -aG sudo elasticsearch

#change ownership from root to elasticsearch
sudo chown -R elasticsearch:elasticsearch /usr/local/elasticsearch

# ensure to set access to /elasticsearch/keystore
sudo chown root:elasticsearch /usr/local/elasticsearch/config/elasticsearch.keystore


# check status of cluster - 
curl -XGET 'http://10.0.0.13:9200/_cluster/health?pretty' # This should be green

# set the configurations in config/elasticsearch.yml

network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["10.0.0.13"]
cluster.initial_master_nodes: ["InsightES-N1"]
node.master: true
node.data: true


#ERROR: [1] bootstrap checks failed
#[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
sudo sysctl -w vm.max_map_count=262144

#update jvm options -  like 22/23
conf/jvm.options
# This should be green
curl -XGET 'http://10.0.0.6:9200/_cluster/health?pretty' 
GET 'http://10.0.0.6:9200/_nodes?filter_path=**.mlockall'
curl -XGET 'http://10.0.0.8:9200/_nodes?filter_path=**.mlockall'

# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-production-elasticsearch-cluster-on-ubuntu-14-04
# for a multinode cluster - enable memory locking

# 
/etc/security/limits.conf


# Set configs - 


# set following config in - /etc/elasticsearch/elasticsearch.yml for each node 
cluster.name: InsightElasticSearch
node.name: InsightElasticSearch_n1
node.master: true
node.data: true
index.number_of_shards: 1
index.number_of_replicas: 1
#enter the private IP and port of your node:
network.host: IP
http.port: 9200
#detail the private IPs of your nodes:
discovery.zen.ping.unicast.hosts: [List of IP] #all other nodes


# Instructions - 
curl -XPOST http://10.0.0.13:9200/subscribers/_bulk?pretty --data-binary @part-00003.txt -H 'Content-Type: application/json'
