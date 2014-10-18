title: Immutable Infrastructure Persistence
author:
  name: Ian Blenke
  twitter: ianblenke
  url: http://ianblenke.github.io/immutable-infrastructure-persistence
output: index.html
controls: true

--

### Immutable Infrastructure Persistence
#### 12factor, Docker, PaaS (Dokku/Deis), and Fleet
## Ian Blenke @ianblenke
## ![http://goo.gl/fkHHRA](http://goo.gl/fkHHRA.qr)
## http://goo.gl/fkHHRA

--

### Persistence

* "Bits on disk"
* Reboot safely
* Consistency
* Availability
* Partitionability

--

### Immutable Infrastructure

* Golden **Images**
* Running **Containers**
* Temporary filesystem
* No Persistence

--

### Current "best practice"

* Separate Persistence layers from Immutable Infrastructure application deployment layers
* Manage Persistence layers with convergence tools
  * Chef
  * Puppet
  * Ansible
  * SALT
  * cfengine2
  * cfengine/isconf/Makefiles...

--

### Platform-as-a-Service (PaaS)

* Dynamically scalable
* Rolling deploys

--

### PaaS Examples

* Heroku (git push, PaaS/SaaS)
* Dokku (git push, Docker, 100 lines of Bash!)
* Deis (git push, CoreOS/Fleet/Docker)
* OpenShift (git push, ProjectAtomic/Geard/Docker)
* CloudFoundry (command push, Warden and Mesos or Docker)
* Apache Stratos (Apache Mesos)
* Longshoreman (command push, Docker)
* Flynn
* Others

--

### Heroku [12factor](http://12factor.net) Methodology

* Declarative formats automate and document
* Clean contract for containers
* Minimize divergence
* Scale with minimal tooling changes

--

### Heroku deployment model

* Heroku buildpacks
  * git project auto-detection
  * dyno "images" compiled at deploy time
* dyno "workers" run containerized images
* Environment variables for app settings

--

### Docker

* Images
* Volumes
* Ports
* Environment variables
* Links (NAME_TCP_5000_ADDR/NAME_TCP_5000_PORT)
* Containers

--


### Dokku "Contract"

* Same deploy model as Heroku
* Only 1 host
* progrium/buildstep generated docker images
* Very simple: 100 lines of bash

--

### Deis "Contract"

* Same deploy model as Heroku
* etcd/systemd/fleet unit based deployment
* deisctl orchestrates unit deployment and deis upgrades
* deis command wraps user and application configuration
* docker images built by deis-builder during git push
  * progrium/buildstep generated slug wrapped in a slug runner
  * include ENV metadata layers from application settings
* Rolling version deployments
* per-application memory/cpu constraints

--

### Deis Fleet Units

* deis-controller - django RESTful interface, coordinator
* deis-builder - slug builder
* deis-publisher - docker event relay
* deis-router - nginx reverse proxy
* deis-registry - docker private image repo
* deis-logger - "deis logs" collector and wrapper
* deis-database - postgresql + wal-e
* deis-store-gateway - ceph radosgw (S3)
* deis-store-daemon - ceph osd (storage)
* deis-store-monitor - ceph monitor

--

### What is Fleet?

* Submits systemd units to member machines
* Part of the CoreOS project
* Written in go
* Built on etcd's RAFT/GOSSIP CAP theory clustering
* Allows for complex scheduling of units given constraints
* As of Fleet 0.8.0+, units can now be "Global" and automatically run on all member nodes

--

### Issues with Fleet

* Dependency on systemd. **Everyone loves systemd**
* Fleet versions younger than 0.7.4 or so get confused as to the actual state of the units
* Fleet versions younger than 0.8.3 have "zombie units" that cannot be killed
* Fleet 0.9.0 is promised to "fairly" spread units based on system load

--

### Issues with etcd

* Disk latency currently causes flapping
  * **peer-election-timeout: 2000**
  * **peer-heartbeat-interval: 500**
* Next major version of etcd will allow delayed writes
* Only 9 members will participate in leader election
  * If more than 4 of these are lost, quorum is lost, and etcd key/value store goes read-only
* Hundreds of fleet nodes will hammer the master/leaders
* Automated node removal timer defaults to a week

--

### Issues with coreos

* alpha/beta/stable
* Rapid upgrade cycles fixing issues with etcd/fleet
* btrfs volumes "fill up" yet still show space
* Upgrading coreos safely with locksmith and omaha protocol

--

### Other Example Fleet Units

* [ianblenke/coreos-vagrant-kitchen-sink](https://github.com/ianblenke/coreos-vagrant-kitchen-sink)
* Vagrant CoreOS with self-orchestrated:
  * Flannel (VPN)
  * Kubernetes (YAML based orchestration)
  * libswarm (Docker API reverse proxy)
  * Panamax (YAML/web based orchestration)
  * Kibana, Logstash, Logspout, ElasticSearch
  * Heapster, Grafana, Influxdb, cadvisor
  * Galera MySQL
  * Zookeeper
  * Many others to come

--

### Data "in flight"

* If containers are stopped, their volumes disappear
  * Linked volumes allow for persistence and maintenance
* Horizontally scaled persistence layer
* Multiple availability zones to prevent quorum loss

--

### But what about upgrades?

* Data volumes can contain metadata to allow the docker image to detect and upgrade storage
* A "controller" unit could be used to orchestrate upgrades transparently
* There is a strong need for automated orchestration "distribution"
  * Akin to the upgrade scripts in an distribution "package"
* Waiting for a re-seed/mirror event to succeed before continuing is important

--

### Is this Persistence safe?

* container volumes can be mounted from underlying host
* stopped "data" container volumes can be mounted from another
* Docker 1.20+ --restart=always flag
* Other experimental Docker image storage backends than AUFS and BTRFS do exist: ZFS, Hadoop, etc

--

### Other risks

* Docker 172.17.42.0/24 "hides" containers between hosts (Flannel addresses this with a VPN)
* Shared nodes means:
  * IO saturation on persistence member nodes starving IO for other layers
  * Only so many pre-defined ports available to be mapped
  * Shared-tenancy deployment not advised - CoreOS fleets should be limited in scope

--

### Real world example

* Chef provisioned i2.8xlarge postgres instances on 8 SSD **ephemeral** (not EBS+PIOPs!) disk RAID-10 arrays
* If stopped, the persistence is _gone_
* The actual persistence safety provided by daily wal-e full backups and streaming wal-e archives to S3 storage

Even with chef provisioned "always on" servers, persistence is not guaranteed, nor is it even necessary.

--

### Any questions? Comments?

## Ian Blenke [@ianblenke](http://twitter.com/ianblenke)
## email: ian at blenke.com
## github.com/ianblenke
## ![http://goo.gl/fkHHRA](http://goo.gl/fkHHRA.qr)
## This presentation: http://goo.gl/fkHHRA

