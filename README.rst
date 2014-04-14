==========
virtualbox
==========

Install virtualbox and phpvirtualbox for home use.


.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``virtualbox``
--------------

Install virtualbox package from oracle.

``virtualbox.webservice``
-------------------------

Activate the virtualbox webservice.
This state creates a user which will run the webservice daemon and configure it.
Virtual boxes will be created in the home directory of the former user.

``virtualbox.extpack``
----------------------

Download and install the current Oracle VM VirtualBox Extension Pack.

.. note::

    The Extension Pack is not licensed under the GPL2!
    The VirtualBox Personal Use and Evaluation License (PUEL) applies to it, see
    https://www.virtualbox.org/wiki/VirtualBox_PUEL and https://www.virtualbox.org/wiki/Licensing_FAQ
    for more information.

``virtualbox.phpvirtualbox``
----------------------------

Download and install the latest phpvirtualbox.
Apache is used to serve the webpages.


TODO
====

- make default values in map.jinja overwritable with pillar data
