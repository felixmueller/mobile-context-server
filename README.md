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

The *Mobile Context Server* consists of a [Sinatra](http://www.sinatrarb.com/) Web application and a sample-ontology containing the context information. Here is how to set everything up:

#### 1. Set up the semantic triple store ####

The hosting of the context model requires a running instance of the OpenRDF Sesame semantic triple store containing the ontology.

1. Download the [OpenRDF Sesame](http://www.openrdf.org) Web application [here](http://www.openrdf.org/download.jsp).
2. Set it up following the [instructions](http://www.openrdf.org/doc/sesame2/users/ch06.html).
3. Navigate to the workbench (i.e. http://yourhostname/openrdf-workbench/) and add a new repository for storing the contexts.
4. Add the [sample ontology file](http://github.com/flxmllr/mobile-context-server/raw/master/ontology/context.owl) to the created repository.

#### 2. Set up the Web application ####

The Sinatra Web application needs to be hosted by a hosting service providing Sinatra support. [Heroku](http://heroku.com/) for example offers free Sinatra hosting for small Web apps.

1. Download or checkout the source files of this project.
2. Enter the proper URL of your triple store server and repository name in the file `lib/sesameAdapter.rb`.
3. Set up the Web application by following the provider's instructions (for Heroku, see [here](http://docs.heroku.com/quickstart)).

The *Mobile Context Server* should now be ready. See step 3 for customization.

#### 3. Customization ####

To add or modify context information, you can simply edit the ontology hosted by the triple store. I recommended the [Protégé Ontology Editor](http://protege.stanford.edu) for editing the OWL file. Examples for adding contexts are shown in [this YouTube video](http://www.youtube.com/watch?v=Bx2nH0Z9hPc).



Copyright (c) 2010 Felix Mueller, released under the [MIT license](http://github.com/flxmllr/mobile-context-server/blob/master/MIT-LICENSE)
