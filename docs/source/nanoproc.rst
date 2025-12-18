.. _nanoproc:

Nanoprocessor Replica
=====================

This design is a functional, cycle-accurate replica of the `Nanoprocessor <https://www.righto.com/2020/09/inside-hp-nanoprocessor-high-speed.html>`__, a simple programmable I/O processor with 16 8-bit registers for holding data, a 8-bit data bus for I/O and a dedicated GPIO port.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: nanoprocessor-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[0]``
      - ``RSTn``
      - I (PD)
      - Active low reset input
    * - ``bidir[13:7]``
      - ``DC[6:0]``
      - O (open drain)
      - Last-significant 7 bits of the Direct Control Bus
    * - ``bidir[14]``
      - ``IREQn``
      - I (PU)
      - Interrupt-Request input, level-sensitive
    * - ``bidir[15]``
      - ``INTACK``
      - O
      - Interrupt-Acknowledge output
    * - ``bidir[16]``
      - ``INTENA``
      - O
      - Interrupt-Enable output
    * - ``bidir[17]``
      - ``PSG``
      - O
      - Program Gate - Indicates that the program address is valid and the nanoprocessor is requesting to fetch an instruction byte.
    * - ``bidir[21:18]``
      - ``DS[3:0]``
      - O
      - Device Select / Device Address
    * - ``bidir[22]``
      - ``RWn``
      - O
      - Device Read/Write select - High is Read, Low is Write
    * - ``bidir[30:23]``
      - ``D[7:0]``
      - IO
      - Multiplexed, Bi-directional data bus for both instruction fetches and device access
    * - ``bidir[41:31]``
      - ``PA[10:0]``
      - O
      - Program Address lines

----------
Bus cycles
----------

The Nanoprocessor is a Harvard-Architecture style processor, but multiplexes both types of memory onto the same data bus. To avoid collisions, the ``PSG`` output indicates when a program data fetch is being performed. When ``PSG`` is high, a byte from the program memory (as addressed by ``PA``) should be placed on the databus. Otherwise, the I/O device addressed by ``DS`` is to respond according to the state of ``RWn``.

-------------------
Direct Control Port
-------------------

The Direct Control lines (``DC[6:0]``) are a set of individually-controllable GPIO lines. Each line is a open-drain output with weak pull-up and individually latched. Each line configured to output a logic one (pull-up) can be used as an input pin and have its state be read by the processor. The Direct Control port is actually 8-bits wide internally, but the most-significant bit is used as the interrupt-enable and its state is reflected on the ``INTENA`` pin. It is automatically set and reset as part of the interrupt sequence.

----------
Interrupts
----------

If the ``IREQn`` line is low at the end of an instruction’s execute phase, the processor is interrupted. This is regardless of the state of ``INTENA``, though this pin can be used to gate the interrupt request line externally. If this is not the case, ``INTENA`` may be used as a general-purpose output.

When an interrupt occurs, the Program Counter is backed-up in ``ISR`` and a vectored interrupt is executed, whereby the least-significant 8 bits of the Program Counter are loaded from the current databus contents, with the remaining bits set to zero. ``INTENA`` is also cleared. To indicate that a vectored interrupt is taking place, ``INTACK`` pulses high for one clock during the vector fetch.

The ``RTI`` instruction returns from an interrupt, restoring the Program Counter from ``ISR``, without changing the state of ``INTENA``. The instruction ``RTE`` does the same, but also sets ``INTENA``.

-----------------
Programming Model
-----------------

The Nanoprocessor contains 16 general-purpose registers each 8-bit wide and labeled ``R0`` through ``R15`` and can be used interchangably, except ``R0``, which is the only valid source for comparisons and indexing. An 8-bit Accumulator register, ``ACC``, is used for most operations and its contents can be freely exchanged with that of any general-purpose register.

The Subroutine Stack Register, ``SSR``, and Interrupt Stack Register, ``ISR``, provide a single level of nesting each. Despite the names, both registers hold just a single value. The Extend Register, ``E``, holds a single bit of information, usually indicating a overflow or borrow condition, but can also be set, cleared and read by program instructions.

Finally, the Program Counter always points to the next instruction to be executed. It, as well as ``SSR`` and ``ISR``, are 11-bits wide, resulting in a program memory capacity of 2048 bytes.

---------------
Instruction Set
---------------

SBS - Skip on Bit Set
---------------------

.. wavedrom::

     { "reg": [
       {"name": "N", "bits": 3},
       {"name": 2, "bits": 5}],
       "config": {"hspace": 600}
     }

Skips the following two bytes if the indicated bit ``N`` in ``ACC`` is set (one).

SBZ - Skip on Bit Zero
----------------------

.. wavedrom::

     { "reg": [
       {"name": "N", "bits": 3},
       {"name": 6, "bits": 5}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if the indicated bit ``N`` in ``ACC`` is cleared (zero).

SBN - Set Bit N
---------------

.. wavedrom::

     { "reg": [
       {"name": "N", "bits": 3},
       {"name": 4, "bits": 5}],
       "config": {"hspace": 600}
     }

Sets the indicated bit ``N`` in ``ACC``.

CBN - Clear Bit N
-----------------

.. wavedrom::

     { "reg": [
       {"name": "N", "bits": 3},
       {"name": 20, "bits": 5}],
       "config": {"hspace": 600}
     }

Clears the indicated bit ``N`` in ``ACC``.

INB - Increment Binary
----------------------

.. wavedrom::

     { "reg": [
       {"name": 0, "bits": 8}],
       "config": {"hspace": 600}
     }

Increments ``ACC`` as an 8-bit binary number. ``E`` is set if overflow occurs.

IND - Increment Decimal
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 2, "bits": 8}],
       "config": {"hspace": 600}
     }

Increments ``ACC`` as a packed BCD value. ``E`` is set if overflow occurs.

DEB - Decrement Binary
----------------------

.. wavedrom::

     { "reg": [
       {"name": 1, "bits": 8}],
       "config": {"hspace": 600}
     }

Decrements ``ACC`` as an 8-bit binary number. ``E`` is set if underflow occurs.

DED - Decrement Decimal
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 3, "bits": 8}],
       "config": {"hspace": 600}
     }

Decrements ``ACC`` as a packed BCD value. ``E`` is set if underflow occurs.

CLA - Clear Accumulator
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 4, "bits": 8}],
       "config": {"hspace": 600}
     }

Clears all bits in ``ACC`` to zero.

CMA - Complement Accumulator
----------------------------

.. wavedrom::

     { "reg": [
       {"name": 5, "bits": 8}],
       "config": {"hspace": 600}
     }

Complements all bits in ``ACC`` (one’s complement).

LSA - Left-Shift Accumulator
----------------------------

.. wavedrom::

     { "reg": [
       {"name": 7, "bits": 8}],
       "config": {"hspace": 600}
     }

Shifts the bits in ``ACC`` one place to the left, clearing the least significant bit to zero. ``E`` is unaffected.


RSA - Right-Shift Accumulator
-----------------------------

.. wavedrom::

     { "reg": [
       {"name": 6, "bits": 8}],
       "config": {"hspace": 600}
     }

Shifts the bits in ``ACC`` one place to the right, clearing the most significant bit to zero. ``E`` is unaffected.

SES - Skip on Extend Set
------------------------

.. wavedrom::

     { "reg": [
       {"name": 31, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``E`` is set (one).

SEZ - Skip on Extend Zero
-------------------------

.. wavedrom::

     { "reg": [
       {"name": 63, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``E`` is cleared (zero).

LDR - Load ROM Data
-------------------

.. wavedrom::

     { "reg": [
       {"name": 207, "bits": 8}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "D", "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the immediate program data byte ``D`` into ``ACC``. This is a two-byte instruction.

LDA - Load Accumulator
----------------------

.. wavedrom::

     { "reg": [
       {"name": "R", "bits": 4},
       {"name": 6, "bits": 4}],
       "config": {"hspace": 600}
     }

Loads ``ACC`` with the contents of the general-purpose register ``R``.

STA - Store Accumulator
-----------------------

.. wavedrom::

     { "reg": [
       {"name": "R", "bits": 4},
       {"name": 7, "bits": 4}],
       "config": {"hspace": 600}
     }

Stores the contents of ``ACC`` into the general-purpose register ``R``.

LDI - Load Indexed
------------------

.. wavedrom::

     { "reg": [
       {"name": "Z", "bits": 4},
       {"name": 14, "bits": 4}],
       "config": {"hspace": 600}
     }

Loads ``ACC`` with the contents with data from the general-purpose register indexed by ``Z | R0[3:0]``.

STI - Store Indexed
-------------------

.. wavedrom::

     { "reg": [
       {"name": "Z", "bits": 4},
       {"name": 15, "bits": 4}],
       "config": {"hspace": 600}
     }

Stores the contents of ``ACC`` into the general-purpose register indexed by ``Z | R0[3:0]``.

STR - Store ROM Data
--------------------

.. wavedrom::

     { "reg": [
       {"name": "R", "bits": 4},
       {"name": 13, "bits": 4}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "D", "bits": 8}],
       "config": {"hspace": 600}
     }

Stores the immediate program data byte ``D`` into the general-purpose register ``R``. This is a two-byte instruction.

STE - Set Extend
----------------

.. wavedrom::

     { "reg": [
       {"name": 180, "bits": 8}],
       "config": {"hspace": 600}
     }

Sets ``E``.

CLE - Clear Extend
------------------

.. wavedrom::

     { "reg": [
       {"name": 181, "bits": 8}],
       "config": {"hspace": 600}
     }

Clears ``E`` to zero.

DSI - Disable Interrupt
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 175, "bits": 8}],
       "config": {"hspace": 600}
     }

Clears ``INTENA``. Same as ``CLC 7``.

ENI - Enable Interrupt
----------------------

.. wavedrom::

     { "reg": [
       {"name": 47, "bits": 8}],
       "config": {"hspace": 600}
     }

Sets ``INTENA``. Same as ``STC 7``.

SLT - Skip on Less Than
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 9, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is less than ``R0``.

SEQ - Skip on Equal
-------------------

.. wavedrom::

     { "reg": [
       {"name": 10, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is equal to ``R0``.

SAZ - Skip on Accumulator Zero
------------------------------

.. wavedrom::

     { "reg": [
       {"name": 11, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is equal to zero.

SLE - Skip on Less Equal
------------------------

.. wavedrom::

     { "reg": [
       {"name": 12, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is less than or equal to ``R0``.

SGE - Skip on Greater Equal
---------------------------

.. wavedrom::

     { "reg": [
       {"name": 13, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is greater than or equal to ``R0``.

SNE - Skip on Not Equal
-----------------------

.. wavedrom::

     { "reg": [
       {"name": 14, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is *not* equal to ``R0``.

SAN - Skip on Accumulator Not zero
----------------------------------

.. wavedrom::

     { "reg": [
       {"name": 15, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is *not* equal to zero.

SGT - Skip on Greater Than
--------------------------

.. wavedrom::

     { "reg": [
       {"name": 16, "bits": 8}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if ``ACC`` is greater than ``R0``.

INA - Input Data to Accumulator
-------------------------------

.. wavedrom::

     { "reg": [
       {"name": "DS", "bits": 4},
       {"name": 4, "bits": 4}],
       "config": {"hspace": 600}
     }

Loads ``ACC`` with a byte read from the device addressed by ``DS``.

OTA - Output Accumulator
------------------------

.. wavedrom::

     { "reg": [
       {"name": "DS", "bits": 4},
       {"name": 5, "bits": 4}],
       "config": {"hspace": 600}
     }

Writes the contents of ``ACC`` to the device addressed by ``DS``. A value of 15 for ``DS`` is invalid.

OTR - Output ROM data
---------------------

.. wavedrom::

     { "reg": [
       {"name": "DS", "bits": 4},
       {"name": 12, "bits": 4}],
       "config": {"hspace": 600}
     }
     
.. wavedrom::

     { "reg": [
       {"name": "D", "bits": 8}],
       "config": {"hspace": 600}
     }

Writes the immediate program data byte ``D`` to the device addressed by ``DS``. ``RWn`` and ``PSG`` are asserted at the same time while the databus remains in a high-impedance state to cause the byte to be transmitted to the device.

STC - Set Control
-----------------

.. wavedrom::

     { "reg": [
       {"name": "K", "bits": 3},
       {"name": 5, "bits": 5}],
       "config": {"hspace": 600}
     }

Sets bit ``K`` in the Direct Control port.

CLC - Clear Control
-------------------

.. wavedrom::

     { "reg": [
       {"name": "K", "bits": 3},
       {"name": 37, "bits": 5}],
       "config": {"hspace": 600}
     }

Clears bit ``K`` in the Direct Control port to zero.

SFS - Skip on Flag Set
----------------------

.. wavedrom::

     { "reg": [
       {"name": "J", "bits": 3},
       {"name": 3, "bits": 5}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if bit ``J`` in Direct Control is set (one). Used primarily on Direct Control lines wired as inputs.

SFZ - Skip on Flag Zero
-----------------------

.. wavedrom::

     { "reg": [
       {"name": "J", "bits": 3},
       {"name": 3, "bits": 5}],
       "config": {"hspace": 600}
     }

Skips the following two program bytes if bit ``J`` in Direct Control is cleared (zero). Used primarily on Direct Control lines wired as inputs.

RTI - Return from Interrupt
---------------------------

.. wavedrom::

     { "reg": [
       {"name": 144, "bits": 8}],
       "config": {"hspace": 600}
     }

Returns from an interrupt by loading the Program Counter with the value of ``ISR``. ``INTENA`` is unaffected.

RTE - Return w. Enable
----------------------

.. wavedrom::

     { "reg": [
       {"name": 177, "bits": 8}],
       "config": {"hspace": 600}
     }

Returns from an interrupt by loading the Program Counter with the value of ``ISR`` and *sets* ``INTENA``.

NOP - No Operation
------------------

.. wavedrom::

     { "reg": [
       {"name": 95, "bits": 8}],
       "config": {"hspace": 600}
     }
     
No operation is performed.

JAI - Jump through Accumulator Indirect
---------------------------------------

.. wavedrom::

     { "reg": [
       {"name": "Z", "bits": 3},
       {"name": 18, "bits": 5}],
       "config": {"hspace": 600}
     }

Performs an indirect jump by loading the Program Counter with a computed value. The page number (3 most-significant bits) are computed through ``Z | R0[2:0]`` and the page offset (8 least-significant bits) are taken directly from the contents of ``ACC``.

JAS - Jump through Accumulator indirect to Subroutine
-----------------------------------------------------

.. wavedrom::

     { "reg": [
       {"name": "Z", "bits": 3},
       {"name": 19, "bits": 5}],
       "config": {"hspace": 600}
     }

Performs an indirect jump by loading the Program Counter with a computed value and copies the address of the instruction byte plus 2 into ``SSR``. The page number (3 most-significant bits) are computed through ``Z | R0[2:0]`` and the page offset (8 least-significant bits) are taken directly from the contents of ``ACC``.

JMP - Jump
----------

.. wavedrom::

     { "reg": [
       {"name": "Page Number", "bits": 3},
       {"name": 16, "bits": 5}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Page Offset", "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the Program Counter from immediate program bytes. This is a two-byte instruction.

JSB - Jump to Subroutine
------------------------

.. wavedrom::

     { "reg": [
       {"name": "Page Number", "bits": 3},
       {"name": 17, "bits": 5}],
       "config": {"hspace": 600}
     }

.. wavedrom::

     { "reg": [
       {"name": "Page Offset", "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the Program Counter from immediate program bytes and copies the address of the first instruction byte plus 2 into ``SSR``. This is a two-byte instruction.

RTS - Return from Subroutine
----------------------------

.. wavedrom::

     { "reg": [
       {"name": 184, "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the Program Counter with the contents of ``SSR`` and loads ``SSR`` with the address of the instruction byte plus 2.

RSE - Return from Subroutine and Enable
---------------------------------------

.. wavedrom::

     { "reg": [
       {"name": 185, "bits": 8}],
       "config": {"hspace": 600}
     }

Loads the Program Counter with the contents of ``SSR``, loads ``SSR`` with the address of the instruction byte plus 2 and sets ``INTENA``.
