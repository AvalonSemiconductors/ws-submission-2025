.. _simplecpu:

Simple CPU
==========

This design, with ID ``'b00110``, is an intentionally simplistic 8-bit CPU for educational purposes, with only 16 instructions and 64 bytes of on-die memory. The memory can be pre-programmed by the user through inputs pins intended to be controlled via toggle switches and push buttons. An automatic preload mode is also available to initialize RAM contents from an external memory.

For I/O, one output port and one input port are provided, each 8-bits wide.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: mccpu-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[0]``
      - ``RSTn``
      - I (PD)
      - Active low reset input
    * - ``bidir[8:1]``
      - ``out[7:0]``
      - O
      - General-purpose output port
    * - ``bidir[9]``
      - Run Enable
      - I (PD)
      - Puts the processor into free-run mode when high
    * - ``bidir[10]``
      - Load
      - I (PD)
      - A rising edge on this pin loads the next byte in loader mode
    * - ``bidir[11]``
      - Preload Enable
      - I (PD)
      - A high level on this pin as reset is released enables auto-preload mode or for blinkenlights
    * - ``bidir[19:12]``
      - ``load_in[7:0]``
      - I (PD)
      - Data byte input during loader and auto-preload modes
    * - ``bidir[27:20]``
      - ``in[7:0]``
      - I (PD)
      - General-purpose input port
    * - ``bidir[35:28]``
      - ``PC[7:0]``
      - O
      - Mirror of the Program Counter register, used during auto-preload mode
    * - ``bidir[36]``
      - Preload Active
      - O
      - Active low, asserted when auto-preload mode is active and still fetching bytes
    * - ``bidir[37]``
      - Loader Enable
      - I (PD)
      - Enables loader mode when high
    * - ``bidir[41:38]``
      - ``ireg[3:0]``
      - O
      - Mirror of the instruction register showing the current opcode being executed, used for debugging or blinkenlights

-----------------
Programming Model
-----------------

There are only three major registers inside the processor, all 8-bits wide: the accumulator, through which all arithmatic and logic operations are performed, the Program Counter, which points to the current instruction being executed, and the latches for the general-purpose output port. All of these are accessible to the programmer.

Instructions are always two bytes long and though they must not be strictly alligned to even memory locations, it is recommended to keep instructions aligned. Of the combined 16-bits, only 12 are used. The first byte fetched contains the opcode in its least-significant 4 bits, with the remaining bits ignored, and the following byte contains the instruction argument - either an immediate or an absolute memory address. For instructions which do not use the argument byte, all of its bits are don’t care.

64 bytes of built-in RAM are provided from addresses 0 through 63, which then repeats four times over the whole 256-byte address space.

----------------
Loader Operation
----------------

There are two ways to initialize the memory contents. The first is regular loader mode, activated by pulling the Loader Enable high. This can be done at any time, though it is recommended to pair this with a reset to clear the program counter to zero. Successive negative-to-positive transitions on the Load input will read the 8-bit value presented on the ``load_in`` pins and store it in the RAM at the Program Counter location, before incrementing the Program Counter by one. The current Program Counter value is displayed on the ``PC`` pins for reference. When the Load pin is released, the processor instantly enters free-running mode and starts fetching instructions from the Program Counter location. De-asserting Load in this manner does not clear the Program Counter to zero, so it is recommended to pair this with a reset.

The other way of setting up memory is using auto-preload mode, which is enabled with a high level on the Preload Enable input. This pin is only sampled while reset is active, however and so must be in the desired state as reset is released. If reset is released while Preload Enable is high, the processor will autonomously cycle the Program Counter through values 0 through 63 (inclusive), automatically copying the input at ``load_in`` to the Program Counter location before every increment. The Preload Active pin is low during this process. As soon as the Program Counter has reached address 63 and the ``load_in`` value has been latched for this location, the Program Counter is cleared to zero, Preload Active goes high and free-running mode is entered automatically. This process allows memory initialization from an external ROM by using the ``PC`` outputs as the address to the ROM and Preload Active as the output-enable to the ROM, with the ROM data outputs wired to ``load_in``.

----------------
CPU Instructions
----------------

NOT - NOT accumulator
------------------------

.. wavedrom::

     { "reg": [
       {"name": 0, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"type": 1, "bits": 8}],
       "config": {"hspace": 600}
     }

Logically inverts all bits in the accumulator.

SUBm - Substract Memory
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 1, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Subtracts from the accumulator the contents of specified memory location.

ADDm - Add Memory
-----------------

.. wavedrom::

     { "reg": [
       {"name": 2, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Adds to the accumulator the contents of specified memory location.

ORm - OR Memory
---------------

.. wavedrom::

     { "reg": [
       {"name": 3, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Logic ORs onto the accumulator the contents of specified memory location.

STOREm - Store to memory
------------------------

.. wavedrom::

     { "reg": [
       {"name": 4, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Stores the contents of the accumulator to the specified memory location.

BZ - Branch if Zero
-------------------

.. wavedrom::

     { "reg": [
       {"name": 5, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Offset", "bits": 8}],
       "config": {"hspace": 600}
     }

Adds the specified offset to the Program Counter IF the current accumulator contents equal exactly zero. The offset is measured from the location of the second instruction byte containing the offset. The offset is a signed integer.

ANDm - AND Memory
-----------------

.. wavedrom::

     { "reg": [
       {"name": 6, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Logic ANDs onto the accumulator the contents of specified memory location.

LOADm - Load from Memory
------------------------

.. wavedrom::

     { "reg": [
       {"name": 7, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the memory contents from the specified memory location into the accumulator, overwriting its previous contents.

IN - Input from IO
------------------

.. wavedrom::

     { "reg": [
       {"name": 8, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"type": 1, "bits": 8}],
       "config": {"hspace": 600}
     }

Gets the input value from the ``in[7:0]`` pins and stores it into the accumulator, overwriting its previous contents. Note that these pins are only sampled on every second clock edge to internally buffer them.

SUBi - Substract Immediate
--------------------------

.. wavedrom::

     { "reg": [
       {"name": 9, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Immediate", "bits": 8}],
       "config": {"hspace": 600}
     }

Subtracts from the accumulator the immediate constant provided with the instruction.

ADDi - Add Immediate
--------------------

.. wavedrom::

     { "reg": [
       {"name": 10, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Immediate", "bits": 8}],
       "config": {"hspace": 600}
     }

Adds to the accumulator the immediate constant provided with the instruction.

ORm - OR Memory
---------------

.. wavedrom::

     { "reg": [
       {"name": 11, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Immediate", "bits": 8}],
       "config": {"hspace": 600}
     }

Logic ORs onto the accumulator the immediate constant provided with the instruction.

OUT - Output to IO
------------------

.. wavedrom::

     { "reg": [
       {"name": 12, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"type": 1, "bits": 8}],
       "config": {"hspace": 600}
     }

Stores the contents of the accumulator to the output port latch, causing this value to become visible at the ``out[7:0]`` pins.

BR - Branch unconditionally
---------------------------

.. wavedrom::

     { "reg": [
       {"name": 13, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Offset", "bits": 8}],
       "config": {"hspace": 600}
     }

Adds the specified offset to the Program Counter unconditionally (always). The offset is measured from the location of the second instruction byte containing the offset. The offset is a signed integer.

ANDi - AND Immediate
--------------------

.. wavedrom::

     { "reg": [
       {"name": 14, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Address", "bits": 8}],
       "config": {"hspace": 600}
     }

Logic ANDs onto the accumulator the immediate constant provided with the instruction.

LOADi - Load Immediate
----------------------

.. wavedrom::

     { "reg": [
       {"name": 15, "bits": 4},
       {"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Immediate", "bits": 8}],
       "config": {"hspace": 600}
     }

Stores the immediate constant provided with the instruction into the accumulator, overwriting its previous contents.
