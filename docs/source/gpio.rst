.. _gpio:

GPIO Chip
=========

This design combines many common I/O peripherals into a single layout and interfaces to the outside world using an 8-bit bus interface compatible with many old 8-bit and 16-bit microprocessors. It contains 16 individually programmable GPIO lines, 3 timer/counters, 3 DACs, a PRNG, one UART, one SPI port and 16 bytes of general-purpose registers.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: gpio-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[0]``
      - ``INTn``
      - O
      - Interrupt output, active low
    * - ``bidir[1]``
      - ``SDI``
      - I
      - SPI Serial Data In
    * - ``bidir[2]``
      - ``RSTm``
      - I
      - Active-low design reset
    * - ``bidir[3]``
      - ``SDO``
      - O
      - SPI Serial Data Out
    * - ``bidir[4]``
      - ``SCLK``
      - O
      - SPI Serial Clock Out
    * - ``bidir[5]``
      - ``T0``
      - O
      - Timer 0 toggle output
    * - ``bidir[6]``
      - ``T1``
      - O
      - Timer 1 toggle output
    * - ``bidir[12:7]``
      - ``A[5:0]``
      - I
      - Bus address inputs
    * - ``bidir[20:13]``
      - ``D[7:0]``
      - IO
      - Bidirectional bus data lines
    * - ``bidir[21]``
      - ``CEn``
      - I (PU)
      - Bus Chip Enable input
    * - ``bidir[22]``
      - ``OEn``
      - I
      - Bus Output Enable input
    * - ``bidir[23]``
      - ``WEn``
      - I
      - Bus Write Enable input
    * - ``bidir[24]``
      - ``PA[0]/T0CLK/CTSn``
      - IO
      - PORTA bit 0 or Timer 0 external clock or UART Clear To Send output
    * - ``bidir[25]``
      - ``PA[1]/T1CLK``
      - IO
      - PORTA bit 1 or Timer 1 external clock
    * - ``bidir[31:26]``
      - ``PA[7:2]``
      - IO
      - PORTA GPIO port
    * - ``bidir[39:32]``
      - ``PB[7:0]``
      - IO
      - PORTB GPIO port
    * - ``bidir[40]``
      - ``RXD``
      - I (PU)
      - UART Receive Data input
    * - ``bidir[41]``
      - ``TXD``
      - O
      - UART Transmit Data output
    * - ``analog[0]``
      - ``DAC[0]``
      - O
      - Digital To Analog Converter output
    * - ``analog[5]``
      - ``DAC[1]``
      - O
      - Digital To Analog Converter output
    * - ``analog[10]``
      - ``DAC[2]``
      - O
      - Digital To Analog Converter output

-------------
Bus Interface
-------------

The design’s internal registers are addressed using a 8-bit data bus with data lines on the ``D[7:0]`` pads, register address provided on the ``A[5:0]`` pads and controlled by the ``CEn``, ``OEn`` and ``WEn`` inputs. Any register read or write cycle requires ``CEn`` to be low in addition to either ``OEn`` or ``WEn`` being low. ``OEn`` takes precedence over ``WEn``, but the condition of all three inputs being low simultaneously should generally be avoided. ``OEn`` being low indicates a read access, with the value of the addressed register being presented on the ``D[7:0]`` lines, which become outputs during this time. ``WEn`` being low indicates a write access, with a value presented on the ``D[7:0]`` lines being written into the addressed register, if the register in question is writeable. For read-only registers, ``WEn`` simply has no effect.

All three control lines are synchronous to the clock. ``WEn`` takes effect on every rising clock edge where it and ``CEn`` are low and ``OEn`` is high. When ``OEn`` goes low, the ``D[7:0]`` become outputs immediately, outputing the value of the addressed register, but if the addressed register triggers a side effect when read (i.e. ``UDAT``), this only triggers on the next rising clock edge after ``OEn`` and ``CEn`` going low.

---------------------
Register Descriptions
---------------------

All registers are listed by address and mnemonic.

GPIO Port
---------

Two 8-bit GPIO ports are provided through these registers, with pin direction and pull resistors individually programmable. Every bit of these registers is mapped to the corresponding bit on the ``PA``/``PB`` pads. ``DDRx`` controls pin direction, with logic ones indicating outputs and logic zeroes indicating inputs. The ``PORTx`` registers control the states of any outputs, with logic ones indicating a high output state and logic zeroes indicating a low output state. For pins configured as inputs, the input levels can be sampled by reading the ``PINx`` registers, where high level inputs generate logic ones and low level inputs generate logic zeroes.

Inputs can additionally be configured to have an internal pull-up or pull-down resistor with the ``PUx`` and ``PDx`` registers. ``PUx`` enables pull-ups while ``PDx`` enables pull-downs. Setting bits in either register for port bits configured as outputs has no effect.

``'h00`` - ``DDRA``

.. wavedrom::

     { "reg": [
       {"name": "DDRA", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h01`` - ``DDRB``

.. wavedrom::

     { "reg": [
       {"name": "DDRB", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h02`` - ``PORTA``

.. wavedrom::

     { "reg": [
       {"name": "PORTA", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h03`` - ``PORTB``

.. wavedrom::

     { "reg": [
       {"name": "PORTB", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h04`` - ``PINA`` - Read Only

.. wavedrom::

     { "reg": [
       {"name": "PINA", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h05`` - ``PINB`` - Read Only

.. wavedrom::

     { "reg": [
       {"name": "PINB", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h2B`` - ``PUA``

.. wavedrom::

     { "reg": [
       {"name": "PUA", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h2C`` - ``PUB``

.. wavedrom::

     { "reg": [
       {"name": "PUB", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h2D`` - ``PDA``

.. wavedrom::

     { "reg": [
       {"name": "PDA", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h2E`` - ``PDB``

.. wavedrom::

     { "reg": [
       {"name": "PDB", "bits": 8}],
       "config": {"hspace": 600}
     }

Serial Ports
------------

Two serial ports, one SPI master port and one UART, are provided through these registers. Both have individually programmable bitrates, generated by dividing the input clock. ``SDIV`` contains the divider value for the SPI port and ``UDIV`` the divider value for the UART. The final bitrate for either is then ``clock / (UDIV/SDIV + 1)``.

Both ports have a data register, ``SDAT`` for the SPI port and ``UDAT`` for the UART, which immediately initiate a data transfer when written to. In the case of the SPI port, a full-duplex data exchange takes place, with the received byte obtainable by reading ``SDAT`` once the transfer is complete. The UART will asynchronously receive bytes, which can then be obtained by reading ``UDAT``.

The ``SSTAT`` register provides status information and configuration options for the serial ports.
The bits ``SBUSY``, for the SPI port, and ``UBUSY``, for the UART, indicate if the corresponding serial port is still busy transmitting the last value written to its data register. No further data register writes may take place for a serial port if its corresponding busy bit is set. The UART additionally provides the ``UHB`` status bit which reads one if it has completed receiving a new byte and this data is now available in ``UDAT``. Reading ``UDAT`` then also clears ``UHB``. Buffer overruns are not detected.

The UART is capable of generating an interrupt whenever it has received a byte, which can be enabled by setting the ``UIEN`` bit in ``SSTAT``. Basic flow control can also be enabled by setting ``FLOWEN``. ``PORTA`` bit zero, corresponding to the ``PA[0]`` pad, must additionally be an output pin to use this feature. Setting ``FLOWEN`` overrides the output value setting of this pad with the ``CTSn`` flow control line. This line goes high whenever ``UHB`` is set and only goes low when ``UHB`` becomes low again. This indicates to the other end of the connection that no further bytes can be received by the UART until ``UDAT`` is read.

``'h06`` - ``SDIV``

.. wavedrom::

     { "reg": [
       {"name": "SDIV", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h07`` - ``SDAT``

.. wavedrom::

     { "reg": [
       {"name": "SDAT", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h08`` - ``UDIV`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "UDIV[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h09`` - ``UDIV`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "UDIV[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h0A`` - ``UDAT``

.. wavedrom::

     { "reg": [
       {"name": "UDAT", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h0B`` - ``SSTAT`` - Only marked bits are writeable

.. wavedrom::

     { "reg": [
       {"name": "SBUSY", "bits": 1},{"name": "UHB", "bits": 1},{"name": "UBUSY", "bits": 1},{"type": 1, "bits": 3},{"name": "FLOWEN", "bits": 1, "type": 3},{"name": "UIEN", "bits": 1, "type": 3}],
       "config": {"hspace": 600}
     }

Timer/Counters
--------------

Three timer/counters provide precise general-purpose or interrupt timing based on the system clock, or an external clock, or can count pulses from an external source. All timers are 16-bits wide with a 16-bit prescaler and a 16-bit compare unit. Reading and writing these 16-bit registers through the 8-bit databus must follow a specific pattern. All put the ``TMRx`` registers can have their LSB and MSB read in any order. To read the timer values, a write to the ``TCAPT`` register will instantly copy all timer values from ``TMRx`` to the corresponding ``CAPx`` registers, which may then be read in any order. Writing any 16-bit register must be done LSB first. When writing to the LSB of one of these registers, the value is not directly written, but instead cached in a hidden temporary register. When the write to the MSB is done, the value presented on the bus and that in the temporary register are combined to form a full 16-bit value, which is then instantaneously written to the target register.

Each timer functions the same: it counts up from zero until reaching the value programmed in ``TTOPx``, at which point it resets to zero, optionally generating an interrupt or toggling an output pin. The rate at which each timer counts up can be set in multiple ways and if the ``TPREx`` registers have been programmed with non-zero values, the count rate is additionally divided by ``TPREx + 1``. The simplest and default method is counting up at the rate of the design input clock, divided by ``TPREx + 1``. However, timers ``TMR0`` and ``TMR1`` may also receive a count rate from an external source, which can be selected by setting ``TxEXT`` in ``TOPT``. Once enabled, the clock source of the affected timer switches to its corresponding ``TxCLK`` input pad. As ``T0CLK`` and ``T1CLK`` are shared with ``PA[0]`` and ``PA[1]``, the corresponding ``PORTA`` bits must be set to inputs. They can then still be read normally through ``PINA`` on top of functioning as ``TxCLK`` and a pull-up or pull-down may still be enabled for either pad. The design will then detect positive going edges on ``TxCLK`` and the corresponding timer/counter will increment every ``TPREx + 1`` such edges.

Setting ``TMRIEx`` bits in ``TOPT`` enables the generation of timer interrupts for the corresponding timer/counter. Every time a interrupt-enabled timer reaches ``TTOPx`` and resets to zero, its ``TxIRQ`` bit is set and an interrupt is generated. These interrupts must be cleared by writing to the ``TIRQS`` register. Every logic one in the written value resets the corresponding ``TxIRQ`` bit, clearing the interrupt. Reading ``TIRQS`` reveals which timers currently have  their ``TxIRQ`` bit set. If a ``TMRIEx`` bit is cleared while the corresponding ``TxIRQ`` bit is set, the ``TxIRQ`` bit also clears.

``'h0C`` - ``TOPT``

.. wavedrom::

     { "reg": [
       {"name": "TMRIE[2:0]", "bits": 3},{"name": "TMR0EXT", "bits": 1},{"name": "TMR1EXT", "bits": 1},{"type": 1, "bits": 3}],
       "config": {"hspace": 600}
     }

``'h0D`` - ``TIRQS``

.. wavedrom::

     { "reg": [
       {"name": "TMR0IRQ", "bits": 1},{"name": "TMR1IRQ", "bits": 1},{"name": "TMR2IRQ", "bits": 1},{"type": 1, "bits": 5}],
       "config": {"hspace": 600}
     }

``'h0E`` - ``TCAPT`` - Write Only

Writing this register instantaneously captures all current ``TMRx`` values into the corresponding ``CAPx`` registers.

``'h0F`` - ``T0PRE`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T0PRE[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h10`` - ``T0PRE`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T0PRE[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h11`` - ``T1PRE`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T1PRE[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h12`` - ``T1PRE`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T1PRE[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h13`` - ``T2PRE`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T2PRE[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h14`` - ``T2PRE`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T2PRE[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h15`` - ``T0TOP`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T0TOP[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h16`` - ``T0TOP`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T0TOP[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h17`` - ``T1TOP`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T1TOP[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h18`` - ``T1TOP`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T1TOP[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h19`` - ``T2TOP`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "T2TOP[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1A`` - ``T2TOP`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "T2TOP[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1B`` - ``TMR0`` (write) / ``CAP0`` (read) (LSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR0[7:0] / CAP0[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1C`` - ``TMR0`` (write) / ``CAP0`` (read) (MSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR0[15:8] / CAP0[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1D`` - ``TMR1`` (write) / ``CAP1`` (read) (LSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR1[7:0] / CAP1[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1E`` - ``TMR1`` (write) / ``CAP1`` (read) (MSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR1[15:8] / CAP1[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h1F`` - ``TMR2`` (write) / ``CAP2`` (read) (LSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR2[7:0] / CAP2[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h20`` - ``TMR2`` (write) / ``CAP2`` (read) (MSB)

.. wavedrom::

     { "reg": [
       {"name": "TMR2[15:8] / CAP2[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

Digital To Analog Converters
----------------------------

Three DACs provide analog output capabilities. Each DAC is 12-bits wide, with a change of a DAC’s register value corresponding to a proportional voltage change on its analog output pin. A value of zero produces a voltage close to 0V while the maximum value of ``'hFFF`` produces a voltage close to the supply voltage¹. Values in-between these two extremes produce voltages on a linear slope between 0V and the supply voltage. Each DAC is typically capable of driving a 1Kohm load.

¹Proper functioning of the DACs is not guranteed at supply voltages not equal to 5V +/- 10% as all passive circuit components were tuned for 5V operation.

``'h21`` - ``DAC0`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC0[11:8]", "bits": 4},{"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

``'h22`` - ``DAC0`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC0[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h23`` - ``DAC1`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC1[11:8]", "bits": 4},{"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

``'h24`` - ``DAC1`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC1[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h25`` - ``DAC2`` (MSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC2[11:8]", "bits": 4},{"type": 1, "bits": 4}],
       "config": {"hspace": 600}
     }

``'h26`` - ``DAC2`` (LSB)

.. wavedrom::

     { "reg": [
       {"name": "DAC2[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

PRNG
----

A Xorshift-based PRNG provides random values that update on every clock cycle. 24 of the PRNG state’s 32-bits are left uninitialized on reset, meaning they start with a truly random state from the register bit flip-flops settling into random states on power-up, providing a different random number sequence each time. The whole 32-bit state of the PRNG is accessible, though it is not capturable in whole like is the case with the timer values.

``'h27`` - ``PRNG``

.. wavedrom::

     { "reg": [
       {"name": "PRNG[7:0]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h28`` - ``PRNG``

.. wavedrom::

     { "reg": [
       {"name": "PRNG[15:8]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h29`` - ``PRNG``

.. wavedrom::

     { "reg": [
       {"name": "PRNG[23:16]", "bits": 8}],
       "config": {"hspace": 600}
     }

``'h2A`` - ``PRNG``

.. wavedrom::

     { "reg": [
       {"name": "PRNG[31:24]", "bits": 8}],
       "config": {"hspace": 600}
     }

General-Purpose Registers
-------------------------

16 addresses in the range ``'h30`` through ``'h3F`` (inclusive) map to registers which are readable and writeable, but are not mapped to any hardware function. This essentially turns them into 16 bytes of general-purpose random-access memory that can be used arbitrarily for data storage by the host system.

----------
Interrupts
----------

Interrupts are provided by the ``INTn`` output pin. This pin transitions low as soon as any enabled interrupt source becomes active and stays low until the number of active interrupt sources has reached zero after each source has been cleared or reset. All three timers as well as the UART serial port can generate interrupts, as described in their own sections above.
