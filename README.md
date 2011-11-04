Orasaurus
=========
A super simple framework for building Oracle databases.
-------------------------------------------------------

Orasaurus is a powerful SQL*Plus script generator.

Requirements
------------

To get the most out of the generated scripts, you should have SQL*plus installed and configured for the command-line. [Instructions](http://download.oracle.com/docs/cd/B10501_01/server.920/a90842/ch4.htm).

Usage
-----

Install the gem

`gem install orasaurus`

From the command-line, navigate to the directory that contains your application, then run the following command.

`orasaurus generate_build_scripts`

When you run the generator, Orasaurus, examines all directories looking for files with the following extensions: `.pkg, .pks, .pkb, .sql, .trg`. Each of the buildable files is added to a build script that is placed in each directory. These scripts can be generated over and over as you develop.

You can also use the underlying code,as you see fit. The ruby docs are [here](http://rubydoc.info/gems/orasaurus/0.0.4/frames).

Coming Soon
-----------

I will be adding features that will allow Orasaurus to generate the build scripts in the proper order, configurable options, and automation for executing the build and evaluating the results (i.e. were there errors).