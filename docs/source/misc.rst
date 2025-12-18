.. _misc:

Miscelaneous
============

Selecting design ID ``'b00011`` enables three macros at once, all of which are replicas of ones found on the GFMPW-1-MULTI die.

The first is "Diceroll", which animates a random-number-roll on a 7-segment display upon a positive edge on the ``ROLL`` pin. The decimal point on the display is illuminated to indicate when the roll is complete. Its RNG is a simple LFSR that is always shifting, even when the animation isn’t playing. So the sequence depends on the exact time intervals between button presses and should therefor be different each time.

Next is "LED Blinker" which toggles a number of output pins at different rates.

Lastly, "Hellorld!" generates UART frames at 9600 baud when clocked at 10MHz.

Pad Assignments
---------------

.. list-table:: Pad description
    :name: misc-pad-description
    :header-rows: 1
    
    * - Pad
      - Name
      - Type
      - Summary
    * - ``bidir[0]``
      - RSTn
      - I (PD)
      - Reset input
    * - ``bidir[1]``
      - Blink Slow
      - O
      - Slow frequency LED blink
    * - ``bidir[2]``
      - Blink Fast
      - O
      - High frequency LED blink
    * - ``bidir[3]``
      - Tone
      - O
      - Even higher frequency signal, audible
    * - ``bidir[31:4]``
      - UART TX
      - O
      - 28 copies of the UART TX signal
    * - ``bidir[38:32]``
      - SEG A - G
      - O
      - Segment outputs to 7-segment display LEDs
    * - ``bidir[39]``
      - DP
      - O
      - Output to 7-segment display Decimal Point LED
    * - ``bidir[40]``
      - RNG
      - O
      - Wired to one of the bits in "Diceroll"’s LFSR
    * - ``bidir[41]``
      - ROLL
      - I (PD)
      - Pulsed high to begin dice rolling animation - 
