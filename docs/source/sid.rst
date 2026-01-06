.. _sid:

SID
===

This is an updated version of the same layout taped out as part of the AvalonSemiconductors GFMPW-1 Multi-Project die, documented `here <https://avalonsemiconductors.github.io/GFMPW-1-MULTI/sid.html>`__.

Several bus timing problems have been fixed and the implementation of the filters adjusted to function slightly better. The POT registers and associated IO pads have now also been implemented. Additionally, two of the DACs on the die are now used for direct, analog audio output. The external DAC output option has been retained as a fallback, but the DAC chip supported was changed to the MCP4921.

Just as before, two SIDs are actually contained with the design, with an extra address pin differentiating between the two, no external filter capacitors are required and all registers marked as write-only in the original SID documentation are now read-write. A input clock 8 times faster than that of the original SID is still required due to the voices and filters being time-multiplexed/pipelined in this implementation. The ICS501 integrated circuit has been verified as being suitable for multiplying a host system’s clock by 8 for this purpose.

In cases where timing issues on the ``R/Wn`` and ``CEn`` control lines exist, these signals may be synchronized to a slower separate clock signal by pulling ``PHI2ENn`` low and feeding the slow clock into the ``PHI2`` input.

For a functional description of the SID, see `this page <https://www.waitingforfriday.com/?p=661>`__.

---------------
Pad Assignments
---------------

.. list-table:: Pad description
    :name: sid-pad-description
    :header-rows: 1

    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[5]``
      - ``R/Wn``
      - I
      - Active low write-enable
    * - ``bidir[10]``
      - ``CEn``
      - I
      - Active low chip-enable
    * - ``bidir[15:11]``
      - ``A[4:0]``
      - I
      - Register address inputs
    * - ``bidir[21:16]``
      - ``D[5:0]``
      - IO
      - Bi-directional databus
    * - ``bidir[23]``
      - ``D[6]``
      - IO
      - Bi-directional databus
    * - ``bidir[24]``
      - ``PHI2``
      - I (PU)
      - External synchronization clock input
    * - ``bidir[25]``
      - ``PHI2ENn``
      - I (PU)
      - Enables external clock synchronization when pulled low
    * - ``bidir[27]``
      - ``DSCLK`` ¹
      - O
      - Serial clock to external DACs
    * - ``bidir[29:28]``
      - ``DSDO[1:0]``
      - O
      - Serial data out for each external DAC individually
    * - ``bidir[30]``
      - ``DLEn`` ¹
      - O
      - External DAC Latch Enable (active-low)
    * - ``bidir[31]``
      - ``DCSn`` ¹
      - O
      - External DAC Chip Select (active-low)
    * - ``bidir[32]``
      - ``D[7]``
      - IO
      - Bi-directional databus
    * - ``bidir[33]``
      - ``POTY``
      - IO
      - Potentiometer analog input Y
    * - ``bidir[34]``
      - ``POTX``
      - IO
      - Potentiometer analog input X
    * - ``bidir[39]``
      - ``A[5]``
      - I (PD)
      - Register address input
    * - ``bidir[41]``
      - ``RSTn``
      - I
      - Active-low design reset

¹These signals are shared between both external DACs.
