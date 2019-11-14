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

The Test Scripts
----------------

Run Time Switches for Player.x
------------------------------
