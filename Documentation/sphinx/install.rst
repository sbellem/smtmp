Installation and Setup
======================

Installation
------------

Installing MPIR and OpenSSL
^^^^^^^^^^^^^^^^^^^^^^^^^^^
This bit, on explaining how to install MPIR and OpenSSL inside ``$HOME/local``, 
is inspired from `this blogpost <https://rdragos.github.io/2019/01/07/scale/>`_.
The target directory here can be changed to whatever you wish.
If you follow this section we assume that you have **cloned**
the main repository in your ``$HOME`` directory.

Change CONFIG.mine
^^^^^^^^^^^^^^^^^^

Change config.h
^^^^^^^^^^^^^^^
If wanted you can also now configure various bits of the system
by editing the file::

     config.h

in the sub-directory ``src``.
The main things to watch out for here are the various FHE security parameters;
these are explained in more detail in Section :ref:`sec-fhe`.
Note, to configure the statistical security parameter for the number representations
in the compiler (integer comparison, fixed point etc) from the default
of :math:`40` you need to add the following commands to your MAMBA programs.

.. code-block:: python

    program.security = 100
    sfix.kappa = 60
    sfloat.kappa = 30

However, in the case of the last two you *may* also need to change the
precision or prime size you are using. See the documentation for
``sfix`` and ``sfloat`` for this.

Final Compilation
^^^^^^^^^^^^^^^^^
The only thing you now have to do is type

.. code-block:: shell

    make progs

That's it! After ``make`` finishes then you should see a ``Player.x``
executable inside the SCALE-MAMBA directory.

Compile with CMake (experimental)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
It is possible to build SCALE with CMake.
We introduced CMake because there are many development tools that
work with CMake-based projects, e.g., CLion, clangd and so on.

You may install the dependencies the same way as above.
We explain how to use CMake with the example below.

.. code-block:: shell

    mkdir src/build
    cd src/build
    # create the cmake project
    CC=gcc CXX=g++ cmake \
        -DOPENSSL_ROOT_DIR=$openssl_root \
        -DCRYPTOPP_ROOT_DIR=$cryptopp_root \
        -DMPIR_ROOT_DIR=$mpir_root ..
    # build the project
    make

The first step is to have CMake create a project using the ``cmake`` command.
The compiler can be changed using ``CC`` and ``CXX``.
Use the ``-D`` flag to configure the dependencies.
For example, if the MPIR library is in ``$HOME/mpir/lib`` and its include files
are in ``$HOME/mpir/include``, then ``DMPIR_ROOT_DIR`` should be set to
``$HOME/mpir``, i.e., the parent directory of ``lib`` and ``include``.
If the dependencies are installed in the default directories,
e.g., ``/usr/{lib64,include}`` or ``/usr/local/{lib64,include}``,
then the ``-D`` flags are not needed.
Finally, run ``make`` to create the binaries.
The ``cmake`` command is not needed in subsequent compilations.
For more information on CMake, we recommend this excellent
`wiki <https://gitlab.kitware.com/cmake/community/wikis/home>`_.


Creating and Installing Certificates
------------------------------------
For a proper configuration you need to worry about the rest
of this section. 
However, for a quick idiotic test installation jump down to
:ref:`subsec-idiot`.

All channels will be TLS encrypted. For SPDZ this is not needed, but for
other protocols we either need authenticated or secure channels. So might
as well do everything over *mutually* authenticated TLS. We are going
to setup a small PKI to do this. You thus first need to create
keys and certificates for the main CA and the various players you
will be using.

When running ``openssl req ...`` to create certificates, it is
vitally important to ensure that each player has a different Common
Name (CN), and that the CNs contain no spaces.  The CN is used later
to configure the main MPC system and be sure about each party's
identity (in other words, they really are who they say they are).

First go into the certificate store::

   cd Cert-Store

Create CA authority private key::

   openssl genrsa -out RootCA.key 4096

Create the CA self-signed certificate::
       
   openssl req -new -x509 -days 1826 -key RootCA.key -out RootCA.crt

Note, setting the DN for the CA is not important, you can leave them
at the default values.

Now for *each* MPC player create a player certificate, e.g.::

   openssl genrsa -out Player0.key 2048
   openssl req -new -key Player0.key -out Player0.csr
   openssl x509 -req -days 1000 -in Player0.csr -CA RootCA.crt \
                 -CAkey RootCA.key -set_serial 0101 -out Player0.crt -sha256

remembering to set a different Common Name for each player.

In the above we assumed a global shared file system. Obviously on
a real system the private keys is kept only in the
``Cert-Store`` of that particular player, and the player public
keys are placed in the ``Cert-Store`` on each player's
computer. The global shared file system here is simply for test
purposes. Thus a directory listing of ``Cert-Store``
for player one, in a four player installation, will look like::

   Player1.crt
   Player1.key
   Player2.crt
   Player3.crt
   Player4.crt
   RootCA.crt

Runnning Setup
--------------
The program ``Setup.x`` is used to run a one-time setup 
for the networking and/or secret-sharing system being used
and/or set up the GC to LSSS conversion circuit.
You must do networking before secret-sharing (unless you keep
the number of players fixed), since the secret-sharing setup
picks up the total number of players you configured when setting
up networking.
And you must do secret sharing setup before creating the conversion
circuit (since this requires the prime created for the secret
sharing scheme).

.. note:: Just as above for OpenSSL key-generation, for demo purposes we assume
   a global file store with a single directory ``Data``.

Running the program ``Setup.x`` and specifying the secret-sharing
method will cause the program to generate files holding MAC and/or FHE
keys and place them in the folder ``Data``.  When running the
protocol on separate machines, you must then install the appropriate
generated MAC key file ``MKey-*.key`` in the ``Data`` folder of
each player's computer.  If you have selected full-threshold, you also
need to install the file ``FHE-Key-*.key`` in the same directory.
You also need to make sure the public data files
\verb+NetworkData.txt+ and ``SharingData.txt`` are in the directory
``Data`` on each player's computer.
These last two files specify the configuration which you select with
the ``Setup.x`` program.

We now provide more detail on each of the three aspects of the program
``Setup.x``.

Data for Networking
^^^^^^^^^^^^^^^^^^^
Input provided by the user generates the file
``Data/NetworkData.txt`` which defines the following

* The root certificate name.
* The number of players.
* For each player you then need to define

   * Which IP address is going to be used
   * The name of the certificate for that player

.. \iffalse XXXX
.. \item Whether a fake offline phase is going to be used.
.. \item Whether a fake sacrifice phase is going to be used.
.. \fi

Data for Secret Sharing
^^^^^^^^^^^^^^^^^^^^^^^
You first define whether you are going to be using full threshold (as in
traditional SPDZ), Shamir (with :math:`t<n/2`), a Q2-Replicated scheme, or 
a Q2-MSP.

Full Threshold
""""""""""""""
In this case the prime modulus cannot be chosen directly, but
needs to be selected to be FHE-friendly [#]_.
Hence, in this case we give you two options.

* Recommended: You specify the number of bits in the modulus
  (between 16 bits and 1024 bits).  The system will then
  search for a modulus which is compatible with the FHE system we are
  using.
* Advanced: You enter a specific prime. The system then searches
  for FHE parameters which are compatible, if it finds none (which is highly
  likely unless you are very careful in your selection) it aborts.

After this stage the MAC keys and FHE secret keys are setup and written into the
files:

   * ``MKey-*.key``
   * ``FHE-Key-*.key``

in the ``Data`` directory. 
This is clearly an insecure way of parties picking their MAC keys. But this is only a
research system. 
At this stage we also generate a set of keys
for distributed decryption of a level-one FHE scheme if needed.

.. \iffalse XXXX
.. For the case of fake offline we assume these keys are on {\em each} computer,
.. but using fake offline is only for test purposes in any case.
.. \fi


Shamir Secret Sharing
"""""""""""""""""""""
Shamir secret sharing we assume is self-explanatory.
For the Shamir setting we use an online phase using the reduced communication
protocols of :cite:`KRSW`;
the offline phase (*currently*) only supports *Maurer*'s multiplication method
:cite:`Maurer`.
This will be changed in future releases to also support the new offline method from
:cite:`SW18`.

.. .. bibliography:: ../SCALE.bib

Replicated Secret Sharing
"""""""""""""""""""""""""

Q2-MSP Programs
"""""""""""""""

Conversion Circuit
^^^^^^^^^^^^^^^^^^

.. _subsec-idiot:

Idiot's Installation
--------------------

.. [#] In all other cases you select the prime modulus for the LSSS directly at this point.
