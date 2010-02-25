Mobile Context Framework
========================

The progressive spreading of wireless networks and increasingly powerful mobile computers creates a big potential for a wide spectrum of innovative applications. Context-aware applications adapt the circumstances of the user's current situation which enables new and intelligent user interfaces. Nevertheless, the sheer diversity of exploitable contexts and the plethora of sensing technologies are actually working against the deployment of context-aware systems. A framework for context retrieval should enable the development of context-aware applications without considering details of context acquisition and context management. Moreover, exchange and reusability of context information should be allowed between applications and users.

The *Mobile Context Framework* tries to solve the described issues. It consists of three components:

* The Mobile Context Server (this project)
* The [Mobile Context iPhone Library](http://github.com/flxmllr/mobile-context-iphone-lib/)
* The [Mobile Context iPhone Demo App](http://github.com/flxmllr/mobile-context-iphone-demo/)

The Mobile Context Server
-------------------------

### Installation notes ###

The Mobile Context Server consists of a [Sinatra](http://sinatrarb.com/) Web application and a sample-ontology containing the context information. Here is how to set everything up:

#### 1. Set up the semantic triple store ####

The hosting of the context model requires a running instance of the OpenRDF Sesame semantic triple store containing the ontology.

* Download the [OpenRDF Sesame](http://www.openrdf.org) Web application [here](http://www.openrdf.org/download.jsp)
* Set it up following the [instructions](http://www.openrdf.org/doc/sesame2/users/ch06.html)
* Navigate to the workbench (i.e. http://yourhostname/openrdf-workbench/) and add a new repository for storing the contexts
* Add the [sample ontology file](http://github.com/flxmllr/mobile-context-server/raw/master/ontology/context.owl) to the created repository

#### 2. Set up the Web application ####

test2

#### 3. Customization ####

test3

### API documentation ###

coming soon...


Copyright (c) 2010 Felix Mueller, released under the [MIT license](http://github.com/flxmllr/mobile-context-server/blob/master/MIT-LICENSE)
