As part of the Legacy Tobacco Document Library project, the UCSF CKM (Center for Knowledge Management) initiated a pilot project to evaluate how effectively Blacklight would work for search and discovery with our Solr index.  This pilot was limited to Blacklight - we did not evaluate the other parts of the hydra stack for adding documents of managing the repository.

There were two main branches for this project.  The first was creating a minimum viable configuration of Blacklight for use with our repository and index.  The goal of this project was to get the core blacklight application working with our repository.  We did not add any features, though we did have to modify the code in a few places to support our Solr Configuration.  

You can find the minimal changes set at:

github repo for minimal

The second project involved adding an number of modifications and enhancements.  These include:

MyAccess login (shibboleth)
Notes field for bookmarks
Notes field for searches
Download searches in txt, csv, xls
Download bookmarks in txt, csv, xls, endnote, refworks
Email search history and saved searches
Specific formatting for citations
Ability to choose a subset bookmarks, records, or searches for email or download through checkboxes

This repository contains the code base for the more elaborate feature set.  

Installation Procedures:

The installation procedure for this application similar to the installation for Blacklight.  
http://projectblacklight.org

The main difference from the default application is that you will need to run a specific Solr schema.  This is available (with a subset of tobacco records) at:

url to solr schema.  

Note that the solr.yml file in config is set to access this repository on port 8983 on localhost (the default installation provided by the repository above.  )

Also - If you want to send email from this application, you will also need to configure the smtp mailer in:
config/environments/development.rb (you will need to add a username and passwords).  Alternatively, you can configure a system mailer per the blacklight instruction.  

Aside from this, this code is a fairly straightforward Ruby on Rails application.  

bundle
rake db:migrate
rails server
