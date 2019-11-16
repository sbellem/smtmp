Simple Example
==============
In this section we describe writing and compiling a simple
function using the python-like language MAMBA.
We also explain how to run the test scripts to test the system
out, plus the run time options/switches you can pass to
:file:`Player.x` for different behaviours.

Compiling and running simple program
------------------------------------
Look at the simple program in :file:`Programs/tutorial/tutorial.mpc`
given below:

.. literalinclude:: ../../Programs/tutorial/tutorial.mpc

This takes a secret integer ``a`` and a clear integer ``b``
and applies various operations to them. It then prints tests
as to whether these operations give the desired results.
Then an array of secret integers is created and assigned the
values :math:`i^2`. Finally a conditional expression is evaluated
based on a clear value.

.. note::

   Notice how the :file:`tutorial.mpc` file is put into a directory
   called :file:`tutorial`, this is crucial for the running of
   the compiler.

To compile this program we type

.. code-block:: shell

   ./compile.py Programs/tutorial

in the main directory. Notice how we run the compiler on the
*directory* and not the program file itself.
The compiler then places various "tape" files consisting of
byte-code instructions into this directory, along with a
schedule file :file:`tutorial.sch`. It is this last file which
tells the run time how to run the program, including how
many threads to run, and which "tape" files to run
first [#]_.

Having compiled our program we can now run it. To do so
we simply need to execute the following commands, one on
each of the computers in our MPC engine (assuming three players)

.. code-block:: shell

    $ ./Player.x 0 Programs/tutorial
    $ ./Player.x 1 Programs/tutorial
    $ ./Player.x 2 Programs/tutorial

Note players are numbered from zero, and again we run the
*directory* and not the program file itself.

The Test Scripts
----------------
You will notice a bunch of test programs in directory
:file:`Programs`. These are for use with the test scripts
in the directory :file:`Scripts`.
To use these test scripts you simply execute in the
top level directory

.. code-block:: shell

   $ Script/test.sh test_<name of test>

The test scripts place data in the clear memory dump
at the end of a program, and test this cleared memory against
a simulated run.

the :file:`test-all` facility of

.. code-block:: shell

   $ Script/test.sh

If a test passes then the program will fail, with a
(possibly cryptic) explanation of why.

.. note:: I don't understand the above.
   See: https://github.com/KULeuven-COSIC/SCALE-MAMBA/issues/24

We also provide a script which tests the **entire**
system over various access structures. This can
take a **very long time to run**, but if you want to
run exhaustive tests then in the main directory
execute

.. code-block:: shell

   $ ./run_tests.sh


Run Time Switches for Player.x
------------------------------
There are a number of switches which can be passed to the
program :file:`Player.x`; these are

**-pnb** :math:`x`
   Sets the base port number to :math:`x`. This by default is equal to
   5000. With this setting we use all port numbers in the range
   :math:`x` to :math:`x+n-1`, where :math:`n` is the number of
   players.

**-pns** :math:`x_1,\ldots,x_n`
   This overides the ``pnb`` option, and sets the listening port number
   for player :math:`i` to :math:`x_i`. The same arguments must be
   supplied to each player, otherwise the players do not know where to
   connect to, and if this option is used there needs to be precisely
   :math:`n` given distinct port numbers.

**-mem xxxx**
   Where xxxx is either ``old`` ``empty``. The default is ``empty``.
   See later for what we mean by memory.

**-verbose n**
   Sets the verbose level to :math:`n`. The higher value of :math:`n`
   the more diagnostic information is printed. This is mainly for our
   own testing purposes, but verbose level one gives you a method to
   time offline production (see the Changes section for version 1.1).
   If :math:`n` is negative then the byte-codes being executed by the
   online phase are output (and no offline verbose output is produced).

**-max m,s,b**
   Stop running the offline phase for each online thread when we have
   generated :math:`m` multiplication triples, :math:`s` square pairs
   and :math:`b` shared bits.

**-min m,s,b**
   Do not run the online phase in each thread until the associated
   offline threads have generated :math:`m` multiplication triples,
   :math:`s` square pairs and :math:`b` shared bits. However, these
   minimums need to be less than the maximum sacrificed list sizes
   defined in :file:`config.h`. Otherwise the maximums defined in that
   file will result in the program freezing.

**-maxI i**
   An issue when using the flag **-max** is that for programs with a
   large amount of input/output **-max** can cause the IO queue to stop
   being filled. Thus if you use **-max** and are in this situation
   then signal using this flag an upper bound on the number of amount
   IO data you will be consuming. We would recommend that you multiply
   the max amount per player by the number of players here.

**-f 2**
   The number of FHE factories to run in parallel. This only applies
   (obviously) to the Full Threshold situation. How this affects your
   installation depends on the number of cores and how much memory you
   have. We set the default to two.

For example by using high values of the variables set to **-min** you
get the offline data queues full before you trigger the execution
of the online program. For a small online program this will produce
times close to that of running the offline phase on its own.
Or alternatively you can stop these queues using **-max**. By
combining the two together you can get something close to (but not
exactly the same as) running the offline phase followed by the online
phase.

Note that the flags **-max**, **-min** and **-maxI** do
not effect the offline production of aBits via the OT thread. Since
this is usually quite fast in filling up its main queue.


.. [#] Historical note, we call the byte-code files "tapes" as they
       are roughly equivalent to simple programs, and
       the initial idea for scheduling came to Nigel when looking at
       the Harwell WITCH computer at TMNOC. They in some sense
       correspond to "largish" basic blocks in modern programming
       languages.
