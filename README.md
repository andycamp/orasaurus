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

`orasaurus generate [script_type]`

When you run the generator, Orasaurus, examines all directories looking for files with the following extensions: `.pkg .pks .pkb .sql .trg .prc. fnc .vw`. Each of the buildable files is added to a build script that is placed in each directory. These scripts can be generated over and over as you develop.

There are two kinds of `script_types`: build and teardown. Build scripts are sql\*plus scripts that run the contents of each buildable file into sql\*plus. The teardown scripts attempts to reverse the build scripts by dynamically creating scripts to drop the database objects (this really only works if your filenames are database object names).

If you choose to order your build scripts using sql, you must name your files to match the database object that the files contain. For instance, if you have a table called notes, the DDL for that table should be in a file titled "notes.some_buildable_extension".

You can also use the underlying code,as you see fit.

There is command-line help, as well: `orasaurus help`.

Coming Soon
-----------

I will be adding features adding automation for executing the build and evaluating the results (i.e. were there errors), a richer interface for customizing builds, and some additional generators for automating the execution of the builds.